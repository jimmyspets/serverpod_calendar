import 'dart:convert';

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
import 'test_tools/serverpod_test_tools.dart';

CalendarEventTiming timing(
  int day,
  CalendarEventTimeKind kind, {
  bool span = false,
}) => CalendarEventTiming(
  kind: kind,
  zoneId: kind == CalendarEventTimeKind.zoned ? 'Europe/Stockholm' : null,
  start: CalendarEventCivil(
    year: 2026,
    month: 1,
    day: day,
    hour: kind == CalendarEventTimeKind.date ? 0 : 9,
  ),
  duration: span
      ? (kind == CalendarEventTimeKind.date
            ? CalendarEventDuration(days: 1)
            : CalendarEventDuration(hours: 1))
      : null,
);
CalendarEventRule daily([int count = 5]) => CalendarEventRule(
  frequency: CalendarEventFrequency.daily,
  count: count,
  byDay: [],
  byMonthDay: [],
  byYearDay: [],
  byWeekNo: [],
  byMonth: [],
  byHour: [],
  byMinute: [],
  bySetPosition: [],
);

void main() {
  withServerpod('native event future cancellation', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late TestAlarmDeliveryPort delivery;
    late CalendarService service;
    late UuidValue calendar;
    setUp(() async {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      policy = TestPolicy();
      delivery = TestAlarmDeliveryPort();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        alarms: CalendarAlarmRuntime(
          policy: TestAlarmBackgroundPolicy(),
          delivery: delivery,
        ),
      );
      service = CalendarModule.service(session);
      calendar = (await service.create(createInput()))!.calendarId;
    });
    Future<CalendarEventReceipt> create([
      CalendarEventTimeKind kind = CalendarEventTimeKind.utc,
    ]) async => (await service.createEvent(
      CalendarEventCreateRequest(
        calendarId: calendar,
        content: CalendarEventContent(
          summary: 'Synthetic future series',
          timing: timing(1, kind, span: true),
          recurrence: CalendarEventRecurrence(
            rule: daily(),
            inclusions: [],
            exclusions: [],
          ),
        ),
      ),
    ))!;
    Future<CalendarEventDataRecord> data(UuidValue id) async =>
        (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(id),
        ))!;
    Future<int> revision(UuidValue id) async =>
        (await CalendarEventRecord.db.findById(session, id))!.revision;
    Future<CalendarEventReceipt?> act(
      UuidValue id,
      CalendarEventTimeKind kind,
      int day,
      CalendarEventOccurrenceAction action, {
      int? expected,
      CalendarEventTiming? replacement,
    }) async => service.changeOccurrence(
      CalendarEventOccurrenceChange(
        eventId: id,
        expectedRevision: expected ?? await revision(id),
        originalStart: timing(day, kind),
        action: action,
        replacement: replacement,
      ),
    );
    CalendarEventOccurrenceListQuery query({
      bool cancelled = false,
      String? cursor,
      int size = 20,
    }) => CalendarEventOccurrenceListQuery(
      calendarId: calendar,
      fromUtc: DateTime.utc(2025, 12, 31),
      untilUtc: DateTime.utc(2026, 1, 10),
      includeCancelled: cancelled,
      pageSize: size,
      cursor: cursor,
      fieldGroups: [],
    );
    Future<int> busyCount() async => (await service.freeBusy(
      CalendarFreeBusyQuery(
        calendarId: calendar,
        fromUtc: DateTime.utc(2025, 12, 31),
        untilUtc: DateTime.utc(2026, 1, 10),
      ),
    )).periods.where((p) => p.kind == CalendarFreeBusyKind.busy).length;
    Future<Object> export(UuidValue id) async => service.exportEvents(
      CalendarEventExportRequest(
        calendarId: calendar,
        expectedRevision: (await CalendarIdentityRecord.db.findById(
          session,
          calendar,
        ))!.revision,
        selection: [
          CalendarEventExportSelection(
            eventId: id,
            expectedRevision: await revision(id),
          ),
        ],
      ),
    );

    for (final kind in [
      CalendarEventTimeKind.date,
      CalendarEventTimeKind.utc,
      CalendarEventTimeKind.zoned,
    ]) {
      test(
        '${kind.name} native actions retain timing and individual flags across restoration',
        () async {
          final id = (await create(kind)).eventId;
          final parent = (await CalendarDataRecord.db.findFirstRow(
            session,
            where: (t) => t.calendarId.equals(calendar),
          ))!.toJson();
          await act(
            id,
            kind,
            3,
            CalendarEventOccurrenceAction.replaceSingleTiming,
            replacement: timing(1, kind, span: true),
          );
          await act(id, kind, 4, CalendarEventOccurrenceAction.cancelSingle);
          await act(
            id,
            kind,
            2,
            CalendarEventOccurrenceAction.replaceFutureTiming,
            replacement: timing(3, kind, span: true),
          );
          final before = await data(id),
              old = jsonEncode((await data(id)).timingOverrides!.toJson());
          final firstPage = await service.listEventOccurrences(query(size: 1));
          await act(id, kind, 2, CalendarEventOccurrenceAction.cancelFuture);
          final masked = await data(id);
          expect(masked.timingOverrides!.cancelledFrom!.start.day, 2);
          expect(
            masked.protocolState!.version.sequence,
            before.protocolState!.version.sequence! + 1,
          );
          expect(
            masked.protocolState!.overrides.map((v) => v.toJson()),
            before.protocolState!.overrides.map((v) => v.toJson()),
          );
          expect(
            (await service.listEventOccurrences(query())).occurrences.length,
            1,
          );
          expect(
            (await service.listEventOccurrences(query(cancelled: true)))
                .occurrences
                .where((v) => v.cancelled)
                .length,
            4,
          );
          expect(await busyCount(), 1);
          await expectLater(
            export(id),
            failure(CalendarFailureCode.validation),
          );
          if (firstPage.nextCursor != null) {
            await expectLater(
              service.listEventOccurrences(
                query(size: 1, cursor: firstPage.nextCursor),
              ),
              failure(CalendarFailureCode.invalidCursor),
            );
          }
          await act(id, kind, 4, CalendarEventOccurrenceAction.cancelFuture);
          expect(
            (await data(id)).protocolState!.toJson(),
            masked.protocolState!.toJson(),
          );
          await expectLater(
            act(id, kind, 4, CalendarEventOccurrenceAction.restoreFuture),
            failure(CalendarFailureCode.validation),
          );
          await act(id, kind, 2, CalendarEventOccurrenceAction.restoreFuture);
          expect(jsonEncode((await data(id)).timingOverrides!.toJson()), old);
          expect(
            (await service.listEventOccurrences(query())).occurrences.length,
            4,
          );
          expect(
            (await service.listEventOccurrences(query(cancelled: true)))
                .occurrences
                .where((v) => v.cancelled)
                .length,
            1,
          );
          expect(
            (await CalendarDataRecord.db.findFirstRow(
              session,
              where: (t) => t.calendarId.equals(calendar),
            ))!.toJson(),
            parent,
          );
          // The preserved follow-series single cancellation remains unrepresentable.
          await expectLater(
            export(id),
            failure(CalendarFailureCode.validation),
          );
        },
      );
    }
    test('restore enables export again and deletion removes all active cutoff state', () async {
      final id = (await create()).eventId;
      await export(id);
      await act(
        id,
        CalendarEventTimeKind.utc,
        2,
        CalendarEventOccurrenceAction.cancelFuture,
      );
      await expectLater(export(id), failure(CalendarFailureCode.validation));
      await act(
        id,
        CalendarEventTimeKind.utc,
        2,
        CalendarEventOccurrenceAction.restoreFuture,
      );
      await export(id);
      await act(
        id,
        CalendarEventTimeKind.utc,
        2,
        CalendarEventOccurrenceAction.cancelFuture,
      );
      await service.deleteEvent(id, await revision(id));
      expect(
        await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(id),
        ),
        isNull,
      );
      expect(
        (await CalendarEventRecord.db.findById(session, id))!.deletedAt,
        isNotNull,
      );
    });
    test('independent lifecycle authority and final denial preserve complete state', () async {
      final id = (await create()).eventId;
      policy.denied.add(CalendarPermission.changeEventStatus);
      await expectLater(
        act(
          id,
          CalendarEventTimeKind.utc,
          2,
          CalendarEventOccurrenceAction.cancelFuture,
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.denyFinal = true;
      final before = jsonEncode((await data(id)).toJson());
      await expectLater(
        act(
          id,
          CalendarEventTimeKind.utc,
          2,
          CalendarEventOccurrenceAction.cancelFuture,
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(jsonEncode((await data(id)).toJson()), before);
      expect(await revision(id), 1);
      policy.denyFinal = false;
      policy.denied.add(CalendarPermission.updateEvent);
      var saw = false;
      policy.onEventLifecycle = (request, phase) {
        expect(request.currentEvent!.eventId, id);
        if (phase == CalendarAuthorizationPhase.finalWrite) {
          expect(request.proposedTimingOverrides!.cancelledFrom!.start.day, 2);
          expect(
            () => request.proposedTimingOverrides!.singles.clear(),
            throwsUnsupportedError,
          );
          saw = true;
        }
      };
      await act(
        id,
        CalendarEventTimeKind.utc,
        2,
        CalendarEventOccurrenceAction.cancelFuture,
      );
      expect(saw, isTrue);
      policy.onEventLifecycle = null;
      policy.denied.add(CalendarPermission.changeEventStatus);
      await expectLater(
        act(
          id,
          CalendarEventTimeKind.utc,
          2,
          CalendarEventOccurrenceAction.restoreFuture,
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect((await data(id)).timingOverrides!.cancelledFrom, isNotNull);
    });
    test(
      'hidden timing is not disclosed and stale or orphaning writes reject',
      () async {
        final id = (await create()).eventId;
        await act(
          id,
          CalendarEventTimeKind.utc,
          2,
          CalendarEventOccurrenceAction.cancelFuture,
        );
        policy.eventGrants.remove(CalendarEventFieldGroup.timing);
        expect(
          (await service.getEvent(
            id,
            CalendarEventFieldGroup.values,
          )).timingOverrides,
          isNull,
        );
        policy.eventGrants.add(CalendarEventFieldGroup.timing);
        await expectLater(
          act(
            id,
            CalendarEventTimeKind.utc,
            2,
            CalendarEventOccurrenceAction.restoreFuture,
            expected: 1,
          ),
          failure(CalendarFailureCode.staleRevision),
        );
        final row = await data(id);
        await expectLater(
          service.updateEvent(
            CalendarEventUpdateRequest(
              eventId: id,
              expectedRevision: await revision(id),
              content: row.content.copyWith(
                recurrence: row.content.recurrence!.copyWith(
                  exclusions: [timing(2, CalendarEventTimeKind.utc)],
                ),
              ),
              replaceRecurrenceDates: true,
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(
          (await data(id)).timingOverrides!.toJson(),
          row.timingOverrides!.toJson(),
        );
      },
    );
    test('protocol overflow rolls back cutoff and API revision', () async {
      final id = (await create()).eventId;
      final row = await data(id);
      row.protocolState = row.protocolState!.copyWith(
        version: row.protocolState!.version.copyWith(sequence: 2147483647),
      );
      await CalendarEventDataRecord.db.updateRow(session, row);
      await expectLater(
        act(
          id,
          CalendarEventTimeKind.utc,
          2,
          CalendarEventOccurrenceAction.cancelFuture,
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect((await data(id)).timingOverrides, isNull);
      expect(await revision(id), 1);
    });
    for (final absolute in [false, true]) {
      test(
        'restoration does not redeliver retained ${absolute ? 'absolute item' : 'relative'} acceptance',
        () async {
          final raw =
              (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                      .single
                      .single
                  as DateTime;
          final due = DateTime.fromMillisecondsSinceEpoch(
            raw.toUtc().millisecondsSinceEpoch ~/ 1000 * 1000,
            isUtc: true,
          ).subtract(const Duration(minutes: 1));
          final anchor = CalendarEventTiming(
            kind: CalendarEventTimeKind.utc,
            start: CalendarEventCivil(
              year: due.year,
              month: due.month,
              day: due.day,
              hour: due.hour,
              minute: due.minute,
              second: due.second,
            ),
          );
          final id = (await service.createEvent(
            CalendarEventCreateRequest(
              calendarId: calendar,
              content: CalendarEventContent(
                timing: anchor.copyWith(
                  duration: CalendarEventDuration(hours: 1),
                ),
                recurrence: CalendarEventRecurrence(
                  rule: daily(3),
                  inclusions: [],
                  exclusions: [],
                ),
              ),
            ),
          ))!.eventId;
          final parent = CalendarAlarmParent(
            kind: CalendarAlarmParentKind.event,
            id: id,
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
          for (final action in [
            CalendarEventOccurrenceAction.cancelFuture,
            CalendarEventOccurrenceAction.restoreFuture,
          ]) {
            await service.changeOccurrence(
              CalendarEventOccurrenceChange(
                eventId: id,
                expectedRevision: await revision(id),
                originalStart: anchor,
                action: action,
              ),
            );
            await CalendarModule.runAlarmMaintenance(session);
            expect(delivery.calls, 1);
          }
          expect(
            (await CalendarAlarmRecord.db.findById(session, alarm.id))!.armed,
            isTrue,
          );
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
    test('relative accepted/repeat/snooze recovery withdraws and actions survive restoration', () async {
      final nowRaw =
          (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                  .single
                  .single
              as DateTime;
      final now = DateTime.fromMillisecondsSinceEpoch(
        nowRaw.toUtc().millisecondsSinceEpoch ~/ 1000 * 1000,
        isUtc: true,
      );
      final start = now.subtract(const Duration(minutes: 1));
      final anchor = CalendarEventTiming(
        kind: CalendarEventTimeKind.utc,
        start: CalendarEventCivil(
          year: start.year,
          month: start.month,
          day: start.day,
          hour: start.hour,
          minute: start.minute,
          second: start.second,
        ),
      );
      final id = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: calendar,
          content: CalendarEventContent(
            timing: anchor.copyWith(duration: CalendarEventDuration(hours: 1)),
            recurrence: CalendarEventRecurrence(
              rule: daily(3),
              inclusions: [],
              exclusions: [],
            ),
          ),
        ),
      ))!.eventId;
      final parent = CalendarAlarmParent(
        kind: CalendarAlarmParentKind.event,
        id: id,
      );
      final alarm = (await service.createPersonalAlarm(
        CalendarAlarmCreateRequest(
          parent: parent,
          definition: CalendarAlarmDefinition(
            relativeDuration: CalendarAlarmDuration(),
            anchor: CalendarAlarmAnchor.start,
            repeat: 2,
            repeatInterval: CalendarAlarmDuration(seconds: 20),
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
      final intent = delivery.accepted.values.first;
      expect(
        await CalendarModule.checkAlarmDelivery(session, intent),
        CalendarAlarmDeliveryCheck.eligible,
      );
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
          snoozeAt: now.add(const Duration(minutes: 5)),
        ),
      );
      final action = (await CalendarAlarmActionRecord.db.findFirstRow(
        session,
        where: (t) => t.alarmId.equals(alarm.id),
      ))!;
      final plan = (await CalendarAlarmPlanRecord.db.findFirstRow(
        session,
        where: (t) => t.alarmId.equals(alarm.id),
      ))!;
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: await revision(id),
          originalStart: anchor,
          action: CalendarEventOccurrenceAction.cancelFuture,
        ),
      );
      final invalid = (await CalendarAlarmPlanRecord.db.findById(
        session,
        plan.id!,
      ))!;
      expect(invalid.dirty, isTrue);
      expect(invalid.leaseFence, greaterThan(plan.leaseFence));
      expect(
        await CalendarModule.checkAlarmDelivery(session, intent),
        CalendarAlarmDeliveryCheck.withdrawn,
      );
      expect(
        await CalendarModule.projectAlarmNotification(session, intent),
        isNull,
      );
      await CalendarModule.runAlarmMaintenance(session);
      final masked = (await CalendarAlarmPlanRecord.db.findById(
        session,
        plan.id!,
      ))!;
      expect(masked.timingDigest, isNot(plan.timingDigest));
      expect(
        (await CalendarAlarmActionRecord.db.findById(
          session,
          action.id!,
        ))!.toJson(),
        action.toJson(),
      );
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: await revision(id),
          originalStart: anchor,
          action: CalendarEventOccurrenceAction.restoreFuture,
        ),
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(
        (await CalendarAlarmActionRecord.db.findById(
          session,
          action.id!,
        ))!.toJson(),
        action.toJson(),
      );
      expect(
        await CalendarModule.projectAlarmNotification(session, intent),
        isNull,
      );
    });
  });
}
