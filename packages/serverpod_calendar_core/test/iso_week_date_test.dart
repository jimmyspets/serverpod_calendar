import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate date(int year, int month, int day) =>
    CalendarDate(year: year, month: month, day: day);

// Expected fields and rolling fingerprints independently computed with
// Python 3.11.9 datetime.date.isocalendar(), not this implementation.
const fixtures = [
  [1, 1, 1, 1, 1, 1],
  [1, 12, 31, 2, 1, 1],
  [9999, 1, 1, 9998, 53, 5],
  [9999, 12, 31, 9999, 52, 5],
  [1900, 1, 1, 1900, 1, 1],
  [1900, 12, 31, 1901, 1, 1],
  [2000, 1, 1, 1999, 52, 6],
  [2004, 12, 31, 2004, 53, 5],
  [2005, 1, 1, 2004, 53, 6],
  [2007, 12, 31, 2008, 1, 1],
  [2009, 12, 31, 2009, 53, 4],
  [2010, 1, 3, 2009, 53, 7],
  [2015, 12, 31, 2015, 53, 4],
  [2016, 1, 1, 2015, 53, 5],
  [2016, 1, 4, 2016, 1, 1],
  [2020, 12, 31, 2020, 53, 4],
  [2021, 1, 1, 2020, 53, 5],
  [2021, 1, 3, 2020, 53, 7],
  [2021, 1, 4, 2021, 1, 1],
  [2024, 12, 29, 2024, 52, 7],
  [2024, 12, 30, 2025, 1, 1],
  [2026, 12, 31, 2026, 53, 4],
  [2100, 1, 1, 2099, 53, 5],
  [2400, 12, 31, 2400, 52, 7],
];

int fingerprint(int previous, IsoWeekDate value) =>
    (previous * 31 + value.weekYear * 1000 + value.week * 10 + value.weekday) %
    2147483647;

void main() {
  for (final fields in fixtures) {
    final input = date(fields[0], fields[1], fields[2]);
    test('ISO boundary fields for $input', () {
      final value = IsoWeekDate.fromDate(input);
      expect([value.weekYear, value.week, value.weekday], fields.sublist(3));
    });
  }

  for (final fixture in [(1, 222650477), (2000, 1784885802)]) {
    test('all dates in the 400-year cycle starting ${fixture.$1}', () {
      var current = date(fixture.$1, 1, 1);
      var digest = 0;
      for (var i = 0; i < 146097; i++) {
        final value = IsoWeekDate.fromDate(current);
        expect(value.weekYear, inInclusiveRange(1, 9999));
        expect(value.week, inInclusiveRange(1, 53));
        expect(value.weekday, current.weekday);
        digest = fingerprint(digest, value);
        current = current.addDays(1);
      }
      expect(current, date(fixture.$1 + 400, 1, 1));
      expect(digest, fixture.$2);
    });
  }

  test('January and December boundaries across every supported year', () {
    var digest = 0;
    for (var year = 1; year <= 9999; year++) {
      for (final (month, day) in [(1, 1), (1, 4), (12, 28), (12, 31)]) {
        final value = IsoWeekDate.fromDate(date(year, month, day));
        digest = fingerprint(digest, value);
        if (month == 1 && day == 4) {
          expect(value.weekYear, year);
          expect(value.week, 1);
        }
        if (month == 12 && day == 28) {
          expect(value.weekYear, year);
          expect(value.week, anyOf(52, 53));
        }
      }
    }
    expect(digest, 843918866);
  });

  test('complete ISO weeks agree with independent January 4 boundaries', () {
    var longYears = 0;
    for (var year = 2000; year < 2400; year++) {
      // Test oracle uses UTC only as a separate Gregorian arithmetic engine;
      // the public value and production implementation never use timestamps.
      final january4 = DateTime.utc(year, 1, 4);
      final nextJanuary4 = DateTime.utc(year + 1, 1, 4);
      final monday = january4.subtract(Duration(days: january4.weekday - 1));
      final nextMonday = nextJanuary4.subtract(
        Duration(days: nextJanuary4.weekday - 1),
      );
      final days = nextMonday.difference(monday).inDays;
      expect(days, anyOf(364, 371));
      if (days == 371) longYears++;
      for (var offset = 0; offset < days; offset++) {
        final civil = monday.add(Duration(days: offset));
        final value = IsoWeekDate.fromDate(
          date(civil.year, civil.month, civil.day),
        );
        expect(
          [value.weekYear, value.week, value.weekday],
          [year, offset ~/ 7 + 1, offset % 7 + 1],
        );
      }
    }
    expect(longYears, 71);
  });

  test('equality and hash distinguish week-year, week and weekday', () {
    final value = IsoWeekDate.fromDate(date(2021, 1, 3));
    final same = IsoWeekDate.fromDate(date(2021, 1, 3));
    expect(value, same);
    expect(value.hashCode, same.hashCode);
    expect(value, isNot(IsoWeekDate.fromDate(date(2022, 1, 2))));
    expect(value, isNot(IsoWeekDate.fromDate(date(2021, 1, 10))));
    expect(value, isNot(IsoWeekDate.fromDate(date(2021, 1, 2))));
    expect(value, isNot(date(2021, 1, 3)));
  });

  test('diagnostic text retains ISO year, padded week and weekday', () {
    expect(IsoWeekDate.fromDate(date(1, 1, 1)).toString(), '0001-W01-1');
    expect(IsoWeekDate.fromDate(date(2021, 1, 3)).toString(), '2020-W53-7');
    expect(IsoWeekDate.fromDate(date(9999, 12, 31)).toString(), '9999-W52-5');
  });

  test('Sunday recurrence week membership never changes native ISO fields', () {
    final sunday = date(2021, 1, 3);
    final rule = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.yearly,
      weekStart: Weekday.sunday,
      byWeekNo: [1],
      count: 1,
    );
    final generated = DateRecurrenceGenerator().expand(
      start: sunday,
      rule: rule,
      from: sunday,
      through: sunday,
      maxCandidateDays: 366,
      maxResults: 1,
    );
    expect(generated, [sunday]);
    final label = IsoWeekDate.fromDate(generated.single);
    expect([label.weekYear, label.week, label.weekday], [2020, 53, 7]);
    expect(rule.weekStart, Weekday.sunday);
  });
}
