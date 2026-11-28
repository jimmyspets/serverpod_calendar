import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'test_tools/serverpod_test_tools.dart';

Uint8List bundleBytes({
  String uid = 'bundle',
  int sequence = 2,
  bool date = false,
  String? zone,
}) {
  final master = utf8.decode(
    invitationBytes(
      uid: uid,
      sequence: sequence,
      date: date,
      zone: zone,
      extra: ['RRULE:FREQ=DAILY;COUNT=8'],
    ),
  );
  String value(int day) =>
      '2030010$day${date ? '' : 'T090000${zone == null ? 'Z' : ''}'}';
  String prop(String name, int day, {bool future = false}) =>
      '$name${date
          ? ';VALUE=DATE'
          : zone == null
          ? ''
          : ';TZID=$zone'}${future ? ';RANGE=THISANDFUTURE' : ''}:${value(day)}';
  final parts = [
    for (final future in [false, true]) ...[
      'BEGIN:VEVENT',
      'UID:$uid',
      'DTSTAMP:20260102T000000Z',
      if (future) 'SEQUENCE:12',
      prop('RECURRENCE-ID', future ? 5 : 2, future: future),
      prop('DTSTART', future ? 6 : 4),
      'SUMMARY:${future ? 'Range' : 'Single'}',
      'ORGANIZER:mailto:organizer@example.invalid',
      'ATTENDEE:mailto:alice@example.invalid',
      'ATTENDEE:mailto:bob@example.invalid',
      'END:VEVENT',
    ],
  ].join('\r\n');
  return Uint8List.fromList(
    utf8.encode(
      master.replaceFirst('END:VCALENDAR', '$parts\r\nEND:VCALENDAR'),
    ),
  );
}

