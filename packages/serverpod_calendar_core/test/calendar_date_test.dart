import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  CalendarDate date(int year, int month, int day) =>
      CalendarDate(year: year, month: month, day: day);

  test('accepts both selected profile boundaries', () {
    expect(date(1, 1, 1).toString(), '0001-01-01');
    expect(date(9999, 12, 31).toString(), '9999-12-31');
  });

  for (final year in [-1, 0, 10000]) {
    test('rejects unsupported year $year', () {
      expect(() => date(year, 1, 1), throwsRangeError);
    });
  }

  for (final month in [-1, 0, 13]) {
    test('rejects month $month without normalization', () {
      expect(() => date(2026, month, 1), throwsRangeError);
    });
  }

  for (final day in [-1, 0, 32]) {
    test('rejects January day $day without normalization', () {
      expect(() => date(2026, 1, day), throwsRangeError);
    });
  }

  const lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  for (var month = 1; month <= 12; month++) {
    final last = lengths[month - 1];
    test('validates final day and overflow for month $month', () {
      final value = date(2026, month, last);
      expect(value.year, 2026);
      expect(value.month, month);
      expect(value.day, last);
      expect(value.daysInMonth, last);
      expect(() => date(2026, month, last + 1), throwsRangeError);
    });
  }

  for (final year in [4, 1600, 2000, 2024, 2400]) {
    test('accepts Gregorian leap day in $year', () {
      final leap = date(year, 2, 29);
      expect(leap.isLeapYear, isTrue);
      expect(leap.daysInMonth, 29);
      expect(() => date(year, 2, 30), throwsRangeError);
    });
  }

  for (final year in [1, 100, 1900, 2023, 2100, 9999]) {
    test('rejects Gregorian leap day in $year', () {
      expect(date(year, 2, 28).isLeapYear, isFalse);
      expect(() => date(year, 2, 29), throwsRangeError);
    });
  }

  test('a Gregorian 400-year cycle has 146097 days and 97 leap years', () {
    var days = 0;
    var leapYears = 0;
    for (var year = 1600; year < 2000; year++) {
      if (date(year, 1, 1).isLeapYear) leapYears++;
      for (var month = 1; month <= 12; month++) {
        days += date(year, month, 1).daysInMonth;
      }
    }
    expect(days, 146097);
    expect(leapYears, 97);
  });

  test('ordering handles day, month and year boundaries', () {
    final expected = [
      date(1, 1, 1),
      date(2023, 12, 31),
      date(2024, 2, 28),
      date(2024, 2, 29),
      date(2024, 3, 1),
      date(9999, 12, 31),
    ];
    expect(expected.reversed.toList()..sort(), expected);
    expect(date(2024, 2, 29).compareTo(date(2024, 2, 29)), 0);
    for (var i = 1; i < expected.length; i++) {
      expect(expected[i - 1].compareTo(expected[i]), lessThan(0));
      expect(expected[i].compareTo(expected[i - 1]), greaterThan(0));
    }
  });

  test('value equality and hashing retain every date field', () {
    final leap = date(2024, 2, 29);
    final equal = date(2024, 2, 29);
    expect(leap, equal);
    expect(leap.hashCode, equal.hashCode);
    expect({
      leap,
      equal,
      date(2024, 2, 28),
      date(2024, 3, 29),
      date(2028, 2, 29),
    }, hasLength(4));
    expect(leap == Object(), isFalse);
  });

  test('diagnostic text pads fields without adding a time or zone', () {
    expect(date(42, 3, 7).toString(), '0042-03-07');
  });
}
