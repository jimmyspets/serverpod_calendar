import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate date(int year, int month, int day) =>
    CalendarDate(year: year, month: month, day: day);

void main() {
  test('crosses month and year boundaries in either direction', () {
    expect(date(2024, 12, 31).addDays(1), date(2025, 1, 1));
    expect(date(2025, 1, 1).addDays(-1), date(2024, 12, 31));
    expect(date(2024, 4, 30).addDays(1), date(2024, 5, 1));
    expect(date(2024, 5, 1).addDays(-1), date(2024, 4, 30));
    expect(date(2024, 2, 29).addDays(0), date(2024, 2, 29));
  });

  for (final year in [1900, 2000, 2024, 2100]) {
    test('February arithmetic follows Gregorian leap rules in $year', () {
      final leap = year == 2000 || year == 2024;
      expect(date(year, 2, 28).addDays(leap ? 2 : 1), date(year, 3, 1));
      expect(date(year, 3, 1).addDays(-1), date(year, 2, leap ? 29 : 28));
    });
  }

  test('signed day counts and inverse addition span the full profile', () {
    final first = date(1, 1, 1);
    final last = date(9999, 12, 31);
    expect(first.daysUntil(last), 3652058);
    expect(last.daysUntil(first), -3652058);
    expect(first.addDays(3652058), last);
    expect(last.addDays(-3652058), first);
    expect(last.daysUntil(last), 0);
    expect(date(1999, 12, 31).daysUntil(date(2000, 3, 1)), 61);
  });

  test('rejects overflow before adding even very large day counts', () {
    expect(() => date(1, 1, 1).addDays(-1), throwsRangeError);
    expect(() => date(9999, 12, 31).addDays(1), throwsRangeError);
    expect(() => date(2024, 1, 1).addDays(1099511627776), throwsRangeError);
    expect(() => date(2024, 1, 1).addDays(-(1099511627776)), throwsRangeError);
  });

  test('weekdays use Monday one through Sunday seven', () {
    expect(date(1, 1, 1).weekday, 1);
    expect(date(2000, 1, 1).weekday, 6);
    expect(date(2024, 2, 29).weekday, 4);
    expect(date(9999, 12, 31).weekday, 5);
    for (var offset = 0; offset < 7; offset++) {
      expect(date(1997, 7, 14).addDays(offset).weekday, offset + 1);
    }
  });

  test('every day in a 400-year cycle advances and reverses consistently', () {
    final first = date(1600, 1, 1);
    var current = first;
    for (var offset = 1; offset <= 146097; offset++) {
      final next = current.addDays(1);
      expect(next.compareTo(current), greaterThan(0));
      expect(next.addDays(-1), current);
      expect(first.daysUntil(next), offset);
      expect(next.weekday, current.weekday % 7 + 1);
      current = next;
    }
    expect(current, date(2000, 1, 1));
    expect(current.weekday, first.weekday);
  });
}
