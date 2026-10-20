import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CivilDateTime c(int h, int m, [int s = 0, int fraction = 0]) => CivilDateTime(
  date: CalendarDate(year: 2026, month: 1, day: 1),
  hour: h,
  minute: m,
  second: s,
  microsecond: fraction,
);
void main() {
  test(
    'whole-second endpoints, zero fractions, comparison and diagnostics',
    () {
      expect(c(0, 0).toString(), '2026-01-01T00:00:00');
      expect(c(23, 59, 59).toString(), '2026-01-01T23:59:59');
      expect(c(0, 0, 0, 0), c(0, 0));
      expect(c(0, 0).hashCode, c(0, 0, 0, 0).hashCode);
      expect(c(9, 0, 1).compareTo(c(9, 0)), greaterThan(0));
    },
  );
  for (final f in [-1, 1, 999, 1000, 123456, 999999, 1000000]) {
    test(
      'rejects nonzero fraction $f without rounding',
      () => expect(() => c(9, 0, 0, f), throwsRangeError),
    );
  }
  for (final fields in [(-1, 0, 0), (24, 0, 0), (0, 60, 0), (0, 0, 60)]) {
    test(
      'rejects invalid clock/leap second $fields',
      () => expect(() => c(fields.$1, fields.$2, fields.$3), throwsRangeError),
    );
  }
  test('exclusive civil endpoint is midnight only', () {
    expect(
      CivilDateTime(
        date: const CalendarDate.exclusiveEnd(),
        hour: 0,
        minute: 0,
      ).toString(),
      '2100-01-01T00:00:00',
    );
    expect(
      () => CivilDateTime(
        date: const CalendarDate.exclusiveEnd(),
        hour: 0,
        minute: 0,
        second: 1,
      ),
      throwsRangeError,
    );
  });
}
