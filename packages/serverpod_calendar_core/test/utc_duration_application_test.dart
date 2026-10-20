import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  test('positive and negative whole units remain exact', () {
    final start = DateTime.utc(2026, 1, 2, 9, 0, 7);
    final value = CalendarDuration(days: 1, hours: 2, minutes: 3, seconds: 4);
    expect(value.addToUtc(start), DateTime.utc(2026, 1, 3, 11, 3, 11));
    expect(
      CalendarDuration(
        sign: -1,
        days: 1,
        hours: 2,
        minutes: 3,
        seconds: 4,
      ).addToUtc(start),
      DateTime.utc(2026, 1, 1, 6, 57, 3),
    );
    expect(
      CalendarDuration(weeks: 1).addToUtc(start),
      start.add(const Duration(days: 7)),
    );
  });
  test('calendar UTC days are 24 hours and clock components do not normalize in storage', () {
    final start = DateTime.utc(2026, 3, 28, 9);
    expect(
      CalendarDuration(days: 1).addToUtc(start),
      CalendarDuration(hours: 24).addToUtc(start),
    );
    expect(
      CalendarDuration(seconds: 60).addToUtc(start),
      start.add(const Duration(minutes: 1)),
    );
  });
  test('rejects fractional magnitude and source without truncation', () {
    for (final f in [1, 1000, 999999]) {
      expect(() => CalendarDuration(microsecond: f), throwsRangeError);
    }
    expect(
      () => CalendarDuration().addToUtc(DateTime.utc(2026, 1, 1, 0, 0, 0, 1)),
      throwsArgumentError,
    );
    expect(
      () => CalendarDuration().addToUtc(DateTime(2026)),
      throwsArgumentError,
    );
  });
  test('huge components fail before narrowing or overflowing', () {
    expect(
      () =>
          CalendarDuration(days: CalendarDuration.maxComponent)
              .addToUtc(DateTime.utc(2026)),
      throwsRangeError,
    );
    expect(
      () => CalendarDuration(
        sign: -1,
        seconds: CalendarDuration.maxComponent,
      ).addToUtc(DateTime.utc(2026)),
      throwsRangeError,
    );
  });
  test('supported horizon, explicit endpoint and signed zero', () {
    final start = DateTime.utc(1970), end = DateTime.utc(2100);
    expect(CalendarDuration(days: 47482).addToUtc(start), end);
    expect(CalendarDuration(sign: -1, days: 47482).addToUtc(end), start);
    expect(CalendarDuration(sign: -1).addToUtc(start), start);
  });
}
