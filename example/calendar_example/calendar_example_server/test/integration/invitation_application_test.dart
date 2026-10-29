import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('explicit linked invitation updates', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late InvitationTestHost host;
    late CalendarService service;
    late CalendarInvitationAdoptionRequest creation;
    late CalendarInvitationAdoptionReceipt link;
    late UuidValue entryId;
    void install({
      CalendarAuthorizationGuarantee required =
          CalendarAuthorizationGuarantee.freshCheck,
    }) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: CalendarModuleOptions(requiredWriteGuarantee: required),
        invitations: CalendarInvitationRuntime(host: host),
      );
      service = CalendarModule.service(session);
    }

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
      install();
    });
    Future<void> seed({Uint8List? bytes}) async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final first = await CalendarModule.receiveSchedulingInvitation(
        session,
        invitationDelivery(
          bytes: bytes ?? invitationBytes(summary: 'Original'),
        ),
      );
      entryId = first.entryId;
      creation = CalendarInvitationAdoptionRequest(
        invitationId: entryId,
        sourceId: first.sourceId,
        expectedRevision: 1,
        calendarId: calendar,
        expectedCalendarRevision: 1,
      );
      link = await service.adoptInvitation(creation);
    }

    Future<CalendarInvitationReceipt> incoming({
      int? sequence = 1,
      String stamp = '20260101T000000Z',
      String summary = 'Changed',
      List<String> extra = const [],
    }) async {
      final received = await CalendarModule.receiveSchedulingInvitation(
        session,
        invitationDelivery(
          key: const Uuid().v4obj().toString(),
          bytes: invitationBytes(
            sequence: sequence,
            stamp: stamp,
            summary: summary,
            extra: extra,
          ),
        ),
      );
      entryId = received.entryId;
      return received;
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
      expect((await data()).content.summary, 'Original');
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
      expect((await service.getInvitation(entryId)).dismissedAt, isNull);
    }

    Future<void> localEdit() async {
      final row = await data();
      final identity = (await CalendarEventRecord.db.find(session)).single;
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: link.eventId,
          expectedRevision: identity.revision,
          content: row.content.copyWith(summary: 'Local draft'),
        ),
      );
    }

    Future<void> expireInbox() async {
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
      expect(await CalendarInvitationRecord.db.count(session), 0);
    }

    test('initial projection has no checkpoint and first update preserves creation identity', () async {
      await seed();
      final initial = await service.invitationApplication(entryId);
      expect(initial.applicationRevision, 0);
      expect(initial.acceptedSequence, isNull);
      expect(initial.canApply, isFalse);
      expect(initial.hasLocalChanges, isFalse);
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
      await incoming(
        extra: [
          'DESCRIPTION;LANGUAGE=sv:Ny text',
          'PRIORITY:3',
          'URL:https://example.invalid/meeting',
        ],
      );
      final preview = await service.invitationApplication(entryId);
      expect(preview.currentContent.summary, 'Original');
      expect(preview.incomingContent!.summary, 'Changed');
      expect(preview.incomingSourceText, contains('METHOD:REQUEST'));
      final old = await data();
      final result = await service.applyInvitationUpdate(await request());
      expect(result.eventId, link.eventId);
      expect(result.eventRevision, 2);
      expect(result.applicationRevision, 1);
      final updated = await data();
      expect(updated.createdAt, old.createdAt);
      expect(updated.origin, CalendarEventOrigin.imported);
      expect(updated.content.description, 'Ny text');
      expect(updated.content.textParameters!.description!.language, 'sv');
      expect(updated.protocolState!.version.sequence, 1);
      expect(updated.protocolState!.statusPresent, isFalse);
      expect(updated.importBaseline!.canonicalValue, contains('Changed'));
      expect((await service.getInvitation(entryId)).dismissedAt, isNotNull);
      expect(
        (await service.invitationLink(creation.invitationId))!.toJson(),
        link.toJson(),
      );
      expect((await service.adoptInvitation(creation)).toJson(), link.toJson());
      expect(
        (await service.invitationApplication(entryId)).latestResult!.toJson(),
        result.toJson(),
      );
      expect(
        (await CalendarIdentityRecord.db.find(session)).single.revision,
        1,
      );
      expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      expect(await CalendarAlarmRecord.db.count(session), 0);
    });
    test('latest retry preserves local edits and newer pending source without generation changes', () async {
      await seed();
      await incoming();
      final input = await request();
      final result = await service.applyInvitationUpdate(input);
      await localEdit();
      await incoming(sequence: 2, summary: 'Newer pending');
      final generation = (await CalendarScopeRecord.db.find(session))
          .single
          .revision;
      expect(
        (await service.applyInvitationUpdate(input)).toJson(),
        result.toJson(),
      );
      expect((await data()).content.summary, 'Local draft');
      expect((await service.getInvitation(entryId)).dismissedAt, isNull);
      expect(
        (await CalendarScopeRecord.db.find(session)).single.revision,
        generation,
      );
      expect(
        (await service.invitationApplication(entryId)).hasLocalChanges,
        isTrue,
      );
    });
    test('older commands become stale after another application', () async {
      await seed();
      await incoming();
      final first = await request();
      final a = await service.applyInvitationUpdate(first);
      await incoming(sequence: 2, summary: 'Second update');
      final second = await request();
      final b = await service.applyInvitationUpdate(second);
      expect(a.id, isNot(b.id));
      expect(b.applicationRevision, 2);
      await expectLater(
        service.applyInvitationUpdate(first),
        failure(CalendarFailureCode.staleRevision),
      );
      expect((await data()).content.summary, 'Second update');
      expect(await CalendarInvitationApplicationRecord.db.count(session), 1);
      expect((await service.adoptInvitation(creation)).id, link.id);
    });
    test('local changes reject even a much higher source sequence', () async {
      await seed();
      await localEdit();
      await incoming(sequence: 999);
      final view = await service.invitationApplication(entryId);
      expect(view.hasLocalChanges, isTrue);
      expect(view.canApply, isFalse);
      await expectLater(
        service.applyInvitationUpdate(await request()),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await data()).content.summary, 'Local draft');
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
    });
    test('identical native save advances API revision without inventing a content conflict', () async {
      await seed();
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: link.eventId,
          expectedRevision: 1,
          content: (await data()).content,
        ),
      );
      await incoming();
      expect(
        (await service.invitationApplication(entryId)).hasLocalChanges,
        isFalse,
      );
      expect(
        (await service.applyInvitationUpdate(await request())).eventRevision,
        3,
      );
    });
    test('sequence omission remains distinct from zero and higher sequence permits earlier stamp', () async {
      await seed(bytes: invitationBytes(summary: 'Original', sequence: 0));
      await incoming(sequence: null, stamp: '20260102T000000Z');
      await service.applyInvitationUpdate(await request());
      expect(
        (await service.invitationApplication(entryId)).acceptedSequence,
        isNull,
      );
      expect((await data()).protocolState!.version.sequence, isNull);
      await incoming(sequence: 5, stamp: '20250101T000000Z');
      await service.applyInvitationUpdate(await request());
      expect((await data()).protocolState!.version.stamp, DateTime.utc(2025));
    });
    test('expired marker does not allow lower or tied source versions to overwrite acceptance', () async {
      await seed();
      await incoming(sequence: 2);
      await service.applyInvitationUpdate(await request());
      await expireInbox();
      await incoming(sequence: 1, summary: 'Older');
      expect((await service.invitationApplication(entryId)).canApply, isFalse);
      await expectLater(
        service.applyInvitationUpdate(await request()),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.dismissInvitation(entryId, 1);
      await expireInbox();
      await incoming(sequence: 2, summary: 'Different same version');
      await expectLater(
        service.applyInvitationUpdate(await request()),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await data()).content.summary, 'Changed');
    });
    test('source and parent revisions are authoritative', () async {
      await seed();
      await incoming();
      final input = await request();
      await expectLater(
        service.applyInvitationUpdate(
          input.copyWith(expectedCalendarRevision: 2),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.applyInvitationUpdate(
          input.copyWith(expectedApplicationRevision: 1),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      await incoming(sequence: 2);
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.staleRevision),
      );
      await unchanged();
    });
    test('independent invitation and full native read gates protect conflict classification', () async {
      await seed();
      await incoming();
      final input = await request();
      for (final op in [
        CalendarInvitationOperation.readSummary,
        CalendarInvitationOperation.readSource,
        CalendarInvitationOperation.readLink,
        CalendarInvitationOperation.readApplication,
        CalendarInvitationOperation.apply,
      ]) {
        host.denied.add(op);
        await expectLater(
          service.applyInvitationUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        await unchanged();
      }
      policy.denied.add(CalendarPermission.readEventSource);
      await expectLater(
        service.invitationApplication(entryId),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.eventGrants.remove(CalendarEventFieldGroup.location);
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.accessDenied),
      );
      await unchanged();
    });
    test(
      'native import replacement content and metadata gates remain independent',
      () async {
        await seed();
        await incoming(
          extra: ['URL:https://example.invalid/new', 'PRIORITY:2'],
        );
        final input = await request();
        for (final op in [
          CalendarPermission.importEvents,
          CalendarPermission.replaceEventsFromImport,
          CalendarPermission.updateEvent,
          CalendarPermission.updateEventTextMetadata,
          CalendarPermission.updateEventDescriptiveMetadata,
        ]) {
          policy.denied.add(op);
          await expectLater(
            service.applyInvitationUpdate(input),
            failure(CalendarFailureCode.accessDenied),
          );
          policy.denied.clear();
          await unchanged();
        }
      },
    );
    test('late host denial rolls back all rows and exposes immutable current/proposed state', () async {
      await seed();
      await incoming();
      final input = await request();
      final generation = (await CalendarScopeRecord.db.find(session))
          .single
          .revision;
      var sawFinal = false;
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.apply &&
            phase == CalendarAuthorizationPhase.finalWrite) {
          host.denyFinal = true;
          sawFinal = true;
          expect(c.currentEvent!.content.summary, 'Original');
          expect(c.proposedEvent!.content.summary, 'Changed');
          expect(c.currentApplication!.revision, 0);
          expect(c.proposedApplication!.revision, 1);
          expect(c.linkSource!.sequence, isNull);
          expect(c.proposedApplication!.sequence, 1);
          expect(c.applicationReceipt!.eventRevision, 2);
        }
      };
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(sawFinal, isTrue);
      await unchanged();
      expect(
        (await CalendarScopeRecord.db.find(session)).single.revision,
        generation,
      );
    });
    test(
      'native final denial and hidden mutation receipts roll back changes',
      () async {
        await seed();
        await incoming();
        final input = await request();
        policy.denyFinal = true;
        await expectLater(
          service.applyInvitationUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        await unchanged();
        policy.denyFinal = false;
        policy.hideEventImportBatch = true;
        await expectLater(
          service.applyInvitationUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        await unchanged();
      },
    );
    test('latest retry after expiry preserves accepted versus original source descriptors', () async {
      await seed();
      await incoming();
      final input = await request();
      final result = await service.applyInvitationUpdate(input);
      await localEdit();
      await expireInbox();
      var sawMissing = false;
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.apply &&
            c.historicalSourceUnavailable == true) {
          sawMissing = true;
          expect(c.message, isNull);
          expect(c.normalizedSource, isNull);
          expect(c.linkSource!.sequence, isNull);
          expect(c.currentApplication!.sequence, 1);
          expect(c.currentApplication!.eventRevision, 2);
          expect(c.currentEvent!.revision, 3);
          expect(c.sourceDigest, c.currentApplication!.digest);
        }
      };
      expect(
        (await service.applyInvitationUpdate(input)).toJson(),
        result.toJson(),
      );
      expect(sawMissing, isTrue);
      expect((await service.adoptInvitation(creation)).toJson(), link.toJson());
      expect(
        (await service.invitationApplication(creation.invitationId))
            .applicationRevision,
        1,
      );
    });
    test('missing or corrupt checkpoint fails unavailable without initial-state fallback', () async {
      await seed();
      await incoming();
      final input = await request();
      await service.applyInvitationUpdate(input);
      final checkpoint = (await CalendarInvitationApplicationRecord.db.find(
        session,
      )).single;
      await CalendarInvitationApplicationRecord.db.deleteRow(
        session,
        checkpoint,
      );
      await expectLater(
        service.invitationApplication(entryId),
        failure(CalendarFailureCode.unavailable),
      );
      await CalendarInvitationApplicationRecord.db.insertRow(
        session,
        checkpoint,
      );
      checkpoint.creationDigest = '0' * 64;
      await CalendarInvitationApplicationRecord.db.updateRow(
        session,
        checkpoint,
      );
      await expectLater(
        service.adoptInvitation(creation),
        failure(CalendarFailureCode.unavailable),
      );
      expect((await data()).content.summary, 'Changed');
    });
    test(
      'native deletion scrubs content and never recreates linked events',
      () async {
        await seed();
        await incoming();
        final input = await request();
        await service.applyInvitationUpdate(input);
        await service.deleteEvent(link.eventId, 2);
        expect(await CalendarEventDataRecord.db.count(session), 0);
        expect(await CalendarInvitationApplicationRecord.db.count(session), 1);
        await expectLater(
          service.applyInvitationUpdate(input),
          failure(CalendarFailureCode.unavailable),
        );
        await expectLater(
          service.adoptInvitation(creation),
          failure(CalendarFailureCode.unavailable),
        );
        await service.delete(link.calendarId, 1);
      },
    );
    test(
      'personal definitions survive source updates without arming or delivery',
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
        await incoming();
        await service.applyInvitationUpdate(await request());
        expect(
          (await CalendarAlarmRecord.db.findById(session, alarm.id))!.toJson(),
          before,
        );
        expect(await CalendarAlarmFiringRecord.db.count(session), 0);
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      },
    );
    test('foreign scope and final recipient remapping cannot apply', () async {
      await seed();
      await incoming();
      final input = await request();
      policy.scopeOverride = 'foreign';
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.scopeOverride = null;
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.apply &&
            phase == CalendarAuthorizationPhase.finalWrite) {
          host.currentOverride = const CalendarInvitationRecipient(
            scopeKey: 'test:alice',
            key: 'other',
            calendarAddress: 'mailto:other@example.invalid',
          );
        }
      };
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.unavailable),
      );
      host.currentOverride = null;
      await unchanged();
    });

    test('valid lifecycle changes require separate status authority', () async {
      await seed(
        bytes: invitationBytes(
          summary: 'Original',
          extra: ['STATUS:TENTATIVE'],
        ),
      );
      await incoming();
      final input = await request();
      policy.denied.add(CalendarPermission.changeEventStatus);
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.accessDenied),
      );
      await unchanged();
      policy.denied.clear();
      await service.applyInvitationUpdate(input);
      expect((await data()).content.status, CalendarEventStatus.confirmed);
      expect((await data()).protocolState!.statusPresent, isFalse);
    });
    test(
      'complete DATE UTC and named-zone replacements retain timing meaning',
      () async {
        await seed(bytes: invitationBytes(summary: 'Original', date: true));
        await incoming();
        await service.applyInvitationUpdate(await request());
        expect((await data()).content.timing.kind, CalendarEventTimeKind.utc);
        final source = await CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(
            key: 'zone-update',
            bytes: invitationBytes(
              sequence: 2,
              zone: 'Europe/Stockholm',
              extra: ['DURATION:PT1H'],
            ),
          ),
        );
        entryId = source.entryId;
        await service.applyInvitationUpdate(await request());
        final timing = (await data()).content.timing;
        expect(timing.kind, CalendarEventTimeKind.zoned);
        expect(timing.zoneId, 'Europe/Stockholm');
        expect(timing.duration!.hours, 1);
        expect((await service.adoptInvitation(creation)).eventId, link.eventId);
      },
    );

    test(
      'revision exhaustion rejects without partial application state',
      () async {
        await seed();
        await incoming();
        final identity = (await CalendarEventRecord.db.find(session)).single;
        identity.revision = 9007199254740991;
        await CalendarEventRecord.db.updateRow(session, identity);
        await expectLater(
          service.applyInvitationUpdate(await request()),
          failure(CalendarFailureCode.limitExceeded),
        );
        await unchanged();
      },
    );
    test(
      'coordinated policy cannot downgrade during final application checks',
      () async {
        policy.capability = CalendarAuthorizationGuarantee.coordinated;
        host.capability = CalendarAuthorizationGuarantee.coordinated;
        install(required: CalendarAuthorizationGuarantee.coordinated);
        await seed();
        await incoming();
        final input = await request();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.apply &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.capability = CalendarAuthorizationGuarantee.freshCheck;
          }
        };
        await expectLater(
          service.applyInvitationUpdate(input),
          failure(CalendarFailureCode.unavailable),
        );
        host.capability = CalendarAuthorizationGuarantee.coordinated;
        await unchanged();
      },
    );

    test('another invitation UID cannot target an existing link', () async {
      await seed();
      final other = await CalendarModule.receiveSchedulingInvitation(
        session,
        invitationDelivery(
          key: 'other-uid',
          bytes: invitationBytes(uid: 'another-meeting', sequence: 1),
        ),
      );
      final input = CalendarInvitationApplyRequest(
        invitationId: other.entryId,
        sourceId: other.sourceId,
        expectedInvitationRevision: 1,
        linkId: link.id,
        expectedEventRevision: 1,
        expectedCalendarRevision: 1,
        expectedApplicationRevision: 0,
      );
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.accessDenied),
      );
      expect((await data()).content.summary, 'Original');
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
    });
  });
}
