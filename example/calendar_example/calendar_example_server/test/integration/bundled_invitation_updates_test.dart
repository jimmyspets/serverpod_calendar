import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart' show InvitationTestHost, invitationDelivery;
import 'invitation_bundles_test.dart' show bundleBytes;
import 'test_tools/serverpod_test_tools.dart';

Uint8List updatedBundle({
  int? child,
  int master = 2,
  String? zone,
  bool date = false,
}) {
  var text = utf8.decode(bundleBytes(sequence: master, zone: zone, date: date));
  if (child != null) {
    text = text.replaceFirst(
      'SUMMARY:Single',
      'SEQUENCE:$child\r\nSUMMARY:Child $child',
    );
  }
  return Uint8List.fromList(utf8.encode(text));
}

void main() {
  withServerpod('complete bundled REQUEST updates', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late InvitationTestHost host;
    late CalendarService service;
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
    Future<CalendarInvitationReceipt> receive(Uint8List bytes, String key) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(key: key, bytes: bytes),
        );
    Future<CalendarInvitationAdoptionReceipt> seed({
      bool date = false,
      String? zone,
    }) async {
      final calendar = (await service.create(createInput()))!;
      final source = await receive(
        updatedBundle(date: date, zone: zone),
        'initial',
      );
      return service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: source.entryId,
          expectedRevision: 1,
          sourceId: source.sourceId,
          calendarId: calendar.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
    }

    CalendarInvitationApplyRequest command(
      CalendarInvitationBundleApplicationView view,
    ) => CalendarInvitationApplyRequest(
      invitationId: view.invitationId,
      sourceId: view.incomingSourceId!,
      expectedInvitationRevision: view.invitationRevision!,
      linkId: view.linkId,
      expectedEventRevision: view.eventRevision,
      expectedCalendarRevision: view.calendarRevision,
      expectedApplicationRevision: view.applicationRevision,
    );

    for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
      test(
        '$profile child-only update, immutable latest retry and stable creation receipt',
        () async {
          final date = profile == 'date',
              zone = profile == 'date' || profile == 'utc' ? null : profile;
          final created = await seed(date: date, zone: zone);
          final incoming = await receive(
            updatedBundle(child: 1, date: date, zone: zone),
            'update',
          );
          expect(incoming.outcome, CalendarInvitationOutcome.selected);
          final view = await service.invitationBundleApplication(
            incoming.entryId,
          );
          expect(view.canApply, isTrue);
          expect(
            view.acceptedComponents
                .singleWhere((v) => v.originalStart == null)
                .sequence,
            2,
          );
          final input = command(view);
          final contexts = <CalendarInvitationPolicyContext>[];
          host.onAuthorize = (c, tx, phase) async {
            contexts.add(c);
            if (c.operation == CalendarInvitationOperation.applyBundleUpdate &&
                c.proposedApplication != null) {
              expect(c.currentEvent!.revision, 1);
              expect(c.proposedEvent!.revision, 2);
              expect(c.current!.revision, 3);
              expect(c.current!.dismissedAt, isNull);
              expect(c.proposedRevision, 4);
              expect(c.proposedDismissed, isTrue);
            }
          };
          final result = await service.applyInvitationBundleUpdate(input);
          expect(result.kind, CalendarInvitationSourceKind.requestBundle);
          expect(result.eventRevision, 2);
          expect(result.applicationRevision, 1);
          final data = (await CalendarEventDataRecord.db.find(session)).single;
          expect(data.protocolState!.version.sequence, 2);
          expect(data.protocolState!.overrides.first.version.sequence, 1);
          expect(
            data.timingOverrides!.singles.single.contentOverrides!.summary,
            'Child 1',
          );
          expect(
            (await service.invitationLink(created.invitationId))!.toJson(),
            created.toJson(),
          );
          final scope = (await CalendarScopeRecord.db.find(session))
              .single
              .revision;
          expect(
            (await service.applyInvitationBundleUpdate(input)).toJson(),
            result.toJson(),
          );
          expect(
            (await CalendarScopeRecord.db.find(session)).single.revision,
            scope,
          );
          expect(
            contexts.any(
              (c) =>
                  c.proposedEvent != null &&
                  c.bundleEvidence?.incoming.length == 3,
            ),
            isTrue,
          );
          expect(
            (await service.invitationBundleApplication(incoming.entryId))
                .canApply,
            isFalse,
          );
        },
      );
    }
    test(
      'pending child regression and tied payload reject without mixing sources',
      () async {
        await seed();
        await receive(updatedBundle(child: 2), 'pending');
        await expectLater(
          receive(updatedBundle(child: 1, master: 3), 'incomparable'),
          failure(CalendarFailureCode.validation),
        );
        final tied = utf8
            .decode(updatedBundle(child: 2))
            .replaceFirst('SUMMARY:Child 2', 'SUMMARY:Different');
        await expectLater(
          receive(Uint8List.fromList(utf8.encode(tied)), 'tied'),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarInvitationSourceRecord.db.count(session), 2);
        expect((await CalendarEventRecord.db.find(session)).single.revision, 1);
      },
    );
    test(
      'native edits block new application but never rewrite an exact retry',
      () async {
        final created = await seed();
        await receive(updatedBundle(child: 1), 'first');
        final first = command(
          await service.invitationBundleApplication(created.invitationId),
        );
        final result = await service.applyInvitationBundleUpdate(first);
        final data = (await CalendarEventDataRecord.db.find(session)).single;
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: created.eventId,
            expectedRevision: 2,
            content: data.content.copyWith(summary: 'Private draft'),
          ),
        );
        await receive(updatedBundle(child: 2), 'next');
        final view = await service.invitationBundleApplication(
          created.invitationId,
        );
        expect(view.hasLocalChanges, isTrue);
        expect(view.canApply, isFalse);
        await expectLater(
          service.applyInvitationBundleUpdate(command(view)),
          failure(CalendarFailureCode.dependencyConflict),
        );
        expect(
          (await service.applyInvitationBundleUpdate(first)).toJson(),
          result.toJson(),
        );
        expect(
          (await CalendarEventDataRecord.db.find(session))
              .single
              .content
              .summary,
          'Private draft',
        );
      },
    );
    for (final op in [
      CalendarInvitationOperation.readBundleApplication,
      CalendarInvitationOperation.applyBundleUpdate,
    ]) {
      test('independent $op denies access/application', () async {
        final created = await seed();
        await receive(updatedBundle(child: 1), 'update');
        final view = await service.invitationBundleApplication(
          created.invitationId,
        );
        host.denied.add(op);
        if (op == CalendarInvitationOperation.readBundleApplication) {
          await expectLater(
            service.invitationBundleApplication(created.invitationId),
            failure(CalendarFailureCode.accessDenied),
          );
        }
        await expectLater(
          service.applyInvitationBundleUpdate(command(view)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
        expect((await CalendarEventRecord.db.find(session)).single.revision, 1);
      });
    }
    Future<void> expire({bool keepMarker = false}) async {
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation_receipt SET "expiresAt" = now() - interval \'40 days\'',
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation_source SET "inactiveAt" = now() - interval \'40 days\'',
      );
      await session.db.unsafeExecute(
        keepMarker
            ? 'UPDATE serverpod_calendar_invitation SET "dismissedAt" = now()'
            : 'UPDATE serverpod_calendar_invitation SET "dismissedAt" = now() - interval \'40 days\'',
      );
      await service.listInvitations();
    }

    test('semantic duplicate retains exact ingress identity without reactivating review', () async {
      final created = await seed();
      final variant = Uint8List.fromList(
        utf8.encode(
          utf8
              .decode(updatedBundle())
              .replaceFirst(
                'PRODID:-//Synthetic//EN',
                'PRODID:-//Other envelope//EN',
              ),
        ),
      );
      final scope = (await CalendarScopeRecord.db.find(session))
          .single
          .revision;
      final received = await receive(variant, 'duplicate-envelope');
      expect(received.outcome, CalendarInvitationOutcome.duplicate);
      expect(
        (await receive(variant, 'duplicate-envelope')).toJson(),
        received.toJson(),
      );
      expect(
        (await service.getInvitation(created.invitationId)).dismissedAt,
        isNotNull,
      );
      expect(
        (await service.invitationSource(
          created.invitationId,
          received.sourceId,
        )).text,
        contains('Other envelope'),
      );
      expect(
        (await CalendarScopeRecord.db.find(session)).single.revision,
        scope,
      );
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
    });
    test('latest acceptance survives body/queue expiry, later epochs supersede only update receipts', () async {
      final created = await seed();
      await receive(updatedBundle(child: 1), 'one');
      final first = command(
        await service.invitationBundleApplication(created.invitationId),
      );
      final result = await service.applyInvitationBundleUpdate(first);
      await expire();
      expect(await CalendarInvitationRecord.db.count(session), 0);
      expect(
        (await service.applyInvitationBundleUpdate(first)).toJson(),
        result.toJson(),
      );
      final old = await service.invitationBundleApplication(
        created.invitationId,
      );
      expect(old.acceptedSourceUnavailable, isTrue);
      expect(
        old.acceptedComponents
            .where((v) => v.originalStart != null && !v.isThisAndFuture)
            .single
            .sequence,
        1,
      );
      final incoming = await receive(
        updatedBundle(child: 2, master: 3),
        'new-epoch',
      );
      expect(incoming.entryId, isNot(created.invitationId));
      final next = command(
        await service.invitationBundleApplication(incoming.entryId),
      );
      final second = await service.applyInvitationBundleUpdate(next);
      expect(second.applicationRevision, 2);
      await expectLater(
        service.applyInvitationBundleUpdate(first),
        failure(CalendarFailureCode.staleRevision),
      );
      await expire();
      expect(
        (await service.applyInvitationBundleUpdate(next)).toJson(),
        second.toJson(),
      );
      expect(
        (await service.invitationBundleApplication(incoming.entryId))
            .acceptedSourceUnavailable,
        isTrue,
      );
      expect(
        (await service.invitationLink(created.invitationId))!.toJson(),
        created.toJson(),
      );
      await service.deleteEvent(created.eventId, 3);
      await expectLater(
        service.applyInvitationBundleUpdate(next),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await CalendarEventDataRecord.db.count(session), 0);
      expect(
        (await CalendarInvitationLinkRecord.db.find(session))
            .single
            .bundledRequest,
        isTrue,
      );
    });
    test('missing pending vector evidence never falls back to master ordering', () async {
      await seed();
      await receive(updatedBundle(child: 2), 'pending');
      await expire(keepMarker: true);
      expect(await CalendarInvitationSourceRecord.db.count(session), 0);
      expect(await CalendarInvitationRecord.db.count(session), 1);
      await expectLater(
        receive(updatedBundle(child: 3, master: 3), 'unknown'),
        failure(CalendarFailureCode.unavailable),
      );
      await expire();
      // Expired unaccepted history is not an invented permanent version floor.
      final next = await receive(
        updatedBundle(child: 1, master: 3),
        'accepted-basis',
      );
      expect(next.outcome, CalendarInvitationOutcome.selected);
      expect((await CalendarEventRecord.db.find(session)).single.revision, 1);
    });
    test(
      'incomplete bundles reject before storing any source fragment',
      () async {
        await seed();
        final text = utf8
            .decode(updatedBundle(child: 1))
            .replaceFirst(
              RegExp(
                r'BEGIN:VEVENT\r\nUID:bundle\r\nDTSTAMP:20260102T000000Z\r\nSEQUENCE:12[\s\S]*?END:VEVENT\r\n',
              ),
              '',
            );
        await expectLater(
          receive(Uint8List.fromList(utf8.encode(text)), 'missing-range'),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarInvitationSourceRecord.db.count(session), 1);
      },
    );
    for (final permission in [
      CalendarPermission.readEventSource,
      CalendarPermission.importEvents,
      CalendarPermission.replaceEventsFromImport,
      CalendarPermission.updateEvent,
    ]) {
      test(
        'native $permission remains required for a complete replacement',
        () async {
          final created = await seed();
          await receive(updatedBundle(child: 1), 'update');
          final input = command(
            await service.invitationBundleApplication(created.invitationId),
          );
          policy.denied.add(permission);
          await expectLater(
            service.applyInvitationBundleUpdate(input),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(
            await CalendarInvitationApplicationRecord.db.count(session),
            0,
          );
          expect(
            (await CalendarEventRecord.db.find(session)).single.revision,
            1,
          );
        },
      );
    }
    test('accepted baseline digest corruption is unavailable, never a clean candidate', () async {
      final created = await seed();
      await receive(updatedBundle(child: 1), 'one');
      await service.applyInvitationBundleUpdate(
        command(
          await service.invitationBundleApplication(created.invitationId),
        ),
      );
      final row = (await CalendarInvitationApplicationRecord.db.find(session))
          .single;
      row.baselineDigest = List.filled(64, 'f').join();
      await CalendarInvitationApplicationRecord.db.updateRow(session, row);
      await expectLater(
        service.invitationBundleApplication(created.invitationId),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test('private alarm definitions and acknowledgement survive source application', () async {
      final created = await seed();
      final alarm = (await service.createPersonalAlarm(
        CalendarAlarmCreateRequest(
          parent: CalendarAlarmParent(
            kind: CalendarAlarmParentKind.event,
            id: created.eventId,
          ),
          definition: CalendarAlarmDefinition(absoluteUtc: DateTime.utc(2030)),
        ),
      ))!;
      final time =
          ((await session.db.unsafeQuery(
                    "SELECT date_trunc('second',clock_timestamp())",
                  )).single.single
                  as DateTime)
              .toUtc();
      final action = await CalendarAlarmActionRecord.db.insertRow(
        session,
        CalendarAlarmActionRecord(
          alarmId: alarm.id,
          originalKey: 'item',
          revision: 1,
          acknowledgedAt: time,
          createdAt: time,
          updatedAt: time,
        ),
      );
      final definition = (await CalendarAlarmRecord.db.findById(
        session,
        alarm.id,
      ))!.toJson();
      await receive(updatedBundle(child: 1), 'update');
      final view = await service.invitationBundleApplication(
        created.invitationId,
      );
      expect(view.hasLocalChanges, isFalse);
      await service.applyInvitationBundleUpdate(command(view));
      expect(
        (await CalendarAlarmRecord.db.findById(session, alarm.id))!.toJson(),
        definition,
      );
      expect(
        (await CalendarAlarmActionRecord.db.findById(
          session,
          action.id!,
        ))!.toJson(),
        action.toJson(),
      );
      await service.deleteEvent(created.eventId, 2);
      expect(await CalendarAlarmRecord.db.count(session), 0);
      expect(await CalendarAlarmActionRecord.db.count(session), 0);
    });
    test(
      'retained result revisions must bind the exact original command',
      () async {
        final created = await seed();
        await receive(updatedBundle(child: 1), 'one');
        final input = command(
          await service.invitationBundleApplication(created.invitationId),
        );
        await service.applyInvitationBundleUpdate(input);
        final data = (await CalendarEventDataRecord.db.find(session)).single;
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: created.eventId,
            expectedRevision: 2,
            content: data.content,
          ),
        );
        final row = (await CalendarInvitationApplicationRecord.db.find(session))
            .single;
        row.eventRevision = 3;
        await CalendarInvitationApplicationRecord.db.updateRow(session, row);
        await expectLater(
          service.applyInvitationBundleUpdate(input),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test('a pruned accepted master cannot regress below the immutable creation version', () async {
      final created = await seed();
      await receive(updatedBundle(child: 1), 'one');
      await service.applyInvitationBundleUpdate(
        command(
          await service.invitationBundleApplication(created.invitationId),
        ),
      );
      await expire();
      final proposal = invitationRequestBundleProposal(
        parseIcalendarSchedulingMessage(updatedBundle(child: 1, master: 1)),
      );
      final data = (await CalendarEventDataRecord.db.find(session)).single;
      data.importBaseline = proposal.importBaseline;
      await CalendarEventDataRecord.db.updateRow(session, data);
      final row = (await CalendarInvitationApplicationRecord.db.find(session))
          .single;
      row.sequence = 1;
      // Recompute only this synthetic row's baseline binding to exercise the
      // independently retained creation-version floor rather than a bad digest.
      final bytes = BytesBuilder(copy: false);
      for (final value in [
        proposal.importBaseline.profile,
        proposal.importBaseline.canonicalValue,
      ]) {
        final encoded = utf8.encode(value);
        bytes.add(utf8.encode('${encoded.length}:'));
        bytes.add(encoded);
      }
      row.baselineDigest = sha256.convert(bytes.takeBytes()).toString();
      await CalendarInvitationApplicationRecord.db.updateRow(session, row);
      await expectLater(
        service.invitationBundleApplication(created.invitationId),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test('final policy denial rolls back event, baseline, acceptance and review together', () async {
      final created = await seed();
      await receive(updatedBundle(child: 1), 'update');
      final view = await service.invitationBundleApplication(
        created.invitationId,
      );
      final before = (await CalendarEventDataRecord.db.find(session))
          .single
          .importBaseline!
          .canonicalValue;
      host.denyFinal = true;
      await expectLater(
        service.applyInvitationBundleUpdate(command(view)),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await CalendarEventDataRecord.db.find(session))
            .single
            .importBaseline!
            .canonicalValue,
        before,
      );
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
      expect(
        (await CalendarInvitationRecord.db.find(session)).single.dismissedAt,
        isNull,
      );
    });
  });
}
