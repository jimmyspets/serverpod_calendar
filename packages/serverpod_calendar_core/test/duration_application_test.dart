import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int y, int m, int day) =>
    CalendarDate(year: y, month: m, day: day);
CivilDateTime c(int y, int m, int day, int h, [int minute = 0]) =>
    CivilDateTime(date: d(y, m, day), hour: h, minute: minute);
DateTime apply(
  CalendarDuration value,
  CivilDateTime start, [
  String zone = 'Europe/Stockholm',
]) => value.addToZoned(start, zoneId: zone, resolver: NamedZoneResolver());
void main() {
  test('date-only signed days/weeks cross leap and year boundaries', () {
    expect(CalendarDuration(days: 1).addToDate(d(2000, 2, 28)), d(2000, 2, 29));
    expect(
      CalendarDuration(sign: -1, days: 1).addToDate(d(1971, 3, 1)),
      d(1971, 2, 28),
    );
    expect(
      CalendarDuration(weeks: 2).addToDate(d(2023, 12, 25)),
      d(2024, 1, 8),
    );
  });
  test(
    'date arithmetic reaches endpoints and rejects overflow before aggregation',
    () {
      expect(
        CalendarDuration(days: 47482).addToDate(d(1970, 1, 1)),
        const CalendarDate.exclusiveEnd(),
      );
      expect(
        CalendarDuration(
          sign: -1,
          days: 47482,
        ).addToDate(const CalendarDate.exclusiveEnd()),
        d(1970, 1, 1),
      );
      expect(
        () => CalendarDuration(sign: -1, days: 1).addToDate(d(1970, 1, 1)),
        throwsRangeError,
      );
      expect(
        () => CalendarDuration(days: 2).addToDate(d(2099, 12, 31)),
        throwsRangeError,
      );
      expect(
        () =>
            CalendarDuration(weeks: CalendarDuration.maxComponent)
                .addToDate(d(2026, 1, 1)),
        throwsRangeError,
      );
      expect(
        () => CalendarDuration(hours: 1).addToDate(d(2026, 1, 1)),
        throwsArgumentError,
      );
    },
  );
  for (final row in [(3, 28, 3, 29, 10), (10, 24, 10, 25, 11)]) {
    test('nominal day follows DST for ${row.$1}', () {
      expect(
        apply(CalendarDuration(days: 1), c(2026, row.$1, row.$2, 12)),
        DateTime.utc(2026, row.$3, row.$4, row.$5),
      );
      expect(
        apply(CalendarDuration(hours: 24), c(2026, row.$1, row.$2, 12)),
        DateTime.utc(
          2026,
          row.$1,
          row.$2,
          12,
        ).add(Duration(hours: row.$1 == 3 ? 23 : 22)),
      );
    });
  }
  test('signed mixed duration moves calendar fields before clock units', () {
    expect(
      apply(CalendarDuration(sign: -1, days: 1, hours: 1), c(2026, 3, 29, 12)),
      DateTime.utc(2026, 3, 28, 10),
    );
    expect(
      apply(CalendarDuration(days: 1, hours: 1), c(2026, 3, 28, 2, 30)),
      DateTime.utc(2026, 3, 29, 2, 30),
    );
  });
  test(
    'later-fold elapsed endpoint is not re-resolved to the first instant',
    () {
      final instant = apply(
        CalendarDuration(days: 1, hours: 1),
        c(2026, 10, 24, 2, 30),
      );
      expect(instant, DateTime.utc(2026, 10, 25, 1, 30));
      expect(
        NamedZoneResolver().localAt(instant, zoneId: 'Europe/Stockholm'),
        c(2026, 10, 25, 2, 30),
      );
    },
  );
  test('explicit gap start retains its requested fields for date movement', () {
    expect(
      apply(CalendarDuration(days: 1), c(2026, 3, 29, 2, 30)),
      DateTime.utc(2026, 3, 30, 0, 30),
    );
  });
  test(
    'non-hour transitions and whole-date gaps preserve nominal semantics',
    () {
      expect(
        apply(
          CalendarDuration(days: 1),
          c(2026, 4, 4, 12),
          'Australia/Lord_Howe',
        ),
        DateTime.utc(2026, 4, 5, 1, 30),
      );
      expect(
        apply(CalendarDuration(days: 1), c(2011, 12, 29, 12), 'Pacific/Apia'),
        DateTime.utc(2011, 12, 30, 22),
      );
      expect(
        apply(CalendarDuration(weeks: 1), c(2011, 12, 24, 12), 'Pacific/Apia'),
        DateTime.utc(2011, 12, 30, 22),
      );
    },
  );
  test('whole-second source and magnitudes never round', () {
    expect(() => CalendarDuration(microsecond: 1), throwsRangeError);
    expect(
      apply(
        CalendarDuration(hours: 25, minutes: 90, seconds: 60),
        c(2026, 1, 1, 0),
        'UTC',
      ),
      DateTime.utc(2026, 1, 2, 2, 31),
    );
  });
  test(
    'huge magnitudes and unsupported calendar endpoints fail explicitly',
    () {
      expect(
        () => apply(
          CalendarDuration(hours: CalendarDuration.maxComponent),
          c(2026, 1, 1, 0),
        ),
        throwsRangeError,
      );
      expect(
        () => apply(CalendarDuration(days: 1), c(2099, 12, 31, 12)),
        throwsRangeError,
      );
      expect(
        () => apply(CalendarDuration(hours: 24), c(2099, 12, 31, 12)),
        throwsRangeError,
      );
      expect(
        () => apply(
          CalendarDuration(sign: -1, seconds: 1),
          c(1970, 1, 1, 0),
          'UTC',
        ),
        throwsRangeError,
      );
    },
  );
  test('known histories now work; unknown offsets and names still fail', () {
    expect(
      apply(CalendarDuration(), c(2026, 1, 1, 0), 'Africa/Abidjan'),
      DateTime.utc(2026),
    );
    expect(
      () => apply(CalendarDuration(), c(2026, 1, 1, 0), 'Factory'),
      throwsA(isA<ZoneCoverageException>()),
    );
    expect(
      () => apply(CalendarDuration(), c(2026, 1, 1, 0), 'europe/stockholm'),
      throwsArgumentError,
    );
  });
  test('inverse projection rejects local and fractional inputs', () {
    final r = NamedZoneResolver();
    expect(() => r.localAt(DateTime(2026), zoneId: 'UTC'), throwsArgumentError);
    expect(
      () => r.localAt(DateTime.utc(2026, 1, 1, 0, 0, 0, 1), zoneId: 'UTC'),
      throwsArgumentError,
    );
  });
  test('boundary UTC spillover retains ordinary local fields', () {
    final r = NamedZoneResolver();
    expect(
      r.localAt(DateTime.utc(1969, 12, 31, 23), zoneId: 'Etc/GMT-1'),
      c(1970, 1, 1, 0),
    );
    expect(
      r.localAt(DateTime.utc(2100, 1, 1, 0, 59), zoneId: 'Etc/GMT+1'),
      c(2099, 12, 31, 23, 59),
    );
  });
}
