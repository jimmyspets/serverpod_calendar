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
  withServerpod('durable restore-only source acceptance', (
    builder,
    endpoints,
  ) {
    late Session session;
    late InvitationTestHost host;
    late TestPolicy policy;
    late CalendarService service;
    void install({
      CalendarInvitationOptions? options,
      CalendarAlarmRuntime? alarms,
    }) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(host: host, options: options),
        alarms: alarms,
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
      String? original,
    }) async {
      final bytes = rangeInvitationBytes(
        cancel: true,
        original: original,
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

    Future<CalendarInvitationApplicationView> whole({
      int sequence = 11,
      String stamp = '20260101T000000Z',
      List<String> extra = const [],
    }) async {
      var text = utf8
          .decode(
            invitationBytes(sequence: sequence, stamp: stamp, extra: extra),
          )
          .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL')
          .replaceFirst(
            'BEGIN:VEVENT\r\n',
            'BEGIN:VEVENT\r\nSTATUS:CANCELLED\r\n',
          );
      text = text
          .split('\r\n')
          .where((l) => !l.startsWith('DTSTART') && !l.startsWith('SUMMARY'))
          .join('\r\n');
      final r = await receive(Uint8List.fromList(utf8.encode(text)));
      return service.invitationApplication(r.entryId);
    }

    Future<CalendarInvitationOccurrenceApplicationView> restoration({
      bool date = false,
      String? zone,
      int sequence = 4,
      String summary = 'Review',
    }) async {
      var text = utf8.decode(
        rangeInvitationBytes(date: date, zone: zone, sequence: sequence),
      );
      final a = date
          ? 'DTSTART;VALUE=DATE:20300101'
          : zone == null
          ? 'DTSTART:20300101T090000Z'
          : 'DTSTART;TZID=$zone:20300101T090000';
      text = text
          .replaceFirst(a, a.replaceFirst('20300101', '20300102'))
          .replaceFirst('SUMMARY:Review', 'SUMMARY:$summary');
      final r = await receive(Uint8List.fromList(utf8.encode(text)));
      return service.invitationRangeRestorationApplication(r.entryId);
    }

    for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
      for (final version in [4, 5, 6]) {
        test(
          '$profile v$version to v7 preserves canonical values and guarded retries',
          () async {
            final date = profile == 'date',
                zone = profile == 'Europe/Stockholm' ? profile : null;
            await setup(date: date, zone: zone);
            final originalCancel = await cancel(date: date, zone: zone);
            await service.applyInvitationRangeCancellation(originalCancel);
            CalendarInvitationApplyRequest? masterInput;
            CalendarInvitationApplyReceipt? masterResult;
            if (version >= 5) {
              masterInput = masterCommand(
                await newerMaster(sequence: 2, date: date, zone: zone),
              );
              masterResult = await service.applyInvitationUpdate(masterInput);
            }
            if (version == 6) {
              await service.applyInvitationCancellation(
                masterCommand(await whole(sequence: 5)),
              );
              masterInput = masterCommand(
                await newerMaster(sequence: 6, date: date, zone: zone),
              );
              masterResult = await service.applyInvitationUpdate(masterInput);
            }
            final before = await data(), old = await row();
            final v = await restoration(
              date: date,
              zone: zone,
              sequence: version == 6 ? 7 : 4,
              summary: version >= 5 ? 'Updated master' : 'Review',
            );
            expect(v.canApply, isTrue);
            final input = command(v),
                r = await service.applyInvitationRangeRestoration(command(v));
            final after = await data();
            final next = await row();
            final state = jsonDecode(next.stateJson) as Map;
            expect(state['version'], 7);
            expect(state.containsKey('targets'), isFalse);
            expect(state['preRestoration']['state'], jsonDecode(old.stateJson));
            expect(after.timingOverrides?.cancelledFrom, isNull);
            expect(after.content.toJson(), before.content.toJson());
            expect(
              after.protocolState!.toJson(),
              before.protocolState!.toJson(),
            );
            expect(
              after.importBaseline!.toJson(),
              before.importBaseline!.toJson(),
            );
            final view = await service.invitationRangeRestorationApplication(
              v.invitationId,
            );
            expect(view.hasAcceptedRangeCancellation, isTrue);
            expect(view.hasAcceptedRangeRestoration, isTrue);
            expect(view.hasLocalChanges, isFalse);
            expect(view.canApply, isFalse);
            expect(
              (await service.applyInvitationRangeRestoration(input)).toJson(),
              r.toJson(),
            );
            await expectLater(
              service.applyInvitationRangeCancellation(originalCancel),
              failure(CalendarFailureCode.dependencyConflict),
            );
            if (masterInput != null) {
              expect(
                (await service.applyInvitationUpdate(masterInput)).toJson(),
                masterResult!.toJson(),
              );
            }
            expect((await row()).toJson(), next.toJson());
            final master = await newerMaster(
              sequence: 20,
              date: date,
              zone: zone,
            );
            expect(master.hasAcceptedRangeRestoration, isTrue);
            expect(master.canApply, isFalse);
            await expectLater(
              service.applyInvitationUpdate(masterCommand(master)),
              failure(CalendarFailureCode.dependencyConflict),
            );
          },
        );
      }
    }
    for (final op in [
      CalendarInvitationOperation.applyRangeRestoration,
      CalendarInvitationOperation.readRangeRestorationApplication,
      CalendarInvitationOperation.readSource,
      CalendarInvitationOperation.composeAcceptedRangeCancellation,
      CalendarInvitationOperation.composeAcceptedOccurrences,
    ]) {
      test('final $op denial rolls back complete restoration', () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        final v = await restoration(),
            input = command(v),
            before = await data(),
            previous = await row();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == op &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.denied.add(op);
          }
        };
        await expectLater(
          service.applyInvitationRangeRestoration(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await data()).toJson(), before.toJson());
        expect((await row()).toJson(), previous.toJson());
      });
    }
    test('ordinary range apply never becomes restoration and local cutoff clear conflicts', () async {
      final link = await setup();
      await service.applyInvitationRangeCancellation(await cancel());
      final v = await restoration(), input = command(v);
      await expectLater(
        service.applyInvitationRangeUpdate(input),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final before = await data();
      before.timingOverrides = null;
      await CalendarEventDataRecord.db.updateRow(session, before);
      expect(
        (await service.invitationRangeRestorationApplication(v.invitationId))
            .hasLocalChanges,
        isTrue,
      );
      await expectLater(
        service.applyInvitationRangeRestoration(input),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(link.eventId, isNotNull);
    });
    test('native lifecycle permission is independent', () async {
      await setup();
      await service.applyInvitationRangeCancellation(await cancel());
      final input = command(await restoration());
      policy.denied.add(CalendarPermission.changeEventStatus);
      await expectLater(
        service.applyInvitationRangeRestoration(input),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test(
      'retry preserves later native edits and a newly added local cutoff',
      () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        final input = command(await restoration()),
            receipt = await service.applyInvitationRangeRestoration(input);
        final d = await data();
        d.content = d.content.copyWith(summary: 'Private local draft');
        d.timingOverrides = CalendarEventTimingOverrides(
          singles: [],
          future: [],
          cancelledFrom: CalendarEventTiming(
            kind: CalendarEventTimeKind.utc,
            start: CalendarEventCivil(year: 2030, month: 1, day: 3, hour: 9),
          ),
        );
        await CalendarEventDataRecord.db.updateRow(session, d);
        final before = (await data()).toJson(), prior = (await row()).toJson();
        expect(
          (await service.applyInvitationRangeRestoration(input)).id,
          receipt.id,
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), prior);
        final newer = await restoration(sequence: 5);
        expect(newer.canApply, isFalse);
        await expectLater(
          service.applyInvitationRangeRestoration(command(newer)),
          failure(CalendarFailureCode.dependencyConflict),
        );
      },
    );
    test(
      'individually cancelled originals survive source restoration',
      () async {
        await setup();
        final source = await receive(
          instanceInvitationBytes(
            cancel: true,
            original: '20300103T090000Z',
            sequence: 2,
          ),
        );
        await service.applyInvitationOccurrenceCancellation(
          command(
            await service.invitationOccurrenceApplication(source.entryId),
          ),
        );
        await service.applyInvitationRangeCancellation(await cancel());
        final before = (await data()).timingOverrides!.singles.single.toJson();
        await service.applyInvitationRangeRestoration(
          command(await restoration()),
        );
        final d = await data();
        expect(d.timingOverrides!.singles.single.cancelled, isTrue);
        expect(d.timingOverrides!.singles.single.toJson(), before);
      },
    );
    test(
      'complete predecessor plus source evidence counts toward quota',
      () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        final input = command(await restoration()),
            previous = await row(),
            before = await data();
        install(
          options: CalendarInvitationOptions(
            maxOccurrenceCheckpointBytes:
                utf8.encode(previous.stateJson).length + 8,
          ),
        );
        await expectLater(
          service.applyInvitationRangeRestoration(input),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect((await data()).toJson(), before.toJson());
        expect((await row()).toJson(), previous.toJson());
      },
    );
    test(
      'accepted cancellation source has independent final authority',
      () async {
        await setup();
        final cancellation = await cancel();
        await service.applyInvitationRangeCancellation(cancellation);
        final input = command(await restoration());
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.readSource &&
              c.sourceId == cancellation.sourceId &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.denied.add(CalendarInvitationOperation.readSource);
          }
        };
        await expectLater(
          service.applyInvitationRangeRestoration(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await data()).timingOverrides!.cancelledFrom, isNotNull);
      },
    );
    test(
      'pruned source bodies retain retry evidence and deletion scrubs v7',
      () async {
        final link = await setup();
        final cancellation = await cancel();
        await service.applyInvitationRangeCancellation(cancellation);
        final input = command(await restoration()),
            result = await service.applyInvitationRangeRestoration(input);
        for (final id in [cancellation.sourceId, input.sourceId]) {
          final source = (await CalendarInvitationSourceRecord.db.findById(
            session,
            id,
          ))!;
          final entry = (await CalendarInvitationRecord.db.findById(
            session,
            source.entryId,
          ))!;
          await CalendarInvitationRecord.db.updateRow(
            session,
            entry.copyWith(currentSourceId: null),
          );
          await CalendarInvitationReceiptRecord.db.deleteWhere(
            session,
            where: (t) => t.sourceId.equals(id),
          );
          await CalendarInvitationSourceRecord.db.deleteWhere(
            session,
            where: (t) => t.id.equals(id),
          );
        }
        expect(
          (await service.applyInvitationRangeRestoration(input)).id,
          result.id,
        );
        await service.deleteEvent(link.eventId, result.eventRevision);
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
      },
    );
    test(
      'nested restoration predecessor and modified source cannot downgrade',
      () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        final input = command(await restoration());
        await service.applyInvitationRangeRestoration(input);
        final d = await row();
        final state = jsonDecode(d.stateJson) as Map<String, dynamic>;
        state['preRestoration']['state']['version'] = 7;
        d.stateJson = jsonEncode(state);
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          d,
        );
        await expectLater(
          service.applyInvitationRangeRestoration(input),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    Future<CalendarInvitationOccurrenceApplicationView>
    restorationWithDuration() async {
      final text = utf8
          .decode(rangeInvitationBytes(sequence: 4))
          .replaceFirst('DTSTART:20300101T090000Z', 'DTSTART:20300102T090000Z')
          .replaceFirst('SUMMARY:Review', 'DURATION:PT1H\r\nSUMMARY:Review');
      final r = await receive(Uint8List.fromList(utf8.encode(text)));
      return service.invitationRangeRestorationApplication(r.entryId);
    }

    test('restoration restores bookings and fences alarm plans', () async {
      final link = await setup(extra: ['DURATION:PT1H']);
      await service.applyInvitationRangeCancellation(await cancel());
      final input = command(await restorationWithDuration());
      final query = CalendarFreeBusyQuery(
        calendarId: link.calendarId,
        fromUtc: DateTime.utc(2030),
        untilUtc: DateTime.utc(2030, 1, 7),
      );
      final beforeBusy = await service.freeBusy(query);
      expect(
        beforeBusy.periods
            .where((p) => p.kind == CalendarFreeBusyKind.busy)
            .length,
        1,
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
          definition: CalendarAlarmDefinition(absoluteUtc: DateTime.utc(2030)),
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
      await service.applyInvitationRangeRestoration(input);
      final busy = await service.freeBusy(query);
      expect(busy.coverage, CalendarFreeBusyCoverage.complete);
      expect(
        busy.periods.where((p) => p.kind == CalendarFreeBusyKind.busy).length,
        6,
      );
      final changed = (await CalendarAlarmPlanRecord.db.findById(
        session,
        plan.id!,
      ))!;
      expect(changed.dirty, isTrue);
      expect(changed.leaseOwner, isNull);
      expect(changed.leaseFence, 9);
      await service.applyInvitationRangeRestoration(input);
      expect(
        (await CalendarAlarmPlanRecord.db.findById(
          session,
          plan.id!,
        ))!.leaseFence,
        9,
      );
    });
    for (final field in [
      'version',
      'preRestoration',
      'restoration',
      'expectedNativeDigest',
      'receiptDigest',
      'baselineDigest',
    ]) {
      test('corrupt v7 $field fails unavailable without fallback', () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        final input = command(await restoration());
        await service.applyInvitationRangeRestoration(input);
        final value = await row();
        final state = jsonDecode(value.stateJson) as Map<String, dynamic>;
        if (field == 'version') {
          state[field] = 6;
        } else {
          state.remove(field);
        }
        value.stateJson = jsonEncode(state);
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          value,
        );
        await expectLater(
          service.applyInvitationRangeRestoration(input),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
  });
}
