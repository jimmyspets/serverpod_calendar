import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'invitation_responses_test.dart' show ResponseHost, ResponseTransport;
import 'range_invitations_test.dart' show rangeInvitationBytes;
import 'invitation_cancellation_test.dart' show cancellationBytes;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('durable ordinary recurring response proof', (
    builder,
    endpoints,
  ) {
    late Session session;
    late InvitationTestHost invitations;
    late ResponseHost host;
    late CalendarService service;
    void install({
      bool enabled = true,
      CalendarRecurringResponseOptions? limits,
      bool runtime = true,
      int batchSize = 32,
    }) {
      CalendarModule.install(
        session.serverpod,
        policy: TestPolicy(),
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(
          host: invitations,
          responses: runtime
              ? CalendarInvitationResponseRuntime(
                  host: host,
                  transport: ResponseTransport(),
                  options: CalendarInvitationResponseOptions(
                    batchSize: batchSize,
                    recurringOccurrences:
                        limits ??
                        CalendarRecurringResponseOptions(enabled: enabled),
                  ),
                )
              : null,
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
      install();
    });
    tearDown(() async {
      await session.close();
    });
    Future<CalendarInvitationReceipt> receive(Uint8List bytes) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(
            key: const Uuid().v4obj().toString(),
            bytes: bytes,
          ),
        );
    Uint8List master({bool date = false, String? zone}) => invitationBytes(
      sequence: 1,
      date: date,
      zone: zone,
      extra: ['RRULE:FREQ=DAILY;COUNT=8'],
    );
    Future<CalendarInvitationResponseSelectionEvidenceRecord> latest() async {
      final head = (await CalendarInvitationResponseSelectionHeadRecord.db.find(
        session,
      )).single;
      return (await CalendarInvitationResponseSelectionEvidenceRecord.db
          .findById(session, head.currentEvidenceId!))!;
    }

    for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
      test(
        '$profile fresh enrollment pins exact source and duplicate changes nothing',
        () async {
          final bytes = master(
            date: profile == 'date',
            zone: {'date', 'utc'}.contains(profile) ? null : profile,
          );
          final first = await receive(bytes), before = await latest();
          expect(jsonDecode(before.evidenceJson)['complete'], isTrue);
          expect(
            await CalendarInvitationResponseSelectionSourcePinRecord.db.count(
              session,
            ),
            1,
          );
          await receive(bytes);
          expect((await latest()).id, before.id);
          expect(
            await CalendarInvitationResponseStateRecord.db.count(session),
            0,
          );
          expect(await CalendarEventDataRecord.db.count(session), 0);
          expect(first.entryRevision, 1);
        },
      );
    }
    test(
      'legacy history is not enrolled when a host later enables capture',
      () async {
        install(enabled: false);
        await receive(master());
        install();
        await receive(
          invitationBytes(sequence: 2, extra: ['RRULE:FREQ=DAILY;COUNT=8']),
        );
        expect(
          await CalendarInvitationResponseSelectionHeadRecord.db.count(session),
          0,
        );
      },
    );
    test(
      'a host without response runtime cannot skip capture of enrolled history',
      () async {
        await receive(master());
        final before = await latest();
        install(runtime: false);
        await expectLater(
          receive(
            invitationBytes(sequence: 2, extra: ['RRULE:FREQ=DAILY;COUNT=8']),
          ),
          failure(CalendarFailureCode.unavailable),
        );
        expect((await latest()).id, before.id);
        expect(await CalendarInvitationSourceRecord.db.count(session), 1);
      },
    );
    test(
      'maintenance denial and proof quota roll back the whole intake',
      () async {
        host.denied.add(
          CalendarInvitationResponseOperation.maintainRecurringResponseEvidence,
        );
        await expectLater(
          receive(master()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationRecord.db.count(session), 0);
        host.denied.clear();
        install(
          limits: CalendarRecurringResponseOptions(
            enabled: true,
            maxVersionsPerHead: 1,
          ),
        );
        await receive(master());
        await expectLater(
          receive(
            invitationBytes(sequence: 2, extra: ['RRULE:FREQ=DAILY;COUNT=8']),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await CalendarInvitationSourceRecord.db.count(session), 1);
        expect(
          await CalendarInvitationResponseSelectionEvidenceRecord.db.count(
            session,
          ),
          1,
        );
      },
    );
    test(
      'restore-only received proof is independent of calendar Apply',
      () async {
        await receive(master());
        await receive(rangeInvitationBytes(sequence: 3, cancel: true));
        var data =
            jsonDecode((await latest()).evidenceJson) as Map<String, dynamic>;
        expect((data['cycles'] as List).single['restored'], isNull);
        var restore = utf8.decode(rangeInvitationBytes(sequence: 4));
        restore = restore.replaceFirst(
          'DTSTART:20300101T090000Z',
          'DTSTART:20300102T090000Z',
        );
        final r = await receive(Uint8List.fromList(utf8.encode(restore)));
        data =
            jsonDecode((await latest()).evidenceJson) as Map<String, dynamic>;
        expect(
          (data['cycles'] as List).single['restored'],
          r.sourceId.toString(),
        );
        expect(await CalendarEventDataRecord.db.count(session), 0);
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
      },
    );
    CalendarEventTiming point(int day) => CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2030, month: 1, day: day, hour: 9),
    );
    CalendarInvitationRecurringOccurrenceResponseRequest command(
      CalendarInvitationRecurringOccurrenceResponseView view, {
      CalendarInvitationResponseChoice choice =
          CalendarInvitationResponseChoice.accepted,
    }) => CalendarInvitationRecurringOccurrenceResponseRequest(
      request: CalendarInvitationResponseRequest(
        invitationId: view.masterInvitationId,
        expectedInvitationRevision: view.masterInvitationRevision,
        sourceId: view.membershipSourceId!,
        expectedResponseRevision: view.response.revision,
        commandId: const Uuid().v4obj(),
        choice: choice,
      ),
      openedInvitationId: view.openedInvitationId,
      originalStart: view.originalStart,
      selectionHeadId: view.selectionHeadId,
      expectedSelectionRevision: view.selectionRevision,
      selectionEvidenceId: view.selectionEvidenceId!,
      selectionDigest: view.selectionDigest!,
    );
    test('disabled admission still maintains enrolled proof and reauthorizes retained retries', () async {
      final root = await receive(master());
      final selected = await service.recurringOccurrenceResponse(
        root.entryId,
        point(1),
      );
      final saved = command(selected);
      final first = await service.sendRecurringOccurrenceResponse(saved);
      install(enabled: false);
      await receive(
        invitationBytes(sequence: 2, extra: ['RRULE:FREQ=DAILY;COUNT=8']),
      );
      final current = await service.recurringOccurrenceResponse(
        root.entryId,
        point(1),
      );
      expect(current.selectionRevision, 2);
      expect(current.canSend, isFalse);
      expect(current.blockedReason, 'disabled');
      expect(
        (await service.sendRecurringOccurrenceResponse(saved)).id,
        first.id,
      );
      await expectLater(
        service.sendRecurringOccurrenceResponse(command(current)),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await CalendarInvitationResponseRecord.db.count(session), 1);
    });
    test('whole cancellation and reopening preserve independent source cutoff without calendar Apply', () async {
      final root = await receive(master());
      await receive(rangeInvitationBytes(sequence: 3, cancel: true));
      await receive(cancellationBytes(sequence: 10));
      expect(
        (await service.recurringOccurrenceResponse(
          root.entryId,
          point(1),
        )).canSend,
        isFalse,
      );
      await receive(
        invitationBytes(sequence: 11, extra: ['RRULE:FREQ=DAILY;COUNT=8']),
      );
      expect(
        (await service.recurringOccurrenceResponse(
          root.entryId,
          point(1),
        )).canSend,
        isTrue,
      );
      expect(
        (await service.recurringOccurrenceResponse(
          root.entryId,
          point(3),
        )).canSend,
        isFalse,
      );
      expect(await CalendarEventDataRecord.db.count(session), 0);
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 0);
    });
    test(
      'unlisted original has minimal durable reply and canonical state',
      () async {
        final r = await receive(master());
        final view = await service.recurringOccurrenceResponse(
          r.entryId,
          point(3),
        );
        expect(view.canSend, isTrue);
        expect(view.componentVersion!.sequence, 1);
        final request = command(view),
            receipt = await service.sendRecurringOccurrenceResponse(request);
        expect(
          (await service.sendRecurringOccurrenceResponse(request)).toJson(),
          receipt.toJson(),
        );
        final state = (await CalendarInvitationResponseStateRecord.db.find(
          session,
        )).single;
        expect(state.entryId, r.entryId);
        expect(state.responseOriginalStart!.start.day, 3);
        expect(state.sourceDigest, view.selectionDigest);
        final delivery = (await CalendarInvitationResponseRecord.db.find(
          session,
        )).single;
        expect(delivery.selectionEvidenceId, view.selectionEvidenceId);
        expect(delivery.payload, contains('RECURRENCE-ID:20300103T090000Z'));
        expect(delivery.payload, contains('SEQUENCE:1'));
        expect(delivery.payload, isNot(contains('RANGE=')));
        expect(
          (await service.recurringOccurrenceResponseActivity(
            r.entryId,
            point(3),
          )).length,
          1,
        );
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(
          (await CalendarInvitationResponseRecord.db.findById(
            session,
            delivery.id!,
          ))!.state,
          CalendarInvitationResponseDeliveryState.accepted,
        );
        expect(await CalendarEventDataRecord.db.count(session), 0);
      },
    );
    test('instance and master paths share state and prevent contradictory concurrent choices', () async {
      final r = await receive(master());
      final own = await receive(
        invitationBytes(sequence: 4, extra: ['RECURRENCE-ID:20300103T090000Z']),
      );
      final fromMaster = await service.recurringOccurrenceResponse(
        r.entryId,
        point(3),
      );
      final fromOwn = await service.recurringOccurrenceResponse(
        own.entryId,
        point(3),
      );
      expect(fromOwn.selectionEvidenceId, fromMaster.selectionEvidenceId);
      expect(fromOwn.controllingSourceId, own.sourceId);
      expect(fromOwn.componentVersion!.sequence, 4);
      final first = command(fromMaster),
          other = command(
            fromOwn,
            choice: CalendarInvitationResponseChoice.declined,
          );
      await service.sendRecurringOccurrenceResponse(first);
      await expectLater(
        service.sendRecurringOccurrenceResponse(other),
        failure(CalendarFailureCode.staleRevision),
      );
      final view = await service.recurringOccurrenceResponse(
        own.entryId,
        point(3),
      );
      expect(view.response.revision, 1);
      expect(view.response.choice, CalendarInvitationResponseChoice.accepted);
      final alias = await service.invitationResponse(own.entryId);
      expect(alias.revision, 1);
      expect(alias.canSend, isFalse);
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 1);
    });
    for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
      test(
        '$profile shared read/send/worker preserve original and exact source version',
        () async {
          final date = profile == 'date',
              zone = {'date', 'utc'}.contains(profile) ? null : profile;
          final r = await receive(master(date: date, zone: zone));
          final original = CalendarEventTiming(
            kind: date
                ? CalendarEventTimeKind.date
                : zone == null
                ? CalendarEventTimeKind.utc
                : CalendarEventTimeKind.zoned,
            zoneId: zone,
            start: CalendarEventCivil(
              year: 2030,
              month: 1,
              day: 3,
              hour: date ? 0 : 9,
            ),
          );
          final own = await receive(
            invitationBytes(
              date: date,
              zone: zone,
              sequence: 0,
              extra: [
                date
                    ? 'RECURRENCE-ID;VALUE=DATE:20300103'
                    : zone == null
                    ? 'RECURRENCE-ID:20300103T090000Z'
                    : 'RECURRENCE-ID;TZID=$zone:20300103T090000',
              ],
            ),
          );
          final selected = await service.recurringOccurrenceResponse(
            r.entryId,
            original,
          );
          expect(selected.controllingSourceId, own.sourceId);
          expect(selected.componentVersion!.sequence, 0);
          final receipt = await service.sendRecurringOccurrenceResponse(
            command(selected),
          );
          await CalendarModule.runInvitationResponseMaintenance(session);
          final delivery = (await CalendarInvitationResponseRecord.db.findById(
            session,
            receipt.id,
          ))!;
          expect(
            delivery.state,
            CalendarInvitationResponseDeliveryState.accepted,
          );
          expect(delivery.payload, contains('SEQUENCE:0'));
          expect(delivery.payload, isNot(contains('RANGE=')));
          expect(
            (await service.recurringOccurrenceResponse(
              own.entryId,
              original,
            )).response.revision,
            1,
          );
        },
      );
    }
    test('noncontrolling source change withdraws queued proof but exact retry never reactivates', () async {
      final r = await receive(master());
      final initial = await service.recurringOccurrenceResponse(
        r.entryId,
        point(1),
      );
      final request = command(initial),
          receipt = await service.sendRecurringOccurrenceResponse(request);
      await receive(
        invitationBytes(sequence: 2, extra: ['RECURRENCE-ID:20300103T090000Z']),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(
        (await CalendarInvitationResponseRecord.db.findById(
          session,
          receipt.id,
        ))!.state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      final latestView = await service.recurringOccurrenceResponse(
        r.entryId,
        point(1),
      );
      expect(latestView.componentVersion!.sequence, 1);
      expect(latestView.response.appliesToCurrentSource, isFalse);
      expect(
        (await service.sendRecurringOccurrenceResponse(request)).toJson(),
        receipt.toJson(),
      );
      expect(
        (await CalendarInvitationResponseRecord.db.findById(
          session,
          receipt.id,
        ))!.state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
    });
    test(
      'dedicated read/send permissions and final rollback protect shared state',
      () async {
        final r = await receive(master());
        host.denied.add(
          CalendarInvitationResponseOperation.readRecurringOccurrence,
        );
        await expectLater(
          service.recurringOccurrenceResponse(r.entryId, point(3)),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        final view = await service.recurringOccurrenceResponse(
          r.entryId,
          point(3),
        );
        host.denied.add(
          CalendarInvitationResponseOperation.sendRecurringOccurrence,
        );
        await expectLater(
          service.sendRecurringOccurrenceResponse(command(view)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
        host.denied.clear();
        host.denyFinal = true;
        await expectLater(
          service.sendRecurringOccurrenceResponse(command(view)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
      },
    );
    test('every basis source requires raw read permission before target disclosure', () async {
      final r = await receive(master());
      invitations.denied.add(CalendarInvitationOperation.readSource);
      await expectLater(
        service.recurringOccurrenceResponse(r.entryId, point(3)),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.recurringOccurrenceResponseActivity(r.entryId, point(3)),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('range mask, nonmatching request and restore-only proof do not depend on a native event', () async {
      final r = await receive(master());
      await receive(rangeInvitationBytes(sequence: 3, cancel: true));
      expect(
        (await service.recurringOccurrenceResponse(
          r.entryId,
          point(3),
        )).canSend,
        isFalse,
      );
      expect(
        (await service.recurringOccurrenceResponse(
          r.entryId,
          point(1),
        )).canSend,
        isTrue,
      );
      await receive(rangeInvitationBytes(sequence: 4));
      expect(
        (await service.recurringOccurrenceResponse(
          r.entryId,
          point(3),
        )).canSend,
        isFalse,
      );
      var restore = utf8.decode(rangeInvitationBytes(sequence: 5));
      restore = restore.replaceFirst(
        'DTSTART:20300101T090000Z',
        'DTSTART:20300102T090000Z',
      );
      await receive(Uint8List.fromList(utf8.encode(restore)));
      final reopened = await service.recurringOccurrenceResponse(
        r.entryId,
        point(3),
      );
      expect(reopened.canSend, isTrue);
      expect(reopened.componentVersion!.sequence, 5);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 0);
    });
    test('orphaning master input is unknown coverage until source membership is repaired', () async {
      final r = await receive(master());
      await receive(
        invitationBytes(sequence: 2, extra: ['RECURRENCE-ID:20300103T090000Z']),
      );
      await receive(
        invitationBytes(sequence: 3, extra: ['RRULE:FREQ=DAILY;COUNT=2']),
      );
      final unavailable = await service.recurringOccurrenceResponse(
        r.entryId,
        point(3),
      );
      expect(unavailable.canSend, isFalse);
      expect(unavailable.blockedReason, 'incompleteEvidence');
      await receive(
        invitationBytes(sequence: 4, extra: ['RRULE:FREQ=DAILY;COUNT=8']),
      );
      expect(
        (await service.recurringOccurrenceResponse(
          r.entryId,
          point(3),
        )).canSend,
        isTrue,
      );
    });
    test(
      'missing source pin prevents read and dispatch, without inferred absence',
      () async {
        final r = await receive(master());
        final view = await service.recurringOccurrenceResponse(
          r.entryId,
          point(3),
        );
        final receipt = await service.sendRecurringOccurrenceResponse(
          command(view),
        );
        await CalendarInvitationResponseSelectionSourcePinRecord.db.deleteWhere(
          session,
          where: (t) => t.evidenceId.equals(view.selectionEvidenceId!),
        );
        await expectLater(
          service.recurringOccurrenceResponse(r.entryId, point(3)),
          failure(CalendarFailureCode.unavailable),
        );
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(
          (await CalendarInvitationResponseRecord.db.findById(
            session,
            receipt.id,
          ))!.state,
          isNot(CalendarInvitationResponseDeliveryState.accepted),
        );
      },
    );
    test(
      'restoration flags cannot be forged by recomputing outer proof hashes',
      () async {
        final r = await receive(master());
        await receive(rangeInvitationBytes(sequence: 3, cancel: true));
        await receive(
          rangeInvitationBytes(sequence: 4),
        ); // Different DTSTART: not restoration.
        final row = await latest(),
            data = jsonDecode(row.evidenceJson) as Map<String, dynamic>;
        final current = (data['current'] as List).cast<Map<String, dynamic>>();
        final forged = current.singleWhere(
          (v) => v['target'] != 'master',
        )['source'];
        (data['cycles'] as List).single['restored'] = forged;
        row.evidenceJson = jsonEncode(data);
        row.byteCount = utf8.encode(row.evidenceJson).length;
        final bytes = <int>[];
        for (final part in [
          'recurring-response-evidence-v1',
          row.evidenceJson,
        ]) {
          final raw = utf8.encode(part);
          bytes.addAll(utf8.encode('${raw.length}:'));
          bytes.addAll(raw);
        }
        row.digest = sha256.convert(bytes).toString();
        await CalendarInvitationResponseSelectionEvidenceRecord.db.updateRow(
          session,
          row,
        );
        await expectLater(
          service.recurringOccurrenceResponse(r.entryId, point(3)),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test('nested caller and policy DTO mutation cannot alter a frozen shared command', () async {
      final r = await receive(master());
      final view = await service.recurringOccurrenceResponse(
        r.entryId,
        point(3),
      );
      final request = command(view);
      host.onCheck = (context, tx, phase) async {
        request.request.choice = CalendarInvitationResponseChoice.declined;
        context.request?.choice = CalendarInvitationResponseChoice.tentative;
        if (context.recurringSelection != null) {
          expect(
            () => context.recurringSelection!.packets.clear(),
            throwsUnsupportedError,
          );
          final detached = jsonDecode(
            context.recurringSelection!.snapshotJson,
          ) as Map<String, dynamic>;
          detached['complete'] = false;
        }
      };
      final receipt = await service.sendRecurringOccurrenceResponse(request);
      expect(receipt.choice, CalendarInvitationResponseChoice.accepted);
      expect(
        (await CalendarInvitationResponseRecord.db.findById(
          session,
          receipt.id,
        ))!.choice,
        CalendarInvitationResponseChoice.accepted,
      );
    });
    test('pruning retires unpinned proof but preserves current proof and personal revision', () async {
      final r = await receive(master());
      final selected = await service.recurringOccurrenceResponse(
        r.entryId,
        point(3),
      );
      final receipt = await service.sendRecurringOccurrenceResponse(
        command(selected),
      );
      await receive(
        invitationBytes(sequence: 2, extra: ['RRULE:FREQ=DAILY;COUNT=8']),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      await session.db.unsafeExecute(
        "UPDATE serverpod_calendar_invitation_response SET \"terminalAt\"=clock_timestamp()-interval '32 days' WHERE id=CAST(@id AS uuid)",
        parameters: QueryParameters.named({'id': receipt.id.toString()}),
      );
      await session.db.unsafeExecute(
        "UPDATE calendar_inv_response_selection_evidence SET \"retiredAt\"=clock_timestamp()-interval '32 days' WHERE id=CAST(@id AS uuid)",
        parameters: QueryParameters.named({
          'id': selected.selectionEvidenceId.toString(),
        }),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      expect(
        await CalendarInvitationResponseSelectionEvidenceRecord.db.count(
          session,
        ),
        1,
      );
      expect(
        await CalendarInvitationResponseSelectionSourcePinRecord.db.count(
          session,
        ),
        1,
      );
      final view = await service.recurringOccurrenceResponse(
        r.entryId,
        point(3),
      );
      expect(view.response.revision, 1);
      expect(view.response.choice, CalendarInvitationResponseChoice.accepted);
      expect(view.response.appliesToCurrentSource, isFalse);
      expect(view.canSend, isTrue);
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 1);
    });
    test('non-actionable purged recipient cannot starve another recipient proof cleanup', () async {
      install(batchSize: 1);
      await receive(master());
      final marker =
          (await CalendarInvitationResponseSelectionHeadRecord.db.find(session))
              .single;
      await CalendarInvitationResponseSelectionSourcePinRecord.db.deleteWhere(
        session,
        where: (t) => t.evidenceId.equals(marker.currentEvidenceId!),
      );
      await CalendarInvitationResponseSelectionEvidenceRecord.db.deleteWhere(
        session,
        where: (t) => t.headId.equals(marker.id!),
      );
      await session.db.unsafeExecute(
        "UPDATE calendar_inv_response_selection_head SET state='purged', \"currentEvidenceId\"=NULL, \"purgedAt\"=clock_timestamp()-interval '32 days'",
      );
      invitations.target = const CalendarInvitationRecipient(
        scopeKey: 'test:alice',
        key: 'z-recipient',
        calendarAddress: 'mailto:alice@example.invalid',
      );
      await receive(master());
      await receive(
        invitationBytes(sequence: 2, extra: ['RRULE:FREQ=DAILY;COUNT=8']),
      );
      final other =
          (await CalendarInvitationResponseSelectionHeadRecord.db.find(
            session,
            where: (t) => t.recipientKey.equals('z-recipient'),
          )).single;
      await session.db.unsafeExecute(
        "UPDATE calendar_inv_response_selection_evidence SET \"retiredAt\"=clock_timestamp()-interval '32 days' WHERE \"headId\"=CAST(@head AS uuid) AND id<>CAST(@current AS uuid)",
        parameters: QueryParameters.named({
          'head': other.id!.toString(),
          'current': other.currentEvidenceId!.toString(),
        }),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(
        await CalendarInvitationResponseSelectionEvidenceRecord.db.count(
          session,
          where: (t) => t.headId.equals(other.id!),
        ),
        1,
      );
      expect(
        await CalendarInvitationResponseSelectionHeadRecord.db.findById(
          session,
          marker.id!,
        ),
        isNotNull,
      );
    });
    test('inactive proof scrubs without self-pin deadlock and respects ingress receipt retention', () async {
      final r = await receive(master());
      await service.dismissInvitation(r.entryId, r.entryRevision);
      // Synthetic aging uses database time; no production clock is changed.
      await session.db.unsafeExecute(
        "UPDATE serverpod_calendar_invitation SET \"dismissedAt\"=clock_timestamp()-interval '32 days'",
      );
      await session.db.unsafeExecute(
        "UPDATE serverpod_calendar_invitation_source SET \"inactiveAt\"=clock_timestamp()-interval '32 days'",
      );
      await session.db.unsafeExecute(
        "UPDATE calendar_inv_response_selection_head SET \"updatedAt\"=clock_timestamp()-interval '33 days',\"inactiveAt\"=clock_timestamp()-interval '32 days'",
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      final head = (await CalendarInvitationResponseSelectionHeadRecord.db.find(
        session,
      )).single;
      expect(head.state, 'purged');
      expect(head.currentEvidenceId, isNull);
      expect(
        await CalendarInvitationResponseSelectionEvidenceRecord.db.count(
          session,
        ),
        0,
      );
      expect(
        await CalendarInvitationResponseSelectionSourcePinRecord.db.count(
          session,
        ),
        0,
      );
      expect(
        await CalendarInvitationSourceRecord.db.count(session),
        1,
        reason: 'Unexpired ingress still pins its source',
      );
      await session.db.unsafeExecute(
        "UPDATE serverpod_calendar_invitation_receipt SET \"expiresAt\"=clock_timestamp()-interval '1 day'",
      );
      await session.db.unsafeExecute(
        "UPDATE calendar_inv_response_selection_head SET \"purgedAt\"=clock_timestamp()-interval '32 days'",
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(await CalendarInvitationSourceRecord.db.count(session), 0);
      expect(await CalendarInvitationRecord.db.count(session), 0);
      expect(
        await CalendarInvitationResponseSelectionHeadRecord.db.count(session),
        0,
      );
    });
  });
}
