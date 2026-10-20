import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate date(int year, int month, int day) =>
    CalendarDate(year: year, month: month, day: day);
CivilDateTime civil(int year, int month, int day, int hour, [int minute = 0]) =>
    CivilDateTime(date: date(year, month, day), hour: hour, minute: minute);

void main() {
  final resolver = NamedZoneResolver();
  DateTime apply(
    CalendarDuration duration,
    CivilDateTime start, [
    String zone = 'Europe/Stockholm',
  ]) => duration.addToZoned(start, zoneId: zone, resolver: resolver);

  test(
    'date-only days and weeks cross leap/month/year boundaries both ways',
    () {
      expect(
        CalendarDuration(days: 1).addToDate(date(2024, 2, 28)),
        date(2024, 2, 29),
      );
      expect(
        CalendarDuration(sign: -1, days: 1).addToDate(date(1900, 3, 1)),
        date(1900, 2, 28),
      );
      expect(
        CalendarDuration(weeks: 2).addToDate(date(2023, 12, 25)),
        date(2024, 1, 8),
      );
      expect(
        CalendarDuration(sign: -1, weeks: 2).addToDate(date(2024, 1, 8)),
        date(2023, 12, 25),
      );
    },
  );
  test('date-only application reaches both exact profile boundaries', () {
    expect(
      CalendarDuration(days: 3652058).addToDate(date(1, 1, 1)),
      date(9999, 12, 31),
    );
    expect(
      CalendarDuration(sign: -1, days: 3652058).addToDate(date(9999, 12, 31)),
      date(1, 1, 1),
    );
    expect(CalendarDuration().addToDate(date(1, 1, 1)), date(1, 1, 1));
    expect(
      CalendarDuration(sign: -1).addToDate(date(9999, 12, 31)),
      date(9999, 12, 31),
    );
  });
  for (final duration in [
    CalendarDuration(days: 1),
    CalendarDuration(weeks: 1),
    CalendarDuration(days: CalendarDuration.maxComponent),
    CalendarDuration(weeks: CalendarDuration.maxComponent),
  ]) {
    test(
      'date-only application rejects positive overflow: ${duration.days}/${duration.weeks}',
      () {
        expect(() => duration.addToDate(date(9999, 12, 31)), throwsRangeError);
      },
    );
  }
  test('negative day/week overflow fails before arithmetic', () {
    for (final duration in [
      CalendarDuration(sign: -1, days: 1),
      CalendarDuration(sign: -1, weeks: 1),
      CalendarDuration(sign: -1, weeks: CalendarDuration.maxComponent),
    ]) {
      expect(() => duration.addToDate(date(1, 1, 1)), throwsRangeError);
    }
    expect(
      CalendarDuration(weeks: 1).addToDate(date(9999, 12, 24)),
      date(9999, 12, 31),
    );
    expect(
      () => CalendarDuration(weeks: 1).addToDate(date(9999, 12, 25)),
      throwsRangeError,
    );
  });
  for (final duration in [
    CalendarDuration(hours: 24),
    CalendarDuration(minutes: 1),
    CalendarDuration(seconds: 1),
    CalendarDuration(microsecond: 1),
  ]) {
    test(
      'date-only application rejects clock components ${duration.hours}/${duration.minutes}/${duration.seconds}/${duration.microsecond}',
      () {
        expect(() => duration.addToDate(date(2026, 1, 1)), throwsArgumentError);
      },
    );
  }
  test('spring calendar day differs from 24 elapsed hours', () {
    final start = civil(2026, 3, 28, 12);
    expect(
      apply(CalendarDuration(days: 1), start),
      DateTime.utc(2026, 3, 29, 10),
    );
    expect(
      apply(CalendarDuration(hours: 24), start),
      DateTime.utc(2026, 3, 29, 11),
    );
  });
  test('autumn calendar day differs from 24 elapsed hours', () {
    final start = civil(2026, 10, 24, 12);
    expect(
      apply(CalendarDuration(days: 1), start),
      DateTime.utc(2026, 10, 25, 11),
    );
    expect(
      apply(CalendarDuration(hours: 24), start),
      DateTime.utc(2026, 10, 25, 10),
    );
  });
  test('negative mixed duration applies calendar days before clock hours', () {
    expect(
      apply(
        CalendarDuration(sign: -1, days: 1, hours: 1),
        civil(2026, 3, 29, 12),
      ),
      DateTime.utc(2026, 3, 28, 10),
    );
  });
  test(
    'intermediate gap resolves with pre-gap offset before clock addition',
    () {
      expect(
        apply(CalendarDuration(days: 1, hours: 1), civil(2026, 3, 28, 2, 30)),
        DateTime.utc(2026, 3, 29, 2, 30),
      );
    },
  );
  test('fold intermediate chooses first instant but elapsed endpoint can be later fold', () {
    final start = civil(2026, 10, 24, 2, 30);
    expect(
      apply(CalendarDuration(days: 1), start),
      DateTime.utc(2026, 10, 25, 0, 30),
    );
    final end = apply(CalendarDuration(days: 1, hours: 1), start);
    expect(end, DateTime.utc(2026, 10, 25, 1, 30));
    expect(
      resolver.localAt(end, zoneId: 'Europe/Stockholm'),
      civil(2026, 10, 25, 2, 30),
    );
  });
  test('gap start retains requested fields for calendar movement', () {
    final start = civil(2026, 3, 29, 2, 30);
    expect(apply(CalendarDuration(), start), DateTime.utc(2026, 3, 29, 1, 30));
    expect(
      apply(CalendarDuration(days: 1), start),
      DateTime.utc(2026, 3, 30, 0, 30),
    );
  });
  test(
    'Lord Howe half-hour transition is not treated as a one-hour change',
    () {
      expect(
        apply(
          CalendarDuration(days: 1),
          civil(2026, 4, 4, 12),
          'Australia/Lord_Howe',
        ),
        DateTime.utc(2026, 4, 5, 1, 30),
      );
    },
  );
  test('Apia whole-day gap and week movement preserve calendar semantics', () {
    expect(
      apply(CalendarDuration(days: 1), civil(2011, 12, 29, 12), 'Pacific/Apia'),
      DateTime.utc(2011, 12, 30, 22),
    );
    expect(
      apply(
        CalendarDuration(weeks: 1),
        civil(2011, 12, 24, 12),
        'Pacific/Apia',
      ),
      DateTime.utc(2011, 12, 30, 22),
    );
  });
  test('clock aggregation preserves fractions across a negative UTC epoch', () {
    final start = CivilDateTime(
      date: date(1969, 12, 31),
      hour: 23,
      minute: 59,
      second: 59,
      microsecond: 999999,
    );
    expect(
      apply(CalendarDuration(microsecond: 1), start, 'Etc/UTC'),
      DateTime.utc(1970),
    );
    expect(
      apply(
        CalendarDuration(sign: -1, microsecond: 1),
        civil(1970, 1, 1, 0),
        'Etc/UTC',
      ),
      DateTime.utc(1969, 12, 31, 23, 59, 59, 999, 999),
    );
  });
  test('non-normalized clock units have exact elapsed arithmetic', () {
    expect(
      apply(
        CalendarDuration(hours: 25, minutes: 90, seconds: 60, microsecond: 1),
        civil(2026, 1, 1, 0),
        'Etc/UTC',
      ),
      DateTime.utc(2026, 1, 2, 2, 31, 0, 0, 1),
    );
  });
  test('maximum clock components reject safely without integer overflow', () {
    expect(
      () => apply(
        CalendarDuration(
          hours: CalendarDuration.maxComponent,
          minutes: CalendarDuration.maxComponent,
          seconds: CalendarDuration.maxComponent,
        ),
        civil(2026, 1, 1, 0),
      ),
      throwsRangeError,
    );
    expect(
      () => apply(
        CalendarDuration(sign: -1, seconds: CalendarDuration.maxComponent),
        civil(2026, 1, 1, 0),
      ),
      throwsRangeError,
    );
  });
  test('start, intermediate and clock endpoint each enforce zone coverage', () {
    expect(
      () => apply(CalendarDuration(), civil(2038, 1, 1, 0)),
      throwsRangeError,
    );
    expect(
      () => apply(CalendarDuration(days: 1), civil(2037, 12, 31, 12)),
      throwsRangeError,
    );
    expect(
      () => apply(CalendarDuration(hours: 24), civil(2037, 12, 31, 12)),
      throwsRangeError,
    );
    expect(
      () => apply(
        CalendarDuration(sign: -1, microsecond: 1),
        civil(1900, 1, 1, 0),
        'Etc/UTC',
      ),
      throwsRangeError,
    );
    expect(
      () => apply(CalendarDuration(), civil(2026, 1, 1, 0), 'Africa/Abidjan'),
      throwsA(isA<ZoneCoverageException>()),
    );
    expect(
      () => apply(
        CalendarDuration(sign: -1, days: 5000),
        civil(1930, 1, 1, 12),
        'Asia/Kathmandu',
      ),
      throwsA(isA<ZoneCoverageException>()),
    );
    expect(
      () => apply(
        CalendarDuration(sign: -1, hours: 120000),
        civil(1930, 1, 1, 12),
        'Asia/Kathmandu',
      ),
      throwsA(isA<ZoneCoverageException>()),
    );
  });
  test(
    'aliases work while case guessing and unknown zones fail even for zero',
    () {
      expect(
        apply(CalendarDuration(days: 1), civil(2026, 3, 7, 12), 'US/Eastern'),
        DateTime.utc(2026, 3, 8, 16),
      );
      expect(
        () =>
            apply(CalendarDuration(), civil(2026, 1, 1, 0), 'europe/stockholm'),
        throwsArgumentError,
      );
    },
  );
  test('inverse projection retains fractions and both sides of a fold', () {
    final earlier = DateTime.utc(2026, 10, 25, 0, 30, 0, 123, 456);
    final later = DateTime.utc(2026, 10, 25, 1, 30, 0, 123, 456);
    final expected = CivilDateTime(
      date: date(2026, 10, 25),
      hour: 2,
      minute: 30,
      microsecond: 123456,
    );
    expect(resolver.localAt(earlier, zoneId: 'Europe/Stockholm'), expected);
    expect(resolver.localAt(later, zoneId: 'Europe/Stockholm'), expected);
  });
  test(
    'inverse projection guards UTC, exact names, local years and coverage',
    () {
      expect(
        () => resolver.localAt(DateTime(2026), zoneId: 'Etc/UTC'),
        throwsArgumentError,
      );
      expect(
        () => resolver.localAt(DateTime.utc(2026), zoneId: 'Unknown/Zone'),
        throwsArgumentError,
      );
      expect(
        () => resolver.localAt(DateTime.utc(2038), zoneId: 'Etc/UTC'),
        throwsRangeError,
      );
      expect(
        () => resolver.localAt(DateTime.utc(1800), zoneId: 'Etc/UTC'),
        throwsRangeError,
      );
      expect(
        () => resolver.localAt(DateTime.utc(2026), zoneId: 'Africa/Abidjan'),
        throwsA(isA<ZoneCoverageException>()),
      );
      expect(
        () => resolver.localAt(DateTime.utc(2026), zoneId: 'Factory'),
        throwsA(isA<ZoneCoverageException>()),
      );
    },
  );
  test(
    'local-year guards permit valid UTC spillover at civil envelope edges',
    () {
      final early = DateTime.utc(1899, 12, 31, 23);
      final late = DateTime.utc(2038, 1, 1, 0, 59);
      expect(
        resolver.localAt(early, zoneId: 'Etc/GMT-1'),
        civil(1900, 1, 1, 0),
      );
      expect(
        resolver.localAt(late, zoneId: 'Etc/GMT+1'),
        civil(2037, 12, 31, 23, 59),
      );
    },
  );
}
