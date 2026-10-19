import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  final date = CalendarDate(year: 2024, month: 2, day: 29);
  CivilDateTime civil({
    int hour = 0,
    int minute = 0,
    int second = 0,
    int microsecond = 0,
    CalendarDate? on,
  }) => CivilDateTime(
    date: on ?? date,
    hour: hour,
    minute: minute,
    second: second,
    microsecond: microsecond,
  );

  test(
    'retains a validated date and defaults seconds and fractions to zero',
    () {
      final value = CivilDateTime(date: date, hour: 9, minute: 30);
      expect(value.date, date);
      expect(value.hour, 9);
      expect(value.minute, 30);
      expect(value.second, 0);
      expect(value.microsecond, 0);
    },
  );

  test('accepts both civil time boundaries without rollover', () {
    expect(civil().toString(), '2024-02-29T00:00:00');
    final last = civil(hour: 23, minute: 59, second: 59, microsecond: 999999);
    expect(last.date, date);
    expect(last.toString(), '2024-02-29T23:59:59.999999');
  });

  for (final hour in [-1, 24]) {
    test('rejects hour $hour without date normalization', () {
      expect(() => civil(hour: hour), throwsRangeError);
    });
  }
  for (final minute in [-1, 60]) {
    test('rejects minute $minute without normalization', () {
      expect(() => civil(minute: minute), throwsRangeError);
    });
  }
  for (final second in [-1, 60, 61]) {
    test('rejects second $second including unsupported leap second', () {
      expect(
        () => civil(hour: 23, minute: 59, second: second),
        throwsRangeError,
      );
    });
  }
  for (final fraction in [-1, 1000000]) {
    test(
      'rejects fractional microsecond count $fraction without truncation',
      () {
        expect(() => civil(microsecond: fraction), throwsRangeError);
      },
    );
  }

  for (final fraction in [1, 999, 1000, 123456, 999999]) {
    test('preserves fractional second $fraction exactly', () {
      final value = civil(microsecond: fraction);
      expect(value.microsecond, fraction);
      expect(value.second, 0);
      expect(value, isNot(civil()));
    });
  }

  test('ordering distinguishes every field at rollover boundaries', () {
    final ordered = [
      civil(
        on: CalendarDate(year: 2023, month: 12, day: 31),
        hour: 23,
        minute: 59,
        second: 59,
        microsecond: 999999,
      ),
      civil(
        on: CalendarDate(year: 2024, month: 2, day: 28),
        hour: 23,
        minute: 59,
        second: 59,
        microsecond: 999999,
      ),
      civil(),
      civil(microsecond: 1),
      civil(second: 1),
      civil(minute: 1),
      civil(hour: 1),
      civil(on: CalendarDate(year: 2024, month: 3, day: 1)),
    ];
    expect(ordered.reversed.toList()..sort(), ordered);
    expect(civil().compareTo(civil()), 0);
    for (var i = 1; i < ordered.length; i++) {
      expect(ordered[i - 1].compareTo(ordered[i]), lessThan(0));
      expect(ordered[i].compareTo(ordered[i - 1]), greaterThan(0));
    }
  });

  test('equality and hashing preserve the date and all time fields', () {
    final equal = civil();
    expect(equal, civil());
    expect(equal.hashCode, civil().hashCode);
    expect({
      equal,
      civil(),
      civil(hour: 1),
      civil(minute: 1),
      civil(second: 1),
      civil(microsecond: 1),
      civil(on: CalendarDate(year: 2024, month: 3, day: 1)),
    }, hasLength(6));
    expect(equal == Object(), isFalse);
  });

  test('diagnostic text preserves six fractional digits without a zone', () {
    expect(
      civil(hour: 3, minute: 4, second: 5, microsecond: 1).toString(),
      '2024-02-29T03:04:05.000001',
    );
    expect(civil(microsecond: 120000).toString(), '2024-02-29T00:00:00.120000');
  });

  test('civil fields do not resolve potential Stockholm gap or fold times', () {
    final gap = civil(
      on: CalendarDate(year: 2026, month: 3, day: 29),
      hour: 2,
      minute: 30,
    );
    final fold = civil(
      on: CalendarDate(year: 2026, month: 10, day: 25),
      hour: 2,
      minute: 30,
    );
    expect(gap.hour, 2);
    expect(fold.hour, 2);
    expect(gap.minute, 30);
    expect(fold.minute, 30);
    // These tuples have no zone and make no promise that an instant exists or
    // is unique. Only a later named-zone resolver can answer that question.
  });
}
