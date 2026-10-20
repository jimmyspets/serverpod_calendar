import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  test(
    'positive and negative mixed units preserve complete native fractions',
    () {
      final start = DateTime.utc(2026, 1, 1, 12, 30, 15, 123, 456);
      final value = CalendarDuration(
        days: 1,
        hours: 2,
        minutes: 3,
        seconds: 4,
        microsecond: 500001,
      );
      expect(
        value.addToUtc(start),
        DateTime.utc(2026, 1, 2, 14, 33, 19, 623, 457),
      );
      expect(
        CalendarDuration(
          sign: -1,
          days: 1,
          hours: 2,
          minutes: 3,
          seconds: 4,
          microsecond: 500001,
        ).addToUtc(value.addToUtc(start)),
        start,
      );
    },
  );
  test('UTC weeks/days cross Gregorian leap and year boundaries', () {
    expect(
      CalendarDuration(weeks: 1).addToUtc(DateTime.utc(2023, 12, 28)),
      DateTime.utc(2024, 1, 4),
    );
    expect(
      CalendarDuration(days: 2).addToUtc(DateTime.utc(2024, 2, 28)),
      DateTime.utc(2024, 3, 1),
    );
    expect(
      CalendarDuration(days: 1).addToUtc(DateTime.utc(1900, 2, 28)),
      DateTime.utc(1900, 3, 1),
    );
    expect(
      CalendarDuration(sign: -1, days: 1).addToUtc(DateTime.utc(2100, 3, 1)),
      DateTime.utc(2100, 2, 28),
    );
  });
  test('one UTC day and 24 UTC hours agree without rewriting units', () {
    for (final start in [
      DateTime.utc(2026, 3, 29),
      DateTime.utc(2026, 10, 25),
    ]) {
      expect(
        CalendarDuration(days: 1).addToUtc(start),
        CalendarDuration(hours: 24).addToUtc(start),
      );
      expect(
        CalendarDuration(weeks: 1).addToUtc(start),
        CalendarDuration(days: 7).addToUtc(start),
      );
    }
  });
  test('non-normalized clock components are aggregated exactly', () {
    expect(
      CalendarDuration(
        hours: 25,
        minutes: 61,
        seconds: 61,
        microsecond: 999999,
      ).addToUtc(DateTime.utc(2026)),
      DateTime.utc(2026, 1, 2, 2, 2, 1, 999, 999),
    );
  });
  test(
    'fractional addition crosses the negative UTC epoch without truncation',
    () {
      final epoch = DateTime.utc(1970);
      final before = DateTime.utc(1969, 12, 31, 23, 59, 59, 999, 999);
      expect(CalendarDuration(microsecond: 1).addToUtc(before), epoch);
      expect(
        CalendarDuration(sign: -1, microsecond: 1).addToUtc(epoch),
        before,
      );
      expect(
        CalendarDuration(microsecond: 2).addToUtc(before),
        DateTime.utc(1970, 1, 1, 0, 0, 0, 0, 1),
      );
    },
  );
  for (final year in [1, 1600, 1684, 2255, 9999]) {
    test(
      'year $year preserves odd microseconds outside safe epoch getter range',
      () {
        final start = DateTime.utc(year, 1, 1, 12, 30, 45, 123, 457);
        final next = CalendarDuration(microsecond: 1).addToUtc(start);
        expect(next, DateTime.utc(year, 1, 1, 12, 30, 45, 123, 458));
        expect(
          CalendarDuration(sign: -1, microsecond: 1).addToUtc(next),
          start,
        );
        expect(
          CalendarDuration(microsecond: 543210).addToUtc(start),
          DateTime.utc(year, 1, 1, 12, 30, 45, 666, 667),
        );
      },
    );
  }
  test('zero and signed zero validate UTC without changing the instant', () {
    final start = DateTime.utc(1, 1, 1, 0, 0, 0, 0, 1);
    expect(CalendarDuration().addToUtc(start), start);
    expect(CalendarDuration(sign: -1).addToUtc(start), start);
    expect(
      () => CalendarDuration().addToUtc(DateTime(2026)),
      throwsArgumentError,
    );
    expect(
      () => CalendarDuration(days: 1).addToUtc(DateTime(2026)),
      throwsArgumentError,
    );
  });
  test('exact Dart instant endpoints and adjacent fractions are supported', () {
    final min = DateTime.fromMillisecondsSinceEpoch(
      -8640000000000000,
      isUtc: true,
    );
    final max = DateTime.fromMillisecondsSinceEpoch(
      8640000000000000,
      isUtc: true,
    );
    expect(CalendarDuration().addToUtc(min), min);
    expect(CalendarDuration().addToUtc(max), max);
    final justAbove = CalendarDuration(microsecond: 1).addToUtc(min);
    final justBelow = CalendarDuration(sign: -1, microsecond: 1).addToUtc(max);
    expect(justAbove.millisecondsSinceEpoch, min.millisecondsSinceEpoch);
    expect(justAbove.microsecond, 1);
    expect(justBelow.millisecondsSinceEpoch, max.millisecondsSinceEpoch - 1);
    expect(justBelow.microsecond, 999);
    expect(CalendarDuration(sign: -1, microsecond: 1).addToUtc(justAbove), min);
    expect(CalendarDuration(microsecond: 1).addToUtc(justBelow), max);
    expect(
      () => CalendarDuration(sign: -1, microsecond: 1).addToUtc(min),
      throwsRangeError,
    );
    expect(
      () => CalendarDuration(microsecond: 1).addToUtc(max),
      throwsRangeError,
    );
  });
  for (final value in [
    CalendarDuration(weeks: CalendarDuration.maxComponent),
    CalendarDuration(days: CalendarDuration.maxComponent),
    CalendarDuration(
      hours: CalendarDuration.maxComponent,
      minutes: CalendarDuration.maxComponent,
      seconds: CalendarDuration.maxComponent,
    ),
    CalendarDuration(sign: -1, days: CalendarDuration.maxComponent),
  ]) {
    test(
      'huge signed component totals reject without overflow ${value.sign}/${value.weeks}/${value.days}',
      () {
        expect(() => value.addToUtc(DateTime.utc(2026)), throwsRangeError);
      },
    );
  }
  test(
    'full instant-range movement aggregates beyond signed 64-bit deltas',
    () {
      final min = DateTime.fromMillisecondsSinceEpoch(
        -8640000000000000,
        isUtc: true,
      );
      final max = DateTime.fromMillisecondsSinceEpoch(
        8640000000000000,
        isUtc: true,
      );
      expect(CalendarDuration(days: 200000000).addToUtc(min), max);
      expect(CalendarDuration(sign: -1, days: 200000000).addToUtc(max), min);
    },
  );
  test('explicit UTC after 2037 does not bypass named-zone guards', () {
    final start = DateTime.utc(2038, 1, 1, 0, 0, 0, 0, 1);
    expect(
      CalendarDuration(days: 1).addToUtc(start),
      DateTime.utc(2038, 1, 2, 0, 0, 0, 0, 1),
    );
    expect(
      () => NamedZoneResolver().resolve(
        CivilDateTime(
          date: CalendarDate(year: 2038, month: 1, day: 1),
          hour: 0,
          minute: 0,
        ),
        zoneId: 'Europe/Stockholm',
      ),
      throwsRangeError,
    );
  });
}
