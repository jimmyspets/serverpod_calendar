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
  withServerpod('master lifecycle retaining range cancellation', (
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

    for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
      for (final priorComposition in [false, true]) {
        test(
          '$profile ${priorComposition ? 'v5' : 'v4'}-v6 cancellation/reopening keeps original evidence and retries',
          () async {
            final date = profile == 'date',
                zone = profile == 'Europe/Stockholm' ? profile : null;
            await setup(date: date, zone: zone);
            final input = await cancel(sequence: 10, date: date, zone: zone);
            final rangeResult = await service.applyInvitationRangeCancellation(
              input,
            );
            if (priorComposition) {
              await service.applyInvitationUpdate(
                masterCommand(
                  await newerMaster(sequence: 2, date: date, zone: zone),
                ),
              );
            }
            final old = jsonDecode((await row()).stateJson) as Map;
            final frozen =
                old['cancellationBasis'] ??
                (await data()).importBaseline!.toJson();
            final v = await whole(
              extra: ['CREATED:20250101T000000Z', 'DESCRIPTION:Review only'],
            );
            expect(v.hasAcceptedRangeCancellation, isTrue);
            expect(v.canApplyCancellation, isTrue);
            final request = masterCommand(v),
                result = await service.applyInvitationCancellation(
                  masterCommand(v),
                );
            var d = await data();
            var state = jsonDecode((await row()).stateJson) as Map;
            expect(state['version'], 6);
            expect(state['rangeCancellation'], old['rangeCancellation']);
            expect(state['cancellationBasis'], frozen);
            expect(d.content.status, CalendarEventStatus.cancelled);
            expect(d.content.description, isNull);
            expect(d.timingOverrides!.cancelledFrom!.start.day, 2);
            expect(d.protocolState!.version.sequence, 11);
            expect(d.protocolState!.version.created, DateTime.utc(2025));
            expect(d.protocolState!.version.lastModified, isNull);
            expect(
              d.importBaseline!.canonicalValue,
              isNot(contains('cancelledFrom')),
            );
            final before = d.toJson(), beforeRow = (await row()).toJson();
            expect(
              (await service.applyInvitationCancellation(request)).id,
              result.id,
            );
            expect(
              (await service.applyInvitationRangeCancellation(input)).id,
              rangeResult.id,
            );
            expect((await data()).toJson(), before);
            expect((await row()).toJson(), beforeRow);
            final reopened = await newerMaster(
              sequence: 12,
              date: date,
              zone: zone,
            );
            expect(reopened.canApply, isTrue);
            expect(reopened.canApplyCancellation, isFalse);
            final reopenRequest = masterCommand(reopened),
                reopenedResult = await service.applyInvitationUpdate(
                  masterCommand(reopened),
                );
            d = await data();
            state = jsonDecode((await row()).stateJson) as Map;
            expect(state['version'], 6);
            expect(state['cancellationBasis'], frozen);
            expect(state['rangeCancellation'], old['rangeCancellation']);
            expect(d.content.status, CalendarEventStatus.confirmed);
            expect(d.timingOverrides!.cancelledFrom!.start.day, 2);
            final retained = await service.invitationRangeApplication(
              input.invitationId,
            );
            expect(retained.hasLocalChanges, isFalse);
            expect(retained.acceptedVersion.sequence, 10);
            expect(
              retained.currentOccurrence!.status,
              CalendarEventStatus.cancelled,
            );
            expect(
              (await service.applyInvitationUpdate(reopenRequest)).id,
              reopenedResult.id,
            );
            expect(
              (await service.applyInvitationRangeCancellation(input)).id,
              rangeResult.id,
            );
            await service.applyInvitationUpdate(
              masterCommand(
                await newerMaster(sequence: 13, date: date, zone: zone),
              ),
            );
            expect(jsonDecode((await row()).stateJson)['version'], 6);
          },
        );
      }
    }
    for (final sequence in [9, 10]) {
      test(
        'whole CANCEL $sequence does not override historical range version 10',
        () async {
          await setup();
          await service.applyInvitationRangeCancellation(
            await cancel(sequence: 10),
          );
          final v = await whole(sequence: sequence, stamp: '20270101T000000Z');
          expect(v.canApplyCancellation, isFalse);
          expect(v.occurrenceCompositionBlocked, isTrue);
          final before = (await data()).toJson(),
              beforeRow = (await row()).toJson();
          await expectLater(
            service.applyInvitationCancellation(masterCommand(v)),
            failure(CalendarFailureCode.dependencyConflict),
          );
          expect((await data()).toJson(), before);
          expect((await row()).toJson(), beforeRow);
        },
      );
    }
    test('repeated whole cancellations require strict advancement and reopening preserves the mask', () async {
      await setup();
      await service.applyInvitationRangeCancellation(
        await cancel(sequence: 10),
      );
      await service.applyInvitationCancellation(masterCommand(await whole()));
      final equal = await whole(stamp: '20260101T000001Z');
      expect(equal.canApplyCancellation, isFalse);
      await expectLater(
        service.applyInvitationCancellation(masterCommand(equal)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.applyInvitationCancellation(
        masterCommand(await whole(sequence: 12)),
      );
      await service.applyInvitationUpdate(
        masterCommand(await newerMaster(sequence: 13)),
      );
      expect((await data()).timingOverrides!.cancelledFrom, isNotNull);
    });
    for (final op in [
      CalendarInvitationOperation.applyCancellation,
      CalendarInvitationOperation.composeAcceptedRangeCancellation,
      CalendarInvitationOperation.composeAcceptedOccurrences,
    ]) {
      test(
        'independent $op gates preview and rolls back final lifecycle denial',
        () async {
          await setup();
          await service.applyInvitationRangeCancellation(
            await cancel(sequence: 10),
          );
          final v = await whole();
          final request = masterCommand(v);
          host.denied.add(op);
          final denied = await service.invitationApplication(v.invitationId);
          expect(denied.canApplyCancellation, isFalse);
          host.denied.clear();
          final before = (await data()).toJson(),
              oldRow = (await row()).toJson();
          host.onAuthorize = (c, tx, phase) async {
            if (c.operation == op &&
                phase == CalendarAuthorizationPhase.finalWrite) {
              expect(
                c.proposedEvent!.content.status,
                CalendarEventStatus.cancelled,
              );
              expect(
                c.proposedEvent!.timingOverrides!.cancelledFrom,
                isNotNull,
              );
              expect(
                jsonDecode(
                  c.proposedOccurrenceApplication!.stateJson,
                )['version'],
                6,
              );
              host.denied.add(op);
            }
          };
          await expectLater(
            service.applyInvitationCancellation(request),
            failure(CalendarFailureCode.accessDenied),
          );
          expect((await data()).toJson(), before);
          expect((await row()).toJson(), oldRow);
        },
      );
    }
    test('lifecycle native permission remains required for cancellation and reopening', () async {
      await setup();
      await service.applyInvitationRangeCancellation(
        await cancel(sequence: 10),
      );
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
    test('local restoration after whole cancellation is dirty and exact retries do not reapply cutoff', () async {
      final link = await setup();
      final input = await cancel(sequence: 10);
      final range = await service.applyInvitationRangeCancellation(input);
      final request = masterCommand(await whole()),
          result = await service.applyInvitationCancellation(request);
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: link.eventId,
          expectedRevision: result.eventRevision,
          originalStart: (await data()).timingOverrides!.cancelledFrom!,
          action: CalendarEventOccurrenceAction.restoreFuture,
        ),
      );
      final v = await newerMaster(sequence: 12);
      expect(v.hasLocalChanges, isTrue);
      expect(v.canApply, isFalse);
      await expectLater(
        service.applyInvitationUpdate(masterCommand(v)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final before = (await data()).toJson(), oldRow = (await row()).toJson();
      expect(
        (await service.applyInvitationCancellation(request)).id,
        result.id,
      );
      expect(
        (await service.applyInvitationRangeCancellation(input)).id,
        range.id,
      );
      expect((await data()).toJson(), before);
      expect((await row()).toJson(), oldRow);
    });
    test('whole floor includes an accepted original before the range cutoff; its cancellation survives reopening', () async {
      await setup();
      final r = await receive(
        instanceInvitationBytes(
          sequence: 30,
          cancel: true,
          original: '20300101T090000Z',
        ),
      );
      await service.applyInvitationOccurrenceCancellation(
        command(await service.invitationOccurrenceApplication(r.entryId)),
      );
      await service.applyInvitationRangeCancellation(
        await cancel(sequence: 10),
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
      final old = (await data()).protocolState!.overrides
          .map((v) => v.toJson())
          .toList();
      await service.applyInvitationUpdate(
        masterCommand(await newerMaster(sequence: 32)),
      );
      final d = await data();
      expect(d.timingOverrides!.singles.single.cancelled, isTrue);
      expect(d.protocolState!.overrides.map((v) => v.toJson()).toList(), old);
    });
    test('omitted old sequence stays omitted in frozen evidence and maximum floor has no implicit increment', () async {
      await setup(sequence: null);
      final input = await cancel(sequence: 2147483647);
      final result = await service.applyInvitationRangeCancellation(input);
      final v = await whole(sequence: 2147483647, stamp: '20270101T000000Z');
      expect(v.canApplyCancellation, isFalse);
      await expectLater(
        service.applyInvitationCancellation(masterCommand(v)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(
        (await service.applyInvitationRangeCancellation(input)).id,
        result.id,
      );
      expect((await data()).importBaseline!.sourceSequence, isNull);
    });
    test('reopening follows existing equal-sequence later-stamp ordering without restoring suffix', () async {
      await setup();
      await service.applyInvitationRangeCancellation(
        await cancel(sequence: 10),
      );
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
      expect((await data()).timingOverrides!.cancelledFrom, isNotNull);
      expect((await data()).protocolState!.version.sequence, 11);
    });
    for (final baseVersion in [4, 5]) {
      test('marker-only v$baseVersion-to-v6 upgrade rejects', () async {
        await setup();
        final input = await cancel(sequence: 10);
        await service.applyInvitationRangeCancellation(input);
        if (baseVersion == 5) {
          await service.applyInvitationUpdate(
            masterCommand(await newerMaster(sequence: 2)),
          );
        }
        final r = await row(),
            state = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
        state['version'] = 6;
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          r.copyWith(stateJson: jsonEncode(state)),
        );
        await expectLater(
          service.invitationRangeApplication(input.invitationId),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
    test(
      'current source-kind mismatch is not accepted as a v6 projection',
      () async {
        await setup();
        final input = await cancel(sequence: 10);
        await service.applyInvitationRangeCancellation(input);
        await service.applyInvitationCancellation(masterCommand(await whole()));
        final record = (await CalendarInvitationApplicationRecord.db.find(
          session,
        )).single;
        await CalendarInvitationApplicationRecord.db.updateRow(
          session,
          record.copyWith(kind: CalendarInvitationSourceKind.request),
        );
        await expectLater(
          service.invitationRangeApplication(input.invitationId),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test('source pruning and deletion preserve retry evidence then scrub v6 content', () async {
      final link = await setup();
      final input = await cancel(sequence: 10);
      final range = await service.applyInvitationRangeCancellation(input);
      final request = masterCommand(await whole());
      final cancelled = await service.applyInvitationCancellation(request);
      for (final id in [input.sourceId, request.sourceId]) {
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
        (await service.applyInvitationCancellation(request)).id,
        cancelled.id,
      );
      expect(
        (await service.applyInvitationRangeCancellation(input)).id,
        range.id,
      );
      await service.deleteEvent(link.eventId, cancelled.eventRevision);
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
    });
    test('quota and original source authority failures leave whole lifecycle atomic', () async {
      await setup();
      final input = await cancel(sequence: 10);
      await service.applyInvitationRangeCancellation(input);
      final v = await whole();
      final request = masterCommand(v),
          before = (await data()).toJson(),
          oldRow = (await row()).toJson();
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
        service.applyInvitationCancellation(request),
        failure(CalendarFailureCode.limitExceeded),
      );
      install();
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.readSource &&
            c.sourceId == input.sourceId &&
            phase == CalendarAuthorizationPhase.finalWrite) {
          host.denied.add(CalendarInvitationOperation.readSource);
        }
      };
      await expectLater(
        service.applyInvitationCancellation(request),
        failure(CalendarFailureCode.accessDenied),
      );
      expect((await data()).toJson(), before);
      expect((await row()).toJson(), oldRow);
    });
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
            masterCommand(await whole()),
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
                  sequence: 12,
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
          expect((await data()).timingOverrides!.cancelledFrom, isNotNull);
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
    test('whole cancel removes booking and reopening restores only pre-cutoff originals', () async {
      final link = await setup(extra: ['DURATION:PT1H']);
      await service.applyInvitationRangeCancellation(
        await cancel(sequence: 10),
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

      expect(await occupied(), 1);
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
      expect(await occupied(), 1);
    });
    test(
      'orphaning reopening cannot erase the cutoff while master is cancelled',
      () async {
        await setup();
        await service.applyInvitationRangeCancellation(
          await cancel(sequence: 10),
        );
        await service.applyInvitationCancellation(masterCommand(await whole()));
        final v = await newerMaster(
          sequence: 12,
          extra: ['RRULE:FREQ=DAILY;COUNT=1'],
        );
        expect(v.canApply, isFalse);
        final before = (await data()).toJson(), old = (await row()).toJson();
        await expectLater(
          service.applyInvitationUpdate(masterCommand(v)),
          failure(CalendarFailureCode.validation),
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), old);
      },
    );
    for (final field in [
      'cancellationBasis',
      'cancellationNativeDigest',
      'compositionDigest',
      'expectedNativeDigest',
      'receiptDigest',
    ]) {
      test('corrupt v6 $field rejects rather than falling back', () async {
        await setup();
        final input = await cancel(sequence: 10);
        await service.applyInvitationRangeCancellation(input);
        await service.applyInvitationCancellation(masterCommand(await whole()));
        final r = await row(),
            state = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
        if (field == 'cancellationBasis') {
          state.remove(field);
        } else {
          state[field] = '0' * 64;
        }
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          r.copyWith(stateJson: jsonEncode(state)),
        );
        await expectLater(
          service.invitationRangeApplication(input.invitationId),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
  });
}
