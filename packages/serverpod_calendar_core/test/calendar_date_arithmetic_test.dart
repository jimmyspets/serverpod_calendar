import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int y, int m, int day) =>
    CalendarDate(year: y, month: m, day: day);
void main() {
  test('all supported dates agree with an independent UTC field oracle', () {
    final first = d(1970, 1, 1);
    const end = CalendarDate.exclusiveEnd();
    final length = first.daysUntil(end);
    expect(length, 47482);
    for (var i = 0; i < length; i++) {
      final date = first.addDays(i);
      final reference = DateTime.utc(1970).add(Duration(days: i));
      expect(
        (date.year, date.month, date.day, date.weekday),
        (reference.year, reference.month, reference.day, reference.weekday),
      );
      expect(date.daysUntil(first), -i);
      expect(date.addDays(-i), first);
    }
  });
  test('leap, year and profile boundaries never clamp', () {
    expect(d(2000, 2, 28).addDays(1), d(2000, 2, 29));
    expect(d(2000, 2, 29).addDays(1), d(2000, 3, 1));
    expect(d(2026, 12, 31).addDays(1), d(2027, 1, 1));
    expect(() => d(1970, 1, 1).addDays(-1), throwsRangeError);
    expect(
      () => const CalendarDate.exclusiveEnd().addDays(1),
      throwsRangeError,
    );
    expect(
      () => d(2026, 1, 1).addDays(DateRecurrenceRule.maxScalar),
      throwsRangeError,
    );
    expect(const CalendarDate.exclusiveEnd().addDays(-1), d(2099, 12, 31));
  });
}
