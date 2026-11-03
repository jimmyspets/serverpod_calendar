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
  withServerpod('master composition preserving source restoration', (
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
      for (final composedBefore in [false, true]) {
        test(
          '$profile ${composedBefore ? 'existing' : 'null'} master v7-v8 keeps frozen restoration and retries',
          () async {
            final date = profile == 'date',
                zone = profile == 'Europe/Stockholm' ? profile : null;
            await setup(date: date, zone: zone);
            await service.applyInvitationRangeCancellation(
              await cancel(date: date, zone: zone),
            );
            if (composedBefore) {
              await service.applyInvitationUpdate(
                masterCommand(
                  await newerMaster(sequence: 2, date: date, zone: zone),
                ),
              );
            }
            final restorationInput = command(
              await restoration(
                date: date,
                zone: zone,
                sequence: 10,
                summary: composedBefore ? 'Updated master' : 'Review',
              ),
            );
            final restored = await service.applyInvitationRangeRestoration(
                  restorationInput,
                ),
                old = await row(),
                oldData = await data();
            final view = await newerMaster(
              sequence: composedBefore ? 3 : 2,
              date: date,
              zone: zone,
            );
            expect(view.canApply, isTrue);
            expect(view.occurrenceCompositionBlocked, isFalse);
            expect((await row()).toJson(), old.toJson());
            expect((await data()).toJson(), oldData.toJson());
            final input = masterCommand(view),
                r = await service.applyInvitationUpdate(masterCommand(view));
            final first = jsonDecode((await row()).stateJson) as Map;
            expect(first['version'], 8);
            expect(first.containsKey('targets'), isFalse);
            expect(first.containsKey('restoration'), isFalse);
            expect(
              first['frozenRestoration']['checkpoint']['state'],
              jsonDecode(old.stateJson),
            );
            expect(
              first['frozenRestoration']['baseline'],
              oldData.importBaseline!.toJson(),
            );
            expect(
              first['frozenRestoration']['master'] == null,
              !composedBefore,
            );
            expect((await data()).timingOverrides?.cancelledFrom, isNull);
            expect((await data()).content.summary, 'Updated master');
            final source = await service.invitationRangeRestorationApplication(
              restorationInput.invitationId,
            );
            expect(source.acceptedVersion.sequence, 10);
            expect(source.hasAcceptedRangeRestoration, isTrue);
            expect(source.hasLocalChanges, isFalse);
            expect(
              (await service.applyInvitationRangeRestoration(restorationInput))
                  .toJson(),
              restored.toJson(),
            );
            expect(
              (await service.applyInvitationUpdate(input)).toJson(),
              r.toJson(),
            );
            final next = await newerMaster(
              sequence: composedBefore ? 4 : 3,
              date: date,
              zone: zone,
            );
            await service.applyInvitationUpdate(masterCommand(next));
            final second = jsonDecode((await row()).stateJson) as Map;
            expect(second['version'], 8);
            expect(second['frozenRestoration'], first['frozenRestoration']);
            expect(
              (await service.applyInvitationRangeRestoration(restorationInput))
                  .id,
              restored.id,
            );
          },
        );
      }
    }
    test('explicit DST gap original stays valid; removing its inclusion is an orphan', () async {
      const zone = 'Europe/Stockholm';
      const inclusion = 'RDATE;TZID=$zone:20300331T023000';
      await setup(
        zone: zone,
        start: 'DTSTART;TZID=$zone:20300330T023000',
        extra: [inclusion],
      );
      await service.applyInvitationRangeCancellation(
        await cancel(zone: zone, original: '20300331T023000'),
      );
      Uint8List eventBytes(
        int sequence, {
        bool range = false,
        bool include = true,
      }) {
        final raw = range
            ? rangeInvitationBytes(
                zone: zone,
                sequence: sequence,
                original: '20300331T023000',
              )
            : invitationBytes(
                zone: zone,
                sequence: sequence,
                extra: ['RRULE:FREQ=DAILY;COUNT=6', if (include) inclusion],
              );
        final start = range ? '20300331T023000' : '20300330T023000';
        return Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(raw)
                .replaceFirst(
                  'DTSTART;TZID=$zone:20300101T090000',
                  'DTSTART;TZID=$zone:$start',
                ),
          ),
        );
      }

      final source = await receive(eventBytes(4, range: true));
      final savedInput = command(
        await service.invitationRangeRestorationApplication(source.entryId),
      );
      final restored = await service.applyInvitationRangeRestoration(
        savedInput,
      );
      final next = await receive(eventBytes(2));
      await service.applyInvitationUpdate(
        masterCommand(await service.invitationApplication(next.entryId)),
      );
      final view = await service.invitationRangeRestorationApplication(
        source.entryId,
      );
      expect(view.originalStart.start.month, 3);
      expect(view.originalStart.start.day, 31);
      expect(view.originalStart.start.hour, 2);
      expect(view.originalStart.start.minute, 30);
      expect(view.originalStart.zoneId, zone);
      expect(view.hasLocalChanges, isFalse);
      expect((await data()).timingOverrides?.cancelledFrom, isNull);
      final orphan = await receive(eventBytes(3, include: false));
      final blocked = await service.invitationApplication(orphan.entryId);
      expect(blocked.canApply, isFalse);
      await expectLater(
        service.applyInvitationUpdate(masterCommand(blocked)),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await service.applyInvitationRangeRestoration(savedInput)).id,
        restored.id,
      );
    });
    test('recorded omitted source sequence and null master remain absent in frozen state', () async {
      await setup(sequence: null);
      await service.applyInvitationRangeCancellation(await cancel());
      await service.applyInvitationRangeRestoration(
        command(await restoration()),
      );
      await service.applyInvitationUpdate(
        masterCommand(await newerMaster(sequence: 1)),
      );
      final state = jsonDecode((await row()).stateJson) as Map;
      expect(state['frozenRestoration']['master'], isNull);
      final before = CalendarEventImportBaseline.fromJson(
        state['frozenRestoration']['baseline'],
      );
      expect(
        jsonDecode(before.canonicalValue)['protocol']['version']['sequence'],
        isNull,
      );
    });
    for (final extra in [
      ['RRULE:FREQ=DAILY;COUNT=1'],
      ['RRULE:FREQ=DAILY;COUNT=6', 'EXDATE:20300102T090000Z'],
    ]) {
      test(
        'orphaning restoration anchor rejects master ${extra.last}',
        () async {
          await setup();
          await service.applyInvitationRangeCancellation(await cancel());
          await service.applyInvitationRangeRestoration(
            command(await restoration()),
          );
          final old = (await row()).toJson(), before = (await data()).toJson();
          final v = await newerMaster(sequence: 3, extra: extra);
          expect(v.canApply, isFalse);
          await expectLater(
            service.applyInvitationUpdate(masterCommand(v)),
            failure(CalendarFailureCode.validation),
          );
          expect((await row()).toJson(), old);
          expect((await data()).toJson(), before);
        },
      );
    }
    test(
      'whole cancellation remains guarded after active composition',
      () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        await service.applyInvitationRangeRestoration(
          command(await restoration()),
        );
        await service.applyInvitationUpdate(
          masterCommand(await newerMaster(sequence: 2)),
        );
        final v = await whole();
        expect(v.canApplyCancellation, isFalse);
        await expectLater(
          service.applyInvitationCancellation(masterCommand(v)),
          failure(CalendarFailureCode.dependencyConflict),
        );
      },
    );
    for (final op in [
      CalendarInvitationOperation.composeAcceptedRangeRestoration,
      CalendarInvitationOperation.composeAcceptedRangeCancellation,
      CalendarInvitationOperation.composeAcceptedOccurrences,
      CalendarInvitationOperation.apply,
    ]) {
      test('independent final $op authority rolls back composition', () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        await service.applyInvitationRangeRestoration(
          command(await restoration()),
        );
        final v = await newerMaster(sequence: 2),
            input = masterCommand(v),
            old = (await row()).toJson(),
            before = (await data()).toJson();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == op &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.denied.add(op);
          }
        };
        await expectLater(
          service.applyInvitationUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await row()).toJson(), old);
        expect((await data()).toJson(), before);
      });
    }
    test(
      'local cutoff/draft conflicts and historical retry do not overwrite them',
      () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        final input = command(await restoration()),
            result = await service.applyInvitationRangeRestoration(input);
        final d = await data();
        d.content = d.content.copyWith(summary: 'Local draft');
        d.timingOverrides = CalendarEventTimingOverrides(
          singles: [],
          future: [],
          cancelledFrom: CalendarEventTiming(
            kind: CalendarEventTimeKind.utc,
            start: CalendarEventCivil(year: 2030, month: 1, day: 2, hour: 9),
          ),
        );
        await CalendarEventDataRecord.db.updateRow(session, d);
        final v = await newerMaster(sequence: 2);
        expect(v.hasLocalChanges, isTrue);
        expect(v.canApply, isFalse);
        await expectLater(
          service.applyInvitationUpdate(masterCommand(v)),
          failure(CalendarFailureCode.dependencyConflict),
        );
        expect(
          (await service.applyInvitationRangeRestoration(input)).id,
          result.id,
        );
        expect((await data()).toJson(), d.toJson());
      },
    );
    test('individually cancelled components survive composition with independent versions', () async {
      await setup();
      final s = await receive(
        instanceInvitationBytes(cancel: true, original: '20300103T090000Z'),
      );
      await service.applyInvitationOccurrenceCancellation(
        command(await service.invitationOccurrenceApplication(s.entryId)),
      );
      await service.applyInvitationRangeCancellation(await cancel());
      await service.applyInvitationRangeRestoration(
        command(await restoration()),
      );
      final before = (await data()).timingOverrides!.singles.single.toJson(),
          protocol = (await data()).protocolState!.overrides.single.toJson();
      await service.applyInvitationUpdate(
        masterCommand(await newerMaster(sequence: 2)),
      );
      expect((await data()).timingOverrides!.singles.single.toJson(), before);
      expect((await data()).protocolState!.overrides.single.toJson(), protocol);
    });
    test(
      'higher master sequence preserves backwards source clock exactly',
      () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        await service.applyInvitationRangeRestoration(
          command(await restoration()),
        );
        final incoming = await receive(
          invitationBytes(
            sequence: 2,
            stamp: '20200101T000000Z',
            summary: 'Old clock',
            extra: ['RRULE:FREQ=DAILY;COUNT=6'],
          ),
        );
        await service.applyInvitationUpdate(
          masterCommand(await service.invitationApplication(incoming.entryId)),
        );
        expect((await data()).protocolState!.version.stamp, DateTime.utc(2020));
        final state = jsonDecode((await row()).stateJson) as Map;
        final baseline = CalendarEventImportBaseline.fromJson(
          state['frozenRestoration']['baseline'],
        );
        expect(
          jsonDecode(baseline.canonicalValue)['protocol']['version']['stamp'],
          DateTime.utc(2026).toIso8601String(),
        );
      },
    );
    test('frozen snapshot and private caps reject atomically', () async {
      await setup();
      await service.applyInvitationRangeCancellation(await cancel());
      await service.applyInvitationRangeRestoration(
        command(await restoration()),
      );
      final v = await newerMaster(sequence: 2),
          input = masterCommand(v),
          old = await row(),
          before = await data();
      install(
        options: CalendarInvitationOptions(
          maxOccurrenceCheckpointBytes: utf8.encode(old.stateJson).length + 8,
        ),
      );
      expect(
        (await service.invitationApplication(v.invitationId)).canApply,
        isFalse,
      );
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect((await row()).toJson(), old.toJson());
      expect((await data()).toJson(), before.toJson());
    });
    test('exact native profile cannot change during composition', () async {
      await setup();
      await service.applyInvitationRangeCancellation(await cancel());
      await service.applyInvitationRangeRestoration(
        command(await restoration()),
      );
      final v = await newerMaster(sequence: 2, date: true);
      expect(v.canApply, isFalse);
      await expectLater(
        service.applyInvitationUpdate(masterCommand(v)),
        failure(CalendarFailureCode.validation),
      );
    });
    test(
      'pruning retains source retries; deletion scrubs frozen v8 data',
      () async {
        final link = await setup();
        final cancelInput = await cancel();
        await service.applyInvitationRangeCancellation(cancelInput);
        final input = command(await restoration()),
            restored = await service.applyInvitationRangeRestoration(input);
        final masterInput = masterCommand(await newerMaster(sequence: 2)),
            changed = await service.applyInvitationUpdate(masterInput);
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
          (await service.applyInvitationUpdate(masterInput)).id,
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
        final input = masterCommand(await newerMaster(sequence: 2)),
            before = (await row()).toJson();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.readSource &&
              c.sourceId == restored.sourceId &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.denied.add(CalendarInvitationOperation.readSource);
          }
        };
        await expectLater(
          service.applyInvitationUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await row()).toJson(), before);
      },
    );
    for (final field in ['checkpoint', 'baseline', 'master']) {
      test(
        'changed frozen $field is unavailable without replay fallback',
        () async {
          await setup();
          await service.applyInvitationRangeCancellation(await cancel());
          await service.applyInvitationUpdate(
            masterCommand(await newerMaster(sequence: 2)),
          );
          final input = command(
            await restoration(sequence: 10, summary: 'Updated master'),
          );
          await service.applyInvitationRangeRestoration(input);
          await service.applyInvitationUpdate(
            masterCommand(await newerMaster(sequence: 3)),
          );
          final value = await row(),
              state =
                  jsonDecode((await row()).stateJson) as Map<String, dynamic>;
          final frozen = state['frozenRestoration'] as Map<String, dynamic>;
          if (field == 'checkpoint') {
            frozen['checkpoint']['state']['version'] = 8;
          } else if (field == 'master') {
            frozen['master']['scopeKey'] = 'other:scope';
          } else {
            frozen['baseline']['canonicalValue'] = '{}';
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
        },
      );
    }
    test(
      'new master timing updates busy periods and fences personal alarm leases',
      () async {
        final link = await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        await service.applyInvitationRangeRestoration(
          command(await restoration()),
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
        final query = CalendarFreeBusyQuery(
          calendarId: link.calendarId,
          fromUtc: DateTime.utc(2030),
          untilUtc: DateTime.utc(2030, 1, 7),
        );
        expect(
          (await service.freeBusy(query)).periods
              .where((p) => p.kind == CalendarFreeBusyKind.busy),
          isEmpty,
        );
        final v = await newerMaster(
          sequence: 2,
          extra: ['RRULE:FREQ=DAILY;COUNT=6', 'DURATION:PT1H'],
        );
        await service.applyInvitationUpdate(masterCommand(v));
        expect(
          (await service.freeBusy(query)).periods
              .where((p) => p.kind == CalendarFreeBusyKind.busy)
              .length,
          6,
        );
        final changed = (await CalendarAlarmPlanRecord.db.findById(
          session,
          plan.id!,
        ))!;
        expect(changed.dirty, isTrue);
        expect(changed.leaseFence, 9);
        expect(changed.leaseOwner, isNull);
        expect((await data()).timingOverrides?.cancelledFrom, isNull);
      },
    );
    for (final field in [
      'frozenRestoration',
      'masterBaseline',
      'masterDigest',
      'baselineDigest',
      'expectedNativeDigest',
      'compositionDigest',
      'receiptDigest',
    ]) {
      test('altered v8 $field fails unavailable', () async {
        await setup();
        await service.applyInvitationRangeCancellation(await cancel());
        final input = command(await restoration());
        await service.applyInvitationRangeRestoration(input);
        await service.applyInvitationUpdate(
          masterCommand(await newerMaster(sequence: 2)),
        );
        final value = await row(),
            state = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
        state.remove(field);
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
