import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int y, int m, int day) =>
    CalendarDate(year: y, month: m, day: day);
void main() {
  final generator = DateRecurrenceGenerator();
  List<CalendarDate> expand(
    CalendarDate start,
    List<int> weeks, {
    Weekday wkst = Weekday.monday,
    List<ByDayValue> days = const [],
    List<int> months = const [],
    List<int> positions = const [],
    int interval = 1,
    int? count,
    CalendarDate? through,
    int work = 10000,
    int results = 100,
  }) => generator.expand(
    start: start,
    rule: DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.yearly,
      interval: interval,
      count: count,
      weekStart: wkst,
      byWeekNo: weeks,
      byDay: days,
      byMonth: months,
      bySetPosition: positions,
    ),
    from: start,
    through: through ?? d(2030, 12, 31),
    maxCandidateDays: work,
    maxResults: results,
  );
  final monday = ByDayValue(weekday: Weekday.monday);

  test(
    'week one includes December dates with no inherited weekday restriction',
    () {
      expect(expand(d(2019, 12, 30), [1], through: d(2020, 1, 5)), [
        d(2019, 12, 30),
        d(2019, 12, 31),
        d(2020, 1, 1),
        d(2020, 1, 2),
        d(2020, 1, 3),
        d(2020, 1, 4),
        d(2020, 1, 5),
      ]);
    },
  );
  test(
    'week 53 includes January dates belonging to the previous week-year',
    () {
      final expected = [
        d(2020, 12, 28),
        d(2020, 12, 29),
        d(2020, 12, 30),
        d(2020, 12, 31),
        d(2021, 1, 1),
        d(2021, 1, 2),
        d(2021, 1, 3),
      ];
      expect(expand(d(2020, 12, 28), [53], through: d(2021, 1, 3)), expected);
      expect(expand(d(2020, 12, 28), [-1], through: d(2021, 1, 3)), expected);
    },
  );
  test('missing week 53 does not consume COUNT or become week 52', () {
    expect(expand(d(2020, 12, 28), [53], days: [monday], count: 2), [
      d(2020, 12, 28),
      d(2026, 12, 28),
    ]);
  });
  test(
    'negative ordinal uses the week-year length of a December boundary date',
    () {
      expect(expand(d(2014, 12, 29), [-53], days: [monday], count: 2), [
        d(2014, 12, 29),
        d(2019, 12, 30),
      ]);
    },
  );
  test('negative week 52 can select week one of a 52-week week-year', () {
    expect(
      expand(d(2017, 1, 2), [-52], through: d(2017, 1, 8)),
      List.generate(7, (i) => d(2017, 1, 2).addDays(i)),
    );
  });
  test(
    'YEARLY interval stays anchored to calendar years across December week one',
    () {
      expect(
        expand(d(2019, 12, 30), [1], interval: 2, days: [monday], count: 3),
        [d(2019, 12, 30), d(2021, 1, 4), d(2023, 1, 2)],
      );
    },
  );
  test(
    'BYMONTH filters calendar months while week selection crosses the year',
    () {
      expect(
        expand(d(2014, 12, 29), [1], months: [12], days: [monday], count: 3),
        [d(2014, 12, 29), d(2018, 12, 31), d(2019, 12, 30)],
      );
    },
  );
  test('BYSETPOS selects from all matching dates in the calendar year', () {
    expect(
      expand(
        d(2017, 1, 8),
        [1],
        days: [ByDayValue(weekday: Weekday.sunday)],
        positions: [1],
        count: 3,
      ),
      [d(2017, 1, 8), d(2018, 1, 7), d(2019, 1, 6)],
    );
  });
  test(
    'positive/negative aliases and duplicate selectors do not duplicate COUNT',
    () {
      expect(expand(d(2020, 12, 28), [53, -1, 53], days: [monday], count: 2), [
        d(2020, 12, 28),
        d(2021, 12, 27),
      ]);
    },
  );
  final january2021 = <Weekday, int>{
    Weekday.monday: 53,
    Weekday.tuesday: 1,
    Weekday.wednesday: 1,
    Weekday.thursday: 1,
    Weekday.friday: 1,
    Weekday.saturday: 52,
    Weekday.sunday: 53,
  };
  for (final entry in january2021.entries) {
    test('January boundary uses four-day week numbering for ${entry.key}', () {
      expect(expand(d(2021, 1, 1), [entry.value], wkst: entry.key, count: 1), [
        d(2021, 1, 1),
      ]);
      expect(
        () => expand(
          d(2021, 1, 1),
          [entry.value == 1 ? 53 : 1],
          wkst: entry.key,
          count: 1,
        ),
        throwsArgumentError,
      );
    });
  }
  test(
    'virtual adjacent week-years do not create year-zero or year-10000 dates',
    () {
      expect(
        expand(
          d(1, 1, 1),
          [-1],
          wkst: Weekday.tuesday,
          count: 1,
          through: d(1, 12, 31),
        ),
        [d(1, 1, 1)],
      );
      expect(
        expand(
          d(9999, 12, 31),
          [1],
          wkst: Weekday.friday,
          count: 1,
          through: d(9999, 12, 31),
        ),
        [d(9999, 12, 31)],
      );
      expect(() => d(0, 1, 1), throwsRangeError);
      expect(() => d(10000, 1, 1), throwsRangeError);
    },
  );
  test(
    'week-number work and result exhaustion still throw without truncation',
    () {
      expect(
        () => expand(d(2020, 12, 28), [53], count: 1, work: 10),
        throwsA(isA<RecurrenceLimitException>()),
      );
      expect(
        () => expand(d(2020, 12, 28), [53], through: d(2021, 1, 3), results: 2),
        throwsA(isA<RecurrenceLimitException>()),
      );
    },
  );
  for (final wkst in Weekday.values) {
    test(
      '400-year first/last-week membership agrees with fourth-day anchors for $wkst',
      () {
        final start = d(1600, 1, 4);
        final end = d(1999, 12, 31);
        final actual = expand(
          start,
          [1, -1],
          wkst: wkst,
          through: end,
          work: 146097,
          results: 6000,
        );
        final expected = <CalendarDate>[];
        final length = start.daysUntil(end);
        for (var i = 0; i <= length; i++) {
          final date = start.addDays(i);
          // Independent construction: the fourth weekday determines week-year.
          final fourth = date.addDays(
            3 - (date.weekday - wkst.isoNumber + 7) % 7,
          );
          final inFirstWeek = d(fourth.year, 1, 1).daysUntil(fourth) < 7;
          final inLastWeek = fourth.addDays(7).year != fourth.year;
          if (inFirstWeek || inLastWeek) expected.add(date);
        }
        expect(actual, expected);
      },
    );
  }
}
