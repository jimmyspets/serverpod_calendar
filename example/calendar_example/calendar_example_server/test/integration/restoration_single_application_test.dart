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
  withServerpod('single applications preserving source restoration', (
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

    Future<CalendarInvitationOccurrenceApplicationView> single({
      bool date = false,
      String? zone,
      int sequence = 2,
      bool cancelled = false,
      String? original,
    }) async {
      final r = await receive(
        instanceInvitationBytes(
          date: date,
          zone: zone,
          sequence: sequence,
          cancel: cancelled,
          original: original,
        ),
      );
      return service.invitationOccurrenceApplication(r.entryId);
    }

    for (final profile in ['utc', 'date', 'Europe/Stockholm']) {
      for (final initial in [7, 8, 9]) {
        test(
          '$profile v$initial to v10 single lifecycle, master composition and receipt supersession',
          () async {
            final date = profile == 'date',
                zone = profile == 'Europe/Stockholm' ? profile : null;
            final restored = await ready(
              date: date,
              zone: zone,
              composed: initial == 8,
            );
            if (initial == 9) {
              await service.applyInvitationCancellation(
                masterCommand(await whole()),
              );
              await service.applyInvitationUpdate(
                masterCommand(
                  await newerMaster(sequence: 12, date: date, zone: zone),
                ),
              );
            }
            final before = jsonDecode((await row()).stateJson) as Map;
            final seq = initial == 9
                ? 13
                : initial == 8
                ? 3
                : 2;
            final v = await single(date: date, zone: zone, sequence: seq);
            expect(v.canApply, isTrue);
            final input = command(v),
                result = await service.applyInvitationOccurrenceUpdate(
                  command(v),
                );
            final first = jsonDecode((await row()).stateJson) as Map;
            expect(first['version'], 10);
            expect(
              first['frozenRestoration']['checkpoint']['state']['version'],
              7,
            );
            if (initial != 7) {
              expect(first['frozenRestoration'], before['frozenRestoration']);
            }
            expect((await data()).timingOverrides?.cancelledFrom, isNull);
            expect(
              (await service.applyInvitationOccurrenceUpdate(input)).toJson(),
              result.toJson(),
            );
            await expectLater(
              service.applyInvitationRangeRestoration(restored),
              failure(CalendarFailureCode.dependencyConflict),
            );
            final cancelled = await single(
              date: date,
              zone: zone,
              sequence: seq + 1,
              cancelled: true,
            );
            expect(cancelled.canApply, isTrue);
            final cancelInput = command(cancelled),
                receipt = await service.applyInvitationOccurrenceCancellation(
                  command(cancelled),
                );
            await expectLater(
              service.applyInvitationOccurrenceUpdate(input),
              failure(CalendarFailureCode.staleRevision),
            );
            final protocol = (await data()).protocolState!.overrides.single
                .toJson();
            await service.applyInvitationUpdate(
              masterCommand(
                await newerMaster(sequence: 18, date: date, zone: zone),
              ),
            );
            expect(
              (await data()).timingOverrides!.singles.single.cancelled,
              isTrue,
            );
            expect(
              (await data()).protocolState!.overrides.single.toJson(),
              protocol,
            );
            expect(
              (await service.applyInvitationOccurrenceCancellation(cancelInput))
                  .id,
              receipt.id,
            );
            final wholeView = await whole(sequence: 20);
            expect(wholeView.canApplyCancellation, isTrue);
            expect(wholeView.occurrenceCompositionBlocked, isFalse);
            await service.applyInvitationCancellation(masterCommand(wholeView));
            expect(
              (await data()).content.status,
              CalendarEventStatus.cancelled,
            );
            await service.applyInvitationUpdate(
              masterCommand(
                await newerMaster(sequence: 21, date: date, zone: zone),
              ),
            );
            expect(
              (await data()).timingOverrides!.singles.single.cancelled,
              isTrue,
            );
            expect((await data()).timingOverrides?.cancelledFrom, isNull);
            final reopen = await single(
              date: date,
              zone: zone,
              sequence: seq + 2,
            );
            expect(reopen.canApply, isTrue);
            await service.applyInvitationOccurrenceUpdate(command(reopen));
            expect(
              (await data()).timingOverrides!.singles.single.cancelled,
              isFalse,
            );
            expect(
              (jsonDecode((await row()).stateJson) as Map)['frozenRestoration'],
              first['frozenRestoration'],
            );
          },
        );
      }
    }
    test('v10 whole CANCEL floor still includes historical restoration independently of latest single', () async {
      await ready();
      await service.applyInvitationOccurrenceUpdate(command(await single()));
      final v = await whole(sequence: 9, stamp: '20270101T000000Z');
      expect(v.canApplyCancellation, isFalse);
      await expectLater(
        service.applyInvitationCancellation(masterCommand(v)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.applyInvitationCancellation(
        masterCommand(await whole(sequence: 11)),
      );
    });
    test(
      'higher current single remains a separate whole cancellation floor',
      () async {
        await ready();
        await service.applyInvitationOccurrenceUpdate(
          command(await single(sequence: 30)),
        );
        final v = await whole(sequence: 20);
        expect(v.canApplyCancellation, isFalse);
        await expectLater(
          service.applyInvitationCancellation(masterCommand(v)),
          failure(CalendarFailureCode.dependencyConflict),
        );
        await service.applyInvitationCancellation(
          masterCommand(await whole(sequence: 31)),
        );
      },
    );
    test('whole-cancelled master blocks new singles but retains latest non-mutating retry', () async {
      await ready();
      final input = command(await single());
      final r = await service.applyInvitationOccurrenceUpdate(input);
      final pending = await single(sequence: 3);
      await service.applyInvitationCancellation(masterCommand(await whole()));
      final v = await service.invitationOccurrenceApplication(
        pending.invitationId,
      );
      expect(v.canApply, isFalse);
      await expectLater(
        service.applyInvitationOccurrenceUpdate(command(v)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final before = (await data()).toJson();
      expect((await service.applyInvitationOccurrenceUpdate(input)).id, r.id);
      expect((await data()).toJson(), before);
    });
    test(
      'new ranges and restoration remain guarded after a single acceptance',
      () async {
        final restored = await ready();
        await service.applyInvitationOccurrenceUpdate(command(await single()));
        final source = await receive(rangeInvitationBytes(sequence: 20));
        final v = await service.invitationRangeApplication(source.entryId);
        expect(v.canApply, isFalse);
        await expectLater(
          service.applyInvitationRangeUpdate(command(v)),
          failure(CalendarFailureCode.dependencyConflict),
        );
        await expectLater(
          service.applyInvitationRangeRestoration(restored),
          failure(CalendarFailureCode.dependencyConflict),
        );
      },
    );
    test('local draft and cutoff conflict; retained current retry never overwrites them', () async {
      await ready();
      final input = command(await single());
      final r = await service.applyInvitationOccurrenceUpdate(input);
      final d = await data();
      d.content = d.content.copyWith(summary: 'Local draft');
      d.timingOverrides = d.timingOverrides!.copyWith(
        cancelledFrom: CalendarEventTiming(
          kind: CalendarEventTimeKind.utc,
          start: CalendarEventCivil(year: 2030, month: 1, day: 3, hour: 9),
        ),
      );
      await CalendarEventDataRecord.db.updateRow(session, d);
      final v = await single(sequence: 3);
      expect(v.hasLocalChanges, isTrue);
      expect(v.canApply, isFalse);
      await expectLater(
        service.applyInvitationOccurrenceUpdate(command(v)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await service.applyInvitationOccurrenceUpdate(input)).id, r.id);
      expect((await data()).toJson(), d.toJson());
    });
    test(
      'current target and historical proof bytes are charged before any write',
      () async {
        await ready();
        final input = command(await single()),
            before = (await data()).toJson(),
            prior = (await row()).toJson();
        install(
          options: CalendarInvitationOptions(
            maxOccurrenceCheckpointBytes:
                utf8.encode((await row()).stateJson).length + 8,
          ),
        );
        await expectLater(
          service.applyInvitationOccurrenceUpdate(input),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), prior);
      },
    );
    for (final op in [
      CalendarInvitationOperation.composeAcceptedOccurrences,
      CalendarInvitationOperation.composeAcceptedRangeCancellation,
      CalendarInvitationOperation.composeAcceptedRangeRestoration,
      CalendarInvitationOperation.applyOccurrenceUpdate,
      CalendarInvitationOperation.readOccurrenceApplication,
    ]) {
      test(
        'final $op denial rolls back native/source/checkpoint state',
        () async {
          await ready();
          final input = command(await single()),
              before = (await data()).toJson(),
              prior = (await row()).toJson();
          host.onAuthorize = (c, tx, phase) async {
            if (c.operation == op &&
                phase == CalendarAuthorizationPhase.finalWrite) {
              host.denied.add(op);
            }
          };
          await expectLater(
            service.applyInvitationOccurrenceUpdate(input),
            failure(CalendarFailureCode.accessDenied),
          );
          expect((await data()).toJson(), before);
          expect((await row()).toJson(), prior);
        },
      );
    }
    for (final op in [
      CalendarInvitationOperation.composeAcceptedRangeRestoration,
      CalendarInvitationOperation.applyOccurrenceUpdate,
    ]) {
      test('read eligibility withholds action when $op is denied', () async {
        await ready();
        final v = await single();
        host.denied.add(op);
        if (op == CalendarInvitationOperation.applyOccurrenceUpdate) {
          expect(
            (await service.invitationOccurrenceApplication(v.invitationId))
                .canApply,
            isFalse,
          );
        } else {
          await expectLater(
            service.invitationOccurrenceApplication(v.invitationId),
            failure(CalendarFailureCode.accessDenied),
          );
        }
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
      'targets',
      'latestTargetKey',
      'requestDigest',
      'receipt',
      'compositionDigest',
      'receiptDigest',
    ]) {
      test('missing v10 $field fails unavailable without fallback', () async {
        await ready();
        final input = command(await single());
        await service.applyInvitationOccurrenceUpdate(input);
        final value = await row(),
            state = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
        state.remove(field);
        value.stateJson = jsonEncode(state);
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          value,
        );
        await expectLater(
          service.applyInvitationOccurrenceUpdate(input),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
    test('historical restoration original remains protected after a different single is accepted', () async {
      await ready();
      await service.applyInvitationOccurrenceUpdate(
        command(await single(original: '20300103T090000Z')),
      );
      final v = await newerMaster(
        sequence: 12,
        extra: ['RRULE:FREQ=DAILY;COUNT=6', 'EXDATE:20300102T090000Z'],
      );
      expect(v.canApply, isFalse);
      await expectLater(
        service.applyInvitationUpdate(masterCommand(v)),
        failure(CalendarFailureCode.validation),
      );
    });
    test('existing range version governs later single and same-anchor collisions reject atomically', () async {
      await setup();
      final range = await receive(rangeInvitationBytes(sequence: 5));
      await service.applyInvitationRangeUpdate(
        command(await service.invitationRangeApplication(range.entryId)),
      );
      await service.applyInvitationRangeCancellation(
        await cancel(sequence: 10),
      );
      final restoredText = utf8.decode(rangeInvitationBytes(sequence: 11));
      final restoredSource = await receive(
        Uint8List.fromList(utf8.encode(restoredText)),
      );
      await service.applyInvitationRangeRestoration(
        command(
          await service.invitationRangeRestorationApplication(
            restoredSource.entryId,
          ),
        ),
      );
      final collision = await single(sequence: 12);
      expect(collision.canApply, isFalse);
      final before = (await data()).toJson();
      await expectLater(
        service.applyInvitationOccurrenceUpdate(command(collision)),
        failure(CalendarFailureCode.validation),
      );
      expect((await data()).toJson(), before);
      final oldFuture = (await data()).timingOverrides!.future.single.toJson();
      final low = await single(sequence: 4, original: '20300103T090000Z');
      expect(low.canApply, isFalse);
      final valid = await single(sequence: 6, original: '20300103T090000Z');
      expect(valid.canApply, isTrue);
      await service.applyInvitationOccurrenceUpdate(command(valid));
      expect((await data()).timingOverrides!.future.single.toJson(), oldFuture);
      expect((jsonDecode((await row()).stateJson) as Map)['targets'].length, 2);
    });
    for (final mutation in [
      'nested',
      'kind',
      'target-source',
      'target-version',
      'duplicate',
      'unknown-field',
    ]) {
      test('v10 $mutation corruption cannot be flattened or rebound', () async {
        await ready();
        final input = command(await single());
        await service.applyInvitationOccurrenceUpdate(input);
        final value = await row(),
            state = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
        switch (mutation) {
          case 'nested':
            state['frozenRestoration']['checkpoint']['state']['version'] = 10;
          case 'kind':
            state['masterKind'] = 'meetingCancellation';
          case 'target-source':
            state['targets'][0]['source'] = 'private malformed fixture';
          case 'target-version':
            state['targets'][0]['version']['sequence'] = 99;
          case 'duplicate':
            state['targets'].add(state['targets'][0]);
          case 'unknown-field':
            state['restoration'] = {};
        }
        value.stateJson = jsonEncode(state);
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          value,
        );
        await expectLater(
          service.applyInvitationOccurrenceUpdate(input),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
    test('pruning retains current source authority and deletion scrubs frozen and current data', () async {
      await ready();
      final input = command(await single());
      final receipt = await service.applyInvitationOccurrenceUpdate(input);
      final source = (await CalendarInvitationSourceRecord.db.findById(
        session,
        input.sourceId,
      ))!;
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
        where: (t) => t.sourceId.equals(source.id!),
      );
      await CalendarInvitationSourceRecord.db.deleteRow(session, source);
      expect(
        (await service.applyInvitationOccurrenceUpdate(input)).id,
        receipt.id,
      );
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.readSource &&
            c.sourceId == input.sourceId &&
            phase == CalendarAuthorizationPhase.finalWrite) {
          host.denied.add(CalendarInvitationOperation.readSource);
        }
      };
      await expectLater(
        service.applyInvitationOccurrenceUpdate(input),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denied.clear();
      host.onAuthorize = null;
      await service.deleteEvent(receipt.eventId, receipt.eventRevision);
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
    });
    for (final mode in ['relative', 'absolute', 'snooze']) {
      final absolute = mode == 'absolute';
      test(
        'v10 whole cancellation withdraws $mode reminders and reopening preserves actions without replay',
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
          final singleSource = await receive(
            instanceInvitationBytes(
              sequence: 12,
              cancel: true,
              original: point(due.add(const Duration(days: 2))),
            ),
          );
          await service.applyInvitationOccurrenceCancellation(
            command(
              await service.invitationOccurrenceApplication(
                singleSource.entryId,
              ),
            ),
          );
          expect((jsonDecode((await row()).stateJson) as Map)['version'], 10);
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
            masterCommand(await whole(sequence: 13)),
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
                  sequence: 14,
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
    test('legacy restoration receipt keeps its original permission contract before any new single', () async {
      final input = await ready();
      final before = (await data()).toJson(), prior = (await row()).toJson();
      host.denied.add(
        CalendarInvitationOperation.composeAcceptedRangeRestoration,
      );
      final receipt = await service.applyInvitationRangeRestoration(input);
      expect(receipt.eventRevision, 3);
      expect((await data()).toJson(), before);
      expect((await row()).toJson(), prior);
    });
  });
}
