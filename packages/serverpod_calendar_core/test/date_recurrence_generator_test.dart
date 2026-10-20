import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int y, int m, int day) =>
    CalendarDate(year: y, month: m, day: day);
void main() {
  final generator = DateRecurrenceGenerator();
  List<CalendarDate> expand(
    CalendarDate start,
    DateRecurrenceRule rule, {
    CalendarDate? from,
    CalendarDate? through,
    int work = 10000,
    int results = 100,
  }) => generator.expand(
    start: start,
    rule: rule,
    from: from ?? start,
    through: through ?? d(2030, 12, 31),
    maxCandidateDays: work,
    maxResults: results,
  );
  ByDayValue day(Weekday weekday, [int? ordinal]) =>
      ByDayValue(weekday: weekday, ordinal: ordinal);

  test('daily interval and inclusive query/UNTIL bounds', () {
    final rule = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.daily,
      interval: 2,
      until: d(2026, 1, 7),
    );
    expect(
      expand(d(2026, 1, 1), rule, from: d(2026, 1, 3), through: d(2026, 1, 7)),
      [d(2026, 1, 3), d(2026, 1, 5), d(2026, 1, 7)],
    );
    expect(
      expand(d(2026, 1, 1), rule, from: d(2026, 1, 7), through: d(2026, 1, 7)),
      [d(2026, 1, 7)],
    );
  });
  test('COUNT includes start and occurrences before the query', () {
    final rule = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.daily,
      count: 3,
    );
    expect(expand(d(2026, 1, 1), rule, from: d(2026, 1, 3)), [d(2026, 1, 3)]);
    expect(expand(d(2026, 1, 1), rule, from: d(2026, 1, 4)), isEmpty);
  });
  test('weekly defaults to DTSTART weekday', () {
    expect(
      expand(
        d(2026, 1, 5),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.weekly,
          interval: 2,
          count: 3,
        ),
      ),
      [d(2026, 1, 5), d(2026, 1, 19), d(2026, 2, 2)],
    );
  });
  test('RFC-style two-week Tuesday/Sunday example changes with WKST', () {
    final days = [day(Weekday.tuesday), day(Weekday.sunday)];
    expect(
      expand(
        d(1997, 8, 5),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.weekly,
          interval: 2,
          count: 4,
          byDay: days,
        ),
      ),
      [d(1997, 8, 5), d(1997, 8, 10), d(1997, 8, 19), d(1997, 8, 24)],
    );
    expect(
      expand(
        d(1997, 8, 5),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.weekly,
          interval: 2,
          count: 4,
          byDay: days,
          weekStart: Weekday.sunday,
        ),
      ),
      [d(1997, 8, 5), d(1997, 8, 17), d(1997, 8, 19), d(1997, 8, 31)],
    );
  });
  for (final weekStart in Weekday.values) {
    test('weekly interval one retains all weekdays for $weekStart', () {
      expect(
        expand(
          d(2026, 1, 1),
          DateRecurrenceRule(
            frequency: DateRecurrenceFrequency.weekly,
            weekStart: weekStart,
            count: 3,
            byDay: [day(Weekday.thursday)],
          ),
        ),
        [d(2026, 1, 1), d(2026, 1, 8), d(2026, 1, 15)],
      );
    });
  }
  test('monthly day 31 skips invalid dates without consuming COUNT', () {
    expect(
      expand(
        d(2026, 1, 31),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.monthly,
          count: 4,
        ),
      ),
      [d(2026, 1, 31), d(2026, 3, 31), d(2026, 5, 31), d(2026, 7, 31)],
    );
  });
  test('yearly February 29 skips non-leap years including 2100', () {
    expect(
      expand(
        d(2096, 2, 29),
        DateRecurrenceRule(frequency: DateRecurrenceFrequency.yearly, count: 3),
        through: d(2108, 12, 31),
      ),
      [d(2096, 2, 29), d(2104, 2, 29), d(2108, 2, 29)],
    );
  });
  test('monthly negative month day and weekday ordinal', () {
    expect(
      expand(
        d(2026, 1, 31),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.monthly,
          byMonthDay: [-1],
          count: 3,
        ),
      ),
      [d(2026, 1, 31), d(2026, 2, 28), d(2026, 3, 31)],
    );
    expect(
      expand(
        d(2026, 1, 30),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.monthly,
          byDay: [day(Weekday.friday, -1)],
          count: 3,
        ),
      ),
      [d(2026, 1, 30), d(2026, 2, 27), d(2026, 3, 27)],
    );
  });
  test('yearly BYMONTH inherits day while BYMONTHDAY expands months', () {
    expect(
      expand(
        d(2026, 1, 10),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          byMonth: [1, 3],
          count: 3,
        ),
      ),
      [d(2026, 1, 10), d(2026, 3, 10), d(2027, 1, 10)],
    );
    expect(
      expand(
        d(2026, 1, 10),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          byMonthDay: [10],
          count: 3,
        ),
      ),
      [d(2026, 1, 10), d(2026, 2, 10), d(2026, 3, 10)],
    );
  });
  test('yearly ordinal weekdays use year scope or selected month scope', () {
    expect(
      expand(
        d(2026, 1, 5),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          byDay: [day(Weekday.monday, 1)],
          count: 2,
        ),
      ),
      [d(2026, 1, 5), d(2027, 1, 4)],
    );
    expect(
      expand(
        d(2026, 2, 2),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          byMonth: [2, 3],
          byDay: [day(Weekday.monday, 1)],
          count: 3,
        ),
      ),
      [d(2026, 2, 2), d(2026, 3, 2), d(2027, 2, 1)],
    );
  });
  test('signed year-day selectors respect leap-year lengths', () {
    expect(
      expand(
        d(2024, 12, 31),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          byYearDay: [366],
          count: 2,
        ),
        through: d(2028, 12, 31),
      ),
      [d(2024, 12, 31), d(2028, 12, 31)],
    );
    expect(
      expand(
        d(2026, 12, 31),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          byYearDay: [-1],
          count: 2,
        ),
      ),
      [d(2026, 12, 31), d(2027, 12, 31)],
    );
  });
  test('BYSETPOS applies after filters across the complete cadence period', () {
    final weekdays = [
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
      Weekday.thursday,
      Weekday.friday,
    ].map((v) => day(v)).toList();
    final rule = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.monthly,
      byDay: weekdays,
      bySetPosition: [-1, 99],
      count: 3,
    );
    expect(expand(d(2026, 1, 30), rule), [
      d(2026, 1, 30),
      d(2026, 2, 27),
      d(2026, 3, 31),
    ]);
    expect(expand(d(2026, 1, 30), rule, through: d(2026, 2, 15)), [
      d(2026, 1, 30),
    ]);
  });
  test('overlapping BYDAY/BYSETPOS selections produce one occurrence', () {
    expect(
      expand(
        d(2026, 1, 5),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.monthly,
          byDay: [day(Weekday.monday), day(Weekday.monday, 1)],
          bySetPosition: [1, -4],
          count: 2,
        ),
      ),
      [d(2026, 1, 5), d(2026, 2, 2)],
    );
  });
  test(
    'mismatched filters or set positions reject DTSTART even outside query',
    () {
      expect(
        () => expand(
          d(2026, 1, 1),
          DateRecurrenceRule(
            frequency: DateRecurrenceFrequency.daily,
            byMonth: [2],
          ),
          from: d(2026, 3, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => expand(
          d(2026, 1, 5),
          DateRecurrenceRule(
            frequency: DateRecurrenceFrequency.monthly,
            byDay: [day(Weekday.monday)],
            bySetPosition: [-1],
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => expand(
          d(2026, 1, 5),
          DateRecurrenceRule(
            frequency: DateRecurrenceFrequency.daily,
            until: d(2026, 1, 4),
          ),
        ),
        throwsArgumentError,
      );
    },
  );
  test('unsupported week-number rules fail before any results, including COUNT one', () {
    expect(
      () => expand(
        d(2026, 1, 1),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          byWeekNo: [1],
          count: 1,
        ),
      ),
      throwsUnsupportedError,
    );
  });
  test('work limit counts rejected candidates and pre-query history', () {
    expect(
      () => expand(
        d(2026, 1, 1),
        DateRecurrenceRule(frequency: DateRecurrenceFrequency.daily),
        from: d(2026, 2, 1),
        through: d(2026, 2, 2),
        work: 10,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => expand(
        d(2026, 1, 31),
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.monthly,
          count: 2,
        ),
        work: 32,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('result cap throws rather than returning a truncated list', () {
    final rule = DateRecurrenceRule(frequency: DateRecurrenceFrequency.daily);
    expect(
      () => expand(d(2026, 1, 1), rule, through: d(2026, 1, 3), results: 2),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(expand(d(2026, 1, 1), rule, through: d(2026, 1, 2), results: 2), [
      d(2026, 1, 1),
      d(2026, 1, 2),
    ]);
  });
  test('exact work/result budget and COUNT termination succeed', () {
    final dates = expand(
      d(2026, 1, 1),
      DateRecurrenceRule(frequency: DateRecurrenceFrequency.daily, count: 1),
      work: 1,
      results: 1,
    );
    expect(dates, [d(2026, 1, 1)]);
    expect(() => dates.clear(), throwsUnsupportedError);
  });
  test(
    'huge cadence steps terminate safely without multiplication overflow',
    () {
      for (final frequency in DateRecurrenceFrequency.values) {
        expect(
          expand(
            d(2026, 1, 1),
            DateRecurrenceRule(
              frequency: frequency,
              interval: DateRecurrenceRule.maxScalar,
            ),
          ),
          [d(2026, 1, 1)],
        );
      }
    },
  );
  test(
    'closed date query covers both year profile edges without timestamps',
    () {
      expect(
        expand(
          d(9999, 12, 31),
          DateRecurrenceRule(frequency: DateRecurrenceFrequency.daily),
          through: d(9999, 12, 31),
        ),
        [d(9999, 12, 31)],
      );
      expect(
        expand(
          d(1, 1, 1),
          DateRecurrenceRule(
            frequency: DateRecurrenceFrequency.weekly,
            weekStart: Weekday.tuesday,
            count: 2,
          ),
          through: d(1, 1, 8),
        ),
        [d(1, 1, 1), d(1, 1, 8)],
      );
    },
  );
  test(
    'empty queries before DTSTART and after UNTIL still validate the series',
    () {
      final rule = DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.daily,
        until: d(2026, 1, 5),
      );
      expect(
        expand(
          d(2026, 1, 1),
          rule,
          from: d(2025, 1, 1),
          through: d(2025, 1, 2),
        ),
        isEmpty,
      );
      expect(
        expand(
          d(2026, 1, 1),
          rule,
          from: d(2026, 2, 1),
          through: d(2026, 2, 2),
        ),
        isEmpty,
      );
    },
  );
  test('invalid query order and nonpositive budgets fail', () {
    final rule = DateRecurrenceRule(frequency: DateRecurrenceFrequency.daily);
    expect(
      () => expand(
        d(2026, 1, 1),
        rule,
        from: d(2026, 2, 1),
        through: d(2026, 1, 1),
      ),
      throwsArgumentError,
    );
    expect(() => expand(d(2026, 1, 1), rule, work: 0), throwsRangeError);
    expect(() => expand(d(2026, 1, 1), rule, results: -1), throwsRangeError);
  });
  test(
    'BYSETPOS refuses a weekly period clipped by either date-profile edge',
    () {
      expect(
        () => expand(
          d(1, 1, 1),
          DateRecurrenceRule(
            frequency: DateRecurrenceFrequency.weekly,
            weekStart: Weekday.tuesday,
            byDay: [day(Weekday.monday)],
            bySetPosition: [1],
          ),
          through: d(1, 1, 8),
        ),
        throwsRangeError,
      );
      expect(
        () => expand(
          d(9999, 12, 31),
          DateRecurrenceRule(
            frequency: DateRecurrenceFrequency.weekly,
            byDay: [day(Weekday.friday)],
            bySetPosition: [-1],
          ),
          through: d(9999, 12, 31),
        ),
        throwsRangeError,
      );
    },
  );
}
