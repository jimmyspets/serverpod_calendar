import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/src/availability_storage_values.dart';
import 'package:serverpod_calendar_server/src/availability_wire_storage.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/task_recurrence_values.dart';
import 'package:serverpod_calendar_server/src/task_source_values.dart';
import 'package:serverpod_calendar_server/src/alarm_work_store.dart';

import 'test_tools/serverpod_test_tools.dart';

const groups = CalendarFieldGroup.values;
const eventGroups = CalendarEventFieldGroup.values;
CalendarEventContent eventInput({
  String? summary,
  CalendarEventStatus status = CalendarEventStatus.confirmed,
}) => CalendarEventContent(
  summary: summary,
  status: status,
  timing: CalendarEventTiming(
    kind: CalendarEventTimeKind.date,
    start: CalendarEventCivil(year: 2026, month: 3, day: 29),
  ),
);

CalendarCreateRequest createInput([String name = 'Calendar']) =>
    CalendarCreateRequest(
      displayName: name,
      availabilityZoneId: 'Europe/Stockholm',
      noRuleFallback: CalendarNoRuleFallback.free,
    );
Matcher failure(CalendarFailureCode code) =>
    throwsA(isA<CalendarException>().having((e) => e.code, 'code', code));

void main() {
  withServerpod('calendar storage and replaceable policy', (
    builder,
    endpoints,
  ) {
    late Session session;
    late TestPolicy policy;
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
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
      );
      service = CalendarModule.service(session);
    });
    CalendarEventRule daily({int count = 3}) => CalendarEventRule(
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
    CalendarEventTiming day(
      int n, {
      CalendarEventTimeKind kind = CalendarEventTimeKind.date,
    }) => CalendarEventTiming(
      kind: kind,
      start: CalendarEventCivil(year: 2026, month: 3, day: n),
    );
    CalendarEventOccurrenceQuery preview(UuidValue id, {int revision = 1}) =>
        CalendarEventOccurrenceQuery(
          eventId: id,
          expectedRevision: revision,
          fromDate: CalendarEventCivil(year: 2026, month: 3, day: 1),
          untilDate: CalendarEventCivil(year: 2026, month: 4, day: 1),
        );
    CalendarEventOccurrenceChange occurrenceChange(
      UuidValue id,
      CalendarEventOccurrenceAction action, {
      int revision = 1,
      int dayNumber = 30,
      CalendarEventTiming? replacement,
    }) => CalendarEventOccurrenceChange(
      eventId: id,
      expectedRevision: revision,
      originalStart: day(dayNumber),
      action: action,
      replacement: replacement,
    );
    Future<UuidValue> recurringEvent() async {
      final parent = (await service.create(createInput()))!.calendarId;
      return (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput().copyWith(
            recurrence: CalendarEventRecurrence(
              rule: daily(),
              inclusions: [],
              exclusions: [],
            ),
          ),
        ),
      ))!.eventId;
    }

    CalendarFreeBusyQuery busyQuery(UuidValue calendar) =>
        CalendarFreeBusyQuery(
          calendarId: calendar,
          fromUtc: DateTime.utc(2026, 3, 29),
          untilUtc: DateTime.utc(2026, 3, 30),
        );
    Future<CalendarEventReceipt> booking(
      UuidValue calendar,
      int hour,
      int end, {
      CalendarEventStatus status = CalendarEventStatus.confirmed,
      CalendarEventTransparency transparency = CalendarEventTransparency.opaque,
    }) async => (await service.createEvent(
      CalendarEventCreateRequest(
        calendarId: calendar,
        content: CalendarEventContent(
          summary: 'Private booking',
          description: 'Private notes',
          location: 'Private room',
          status: status,
          transparency: transparency,
          timing: CalendarEventTiming(
            kind: CalendarEventTimeKind.utc,
            start: CalendarEventCivil(
              year: 2026,
              month: 3,
              day: 29,
              hour: hour,
            ),
            end: CalendarEventCivil(year: 2026, month: 3, day: 29, hour: end),
          ),
        ),
      ),
    ))!;
    CalendarAvailabilityTarget target([String id = 'alice']) =>
        CalendarAvailabilityTarget(
          namespace: 'test',
          kind: 'user',
          externalId: id,
        );
    CalendarAvailabilitySearchQuery searchQuery(
      List<CalendarAvailabilityTarget> targets, {
      CalendarAvailabilitySearchMode mode =
          CalendarAvailabilitySearchMode.commonFree,
      int minimum = 1,
    }) => CalendarAvailabilitySearchQuery(
      targets: targets,
      fromUtc: DateTime.utc(2026, 3, 29),
      untilUtc: DateTime.utc(2026, 3, 30),
      mode: mode,
      minimumSeconds: minimum,
    );
    Future<UuidValue> contributor(
      String name, {
      bool contributes = true,
    }) async {
      final calendar = (await service.create(createInput()))!.calendarId;
      await service.changeSubject(
        CalendarSubjectChangeRequest(
          calendarId: calendar,
          expectedRevision: 1,
          action: CalendarSubjectAction.attach,
          namespace: 'test',
          kind: 'user',
          externalId: name,
          contributesAvailability: contributes,
        ),
      );
      return calendar;
    }

    CalendarTaskContent taskContent([String? summary]) => CalendarTaskContent(
      summary: summary,
      timing: CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
    );
    Future<CalendarTaskReceipt> taskCreate(
      UuidValue calendar, {
      List<CalendarTaskAssignee> assignees = const [],
    }) async => (await service.createTask(
      CalendarTaskCreateRequest(
        calendarId: calendar,
        content: taskContent('Private task'),
        assignees: assignees,
      ),
    ))!;
    Future<CalendarTaskView> taskRead(UuidValue id) =>
        service.getTask(id, CalendarTaskFieldGroup.values);
    CalendarTaskProgressRequest progressRequest(
      UuidValue id,
      int revision,
      CalendarTaskProgressAction action, [
      int? percent,
    ]) => CalendarTaskProgressRequest(
      taskId: id,
      expectedRevision: revision,
      action: action,
      percentComplete: percent,
    );
    const taskGroups = CalendarTaskFieldGroup.values;

    Future<CalendarTaskReceipt> recurringTask() async {
      final parent = (await service.create(createInput()))!.calendarId;
      return (await service.createTask(
        CalendarTaskCreateRequest(
          calendarId: parent,
          content: CalendarTaskContent(
            timing: CalendarTaskTiming(
              kind: CalendarTaskTimeKind.date,
              start: CalendarEventCivil(year: 2026, month: 3, day: 28),
              duration: CalendarEventDuration(days: 1),
            ),
            recurrence: CalendarEventRecurrence(
              rule: daily(),
              inclusions: [],
              exclusions: [],
            ),
          ),
          assignees: [],
        ),
      ))!;
    }

    CalendarTaskOccurrenceQuery taskPreview(
      CalendarTaskReceipt t, [
      int revision = 1,
    ]) => CalendarTaskOccurrenceQuery(
      taskId: t.taskId,
      expectedRevision: revision,
      fromDate: CalendarEventCivil(year: 2026, month: 3, day: 27),
      untilDate: CalendarEventCivil(year: 2026, month: 4, day: 1),
    );
    CalendarTaskOccurrenceProgressRequest occurrenceProgress(
      CalendarTaskReceipt t,
      CalendarEventTiming original,
      int revision,
      CalendarTaskProgressAction action, [
      int? percentage,
    ]) => CalendarTaskOccurrenceProgressRequest(
      taskId: t.taskId,
      expectedRevision: revision,
      originalStart: original,
      action: action,
      percentComplete: percentage,
    );
    CalendarTaskHistoryQuery taskHistory(
      CalendarTaskReceipt t,
      CalendarEventTiming original,
      int revision, {
      int size = 1,
      String? cursor,
    }) => CalendarTaskHistoryQuery(
      taskId: t.taskId,
      expectedRevision: revision,
      originalStart: original,
      pageSize: size,
      cursor: cursor,
    );

    List<String> importedTask(
      String uid, {
      List<String> properties = const [],
      List<String> timing = const ['DTSTART;VALUE=DATE:20260328'],
    }) => [
      'BEGIN:VTODO',
      'UID:$uid',
      'DTSTAMP:20260301T000000Z',
      ...timing,
      ...properties,
      'END:VTODO',
    ];
    String taskCalendar(List<String> components) => [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:Synthetic',
      ...components,
      'END:VCALENDAR',
      '',
    ].join('\r\n');
    CalendarTaskImportRequest taskImportRequest(
      UuidValue parent, {
      String? text,
      int revision = 1,
    }) => CalendarTaskImportRequest(
      calendarId: parent,
      expectedRevision: revision,
      bytes: ByteData.sublistView(
        Uint8List.fromList(
          utf8.encode(
            text ?? taskCalendar(importedTask('imported@example.invalid')),
          ),
        ),
      ),
    );

    Future<int> generation() async =>
        (await CalendarScopeRecord.db.findFirstRow(
          session,
          where: (t) => t.scopeKey.equals('test:alice'),
        ))!.revision;

    Future<CalendarEventReceipt> contentEvent() async {
      final parent = (await service.create(createInput()))!;
      return (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent.calendarId,
          content: eventInput(summary: 'Master').copyWith(
            description: 'Details',
            location: 'Room',
            recurrence: CalendarEventRecurrence(
              rule: daily(),
              inclusions: [],
              exclusions: [],
            ),
          ),
        ),
      ))!;
    }

    CalendarEventOccurrenceContentRequest eventContentChange(
      UuidValue id, {
      int revision = 1,
      CalendarEventContentField field = CalendarEventContentField.summary,
      CalendarEventContentAction action = CalendarEventContentAction.setValue,
      String? text = 'Own',
    }) => CalendarEventOccurrenceContentRequest(
      eventId: id,
      expectedRevision: revision,
      originalStart: day(30),
      changes: [
        CalendarEventOccurrenceContentChange(
          field: field,
          action: action,
          text: text,
        ),
      ],
    );

    test(
      'personal alarms hidden mutation receipts do not disclose private state',
      () async {
        final calendar = (await service.create(createInput()))!.calendarId;
        final event = await booking(calendar, 10, 11);
        final parent = CalendarAlarmParent(
          kind: CalendarAlarmParentKind.event,
          id: event.eventId,
        );
        policy.hideAlarmReceipt = true;
        expect(
          await service.createPersonalAlarm(
            CalendarAlarmCreateRequest(
              parent: parent,
              definition: CalendarAlarmDefinition(
                absoluteUtc: DateTime.utc(2026, 3, 29),
              ),
            ),
          ),
          isNull,
        );
        final row = (await service.listPersonalAlarms(parent)).single;
        expect(
          await service.updatePersonalAlarm(
            CalendarAlarmUpdateRequest(
              parent: parent,
              alarmId: row.id,
              expectedRevision: 1,
              definition: CalendarAlarmDefinition(
                absoluteUtc: DateTime.utc(2026, 3, 30),
              ),
            ),
          ),
          isNull,
        );
        expect((await service.listPersonalAlarms(parent)).single.revision, 2);
      },
    );

    test(
      'personal alarms revision exhaustion rejects even with a hidden receipt',
      () async {
        final calendar = (await service.create(createInput()))!.calendarId;
        final event = await booking(calendar, 10, 11);
        final parent = CalendarAlarmParent(
          kind: CalendarAlarmParentKind.event,
          id: event.eventId,
        );
        final created = (await service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: parent,
            definition: CalendarAlarmDefinition(
              absoluteUtc: DateTime.utc(2026, 3, 29),
            ),
          ),
        ))!;
        final row = (await CalendarAlarmRecord.db.findById(
          session,
          created.id,
        ))!;
        row.revision = 9007199254740991;
        await CalendarAlarmRecord.db.updateRow(session, row);
        policy.hideAlarmReceipt = true;
        await expectLater(
          service.updatePersonalAlarm(
            CalendarAlarmUpdateRequest(
              parent: parent,
              alarmId: created.id,
              expectedRevision: row.revision,
              definition: CalendarAlarmDefinition(
                absoluteUtc: DateTime.utc(2026, 3, 30),
              ),
            ),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(
          (await service.listPersonalAlarms(parent)).single.revision,
          row.revision,
        );
      },
    );

    CalendarAlarmParent eventAlarmParent(UuidValue id) =>
        CalendarAlarmParent(kind: CalendarAlarmParentKind.event, id: id);
    CalendarAlarmDefinition relativeAlarm({
      bool end = false,
      String? zone = 'Europe/Stockholm',
    }) => CalendarAlarmDefinition(
      relativeDuration: CalendarAlarmDuration(sign: -1, minutes: 5),
      anchor: end ? CalendarAlarmAnchor.end : CalendarAlarmAnchor.start,
      dateZoneId: zone,
    );
    CalendarAlarmDefinition absoluteAlarm() =>
        CalendarAlarmDefinition(absoluteUtc: DateTime.utc(2026, 3, 29, 12));

    Future<CalendarAlarmRecord> workAlarm() async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final event = await booking(calendar, 10, 11);
      final alarm = (await service.createPersonalAlarm(
        CalendarAlarmCreateRequest(
          parent: eventAlarmParent(event.eventId),
          definition: relativeAlarm(),
        ),
      ))!;
      return (await CalendarAlarmRecord.db.findById(session, alarm.id))!;
    }

    Future<CalendarAlarmPlanRecord> workPlan(CalendarAlarmRecord alarm) =>
        CalendarAlarmPlanRecord.db.insertRow(
          session,
          CalendarAlarmPlanRecord(
            alarmId: alarm.id!,
            scopeKey: alarm.scopeKey,
            generation: alarm.generation,
            nextScanAt: DateTime.utc(2020),
          ),
        );

    Future<CalendarAlarmFiringRecord> workFiring(
      CalendarAlarmRecord alarm,
      int ordinal,
      CalendarAlarmFiringState state, {
      DateTime? terminal,
      DateTime? lease,
    }) => CalendarAlarmFiringRecord.db.insertRow(
      session,
      CalendarAlarmFiringRecord(
        alarmId: alarm.id!,
        generation: alarm.generation,
        originalKey: 'original',
        kind: CalendarAlarmFiringKind.automatic,
        repeatOrdinal: ordinal,
        dueAt: DateTime.utc(2020),
        expiresAt: DateTime.utc(2020, 1, 1, 0, 15),
        state: state,
        nextAttemptAt: DateTime.utc(2020),
        terminalAt: terminal,
        leaseUntil: lease,
        createdAt: DateTime.utc(2020),
        updatedAt: DateTime.utc(2020),
      ),
    );

    late TestAlarmBackgroundPolicy alarmPolicy;
    late TestAlarmDeliveryPort alarmDelivery;
    void installAlarmRuntime({int cap = 1000}) {
      alarmPolicy = TestAlarmBackgroundPolicy();
      alarmDelivery = TestAlarmDeliveryPort();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        alarms: CalendarAlarmRuntime(
          policy: alarmPolicy,
          delivery: alarmDelivery,
          options: CalendarAlarmWorkOptions(maxFirings: cap),
        ),
      );
      service = CalendarModule.service(session);
    }

    Future<DateTime> alarmNow() async => DateTime.fromMillisecondsSinceEpoch(
      ((await session.db.unsafeQuery('SELECT clock_timestamp()')).single.single
                  as DateTime)
              .toUtc()
              .millisecondsSinceEpoch ~/
          1000 *
          1000,
      isUtc: true,
    );
    Future<CalendarAlarmView> armedDueAlarm({bool repeats = false}) async {
      final row = await workAlarm();
      final now = await alarmNow();
      await service.updatePersonalAlarm(
        CalendarAlarmUpdateRequest(
          parent: eventAlarmParent(row.parentId),
          alarmId: row.id!,
          expectedRevision: 1,
          definition: CalendarAlarmDefinition(
            absoluteUtc: now.subtract(const Duration(minutes: 1)),
            repeat: repeats ? 2 : null,
            repeatInterval: repeats ? CalendarAlarmDuration(seconds: 30) : null,
          ),
        ),
      );
      return (await service.setPersonalAlarmArmed(
        eventAlarmParent(row.parentId),
        row.id!,
        2,
        true,
      ))!;
    }

    CalendarAlarmActionRequest actionInput(
      CalendarAlarmView a,
      CalendarAlarmFiringRecord f,
      CalendarAlarmActionKind kind, {
      int revision = 0,
      DateTime? snooze,
    }) => CalendarAlarmActionRequest(
      parent: a.parent,
      alarmId: a.id,
      expectedAlarmRevision: a.revision,
      expectedActionRevision: revision,
      kind: kind,
      firingId: f.id,
      snoozeAt: snooze,
    );
    Future<CalendarAlarmFiringRecord> acceptedFiring(
      CalendarAlarmView a,
    ) async => (await CalendarAlarmFiringRecord.db.findFirstRow(
      session,
      where: (t) =>
          t.alarmId.equals(a.id) &
          t.state.equals(CalendarAlarmFiringState.accepted),
    ))!;

    test('alarm actions acknowledge, dismiss and reset preserve private revisions and pruning cutoff', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm();
      final publicGeneration = await generation();
      await CalendarModule.runAlarmMaintenance(session);
      final f = await acceptedFiring(a);
      final ack = (await service.actOnPersonalAlarm(
        actionInput(a, f, CalendarAlarmActionKind.acknowledge),
      ))!;
      expect(ack.acknowledgedAt, isNotNull);
      expect(
        await CalendarModule.validateAlarmDelivery(
          session,
          alarmDelivery.accepted.values.single,
        ),
        isFalse,
      );
      final dismissed = (await service.actOnPersonalAlarm(
        actionInput(
          a,
          f,
          CalendarAlarmActionKind.dismiss,
          revision: ack.revision,
        ),
      ))!;
      expect(dismissed.dismissedAt, isNotNull);
      await CalendarAlarmFiringRecord.db.deleteWhere(
        session,
        where: (t) => t.alarmId.equals(a.id),
      );
      final reset = (await service.actOnPersonalAlarm(
        CalendarAlarmActionRequest(
          parent: a.parent,
          alarmId: a.id,
          expectedAlarmRevision: a.revision,
          expectedActionRevision: dismissed.revision,
          kind: CalendarAlarmActionKind.reset,
          actionId: ack.id,
        ),
      ))!;
      expect(reset.resetAt, isNotNull);
      expect(reset.acknowledgedAt, isNull);
      expect(reset.dismissedAt, isNull);
      await CalendarModule.runAlarmMaintenance(session);
      expect(alarmDelivery.calls, 1);
      expect(
        (await service.listPersonalAlarms(a.parent)).single.revision,
        a.revision,
      );
      expect(await generation(), publicGeneration);
      final page = await service.personalAlarmActivity(
        a.parent,
        a.id,
        CalendarAlarmActivityKind.actions,
        10,
        null,
      );
      expect(page.actions.single.id, ack.id);
      expect(page.firings, isEmpty);
    });

    test('alarm actions stale, final denied, hidden and recipient checks are atomic', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final f = await acceptedFiring(a);
      final input = actionInput(a, f, CalendarAlarmActionKind.acknowledge);
      policy.denied.add(CalendarPermission.acknowledgePersonalAlarm);
      await expectLater(
        service.actOnPersonalAlarm(input),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.denyFinal = true;
      await expectLater(
        service.actOnPersonalAlarm(input),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      policy.alarmRecipientOverride = (phase) => CalendarAlarmRecipient(
        'demo',
        phase == CalendarAuthorizationPhase.finalWrite ? 'changed' : 'alice',
      );
      await expectLater(
        service.actOnPersonalAlarm(input),
        failure(CalendarFailureCode.unavailable),
      );
      policy.alarmRecipientOverride = null;
      expect(await CalendarAlarmActionRecord.db.count(session), 0);
      policy.hideAlarmReceipt = true;
      expect(await service.actOnPersonalAlarm(input), isNull);
      policy.hideAlarmReceipt = false;
      await expectLater(
        service.actOnPersonalAlarm(input),
        failure(CalendarFailureCode.staleRevision),
      );
      policy.alarmRecipientOverride = (_) =>
          const CalendarAlarmRecipient('demo', 'bob');
      await expectLater(
        service.actOnPersonalAlarm(input),
        failure(CalendarFailureCode.accessDenied),
      );
    });

    test('alarm actions snooze replaces pending work and reset cancels it without chains', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final f = await acceptedFiring(a);
      final due = (await alarmNow()).add(const Duration(minutes: 10));
      final first = (await service.actOnPersonalAlarm(
        actionInput(a, f, CalendarAlarmActionKind.snooze, snooze: due),
      ))!;
      await CalendarModule.runAlarmMaintenance(session);
      final sf = (await CalendarAlarmFiringRecord.db.findFirstRow(
        session,
        where: (t) => t.kind.equals(CalendarAlarmFiringKind.snooze),
      ))!;
      expect(sf.dueAt, due);
      expect(sf.state, CalendarAlarmFiringState.pending);
      await expectLater(
        service.actOnPersonalAlarm(
          actionInput(
            a,
            sf,
            CalendarAlarmActionKind.snooze,
            revision: first.revision,
            snooze: due.add(const Duration(minutes: 1)),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      final next = (await service.actOnPersonalAlarm(
        actionInput(
          a,
          f,
          CalendarAlarmActionKind.snooze,
          revision: first.revision,
          snooze: due.add(const Duration(minutes: 2)),
        ),
      ))!;
      await CalendarModule.runAlarmMaintenance(session);
      final pending = await CalendarAlarmFiringRecord.db.find(
        session,
        where: (t) =>
            t.kind.equals(CalendarAlarmFiringKind.snooze) &
            t.state.equals(CalendarAlarmFiringState.pending),
      );
      expect(pending.single.dueAt, next.pendingSnoozeAt);
      await service.actOnPersonalAlarm(
        CalendarAlarmActionRequest(
          parent: a.parent,
          alarmId: a.id,
          expectedAlarmRevision: a.revision,
          expectedActionRevision: next.revision,
          kind: CalendarAlarmActionKind.reset,
          actionId: next.id,
        ),
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(
        await CalendarAlarmFiringRecord.db.count(
          session,
          where: (t) =>
              t.kind.equals(CalendarAlarmFiringKind.snooze) &
              t.state.equals(CalendarAlarmFiringState.pending),
        ),
        0,
      );
      expect(alarmDelivery.calls, 1);
    });

    test('alarm actions reject fractional, past, beyond seven-day and exhausted budget snooze atomically', () async {
      installAlarmRuntime(cap: 1);
      final a = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final f = await acceptedFiring(a);
      final now = await alarmNow();
      for (final due in [
        now,
        now.add(const Duration(days: 7, seconds: 2)),
        now.add(const Duration(minutes: 1, microseconds: 1)),
      ]) {
        await expectLater(
          service.actOnPersonalAlarm(
            actionInput(a, f, CalendarAlarmActionKind.snooze, snooze: due),
          ),
          failure(CalendarFailureCode.validation),
        );
      }
      await expectLater(
        service.actOnPersonalAlarm(
          actionInput(
            a,
            f,
            CalendarAlarmActionKind.snooze,
            snooze: now.add(const Duration(minutes: 1)),
          ),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarAlarmActionRecord.db.count(session), 0);
      expect(
        (await CalendarAlarmPlanRecord.db.findFirstRow(session))!.dirty,
        isFalse,
      );
    });

    test('alarm actions history cursors bind kind, alarm, principal and policy and preserve independent read gates', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm(repeats: true);
      await CalendarModule.runAlarmMaintenance(session);
      final first = await service.personalAlarmActivity(
        a.parent,
        a.id,
        CalendarAlarmActivityKind.firings,
        1,
        null,
      );
      expect(first.firings, hasLength(1));
      expect(first.nextCursor, isNotNull);
      await expectLater(
        service.personalAlarmActivity(
          a.parent,
          a.id,
          CalendarAlarmActivityKind.actions,
          1,
          first.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      final next = await service.personalAlarmActivity(
        a.parent,
        a.id,
        CalendarAlarmActivityKind.firings,
        1,
        first.nextCursor,
      );
      expect(next.firings.single.id, isNot(first.firings.single.id));
      policy.denied.add(CalendarPermission.readPersonalAlarmActivity);
      await expectLater(
        service.personalAlarmActivity(
          a.parent,
          a.id,
          CalendarAlarmActivityKind.firings,
          1,
          first.nextCursor,
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      final saved = (await CalendarCursorRecord.db.findFirstRow(
        session,
        where: (t) => t.token.equals(first.nextCursor!),
      ))!;
      saved.principalId = 'bob';
      await CalendarCursorRecord.db.updateRow(session, saved);
      await expectLater(
        service.personalAlarmActivity(
          a.parent,
          a.id,
          CalendarAlarmActivityKind.firings,
          1,
          first.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
    });

    test('alarm actions due unaccepted snooze can be rescheduled through its automatic origin', () async {
      installAlarmRuntime();
      alarmDelivery.decline = true;
      final a = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final f = (await CalendarAlarmFiringRecord.db.findFirstRow(session))!;
      expect(f.state, CalendarAlarmFiringState.pending);
      final due = (await alarmNow()).add(const Duration(minutes: 5));
      final first = (await service.actOnPersonalAlarm(
        actionInput(a, f, CalendarAlarmActionKind.snooze, snooze: due),
      ))!;
      await CalendarModule.runAlarmMaintenance(session);
      final second = (await service.actOnPersonalAlarm(
        actionInput(
          a,
          f,
          CalendarAlarmActionKind.snooze,
          revision: first.revision,
          snooze: due.add(const Duration(minutes: 1)),
        ),
      ))!;
      expect(second.pendingSnoozeAt, due.add(const Duration(minutes: 1)));
    });

    test('alarm actions reset allows future repeats but never replays an accepted firing after generation changes', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final f = await acceptedFiring(a);
      final ack = (await service.actOnPersonalAlarm(
        actionInput(a, f, CalendarAlarmActionKind.acknowledge),
      ))!;
      final reset = (await service.actOnPersonalAlarm(
        CalendarAlarmActionRequest(
          parent: a.parent,
          alarmId: a.id,
          expectedAlarmRevision: a.revision,
          expectedActionRevision: ack.revision,
          kind: CalendarAlarmActionKind.reset,
          actionId: ack.id,
        ),
      ))!;
      await service.updatePersonalAlarm(
        CalendarAlarmUpdateRequest(
          parent: a.parent,
          alarmId: a.id,
          expectedRevision: a.revision,
          definition: CalendarAlarmDefinition(
            absoluteUtc: f.dueAt,
            repeat: 1,
            repeatInterval: CalendarAlarmDuration(hours: 1),
          ),
        ),
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(alarmDelivery.calls, 1);
      final future = await CalendarAlarmFiringRecord.db.find(
        session,
        where: (t) => t.state.equals(CalendarAlarmFiringState.pending),
      );
      expect(future.single.dueAt.isAfter(reset.resetAt!), isTrue);
    });

    test('alarm actions activity cursor cannot cross into calendar event task or history lists', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm(repeats: true);
      await CalendarModule.runAlarmMaintenance(session);
      final page = await service.personalAlarmActivity(
        a.parent,
        a.id,
        CalendarAlarmActivityKind.firings,
        1,
        null,
      );
      final record = (await CalendarAlarmRecord.db.findById(session, a.id))!;
      await expectLater(
        service.list(pageSize: 1, fieldGroups: [], cursor: page.nextCursor),
        failure(CalendarFailureCode.invalidCursor),
      );
      await expectLater(
        service.listEvents(
          record.calendarId,
          pageSize: 1,
          fieldGroups: [],
          cursor: page.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      await expectLater(
        service.listTasks(
          record.calendarId,
          pageSize: 1,
          fieldGroups: [],
          cursor: page.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
    });

    test('alarm actions final host context includes actual parent firing and proposed action', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final f = await acceptedFiring(a);
      await service.actOnPersonalAlarm(
        actionInput(a, f, CalendarAlarmActionKind.acknowledge),
      );
      final request = policy.lastAlarmAction!;
      expect(request.eventId, a.parent.id);
      expect(request.currentEvent, isNotNull);
      expect(request.currentAlarmFiring!.id, f.id);
      expect(request.alarmRecipient!.key, 'alice');
      expect(request.currentAlarmAction, isNull);
      expect(request.proposedAlarmAction!.acknowledgedAt, isNotNull);
      expect(request.alarmActionKind, CalendarAlarmActionKind.acknowledge);
    });

    test(
      'alarm actions time validation repeats after a slow final policy check',
      () async {
        installAlarmRuntime();
        final a = await armedDueAlarm();
        await CalendarModule.runAlarmMaintenance(session);
        final f = await acceptedFiring(a);
        policy.alarmActionFinalDelay = const Duration(seconds: 2);
        await expectLater(
          service.actOnPersonalAlarm(
            actionInput(
              a,
              f,
              CalendarAlarmActionKind.snooze,
              snooze: (await alarmNow()).add(const Duration(seconds: 2)),
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarAlarmActionRecord.db.count(session), 0);
      },
    );

    test('alarm actions snooze rejects future expired and stale generation references', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final f = await acceptedFiring(a);
      final now = await alarmNow();
      final original = f.copyWith();
      f.state = CalendarAlarmFiringState.pending;
      f.dueAt = now.add(const Duration(minutes: 1));
      await CalendarAlarmFiringRecord.db.updateRow(session, f);
      await expectLater(
        service.actOnPersonalAlarm(
          actionInput(
            a,
            f,
            CalendarAlarmActionKind.snooze,
            snooze: now.add(const Duration(minutes: 5)),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      f.dueAt = now.subtract(const Duration(minutes: 20));
      f.expiresAt = now;
      await CalendarAlarmFiringRecord.db.updateRow(session, f);
      await expectLater(
        service.actOnPersonalAlarm(
          actionInput(
            a,
            f,
            CalendarAlarmActionKind.snooze,
            snooze: now.add(const Duration(minutes: 5)),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      original.generation++;
      await CalendarAlarmFiringRecord.db.updateRow(session, original);
      await expectLater(
        service.actOnPersonalAlarm(
          actionInput(
            a,
            original,
            CalendarAlarmActionKind.snooze,
            snooze: now.add(const Duration(minutes: 5)),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarAlarmActionRecord.db.count(session), 0);
    });

    test('alarm actions accepted expired history still establishes snooze while active', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final f = await acceptedFiring(a);
      f.expiresAt = (await alarmNow()).subtract(const Duration(seconds: 1));
      await CalendarAlarmFiringRecord.db.updateRow(session, f);
      final result = await service.actOnPersonalAlarm(
        actionInput(
          a,
          f,
          CalendarAlarmActionKind.snooze,
          snooze: (await alarmNow()).add(const Duration(days: 7)),
        ),
      );
      expect(result!.pendingSnoozeAt, isNotNull);
    });

    test('alarm actions action counter exhaustion and parent spoofing fail without mutation', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final f = await acceptedFiring(a);
      final action = (await service.actOnPersonalAlarm(
        actionInput(a, f, CalendarAlarmActionKind.acknowledge),
      ))!;
      final row = (await CalendarAlarmActionRecord.db.findById(
        session,
        action.id,
      ))!;
      row.revision = 9007199254740991;
      await CalendarAlarmActionRecord.db.updateRow(session, row);
      policy.denied.add(CalendarPermission.dismissPersonalAlarm);
      await expectLater(
        service.actOnPersonalAlarm(
          actionInput(
            a,
            f,
            CalendarAlarmActionKind.dismiss,
            revision: row.revision,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      await expectLater(
        service.actOnPersonalAlarm(
          actionInput(
            a,
            f,
            CalendarAlarmActionKind.dismiss,
            revision: row.revision,
          ),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      final other = await workAlarm();
      await expectLater(
        service.actOnPersonalAlarm(
          CalendarAlarmActionRequest(
            parent: eventAlarmParent(other.parentId),
            alarmId: a.id,
            expectedAlarmRevision: a.revision,
            expectedActionRevision: row.revision,
            kind: CalendarAlarmActionKind.reset,
            actionId: row.id,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await CalendarAlarmActionRecord.db.findById(
          session,
          row.id!,
        ))!.dismissedAt,
        isNull,
      );
      row.revision = 1;
      row.snoozeRevision = 9007199254740991;
      await CalendarAlarmActionRecord.db.updateRow(session, row);
      final reset = await service.actOnPersonalAlarm(
        CalendarAlarmActionRequest(
          parent: a.parent,
          alarmId: a.id,
          expectedAlarmRevision: a.revision,
          expectedActionRevision: 1,
          kind: CalendarAlarmActionKind.reset,
          actionId: row.id,
        ),
      );
      expect(reset!.resetAt, isNotNull);
    });

    test('alarm actions snooze uses raw database time rather than a future audit timestamp', () async {
      installAlarmRuntime();
      final a = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final f = await acceptedFiring(a);
      final ack = (await service.actOnPersonalAlarm(
        actionInput(a, f, CalendarAlarmActionKind.acknowledge),
      ))!;
      await CalendarModule.runAlarmMaintenance(session);
      final row = (await CalendarAlarmActionRecord.db.findById(
        session,
        ack.id,
      ))!;
      final now = await alarmNow();
      row.updatedAt = now.add(const Duration(days: 1));
      await CalendarAlarmActionRecord.db.updateRow(session, row);
      await expectLater(
        service.actOnPersonalAlarm(
          actionInput(
            a,
            f,
            CalendarAlarmActionKind.snooze,
            revision: ack.revision,
            snooze: now.add(const Duration(days: 7, hours: 1)),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await CalendarAlarmActionRecord.db.findById(
          session,
          row.id!,
        ))!.pendingSnoozeAt,
        isNull,
      );
    });

    test(
      'alarm actions alarm and parent deletion scrub private continuation rows',
      () async {
        installAlarmRuntime();
        for (final deleteParent in [false, true]) {
          final a = await armedDueAlarm(repeats: true);
          await CalendarModule.runAlarmMaintenance(session);
          final page = await service.personalAlarmActivity(
            a.parent,
            a.id,
            CalendarAlarmActivityKind.firings,
            1,
            null,
          );
          expect(page.nextCursor, isNotNull);
          if (deleteParent) {
            await service.deleteEvent(a.parent.id, 1);
          } else {
            await service.deletePersonalAlarm(a.parent, a.id, a.revision);
          }
          expect(
            await CalendarCursorRecord.db.count(
              session,
              where: (t) => t.alarmActivityId.equals(a.id),
            ),
            0,
          );
        }
      },
    );

    test('alarm planner explicit arming requires configured runtime and separate authority', () async {
      final row = await workAlarm();
      expect(row.armed, isFalse);
      await expectLater(
        service.setPersonalAlarmArmed(
          eventAlarmParent(row.parentId),
          row.id!,
          1,
          true,
        ),
        failure(CalendarFailureCode.unavailable),
      );
      installAlarmRuntime();
      policy.denied.add(CalendarPermission.armPersonalAlarm);
      await expectLater(
        service.setPersonalAlarmArmed(
          eventAlarmParent(row.parentId),
          row.id!,
          1,
          true,
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarAlarmPlanRecord.db.count(session), 0);
      policy.denied.clear();
      final armed = (await service.setPersonalAlarmArmed(
        eventAlarmParent(row.parentId),
        row.id!,
        1,
        true,
      ))!;
      expect(armed.armed, isTrue);
      expect(armed.revision, 2);
      await expectLater(
        service.setPersonalAlarmArmed(
          eventAlarmParent(row.parentId),
          row.id!,
          1,
          false,
        ),
        failure(CalendarFailureCode.staleRevision),
      );
    });

    test('alarm planner complete window coalesces repeats and accepts one stable private intent', () async {
      installAlarmRuntime();
      final alarm = await armedDueAlarm(repeats: true);
      final scope = await generation();
      await CalendarModule.runAlarmMaintenance(session);
      final plan = (await CalendarAlarmPlanRecord.db.findFirstRow(session))!;
      expect(plan.status, CalendarAlarmPlanStatus.ready);
      expect(plan.dirty, isFalse);
      expect(
        plan.windowEnd!.difference(plan.windowStart!),
        const Duration(days: 30, minutes: 15),
      );
      final firings = await CalendarAlarmFiringRecord.db.find(
        session,
        orderBy: (t) => t.repeatOrdinal,
      );
      expect(firings.map((f) => f.state), [
        CalendarAlarmFiringState.suppressed,
        CalendarAlarmFiringState.suppressed,
        CalendarAlarmFiringState.accepted,
      ]);
      expect(alarmDelivery.accepted, hasLength(1));
      final intent = alarmDelivery.accepted.values.single;
      expect(intent.alarmId, alarm.id);
      expect(
        await CalendarModule.validateAlarmDelivery(session, intent),
        isTrue,
      );
      expect(await generation(), scope);
      expect(
        (await service.listPersonalAlarms(alarm.parent)).single.revision,
        alarm.revision,
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(alarmDelivery.calls, 1);
      alarmPolicy.verdict = CalendarAuthorizationVerdict.deny;
      expect(
        await CalendarModule.validateAlarmDelivery(session, intent),
        isFalse,
      );
    });

    test('alarm notification projection requires separate authority and uses current text', () async {
      installAlarmRuntime();
      final alarm = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final intent = alarmDelivery.accepted.values.single;
      final data = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(alarm.parent.id),
      ))!;
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: alarm.parent.id,
          expectedRevision: 1,
          content: data.content.copyWith(summary: 'Fresh authorized title'),
        ),
      );
      await CalendarModule.runAlarmMaintenance(session);
      final view = await CalendarModule.projectAlarmNotification(
        session,
        intent,
      );
      expect(view!.summary, 'Fresh authorized title');
      expect(view.snoozeAllowed, isTrue);
      alarmPolicy.deniedOperations.add(
        CalendarAlarmBackgroundOperation.project,
      );
      expect(
        await CalendarModule.checkAlarmDelivery(session, intent),
        CalendarAlarmDeliveryCheck.eligible,
      );
      expect(
        await CalendarModule.projectAlarmNotification(session, intent),
        isNull,
      );
      expect(
        await CalendarModule.checkAlarmDelivery(
          session,
          intent,
          forProjection: true,
        ),
        CalendarAlarmDeliveryCheck.withdrawn,
      );
    });

    test(
      'alarm notification distinguishes a dirty plan from withdrawn source',
      () async {
        installAlarmRuntime();
        final alarm = await armedDueAlarm();
        await CalendarModule.runAlarmMaintenance(session);
        final intent = alarmDelivery.accepted.values.single;
        final plan = (await CalendarAlarmPlanRecord.db.findFirstRow(session))!;
        plan.dirty = true;
        await CalendarAlarmPlanRecord.db.updateRow(session, plan);
        expect(
          await CalendarModule.checkAlarmDelivery(session, intent),
          CalendarAlarmDeliveryCheck.unavailable,
        );
        plan.dirty = false;
        await CalendarAlarmPlanRecord.db.updateRow(session, plan);
        final firing = (await CalendarAlarmFiringRecord.db.findById(
          session,
          intent.firingId,
        ))!;
        await service.actOnPersonalAlarm(
          actionInput(alarm, firing, CalendarAlarmActionKind.acknowledge),
        );
        expect(
          await CalendarModule.checkAlarmDelivery(session, intent),
          CalendarAlarmDeliveryCheck.withdrawn,
        );
        expect(
          await CalendarModule.projectAlarmNotification(session, intent),
          isNull,
        );
      },
    );

    test('alarm planner identical private writes and parent text edits never replay accepted firings', () async {
      installAlarmRuntime();
      final alarm = await armedDueAlarm();
      await CalendarModule.runAlarmMaintenance(session);
      final original = (await CalendarAlarmRecord.db.findById(
        session,
        alarm.id,
      ))!;
      final saved = (await service.updatePersonalAlarm(
        CalendarAlarmUpdateRequest(
          parent: alarm.parent,
          alarmId: alarm.id,
          expectedRevision: alarm.revision,
          definition: alarm.definition,
        ),
      ))!;
      await service.setPersonalAlarmArmed(
        alarm.parent,
        alarm.id,
        saved.revision,
        true,
      );
      final data = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(alarm.parent.id),
      ))!;
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: alarm.parent.id,
          expectedRevision: 1,
          content: data.content.copyWith(summary: 'Changed text only'),
        ),
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(
        (await CalendarAlarmRecord.db.findById(session, alarm.id))!.generation,
        original.generation,
      );
      expect(await CalendarAlarmFiringRecord.db.count(session), 1);
      expect(alarmDelivery.calls, 1);
      expect(
        (await service.listPersonalAlarms(alarm.parent)).single.planningStatus,
        CalendarAlarmPlanStatus.ready,
      );
    });

    test('alarm planner host can permit planning while denying dispatch independently', () async {
      installAlarmRuntime();
      await armedDueAlarm();
      alarmPolicy.deniedOperations.add(
        CalendarAlarmBackgroundOperation.dispatch,
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(
        (await CalendarAlarmPlanRecord.db.findFirstRow(session))!.status,
        CalendarAlarmPlanStatus.ready,
      );
      expect(alarmDelivery.calls, 0);
      expect(
        (await CalendarAlarmFiringRecord.db.findFirstRow(session))!.state,
        CalendarAlarmFiringState.pending,
      );
      expect(
        alarmPolicy.lastOperation,
        CalendarAlarmBackgroundOperation.dispatch,
      );
    });

    test(
      'alarm planner density failure exposes no partial work or handoff',
      () async {
        installAlarmRuntime(cap: 1);
        await armedDueAlarm(repeats: true);
        await CalendarModule.runAlarmMaintenance(session);
        final plan = (await CalendarAlarmPlanRecord.db.findFirstRow(session))!;
        expect(plan.status, CalendarAlarmPlanStatus.needsAttention);
        expect(plan.windowStart, isNull);
        expect(plan.windowEnd, isNull);
        expect(await CalendarAlarmFiringRecord.db.count(session), 0);
        expect(alarmDelivery.calls, 0);
      },
    );

    test('alarm planner final background denial is atomic and actions survive replanning', () async {
      installAlarmRuntime();
      final alarm = await armedDueAlarm();
      alarmPolicy.finalVerdict = CalendarAuthorizationVerdict.deny;
      await CalendarModule.runAlarmMaintenance(session);
      expect(
        (await CalendarAlarmPlanRecord.db.findFirstRow(session))!.status,
        CalendarAlarmPlanStatus.unavailable,
      );
      expect(await CalendarAlarmFiringRecord.db.count(session), 0);
      expect(alarmDelivery.calls, 0);
      alarmPolicy.finalVerdict = null;
      await CalendarAlarmActionRecord.db.insertRow(
        session,
        CalendarAlarmActionRecord(
          alarmId: alarm.id,
          originalKey: 'item',
          revision: 1,
          acknowledgedAt: await alarmNow(),
          createdAt: await alarmNow(),
          updatedAt: await alarmNow(),
        ),
      );
      await service.updatePersonalAlarm(
        CalendarAlarmUpdateRequest(
          parent: alarm.parent,
          alarmId: alarm.id,
          expectedRevision: alarm.revision,
          definition: alarm.definition.copyWith(
            absoluteUtc: alarm.definition.absoluteUtc!.subtract(
              const Duration(seconds: 1),
            ),
          ),
        ),
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(
        (await CalendarAlarmPlanRecord.db.findFirstRow(session))!.status,
        CalendarAlarmPlanStatus.ready,
      );
      expect(
        (await CalendarAlarmFiringRecord.db.findFirstRow(session))!.state,
        CalendarAlarmFiringState.suppressed,
      );
      expect(alarmDelivery.calls, 0);
    });

    test('alarm planner preserves independent task source progress while suppressing every completion signal', () async {
      installAlarmRuntime();
      final calendar = (await service.create(createInput()))!.calendarId;
      final now = await alarmNow();
      for (final progress in [
        CalendarTaskProgress(status: CalendarTaskStatus.completed),
        CalendarTaskProgress(status: CalendarTaskStatus.cancelled),
        CalendarTaskProgress(
          status: CalendarTaskStatus.needsAction,
          percentComplete: 100,
        ),
        CalendarTaskProgress(completedAt: now),
      ]) {
        final task = (await service.createTask(
          CalendarTaskCreateRequest(
            calendarId: calendar,
            content: CalendarTaskContent(
              timing: CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
            ),
            assignees: [],
          ),
        ))!;
        final data = (await CalendarTaskDataRecord.db.findFirstRow(
          session,
          where: (t) => t.taskId.equals(task.taskId),
        ))!;
        data.progress = progress;
        await CalendarTaskDataRecord.db.updateRow(session, data);
        final parent = CalendarAlarmParent(
          kind: CalendarAlarmParentKind.task,
          id: task.taskId,
        );
        final alarm = (await service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: parent,
            definition: CalendarAlarmDefinition(
              absoluteUtc: now.subtract(const Duration(minutes: 1)),
            ),
          ),
        ))!;
        await service.setPersonalAlarmArmed(parent, alarm.id, 1, true);
        expect(
          (await CalendarTaskDataRecord.db.findFirstRow(
            session,
            where: (t) => t.taskId.equals(task.taskId),
          ))!.progress,
          progress,
        );
      }
      await CalendarModule.runAlarmMaintenance(session);
      final firings = await CalendarAlarmFiringRecord.db.find(session);
      expect(firings, hasLength(4));
      expect(
        firings.every((f) => f.state == CalendarAlarmFiringState.suppressed),
        isTrue,
      );
      expect(alarmDelivery.calls, 0);
    });

    test('alarm planner crash after durable acceptance retries the same logical id', () async {
      installAlarmRuntime();
      final alarm = await armedDueAlarm();
      alarmDelivery.throwAfterAcceptance = true;
      await CalendarModule.runAlarmMaintenance(session);
      final first = (await CalendarAlarmFiringRecord.db.findFirstRow(session))!;
      expect(first.state, CalendarAlarmFiringState.pending);
      expect(first.attemptCount, 1);
      expect(alarmDelivery.accepted, hasLength(1));
      first.nextAttemptAt = DateTime.utc(2020);
      await CalendarAlarmFiringRecord.db.updateRow(session, first);
      await CalendarModule.runAlarmMaintenance(session);
      expect(alarmDelivery.calls, 2);
      expect(alarmDelivery.accepted, hasLength(1));
      expect(
        (await CalendarAlarmFiringRecord.db.findById(
          session,
          first.id!,
        ))!.state,
        CalendarAlarmFiringState.accepted,
      );
      final intent = alarmDelivery.accepted.values.single;
      await service.setPersonalAlarmArmed(
        alarm.parent,
        alarm.id,
        alarm.revision,
        false,
      );
      expect(
        await CalendarModule.validateAlarmDelivery(session, intent),
        isFalse,
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(alarmDelivery.calls, 2);
    });

    test(
      'alarm work leases reject expired owners and stale generations',
      () async {
        final alarm = await workAlarm(), plan = await workPlan(alarm);
        final store = AlarmWorkStore(session, CalendarAlarmWorkOptions());
        final first = (await store.claimPlans()).single;
        expect(await store.claimPlans(), isEmpty);
        await session.db.transaction((tx) async {
          expect(await store.ownedPlan(first, tx), isNotNull);
        });
        final expired = (await CalendarAlarmPlanRecord.db.findById(
          session,
          plan.id!,
        ))!;
        expired.leaseUntil = DateTime.utc(2020);
        await CalendarAlarmPlanRecord.db.updateRow(session, expired);
        final second = (await store.claimPlans()).single;
        expect(second.fence, first.fence + 1);
        expect(second.owner, isNot(first.owner));
        await session.db.transaction((tx) async {
          expect(await store.ownedPlan(first, tx), isNull);
          expect(await store.ownedPlan(second, tx), isNotNull);
        });
        await service.updatePersonalAlarm(
          CalendarAlarmUpdateRequest(
            parent: eventAlarmParent(alarm.parentId),
            alarmId: alarm.id!,
            expectedRevision: alarm.revision,
            definition: absoluteAlarm(),
          ),
        );
        await session.db.transaction((tx) async {
          expect(await store.ownedPlan(second, tx), isNull);
        });
        final changed = (await CalendarAlarmPlanRecord.db.findById(
          session,
          plan.id!,
        ))!;
        expect(changed.dirty, isTrue);
        expect(changed.generation, 2);
        expect(changed.leaseOwner, isNull);
      },
    );

    test('alarm work pruning is bounded terminal-only and never deletes action state', () async {
      final alarm = await workAlarm();
      final action = await CalendarAlarmActionRecord.db.insertRow(
        session,
        CalendarAlarmActionRecord(
          alarmId: alarm.id!,
          originalKey: 'original',
          revision: 1,
          acknowledgedAt: DateTime.utc(2020),
          dismissedAt: DateTime.utc(2020),
          createdAt: DateTime.utc(2020),
          updatedAt: DateTime.utc(2020),
        ),
      );
      await workFiring(
        alarm,
        0,
        CalendarAlarmFiringState.accepted,
        terminal: DateTime.utc(2020),
      );
      await workFiring(
        alarm,
        1,
        CalendarAlarmFiringState.suppressed,
        terminal: DateTime.utc(2020),
      );
      await workFiring(
        alarm,
        2,
        CalendarAlarmFiringState.pending,
        terminal: DateTime.utc(2020),
      );
      await workFiring(alarm, 3, CalendarAlarmFiringState.expired);
      await workFiring(
        alarm,
        4,
        CalendarAlarmFiringState.accepted,
        terminal: DateTime.utc(2020),
        lease: DateTime.utc(2099),
      );
      final store = AlarmWorkStore(
        session,
        CalendarAlarmWorkOptions(maxClaims: 1),
      );
      expect(await store.pruneTerminalHistory(), 1);
      expect(await store.pruneTerminalHistory(), 1);
      expect(await store.pruneTerminalHistory(), 0);
      expect(await CalendarAlarmFiringRecord.db.count(session), 3);
      expect(
        (await CalendarAlarmActionRecord.db.findById(
          session,
          action.id!,
        ))!.toJson(),
        action.toJson(),
      );
      await service.deletePersonalAlarm(
        eventAlarmParent(alarm.parentId),
        alarm.id!,
        1,
      );
      expect(await CalendarAlarmPlanRecord.db.count(session), 0);
      expect(await CalendarAlarmFiringRecord.db.count(session), 0);
      expect(await CalendarAlarmActionRecord.db.count(session), 0);
    });

    test(
      'alarm work shared writes dirty leases without changing private versions',
      () async {
        final alarm = await workAlarm(), plan = await workPlan(alarm);
        final store = AlarmWorkStore(session, CalendarAlarmWorkOptions());
        final lease = (await store.claimPlans()).single;
        final before = alarm.toJson();
        await service.create(createInput('Unrelated shared calendar write'));
        final changed = (await CalendarAlarmPlanRecord.db.findById(
          session,
          plan.id!,
        ))!;
        expect(changed.dirty, isTrue);
        expect(changed.leaseOwner, isNull);
        expect(changed.leaseFence, greaterThan(lease.fence));
        expect(
          (await CalendarAlarmRecord.db.findById(session, alarm.id!))!.toJson(),
          before,
        );
        await session.db.transaction((tx) async {
          expect(await store.ownedPlan(lease, tx), isNull);
        });
      },
    );

    test('alarm work setting changes suppress retries but preserve acknowledgements', () async {
      final alarm = await workAlarm();
      await workPlan(alarm);
      final firing = await workFiring(
        alarm,
        0,
        CalendarAlarmFiringState.pending,
      );
      final action = await CalendarAlarmActionRecord.db.insertRow(
        session,
        CalendarAlarmActionRecord(
          alarmId: alarm.id!,
          originalKey: 'original',
          revision: 1,
          acknowledgedAt: DateTime.utc(2020),
          createdAt: DateTime.utc(2020),
          updatedAt: DateTime.utc(2020),
        ),
      );
      await service.updatePersonalAlarm(
        CalendarAlarmUpdateRequest(
          parent: eventAlarmParent(alarm.parentId),
          alarmId: alarm.id!,
          expectedRevision: 1,
          definition: absoluteAlarm(),
        ),
      );
      final changed = (await CalendarAlarmFiringRecord.db.findById(
        session,
        firing.id!,
      ))!;
      expect(changed.state, CalendarAlarmFiringState.suppressed);
      expect(changed.terminalAt, isNotNull);
      expect(
        (await CalendarAlarmActionRecord.db.findById(
          session,
          action.id!,
        ))!.toJson(),
        action.toJson(),
      );
      await service.deleteEvent(alarm.parentId, 1);
      expect(await CalendarAlarmRecord.db.count(session), 0);
      expect(await CalendarAlarmPlanRecord.db.count(session), 0);
      expect(await CalendarAlarmFiringRecord.db.count(session), 0);
      expect(await CalendarAlarmActionRecord.db.count(session), 0);
    });

    test('personal alarms CRUD leaves item protocol, source and scope generation unchanged', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final event = await booking(calendar, 10, 11);
      final parent = eventAlarmParent(event.eventId);
      final before = (await service.getEvent(
        event.eventId,
        eventGroups,
      )).toJson();
      final scope = (await CalendarScopeRecord.db.findFirstRow(session))!
          .revision;
      final created = (await service.createPersonalAlarm(
        CalendarAlarmCreateRequest(parent: parent, definition: relativeAlarm()),
      ))!;
      expect(created.revision, 1);
      expect(created.anchorCompatible, isTrue);
      expect(policy.lastEventRequest!.alarmRecipient!.key, 'alice');
      expect(policy.lastEventRequest!.currentEvent!.eventId, event.eventId);
      expect((await service.listPersonalAlarms(parent)).single.id, created.id);
      final updated = (await service.updatePersonalAlarm(
        CalendarAlarmUpdateRequest(
          parent: parent,
          alarmId: created.id,
          expectedRevision: 1,
          definition: absoluteAlarm(),
        ),
      ))!;
      expect(updated.revision, 2);
      expect(updated.updatedAt.isBefore(updated.createdAt), isFalse);
      expect(
        (await service.getEvent(event.eventId, eventGroups)).toJson(),
        before,
      );
      expect(
        (await CalendarScopeRecord.db.findFirstRow(session))!.revision,
        scope,
      );
      await service.deletePersonalAlarm(parent, created.id, 2);
      expect(await service.listPersonalAlarms(parent), isEmpty);
      expect(await CalendarAlarmRecord.db.count(session), 0);
    });

    test(
      'personal alarms isolate recipients even in one shared host scope',
      () async {
        policy.scopeOverride = 'shared-personal-alarms';
        final calendar = (await service.create(createInput()))!.calendarId;
        final event = await booking(calendar, 10, 11);
        final parent = eventAlarmParent(event.eventId);
        final created = (await service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: parent,
            definition: absoluteAlarm(),
          ),
        ))!;
        final bobSession = builder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'bob',
                {},
              ),
            )
            .build();
        final bob = CalendarModule.service(bobSession);
        expect(await bob.listPersonalAlarms(parent), isEmpty);
        await expectLater(
          bob.updatePersonalAlarm(
            CalendarAlarmUpdateRequest(
              parent: parent,
              alarmId: created.id,
              expectedRevision: 1,
              definition: absoluteAlarm(),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          bob.deletePersonalAlarm(parent, created.id, 1),
          failure(CalendarFailureCode.accessDenied),
        );
        await bob.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: parent,
            definition: absoluteAlarm(),
          ),
        );
        expect(
          (await service.listPersonalAlarms(parent)).single.id,
          created.id,
        );
        policy.scopeOverride = 'foreign';
        await expectLater(
          service.listPersonalAlarms(parent),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );

    test('personal alarms stale, final-denied and changed recipient writes are atomic', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final event = await booking(calendar, 10, 11);
      final parent = eventAlarmParent(event.eventId);
      final created = (await service.createPersonalAlarm(
        CalendarAlarmCreateRequest(parent: parent, definition: absoluteAlarm()),
      ))!;
      policy.denyFinal = true;
      await expectLater(
        service.updatePersonalAlarm(
          CalendarAlarmUpdateRequest(
            parent: parent,
            alarmId: created.id,
            expectedRevision: 1,
            definition: relativeAlarm(),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.deletePersonalAlarm(parent, created.id, 1),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      await expectLater(
        service.updatePersonalAlarm(
          CalendarAlarmUpdateRequest(
            parent: parent,
            alarmId: created.id,
            expectedRevision: 0,
            definition: relativeAlarm(),
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.deletePersonalAlarm(parent, created.id, 0),
        failure(CalendarFailureCode.staleRevision),
      );
      policy.alarmRecipientOverride = (phase) => CalendarAlarmRecipient(
        'demo',
        phase == CalendarAuthorizationPhase.finalWrite ? 'changed' : 'alice',
      );
      await expectLater(
        service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: parent,
            definition: absoluteAlarm(),
          ),
        ),
        failure(CalendarFailureCode.unavailable),
      );
      policy.alarmRecipientOverride = null;
      expect((await service.listPersonalAlarms(parent)).single.revision, 1);
      policy.denied.add(CalendarPermission.readPersonalAlarms);
      await expectLater(
        service.listPersonalAlarms(parent),
        failure(CalendarFailureCode.accessDenied),
      );
    });

    test('personal alarms require valid initial anchors but cannot block later shared edits', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final event = await booking(calendar, 10, 11);
      final parent = eventAlarmParent(event.eventId);
      final alarm = (await service.createPersonalAlarm(
        CalendarAlarmCreateRequest(
          parent: parent,
          definition: relativeAlarm(end: true, zone: null),
        ),
      ))!;
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: event.eventId,
          expectedRevision: 1,
          content: eventInput().copyWith(
            timing: CalendarEventTiming(
              kind: CalendarEventTimeKind.utc,
              start: CalendarEventCivil(
                year: 2026,
                month: 3,
                day: 29,
                hour: 10,
              ),
            ),
          ),
        ),
      );
      expect(
        (await service.listPersonalAlarms(parent)).single.anchorCompatible,
        isFalse,
      );
      expect(
        (await service.listPersonalAlarms(parent)).single.revision,
        alarm.revision,
      );
      await expectLater(
        service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: parent,
            definition: relativeAlarm(end: true),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await service.updatePersonalAlarm(
        CalendarAlarmUpdateRequest(
          parent: parent,
          alarmId: alarm.id,
          expectedRevision: 1,
          definition: absoluteAlarm(),
        ),
      );
      final dateEvent = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: calendar, content: eventInput()),
      ))!.eventId;
      await expectLater(
        service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: eventAlarmParent(dateEvent),
            definition: relativeAlarm(zone: null),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: eventAlarmParent(dateEvent),
            definition: relativeAlarm(),
          ),
        ))!.anchorCompatible,
        isTrue,
      );
    });

    test('personal alarms absolute triggers support undated tasks and parent deletion scrubs every recipient', () async {
      policy.scopeOverride = 'shared-delete-alarms';
      final calendar = (await service.create(createInput()))!.calendarId;
      final task = await taskCreate(calendar);
      final parent = CalendarAlarmParent(
        kind: CalendarAlarmParentKind.task,
        id: task.taskId,
      );
      await expectLater(
        service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: parent,
            definition: relativeAlarm(),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await service.createPersonalAlarm(
        CalendarAlarmCreateRequest(parent: parent, definition: absoluteAlarm()),
      );
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      await CalendarModule.service(bobSession).createPersonalAlarm(
        CalendarAlarmCreateRequest(parent: parent, definition: absoluteAlarm()),
      );
      policy.denied.add(CalendarPermission.deletePersonalAlarm);
      policy.denyFinal = true;
      await expectLater(
        service.deleteTask(task.taskId, 1),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarAlarmRecord.db.count(session), 2);
      policy.denyFinal = false;
      await service.deleteTask(task.taskId, 1);
      expect(await CalendarAlarmRecord.db.count(session), 0);
      final event = await booking(calendar, 10, 11);
      await service.createPersonalAlarm(
        CalendarAlarmCreateRequest(
          parent: eventAlarmParent(event.eventId),
          definition: absoluteAlarm(),
        ),
      );
      await service.deleteEvent(event.eventId, 1);
      expect(await CalendarAlarmRecord.db.count(session), 0);
    });

    test(
      'personal alarms enforce the private cap and reject parent spoofing',
      () async {
        final calendar = (await service.create(createInput()))!.calendarId;
        final event = await booking(calendar, 10, 11);
        final parent = eventAlarmParent(event.eventId);
        for (var i = 0; i < 15; i++) {
          await service.createPersonalAlarm(
            CalendarAlarmCreateRequest(
              parent: parent,
              definition: absoluteAlarm(),
            ),
          );
        }
        await service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: parent,
            definition: absoluteAlarm(),
          ),
        );
        await expectLater(
          service.createPersonalAlarm(
            CalendarAlarmCreateRequest(
              parent: parent,
              definition: absoluteAlarm(),
            ),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        final rows = await service.listPersonalAlarms(parent);
        expect(rows, hasLength(16));
        final other = await booking(calendar, 12, 13);
        await expectLater(
          service.updatePersonalAlarm(
            CalendarAlarmUpdateRequest(
              parent: eventAlarmParent(other.eventId),
              alarmId: rows.first.id,
              expectedRevision: 1,
              definition: absoluteAlarm(),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );

    test('event content preserves timing and occupancy while content follows selected groups', () async {
      final e = await contentEvent();
      final baseline = await service.previewOccurrences(preview(e.eventId));
      await service.changeOccurrenceContent(eventContentChange(e.eventId));
      final hidden = await service.previewOccurrences(
        preview(e.eventId, revision: 2),
      );
      expect(
        hidden.occurrences.map((o) => o.toJson()).toList(),
        baseline.occurrences.map((o) => o.toJson()).toList(),
      );
      final visible = await service.previewOccurrences(
        preview(e.eventId, revision: 2).copyWith(
          fieldGroups: [
            CalendarEventFieldGroup.summary,
            CalendarEventFieldGroup.description,
          ],
        ),
      );
      expect(visible.occurrences[1].content!.summary, 'Own');
      expect(visible.occurrences[1].content!.description, 'Details');
      expect(visible.occurrences[1].content!.location, isNull);
      expect(visible.occurrences[2].content!.summary, 'Master');
      final view = await service.getEvent(e.eventId, eventGroups);
      expect(view.timingOverrides!.singles.single.replacement, isNull);
      expect(view.protocolVersion!.sequence, 0);
      expect(view.occurrenceProtocolVersions!.single.version.sequence, 0);
      final timing = await service.getEvent(e.eventId, [
        CalendarEventFieldGroup.timing,
        CalendarEventFieldGroup.protocolIdentity,
      ]);
      expect(timing.timingOverrides, isNull);
      expect(timing.occurrenceProtocolVersions, isEmpty);
      await expectLater(
        service.exportEvents(
          CalendarEventExportRequest(
            calendarId: e.calendarId,
            expectedRevision: 1,
            selection: [
              CalendarEventExportSelection(
                eventId: e.eventId,
                expectedRevision: 2,
              ),
            ],
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
    });
    test(
      'event content clear inherit and master edits preserve own fields',
      () async {
        final e = await contentEvent();
        await service.changeOccurrenceContent(eventContentChange(e.eventId));
        final current = await service.getEvent(e.eventId, eventGroups);
        final raw = (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(e.eventId),
        ))!;
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: e.eventId,
            expectedRevision: 2,
            content: raw.content.copyWith(
              summary: 'Changed',
              description: 'New details',
            ),
          ),
        );
        final v = await service.previewOccurrences(
          preview(e.eventId, revision: 3).copyWith(
            fieldGroups: [
              CalendarEventFieldGroup.summary,
              CalendarEventFieldGroup.description,
            ],
          ),
        );
        expect(v.occurrences[1].content!.summary, 'Own');
        expect(v.occurrences[1].content!.description, 'New details');
        expect(
          (await service.getEvent(
            e.eventId,
            eventGroups,
          )).occurrenceProtocolVersions!.single.version,
          current.occurrenceProtocolVersions!.single.version,
        );
        await service.changeOccurrenceContent(
          eventContentChange(
            e.eventId,
            revision: 3,
            action: CalendarEventContentAction.clearValue,
            text: null,
          ),
        );
        expect(
          (await service.getEvent(
            e.eventId,
            eventGroups,
          )).timingOverrides!.singles.single.contentOverrides!.summary,
          '',
        );
        await service.changeOccurrenceContent(
          eventContentChange(
            e.eventId,
            revision: 4,
            action: CalendarEventContentAction.inheritSeries,
            text: null,
          ),
        );
        expect(
          (await service.getEvent(e.eventId, eventGroups)).timingOverrides,
          isNull,
        );
      },
    );
    test(
      'event content needs update authority independently of lifecycle',
      () async {
        final e = await contentEvent();
        policy.denied.add(CalendarPermission.updateEvent);
        await expectLater(
          service.changeOccurrenceContent(eventContentChange(e.eventId)),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        policy.denied.add(CalendarPermission.changeEventStatus);
        await service.changeOccurrenceContent(eventContentChange(e.eventId));
        expect((await service.getEvent(e.eventId, eventGroups)).revision, 2);
      },
    );
    for (final group in [
      CalendarEventFieldGroup.summary,
      CalendarEventFieldGroup.description,
      CalendarEventFieldGroup.location,
    ]) {
      test(
        'event content preview requires requested ${group.name} disclosure',
        () async {
          final e = await contentEvent();
          await service.changeOccurrenceContent(
            eventContentChange(
              e.eventId,
              field: CalendarEventContentField.values.byName(group.name),
            ),
          );
          policy.eventGrants.remove(group);
          await expectLater(
            service.previewOccurrences(
              preview(e.eventId, revision: 2).copyWith(fieldGroups: [group]),
            ),
            failure(CalendarFailureCode.accessDenied),
          );
          final view = await service.getEvent(e.eventId, eventGroups);
          expect(view.timingOverrides, isNull);
          expect(view.occurrenceProtocolVersions, isEmpty);
          expect(
            (await service.previewOccurrences(preview(e.eventId, revision: 2)))
                .occurrences
                .every((v) => v.content == null && v.contentOverrides == null),
            isTrue,
          );
        },
      );
    }
    test(
      'event content freezes request and preview lists before callbacks',
      () async {
        final e = await contentEvent();
        final changes = [...eventContentChange(e.eventId).changes];
        final future = service.changeOccurrenceContent(
          eventContentChange(e.eventId).copyWith(changes: changes),
        );
        changes.clear();
        await future;
        final fields = [CalendarEventFieldGroup.summary];
        final pending = service.previewOccurrences(
          preview(e.eventId, revision: 2).copyWith(fieldGroups: fields),
        );
        fields.add(CalendarEventFieldGroup.location);
        final result = await pending;
        expect(
          result.disclosedGroups,
          contains(CalendarEventFieldGroup.summary),
        );
        expect(
          result.disclosedGroups,
          isNot(contains(CalendarEventFieldGroup.location)),
        );
        expect(result.occurrences[1].content!.summary, 'Own');
      },
    );
    test(
      'event content final actual context stale denial and rollback',
      () async {
        final e = await contentEvent();
        final gen = await generation();
        policy.onFinal = () {
          final request = policy.lastEventRequest!;
          expect(request.calendarId, e.calendarId);
          expect(request.currentEvent!.eventId, e.eventId);
          expect(request.eventOccurrenceContentChange!.originalStart, day(30));
          expect(
            request
                .proposedTimingOverrides!
                .singles
                .single
                .contentOverrides!
                .summary,
            'Own',
          );
          expect(
            () => request.eventOccurrenceContentChange!.changes.clear(),
            throwsUnsupportedError,
          );
        };
        policy.denyFinal = true;
        await expectLater(
          service.changeOccurrenceContent(eventContentChange(e.eventId)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await generation(), gen);
        expect(
          (await service.getEvent(e.eventId, eventGroups)).timingOverrides,
          isNull,
        );
        policy.denyFinal = false;
        await service.changeOccurrenceContent(eventContentChange(e.eventId));
        policy.onFinal = null;
        await expectLater(
          service.changeOccurrenceContent(eventContentChange(e.eventId)),
          failure(CalendarFailureCode.staleRevision),
        );
      },
    );
    test('event content rejects orphaning master edits without dropping stored content', () async {
      final e = await contentEvent();
      await service.changeOccurrenceContent(eventContentChange(e.eventId));
      final raw = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(e.eventId),
      ))!;
      await expectLater(
        service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: e.eventId,
            expectedRevision: 2,
            content: raw.content.copyWith(
              recurrence: raw.content.recurrence!.copyWith(
                exclusions: [day(30)],
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await service.getEvent(
          e.eventId,
          eventGroups,
        )).timingOverrides!.singles.single.contentOverrides!.summary,
        'Own',
      );
    });

    test('event content identical native save keeps protocol version while API revision advances', () async {
      final e = await contentEvent();
      await service.changeOccurrenceContent(eventContentChange(e.eventId));
      final before = await service.getEvent(e.eventId, eventGroups),
          gen = await generation();
      await service.changeOccurrenceContent(
        eventContentChange(e.eventId, revision: 2),
      );
      final after = await service.getEvent(e.eventId, eventGroups);
      expect(after.revision, 3);
      expect(await generation(), gen + 1);
      expect(after.protocolVersion, before.protocolVersion);
      expect(
        after.occurrenceProtocolVersions,
        before.occurrenceProtocolVersions,
      );
    });
    test('event content late generation overflow rolls back new component and protocol state', () async {
      final e = await contentEvent();
      final scope = (await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      ))!;
      scope.revision = 9223372036854775807;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.changeOccurrenceContent(eventContentChange(e.eventId)),
        failure(CalendarFailureCode.limitExceeded),
      );
      final after = await service.getEvent(e.eventId, eventGroups);
      expect(after.revision, 1);
      expect(after.timingOverrides, isNull);
      expect(after.occurrenceProtocolVersions, isEmpty);
    });
    test('event content stored old imported baseline is unavailable rather than reinterpreted', () async {
      final e = await contentEvent();
      final row = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(e.eventId),
      ))!;
      row.importBaseline = eventImportBaseline(
        row.protocolUid,
        row.content,
        row.timingOverrides,
        row.protocolState!,
      ).copyWith(profile: eventBaselineProfile.replaceFirst('v2', 'v1'));
      await CalendarEventDataRecord.db.updateRow(session, row);
      await expectLater(
        service.getEvent(e.eventId, eventGroups),
        failure(CalendarFailureCode.unavailable),
      );
      await expectLater(
        service.changeOccurrenceContent(eventContentChange(e.eventId)),
        failure(CalendarFailureCode.unavailable),
      );
    });

    CalendarTaskReplaceRequest taskReplacement(
      UuidValue parent,
      UuidValue id, {
      int revision = 1,
      String? text,
      List<CalendarTaskExportSelection>? selection,
    }) => CalendarTaskReplaceRequest(
      calendarId: parent,
      expectedRevision: 1,
      selection:
          selection ??
          [CalendarTaskExportSelection(taskId: id, expectedRevision: revision)],
      bytes: taskImportRequest(parent, text: text).bytes,
    );
    Future<CalendarTaskDataRecord> taskData(UuidValue id) async =>
        (await CalendarTaskDataRecord.db.findFirstRow(
          session,
          where: (t) => t.taskId.equals(id),
        ))!;

    test('task replacement exact retry is a true no-op and changed source keeps assignments audit checkpoint and own identity', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      String source(String summary, {String stamp = '20260301T000000Z'}) =>
          taskCalendar([
            ...importedTask(
              'imported@example.invalid',
              properties: [
                'RRULE:FREQ=DAILY;COUNT=3',
                'SUMMARY:$summary',
                'PERCENT-COMPLETE:25',
              ],
            ),
            ...importedTask(
              'imported@example.invalid',
              timing: [],
              properties: [
                'RECURRENCE-ID;VALUE=DATE:20260329',
                'PERCENT-COMPLETE:12',
              ],
            ),
          ]).replaceAll('20260301T000000Z', stamp);
      final id = (await service.importTasks(
        taskImportRequest(parent, text: source('Before')),
      )).receipts.single.taskId;
      final row = (await CalendarTaskOccurrenceRecord.db.find(session)).single;
      final before = await taskData(id);
      final gen = await generation();
      final noOp = await service.replaceTasksFromImport(
        taskReplacement(parent, id, text: source('Before')),
      );
      expect(noOp.receipts.single.changed, isFalse);
      expect((await taskData(id)).toJson(), before.toJson());
      expect(await generation(), gen);
      await service.changeTaskAssignments(
        CalendarTaskAssignmentsRequest(
          taskId: id,
          expectedRevision: 1,
          assignees: [
            CalendarTaskAssignee(
              namespace: 'test',
              kind: 'person',
              externalId: 'alice',
            ),
          ],
        ),
      );
      final assigned = await taskData(id);
      final replaced = await service.replaceTasksFromImport(
        taskReplacement(
          parent,
          id,
          revision: 2,
          text: source('After', stamp: '20260201T000000Z'),
        ),
      );
      expect(replaced.receipts.single.changed, isTrue);
      expect(replaced.receipts.single.receipt.revision, 3);
      final after = await taskData(id);
      expect(after.assignees, assigned.assignees);
      expect(after.hasRecordedProgress, isNull);
      expect(after.createdAt, before.createdAt);
      expect(after.protocolVersion.stamp, DateTime.utc(2026, 2));
      expect(after.protocolVersion.sequence, isNull);
      expect(after.content.summary, 'After');
      expect(
        (await CalendarTaskOccurrenceRecord.db.find(session)).single.id,
        row.id,
      );
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
      expect(
        after.importBaseline!.canonicalValue,
        taskImportBaseline(
          after.protocolUid,
          after.sourceState!,
        ).canonicalValue,
      );
    });
    for (final permission in [
      CalendarPermission.importTasks,
      CalendarPermission.replaceTasksFromImport,
      CalendarPermission.readTask,
      CalendarPermission.readTaskSource,
      CalendarPermission.updateTask,
      CalendarPermission.changeTaskProgress,
    ]) {
      test(
        'task replacement independently requires ${permission.name} including removed progress',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final id = (await service.importTasks(
            taskImportRequest(
              parent,
              text: taskCalendar(
                importedTask(
                  'imported@example.invalid',
                  properties: ['PERCENT-COMPLETE:25'],
                ),
              ),
            ),
          )).receipts.single.taskId;
          final before = await taskData(id), gen = await generation();
          policy.denied.add(permission);
          await expectLater(
            service.replaceTasksFromImport(taskReplacement(parent, id)),
            failure(CalendarFailureCode.accessDenied),
          );
          expect((await taskData(id)).toJson(), before.toJson());
          expect(await generation(), gen);
        },
      );
    }
    test('task replacement read groups and final denial protect no-ops and changed batches', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importTasks(taskImportRequest(parent)))
          .receipts
          .single
          .taskId;
      policy.taskGrants = {CalendarTaskFieldGroup.summary};
      await expectLater(
        service.replaceTasksFromImport(taskReplacement(parent, id)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.taskGrants = CalendarTaskFieldGroup.values.toSet();
      policy.denyFinal = true;
      await expectLater(
        service.replaceTasksFromImport(taskReplacement(parent, id)),
        failure(CalendarFailureCode.accessDenied),
      );
      expect((await CalendarTaskRecord.db.findById(session, id))!.revision, 1);
    });
    test('task replacement rejects lower source sequence permits equal and preserves exact omissions', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final old = taskCalendar(
        importedTask(
          'imported@example.invalid',
          properties: ['SEQUENCE:3', 'SUMMARY:Before'],
        ),
      );
      final id = (await service.importTasks(
        taskImportRequest(parent, text: old),
      )).receipts.single.taskId;
      await expectLater(
        service.replaceTasksFromImport(
          taskReplacement(
            parent,
            id,
            text: old.replaceAll('SEQUENCE:3', 'SEQUENCE:2'),
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final equal = await service.replaceTasksFromImport(
        taskReplacement(
          parent,
          id,
          text: old.replaceAll('SUMMARY:Before', 'SUMMARY:After'),
        ),
      );
      expect(equal.receipts.single.changed, isTrue);
      await expectLater(
        service.replaceTasksFromImport(
          taskReplacement(parent, id, revision: 2),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
    });
    test('task replacement rejects local changes but identical local state does not adopt the baseline', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importTasks(taskImportRequest(parent)))
          .receipts
          .single
          .taskId;
      final imported = await taskData(id);
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: id,
          expectedRevision: 1,
          content: imported.content.copyWith(summary: 'Local'),
        ),
      );
      final current = await taskData(id), gen = await generation();
      await expectLater(
        service.replaceTasksFromImport(
          taskReplacement(parent, id, revision: 2),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final bytes = await service.exportTasks(
        CalendarTaskExportRequest(
          calendarId: parent,
          expectedRevision: 1,
          selection: [
            CalendarTaskExportSelection(taskId: id, expectedRevision: 2),
          ],
        ),
      );
      final result = await service.replaceTasksFromImport(
        taskReplacement(parent, id, revision: 2).copyWith(bytes: bytes),
      );
      expect(result.receipts.single.changed, isFalse);
      expect((await taskData(id)).toJson(), current.toJson());
      expect((await taskData(id)).importBaseline, imported.importBaseline);
      expect(await generation(), gen);
    });
    test('task replacement exact selection stale and missing baseline fail atomically', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final ids = (await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar([
            ...importedTask('one'),
            ...importedTask('two'),
          ]),
        ),
      )).receipts.map((r) => r.taskId).toList();
      final selection = [
        for (final id in ids)
          CalendarTaskExportSelection(taskId: id, expectedRevision: 1),
      ];
      await expectLater(
        service.replaceTasksFromImport(
          taskReplacement(
            parent,
            ids.first,
            selection: selection,
            text: taskCalendar(importedTask('one')),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.replaceTasksFromImport(
          taskReplacement(
            parent,
            ids.first,
            revision: 2,
            text: taskCalendar(importedTask('one')),
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      final data = await taskData(ids.last);
      data.importBaseline = null;
      await CalendarTaskDataRecord.db.updateRow(session, data);
      final gen = await generation();
      await expectLater(
        service.replaceTasksFromImport(
          taskReplacement(
            parent,
            ids.first,
            selection: selection,
            text: taskCalendar([
              ...importedTask('one', properties: ['SUMMARY:Changed']),
              ...importedTask('two'),
            ]),
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await taskData(ids.first)).content.summary, isNull);
      expect(await generation(), gen);
    });
    test('task replacement snapshots bytes selection and full trusted intent before callbacks', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importTasks(taskImportRequest(parent)))
          .receipts
          .single
          .taskId;
      final request = taskReplacement(
        parent,
        id,
        text: taskCalendar(
          importedTask(
            'imported@example.invalid',
            properties: ['SUMMARY:Changed'],
          ),
        ),
      );
      var saw = false;
      policy.onTaskReplacement = (r) {
        if (r.taskReplacement == null) {
          request.selection.clear();
          request.bytes.buffer.asUint8List().fillRange(
            0,
            request.bytes.buffer.lengthInBytes,
            0,
          );
        } else {
          saw = true;
          expect(r.taskReplacement!.members.single.current.taskId, id);
          expect(
            r
                .taskReplacement!
                .members
                .single
                .proposed
                .sourceState
                .master
                .content
                .summary,
            'Changed',
          );
          expect(
            () => r.taskReplacement!.members.clear(),
            throwsUnsupportedError,
          );
        }
      };
      await service.replaceTasksFromImport(request);
      expect(saw, isTrue);
      expect((await taskData(id)).content.summary, 'Changed');
    });

    test('task replacement preserves local progress history and rejects changed replacement', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final source = taskCalendar(
        importedTask(
          'imported@example.invalid',
          properties: ['RRULE:FREQ=DAILY;COUNT=3'],
        ),
      );
      final id = (await service.importTasks(
        taskImportRequest(parent, text: source),
      )).receipts.single.taskId;
      await service.changeTaskOccurrenceProgress(
        CalendarTaskOccurrenceProgressRequest(
          taskId: id,
          expectedRevision: 1,
          originalStart: day(28),
          action: CalendarTaskProgressAction.complete,
        ),
      );
      final history = (await CalendarTaskHistoryRecord.db.find(session))
          .map((r) => r.toJson())
          .toList();
      final before = await taskData(id);
      await expectLater(
        service.replaceTasksFromImport(
          taskReplacement(parent, id, revision: 2, text: source),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final bytes = await service.exportTasks(
        CalendarTaskExportRequest(
          calendarId: parent,
          expectedRevision: 1,
          selection: [
            CalendarTaskExportSelection(taskId: id, expectedRevision: 2),
          ],
        ),
      );
      expect(
        (await service.replaceTasksFromImport(
          taskReplacement(parent, id, revision: 2).copyWith(bytes: bytes),
        )).receipts.single.changed,
        isFalse,
      );
      expect((await taskData(id)).toJson(), before.toJson());
      expect(
        (await CalendarTaskHistoryRecord.db.find(session))
            .map((r) => r.toJson())
            .toList(),
        history,
      );
    });
    test('task replacement reconciles exact originals without retargeting removed own rows', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      String source(List<int> originals) => taskCalendar([
        ...importedTask(
          'imported@example.invalid',
          properties: ['RRULE:FREQ=DAILY;COUNT=4'],
        ),
        for (final original in originals)
          ...importedTask(
            'imported@example.invalid',
            timing: [],
            properties: [
              'RECURRENCE-ID;VALUE=DATE:202603$original',
              'PERCENT-COMPLETE:25',
            ],
          ),
      ]);
      final id = (await service.importTasks(
        taskImportRequest(parent, text: source([29, 30])),
      )).receipts.single.taskId;
      final old = await CalendarTaskOccurrenceRecord.db.find(session);
      final retained = old.singleWhere((r) => r.originalStart.start.day == 30);
      await service.replaceTasksFromImport(
        taskReplacement(parent, id, text: source([30, 31])),
      );
      final rows = await CalendarTaskOccurrenceRecord.db.find(session);
      expect(
        rows.map((r) => r.originalStart.start.day),
        unorderedEquals([30, 31]),
      );
      expect(
        rows.singleWhere((r) => r.originalStart.start.day == 30).id,
        retained.id,
      );
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
    });
    test('task replacement late scope overflow rolls back every payload revision and baseline', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final old = taskCalendar([
        ...importedTask('one'),
        ...importedTask('two'),
      ]);
      final ids = (await service.importTasks(
        taskImportRequest(parent, text: old),
      )).receipts.map((r) => r.taskId).toList();
      final before = (await CalendarTaskDataRecord.db.find(session))
          .map((r) => r.toJson())
          .toList();
      final scope = (await CalendarScopeRecord.db.find(session)).single;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.replaceTasksFromImport(
          taskReplacement(
            parent,
            ids.first,
            selection: [
              for (final id in ids)
                CalendarTaskExportSelection(taskId: id, expectedRevision: 1),
            ],
            text: taskCalendar([
              ...importedTask('one', properties: ['SUMMARY:Changed']),
              ...importedTask('two', properties: ['SUMMARY:Changed']),
            ]),
          ),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(
        (await CalendarTaskDataRecord.db.find(session))
            .map((r) => r.toJson())
            .toList(),
        before,
      );
      expect(
        (await CalendarTaskRecord.db.find(session)).map((r) => r.revision),
        everyElement(1),
      );
    });

    test('task import retains full source progress metadata baseline versions and no invented side effects', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final text = taskCalendar([
        ...importedTask(
          'source@example.invalid',
          properties: [
            'SUMMARY;LANGUAGE=sv:Hej',
            'PERCENT-COMPLETE:37',
            'COMPLETED:20260302T000000Z',
            'RRULE:FREQ=DAILY;COUNT=3',
            'SEQUENCE:7',
            'LAST-MODIFIED:20260201T000000Z',
            'CATEGORIES;LANGUAGE=sv:ett,ett',
            'COMMENT:Comment',
            'CONTACT:Private contact',
            'CLASS:PRIVATE',
            'ORGANIZER:mailto:source@example.invalid',
            'ATTENDEE;RSVP=TRUE:mailto:guest@example.invalid',
            'RELATED-TO:missing@example.invalid',
            'ATTACH;FMTTYPE=application/pdf:cid:synthetic@example.invalid',
            'BEGIN:VALARM',
            'ACTION:DISPLAY',
            'DESCRIPTION:Unarmed',
            'TRIGGER:-PT5M',
            'UID:alarm@example.invalid',
            'ACKNOWLEDGED:20260301T090000Z',
            'END:VALARM',
          ],
        ),
        'BEGIN:VTODO',
        'UID:source@example.invalid',
        'DTSTAMP:20260303T000000Z',
        'RECURRENCE-ID;VALUE=DATE:20260329',
        'PERCENT-COMPLETE:12',
        'END:VTODO',
      ]);
      final result = await service.importTasks(
        taskImportRequest(parent, text: text),
      );
      final id = result.receipts.single.taskId, view = await taskRead(id);
      expect(id.toString(), isNot('source@example.invalid'));
      expect(view.protocolVersion!.sequence, 7);
      expect(view.protocolVersion!.lastModified, DateTime.utc(2026, 2, 1));
      expect(view.protocolVersion!.created, isNull);
      expect(view.progress!.status, isNull);
      expect(view.progress!.percentComplete, 37);
      expect(view.progress!.completedAt, DateTime.utc(2026, 3, 2));
      expect(view.assignees, isEmpty);
      expect(view.summary, 'Hej');
      final data = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(data.hasRecordedProgress, isNull);
      expect(
        data.sourceState!.master.metadata.contacts.single.value,
        'Private contact',
      );
      expect(
        data.sourceState!.master.metadata.alarms.single.acknowledged,
        DateTime.utc(2026, 3, 1, 9),
      );
      validateTaskImportBaseline(
        data.importBaseline!,
        'source@example.invalid',
      );
      final previews = await service.previewTaskOccurrences(
        CalendarTaskOccurrenceQuery(
          taskId: id,
          expectedRevision: 1,
          fromDate: day(27).start,
          untilDate: day(31).start,
        ),
      );
      expect(previews.occurrences[0].progress.percentComplete, 37);
      expect(previews.occurrences[1].progress.percentComplete, 12);
      expect(previews.occurrences[1].progress.completedAt, isNull);
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
      final row = (await CalendarTaskOccurrenceRecord.db.find(session)).single;
      expect(row.protocolVersion!.stamp, DateTime.utc(2026, 3, 3));
      expect(row.protocolVersion!.sequence, isNull);
      expect((await service.get(parent, groups)).revision, 1);
      expect(view.toJson().containsKey('sourceState'), isFalse);
      expect(view.toJson().containsKey('importBaseline'), isFalse);
      await service.deleteTask(id, 1);
      expect(await CalendarTaskDataRecord.db.count(session), 0);
      expect(await CalendarTaskOccurrenceRecord.db.count(session), 0);
    });
    for (final op in [
      CalendarPermission.importTasks,
      CalendarPermission.createTask,
      CalendarPermission.changeTaskProgress,
    ]) {
      test(
        'task import independently requires ${op.name} and rolls back final denial',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final request = taskImportRequest(
            parent,
            text: taskCalendar(
              importedTask('gate', properties: ['PERCENT-COMPLETE:0']),
            ),
          );
          policy.denied.add(op);
          await expectLater(
            service.importTasks(request),
            failure(CalendarFailureCode.accessDenied),
          );
          policy.denied.clear();
          policy.denyFinal = true;
          await expectLater(
            service.importTasks(request),
            failure(CalendarFailureCode.accessDenied),
          );
          policy.denyFinal = false;
          expect(await CalendarTaskRecord.db.count(session), 0);
          expect(await CalendarTaskDataRecord.db.count(session), 0);
        },
      );
    }
    for (final property in [
      'STATUS:NEEDS-ACTION',
      'PERCENT-COMPLETE:0',
      'COMPLETED:20260301T000000Z',
    ]) {
      test(
        'task import progress authority detects source $property on an occurrence',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final text = taskCalendar([
            ...importedTask(
              'progress',
              properties: ['RRULE:FREQ=DAILY;COUNT=2'],
            ),
            'BEGIN:VTODO',
            'UID:progress',
            'DTSTAMP:20260301T000000Z',
            'RECURRENCE-ID;VALUE=DATE:20260329',
            property,
            'END:VTODO',
          ]);
          policy.denied.add(CalendarPermission.changeTaskProgress);
          await expectLater(
            service.importTasks(taskImportRequest(parent, text: text)),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(await CalendarTaskRecord.db.count(session), 0);
        },
      );
    }
    test('task import absent progress needs no progress authority and neutral prior progress stays unknown', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      policy.denied.addAll([
        CalendarPermission.changeTaskProgress,
        CalendarPermission.changeTaskAssignments,
      ]);
      final result = await service.importTasks(taskImportRequest(parent)),
          id = result.receipts.single.taskId;
      final data = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(data.progress.status, isNull);
      expect(data.progress.percentComplete, isNull);
      expect(data.hasRecordedProgress, isNull);
      policy.denied.clear();
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: id,
            expectedRevision: 1,
            content: data.content.copyWith(
              recurrence: CalendarEventRecurrence(
                rule: daily(),
                inclusions: [],
                exclusions: [],
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
    });
    test('task import final member rejection and policy revocation roll back complete immutable batch', () async {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          policyBatchSize: 1,
        ),
      );
      service = CalendarModule.service(session);
      final parent = (await service.create(createInput()))!.calendarId;
      final request = taskImportRequest(
        parent,
        text: taskCalendar([
          ...importedTask('first'),
          ...importedTask('second'),
        ]),
      );
      policy.denyTaskImportUid = 'second';
      policy.onTaskImport = (s, r, tx, phase) async {
        if (r.taskImport != null) {
          expect(r.current!.calendarId, parent);
          expect(r.taskImport!.members, hasLength(2));
          expect(() => r.taskImport!.members.clear(), throwsUnsupportedError);
          expect(
            () => r
                .taskImport!
                .members
                .first
                .sourceState
                .master
                .metadata
                .contacts
                .clear(),
            throwsUnsupportedError,
          );
          if (r.taskId != null) expect(r.proposedTaskSourceState, isNotNull);
        }
      };
      await expectLater(
        service.importTasks(request),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarTaskRecord.db.count(session), 0);
      policy.denyTaskImportUid = null;
      policy.onTaskImport = (s, r, tx, phase) async {
        if (r.taskImport != null &&
            phase == CalendarAuthorizationPhase.finalWrite) {
          policy.epoch = 'revoked';
        }
      };
      await expectLater(
        service.importTasks(request),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await CalendarTaskRecord.db.count(session), 0);
    });
    test('task import receipts require batch member and progress disclosure and grant no task read', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      policy.hideTaskImportBatch = true;
      final result = await service.importTasks(taskImportRequest(parent));
      expect(result.receipts, isEmpty);
      expect(await CalendarTaskRecord.db.count(session), 1);
      policy.hideTaskImportBatch = false;
      policy.hideTaskImportUid = 'hidden';
      final next = await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar([
            ...importedTask('shown'),
            ...importedTask('hidden'),
          ]),
        ),
      );
      expect(next.receipts, hasLength(1));
      expect(await CalendarTaskRecord.db.count(session), 3);
      policy.denied.add(CalendarPermission.readTask);
      await expectLater(
        taskRead(next.receipts.single.taskId),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('task import exact destination UID conflicts copies and tombstone reuse preserve identities', () async {
      final parent = (await service.create(createInput()))!.calendarId,
          other = (await service.create(createInput('Other')))!.calendarId;
      final first = (await service.importTasks(taskImportRequest(parent)))
          .receipts
          .single;
      await expectLater(
        service.importTasks(taskImportRequest(parent)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final copy = (await service.importTasks(taskImportRequest(other)))
          .receipts
          .single;
      expect(copy.taskId, isNot(first.taskId));
      await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar(importedTask('Imported@example.invalid')),
        ),
      );
      await service.deleteTask(first.taskId, 1);
      final reused = (await service.importTasks(taskImportRequest(parent)))
          .receipts
          .single;
      expect(reused.taskId, isNot(first.taskId));
      expect(await CalendarTaskRecord.db.count(session), 4);
    });
    test('task import preserves the exact ByteData slice and snapshots bytes before policy awaits', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final payload = utf8.encode(taskCalendar(importedTask('slice'))),
          storage = Uint8List.fromList([1, 2, ...payload, 3]);
      policy.onTaskImport = (s, r, tx, phase) async {
        if (r.taskImport == null) storage.fillRange(0, storage.length, 0);
      };
      final result = await service.importTasks(
        CalendarTaskImportRequest(
          calendarId: parent,
          expectedRevision: 1,
          bytes: ByteData.view(storage.buffer, 2, payload.length),
        ),
      );
      expect(result.receipts, hasLength(1));
      expect(
        (await taskRead(result.receipts.single.taskId)).protocolUid,
        'slice',
      );
    });
    test('task import stale revision scope and destination budgets reject without writes', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.importTasks(taskImportRequest(parent, revision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      policy.scopeOverride = 'other';
      await expectLater(
        service.importTasks(taskImportRequest(parent)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.scopeOverride = null;
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          maxScannedTasks: 1,
        ),
      );
      service = CalendarModule.service(session);
      await expectLater(
        service.importTasks(
          taskImportRequest(
            parent,
            text: taskCalendar([
              ...importedTask('one'),
              ...importedTask('two'),
            ]),
          ),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarTaskRecord.db.count(session), 0);
    });
    for (final malformed in <String, String>{
      'empty': taskCalendar([]),
      'bare LF': taskCalendar(importedTask('bad')).replaceAll('\r\n', '\n'),
      'floating': taskCalendar(
        importedTask('bad', timing: ['DTSTART:20260328T120000']),
      ),
      'fraction': taskCalendar(
        importedTask('bad', timing: ['DTSTART:20260328T120000.001Z']),
      ),
      'unsupported': taskCalendar(
        importedTask('bad', properties: ['X-UNKNOWN:bad']),
      ),
      'duplicate': taskCalendar([
        ...importedTask('same'),
        ...importedTask('same'),
      ]),
      'detached': taskCalendar([
        'BEGIN:VTODO',
        'UID:missing',
        'DTSTAMP:20260301T000000Z',
        'RECURRENCE-ID;VALUE=DATE:20260329',
        'END:VTODO',
      ]),
      'method': taskCalendar(importedTask('bad'))
          .replaceFirst('VERSION:2.0', 'VERSION:2.0\r\nMETHOD:REQUEST'),
    }.entries) {
      test('task import rejects ${malformed.key} atomically', () async {
        final parent = (await service.create(createInput()))!.calendarId;
        await expectLater(
          service.importTasks(taskImportRequest(parent, text: malformed.value)),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarTaskRecord.db.count(session), 0);
        expect(await CalendarTaskDataRecord.db.count(session), 0);
      });
    }

    test('task import strict byte bounds encoding and authorization precede source parsing', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      for (final bytes in [
        Uint8List.fromList([0xff]),
        Uint8List.fromList([
          0xef,
          0xbb,
          0xbf,
          ...utf8.encode(taskCalendar(importedTask('bom'))),
        ]),
      ]) {
        await expectLater(
          service.importTasks(
            CalendarTaskImportRequest(
              calendarId: parent,
              expectedRevision: 1,
              bytes: ByteData.sublistView(bytes),
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
      }
      await expectLater(
        service.importTasks(
          CalendarTaskImportRequest(
            calendarId: parent,
            expectedRevision: 1,
            bytes: ByteData(1048577),
          ),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      policy.denied.add(CalendarPermission.importTasks);
      await expectLater(
        service.importTasks(taskImportRequest(parent, text: 'malformed')),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarTaskRecord.db.count(session), 0);
    });
    test('task import digest collisions compare exact UIDs and hidden progress receipts remain private', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      await service.importTasks(taskImportRequest(parent));
      final existing = (await CalendarTaskDataRecord.db.find(session)).single;
      existing.uidDigest = eventUidDigest('collision');
      await CalendarTaskDataRecord.db.updateRow(session, existing);
      final result = await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar(importedTask('collision')),
        ),
      );
      expect(result.receipts, hasLength(1));
      expect(await CalendarTaskRecord.db.count(session), 2);
      policy.hideTaskProgressReceipt = true;
      final hidden = await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar(
            importedTask(
              'progress-hidden',
              properties: ['STATUS:NEEDS-ACTION'],
            ),
          ),
        ),
      );
      expect(hidden.receipts, isEmpty);
      expect(await CalendarTaskRecord.db.count(session), 3);
    });

    test('task import accepts undated UTC and named-zone source timing without reinterpretation', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      for (final (uid, timing) in [
        ('undated', <String>[]),
        ('utc', ['DUE:20260329T120000Z']),
        ('dated', ['DUE;VALUE=DATE:20260329']),
      ]) {
        final result = await service.importTasks(
          taskImportRequest(
            parent,
            text: taskCalendar(importedTask(uid, timing: timing)),
          ),
        );
        final view = await taskRead(result.receipts.single.taskId);
        expect(view.timing!.start, isNull);
        if (uid == 'utc') expect(view.timing!.kind, CalendarTaskTimeKind.utc);
        if (uid == 'undated') {
          expect(view.timing!.kind, CalendarTaskTimeKind.undated);
        }
      }
      final document = IcalendarSyntaxDocument([
        IcalendarSyntaxComponent('VCALENDAR', [
          IcalendarSyntaxProperty('VERSION', '2.0'),
          IcalendarSyntaxProperty('PRODID', 'Synthetic'),
          createIcalendarTimeZone('Europe/Stockholm'),
          IcalendarSyntaxComponent('VTODO', [
            IcalendarSyntaxProperty('UID', 'zoned'),
            IcalendarSyntaxProperty('DTSTAMP', '20260301T000000Z'),
            IcalendarSyntaxProperty(
              'DTSTART',
              '20260328T090000',
              parameters: [
                IcalendarSyntaxParameter('TZID', ['Europe/Stockholm']),
              ],
            ),
            IcalendarSyntaxProperty('DURATION', 'P1D'),
          ]),
        ]),
      ]);
      final result = await service.importTasks(
        CalendarTaskImportRequest(
          calendarId: parent,
          expectedRevision: 1,
          bytes: ByteData.sublistView(serializeIcalendarSyntax(document)),
        ),
      );
      final view = await taskRead(result.receipts.single.taskId);
      expect(view.timing!.zoneId, 'Europe/Stockholm');
      expect(view.timing!.duration!.days, 1);
    });

    test('task import late parse conflict and post-write overflow leave no partial state', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.importTasks(
          taskImportRequest(
            parent,
            text: taskCalendar([
              ...importedTask('valid'),
              ...importedTask('invalid', properties: ['X-UNKNOWN:bad']),
            ]),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarTaskRecord.db.count(session), 0);
      await service.importTasks(
        taskImportRequest(parent, text: taskCalendar(importedTask('existing'))),
      );
      await expectLater(
        service.importTasks(
          taskImportRequest(
            parent,
            text: taskCalendar([
              ...importedTask('would-be-new'),
              ...importedTask('existing'),
            ]),
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(await CalendarTaskRecord.db.count(session), 1);
      final scope = (await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      ))!;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.importTasks(
          taskImportRequest(
            parent,
            text: taskCalendar([
              ...importedTask(
                'rolled-back',
                properties: ['RRULE:FREQ=DAILY;COUNT=2'],
              ),
              'BEGIN:VTODO',
              'UID:rolled-back',
              'DTSTAMP:20260301T000000Z',
              'RECURRENCE-ID;VALUE=DATE:20260329',
              'END:VTODO',
            ]),
          ),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarTaskRecord.db.count(session), 1);
      expect(await CalendarTaskDataRecord.db.count(session), 1);
      expect(await CalendarTaskOccurrenceRecord.db.count(session), 0);
      expect(
        (await CalendarTaskDataRecord.db.find(session)).single.protocolUid,
        'existing',
      );
    });
    test(
      'task import rereads destination revision after pre-parse authorization',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        policy.onTaskImport = (s, r, tx, phase) async {
          if (r.taskImport == null) {
            final row = (await CalendarIdentityRecord.db.findById(
              s,
              parent,
              transaction: tx,
            ))!;
            row.revision++;
            await CalendarIdentityRecord.db.updateRow(s, row, transaction: tx);
          }
        };
        await expectLater(
          service.importTasks(taskImportRequest(parent)),
          failure(CalendarFailureCode.staleRevision),
        );
        expect(await CalendarTaskRecord.db.count(session), 0);
      },
    );

    // Synthetic storage fixture only; no import endpoint is exercised here.
    Future<CalendarTaskReceipt> storedSourceTask({
      bool recurring = false,
      bool alarm = false,
    }) async {
      final parent = (await service.create(createInput()))!.calendarId,
          task = await taskCreate(parent);
      final p = taskStorageProposal(
        parseIcalendarTaskCalendar(
          utf8.encode(
            [
              'BEGIN:VCALENDAR',
              'VERSION:2.0',
              'PRODID:Synthetic',
              'BEGIN:VTODO',
              'UID:source-task@example.invalid',
              'DTSTAMP:20260301T000000Z',
              'SUMMARY;LANGUAGE=sv:Hej',
              'CONTACT:Private source contact',
              'ORGANIZER:mailto:source@example.invalid',
              'ATTENDEE:mailto:guest@example.invalid',
              'ATTACH:cid:synthetic@example.invalid',
              'STATUS:NEEDS-ACTION',
              'PERCENT-COMPLETE:0',
              'DTSTART;VALUE=DATE:20260328',
              if (recurring) 'RRULE:FREQ=DAILY;COUNT=4',
              if (alarm) ...[
                'BEGIN:VALARM',
                'ACTION:DISPLAY',
                'DESCRIPTION:Private reminder',
                'TRIGGER:-PT5M',
                'END:VALARM',
              ],
              'END:VTODO',
              if (recurring) ...[
                'BEGIN:VTODO',
                'UID:source-task@example.invalid',
                'DTSTAMP:20260302T000000Z',
                'RECURRENCE-ID;VALUE=DATE:20260329',
                'SUMMARY;LANGUAGE=sv:Hej',
                'PERCENT-COMPLETE:12',
                'END:VTODO',
              ],
              'END:VCALENDAR',
              '',
            ].join('\r\n'),
          ),
        ).series.single,
      );
      final d = (await CalendarTaskDataRecord.db.find(session)).single;
      d.protocolUid = p.protocolUid;
      d.uidDigest = eventUidDigest(p.protocolUid);
      d.content = p.state.master.content;
      d.progress = p.state.master.progress;
      d.protocolVersion = p.state.master.version;
      d.sourceState = p.state;
      d.importBaseline = p.importBaseline;
      d.hasRecordedProgress = null;
      await CalendarTaskDataRecord.db.updateRow(session, d);
      for (final o in p.state.occurrences) {
        await CalendarTaskOccurrenceRecord.db.insertRow(
          session,
          CalendarTaskOccurrenceRecord(
            taskId: task.taskId,
            originalKey: taskOriginalKey(o.originalStart!),
            originalStart: o.originalStart!,
            contentOverrides: taskSourceContentOverrides(o),
            progress: o.progress,
            protocolVersion: o.version,
          ),
        );
      }
      return task;
    }

    test('task source storage retains metadata baseline and immutable policy context across edits', () async {
      final task = await storedSourceTask(recurring: true),
          before = (await CalendarTaskDataRecord.db.find(session)).single;
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: task.taskId,
          expectedRevision: 1,
          content: before.content.copyWith(summary: 'Changed'),
        ),
      );
      final proposal = policy.lastTaskRequest!.proposedTaskSourceState!;
      expect(
        proposal.master.metadata.contacts.single.value,
        'Private source contact',
      );
      expect(proposal.master.metadata.attendees, hasLength(1));
      expect(proposal.master.textParameters!.summary!.language, 'sv');
      expect(
        () => proposal.master.metadata.attendees.clear(),
        throwsUnsupportedError,
      );
      expect(
        () => policy
            .lastTaskRequest!
            .currentTask!
            .sourceState!
            .master
            .metadata
            .contacts
            .clear(),
        throwsUnsupportedError,
      );
      final after = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(after.importBaseline, before.importBaseline);
      expect(
        after.sourceState!.occurrences.single,
        before.sourceState!.occurrences.single,
      );
      expect(
        (await CalendarTaskOccurrenceRecord.db.find(session))
            .single
            .protocolVersion,
        before.sourceState!.occurrences.single.version,
      );
      expect(after.protocolVersion.sequence, 1);
      final view = await taskRead(task.taskId);
      expect(view.assignees, isEmpty);
      expect(view.toJson().containsKey('sourceState'), isFalse);
      expect(view.toJson().containsKey('importBaseline'), isFalse);
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: task.taskId,
          expectedRevision: 2,
          content: after.content,
        ),
      );
      final noOp = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(noOp.protocolVersion, after.protocolVersion);
      expect(noOp.sourceState, after.sourceState);
    });
    test('task source storage rejects lost alarm anchors unknown conversion and final denial atomically', () async {
      final task = await storedSourceTask(alarm: true),
          before = (await CalendarTaskDataRecord.db.find(session)).single;
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: task.taskId,
            expectedRevision: 1,
            content: before.content.copyWith(
              timing: CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: task.taskId,
            expectedRevision: 1,
            content: before.content.copyWith(
              recurrence: CalendarEventRecurrence(
                rule: daily(),
                inclusions: [],
                exclusions: [],
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: task.taskId,
            expectedRevision: 1,
            content: before.content.copyWith(
              description: String.fromCharCode(0x1f600) * 16384,
            ),
          ),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      policy.denyFinal = true;
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: task.taskId,
            expectedRevision: 1,
            content: before.content.copyWith(summary: 'Denied'),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      final after = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(after.toJson(), before.toJson());
      expect((await taskRead(task.taskId)).revision, 1);
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
    });
    test('task source storage occurrence actions own versions without changing the master', () async {
      final task = await storedSourceTask(recurring: true),
          before = (await CalendarTaskDataRecord.db.find(session)).single;
      final values = await service.previewTaskOccurrences(taskPreview(task)),
          original = values.occurrences[1].originalStart;
      expect(values.occurrences[1].progress.status, isNull);
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(
          task,
          original,
          1,
          CalendarTaskProgressAction.complete,
        ),
      );
      expect(
        policy.lastTaskRequest!.proposedTaskOccurrenceVersion!.sequence,
        1,
      );
      expect(
        policy.lastTaskRequest!.proposedTaskVersion,
        before.protocolVersion,
      );
      var after = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(after.protocolVersion, before.protocolVersion);
      expect(after.importBaseline, before.importBaseline);
      expect(after.sourceState!.occurrences.single.version.created, isNull);
      expect(
        after.sourceState!.occurrences.single.content.timing.kind,
        CalendarTaskTimeKind.undated,
      );
      expect(await CalendarTaskHistoryRecord.db.count(session), 1);
      final version = after.sourceState!.occurrences.single.version;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(
          task,
          original,
          2,
          CalendarTaskProgressAction.complete,
        ),
      );
      after = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(after.sourceState!.occurrences.single.version, version);
      expect(await CalendarTaskHistoryRecord.db.count(session), 1);
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(
          task,
          values.occurrences.first.originalStart,
          3,
          CalendarTaskProgressAction.complete,
        ),
      );
      after = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(after.sourceState!.occurrences, hasLength(2));
      expect(after.sourceState!.occurrences.last.version.sequence, 0);
      expect(after.sourceState!.occurrences.last.version.created, isNotNull);
      expect(after.protocolVersion, before.protocolVersion);
    });
    test('task source storage assignments preserve protocol state and keep stale final checks', () async {
      final task = await storedSourceTask(),
          before = (await CalendarTaskDataRecord.db.find(session)).single;
      CalendarTaskAssignmentsRequest request(int revision) =>
          CalendarTaskAssignmentsRequest(
            taskId: task.taskId,
            expectedRevision: revision,
            assignees: [
              CalendarTaskAssignee(
                namespace: 'test',
                kind: 'user',
                externalId: 'alice',
              ),
            ],
          );
      await service.changeTaskAssignments(request(1));
      final after = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(after.protocolVersion, before.protocolVersion);
      expect(after.sourceState, before.sourceState);
      expect(after.importBaseline, before.importBaseline);
      expect((await taskRead(task.taskId)).revision, 2);
      await expectLater(
        service.changeTaskAssignments(request(1)),
        failure(CalendarFailureCode.staleRevision),
      );
      policy.denyFinal = true;
      await expectLater(
        service.changeTaskAssignments(request(2)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      expect((await taskRead(task.taskId)).revision, 2);
    });
    test('task source storage corrupt projections and private baseline profiles fail closed', () async {
      final task = await storedSourceTask(recurring: true),
          data = (await CalendarTaskDataRecord.db.find(session)).single;
      final original = data.content;
      data.content = original.copyWith(summary: 'Corrupt shadow');
      await CalendarTaskDataRecord.db.updateRow(session, data);
      await expectLater(
        taskRead(task.taskId),
        failure(CalendarFailureCode.unavailable),
      );
      data.content = original;
      await CalendarTaskDataRecord.db.updateRow(session, data);
      final row = (await CalendarTaskOccurrenceRecord.db.find(session)).single;
      row.progress = CalendarTaskProgress(percentComplete: 99);
      await CalendarTaskOccurrenceRecord.db.updateRow(session, row);
      await expectLater(
        service.previewTaskOccurrences(taskPreview(task)),
        failure(CalendarFailureCode.unavailable),
      );
      data.importBaseline = data.importBaseline!.copyWith(profile: 'unknown');
      await CalendarTaskDataRecord.db.updateRow(session, data);
      await expectLater(
        taskRead(task.taskId),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test('task source storage deletion scrubs active data source history and baseline', () async {
      final task = await storedSourceTask(recurring: true),
          first = (await service.previewTaskOccurrences(taskPreview(task)))
              .occurrences
              .first
              .originalStart;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(task, first, 1, CalendarTaskProgressAction.complete),
      );
      await service.deleteTask(task.taskId, 2);
      expect(await CalendarTaskDataRecord.db.count(session), 0);
      expect(await CalendarTaskOccurrenceRecord.db.count(session), 0);
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
      final marker = (await CalendarTaskRecord.db.find(session)).single;
      expect(marker.deletedAt, isNotNull);
      expect(marker.revision, 3);
      expect(marker.toJson().containsKey('sourceState'), isFalse);
    });
    test('task source storage legacy occurrence initialization invents no creation or import baseline', () async {
      final task = await recurringTask(),
          first = (await service.previewTaskOccurrences(taskPreview(task)))
              .occurrences
              .first
              .originalStart;
      await CalendarTaskOccurrenceRecord.db.insertRow(
        session,
        CalendarTaskOccurrenceRecord(
          taskId: task.taskId,
          originalKey: taskOriginalKey(first),
          originalStart: first,
          progress: CalendarTaskProgress(percentComplete: 12),
        ),
      );
      final before = (await CalendarTaskDataRecord.db.find(session)).single;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(task, first, 1, CalendarTaskProgressAction.complete),
      );
      final row = (await CalendarTaskOccurrenceRecord.db.find(session)).single;
      expect(row.protocolVersion!.sequence, 1);
      expect(row.protocolVersion!.created, isNull);
      final after = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(after.importBaseline, isNull);
      expect(after.sourceState, isNull);
      expect(after.protocolVersion, before.protocolVersion);
    });

    test('source progress optional fields survive reads content writes and disclosure', () async {
      final parent = (await service.create(createInput()))!.calendarId,
          t = await taskCreate(parent);
      final data = (await CalendarTaskDataRecord.db.find(session)).single;
      data.progress = CalendarTaskProgress(completedAt: DateTime.utc(2020));
      await CalendarTaskDataRecord.db.updateRow(session, data);
      var view = await taskRead(t.taskId);
      expect(view.progress!.status, isNull);
      expect(view.progress!.percentComplete, isNull);
      expect(view.progress!.completedAt, DateTime.utc(2020));
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: t.taskId,
          expectedRevision: 1,
          content: taskContent('Changed text'),
        ),
      );
      view = await taskRead(t.taskId);
      expect(view.progress!.status, isNull);
      expect(view.progress!.percentComplete, isNull);
      expect(view.progress!.completedAt, DateTime.utc(2020));
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
      policy.taskGrants.remove(CalendarTaskFieldGroup.progress);
      expect((await taskRead(t.taskId)).progress, isNull);
      policy.taskGrants.add(CalendarTaskFieldGroup.progress);
      await service.changeTaskProgress(
        progressRequest(t.taskId, 2, CalendarTaskProgressAction.cancel),
      );
      view = await taskRead(t.taskId);
      expect(view.progress!.status, CalendarTaskStatus.cancelled);
      expect(view.progress!.percentComplete, isNull);
      expect(view.progress!.completedAt, isNull);
    });
    test('source recurring master defaults and sparse explicit originals remain independent', () async {
      final t = await recurringTask(),
          data = (await CalendarTaskDataRecord.db.find(session)).single;
      data.progress = CalendarTaskProgress(
        status: CalendarTaskStatus.completed,
        percentComplete: 37,
      );
      await CalendarTaskDataRecord.db.updateRow(session, data);
      final preview = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences;
      expect(
        preview.every(
          (o) =>
              o.progress.status == CalendarTaskStatus.completed &&
              o.progress.percentComplete == 37 &&
              o.progress.completedAt == null,
        ),
        isTrue,
      );
      final first = preview.first.originalStart,
          second = preview[1].originalStart;
      await CalendarTaskOccurrenceRecord.db.insertRow(
        session,
        CalendarTaskOccurrenceRecord(
          taskId: t.taskId,
          originalKey: taskOriginalKey(second),
          originalStart: second,
          progress: CalendarTaskProgress(percentComplete: 12),
        ),
      );
      var values = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences;
      expect(values[1].progress.status, isNull);
      expect(values[1].progress.percentComplete, 12);
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, first, 1, CalendarTaskProgressAction.complete),
      );
      values = (await service.previewTaskOccurrences(taskPreview(t, 2)))
          .occurrences;
      expect(values.first.progress.percentComplete, 100);
      expect(values.first.progress.completedAt, isNotNull);
      expect(values[1].progress.status, isNull);
      expect(values[1].progress.percentComplete, 12);
      expect(values.last.progress.percentComplete, 37);
      expect(values.last.progress.completedAt, isNull);
      final history = (await service.taskOccurrenceHistory(
        taskHistory(t, first, 2),
      )).entries.single;
      expect(history.before.status, CalendarTaskStatus.completed);
      expect(history.before.percentComplete, 37);
      expect(history.before.completedAt, isNull);
      expect(history.after.percentComplete, 100);
      expect(policy.lastTaskRequest!.currentTask!.progress.percentComplete, 37);
      await expectLater(
        service.changeTaskProgress(
          progressRequest(t.taskId, 2, CalendarTaskProgressAction.reopen),
        ),
        failure(CalendarFailureCode.validation),
      );
    });
    test('source completion timestamp still blocks supposedly clean native recurrence conversion', () async {
      final parent = (await service.create(createInput()))!.calendarId,
          t = await taskCreate(parent),
          data = (await CalendarTaskDataRecord.db.find(session)).single;
      data.progress = CalendarTaskProgress(
        status: CalendarTaskStatus.needsAction,
        percentComplete: 0,
        completedAt: DateTime.utc(2020),
      );
      await CalendarTaskDataRecord.db.updateRow(session, data);
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: t.taskId,
            expectedRevision: 1,
            content: CalendarTaskContent(
              timing: CalendarTaskTiming(
                kind: CalendarTaskTimeKind.date,
                start: CalendarEventCivil(year: 2026, month: 3, day: 28),
              ),
              recurrence: CalendarEventRecurrence(
                rule: daily(),
                inclusions: [],
                exclusions: [],
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
    });
    test('recurring task progress is independent with retained history and true transition no-ops', () async {
      final t = await recurringTask(),
          initial = await service.previewTaskOccurrences(taskPreview(t));
      final original = initial.occurrences.first.originalStart;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, original, 1, CalendarTaskProgressAction.complete),
      );
      final completed = (await service.previewTaskOccurrences(
        taskPreview(t, 2),
      )).occurrences;
      expect(completed.first.progress.status, CalendarTaskStatus.completed);
      expect(
        completed
            .skip(1)
            .every((o) => o.progress.status == CalendarTaskStatus.needsAction),
        isTrue,
      );
      expect(
        (await taskRead(t.taskId)).progress!.status,
        CalendarTaskStatus.needsAction,
      );
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, original, 2, CalendarTaskProgressAction.complete),
      );
      expect(await CalendarTaskHistoryRecord.db.count(session), 1);
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, original, 3, CalendarTaskProgressAction.cancel),
      );
      final cancelled = (await service.previewTaskOccurrences(
        taskPreview(t, 4),
      )).occurrences.first;
      expect(cancelled.progress.percentComplete, 100);
      expect(cancelled.progress.completedAt, isNull);
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, original, 4, CalendarTaskProgressAction.reopen),
      );
      final history = await service.taskOccurrenceHistory(
        taskHistory(t, original, 5, size: 10),
      );
      expect(history.entries.map((e) => e.action), [
        CalendarTaskProgressAction.complete,
        CalendarTaskProgressAction.cancel,
        CalendarTaskProgressAction.reopen,
      ]);
      expect(
        history.entries.first.after.completedAt,
        completed.first.progress.completedAt,
      );
      expect(history.entries.last.after.percentComplete, 0);
      expect(
        history.entries.every(
          (e) =>
              e.recordedAt.isUtc &&
              e.recordedAt.microsecond == 0 &&
              e.recordedAt.millisecond == 0,
        ),
        isTrue,
      );
      expect(await CalendarTaskOccurrenceRecord.db.count(session), 1);
      await expectLater(
        service.changeTaskProgress(
          progressRequest(t.taskId, 5, CalendarTaskProgressAction.complete),
        ),
        failure(CalendarFailureCode.validation),
      );
    });
    test('recurring task rule changes preserve exact recorded originals and reject exclusion or recurrence removal', () async {
      final t = await recurringTask(),
          original = (await service.previewTaskOccurrences(taskPreview(t)))
              .occurrences
              .first
              .originalStart;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, original, 1, CalendarTaskProgressAction.complete),
      );
      var current = await taskRead(t.taskId);
      CalendarTaskContent content({CalendarEventRecurrence? recurrence}) =>
          CalendarTaskContent(
            summary: 'Edited',
            timing: current.timing!,
            recurrence: recurrence,
          );
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: t.taskId,
            expectedRevision: 2,
            content: content(
              recurrence: current.recurrence!.copyWith(exclusions: [original]),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: t.taskId,
            expectedRevision: 2,
            content: content(),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: t.taskId,
          expectedRevision: 2,
          content: content(
            recurrence: current.recurrence!.copyWith(rule: daily(count: 4)),
          ),
        ),
      );
      expect(
        policy.lastTaskRequest!.recordedTaskOccurrences.single.originalStart
            .toJson(),
        original.toJson(),
      );
      expect(
        () => policy.lastTaskRequest!.recordedTaskOccurrences.clear(),
        throwsUnsupportedError,
      );
      current = await taskRead(t.taskId);
      expect(current.revision, 3);
      expect(
        (await service.taskOccurrenceHistory(taskHistory(t, original, 3)))
            .entries,
        hasLength(1),
      );
    });
    for (final permission in [
      CalendarPermission.readTask,
      CalendarPermission.previewTaskOccurrences,
    ]) {
      test(
        'recurring task preview independently requires ${permission.name}',
        () async {
          final t = await recurringTask();
          policy.denied.add(permission);
          await expectLater(
            service.previewTaskOccurrences(taskPreview(t)),
            failure(CalendarFailureCode.accessDenied),
          );
        },
      );
    }
    for (final group in [
      CalendarTaskFieldGroup.timing,
      CalendarTaskFieldGroup.progress,
    ]) {
      test(
        'recurring task preview/history require ${group.name} disclosure',
        () async {
          final t = await recurringTask(),
              original = (await service.previewTaskOccurrences(taskPreview(t)))
                  .occurrences
                  .first
                  .originalStart;
          policy.taskGrants.remove(group);
          await expectLater(
            service.previewTaskOccurrences(taskPreview(t)),
            failure(CalendarFailureCode.accessDenied),
          );
          await expectLater(
            service.taskOccurrenceHistory(taskHistory(t, original, 1)),
            failure(CalendarFailureCode.accessDenied),
          );
        },
      );
    }
    test('task history requires independent authority with immutable actual original context', () async {
      final t = await recurringTask(),
          original = (await service.previewTaskOccurrences(taskPreview(t)))
              .occurrences
              .first
              .originalStart;
      policy.denied.add(CalendarPermission.readTaskHistory);
      await expectLater(
        service.taskOccurrenceHistory(taskHistory(t, original, 1)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(
          t,
          original,
          1,
          CalendarTaskProgressAction.setPercentage,
          60,
        ),
      );
      final context = policy.lastTaskRequest!;
      expect(context.taskId, t.taskId);
      expect(context.calendarId, t.calendarId);
      expect(context.currentTaskOccurrence!.progress.percentComplete, 0);
      expect(context.proposedTaskOccurrence!.progress.percentComplete, 60);
      expect(
        context.taskOccurrenceProgressChange!.originalStart.toJson(),
        original.toJson(),
      );
      policy.denied.add(CalendarPermission.readTask);
      await expectLater(
        service.taskOccurrenceHistory(taskHistory(t, original, 2)),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('task occurrence final denial stale nonexistent and excluded identities cannot append history', () async {
      final t = await recurringTask(),
          original = (await service.previewTaskOccurrences(taskPreview(t)))
              .occurrences
              .first
              .originalStart;
      policy.denyFinal = true;
      await expectLater(
        service.changeTaskOccurrenceProgress(
          occurrenceProgress(
            t,
            original,
            1,
            CalendarTaskProgressAction.complete,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      await expectLater(
        service.changeTaskOccurrenceProgress(
          occurrenceProgress(
            t,
            original,
            2,
            CalendarTaskProgressAction.complete,
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.changeTaskOccurrenceProgress(
          occurrenceProgress(
            t,
            original.copyWith(
              start: CalendarEventCivil(year: 2026, month: 3, day: 31),
            ),
            1,
            CalendarTaskProgressAction.complete,
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
      expect(await CalendarTaskOccurrenceRecord.db.count(session), 0);
      expect((await taskRead(t.taskId)).revision, 1);
    });
    test('task history continuations isolate original object query kind and changed generation', () async {
      final t = await recurringTask(),
          originals = (await service.previewTaskOccurrences(taskPreview(t)))
              .occurrences;
      final first = originals.first.originalStart,
          second = originals[1].originalStart;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, first, 1, CalendarTaskProgressAction.complete),
      );
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, first, 2, CalendarTaskProgressAction.reopen),
      );
      final page = await service.taskOccurrenceHistory(
            taskHistory(t, first, 3),
          ),
          cursor = page.nextCursor!;
      expect(page.entries.single.action, CalendarTaskProgressAction.complete);
      expect(
        (await service.taskOccurrenceHistory(
          taskHistory(t, first, 3, cursor: cursor),
        )).entries.single.action,
        CalendarTaskProgressAction.reopen,
      );
      await expectLater(
        service.taskOccurrenceHistory(
          taskHistory(t, second, 3, cursor: cursor),
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      await expectLater(
        service.taskOccurrenceHistory(
          taskHistory(t, first, 3, size: 2, cursor: cursor),
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      await expectLater(
        service.listTasks(
          t.calendarId,
          pageSize: 1,
          fieldGroups: [
            CalendarTaskFieldGroup.timing,
            CalendarTaskFieldGroup.progress,
          ],
          cursor: cursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      await expectLater(
        service.listEvents(
          t.calendarId,
          pageSize: 1,
          fieldGroups: [],
          cursor: cursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      policy.epoch = 'changed';
      await expectLater(
        service.taskOccurrenceHistory(taskHistory(t, first, 3, cursor: cursor)),
        failure(CalendarFailureCode.invalidCursor),
      );
      policy.epoch = 'v1';
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, second, 3, CalendarTaskProgressAction.complete),
      );
      await expectLater(
        service.taskOccurrenceHistory(taskHistory(t, first, 4, cursor: cursor)),
        failure(CalendarFailureCode.invalidCursor),
      );
    });
    test('task conversion rejects unknown or ever-recorded progress even after reopening', () async {
      final parent = (await service.create(createInput()))!.calendarId,
          task = await taskCreate(parent);
      final recurring = CalendarTaskContent(
        timing: CalendarTaskTiming(
          kind: CalendarTaskTimeKind.date,
          start: CalendarEventCivil(year: 2026, month: 3, day: 28),
        ),
        recurrence: CalendarEventRecurrence(
          rule: daily(),
          inclusions: [],
          exclusions: [],
        ),
      );
      await service.changeTaskProgress(
        progressRequest(task.taskId, 1, CalendarTaskProgressAction.complete),
      );
      await service.changeTaskProgress(
        progressRequest(task.taskId, 2, CalendarTaskProgressAction.reopen),
      );
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: task.taskId,
            expectedRevision: 3,
            content: recurring,
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      final data = (await CalendarTaskDataRecord.db.find(session)).single;
      data.hasRecordedProgress = null;
      await CalendarTaskDataRecord.db.updateRow(session, data);
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: task.taskId,
            expectedRevision: 3,
            content: recurring,
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      final clean = await taskCreate(parent);
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: clean.taskId,
          expectedRevision: 1,
          content: recurring,
        ),
      );
      expect((await taskRead(clean.taskId)).recurrence, isNotNull);
    });
    test(
      'task deletion scrubs occurrence state and all retained history',
      () async {
        final t = await recurringTask(),
            original = (await service.previewTaskOccurrences(taskPreview(t)))
                .occurrences
                .first
                .originalStart;
        await service.changeTaskOccurrenceProgress(
          occurrenceProgress(
            t,
            original,
            1,
            CalendarTaskProgressAction.complete,
          ),
        );
        await service.changeTaskOccurrenceProgress(
          occurrenceProgress(t, original, 2, CalendarTaskProgressAction.reopen),
        );
        await service.deleteTask(t.taskId, 3);
        expect(await CalendarTaskOccurrenceRecord.db.count(session), 0);
        expect(await CalendarTaskHistoryRecord.db.count(session), 0);
        expect(await CalendarTaskDataRecord.db.count(session), 0);
        expect(
          (await CalendarTaskRecord.db.findById(session, t.taskId))!.deletedAt,
          isNotNull,
        );
      },
    );

    test('recorded task originals are bounded without pruning history or partial state', () async {
      final t = await recurringTask(), view = await taskRead(t.taskId);
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: t.taskId,
          expectedRevision: 1,
          content: CalendarTaskContent(
            timing: view.timing!,
            recurrence: view.recurrence!.copyWith(rule: daily(count: 1001)),
          ),
        ),
      );
      final start = DateTime.utc(2026, 3, 28);
      CalendarEventTiming original(int n) {
        final d = start.add(Duration(days: n));
        return CalendarEventTiming(
          kind: CalendarEventTimeKind.date,
          start: CalendarEventCivil(year: d.year, month: d.month, day: d.day),
        );
      }

      await CalendarTaskOccurrenceRecord.db.insert(session, [
        for (var i = 0; i < 1000; i++)
          CalendarTaskOccurrenceRecord(
            taskId: t.taskId,
            originalKey: taskOriginalKey(original(i)),
            originalStart: original(i),
            progress: CalendarTaskProgress(),
          ),
      ]);
      await expectLater(
        service.changeTaskOccurrenceProgress(
          occurrenceProgress(
            t,
            original(1000),
            2,
            CalendarTaskProgressAction.complete,
          ),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarTaskOccurrenceRecord.db.count(session), 1000);
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
      expect((await taskRead(t.taskId)).revision, 2);
    });
    test('task history rejects corrupted transition evidence instead of disclosing it', () async {
      final t = await recurringTask(),
          original = (await service.previewTaskOccurrences(taskPreview(t)))
              .occurrences
              .first
              .originalStart;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, original, 1, CalendarTaskProgressAction.complete),
      );
      final record = (await CalendarTaskHistoryRecord.db.find(session)).single;
      record.action = CalendarTaskProgressAction.reopen;
      await CalendarTaskHistoryRecord.db.updateRow(session, record);
      await expectLater(
        service.taskOccurrenceHistory(taskHistory(t, original, 2)),
        failure(CalendarFailureCode.unavailable),
      );
    });

    test('task native lifecycle preserves chosen percentage and current completion semantics', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final before = await service.get(parent, groups);
      final created = await taskCreate(parent), id = created.taskId;
      final original = await taskRead(id);
      expect(original.progress!.status, CalendarTaskStatus.needsAction);
      expect(original.protocolVersion!.sequence, 0);
      expect(original.protocolUid, isNot(id.toString()));
      await service.changeTaskProgress(
        progressRequest(id, 1, CalendarTaskProgressAction.setPercentage, 65),
      );
      await service.changeTaskProgress(
        progressRequest(id, 2, CalendarTaskProgressAction.cancel),
      );
      var current = await taskRead(id);
      expect(current.progress!.percentComplete, 65);
      expect(current.progress!.completedAt, isNull);
      expect(current.progress!.status, CalendarTaskStatus.cancelled);
      await expectLater(
        service.changeTaskProgress(
          progressRequest(id, 3, CalendarTaskProgressAction.complete),
        ),
        failure(CalendarFailureCode.validation),
      );
      await service.changeTaskProgress(
        progressRequest(id, 3, CalendarTaskProgressAction.reopen),
      );
      expect((await taskRead(id)).progress!.percentComplete, 0);
      await service.changeTaskProgress(
        progressRequest(id, 4, CalendarTaskProgressAction.complete),
      );
      current = await taskRead(id);
      final completed = current.progress!.completedAt!,
          version = current.protocolVersion!.toJson();
      expect(current.progress!.percentComplete, 100);
      expect(completed.isUtc, isTrue);
      expect(completed.millisecond, 0);
      expect(completed.microsecond, 0);
      await service.changeTaskProgress(
        progressRequest(id, 5, CalendarTaskProgressAction.complete),
      );
      current = await taskRead(id);
      expect(current.revision, 6);
      expect(current.progress!.completedAt, completed);
      expect(current.protocolVersion!.toJson(), version);
      await service.changeTaskProgress(
        progressRequest(id, 6, CalendarTaskProgressAction.cancel),
      );
      current = await taskRead(id);
      expect(current.progress!.percentComplete, 100);
      expect(current.progress!.completedAt, isNull);
      expect(current.protocolUid, original.protocolUid);
      final after = await service.get(parent, groups);
      expect(after.revision, before.revision);
      expect(
        after.protocolIdentity!.toJson(),
        before.protocolIdentity!.toJson(),
      );
    });

    for (final permission in [
      CalendarPermission.createTask,
      CalendarPermission.changeTaskAssignments,
    ]) {
      test(
        'task initial assignments independently require ${permission.name}',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          policy.denied.add(permission);
          await expectLater(
            taskCreate(
              parent,
              assignees: [
                CalendarTaskAssignee(
                  namespace: 'test',
                  kind: 'user',
                  externalId: 'alice',
                ),
              ],
            ),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(await CalendarTaskRecord.db.count(session), 0);
          expect(await CalendarTaskDataRecord.db.count(session), 0);
        },
      );
    }
    test('task assignment proposals are canonical immutable actual object context and support batch size one', () async {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          policyBatchSize: 1,
        ),
      );
      service = CalendarModule.service(session);
      final parent = (await service.create(createInput()))!.calendarId;
      final member = CalendarTaskAssignee(
        namespace: 'test',
        kind: 'user',
        externalId: 'alice',
      );
      final created = await taskCreate(parent, assignees: [member, member]);
      final request = policy.lastTaskRequest!;
      final assignmentVersion = (await taskRead(created.taskId))
          .protocolVersion;
      expect(request.taskId, created.taskId);
      expect(request.calendarId, parent);
      expect(request.current!.calendarId, parent);
      expect(request.proposedTaskAssignees, hasLength(1));
      expect(
        () => request.proposedTaskAssignees!.clear(),
        throwsUnsupportedError,
      );
      policy.denied.add(CalendarPermission.updateTask);
      await service.changeTaskAssignments(
        CalendarTaskAssignmentsRequest(
          taskId: created.taskId,
          expectedRevision: 1,
          assignees: [],
        ),
      );
      expect(policy.lastTaskRequest!.currentTask!.assignees, hasLength(1));
      expect((await taskRead(created.taskId)).assignees, isEmpty);
      expect(
        (await taskRead(created.taskId)).protocolVersion,
        assignmentVersion,
      );
    });
    for (final op in [
      CalendarPermission.updateTask,
      CalendarPermission.changeTaskProgress,
      CalendarPermission.changeTaskAssignments,
      CalendarPermission.deleteTask,
    ]) {
      test(
        'task ${op.name} is independently authorized and final denial rolls back',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final task = await taskCreate(parent);
          Future<dynamic> write() => switch (op) {
            CalendarPermission.updateTask => service.updateTask(
              CalendarTaskUpdateRequest(
                taskId: task.taskId,
                expectedRevision: 1,
                content: taskContent('changed'),
              ),
            ),
            CalendarPermission.changeTaskProgress => service.changeTaskProgress(
              progressRequest(
                task.taskId,
                1,
                CalendarTaskProgressAction.complete,
              ),
            ),
            CalendarPermission.changeTaskAssignments =>
              service.changeTaskAssignments(
                CalendarTaskAssignmentsRequest(
                  taskId: task.taskId,
                  expectedRevision: 1,
                  assignees: [],
                ),
              ),
            _ => service.deleteTask(task.taskId, 1),
          };
          policy.denied.add(op);
          await expectLater(write(), failure(CalendarFailureCode.accessDenied));
          policy.denied.clear();
          policy.denyFinal = true;
          await expectLater(write(), failure(CalendarFailureCode.accessDenied));
          policy.denyFinal = false;
          final current = await taskRead(task.taskId);
          expect(current.revision, 1);
          expect(current.summary, 'Private task');
          expect(current.progress!.status, CalendarTaskStatus.needsAction);
          expect(current.protocolVersion!.sequence, 0);
        },
      );
    }
    test('task content cannot change progress or assignments and stale writes preserve state', () async {
      final parent = (await service.create(createInput()))!.calendarId,
          task = await taskCreate(parent);
      await service.changeTaskProgress(
        progressRequest(task.taskId, 1, CalendarTaskProgressAction.complete),
      );
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: task.taskId,
            expectedRevision: 1,
            content: taskContent('stale'),
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      policy.denied.addAll([
        CalendarPermission.changeTaskProgress,
        CalendarPermission.changeTaskAssignments,
      ]);
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: task.taskId,
          expectedRevision: 2,
          content: taskContent('content only'),
        ),
      );
      final current = await taskRead(task.taskId);
      expect(current.progress!.status, CalendarTaskStatus.completed);
      expect(current.assignees, isEmpty);
      expect(policy.lastTaskRequest!.currentTask!.calendarId, parent);
    });
    test('task disclosure groups hide protected contents and denied reads/list do not expose identities', () async {
      final parent = (await service.create(createInput()))!.calendarId,
          task = await taskCreate(parent);
      policy.taskGrants = {CalendarTaskFieldGroup.summary};
      final current = await taskRead(task.taskId);
      expect(current.disclosedGroups, [CalendarTaskFieldGroup.summary]);
      expect(current.summary, 'Private task');
      expect(current.timing, isNull);
      expect(current.progress, isNull);
      expect(current.assignees, isNull);
      expect(current.protocolUid, isNull);
      expect(current.protocolVersion, isNull);
      policy.denied.add(CalendarPermission.readTask);
      await expectLater(
        taskRead(task.taskId),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await service.listTasks(
          parent,
          pageSize: 5,
          fieldGroups: taskGroups,
        )).tasks,
        isEmpty,
      );
      policy.denied.add(CalendarPermission.listTasks);
      await expectLater(
        service.listTasks(parent, pageSize: 5, fieldGroups: taskGroups),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('task continuations bind query kind calendar fields policy generation and page size', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final other = (await service.create(createInput()))!.calendarId;
      final first = await taskCreate(parent);
      await taskCreate(parent);
      await booking(parent, 10, 11);
      await booking(parent, 12, 13);
      Future<CalendarTaskPage> page({
        int size = 1,
        String? cursor,
        List<CalendarTaskFieldGroup> fields = taskGroups,
        UuidValue? calendar,
      }) => service.listTasks(
        calendar ?? parent,
        pageSize: size,
        fieldGroups: fields,
        cursor: cursor,
      );
      final initial = await page(), cursor = initial.nextCursor!;
      expect(initial.tasks, hasLength(1));
      expect(
        (await page(cursor: cursor)).tasks.single.id,
        isNot(initial.tasks.single.id),
      );
      await expectLater(
        page(size: 2, cursor: cursor),
        failure(CalendarFailureCode.invalidCursor),
      );
      await expectLater(
        page(calendar: other, cursor: cursor),
        failure(CalendarFailureCode.invalidCursor),
      );
      await expectLater(
        page(fields: [], cursor: cursor),
        failure(CalendarFailureCode.invalidCursor),
      );
      await expectLater(
        service.list(pageSize: 1, fieldGroups: groups, cursor: cursor),
        failure(CalendarFailureCode.invalidCursor),
      );
      await expectLater(
        service.listEvents(
          parent,
          pageSize: 1,
          fieldGroups: eventGroups,
          cursor: cursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      final eventCursor = (await service.listEvents(
        parent,
        pageSize: 1,
        fieldGroups: eventGroups,
      )).nextCursor!;
      await expectLater(
        page(cursor: eventCursor),
        failure(CalendarFailureCode.invalidCursor),
      );
      policy.epoch = 'v2';
      await expectLater(
        page(cursor: cursor),
        failure(CalendarFailureCode.invalidCursor),
      );
      policy.epoch = 'v1';
      await service.changeTaskProgress(
        progressRequest(first.taskId, 1, CalendarTaskProgressAction.complete),
      );
      await expectLater(
        page(cursor: cursor),
        failure(CalendarFailureCode.invalidCursor),
      );
    });
    test('task candidate plans constrain results without granting access and scan budgets fail closed', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final task = await taskCreate(parent);
      await taskCreate(parent);
      policy.taskCandidates = {task.taskId};
      expect(
        (await service.listTasks(
          parent,
          pageSize: 5,
          fieldGroups: taskGroups,
        )).tasks.single.id,
        task.taskId,
      );
      policy.denied.add(CalendarPermission.readTask);
      expect(
        (await service.listTasks(
          parent,
          pageSize: 5,
          fieldGroups: taskGroups,
        )).tasks,
        isEmpty,
      );
      policy.taskCandidates = null;
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          maxScannedTasks: 1,
          policyBatchSize: 1,
        ),
      );
      await expectLater(
        CalendarModule.service(session)
            .listTasks(parent, pageSize: 1, fieldGroups: taskGroups),
        failure(CalendarFailureCode.limitExceeded),
      );
    });
    test('tasks never book time and deletion scrubs payload while blocking parent only when active', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final task = (await service.createTask(
        CalendarTaskCreateRequest(
          calendarId: parent,
          content: taskContent().copyWith(
            timing: CalendarTaskTiming(
              kind: CalendarTaskTimeKind.zoned,
              zoneId: 'Europe/Stockholm',
              start: CalendarEventCivil(year: 2026, month: 3, day: 29, hour: 9),
              duration: CalendarEventDuration(hours: 2),
            ),
          ),
          assignees: [],
        ),
      ))!;
      expect(
        (await service.freeBusy(busyQuery(parent))).periods
            .every((p) => p.kind == CalendarFreeBusyKind.free),
        isTrue,
      );
      await expectLater(
        service.delete(parent, 1),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.deleteTask(task.taskId, 1);
      expect(await CalendarTaskDataRecord.db.count(session), 0);
      final marker = await CalendarTaskRecord.db.findById(session, task.taskId);
      expect(marker!.calendarId, parent);
      expect(marker.revision, 2);
      expect(marker.deletedAt, isNotNull);
      expect(marker.toJson().keys.toSet(), {
        '__className__',
        'id',
        'calendarId',
        'revision',
        'deletedAt',
      });
      await expectLater(
        taskRead(task.taskId),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await service.listTasks(
          parent,
          pageSize: 5,
          fieldGroups: taskGroups,
        )).tasks,
        isEmpty,
      );
      await service.delete(parent, 1);
    });
    test(
      'task actual scope and inconsistent stored parent fail closed',
      () async {
        final parent = (await service.create(createInput()))!.calendarId,
            task = await taskCreate(parent);
        final bob = builder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'bob',
                {},
              ),
            )
            .build();
        await expectLater(
          CalendarModule.service(bob).getTask(task.taskId, taskGroups),
          failure(CalendarFailureCode.accessDenied),
        );
        final data = (await CalendarTaskDataRecord.db.find(session)).single;
        data.calendarId = (await service.create(createInput()))!.calendarId;
        await CalendarTaskDataRecord.db.updateRow(session, data);
        await expectLater(
          taskRead(task.taskId),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test('task protocol overflow and scope generation overflow roll back active writes', () async {
      final parent = (await service.create(createInput()))!.calendarId,
          task = await taskCreate(parent);
      final data = (await CalendarTaskDataRecord.db.find(session)).single;
      data.protocolVersion = data.protocolVersion.copyWith(
        sequence: 2147483647,
      );
      await CalendarTaskDataRecord.db.updateRow(session, data);
      await expectLater(
        service.changeTaskProgress(
          progressRequest(task.taskId, 1, CalendarTaskProgressAction.complete),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect((await taskRead(task.taskId)).revision, 1);
      data.protocolVersion = data.protocolVersion.copyWith(sequence: 0);
      await CalendarTaskDataRecord.db.updateRow(session, data);
      final scope = (await CalendarScopeRecord.db.find(session)).single;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.changeTaskProgress(
          progressRequest(task.taskId, 1, CalendarTaskProgressAction.complete),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      final current = await taskRead(task.taskId);
      expect(current.revision, 1);
      expect(current.progress!.completedAt, isNull);
      expect(current.protocolVersion!.sequence, 0);
    });

    test('subject search unions bookings from complete contributors independently of direct calendar access', () async {
      final a = await contributor('alice'), b = await contributor('alice');
      final admin = await contributor('alice', contributes: false);
      await booking(a, 9, 10);
      await booking(b, 10, 11);
      await booking(admin, 12, 14);
      policy.denied.addAll([
        CalendarPermission.readFreeBusy,
        CalendarPermission.readEvent,
        CalendarPermission.listEvents,
        CalendarPermission.read,
        CalendarPermission.readAssociations,
      ]);
      final before = await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      );
      final result = await service.searchAvailability(searchQuery([target()]));
      expect(result.commonCoverage, CalendarFreeBusyCoverage.complete);
      final periods = result.results.single.periods;
      expect(periods.map((p) => p.kind), [
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.busy,
        CalendarFreeBusyKind.free,
      ]);
      expect(periods[1].startUtc, DateTime.utc(2026, 3, 29, 9));
      expect(periods[1].endUtc, DateTime.utc(2026, 3, 29, 11));
      final wire = result.toJson().toString();
      for (final secret in [
        a.toString(),
        b.toString(),
        admin.toString(),
        'Private booking',
        'test:alice',
      ]) {
        expect(wire, isNot(contains(secret)));
      }
      final projected = policy.searchRequests.where(
        (r) => r.operation == CalendarPermission.projectCalendarAvailability,
      );
      expect(projected.map((r) => r.calendarId).toSet(), {a, b});
      expect(
        projected.every(
          (r) =>
              r.availabilityTarget!.externalId == 'alice' &&
              r.current!.calendarId == r.calendarId,
        ),
        isTrue,
      );
      expect(result.calculatedAtUtc.microsecond, 0);
      expect(result.calculatedAtUtc.millisecond, 0);
      final after = await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      );
      expect(after!.revision, before!.revision);
    });
    test('subject search combines targets and deduplicates exact references without changing free semantics', () async {
      final a = await contributor('alice'), b = await contributor('bob');
      await booking(a, 9, 10);
      await booking(b, 10, 11);
      final query = searchQuery([target(), target('bob'), target()]);
      final result = await service.searchAvailability(query);
      expect(result.results.map((r) => r.target.externalId), ['alice', 'bob']);
      expect(result.commonCoverage, CalendarFreeBusyCoverage.complete);
      expect(result.commonSlots.map((w) => (w.startUtc, w.endUtc)), [
        (DateTime.utc(2026, 3, 29), DateTime.utc(2026, 3, 29, 9)),
        (DateTime.utc(2026, 3, 29, 11), DateTime.utc(2026, 3, 30)),
      ]);
      final perTarget = await service.searchAvailability(
        query.copyWith(mode: CalendarAvailabilitySearchMode.perTarget),
      );
      expect(perTarget.commonCoverage, isNull);
      expect(perTarget.commonSlots, isEmpty);
      expect(
        perTarget.results.every(
          (r) => r.coverage == CalendarFreeBusyCoverage.complete,
        ),
        isTrue,
      );
      expect(perTarget.snapshotId, isNot(result.snapshotId));
    });
    test('subject search denied targets and required projections never establish common free', () async {
      final a = await contributor('alice');
      await contributor('bob');
      await booking(a, 9, 10);
      policy.deniedSubjects.add('bob');
      final result = await service.searchAvailability(
        searchQuery([target(), target('bob')]),
      );
      expect(result.results.first.coverage, CalendarFreeBusyCoverage.complete);
      expect(result.results.last.coverage, CalendarFreeBusyCoverage.unknown);
      expect(result.results.last.periods, isEmpty);
      expect(result.results.last.freeSlots, isEmpty);
      expect(result.commonCoverage, CalendarFreeBusyCoverage.unknown);
      expect(result.commonSlots, isEmpty);
      for (final operation in [
        CalendarPermission.projectCalendarAvailability,
        CalendarPermission.projectEventBusy,
      ]) {
        policy.denied.add(operation);
        expect(
          (await service.searchAvailability(searchQuery([target()])))
              .results
              .single
              .coverage,
          CalendarFreeBusyCoverage.unknown,
        );
        policy.denied.remove(operation);
      }
    });
    test('subject search empty incomplete foreign and deleted contributor sets remain unknown', () async {
      final a = await contributor('alice');
      final query = searchQuery([target()]);
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: [],
      );
      expect(
        (await service.searchAvailability(query)).commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: false,
        revision: 'v',
        calendarIds: [a],
      );
      expect(
        (await service.searchAvailability(query)).results.single.periods,
        isEmpty,
      );
      policy.scopeOverride = 'test:foreign';
      final foreign = (await service.create(createInput()))!.calendarId;
      policy.scopeOverride = null;
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: [foreign],
      );
      expect(
        (await service.searchAvailability(query)).commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
      final deleted = (await service.create(createInput()))!.calendarId;
      await service.delete(deleted, 1);
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: [deleted],
      );
      expect(
        (await service.searchAvailability(query)).commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
    });
    test('subject search rechecks resolver revision set and summary access after calculation', () async {
      final a = await contributor('alice'), b = await contributor('bob');
      final query = searchQuery([target()]);
      for (final changeSet in [false, true]) {
        policy.resolverCalls.clear();
        policy.resolveOverride = (_, n) => CalendarSubjectResolution(
          complete: true,
          revision: !changeSet && n > 1 ? 'changed' : 'v',
          calendarIds: [changeSet && n > 1 ? b : a],
        );
        final result = await service.searchAvailability(query);
        expect(result.commonCoverage, CalendarFreeBusyCoverage.unknown);
        expect(result.results.single.periods, isEmpty);
      }
      policy.resolveOverride = null;
      policy.resolverCalls.clear();
      var calls = 0;
      policy.onSearchRead = (r) {
        if (++calls > 1) policy.deniedSubjects.add('alice');
      };
      expect(
        (await service.searchAvailability(query)).commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
    });
    test('subject search freezes query context and rejects malformed bounds minimums and raw target caps', () async {
      await contributor('alice');
      final originals = [target()];
      policy.onSearchRead = (r) {
        expect(
          () => r.availabilitySearchQuery!.targets.clear(),
          throwsUnsupportedError,
        );
        originals.clear();
      };
      expect(
        (await service.searchAvailability(searchQuery(originals))).results,
        hasLength(1),
      );
      policy.onSearchRead = null;
      for (final query in [
        searchQuery([]),
        searchQuery(List.generate(33, (_) => target())),
        searchQuery([target()], minimum: 0),
        searchQuery([target()], minimum: 2678401),
        searchQuery([target()])
            .copyWith(fromUtc: DateTime.utc(2026, 3, 29, 0, 0, 0, 1)),
        searchQuery([target()]).copyWith(untilUtc: DateTime.utc(2026, 5, 1)),
      ]) {
        await expectLater(
          service.searchAvailability(query),
          failure(CalendarFailureCode.validation),
        );
      }
      await expectLater(
        service.searchAvailability(
          searchQuery(List.generate(9, (n) => target('$n'))),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
    });
    test('subject search contributor raw caps and whole-query calendar budgets cannot produce partial common slots', () async {
      final ids = <UuidValue>[];
      for (var i = 0; i < 8; i++) {
        ids.add((await service.create(createInput()))!.calendarId);
      }
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: ids,
      );
      final result = await service.searchAvailability(
        searchQuery([target(), target('bob'), target('carol')]),
      );
      expect(
        result.results
            .take(2)
            .every((r) => r.coverage == CalendarFreeBusyCoverage.complete),
        isTrue,
      );
      expect(result.results.last.coverage, CalendarFreeBusyCoverage.unknown);
      expect(result.commonCoverage, CalendarFreeBusyCoverage.unknown);
      expect(result.commonSlots, isEmpty);
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: List.filled(9, ids.first),
      );
      expect(
        (await service.searchAvailability(searchQuery([target()])))
            .commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
    });

    CalendarAvailabilityContent hours({
      int priority = 0,
      bool closed = false,
    }) => CalendarAvailabilityContent(
      summary: 'Private working hours',
      priority: priority,
      openings: closed
          ? []
          : [
              CalendarAvailabilityOpening(
                timing: CalendarEventTiming(
                  kind: CalendarEventTimeKind.utc,
                  start: CalendarEventCivil(
                    year: 2026,
                    month: 3,
                    day: 29,
                    hour: 9,
                  ),
                  end: CalendarEventCivil(
                    year: 2026,
                    month: 3,
                    day: 29,
                    hour: 17,
                  ),
                ),
                recurrence: CalendarEventRecurrence(
                  rule: daily(),
                  inclusions: [],
                  exclusions: [],
                ),
              ),
            ],
    );
    test('subject search supports mixed people room and equipment references with the same external identifier', () async {
      final person = await contributor('shared');
      final targets = [target('shared')];
      final calendars = [person];
      for (final kind in ['room', 'equipment']) {
        final calendar = (await service.create(createInput()))!.calendarId;
        await service.changeSubject(
          CalendarSubjectChangeRequest(
            calendarId: calendar,
            expectedRevision: 1,
            action: CalendarSubjectAction.attach,
            namespace: 'test',
            kind: kind,
            externalId: 'shared',
            contributesAvailability: true,
          ),
        );
        targets.add(target('shared').copyWith(kind: kind));
        calendars.add(calendar);
      }
      for (var i = 0; i < calendars.length; i++) {
        await booking(calendars[i], 9 + i, 10 + i);
      }
      final result = await service.searchAvailability(searchQuery(targets));
      expect(result.results.map((r) => r.target.kind), [
        'user',
        'room',
        'equipment',
      ]);
      expect(
        result.results.every(
          (r) => r.coverage == CalendarFreeBusyCoverage.complete,
        ),
        isTrue,
      );
      expect(result.commonCoverage, CalendarFreeBusyCoverage.complete);
      expect(result.commonSlots.first.endUtc, DateTime.utc(2026, 3, 29, 9));
      expect(result.commonSlots.last.startUtc, DateTime.utc(2026, 3, 29, 12));
    });

    test('subject search intersects independently prioritized hours and filters minimum after combining', () async {
      final a = await contributor('alice'), b = await contributor('alice');
      await service.createAvailability(
        CalendarAvailabilityCreateRequest(calendarId: a, content: hours()),
      );
      await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: b,
          content: hours(priority: 1).copyWith(
            openings: [
              CalendarAvailabilityOpening(
                timing: hours().openings.single.timing.copyWith(
                  start: CalendarEventCivil(
                    year: 2026,
                    month: 3,
                    day: 29,
                    hour: 10,
                  ),
                  end: CalendarEventCivil(
                    year: 2026,
                    month: 3,
                    day: 29,
                    hour: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      final result = await service.searchAvailability(
        searchQuery([target()], minimum: 7 * 3600),
      );
      expect(result.commonSlots.single.startUtc, DateTime.utc(2026, 3, 29, 10));
      expect(result.commonSlots.single.endUtc, DateTime.utc(2026, 3, 29, 17));
      final tooLong = await service.searchAvailability(
        searchQuery([target()], minimum: 7 * 3600 + 1),
      );
      expect(tooLong.commonCoverage, CalendarFreeBusyCoverage.complete);
      expect(tooLong.commonSlots, isEmpty);
      expect(tooLong.results.single.periods, hasLength(3));
      policy.denied.add(CalendarPermission.projectAvailability);
      expect(
        (await service.searchAvailability(searchQuery([target()])))
            .commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
    });
    test('subject search charges duplicate source reads against an aggregate event budget', () async {
      final a = await contributor('alice');
      for (var i = 0; i < 33; i++) {
        await booking(a, 9, 10);
      }
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: [a],
      );
      final result = await service.searchAvailability(
        searchQuery(List.generate(8, (i) => target('person$i'))),
      );
      expect(
        result.results
            .take(7)
            .every((r) => r.coverage == CalendarFreeBusyCoverage.complete),
        isTrue,
      );
      expect(result.results.last.coverage, CalendarFreeBusyCoverage.unknown);
      expect(result.commonCoverage, CalendarFreeBusyCoverage.unknown);
      expect(result.commonSlots, isEmpty);
    });

    Future<CalendarAvailabilityView> editableHours() async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final created = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      return service.getAvailability(created.availabilityId);
    }

    CalendarAvailabilityOccurrenceChange openingChange(
      CalendarAvailabilityView rule,
      CalendarEventOccurrenceAction action, {
      CalendarEventTiming? replacement,
    }) => CalendarAvailabilityOccurrenceChange(
      availabilityId: rule.id,
      openingUid: rule.content.openings.single.uid!,
      expectedRevision: rule.revision,
      originalStart: rule.content.openings.single.timing.copyWith(
        end: null,
        duration: null,
      ),
      action: action,
      replacement: replacement,
    );
    CalendarAvailabilityOccurrenceQuery openingQuery(
      CalendarAvailabilityView rule,
    ) => CalendarAvailabilityOccurrenceQuery(
      availabilityId: rule.id,
      openingUid: rule.content.openings.single.uid!,
      expectedRevision: rule.revision,
      fromUtc: DateTime.utc(2026, 3, 29),
      untilUtc: DateTime.utc(2026, 4, 1),
    );
    Future<CalendarAvailabilityView> storedSource({
      UuidValue? parent,
      String? uid,
    }) async {
      final calendar =
          parent ?? (await service.create(createInput()))!.calendarId;
      final receipt = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: CalendarAvailabilityContent(openings: []),
        ),
      ))!;
      final lines = [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:-//Synthetic storage fixture//EN',
        'BEGIN:VAVAILABILITY',
        'UID:${uid ?? 'source/界@example.invalid'}',
        'DTSTAMP:20400101T000000Z',
        'SEQUENCE:17',
        'CATEGORIES;LANGUAGE=en:One,One',
        'CATEGORIES;LANGUAGE=sv:Två',
        'CONTACT;LANGUAGE=en;ALTREP="cid:desk@example.invalid":Desk',
        'BEGIN:AVAILABLE',
        'UID:hours/source@example.invalid',
        'DTSTAMP:20500101T000000Z',
        'DTSTART:20261022T090000Z',
        'DURATION:PT1H',
        'RDATE;VALUE=PERIOD:20261023T090000Z/PT2H',
        'CONTACT:Opening desk',
        'CATEGORIES;LANGUAGE=sv:Öppet',
        'END:AVAILABLE',
        'END:VAVAILABILITY',
        'END:VCALENDAR',
        '',
      ];
      final wire = parseIcalendarAvailabilityCalendar(
        utf8.encode(lines.join('\r\n')),
      );
      final proposal = availabilityStorageProposal(wire.definitions.single);
      final data = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(receipt.availabilityId),
      ))!;
      await CalendarAvailabilityDataRecord.db.updateRow(
        session,
        data.copyWith(
          protocolUid: proposal.protocolUid,
          uidDigest: availabilityUidDigest(proposal.protocolUid),
          content: proposal.content,
          timingOverrides: proposal.edits,
          protocolState: proposal.protocolState,
        ),
      );
      return service.getAvailability(receipt.availabilityId);
    }

    String importDefinition(
      String uid, {
      String extra = '',
      String opening = '',
    }) => [
      'BEGIN:VAVAILABILITY',
      'UID:$uid',
      'DTSTAMP:20400101T000000Z',
      'SEQUENCE:17',
      'SUMMARY:Imported hours',
      extra,
      opening,
      'END:VAVAILABILITY',
    ].where((s) => s.isNotEmpty).join('\r\n');
    String importFile(List<String> definitions) => [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic//EN',
      ...definitions,
      'END:VCALENDAR',
      '',
    ].join('\r\n');

    String eventSource(
      String uid, {
      List<String> extra = const [],
      String timing = 'DTSTART:20260329T090000Z',
    }) => [
      'BEGIN:VEVENT',
      'UID:$uid',
      'DTSTAMP:20400101T000000Z',
      timing,
      ...extra,
      'END:VEVENT',
    ].join('\r\n');
    String eventFile(List<String> components) => [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic import tests//EN',
      ...components,
      'END:VCALENDAR',
      '',
    ].join('\r\n');
    CalendarEventImportRequest eventImport(
      UuidValue parent,
      List<String> components, {
      int revision = 1,
      String? raw,
    }) => CalendarEventImportRequest(
      calendarId: parent,
      expectedRevision: revision,
      bytes: ByteData.sublistView(
        Uint8List.fromList(utf8.encode(raw ?? eventFile(components))),
      ),
    );
    CalendarEventReplaceRequest eventReplacement(
      UuidValue parent,
      UuidValue id,
      List<String> components, {
      int revision = 1,
      List<CalendarEventExportSelection>? selection,
    }) => CalendarEventReplaceRequest(
      calendarId: parent,
      expectedRevision: 1,
      selection:
          selection ??
          [
            CalendarEventExportSelection(
              eventId: id,
              expectedRevision: revision,
            ),
          ],
      bytes: eventImport(parent, components).bytes,
    );
    Future<CalendarEventDataRecord> eventData(UuidValue id) async =>
        (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(id),
        ))!;
    test('event replacement identical retry is a true no-op and source corrections retain exact omissions', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final old = [
        eventSource('source', extra: ['SUMMARY;LANGUAGE=en:Before']),
      ];
      final id = (await service.importEvents(eventImport(parent, old)))
          .receipts
          .single
          .eventId;
      final before = await eventData(id), gen = await generation();
      final noOp = await service.replaceEventsFromImport(
        eventReplacement(parent, id, old),
      );
      expect(noOp.receipts.single.changed, isFalse);
      expect((await eventData(id)).toJson(), before.toJson());
      expect(await generation(), gen);
      final changed = [
        old.single
            .replaceAll('Before', 'After')
            .replaceAll('20400101T000000Z', '20390101T000000Z'),
      ];
      final result = await service.replaceEventsFromImport(
        eventReplacement(parent, id, changed),
      );
      expect(result.receipts.single.changed, isTrue);
      expect(result.receipts.single.receipt.revision, 2);
      final after = await eventData(id);
      expect(after.createdAt, before.createdAt);
      expect(after.content.summary, 'After');
      expect(after.content.textParameters!.summary!.language, 'en');
      expect(after.protocolState!.version.stamp, DateTime.utc(2039));
      expect(after.protocolState!.version.sequence, isNull);
      expect(after.protocolState!.statusPresent, isFalse);
      expect(after.protocolState!.transparencyPresent, isFalse);
      expect(
        after.importBaseline!.canonicalValue,
        eventImportBaseline(
          after.protocolUid,
          after.content,
          after.timingOverrides,
          after.protocolState!,
        ).canonicalValue,
      );
      expect(await generation(), gen + 1);
    });
    for (final permission in [
      CalendarPermission.importEvents,
      CalendarPermission.replaceEventsFromImport,
      CalendarPermission.readEvent,
      CalendarPermission.readEventSource,
      CalendarPermission.updateEvent,
    ]) {
      test(
        'event replacement independently requires ${permission.name}',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final id = (await service.importEvents(
            eventImport(parent, [eventSource('source')]),
          )).receipts.single.eventId;
          final before = await eventData(id), gen = await generation();
          policy.denied.add(permission);
          await expectLater(
            service.replaceEventsFromImport(
              eventReplacement(parent, id, [
                eventSource('source', extra: ['SUMMARY:Changed']),
              ]),
            ),
            failure(CalendarFailureCode.accessDenied),
          );
          expect((await eventData(id)).toJson(), before.toJson());
          expect(await generation(), gen);
        },
      );
    }
    for (final group in CalendarEventFieldGroup.values) {
      test(
        'event replacement requires ${group.name} disclosure before no-op results',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final source = [eventSource('source')];
          final id = (await service.importEvents(eventImport(parent, source)))
              .receipts
              .single
              .eventId;
          policy.eventGrants.remove(group);
          await expectLater(
            service.replaceEventsFromImport(
              eventReplacement(parent, id, source),
            ),
            failure(CalendarFailureCode.accessDenied),
          );
        },
      );
    }
    for (final statuses in [
      ['CONFIRMED', 'CANCELLED'],
      ['CANCELLED', 'CONFIRMED'],
      ['CONFIRMED', 'TENTATIVE'],
    ]) {
      test(
        'event replacement lifecycle ${statuses.join(' to ')} needs separate authority',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final id = (await service.importEvents(
            eventImport(parent, [
              eventSource('source', extra: ['STATUS:${statuses.first}']),
            ]),
          )).receipts.single.eventId;
          policy.denied.add(CalendarPermission.changeEventStatus);
          final request = eventReplacement(parent, id, [
            eventSource('source', extra: ['STATUS:${statuses.last}']),
          ]);
          await expectLater(
            service.replaceEventsFromImport(request),
            failure(CalendarFailureCode.accessDenied),
          );
          policy.denied.clear();
          await service.replaceEventsFromImport(request);
          expect(
            (await eventData(id)).content.status.name.toUpperCase(),
            statuses.last,
          );
        },
      );
    }
    for (final adding in [false, true]) {
      test(
        'event replacement ${adding ? 'adding' : 'removing'} a cancelled original requires lifecycle permission',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final master = eventSource(
            'source',
            extra: ['RRULE:FREQ=DAILY;COUNT=3'],
          );
          final cancellation = eventSource(
            'source',
            timing: 'DTSTART:20260330T090000Z',
            extra: [
              'RECURRENCE-ID:20260330T090000Z',
              'STATUS:CANCELLED',
            ],
          );
          final old = [master, if (!adding) cancellation],
              next = [master, if (adding) cancellation];
          final id = (await service.importEvents(eventImport(parent, old)))
              .receipts
              .single
              .eventId;
          policy.denied.add(CalendarPermission.changeEventStatus);
          await expectLater(
            service.replaceEventsFromImport(eventReplacement(parent, id, next)),
            failure(CalendarFailureCode.accessDenied),
          );
          policy.denied.clear();
          await service.replaceEventsFromImport(
            eventReplacement(parent, id, next),
          );
          expect(
            (await eventData(id)).timingOverrides?.singles
                    .where((o) => o.cancelled)
                    .length ??
                0,
            adding ? 1 : 0,
          );
        },
      );
    }
    test('event replacement equal sequence is allowed lower or omitted source versions reject', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final old = [
        eventSource('source', extra: ['SEQUENCE:3', 'SUMMARY:Before']),
      ];
      final id = (await service.importEvents(eventImport(parent, old)))
          .receipts
          .single
          .eventId;
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(parent, id, [
            old.single.replaceAll('SEQUENCE:3', 'SEQUENCE:2'),
          ]),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.replaceEventsFromImport(
        eventReplacement(parent, id, [
          old.single.replaceAll('Before', 'After'),
        ]),
      );
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(parent, id, [eventSource('source')], revision: 2),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
    });
    test('event replacement local content conflicts and identical local exports never adopt the baseline', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final old = [eventSource('source')];
      final id = (await service.importEvents(eventImport(parent, old)))
          .receipts
          .single
          .eventId;
      final imported = await eventData(id);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 1,
          content: imported.content.copyWith(summary: 'Local'),
        ),
      );
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(parent, id, old, revision: 2),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final bytes = await service.exportEvents(
        CalendarEventExportRequest(
          calendarId: parent,
          expectedRevision: 1,
          selection: [
            CalendarEventExportSelection(eventId: id, expectedRevision: 2),
          ],
        ),
      );
      final before = await eventData(id), gen = await generation();
      final result = await service.replaceEventsFromImport(
        eventReplacement(parent, id, old, revision: 2).copyWith(bytes: bytes),
      );
      expect(result.receipts.single.changed, isFalse);
      expect((await eventData(id)).toJson(), before.toJson());
      expect((await eventData(id)).importBaseline, imported.importBaseline);
      expect(await generation(), gen);
    });
    test('event replacement baseline final denial and late overflow roll back the whole selection', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final old = [eventSource('one'), eventSource('two')];
      final ids = (await service.importEvents(eventImport(parent, old)))
          .receipts
          .map((r) => r.eventId)
          .toList();
      final request = eventReplacement(
        parent,
        ids.first,
        [
          eventSource('one', extra: ['SUMMARY:Changed']),
          eventSource('two', extra: ['SUMMARY:Changed']),
        ],
        selection: [
          for (final id in ids)
            CalendarEventExportSelection(eventId: id, expectedRevision: 1),
        ],
      );
      final before = (await CalendarEventDataRecord.db.find(session))
          .map((r) => r.toJson())
          .toList();
      policy.denyFinal = true;
      await expectLater(
        service.replaceEventsFromImport(request),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      final data = await eventData(ids.last),
          baseline = (await eventData(ids.last)).importBaseline;
      data.importBaseline = null;
      await CalendarEventDataRecord.db.updateRow(session, data);
      await expectLater(
        service.replaceEventsFromImport(request),
        failure(CalendarFailureCode.dependencyConflict),
      );
      data.importBaseline = baseline;
      await CalendarEventDataRecord.db.updateRow(session, data);
      final scope = (await CalendarScopeRecord.db.find(session)).single;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.replaceEventsFromImport(request),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(
        (await CalendarEventDataRecord.db.find(session))
            .map((r) => r.toJson())
            .toList(),
        before,
      );
      expect(
        (await CalendarEventRecord.db.find(session)).map((r) => r.revision),
        everyElement(1),
      );
    });
    test('event replacement snapshots bytes selection and trusted intent and rejects stale exact sets', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importEvents(
        eventImport(parent, [eventSource('source')]),
      )).receipts.single.eventId;
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(parent, id, [eventSource('wrong')]),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(parent, id, [eventSource('source')], revision: 2),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      final request = eventReplacement(parent, id, [
        eventSource('source', extra: ['SUMMARY:Changed']),
      ]);
      var saw = false;
      policy.onEventReplacement = (r) {
        if (r.eventReplacement == null) {
          request.selection.clear();
          request.bytes.buffer.asUint8List().fillRange(
            0,
            request.bytes.buffer.lengthInBytes,
            0,
          );
        } else {
          saw = true;
          expect(r.eventReplacement!.members.single.current.eventId, id);
          expect(
            r.eventReplacement!.members.single.proposed.content.summary,
            'Changed',
          );
          expect(
            () => r.eventReplacement!.members.clear(),
            throwsUnsupportedError,
          );
        }
      };
      await service.replaceEventsFromImport(request);
      expect(saw, isTrue);
    });

    test('event replacement rejects foreign deleted duplicate malformed and incompatible-baseline requests without writes', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final other = (await service.create(createInput('Other')))!.calendarId;
      final source = [eventSource('source')];
      final id = (await service.importEvents(eventImport(parent, source)))
          .receipts
          .single
          .eventId;
      final foreign = (await service.importEvents(eventImport(other, source)))
          .receipts
          .single
          .eventId;
      final gen = await generation();
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(parent, foreign, source),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      final request = eventReplacement(parent, id, source);
      await expectLater(
        service.replaceEventsFromImport(
          request.copyWith(
            selection: [...request.selection, ...request.selection],
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.replaceEventsFromImport(request.copyWith(selection: [])),
        failure(CalendarFailureCode.limitExceeded),
      );
      await expectLater(
        service.replaceEventsFromImport(
          request.copyWith(
            bytes: ByteData.sublistView(
              Uint8List.fromList(
                utf8.encode(eventFile(source).replaceAll('\r\n', '\n')),
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      final data = await eventData(id);
      data.importBaseline = data.importBaseline!.copyWith(
        profile: 'unsupported',
      );
      await CalendarEventDataRecord.db.updateRow(session, data);
      await expectLater(
        service.replaceEventsFromImport(request),
        failure(CalendarFailureCode.unavailable),
      );
      expect((await CalendarEventRecord.db.findById(session, id))!.revision, 1);
      expect(await generation(), gen);
      await service.deleteEvent(foreign, 1);
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(other, foreign, source),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });

    test('event import preserves source semantics versions baselines and occupied time atomically', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final before = await service.get(parent, groups);
      final gen = await generation();
      final result = await service.importEvents(
        eventImport(parent, [
          eventSource(
            'source@example.invalid',
            extra: [
              'DURATION:PT1H',
              'SUMMARY;LANGUAGE=sv;ALTREP="cid:synthetic@example.invalid":Private source',
              'RRULE:FREQ=DAILY;COUNT=3',
              'RDATE;VALUE=PERIOD:20260402T090000Z/PT2H',
              'SEQUENCE:6',
            ],
          ),
          eventSource(
            'source@example.invalid',
            timing: 'DTSTART:20260330T150000Z',
            extra: [
              'RECURRENCE-ID:20260330T090000Z',
              'DURATION:PT3H',
              'STATUS:CANCELLED',
              'SEQUENCE:8',
            ],
          ),
          eventSource(
            'date-source',
            timing: 'DTSTART;VALUE=DATE:20260329',
            extra: ['DURATION:P2D', 'TRANSP:TRANSPARENT'],
          ),
        ]),
      );
      expect(result.receipts, hasLength(2));
      expect(await generation(), gen + 1);
      final after = await service.get(parent, groups);
      expect(after.revision, before.revision);
      expect(
        after.protocolIdentity!.lastModified,
        before.protocolIdentity!.lastModified,
      );
      final id = result.receipts.first.eventId;
      final view = await service.getEvent(id, eventGroups);
      expect(view.protocolUid, 'source@example.invalid');
      expect(view.protocolVersion!.sequence, 6);
      expect(view.protocolVersion!.stamp, DateTime.utc(2040));
      expect(view.protocolVersion!.created, isNull);
      expect(view.statusPresent, isFalse);
      expect(view.transparencyPresent, isFalse);
      expect(view.textParameters!.summary!.language, 'sv');
      expect(view.periods!.single.duration!.hours, 2);
      expect(view.timingOverrides!.singles.single.replacement!.start.hour, 15);
      expect(view.occurrenceProtocolVersions!.single.version.sequence, 8);
      final data = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      ))!;
      validateEventImportBaseline(data.importBaseline!, data.protocolUid);
      expect(data.createdAt.isBefore(DateTime.utc(2040)), isTrue);
      expect(jsonEncode(view.toJson()), isNot(contains('canonicalValue')));
      final busy = await service.freeBusy(
        CalendarFreeBusyQuery(
          calendarId: parent,
          fromUtc: DateTime.utc(2026, 4, 2, 9),
          untilUtc: DateTime.utc(2026, 4, 2, 11),
        ),
      );
      expect(busy.coverage, CalendarFreeBusyCoverage.complete);
      expect(busy.periods.single.kind, CalendarFreeBusyKind.busy);
      final cancelled = await service.freeBusy(
        CalendarFreeBusyQuery(
          calendarId: parent,
          fromUtc: DateTime.utc(2026, 3, 30, 15),
          untilUtc: DateTime.utc(2026, 3, 30, 18),
        ),
      );
      expect(cancelled.periods.single.kind, CalendarFreeBusyKind.free);
      await expectLater(
        service.delete(parent, 1),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.deleteEvent(id, 1);
      expect(
        await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(id),
        ),
        isNull,
      );
    });
    for (final right in [
      CalendarPermission.importEvents,
      CalendarPermission.createEvent,
      CalendarPermission.changeEventStatus,
    ]) {
      test('event import independently requires ${right.name}', () async {
        final parent = (await service.create(createInput()))!.calendarId;
        policy.denied.add(right);
        final gen = await generation();
        await expectLater(
          service.importEvents(
            eventImport(parent, [
              eventSource('cancelled', extra: ['STATUS:CANCELLED']),
            ]),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarEventRecord.db.count(session), 0);
        expect(await generation(), gen);
      });
    }
    test('event import single cancellation needs lifecycle but ordinary creation does not', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      policy.denied.add(CalendarPermission.changeEventStatus);
      await expectLater(
        service.importEvents(
          eventImport(parent, [
            eventSource('cancel-series', extra: ['RRULE:FREQ=DAILY;COUNT=2']),
            eventSource(
              'cancel-series',
              extra: ['RECURRENCE-ID:20260330T090000Z', 'STATUS:CANCELLED'],
              timing: 'DTSTART:20260330T090000Z',
            ),
          ]),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      final result = await service.importEvents(
        eventImport(parent, [eventSource('ordinary')]),
      );
      expect(result.receipts, hasLength(1));
    });
    test('event import final later member denial rolls back full batch and generation', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final gen = await generation();
      policy.denyEventImportUid = 'second';
      await expectLater(
        service.importEvents(
          eventImport(parent, [eventSource('first'), eventSource('second')]),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarEventRecord.db.count(session), 0);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      expect(await generation(), gen);
    });
    test('event import receipts require batch create and lifecycle disclosure without read rights', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      policy.denied.addAll([
        CalendarPermission.readEvent,
        CalendarPermission.listEvents,
      ]);
      policy.hideEventImportUid = 'hidden';
      final result = await service.importEvents(
        eventImport(parent, [eventSource('shown'), eventSource('hidden')]),
      );
      expect(result.receipts, hasLength(1));
      expect(await CalendarEventRecord.db.count(session), 2);
      policy.hideEventImportBatch = true;
      expect(
        (await service.importEvents(
          eventImport(parent, [eventSource('batch-hidden')]),
        )).receipts,
        isEmpty,
      );
      policy.hideEventImportBatch = false;
      policy.hideEventLifecycleReceipt = true;
      expect(
        (await service.importEvents(
          eventImport(parent, [
            eventSource('cancelled-hidden', extra: ['STATUS:CANCELLED']),
          ]),
        )).receipts,
        isEmpty,
      );
    });
    test('event import UID conflicts are exact active destination-local with digest collisions', () async {
      final a = (await service.create(createInput()))!.calendarId;
      final b = (await service.create(createInput()))!.calendarId;
      final uid = 'Long ${'😀' * 1000}@example.invalid';
      final one = (await service.importEvents(
        eventImport(a, [eventSource(uid)]),
      )).receipts.single;
      final row = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(one.eventId),
      ))!;
      row.uidDigest = eventUidDigest('different');
      await CalendarEventDataRecord.db.updateRow(session, row);
      await service.importEvents(eventImport(a, [eventSource('different')]));
      // Restore the true digest before checking exact UID retry behavior.
      row.uidDigest = eventUidDigest(uid);
      await CalendarEventDataRecord.db.updateRow(session, row);
      final gen = await generation();
      await expectLater(
        service.importEvents(
          eventImport(a, [eventSource('late-new'), eventSource(uid)]),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(await generation(), gen);
      final copy = (await service.importEvents(
        eventImport(b, [eventSource(uid)]),
      )).receipts.single;
      expect(copy.eventId, isNot(one.eventId));
      await service.importEvents(
        eventImport(a, [eventSource(uid.toUpperCase())]),
      );
      policy.denied.add(CalendarPermission.createEvent);
      await expectLater(
        service.importEvents(eventImport(a, [eventSource(uid)])),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      await service.deleteEvent(one.eventId, 1);
      final reimport = (await service.importEvents(
        eventImport(a, [eventSource(uid)]),
      )).receipts.single;
      expect(reimport.eventId, isNot(one.eventId));
    });
    test('event import owns ByteData view before callbacks and proposals are deeply immutable', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final encoded = utf8.encode(
        eventFile([
          eventSource('owned', extra: ['RRULE:FREQ=DAILY;COUNT=2']),
        ]),
      );
      final padded = Uint8List.fromList([1, 2, ...encoded, 3]);
      var sawFinal = false;
      policy.onEventImport = (s, r, tx, phase) async {
        if (r.eventImport == null) {
          padded.fillRange(0, padded.length, 0);
        } else {
          expect(r.calendarId, parent);
          expect(r.current!.calendarId, parent);
          expect(() => r.eventImport!.members.clear(), throwsUnsupportedError);
          expect(
            () => r.eventImport!.members.single.content.recurrence!.rule!.byDay
                .clear(),
            throwsUnsupportedError,
          );
          expect(
            () => r.eventImport!.members.single.protocolState.overrides.clear(),
            throwsUnsupportedError,
          );
          if (phase == CalendarAuthorizationPhase.finalWrite) sawFinal = true;
        }
      };
      final result = await service.importEvents(
        CalendarEventImportRequest(
          calendarId: parent,
          expectedRevision: 1,
          bytes: ByteData.sublistView(padded, 2, padded.length - 1),
        ),
      );
      expect(result.receipts, hasLength(1));
      expect(sawFinal, isTrue);
      final finalCreates = policy.eventImportRequests.where(
        (v) =>
            v.$2 == CalendarAuthorizationPhase.finalWrite &&
            v.$1.operation == CalendarPermission.createEvent,
      );
      expect(finalCreates.single.$1.eventId, result.receipts.single.eventId);
      expect(
        finalCreates.single.$1.proposedEventProtocolState!.version.stamp,
        DateTime.utc(2040),
      );
    });
    test(
      'event import rechecks actor policy epoch and declared coordination',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        policy.onEventImport = (s, r, tx, phase) async {
          if (r.eventImport != null) policy.epoch = 'changed';
        };
        await expectLater(
          service.importEvents(eventImport(parent, [eventSource('epoch')])),
          failure(CalendarFailureCode.unavailable),
        );
        expect(await CalendarEventRecord.db.count(session), 0);
      },
    );
    test('event import stale foreign deleted parents and final denial leave no state', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.importEvents(
          eventImport(parent, [eventSource('stale')], revision: 2),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      final bob = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      await expectLater(
        CalendarModule.service(bob)
            .importEvents(eventImport(parent, [eventSource('foreign')])),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = true;
      await expectLater(
        service.importEvents(eventImport(parent, [eventSource('denied')])),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      await service.delete(parent, 1);
      await expectLater(
        service.importEvents(eventImport(parent, [eventSource('deleted')])),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarEventRecord.db.count(session), 0);
    });
    for (final bad in ['unsupported', 'detached', 'method', 'line endings']) {
      test('event import rejects $bad without partial writes', () async {
        final parent = (await service.create(createInput()))!.calendarId;
        var raw = eventFile([
          eventSource('valid'),
          eventSource(
            'bad',
            extra: [
              if (bad == 'unsupported') 'X-UNKNOWN:value',
              if (bad == 'detached') 'RECURRENCE-ID:20260329T090000Z',
            ],
          ),
        ]);
        if (bad == 'method') {
          raw = raw.replaceFirst(
            'VERSION:2.0',
            'VERSION:2.0\r\nMETHOD:REQUEST',
          );
        }
        if (bad == 'line endings') raw = raw.replaceAll('\r\n', '\n');
        final gen = await generation();
        await expectLater(
          service.importEvents(eventImport(parent, [], raw: raw)),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarEventDataRecord.db.count(session), 0);
        expect(await generation(), gen);
      });
    }
    test(
      'event import declared coordination cannot downgrade at final checks',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        policy.capability = CalendarAuthorizationGuarantee.coordinated;
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.coordinated,
          ),
        );
        service = CalendarModule.service(session);
        policy.onEventImport = (s, r, tx, phase) async {
          if (r.eventImport != null &&
              phase == CalendarAuthorizationPhase.preliminaryWrite) {
            policy.capability = CalendarAuthorizationGuarantee.freshCheck;
          }
        };
        await expectLater(
          service.importEvents(eventImport(parent, [eventSource('downgrade')])),
          failure(CalendarFailureCode.unavailable),
        );
        expect(await CalendarEventRecord.db.count(session), 0);
      },
    );
    test('event import reloads parent revision after preflight', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      policy.onEventImport = (s, r, tx, phase) async {
        if (r.eventImport == null) {
          final row = (await CalendarIdentityRecord.db.findById(
            s,
            parent,
            transaction: tx,
          ))!;
          row.revision++;
          await CalendarIdentityRecord.db.updateRow(s, row, transaction: tx);
        }
      };
      await expectLater(
        service.importEvents(
          eventImport(parent, [eventSource('stale-after-parse')]),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      expect(await CalendarEventRecord.db.count(session), 0);
    });
    test('event import rolls back inserted baselines on post-write generation overflow', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final scope = (await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      ))!;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.importEvents(eventImport(parent, [eventSource('rolled-back')])),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarEventRecord.db.count(session), 0);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      expect(await generation(), 9007199254740991);
    });
    test(
      'event import validates full-horizon zones and retains named source form',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final zone = [
          'BEGIN:VTIMEZONE',
          'TZID:UTC',
          'BEGIN:STANDARD',
          'DTSTART:19000101T000000',
          'TZOFFSETFROM:+0000',
          'TZOFFSETTO:+0000',
          'END:STANDARD',
          'END:VTIMEZONE',
        ].join('\r\n');
        final source = eventSource(
          'named',
          timing: 'DTSTART;TZID=UTC:20260329T090000',
          extra: ['DURATION:P1D'],
        );
        final result = await service.importEvents(
          eventImport(parent, [zone, source]),
        );
        final view = await service.getEvent(
          result.receipts.single.eventId,
          eventGroups,
        );
        expect(view.timing!.kind, CalendarEventTimeKind.zoned);
        expect(view.timing!.zoneId, 'UTC');
        expect(view.timing!.duration!.days, 1);
        final invalid = eventFile([
          zone.replaceAll('+0000', '+0100'),
          source.replaceFirst('UID:named', 'UID:wrong-zone'),
        ]);
        await expectLater(
          service.importEvents(eventImport(parent, [], raw: invalid)),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarEventRecord.db.count(session), 1);
      },
    );
    test('event import charges byte raw component and destination capacity limits', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.importEvents(eventImport(parent, [], raw: 'x' * 1048577)),
        failure(CalendarFailureCode.limitExceeded),
      );
      // Two master groups stay below the per-series override cap but together exceed raw VEVENT count.
      String stamp(int n) {
        final d = DateTime.utc(2026, 1, 1).add(Duration(days: n));
        return '2026${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T090000Z';
      }

      await expectLater(
        service.importEvents(
          eventImport(parent, [
            for (var m = 0; m < 2; m++) ...[
              eventSource(
                'master-$m',
                timing: 'DTSTART:${stamp(0)}',
                extra: ['RRULE:FREQ=DAILY;COUNT=65'],
              ),
              for (var i = 1; i <= (m == 0 ? 64 : 63); i++)
                eventSource(
                  'master-$m',
                  timing: 'DTSTART:${stamp(i)}',
                  extra: ['RECURRENCE-ID:${stamp(i)}'],
                ),
            ],
          ]),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          maxScannedEvents: 1,
          policyBatchSize: 1,
        ),
      );
      service = CalendarModule.service(session);
      await service.importEvents(eventImport(parent, [eventSource('one')]));
      final gen = await generation();
      await expectLater(
        service.importEvents(eventImport(parent, [eventSource('two')])),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await generation(), gen);
      expect(await CalendarEventRecord.db.count(session), 1);
    });

    CalendarEventExportRequest eventExport(
      List<CalendarEventReceipt> events, {
      UuidValue? parent,
      int parentRevision = 1,
    }) => CalendarEventExportRequest(
      calendarId: parent ?? events.first.calendarId,
      expectedRevision: parentRevision,
      selection: [
        for (final e in events)
          CalendarEventExportSelection(
            eventId: e.eventId,
            expectedRevision: e.revision,
          ),
      ],
    );
    String exported(ByteData bytes) => utf8.decode(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    const richEventSourceAlarms = [
      'BEGIN:VALARM',
      'ACTION:DISPLAY',
      'DESCRIPTION:SOURCE-ALARM-DESCRIPTION',
      'TRIGGER:-PT5M',
      'UID:event-source-alarm',
      'ACKNOWLEDGED:20260320T120000Z',
      'END:VALARM',
      'BEGIN:VALARM',
      'ACTION:DISPLAY',
      'DESCRIPTION:Source snooze',
      'TRIGGER;VALUE=DATE-TIME:20260329T080000Z',
      'UID:event-source-snooze',
      'RELATED-TO;RELTYPE=SNOOZE:event-source-alarm',
      'END:VALARM',
    ];
    CalendarEventDescriptiveMetadata descriptive({
      int? priority = 0,
      String latitude = '+090.000000000000000000',
      String longitude = '-000.000',
    }) => CalendarEventDescriptiveMetadata(
      priority: priority,
      geographicPosition: CalendarEventGeographicPosition(
        latitudeText: latitude,
        longitudeText: longitude,
      ),
      resourceGroups: [
        CalendarEventResourceGroup(
          values: ['Rum, ett', '', 'Rum'],
          language: 'sv',
          alternativeUri: 'cid:labels@example.invalid',
        ),
        CalendarEventResourceGroup(values: ['Room', 'Room']),
      ],
    );
    const wireDescriptive = [
      'PRIORITY:0',
      'GEO:+090.000000000000000000;-000.000',
      r'RESOURCES;LANGUAGE=sv;ALTREP="cid:labels@example.invalid":Rum\, ett,,Rum',
      'RESOURCES:Room,Room',
    ];
    test('event descriptive native edit preserves unrelated source, exact decimals and protocol no-op', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importEvents(
        eventImport(parent, [
          eventSource(
            'descriptive',
            extra: ['CONTACT:PRIVATE-DESK', 'SUMMARY:Original'],
          ),
        ]),
      )).receipts.single.eventId;
      final baseline = (await eventData(id)).importBaseline!.canonicalValue;
      await service.updateEventDescriptiveMetadata(
        CalendarEventDescriptiveRequest(
          eventId: id,
          expectedRevision: 1,
          metadata: descriptive(),
        ),
      );
      final row = await eventData(id), version = row.protocolState!.version;
      expect(version.sequence, 1);
      expect(
        row.protocolState!.sourceMetadata!.contacts.single.value,
        'PRIVATE-DESK',
      );
      expect(row.importBaseline!.canonicalValue, baseline);
      final view = await service.getEvent(id, eventGroups);
      expect(view.priority, 0);
      expect(view.geographicPosition!.latitudeText, '+090.000000000000000000');
      expect(view.resourceGroups!.first.values, ['Rum, ett', '', 'Rum']);
      expect(
        jsonEncode(view.toJsonForProtocol()),
        isNot(contains('PRIVATE-DESK')),
      );
      final exported = await service.exportEvents(
        eventExport([
          CalendarEventReceipt(
            eventId: id,
            calendarId: parent,
            revision: 2,
            deleted: false,
          ),
        ]),
      );
      expect(
        parseIcalendarEventCalendar(
          exported.buffer.asUint8List(
            exported.offsetInBytes,
            exported.lengthInBytes,
          ),
        ).events.single.metadata.resources.length,
        2,
      );
      await service.updateEventDescriptiveMetadata(
        CalendarEventDescriptiveRequest(
          eventId: id,
          expectedRevision: 2,
          metadata: descriptive(),
        ),
      );
      expect((await eventData(id)).protocolState!.version, version);
      expect((await service.getEvent(id, eventGroups)).revision, 3);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 3,
          content: row.content.copyWith(summary: 'Native edit'),
        ),
      );
      final after = await eventData(id);
      expect(
        after.protocolState!.sourceMetadata!.geographicPosition!.longitudeText,
        '-000.000',
      );
      expect(after.importBaseline!.canonicalValue, baseline);
      await service.updateEventDescriptiveMetadata(
        CalendarEventDescriptiveRequest(
          eventId: id,
          expectedRevision: 4,
          metadata: CalendarEventDescriptiveMetadata(resourceGroups: []),
        ),
      );
      final cleared = await eventData(id);
      expect(cleared.protocolState!.sourceMetadata!.priority, isNull);
      expect(cleared.protocolState!.sourceMetadata!.geographicPosition, isNull);
      expect(cleared.protocolState!.sourceMetadata!.resourceGroups, isNull);
      expect(
        cleared.protocolState!.sourceMetadata!.contacts.single.value,
        'PRIVATE-DESK',
      );
    });
    test('event descriptive import preserves matching occurrence presence and omitted inheritance', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importEvents(
        eventImport(parent, [
          eventSource(
            'descriptive',
            extra: ['RRULE:FREQ=DAILY;COUNT=3', ...wireDescriptive],
          ),
          eventSource(
            'descriptive',
            timing: 'DTSTART:20260330T100000Z',
            extra: ['RECURRENCE-ID:20260330T090000Z'],
          ),
          eventSource(
            'descriptive',
            timing: 'DTSTART:20260331T100000Z',
            extra: ['RECURRENCE-ID:20260331T090000Z', ...wireDescriptive],
          ),
        ]),
      )).receipts.single.eventId;
      final row = await eventData(id), gen = await generation();
      expect(row.timingOverrides!.singles.first.sourceMetadata, isNull);
      expect(row.timingOverrides!.singles.last.sourceMetadata!.priority, 0);
      final bytes = await service.exportEvents(
        eventExport([
          CalendarEventReceipt(
            eventId: id,
            calendarId: parent,
            revision: 1,
            deleted: false,
          ),
        ]),
      );
      final round = eventStorageProposal(
        parseIcalendarEventCalendar(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        ).series.single,
      );
      expect(
        round.importBaseline.canonicalValue,
        row.importBaseline!.canonicalValue,
      );
      await expectLater(
        service.updateEventDescriptiveMetadata(
          CalendarEventDescriptiveRequest(
            eventId: id,
            expectedRevision: 1,
            metadata: descriptive(priority: 1),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect((await eventData(id)).toJson(), row.toJson());
      expect(await generation(), gen);
      policy.denied.add(CalendarPermission.updateEventDescriptiveMetadata);
      await expectLater(
        service.updateEventDescriptiveMetadata(
          CalendarEventDescriptiveRequest(
            eventId: id,
            expectedRevision: 1,
            metadata: descriptive(priority: 1),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('event descriptive groups independently disclose fields and protect full export', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final receipt = (await service.importEvents(
        eventImport(parent, [
          eventSource('descriptive', extra: wireDescriptive),
        ]),
      )).receipts.single;
      for (final group in [
        CalendarEventFieldGroup.location,
        CalendarEventFieldGroup.priority,
        CalendarEventFieldGroup.resources,
      ]) {
        policy.eventGrants = {group};
        final view = await service.getEvent(receipt.eventId, eventGroups);
        expect(
          view.priority,
          group == CalendarEventFieldGroup.priority ? 0 : null,
        );
        expect(
          view.geographicPosition != null,
          group == CalendarEventFieldGroup.location,
        );
        expect(
          view.resourceGroups != null,
          group == CalendarEventFieldGroup.resources,
        );
        final listed = (await service.listEvents(
          parent,
          pageSize: 10,
          fieldGroups: eventGroups,
        )).events.single;
        expect(listed.toJson(), view.toJson());
        await expectLater(
          service.exportEvents(eventExport([receipt])),
          failure(CalendarFailureCode.accessDenied),
        );
      }
    });
    test(
      'event descriptive validation stale denial and final rollback are atomic',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final receipt = (await service.createEvent(
          CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
        ))!;
        final id = receipt.eventId,
            before = await eventData(receipt.eventId),
            gen = await generation();
        Future<CalendarEventReceipt?> write(
          CalendarEventDescriptiveMetadata value, {
          int revision = 1,
        }) => service.updateEventDescriptiveMetadata(
          CalendarEventDescriptiveRequest(
            eventId: id,
            expectedRevision: revision,
            metadata: value,
          ),
        );
        await expectLater(
          write(descriptive(latitude: '90.000000000000000001')),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(
          write(descriptive(priority: 10)),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(
          write(
            CalendarEventDescriptiveMetadata(
              resourceGroups: [CalendarEventResourceGroup(values: [])],
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(
          write(descriptive(), revision: 2),
          failure(CalendarFailureCode.staleRevision),
        );
        policy.denied.add(CalendarPermission.updateEventDescriptiveMetadata);
        await expectLater(
          write(descriptive()),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        policy.denyFinal = true;
        await expectLater(
          write(descriptive()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await eventData(id)).toJson(), before.toJson());
        expect(await generation(), gen);
      },
    );
    test('event descriptive replacement gates metadata changes and preserves no-op baseline', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final original = [eventSource('descriptive', extra: wireDescriptive)];
      final id = (await service.importEvents(eventImport(parent, original)))
          .receipts
          .single
          .eventId;
      final changed = [
        eventSource(
          'descriptive',
          extra: [
            ...wireDescriptive.where((s) => !s.startsWith('PRIORITY:')),
            'PRIORITY:4',
          ],
        ),
      ];
      final before = await eventData(id), gen = await generation();
      policy.denied.add(CalendarPermission.updateEventDescriptiveMetadata);
      await expectLater(
        service.replaceEventsFromImport(eventReplacement(parent, id, changed)),
        failure(CalendarFailureCode.accessDenied),
      );
      expect((await eventData(id)).toJson(), before.toJson());
      expect(await generation(), gen);
      policy.denied.clear();
      await service.replaceEventsFromImport(
        eventReplacement(parent, id, changed),
      );
      expect((await service.getEvent(id, eventGroups)).priority, 4);
      final clean = await eventData(id), after = await generation();
      expect(
        (await service.replaceEventsFromImport(
          eventReplacement(parent, id, changed, revision: 2),
        )).receipts.single.changed,
        isFalse,
      );
      expect((await eventData(id)).toJson(), clean.toJson());
      expect(await generation(), after);
      await service.updateEventDescriptiveMetadata(
        CalendarEventDescriptiveRequest(
          eventId: id,
          expectedRevision: 2,
          metadata: descriptive(priority: 2),
        ),
      );
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(parent, id, changed, revision: 3),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
    });
    test('event descriptive replacement gates occurrence pinning and unpinning independently of master values', () async {
      for (final future in [false, true]) {
        final parent = (await service.create(createInput()))!.calendarId;
        List<String> source(bool own) => [
          eventSource(
            'descriptive-presence',
            extra: ['RRULE:FREQ=DAILY;COUNT=3', ...wireDescriptive],
          ),
          eventSource(
            'descriptive-presence',
            timing: 'DTSTART:20260330T100000Z',
            extra: [
              'RECURRENCE-ID${future ? ';RANGE=THISANDFUTURE' : ''}:20260330T090000Z',
              if (own) ...wireDescriptive,
            ],
          ),
        ];
        final id = (await service.importEvents(
          eventImport(parent, source(false)),
        )).receipts.single.eventId;
        final before = await eventData(id), gen = await generation();
        policy.denied.add(CalendarPermission.updateEventDescriptiveMetadata);
        await expectLater(
          service.replaceEventsFromImport(
            eventReplacement(parent, id, source(true)),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await eventData(id)).toJson(), before.toJson());
        expect(await generation(), gen);
        policy.denied.clear();
        await service.replaceEventsFromImport(
          eventReplacement(parent, id, source(true)),
        );
        final pinned = await eventData(id), after = await generation();
        policy.denied.add(CalendarPermission.updateEventDescriptiveMetadata);
        await expectLater(
          service.replaceEventsFromImport(
            eventReplacement(parent, id, source(false), revision: 2),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await eventData(id)).toJson(), pinned.toJson());
        expect(await generation(), after);
        policy.denied.clear();
      }
    });
    const richEventMetadata = [
      'RELATED-TO:SOURCE-RELATED',
      'ATTACH;VALUE=URI;FMTTYPE=application/pdf:urn:source:file',
      'ORGANIZER;CN=Inert source:mailto:source-organizer@example.invalid',
      'ATTENDEE;PARTSTAT=DECLINED;RSVP=TRUE:mailto:source-attendee@example.invalid',
      'URL:https://example.invalid/event',
      'CLASS:PRIVATE',
      'CATEGORIES;LANGUAGE=en:Work,Work',
      'CATEGORIES;LANGUAGE=sv:Arbete',
      'COMMENT;LANGUAGE=sv:Source note',
      'CONTACT;ALTREP="cid:desk@example.invalid":SOURCE-DESK',
      ...richEventSourceAlarms,
    ];
    List<String> richEvent({
      String contact = 'SOURCE-DESK',
      String target = 'SOURCE-RELATED',
      String alarmDescription = 'SOURCE-ALARM-DESCRIPTION',
      bool own = true,
    }) => [
      eventSource(
        'rich',
        extra: [
          'RRULE:FREQ=DAILY;COUNT=3',
          ...richEventMetadata.map(
            (v) => v
                .replaceFirst('SOURCE-DESK', contact)
                .replaceFirst('SOURCE-RELATED', target)
                .replaceFirst('SOURCE-ALARM-DESCRIPTION', alarmDescription),
          ),
        ],
      ),
      if (own)
        eventSource(
          'rich',
          timing: 'DTSTART:20260330T110000Z',
          extra: [
            'RECURRENCE-ID:20260330T090000Z',
            'SEQUENCE:3',
            'CREATED:20260320T000000Z',
            ...richEventMetadata.map(
              (v) => v
                  .replaceFirst('SOURCE-DESK', contact)
                  .replaceFirst('SOURCE-RELATED', target)
                  .replaceFirst('SOURCE-ALARM-DESCRIPTION', alarmDescription),
            ),
          ],
        ),
    ];
    CalendarEventTiming richOriginal() => CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2026, month: 3, day: 30, hour: 9),
    );
    test('event source metadata persists server-only groups while ordinary views stay private', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final e = (await service.importEvents(eventImport(parent, richEvent())))
          .receipts;
      final row = await eventData(e.single.eventId), gen = await generation();
      expect(
        row.protocolState!.sourceMetadata!.contacts.single.value,
        'SOURCE-DESK',
      );
      expect(
        row
            .timingOverrides!
            .singles
            .single
            .sourceMetadata!
            .categoryGroups
            .first
            .values,
        ['Work', 'Work'],
      );
      expect(
        jsonEncode(row.timingOverrides!.toJsonForProtocol()),
        isNot(contains('SOURCE-DESK')),
      );
      final view = await service.getEvent(e.single.eventId, eventGroups);
      expect(view.timingOverrides!.singles.single.sourceMetadata, isNull);
      expect(
        jsonEncode(view.toJsonForProtocol()),
        isNot(contains('SOURCE-DESK')),
      );
      policy.onEventExport = (r) {
        if (r.eventExport == null) return;
        final member = r.eventExport!.members.first;
        expect(
          member.protocolState!.sourceMetadata!.contacts.single.value,
          'SOURCE-DESK',
        );
        expect(
          () => member
              .protocolState!
              .sourceMetadata!
              .categoryGroups
              .first
              .values
              .clear(),
          throwsUnsupportedError,
        );
      };
      final text = exported(await service.exportEvents(eventExport(e)));
      expect('CONTACT'.allMatches(text).length, 2);
      expect('source-attendee@example.invalid'.allMatches(text).length, 2);
      expect(
        row
            .protocolState!
            .sourceMetadata!
            .attendees!
            .single
            .parameters['PARTSTAT'],
        ['DECLINED'],
      );
      expect(row.content.status, CalendarEventStatus.confirmed);
      expect(
        jsonEncode(view.toJsonForProtocol()),
        isNot(contains('source-attendee@example.invalid')),
      );
      expect(text, contains('CLASS:PRIVATE'));
      expect(
        row.protocolState!.sourceMetadata!.relationships!.single.targetUid,
        'SOURCE-RELATED',
      );
      expect(
        row
            .timingOverrides!
            .singles
            .single
            .sourceMetadata!
            .attachments!
            .single
            .explicitUri,
        isTrue,
      );
      expect(
        jsonEncode(view.toJsonForProtocol()),
        isNot(contains('urn:source:file')),
      );
      expect(
        text,
        contains('ATTACH;VALUE=URI;FMTTYPE=application/pdf:urn:source:file'),
      );
      final round = eventStorageProposal(
        parseIcalendarEventCalendar(utf8.encode(text)).series.single,
      );
      expect(
        round.importBaseline.canonicalValue,
        row.importBaseline!.canonicalValue,
      );
      expect(await generation(), gen);
    });
    test(
      'event source participants reject late invalid event states atomically',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final before = await generation();
        await expectLater(
          service.importEvents(
            eventImport(parent, [
              eventSource('participant-good', extra: richEventMetadata),
              eventSource(
                'participant-bad',
                extra: [
                  'ORGANIZER:mailto:org@example.invalid',
                  'ATTENDEE;PARTSTAT=COMPLETED:mailto:worker@example.invalid',
                ],
              ),
            ]),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(
          (await service.listEvents(
            parent,
            pageSize: 20,
            fieldGroups: eventGroups,
          )).events,
          isEmpty,
        );
        expect(await generation(), before);
      },
    );
    test('event source metadata survives native edits without rewriting source history', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importEvents(eventImport(parent, richEvent())))
          .receipts
          .single
          .eventId;
      final before = await eventData(id);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 1,
          content: before.content.copyWith(summary: 'Native title'),
        ),
      );
      final after = await eventData(id);
      expect(
        after.protocolState!.sourceMetadata,
        before.protocolState!.sourceMetadata,
      );
      expect(
        after.timingOverrides!.singles.single.sourceMetadata,
        before.timingOverrides!.singles.single.sourceMetadata,
      );
      expect(
        after.protocolState!.overrides.single.version,
        before.protocolState!.overrides.single.version,
      );
      expect(after.importBaseline, before.importBaseline);
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(
            parent,
            id,
            richEvent(contact: 'Changed'),
            revision: 2,
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
    });
    test('event source metadata-only originals keep inheritance through timing scope transfers', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final receipt = (await service.importEvents(
        eventImport(parent, richEvent()),
      )).receipts.single;
      final id = receipt.eventId, before = await eventData(id);
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: 1,
          originalStart: richOriginal(),
          action: CalendarEventOccurrenceAction.clearSingleTiming,
        ),
      );
      final cleared = await eventData(id);
      expect(cleared.timingOverrides!.singles.single.replacement, isNull);
      expect(
        cleared.timingOverrides!.singles.single.sourceMetadata,
        before.timingOverrides!.singles.single.sourceMetadata,
      );
      final hidden = await service.getEvent(id, eventGroups);
      expect(hidden.timingOverrides, isNull);
      expect(hidden.occurrenceProtocolVersions, isEmpty);
      await expectLater(
        service.exportEvents(eventExport([receipt.copyWith(revision: 2)])),
        failure(CalendarFailureCode.validation),
      );
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: 2,
          originalStart: richOriginal(),
          action: CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: richOriginal().copyWith(
            start: richOriginal().start.copyWith(hour: 10),
          ),
        ),
      );
      final ranged = await eventData(id);
      expect(
        ranged.timingOverrides!.future.single.sourceMetadata,
        before.timingOverrides!.singles.single.sourceMetadata,
      );
      expect(
        ranged.protocolState!.overrides.single.version.created,
        before.protocolState!.overrides.single.version.created,
      );
      final text = exported(
        await service.exportEvents(
          eventExport([receipt.copyWith(revision: 3)]),
        ),
      );
      expect(text, contains('SOURCE-DESK'));
      expect(text, contains('RANGE=THISANDFUTURE'));
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: 3,
          originalStart: richOriginal(),
          action: CalendarEventOccurrenceAction.clearFutureTiming,
        ),
      );
      expect(
        (await eventData(id)).timingOverrides!.singles.single.sourceMetadata,
        isNotNull,
      );
    });
    test('event source metadata replacement changes complete metadata and identical retry stays a no-op', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importEvents(eventImport(parent, richEvent())))
          .receipts
          .single
          .eventId;
      final changed = await service.replaceEventsFromImport(
        eventReplacement(parent, id, richEvent(contact: 'Replaced')),
      );
      expect(changed.receipts.single.changed, isTrue);
      final before = await eventData(id), gen = await generation();
      final same = await service.replaceEventsFromImport(
        eventReplacement(
          parent,
          id,
          richEvent(contact: 'Replaced'),
          revision: 2,
        ),
      );
      expect(same.receipts.single.changed, isFalse);
      expect(await generation(), gen);
      expect((await eventData(id)).toJson(), before.toJson());
      policy.denied.add(CalendarPermission.readEventSource);
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(
            parent,
            id,
            richEvent(contact: 'Replaced'),
            revision: 2,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('event source references preserve parameter-free participant baselines through replacements', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      List<String> input(String target) => [
        eventSource(
          'bare',
          extra: [
            'ORGANIZER:mailto:o@example.invalid',
            'ATTENDEE:mailto:a@example.invalid',
            'RELATED-TO:$target',
          ],
        ),
      ];
      final id = (await service.importEvents(
        eventImport(parent, input('missing')),
      )).receipts.single.eventId;
      expect(
        (await service.replaceEventsFromImport(
          eventReplacement(parent, id, input('missing')),
        )).receipts.single.changed,
        isFalse,
      );
      expect(
        (await service.replaceEventsFromImport(
          eventReplacement(parent, id, input('other-missing')),
        )).receipts.single.changed,
        isTrue,
      );
      expect(
        (await service.replaceEventsFromImport(
          eventReplacement(parent, id, input('other-missing'), revision: 2),
        )).receipts.single.changed,
        isFalse,
      );
    });
    test('event source references replace without resolution and identical source retries are no-ops', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importEvents(eventImport(parent, richEvent())))
          .receipts
          .single
          .eventId;
      final result = await service.replaceEventsFromImport(
        eventReplacement(parent, id, richEvent(target: 'different-unresolved')),
      );
      expect(result.receipts.single.changed, isTrue);
      final before = await eventData(id), gen = await generation();
      expect(
        before.protocolState!.sourceMetadata!.relationships!.single.targetUid,
        'different-unresolved',
      );
      expect(
        (await service.replaceEventsFromImport(
          eventReplacement(
            parent,
            id,
            richEvent(target: 'different-unresolved'),
            revision: 2,
          ),
        )).receipts.single.changed,
        isFalse,
      );
      expect((await eventData(id)).toJson(), before.toJson());
      expect(await generation(), gen);
    });
    test(
      'event source references reject a late inline attachment atomically',
      () async {
        final parent = (await service.create(createInput()))!.calendarId,
            gen = await generation();
        await expectLater(
          service.importEvents(
            eventImport(parent, [
              eventSource('reference-good', extra: richEventMetadata),
              eventSource('reference-bad', extra: ['ATTACH;VALUE=BINARY:AAAA']),
            ]),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(
          (await service.listEvents(
            parent,
            pageSize: 20,
            fieldGroups: eventGroups,
          )).events,
          isEmpty,
        );
        expect(await generation(), gen);
      },
    );
    Future<CalendarAlarmParent> adoptionEvent() async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final event = (await service.importEvents(
        eventImport(calendar, richEvent()),
      )).receipts.single;
      return eventAlarmParent(event.eventId);
    }

    test(
      'alarm adoption copies master timing only into independent unarmed rows',
      () async {
        final parent = await adoptionEvent();
        final before = jsonEncode((await eventData(parent.id)).toJson());
        final gen = await generation();
        policy.eventGrants = {};
        final review = await service.personalAlarmSourceTimings(parent, null);
        expect(review.definitions, hasLength(2));
        expect(
          jsonEncode(review.toJsonForProtocol()),
          isNot(contains('SOURCE-ALARM-DESCRIPTION')),
        );
        final first = (await service.adoptPersonalAlarm(
          parent,
          review.parentRevision,
          0,
          null,
        ))!;
        final second = (await service.adoptPersonalAlarm(
          parent,
          review.parentRevision,
          1,
          null,
        ))!;
        expect(first.definition.relativeDuration!.sign, -1);
        expect(first.definition.relativeDuration!.minutes, 5);
        expect(second.definition.absoluteUtc, DateTime.utc(2026, 3, 29, 8));
        expect(first.armed, isFalse);
        expect(second.armed, isFalse);
        expect(first.id, isNot(second.id));
        expect(await CalendarAlarmPlanRecord.db.count(session), 0);
        expect(await CalendarAlarmFiringRecord.db.count(session), 0);
        expect(await CalendarAlarmActionRecord.db.count(session), 0);
        expect(jsonEncode((await eventData(parent.id)).toJson()), before);
        expect(await generation(), gen);
        expect(policy.lastAlarmAdoption!.alarmSourceIndex, 1);
        expect(policy.lastAlarmAdoption!.currentEvent!.eventId, parent.id);
        expect(policy.lastAlarmAdoption!.proposedAlarmArmed, isFalse);
      },
    );
    for (final permission in [
      CalendarPermission.readEventSource,
      CalendarPermission.adoptPersonalAlarm,
      CalendarPermission.createPersonalAlarm,
    ]) {
      test(
        'alarm adoption requires independent $permission authority',
        () async {
          final parent = await adoptionEvent();
          policy.denied.add(permission);
          await expectLater(
            service.adoptPersonalAlarm(parent, 1, 0, null),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(await CalendarAlarmRecord.db.count(session), 0);
          if (permission == CalendarPermission.readEventSource) {
            await expectLater(
              service.adoptPersonalAlarm(parent, -9, -9, null),
              failure(CalendarFailureCode.accessDenied),
            );
            await expectLater(
              service.personalAlarmSourceTimings(parent, null),
              failure(CalendarFailureCode.accessDenied),
            );
          }
        },
      );
    }
    test('alarm adoption rejects stale source revision invalid index and final denial atomically', () async {
      final parent = await adoptionEvent();
      await expectLater(
        service.adoptPersonalAlarm(parent, 2, 0, null),
        failure(CalendarFailureCode.staleRevision),
      );
      for (final index in [-1, 2]) {
        await expectLater(
          service.adoptPersonalAlarm(parent, 1, index, null),
          failure(CalendarFailureCode.validation),
        );
      }
      policy.denyFinal = true;
      await expectLater(
        service.adoptPersonalAlarm(parent, 1, 0, null),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarAlarmRecord.db.count(session), 0);
    });
    test('alarm adoption final recipient changes cannot create a copy for the earlier recipient', () async {
      final parent = await adoptionEvent();
      var changed = false;
      policy.onFinal = () => changed = true;
      policy.alarmRecipientOverride = (_) =>
          CalendarAlarmRecipient('demo', changed ? 'bob' : 'alice');
      await expectLater(
        service.adoptPersonalAlarm(parent, 1, 0, null),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await CalendarAlarmRecord.db.count(session), 0);
    });
    test('alarm adoption task DATE timing requires explicit zone and retains source state', () async {
      final task = await storedSourceTask(alarm: true);
      final parent = CalendarAlarmParent(
        kind: CalendarAlarmParentKind.task,
        id: task.taskId,
      );
      final before = jsonEncode(
        (await CalendarTaskDataRecord.db.findFirstRow(session))!.toJson(),
      );
      await expectLater(
        service.adoptPersonalAlarm(parent, 1, 0, null),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.adoptPersonalAlarm(parent, 1, 0, 'europe/stockholm'),
        failure(CalendarFailureCode.validation),
      );
      final adopted = (await service.adoptPersonalAlarm(
        parent,
        1,
        0,
        'Europe/Stockholm',
      ))!;
      expect(adopted.definition.dateZoneId, 'Europe/Stockholm');
      expect(adopted.armed, isFalse);
      expect(
        jsonEncode(
          (await CalendarTaskDataRecord.db.findFirstRow(session))!.toJson(),
        ),
        before,
      );
      policy.denied.add(CalendarPermission.readTaskSource);
      await expectLater(
        service.personalAlarmSourceTimings(parent, null),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('alarm adoption preserves hidden receipts and the existing per-recipient cap', () async {
      final parent = await adoptionEvent();
      policy.hideAlarmReceipt = true;
      expect(await service.adoptPersonalAlarm(parent, 1, 0, null), isNull);
      for (var i = 1; i < 16; i++) {
        await service.adoptPersonalAlarm(parent, 1, 0, null);
      }
      await expectLater(
        service.adoptPersonalAlarm(parent, 1, 0, null),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect((await service.listPersonalAlarms(parent)), hasLength(16));
      policy.scopeOverride = 'foreign';
      await expectLater(
        service.adoptPersonalAlarm(parent, 1, 0, null),
        failure(CalendarFailureCode.accessDenied),
      );
    });

    test(
      'alarm adoption preserves END calendar units and paired repeat units',
      () async {
        final calendar = (await service.create(createInput()))!.calendarId;
        final event = (await service.importEvents(
          eventImport(calendar, [
            eventSource(
              'unit-alarm',
              timing: 'DTSTART:20260329T090000Z\r\nDTEND:20260329T100000Z',
              extra: [
                'BEGIN:VALARM',
                'ACTION:DISPLAY',
                'DESCRIPTION:Source only',
                'TRIGGER;RELATED=END:-P1D',
                'REPEAT:2',
                'DURATION:PT1H',
                'END:VALARM',
              ],
            ),
          ]),
        )).receipts.single;
        final adopted = (await service.adoptPersonalAlarm(
          eventAlarmParent(event.eventId),
          1,
          0,
          null,
        ))!;
        expect(adopted.definition.anchor, CalendarAlarmAnchor.end);
        expect(adopted.definition.relativeDuration!.sign, -1);
        expect(adopted.definition.relativeDuration!.days, 1);
        expect(adopted.definition.relativeDuration!.hours, 0);
        expect(adopted.definition.repeat, 2);
        expect(adopted.definition.repeatInterval!.hours, 1);
      },
    );

    test('alarm adoption keeps copies private for recipients sharing the same host scope', () async {
      policy.scopeOverride = 'shared-source-adoption';
      final parent = await adoptionEvent();
      final alice = (await service.adoptPersonalAlarm(parent, 1, 0, null))!;
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      final bobService = CalendarModule.service(bobSession);
      final bob = (await bobService.adoptPersonalAlarm(parent, 1, 0, null))!;
      expect(bob.id, isNot(alice.id));
      expect((await service.listPersonalAlarms(parent)).single.id, alice.id);
      expect((await bobService.listPersonalAlarms(parent)).single.id, bob.id);
    });

    test('event source alarms persist privately and source replacements remain unarmed no-ops on retry', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final receipt = (await service.importEvents(
        eventImport(parent, richEvent()),
      )).receipts.single;
      final row = await eventData(receipt.eventId);
      expect(
        row.protocolState!.sourceMetadata!.alarms!.first.uid,
        'event-source-alarm',
      );
      expect(
        row
            .timingOverrides!
            .singles
            .single
            .sourceMetadata!
            .alarms!
            .last
            .snoozeTargetUid,
        'event-source-alarm',
      );
      final view = await service.getEvent(receipt.eventId, eventGroups);
      expect(
        jsonEncode(view.toJsonForProtocol()),
        isNot(contains('SOURCE-ALARM-DESCRIPTION')),
      );
      final file = await service.exportEvents(eventExport([receipt]));
      final source = parseIcalendarEventCalendar(utf8.encode(exported(file)))
          .series
          .single;
      expect(source.master.alarms.length, 2);
      expect(source.overrides.single.alarms.last.isSnooze, isTrue);
      final changed = await service.replaceEventsFromImport(
        eventReplacement(
          parent,
          receipt.eventId,
          richEvent(alarmDescription: 'Changed source alarm'),
        ),
      );
      expect(changed.receipts.single.changed, isTrue);
      final before = await eventData(receipt.eventId), gen = await generation();
      expect(
        (await service.replaceEventsFromImport(
          eventReplacement(
            parent,
            receipt.eventId,
            richEvent(alarmDescription: 'Changed source alarm'),
            revision: 2,
          ),
        )).receipts.single.changed,
        isFalse,
      );
      expect((await eventData(receipt.eventId)).toJson(), before.toJson());
      expect(await generation(), gen);
    });
    test('event source END alarm anchors reject incompatible native master single and future timing atomically', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importEvents(
        eventImport(parent, [
          eventSource(
            'end-alarm',
            extra: [
              'DURATION:PT1H',
              'RRULE:FREQ=DAILY;COUNT=3',
              'BEGIN:VALARM',
              'ACTION:DISPLAY',
              'DESCRIPTION:END source',
              'TRIGGER;RELATED=END:-PT5M',
              'END:VALARM',
            ],
          ),
        ]),
      )).receipts.single.eventId;
      final before = await eventData(id), gen = await generation();
      await expectLater(
        service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: id,
            expectedRevision: 1,
            content: before.content.copyWith(
              timing: before.content.timing.copyWith(duration: null),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      for (final action in [
        CalendarEventOccurrenceAction.replaceSingleTiming,
        CalendarEventOccurrenceAction.replaceFutureTiming,
      ]) {
        await expectLater(
          service.changeOccurrence(
            CalendarEventOccurrenceChange(
              eventId: id,
              expectedRevision: 1,
              originalStart: richOriginal(),
              action: action,
              replacement: richOriginal(),
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
      }
      expect((await eventData(id)).toJson(), before.toJson());
      expect(await generation(), gen);
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: 1,
          originalStart: richOriginal(),
          action: CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: richOriginal().copyWith(
            duration: CalendarEventDuration(hours: 2),
          ),
        ),
      );
      expect(
        (await eventData(id))
            .protocolState!
            .sourceMetadata!
            .alarms!
            .single
            .related,
        'END',
      );
    });
    test('event source alarms reject late unsupported actions without partial imports', () async {
      final parent = (await service.create(createInput()))!.calendarId,
          gen = await generation();
      await expectLater(
        service.importEvents(
          eventImport(parent, [
            eventSource('alarm-good', extra: richEventMetadata),
            eventSource(
              'alarm-bad',
              extra: [
                'BEGIN:VALARM',
                'ACTION:AUDIO',
                'DESCRIPTION:Unsupported',
                'TRIGGER:-PT5M',
                'END:VALARM',
              ],
            ),
          ]),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await service.listEvents(
          parent,
          pageSize: 20,
          fieldGroups: eventGroups,
        )).events,
        isEmpty,
      );
      expect(await generation(), gen);
    });
    test('event source metadata export rechecks independent source authority after serialization', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final e = (await service.importEvents(eventImport(parent, richEvent())))
          .receipts;
      var checks = 0;
      policy.onEventExport = (r) {
        if (r.eventId == null && ++checks == 2) {
          policy.denied.add(CalendarPermission.readEventSource);
        }
      };
      final gen = await generation();
      await expectLater(
        service.exportEvents(eventExport(e)),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(checks, 2);
      expect(await generation(), gen);
    });
    test('event source metadata replacement final source-read denial rolls back batch', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importEvents(eventImport(parent, richEvent())))
          .receipts
          .single
          .eventId;
      final before = await eventData(id), gen = await generation();
      policy.onFinal = () =>
          policy.denied.add(CalendarPermission.readEventSource);
      await expectLater(
        service.replaceEventsFromImport(
          eventReplacement(parent, id, richEvent(contact: 'Denied')),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect((await eventData(id)).toJson(), before.toJson());
      expect(await generation(), gen);
    });
    test('event source metadata late malformed input and aggregate budget reject without partial imports', () async {
      final parent = (await service.create(createInput()))!.calendarId,
          gen = await generation();
      await expectLater(
        service.importEvents(
          eventImport(parent, [
            eventSource('good', extra: richEventMetadata),
            eventSource('bad', extra: ['URL:ftp://example.invalid/event']),
          ]),
        ),
        failure(CalendarFailureCode.validation),
      );
      final big = List.filled(4096, 'x').join();
      await expectLater(
        service.importEvents(
          eventImport(parent, [
            eventSource(
              'oversized',
              extra: [for (var i = 0; i < 17; i++) 'COMMENT:$big'],
            ),
          ]),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarEventDataRecord.db.count(session), 0);
      expect(await generation(), gen);
    });
    test('event source metadata deletion scrubs active source and private baseline', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.importEvents(eventImport(parent, richEvent())))
          .receipts
          .single
          .eventId;
      await service.deleteEvent(id, 1);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      final marker = (await CalendarEventRecord.db.findById(session, id))!;
      expect(jsonEncode(marker.toJson()), isNot(contains('SOURCE-DESK')));
      expect(marker.deletedAt, isNotNull);
    });

    CalendarTaskExportRequest taskExport(
      List<CalendarTaskReceipt> tasks, {
      UuidValue? parent,
      int parentRevision = 1,
    }) => CalendarTaskExportRequest(
      calendarId: parent ?? tasks.first.calendarId,
      expectedRevision: parentRevision,
      selection: [
        for (final t in tasks)
          CalendarTaskExportSelection(
            taskId: t.taskId,
            expectedRevision: t.revision,
          ),
      ],
    );
    CalendarTaskOccurrenceTimingRequest taskTiming(
      CalendarTaskReceipt t,
      CalendarEventTiming original,
      CalendarTaskTiming? replacement, [
      int? revision,
    ]) => CalendarTaskOccurrenceTimingRequest(
      taskId: t.taskId,
      expectedRevision: revision ?? t.revision,
      originalStart: original,
      replacement: replacement,
    );
    CalendarTaskTiming movedTask([int day = 31]) => CalendarTaskTiming(
      kind: CalendarTaskTimeKind.date,
      start: CalendarEventCivil(year: 2026, month: 3, day: day),
    );
    CalendarTaskOccurrenceContentChange contentChange(
      CalendarTaskContentField field,
      CalendarTaskContentAction action, {
      String? text,
      int? priority,
    }) => CalendarTaskOccurrenceContentChange(
      field: field,
      action: action,
      text: text,
      priority: priority,
    );
    CalendarTaskOccurrenceContentRequest taskContentRequest(
      CalendarTaskReceipt t,
      CalendarEventTiming original,
      int revision,
      List<CalendarTaskOccurrenceContentChange> changes,
    ) => CalendarTaskOccurrenceContentRequest(
      taskId: t.taskId,
      expectedRevision: revision,
      originalStart: original,
      changes: changes,
    );
    CalendarTaskOccurrenceQuery contentPreview(
      CalendarTaskReceipt t,
      int revision,
    ) => taskPreview(t, revision).copyWith(
      fieldGroups: [
        CalendarTaskFieldGroup.summary,
        CalendarTaskFieldGroup.description,
        CalendarTaskFieldGroup.location,
        CalendarTaskFieldGroup.priority,
      ],
    );

    test('task content new source component captures sparse progress and rejects orphaning pattern edits', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final t = (await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar(
            importedTask(
              'content-capture',
              properties: [
                'RRULE:FREQ=DAILY;COUNT=3',
                'SUMMARY;LANGUAGE=sv:Hej',
                'PERCENT-COMPLETE:37',
              ],
            ),
          ),
        ),
      )).receipts.single;
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences[1]
          .originalStart;
      final data = (await CalendarTaskDataRecord.db.find(session)).single;
      await service.changeTaskOccurrenceContent(
        taskContentRequest(t, original, 1, [
          contentChange(
            CalendarTaskContentField.summary,
            CalendarTaskContentAction.setValue,
            text: 'Own',
          ),
        ]),
      );
      final row = (await CalendarTaskOccurrenceRecord.db.find(session)).single;
      expect(row.progress.status, isNull);
      expect(row.progress.percentComplete, 37);
      expect(await CalendarTaskHistoryRecord.db.find(session), isEmpty);
      final after = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(after.importBaseline, data.importBaseline);
      expect(after.protocolVersion, data.protocolVersion);
      expect(
        after.sourceState!.occurrences.single.textParameters!.summary!.language,
        'sv',
      );
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: t.taskId,
            expectedRevision: 2,
            content: data.content.copyWith(
              recurrence: CalendarEventRecurrence(
                rule: daily(count: 1),
                inclusions: [],
                exclusions: [],
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await CalendarTaskDataRecord.db.updateRow(
        session,
        after.copyWith(
          importBaseline: after.importBaseline!.copyWith(
            profile: after.importBaseline!.profile.replaceFirst('v3/', 'v2/'),
          ),
        ),
      );
      await expectLater(
        service.changeTaskOccurrenceContent(
          taskContentRequest(t, original, 2, [
            contentChange(
              CalendarTaskContentField.summary,
              CalendarTaskContentAction.clearValue,
            ),
          ]),
        ),
        failure(CalendarFailureCode.unavailable),
      );
      expect(
        (await CalendarTaskOccurrenceRecord.db.find(session))
            .single
            .contentOverrides!
            .summary,
        'Own',
      );
    });

    test('task content selected fields follow or pin series independently and preserve completion history', () async {
      final t = await recurringTask();
      var data = (await CalendarTaskDataRecord.db.find(session)).single;
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: t.taskId,
          expectedRevision: 1,
          content: data.content.copyWith(
            summary: 'Series',
            location: 'Room',
            priority: 3,
          ),
        ),
      );
      final original = (await service.previewTaskOccurrences(taskPreview(t, 2)))
          .occurrences
          .first
          .originalStart;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, original, 2, CalendarTaskProgressAction.complete),
      );
      final history = (await CalendarTaskHistoryRecord.db.find(session)).single
          .toJson();
      await service.changeTaskOccurrenceContent(
        taskContentRequest(t, original, 3, [
          contentChange(
            CalendarTaskContentField.summary,
            CalendarTaskContentAction.setValue,
            text: 'Series',
          ),
        ]),
      );
      data = (await CalendarTaskDataRecord.db.find(session)).single;
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: t.taskId,
          expectedRevision: 4,
          content: data.content.copyWith(
            summary: 'New series',
            location: 'New room',
          ),
        ),
      );
      var preview = (await service.previewTaskOccurrences(contentPreview(t, 5)))
          .occurrences;
      expect(preview.map((o) => o.content!.summary), [
        'Series',
        'New series',
        'New series',
      ]);
      expect(preview.first.content!.location, 'New room');
      expect(preview.first.progress.status, CalendarTaskStatus.completed);
      await service.changeTaskOccurrenceContent(
        taskContentRequest(t, original, 5, [
          contentChange(
            CalendarTaskContentField.summary,
            CalendarTaskContentAction.clearValue,
          ),
        ]),
      );
      expect(
        (await service.previewTaskOccurrences(contentPreview(t, 6)))
            .occurrences
            .first
            .content!
            .summary,
        '',
      );
      await service.changeTaskOccurrenceContent(
        taskContentRequest(t, original, 6, [
          contentChange(
            CalendarTaskContentField.summary,
            CalendarTaskContentAction.inheritSeries,
          ),
        ]),
      );
      preview = (await service.previewTaskOccurrences(contentPreview(t, 7)))
          .occurrences;
      expect(preview.first.content!.summary, 'New series');
      expect(preview.first.contentOverrides, isNull);
      expect(
        (await CalendarTaskHistoryRecord.db.find(session)).single.toJson(),
        history,
      );
      final row = (await CalendarTaskOccurrenceRecord.db.find(session)).single;
      await service.changeTaskOccurrenceContent(
        taskContentRequest(t, original, 7, [
          contentChange(
            CalendarTaskContentField.summary,
            CalendarTaskContentAction.inheritSeries,
          ),
        ]),
      );
      expect(
        (await CalendarTaskOccurrenceRecord.db.find(session))
            .single
            .protocolVersion,
        row.protocolVersion,
      );
    });

    test('task content default and selected preview disclosure hides other values and override presence', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      await service.changeTaskOccurrenceContent(
        taskContentRequest(t, original, 1, [
          contentChange(
            CalendarTaskContentField.location,
            CalendarTaskContentAction.setValue,
            text: 'Private room',
          ),
        ]),
      );
      final ordinary = await service.previewTaskOccurrences(taskPreview(t, 2));
      expect(ordinary.occurrences.map((o) => o.content), everyElement(isNull));
      expect(
        ordinary.occurrences.map((o) => o.contentOverrides),
        everyElement(isNull),
      );
      policy.taskGrants = {
        CalendarTaskFieldGroup.timing,
        CalendarTaskFieldGroup.progress,
        CalendarTaskFieldGroup.summary,
      };
      final query = taskPreview(
        t,
        2,
      ).copyWith(fieldGroups: [CalendarTaskFieldGroup.summary]);
      final visible = await service.previewTaskOccurrences(query);
      expect(visible.disclosedGroups.toSet(), {
        CalendarTaskFieldGroup.timing,
        CalendarTaskFieldGroup.progress,
        CalendarTaskFieldGroup.summary,
      });
      expect(visible.occurrences.first.contentOverrides, isNull);
      await expectLater(
        service.previewTaskOccurrences(
          query.copyWith(fieldGroups: [CalendarTaskFieldGroup.location]),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.previewTaskOccurrences(
          query.copyWith(fieldGroups: [CalendarTaskFieldGroup.assignments]),
        ),
        failure(CalendarFailureCode.validation),
      );
    });

    test('task content independent authority immutable final context stale denial and late rollback', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      final changes = [
        contentChange(
          CalendarTaskContentField.summary,
          CalendarTaskContentAction.setValue,
          text: 'Own',
        ),
      ];
      await expectLater(
        service.changeTaskOccurrenceContent(
          taskContentRequest(t, original, 2, changes),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      policy.denied.add(CalendarPermission.updateTask);
      await expectLater(
        service.changeTaskOccurrenceContent(
          taskContentRequest(t, original, 1, changes),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.denyFinal = true;
      await expectLater(
        service.changeTaskOccurrenceContent(
          taskContentRequest(t, original, 1, changes),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      policy.denied.addAll([
        CalendarPermission.changeTaskProgress,
        CalendarPermission.changeTaskAssignments,
        CalendarPermission.readTask,
      ]);
      policy.onFinal = () {
        final q = policy.lastTaskRequest!;
        expect(q.calendarId, t.calendarId);
        expect(q.taskOccurrenceContentChange!.originalStart, original);
        expect(q.proposedTaskOccurrence!.content!.summary, 'Own');
        expect(q.proposedTaskOccurrenceVersion!.sequence, 0);
        expect(
          () => q.taskOccurrenceContentChange!.changes.clear(),
          throwsUnsupportedError,
        );
        expect(() => q.recordedTaskOccurrences.clear(), throwsUnsupportedError);
      };
      final scope = (await CalendarScopeRecord.db.find(session)).single;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.changeTaskOccurrenceContent(
          taskContentRequest(t, original, 1, changes),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarTaskOccurrenceRecord.db.find(session), isEmpty);
      expect(
        (await CalendarTaskRecord.db.findById(session, t.taskId))!.revision,
        1,
      );
    });

    test('task content source range stays anchor local retains annotations and captures no history', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final t = (await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar([
            ...importedTask(
              'content',
              properties: [
                'RRULE:FREQ=DAILY;COUNT=3',
                'SUMMARY;LANGUAGE=sv:Hej',
                'PRIORITY:3',
                'PERCENT-COMPLETE:37',
              ],
            ),
            ...importedTask(
              'content',
              timing: ['DTSTART;VALUE=DATE:20260329'],
              properties: [
                'RECURRENCE-ID;VALUE=DATE;RANGE=THISANDFUTURE:20260328',
                'SUMMARY;LANGUAGE=en:Own',
                'PRIORITY:0',
              ],
            ),
          ]),
        ),
      )).receipts.single;
      var preview = (await service.previewTaskOccurrences(contentPreview(t, 1)))
          .occurrences;
      final original = preview.first.originalStart;
      expect(preview.map((o) => o.content!.summary), ['Own', 'Hej', 'Hej']);
      expect(preview.map((o) => o.content!.priority), [0, 3, 3]);
      final baseline = (await CalendarTaskDataRecord.db.find(session))
          .single
          .importBaseline;
      await service.changeTaskOccurrenceContent(
        taskContentRequest(t, original, 1, [
          contentChange(
            CalendarTaskContentField.summary,
            CalendarTaskContentAction.setValue,
            text: 'Edited',
          ),
        ]),
      );
      var data = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(
        data.sourceState!.occurrences.single.textParameters!.summary!.language,
        'en',
      );
      await service.changeTaskOccurrenceContent(
        taskContentRequest(t, original, 2, [
          contentChange(
            CalendarTaskContentField.summary,
            CalendarTaskContentAction.clearValue,
          ),
        ]),
      );
      data = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(
        data.sourceState!.occurrences.single.textParameters!.summary,
        isNull,
      );
      await service.changeTaskOccurrenceContent(
        taskContentRequest(t, original, 3, [
          contentChange(
            CalendarTaskContentField.summary,
            CalendarTaskContentAction.inheritSeries,
          ),
        ]),
      );
      data = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(data.importBaseline, baseline);
      expect(data.sourceState!.occurrences.single.thisAndFuture, isTrue);
      expect(data.sourceState!.occurrences.single.content.summary, isNull);
      expect(await CalendarTaskHistoryRecord.db.find(session), isEmpty);
      final bytes = await service.exportTasks(
        taskExport([t.copyWith(revision: 4)]),
      );
      final other = (await service.create(createInput()))!.calendarId;
      final copy = (await service.importTasks(
        CalendarTaskImportRequest(
          calendarId: other,
          expectedRevision: 1,
          bytes: bytes,
        ),
      )).receipts.single;
      preview = (await service.previewTaskOccurrences(contentPreview(copy, 1)))
          .occurrences;
      expect(preview.map((o) => o.content!.summary), ['Hej', 'Hej', 'Hej']);
      expect(preview.map((o) => o.content!.priority), [0, 3, 3]);
    });
    CalendarTaskOccurrenceTimingRequest taskFuture(
      CalendarTaskReceipt t,
      CalendarEventTiming original,
      CalendarTaskTiming? replacement, [
      int? revision,
    ]) => taskTiming(
      t,
      original,
      replacement,
      revision,
    ).copyWith(thisAndFuture: true);

    for (final kind in [CalendarTaskTimeKind.utc, CalendarTaskTimeKind.zoned]) {
      test(
        'task future ${kind.name} persists nominal deadlines across DST and export',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final timing = CalendarTaskTiming(
            kind: kind,
            zoneId: kind == CalendarTaskTimeKind.zoned
                ? 'Europe/Stockholm'
                : null,
            start: CalendarEventCivil(year: 2026, month: 3, day: 27, hour: 9),
            duration: CalendarEventDuration(days: 1),
          );
          final t = (await service.createTask(
            CalendarTaskCreateRequest(
              calendarId: parent,
              content: CalendarTaskContent(
                timing: timing,
                recurrence: CalendarEventRecurrence(
                  rule: daily(),
                  inclusions: [],
                  exclusions: [],
                ),
              ),
              assignees: [],
            ),
          ))!;
          CalendarTaskOccurrenceQuery query(int rev) =>
              CalendarTaskOccurrenceQuery(
                taskId: t.taskId,
                expectedRevision: rev,
                fromUtc: DateTime.utc(2026, 3, 27),
                untilUtc: DateTime.utc(2026, 4, 1),
              );
          final original = (await service.previewTaskOccurrences(query(1)))
              .occurrences
              .first
              .originalStart;
          await service.changeTaskOccurrenceTiming(
            taskFuture(
              t,
              original,
              timing.copyWith(
                start: CalendarEventCivil(
                  year: 2026,
                  month: 3,
                  day: 28,
                  hour: 9,
                ),
              ),
            ),
          );
          final values = (await service.previewTaskOccurrences(query(2)))
              .occurrences;
          expect(values.map((o) => o.actualStart!.start.day), [28, 29, 30]);
          expect(
            values.first.dueUtc!.difference(values.first.startUtc!).inHours,
            kind == CalendarTaskTimeKind.zoned ? 23 : 24,
          );
          expect(values.map((o) => o.duration!.days), [1, 1, 1]);
          final bytes = await service.exportTasks(
            taskExport([t.copyWith(revision: 2)]),
          );
          final other = (await service.create(createInput()))!.calendarId;
          final copy = (await service.importTasks(
            CalendarTaskImportRequest(
              calendarId: other,
              expectedRevision: 1,
              bytes: bytes,
            ),
          )).receipts.single;
          final again = (await service.previewTaskOccurrences(
            query(1).copyWith(taskId: copy.taskId),
          )).occurrences;
          expect(again.map((o) => o.startUtc), values.map((o) => o.startUtc));
          expect(again.map((o) => o.dueUtc), values.map((o) => o.dueUtc));
          expect(again.first.futureTiming, values.first.futureTiming);
        },
      );
    }

    test('task future captures source master progress and rejects lost END alarm anchors', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final t = (await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar(
            importedTask(
              'future-capture',
              properties: ['RRULE:FREQ=DAILY;COUNT=3', 'PERCENT-COMPLETE:37'],
            ),
          ),
        ),
      )).receipts.single;
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      final baseline = (await CalendarTaskDataRecord.db.find(session))
          .single
          .importBaseline;
      policy.denied.addAll([
        CalendarPermission.changeTaskProgress,
        CalendarPermission.changeTaskAssignments,
      ]);
      await service.changeTaskOccurrenceTiming(
        taskFuture(t, original, movedTask(29)),
      );
      policy.denied.clear();
      final data = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(data.importBaseline, baseline);
      expect(data.sourceState!.occurrences.single.thisAndFuture, isTrue);
      expect(data.sourceState!.occurrences.single.progress.percentComplete, 37);
      expect(await CalendarTaskHistoryRecord.db.find(session), isEmpty);
      final alarmTask = (await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar(
            importedTask(
              'future-alarm',
              properties: [
                'RRULE:FREQ=DAILY;COUNT=3',
                'DURATION:P1D',
                'BEGIN:VALARM',
                'ACTION:DISPLAY',
                'DESCRIPTION:Due',
                'TRIGGER;RELATED=END:-PT5M',
                'END:VALARM',
              ],
            ),
          ),
        ),
      )).receipts.single;
      final alarmOriginal = (await service.previewTaskOccurrences(
        taskPreview(alarmTask),
      )).occurrences.first.originalStart;
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskFuture(alarmTask, alarmOriginal, movedTask()),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarTaskOccurrenceRecord.db.count(session), 1);
    });

    test('task future absolute ranges preserve completed history and independent singles', () async {
      final t = await recurringTask();
      final originals = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .map((o) => o.originalStart)
          .toList();
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(
          t,
          originals[0],
          1,
          CalendarTaskProgressAction.complete,
        ),
      );
      final history = (await CalendarTaskHistoryRecord.db.find(session)).single
          .toJson();
      final master = (await CalendarTaskDataRecord.db.find(session))
          .single
          .protocolVersion;
      await service.changeTaskOccurrenceTiming(
        taskFuture(t, originals[0], movedTask(29), 2),
      );
      var preview = (await service.previewTaskOccurrences(taskPreview(t, 3)))
          .occurrences;
      expect(preview.map((o) => o.actualStart!.start.day), [29, 30, 31]);
      expect(preview.first.progress.status, CalendarTaskStatus.completed);
      expect(preview.skip(1).map((o) => o.progress.percentComplete), [0, 0]);
      expect(preview.map((o) => o.dueDate), everyElement(isNull));
      await service.changeTaskOccurrenceTiming(
        taskTiming(t, originals[1], movedTask(28), 3),
      );
      await service.changeTaskOccurrenceTiming(
        taskFuture(t, originals[2], movedTask(29), 4),
      );
      preview = (await service.previewTaskOccurrences(taskPreview(t, 5)))
          .occurrences;
      expect(preview.map((o) => o.originalStart), [
        originals[1],
        originals[0],
        originals[2],
      ]);
      expect(preview.map((o) => o.actualStart!.start.day), [28, 29, 29]);
      final anchor = (await CalendarTaskOccurrenceRecord.db.find(session))
          .singleWhere((r) => r.originalStart == originals[2]);
      await service.changeTaskOccurrenceTiming(
        taskFuture(t, originals[2], movedTask(29), 5),
      );
      expect(
        (await CalendarTaskOccurrenceRecord.db.find(session))
            .singleWhere((r) => r.originalStart == originals[2])
            .protocolVersion,
        anchor.protocolVersion,
      );
      policy.onFinal = () {
        final q = policy.lastTaskRequest!;
        expect(q.taskOccurrenceTimingChange!.thisAndFuture, isTrue);
        expect(q.currentTaskOccurrence!.actualStart!.start.day, 29);
        expect(q.proposedTaskOccurrence!.actualStart!.start.day, 31);
        expect(q.proposedTaskOccurrence!.futureTiming, isNull);
        expect(() => q.recordedTaskOccurrences.clear(), throwsUnsupportedError);
      };
      await service.changeTaskOccurrenceTiming(
        taskFuture(t, originals[2], null, 6),
      );
      policy.onFinal = null;
      expect(
        (await service.previewTaskOccurrences(taskPreview(t, 7)))
            .occurrences
            .last
            .actualStart!
            .start
            .day,
        31,
      );
      expect(
        (await CalendarTaskHistoryRecord.db.find(session)).single.toJson(),
        history,
      );
      expect(
        (await CalendarTaskDataRecord.db.find(session)).single.protocolVersion,
        master,
      );
    });

    test('task future scope collisions and orphaning pattern edits reject atomically', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences[1]
          .originalStart;
      await service.changeTaskOccurrenceTiming(
        taskFuture(t, original, movedTask(30)),
      );
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskTiming(t, original, movedTask(), 2),
        ),
        failure(CalendarFailureCode.validation),
      );
      final data = (await CalendarTaskDataRecord.db.find(session)).single;
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: t.taskId,
            expectedRevision: 2,
            content: data.content.copyWith(
              recurrence: CalendarEventRecurrence(
                rule: daily(count: 1),
                inclusions: [],
                exclusions: [],
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await service.changeTaskOccurrenceTiming(
        taskFuture(t, original, null, 2),
      );
      await service.changeTaskOccurrenceTiming(
        taskTiming(t, original, movedTask(), 3),
      );
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskFuture(t, original, movedTask(30), 4),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await CalendarTaskOccurrenceRecord.db.find(session))
            .single
            .replacementTiming,
        movedTask(),
      );
    });

    test('task future authorization stale final denial and late rollback retain storage', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskFuture(t, original, movedTask(), 2),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      policy.denied.add(CalendarPermission.updateTask);
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskFuture(t, original, movedTask()),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.denyFinal = true;
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskFuture(t, original, movedTask()),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      final scope = (await CalendarScopeRecord.db.find(session)).single;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskFuture(t, original, movedTask()),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarTaskOccurrenceRecord.db.find(session), isEmpty);
      expect(
        (await CalendarTaskRecord.db.findById(session, t.taskId))!.revision,
        1,
      );
    });

    test('task future imports anchor progress only and round trips ranges with source baseline', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final t = (await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar([
            ...importedTask(
              'future',
              properties: [
                'RRULE:FREQ=DAILY;COUNT=4',
                'DURATION:P1D',
                'PERCENT-COMPLETE:37',
              ],
            ),
            ...importedTask(
              'future',
              timing: ['DTSTART;VALUE=DATE:20260402'],
              properties: [
                'RECURRENCE-ID;VALUE=DATE;RANGE=THISANDFUTURE:20260329',
                'STATUS:COMPLETED',
                'PERCENT-COMPLETE:100',
              ],
            ),
            ...importedTask(
              'future',
              timing: [],
              properties: [
                'RECURRENCE-ID;VALUE=DATE:20260330',
                'PERCENT-COMPLETE:12',
              ],
            ),
          ]),
        ),
      )).receipts.single;
      CalendarTaskOccurrenceQuery query(int rev) =>
          taskPreview(t, rev).copyWith(
            fromDate: CalendarEventCivil(year: 2026, month: 4, day: 1),
            untilDate: CalendarEventCivil(year: 2026, month: 4, day: 5),
          );
      var preview = (await service.previewTaskOccurrences(query(1)))
          .occurrences;
      expect(preview.map((o) => o.actualStart!.start.day), [2, 3, 4]);
      expect(preview.map((o) => o.progress.percentComplete), [100, 12, 37]);
      expect(preview.map((o) => o.progress.status), [
        CalendarTaskStatus.completed,
        null,
        null,
      ]);
      expect(preview.map((o) => o.dueDate), everyElement(isNull));
      final data = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(data.sourceState!.occurrences.first.thisAndFuture, isTrue);
      expect(await CalendarTaskHistoryRecord.db.find(session), isEmpty);
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(
          t,
          preview.first.originalStart,
          1,
          CalendarTaskProgressAction.reopen,
        ),
      );
      preview = (await service.previewTaskOccurrences(query(2))).occurrences;
      expect(preview.map((o) => o.progress.percentComplete), [0, 12, 37]);
      expect(
        (await CalendarTaskDataRecord.db.find(session)).single.importBaseline,
        data.importBaseline,
      );
      final bytes = await service.exportTasks(
        taskExport([t.copyWith(revision: 2)]),
      );
      expect(exported(bytes), contains('RANGE=THISANDFUTURE'));
      final other = (await service.create(createInput()))!.calendarId;
      final copy = (await service.importTasks(
        CalendarTaskImportRequest(
          calendarId: other,
          expectedRevision: 1,
          bytes: bytes,
        ),
      )).receipts.single;
      final again = (await service.previewTaskOccurrences(
        query(1).copyWith(taskId: copy.taskId),
      )).occurrences;
      expect(
        again.map((o) => o.actualStart),
        preview.map((o) => o.actualStart),
      );
      expect(again.map((o) => o.progress), preview.map((o) => o.progress));
    });

    test(
      'task future DATE preview permits only the explicit 2100 query boundary',
      () async {
        final t = await recurringTask();
        final original = (await service.previewTaskOccurrences(taskPreview(t)))
            .occurrences
            .first
            .originalStart;
        await service.changeTaskOccurrenceTiming(
          taskFuture(
            t,
            original,
            CalendarTaskTiming(
              kind: CalendarTaskTimeKind.date,
              start: CalendarEventCivil(year: 2099, month: 12, day: 31),
            ),
          ),
        );
        final q = taskPreview(t, 2).copyWith(
          fromDate: CalendarEventCivil(year: 2099, month: 12, day: 31),
          untilDate: CalendarEventCivil(year: 2100, month: 1, day: 1),
        );
        expect(
          (await service.previewTaskOccurrences(q))
              .occurrences
              .single
              .originalStart,
          original,
        );
      },
    );
    for (final kind in [CalendarTaskTimeKind.utc, CalendarTaskTimeKind.zoned]) {
      test(
        'task timing ${kind.name} persists DST gap replacements and wire versions',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final timing = CalendarTaskTiming(
            kind: kind,
            zoneId: kind == CalendarTaskTimeKind.zoned
                ? 'Europe/Stockholm'
                : null,
            start: CalendarEventCivil(year: 2026, month: 3, day: 28, hour: 9),
            duration: CalendarEventDuration(days: 1),
          );
          final t = (await service.createTask(
            CalendarTaskCreateRequest(
              calendarId: parent,
              content: CalendarTaskContent(
                timing: timing,
                recurrence: CalendarEventRecurrence(
                  rule: daily(),
                  inclusions: [],
                  exclusions: [],
                ),
              ),
              assignees: [],
            ),
          ))!;
          CalendarTaskOccurrenceQuery query(int rev) =>
              CalendarTaskOccurrenceQuery(
                taskId: t.taskId,
                expectedRevision: rev,
                fromUtc: DateTime.utc(2026, 3, 27),
                untilUtc: DateTime.utc(2026, 3, 31),
              );
          final original = (await service.previewTaskOccurrences(query(1)))
              .occurrences
              .first
              .originalStart;
          final replacement = timing.copyWith(
            start: CalendarEventCivil(
              year: 2026,
              month: 3,
              day: 29,
              hour: 2,
              minute: 30,
            ),
          );
          await service.changeTaskOccurrenceTiming(
            taskTiming(t, original, replacement),
          );
          final o = (await service.previewTaskOccurrences(query(2)))
              .occurrences
              .first;
          expect(o.originalStart, original);
          expect(o.actualStart!.start.hour, 2);
          expect(
            o.dueUtc!.difference(o.startUtc!).inHours,
            kind == CalendarTaskTimeKind.zoned ? 23 : 24,
          );
          final wire = await service.exportTasks(
            taskExport([t.copyWith(revision: 2)]),
          );
          final copyParent = (await service.create(createInput()))!.calendarId;
          final copy = (await service.importTasks(
            CalendarTaskImportRequest(
              calendarId: copyParent,
              expectedRevision: 1,
              bytes: wire,
            ),
          )).receipts.single;
          final again = (await service.previewTaskOccurrences(
            query(1).copyWith(taskId: copy.taskId),
          )).occurrences.first;
          expect(again.startUtc, o.startUtc);
          expect(again.dueUtc, o.dueUtc);
          expect(again.replacementTiming, replacement);
        },
      );
    }
    test('task timing late generation failure rolls back inserted state and revision', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      final scope = (await CalendarScopeRecord.db.find(session)).single;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskTiming(t, original, movedTask()),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarTaskOccurrenceRecord.db.find(session), isEmpty);
      expect(
        (await CalendarTaskRecord.db.findById(session, t.taskId))!.revision,
        1,
      );
    });
    test('task timing moves completed originals without changing progress history or master version', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, original, 1, CalendarTaskProgressAction.complete),
      );
      final before = (await CalendarTaskOccurrenceRecord.db.find(session))
          .single;
      final master = (await CalendarTaskDataRecord.db.find(session)).single;
      final history = (await CalendarTaskHistoryRecord.db.find(session)).single;
      await service.changeTaskOccurrenceTiming(
        taskTiming(t, original, movedTask(), 2),
      );
      final moved = (await service.previewTaskOccurrences(taskPreview(t, 3)))
          .occurrences
          .last;
      expect(moved.originalStart, original);
      expect(moved.actualStart!.start.day, 31);
      expect(moved.dueDate, isNull);
      expect(moved.progress, before.progress);
      final row = (await CalendarTaskOccurrenceRecord.db.find(session)).single;
      expect(row.protocolVersion!.sequence, 1);
      expect(
        (await CalendarTaskHistoryRecord.db.find(session)).single.toJson(),
        history.toJson(),
      );
      expect(
        (await CalendarTaskDataRecord.db.find(session)).single.protocolVersion,
        master.protocolVersion,
      );
      await service.changeTaskOccurrenceTiming(
        taskTiming(t, original, movedTask(), 3),
      );
      expect(
        (await CalendarTaskOccurrenceRecord.db.find(session))
            .single
            .protocolVersion,
        row.protocolVersion,
      );
      await service.changeTaskOccurrenceTiming(
        taskTiming(t, original, null, 4),
      );
      final restored = (await service.previewTaskOccurrences(taskPreview(t, 5)))
          .occurrences
          .first;
      expect(restored.originalStart, original);
      expect(restored.progress, before.progress);
      expect(restored.dueDate!.day, 29);
      expect(
        (await CalendarTaskHistoryRecord.db.find(session)).single.toJson(),
        history.toJson(),
      );
    });
    test('task timing captures imported master progress without history and retains baseline', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final t = (await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar(
            importedTask(
              'capture',
              properties: [
                'RRULE:FREQ=DAILY;COUNT=3',
                'PERCENT-COMPLETE:37',
                'STATUS:COMPLETED',
              ],
            ),
          ),
        ),
      )).receipts.single;
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      final before = (await CalendarTaskDataRecord.db.find(session)).single;
      await service.changeTaskOccurrenceTiming(
        taskTiming(t, original, movedTask()),
      );
      final row = (await CalendarTaskOccurrenceRecord.db.find(session)).single;
      expect(row.progress, before.progress);
      expect(row.protocolVersion!.sequence, 0);
      expect(await CalendarTaskHistoryRecord.db.find(session), isEmpty);
      final after = (await CalendarTaskDataRecord.db.find(session)).single;
      expect(after.importBaseline, before.importBaseline);
      expect(after.protocolVersion, before.protocolVersion);
      expect(after.sourceState!.occurrences.single.progress, before.progress);
      final bytes = await service.exportTasks(
        taskExport([t.copyWith(revision: 2)]),
      );
      final copyParent = (await service.create(createInput()))!.calendarId;
      final copy = (await service.importTasks(
        CalendarTaskImportRequest(
          calendarId: copyParent,
          expectedRevision: 1,
          bytes: bytes,
        ),
      )).receipts.single;
      final preview = await service.previewTaskOccurrences(taskPreview(copy));
      expect(preview.occurrences.last.actualStart!.start.day, 31);
      expect(preview.occurrences.last.progress, before.progress);
      expect(preview.occurrences.last.dueDate, isNull);
    });
    test('task timing clears absent overrides as no-op without creating progress or versions', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      await service.changeTaskOccurrenceTiming(taskTiming(t, original, null));
      expect(await CalendarTaskOccurrenceRecord.db.find(session), isEmpty);
      expect(await CalendarTaskHistoryRecord.db.find(session), isEmpty);
      expect((await taskRead(t.taskId)).revision, 2);
    });
    test('task timing uses content authority independently of progress and assignment permissions', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      policy.denied.addAll([
        CalendarPermission.changeTaskProgress,
        CalendarPermission.changeTaskAssignments,
        CalendarPermission.readTask,
      ]);
      await service.changeTaskOccurrenceTiming(
        taskTiming(t, original, movedTask()),
      );
      expect(
        (await CalendarTaskOccurrenceRecord.db.find(session))
            .single
            .replacementTiming,
        movedTask(),
      );
      policy.denied.clear();
      policy.denied.add(CalendarPermission.updateTask);
      await expectLater(
        service.changeTaskOccurrenceTiming(taskTiming(t, original, null, 2)),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('task timing rejects stale and final-denied writes without changing records', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskTiming(t, original, movedTask(), 2),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      policy.denyFinal = true;
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskTiming(t, original, movedTask()),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarTaskOccurrenceRecord.db.find(session), isEmpty);
      expect(
        (await CalendarTaskRecord.db.findById(session, t.taskId))!.revision,
        1,
      );
    });
    test('task timing host receives actual original current final state and frozen retained records', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      policy.onFinal = () {
        final q = policy.lastTaskRequest!;
        expect(q.taskOccurrenceTimingChange!.originalStart, original);
        expect(q.currentTask!.taskId, t.taskId);
        expect(q.calendarId, t.calendarId);
        expect(q.proposedTaskOccurrence!.replacementTiming, movedTask());
        expect(q.proposedTaskVersion, q.currentTask!.protocolVersion);
        expect(q.proposedTaskOccurrenceVersion!.sequence, 0);
        expect(() => q.recordedTaskOccurrences.clear(), throwsUnsupportedError);
      };
      await service.changeTaskOccurrenceTiming(
        taskTiming(t, original, movedTask()),
      );
    });
    test('task timing preserves overrides through master edits and rejects orphaned patterns', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences[1]
          .originalStart;
      await service.changeTaskOccurrenceTiming(
        taskTiming(t, original, movedTask()),
      );
      final data = (await CalendarTaskDataRecord.db.find(session)).single;
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: t.taskId,
          expectedRevision: 2,
          content: data.content.copyWith(
            summary: 'Edited',
            timing: data.content.timing.copyWith(
              duration: CalendarEventDuration(days: 2),
            ),
          ),
        ),
      );
      expect(
        (await service.previewTaskOccurrences(taskPreview(t, 3)))
            .occurrences
            .last
            .replacementTiming,
        movedTask(),
      );
      await expectLater(
        service.updateTask(
          CalendarTaskUpdateRequest(
            taskId: t.taskId,
            expectedRevision: 3,
            content: data.content.copyWith(
              recurrence: CalendarEventRecurrence(
                rule: daily(count: 1),
                inclusions: [],
                exclusions: [],
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
    });
    test('task timing import stores complete replacements and preview includes moved-in originals', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final t = (await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar([
            ...importedTask(
              'moved',
              properties: ['RRULE:FREQ=DAILY;COUNT=3', 'DURATION:P1D'],
            ),
            ...importedTask(
              'moved',
              timing: ['DTSTART;VALUE=DATE:20260402'],
              properties: [
                'RECURRENCE-ID;VALUE=DATE:20260328',
                'STATUS:COMPLETED',
              ],
            ),
          ]),
        ),
      )).receipts.single;
      final q = taskPreview(t).copyWith(
        fromDate: CalendarEventCivil(year: 2026, month: 4, day: 2),
        untilDate: CalendarEventCivil(year: 2026, month: 4, day: 3),
      );
      final o = (await service.previewTaskOccurrences(q)).occurrences.single;
      expect(o.originalStart.start.day, 28);
      expect(o.actualStart!.start.month, 4);
      expect(o.dueDate, isNull);
      expect(o.progress.status, CalendarTaskStatus.completed);
      expect(
        (await service.previewTaskOccurrences(taskPreview(t))).occurrences,
        hasLength(2),
      );
      expect(await CalendarTaskHistoryRecord.db.find(session), isEmpty);
    });
    test(
      'task timing rejects clearing inherited END alarm anchors atomically',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final t = (await service.importTasks(
          taskImportRequest(
            parent,
            text: taskCalendar(
              importedTask(
                'alarm',
                properties: [
                  'RRULE:FREQ=DAILY;COUNT=3',
                  'DURATION:P1D',
                  'BEGIN:VALARM',
                  'ACTION:DISPLAY',
                  'DESCRIPTION:Due',
                  'TRIGGER;RELATED=END:-PT5M',
                  'END:VALARM',
                ],
              ),
            ),
          ),
        )).receipts.single;
        final original = (await service.previewTaskOccurrences(taskPreview(t)))
            .occurrences
            .first
            .originalStart;
        await expectLater(
          service.changeTaskOccurrenceTiming(
            taskTiming(t, original, movedTask()),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarTaskOccurrenceRecord.db.find(session), isEmpty);
        expect(
          (await CalendarTaskRecord.db.findById(session, t.taskId))!.revision,
          1,
        );
      },
    );
    for (final bad in [
      CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
      CalendarTaskTiming(
        kind: CalendarTaskTimeKind.utc,
        start: CalendarEventCivil(year: 2026, month: 3, day: 31),
      ),
      CalendarTaskTiming(
        kind: CalendarTaskTimeKind.date,
        start: CalendarEventCivil(year: 2100, month: 1, day: 1),
      ),
      CalendarTaskTiming(
        kind: CalendarTaskTimeKind.date,
        start: CalendarEventCivil(year: 2026, month: 3, day: 31),
        duration: CalendarEventDuration(microsecond: 1),
      ),
    ]) {
      test('task timing rejects invalid replacement ${bad.toJson()}', () async {
        final t = await recurringTask();
        final original = (await service.previewTaskOccurrences(taskPreview(t)))
            .occurrences
            .first
            .originalStart;
        await expectLater(
          service.changeTaskOccurrenceTiming(taskTiming(t, original, bad)),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarTaskOccurrenceRecord.db.find(session), isEmpty);
      });
    }
    test('task timing rejects absent originals and old source baseline without inventing state', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      await expectLater(
        service.changeTaskOccurrenceTiming(
          taskTiming(
            t,
            original.copyWith(
              start: CalendarEventCivil(year: 2026, month: 4, day: 2),
            ),
            movedTask(),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      final parent = (await service.create(createInput()))!.calendarId;
      final imported = (await service.importTasks(taskImportRequest(parent)))
          .receipts
          .single;
      final row = (await CalendarTaskDataRecord.db.findFirstRow(
        session,
        where: (r) => r.taskId.equals(imported.taskId),
      ))!;
      await CalendarTaskDataRecord.db.updateRow(
        session,
        row.copyWith(
          importBaseline: row.importBaseline!.copyWith(
            profile: 'task-source-v1/old',
          ),
        ),
      );
      await expectLater(
        taskRead(imported.taskId),
        failure(CalendarFailureCode.unavailable),
      );
    });

    test('task export preserves current rich source and sparse progress with no private or native state', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final t = (await service.importTasks(
        taskImportRequest(
          parent,
          text: taskCalendar([
            ...importedTask(
              'export@example.invalid',
              properties: [
                'SUMMARY;LANGUAGE=sv:Before',
                'PERCENT-COMPLETE:37',
                'COMPLETED:20260302T000000Z',
                'RRULE:FREQ=DAILY;COUNT=3',
                'CATEGORIES;LANGUAGE=sv:one,one',
                'CONTACT:Private source contact',
                'ORGANIZER:mailto:source@example.invalid',
                'ATTENDEE;ROLE=CHAIR:mailto:guest@example.invalid',
                'RELATED-TO:unresolved',
                'ATTACH;VALUE=URI;FMTTYPE=text/plain:cid:example',
                'BEGIN:VALARM',
                'ACTION:DISPLAY',
                'TRIGGER:-PT5M',
                'DESCRIPTION:Unarmed',
                'UID:alarm',
                'ACKNOWLEDGED:20260301T000000Z',
                'END:VALARM',
                'BEGIN:VALARM',
                'ACTION:DISPLAY',
                'TRIGGER;VALUE=DATE-TIME:20260329T000000Z',
                'DESCRIPTION:Snoozed source',
                'UID:snooze',
                'RELATED-TO;RELTYPE=SNOOZE:alarm',
                'END:VALARM',
              ],
            ),
            ...importedTask(
              'export@example.invalid',
              timing: [],
              properties: [
                'RECURRENCE-ID;VALUE=DATE:20260329',
                'SEQUENCE:9',
                'STATUS:CANCELLED',
              ],
            ),
          ]),
        ),
      )).receipts.single;
      final before = (await CalendarTaskDataRecord.db.findFirstRow(
        session,
        where: (r) => r.taskId.equals(t.taskId),
      ))!;
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: t.taskId,
          expectedRevision: 1,
          content: before.content.copyWith(summary: 'Current'),
        ),
      );
      final current = (await CalendarTaskDataRecord.db.findFirstRow(
        session,
        where: (r) => r.taskId.equals(t.taskId),
      ))!;
      final gen = await generation();
      final req = taskExport([t.copyWith(revision: 2)]);
      final bytes = await service.exportTasks(req), text = exported(bytes);
      expect(text, contains('SUMMARY;LANGUAGE=sv:Current'));
      expect(text, isNot(contains('Before')));
      expect(text, contains('CONTACT:Private source contact'));
      expect(text, contains('RELATED-TO;RELTYPE=SNOOZE:alarm'));
      expect(text, isNot(contains(t.taskId.toString())));
      for (final hidden in [
        'importBaseline',
        'hasRecordedProgress',
        'assignees',
        'scopeKey',
      ]) {
        expect(text, isNot(contains(hidden)));
      }
      final parsed = parseIcalendarTaskCalendar(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      ).series.single;
      expect(parsed.master.status, isNull);
      expect(parsed.master.percentComplete, 37);
      expect(parsed.master.sequence, 1);
      expect(parsed.overrides.single.component.sequence, 9);
      expect(parsed.overrides.single.component.percentComplete, isNull);
      expect(parsed.master.alarms, hasLength(2));
      expect(exported(await service.exportTasks(req)), text);
      expect(
        (await CalendarTaskDataRecord.db.findFirstRow(
          session,
          where: (r) => r.taskId.equals(t.taskId),
        ))!.toJson(),
        current.toJson(),
      );
      expect(await generation(), gen);
    });
    for (final permission in [
      CalendarPermission.exportTasks,
      CalendarPermission.readTask,
      CalendarPermission.readTaskSource,
    ]) {
      test('task export independently requires ${permission.name}', () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final t = await taskCreate(parent);
        policy.denied.add(permission);
        await expectLater(
          service.exportTasks(taskExport([t])),
          failure(CalendarFailureCode.accessDenied),
        );
      });
    }
    for (final group in CalendarTaskFieldGroup.values) {
      test('task export requires disclosure of ${group.name}', () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final t = await taskCreate(parent);
        policy.taskGrants.remove(group);
        await expectLater(
          service.exportTasks(taskExport([t])),
          failure(CalendarFailureCode.accessDenied),
        );
      });
    }
    test('task export native recurrence has independent occurrence progress versions and no assignment mapping', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, original, 1, CalendarTaskProgressAction.complete),
      );
      await service.changeTaskAssignments(
        CalendarTaskAssignmentsRequest(
          taskId: t.taskId,
          expectedRevision: 2,
          assignees: [
            CalendarTaskAssignee(
              namespace: 'test',
              kind: 'user',
              externalId: 'private-assignee',
            ),
          ],
        ),
      );
      final bytes = await service.exportTasks(
        taskExport([t.copyWith(revision: 3)]),
      );
      final parsed = parseIcalendarTaskCalendar(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      ).series.single;
      expect(parsed.master.sequence, 0);
      expect(parsed.overrides.single.component.sequence, 0);
      expect(parsed.overrides.single.component.percentComplete, 100);
      expect(exported(bytes), isNot(contains('private-assignee')));
      expect(exported(bytes), isNot(contains('ATTENDEE')));
    });
    test('task export final checks contain immutable full current selection and reject member revocation', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final tasks = [await taskCreate(parent), await taskCreate(parent)];
      var batches = 0;
      policy.onTaskExport = (r) {
        expect(r.taskExport!.members, hasLength(2));
        expect(() => r.taskExport!.members.clear(), throwsUnsupportedError);
        expect(
          () => r
              .taskExport!
              .members
              .first
              .sourceState
              .master
              .metadata
              .attendees
              .clear(),
          throwsUnsupportedError,
        );
        if (r.taskId == null) {
          batches++;
          if (batches == 2) policy.deniedTaskExports.add(tasks.last.taskId);
        }
      };
      final gen = await generation();
      await expectLater(
        service.exportTasks(taskExport(tasks)),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(batches, 2);
      expect(await generation(), gen);
    });
    test('task export rejects stale duplicate empty invalid foreign missing and deleted selection', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final t = await taskCreate(parent);
      final other = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.exportTasks(taskExport([t], parentRevision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.exportTasks(taskExport([t.copyWith(revision: 2)])),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.exportTasks(taskExport([t, t])),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.exportTasks(taskExport([], parent: parent)),
        failure(CalendarFailureCode.limitExceeded),
      );
      await expectLater(
        service.exportTasks(taskExport([t.copyWith(revision: 0)])),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.exportTasks(taskExport([t], parent: other)),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.exportTasks(
          taskExport([t.copyWith(taskId: const Uuid().v4obj())]),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        CalendarModule.service(
          builder
              .copyWith(
                authentication: AuthenticationOverride.authenticationInfo(
                  'bob',
                  {},
                ),
              )
              .build(),
        ).exportTasks(taskExport([t])),
        failure(CalendarFailureCode.accessDenied),
      );
      await service.deleteTask(t.taskId, 1);
      await expectLater(
        service.exportTasks(taskExport([t])),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('task export supports single-request policy batches and fails closed on policy outage', () async {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          policyBatchSize: 1,
        ),
      );
      service = CalendarModule.service(session);
      final parent = (await service.create(createInput()))!.calendarId;
      final t = await taskCreate(parent);
      expect(
        exported(await service.exportTasks(taskExport([t]))),
        contains('BEGIN:VTODO'),
      );
      policy.unavailable = true;
      await expectLater(
        service.exportTasks(taskExport([t])),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test('task export context revocation after serialization fails without mutations', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final t = await taskCreate(parent);
      var batches = 0;
      policy.onTaskExport = (r) {
        if (r.taskId == null && ++batches == 2) policy.epoch = 'changed';
      };
      await expectLater(
        service.exportTasks(taskExport([t])),
        failure(CalendarFailureCode.unavailable),
      );
      expect(batches, 2);
    });
    test('task export rejects missing legacy component versions and aggregate limits without repair', () async {
      final t = await recurringTask();
      final original = (await service.previewTaskOccurrences(taskPreview(t)))
          .occurrences
          .first
          .originalStart;
      await service.changeTaskOccurrenceProgress(
        occurrenceProgress(t, original, 1, CalendarTaskProgressAction.complete),
      );
      final row = (await CalendarTaskOccurrenceRecord.db.findFirstRow(
        session,
        where: (r) => r.taskId.equals(t.taskId),
      ))!;
      await CalendarTaskOccurrenceRecord.db.updateRow(
        session,
        row.copyWith(protocolVersion: null),
      );
      await expectLater(
        service.exportTasks(taskExport([t.copyWith(revision: 2)])),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await CalendarTaskOccurrenceRecord.db.findById(
          session,
          row.id!,
        ))!.protocolVersion,
        isNull,
      );
      final tooMany = List.generate(
        129,
        (_) => t.copyWith(taskId: const Uuid().v4obj()),
      );
      await expectLater(
        service.exportTasks(taskExport(tooMany)),
        failure(CalendarFailureCode.limitExceeded),
      );
    });

    test('event export emits current authorized state and leaves all stored values unchanged', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final imported = await service.importEvents(
        eventImport(parent, [
          eventSource(
            'wire',
            extra: [
              'SUMMARY;LANGUAGE=sv:Before',
              'DURATION:PT1H',
              'RRULE:FREQ=DAILY;COUNT=2',
              'RDATE;VALUE=PERIOD:20260402T090000Z/PT2H',
            ],
          ),
        ]),
      );
      final receipt = imported.receipts.single;
      final row = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(receipt.eventId),
      ))!;
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: receipt.eventId,
          expectedRevision: 1,
          content: row.content.copyWith(summary: 'Current'),
        ),
      );
      final dataBefore = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(receipt.eventId),
      ))!;
      final gen = await generation();
      final request = eventExport([receipt.copyWith(revision: 2)]);
      final bytes = await service.exportEvents(request), text = exported(bytes);
      expect(text, contains('SUMMARY;LANGUAGE=sv:Current'));
      expect(text, isNot(contains('Before')));
      expect(text, isNot(contains('importBaseline')));
      expect(text, isNot(contains(receipt.eventId.toString())));
      final parsed = parseIcalendarEventCalendar(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      ).series.single;
      expect(parsed.master.sequence, 1);
      expect(parsed.master.stamp, DateTime.utc(2040));
      expect(
        parsed
            .master
            .recurrence!
            .timedSet!
            .periods
            .values
            .single
            .duration!
            .hours,
        2,
      );
      expect(exported(await service.exportEvents(request)), text);
      final after = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(receipt.eventId),
      ))!;
      expect(jsonEncode(after.toJson()), jsonEncode(dataBefore.toJson()));
      expect(await generation(), gen);
    });
    for (final permission in [
      CalendarPermission.exportEvents,
      CalendarPermission.readEvent,
      CalendarPermission.readEventSource,
    ]) {
      test('event export independently requires ${permission.name}', () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final e = (await service.importEvents(
          eventImport(parent, [eventSource('rights')]),
        )).receipts;
        policy.denied.add(permission);
        await expectLater(
          service.exportEvents(eventExport(e)),
          failure(CalendarFailureCode.accessDenied),
        );
      });
    }
    for (final group in CalendarEventFieldGroup.values) {
      test('event export requires disclosure of ${group.name}', () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final e = (await service.importEvents(
          eventImport(parent, [eventSource('disclosure')]),
        )).receipts;
        policy.eventGrants.remove(group);
        await expectLater(
          service.exportEvents(eventExport(e)),
          failure(CalendarFailureCode.accessDenied),
        );
      });
    }
    test('event export repeats complete immutable source checks after serialization', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final e = (await service.importEvents(
        eventImport(parent, [eventSource('first'), eventSource('second')]),
      )).receipts;
      var batches = 0;
      policy.onEventExport = (request) {
        if (request.eventExport != null && request.eventId == null) {
          batches++;
          expect(request.eventExport!.members, hasLength(2));
          expect(
            () => request.eventExport!.members.clear(),
            throwsUnsupportedError,
          );
          if (batches == 2) policy.deniedEventExports.add(e.last.eventId);
        }
      };
      final gen = await generation();
      await expectLater(
        service.exportEvents(eventExport(e)),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(batches, 2);
      expect(await generation(), gen);
      expect(await CalendarEventRecord.db.count(session), 2);
    });
    test('event export rejects stale duplicate missing foreign deleted and wrong-parent selection', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final other = (await service.create(createInput()))!.calendarId;
      final e = (await service.importEvents(
        eventImport(parent, [eventSource('target')]),
      )).receipts.single;
      await expectLater(
        service.exportEvents(eventExport([e], parentRevision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.exportEvents(eventExport([e.copyWith(revision: 2)])),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.exportEvents(eventExport([e, e])),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.exportEvents(eventExport([e], parent: other)),
        failure(CalendarFailureCode.accessDenied),
      );
      final bob = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      await expectLater(
        CalendarModule.service(bob).exportEvents(eventExport([e])),
        failure(CalendarFailureCode.accessDenied),
      );
      await service.deleteEvent(e.eventId, 1);
      await expectLater(
        service.exportEvents(eventExport([e])),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.exportEvents(
          eventExport([e.copyWith(eventId: const Uuid().v4obj())]),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('event export honors single-request policy batches and current context failure', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final e = (await service.importEvents(
        eventImport(parent, [eventSource('chunk')]),
      )).receipts;
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          policyBatchSize: 1,
        ),
      );
      service = CalendarModule.service(session);
      expect(
        exported(await service.exportEvents(eventExport(e))),
        contains('BEGIN:VEVENT'),
      );
      policy.onEventExport = (r) {
        if (r.eventExport != null) policy.epoch = 'changed';
      };
      await expectLater(
        service.exportEvents(eventExport(e)),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test('event export rejects unrepresentable restoration state without a partial file', () async {
      final id = await recurringEvent();
      final before = await service.getEvent(id, eventGroups);
      await service.changeOccurrence(
        occurrenceChange(id, CalendarEventOccurrenceAction.cancelSingle),
      );
      final other = (await service.importEvents(
        eventImport(before.calendarId, [eventSource('other')]),
      )).receipts.single;
      final bad = CalendarEventReceipt(
        eventId: id,
        calendarId: before.calendarId,
        revision: 2,
        deleted: false,
      );
      await expectLater(
        service.exportEvents(eventExport([other, bad])),
        failure(CalendarFailureCode.validation),
      );
      final data = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      ))!;
      expect(data.timingOverrides!.singles.single.cancelled, isTrue);
    });
    test('event export rejects aggregate component limits without changing source state', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final e = (await service.importEvents(
        eventImport(parent, [
          for (var i = 0; i < 128; i++) eventSource('cap-$i'),
        ]),
      )).receipts;
      final extra = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
      ))!;
      await expectLater(
        service.exportEvents(eventExport([...e, extra])),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarEventRecord.db.count(session), 129);
    });

    CalendarAvailabilityImportRequest importRequest(
      UuidValue parent,
      List<String> definitions, {
      int revision = 1,
      String? raw,
    }) => CalendarAvailabilityImportRequest(
      calendarId: parent,
      expectedRevision: revision,
      bytes: ByteData.sublistView(
        Uint8List.fromList(utf8.encode(raw ?? importFile(definitions))),
      ),
    );
    test('availability import honors ByteData views named zones and component overrides', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final opening = [
        'BEGIN:AVAILABLE',
        'UID:named-opening',
        'DTSTAMP:20400101T000000Z',
        'DTSTART;TZID=UTC:20261022T090000',
        'DURATION:PT1H',
        'RRULE:FREQ=DAILY;COUNT=2',
        'END:AVAILABLE',
        'BEGIN:AVAILABLE',
        'UID:named-opening',
        'DTSTAMP:20390101T000000Z',
        'RECURRENCE-ID;TZID=UTC:20261023T090000',
        'DTSTART;TZID=UTC:20261023T110000',
        'DURATION:PT2H',
        'END:AVAILABLE',
      ].join('\r\n');
      final zone = [
        'BEGIN:VTIMEZONE',
        'TZID:UTC',
        'BEGIN:STANDARD',
        'DTSTART:19000101T000000',
        'TZOFFSETFROM:+0000',
        'TZOFFSETTO:+0000',
        'END:STANDARD',
        'END:VTIMEZONE',
      ].join('\r\n');
      final raw = importFile([
        zone,
        importDefinition('Named', opening: opening),
      ]);
      final bytes = Uint8List.fromList([1, 2, ...utf8.encode(raw), 3]);
      final result = await service.importAvailability(
        CalendarAvailabilityImportRequest(
          calendarId: parent,
          expectedRevision: 1,
          bytes: ByteData.view(bytes.buffer, 2, bytes.length - 3),
        ),
      );
      final rule = await service.getAvailability(
        result.receipts.single.availabilityId,
      );
      expect(rule.content.openings.single.timing.zoneId, 'UTC');
      expect(
        rule
            .timingOverrides!
            .single
            .overrides
            .singles
            .single
            .replacement!
            .start
            .hour,
        11,
      );
      expect(
        rule.protocolState.openings.single.overrides!.single.stamp,
        DateTime.utc(2039),
      );
      final preview = await service.previewAvailabilityOccurrences(
        CalendarAvailabilityOccurrenceQuery(
          availabilityId: rule.id,
          openingUid: rule.content.openings.single.uid!,
          expectedRevision: 1,
          fromUtc: DateTime.utc(2026, 10, 23),
          untilUtc: DateTime.utc(2026, 10, 24),
        ),
      );
      expect(
        preview.occurrences.single.startUtc,
        DateTime.utc(2026, 10, 23, 11),
      );
      expect(preview.occurrences.single.endUtc, DateTime.utc(2026, 10, 23, 13));
    });
    test('availability import revalidates required coordination guarantee before commit', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      policy.capability = CalendarAuthorizationGuarantee.coordinated;
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.coordinated,
        ),
      );
      service = CalendarModule.service(session);
      policy.onPreliminary = () {
        policy.capability = CalendarAuthorizationGuarantee.freshCheck;
      };
      await expectLater(
        service.importAvailability(
          importRequest(parent, [importDefinition('Guarantee')]),
        ),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await CalendarAvailabilityDataRecord.db.count(session), 0);
    });

    test('availability import retains source identity version groups contacts and PERIODs atomically', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final before = await generation();
      final result = await service.importAvailability(
        importRequest(parent, [
          importDefinition(
            '來源@example.invalid',
            extra: 'CATEGORIES;LANGUAGE=en:One,One\r\nCATEGORIES;LANGUAGE=sv:Två\r\nCONTACT;LANGUAGE=sv:Desk',
            opening: [
              'BEGIN:AVAILABLE',
              'UID:opening-not-a-uuid',
              'DTSTAMP:20390101T000000Z',
              'DTSTART:20261022T090000Z',
              'DURATION:PT1H',
              'RDATE;VALUE=PERIOD:20261023T090000Z/PT2H',
              'END:AVAILABLE',
            ].join('\r\n'),
          ),
          importDefinition('Second definition'),
        ]),
      );
      final importPolicyRequest = policy.lastAvailabilityRequest!;
      expect(result.receipts, hasLength(2));
      expect(await generation(), before + 1);
      final parentView = await service.get(parent, groups);
      expect(parentView.revision, 1);
      final rule = await service.getAvailability(
        result.receipts.first.availabilityId,
      );
      expect(rule.protocolUid, '來源@example.invalid');
      expect(rule.protocolState.sequence, 17);
      expect(rule.protocolState.stamp, DateTime.utc(2040));
      expect(rule.protocolState.created, isNull);
      expect(rule.lastModified, isNull);
      expect(rule.content.categoryGroups!.first.values, ['One', 'One']);
      expect(rule.content.contacts!.single.language, 'sv');
      expect(rule.content.openings.single.protocolUid, 'opening-not-a-uuid');
      expect(rule.content.openings.single.uid, isNotNull);
      expect(rule.content.openings.single.periods!.single.duration!.hours, 2);
      final request = importPolicyRequest;
      expect(request.availabilityImport!.members, hasLength(2));
      expect(
        () => request.availabilityImport!.members.clear(),
        throwsUnsupportedError,
      );
      expect(
        () => request
            .availabilityImport!
            .members
            .first
            .content
            .categoryGroups!
            .first
            .values
            .clear(),
        throwsUnsupportedError,
      );
      final row = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(rule.id),
      ))!;
      expect(row.createdAt.year, 2026);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: 1,
          content: rule.content.copyWith(summary: 'Local edit'),
        ),
      );
      final edited = await service.getAvailability(rule.id);
      expect(edited.protocolState.sequence, 18);
      expect(edited.content.contacts!.single.value, 'Desk');
    });

    for (final permission in [
      CalendarPermission.importAvailability,
      CalendarPermission.createAvailability,
    ]) {
      test(
        'availability import independently requires ${permission.name}',
        () async {
          final parent = (await service.create(createInput()))!.calendarId;
          final before = await generation();
          policy.denied.add(permission);
          await expectLater(
            service.importAvailability(
              importRequest(parent, [importDefinition('Denied')]),
            ),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(await CalendarAvailabilityDataRecord.db.count(session), 0);
          expect(await generation(), before);
        },
      );
    }
    test('availability import final member denial rolls back entire file and generation', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final before = await generation();
      policy.denyImportUid = 'Last';
      await expectLater(
        service.importAvailability(
          importRequest(parent, [
            importDefinition('First'),
            importDefinition('Last'),
          ]),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarAvailabilityDataRecord.db.count(session), 0);
      expect(await CalendarAvailabilityRecord.db.count(session), 0);
      expect(await generation(), before);
    });
    test('availability import receipts use final import and member disclosure independently of read rights', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      policy.denied.add(CalendarPermission.readAvailability);
      policy.hideImportReceiptUid = 'Hidden receipt';
      var result = await service.importAvailability(
        importRequest(parent, [
          importDefinition('Visible receipt'),
          importDefinition('Hidden receipt'),
        ]),
      );
      expect(result.receipts, hasLength(1));
      expect(await CalendarAvailabilityDataRecord.db.count(session), 2);
      policy.hideImportBatchReceipt = true;
      result = await service.importAvailability(
        importRequest(parent, [importDefinition('No batch receipt')]),
      );
      expect(result.receipts, isEmpty);
      expect(await CalendarAvailabilityDataRecord.db.count(session), 3);
    });
    test('availability import UID conflicts are exact active and destination-local', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final other = (await service.create(createInput()))!.calendarId;
      final receipt = (await service.importAvailability(
        importRequest(parent, [importDefinition('UID')]),
      )).receipts.single;
      final before = await generation();
      await expectLater(
        service.importAvailability(
          importRequest(parent, [
            importDefinition('new'),
            importDefinition('UID'),
          ]),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(await generation(), before);
      expect(await CalendarAvailabilityDataRecord.db.count(session), 1);
      await service.importAvailability(
        importRequest(other, [importDefinition('UID')]),
      );
      await service.importAvailability(
        importRequest(parent, [importDefinition('uid')]),
      );
      await service.deleteAvailability(receipt.availabilityId, 1);
      final fresh = (await service.importAvailability(
        importRequest(parent, [importDefinition('UID')]),
      )).receipts.single;
      expect(fresh.availabilityId, isNot(receipt.availabilityId));
    });
    test(
      'availability import rejects stale foreign and deleted parents',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        await expectLater(
          service.importAvailability(
            importRequest(parent, [importDefinition('Stale')], revision: 2),
          ),
          failure(CalendarFailureCode.staleRevision),
        );
        policy.scopeOverride = 'foreign';
        await expectLater(
          service.importAvailability(
            importRequest(parent, [importDefinition('Foreign')]),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.scopeOverride = null;
        await service.delete(parent, 1);
        await expectLater(
          service.importAvailability(
            importRequest(parent, [importDefinition('Deleted')]),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarAvailabilityDataRecord.db.count(session), 0);
      },
    );
    test(
      'availability import rechecks policy epoch after parsing preflight',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        policy.onImportBatch = (s, request, tx, phase) async {
          if (request.availabilityImport != null) policy.epoch = 'changed';
        };
        await expectLater(
          service.importAvailability(
            importRequest(parent, [importDefinition('Epoch')]),
          ),
          failure(CalendarFailureCode.unavailable),
        );
        expect(await CalendarAvailabilityDataRecord.db.count(session), 0);
      },
    );
    test('availability import organizer approval runs both phases with complete source proposal', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      policy.denyFinalOrganizer = true;
      await expectLater(
        service.importAvailability(
          importRequest(parent, [
            importDefinition(
              'Organizer',
              extra: 'ORGANIZER:mailto:source@example.invalid',
            ),
          ]),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(policy.organizerPhases, [
        CalendarAuthorizationPhase.preliminaryWrite,
        CalendarAuthorizationPhase.finalWrite,
      ]);
      expect(
        policy.organizerRequest!.availabilityImport!.members.single.protocolUid,
        'Organizer',
      );
      expect(await CalendarAvailabilityDataRecord.db.count(session), 0);
    });
    test('availability import trusted extension validators run again at final write and fail closed', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      var validations = 0;
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        availabilityExtensions: [
          CalendarAvailabilityExtensionRegistration(
            name: 'X-TEST',
            contexts: CalendarAvailabilityExtensionContext.values,
            validate: (_) {
              if (++validations == 2) {
                throw StateError('Synthetic registry failure');
              }
              return true;
            },
          ),
        ],
      );
      service = CalendarModule.service(session);
      await expectLater(
        service.importAvailability(
          importRequest(parent, [
            importDefinition('Extension', extra: 'X-TEST:Private value'),
          ]),
        ),
        failure(CalendarFailureCode.unavailable),
      );
      expect(validations, 2);
      expect(await CalendarAvailabilityDataRecord.db.count(session), 0);
    });
    test('availability import preserves omitted source sequence without inventing dates', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final definition = importDefinition('Omitted')
          .replaceAll('SEQUENCE:17\r\n', '');
      final result = await service.importAvailability(
        importRequest(parent, [definition]),
      );
      final rule = await service.getAvailability(
        result.receipts.single.availabilityId,
      );
      expect(rule.protocolState.sequence, isNull);
      expect(rule.protocolState.created, isNull);
      expect(rule.lastModified, isNull);
    });
    for (final malformed in [
      'bare LF',
      'unsupported component',
      'duplicate master',
      'unknown extension',
      'fraction',
    ]) {
      test('availability import rejects $malformed without rows', () async {
        final parent = (await service.create(createInput()))!.calendarId;
        var raw = importFile([importDefinition('Invalid')]);
        raw = switch (malformed) {
          'bare LF' => raw.replaceAll('\r\n', '\n'),
          'unsupported component' => raw.replaceAll('VAVAILABILITY', 'VEVENT'),
          'duplicate master' => importFile([
            importDefinition('Invalid'),
            importDefinition('Invalid'),
          ]),
          'unknown extension' => importFile([
            importDefinition('Invalid', extra: 'X-UNREGISTERED:No'),
          ]),
          _ => raw.replaceAll('20400101T000000Z', '20400101T000000.1Z'),
        };
        await expectLater(
          service.importAvailability(importRequest(parent, [], raw: raw)),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarAvailabilityDataRecord.db.count(session), 0);
      });
    }
    test(
      'availability import bounds bytes and destination capacity atomically',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        await expectLater(
          service.importAvailability(
            importRequest(parent, [], raw: 'x' * 1048577),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        await service.importAvailability(
          importRequest(parent, [
            for (var i = 0; i < 64; i++) importDefinition('capacity-$i'),
          ]),
        );
        final before = await generation();
        await expectLater(
          service.importAvailability(
            importRequest(parent, [importDefinition('overflow')]),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await generation(), before);
        expect(await CalendarAvailabilityDataRecord.db.count(session), 64);
      },
    );

    CalendarAvailabilityExportRequest exportRequest(
      List<CalendarAvailabilityView> rules, {
      UuidValue? parent,
      int revision = 1,
    }) => CalendarAvailabilityExportRequest(
      calendarId: parent ?? rules.first.calendarId,
      expectedRevision: revision,
      selection: [
        for (final rule in rules)
          CalendarAvailabilityExportSelection(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
          ),
      ],
    );
    List<int> exportedBytes(ByteData data) =>
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    test('availability export preserves imported source and current edits without changing audit or revisions', () async {
      final original = await storedSource();
      final before = await generation();
      final bytes = await service.exportAvailability(exportRequest([original]));
      final parsed = parseIcalendarAvailabilityCalendar(exportedBytes(bytes));
      final source = parsed.definitions.single;
      expect(source.uid, original.protocolUid);
      expect(source.stamp, DateTime.utc(2040));
      expect(source.sequence, 17);
      expect(source.created, isNull);
      expect(source.lastModified, isNull);
      expect(source.metadata.categoryGroups.first.values, ['One', 'One']);
      expect(source.metadata.contacts.single.value, 'Desk');
      expect(
        source
            .openings
            .single
            .master
            .recurrence!
            .periods
            .values
            .single
            .duration!
            .hours,
        2,
      );
      expect(await generation(), before);
      expect((await service.getAvailability(original.id)).revision, 1);
      expect((await service.get(original.calendarId, groups)).revision, 1);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: original.id,
          expectedRevision: 1,
          content: original.content.copyWith(summary: 'Current export'),
        ),
      );
      final edited = await service.getAvailability(original.id);
      final current = parseIcalendarAvailabilityCalendar(
        exportedBytes(
          await service.exportAvailability(exportRequest([edited])),
        ),
      );
      expect(current.definitions.single.summary!.value, 'Current export');
      expect(current.definitions.single.sequence, 18);
    });
    for (final permission in [
      CalendarPermission.exportAvailability,
      CalendarPermission.readAvailability,
    ]) {
      test(
        'availability export independently requires ${permission.name}',
        () async {
          final original = await storedSource();
          policy.denied.add(permission);
          await expectLater(
            service.exportAvailability(exportRequest([original])),
            failure(CalendarFailureCode.accessDenied),
          );
        },
      );
    }
    test('availability export is explicit all-or-nothing and freezes full host selection', () async {
      final first = await storedSource(uid: 'First source');
      final second = await storedSource(
        parent: first.calendarId,
        uid: 'Second source',
      );
      final selection = [
        CalendarAvailabilityExportSelection(
          availabilityId: first.id,
          expectedRevision: 1,
        ),
        CalendarAvailabilityExportSelection(
          availabilityId: second.id,
          expectedRevision: 1,
        ),
      ];
      CalendarAuthorizationRequest? last;
      policy.onExportBatch = (r) {
        if (r.availabilityExport == null) return;
        last = r;
        selection.clear();
        expect(
          () => r.availabilityExport!.members.clear(),
          throwsUnsupportedError,
        );
        expect(
          () => r.availabilityExport!.members.first.content.contacts!.clear(),
          throwsUnsupportedError,
        );
      };
      policy.deniedExportIds.add(second.id);
      await expectLater(
        service.exportAvailability(
          CalendarAvailabilityExportRequest(
            calendarId: first.calendarId,
            expectedRevision: 1,
            selection: selection,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(last!.availabilityExport!.members, hasLength(2));
      expect(selection, isEmpty);
      expect(await CalendarAvailabilityDataRecord.db.count(session), 2);
    });
    test('availability export reauthorizes every selected source after serialization', () async {
      final original = await storedSource();
      var fullChecks = 0;
      policy.onExportBatch = (r) {
        if (r.availabilityExport != null && ++fullChecks == 2) {
          policy.denied.add(CalendarPermission.readAvailability);
        }
      };
      await expectLater(
        service.exportAvailability(exportRequest([original])),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(fullChecks, 2);
    });
    test('availability export rejects stale missing foreign and mismatched selections', () async {
      final original = await storedSource();
      await expectLater(
        service.exportAvailability(exportRequest([original], revision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.exportAvailability(
          exportRequest([original.copyWith(revision: 2)]),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      final other = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.exportAvailability(exportRequest([original], parent: other)),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.exportAvailability(
          exportRequest([original.copyWith(id: const Uuid().v4obj())]),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.scopeOverride = 'foreign';
      await expectLater(
        service.exportAvailability(exportRequest([original])),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('availability export rejects duplicate opening source UIDs in combined selection but permits individual export', () async {
      final first = await storedSource(uid: 'First source');
      final second = await storedSource(
        parent: first.calendarId,
        uid: 'Second source',
      );
      await service.exportAvailability(exportRequest([first]));
      await expectLater(
        service.exportAvailability(exportRequest([first, second])),
        failure(CalendarFailureCode.validation),
      );
    });
    test('availability export order is deterministic and selected deleted members never disappear silently', () async {
      final first = await editableHours();
      final secondReceipt = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: first.calendarId,
          content: CalendarAvailabilityContent(openings: []),
        ),
      ))!;
      final second = await service.getAvailability(
        secondReceipt.availabilityId,
      );
      expect(
        exportedBytes(
          await service.exportAvailability(exportRequest([first, second])),
        ),
        exportedBytes(
          await service.exportAvailability(exportRequest([second, first])),
        ),
      );
      await service.deleteAvailability(second.id, second.revision);
      await expectLater(
        service.exportAvailability(exportRequest([first, second])),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('availability export current extension failure yields no result and no mutations', () async {
      final original = await storedSource();
      final receipt = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: original.calendarId,
          content: CalendarAvailabilityContent(openings: []),
        ),
      ))!;
      final data = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(receipt.availabilityId),
      ))!;
      await CalendarAvailabilityDataRecord.db.updateRow(
        session,
        data.copyWith(
          content: data.content.copyWith(
            extensions: [
              CalendarAvailabilityExtension(name: 'X-TEST', value: 'Private'),
            ],
          ),
        ),
      );
      final before = await generation();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        availabilityExtensions: [
          CalendarAvailabilityExtensionRegistration(
            name: 'X-TEST',
            contexts: CalendarAvailabilityExtensionContext.values,
            validate: (_) => throw StateError('Synthetic registry outage'),
          ),
        ],
      );
      service = CalendarModule.service(session);
      final rule = await service.getAvailability(receipt.availabilityId);
      await expectLater(
        service.exportAvailability(exportRequest([rule])),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await generation(), before);
    });
    test(
      'availability export selection limits reject before producing output',
      () async {
        final original = await storedSource();
        final empty = exportRequest([original]).copyWith(selection: []);
        await expectLater(
          service.exportAvailability(empty),
          failure(CalendarFailureCode.limitExceeded),
        );
        final duplicate = exportRequest([original]).copyWith(
          selection: [
            ...exportRequest([original]).selection,
            ...exportRequest([original]).selection,
          ],
        );
        await expectLater(
          service.exportAvailability(duplicate),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(
          service.exportAvailability(
            empty.copyWith(
              selection: List.filled(
                65,
                exportRequest([original]).selection.single,
              ),
            ),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
      },
    );

    Future<CalendarAvailabilityView> importedRule({
      UuidValue? parent,
      String uid = 'update-source',
      String? definition,
    }) async {
      parent ??= (await service.create(createInput()))!.calendarId;
      final result = await service.importAvailability(
        importRequest(parent, [definition ?? importDefinition(uid)]),
      );
      return service.getAvailability(result.receipts.single.availabilityId);
    }

    CalendarAvailabilityReplaceRequest replaceInput(
      List<CalendarAvailabilityView> rules,
      List<String> definitions, {
      int parentRevision = 1,
    }) => CalendarAvailabilityReplaceRequest(
      calendarId: rules.first.calendarId,
      expectedRevision: parentRevision,
      selection: [
        for (final rule in rules)
          CalendarAvailabilityExportSelection(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
          ),
      ],
      bytes: importRequest(rules.first.calendarId, definitions).bytes,
    );
    String replaceOpening(String uid, {int hour = 9, String extra = ''}) => [
      'BEGIN:AVAILABLE',
      'UID:$uid',
      'DTSTAMP:20500101T000000Z',
      'DTSTART:20261022T${hour.toString().padLeft(2, '0')}0000Z',
      'DURATION:PT1H',
      extra,
      'END:AVAILABLE',
    ].where((s) => s.isNotEmpty).join('\r\n');
    test('availability replacement exact replay is a true no-op including private baseline and audit time', () async {
      final rule = await importedRule();
      final before = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(rule.id),
      ))!;
      expect(before.importBaseline, isNotNull);
      final gen = await generation();
      final result = await service.replaceAvailabilityFromImport(
        replaceInput([rule], [importDefinition('update-source')]),
      );
      expect(result.receipts.single.changed, isFalse);
      expect(result.receipts.single.receipt.revision, 1);
      final after = (await CalendarAvailabilityDataRecord.db.findById(
        session,
        before.id!,
      ))!;
      expect(after.toJson(), before.toJson());
      expect(await generation(), gen);
      expect(rule.toJson().containsKey('importBaseline'), isFalse);
    });
    test('availability replacement equal sequence changed content and timestamp regressions retain source state', () async {
      final initial = importDefinition(
        'update-source',
        extra: 'CREATED:20410101T000000Z\r\nLAST-MODIFIED:20420101T000000Z',
        opening: replaceOpening('A'),
      );
      final rule = await importedRule(definition: initial);
      final originalId = rule.content.openings.single.uid;
      final next =
          importDefinition(
                'update-source',
                extra: 'CONTACT:New source contact',
                opening: replaceOpening('A')
                    .replaceAll('20500101T000000Z', '20190101T000000Z'),
              )
              .replaceAll('Imported hours', 'New title')
              .replaceAll('20400101T000000Z', '20200101T000000Z');
      final gen = await generation();
      final result = await service.replaceAvailabilityFromImport(
        replaceInput([rule], [next]),
      );
      expect(result.receipts.single.changed, isTrue);
      expect(result.receipts.single.receipt.revision, 2);
      final after = await service.getAvailability(rule.id);
      expect(after.protocolState.sequence, 17);
      expect(after.protocolState.stamp, DateTime.utc(2020));
      expect(after.protocolState.created, isNull);
      expect(after.lastModified, isNull);
      expect(after.protocolState.openings.single.stamp, DateTime.utc(2019));
      expect(after.content.contacts!.single.value, 'New source contact');
      expect(after.content.openings.single.uid, originalId);
      expect(await generation(), gen + 1);
      expect((await service.get(rule.calendarId, groups)).revision, 1);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: 2,
          content: after.content.copyWith(summary: 'Native later'),
        ),
      );
      expect(
        (await service.getAvailability(rule.id)).protocolState.stamp
            .isBefore(DateTime.utc(2020)),
        isFalse,
      );
    });
    test('availability replacement mixed no-op and changed members bump generation once', () async {
      final first = await importedRule(uid: 'A');
      final second = await importedRule(parent: first.calendarId, uid: 'B');
      final gen = await generation();
      final result = await service.replaceAvailabilityFromImport(
        replaceInput(
          [first, second],
          [
            importDefinition('B').replaceAll('Imported hours', 'Changed B'),
            importDefinition('A'),
          ],
        ),
      );
      expect(result.receipts.map((r) => r.changed), [false, true]);
      expect((await service.getAvailability(first.id)).revision, 1);
      expect((await service.getAvailability(second.id)).revision, 2);
      expect(await generation(), gen + 1);
    });
    test('availability replacement rejects local edits and never adopts an identical local export', () async {
      var rule = await importedRule();
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: 1,
          content: rule.content.copyWith(summary: 'Local edit'),
        ),
      );
      rule = await service.getAvailability(rule.id);
      final changed = importDefinition('update-source')
          .replaceAll('SEQUENCE:17', 'SEQUENCE:99');
      await expectLater(
        service.replaceAvailabilityFromImport(replaceInput([rule], [changed])),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final export = await service.exportAvailability(exportRequest([rule]));
      final noop = await service.replaceAvailabilityFromImport(
        replaceInput([rule], []).copyWith(bytes: export),
      );
      expect(noop.receipts.single.changed, isFalse);
      await expectLater(
        service.replaceAvailabilityFromImport(replaceInput([rule], [changed])),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await service.getAvailability(rule.id)).revision, 2);
    });
    test('availability replacement native accepted no-op saves do not create a local conflict', () async {
      var rule = await importedRule();
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: 1,
          content: rule.content,
        ),
      );
      rule = await service.getAvailability(rule.id);
      final result = await service.replaceAvailabilityFromImport(
        replaceInput(
          [rule],
          [
            importDefinition('update-source')
                .replaceAll('Imported hours', 'Source change'),
          ],
        ),
      );
      expect(result.receipts.single.receipt.revision, 3);
    });
    test('availability replacement lower source sequence and absent baseline reject without changes', () async {
      final rule = await importedRule();
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput(
            [rule],
            [
              importDefinition('update-source')
                  .replaceAll('SEQUENCE:17', 'SEQUENCE:16'),
            ],
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput(
            [rule],
            [
              importDefinition('update-source')
                  .replaceAll('SEQUENCE:17\r\n', ''),
            ],
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final native = await editableHours();
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput([native], [importDefinition(native.protocolUid)]),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final row = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(rule.id),
      ))!;
      await CalendarAvailabilityDataRecord.db.updateRow(
        session,
        row.copyWith(importBaseline: null),
      );
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput([rule], [importDefinition('update-source')]),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
    });
    test('availability replacement omitted source sequence permits equal omitted sequence updates', () async {
      final first = importDefinition('update-source')
          .replaceAll('SEQUENCE:17\r\n', '');
      final rule = await importedRule(definition: first);
      await service.replaceAvailabilityFromImport(
        replaceInput(
          [rule],
          [first.replaceAll('Imported hours', 'Omitted version change')],
        ),
      );
      expect(
        (await service.getAvailability(rule.id)).protocolState.sequence,
        isNull,
      );
    });
    test('availability replacement preserves current opening identities and allocates fresh identities after removal', () async {
      final rule = await importedRule(
        definition: importDefinition(
          'update-source',
          opening: '${replaceOpening('A')}\r\n${replaceOpening('B', hour: 12)}',
        ),
      );
      final a = rule.content.openings.first.uid,
          b = rule.content.openings.last.uid;
      await service.replaceAvailabilityFromImport(
        replaceInput(
          [rule],
          [
            importDefinition(
              'update-source',
              opening:
                  '${replaceOpening('B', hour: 13)}\r\n${replaceOpening('C', hour: 15)}',
            ),
          ],
        ),
      );
      var current = await service.getAvailability(rule.id);
      expect(current.content.openings.first.uid, b);
      expect(current.content.openings.last.uid, isNot(a));
      await service.replaceAvailabilityFromImport(
        replaceInput(
          [current],
          [importDefinition('update-source', opening: replaceOpening('A'))],
        ),
      );
      current = await service.getAvailability(rule.id);
      expect(current.content.openings.single.uid, isNot(a));
    });
    for (final permission in [
      CalendarPermission.importAvailability,
      CalendarPermission.replaceAvailabilityFromImport,
      CalendarPermission.readAvailability,
      CalendarPermission.updateAvailabilityMetadata,
    ]) {
      test(
        'availability replacement requires ${permission.name} independently',
        () async {
          final rule = await importedRule();
          policy.denied.add(permission);
          await expectLater(
            service.replaceAvailabilityFromImport(
              replaceInput(
                [rule],
                [
                  importDefinition('update-source')
                      .replaceAll('Imported hours', 'Changed'),
                ],
              ),
            ),
            failure(CalendarFailureCode.accessDenied),
          );
        },
      );
    }
    test('availability replacement structural and occurrence changes require independent rights', () async {
      final original = importDefinition(
        'update-source',
        opening: replaceOpening('A', extra: 'RRULE:FREQ=DAILY;COUNT=3'),
      );
      final rule = await importedRule(definition: original);
      policy.denied.add(CalendarPermission.updateAvailability);
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput([rule], [original.replaceAll('PT1H', 'PT2H')]),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.denied.add(CalendarPermission.changeAvailabilityOccurrence);
      final override = [
        'BEGIN:AVAILABLE',
        'UID:A',
        'DTSTAMP:20400101T000000Z',
        'RECURRENCE-ID:20261023T090000Z',
        'DTSTART:20261023T110000Z',
        'DURATION:PT1H',
        'END:AVAILABLE',
      ].join('\r\n');
      final next = original.replaceAll(
        'END:VAVAILABILITY',
        '$override\r\nEND:VAVAILABILITY',
      );
      await expectLater(
        service.replaceAvailabilityFromImport(replaceInput([rule], [next])),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('availability replacement late member denial and conflict roll back all rows baselines and generation', () async {
      final first = await importedRule(uid: 'A');
      final second = await importedRule(parent: first.calendarId, uid: 'B');
      final gen = await generation();
      policy.denyReplacementId = second.id;
      final input = replaceInput(
        [first, second],
        [
          importDefinition('A').replaceAll('Imported hours', 'Changed A'),
          importDefinition('B').replaceAll('Imported hours', 'Changed B'),
        ],
      );
      await expectLater(
        service.replaceAvailabilityFromImport(input),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await generation(), gen);
      expect((await service.getAvailability(first.id)).revision, 1);
      policy.denyReplacementId = null;
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: second.id,
          expectedRevision: 1,
          content: second.content.copyWith(summary: 'Local B'),
        ),
      );
      final changedSecond = await service.getAvailability(second.id);
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput(
            [first, changedSecond],
            [
              importDefinition('A').replaceAll('Imported hours', 'Changed A'),
              importDefinition('B'),
            ],
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await service.getAvailability(first.id)).revision, 1);
    });
    test('availability replacement final organizer removal approval and policy epoch changes fail closed', () async {
      final rule = await importedRule(
        definition: importDefinition(
          'update-source',
          extra: 'ORGANIZER:mailto:source@example.invalid',
        ),
      );
      policy.denyFinalOrganizer = true;
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput([rule], [importDefinition('update-source')]),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        policy.organizerRequest!.currentAvailability!.content.organizer,
        isNotNull,
      );
      expect(policy.organizerRequest!.proposedAvailability!.organizer, isNull);
      policy.denyFinalOrganizer = false;
      policy.onFinal = () => policy.epoch = 'changed';
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput([rule], [importDefinition('update-source')]),
        ),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test('availability replacement stale and exact file/selection mismatch requests reject', () async {
      final rule = await importedRule();
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput(
            [rule],
            [importDefinition('update-source')],
            parentRevision: 2,
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput(
            [rule.copyWith(revision: 2)],
            [importDefinition('update-source')],
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput([rule], [importDefinition('Other')]),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput(
            [rule],
            [importDefinition('update-source'), importDefinition('Extra')],
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      final other = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput(
            [rule],
            [importDefinition('update-source')],
          ).copyWith(calendarId: other),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('availability replacement receipts use final decisions and no-op snapshots exclude baseline payload', () async {
      final rule = await importedRule();
      CalendarAuthorizationRequest? finalRequest;
      policy.onReplacement = (request, phase) {
        if (request.availabilityReplacement != null &&
            phase == CalendarAuthorizationPhase.finalWrite) {
          finalRequest = request;
          expect(
            () => request.availabilityReplacement!.members.clear(),
            throwsUnsupportedError,
          );
        }
      };
      policy.hideReplacementReceipt = true;
      final result = await service.replaceAvailabilityFromImport(
        replaceInput([rule], [importDefinition('update-source')]),
      );
      expect(result.receipts, isEmpty);
      final member = finalRequest!.availabilityReplacement!.members.single;
      expect(member.changed, isFalse);
      expect(member.localChanges, isFalse);
      expect(member.baselineProfile, isNotNull);
    });
    test('availability replacement deletion scrubs private baseline and incompatible baselines reject', () async {
      final rule = await importedRule();
      final row = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(rule.id),
      ))!;
      await CalendarAvailabilityDataRecord.db.updateRow(
        session,
        row.copyWith(
          importBaseline: row.importBaseline!.copyWith(profile: 'unknown'),
        ),
      );
      await expectLater(
        service.replaceAvailabilityFromImport(
          replaceInput([rule], [importDefinition('update-source')]),
        ),
        failure(CalendarFailureCode.unavailable),
      );
      await service.deleteAvailability(rule.id, 1);
      expect(
        await CalendarAvailabilityDataRecord.db.findById(session, row.id!),
        isNull,
      );
      final marker = (await CalendarAvailabilityRecord.db.findById(
        session,
        rule.id,
      ))!;
      expect(marker.deletedAt, isNotNull);
    });

    test('source storage preserves protocol dates metadata PERIOD calculation and native edit retention', () async {
      var rule = await storedSource();
      final initial = rule.protocolState.toJson();
      expect(rule.lastModified, isNull);
      expect(rule.content.categoryGroups!.first.values, ['One', 'One']);
      expect(
        (await service.listAvailability(
          rule.calendarId,
          category: 'Två',
        )).single.id,
        rule.id,
      );
      expect(
        (await service.listAvailability(
          rule.calendarId,
          category: 'Öppet',
        )).single.id,
        rule.id,
      );
      expect(
        await service.listAvailability(rule.calendarId, category: 'två'),
        isEmpty,
      );
      policy.denied.add(CalendarPermission.readAvailability);
      expect(
        await service.listAvailability(rule.calendarId, category: 'Två'),
        isEmpty,
      );
      policy.denied.clear();
      final data = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(rule.id),
      ))!;
      expect(data.createdAt.year, 2026);
      expect(rule.protocolState.stamp, DateTime.utc(2040));
      final groups = rule.content.categoryGroups!
          .map((g) => g.toJson())
          .toList();
      final openingId = rule.content.openings.single.uid;
      await service.updateAvailability(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(
            categoryGroups: null,
            contacts: null,
            openings: [
              rule.content.openings.single.copyWith(
                categoryGroups: null,
                contacts: null,
                periods: null,
                protocolUid: null,
              ),
            ],
          ),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.protocolState.toJson(), initial);
      expect(
        rule.content.categoryGroups!.map((g) => g.toJson()).toList(),
        groups,
      );
      expect(rule.content.contacts!.single.value, 'Desk');
      expect(rule.content.openings.single.uid, openingId);
      expect(
        rule.content.openings.single.contacts!.single.value,
        'Opening desk',
      );
      expect(rule.content.openings.single.periods!.single.duration!.hours, 2);
      expect(
        policy
            .lastAvailabilityRequest!
            .currentAvailability!
            .content
            .contacts!
            .single
            .value,
        'Desk',
      );
      final preview = await service.previewAvailabilityOccurrences(
        CalendarAvailabilityOccurrenceQuery(
          availabilityId: rule.id,
          openingUid: openingId!,
          expectedRevision: rule.revision,
          fromUtc: DateTime.utc(2026, 10, 23),
          untilUtc: DateTime.utc(2026, 10, 24),
        ),
      );
      expect(
        preview.occurrences.single.endUtc!
            .difference(preview.occurrences.single.startUtc!)
            .inHours,
        2,
      );
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(summary: 'Local name'),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.protocolState.sequence, 18);
      expect(rule.protocolState.stamp, DateTime.utc(2040));
      expect(rule.protocolState.created, isNull);
      expect(
        rule.content.contacts!.single.alternativeUri,
        'cid:desk@example.invalid',
      );
    });
    test('source CONTACT and protocol opening identity cannot be authored or altered natively', () async {
      final rule = await storedSource();
      for (final content in [
        rule.content.copyWith(
          contacts: [CalendarAvailabilityText(value: 'Changed')],
        ),
        rule.content.copyWith(contacts: []),
        rule.content.copyWith(
          openings: [
            rule.content.openings.single.copyWith(protocolUid: 'changed'),
          ],
        ),
        rule.content.copyWith(
          openings: [
            rule.content.openings.single.copyWith(
              contacts: [CalendarAvailabilityText(value: 'Changed')],
            ),
          ],
        ),
      ]) {
        await expectLater(
          service.updateAvailabilityMetadata(
            CalendarAvailabilityUpdateRequest(
              availabilityId: rule.id,
              expectedRevision: rule.revision,
              content: content,
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
      }
      final after = await service.getAvailability(rule.id);
      expect(after.revision, rule.revision);
      expect(after.content.toJson(), rule.content.toJson());
      await expectLater(
        service.createAvailability(
          CalendarAvailabilityCreateRequest(
            calendarId: rule.calendarId,
            content: CalendarAvailabilityContent(
              openings: [],
              contacts: [CalendarAvailabilityText(value: 'Native contact')],
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
    });
    test('source metadata policy denial and stale writes leave all retained data intact', () async {
      final rule = await storedSource();
      final command = CalendarAvailabilityUpdateRequest(
        availabilityId: rule.id,
        expectedRevision: rule.revision,
        content: rule.content.copyWith(summary: 'Changed'),
      );
      policy.denyFinal = true;
      await expectLater(
        service.updateAvailabilityMetadata(command),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      await expectLater(
        service.updateAvailabilityMetadata(
          command.copyWith(expectedRevision: 99),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      final after = await service.getAvailability(rule.id);
      expect(after.revision, rule.revision);
      expect(after.protocolState.toJson(), rule.protocolState.toJson());
      expect(after.content.toJson(), rule.content.toJson());
    });
    test('long source UID storage allows independent destination copies and deletion scrubs active state', () async {
      final uid = '界' * 4096;
      final first = await storedSource(uid: uid);
      final second = await storedSource(uid: uid);
      expect(second.calendarId, isNot(first.calendarId));
      expect(second.id, isNot(first.id));
      expect(second.protocolUid, first.protocolUid);
      expect(
        second.content.openings.single.uid,
        isNot(first.content.openings.single.uid),
      );
      await service.deleteAvailability(first.id, first.revision);
      expect(
        await CalendarAvailabilityDataRecord.db.findFirstRow(
          session,
          where: (t) => t.availabilityId.equals(first.id),
        ),
        isNull,
      );
      final marker = (await CalendarAvailabilityRecord.db.findById(
        session,
        first.id,
      ))!;
      expect(marker.deletedAt, isNotNull);
      expect((await service.getAvailability(second.id)).protocolUid, uid);
    });
    test('UID candidate index permits digest collisions while equality remains exact', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final a = await storedSource(parent: calendar, uid: 'A');
      final b = await storedSource(parent: calendar, uid: 'B');
      final row = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(b.id),
      ))!;
      final digest = availabilityUidDigest(a.protocolUid);
      // Inject a collision only into this candidate-index test, then restore it.
      await CalendarAvailabilityDataRecord.db.updateRow(
        session,
        row.copyWith(uidDigest: digest),
      );
      try {
        final candidates = await CalendarAvailabilityDataRecord.db.find(
          session,
          where: (t) =>
              t.calendarId.equals(calendar) & t.uidDigest.equals(digest),
        );
        expect(candidates, hasLength(2));
        expect(
          availabilityUidConflicts('A', candidates.map((v) => v.protocolUid)),
          isTrue,
        );
        expect(
          availabilityUidConflicts('B', candidates.map((v) => v.protocolUid)),
          isTrue,
        );
        expect(
          availabilityUidConflicts('C', candidates.map((v) => v.protocolUid)),
          isFalse,
        );
      } finally {
        await CalendarAvailabilityDataRecord.db.updateRow(session, row);
      }
    });
    test(
      'source-only echoes cannot disclose equality without raw read authority',
      () async {
        var rule = await storedSource();
        final opening = rule.content.openings.single;
        final bare = rule.content.copyWith(
          contacts: null,
          openings: [opening.copyWith(contacts: null, protocolUid: null)],
        );
        policy.denied.add(CalendarPermission.readAvailability);
        for (final content in [
          bare.copyWith(contacts: rule.content.contacts),
          bare.copyWith(contacts: [CalendarAvailabilityText(value: 'Guess')]),
          bare.copyWith(
            openings: [
              bare.openings.single.copyWith(protocolUid: opening.protocolUid),
            ],
          ),
          bare.copyWith(
            openings: [bare.openings.single.copyWith(protocolUid: 'Guess')],
          ),
        ]) {
          await expectLater(
            service.updateAvailabilityMetadata(
              CalendarAvailabilityUpdateRequest(
                availabilityId: rule.id,
                expectedRevision: rule.revision,
                content: content,
              ),
            ),
            failure(CalendarFailureCode.accessDenied),
          );
        }
        final receipt = await service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: bare.copyWith(summary: 'Write-only edit'),
          ),
        );
        expect(receipt, isNotNull);
        policy.denied.clear();
        rule = await service.getAvailability(rule.id);
        expect(rule.revision, 2);
        expect(rule.content.contacts!.single.value, 'Desk');
        expect(rule.content.openings.single.protocolUid, opening.protocolUid);
      },
    );
    test('source-only echo rights are rechecked at final write without changing receipt rights', () async {
      var rule = await storedSource();
      final command = CalendarAvailabilityUpdateRequest(
        availabilityId: rule.id,
        expectedRevision: rule.revision,
        content: rule.content.copyWith(summary: 'Changed'),
      );
      policy.onFinal = () =>
          policy.denied.add(CalendarPermission.readAvailability);
      await expectLater(
        service.updateAvailabilityMetadata(command),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.onFinal = null;
      policy.denied.clear();
      expect((await service.getAvailability(rule.id)).revision, rule.revision);
      final receipt = await service.updateAvailabilityMetadata(command);
      expect(receipt, isNotNull);
      rule = await service.getAvailability(rule.id);
      expect(rule.revision, 2);
    });
    test('group and PERIOD clear require explicit empty lists and metadata authority', () async {
      var rule = await storedSource();
      policy.denied.add(CalendarPermission.updateAvailabilityMetadata);
      await expectLater(
        service.updateAvailability(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content.copyWith(categoryGroups: []),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      await service.updateAvailability(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(
            categoryGroups: [],
            openings: [rule.content.openings.single.copyWith(periods: [])],
          ),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.content.categoryGroups, isNull);
      expect(rule.content.openings.single.periods, isNull);
      expect(rule.content.contacts!.single.value, 'Desk');
    });

    test('lifecycle protocol versions distinguish identical saves metadata and opening changes', () async {
      var rule = await editableHours();
      final initial = rule.protocolState.toJson();
      expect(rule.protocolState.sequence, 0);
      expect(rule.protocolState.openings.single.created, isNotNull);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content,
        ),
      );
      expect(
        policy.lastAvailabilityRequest!.proposedAvailabilityProtocolState!
            .toJson(),
        initial,
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.revision, 2);
      expect(rule.protocolState.toJson(), initial);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(description: 'Changed metadata'),
        ),
      );
      expect(
        policy
            .lastAvailabilityRequest!
            .proposedAvailabilityProtocolState!
            .sequence,
        1,
      );
      rule = await service.getAvailability(rule.id);
      expect(
        rule.protocolState.openings.single.toJson(),
        (initial['openings'] as List).single,
      );
      expect(rule.lastModified, rule.protocolState.stamp);
      final before = rule.protocolState.toJson();
      policy.denyFinal = true;
      await expectLater(
        service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content.copyWith(description: 'Denied'),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      expect(
        (await service.getAvailability(rule.id)).protocolState.toJson(),
        before,
      );
      await expectLater(
        service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: 1,
            content: rule.content,
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      expect(
        () => policy
            .lastAvailabilityRequest!
            .currentAvailability!
            .protocolState
            .openings
            .clear(),
        throwsUnsupportedError,
      );
    });
    test('lifecycle occurrence mutations advance protocol once while redundant skips preserve it', () async {
      var rule = await editableHours();
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      expect(
        policy
            .lastAvailabilityRequest!
            .proposedAvailabilityProtocolState!
            .sequence,
        1,
      );
      rule = await service.getAvailability(rule.id);
      final state = rule.protocolState.toJson();
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.protocolState.toJson(), state);
      expect(rule.revision, 3);
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.restoreSingle),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.protocolState.sequence, 2);
    });
    test('lifecycle legacy baseline does not write on reads or invent opening creation', () async {
      var rule = await editableHours();
      var data = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(rule.id),
      ))!;
      data = data.copyWith(
        protocolState: null,
        createdAt: DateTime.utc(2020),
        updatedAt: DateTime.utc(2021),
      );
      await CalendarAvailabilityDataRecord.db.updateRow(session, data);
      rule = await service.getAvailability(rule.id);
      expect(rule.protocolState.created, DateTime.utc(2020));
      expect(rule.protocolState.stamp, DateTime.utc(2021));
      expect(rule.protocolState.openings.single.created, isNull);
      final stored = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(rule.id),
      ))!;
      expect(stored.protocolState, isNull);
      expect(stored.updatedAt, data.updatedAt);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(description: 'Envelope only'),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        rule.protocolState.openings.single.lastModified,
        DateTime.utc(2021),
      );
      expect(rule.protocolState.openings.single.created, isNull);
      await service.updateAvailability(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(
            openings: [
              ...rule.content.openings,
              rule.content.openings.single.copyWith(
                uid: null,
                protocolUid: null,
              ),
            ],
          ),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.protocolState.openings.last.created, isNotNull);
      expect(rule.protocolState.sequence, 2);
    });
    test('lifecycle envelope duration clips free busy and requires structural authority', () async {
      var rule = await editableHours();
      final next = rule.content.copyWith(
        openings: [],
        validFrom: CalendarEventTiming(
          kind: CalendarEventTimeKind.utc,
          start: CalendarEventCivil(year: 2026, month: 3, day: 29, hour: 8),
        ),
        validDuration: CalendarEventDuration(hours: 1),
      );
      final request = CalendarAvailabilityUpdateRequest(
        availabilityId: rule.id,
        expectedRevision: rule.revision,
        content: next,
      );
      await expectLater(
        service.updateAvailabilityMetadata(request),
        failure(CalendarFailureCode.validation),
      );
      policy.denied.add(CalendarPermission.updateAvailability);
      await expectLater(
        service.updateAvailability(request),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      await service.updateAvailability(request);
      rule = await service.getAvailability(rule.id);
      expect(rule.content.validDuration!.hours, 1);
      expect(rule.content.validUntil, isNull);
      final result = await service.freeBusy(
        CalendarFreeBusyQuery(
          calendarId: rule.calendarId,
          fromUtc: DateTime.utc(2026, 3, 29),
          untilUtc: DateTime.utc(2026, 3, 30),
        ),
      );
      expect(result.coverage, CalendarFreeBusyCoverage.complete);
      expect(result.periods.map((p) => p.kind), [
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.unavailable,
        CalendarFreeBusyKind.free,
      ]);
      expect(result.periods[1].startUtc, DateTime.utc(2026, 3, 29, 8));
      expect(result.periods[1].endUtc, DateTime.utc(2026, 3, 29, 9));
      expect(result.toJson().toString(), isNot(contains('sequence')));
    });
    test(
      'lifecycle sequence overflow cannot partially change active state',
      () async {
        var rule = await editableHours();
        final data = (await CalendarAvailabilityDataRecord.db.findFirstRow(
          session,
          where: (t) => t.availabilityId.equals(rule.id),
        ))!;
        await CalendarAvailabilityDataRecord.db.updateRow(
          session,
          data.copyWith(
            protocolState: data.protocolState!.copyWith(sequence: 2147483647),
          ),
        );
        rule = await service.getAvailability(rule.id);
        await expectLater(
          service.updateAvailabilityMetadata(
            CalendarAvailabilityUpdateRequest(
              availabilityId: rule.id,
              expectedRevision: rule.revision,
              content: rule.content.copyWith(description: 'Overflow'),
            ),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(
          (await service.getAvailability(rule.id)).revision,
          rule.revision,
        );
        await service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content,
          ),
        );
        expect(
          (await service.getAvailability(rule.id)).protocolState.sequence,
          2147483647,
        );
      },
    );
    test('publication organizer creation denial and adapter timeout leave no active data', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final input = CalendarAvailabilityCreateRequest(
        calendarId: parent,
        content: hours().copyWith(
          organizer: CalendarAvailabilityOrganizer(
            address: 'mailto:alice@example.invalid',
          ),
        ),
      );
      policy.denyFinalOrganizer = true;
      await expectLater(
        service.createAvailability(input),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await service.listAvailability(parent), isEmpty);
      policy.denyFinalOrganizer = false;
      policy.organizerDelay = const Duration(milliseconds: 100);
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          policyTimeout: Duration(milliseconds: 20),
        ),
      );
      service = CalendarModule.service(session);
      await expectLater(
        service.createAvailability(input),
        failure(CalendarFailureCode.unavailable),
      );
      policy.organizerDelay = Duration.zero;
      expect(await service.listAvailability(parent), isEmpty);
    });
    test(
      'publication organizer approval is independent, final checked and atomic',
      () async {
        var rule = await editableHours();
        final proposed = rule.content.copyWith(
          organizer: CalendarAvailabilityOrganizer(
            address: 'mailto:alice@example.invalid',
            commonName: 'Åsa',
            language: 'SV',
          ),
        );
        CalendarAvailabilityUpdateRequest request() =>
            CalendarAvailabilityUpdateRequest(
              availabilityId: rule.id,
              expectedRevision: rule.revision,
              content: proposed,
            );
        policy.denyOrganizer = true;
        await expectLater(
          service.updateAvailabilityMetadata(request()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await service.getAvailability(rule.id)).revision,
          rule.revision,
        );
        policy.denyOrganizer = false;
        policy.denyFinalOrganizer = true;
        await expectLater(
          service.updateAvailabilityMetadata(request()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await service.getAvailability(rule.id)).content.organizer,
          isNull,
        );
        policy.denyFinalOrganizer = false;
        policy.organizerUnavailable = true;
        await expectLater(
          service.updateAvailabilityMetadata(request()),
          failure(CalendarFailureCode.unavailable),
        );
        policy.organizerUnavailable = false;
        policy.denied.add(CalendarPermission.updateAvailabilityMetadata);
        final calls = policy.organizerPhases.length;
        await expectLater(
          service.updateAvailabilityMetadata(request()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(policy.organizerPhases.length, calls);
        policy.denied.clear();
        await service.updateAvailabilityMetadata(request());
        expect(
          policy.organizerPhases.last,
          CalendarAuthorizationPhase.finalWrite,
        );
        expect(policy.organizerRequest!.calendarId, rule.calendarId);
        expect(
          policy.organizerRequest!.currentAvailability!.availabilityId,
          rule.id,
        );
        expect(
          policy.organizerRequest!.proposedAvailability!.organizer!.commonName,
          'Åsa',
        );
        rule = await service.getAvailability(rule.id);
        expect(rule.content.organizer!.language, 'SV');
        policy.denyOrganizer = true;
        await expectLater(
          service.updateAvailabilityMetadata(
            CalendarAvailabilityUpdateRequest(
              availabilityId: rule.id,
              expectedRevision: rule.revision,
              content: rule.content.copyWith(organizer: null),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await service.getAvailability(rule.id)).content.organizer,
          isNotNull,
        );
      },
    );
    test('publication extension registry rejects names contexts values and failures atomically', () async {
      var rule = await editableHours();
      CalendarAvailabilityContent withExtension(String name, String value) =>
          rule.content.copyWith(
            extensions: [
              CalendarAvailabilityExtension(name: name, value: value),
            ],
          );
      Future<void> update(CalendarAvailabilityContent content) async {
        await service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: content,
          ),
        );
      }

      await expectLater(
        update(withExtension('X-HOST-LABEL', 'OK')),
        failure(CalendarFailureCode.validation),
      );
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        availabilityExtensions: [
          CalendarAvailabilityExtensionRegistration(
            name: 'X-HOST-LABEL',
            contexts: [CalendarAvailabilityExtensionContext.definition],
            validate: (v) {
              if (v == 'FAIL') throw StateError('Synthetic validator failure');
              return v == 'OK';
            },
          ),
        ],
      );
      service = CalendarModule.service(session);
      await expectLater(
        update(withExtension('X-HOST-LABEL', 'BAD')),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        update(withExtension('X-HOST-LABEL', 'FAIL')),
        failure(CalendarFailureCode.unavailable),
      );
      await expectLater(
        update(
          rule.content.copyWith(
            openings: [
              rule.content.openings.single.copyWith(
                extensions: [
                  CalendarAvailabilityExtension(
                    name: 'X-HOST-LABEL',
                    value: 'OK',
                  ),
                ],
              ),
            ],
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect((await service.getAvailability(rule.id)).revision, rule.revision);
      await update(withExtension('x-host-label', 'OK'));
      rule = await service.getAvailability(rule.id);
      expect(rule.content.extensions!.single.name, 'x-host-label');
      expect(
        () => policy
            .lastAvailabilityRequest!
            .currentAvailability!
            .content
            .extensions!
            .clear(),
        throwsUnsupportedError,
      );
    });
    test('publication annotations survive timing edits and stay out of busy summaries', () async {
      var rule = await editableHours();
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(
            summary: 'Private annotated hours',
            comments: ['One', 'Two'],
            textParameters: CalendarAvailabilityTextParameters(
              summary: CalendarTextParameters(
                language: 'SV',
                alternativeUri: 'cid:private@example.invalid',
              ),
              comments: [
                CalendarTextParameters(language: 'en'),
                CalendarTextParameters(language: 'sv'),
              ],
            ),
          ),
        ),
      );
      rule = await service.getAvailability(rule.id);
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.content.textParameters!.comments![1]!.language, 'sv');
      expect(
        rule.content.textParameters!.summary!.alternativeUri,
        'cid:private@example.invalid',
      );
      await service.updateAvailability(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(priority: 1),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.content.textParameters!.summary!.language, 'SV');
      final result = await service.freeBusy(
        CalendarFreeBusyQuery(
          calendarId: rule.calendarId,
          fromUtc: DateTime.utc(2026, 3, 29),
          untilUtc: DateTime.utc(2026, 3, 30),
        ),
      );
      expect(result.coverage, CalendarFreeBusyCoverage.complete);
      expect(
        result.toJson().toString(),
        isNot(contains('private@example.invalid')),
      );
      await expectLater(
        service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision - 1,
            content: rule.content,
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
    });
    test('opening lifecycle preserves single and future edits through metadata and rejects orphaning pattern changes', () async {
      var rule = await editableHours();
      final uid = rule.content.openings.single.uid;
      final replacement = rule.content.openings.single.timing.copyWith(
        start: CalendarEventCivil(year: 2026, month: 3, day: 29, hour: 10),
        end: CalendarEventCivil(year: 2026, month: 3, day: 29, hour: 18),
      );
      await service.changeAvailabilityOccurrence(
        openingChange(
          rule,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: replacement,
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        (await service.previewAvailabilityOccurrences(openingQuery(rule)))
            .occurrences
            .first
            .start
            .hour,
        10,
      );
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        (await service.previewAvailabilityOccurrences(openingQuery(rule)))
            .occurrences,
        hasLength(2),
      );
      expect(
        (await service.freeBusy(busyQuery(rule.calendarId)))
            .periods
            .single
            .kind,
        CalendarFreeBusyKind.unavailable,
      );
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(description: 'Preserved notes'),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        rule.timingOverrides!.single.overrides.singles.single.cancelled,
        isTrue,
      );
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.restoreSingle),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        (await service.freeBusy(busyQuery(rule.calendarId)))
            .periods[1]
            .startUtc
            .hour,
        10,
      );
      expect(rule.content.openings.single.uid, uid);
      await expectLater(
        service.updateAvailability(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content.copyWith(
              openings: [
                rule.content.openings.single.copyWith(
                  recurrence: rule.content.openings.single.recurrence!.copyWith(
                    exclusions: [
                      rule.content.openings.single.timing.copyWith(
                        end: null,
                        duration: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.clearSingleTiming),
      );
      rule = await service.getAvailability(rule.id);
      await service.changeAvailabilityOccurrence(
        openingChange(
          rule,
          CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: replacement,
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        (await service.previewAvailabilityOccurrences(openingQuery(rule)))
            .occurrences
            .map((o) => o.start.hour),
        [10, 10, 10],
      );
      expect(
        policy.lastAvailabilityRequest!.currentAvailability!.timingOverrides,
        isNotNull,
      );
    });
    test('opening mutation and preview enforce independent rights current revision and complete host intent', () async {
      var rule = await editableHours();
      policy.denied.add(CalendarPermission.changeAvailabilityOccurrence);
      await expectLater(
        service.changeAvailabilityOccurrence(
          openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.denyFinal = true;
      await expectLater(
        service.changeAvailabilityOccurrence(
          openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      expect((await service.getAvailability(rule.id)).timingOverrides, isNull);
      policy.denied.add(CalendarPermission.previewAvailabilityOccurrences);
      await expectLater(
        service.previewAvailabilityOccurrences(openingQuery(rule)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      final old = openingQuery(rule);
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      await expectLater(
        service.previewAvailabilityOccurrences(old),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.changeAvailabilityOccurrence(
          openingChange(rule, CalendarEventOccurrenceAction.restoreSingle),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      rule = await service.getAvailability(rule.id);
      expect(policy.lastAvailabilityRequest!.calendarId, rule.calendarId);
      expect(policy.lastAvailabilityRequest!.availabilityId, rule.id);
      expect(
        () => rule.timingOverrides!.single.overrides.singles.clear(),
        throwsUnsupportedError,
      );
    });
    test('availability metadata is separate authority with exact authorized category search and no availability side effects', () async {
      var rule = await editableHours();
      final before = await service.freeBusy(busyQuery(rule.calendarId));
      final next = rule.content.copyWith(
        description: '  Notes\n',
        location: 'Private room',
        categories: ['Work', 'work', 'Work'],
        comments: ['one\ntwo', 'three'],
        url: 'https://example.invalid/info',
        classification: CalendarAvailabilityClass.confidential,
        openings: [
          rule.content.openings.single.copyWith(
            summary: 'Opening label',
            categories: ['Opening'],
          ),
        ],
      );
      policy.denied.add(CalendarPermission.updateAvailabilityMetadata);
      await expectLater(
        service.updateAvailability(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: next,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.denied.add(CalendarPermission.updateAvailability);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: next,
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.content.categories, ['Work', 'work']);
      expect(rule.content.comments, ['one\ntwo', 'three']);
      expect(
        (await service.freeBusy(busyQuery(rule.calendarId))).toJson(),
        before.toJson(),
      );
      expect(
        await service.listAvailability(rule.calendarId, category: 'Work'),
        hasLength(1),
      );
      expect(
        await service.listAvailability(rule.calendarId, category: 'WORK'),
        isEmpty,
      );
      expect(
        await service.listAvailability(rule.calendarId, category: 'Opening'),
        hasLength(1),
      );
      await expectLater(
        service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content.copyWith(priority: 1),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      policy.denied.add(CalendarPermission.readAvailability);
      expect(
        await service.listAvailability(rule.calendarId, category: 'Work'),
        isEmpty,
      );
      final json = (await service.freeBusy(busyQuery(rule.calendarId)))
          .toJson()
          .toString();
      expect(json, isNot(contains('Private room')));
      expect(json, isNot(contains('Opening label')));
    });
    test('deleting an opening deliberately removes its edits and invalid metadata never partially commits', () async {
      var rule = await editableHours();
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      rule = await service.getAvailability(rule.id);
      await expectLater(
        service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content.copyWith(
              url: 'https://user:password@example.invalid',
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect((await service.getAvailability(rule.id)).revision, rule.revision);
      await service.updateAvailability(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(openings: []),
        ),
      );
      expect((await service.getAvailability(rule.id)).timingOverrides, isNull);
    });

    test('availability CRUD has stable identities stale protection markers and parent dependencies', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final receipt = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      final first = await service.getAvailability(receipt.availabilityId);
      expect(first.content.openings.single.uid, isNotNull);
      expect(policy.lastAvailabilityRequest!.calendarId, calendar);
      expect(
        policy.lastAvailabilityRequest!.currentAvailability!.availabilityId,
        first.id,
      );
      await expectLater(
        service.delete(calendar, 1),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final changed = (await service.updateAvailability(
        CalendarAvailabilityUpdateRequest(
          availabilityId: first.id,
          expectedRevision: 1,
          content: first.content.copyWith(summary: 'New hours'),
        ),
      ))!;
      expect(changed.revision, 2);
      final second = await service.getAvailability(first.id);
      expect(second.protocolUid, first.protocolUid);
      expect(
        second.content.openings.single.uid,
        first.content.openings.single.uid,
      );
      expect(second.lastModified!.millisecond, 0);
      await expectLater(
        service.updateAvailability(
          CalendarAvailabilityUpdateRequest(
            availabilityId: first.id,
            expectedRevision: 1,
            content: first.content,
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      expect(await service.listAvailability(calendar), hasLength(1));
      await service.deleteAvailability(first.id, 2);
      expect(await service.listAvailability(calendar), isEmpty);
      expect(
        (await CalendarAvailabilityRecord.db.findById(
          session,
          first.id,
        ))!.deletedAt,
        isNotNull,
      );
      expect(
        await CalendarAvailabilityDataRecord.db.findFirstRow(
          session,
          where: (t) => t.availabilityId.equals(first.id),
        ),
        isNull,
      );
      await service.delete(calendar, 1);
    });
    test('availability rules replace fallback and higher priority closures do not erase bookings', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final rule = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      await booking(calendar, 10, 11);
      final result = await service.freeBusy(busyQuery(calendar));
      expect(result.coverage, CalendarFreeBusyCoverage.complete);
      expect(result.periods.map((p) => p.kind), [
        CalendarFreeBusyKind.unavailable,
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.busy,
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.unavailable,
      ]);
      expect(result.periods[1].startUtc, DateTime.utc(2026, 3, 29, 9));
      expect(
        result.toJson().toString(),
        isNot(contains('Private working hours')),
      );
      final closure = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(priority: 5, closed: true),
        ),
      ))!;
      expect(
        (await service.freeBusy(busyQuery(calendar))).periods.single.kind,
        CalendarFreeBusyKind.unavailable,
      );
      await service.deleteAvailability(closure.availabilityId, 1);
      await service.deleteAvailability(rule.availabilityId, 1);
      expect(
        (await service.freeBusy(busyQuery(calendar))).periods.first.kind,
        CalendarFreeBusyKind.free,
      );
    });
    test('availability raw disclosure is independent from complete projection; denial yields unknown', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final rule = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      policy.denied.add(CalendarPermission.readAvailability);
      await expectLater(
        service.getAvailability(rule.availabilityId),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await service.listAvailability(calendar), isEmpty);
      expect(
        (await service.freeBusy(busyQuery(calendar))).coverage,
        CalendarFreeBusyCoverage.complete,
      );
      policy.denied.add(CalendarPermission.projectAvailability);
      final result = await service.freeBusy(busyQuery(calendar));
      expect(result.coverage, CalendarFreeBusyCoverage.unknown);
      expect(result.periods, isEmpty);
    });
    test('availability update denial is atomic frozen and cannot cross scopes or spoof opening identities', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final receipt = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      final first = await service.getAvailability(receipt.availabilityId);
      policy.onPreliminary = () {
        expect(
          () => policy.lastAvailabilityRequest!.proposedAvailability!.openings
              .clear(),
          throwsUnsupportedError,
        );
        policy.denied.add(CalendarPermission.updateAvailability);
      };
      await expectLater(
        service.updateAvailability(
          CalendarAvailabilityUpdateRequest(
            availabilityId: first.id,
            expectedRevision: 1,
            content: first.content,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.onPreliminary = null;
      policy.denied.clear();
      expect((await service.getAvailability(first.id)).revision, 1);
      await expectLater(
        service.createAvailability(
          CalendarAvailabilityCreateRequest(
            calendarId: calendar,
            content: first.content,
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      policy.scopeOverride = 'other';
      await expectLater(
        service.getAvailability(first.id),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.createAvailability(
          CalendarAvailabilityCreateRequest(
            calendarId: calendar,
            content: hours(),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });

    test('availability named-zone hours survive calendar zone changes and source caps never imply free', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final input = hours().copyWith(
        openings: [
          CalendarAvailabilityOpening(
            timing: hours().openings.single.timing.copyWith(
              kind: CalendarEventTimeKind.zoned,
              zoneId: 'Europe/Stockholm',
            ),
          ),
        ],
      );
      await service.createAvailability(
        CalendarAvailabilityCreateRequest(calendarId: calendar, content: input),
      );
      final before = await service.freeBusy(busyQuery(calendar));
      await service.updateSettings(
        CalendarSettingsUpdateRequest(
          calendarId: calendar,
          expectedRevision: 1,
          availabilityZoneId: 'America/New_York',
          noRuleFallback: CalendarNoRuleFallback.free,
        ),
      );
      expect(
        (await service.freeBusy(busyQuery(calendar))).toJson(),
        before.toJson(),
      );
      expect(before.periods[1].startUtc, DateTime.utc(2026, 3, 29, 7));
      for (var n = 0; n < 4; n++) {
        await service.createAvailability(
          CalendarAvailabilityCreateRequest(
            calendarId: calendar,
            content: hours().copyWith(
              openings: List.generate(16, (_) => hours().openings.single),
            ),
          ),
        );
      }
      final limited = await service.freeBusy(busyQuery(calendar));
      expect(limited.coverage, CalendarFreeBusyCoverage.unknown);
      expect(limited.periods, isEmpty);
    });

    String busyText(ByteData bytes) => utf8.decode(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    List<IcalendarSyntaxProperty> busyProperties(String text) =>
        parseIcalendarSyntax(utf8.encode(text)).components.single.entries
            .whereType<IcalendarSyntaxComponent>()
            .single
            .entries
            .whereType<IcalendarSyntaxProperty>()
            .toList();

    test('free busy export includes classified UTC bookings and hours without details or identities', () async {
      final calendar = (await service.create(createInput('Private calendar')))!
          .calendarId;
      final event = await booking(calendar, 9, 10);
      await booking(calendar, 10, 11, status: CalendarEventStatus.tentative);
      await booking(
        calendar,
        12,
        13,
        transparency: CalendarEventTransparency.transparent,
      );
      await booking(calendar, 14, 15, status: CalendarEventStatus.cancelled);
      final rule = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      final before = (await service.get(calendar, groups)).toJson();
      final eventBefore = (await service.getEvent(
        event.eventId,
        eventGroups,
      )).toJson();
      final ruleBefore = (await service.getAvailability(rule.availabilityId))
          .toJson();
      final scopeBefore = (await CalendarScopeRecord.db.find(session))
          .map((r) => r.toJson())
          .toList();
      policy.denied.addAll([
        CalendarPermission.read,
        CalendarPermission.readEvent,
        CalendarPermission.listEvents,
        CalendarPermission.readAvailability,
      ]);
      policy.eventCandidates = {};
      final text = busyText(await service.exportFreeBusy(busyQuery(calendar)));
      final periods = busyProperties(text)
          .where((p) => p.name == 'FREEBUSY')
          .toList();
      expect(periods.map((p) => p.parameters.single.values.single), [
        'BUSY-UNAVAILABLE',
        'BUSY',
        'BUSY-TENTATIVE',
        'BUSY-UNAVAILABLE',
      ]);
      expect(periods.map((p) => p.value), [
        '20260329T000000Z/20260329T090000Z',
        '20260329T090000Z/20260329T100000Z',
        '20260329T100000Z/20260329T110000Z',
        '20260329T170000Z/20260330T000000Z',
      ]);
      for (final private in [
        'Private',
        calendar.toString(),
        event.eventId.toString(),
        rule.availabilityId.toString(),
        'Europe/Stockholm',
        'SUMMARY:',
        'LOCATION:',
        'ORGANIZER:',
        'ATTENDEE:',
        'RRULE:',
        'METHOD:',
        'VTIMEZONE',
      ]) {
        expect(text, isNot(contains(private)));
      }
      policy.denied.clear();
      expect((await service.get(calendar, groups)).toJson(), before);
      expect(
        (await service.getEvent(event.eventId, eventGroups)).toJson(),
        eventBefore,
      );
      expect(
        (await service.getAvailability(rule.availabilityId)).toJson(),
        ruleBefore,
      );
      expect(
        (await CalendarScopeRecord.db.find(session))
            .map((r) => r.toJson())
            .toList(),
        scopeBefore,
      );
    });
    test('free busy export all-free snapshots use unrelated fresh UIDs and database UTC stamps', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final a = busyProperties(
        busyText(await service.exportFreeBusy(busyQuery(calendar))),
      );
      final b = busyProperties(
        busyText(await service.exportFreeBusy(busyQuery(calendar))),
      );
      String value(List<IcalendarSyntaxProperty> p, String name) =>
          p.singleWhere((p) => p.name == name).value;
      expect(value(a, 'UID'), isNot(value(b, 'UID')));
      expect(value(a, 'UID'), isNot(calendar.toString()));
      expect(a.where((p) => p.name == 'FREEBUSY'), isEmpty);
      expect(value(a, 'DTSTAMP'), matches(RegExp(r'^\d{8}T\d{6}Z$')));
    });
    test(
      'free busy export has independent export and query authority',
      () async {
        final calendar = (await service.create(createInput()))!.calendarId;
        policy.denied.add(CalendarPermission.exportFreeBusy);
        expect(
          (await service.freeBusy(busyQuery(calendar))).coverage,
          CalendarFreeBusyCoverage.complete,
        );
        await expectLater(
          service.exportFreeBusy(busyQuery(calendar)),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied
          ..clear()
          ..add(CalendarPermission.readFreeBusy);
        await expectLater(
          service.exportFreeBusy(busyQuery(calendar)),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test('free busy export rejects unknown source projections and cap without a partial file', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final event = await booking(calendar, 9, 10);
      await booking(calendar, 11, 12);
      policy.busyDenied.add(event.eventId);
      await expectLater(
        service.exportFreeBusy(busyQuery(calendar)),
        failure(CalendarFailureCode.unavailable),
      );
      policy.busyDenied.clear();
      await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      );
      policy.denied.add(CalendarPermission.projectAvailability);
      await expectLater(
        service.exportFreeBusy(busyQuery(calendar)),
        failure(CalendarFailureCode.unavailable),
      );
      policy.denied.clear();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          maxScannedEvents: 1,
        ),
      );
      service = CalendarModule.service(session);
      await expectLater(
        service.exportFreeBusy(busyQuery(calendar)),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test('free busy export repeats parent authority and every source projection after serialization', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      await booking(calendar, 9, 10);
      await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      );
      for (final operation in [
        CalendarPermission.exportFreeBusy,
        CalendarPermission.readFreeBusy,
        CalendarPermission.projectEventBusy,
        CalendarPermission.projectAvailability,
      ]) {
        var count = 0;
        policy.denied.clear();
        policy.onFreeBusyRequest = (r) {
          expect(r.calendarId, calendar);
          expect(r.freeBusyQuery!.fromUtc, busyQuery(calendar).fromUtc);
          if (r.operation == operation && ++count == 2) {
            policy.denied.add(operation);
          }
        };
        await expectLater(
          service.exportFreeBusy(busyQuery(calendar)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(count, 2);
      }
    });
    test('free busy export final context change and unavailable policy fail closed', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      var count = 0;
      policy.onFreeBusyRequest = (r) {
        if (r.operation == CalendarPermission.exportFreeBusy && ++count == 2) {
          policy.epoch = 'changed';
        }
      };
      await expectLater(
        service.exportFreeBusy(busyQuery(calendar)),
        failure(CalendarFailureCode.unavailable),
      );
      policy.onFreeBusyRequest = null;
      policy.unavailable = true;
      await expectLater(
        service.exportFreeBusy(busyQuery(calendar)),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test('free busy export supports one-request policy batches and unavailable fallback', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      await service.updateSettings(
        CalendarSettingsUpdateRequest(
          calendarId: calendar,
          expectedRevision: 1,
          availabilityZoneId: 'UTC',
          noRuleFallback: CalendarNoRuleFallback.unavailable,
        ),
      );
      await booking(calendar, 9, 10);
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          policyBatchSize: 1,
        ),
      );
      service = CalendarModule.service(session);
      final periods = busyProperties(
        busyText(await service.exportFreeBusy(busyQuery(calendar))),
      ).where((p) => p.name == 'FREEBUSY').toList();
      expect(
        periods.single.parameters.single.values.single,
        'BUSY-UNAVAILABLE',
      );
      expect(periods.single.value, '20260329T000000Z/20260330T000000Z');
    });
    test('free busy export expands DATE recurrence DST moves and cancellations without recurrence leakage', () async {
      final id = await recurringEvent();
      final event = await service.getEvent(id, eventGroups);
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: day(28),
        ),
      );
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.cancelSingle,
          revision: 2,
          dayNumber: 31,
        ),
      );
      final text = busyText(
        await service.exportFreeBusy(
          CalendarFreeBusyQuery(
            calendarId: event.calendarId,
            fromUtc: DateTime.utc(2026, 3, 28),
            untilUtc: DateTime.utc(2026, 4, 1),
          ),
        ),
      );
      final periods = busyProperties(text)
          .where((p) => p.name == 'FREEBUSY')
          .toList();
      expect(periods.single.value, '20260328T000000Z/20260329T220000Z');
      expect(text, isNot(contains('RRULE')));
      expect(text, isNot(contains(id.toString())));
    });
    test('free busy export validates UTC profile bounds and deleted or missing calendars', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      for (final query in [
        busyQuery(calendar).copyWith(fromUtc: DateTime(2026)),
        busyQuery(calendar).copyWith(untilUtc: DateTime.utc(2026, 5)),
        busyQuery(calendar).copyWith(fromUtc: DateTime.utc(1969)),
        busyQuery(calendar)
            .copyWith(fromUtc: DateTime.utc(2026, 3, 29, 0, 0, 0, 1)),
      ]) {
        await expectLater(
          service.exportFreeBusy(query),
          failure(CalendarFailureCode.validation),
        );
      }
      final edge = busyQuery(calendar).copyWith(
        fromUtc: DateTime.utc(2099, 12, 31),
        untilUtc: DateTime.utc(2100),
      );
      expect(
        busyText(await service.exportFreeBusy(edge)),
        contains('DTEND:21000101T000000Z'),
      );
      policy.scopeOverride = 'foreign';
      await expectLater(
        service.exportFreeBusy(busyQuery(calendar)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.scopeOverride = null;
      await service.delete(calendar, 1);
      await expectLater(
        service.exportFreeBusy(busyQuery(calendar)),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.exportFreeBusy(busyQuery(const Uuid().v4obj())),
        failure(CalendarFailureCode.accessDenied),
      );
    });

    test('free busy merges private overlapping bookings and retains tentative classification', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final first = await booking(calendar, 9, 11);
      await booking(calendar, 10, 12, status: CalendarEventStatus.tentative);
      await booking(calendar, 13, 14);
      await booking(calendar, 14, 15);
      await booking(
        calendar,
        16,
        17,
        transparency: CalendarEventTransparency.transparent,
      );
      await booking(calendar, 18, 19, status: CalendarEventStatus.cancelled);
      final before = await service.getEvent(first.eventId, eventGroups);
      final result = await service.freeBusy(busyQuery(calendar));
      expect(result.coverage, CalendarFreeBusyCoverage.complete);
      expect(result.periods.map((p) => p.kind), [
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.busy,
        CalendarFreeBusyKind.tentative,
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.busy,
        CalendarFreeBusyKind.free,
      ]);
      expect(result.periods[1].startUtc, DateTime.utc(2026, 3, 29, 9));
      expect(result.periods[1].endUtc, DateTime.utc(2026, 3, 29, 11));
      expect(result.periods[4].endUtc, DateTime.utc(2026, 3, 29, 15));
      final wire = result.toJson().toString();
      expect(wire, isNot(contains('Private')));
      expect(wire, isNot(contains(first.eventId.toString())));
      final after = await service.getEvent(first.eventId, eventGroups);
      expect(after.revision, before.revision);
      expect(after.lastModified, before.lastModified);
    });
    test('free busy is independent of detail plans; denied required projections return unknown without partial periods', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      await booking(calendar, 9, 11);
      final second = await booking(calendar, 13, 14);
      policy.denied.addAll([
        CalendarPermission.read,
        CalendarPermission.readEvent,
        CalendarPermission.listEvents,
      ]);
      policy.eventCandidates = {};
      policy.eventGrants = {};
      policy.grants = {};
      expect(
        (await service.freeBusy(busyQuery(calendar))).periods
            .where((p) => p.kind == CalendarFreeBusyKind.busy)
            .length,
        2,
      );
      expect(policy.lastEventRequest!.freeBusyQuery!.calendarId, calendar);
      expect(policy.lastEventRequest!.currentEvent!.calendarId, calendar);
      policy.busyDenied.add(second.eventId);
      final unknown = await service.freeBusy(busyQuery(calendar));
      expect(unknown.coverage, CalendarFreeBusyCoverage.unknown);
      expect(unknown.periods, isEmpty);
      policy.denied.add(CalendarPermission.readFreeBusy);
      await expectLater(
        service.freeBusy(busyQuery(calendar)),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('free busy DATE recurrence uses calendar zone, moved original identity and single cancellation', () async {
      final id = await recurringEvent();
      final view = await service.getEvent(id, eventGroups);
      final q = CalendarFreeBusyQuery(
        calendarId: view.calendarId,
        fromUtc: DateTime.utc(2026, 3, 28),
        untilUtc: DateTime.utc(2026, 4, 1),
      );
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: day(28),
        ),
      );
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.cancelSingle,
          revision: 2,
          dayNumber: 31,
        ),
      );
      final result = await service.freeBusy(q);
      final occupied = result.periods
          .where((p) => p.kind == CalendarFreeBusyKind.busy)
          .single;
      expect(occupied.startUtc, q.fromUtc);
      expect(occupied.endUtc, DateTime.utc(2026, 3, 29, 22));
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.cancelSingle,
          revision: 3,
        ),
      );
      final after = await service.freeBusy(q);
      expect(
        after.periods
            .singleWhere((p) => p.kind == CalendarFreeBusyKind.busy)
            .endUtc
            .difference(
              after.periods
                  .singleWhere((p) => p.kind == CalendarFreeBusyKind.busy)
                  .startUtc,
            ),
        const Duration(hours: 23),
      );
    });
    test('free busy uses configured no-rule fallback without pretending working-hours support', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      expect(
        (await service.freeBusy(busyQuery(calendar))).periods.single.kind,
        CalendarFreeBusyKind.free,
      );
      await service.updateSettings(
        CalendarSettingsUpdateRequest(
          calendarId: calendar,
          expectedRevision: 1,
          availabilityZoneId: 'Europe/Stockholm',
          noRuleFallback: CalendarNoRuleFallback.unavailable,
        ),
      );
      await booking(calendar, 9, 10);
      final result = await service.freeBusy(busyQuery(calendar));
      expect(result.coverage, CalendarFreeBusyCoverage.complete);
      expect(result.periods.single.kind, CalendarFreeBusyKind.unavailable);
    });
    test(
      'free busy source or recurrence caps cannot yield falsely free results',
      () async {
        final calendar = (await service.create(createInput()))!.calendarId;
        await booking(calendar, 9, 10);
        await booking(calendar, 11, 12);
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
            maxScannedEvents: 1,
          ),
        );
        service = CalendarModule.service(session);
        final limited = await service.freeBusy(busyQuery(calendar));
        expect(limited.coverage, CalendarFreeBusyCoverage.unknown);
        expect(limited.periods, isEmpty);
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          ),
        );
        // A new service observes installation options, not the previously captured runtime.
        service = CalendarModule.service(session);
        final dense = (await service.createEvent(
          CalendarEventCreateRequest(
            calendarId: calendar,
            content: CalendarEventContent(
              timing: CalendarEventTiming(
                kind: CalendarEventTimeKind.utc,
                start: CalendarEventCivil(year: 2026, month: 3, day: 29),
                duration: CalendarEventDuration(minutes: 1),
              ),
              recurrence: CalendarEventRecurrence(
                rule: daily().copyWith(
                  frequency: CalendarEventFrequency.minutely,
                  count: null,
                ),
                inclusions: [],
                exclusions: [],
              ),
            ),
          ),
        ))!;
        final unknown = await service.freeBusy(busyQuery(calendar));
        expect(unknown.coverage, CalendarFreeBusyCoverage.unknown);
        expect(unknown.periods, isEmpty);
        expect(
          (await service.getEvent(dense.eventId, eventGroups)).revision,
          1,
        );
      },
    );
    test('free busy validates UTC precision and bounded increasing windows and protects actual scope', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final q = busyQuery(calendar);
      for (final bad in [
        q.copyWith(fromUtc: DateTime(2026, 3, 29)),
        q.copyWith(fromUtc: DateTime.utc(2026, 3, 29, 0, 0, 0, 1)),
        q.copyWith(untilUtc: q.fromUtc),
        q.copyWith(untilUtc: DateTime.utc(2026, 5, 1)),
      ]) {
        await expectLater(
          service.freeBusy(bad),
          failure(CalendarFailureCode.validation),
        );
      }
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      await expectLater(
        CalendarModule.service(bobSession).freeBusy(q),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('occurrence timing persists separately; cancellation restores prior timing without master changes', () async {
      final id = await recurringEvent();
      final before = await service.getEvent(id, eventGroups);
      final parent = await service.get(before.calendarId, groups);
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: day(28),
        ),
      );
      var view = await service.getEvent(id, eventGroups);
      expect(view.timing!.start.day, 29);
      expect(view.timingOverrides!.singles.single.replacement!.start.day, 28);
      expect(
        (await service.previewOccurrences(preview(id, revision: 2)))
            .occurrences
            .first
            .originalStart
            .day,
        30,
      );
      expect(
        policy.lastEventRequest!.currentEvent!.timingOverrides!.singles.length,
        1,
      );
      expect(
        () => policy.lastEventRequest!.currentEvent!.timingOverrides!.singles
            .clear(),
        throwsUnsupportedError,
      );
      policy.denied.add(CalendarPermission.updateEvent);
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.cancelSingle,
          revision: 2,
        ),
      );
      expect(
        (await service.previewOccurrences(preview(id, revision: 3)))
            .occurrences
            .length,
        2,
      );
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.restoreSingle,
          revision: 3,
        ),
      );
      view = await service.getEvent(id, eventGroups);
      expect(view.timingOverrides!.singles.single.replacement!.start.day, 28);
      expect(view.protocolUid, before.protocolUid);
      expect(view.revision, 4);
      expect(
        (await service.get(view.calendarId, groups)).updatedAt,
        parent.updatedAt,
      );
    });
    test('occurrence action permissions and immutable actual proposed context apply at final checks', () async {
      final id = await recurringEvent();
      policy.denied.add(CalendarPermission.changeEventStatus);
      await expectLater(
        service.changeOccurrence(
          occurrenceChange(id, CalendarEventOccurrenceAction.cancelSingle),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: day(31),
        ),
      );
      expect(
        policy.lastEventRequest!.occurrenceChange!.action,
        CalendarEventOccurrenceAction.replaceFutureTiming,
      );
      expect(policy.lastEventRequest!.currentEvent!.eventId, id);
      expect(
        policy.lastEventRequest!.current!.calendarId,
        policy.lastEventRequest!.calendarId,
      );
      expect(
        policy
            .lastEventRequest!
            .proposedTimingOverrides!
            .future
            .single
            .originalStart
            .start
            .day,
        30,
      );
      expect(
        () => policy.lastEventRequest!.proposedTimingOverrides!.future.clear(),
        throwsUnsupportedError,
      );
      policy.denied.clear();
      policy.denied.add(CalendarPermission.updateEvent);
      await expectLater(
        service.changeOccurrence(
          occurrenceChange(
            id,
            CalendarEventOccurrenceAction.clearFutureTiming,
            revision: 2,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      // Restore permission cannot erase timing. Cancellation at the exact range anchor rejects ambiguity.
      await expectLater(
        service.changeOccurrence(
          occurrenceChange(
            id,
            CalendarEventOccurrenceAction.cancelSingle,
            revision: 2,
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
    });
    test('occurrence overrides survive master edits and reject orphaning or incompatible profiles', () async {
      final id = await recurringEvent();
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: day(28),
        ),
      );
      final c = eventInput(summary: 'Master edit').copyWith(
        recurrence: CalendarEventRecurrence(
          rule: daily(),
          inclusions: [],
          exclusions: [],
        ),
      );
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 2,
          content: c,
        ),
      );
      var current = await service.getEvent(id, eventGroups);
      expect(current.timingOverrides!.singles.length, 1);
      expect(current.summary, 'Master edit');
      for (final bad in [
        c.copyWith(recurrence: c.recurrence!.copyWith(rule: daily(count: 1))),
        c.copyWith(timing: c.timing.copyWith(kind: CalendarEventTimeKind.utc)),
        c.copyWith(recurrence: c.recurrence!.copyWith(exclusions: [day(30)])),
      ]) {
        await expectLater(
          service.updateEvent(
            CalendarEventUpdateRequest(
              eventId: id,
              expectedRevision: 3,
              content: bad,
              replaceRecurrenceDates: true,
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
      }
      current = await service.getEvent(id, eventGroups);
      expect(current.revision, 3);
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.clearSingleTiming,
          revision: 3,
        ),
      );
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 4,
          content: c.copyWith(
            recurrence: c.recurrence!.copyWith(rule: daily(count: 1)),
          ),
        ),
      );
      expect((await service.getEvent(id, eventGroups)).timingOverrides, isNull);
    });
    test('event storage source fields retain through native edits and explicit clears', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
      ))!.eventId;
      final source = eventStorageProposal(
        parseIcalendarEventCalendar(
          utf8.encode(
            [
              'BEGIN:VCALENDAR',
              'VERSION:2.0',
              'PRODID:-//Synthetic//EN',
              'BEGIN:VEVENT',
              'UID:source-text@example.invalid',
              'DTSTAMP:20261022T100000Z',
              'DTSTART:20261022T120000Z',
              'DURATION:PT1H',
              'SUMMARY;LANGUAGE=sv;ALTREP="cid:synthetic@example.invalid":Hej',
              'RDATE;VALUE=PERIOD:20261024T120000Z/PT2H',
              'END:VEVENT',
              'END:VCALENDAR',
              '',
            ].join('\r\n'),
          ),
        ).series.single,
      );
      final data = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      ))!;
      data.protocolUid = source.protocolUid;
      data.uidDigest = eventUidDigest(source.protocolUid);
      data.content = source.content;
      data.timingOverrides = source.edits;
      data.protocolState = source.protocolState;
      data.importBaseline = source.importBaseline;
      await CalendarEventDataRecord.db.updateRow(session, data);
      final old = await service.getEvent(id, eventGroups);
      expect(old.statusPresent, isFalse);
      expect(old.protocolVersion!.sequence, isNull);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 1,
          content: source.content.copyWith(
            summary: 'Changed',
            periods: null,
            textParameters: null,
          ),
        ),
      );
      final after = await service.getEvent(id, eventGroups);
      expect(after.periods!.single.duration!.hours, 2);
      expect(after.textParameters!.summary!.language, 'sv');
      expect(after.protocolVersion!.sequence, 1);
      expect(after.statusPresent, isFalse);
      expect(after.protocolUid, source.protocolUid);
      expect(jsonEncode(after.toJson()), isNot(contains('canonicalValue')));
      final stored = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      ))!;
      expect(
        stored.importBaseline!.canonicalValue,
        source.importBaseline.canonicalValue,
      );
      expect(policy.lastEventRequest!.currentEvent!.protocolState, isNotNull);
      policy.eventGrants = {CalendarEventFieldGroup.summary};
      final limited = await service.getEvent(id, eventGroups);
      expect(limited.periods, isNull);
      expect(limited.protocolVersion, isNull);
      expect(limited.statusPresent, isNull);
      expect(limited.textParameters!.summary!.language, 'sv');
      expect(limited.occurrenceProtocolVersions, isNull);
      policy.eventGrants = {CalendarEventFieldGroup.timing};
      final timingOnly = await service.getEvent(id, eventGroups);
      expect(timingOnly.textParameters, isNull);
      expect(timingOnly.protocolVersion, isNull);
      policy.eventGrants = eventGroups.toSet();
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 2,
          content: source.content.copyWith(
            summary: 'Changed',
            periods: null,
            textParameters: null,
          ),
          replacePeriods: true,
          replaceTextParameters: true,
        ),
      );
      final cleared = await service.getEvent(id, eventGroups);
      expect(cleared.periods, isNull);
      expect(cleared.textParameters?.summary, isNull);
      await service.deleteEvent(id, 3);
      expect(
        await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(id),
        ),
        isNull,
      );
    });
    test('event storage no-op and occurrence writes keep independent protocol state', () async {
      final id = await recurringEvent();
      final before = await service.getEvent(id, eventGroups);
      expect(before.protocolVersion!.sequence, 0);
      final data = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      ))!;
      expect(data.importBaseline, isNull);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 1,
          content: data.content,
        ),
      );
      final noOp = await service.getEvent(id, eventGroups);
      expect(noOp.revision, 2);
      expect(noOp.protocolVersion!.toJson(), before.protocolVersion!.toJson());
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.cancelSingle,
          revision: 2,
        ),
      );
      final cancelled = await service.getEvent(id, eventGroups);
      expect(
        cancelled.protocolVersion!.toJson(),
        before.protocolVersion!.toJson(),
      );
      expect(cancelled.occurrenceProtocolVersions!.single.version.sequence, 0);
      expect(
        cancelled.occurrenceProtocolVersions!.single.version.created,
        isNotNull,
      );
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.restoreSingle,
          revision: 3,
        ),
      );
      final restored = await service.getEvent(id, eventGroups);
      expect(restored.protocolVersion!.sequence, 0);
      // A cancellation-only exception is removed when restored.
      expect(restored.occurrenceProtocolVersions, isEmpty);
    });
    test('event storage denial stale and sequence overflow leave payload baseline and revision unchanged', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.createEvent(
          CalendarEventCreateRequest(
            calendarId: parent,
            content: eventInput(summary: 'Bad URI').copyWith(
              textParameters: CalendarEventTextParameters(
                summary: CalendarTextParameters(
                  alternativeUri: 'http://[broken',
                ),
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      final id = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Before'),
        ),
      ))!.eventId;
      final data = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      ))!;
      data.protocolState = data.protocolState!.copyWith(
        version: data.protocolState!.version.copyWith(
          sequence: eventMaxSequence,
        ),
      );
      await CalendarEventDataRecord.db.updateRow(session, data);
      final request = CalendarEventUpdateRequest(
        eventId: id,
        expectedRevision: 1,
        content: data.content.copyWith(summary: 'After'),
      );
      policy.denied.add(CalendarPermission.updateEvent);
      await expectLater(
        service.updateEvent(request),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      await expectLater(
        service.updateEvent(request.copyWith(expectedRevision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.updateEvent(request),
        failure(CalendarFailureCode.limitExceeded),
      );
      final after = await service.getEvent(id, eventGroups);
      expect(after.revision, 1);
      expect(after.summary, 'Before');
      expect(after.protocolVersion!.sequence, eventMaxSequence);
      await service.updateEvent(request.copyWith(content: data.content));
      expect((await service.getEvent(id, eventGroups)).revision, 2);
    });
    test('event storage legacy read initializes local checkpoint without inventing stored history', () async {
      final id = await recurringEvent();
      await service.changeOccurrence(
        occurrenceChange(id, CalendarEventOccurrenceAction.cancelSingle),
      );
      final data = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      ))!;
      data.protocolState = null;
      await CalendarEventDataRecord.db.updateRow(session, data);
      final view = await service.getEvent(id, eventGroups);
      expect(view.protocolVersion!.sequence, 0);
      expect(view.occurrenceProtocolVersions!.single.version.created, isNull);
      final stored = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      ))!;
      expect(stored.protocolState, isNull);
      expect(stored.importBaseline, isNull);
    });
    test('occurrence stale final-denied and post-write failures roll back timing content revision and time', () async {
      final id = await recurringEvent();
      final before = await service.getEvent(id, eventGroups);
      final request = occurrenceChange(
        id,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: day(28),
      );
      policy.denyFinal = true;
      await expectLater(
        service.changeOccurrence(request),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      await expectLater(
        service.changeOccurrence(request.copyWith(expectedRevision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      final scope = (await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      ))!;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.changeOccurrence(request),
        failure(CalendarFailureCode.limitExceeded),
      );
      final after = await service.getEvent(id, eventGroups);
      expect(after.revision, before.revision);
      expect(after.lastModified, before.lastModified);
      expect(after.timingOverrides, isNull);
      expect(after.protocolUid, before.protocolUid);
    });
    test('occurrence timing disclosure scope boundaries and payload deletion remain protected', () async {
      final id = await recurringEvent();
      await service.changeOccurrence(
        occurrenceChange(id, CalendarEventOccurrenceAction.cancelSingle),
      );
      policy.eventGrants = {CalendarEventFieldGroup.summary};
      expect((await service.getEvent(id, eventGroups)).timingOverrides, isNull);
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      await expectLater(
        CalendarModule.service(bobSession).changeOccurrence(
          occurrenceChange(
            id,
            CalendarEventOccurrenceAction.restoreSingle,
            revision: 2,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.eventGrants = eventGroups.toSet();
      await service.deleteEvent(id, 2);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      final marker = (await CalendarEventRecord.db.findById(session, id))!;
      expect(marker.deletedAt, isNotNull);
      await expectLater(
        service.changeOccurrence(
          occurrenceChange(
            id,
            CalendarEventOccurrenceAction.restoreSingle,
            revision: 3,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('recurrence persists canonically, previews actual identity and preserves explicit dates on pattern replacement', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final c = eventInput().copyWith(
        recurrence: CalendarEventRecurrence(
          rule: daily(),
          inclusions: [day(27), day(27)],
          exclusions: [day(30)],
        ),
      );
      final receipt = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: c),
      ))!;
      final first = await service.getEvent(receipt.eventId, eventGroups);
      expect(first.recurrence!.inclusions.length, 1);
      final result = await service.previewOccurrences(preview(receipt.eventId));
      expect(result.occurrences.map((v) => v.originalStart.day), [27, 29, 31]);
      expect(policy.lastEventRequest!.eventId, receipt.eventId);
      expect(policy.lastEventRequest!.calendarId, parent);
      expect(
        policy.lastEventRequest!.occurrenceQuery!.eventId,
        receipt.eventId,
      );
      expect(
        () => policy
            .lastEventRequest!
            .currentEvent!
            .content
            .recurrence!
            .inclusions
            .clear(),
        throwsUnsupportedError,
      );
      expect(
        () => policy
            .lastEventRequest!
            .currentEvent!
            .content
            .recurrence!
            .rule!
            .byDay
            .clear(),
        throwsUnsupportedError,
      );
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: receipt.eventId,
          expectedRevision: 1,
          content: eventInput().copyWith(
            recurrence: CalendarEventRecurrence(
              rule: daily(count: 2),
              inclusions: [],
              exclusions: [],
            ),
          ),
        ),
      );
      final changed = await service.getEvent(receipt.eventId, eventGroups);
      expect(changed.recurrence!.inclusions.single.start.day, 27);
      expect(changed.recurrence!.exclusions.single.start.day, 30);
      expect(changed.protocolUid, first.protocolUid);
      await expectLater(
        service.previewOccurrences(preview(receipt.eventId)),
        failure(CalendarFailureCode.staleRevision),
      );
      expect(
        (await service.previewOccurrences(
          preview(receipt.eventId, revision: 2),
        )).occurrences.map((v) => v.start.day),
        [27, 29],
      );
    });
    test('incompatible pattern changes reject atomically; explicit replacement can clear dates', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final receipt = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput().copyWith(
            recurrence: CalendarEventRecurrence(
              rule: daily(),
              inclusions: [day(27)],
              exclusions: [],
            ),
          ),
        ),
      ))!;
      final change = CalendarEventUpdateRequest(
        eventId: receipt.eventId,
        expectedRevision: 1,
        content: eventInput().copyWith(
          timing: day(29, kind: CalendarEventTimeKind.utc),
        ),
      );
      await expectLater(
        service.updateEvent(change),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await service.getEvent(receipt.eventId, eventGroups)).revision,
        1,
      );
      policy.denyFinal = true;
      await expectLater(
        service.updateEvent(change.copyWith(replaceRecurrenceDates: true)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      expect(
        (await service.getEvent(
          receipt.eventId,
          eventGroups,
        )).recurrence!.inclusions.length,
        1,
      );
      await service.updateEvent(change.copyWith(replaceRecurrenceDates: true));
      expect(
        (await service.getEvent(receipt.eventId, eventGroups)).recurrence,
        isNull,
      );
    });
    test('preview requires both read and preview rights, timing disclosure and actual scope', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
      ))!.eventId;
      for (final permission in [
        CalendarPermission.readEvent,
        CalendarPermission.previewEventOccurrences,
      ]) {
        policy.denied
          ..clear()
          ..add(permission);
        await expectLater(
          service.previewOccurrences(preview(id)),
          failure(CalendarFailureCode.accessDenied),
        );
      }
      policy.denied.clear();
      policy.eventGrants = {CalendarEventFieldGroup.summary};
      await expectLater(
        service.previewOccurrences(preview(id)),
        failure(CalendarFailureCode.accessDenied),
      );
      final hidden = await service.getEvent(id, eventGroups);
      expect(hidden.timing, isNull);
      expect(hidden.recurrence, isNull);
      policy.eventGrants = eventGroups.toSet();
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      await expectLater(
        CalendarModule.service(bobSession).previewOccurrences(preview(id)),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test(
      'preview caps fail explicitly without changing event revision or time',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final input = eventInput().copyWith(
          timing: day(29, kind: CalendarEventTimeKind.utc),
          recurrence: CalendarEventRecurrence(
            rule: daily().copyWith(
              frequency: CalendarEventFrequency.minutely,
              count: null,
            ),
            inclusions: [],
            exclusions: [],
          ),
        );
        final id = (await service.createEvent(
          CalendarEventCreateRequest(calendarId: parent, content: input),
        ))!.eventId;
        final before = await service.getEvent(id, eventGroups);
        await expectLater(
          service.previewOccurrences(
            CalendarEventOccurrenceQuery(
              eventId: id,
              expectedRevision: 1,
              fromUtc: DateTime.utc(2026, 3, 29),
              untilUtc: DateTime.utc(2026, 3, 30),
            ),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        final after = await service.getEvent(id, eventGroups);
        expect(after.revision, before.revision);
        expect(after.lastModified, before.lastModified);
      },
    );
    test('previous non-recurring JSON payload upgrades without changing event identities', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
      ))!.eventId;
      final before = await service.getEvent(id, eventGroups);
      // Previous serializer wrote recurring:false and no recurrence property.
      await session.db.unsafeQuery(
        "UPDATE serverpod_calendar_event_data SET content = (content::jsonb - 'recurrence') || '{\"recurring\":false}'::jsonb WHERE \"eventId\" = '$id'",
      );
      final after = await service.getEvent(id, eventGroups);
      expect(after.recurrence, isNull);
      expect(after.protocolUid, before.protocolUid);
      expect(after.revision, before.revision);
      expect(after.lastModified, before.lastModified);
    });
    test('event lifecycle preserves UID, separates cancel/delete and blocks parent deletion', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final calendar = await service.get(parent, groups);
      final receipt = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
      ))!;
      final first = await service.getEvent(receipt.eventId, eventGroups);
      expect(first.summary, isNull);
      expect(first.timing!.kind, CalendarEventTimeKind.date);
      expect(first.protocolUid, isNot(receipt.eventId.toString()));
      await expectLater(
        service.delete(parent, 1),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.changeEventStatus(
        CalendarEventStatusRequest(
          eventId: receipt.eventId,
          expectedRevision: 1,
          status: CalendarEventStatus.cancelled,
        ),
      );
      expect(
        (await service.getEvent(receipt.eventId, eventGroups)).status,
        CalendarEventStatus.cancelled,
      );
      await expectLater(
        service.delete(parent, 1),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.changeEventStatus(
        CalendarEventStatusRequest(
          eventId: receipt.eventId,
          expectedRevision: 2,
          status: CalendarEventStatus.tentative,
        ),
      );
      final after = await service.getEvent(receipt.eventId, eventGroups);
      expect(after.protocolUid, first.protocolUid);
      expect(after.lastModified!.isBefore(first.lastModified!), isFalse);
      expect((await service.get(parent, groups)).updatedAt, calendar.updatedAt);
      expect((await service.get(parent, groups)).revision, 1);
      await service.deleteEvent(receipt.eventId, 3);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      final marker = (await CalendarEventRecord.db.findById(
        session,
        receipt.eventId,
      ))!;
      expect(marker.toJson().keys.toSet(), {
        '__className__',
        'id',
        'calendarId',
        'revision',
        'deletedAt',
      });
      await expectLater(
        service.getEvent(receipt.eventId, eventGroups),
        failure(CalendarFailureCode.accessDenied),
      );
      await service.delete(parent, 1);
    });
    test('event edit cannot bypass separate lifecycle checks including cancelled creation', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final event = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Original'),
        ),
      ))!;
      policy.denied.add(CalendarPermission.changeEventStatus);
      await expectLater(
        service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: event.eventId,
            expectedRevision: 1,
            content: eventInput(status: CalendarEventStatus.cancelled),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.createEvent(
          CalendarEventCreateRequest(
            calendarId: parent,
            content: eventInput(status: CalendarEventStatus.cancelled),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarEventRecord.db.count(session), 1);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: event.eventId,
          expectedRevision: 1,
          content: eventInput(summary: 'Edited'),
        ),
      );
      policy.denied.clear();
      policy.denied.add(CalendarPermission.updateEvent);
      await service.changeEventStatus(
        CalendarEventStatusRequest(
          eventId: event.eventId,
          expectedRevision: 2,
          status: CalendarEventStatus.cancelled,
        ),
      );
      expect(
        (await service.getEvent(event.eventId, eventGroups)).summary,
        'Edited',
      );
    });
    test('event context and disclosure are independent of calendar metadata rights', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final event = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Private'),
        ),
      ))!;
      policy.denied.add(CalendarPermission.read);
      policy.eventGrants = {CalendarEventFieldGroup.timing};
      final view = await service.getEvent(event.eventId, eventGroups);
      expect(view.summary, isNull);
      expect(view.status, isNull);
      expect(view.protocolUid, isNull);
      expect(view.timing, isNotNull);
      expect(policy.lastEventRequest!.calendarId, parent);
      expect(policy.lastEventRequest!.current!.calendarId, parent);
      expect(policy.lastEventRequest!.currentEvent!.eventId, event.eventId);
      expect(policy.lastEventRequest!.currentEvent!.content.summary, 'Private');
      expect(
        () => policy.lastEventRequest!.eventGroups.clear(),
        throwsUnsupportedError,
      );
      policy.denied.add(CalendarPermission.readEvent);
      await expectLater(
        service.getEvent(event.eventId, eventGroups),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await service.listEvents(
          parent,
          pageSize: 10,
          fieldGroups: eventGroups,
        )).events,
        isEmpty,
      );
    });
    test('event scopes and host candidate constraints cannot disclose other parents', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final other = (await service.create(createInput()))!.calendarId;
      final event = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
      ))!;
      policy.eventCandidates = {event.eventId};
      expect(
        (await service.listEvents(
          other,
          pageSize: 10,
          fieldGroups: eventGroups,
        )).events,
        isEmpty,
      );
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      final bob = CalendarModule.service(bobSession);
      await expectLater(
        bob.getEvent(event.eventId, eventGroups),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        bob.createEvent(
          CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.eventCandidates = {};
      expect(
        (await service.listEvents(
          parent,
          pageSize: 10,
          fieldGroups: eventGroups,
        )).events,
        isEmpty,
      );
    });
    test(
      'event cursors bind query kind parent groups policy data and page size',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final other = (await service.create(createInput()))!.calendarId;
        for (var i = 0; i < 3; i++) {
          await service.createEvent(
            CalendarEventCreateRequest(
              calendarId: parent,
              content: eventInput(),
            ),
          );
        }
        final page = await service.listEvents(
          parent,
          pageSize: 1,
          fieldGroups: eventGroups,
        );
        expect(page.nextCursor, isNotNull);
        final next = await service.listEvents(
          parent,
          pageSize: 1,
          fieldGroups: eventGroups,
          cursor: page.nextCursor,
        );
        expect(next.events.single.id, isNot(page.events.single.id));
        await expectLater(
          service.listEvents(
            other,
            pageSize: 1,
            fieldGroups: eventGroups,
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        await expectLater(
          service.listEvents(
            parent,
            pageSize: 2,
            fieldGroups: eventGroups,
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        await expectLater(
          service.listEvents(
            parent,
            pageSize: 1,
            fieldGroups: [],
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        await expectLater(
          service.list(
            pageSize: 1,
            fieldGroups: groups,
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        final calendars = await service.list(pageSize: 1, fieldGroups: groups);
        await expectLater(
          service.listEvents(
            parent,
            pageSize: 1,
            fieldGroups: eventGroups,
            cursor: calendars.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        policy.epoch = 'changed';
        await expectLater(
          service.listEvents(
            parent,
            pageSize: 1,
            fieldGroups: eventGroups,
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        policy.epoch = 'v1';
        await service.changeEventStatus(
          CalendarEventStatusRequest(
            eventId: page.events.single.id,
            expectedRevision: 1,
            status: CalendarEventStatus.cancelled,
          ),
        );
        await expectLater(
          service.listEvents(
            parent,
            pageSize: 1,
            fieldGroups: eventGroups,
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
      },
    );
    test('event hidden scan exhaustion fails instead of reporting an empty complete list', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      for (var i = 0; i < 3; i++) {
        await service.createEvent(
          CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
        );
      }
      policy.denied.add(CalendarPermission.readEvent);
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          maxScannedEvents: 2,
        ),
      );
      await expectLater(
        CalendarModule.service(session)
            .listEvents(parent, pageSize: 1, fieldGroups: eventGroups),
        failure(CalendarFailureCode.limitExceeded),
      );
    });
    test('invalid stale final-denied and post-write-failed event commands are atomic', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final event = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Before'),
        ),
      ))!;
      final before = await service.getEvent(event.eventId, eventGroups);
      final update = CalendarEventUpdateRequest(
        eventId: event.eventId,
        expectedRevision: 1,
        content: eventInput(summary: 'After'),
      );
      policy.denyFinal = true;
      await expectLater(
        service.updateEvent(update),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      await expectLater(
        service.updateEvent(update.copyWith(expectedRevision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.updateEvent(
          update.copyWith(
            content: update.content.copyWith(
              timing: update.content.timing.copyWith(
                kind: CalendarEventTimeKind.floating,
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      final scope = (await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      ))!;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.updateEvent(update),
        failure(CalendarFailureCode.limitExceeded),
      );
      final after = await service.getEvent(event.eventId, eventGroups);
      expect(after.summary, before.summary);
      expect(after.revision, 1);
      expect(after.lastModified, before.lastModified);
      expect(after.protocolUid, before.protocolUid);
    });
    test(
      'protocol identity is stable, separate and independently disclosed',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        final other = (await service.create(createInput()))!.calendarId;
        final first = await service.get(id, groups);
        final identity = first.protocolIdentity!;
        expect(
          identity.uid,
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
            ),
          ),
        );
        expect(identity.uid, isNot(id.toString()));
        expect(
          identity.uid,
          isNot((await service.get(other, groups)).protocolIdentity!.uid),
        );
        expect(identity.lastModified.isUtc, isTrue);
        expect(identity.lastModified.millisecond, 0);
        expect(identity.lastModified.microsecond, 0);
        final only = await service.get(id, [
          CalendarFieldGroup.protocolIdentity,
        ]);
        expect(only.protocolIdentity, identity);
        expect(policy.lastSnapshot!.protocolIdentity, identity);
        expect(only.displayName, isNull);
        expect(only.protocolMetadata, isNull);
        expect(only.supplementalMetadata, isNull);
        expect(only.updatedAt, isNull);
        expect(
          (await service.get(id, [
            CalendarFieldGroup.protocolMetadata,
          ])).protocolIdentity,
          isNull,
        );
        policy.grants = {CalendarFieldGroup.metadata};
        expect((await service.get(id, groups)).protocolIdentity, isNull);
        expect(
          (await service.list(
            pageSize: 10,
            fieldGroups: groups,
          )).calendars.every((v) => v.protocolIdentity == null),
          isTrue,
        );
        policy.grants = groups.toSet();
        expect((await service.get(id, groups)).protocolIdentity, identity);
      },
    );
    test('every calendar mutation touches automatic revision time without changing UID', () async {
      final id = (await service.create(createInput()))!.calendarId;
      final uid = (await service.get(id, groups)).protocolIdentity!.uid;
      var revision = 1;
      final mutations = <Future<dynamic> Function()>[
        () => service.updateMetadata(
          CalendarMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            displayName: 'Renamed',
          ),
        ),
        () => service.updatePresentation(
          CalendarPresentationUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            displayName: 'Presented',
            description: 'Notes',
            color: '#112233',
          ),
        ),
        () => service.updateProtocolMetadata(
          CalendarProtocolMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            metadata: CalendarProtocolMetadata(
              names: [],
              descriptions: [],
              color: 'red',
            ),
          ),
        ),
        () => service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            metadata: CalendarSupplementalMetadata(
              url: 'https://example.invalid/calendar',
              categories: [],
              images: [],
            ),
          ),
        ),
        () => service.updateSettings(
          CalendarSettingsUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            availabilityZoneId: 'UTC',
            noRuleFallback: CalendarNoRuleFallback.unavailable,
          ),
        ),
        for (final action in [
          CalendarSubjectAction.attach,
          CalendarSubjectAction.setContribution,
          CalendarSubjectAction.detach,
        ])
          () => service.changeSubject(
            CalendarSubjectChangeRequest(
              calendarId: id,
              expectedRevision: revision,
              action: action,
              namespace: 'fixture',
              kind: 'room',
              externalId: 'one',
              contributesAvailability: action == CalendarSubjectAction.attach,
            ),
          ),
      ];
      for (final change in mutations) {
        final row = (await CalendarDataRecord.db.findFirstRow(
          session,
          where: (t) => t.calendarId.equals(id),
        ))!;
        row.updatedAt = DateTime.utc(2020, 1, 1, 0, 0, 0, 123, 456);
        await CalendarDataRecord.db.updateRow(session, row);
        final before =
            (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                    .single
                    .single
                as DateTime;
        await change();
        revision++;
        final after = await service.get(id, groups);
        expect(after.revision, revision);
        expect(after.protocolIdentity!.uid, uid);
        expect(after.updatedAt!.isBefore(before), isFalse);
        expect(
          after.protocolIdentity!.lastModified.isBefore(
            before.subtract(const Duration(seconds: 1)),
          ),
          isFalse,
        );
        expect(
          after.protocolIdentity!.lastModified.isAfter(after.updatedAt!),
          isFalse,
        );
        expect(
          after.updatedAt!.difference(after.protocolIdentity!.lastModified),
          lessThan(const Duration(seconds: 1)),
        );
      }
    });
    test('clock correction preserves time while same-second revisions still advance', () async {
      final id = (await service.create(createInput()))!.calendarId;
      final row = (await CalendarDataRecord.db.findFirstRow(
        session,
        where: (t) => t.calendarId.equals(id),
      ))!;
      row.updatedAt = DateTime.utc(2080, 4, 5, 12, 34, 59, 987, 654);
      await CalendarDataRecord.db.updateRow(session, row);
      final original = await service.get(id, groups);
      for (final revision in [1, 2]) {
        await service.updateMetadata(
          CalendarMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            displayName: 'Same label',
          ),
        );
        final view = await service.get(id, groups);
        expect(view.revision, revision + 1);
        expect(view.updatedAt, row.updatedAt);
        expect(
          view.protocolIdentity!.lastModified,
          DateTime.utc(2080, 4, 5, 12, 34, 59),
        );
        expect(view.protocolIdentity!.uid, original.protocolIdentity!.uid);
      }
    });
    test(
      'failed writes and reads preserve protocol identity and revision time',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        final before = await service.get(id, groups);
        final command = CalendarMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          displayName: 'Denied',
        );
        policy.denyFinal = true;
        await expectLater(
          service.updateMetadata(command),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denyFinal = false;
        command.expectedRevision = 2;
        await expectLater(
          service.updateMetadata(command),
          failure(CalendarFailureCode.staleRevision),
        );
        command.expectedRevision = 1;
        command.displayName = ' ';
        await expectLater(
          service.updateMetadata(command),
          failure(CalendarFailureCode.validation),
        );
        await service.list(pageSize: 10, fieldGroups: groups);
        final after = await service.get(id, groups);
        expect(after.protocolIdentity, before.protocolIdentity);
        expect(after.updatedAt, before.updatedAt);
        expect(after.revision, 1);
        await service.delete(id, 1);
        expect(
          await CalendarDataRecord.db.findFirstRow(
            session,
            where: (t) => t.calendarId.equals(id),
          ),
          isNull,
        );
        final marker = (await CalendarIdentityRecord.db.findById(session, id))!;
        expect(marker.toJson().containsKey('protocolUid'), isFalse);
        expect(marker.toJson().containsKey('lastModified'), isFalse);
      },
    );
    test(
      'duplicate names, independent fields and content-free deletion marker',
      () async {
        final first = (await service.create(createInput('  Shared  ')))!;
        final second = (await service.create(createInput('Shared')))!;
        expect(first.calendarId, isNot(second.calendarId));
        final view = await service.get(first.calendarId, groups);
        expect(view.displayName, 'Shared');
        expect(view.revision, 1);
        await service.delete(first.calendarId, 1);
        expect(
          await CalendarDataRecord.db.findFirstRow(
            session,
            where: (t) => t.calendarId.equals(first.calendarId),
          ),
          isNull,
        );
        final marker = (await CalendarIdentityRecord.db.findById(
          session,
          first.calendarId,
        ))!;
        expect(marker.revision, 2);
        expect(marker.deletedAt, isNotNull);
        expect(marker.toJson().keys.toSet(), {
          '__className__',
          'id',
          'scopeKey',
          'revision',
          'deletedAt',
        });
        await expectLater(
          service.get(first.calendarId, groups),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await service.list(
            pageSize: 10,
            fieldGroups: groups,
          )).calendars.single.id,
          second.calendarId,
        );
      },
    );
    test(
      'stale revision and settings permission are independent from rename',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        policy.denied.add(CalendarPermission.updateAvailabilitySettings);
        await service.updateMetadata(
          CalendarMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            displayName: 'Renamed',
          ),
        );
        await expectLater(
          service.updateSettings(
            CalendarSettingsUpdateRequest(
              calendarId: id,
              expectedRevision: 2,
              availabilityZoneId: 'UTC',
              noRuleFallback: CalendarNoRuleFallback.unavailable,
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          service.updateMetadata(
            CalendarMetadataUpdateRequest(
              calendarId: id,
              expectedRevision: 1,
              displayName: 'Stale',
            ),
          ),
          failure(CalendarFailureCode.staleRevision),
        );
        expect((await service.get(id, groups)).displayName, 'Renamed');
      },
    );
    test('actual object snapshots and field groups restrict object reads and pages', () async {
      final a = (await service.create(createInput('Hidden')))!;
      final b = (await service.create(createInput('Visible')))!;
      policy.hidden.add(a.calendarId);
      policy.grants = {CalendarFieldGroup.metadata};
      final page = await service.list(pageSize: 1, fieldGroups: groups);
      expect(page.calendars.single.id, b.calendarId);
      expect(page.nextCursor, isNull);
      expect(page.calendars.single.availabilityZoneId, isNull);
      expect(page.calendars.single.disclosedGroups, [
        CalendarFieldGroup.metadata,
      ]);
      await expectLater(
        service.get(a.calendarId, groups),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(policy.sawActualSnapshot, isTrue);
    });
    test('trusted scope isolates calendars even with the same label', () async {
      final id = (await service.create(createInput()))!.calendarId;
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      final bob = CalendarModule.service(bobSession);
      await expectLater(
        bob.get(id, groups),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await bob.list(pageSize: 10, fieldGroups: groups)).calendars,
        isEmpty,
      );
    });
    test(
      'association changes block deletion and advance one revision',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        CalendarSubjectChangeRequest change(
          CalendarSubjectAction action,
          int revision,
        ) => CalendarSubjectChangeRequest(
          calendarId: id,
          expectedRevision: revision,
          action: action,
          namespace: 'host',
          kind: 'room',
          externalId: 'R1',
          contributesAvailability: true,
        );
        await service.changeSubject(change(CalendarSubjectAction.attach, 1));
        expect((await service.subjects(id)).single.externalId, 'R1');
        await expectLater(
          service.delete(id, 2),
          failure(CalendarFailureCode.dependencyConflict),
        );
        await service.changeSubject(change(CalendarSubjectAction.detach, 2));
        expect((await service.delete(id, 3))!.revision, 4);
      },
    );
    test(
      'final denial rolls back without changing data or aggregate revision',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        policy.denyFinal = true;
        await expectLater(
          service.updateMetadata(
            CalendarMetadataUpdateRequest(
              calendarId: id,
              expectedRevision: 1,
              displayName: 'Denied',
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        final view = await service.get(id, groups);
        expect(view.revision, 1);
        expect(view.displayName, 'Calendar');
      },
    );
    test(
      'missing policy responses fail closed without partial pages',
      () async {
        await service.create(createInput());
        policy.malformed = true;
        await expectLater(
          service.list(pageSize: 10, fieldGroups: groups),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test(
      'policy failure is unavailable rather than an empty successful page',
      () async {
        await service.create(createInput());
        policy.unavailable = true;
        await expectLater(
          service.list(pageSize: 10, fieldGroups: groups),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test('cursor binds query, policy epoch and scope data revision', () async {
      for (var i = 0; i < 3; i++) {
        await service.create(createInput());
      }
      final first = await service.list(pageSize: 1, fieldGroups: groups);
      final next = await service.list(
        pageSize: 1,
        fieldGroups: groups,
        cursor: first.nextCursor,
      );
      expect(first.nextCursor, isNotNull);
      expect(first.calendars.single.id, isNot(next.calendars.single.id));
      await expectLater(
        service.list(
          pageSize: 2,
          fieldGroups: groups,
          cursor: first.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      policy.epoch = 'changed';
      await expectLater(
        service.list(
          pageSize: 1,
          fieldGroups: groups,
          cursor: first.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      policy.epoch = 'v1';
      await service.create(createInput());
      await expectLater(
        service.list(
          pageSize: 1,
          fieldGroups: groups,
          cursor: first.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
    });
    test('strong mode rejects an adapter with only fresh-check capability', () {
      expect(
        () => CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.coordinated,
          ),
        ),
        throwsArgumentError,
      );
    });
    test('unavailable dependency checker prevents deletion', () async {
      final id = (await service.create(createInput()))!.calendarId;
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        dependencies: [BrokenDependency()],
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
      );
      await expectLater(
        CalendarModule.service(session).delete(id, 1),
        failure(CalendarFailureCode.unavailable),
      );
      expect((await service.get(id, groups)).revision, 1);
    });
    test(
      'mutable direct-call requests cannot change validated policy intent',
      () async {
        final input = createInput();
        policy.onPreliminary = () {
          input.displayName = 'Changed after validation';
          input.availabilityZoneId = 'invalid/zone';
        };
        final receipt = (await service.create(input))!;
        final view = await service.get(receipt.calendarId, groups);
        expect(view.displayName, 'Calendar');
        expect(view.availabilityZoneId, 'Europe/Stockholm');
      },
    );
    test('native and multilingual protocol values stay independent through unrelated edits', () async {
      final created = (await service.create(
        createInput('Native')
          ..description = '  Native\nnotes  '
          ..color = '#aabbcc',
      ))!;
      final id = created.calendarId;
      final initial = await service.get(id, groups);
      expect(initial.description, '  Native\nnotes  ');
      expect(initial.color, '#AABBCC');
      expect(initial.protocolMetadata!.names, isEmpty);
      await service.updateProtocolMetadata(
        CalendarProtocolMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          metadata: CalendarProtocolMetadata(
            names: [
              CalendarTextVariant(value: 'Protocol', language: 'en'),
              CalendarTextVariant(value: 'Protokoll', language: 'SV'),
            ],
            descriptions: [CalendarTextVariant(value: 'Protocol notes')],
            color: 'Blue',
          ),
        ),
      );
      await service.updateMetadata(
        CalendarMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 2,
          displayName: 'Renamed',
        ),
      );
      final renamed = await service.get(id, groups);
      expect(renamed.description, '  Native\nnotes  ');
      expect(renamed.color, '#AABBCC');
      expect(renamed.protocolMetadata!.names.last.language, 'SV');
      expect(renamed.protocolMetadata!.color, 'Blue');
      await service.updatePresentation(
        CalendarPresentationUpdateRequest(
          calendarId: id,
          expectedRevision: 3,
          displayName: 'New native',
        ),
      );
      final cleared = await service.get(id, groups);
      expect(cleared.description, isNull);
      expect(cleared.color, isNull);
      expect(
        cleared.protocolMetadata!.descriptions.single.value,
        'Protocol notes',
      );
      await service.delete(id, 4);
      expect(
        await CalendarDataRecord.db.findFirstRow(
          session,
          where: (t) => t.calendarId.equals(id),
        ),
        isNull,
      );
      final marker = (await CalendarIdentityRecord.db.findById(session, id))!;
      expect(marker.toJson().keys.toSet(), {
        '__className__',
        'id',
        'scopeKey',
        'revision',
        'deletedAt',
      });
    });
    test(
      'protocol writing and disclosure are separate host capabilities',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        policy.denied.add(CalendarPermission.updateProtocolMetadata);
        await service.updatePresentation(
          CalendarPresentationUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            displayName: 'Allowed',
            description: 'Native',
          ),
        );
        await expectLater(
          service.updateProtocolMetadata(
            CalendarProtocolMetadataUpdateRequest(
              calendarId: id,
              expectedRevision: 2,
              metadata: CalendarProtocolMetadata(
                names: [CalendarTextVariant(value: 'Denied')],
                descriptions: [],
              ),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        policy.denied.add(CalendarPermission.updateMetadata);
        await service.updateProtocolMetadata(
          CalendarProtocolMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 2,
            metadata: CalendarProtocolMetadata(
              names: [CalendarTextVariant(value: 'Protocol')],
              descriptions: [],
            ),
          ),
        );
        await expectLater(
          service.updatePresentation(
            CalendarPresentationUpdateRequest(
              calendarId: id,
              expectedRevision: 3,
              displayName: 'Denied',
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.grants = {CalendarFieldGroup.metadata};
        final page = await service.list(pageSize: 10, fieldGroups: groups);
        expect(page.calendars.single.description, 'Native');
        expect(page.calendars.single.protocolMetadata, isNull);
        expect(page.calendars.single.disclosedGroups, [
          CalendarFieldGroup.metadata,
        ]);
      },
    );
    test('invalid or stale protocol replacement cannot partially commit or rename native fields', () async {
      final id = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.updateProtocolMetadata(
          CalendarProtocolMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarProtocolMetadata(
              names: [
                CalendarTextVariant(value: 'A', language: 'en'),
                CalendarTextVariant(value: 'B', language: 'EN'),
              ],
              descriptions: [],
              color: 'red',
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      var view = await service.get(id, groups);
      expect(view.revision, 1);
      expect(view.protocolMetadata!.names, isEmpty);
      expect(view.protocolMetadata!.color, isNull);
      await service.updateProtocolMetadata(
        CalendarProtocolMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          metadata: CalendarProtocolMetadata(
            names: [CalendarTextVariant(value: 'First')],
            descriptions: [],
          ),
        ),
      );
      await expectLater(
        service.updateProtocolMetadata(
          CalendarProtocolMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarProtocolMetadata(names: [], descriptions: []),
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      policy.denyFinal = true;
      await expectLater(
        service.updatePresentation(
          CalendarPresentationUpdateRequest(
            calendarId: id,
            expectedRevision: 2,
            displayName: 'No',
            description: 'No',
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      view = await service.get(id, groups);
      expect(view.displayName, 'Calendar');
      expect(view.description, isNull);
      expect(view.revision, 2);
      expect(view.protocolMetadata!.names.single.value, 'First');
    });
    test('nested protocol commands and policy snapshots are immutable across callbacks', () async {
      final id = (await service.create(createInput()))!.calendarId;
      final metadata = CalendarProtocolMetadata(
        names: [CalendarTextVariant(value: 'Validated', language: 'en')],
        descriptions: [],
      );
      policy.onPreliminary = () {
        metadata.names.single.value = 'Changed';
        metadata.names.add(
          CalendarTextVariant(value: 'Duplicate', language: 'EN'),
        );
      };
      await service.updateProtocolMetadata(
        CalendarProtocolMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          metadata: metadata,
        ),
      );
      policy.onPreliminary = null;
      final view = await service.get(id, groups);
      expect(view.protocolMetadata!.names.single.value, 'Validated');
      expect(
        policy.lastProtocolIntent!.protocolMetadata!.names.single.value,
        'Validated',
      );
      expect(
        () => policy.lastProtocolIntent!.protocolMetadata!.names.clear(),
        throwsUnsupportedError,
      );
    });
    test('protocol edits invalidate old continuations and clearing preserves absence', () async {
      final id = (await service.create(createInput()))!.calendarId;
      await service.create(createInput());
      final page = await service.list(pageSize: 1, fieldGroups: groups);
      await service.updateProtocolMetadata(
        CalendarProtocolMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          metadata: CalendarProtocolMetadata(
            names: [],
            descriptions: [],
            color: 'red',
          ),
        ),
      );
      await expectLater(
        service.list(pageSize: 1, fieldGroups: groups, cursor: page.nextCursor),
        failure(CalendarFailureCode.invalidCursor),
      );
      await service.updateProtocolMetadata(
        CalendarProtocolMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 2,
          metadata: CalendarProtocolMetadata(names: [], descriptions: []),
        ),
      );
      expect((await service.get(id, groups)).protocolMetadata!.names, isEmpty);
      final row = (await CalendarDataRecord.db.findFirstRow(
        session,
        where: (t) => t.calendarId.equals(id),
      ))!;
      expect(row.protocolMetadata, isNull);
    });
    test(
      'supplemental metadata round trips separately and is group-redacted',
      () async {
        final id = (await service.create(createInput('Native')))!.calendarId;
        await service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarSupplementalMetadata(
              url: 'HTTP://EXAMPLE.INVALID/a%2Fb',
              categories: [CalendarCategory(value: ' Work ', language: 'SV')],
              images: [
                CalendarImageLink(
                  uri: 'https://example.invalid/a.png',
                  display: ['BADGE', 'X-PRIVATE'],
                  mediaType: 'image/png',
                ),
              ],
              refreshHint: CalendarRefreshHint(days: 1),
            ),
          ),
        );
        var view = await service.get(id, groups);
        expect(view.supplementalMetadata!.url, 'HTTP://EXAMPLE.INVALID/a%2Fb');
        expect(view.supplementalMetadata!.images.single.display, [
          'BADGE',
          'X-PRIVATE',
        ]);
        expect(view.supplementalMetadata!.refreshHint!.days, 1);
        expect(view.supplementalMetadata!.refreshHint!.hours, 0);
        expect(view.protocolMetadata!.names, isEmpty);
        await service.updateMetadata(
          CalendarMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 2,
            displayName: 'Renamed',
          ),
        );
        view = await service.get(id, groups);
        expect(view.supplementalMetadata!.categories.single.value, ' Work ');
        policy.grants = {CalendarFieldGroup.metadata};
        expect((await service.get(id, groups)).supplementalMetadata, isNull);
        policy.denied.add(CalendarPermission.updateSupplementalMetadata);
        await expectLater(
          service.updateSupplementalMetadata(
            CalendarSupplementalMetadataUpdateRequest(
              calendarId: id,
              expectedRevision: 3,
              metadata: CalendarSupplementalMetadata(
                categories: [],
                images: [],
              ),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test('category search checks disclosure and binds exact filter to continuation', () async {
      final ids = <UuidValue>[];
      for (final language in ['sv', 'en', 'de']) {
        final id = (await service.create(createInput(language)))!.calendarId;
        ids.add(id);
        await service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarSupplementalMetadata(
              categories: [CalendarCategory(value: 'Work', language: language)],
              images: [],
            ),
          ),
        );
      }
      final filter = CalendarCategoryFilter(value: 'Work');
      final page = await service.list(
        pageSize: 1,
        fieldGroups: [CalendarFieldGroup.metadata],
        categoryFilter: filter,
      );
      expect(page.calendars.single.supplementalMetadata, isNull);
      expect(page.nextCursor, isNotNull);
      expect(policy.sawCategoryFilter, isTrue);
      final second = await service.list(
        pageSize: 1,
        fieldGroups: [CalendarFieldGroup.metadata],
        categoryFilter: filter,
        cursor: page.nextCursor,
      );
      expect(second.calendars.single.id, isNot(page.calendars.single.id));
      await expectLater(
        service.list(
          pageSize: 1,
          fieldGroups: [CalendarFieldGroup.metadata],
          categoryFilter: CalendarCategoryFilter(value: 'work'),
          cursor: page.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      expect(
        (await service.list(
          pageSize: 10,
          fieldGroups: groups,
          categoryFilter: CalendarCategoryFilter(value: 'Work', language: 'SV'),
        )).calendars.single.id,
        ids.first,
      );
      expect(
        (await service.list(
          pageSize: 10,
          fieldGroups: groups,
          categoryFilter: CalendarCategoryFilter(value: 'work'),
        )).calendars,
        isEmpty,
      );
      policy.grants = {CalendarFieldGroup.metadata};
      final hidden = await service.list(
        pageSize: 10,
        fieldGroups: groups,
        categoryFilter: filter,
      );
      expect(hidden.calendars, isEmpty);
      expect(hidden.nextCursor, isNull);
      expect(
        (await service.list(
          pageSize: 10,
          fieldGroups: [CalendarFieldGroup.metadata],
        )).calendars.length,
        3,
      );
    });
    test('invalid and final-denied supplemental replacements cannot partially commit', () async {
      final id = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarSupplementalMetadata(
              categories: [CalendarCategory(value: 'Good')],
              images: [CalendarImageLink(uri: 'data:image/png;base64,x')],
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      policy.denyFinal = true;
      await expectLater(
        service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarSupplementalMetadata(
              categories: [],
              images: [],
              refreshHint: CalendarRefreshHint(hours: 24),
            ),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      final view = await service.get(id, groups);
      expect(view.revision, 1);
      expect(view.supplementalMetadata!.images, isEmpty);
      expect(view.supplementalMetadata!.refreshHint, isNull);
    });
    test('nested supplemental commands freeze before host callbacks and deletion scrubs them', () async {
      final id = (await service.create(createInput()))!.calendarId;
      final value = CalendarSupplementalMetadata(
        categories: [CalendarCategory(value: 'Original')],
        images: [
          CalendarImageLink(
            uri: 'https://example.invalid/a',
            display: ['THUMBNAIL'],
          ),
        ],
        refreshHint: CalendarRefreshHint(hours: 24),
      );
      policy.onPreliminary = () {
        value.categories.single.value = 'Changed';
        value.images.single.display!.clear();
        value.refreshHint!.hours = 48;
      };
      await service.updateSupplementalMetadata(
        CalendarSupplementalMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          metadata: value,
        ),
      );
      policy.onPreliminary = null;
      final view = await service.get(id, groups);
      expect(view.supplementalMetadata!.categories.single.value, 'Original');
      expect(view.supplementalMetadata!.images.single.display, ['THUMBNAIL']);
      expect(view.supplementalMetadata!.refreshHint!.hours, 24);
      expect(
        () =>
            policy.lastSupplementalIntent!.supplementalMetadata!.images.clear(),
        throwsUnsupportedError,
      );
      await expectLater(
        service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarSupplementalMetadata(categories: [], images: []),
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      await service.delete(id, 2);
      expect(
        await CalendarDataRecord.db.findFirstRow(
          session,
          where: (t) => t.calendarId.equals(id),
        ),
        isNull,
      );
      expect(
        (await CalendarIdentityRecord.db.findById(
          session,
          id,
        ))!.toJson().keys.toSet(),
        {'__className__', 'id', 'scopeKey', 'revision', 'deletedAt'},
      );
    });
    test('unauthenticated direct service calls fail closed', () {
      expect(
        () => CalendarModule.service(builder.build()),
        throwsA(isA<CalendarException>()),
      );
    });
    test(
      'policy timeout cannot create data after returning unavailable',
      () async {
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
            policyTimeout: Duration(milliseconds: 20),
          ),
        );
        policy.delay = const Duration(milliseconds: 30);
        await expectLater(
          CalendarModule.service(session).create(createInput()),
          failure(CalendarFailureCode.unavailable),
        );
        await Future<void>.delayed(const Duration(milliseconds: 40));
        expect(await CalendarIdentityRecord.db.count(session), 0);
      },
    );
    test('bounded hidden scan fails instead of reporting exhaustion', () async {
      for (var i = 0; i < 3; i++) {
        policy.hidden.add((await service.create(createInput()))!.calendarId);
      }
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          maxScannedCalendars: 2,
        ),
      );
      await expectLater(
        CalendarModule.service(session).list(pageSize: 1, fieldGroups: groups),
        failure(CalendarFailureCode.limitExceeded),
      );
    });
    test(
      'live capability downgrade cannot weaken a coordinated write',
      () async {
        policy.capability = CalendarAuthorizationGuarantee.coordinated;
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.coordinated,
          ),
        );
        policy.capability = CalendarAuthorizationGuarantee.freshCheck;
        await expectLater(
          CalendarModule.service(session).create(createInput()),
          failure(CalendarFailureCode.unavailable),
        );
        expect(await CalendarIdentityRecord.db.count(session), 0);
      },
    );
    test(
      'invalid name, zone and oversized subject reject atomically',
      () async {
        await expectLater(
          service.create(createInput(' ')),
          failure(CalendarFailureCode.validation),
        );
        final input = createInput()..availabilityZoneId = 'europe/stockholm';
        await expectLater(
          service.create(input),
          failure(CalendarFailureCode.validation),
        );
        final id = (await service.create(createInput()))!.calendarId;
        await expectLater(
          service.changeSubject(
            CalendarSubjectChangeRequest(
              calendarId: id,
              expectedRevision: 1,
              action: CalendarSubjectAction.attach,
              namespace: 'a' * 129,
              kind: 'room',
              externalId: 'R',
              contributesAvailability: true,
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect((await service.get(id, groups)).revision, 1);
      },
    );
  });
}

final class TestPolicy implements CalendarHostPolicy {
  @override
  Future<CalendarAlarmRecipient> resolveAlarmRecipient(
    Session session,
    CalendarHostContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async =>
      alarmRecipientOverride?.call(phase) ??
      CalendarAlarmRecipient('demo', context.principalId);
  CalendarAlarmRecipient? Function(CalendarAuthorizationPhase)?
  alarmRecipientOverride;

  Duration organizerDelay = Duration.zero;
  Duration alarmActionFinalDelay = Duration.zero;
  CalendarAuthorizationRequest? lastAlarmAction;
  bool hideAlarmReceipt = false;
  CalendarAuthorizationRequest? lastAlarmAdoption;
  bool denyOrganizer = false, denyFinalOrganizer = false;
  bool organizerUnavailable = false;
  CalendarAuthorizationRequest? organizerRequest;
  final organizerPhases = <CalendarAuthorizationPhase>[];
  @override
  Future<CalendarAuthorizationVerdict> approveAvailabilityOrganizer(
    Session session,
    CalendarHostContext context,
    CalendarAuthorizationRequest request,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    await Future<void>.delayed(organizerDelay);
    organizerRequest = request;
    organizerPhases.add(phase);
    if (organizerUnavailable) {
      throw StateError('Synthetic organizer service failure');
    }
    return denyOrganizer ||
            (denyFinalOrganizer &&
                phase == CalendarAuthorizationPhase.finalWrite)
        ? CalendarAuthorizationVerdict.deny
        : CalendarAuthorizationVerdict.allow;
  }

  final resolverCalls = <String, int>{};
  CalendarSubjectResolution? Function(CalendarAvailabilityTarget, int)?
  resolveOverride;
  CalendarAuthorizationRequest? lastSearchRequest;
  final searchRequests = <CalendarAuthorizationRequest>[];
  final deniedSubjects = <String>{};
  void Function(CalendarAuthorizationRequest)? onSearchRead;
  UuidValue? denyReplacementId;
  bool hideReplacementReceipt = false;
  void Function(CalendarAuthorizationRequest, CalendarAuthorizationPhase)?
  onReplacement;
  final deniedExportIds = <UuidValue>{};
  void Function(CalendarAuthorizationRequest)? onExportBatch;
  void Function(CalendarAuthorizationRequest)? onFreeBusyRequest;
  final deniedTaskExports = <UuidValue>{};
  void Function(CalendarAuthorizationRequest)? onTaskExport;
  final deniedEventExports = <UuidValue>{};
  void Function(CalendarAuthorizationRequest)? onEventExport;
  String? denyTaskImportUid, hideTaskImportUid;
  bool hideTaskImportBatch = false, hideTaskProgressReceipt = false;
  final taskImportRequests =
      <(CalendarAuthorizationRequest, CalendarAuthorizationPhase)>[];
  Future<void> Function(
    Session,
    CalendarAuthorizationRequest,
    Transaction,
    CalendarAuthorizationPhase,
  )?
  onTaskImport;
  void Function(CalendarAuthorizationRequest)? onTaskReplacement;
  void Function(CalendarAuthorizationRequest)? onEventReplacement;
  String? denyEventImportUid, hideEventImportUid;
  bool hideEventImportBatch = false, hideEventLifecycleReceipt = false;
  final eventImportRequests =
      <(CalendarAuthorizationRequest, CalendarAuthorizationPhase)>[];
  Future<void> Function(
    Session,
    CalendarAuthorizationRequest,
    Transaction,
    CalendarAuthorizationPhase,
  )?
  onEventImport;
  String? denyImportUid, hideImportReceiptUid;
  bool hideImportBatchReceipt = false;
  Future<void> Function(
    Session,
    CalendarAuthorizationRequest,
    Transaction,
    CalendarAuthorizationPhase,
  )?
  onImportBatch;
  final denied = <CalendarPermission>{};
  final deniedReplySources = <UuidValue>{};
  final hidden = <UuidValue>{};
  Set<CalendarFieldGroup> grants = groups.toSet();
  Set<CalendarEventFieldGroup> eventGrants = eventGroups.toSet();
  Set<UuidValue>? taskCandidates;
  Set<CalendarTaskFieldGroup> taskGrants = CalendarTaskFieldGroup.values
      .toSet();
  CalendarAuthorizationRequest? lastTaskRequest;
  Set<UuidValue>? eventCandidates;
  CalendarAuthorizationRequest? lastEventRequest;
  CalendarAuthorizationRequest? lastAvailabilityRequest;
  final busyDenied = <UuidValue>{};
  bool denyFinal = false,
      malformed = false,
      unavailable = false,
      sawActualSnapshot = false;
  String epoch = 'v1';
  String? scopeOverride;
  CalendarPolicySnapshot? lastSnapshot;
  CalendarProposedChange? lastProtocolIntent;
  CalendarProposedChange? lastSupplementalIntent;
  bool sawCategoryFilter = false;
  void Function()? onPreliminary, onFinal;
  Duration delay = Duration.zero;
  CalendarAuthorizationGuarantee capability =
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  CalendarAuthorizationGuarantee get guarantee => capability;
  @override
  Future<CalendarHostContext> resolveContext(Session session) async =>
      CalendarHostContext(
        principalId: session.authenticated!.userIdentifier,
        scopeKey:
            scopeOverride ?? 'test:${session.authenticated!.userIdentifier}',
        policyRevision: epoch,
      );
  @override
  Future<CalendarSubjectResolution> resolveAvailabilitySubject(
    Session session,
    CalendarHostContext context,
    CalendarAvailabilityTarget target,
    Transaction transaction,
  ) async {
    final number = resolverCalls.update(
      target.externalId,
      (v) => v + 1,
      ifAbsent: () => 1,
    );
    final override = resolveOverride?.call(target, number);
    if (override != null) return override;
    final active = await CalendarIdentityRecord.db.find(
      session,
      where: (t) =>
          t.scopeKey.equals(context.scopeKey) & t.deletedAt.equals(null),
      orderBy: (t) => t.id,
      limit: 257,
      transaction: transaction,
    );
    if (active.length > 256) {
      return CalendarSubjectResolution(
        complete: false,
        revision: context.policyRevision,
        calendarIds: [],
      );
    }
    final links = active.isEmpty
        ? <CalendarSubjectRecord>[]
        : await CalendarSubjectRecord.db.find(
            session,
            where: (t) =>
                t.calendarId.inSet(active.map((a) => a.id!).toSet()) &
                t.namespace.equals(target.namespace) &
                t.kind.equals(target.kind) &
                t.externalId.equals(target.externalId) &
                t.contributesAvailability.equals(true),
            orderBy: (t) => t.calendarId,
            limit: 9,
            transaction: transaction,
          );
    final scope = await CalendarScopeRecord.db.findFirstRow(
      session,
      where: (t) => t.scopeKey.equals(context.scopeKey),
      transaction: transaction,
    );
    return CalendarSubjectResolution(
      complete: links.length <= 8,
      revision: '${context.policyRevision}:${scope?.revision ?? 0}',
      calendarIds: links.map((l) => l.calendarId),
    );
  }

  @override
  Future<CalendarTaskCandidatePlan> planTaskQuery(
    Session s,
    CalendarHostContext c,
    CalendarPolicySnapshot calendar,
    Set<CalendarTaskFieldGroup> groups,
  ) async => CalendarTaskCandidatePlan(taskIds: taskCandidates);
  @override
  Future<CalendarEventCandidatePlan> planEventQuery(
    Session s,
    CalendarHostContext c,
    CalendarPolicySnapshot calendar,
    Set<CalendarEventFieldGroup> groups,
  ) async => CalendarEventCandidatePlan(eventIds: eventCandidates);
  @override
  Future<CalendarCandidatePlan> planQuery(
    Session s,
    CalendarHostContext c,
    Set<CalendarFieldGroup> groups, {
    CalendarCategoryQuery? categoryFilter,
  }) async => CalendarCandidatePlan();
  @override
  Future<List<CalendarAuthorizationDecision>> authorizeBatch(
    Session s,
    CalendarHostContext c,
    List<CalendarAuthorizationRequest> requests,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    for (final request in requests) {
      if (request.operation == CalendarPermission.adoptPersonalAlarm) {
        lastAlarmAdoption = request;
      }
      if (request.alarmActionKind != null) {
        lastAlarmAction = request;
        if (phase == CalendarAuthorizationPhase.finalWrite) {
          await Future<void>.delayed(alarmActionFinalDelay);
        }
      }
      if (request.eventReplacement != null ||
          request.operation == CalendarPermission.replaceEventsFromImport) {
        onEventReplacement?.call(request);
      }
      if (request.taskReplacement != null ||
          request.operation == CalendarPermission.replaceTasksFromImport) {
        onTaskReplacement?.call(request);
      }
      if (request.taskExport != null) onTaskExport?.call(request);
      if (request.operation == CalendarPermission.exportEvents) {
        onEventExport?.call(request);
      }
      if (request.taskImport != null ||
          request.operation == CalendarPermission.importTasks) {
        taskImportRequests.add((request, phase));
        await onTaskImport?.call(s, request, tx, phase);
      }
      if (request.eventImport != null) {
        eventImportRequests.add((request, phase));
      }
      if (request.operation == CalendarPermission.importEvents) {
        await onEventImport?.call(s, request, tx, phase);
      }
      if (request.freeBusyQuery != null) onFreeBusyRequest?.call(request);
      if (request.operation ==
          CalendarPermission.replaceAvailabilityFromImport) {
        onReplacement?.call(request, phase);
      }
      if (request.operation == CalendarPermission.exportAvailability &&
          request.availabilityId == null) {
        onExportBatch?.call(request);
      }
      if (request.operation == CalendarPermission.importAvailability) {
        await onImportBatch?.call(s, request, tx, phase);
      }
      if (request.availabilityId != null ||
          request.proposedAvailability != null) {
        lastAvailabilityRequest = request;
      }
    }
    if (phase == CalendarAuthorizationPhase.preliminaryWrite) {
      onPreliminary?.call();
    }
    if (phase == CalendarAuthorizationPhase.finalWrite) {
      onFinal?.call();
    }
    await Future<void>.delayed(delay);
    if (unavailable) throw StateError('Synthetic policy outage');
    if (malformed) return [];
    return [for (final r in requests) decide(r, phase)];
  }

  CalendarAuthorizationDecision decide(
    CalendarAuthorizationRequest r,
    CalendarAuthorizationPhase phase,
  ) {
    if (r.availabilitySearchQuery != null) {
      lastSearchRequest = r;
      searchRequests.add(r);
      if (r.operation == CalendarPermission.readSubjectAvailability) {
        onSearchRead?.call(r);
      }
    }
    if (r.taskId != null) lastTaskRequest = r;
    if (r.eventId != null) lastEventRequest = r;
    if (r.categoryFilter != null) {
      sawCategoryFilter = true;
    }
    if (r.proposed?.supplementalMetadata != null) {
      lastSupplementalIntent = r.proposed;
    }
    if (r.proposed?.protocolMetadata != null) {
      lastProtocolIntent = r.proposed;
    }
    if (r.current != null) {
      sawActualSnapshot = true;
      lastSnapshot = r.current;
      if (r.current!.calendarId != r.calendarId) {
        throw StateError('Wrong snapshot');
      }
    }
    return CalendarAuthorizationDecision(
      key: r.key,
      verdict:
          (r.operation == CalendarPermission.exportTasks &&
                  deniedTaskExports.contains(r.taskId)) ||
              (r.taskImport != null &&
                  r.operation == CalendarPermission.createTask &&
                  phase == CalendarAuthorizationPhase.finalWrite &&
                  r.taskImport!.members.any(
                    (m) =>
                        m.taskId == r.taskId &&
                        m.protocolUid == denyTaskImportUid,
                  )) ||
              (r.operation == CalendarPermission.exportEvents &&
                  deniedEventExports.contains(r.eventId)) ||
              (r.eventImport != null &&
                  r.operation == CalendarPermission.createEvent &&
                  phase == CalendarAuthorizationPhase.finalWrite &&
                  r.eventImport!.members.any(
                    (m) =>
                        m.eventId == r.eventId &&
                        m.protocolUid == denyEventImportUid,
                  )) ||
              (r.availabilityImport != null &&
                  r.operation == CalendarPermission.createAvailability &&
                  r.availabilityImport!.members.any(
                    (m) =>
                        m.availabilityId == r.availabilityId &&
                        m.protocolUid == denyImportUid,
                  ) &&
                  phase == CalendarAuthorizationPhase.finalWrite) ||
              (r.operation == CalendarPermission.exportAvailability &&
                  deniedExportIds.contains(r.availabilityId)) ||
              (phase == CalendarAuthorizationPhase.finalWrite &&
                  r.operation ==
                      CalendarPermission.replaceAvailabilityFromImport &&
                  r.availabilityId != null &&
                  r.availabilityId == denyReplacementId) ||
              denied.contains(r.operation) ||
              (r.operation == CalendarPermission.readSchedulingReplySource &&
                  deniedReplySources.contains(r.schedulingReplySource?.id)) ||
              (r.operation == CalendarPermission.readSubjectAvailability &&
                  deniedSubjects.contains(r.availabilityTarget?.externalId)) ||
              (r.operation == CalendarPermission.projectEventBusy &&
                  busyDenied.contains(r.eventId)) ||
              hidden.contains(r.calendarId) ||
              (denyFinal && phase == CalendarAuthorizationPhase.finalWrite)
          ? CalendarAuthorizationVerdict.deny
          : CalendarAuthorizationVerdict.allow,
      disclosedGroups: grants,
      taskDisclosedGroups: taskGrants,
      eventDisclosedGroups: eventGrants,
      discloseMutationReceipt:
          !hideAlarmReceipt &&
          !(r.taskImport != null &&
              r.operation == CalendarPermission.changeTaskProgress &&
              hideTaskProgressReceipt) &&
          !(r.operation == CalendarPermission.importTasks &&
              hideTaskImportBatch) &&
          !(r.taskImport?.members.any(
                (m) =>
                    m.taskId == r.taskId && m.protocolUid == hideTaskImportUid,
              ) ??
              false) &&
          !(r.operation == CalendarPermission.importEvents &&
              hideEventImportBatch) &&
          !(r.eventImport != null &&
              r.operation == CalendarPermission.changeEventStatus &&
              hideEventLifecycleReceipt) &&
          !(r.eventImport?.members.any(
                (m) =>
                    m.eventId == r.eventId &&
                    m.protocolUid == hideEventImportUid,
              ) ??
              false) &&
          !(hideReplacementReceipt &&
              r.operation ==
                  CalendarPermission.replaceAvailabilityFromImport) &&
          r.operation != CalendarPermission.readAvailability &&
          !(r.operation == CalendarPermission.importAvailability &&
              hideImportBatchReceipt) &&
          !(r.availabilityImport?.members.any(
                (m) =>
                    m.availabilityId == r.availabilityId &&
                    m.protocolUid == hideImportReceiptUid,
              ) ??
              false),
    );
  }
}

final class BrokenDependency implements CalendarDependencyProvider {
  @override
  Future<bool> hasActiveDependencies(
    Session s,
    UuidValue id,
    Transaction tx,
  ) async => throw StateError('Synthetic dependency outage');
}

final class TestAlarmBackgroundPolicy implements CalendarAlarmBackgroundPolicy {
  CalendarAuthorizationVerdict verdict = CalendarAuthorizationVerdict.allow;
  CalendarAuthorizationVerdict? finalVerdict;
  final deniedOperations = <CalendarAlarmBackgroundOperation>{};
  CalendarAlarmBackgroundOperation? lastOperation;
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarAlarmBackgroundContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    lastOperation = context.operation;
    if (deniedOperations.contains(context.operation)) {
      return CalendarAuthorizationVerdict.deny;
    }
    return phase == CalendarAuthorizationPhase.finalWrite
        ? finalVerdict ?? verdict
        : verdict;
  }
}

final class TestAlarmDeliveryPort implements CalendarAlarmDeliveryPort {
  final accepted = <UuidValue, CalendarAlarmDeliveryIntent>{};
  int calls = 0;
  bool throwAfterAcceptance = false;
  bool decline = false;
  @override
  Future<bool> accept(
    Session session,
    CalendarAlarmDeliveryIntent intent,
  ) async {
    calls++;
    if (decline) return false;
    final alreadyAccepted = accepted.containsKey(intent.firingId);
    accepted.putIfAbsent(intent.firingId, () => intent);
    if (throwAfterAcceptance && !alreadyAccepted) {
      throw StateError('Synthetic crash after durable acceptance');
    }
    return true;
  }
}
