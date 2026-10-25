@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/alarm_values.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/task_recurrence_values.dart';

CalendarEventCivil civil(int day, {int hour = 10}) =>
    CalendarEventCivil(year: 2026, month: 3, day: day, hour: hour);
CalendarEventTiming time(int day, {int hour = 10}) => CalendarEventTiming(
  kind: CalendarEventTimeKind.utc,
  start: civil(day, hour: hour),
);
CalendarEventRecurrence recurrence() => CalendarEventRecurrence(
  rule: CalendarEventRule(
    frequency: CalendarEventFrequency.daily,
    count: 3,
    byDay: [],
    byMonthDay: [],
    byYearDay: [],
    byWeekNo: [],
    byMonth: [],
    byHour: [],
    byMinute: [],
    bySetPosition: [],
  ),
  inclusions: [],
  exclusions: [],
);
final window = UtcWindow(
  start: DateTime.utc(2026, 3, 28),
  end: DateTime.utc(2026, 4, 2),
);
final startAlarm = AlarmTiming.relative(
  offset: CalendarDuration(sign: -1, minutes: 5),
  anchor: AlarmAnchor.start,
);

void main() {
  test('event candidates retain original identities through moves and cancellation', () {
    final content = CalendarEventContent(
      timing: time(29).copyWith(duration: CalendarEventDuration(hours: 1)),
      recurrence: recurrence(),
    );
    final values = eventAlarmCandidates(
      content,
      CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: time(30),
            replacement: time(
              31,
              hour: 15,
            ).copyWith(duration: CalendarEventDuration(hours: 1)),
          ),
          CalendarEventSingleOverride(originalStart: time(31), cancelled: true),
        ],
        future: [],
      ),
      startAlarm,
      window,
    ).toList();
    expect(values, hasLength(2));
    expect(values.map((v) => v.dueAt), [
      DateTime.utc(2026, 3, 29, 9, 55),
      DateTime.utc(2026, 3, 31, 14, 55),
    ]);
    expect(values.last.originalKey, taskOriginalKey(time(30)));
  });
  test('event PERIOD own end is used rather than the master duration', () {
    final content = CalendarEventContent(
      timing: time(29).copyWith(duration: CalendarEventDuration(hours: 1)),
      periods: [time(30).copyWith(end: civil(30, hour: 14))],
    );
    final values = eventAlarmCandidates(
      content,
      null,
      AlarmTiming.relative(offset: CalendarDuration(), anchor: AlarmAnchor.end),
      window,
    ).toList();
    expect(values.map((v) => v.dueAt), [
      DateTime.utc(2026, 3, 29, 11),
      DateTime.utc(2026, 3, 30, 14),
    ]);
  });
  test('DATE-relative candidates resolve explicit local midnight over DST', () {
    final content = CalendarEventContent(
      timing: CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: civil(29, hour: 0),
      ),
      recurrence: recurrence(),
    );
    final values = eventAlarmCandidates(
      content,
      null,
      AlarmTiming.relative(
        offset: CalendarDuration(),
        anchor: AlarmAnchor.start,
        dateZoneId: 'Europe/Stockholm',
      ),
      window,
    ).toList();
    expect(values.map((v) => v.dueAt), [
      DateTime.utc(2026, 3, 28, 23),
      DateTime.utc(2026, 3, 29, 22),
      DateTime.utc(2026, 3, 30, 22),
    ]);
  });
  test('absolute candidates apply once per item despite recurrence', () {
    final content = CalendarEventContent(
      timing: time(29),
      recurrence: recurrence(),
    );
    final values = eventAlarmCandidates(
      content,
      null,
      AlarmTiming.absolute(utc: DateTime.utc(2026, 3, 29)),
      window,
    ).toList();
    expect(values.single.originalKey, 'item');
  });
  test('task future timing keeps original identity and independent progress records', () {
    final timing = CalendarTaskTiming(
      kind: CalendarTaskTimeKind.utc,
      start: civil(29),
      duration: CalendarEventDuration(hours: 1),
    );
    final content = CalendarTaskContent(
      timing: timing,
      recurrence: recurrence(),
    );
    final records = [
      CalendarTaskOccurrence(
        originalStart: time(30),
        futureTiming: timing.copyWith(start: civil(30, hour: 15)),
        progress: CalendarTaskProgress(percentComplete: 100),
      ),
    ];
    final values = taskAlarmCandidates(
      content,
      records,
      startAlarm,
      window,
    ).toList();
    expect(values.map((v) => v.dueAt), [
      DateTime.utc(2026, 3, 29, 9, 55),
      DateTime.utc(2026, 3, 30, 14, 55),
      DateTime.utc(2026, 3, 31, 14, 55),
    ]);
    expect(values[1].originalKey, taskOriginalKey(time(30)));
    expect(records.single.progress.status, isNull);
    expect(records.single.progress.percentComplete, 100);
  });
  test('removed task deadline invalidates END planning instead of dropping an occurrence', () {
    final timing = CalendarTaskTiming(
      kind: CalendarTaskTimeKind.utc,
      start: civil(29),
      duration: CalendarEventDuration(hours: 1),
    );
    final content = CalendarTaskContent(
      timing: timing,
      recurrence: recurrence(),
    );
    final records = [
      CalendarTaskOccurrence(
        originalStart: time(30),
        replacementTiming: timing.copyWith(start: civil(30), duration: null),
        progress: CalendarTaskProgress(),
      ),
    ];
    expect(
      () => taskAlarmCandidates(
        content,
        records,
        AlarmTiming.relative(
          offset: CalendarDuration(),
          anchor: AlarmAnchor.end,
        ),
        window,
      ).toList(),
      throwsArgumentError,
    );
  });
  test('inverse trigger window includes offsets/repeats and task deadline lookback', () {
    final alarm = AlarmTiming.relative(
      offset: CalendarDuration(sign: -1, hours: 2),
      anchor: AlarmAnchor.end,
      repeat: 2,
      repeatInterval: CalendarDuration(hours: 1),
    );
    final anchors = alarmAnchorWindow(
      alarm,
      window,
      endLookback: const Duration(days: 3),
    );
    expect(
      anchors.start,
      window.start.subtract(const Duration(days: 3, seconds: 1)),
    );
    expect(anchors.end, window.end.add(const Duration(hours: 2, seconds: 1)));
  });
  test('event explicit gap wall end retains core calendar-offset meaning at its anchor', () {
    final timing = CalendarEventTiming(
      kind: CalendarEventTimeKind.zoned,
      zoneId: 'Europe/Stockholm',
      start: civil(29, hour: 1).copyWith(minute: 30),
      end: civil(29, hour: 2).copyWith(minute: 30),
    );
    final alarm = AlarmTiming.relative(
      offset: CalendarDuration(sign: -1, days: 1),
      anchor: AlarmAnchor.end,
    );
    final expected = alarm.resolveTimedEvent(validateEventTiming(timing).$2!);
    expect(
      eventAlarmCandidates(
        CalendarEventContent(timing: timing),
        null,
        alarm,
        window,
      ).single.dueAt,
      expected.single,
    );
    expect(expected.single, DateTime.utc(2026, 3, 28, 1, 30));
  });
  test('recurring task explicit gap DUE retains core calendar-offset meaning at its anchor', () {
    final content = CalendarTaskContent(
      timing: CalendarTaskTiming(
        kind: CalendarTaskTimeKind.zoned,
        zoneId: 'Europe/Stockholm',
        start: civil(29, hour: 1).copyWith(minute: 30),
        due: civil(29, hour: 2).copyWith(minute: 30),
      ),
      recurrence: recurrence(),
    );
    final alarm = AlarmTiming.relative(
      offset: CalendarDuration(sign: -1, days: 1),
      anchor: AlarmAnchor.end,
    );
    expect(
      taskAlarmCandidates(content, [], alarm, window).first.dueAt,
      DateTime.utc(2026, 3, 28, 1, 30),
    );
  });
  test(
    'resolved later-fold END anchors are preserved in recurrence projections',
    () {
      final start = TimedValue.zoned(
        CivilDateTime(
          date: CalendarDate(year: 2026, month: 10, day: 25),
          hour: 1,
          minute: 30,
        ),
        zoneId: 'Europe/Stockholm',
      );
      final values =
          AlarmTiming.relative(
            offset: CalendarDuration(),
            anchor: AlarmAnchor.end,
          ).resolveTimedProjection(
            start: start,
            end: DateTime.utc(2026, 10, 25, 1, 30),
          );
      expect(values.single, DateTime.utc(2026, 10, 25, 1, 30));
    },
  );
}
