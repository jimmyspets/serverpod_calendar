import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('explicit invitation calendar adoption', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late InvitationTestHost host;
    late CalendarService service;
    void install({CalendarInvitationOptions? options, bool enabled = true}) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: enabled
            ? CalendarInvitationRuntime(host: host, options: options)
            : null,
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
    Future<CalendarInvitationReceipt> receive({
      String key = 'one',
      Uint8List? bytes,
    }) => CalendarModule.receiveSchedulingInvitation(
      session,
      invitationDelivery(key: key, bytes: bytes),
    );
    Future<CalendarInvitationAdoptionRequest> request({
      Uint8List? bytes,
    }) async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final receipt = await receive(bytes: bytes);
      return CalendarInvitationAdoptionRequest(
        invitationId: receipt.entryId,
        expectedRevision: 1,
        sourceId: receipt.sourceId,
        calendarId: calendar,
        expectedCalendarRevision: 1,
      );
    }

    Future<void> noEvent() async {
      expect(await CalendarEventRecord.db.count(session), 0);
      expect(await CalendarInvitationLinkRecord.db.count(session), 0);
      expect(
        (await CalendarInvitationRecord.db.find(session)).single.dismissedAt,
        isNull,
      );
    }

    Future<void> expireInbox() async {
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation_receipt SET "expiresAt" = now() - interval \'40 days\'',
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation_source SET "inactiveAt" = now() - interval \'40 days\'',
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation SET "dismissedAt" = now() - interval \'40 days\'',
      );
      await service.listInvitations();
      expect(await CalendarInvitationRecord.db.count(session), 0);
    }

    test('atomic source-preserving imported copy and stable receipt', () async {
      final input = await request(
        bytes: invitationBytes(
          extra: ['DESCRIPTION;LANGUAGE=sv:Text', 'TRANSP:TRANSPARENT'],
        ),
      );
      final contexts = <CalendarInvitationPolicyContext>[];
      host.onAuthorize = (c, tx, phase) async {
        contexts.add(c);
      };
      policy.onEventImport = (session, request, tx, phase) async {
        expect(request.currentEvent, isNull);
        expect(request.proposedEvent, isNotNull);
        expect(request.eventImport!.members.single.protocolUid, 'meeting');
      };
      final receipt = await service.adoptInvitation(input);
      policy.onEventImport = null;
      expect(receipt.invitationRevision, 2);
      expect(receipt.eventRevision, 1);
      final data = (await CalendarEventDataRecord.db.find(session)).single;
      expect(data.origin, CalendarEventOrigin.imported);
      expect(data.protocolUid, 'meeting');
      expect(data.importBaseline, isNotNull);
      expect(data.protocolState!.version.sequence, isNull);
      expect(data.protocolState!.statusPresent, isFalse);
      expect(data.content.status, CalendarEventStatus.confirmed);
      expect(data.content.transparency, CalendarEventTransparency.transparent);
      expect(
        data.protocolState!.sourceMetadata!.contacts.single.value,
        'PRIVATE CONTACT',
      );
      expect(await CalendarAlarmRecord.db.count(session), 0);
      expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      expect(await service.listInvitations(), isEmpty);
      final scope = (await CalendarScopeRecord.db.find(session)).single;
      final again = await service.adoptInvitation(input);
      expect(again.toJson(), receipt.toJson());
      expect(
        (await service.invitationLink(input.invitationId))!.toJson(),
        receipt.toJson(),
      );
      expect(
        (await CalendarScopeRecord.db.find(session)).single.revision,
        scope.revision,
      );
      expect(
        contexts.any(
          (c) =>
              c.proposedEvent?.origin == CalendarEventOrigin.imported &&
              c.link?.eventId == receipt.eventId,
        ),
        isTrue,
      );
      expect(
        contexts.any(
          (c) => c.isRetry && c.currentEvent?.eventId == receipt.eventId,
        ),
        isTrue,
      );
    });
    test('DATE and named-zone end forms survive adoption', () async {
      for (final (i, bytes) in [
        invitationBytes(uid: 'date', date: true),
        invitationBytes(
          uid: 'zone',
          zone: 'Europe/Stockholm',
          extra: ['DURATION:PT1H'],
        ),
      ].indexed) {
        final calendar = (await service.create(createInput('Calendar $i')))!
            .calendarId;
        final received = await receive(key: '$i', bytes: bytes);
        final added = await service.adoptInvitation(
          CalendarInvitationAdoptionRequest(
            invitationId: received.entryId,
            expectedRevision: 1,
            sourceId: received.sourceId,
            calendarId: calendar,
            expectedCalendarRevision: 1,
          ),
        );
        final event = await service.getEvent(
          added.eventId,
          CalendarEventFieldGroup.values,
        );
        expect(
          event.timing!.kind,
          i == 0 ? CalendarEventTimeKind.date : CalendarEventTimeKind.zoned,
        );
        expect(event.timing!.end, isNull);
        if (i == 1) {
          expect(event.timing!.zoneId, 'Europe/Stockholm');
          expect(event.timing!.duration!.hours, 1);
        }
      }
    });
    test('source or parent staleness, dismissed input and different destination reject', () async {
      final input = await request();
      await expectLater(
        service.adoptInvitation(input.copyWith(expectedCalendarRevision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      await receive(key: 'new', bytes: invitationBytes(sequence: 1));
      await expectLater(
        service.adoptInvitation(input),
        failure(CalendarFailureCode.staleRevision),
      );
      await noEvent();
      final current = await service.getInvitation(input.invitationId);
      final next = input.copyWith(
        expectedRevision: current.revision,
        sourceId: current.sourceId!,
      );
      final added = await service.adoptInvitation(next);
      final other = (await service.create(createInput('Other')))!.calendarId;
      await expectLater(
        service.adoptInvitation(next.copyWith(calendarId: other)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(
        (await service.invitationLink(input.invitationId))!.eventId,
        added.eventId,
      );
    });
    test('independent invitation and calendar gates fail atomically', () async {
      final input = await request();
      for (final operation in [
        CalendarInvitationOperation.readSummary,
        CalendarInvitationOperation.readSource,
        CalendarInvitationOperation.adopt,
      ]) {
        host.denied.add(operation);
        await expectLater(
          service.adoptInvitation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        await noEvent();
      }
      for (final permission in [
        CalendarPermission.importEvents,
        CalendarPermission.createEvent,
        CalendarPermission.readEvent,
        CalendarPermission.readEventSource,
      ]) {
        policy.denied.add(permission);
        await expectLater(
          service.adoptInvitation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        await noEvent();
      }
      policy.eventGrants.remove(CalendarEventFieldGroup.comments);
      await expectLater(
        service.adoptInvitation(input),
        failure(CalendarFailureCode.accessDenied),
      );
      await noEvent();
    });
    test('late invitation/calendar denial rolls back event link review and generation', () async {
      final input = await request();
      final before = (await CalendarScopeRecord.db.find(session))
          .single
          .revision;
      host.denyFinal = true;
      await expectLater(
        service.adoptInvitation(input),
        failure(CalendarFailureCode.accessDenied),
      );
      await noEvent();
      expect(
        (await CalendarScopeRecord.db.find(session)).single.revision,
        before,
      );
      host.denyFinal = false;
      policy.denyFinal = true;
      await expectLater(
        service.adoptInvitation(input),
        failure(CalendarFailureCode.accessDenied),
      );
      await noEvent();
    });
    test('cancelled REQUEST is rejected by the pure message profile before adoption', () async {
      await expectLater(
        receive(bytes: invitationBytes(extra: ['STATUS:CANCELLED'])),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarInvitationRecord.db.count(session), 0);
      expect(await CalendarInvitationLinkRecord.db.count(session), 0);
    });
    test(
      'newer source and local edits are not reapplied by retained retry',
      () async {
        final input = await request();
        final added = await service.adoptInvitation(input);
        final data = (await CalendarEventDataRecord.db.find(session)).single;
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: added.eventId,
            expectedRevision: 1,
            content: data.content.copyWith(summary: 'Local draft'),
          ),
        );
        await receive(
          key: 'new',
          bytes: invitationBytes(sequence: 1, summary: 'New source'),
        );
        expect((await service.adoptInvitation(input)).toJson(), added.toJson());
        expect(
          (await service.getEvent(
            added.eventId,
            CalendarEventFieldGroup.values,
          )).summary,
          'Local draft',
        );
        expect(
          (await service.getInvitation(input.invitationId)).dismissedAt,
          isNull,
        );
        final latest = await service.getInvitation(input.invitationId);
        await expectLater(
          service.adoptInvitation(
            input.copyWith(
              sourceId: latest.sourceId!,
              expectedRevision: latest.revision,
            ),
          ),
          failure(CalendarFailureCode.dependencyConflict),
        );
      },
    );
    test('expired inbox retains receipt and new equivalent inbox cannot create another event', () async {
      final input = await request();
      final added = await service.adoptInvitation(input);
      final data = (await CalendarEventDataRecord.db.find(session)).single;
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: added.eventId,
          expectedRevision: 1,
          content: data.content.copyWith(summary: 'Local after creation'),
        ),
      );
      final originalDigest = (await CalendarInvitationLinkRecord.db.find(
        session,
      )).single.sourceDigest;
      await expireInbox();
      final unavailable = <bool>[];
      host.onAuthorize = (c, tx, phase) async {
        if (c.link != null) {
          unavailable.add(c.historicalSourceUnavailable!);
          expect(c.linkSource!.uid, 'meeting');
          expect(c.linkSource!.organizer, 'mailto:organizer@example.invalid');
          expect(c.linkSource!.sourceId, input.sourceId);
          expect(c.linkSource!.sequence, isNull);
          expect(c.linkSource!.stamp, DateTime.utc(2026));
          expect(c.linkSource!.digest, originalDigest);
          expect(c.sourceDigest, originalDigest);
          expect(c.currentEvent!.revision, 2);
          expect(c.currentEvent!.protocolState!.version.sequence, isNotNull);
        }
      };
      expect((await service.adoptInvitation(input)).toJson(), added.toJson());
      expect(
        (await service.invitationLink(input.invitationId))!.eventId,
        added.eventId,
      );
      expect(unavailable, everyElement(isTrue));
      final reappeared = await receive(key: 'again');
      expect(reappeared.entryId, isNot(input.invitationId));
      expect(
        (await service.invitationLink(reappeared.entryId))!.eventId,
        added.eventId,
      );
      await expectLater(
        service.adoptInvitation(
          input.copyWith(
            invitationId: reappeared.entryId,
            sourceId: reappeared.sourceId,
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(await CalendarEventRecord.db.count(session), 1);
    });
    test('link privacy, deleted payload scrubbing and no recreation', () async {
      final input = await request();
      final added = await service.adoptInvitation(input);
      host.denied.add(CalendarInvitationOperation.readLink);
      await expectLater(
        service.invitationLink(input.invitationId),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denied.clear();
      policy.denied.add(CalendarPermission.readEventSource);
      await expectLater(
        service.invitationLink(input.invitationId),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      await service.deleteEvent(added.eventId, 1);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      expect(await CalendarInvitationLinkRecord.db.count(session), 1);
      await expectLater(
        service.adoptInvitation(input),
        failure(CalendarFailureCode.unavailable),
      );
      await expectLater(
        service.invitationLink(input.invitationId),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test(
      'quota permits retained retries and rejects another creation atomically',
      () async {
        install(options: CalendarInvitationOptions(maxLinks: 1));
        final input = await request();
        final added = await service.adoptInvitation(input);
        expect((await service.adoptInvitation(input)).id, added.id);
        final next = await receive(
          key: 'two',
          bytes: invitationBytes(uid: 'other'),
        );
        await expectLater(
          service.adoptInvitation(
            input.copyWith(invitationId: next.entryId, sourceId: next.sourceId),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await CalendarEventRecord.db.count(session), 1);
        expect((await service.getInvitation(next.entryId)).dismissedAt, isNull);
      },
    );
    test(
      'foreign scope/recipient and unavailable mapping fail closed',
      () async {
        final input = await request();
        await service.adoptInvitation(input);
        policy.scopeOverride = 'foreign';
        await expectLater(
          service.invitationLink(input.invitationId),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.scopeOverride = null;
        host.unavailable = true;
        await expectLater(
          service.adoptInvitation(input),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test(
      'linked source replacement rejects even with invitation runtime disabled',
      () async {
        final input = await request();
        final added = await service.adoptInvitation(input);
        final document = utf8
            .decode(invitationBytes())
            .replaceFirst('METHOD:REQUEST\r\n', '');
        install(enabled: false);
        final replacement = CalendarEventReplaceRequest(
          calendarId: input.calendarId,
          expectedRevision: 1,
          selection: [
            CalendarEventExportSelection(
              eventId: added.eventId,
              expectedRevision: 1,
            ),
          ],
          bytes: ByteData.sublistView(
            Uint8List.fromList(utf8.encode(document)),
          ),
        );
        policy.denied.add(CalendarPermission.readEventSource);
        await expectLater(
          service.replaceEventsFromImport(replacement),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        await expectLater(
          service.replaceEventsFromImport(replacement),
          failure(CalendarFailureCode.dependencyConflict),
        );
        expect(
          (await service.getEvent(
            added.eventId,
            CalendarEventFieldGroup.values,
          )).revision,
          1,
        );
      },
    );

    test(
      'active destination UID conflict never adopts an unrelated import',
      () async {
        final input = await request();
        final file = utf8
            .decode(invitationBytes())
            .replaceFirst('METHOD:REQUEST\r\n', '');
        await service.importEvents(
          CalendarEventImportRequest(
            calendarId: input.calendarId,
            expectedRevision: 1,
            bytes: ByteData.sublistView(Uint8List.fromList(utf8.encode(file))),
          ),
        );
        await expectLater(
          service.adoptInvitation(input),
          failure(CalendarFailureCode.dependencyConflict),
        );
        expect(await CalendarEventRecord.db.count(session), 1);
        expect(await CalendarInvitationLinkRecord.db.count(session), 0);
        expect(
          (await service.getInvitation(input.invitationId)).dismissedAt,
          isNull,
        );
      },
    );
    test('dismissed version cannot create a new link', () async {
      final input = await request();
      await service.dismissInvitation(input.invitationId, 1);
      await expectLater(
        service.adoptInvitation(input.copyWith(expectedRevision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      expect(await CalendarEventRecord.db.count(session), 0);
      expect(await CalendarInvitationLinkRecord.db.count(session), 0);
    });
    test('final recipient remapping rolls back all adoption writes', () async {
      final input = await request();
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.adopt &&
            phase == CalendarAuthorizationPhase.finalWrite) {
          host.currentOverride = const CalendarInvitationRecipient(
            scopeKey: 'test:alice',
            key: 'other',
            calendarAddress: 'mailto:other@example.invalid',
          );
        }
      };
      await expectLater(
        service.adoptInvitation(input),
        failure(CalendarFailureCode.unavailable),
      );
      host.currentOverride = null;
      await noEvent();
    });

    test('expired-source link version must agree with the immutable import baseline', () async {
      final input = await request();
      await service.adoptInvitation(input);
      await expireInbox();
      final link = (await CalendarInvitationLinkRecord.db.find(session)).single;
      link.sequence = 42;
      await CalendarInvitationLinkRecord.db.updateRow(session, link);
      await expectLater(
        service.adoptInvitation(input),
        failure(CalendarFailureCode.unavailable),
      );
      await expectLater(
        service.invitationLink(input.invitationId),
        failure(CalendarFailureCode.unavailable),
      );
    });

    test(
      'hidden mutation receipts reject the blind creation profile atomically',
      () async {
        final input = await request();
        policy.hideEventImportBatch = true;
        await expectLater(
          service.adoptInvitation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        await noEvent();
        policy.hideEventImportBatch = false;
        final added = await service.adoptInvitation(input);
        policy.hideEventImportBatch = true;
        await expectLater(
          service.adoptInvitation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await service.invitationLink(input.invitationId))!.eventId,
          added.eventId,
        );
      },
    );
  });
}
