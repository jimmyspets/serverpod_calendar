import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int day) => CalendarDate(year: 2026, month: 1, day: day);
TimedValue z(int day) => TimedValue.zoned(
  CivilDateTime(
    date: CalendarDate(year: 2026, month: 3, day: day),
    hour: 9,
    minute: 0,
  ),
  zoneId: 'Europe/Stockholm',
);
void main() {
  test('DATE moves include external originals, omit moved-out starts and sort collisions by original', () {
    final r = DateRecurrenceSet(
      start: d(1),
      rule: DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.daily,
        count: 4,
      ),
      maxExplicitDates: 0,
    );
    final master = DateTaskTiming(
      start: d(1),
      duration: CalendarDuration(days: 1),
    );
    final v = master.expandStarts(
      r,
      from: d(2),
      through: d(3),
      maxCandidateDays: 100,
      maxRuleOccurrences: 20,
      maxResults: 10,
      replacements: {
        d(1): DateTaskTiming(start: d(2)),
        d(2): DateTaskTiming(start: d(4)),
        d(4): DateTaskTiming(start: d(2), due: d(5)),
      },
    );
    expect(v.map((o) => o.originalStart), [d(1), d(4), d(3)]);
    expect(v.first.timing.effectiveDue, isNull);
    expect(v[1].timing.effectiveDue, d(5));
    expect(() => v.clear(), throwsUnsupportedError);
  });
  test(
    'DATE replacements reject orphans, result excess and exhausted shared work',
    () {
      final r = DateRecurrenceSet(
        start: d(1),
        rule: DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.daily,
          count: 4,
        ),
        maxExplicitDates: 0,
      );
      final master = DateTaskTiming(start: d(1));
      for (final settings in [(1, 100, d(1)), (10, 1, d(4))]) {
        expect(
          () => master.expandStarts(
            r,
            from: d(1),
            through: d(4),
            maxCandidateDays: settings.$2,
            maxRuleOccurrences: 20,
            maxResults: settings.$1,
            replacements: {settings.$3: DateTaskTiming(start: d(2))},
          ),
          throwsA(isA<RecurrenceLimitException>()),
        );
      }
      expect(
        () => master.expandStarts(
          r,
          from: d(1),
          through: d(4),
          maxCandidateDays: 100,
          maxRuleOccurrences: 20,
          maxResults: 10,
          replacements: {d(5): DateTaskTiming(start: d(2))},
        ),
        throwsArgumentError,
      );
      expect(
        () => master.expandStarts(
          r,
          from: d(1),
          through: d(4),
          maxCandidateDays: 100,
          maxRuleOccurrences: 20,
          maxResults: 10,
          replacements: {d(1): DateTaskTiming(due: d(2))},
        ),
        throwsArgumentError,
      );
    },
  );
  test('timed replacements preserve exact profile, DST nominal duration and original identity', () {
    final r = TimedRecurrenceSet(
      start: z(28),
      rule: TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        count: 3,
      ),
      maxExplicitDates: 0,
    );
    final master = TimedTaskTiming(start: z(28));
    final v = master.expandStarts(
      r,
      window: UtcWindow(
        start: DateTime.utc(2026, 3, 29),
        end: DateTime.utc(2026, 3, 30),
      ),
      maxCandidateWork: 100,
      maxRuleOccurrences: 20,
      maxResults: 10,
      replacements: {
        z(28): TimedTaskTiming(
          start: z(29),
          duration: CalendarDuration(days: 1),
        ),
        z(29): TimedTaskTiming(start: z(30)),
      },
    );
    expect(v.single.originalStart, z(28));
    expect(v.single.timing.start, z(29));
    expect(v.single.timing.dueInstant, DateTime.utc(2026, 3, 30, 7));
    expect(
      () => master.expandStarts(
        r,
        window: UtcWindow(
          start: DateTime.utc(2026, 3, 29),
          end: DateTime.utc(2026, 3, 30),
        ),
        maxCandidateWork: 100,
        maxRuleOccurrences: 20,
        maxResults: 10,
        replacements: {
          z(28): TimedTaskTiming(
            start: TimedValue.utc(DateTime.utc(2026, 3, 29)),
          ),
        },
      ),
      throwsArgumentError,
    );
  });
}
