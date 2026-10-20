import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;

CivilDateTime c(int y, int m, int d, int h, int minute, [int s = 0]) =>
    CivilDateTime(
      date: CalendarDate(year: y, month: m, day: d),
      hour: h,
      minute: minute,
      second: s,
    );
void main() {
  final resolver = NamedZoneResolver();
  test(
    'winter/summer explicit resolutions preserve original fields and version',
    () {
      final local = c(2026, 1, 19, 9, 30, 7),
          result = resolver.resolve(
            c(2026, 1, 19, 9, 30, 7),
            zoneId: 'Europe/Stockholm',
          );
      expect(result.local, local);
      expect(result.instant, DateTime.utc(2026, 1, 19, 8, 30, 7));
      expect(result.kind, ZoneResolutionKind.unique);
      expect(result.dataVersion, NamedZoneResolver.dataVersion);
      expect(
        resolver
            .resolve(c(2026, 7, 1, 9, 0), zoneId: 'Europe/Stockholm')
            .instant,
        DateTime.utc(2026, 7, 1, 7),
      );
    },
  );
  test('spring gap uses pre-gap offset and retains requested fields', () {
    final value = resolver.resolve(
      c(2026, 3, 29, 2, 30),
      zoneId: 'Europe/Stockholm',
    );
    expect(value.kind, ZoneResolutionKind.gap);
    expect(value.instant, DateTime.utc(2026, 3, 29, 1, 30));
    expect(value.local.hour, 2);
    expect(value.effectiveLocal.hour, 3);
    expect(value.interpretationOffset, const Duration(hours: 1));
    expect(value.effectiveOffset, const Duration(hours: 2));
  });
  test('gap/fold boundaries are half-open at one-second precision', () {
    for (final v in [
      (3, 29, 1, 59, 59, ZoneResolutionKind.unique),
      (3, 29, 2, 0, 0, ZoneResolutionKind.gap),
      (3, 29, 2, 59, 59, ZoneResolutionKind.gap),
      (3, 29, 3, 0, 0, ZoneResolutionKind.unique),
      (10, 25, 1, 59, 59, ZoneResolutionKind.unique),
      (10, 25, 2, 0, 0, ZoneResolutionKind.fold),
      (10, 25, 2, 59, 59, ZoneResolutionKind.fold),
      (10, 25, 3, 0, 0, ZoneResolutionKind.unique),
    ]) {
      expect(
        resolver
            .resolve(
              c(2026, v.$1, v.$2, v.$3, v.$4, v.$5),
              zoneId: 'Europe/Stockholm',
            )
            .kind,
        v.$6,
      );
    }
    expect(
      resolver
          .resolve(c(2026, 10, 25, 2, 30), zoneId: 'Europe/Stockholm')
          .instant,
      DateTime.utc(2026, 10, 25, 0, 30),
    );
  });
  test('New York policy is independent of the host timezone', () {
    expect(
      resolver
          .resolve(c(2026, 3, 8, 2, 30), zoneId: 'America/New_York')
          .instant,
      DateTime.utc(2026, 3, 8, 7, 30),
    );
    expect(
      resolver
          .resolve(c(2026, 11, 1, 1, 30), zoneId: 'America/New_York')
          .instant,
      DateTime.utc(2026, 11, 1, 5, 30),
    );
  });
  test(
    'Lord Howe half-hour gap, Apia skipped date and Kathmandu quarter-hour',
    () {
      expect(
        resolver
            .resolve(c(2026, 10, 4, 2, 15), zoneId: 'Australia/Lord_Howe')
            .instant,
        DateTime.utc(2026, 10, 3, 15, 45),
      );
      expect(
        resolver.resolve(c(2011, 12, 30, 12, 0), zoneId: 'Pacific/Apia').kind,
        ZoneResolutionKind.gap,
      );
      expect(
        resolver.resolve(c(2050, 1, 1, 9, 0), zoneId: 'Asia/Kathmandu').instant,
        DateTime.utc(2050, 1, 1, 3, 15),
      );
    },
  );
  for (final y in [2038, 2050, 2099]) {
    test('calculated transitions support summer and winter in $y', () {
      expect(
        resolver.resolve(c(y, 1, 15, 9, 0), zoneId: 'Europe/Stockholm').instant,
        DateTime.utc(y, 1, 15, 8),
      );
      expect(
        resolver.resolve(c(y, 7, 15, 9, 0), zoneId: 'Europe/Stockholm').instant,
        DateTime.utc(y, 7, 15, 7),
      );
    });
  }
  test('initial-only upstream histories have proven bounded coverage now', () {
    expect(
      resolver.resolve(c(1970, 1, 1, 12, 0), zoneId: 'Africa/Abidjan').instant,
      DateTime.utc(1970, 1, 1, 12),
    );
  });
  test(
    'first and final ordinary seconds and explicit end boundary resolve',
    () {
      expect(
        resolver.resolve(c(1970, 1, 1, 0, 0), zoneId: 'Etc/UTC').instant,
        DateTime.utc(1970),
      );
      expect(
        resolver
            .resolve(c(2099, 12, 31, 23, 59, 59), zoneId: 'Etc/UTC')
            .instant,
        DateTime.utc(2099, 12, 31, 23, 59, 59),
      );
      final end = CivilDateTime(
        date: const CalendarDate.exclusiveEnd(),
        hour: 0,
        minute: 0,
      );
      expect(
        resolver.resolve(end, zoneId: 'Europe/Stockholm').instant,
        DateTime.utc(2099, 12, 31, 23),
      );
    },
  );
  test('UTC spillover is allowed for supported civil boundary values', () {
    final first = resolver.resolve(c(1970, 1, 1, 0, 0), zoneId: 'Asia/Tokyo');
    expect(first.instant, DateTime.utc(1969, 12, 31, 15));
    expect(resolver.localAt(first.instant, zoneId: 'Asia/Tokyo'), first.local);
    expect(
      () => resolver.localAt(DateTime.utc(1969, 12, 31), zoneId: 'UTC'),
      throwsRangeError,
    );
  });
  test('aliases remain exact and named identity is preserved', () {
    expect(
      resolver.resolve(c(2026, 1, 1, 9, 0), zoneId: 'US/Eastern').zoneId,
      'US/Eastern',
    );
    expect(resolver.zoneIds, contains('US/Eastern'));
    expect(() => resolver.zoneIds.add('x'), throwsUnsupportedError);
  });
  for (final id in [
    '',
    'Europe/stockholm',
    ' Europe/Stockholm',
    'W. Europe Standard Time',
    'Europe/Imaginary',
    'CEST',
  ]) {
    test(
      'unknown exact key rejects: $id',
      () => expect(
        () => resolver.resolve(c(2026, 1, 1, 0, 0), zoneId: id),
        throwsArgumentError,
      ),
    );
  }
  for (final y in [1969, 2100, 2101]) {
    test(
      'ordinary civil year outside profile rejects: $y',
      () => expect(() => c(y, 1, 1, 0, 0), throwsRangeError),
    );
  }
  test('unknown-offset placeholder is never UTC or a skipped occurrence', () {
    expect(resolver.zoneIds, isNot(contains('Factory')));
    expect(
      () => resolver.resolve(c(2026, 1, 1, 0, 0), zoneId: 'Factory'),
      throwsA(isA<ZoneCoverageException>()),
    );
    expect(
      () => resolver.resolveRecurrenceCandidate(
        c(2026, 1, 1, 0, 0),
        zoneId: 'Factory',
      ),
      throwsA(isA<ZoneCoverageException>()),
    );
  });
  test('generated gaps skip and folds retain first UTC identity', () {
    expect(
      resolver.resolveRecurrenceCandidate(
        c(2026, 3, 29, 2, 30),
        zoneId: 'Europe/Stockholm',
      ),
      isNull,
    );
    expect(
      resolver
          .resolveRecurrenceCandidate(
            c(2026, 10, 25, 2, 30),
            zoneId: 'Europe/Stockholm',
          )!
          .instant,
      DateTime.utc(2026, 10, 25, 0, 30),
    );
  });
  test('resolver never initializes or mutates the host global registry', () {
    final before = Map<String, tz.Location>.of(tz.timeZoneDatabase.locations);
    resolver.resolve(c(2050, 1, 1, 0, 0), zoneId: 'Europe/Stockholm');
    expect(tz.timeZoneDatabase.locations, before);
  });
}
