import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  test(
    'all supported ISO fields agree with independent Thursday arithmetic',
    () {
      final first = CalendarDate(year: 1970, month: 1, day: 1);
      for (var i = 0; i < 47482; i++) {
        final date = first.addDays(i),
            actual = IsoWeekDate.fromDate(first.addDays(i));
        final dt = DateTime.utc(date.year, date.month, date.day);
        final thursday = dt.add(Duration(days: 4 - dt.weekday));
        final week =
            thursday.difference(DateTime.utc(thursday.year)).inDays ~/ 7 + 1;
        expect(
          (actual.weekYear, actual.week, actual.weekday),
          (thursday.year, week, dt.weekday),
        );
      }
    },
  );
  test('New Year uses the ISO week-year independently of WKST', () {
    final sunday = IsoWeekDate.fromDate(
      CalendarDate(year: 2021, month: 1, day: 3),
    );
    expect(sunday.toString(), '2020-W53-7');
    final monday = IsoWeekDate.fromDate(
      CalendarDate(year: 2024, month: 12, day: 30),
    );
    expect(monday.toString(), '2025-W01-1');
    expect(
      monday,
      IsoWeekDate.fromDate(CalendarDate(year: 2024, month: 12, day: 30)),
    );
    expect(
      monday.hashCode,
      IsoWeekDate.fromDate(CalendarDate(year: 2024, month: 12, day: 30))
          .hashCode,
    );
    expect(
      () => IsoWeekDate.fromDate(const CalendarDate.exclusiveEnd()),
      throwsRangeError,
    );
  });
}
