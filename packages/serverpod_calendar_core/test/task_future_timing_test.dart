import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int n) => CalendarDate(year: 2026, month: 1, day: n);
void main() {
  test(
    'DATE ranges replace absolute shifts and leave single timing independent',
    () {
      final r = DateRecurrenceSet(
        start: d(1),
        rule: DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.daily,
          count: 5,
        ),
        maxExplicitDates: 0,
      );
      final master = DateTaskTiming(start: d(1), due: d(2));
      final ranges = {
        d(2): DateTaskTiming(start: d(4), duration: CalendarDuration(days: 2)),
        d(4): DateTaskTiming(start: d(3)),
      };
      final singles = {d(3): DateTaskTiming(start: d(2), due: d(5))};
      final values = master.expandStarts(
        r,
        from: d(1),
        through: d(7),
        maxCandidateDays: 100,
        maxRuleOccurrences: 20,
        maxResults: 10,
        replacements: singles,
        futureChanges: ranges,
      );
      expect(values.map((o) => o.originalStart), [
        d(1),
        d(3),
        d(4),
        d(2),
        d(5),
      ]);
      expect(values.map((o) => o.timing.start), [d(1), d(2), d(3), d(4), d(4)]);
      expect(values[3].timing.effectiveDue, d(6));
      expect(values.last.timing.effectiveDue, isNull);
      expect(
        master.at(d(5), replacements: singles, futureChanges: ranges).start,
        d(4),
      );
      final narrow = master.expandStarts(
        r,
        from: d(4),
        through: d(4),
        maxCandidateDays: 100,
        maxRuleOccurrences: 20,
        maxResults: 10,
        replacements: singles,
        futureChanges: ranges,
      );
      expect(narrow.map((o) => o.originalStart), [d(2), d(5)]);
      expect(
        () => master.expandStarts(
          r,
          from: d(5),
          through: d(4),
          maxCandidateDays: 100,
          maxRuleOccurrences: 20,
          maxResults: 10,
          futureChanges: ranges,
        ),
        throwsArgumentError,
      );
      expect(
        () => master.expandStarts(
          r,
          from: d(1),
          through: d(7),
          maxCandidateDays: 100,
          maxRuleOccurrences: 20,
          maxResults: 10,
          replacements: {d(2): DateTaskTiming(start: d(1))},
          futureChanges: ranges,
        ),
        throwsArgumentError,
      );
      expect(
        () => master.expandStarts(
          r,
          from: d(1),
          through: d(7),
          maxCandidateDays: 1,
          maxRuleOccurrences: 20,
          maxResults: 10,
          futureChanges: ranges,
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
    },
  );
  test('range-generated out-of-profile starts outside the query are not materialized', () {
    final first = CalendarDate(year: 2099, month: 12, day: 30),
        last = CalendarDate(year: 2099, month: 12, day: 31);
    final r = DateRecurrenceSet(
      start: first,
      rule: DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.daily,
        count: 2,
      ),
      maxExplicitDates: 0,
    );
    final result = DateTaskTiming(start: first).expandStarts(
      r,
      from: last,
      through: last,
      maxCandidateDays: 20,
      maxRuleOccurrences: 10,
      maxResults: 10,
      futureChanges: {first: DateTaskTiming(start: last)},
    );
    expect(result.single.originalStart, first);
    expect(result.single.timing.start, last);
  });
  for (final zoned in [false, true]) {
    test(
      'timed ranges preserve civil shift and nominal DST duration $zoned',
      () {
        TimedValue t(int day, int hour) => zoned
            ? TimedValue.zoned(
                CivilDateTime(
                  date: CalendarDate(year: 2026, month: 3, day: day),
                  hour: hour,
                  minute: 0,
                ),
                zoneId: 'Europe/Stockholm',
              )
            : TimedValue.utc(DateTime.utc(2026, 3, day, hour));
        final master = TimedTaskTiming(start: t(28, 9));
        final r = TimedRecurrenceSet(
          start: t(28, 9),
          rule: TimedRecurrenceRule(
            frequency: TimedRecurrenceFrequency.daily,
            count: 4,
          ),
          maxExplicitDates: 0,
        );
        final ranges = {
          t(28, 9): TimedTaskTiming(
            start: t(28, 10),
            duration: CalendarDuration(days: 1),
          ),
          t(30, 9): TimedTaskTiming(start: t(30, 8)),
        };
        final result = master.expandStarts(
          r,
          window: UtcWindow(
            start: DateTime.utc(2026, 3, 28),
            end: DateTime.utc(2026, 4, 1),
          ),
          maxCandidateWork: 100,
          maxRuleOccurrences: 20,
          maxResults: 10,
          futureChanges: ranges,
          replacements: {
            t(29, 9): TimedTaskTiming(
              start: t(29, 7),
              duration: CalendarDuration(hours: 2),
            ),
          },
        );
        expect(result.map((o) => o.timing.start.civil.hour), [10, 7, 8, 8]);
        expect(
          result.first.timing.dueInstant!
              .difference(result.first.timing.start.instant)
              .inHours,
          zoned ? 23 : 24,
        );
        expect(result.first.timing.duration!.days, 1);
        expect(result.last.timing.dueInstant, isNull);
        expect(master.at(t(31, 9), futureChanges: ranges).start.civil.hour, 8);
      },
    );
  }
  test(
    'timed negative ranges move later originals into the effective query',
    () {
      TimedValue t(int n) => TimedValue.utc(DateTime.utc(2026, 1, n, 9));
      final r = TimedRecurrenceSet(
        start: t(1),
        rule: TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          count: 5,
        ),
        maxExplicitDates: 0,
      );
      final result = TimedTaskTiming(start: t(1)).expandStarts(
        r,
        window: UtcWindow(
          start: DateTime.utc(2026, 1, 1),
          end: DateTime.utc(2026, 1, 2),
        ),
        maxCandidateWork: 100,
        maxRuleOccurrences: 20,
        maxResults: 10,
        futureChanges: {
          t(3): TimedTaskTiming(
            start: t(1),
            duration: CalendarDuration(hours: 1),
          ),
        },
      );
      expect(result.map((o) => o.originalStart), [t(1), t(3)]);
      expect(result.last.timing.duration!.hours, 1);
    },
  );
}
