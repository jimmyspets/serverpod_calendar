import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int y, int m, int day) =>
    CalendarDate(year: y, month: m, day: day);
void main() {
  test('ordinary profile is 1970 inclusive through 2100 exclusive', () {
    expect(d(1970, 1, 1).toString(), '1970-01-01');
    expect(d(2099, 12, 31).toString(), '2099-12-31');
  });
  for (final y in [-1, 0, 1969, 2100, 2101, 9999]) {
    test(
      'rejects ordinary year $y',
      () => expect(() => d(y, 1, 1), throwsRangeError),
    );
  }
  for (final m in [0, 13]) {
    test(
      'rejects month $m',
      () => expect(() => d(2026, m, 1), throwsRangeError),
    );
  }
  for (final day in [0, 32]) {
    test(
      'rejects day $day',
      () => expect(() => d(2026, 1, day), throwsRangeError),
    );
  }
  for (var m = 1; m <= 12; m++) {
    final month = m;
    test('valid month end $month', () {
      final length = DateTime.utc(2026, month + 1, 0).day;
      expect(d(2026, month, length).daysInMonth, length);
      expect(() => d(2026, month, length + 1), throwsRangeError);
    });
  }
  test('leap-year rules across every supported year', () {
    for (var y = 1970; y < 2100; y++) {
      final leap = y % 4 == 0;
      expect(d(y, 2, 28).isLeapYear, leap);
      if (leap) {
        expect(d(y, 2, 29).day, 29);
      } else {
        expect(() => d(y, 2, 29), throwsRangeError);
      }
    }
    expect(d(2000, 2, 29).isLeapYear, isTrue);
    expect(() => d(2100, 2, 29), throwsRangeError);
  });
  test('exclusive endpoint is explicit and cannot be an ordinary date', () {
    const end = CalendarDate.exclusiveEnd();
    expect(end.toString(), '2100-01-01');
    expect(end.isExclusiveEnd, isTrue);
    expect(() => end.requireOrdinary(), throwsRangeError);
    expect(d(2099, 12, 31).addDays(1), end);
  });
  test('comparison, equality and hashing retain all fields', () {
    final a = d(2026, 1, 1), same = d(2026, 1, 1), later = d(2026, 1, 2);
    expect(a, same);
    expect(a.hashCode, same.hashCode);
    expect(a.compareTo(later), lessThan(0));
    expect({a, same, later}.length, 2);
  });
}
