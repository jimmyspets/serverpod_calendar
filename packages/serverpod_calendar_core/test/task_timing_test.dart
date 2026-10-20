import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int day) => CalendarDate(year: 2026, month: 1, day: day);
TimedValue u(int day) => TimedValue.utc(DateTime.utc(2026, 1, day, 9));
TimedValue z(int day) => TimedValue.zoned(
  CivilDateTime(
    date: CalendarDate(year: 2026, month: 3, day: day),
    hour: 9,
    minute: 0,
  ),
  zoneId: 'Europe/Stockholm',
);
void main() {
  test('undated, due-only and start-only tasks have no invented end', () {
    expect(DateTaskTiming().effectiveDue, isNull);
    expect(DateTaskTiming(start: d(1)).effectiveDue, isNull);
    expect(DateTaskTiming(due: d(2)).effectiveDue, d(2));
    expect(TimedTaskTiming().effectiveDue, isNull);
    expect(TimedTaskTiming(start: u(1)).effectiveDue, isNull);
    expect(TimedTaskTiming(due: u(2)).effectiveDue, u(2).instant);
  });
  test('duration/start/due cardinality and positive endpoint constraints', () {
    for (final action in <void Function()>[
      () => DateTaskTiming(duration: CalendarDuration(days: 1)),
      () => DateTaskTiming(
        start: d(1),
        due: d(2),
        duration: CalendarDuration(days: 1),
      ),
      () => DateTaskTiming(start: d(1), due: d(1)),
      () => DateTaskTiming(start: d(1), due: d(1).addDays(-1)),
      () => DateTaskTiming(start: d(1), duration: CalendarDuration(hours: 1)),
      () => DateTaskTiming(start: d(1), duration: CalendarDuration()),
      () => TimedTaskTiming(duration: CalendarDuration(hours: 1)),
      () => TimedTaskTiming(
        start: u(1),
        due: u(2),
        duration: CalendarDuration(days: 1),
      ),
      () => TimedTaskTiming(start: u(1), due: u(1)),
      () => TimedTaskTiming(start: u(1), due: z(2)),
      () => TimedTaskTiming(
        start: u(1),
        duration: CalendarDuration(sign: -1, hours: 1),
      ),
    ]) {
      expect(action, throwsArgumentError);
    }
  });
  test('date task projection preserves due form and lacks event defaults', () {
    final due = DateTaskTiming(start: d(1), due: d(3));
    expect(due.at(d(5)).effectiveDue, d(7));
    expect(due.at(d(5)).due, d(7));
    final duration = DateTaskTiming(
      start: d(1),
      duration: CalendarDuration(days: 2),
    );
    expect(duration.at(d(5)).effectiveDue, d(7));
    expect(duration.at(d(5)).due, isNull);
    expect(DateTaskTiming(start: d(1)).at(d(5)).effectiveDue, isNull);
    expect(() => DateTaskTiming(due: d(3)).at(d(5)), throwsStateError);
    expect(due, DateTaskTiming(start: d(1), due: d(3)));
    expect(due.hashCode, DateTaskTiming(start: d(1), due: d(3)).hashCode);
  });
  test(
    'task recurrence uses unchanged original COUNT, additions and exclusions',
    () {
      final recurrence = DateRecurrenceSet(
        start: d(1),
        rule: DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.daily,
          count: 3,
        ),
        inclusions: [d(5)],
        exclusions: [d(2)],
        maxExplicitDates: 2,
      );
      final task = DateTaskTiming(
        start: d(1),
        duration: CalendarDuration(days: 1),
      );
      final values = task.expandStarts(
        recurrence,
        from: d(1),
        through: d(6),
        maxCandidateDays: 100,
        maxRuleOccurrences: 10,
        maxResults: 10,
      );
      expect(values.map((v) => v.originalStart), [d(1), d(3), d(5)]);
      expect(values.map((v) => v.timing.effectiveDue), [d(2), d(4), d(6)]);
      expect(
        () => DateTaskTiming().expandStarts(
          recurrence,
          from: d(1),
          through: d(6),
          maxCandidateDays: 100,
          maxRuleOccurrences: 10,
          maxResults: 10,
        ),
        throwsArgumentError,
      );
    },
  );
  test('zoned task nominal days and exact explicit due differ across DST', () {
    final nominal = TimedTaskTiming(
      start: z(28),
      duration: CalendarDuration(days: 1),
    );
    final exact = TimedTaskTiming(start: z(28), due: z(29));
    expect(nominal.effectiveDue, DateTime.utc(2026, 3, 29, 7));
    expect(nominal.at(z(29)).dueInstant, DateTime.utc(2026, 3, 30, 7));
    expect(exact.at(z(29)).dueInstant, DateTime.utc(2026, 3, 30, 6));
    expect(TimedTaskTiming(start: z(28)).at(z(29)).dueInstant, isNull);
    expect(() => nominal.at(u(1)), throwsArgumentError);
    expect(() => TimedTaskTiming(due: u(2)).at(u(1)), throwsStateError);
    expect(exact, TimedTaskTiming(start: z(28), due: z(29)));
    expect(exact.hashCode, TimedTaskTiming(start: z(28), due: z(29)).hashCode);
  });
  test('timed task recurrence projects milestones by start query', () {
    final r = TimedRecurrenceSet(
      start: u(1),
      rule: TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        count: 3,
      ),
      exclusions: [u(2)],
      maxExplicitDates: 1,
    );
    final values =
        TimedTaskTiming(
          start: u(1),
          duration: CalendarDuration(hours: 2),
        ).expandStarts(
          r,
          window: UtcWindow(start: u(1).instant, end: u(4).instant),
          maxCandidateWork: 100,
          maxRuleOccurrences: 10,
          maxResults: 10,
        );
    expect(values.map((v) => v.originalStart), [u(1), u(3)]);
    expect(values.last.timing.dueInstant, DateTime.utc(2026, 1, 3, 11));
    final periods = TimedRecurrenceSet(
      start: u(1),
      periods: [
        TimedEventSpan(start: u(2), duration: CalendarDuration(hours: 1)),
      ],
      maxExplicitDates: 1,
    );
    expect(
      () => TimedTaskTiming(start: u(1)).expandStarts(
        periods,
        window: UtcWindow(start: u(1).instant, end: u(4).instant),
        maxCandidateWork: 100,
        maxRuleOccurrences: 10,
        maxResults: 10,
      ),
      throwsArgumentError,
    );
  });
  test('last-date start-only task valid; unsupported computed dues reject', () {
    final last = CalendarDate(year: 2099, month: 12, day: 31);
    expect(DateTaskTiming(start: last).effectiveDue, isNull);
    expect(
      () => DateTaskTiming(start: last, duration: CalendarDuration(days: 1)),
      throwsRangeError,
    );
    expect(
      () => TimedTaskTiming(
        start: TimedValue.utc(DateTime.utc(2099, 12, 31, 23)),
        duration: CalendarDuration(hours: 1),
      ),
      throwsRangeError,
    );
  });
}
