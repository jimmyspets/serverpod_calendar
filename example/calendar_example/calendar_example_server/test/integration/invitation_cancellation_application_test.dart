import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart'
    show
        TestPolicy,
        TestAlarmBackgroundPolicy,
        TestAlarmDeliveryPort,
        createInput,
        failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'invitation_cancellation_test.dart' show cancellationBytes;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('explicit cancellation application and reopening', (
    builder,
    endpoints,
  ) {
    late Session session;
    late TestPolicy policy;
    late InvitationTestHost host;
    late CalendarService service;
    late CalendarInvitationAdoptionRequest creation;
    late CalendarInvitationAdoptionReceipt link;
    late UuidValue entryId;
    setUp(() {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      policy = TestPolicy();
      host = InvitationTestHost();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(host: host),
      );
      service = CalendarModule.service(session);
    });
    Future<CalendarInvitationReceipt> receive(Uint8List bytes) async {
      final result = await CalendarModule.receiveSchedulingInvitation(
        session,
        invitationDelivery(key: const Uuid().v4obj().toString(), bytes: bytes),
      );
      entryId = result.entryId;
      return result;
    }

    Future<void> seed({
      bool cancel = true,
      bool date = false,
      String? zone,
    }) async {
      final calendar = (await service.create(createInput()))!;
      final first = await receive(
        invitationBytes(
          summary: 'Original',
          date: date,
          zone: zone,
          extra: [
            if (!date) 'DURATION:PT1H',
            'DESCRIPTION;LANGUAGE=sv:Original description',
            'LOCATION:Original location',
            'URL:https://example.invalid/original',
            'CATEGORIES:Original',
            'CREATED:20250101T000000Z',
            'LAST-MODIFIED:20250102T000000Z',
          ],
        ),
      );
      creation = CalendarInvitationAdoptionRequest(
        invitationId: first.entryId,
        sourceId: first.sourceId,
        expectedRevision: 1,
        calendarId: calendar.calendarId,
        expectedCalendarRevision: 1,
      );
      link = await service.adoptInvitation(creation);
      if (cancel) {
        await receive(
          cancellationBytes(extra: ['DESCRIPTION:Cancellation explanation']),
        );
      }
    }

    Future<CalendarInvitationApplyRequest> request() async {
      final view = await service.invitationApplication(entryId);
      return CalendarInvitationApplyRequest(
        invitationId: entryId,
        sourceId: view.incomingSourceId!,
        expectedInvitationRevision: view.invitationRevision!,
        linkId: link.id,
        expectedEventRevision: view.eventRevision,
        expectedCalendarRevision: view.calendarRevision,
        expectedApplicationRevision: view.applicationRevision,
      );
    }

    Future<CalendarEventDataRecord> data() async =>
        (await CalendarEventDataRecord.db.find(session)).single;
    Future<void> unchanged() async {
      expect((await data()).content.status, CalendarEventStatus.confirmed);
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
      expect((await service.getInvitation(entryId)).dismissedAt, isNull);
    }

    Future<void> local({CalendarEventStatus? status}) async {
      final row = await data();
      final id = (await CalendarEventRecord.db.find(session)).single;
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: link.eventId,
          expectedRevision: id.revision,
          content: status == null
              ? row.content.copyWith(summary: 'Local draft')
              : row.content.copyWith(status: status),
        ),
      );
    }

    Future<void> expire() async {
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation_receipt SET "expiresAt"=now()-interval \'40 days\'',
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation_source SET "inactiveAt"=now()-interval \'40 days\'',
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation SET "dismissedAt"=now()-interval \'40 days\'',
      );
      await service.listInvitations();
    }

    test('minimal cancellation retains content and clears omitted source dates only', () async {
      await seed();
      final before = await data();
      final view = await service.invitationApplication(entryId);
      expect(view.canApplyCancellation, isTrue);
      expect(view.canApply, isFalse);
      final receipt = await service.applyInvitationCancellation(
        await request(),
      );
      expect(receipt.kind, CalendarInvitationSourceKind.meetingCancellation);
      final after = await data();
      expect(
        after.content.toJson(),
        before.content.copyWith(status: CalendarEventStatus.cancelled).toJson(),
      );
      expect(after.protocolUid, before.protocolUid);
      expect(after.origin, CalendarEventOrigin.imported);
      expect(after.createdAt, before.createdAt);
      expect(
        after.protocolState!.sourceMetadata!.toJson(),
        before.protocolState!.sourceMetadata!.toJson(),
      );
      expect(after.protocolState!.statusPresent, isTrue);
      expect(after.protocolState!.version.sequence, 1);
      expect(after.protocolState!.version.stamp, DateTime.utc(2026, 1, 2));
      expect(after.protocolState!.version.created, isNull);
      expect(after.protocolState!.version.lastModified, isNull);
      final accepted = await service.invitationApplication(entryId);
      expect(
        accepted.acceptedKind,
        CalendarInvitationSourceKind.meetingCancellation,
      );
      expect(accepted.hasLocalChanges, isFalse);
      expect(accepted.canApplyCancellation, isFalse);
      expect((await service.adoptInvitation(creation)).id, link.id);
      expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
    });
    test(
      'cancel then newer REQUEST reopens only through explicit update',
      () async {
        await seed();
        final cancelInput = await request();
        await service.applyInvitationCancellation(cancelInput);
        await receive(
          invitationBytes(
            sequence: 2,
            summary: 'Reopened source',
            extra: ['DURATION:PT2H'],
          ),
        );
        var view = await service.invitationApplication(entryId);
        expect(view.currentContent.status, CalendarEventStatus.cancelled);
        expect(
          view.acceptedKind,
          CalendarInvitationSourceKind.meetingCancellation,
        );
        expect(view.canApply, isTrue);
        expect(view.hasLocalChanges, isFalse);
        policy.denied.add(CalendarPermission.changeEventStatus);
        await expectLater(
          service.applyInvitationUpdate(await request()),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        final reopened = await service.applyInvitationUpdate(await request());
        expect(reopened.kind, CalendarInvitationSourceKind.request);
        view = await service.invitationApplication(entryId);
        expect(view.currentContent.status, CalendarEventStatus.confirmed);
        expect(view.currentContent.summary, 'Reopened source');
        expect(view.hasLocalChanges, isFalse);
        await expectLater(
          service.applyInvitationCancellation(cancelInput),
          failure(CalendarFailureCode.staleRevision),
        );
      },
    );
    test('local text and lifecycle changes both block cancellation', () async {
      await seed();
      await local();
      expect(
        (await service.invitationApplication(entryId)).canApplyCancellation,
        isFalse,
      );
      await expectLater(
        service.applyInvitationCancellation(await request()),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await data()).content.summary, 'Local draft');
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
    });
    test(
      'ordinary local cancellation is not adopted as source acceptance',
      () async {
        await seed();
        await local(status: CalendarEventStatus.cancelled);
        await expectLater(
          service.applyInvitationCancellation(await request()),
          failure(CalendarFailureCode.dependencyConflict),
        );
        expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
      },
    );
    test(
      'identical save is clean but stale event revision still rejects',
      () async {
        await seed();
        final old = await request();
        final before = await data();
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: link.eventId,
            expectedRevision: 1,
            content: before.content,
          ),
        );
        expect(
          (await service.invitationApplication(entryId)).hasLocalChanges,
          isFalse,
        );
        await expectLater(
          service.applyInvitationCancellation(old),
          failure(CalendarFailureCode.staleRevision),
        );
        expect(
          (await service.applyInvitationCancellation(await request()))
              .eventRevision,
          3,
        );
      },
    );
    test('summary source link application and dedicated action gates are independent', () async {
      await seed();
      final input = await request();
      for (final op in [
        CalendarInvitationOperation.readSummary,
        CalendarInvitationOperation.readSource,
        CalendarInvitationOperation.readLink,
        CalendarInvitationOperation.readApplication,
        CalendarInvitationOperation.applyCancellation,
      ]) {
        host.denied.add(op);
        await expectLater(
          service.applyInvitationCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        await unchanged();
      }
      host.denied.add(CalendarInvitationOperation.apply);
      expect(
        (await service.applyInvitationCancellation(input)).kind,
        CalendarInvitationSourceKind.meetingCancellation,
      );
    });
    test('native import replacement update lifecycle and source rights are mandatory', () async {
      await seed();
      final input = await request();
      for (final op in [
        CalendarPermission.importEvents,
        CalendarPermission.replaceEventsFromImport,
        CalendarPermission.updateEvent,
        CalendarPermission.changeEventStatus,
        CalendarPermission.readEventSource,
      ]) {
        policy.denied.add(op);
        await expectLater(
          service.applyInvitationCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        await unchanged();
      }
      policy.eventGrants.remove(CalendarEventFieldGroup.location);
      await expectLater(
        service.applyInvitationCancellation(input),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test(
      'late host denial rolls back complete immutable proposed cancellation',
      () async {
        await seed();
        final input = await request();
        final scope = (await CalendarScopeRecord.db.find(session))
            .single
            .revision;
        var saw = false;
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.applyCancellation &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            saw = true;
            expect(
              c.currentApplication!.kind,
              CalendarInvitationSourceKind.request,
            );
            expect(
              c.proposedApplication!.kind,
              CalendarInvitationSourceKind.meetingCancellation,
            );
            expect(
              c.currentEvent!.content.status,
              CalendarEventStatus.confirmed,
            );
            expect(
              c.proposedEvent!.content.status,
              CalendarEventStatus.cancelled,
            );
            expect(
              c.proposedEvent!.content.description,
              c.currentEvent!.content.description,
            );
            expect(
              c.applicationReceipt!.kind,
              CalendarInvitationSourceKind.meetingCancellation,
            );
            expect(
              () => c.proposedEvent!.protocolState!.overrides.clear(),
              throwsUnsupportedError,
            );
            host.denied.add(c.operation);
          }
        };
        await expectLater(
          service.applyInvitationCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(saw, isTrue);
        host.denied.clear();
        host.onAuthorize = null;
        await unchanged();
        expect(
          (await CalendarScopeRecord.db.find(session)).single.revision,
          scope,
        );
      },
    );
    test(
      'native final denial and hidden receipts leave no accepted state',
      () async {
        await seed();
        final input = await request();
        policy.denyFinal = true;
        await expectLater(
          service.applyInvitationCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denyFinal = false;
        await unchanged();
        policy.hideEventImportBatch = true;
        await expectLater(
          service.applyInvitationCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        await unchanged();
      },
    );
    test('latest cancellation retry preserves later local edits and pending REQUEST', () async {
      await seed();
      final input = await request();
      final result = await service.applyInvitationCancellation(input);
      await local();
      await receive(
        invitationBytes(sequence: 2, summary: 'New pending source'),
      );
      final scope = (await CalendarScopeRecord.db.find(session))
          .single
          .revision;
      final before = jsonEncode((await data()).toJson());
      expect(
        (await service.applyInvitationCancellation(input)).toJson(),
        result.toJson(),
      );
      expect(jsonEncode((await data()).toJson()), before);
      expect((await service.getInvitation(entryId)).dismissedAt, isNull);
      expect(
        (await CalendarScopeRecord.db.find(session)).single.revision,
        scope,
      );
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.applyInvitationUpdate(await request()),
        failure(CalendarFailureCode.dependencyConflict),
      );
    });
    test(
      'source expiry retains cancellation kind descriptor and immutable result',
      () async {
        await seed();
        final input = await request();
        final result = await service.applyInvitationCancellation(input);
        await expire();
        var saw = false;
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.applyCancellation &&
              c.historicalSourceUnavailable == true) {
            saw = true;
            expect(c.message, isNull);
            expect(
              c.currentApplication!.kind,
              CalendarInvitationSourceKind.meetingCancellation,
            );
            expect(c.linkSource!.sequence, isNull);
            expect(c.currentApplication!.sequence, 1);
          }
        };
        expect(
          (await service.applyInvitationCancellation(input)).id,
          result.id,
        );
        expect(saw, isTrue);
      },
    );
    test('latest cancellation retry survives two queue epochs', () async {
      await seed(cancel: false);
      await expire();
      await receive(cancellationBytes());
      expect(entryId, isNot(creation.invitationId));
      final input = await request();
      final result = await service.applyInvitationCancellation(input);
      await expire();
      policy.scopeOverride = 'foreign';
      await expectLater(
        service.applyInvitationCancellation(input),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.scopeOverride = null;
      expect((await service.applyInvitationCancellation(input)).id, result.id);
      expect(
        (await service.invitationApplication(creation.invitationId))
            .acceptedKind,
        CalendarInvitationSourceKind.meetingCancellation,
      );
    });
    test(
      'already cancelled new version still requires lifecycle authority',
      () async {
        await seed();
        await service.applyInvitationCancellation(await request());
        final next = await receive(
          cancellationBytes(stamp: '20260103T000000Z'),
        );
        expect(next.outcome, CalendarInvitationOutcome.selected);
        policy.denied.add(CalendarPermission.changeEventStatus);
        await expectLater(
          service.applyInvitationCancellation(await request()),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        final result = await service.applyInvitationCancellation(
          await request(),
        );
        expect(result.applicationRevision, 2);
        expect(
          (await data()).protocolState!.version.stamp,
          DateTime.utc(2026, 1, 3),
        );
      },
    );
    test('wrong method cannot alias either action receipt', () async {
      await seed(cancel: false);
      await receive(invitationBytes(sequence: 1));
      final input = await request();
      await expectLater(
        service.applyInvitationCancellation(input),
        failure(CalendarFailureCode.validation),
      );
      final result = await service.applyInvitationUpdate(input);
      await expectLater(
        service.applyInvitationCancellation(input),
        failure(CalendarFailureCode.staleRevision),
      );
      expect((await service.applyInvitationUpdate(input)).id, result.id);
    });
    test(
      'corrupt accepted kind cannot masquerade as REQUEST baseline',
      () async {
        await seed();
        await service.applyInvitationCancellation(await request());
        final row = (await CalendarInvitationApplicationRecord.db.find(session))
            .single;
        row.kind = CalendarInvitationSourceKind.request;
        await CalendarInvitationApplicationRecord.db.updateRow(session, row);
        await expectLater(
          service.invitationApplication(entryId),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test('accepted cancellation frees busy time and exports retained canonical data', () async {
      await seed();
      final query = CalendarFreeBusyQuery(
        calendarId: link.calendarId,
        fromUtc: DateTime.utc(2030, 1, 1, 8),
        untilUtc: DateTime.utc(2030, 1, 1, 12),
      );
      expect(
        (await service.freeBusy(query)).periods
            .any((p) => p.kind == CalendarFreeBusyKind.busy),
        isTrue,
      );
      final result = await service.applyInvitationCancellation(await request());
      final free = (await service.freeBusy(query)).periods;
      expect(free, hasLength(1));
      expect(free.single.kind, CalendarFreeBusyKind.free);
      expect(free.single.startUtc, query.fromUtc);
      expect(free.single.endUtc, query.untilUtc);
      final bytes = await service.exportEvents(
        CalendarEventExportRequest(
          calendarId: link.calendarId,
          expectedRevision: 1,
          selection: [
            CalendarEventExportSelection(
              eventId: link.eventId,
              expectedRevision: result.eventRevision,
            ),
          ],
        ),
      );
      final text = utf8.decode(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      expect(text, contains('STATUS:CANCELLED'));
      expect(text, contains('SUMMARY:Original'));
      expect(text, contains('DTSTART:20300101T090000Z'));
      expect(text, isNot(contains('Cancellation explanation')));
    });
    test(
      'personal definitions survive and no outbound intent is created',
      () async {
        await seed();
        final alarm = (await service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: CalendarAlarmParent(
              kind: CalendarAlarmParentKind.event,
              id: link.eventId,
            ),
            definition: CalendarAlarmDefinition(
              absoluteUtc: DateTime.utc(2030),
            ),
          ),
        ))!;
        final before = (await CalendarAlarmRecord.db.findById(
          session,
          alarm.id,
        ))!.toJson();
        await service.applyInvitationCancellation(await request());
        expect(
          (await CalendarAlarmRecord.db.findById(session, alarm.id))!.toJson(),
          before,
        );
        expect(await CalendarAlarmFiringRecord.db.count(session), 0);
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      },
    );
    test(
      'explicit source CREATED and LAST-MODIFIED retain exact values',
      () async {
        await seed(cancel: false);
        await receive(
          cancellationBytes(
            extra: [
              'CREATED:20100101T000000Z',
              'LAST-MODIFIED:20110101T000000Z',
            ],
          ),
        );
        await service.applyInvitationCancellation(await request());
        final version = (await data()).protocolState!.version;
        expect(version.created, DateTime.utc(2010));
        expect(version.lastModified, DateTime.utc(2011));
      },
    );
    test(
      'named-zone timing remains unchanged on cancellation',
      () async {
        for (final zone in ['Europe/Stockholm']) {
          await seed(zone: zone);
          final before = (await data()).content.timing.toJson();
          await service.applyInvitationCancellation(await request());
          expect((await data()).content.timing.toJson(), before);
        }
      },
    );

    test('DATE timing remains date-only after cancellation', () async {
      await seed(date: true);
      final before = (await data()).content.timing.toJson();
      await service.applyInvitationCancellation(await request());
      expect((await data()).content.timing.toJson(), before);
      expect((await data()).content.timing.kind, CalendarEventTimeKind.date);
    });
    test('scope and every selected revision remain authoritative', () async {
      await seed();
      final input = await request();
      policy.scopeOverride = 'foreign';
      await expectLater(
        service.applyInvitationCancellation(input),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.scopeOverride = null;
      for (final wrong in [
        input.copyWith(expectedCalendarRevision: 2),
        input.copyWith(expectedEventRevision: 2),
        input.copyWith(expectedInvitationRevision: 99),
        input.copyWith(expectedApplicationRevision: 1),
      ]) {
        await expectLater(
          service.applyInvitationCancellation(wrong),
          failure(CalendarFailureCode.staleRevision),
        );
        await unchanged();
      }
    });
    test(
      'lifecycle and dedicated authority are rechecked for exact retries',
      () async {
        await seed();
        final input = await request();
        final result = await service.applyInvitationCancellation(input);
        policy.denied.add(CalendarPermission.changeEventStatus);
        await expectLater(
          service.applyInvitationCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        host.denied.add(CalendarInvitationOperation.applyCancellation);
        await expectLater(
          service.applyInvitationCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        expect(
          (await service.applyInvitationCancellation(input)).id,
          result.id,
        );
      },
    );

    test('accepted reminder is withdrawn after applied cancellation', () async {
      final delivery = TestAlarmDeliveryPort();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(host: host),
        alarms: CalendarAlarmRuntime(
          policy: TestAlarmBackgroundPolicy(),
          delivery: delivery,
        ),
      );
      service = CalendarModule.service(session);
      await seed();
      final dbNow =
          (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                  .single
                  .single
              as DateTime;
      final due = DateTime.fromMillisecondsSinceEpoch(
        (dbNow.millisecondsSinceEpoch ~/ 1000 - 60) * 1000,
        isUtc: true,
      );
      final parent = CalendarAlarmParent(
        kind: CalendarAlarmParentKind.event,
        id: link.eventId,
      );
      final alarm = (await service.createPersonalAlarm(
        CalendarAlarmCreateRequest(
          parent: parent,
          definition: CalendarAlarmDefinition(absoluteUtc: due),
        ),
      ))!;
      await service.setPersonalAlarmArmed(
        parent,
        alarm.id,
        alarm.revision,
        true,
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(delivery.accepted, hasLength(1));
      final intent = delivery.accepted.values.single;
      expect(
        await CalendarModule.validateAlarmDelivery(session, intent),
        isTrue,
      );
      final definition = (await CalendarAlarmRecord.db.findById(
        session,
        alarm.id,
      ))!.toJson();
      await service.applyInvitationCancellation(await request());
      expect(
        await CalendarModule.validateAlarmDelivery(session, intent),
        isFalse,
      );
      expect(
        (await CalendarAlarmRecord.db.findById(session, alarm.id))!.toJson(),
        definition,
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(delivery.calls, 1);
    });
    test(
      'revision exhaustion cannot leave partial cancellation acceptance',
      () async {
        await seed();
        final row = (await CalendarEventRecord.db.find(session)).single;
        row.revision = 9007199254740991;
        await CalendarEventRecord.db.updateRow(session, row);
        await expectLater(
          service.applyInvitationCancellation(await request()),
          failure(CalendarFailureCode.limitExceeded),
        );
        await unchanged();
      },
    );
    test(
      'required coordinated cancellation cannot downgrade on final check',
      () async {
        policy.capability = CalendarAuthorizationGuarantee.coordinated;
        host.capability = CalendarAuthorizationGuarantee.coordinated;
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.coordinated,
          ),
          invitations: CalendarInvitationRuntime(host: host),
        );
        service = CalendarModule.service(session);
        await seed();
        final input = await request();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.applyCancellation &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.capability = CalendarAuthorizationGuarantee.freshCheck;
          }
        };
        await expectLater(
          service.applyInvitationCancellation(input),
          failure(CalendarFailureCode.unavailable),
        );
        host.capability = CalendarAuthorizationGuarantee.coordinated;
        host.onAuthorize = null;
        await unchanged();
      },
    );
  });
}