void main() {
  withServerpod('initial bundled REQUEST adoption', (builder, endpoints) {
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
    Future<CalendarInvitationReceipt> receive({
      Uint8List? bytes,
      String key = 'one',
    }) => CalendarModule.receiveSchedulingInvitation(
      session,
      invitationDelivery(key: key, bytes: bytes ?? bundleBytes()),
    );
    Future<CalendarInvitationAdoptionRequest> request({
      Uint8List? bytes,
    }) async {
      final calendar = (await service.create(createInput()))!;
      final received = await receive(bytes: bytes);
      return CalendarInvitationAdoptionRequest(
        invitationId: received.entryId,
        expectedRevision: 1,
        sourceId: received.sourceId,
        calendarId: calendar.calendarId,
        expectedCalendarRevision: 1,
      );
    }

    for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
      test(
        '$profile one imported series retains all components and retries',
        () async {
          final input = await request(
            bytes: bundleBytes(
              date: profile == 'date',
              zone: profile == 'date' || profile == 'utc' ? null : profile,
            ),
          );
          final contexts = <CalendarInvitationPolicyContext>[];
          host.onAuthorize = (context, tx, phase) async {
            contexts.add(context);
          };
          final result = await service.adoptInvitation(input);
          expect(result.bundledRequest, isTrue);
          final data = (await CalendarEventDataRecord.db.find(session)).single;
          expect(data.origin, CalendarEventOrigin.imported);
          expect(data.timingOverrides!.singles.length, 1);
          expect(data.timingOverrides!.future.length, 1);
          expect(data.protocolState!.version.sequence, 2);
          expect(data.importBaseline, isNotNull);
          expect(await CalendarEventRecord.db.count(session), 1);
          expect(await CalendarAlarmRecord.db.count(session), 0);
          expect(
            await CalendarSchedulingPublicationRecord.db.count(session),
            0,
          );
          expect(
            (await CalendarInvitationLinkRecord.db.find(session))
                .single
                .bundledRequest,
            isTrue,
          );
          expect(
            contexts.any(
              (c) =>
                  c.operation == CalendarInvitationOperation.adoptBundle &&
                  c.message?.events.length == 3 &&
                  c.proposedEvent != null,
            ),
            isTrue,
          );
          final revision = (await CalendarScopeRecord.db.find(session))
              .single
              .revision;
          expect(
            (await service.adoptInvitation(input)).toJson(),
            result.toJson(),
          );
          expect(
            (await service.invitationLink(input.invitationId))!.toJson(),
            result.toJson(),
          );
          expect(
            (await CalendarScopeRecord.db.find(session)).single.revision,
            revision,
          );
          expect(
            (await receive(
              bytes: bundleBytes(
                date: profile == 'date',
                zone: profile == 'date' || profile == 'utc' ? null : profile,
              ),
            )).entryId,
            input.invitationId,
          );
        },
      );
    }
    for (final operation in [
      CalendarInvitationOperation.receive,
      CalendarInvitationOperation.receiveBundle,
    ]) {
      test('independent $operation denial leaves no intake state', () async {
        host.denied.add(operation);
        await expectLater(
          receive(),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationRecord.db.count(session), 0);
        expect(await CalendarInvitationSourceRecord.db.count(session), 0);
      });
    }
    for (final operation in [
      CalendarInvitationOperation.adopt,
      CalendarInvitationOperation.adoptBundle,
      CalendarInvitationOperation.readSource,
    ]) {
      test(
        'independent $operation denial leaves the reviewed bundle intact',
        () async {
          final input = await request();
          host.denied.add(operation);
          await expectLater(
            service.adoptInvitation(input),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(await CalendarEventRecord.db.count(session), 0);
          expect(await CalendarInvitationLinkRecord.db.count(session), 0);
          expect(
            (await CalendarInvitationRecord.db.find(session))
                .single
                .dismissedAt,
            isNull,
          );
        },
      );
    }
    test('different subsequent bundle and single conversion reject without scalar overwrite', () async {
      final received = await receive();
      await expectLater(
        receive(key: 'new', bytes: bundleBytes(sequence: 20)),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        receive(
          key: 'single',
          bytes: invitationBytes(uid: 'bundle', sequence: 30),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await CalendarInvitationRecord.db.find(session)).single.revision,
        1,
      );
      expect(await CalendarInvitationSourceRecord.db.count(session), 1);
      expect((await receive()).sourceId, received.sourceId);
    });
    test('known single cannot convert to a bundle', () async {
      await receive(bytes: invitationBytes(uid: 'bundle'));
      await expectLater(
        receive(key: 'bundle'),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarInvitationSourceRecord.db.count(session), 1);
    });
    for (final permission in [
      CalendarPermission.importEvents,
      CalendarPermission.createEvent,
    ]) {
      test('native $permission denial rolls back bundle adoption', () async {
        final input = await request();
        policy.denied.add(permission);
        await expectLater(
          service.adoptInvitation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarEventRecord.db.count(session), 0);
        expect(await CalendarInvitationLinkRecord.db.count(session), 0);
      });
    }
    test(
      'invalid components reject the entire intake without retained fragments',
      () async {
        final original = utf8.decode(bundleBytes());
        for (final (i, text) in [
          original.replaceFirst(
            'RECURRENCE-ID:20300102',
            'RECURRENCE-ID:20300109',
          ),
          original.replaceFirst(
            'DTSTART:20300104T090000Z',
            'DTSTART:20300104T090000.5Z',
          ),
          original.replaceFirst(
            'ATTENDEE:mailto:bob@example.invalid',
            'ATTENDEE:mailto:other@example.invalid',
          ),
          original.replaceFirst('UID:bundle', 'UID:other'),
        ].indexed) {
          await expectLater(
            receive(
              key: 'invalid-$i',
              bytes: Uint8List.fromList(utf8.encode(text)),
            ),
            failure(CalendarFailureCode.validation),
          );
          expect(await CalendarInvitationRecord.db.count(session), 0);
          expect(await CalendarInvitationSourceRecord.db.count(session), 0);
        }
      },
    );
    test(
      'wrong recipient and lower source budget do not admit a bundle',
      () async {
        host.target = const CalendarInvitationRecipient(
          scopeKey: 'test:alice',
          key: 'alice',
          calendarAddress: 'mailto:other@example.invalid',
        );
        await expectLater(receive(), failure(CalendarFailureCode.accessDenied));
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          ),
          invitations: CalendarInvitationRuntime(
            host: host,
            options: CalendarInvitationOptions(maxSourceBytes: 128),
          ),
        );
        await expectLater(
          receive(),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await CalendarInvitationRecord.db.count(session), 0);
      },
    );
    test('local edits and pruned inbox preserve the frozen bundle receipt and guards', () async {
      final input = await request();
      final added = await service.adoptInvitation(input);
      final data = (await CalendarEventDataRecord.db.find(session)).single;
      expect(data.protocolState!.overrides.map((v) => v.version.sequence), [
        null,
        12,
      ]);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: added.eventId,
          expectedRevision: 1,
          content: data.content.copyWith(summary: 'Private draft'),
        ),
      );
      await expectLater(
        service.invitationApplication(input.invitationId),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.invitationOccurrenceApplication(input.invitationId),
        failure(CalendarFailureCode.validation),
      );
      expect((await service.adoptInvitation(input)).toJson(), added.toJson());
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
      expect((await service.adoptInvitation(input)).toJson(), added.toJson());
      expect(
        (await service.invitationLink(input.invitationId))!.bundledRequest,
        isTrue,
      );
      await expectLater(
        receive(
          key: 'reconstructed',
          bytes: invitationBytes(uid: 'bundle', sequence: 40),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        receive(key: 'new-bundle'),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await CalendarEventDataRecord.db.find(session)).single.content.summary,
        'Private draft',
      );
      await service.deleteEvent(added.eventId, 2);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      expect(
        (await CalendarInvitationLinkRecord.db.find(session))
            .single
            .bundledRequest,
        isTrue,
      );
      await expectLater(
        service.adoptInvitation(input),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await CalendarEventDataRecord.db.count(session), 0);
    });
    test('final adoption denial rolls back all native/link writes', () async {
      final input = await request();
      host.denyFinal = true;
      await expectLater(
        service.adoptInvitation(input),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarEventRecord.db.count(session), 0);
      expect(await CalendarInvitationLinkRecord.db.count(session), 0);
    });
    test(
      'all older application and participation paths reject the whole bundle',
      () async {
        final input = await request();
        final link = await service.adoptInvitation(input);
        final master = CalendarInvitationApplyRequest(
          invitationId: input.invitationId,
          sourceId: input.sourceId,
          expectedInvitationRevision: 2,
          linkId: link.id,
          expectedEventRevision: 1,
          expectedCalendarRevision: 1,
          expectedApplicationRevision: 0,
        );
        final own = CalendarInvitationOccurrenceApplyRequest(
          invitationId: input.invitationId,
          sourceId: input.sourceId,
          linkId: link.id,
          expectedInvitationRevision: 2,
          expectedEventRevision: 1,
          expectedCalendarRevision: 1,
          expectedApplicationRevision: 0,
          expectedOccurrenceRevision: 0,
        );
        for (final action in <Future<Object?> Function()>[
          () => service.invitationApplication(input.invitationId),
          () => service.invitationOccurrenceApplication(input.invitationId),
          () => service.invitationRangeApplication(input.invitationId),
          () =>
              service.invitationRangeRestorationApplication(input.invitationId),
          () => service.applyInvitationUpdate(master),
          () => service.applyInvitationCancellation(master),
          () => service.applyInvitationOccurrenceUpdate(own),
          () => service.applyInvitationOccurrenceCancellation(own),
          () => service.applyInvitationRangeUpdate(own),
          () => service.applyInvitationRangeCancellation(own),
          () => service.applyInvitationRangeRestoration(own),
          () => service.invitationResponse(input.invitationId),
          () => service.invitationResponseActivity(input.invitationId),
          () => service.sendInvitationResponse(
            CalendarInvitationResponseRequest(
              invitationId: input.invitationId,
              expectedInvitationRevision: 2,
              sourceId: input.sourceId,
              expectedResponseRevision: 0,
              commandId: const Uuid().v4obj(),
              choice: CalendarInvitationResponseChoice.accepted,
            ),
          ),
        ]) {
          await expectLater(action(), failure(CalendarFailureCode.validation));
        }
        expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
        expect((await CalendarEventRecord.db.find(session)).single.revision, 1);
      },
    );
  });
}
