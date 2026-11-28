import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

CalendarDate date(int y, int m, int d) =>
    CalendarDate(year: y, month: m, day: d);
CivilDateTime civil(int y, int m, int d, int h, [int minute = 0]) =>
    CivilDateTime(date: date(y, m, d), hour: h, minute: minute);
TimedValue zoned(int y, int m, int d, int h, [int minute = 0]) =>
    TimedValue.zoned(civil(y, m, d, h, minute), zoneId: 'Europe/Stockholm');
AlarmTiming relative(
  CalendarDuration offset, {
  AlarmAnchor anchor = AlarmAnchor.start,
  String? zone,
  int? repeat,
  CalendarDuration? interval,
}) => AlarmTiming.relative(
  offset: offset,
  anchor: anchor,
  dateZoneId: zone,
  repeat: repeat,
  repeatInterval: interval,
);

void main() {
  test('absolute applies once per item and supports undated tasks', () {
    final due = DateTime.utc(2026, 3, 29, 12);
    final timing = AlarmTiming.absolute(utc: due);
    expect(timing.resolveUndatedTask(), [due]);
    expect(timing.resolveDateEvent(DateEventSpan(start: date(2026, 3, 29))), [
      due,
    ]);
    expect(() => timing.resolveUndatedTask().add(due), throwsUnsupportedError);
  });
  test('UTC start and explicit END offsets preserve whole seconds', () {
    final event = TimedEventSpan(
      start: TimedValue.utc(DateTime.utc(2026, 3, 29, 12)),
      end: TimedValue.utc(DateTime.utc(2026, 3, 29, 13)),
    );
    expect(
      relative(CalendarDuration(sign: -1, minutes: 5)).resolveTimedEvent(event),
      [DateTime.utc(2026, 3, 29, 11, 55)],
    );
    expect(
      relative(
        CalendarDuration(sign: -1, seconds: 2),
        anchor: AlarmAnchor.end,
      ).resolveTimedEvent(event),
      [DateTime.utc(2026, 3, 29, 12, 59, 58)],
    );
  });
  test('implicit event ends never supply END alarm anchors', () {
    final timing = relative(
      CalendarDuration(),
      anchor: AlarmAnchor.end,
      zone: 'UTC',
    );
    expect(
      () => timing.resolveDateEvent(DateEventSpan(start: date(2026, 3, 29))),
      throwsArgumentError,
    );
    expect(
      () => timing.resolveTimedEvent(
        TimedEventSpan(start: TimedValue.utc(DateTime.utc(2026, 3, 29))),
      ),
      throwsArgumentError,
    );
  });
  test('DATE midnight is resolved only in the explicit supplied zone', () {
    final event = DateEventSpan(start: date(2026, 3, 29));
    expect(
      () => relative(CalendarDuration()).resolveDateEvent(event),
      throwsArgumentError,
    );
    expect(
      relative(
        CalendarDuration(),
        zone: 'Europe/Stockholm',
      ).resolveDateEvent(event),
      [DateTime.utc(2026, 3, 28, 23)],
    );
    expect(
      () => relative(CalendarDuration(), zone: 'europe/stockholm'),
      throwsArgumentError,
    );
  });
  test('calendar-day and clock offsets differ across DST', () {
    final event = TimedEventSpan(start: zoned(2026, 3, 28, 12));
    expect(relative(CalendarDuration(days: 1)).resolveTimedEvent(event), [
      DateTime.utc(2026, 3, 29, 10),
    ]);
    expect(relative(CalendarDuration(hours: 24)).resolveTimedEvent(event), [
      DateTime.utc(2026, 3, 29, 11),
    ]);
  });
  test('explicit gap and fold anchors retain the RFC interpretation', () {
    final zero = relative(CalendarDuration());
    expect(
      zero.resolveTimedEvent(TimedEventSpan(start: zoned(2026, 3, 29, 2, 30))),
      [DateTime.utc(2026, 3, 29, 1, 30)],
    );
    expect(
      zero.resolveTimedEvent(TimedEventSpan(start: zoned(2026, 10, 25, 2, 30))),
      [DateTime.utc(2026, 10, 25, 0, 30)],
    );
  });
  test(
    'duration-derived later-fold END is never reinterpreted as the first fold',
    () {
      final event = TimedEventSpan(
        start: zoned(2026, 10, 25, 1, 30),
        duration: CalendarDuration(hours: 2),
      );
      expect(
        relative(
          CalendarDuration(),
          anchor: AlarmAnchor.end,
          repeat: 1,
          interval: CalendarDuration(minutes: 30),
        ).resolveTimedEvent(event),
        [DateTime.utc(2026, 10, 25, 1, 30), DateTime.utc(2026, 10, 25, 2)],
      );
    },
  );
  test('repeat intervals start at preceding resolved firing across DST', () {
    final event = TimedEventSpan(start: zoned(2026, 3, 28, 12));
    expect(
      relative(
        CalendarDuration(),
        repeat: 2,
        interval: CalendarDuration(days: 1),
      ).resolveTimedEvent(event),
      [
        DateTime.utc(2026, 3, 28, 11),
        DateTime.utc(2026, 3, 29, 10),
        DateTime.utc(2026, 3, 30, 10),
      ],
    );
    expect(
      relative(
        CalendarDuration(),
        repeat: 1,
        interval: CalendarDuration(hours: 24),
      ).resolveTimedEvent(event),
      [DateTime.utc(2026, 3, 28, 11), DateTime.utc(2026, 3, 29, 11)],
    );
  });
  test('a skipped civil day does not duplicate a repeated firing instant', () {
    final event = TimedEventSpan(
      start: TimedValue.zoned(civil(2011, 12, 29, 10), zoneId: 'Pacific/Apia'),
    );
    expect(
      relative(
        CalendarDuration(),
        repeat: 2,
        interval: CalendarDuration(days: 1),
      ).resolveTimedEvent(event),
      [
        DateTime.utc(2011, 12, 29, 20),
        DateTime.utc(2011, 12, 30, 20),
        DateTime.utc(2011, 12, 31, 20),
      ],
    );
  });
  test('exclusive UTC and DATE endpoints can anchor negative offsets only', () {
    final timing = relative(
      CalendarDuration(sign: -1, minutes: 5),
      anchor: AlarmAnchor.end,
      zone: 'UTC',
    );
    final dateEvent = DateEventSpan(
      start: date(2099, 12, 31),
      end: const CalendarDate.exclusiveEnd(),
    );
    final timedEvent = TimedEventSpan(
      start: TimedValue.utc(DateTime.utc(2099, 12, 31)),
      end: TimedValue.utcEnd(DateTime.utc(2100)),
    );
    expect(timing.resolveDateEvent(dateEvent), [
      DateTime.utc(2099, 12, 31, 23, 55),
    ]);
    expect(timing.resolveTimedEvent(timedEvent), [
      DateTime.utc(2099, 12, 31, 23, 55),
    ]);
    expect(
      () => relative(
        CalendarDuration(),
        anchor: AlarmAnchor.end,
      ).resolveTimedEvent(timedEvent),
      throwsRangeError,
    );
    expect(
      () => AlarmTiming.absolute(
        utc: DateTime.utc(2099, 12, 31, 23, 59, 59),
        repeat: 1,
        repeatInterval: CalendarDuration(seconds: 1),
      ).resolveUndatedTask(),
      throwsRangeError,
    );
  });
  test(
    'task anchors distinguish absent start, explicit due and duration due',
    () {
      final due = TimedTaskTiming(
        due: TimedValue.utc(DateTime.utc(2026, 3, 29, 12)),
      );
      expect(
        () => relative(CalendarDuration()).resolveTimedTask(due),
        throwsArgumentError,
      );
      expect(
        relative(
          CalendarDuration(),
          anchor: AlarmAnchor.end,
        ).resolveTimedTask(due),
        [DateTime.utc(2026, 3, 29, 12)],
      );
      expect(
        relative(
          CalendarDuration(sign: -1, hours: 1),
          anchor: AlarmAnchor.end,
          zone: 'Europe/Stockholm',
        ).resolveDateTask(
          DateTaskTiming(
            start: date(2026, 3, 29),
            duration: CalendarDuration(days: 1),
          ),
        ),
        [DateTime.utc(2026, 3, 29, 21)],
      );
      expect(
        () => relative(CalendarDuration()).resolveUndatedTask(),
        throwsArgumentError,
      );
    },
  );
  test('resolved recurrence projections retain later-fold ends and reject absent END', () {
    final start = TimedValue.zoned(
      CivilDateTime(date: date(2026, 10, 25), hour: 1, minute: 30),
      zoneId: 'Europe/Stockholm',
    );
    final alarm = relative(CalendarDuration(), anchor: AlarmAnchor.end);
    expect(
      alarm.resolveTimedProjection(
        start: start,
        end: DateTime.utc(2026, 10, 25, 1, 30),
      ),
      [DateTime.utc(2026, 10, 25, 1, 30)],
    );
    expect(
      () => alarm.resolveTimedProjection(start: start),
      throwsArgumentError,
    );
    expect(
      () => alarm.resolveTimedProjection(start: start, end: start.instant),
      throwsArgumentError,
    );
  });
  test(
    'configuration and arithmetic bounds reject without partial firings',
    () {
      expect(
        () => AlarmTiming.absolute(utc: DateTime.utc(2026, 1, 1, 0, 0, 0, 1)),
        throwsArgumentError,
      );
      expect(
        () => AlarmTiming.absolute(utc: DateTime(2026)),
        throwsArgumentError,
      );
      expect(
        () => relative(CalendarDuration(weeks: CalendarDuration.maxComponent)),
        throwsArgumentError,
      );
      expect(
        () => relative(CalendarDuration(), repeat: 1),
        throwsArgumentError,
      );
      expect(
        () => relative(
          CalendarDuration(),
          repeat: 101,
          interval: CalendarDuration(seconds: 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => relative(
          CalendarDuration(),
          repeat: 1,
          interval: CalendarDuration(),
        ),
        throwsArgumentError,
      );
      expect(
        () => relative(
          CalendarDuration(),
          repeat: 100,
          interval: CalendarDuration(days: 4),
        ),
        throwsArgumentError,
      );
      expect(
        () => relative(CalendarDuration(sign: -1, seconds: 1))
            .resolveTimedEvent(
              TimedEventSpan(start: TimedValue.utc(DateTime.utc(1970))),
            ),
        throwsRangeError,
      );
    },
  );
}
