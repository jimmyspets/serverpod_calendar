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
import 'instance_invitations_test.dart' show instanceInvitationBytes;
import 'range_invitations_test.dart' show rangeInvitationBytes;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('master lifecycle preserving source restoration', (
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

    Future<CalendarInvitationOccurrenceApplyRequest> ready({
      bool date = false,
      String? zone,
      bool composed = false,
    }) async {
      await setup(date: date, zone: zone);
      await service.applyInvitationRangeCancellation(
        await cancel(date: date, zone: zone),
      );
      final input = command(
        await restoration(date: date, zone: zone, sequence: 10),
      );
      await service.applyInvitationRangeRestoration(input);
      if (composed) {
        await service.applyInvitationUpdate(
          masterCommand(await newerMaster(sequence: 2, date: date, zone: zone)),
        );
      }
      return input;
    }

    for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
      for (final composed in [false, true]) {
        test(
          '$profile ${composed ? "v8" : "v7"} cancellation and reopening retain frozen proof and retries',
          () async {
            final date = profile == 'date',
                zone = profile == 'Europe/Stockholm' ? profile : null;
            final restore = await ready(
              date: date,
              zone: zone,
              composed: composed,
            );
            final before = await row();
            final v = await whole();
            expect(v.canApplyCancellation, isTrue);
            final input = masterCommand(v),
                receipt = await service.applyInvitationCancellation(
                  masterCommand(v),
                );
            final cancelled = jsonDecode((await row()).stateJson) as Map;
            expect(cancelled['version'], 9);
            expect(cancelled['masterKind'], 'meetingCancellation');
            if (composed) {
              expect(
                cancelled['frozenRestoration'],
                (jsonDecode(before.stateJson) as Map)['frozenRestoration'],
              );
            } else {
              expect(
                cancelled['frozenRestoration']['checkpoint']['state'],
                jsonDecode(before.stateJson),
              );
            }
            expect(
              (await data()).content.status,
              CalendarEventStatus.cancelled,
            );
            expect((await data()).timingOverrides?.cancelledFrom, isNull);
            expect(
              (await service.applyInvitationCancellation(input)).toJson(),
              receipt.toJson(),
            );
            final acceptedRestore = await service
                .applyInvitationRangeRestoration(restore);
            expect(
              acceptedRestore.eventRevision,
              lessThan(receipt.eventRevision),
            );
            final reopen = await newerMaster(
              sequence: 12,
              date: date,
              zone: zone,
            );
            expect(reopen.canApply, isTrue);
            await service.applyInvitationUpdate(masterCommand(reopen));
            expect(
              (await data()).content.status,
              CalendarEventStatus.confirmed,
            );
            expect((await data()).timingOverrides?.cancelledFrom, isNull);
            final reopened = jsonDecode((await row()).stateJson) as Map;
            expect(reopened['version'], 9);
            expect(reopened['masterKind'], 'request');
            expect(
              reopened['frozenRestoration'],
              cancelled['frozenRestoration'],
            );
            await service.applyInvitationUpdate(
              masterCommand(
                await newerMaster(sequence: 13, date: date, zone: zone),
              ),
            );
            expect((jsonDecode((await row()).stateJson) as Map)['version'], 9);
            expect(
              (await service.applyInvitationRangeRestoration(restore)).toJson(),
              acceptedRestore.toJson(),
            );
            await service.applyInvitationCancellation(
              masterCommand(await whole(sequence: 14)),
            );
            expect(
              (await data()).content.status,
              CalendarEventStatus.cancelled,
            );
          },
        );
      }
    }
    for (final sequence in [9, 10]) {
      test(
        'CANCEL sequence $sequence cannot override historical restoration',
        () async {
          await ready();
          final before = (await data()).toJson(),
              checkpoint = (await row()).toJson();
          final v = await whole(sequence: sequence, stamp: '20270101T000000Z');
          expect(v.canApplyCancellation, isFalse);
          await expectLater(
            service.applyInvitationCancellation(masterCommand(v)),
            failure(CalendarFailureCode.dependencyConflict),
          );
          expect((await data()).toJson(), before);
          expect((await row()).toJson(), checkpoint);
        },
      );
    }
    for (final op in [
      CalendarInvitationOperation.composeAcceptedRangeRestoration,
      CalendarInvitationOperation.composeAcceptedRangeCancellation,
      CalendarInvitationOperation.composeAcceptedOccurrences,
      CalendarInvitationOperation.applyCancellation,
    ]) {
      test('final $op denial rolls back lifecycle', () async {
        await ready();
        final input = masterCommand(await whole()),
            before = (await data()).toJson(),
            checkpoint = (await row()).toJson();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == op &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.denied.add(op);
          }
        };
        await expectLater(
          service.applyInvitationCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), checkpoint);
      });
    }
    for (final field in [
      'masterKind',
      'frozenRestoration',
      'masterBaseline',
      'masterBaselineDigest',
      'masterDigest',
      'baselineDigest',
      'expectedNativeDigest',
      'compositionDigest',
      'receiptDigest',
    ]) {
      test('missing v9 $field fails unavailable', () async {
        final restore = await ready();
        await service.applyInvitationCancellation(masterCommand(await whole()));
        final value = await row(),
            state = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
        state.remove(field);
        value.stateJson = jsonEncode(state);
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          value,
        );
        await expectLater(
          service.applyInvitationRangeRestoration(restore),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
    test('high pre-cutoff individual version and cancellation survive whole lifecycle', () async {
      await setup();
      final source = await receive(
        instanceInvitationBytes(
          sequence: 30,
          cancel: true,
          original: '20300101T090000Z',
        ),
      );
      await service.applyInvitationOccurrenceCancellation(
        command(await service.invitationOccurrenceApplication(source.entryId)),
      );
      await service.applyInvitationRangeCancellation(
        await cancel(sequence: 10),
      );
      await service.applyInvitationRangeRestoration(
        command(await restoration(sequence: 11)),
      );
      final denied = await whole(sequence: 20);
      expect(denied.canApplyCancellation, isFalse);
      await expectLater(
        service.applyInvitationCancellation(masterCommand(denied)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final before = (await data()).timingOverrides!.singles.single.toJson();
      final version = (await data()).protocolState!.overrides.single.toJson();
      await service.applyInvitationCancellation(
        masterCommand(await whole(sequence: 31)),
      );
      await service.applyInvitationUpdate(
        masterCommand(await newerMaster(sequence: 32)),
      );
      expect((await data()).timingOverrides!.singles.single.toJson(), before);
      expect((await data()).protocolState!.overrides.single.toJson(), version);
      expect((await data()).timingOverrides?.cancelledFrom, isNull);
    });
    test(
      'equal sequence later stamp reopens without reinstating cutoff',
      () async {
        await ready();
        await service.applyInvitationCancellation(masterCommand(await whole()));
        final r = await receive(
          invitationBytes(
            sequence: 11,
            stamp: '20260101T000001Z',
            extra: ['RRULE:FREQ=DAILY;COUNT=6'],
          ),
        );
        final v = await service.invitationApplication(r.entryId);
        expect(v.canApply, isTrue);
        await service.applyInvitationUpdate(masterCommand(v));
        expect((await data()).content.status, CalendarEventStatus.confirmed);
        expect((await data()).timingOverrides?.cancelledFrom, isNull);
      },
    );
    test(
      'dirty native state conflicts and retained receipts never reapply',
      () async {
        final restore = await ready();
        final input = masterCommand(await whole());
        final result = await service.applyInvitationCancellation(input);
        final d = await data();
        d.content = d.content.copyWith(summary: 'Local draft');
        await CalendarEventDataRecord.db.updateRow(session, d);
        final v = await newerMaster(sequence: 12);
        expect(v.hasLocalChanges, isTrue);
        await expectLater(
          service.applyInvitationUpdate(masterCommand(v)),
          failure(CalendarFailureCode.dependencyConflict),
        );
        expect(
          (await service.applyInvitationCancellation(input)).id,
          result.id,
        );
        await service.applyInvitationRangeRestoration(restore);
        expect((await data()).toJson(), d.toJson());
      },
    );
    for (final mode in ['relative', 'absolute', 'snooze']) {
      final absolute = mode == 'absolute';
      test(
        'whole cancellation withdraws $mode reminders and reopening preserves actions without replay',
        () async {
          final delivery = TestAlarmDeliveryPort();
          install(
            alarms: CalendarAlarmRuntime(
              policy: TestAlarmBackgroundPolicy(),
              delivery: delivery,
            ),
          );
          final raw =
              (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                      .single
                      .single
                  as DateTime;
          final due = DateTime.fromMillisecondsSinceEpoch(
            raw.toUtc().millisecondsSinceEpoch ~/ 1000 * 1000,
            isUtc: true,
          ).subtract(const Duration(minutes: 1));
          String point(DateTime d) =>
              '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}${d.second.toString().padLeft(2, '0')}Z';
          final link = await setup(
            start: 'DTSTART:${point(due)}',
            extra: ['DURATION:PT1H'],
          );
          final range = await cancel(
            sequence: 10,
            original: point(due.add(const Duration(days: 1))),
          );
          await service.applyInvitationRangeCancellation(range);
          final restoredBytes = utf8
              .decode(
                rangeInvitationBytes(
                  sequence: 11,
                  original: point(due.add(const Duration(days: 1))),
                ),
              )
              .replaceFirst(
                'DTSTART:20300101T090000Z',
                'DTSTART:${point(due.add(const Duration(days: 1)))}',
              )
              .replaceFirst(
                'SUMMARY:Review',
                'SUMMARY:Review\r\nDURATION:PT1H',
              );
          final restoredSource = await receive(
            Uint8List.fromList(utf8.encode(restoredBytes)),
          );
          await service.applyInvitationRangeRestoration(
            command(
              await service.invitationRangeRestorationApplication(
                restoredSource.entryId,
              ),
            ),
          );
          final parent = CalendarAlarmParent(
            kind: CalendarAlarmParentKind.event,
            id: link.eventId,
          );
          final alarm = (await service.createPersonalAlarm(
            CalendarAlarmCreateRequest(
              parent: parent,
              definition: absolute
                  ? CalendarAlarmDefinition(absoluteUtc: due)
                  : CalendarAlarmDefinition(
                      relativeDuration: CalendarAlarmDuration(),
                      anchor: CalendarAlarmAnchor.start,
                    ),
            ),
          ))!;
          await service.setPersonalAlarmArmed(
            parent,
            alarm.id,
            alarm.revision,
            true,
          );
          await CalendarModule.runAlarmMaintenance(session);
          expect(delivery.calls, 1);
          final intent = delivery.accepted.values.single;
          expect(
            await CalendarModule.checkAlarmDelivery(session, intent),
            CalendarAlarmDeliveryCheck.eligible,
          );
          CalendarAlarmActionRecord? action;
          if (mode == 'snooze') {
            await service.actOnPersonalAlarm(
              CalendarAlarmActionRequest(
                parent: parent,
                alarmId: alarm.id,
                expectedAlarmRevision: (await CalendarAlarmRecord.db.findById(
                  session,
                  alarm.id,
                ))!.revision,
                expectedActionRevision: 0,
                kind: CalendarAlarmActionKind.snooze,
                firingId: intent.firingId,
                snoozeAt: due.add(const Duration(minutes: 6)),
              ),
            );
            action = (await CalendarAlarmActionRecord.db.find(session)).single;
          }
          await service.applyInvitationCancellation(
            masterCommand(await whole(sequence: 12)),
          );
          expect(
            await CalendarModule.checkAlarmDelivery(session, intent),
            CalendarAlarmDeliveryCheck.withdrawn,
          );
          await CalendarModule.runAlarmMaintenance(session);
          expect(delivery.calls, 1);
          final bytes = utf8
              .decode(
                invitationBytes(
                  sequence: 13,
                  extra: ['RRULE:FREQ=DAILY;COUNT=6', 'DURATION:PT1H'],
                ),
              )
              .replaceFirst(
                'DTSTART:20300101T090000Z',
                'DTSTART:${point(due)}',
              );
          final r = await receive(Uint8List.fromList(utf8.encode(bytes)));
          await service.applyInvitationUpdate(
            masterCommand(await service.invitationApplication(r.entryId)),
          );
          await CalendarModule.runAlarmMaintenance(session);
          expect(delivery.calls, 1);
          expect((await data()).timingOverrides?.cancelledFrom, isNull);
          if (action != null) {
            expect(
              (await CalendarAlarmActionRecord.db.findById(
                session,
                action.id!,
              ))!.toJson(),
              action.toJson(),
            );
          }
          expect(
            await CalendarAlarmFiringRecord.db.count(
              session,
              where: (t) =>
                  t.alarmId.equals(alarm.id) &
                  t.state.equals(CalendarAlarmFiringState.accepted),
            ),
            1,
          );
        },
      );
    }
    test('lifecycle native permission remains required for cancellation and reopening', () async {
      await ready();
      final v = await whole();
      policy.denied.add(CalendarPermission.changeEventStatus);
      expect(
        (await service.invitationApplication(v.invitationId))
            .canApplyCancellation,
        isFalse,
      );
      await expectLater(
        service.applyInvitationCancellation(masterCommand(v)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      await service.applyInvitationCancellation(masterCommand(v));
      final r = await newerMaster(sequence: 12);
      policy.denied.add(CalendarPermission.changeEventStatus);
      expect(
        (await service.invitationApplication(r.invitationId)).canApply,
        isFalse,
      );
      await expectLater(
        service.applyInvitationUpdate(masterCommand(r)),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test(
      'pruning retains source retries; deletion scrubs frozen v9 data',
      () async {
        final link = await setup();
        final cancelInput = await cancel();
        await service.applyInvitationRangeCancellation(cancelInput);
        final input = command(await restoration()),
            restored = await service.applyInvitationRangeRestoration(input);
        final masterInput = masterCommand(await whole()),
            changed = await service.applyInvitationCancellation(masterInput);
        for (final id in [cancelInput.sourceId, input.sourceId]) {
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
          restored.id,
        );
        expect(
          (await service.applyInvitationCancellation(masterInput)).id,
          changed.id,
        );
        await service.deleteEvent(link.eventId, changed.eventRevision);
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
      },
    );
    test(
      'historical restoration source requires fresh final authorization',
      () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        final restored = command(await restoration());
        await service.applyInvitationRangeRestoration(restored);
        final input = masterCommand(await whole()),
            before = (await row()).toJson();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.readSource &&
              c.sourceId == restored.sourceId &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.denied.add(CalendarInvitationOperation.readSource);
          }
        };
        await expectLater(
          service.applyInvitationCancellation(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await row()).toJson(), before);
      },
    );
    test('whole lifecycle withdraws bookings and reopening restores all unmasked days', () async {
      final link = await setup(extra: ['DURATION:PT1H']);
      await service.applyInvitationRangeCancellation(await cancel());
      var text = utf8
          .decode(rangeInvitationBytes(sequence: 10))
          .replaceFirst('DTSTART:20300101T090000Z', 'DTSTART:20300102T090000Z')
          .replaceFirst('SUMMARY:Review', 'SUMMARY:Review\r\nDURATION:PT1H');
      final source = await receive(Uint8List.fromList(utf8.encode(text)));
      await service.applyInvitationRangeRestoration(
        command(
          await service.invitationRangeRestorationApplication(source.entryId),
        ),
      );
      final query = CalendarFreeBusyQuery(
        calendarId: link.calendarId,
        fromUtc: DateTime.utc(2030),
        untilUtc: DateTime.utc(2030, 1, 7),
      );
      Future<int> occupied() async {
        final busy = await service.freeBusy(query);
        expect(busy.coverage, CalendarFreeBusyCoverage.complete);
        return busy.periods
            .where((p) => p.kind == CalendarFreeBusyKind.busy)
            .length;
      }

      expect(await occupied(), 6);
      await service.applyInvitationCancellation(masterCommand(await whole()));
      expect(await occupied(), 0);
      await service.applyInvitationUpdate(
        masterCommand(
          await newerMaster(
            sequence: 12,
            extra: ['RRULE:FREQ=DAILY;COUNT=6', 'DURATION:PT1H'],
          ),
        ),
      );
      expect(await occupied(), 6);
    });
    test(
      'complete v9 evidence exceeds lower quota without any partial write',
      () async {
        await ready();
        final v = await whole(),
            before = (await data()).toJson(),
            prior = (await row()).toJson();
        install(
          options: CalendarInvitationOptions(
            maxOccurrenceCheckpointBytes:
                utf8.encode((await row()).stateJson).length + 8,
          ),
        );
        expect(
          (await service.invitationApplication(v.invitationId))
              .canApplyCancellation,
          isFalse,
        );
        await expectLater(
          service.applyInvitationCancellation(masterCommand(v)),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), prior);
      },
    );
    for (final mutation in [
      'request-kind',
      'unknown-version',
      'nested-history',
      'cancelled-v8',
    ]) {
      test('contradictory $mutation cannot downgrade or flatten v9', () async {
        final input = await ready();
        await service.applyInvitationCancellation(masterCommand(await whole()));
        final value = await row(),
            state = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
        switch (mutation) {
          case 'request-kind':
            state['masterKind'] = 'request';
          case 'unknown-version':
            state['version'] = 10;
          case 'nested-history':
            state['frozenRestoration']['checkpoint']['state']['version'] = 9;
          case 'cancelled-v8':
            state['version'] = 8;
            state.remove('masterKind');
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
    test(
      'source lifecycle clocks stay exact and omitted dates stay absent',
      () async {
        await ready();
        final cancelled = await whole(
          stamp: '20200101T000000Z',
          extra: ['CREATED:20190101T000000Z', 'DESCRIPTION:Review only'],
        );
        await service.applyInvitationCancellation(masterCommand(cancelled));
        var d = await data();
        expect(d.protocolState!.version.stamp, DateTime.utc(2020));
        expect(d.protocolState!.version.created, DateTime.utc(2019));
        expect(d.protocolState!.version.lastModified, isNull);
        expect(d.content.description, isNull);
        final source = await receive(
          invitationBytes(
            sequence: 12,
            stamp: '20180101T000000Z',
            extra: ['RRULE:FREQ=DAILY;COUNT=6'],
          ),
        );
        await service.applyInvitationUpdate(
          masterCommand(await service.invitationApplication(source.entryId)),
        );
        d = await data();
        expect(d.protocolState!.version.stamp, DateTime.utc(2018));
        expect(d.protocolState!.version.created, isNull);
        expect(d.protocolState!.version.lastModified, isNull);
      },
    );
    test('maximum historical restoration has no implicit increment or timestamp bypass', () async {
      await setup(sequence: null);
      await service.applyInvitationRangeCancellation(await cancel());
      final input = command(await restoration(sequence: 2147483647));
      final restored = await service.applyInvitationRangeRestoration(input);
      final v = await whole(sequence: 2147483647, stamp: '20270101T000000Z');
      expect(v.canApplyCancellation, isFalse);
      await expectLater(
        service.applyInvitationCancellation(masterCommand(v)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(
        (await service.applyInvitationRangeRestoration(input)).id,
        restored.id,
      );
      expect((await data()).importBaseline!.sourceSequence, isNull);
    });
  });
}
