import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'invitation_cancellation_test.dart' show cancellationBytes;
import 'invitation_responses_test.dart' show ResponseHost, ResponseTransport;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('recurring-master recipient workflow', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late InvitationTestHost host;
    late ResponseHost responseHost;
    late ResponseTransport transport;
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
      responseHost = ResponseHost();
      transport = ResponseTransport();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(
          host: host,
          responses: CalendarInvitationResponseRuntime(
            host: responseHost,
            transport: transport,
          ),
        ),
      );
      service = CalendarModule.service(session);
    });
    Uint8List source({
      int? sequence,
      bool date = false,
      String? zone,
      List<String> extra = const [],
      String summary = 'Recurring review',
    }) => invitationBytes(
      sequence: sequence,
      date: date,
      zone: zone,
      summary: summary,
      extra: ['RRULE:FREQ=DAILY;COUNT=3', ...extra],
    );
    Future<CalendarInvitationReceipt> receive(Uint8List bytes) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(
            key: const Uuid().v4obj().toString(),
            bytes: bytes,
          ),
        );
    Future<CalendarInvitationAdoptionReceipt> adopt(
      CalendarInvitationReceipt r,
    ) async {
      final calendar = (await service.create(createInput()))!.calendarId;
      return service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: r.entryId,
          sourceId: r.sourceId,
          expectedRevision: r.entryRevision,
          calendarId: calendar,
          expectedCalendarRevision: 1,
        ),
      );
    }

    Future<CalendarInvitationApplyRequest> applyRequest(UuidValue entry) async {
      final v = await service.invitationApplication(entry);
      return CalendarInvitationApplyRequest(
        invitationId: entry,
        sourceId: v.incomingSourceId!,
        expectedInvitationRevision: v.invitationRevision!,
        linkId: v.linkId,
        expectedEventRevision: v.eventRevision,
        expectedCalendarRevision: v.calendarRevision,
        expectedApplicationRevision: v.applicationRevision,
      );
    }

    Future<CalendarEventDataRecord> data() async =>
        (await CalendarEventDataRecord.db.find(session)).single;
    Future<void> expire(UuidValue id) async {
      final entry = await service.getInvitation(id);
      await service.dismissInvitation(id, entry.revision);
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

    CalendarInvitationResponseRequest response(
      CalendarInvitationReceipt r, {
      CalendarInvitationResponseChoice choice =
          CalendarInvitationResponseChoice.declined,
    }) => CalendarInvitationResponseRequest(
      invitationId: r.entryId,
      expectedInvitationRevision: r.entryRevision,
      sourceId: r.sourceId,
      expectedResponseRevision: 0,
      commandId: const Uuid().v4obj(),
      choice: choice,
    );

    for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
      test(
        '$profile master preserves mode/source and adopts one series',
        () async {
          final r = await receive(
            source(
              date: profile == 'date',
              zone: profile == 'Europe/Stockholm' ? profile : null,
            ),
          );
          expect((await service.getInvitation(r.entryId)).recurring, isTrue);
          expect(await CalendarEventRecord.db.count(session), 0);
          final added = await adopt(r);
          final row = await data();
          expect(row.content.recurrence!.rule!.count, 3);
          expect(row.protocolState!.version.sequence, isNull);
          expect(row.importBaseline, isNotNull);
          expect(await CalendarEventRecord.db.count(session), 1);
          expect(await CalendarAlarmRecord.db.count(session), 0);
          expect(await CalendarInvitationResponseRecord.db.count(session), 0);
          expect(
            (await service.invitationLink(r.entryId))!.eventId,
            added.eventId,
          );
        },
      );
    }
    test(
      'PERIOD additions and exclusions retain lengths and source forms',
      () async {
        final r = await receive(
          source(
            extra: [
              'DTEND:20300101T100000Z',
              'EXDATE:20300102T090000Z',
              'RDATE;VALUE=PERIOD:20300105T090000Z/PT2H',
            ],
          ),
        );
        final added = await adopt(r);
        final preview = await service.previewOccurrences(
          CalendarEventOccurrenceQuery(
            eventId: added.eventId,
            expectedRevision: 1,
            fromUtc: DateTime.utc(2030, 1, 1),
            untilUtc: DateTime.utc(2030, 1, 7),
          ),
        );
        expect(preview.occurrences.map((o) => o.start.day), [1, 3, 5]);
        expect(preview.occurrences.last.endUtc!.hour, 11);
        expect((await data()).content.periods, hasLength(1));
      },
    );
    test(
      'named-zone master keeps civil starts across DST after adoption',
      () async {
        final bytes = Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(source(zone: 'Europe/Stockholm'))
                .replaceAll('20300101T090000', '20300330T090000'),
          ),
        );
        final added = await adopt(await receive(bytes));
        final preview = await service.previewOccurrences(
          CalendarEventOccurrenceQuery(
            eventId: added.eventId,
            expectedRevision: 1,
            fromUtc: DateTime.utc(2030, 3, 29),
            untilUtc: DateTime.utc(2030, 4, 3),
          ),
        );
        expect(preview.occurrences.map((o) => o.start.hour), [9, 9, 9]);
        expect(preview.occurrences.map((o) => o.startUtc!.hour), [8, 7, 7]);
      },
    );
    test('explicit-date-only recurrence is a known recurring mode', () async {
      final r = await receive(
        invitationBytes(extra: ['RDATE:20300105T090000Z']),
      );
      expect((await service.getInvitation(r.entryId)).recurring, isTrue);
      await adopt(r);
      expect((await data()).content.recurrence!.rule, isNull);
      expect((await data()).content.recurrence!.inclusions, hasLength(1));
    });
    test(
      'mode conversions reject in both directions without receipts',
      () async {
        final first = await receive(source());
        await expectLater(
          receive(invitationBytes(sequence: 20)),
          failure(CalendarFailureCode.validation),
        );
        expect((await service.getInvitation(first.entryId)).revision, 1);
        expect(await CalendarInvitationReceiptRecord.db.count(session), 1);
        await expectLater(
          receive(
            invitationBytes(
              uid: 'other',
              extra: [
                'RRULE:FREQ=DAILY;COUNT=2',
                'RECURRENCE-ID:20300101T090000Z',
              ],
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        await receive(invitationBytes(uid: 'nonrec'));
        await expectLater(
          receive(
            invitationBytes(
              uid: 'nonrec',
              sequence: 10,
              extra: ['RRULE:FREQ=DAILY;COUNT=1'],
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarInvitationReceiptRecord.db.count(session), 2);
      },
    );
    test(
      'clean update replaces pattern and retains exact retry result',
      () async {
        final r = await receive(source());
        final added = await adopt(r);
        await receive(
          invitationBytes(
            sequence: 1,
            summary: 'New schedule',
            extra: ['RRULE:FREQ=WEEKLY;COUNT=4'],
          ),
        );
        final request = await applyRequest(r.entryId);
        final applied = await service.applyInvitationUpdate(request);
        expect((await data()).content.recurrence!.rule!.count, 4);
        expect(applied.eventId, added.eventId);
        expect(
          (await service.applyInvitationUpdate(request)).toJson(),
          applied.toJson(),
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      },
    );
    test('local occurrence cancellation protects source replacement', () async {
      final r = await receive(source());
      final added = await adopt(r);
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: added.eventId,
          expectedRevision: 1,
          originalStart: CalendarEventTiming(
            kind: CalendarEventTimeKind.utc,
            start: CalendarEventCivil(year: 2030, month: 1, day: 2, hour: 9),
          ),
          action: CalendarEventOccurrenceAction.cancelSingle,
        ),
      );
      await receive(source(sequence: 1, summary: 'Changed source'));
      expect(
        (await service.invitationApplication(r.entryId)).hasLocalChanges,
        isTrue,
      );
      await expectLater(
        service.applyInvitationUpdate(await applyRequest(r.entryId)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await data()).timingOverrides!.singles.single.cancelled, isTrue);
    });
    test(
      'whole cancellation retains recurrence then explicit REQUEST reopens',
      () async {
        final r = await receive(source());
        await adopt(r);
        await receive(cancellationBytes());
        final notice = await service.getInvitation(r.entryId);
        expect(notice.recurring, isTrue);
        expect((await data()).content.status, CalendarEventStatus.confirmed);
        expect(
          (await service.invitationApplication(r.entryId)).canApplyCancellation,
          isTrue,
        );
        final request = await applyRequest(r.entryId);
        final cancelled = await service.applyInvitationCancellation(request);
        expect((await data()).content.status, CalendarEventStatus.cancelled);
        expect((await data()).content.recurrence!.rule!.count, 3);
        expect(
          (await service.applyInvitationCancellation(request)).toJson(),
          cancelled.toJson(),
        );
        await receive(source(sequence: 2));
        expect((await data()).content.status, CalendarEventStatus.cancelled);
        await service.applyInvitationUpdate(await applyRequest(r.entryId));
        expect((await data()).content.status, CalendarEventStatus.confirmed);
      },
    );
    test(
      'expired queue reconstructs mode only from accepted link baseline',
      () async {
        final r = await receive(source());
        await adopt(r);
        await expire(r.entryId);
        await expectLater(
          receive(invitationBytes(sequence: 10)),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarInvitationRecord.db.count(session), 0);
        final next = await receive(source(sequence: 1));
        expect(next.entryId, isNot(r.entryId));
        expect((await service.getInvitation(next.entryId)).recurring, isTrue);
        expect(await CalendarInvitationLinkRecord.db.count(session), 1);
      },
    );
    test('expired queue whole CANCEL keeps known recurring mode', () async {
      final r = await receive(source());
      await adopt(r);
      await expire(r.entryId);
      final next = await receive(cancellationBytes());
      expect((await service.getInvitation(next.entryId)).recurring, isTrue);
      await service.applyInvitationCancellation(
        await applyRequest(next.entryId),
      );
      expect((await data()).content.recurrence, isNotNull);
    });
    test(
      'retained source-pruned marker preserves mode without an active link',
      () async {
        final r = await receive(source());
        await service.dismissInvitation(r.entryId, r.entryRevision);
        await session.db.unsafeExecute(
          'UPDATE serverpod_calendar_invitation_receipt SET "expiresAt"=now()-interval \'40 days\'',
        );
        await session.db.unsafeExecute(
          'UPDATE serverpod_calendar_invitation_source SET "inactiveAt"=now()-interval \'40 days\'',
        );
        await service.listInvitations();
        final marker = await service.getInvitation(r.entryId);
        expect(marker.sourceId, isNull);
        expect(marker.recurring, isTrue);
        await expectLater(
          receive(invitationBytes(sequence: 10)),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarInvitationSourceRecord.db.count(session), 0);
      },
    );
    test(
      'missing accepted-source evidence cannot reconstruct expired queue mode',
      () async {
        final r = await receive(source());
        await adopt(r);
        await expire(r.entryId);
        final row = await data();
        row.importBaseline = null;
        await CalendarEventDataRecord.db.updateRow(session, row);
        await expectLater(
          receive(source(sequence: 1)),
          failure(CalendarFailureCode.unavailable),
        );
        expect(await CalendarInvitationRecord.db.count(session), 0);
      },
    );
    test(
      'PERIOD-only recurrence keeps mode through minimal cancellation',
      () async {
        final r = await receive(
          invitationBytes(
            extra: [
              'RDATE;VALUE=PERIOD:20300105T090000Z/PT2H',
            ],
          ),
        );
        expect((await service.getInvitation(r.entryId)).recurring, isTrue);
        await adopt(r);
        expect((await data()).content.recurrence, isNotNull);
        expect((await data()).content.periods, hasLength(1));
        await receive(cancellationBytes());
        await service.applyInvitationCancellation(
          await applyRequest(r.entryId),
        );
        expect((await data()).content.periods, hasLength(1));
      },
    );
    test(
      'queue reconstruction uses accepted mode despite a local conversion',
      () async {
        final r = await receive(source());
        final added = await adopt(r);
        final row = await data();
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: added.eventId,
            expectedRevision: 1,
            content: row.content.copyWith(recurrence: null),
          ),
        );
        await expire(r.entryId);
        final next = await receive(source(sequence: 1));
        expect((await service.getInvitation(next.entryId)).recurring, isTrue);
        expect(
          (await service.invitationApplication(next.entryId)).hasLocalChanges,
          isTrue,
        );
        expect((await data()).content.recurrence, isNull);
      },
    );
    test('corrupt mode rejects source review without mutating state', () async {
      final r = await receive(source());
      final row = (await CalendarInvitationRecord.db.find(session)).single;
      row.recurring = false;
      await CalendarInvitationRecord.db.updateRow(session, row);
      await expectLater(
        service.getInvitation(r.entryId),
        failure(CalendarFailureCode.unavailable),
      );
      await expectLater(
        service.listInvitations(),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test(
      'decline without adoption queues a minimal master REPLY and stable retry',
      () async {
        final r = await receive(source());
        final request = response(r);
        final sent = await service.sendInvitationResponse(request);
        expect(
          (await service.sendInvitationResponse(request)).toJson(),
          sent.toJson(),
        );
        await CalendarModule.runInvitationResponseMaintenance(session);
        final outgoing = parseIcalendarSchedulingMessage(
          utf8.encode(transport.submissions.single.payload),
        );
        expect(outgoing.method, IcalendarSchedulingMethod.reply);
        expect(outgoing.events.single.isOverride, isFalse);
        expect(outgoing.events.single.recurrence, isNull);
        expect(outgoing.events.single.startTime, isNull);
        expect(outgoing.events.single.sequence, isNull);
        expect(
          outgoing
              .events
              .single
              .participants
              .attendees
              .single
              .participationStatus,
          'DECLINED',
        );
        expect(await CalendarEventRecord.db.count(session), 0);
      },
    );
    test('new recurring source withdraws pending reply and preserves old choice basis', () async {
      final r = await receive(source());
      await service.sendInvitationResponse(response(r));
      await receive(source(sequence: 1));
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, isEmpty);
      expect(
        (await CalendarInvitationResponseRecord.db.find(session)).single.state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      expect(
        (await service.invitationResponse(r.entryId)).appliesToCurrentSource,
        isFalse,
      );
    });
    test(
      'independent final authority rolls back recurring adoption and response',
      () async {
        final r = await receive(source());
        host.denied.add(CalendarInvitationOperation.adopt);
        await expectLater(adopt(r), failure(CalendarFailureCode.accessDenied));
        expect(await CalendarEventRecord.db.count(session), 0);
        responseHost.denyFinal = true;
        await expectLater(
          service.sendInvitationResponse(response(r)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
      },
    );
  });
}
