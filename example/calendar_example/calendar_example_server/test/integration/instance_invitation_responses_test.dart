import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'invitation_cancellation_test.dart' show cancellationBytes;
import 'instance_invitations_test.dart' show instanceInvitationBytes;
import 'invitation_responses_test.dart' show ResponseHost, ResponseTransport;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('selected occurrence attendee responses', (builder, endpoints) {
    late Session session;
    late InvitationTestHost invitations;
    late ResponseHost host;
    late ResponseTransport transport;
    late CalendarService service;
    void install({CalendarInvitationResponseOptions? options}) {
      CalendarModule.install(
        session.serverpod,
        policy: TestPolicy(),
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(
          host: invitations,
          responses: CalendarInvitationResponseRuntime(
            host: host,
            transport: transport,
            options: options,
          ),
        ),
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
      invitations = InvitationTestHost();
      host = ResponseHost();
      transport = ResponseTransport();
      install();
    });
    Future<CalendarInvitationReceipt> receive(List<int> bytes) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(
            key: const Uuid().v4obj().toString(),
            bytes: Uint8List.fromList(bytes),
          ),
        );
    Future<CalendarInvitationReceipt> master({
      int sequence = 20,
      bool date = false,
      String? zone,
      List<String> extra = const ['RRULE:FREQ=DAILY;COUNT=4'],
    }) => receive(
      invitationBytes(sequence: sequence, date: date, zone: zone, extra: extra),
    );
    Future<CalendarInvitationReceipt> occurrence({
      int? sequence = 2,
      bool date = false,
      String? zone,
      bool cancel = false,
      String? original,
    }) {
      final bytes = instanceInvitationBytes(
        sequence: sequence ?? 2,
        date: date,
        zone: zone,
        cancel: cancel,
        original: original,
      );
      return receive(
        sequence == null
            ? utf8.encode(utf8.decode(bytes).replaceFirst('SEQUENCE:2\r\n', ''))
            : bytes,
      );
    }

    CalendarInvitationResponseRequest command(
      CalendarInvitationReceipt r, {
      CalendarInvitationResponseChoice choice =
          CalendarInvitationResponseChoice.accepted,
    }) => CalendarInvitationResponseRequest(
      invitationId: r.entryId,
      sourceId: r.sourceId,
      expectedInvitationRevision: r.entryRevision,
      expectedResponseRevision: 0,
      commandId: const Uuid().v4obj(),
      choice: choice,
    );
    Future<CalendarInvitationResponseRecord> row() async =>
        (await CalendarInvitationResponseRecord.db.findFirstRow(session))!;
    Future<void> pruneMaster(CalendarInvitationReceipt r) async {
      final entry = (await CalendarInvitationRecord.db.findById(
        session,
        r.entryId,
      ))!;
      entry.currentSourceId = null;
      await CalendarInvitationRecord.db.updateRow(session, entry);
      await CalendarInvitationReceiptRecord.db.deleteWhere(
        session,
        where: (t) => t.sourceId.equals(r.sourceId),
      );
      await CalendarInvitationSourceRecord.db.deleteWhere(
        session,
        where: (t) => t.id.equals(r.sourceId),
      );
    }

    Future<void> noCalendarEffects() async {
      expect(await CalendarEventRecord.db.count(session), 0);
      expect(await CalendarInvitationLinkRecord.db.count(session), 0);
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
    }

    for (final profile in ['utc', 'date', 'Europe/Stockholm']) {
      for (final sequence in <int?>[null, 0, 2]) {
        test(
          '$profile source sequence $sequence retains original, minimal reply and independent authority',
          () async {
            final date = profile == 'date',
                zone = profile == 'Europe/Stockholm' ? profile : null;
            await master(date: date, zone: zone);
            final source = await occurrence(
              sequence: sequence,
              date: date,
              zone: zone,
            );
            final preview = await service.invitationResponse(source.entryId);
            expect(preview.canSend, isTrue);
            expect(preview.originalStart!.start.day, 2);
            final input = command(source),
                receipt = await service.sendInvitationResponse(command(source));
            final stored = await row();
            final parsed = parseIcalendarSchedulingMessage(
              utf8.encode(stored.payload),
            );
            expect(parsed.events.single.sequence, sequence);
            expect(parsed.events.single.isOverride, isTrue);
            expect(
              parsed.events.single.startDate ?? parsed.events.single.startTime,
              isNull,
            );
            expect(
              parsed.events.single.source.entries
                  .whereType<IcalendarSyntaxProperty>()
                  .any((p) => p.canonicalName == 'DTSTART'),
              isFalse,
            );
            expect(stored.payload, isNot(contains('SUMMARY')));
            expect(
              stored.payload,
              contains(
                date
                    ? 'RECURRENCE-ID;VALUE=DATE:20300102'
                    : zone == null
                    ? 'RECURRENCE-ID:20300102T090000Z'
                    : 'RECURRENCE-ID;TZID=Europe/Stockholm:20300102T090000',
              ),
            );
            expect(receipt.stamp.microsecond + receipt.stamp.millisecond, 0);
            expect(
              host.contexts.any(
                (c) =>
                    c.operation ==
                        CalendarInvitationResponseOperation.sendOccurrence &&
                    c.occurrenceBasis != null &&
                    !c.occurrenceBasisUnavailable,
              ),
              isTrue,
            );
            await CalendarModule.runInvitationResponseMaintenance(session);
            expect(
              (await row()).state,
              CalendarInvitationResponseDeliveryState.accepted,
            );
            expect(transport.submissions.single.deliveryKey, receipt.id);
            expect(
              host.contexts
                  .where(
                    (c) =>
                        c.operation ==
                        CalendarInvitationResponseOperation.dispatchOccurrence,
                  )
                  .every((c) => c.actor == null && c.occurrenceBasis != null),
              isTrue,
            );
            expect(
              (await service.invitationResponse(source.entryId)).originalStart!
                  .toJson(),
              preview.originalStart!.toJson(),
            );
            expect(
              (await service.getInvitation(source.entryId)).dismissedAt,
              isNull,
            );
            expect(input.invitationId, receipt.invitationId);
            await noCalendarEffects();
          },
        );
      }
    }
    test('DST original is retained instead of a moved named start', () async {
      Uint8List march(List<int> bytes) => Uint8List.fromList(
        utf8.encode(
          utf8
              .decode(bytes)
              .replaceAll('20300101T090000', '20300330T090000')
              .replaceAll('20300102T090000', '20300331T090000'),
        ),
      );
      await receive(
        march(
          invitationBytes(
            sequence: 20,
            zone: 'Europe/Stockholm',
            extra: ['RRULE:FREQ=DAILY;COUNT=4'],
          ),
        ),
      );
      final source = await receive(
        march(instanceInvitationBytes(sequence: 2, zone: 'Europe/Stockholm')),
      );
      await service.sendInvitationResponse(command(source));
      final parsed = parseIcalendarSchedulingMessage(
        utf8.encode((await row()).payload),
      );
      expect(parsed.events.single.originalTime!.civil.date.month, 3);
      expect(parsed.events.single.originalTime!.civil.date.day, 31);
      expect(parsed.events.single.originalTime!.zoneId, 'Europe/Stockholm');
      expect(parsed.events.single.startTime, isNull);
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(
        (await row()).state,
        CalendarInvitationResponseDeliveryState.accepted,
      );
    });
    test('selected source replacement/cancellation withdraws only its own pending intent', () async {
      await master();
      final source = await occurrence(), input = command(source);
      final receipt = await service.sendInvitationResponse(input);
      await occurrence(sequence: 3);
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(
        (await row()).state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      expect(transport.submissions, isEmpty);
      expect((await service.sendInvitationResponse(input)).id, receipt.id);
      final cancelled = await occurrence(sequence: 4, cancel: true);
      expect(
        (await service.invitationResponse(cancelled.entryId)).canSend,
        isFalse,
      );
      await expectLater(
        service.sendInvitationResponse(
          command(cancelled).copyWith(expectedResponseRevision: 1),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect((await service.invitationResponse(cancelled.entryId)).revision, 1);
      expect(
        (await service.invitationResponseActivity(cancelled.entryId)).single.id,
        receipt.id,
      );
      invitations.denied.add(CalendarInvitationOperation.readSource);
      await expectLater(
        service.invitationResponse(source.entryId),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('instance admission observes existing shared state and payload budgets atomically', () async {
      final m = await master(), source = await occurrence();
      install(
        options: CalendarInvitationResponseOptions(maxStatesPerRecipient: 1),
      );
      await service.sendInvitationResponse(command(m));
      await expectLater(
        service.sendInvitationResponse(command(source)),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 1);
      expect((await service.invitationResponse(source.entryId)).revision, 0);
      install(options: CalendarInvitationResponseOptions(maxPayloadBytes: 64));
      await expectLater(
        service.sendInvitationResponse(command(source)),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 1);
    });
    test('master and sibling participation stay independent without calendar adoption', () async {
      final m = await master(),
          a = await occurrence(),
          b = await occurrence(original: '20300103T090000Z');
      await service.sendInvitationResponse(
        command(m, choice: CalendarInvitationResponseChoice.declined),
      );
      await service.sendInvitationResponse(command(a));
      expect(
        (await service.invitationResponse(m.entryId)).choice,
        CalendarInvitationResponseChoice.declined,
      );
      expect(
        (await service.invitationResponse(a.entryId)).choice,
        CalendarInvitationResponseChoice.accepted,
      );
      expect((await service.invitationResponse(b.entryId)).revision, 0);
      await noCalendarEffects();
    });
    for (final op in [
      CalendarInvitationResponseOperation.send,
      CalendarInvitationResponseOperation.sendOccurrence,
    ]) {
      test(
        'final $op denial rolls back private intent and preserves source',
        () async {
          await master();
          final source = await occurrence();
          host.onCheck = (c, tx, phase) async {
            if (c.operation == op &&
                phase == CalendarAuthorizationPhase.finalWrite) {
              expect(c.occurrenceBasis, isNotNull);
              expect(c.proposedState!.originalStart, isNotNull);
              host.denied.add(op);
            }
          };
          await expectLater(
            service.sendInvitationResponse(command(source)),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(await CalendarInvitationResponseRecord.db.count(session), 0);
          expect(
            await CalendarInvitationResponseStateRecord.db.count(session),
            0,
          );
          expect(
            (await service.getInvitation(source.entryId)).revision,
            source.entryRevision,
          );
        },
      );
    }
    test('known orphan/cancelled master blocks send, withdraws pending and preserves exact retries', () async {
      await master();
      final source = await occurrence(), input = command(source);
      final receipt = await service.sendInvitationResponse(input);
      await master(sequence: 21, extra: ['RRULE:FREQ=DAILY;COUNT=1']);
      expect(
        (await service.invitationResponse(source.entryId)).canSend,
        isFalse,
      );
      expect((await service.sendInvitationResponse(input)).id, receipt.id);
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(
        (await row()).state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      expect(transport.submissions, isEmpty);
      await master(sequence: 22);
      await receive(cancellationBytes(sequence: 23));
      expect(
        (await service.invitationResponse(source.entryId)).canSend,
        isFalse,
      );
      expect((await service.sendInvitationResponse(input)).id, receipt.id);
      host.denied.add(CalendarInvitationResponseOperation.sendOccurrence);
      await expectLater(
        service.sendInvitationResponse(input),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('missing unadopted basis is unavailable and retries rather than inferring absence', () async {
      final m = await master();
      final source = await occurrence(), input = command(source);
      final receipt = await service.sendInvitationResponse(input);
      await pruneMaster(m);
      expect(
        (await service.invitationResponse(source.entryId)).canSend,
        isFalse,
      );
      expect((await service.sendInvitationResponse(input)).id, receipt.id);
      expect(host.contexts.last.occurrenceBasisUnavailable, isTrue);
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(
        (await row()).state,
        CalendarInvitationResponseDeliveryState.retrying,
      );
      expect(transport.submissions, isEmpty);
    });
    test('linked accepted basis survives master-body pruning and private local drafts', () async {
      final m = await master(), source = await occurrence();
      final calendar = (await service.create(createInput()))!;
      await service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: m.entryId,
          sourceId: m.sourceId,
          expectedRevision: m.entryRevision,
          calendarId: calendar.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
      final event = (await CalendarEventDataRecord.db.findFirstRow(session))!;
      event.content = event.content.copyWith(summary: 'Private draft');
      await CalendarEventDataRecord.db.updateRow(session, event);
      await pruneMaster(m);
      expect(
        (await service.invitationResponse(source.entryId)).canSend,
        isTrue,
      );
      await service.sendInvitationResponse(command(source));
      expect(
        host.contexts.last.occurrenceBasis!.kind,
        CalendarInvitationOccurrenceBasisKind.acceptedBaseline,
      );
      expect(
        (await CalendarEventDataRecord.db.findFirstRow(session))!
            .content
            .summary,
        'Private draft',
      );
    });
    test('separate dispatch authority and basis cancellation during submit are enforced', () async {
      await master();
      final source = await occurrence();
      await service.sendInvitationResponse(command(source));
      transport.entered = Completer<void>();
      transport.release = Completer<void>();
      final work = CalendarModule.runInvitationResponseMaintenance(session);
      await transport.entered!.future;
      await receive(cancellationBytes(sequence: 21));
      transport.release!.complete();
      await work;
      expect(transport.submissions, hasLength(1));
      expect(
        (await row()).state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      expect(
        (await CalendarInvitationResponseAttemptRecord.db.findFirstRow(
          session,
        ))!.outcome,
        'accepted',
      );
    });
    test(
      'dispatchOccurrence denial withdraws without transport acceptance',
      () async {
        await master();
        final source = await occurrence();
        await service.sendInvitationResponse(command(source));
        host.denied.add(CalendarInvitationResponseOperation.dispatchOccurrence);
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(
          (await row()).state,
          CalendarInvitationResponseDeliveryState.withdrawn,
        );
        expect(transport.submissions, isEmpty);
      },
    );
    test(
      'final occurrence authorization cannot commit after its lease expires',
      () async {
        install(
          options: CalendarInvitationResponseOptions(
            lease: const Duration(seconds: 2),
            transportTimeout: const Duration(seconds: 1),
          ),
        );
        await master();
        final source = await occurrence();
        final receipt = await service.sendInvitationResponse(command(source));
        var delayed = false;
        host.onCheck = (c, tx, phase) async {
          if (!delayed &&
              transport.submissions.isNotEmpty &&
              c.operation ==
                  CalendarInvitationResponseOperation.dispatchOccurrence) {
            delayed = true;
            await Future<void>.delayed(const Duration(seconds: 3));
          }
        };
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(delayed, isTrue);
        expect(
          (await row()).state,
          CalendarInvitationResponseDeliveryState.claimed,
        );
        expect(
          (await CalendarInvitationResponseStateRecord.db.findFirstRow(
            session,
          ))!.outcome,
          CalendarInvitationResponseDeliveryState.claimed,
        );
        expect(
          (await CalendarInvitationResponseAttemptRecord.db.findFirstRow(
            session,
          ))!.outcome,
          'accepted',
        );
        host.onCheck = null;
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(
          (await row()).state,
          CalendarInvitationResponseDeliveryState.accepted,
        );
        expect((await row()).attemptCount, 2);
        expect(transport.submissions, hasLength(2));
        expect(
          transport.submissions.every(
            (v) =>
                v.deliveryKey == receipt.id &&
                v.payload == transport.submissions.first.payload,
          ),
          isTrue,
        );
      },
    );
    for (final afterSubmit in [false, true]) {
      test(
        'slow final occurrence check respects expiry ${afterSubmit ? 'after acceptance' : 'before submission'}',
        () async {
          install(
            options: CalendarInvitationResponseOptions(
              expiry: const Duration(seconds: 2),
            ),
          );
          await master();
          final source = await occurrence();
          await service.sendInvitationResponse(command(source));
          var delayed = false;
          host.onCheck = (c, tx, phase) async {
            if (!delayed &&
                c.operation ==
                    CalendarInvitationResponseOperation.dispatchOccurrence &&
                phase == CalendarAuthorizationPhase.finalWrite &&
                transport.submissions.isNotEmpty == afterSubmit) {
              delayed = true;
              await Future<void>.delayed(const Duration(seconds: 3));
            }
          };
          await CalendarModule.runInvitationResponseMaintenance(session);
          expect(delayed, isTrue);
          expect(
            (await row()).state,
            CalendarInvitationResponseDeliveryState.expired,
          );
          expect(transport.submissions, hasLength(afterSubmit ? 1 : 0));
          if (afterSubmit) {
            expect(
              (await CalendarInvitationResponseAttemptRecord.db.findFirstRow(
                session,
              ))!.outcome,
              'accepted',
            );
          }
        },
      );
    }
    test('retained payload cannot be rebound to a sibling original', () async {
      await master();
      final source = await occurrence();
      await service.sendInvitationResponse(command(source));
      final stored = await row();
      stored.payload = stored.payload.replaceFirst(
        '20300102T090000Z',
        '20300103T090000Z',
      );
      stored.byteCount = utf8.encode(stored.payload).length;
      stored.payloadDigest = sha256
          .convert(utf8.encode(stored.payload))
          .toString();
      await CalendarInvitationResponseRecord.db.updateRow(session, stored);
      await expectLater(
        service.invitationResponseActivity(source.entryId),
        failure(CalendarFailureCode.unavailable),
      );
    });
  });
}
