import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'instance_invitations_test.dart' show instanceInvitationBytes;
import 'range_invitations_test.dart' show rangeInvitationBytes;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('first durable range cancellation', (
    builder,
    endpoints,
  ) {
    late Session session;
    late InvitationTestHost host;
    late TestPolicy policy;
    late CalendarService service;
    void install({CalendarInvitationOptions? options}) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(host: host, options: options),
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
      host = InvitationTestHost();
      policy = TestPolicy();
      install();
    });
    Future<CalendarInvitationReceipt> receive(Uint8List bytes) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(
            key: const Uuid().v4obj().toString(),
            bytes: bytes,
          ),
        );
    Future<CalendarInvitationAdoptionReceipt> setup({
      bool date = false,
      String? zone,
      int? sequence = 1,
      String? start,
      List<String> extra = const [],
    }) async {
      var bytes = invitationBytes(
        sequence: sequence,
        date: date,
        zone: zone,
        extra: ['RRULE:FREQ=DAILY;COUNT=6', ...extra],
      );
      if (start != null) {
        final oldStart = date
            ? 'DTSTART;VALUE=DATE:20300101'
            : zone == null
            ? 'DTSTART:20300101T090000Z'
            : 'DTSTART;TZID=$zone:20300101T090000';
        bytes = Uint8List.fromList(
          utf8.encode(utf8.decode(bytes).replaceFirst(oldStart, start)),
        );
      }
      final m = await receive(bytes);
      final c = (await service.create(createInput()))!;
      return service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: m.entryId,
          sourceId: m.sourceId,
          expectedRevision: m.entryRevision,
          calendarId: c.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
    }

    CalendarInvitationOccurrenceApplyRequest command(
      CalendarInvitationOccurrenceApplicationView v,
    ) => CalendarInvitationOccurrenceApplyRequest(
      invitationId: v.invitationId,
      sourceId: v.incomingSourceId!,
      linkId: v.linkId,
      expectedInvitationRevision: v.invitationRevision,
      expectedEventRevision: v.eventRevision,
      expectedCalendarRevision: v.calendarRevision,
      expectedApplicationRevision: v.applicationRevision,
      expectedOccurrenceRevision: v.occurrenceRevision,
    );
    Future<CalendarInvitationOccurrenceApplyRequest> cancel({
      bool date = false,
      String? zone,
      int sequence = 3,
    }) async {
      final bytes = rangeInvitationBytes(
        cancel: true,
        sequence: sequence,
        date: date,
        zone: zone,
      );
      final r = await receive(
        Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(bytes)
                .split('\r\n')
                .where((line) => !line.startsWith('SUMMARY:'))
                .join('\r\n'),
          ),
        ),
      );
      final v = await service.invitationRangeApplication(r.entryId);
      expect(v.canApply, isTrue);
      return command(v);
    }

    Future<CalendarEventDataRecord> data() async =>
        (await CalendarEventDataRecord.db.find(session)).single;
    Future<CalendarInvitationOccurrenceApplicationRecord> row() async =>
        (await CalendarInvitationOccurrenceApplicationRecord.db.find(session))
            .single;
    CalendarInvitationApplyRequest masterCommand(
      CalendarInvitationApplicationView v,
    ) => CalendarInvitationApplyRequest(
      invitationId: v.invitationId,
      sourceId: v.incomingSourceId!,
      expectedInvitationRevision: v.invitationRevision!,
      linkId: v.linkId,
      expectedEventRevision: v.eventRevision,
      expectedCalendarRevision: v.calendarRevision,
      expectedApplicationRevision: v.applicationRevision,
      expectedOccurrenceRevision: v.occurrenceRevision,
    );
    Future<CalendarInvitationApplicationView> newerMaster({
      int sequence = 3,
      bool date = false,
      String? zone,
      List<String> extra = const ['RRULE:FREQ=DAILY;COUNT=6'],
    }) async {
      final m = await receive(
        invitationBytes(
          sequence: sequence,
          date: date,
          zone: zone,
          summary: 'Updated master',
          extra: extra,
        ),
      );
      return service.invitationApplication(m.entryId);
    }

    for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
      test(
        '$profile keeps baseline and protocol versions; exact retry is write-free',
        () async {
          final date = profile == 'date',
              zone = profile == 'Europe/Stockholm' ? profile : null;
          await setup(date: date, zone: zone);
          final before = await data();
          final input = await cancel(date: date, zone: zone);
          final result = await service.applyInvitationRangeCancellation(input);
          final saved = await data(),
              state = jsonDecode((await row()).stateJson) as Map;
          expect(
            saved.importBaseline!.toJson(),
            before.importBaseline!.toJson(),
          );
          expect(saved.protocolState!.toJson(), before.protocolState!.toJson());
          expect(saved.timingOverrides!.cancelledFrom!.start.day, 2);
          expect(state['version'], 4);
          expect(state['targets'], isEmpty);
          expect(state['rangeCancellation']['version']['sequence'], 3);
          final v = await service.invitationRangeApplication(
            input.invitationId,
          );
          expect(v.hasAcceptedRangeCancellation, isTrue);
          expect(v.hasLocalChanges, isFalse);
          expect(v.currentOccurrence!.status, CalendarEventStatus.cancelled);
          expect(v.acceptedVersion.sequence, 3);
          expect(
            v.acceptedKind,
            CalendarInvitationSourceKind.rangeCancellation,
          );
          expect(v.canApply, isFalse);
          final oldRow = (await row()).toJson(),
              oldData = (await data()).toJson();
          expect(
            (await service.applyInvitationRangeCancellation(input)).id,
            result.id,
          );
          expect((await row()).toJson(), oldRow);
          expect((await data()).toJson(), oldData);
        },
      );
    }
    test('new source applications block; local restoration remains a draft; retry survives newer notice', () async {
      final link = await setup();
      final input = await cancel();
      final result = await service.applyInvitationRangeCancellation(input);
      final master = await newerMaster(sequence: 5);
      expect(master.occurrenceCompositionBlocked, isTrue);
      expect(master.hasLocalChanges, isFalse);
      await expectLater(
        service.applyInvitationUpdate(masterCommand(master)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final saved = await data();
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: link.eventId,
          expectedRevision: result.eventRevision,
          originalStart: saved.timingOverrides!.cancelledFrom!,
          action: CalendarEventOccurrenceAction.restoreFuture,
        ),
      );
      expect(
        (await service.invitationRangeApplication(input.invitationId))
            .hasLocalChanges,
        isTrue,
      );
      final r = await receive(rangeInvitationBytes(sequence: 6));
      final v = await service.invitationRangeApplication(r.entryId);
      expect(v.hasAcceptedRangeCancellation, isTrue);
      expect(v.canApply, isFalse);
      await expectLater(
        service.applyInvitationRangeUpdate(command(v)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(
        (await service.applyInvitationRangeCancellation(input)).id,
        result.id,
      );
      expect((await data()).timingOverrides?.cancelledFrom, isNull);
    });
    for (final op in [
      CalendarInvitationOperation.applyRangeCancellation,
      CalendarInvitationOperation.readSource,
      CalendarInvitationOperation.readRangeApplication,
    ]) {
      test('final $op denial is atomic', () async {
        await setup();
        final input = await cancel();
        host.onAuthorize = (c, tx, phase) async {
          if (phase == CalendarAuthorizationPhase.finalWrite &&
              c.operation == op) {
            expect(c.proposedOccurrenceApplication, isNotNull);
            host.denied.add(op);
          }
        };
        await expectLater(
          service.applyInvitationRangeCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await data()).timingOverrides, isNull);
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
        host.denied.clear();
        host.onAuthorize = null;
        expect(
          (await service.getInvitation(input.invitationId)).dismissedAt,
          isNull,
        );
      });
    }
    test(
      'accepted cancellation source is separately authorized at another notice',
      () async {
        await setup();
        final input = await cancel();
        await service.applyInvitationRangeCancellation(input);
        final m = await receive(
          invitationBytes(sequence: 5, extra: ['RRULE:FREQ=DAILY;COUNT=6']),
        );
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.readSource &&
              c.sourceId == input.sourceId) {
            host.denied.add(CalendarInvitationOperation.readSource);
          }
        };
        await expectLater(
          service.invitationApplication(m.entryId),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          service.applyInvitationRangeCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    for (final mode in ['single', 'composed', 'range']) {
      final range = mode == 'range';
      test(
        'retained $mode at cutoff survives v4 acceptance',
        () async {
          await setup();
          final notice = await receive(
            range
                ? rangeInvitationBytes(sequence: 2)
                : instanceInvitationBytes(
                    sequence: 2,
                    original: '20300102T090000Z',
                  ),
          );
          final v = await (range
              ? service.invitationRangeApplication
              : service.invitationOccurrenceApplication)(notice.entryId);
          await (range
              ? service.applyInvitationRangeUpdate
              : service.applyInvitationOccurrenceUpdate)(command(v));
          if (mode == 'composed') {
            await service.applyInvitationUpdate(
              masterCommand(await newerMaster(sequence: 3)),
            );
            expect((jsonDecode((await row()).stateJson) as Map)['version'], 2);
          }
          final before = await data(),
              oldTargets =
                  (jsonDecode((await row()).stateJson) as Map)['targets'];
          final input = await cancel(sequence: 4);
          await service.applyInvitationRangeCancellation(input);
          final saved = await data();
          expect(
            saved.importBaseline!.toJson(),
            before.importBaseline!.toJson(),
          );
          expect(saved.protocolState!.toJson(), before.protocolState!.toJson());
          expect(
            (jsonDecode((await row()).stateJson) as Map)['targets'],
            oldTargets,
          );
          expect(
            (await service.invitationRangeApplication(input.invitationId))
                .hasLocalChanges,
            isFalse,
          );
        },
      );
    }
    test('retained master retry cannot erase accepted cancellation', () async {
      await setup();
      final m = await newerMaster(sequence: 2), masterInput = masterCommand(m);
      final masterResult = await service.applyInvitationUpdate(masterInput);
      final input = await cancel(sequence: 4);
      await service.applyInvitationRangeCancellation(input);
      final before = (await data()).toJson(),
          checkpoint = (await row()).toJson();
      expect(
        (await service.applyInvitationUpdate(masterInput)).id,
        masterResult.id,
      );
      expect((await data()).toJson(), before);
      expect((await row()).toJson(), checkpoint);
    });
    test('checkpoint budget failure rolls back cutoff and notice', () async {
      await setup();
      final input = await cancel();
      install(
        options: CalendarInvitationOptions(maxOccurrenceCheckpointBytes: 100),
      );
      await expectLater(
        service.applyInvitationRangeCancellation(input),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect((await data()).timingOverrides, isNull);
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
      expect(
        (await service.getInvitation(input.invitationId)).dismissedAt,
        isNull,
      );
    });
    test('native deletion scrubs private acceptance', () async {
      final link = await setup();
      final input = await cancel();
      final result = await service.applyInvitationRangeCancellation(input);
      await service.deleteEvent(link.eventId, result.eventRevision);
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
      expect(await CalendarEventDataRecord.db.count(session), 0);
    });
    test(
      'cancellation removes later booking and invalidates alarm plans once',
      () async {
        final link = await setup(extra: ['DURATION:PT1H']);
        final input = await cancel();
        final query = CalendarFreeBusyQuery(
          calendarId: link.calendarId,
          fromUtc: DateTime.utc(2030),
          untilUtc: DateTime.utc(2030, 1, 4),
        );
        expect(
          (await service.freeBusy(query)).periods
              .where((v) => v.kind == CalendarFreeBusyKind.busy),
          hasLength(3),
        );
        final alarm = await CalendarAlarmRecord.db.insertRow(
          session,
          CalendarAlarmRecord(
            scopeKey: 'test:alice',
            calendarId: link.calendarId,
            parentKind: CalendarAlarmParentKind.event,
            parentId: link.eventId,
            recipientNamespace: 'fixture',
            recipientKey: 'alice',
            revision: 1,
            definition: CalendarAlarmDefinition(
              absoluteUtc: DateTime.utc(2030),
            ),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
        final plan = await CalendarAlarmPlanRecord.db.insertRow(
          session,
          CalendarAlarmPlanRecord(
            alarmId: alarm.id!,
            scopeKey: 'test:alice',
            generation: 1,
            dirty: false,
            nextScanAt: DateTime.utc(2031),
            leaseOwner: const Uuid().v4obj(),
            leaseUntil: DateTime.utc(2031),
            leaseFence: 8,
          ),
        );
        await service.applyInvitationRangeCancellation(input);
        final busy = await service.freeBusy(query);
        expect(busy.coverage, CalendarFreeBusyCoverage.complete);
        expect(
          busy.periods.where((v) => v.kind == CalendarFreeBusyKind.busy),
          hasLength(1),
        );
        final changed = (await CalendarAlarmPlanRecord.db.findById(
          session,
          plan.id!,
        ))!;
        expect(changed.dirty, isTrue);
        expect(changed.leaseOwner, isNull);
        expect(changed.leaseFence, 9);
        await service.applyInvitationRangeCancellation(input);
        expect(
          (await CalendarAlarmPlanRecord.db.findById(
            session,
            plan.id!,
          ))!.leaseFence,
          9,
        );
        expect(
          (await CalendarAlarmRecord.db.findById(session, alarm.id!))!.revision,
          1,
        );
      },
    );
    test('retained cancellation survives inbox-body pruning', () async {
      await setup();
      final input = await cancel();
      final result = await service.applyInvitationRangeCancellation(input);
      final entry = (await CalendarInvitationRecord.db.findById(
        session,
        input.invitationId,
      ))!;
      await CalendarInvitationRecord.db.updateRow(
        session,
        entry.copyWith(currentSourceId: null),
      );
      await CalendarInvitationReceiptRecord.db.deleteWhere(
        session,
        where: (t) => t.sourceId.equals(input.sourceId),
      );
      await CalendarInvitationSourceRecord.db.deleteWhere(
        session,
        where: (t) => t.id.equals(input.sourceId),
      );
      final v = await service.invitationRangeApplication(input.invitationId);
      expect(v.hasAcceptedRangeCancellation, isTrue);
      expect(v.acceptedSourceText, contains('METHOD:CANCEL'));
      expect(v.hasLocalChanges, isFalse);
      expect(
        (await service.applyInvitationRangeCancellation(input)).id,
        result.id,
      );
    });
    for (final permission in [
      CalendarPermission.importEvents,
      CalendarPermission.replaceEventsFromImport,
      CalendarPermission.updateEvent,
      CalendarPermission.changeEventStatus,
      CalendarPermission.readEventSource,
    ]) {
      test('native $permission remains independent', () async {
        await setup();
        final input = await cancel();
        policy.denied.add(permission);
        await expectLater(
          service.applyInvitationRangeCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await data()).timingOverrides, isNull);
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
      });
    }
    for (final field in [
      'expectedNativeDigest',
      'receiptDigest',
      'binding',
      'requiredAfterSequence',
      'source',
    ]) {
      test('corrupt v4 $field fails closed', () async {
        await setup();
        final input = await cancel();
        await service.applyInvitationRangeCancellation(input);
        final record = await row(),
            state = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
        if (field == 'expectedNativeDigest' || field == 'receiptDigest') {
          state[field] = '0' * 64;
        } else {
          state['rangeCancellation'][field] = field == 'requiredAfterSequence'
              ? 123
              : 'corrupt';
        }
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          record.copyWith(stateJson: jsonEncode(state)),
        );
        await expectLater(
          service.invitationRangeApplication(input.invitationId),
          failure(CalendarFailureCode.unavailable),
        );
        await expectLater(
          service.applyInvitationRangeCancellation(input),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
  });
}
