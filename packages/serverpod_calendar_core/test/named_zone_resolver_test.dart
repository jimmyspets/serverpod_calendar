import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  final resolver = NamedZoneResolver();
  CivilDateTime civil(
    int year,
    int month,
    int day,
    int hour,
    int minute, {
    int second = 0,
    int fraction = 0,
  }) => CivilDateTime(
    date: CalendarDate(year: year, month: month, day: day),
    hour: hour,
    minute: minute,
    second: second,
    microsecond: fraction,
  );
  ZoneResolution stockholm(CivilDateTime local) =>
      resolver.resolve(local, zoneId: 'Europe/Stockholm');

  test(
    'bundled snapshot preserves host registry/local and resists later mutation',
    () {
      final host = tz.Location('Host/Private', [], [], [tz.TimeZone.UTC]);
      final registry = tz.timeZoneDatabase.locations;
      registry
        ..clear()
        ..['Host/Private'] = host;
      tz.setLocalLocation(host);
      expect(resolver.zoneIds, contains('Europe/Stockholm'));
      expect(registry.keys, ['Host/Private']);
      expect(identical(tz.local, host), isTrue);
      data.initializeTimeZones();
      tz.getLocation('Europe/Stockholm').zones.clear();
      registry.clear();
      tz.setLocalLocation(host);
      expect(
        stockholm(civil(2026, 7, 19, 9, 30)).instant,
        DateTime.utc(2026, 7, 19, 7, 30),
      );
      expect(
        NamedZoneResolver()
            .resolve(civil(2026, 7, 19, 9, 30), zoneId: 'Europe/Stockholm')
            .instant,
        DateTime.utc(2026, 7, 19, 7, 30),
      );
      expect(identical(tz.local, host), isTrue);
    },
  );

  test('winter resolution preserves request, metadata and UTC precision', () {
    final local = civil(2026, 1, 19, 9, 30, second: 5, fraction: 123456);
    final result = stockholm(local);
    expect(result.local, local);
    expect(result.zoneId, 'Europe/Stockholm');
    expect(result.kind, ZoneResolutionKind.unique);
    expect(result.instant, DateTime.utc(2026, 1, 19, 8, 30, 5, 123, 456));
    expect(result.instant.isUtc, isTrue);
    expect(result.interpretationOffset, const Duration(hours: 1));
    expect(result.effectiveOffset, const Duration(hours: 1));
    expect(result.effectiveLocal, local);
    expect(result.dataVersion, contains('2026e'));
  });

  test('summer uses the pinned daylight offset', () {
    final result = stockholm(civil(2026, 7, 19, 9, 30));
    expect(result.instant, DateTime.utc(2026, 7, 19, 7, 30));
    expect(result.interpretationOffset, const Duration(hours: 2));
  });

  test(
    'explicit Stockholm spring gap uses pre-gap offset and retains input',
    () {
      final local = civil(2026, 3, 29, 2, 30, fraction: 1);
      final result = stockholm(local);
      expect(result.kind, ZoneResolutionKind.gap);
      expect(result.local, local);
      expect(result.instant, DateTime.utc(2026, 3, 29, 1, 30, 0, 0, 1));
      expect(result.interpretationOffset, const Duration(hours: 1));
      expect(result.effectiveOffset, const Duration(hours: 2));
      expect(result.effectiveLocal, civil(2026, 3, 29, 3, 30, fraction: 1));
    },
  );

  test('Stockholm fold chooses the first UTC occurrence', () {
    final result = stockholm(civil(2026, 10, 25, 2, 30));
    expect(result.kind, ZoneResolutionKind.fold);
    expect(result.instant, DateTime.utc(2026, 10, 25, 0, 30));
    expect(result.interpretationOffset, const Duration(hours: 2));
    expect(result.effectiveLocal, result.local);
  });

  test('spring gap boundaries are half-open at microsecond precision', () {
    final before = stockholm(
      civil(2026, 3, 29, 1, 59, second: 59, fraction: 999999),
    );
    expect(before.kind, ZoneResolutionKind.unique);
    expect(before.instant, DateTime.utc(2026, 3, 29, 0, 59, 59, 999, 999));
    expect(stockholm(civil(2026, 3, 29, 2, 0)).kind, ZoneResolutionKind.gap);
    expect(
      stockholm(civil(2026, 3, 29, 2, 59, second: 59, fraction: 999999)).kind,
      ZoneResolutionKind.gap,
    );
    final after = stockholm(civil(2026, 3, 29, 3, 0));
    expect(after.kind, ZoneResolutionKind.unique);
    expect(after.instant, DateTime.utc(2026, 3, 29, 1));
  });

  test('autumn fold boundaries are half-open', () {
    expect(
      stockholm(civil(2026, 10, 25, 1, 59, second: 59, fraction: 999999)).kind,
      ZoneResolutionKind.unique,
    );
    expect(stockholm(civil(2026, 10, 25, 2, 0)).kind, ZoneResolutionKind.fold);
    expect(
      stockholm(civil(2026, 10, 25, 2, 59, second: 59, fraction: 999999)).kind,
      ZoneResolutionKind.fold,
    );
    final after = stockholm(civil(2026, 10, 25, 3, 0));
    expect(after.kind, ZoneResolutionKind.unique);
    expect(after.instant, DateTime.utc(2026, 10, 25, 2));
  });

  test('RFC New York examples resolve explicit gaps and folds', () {
    final gap = resolver.resolve(
      civil(2007, 3, 11, 2, 30),
      zoneId: 'America/New_York',
    );
    final fold = resolver.resolve(
      civil(2007, 11, 4, 1, 30),
      zoneId: 'America/New_York',
    );
    expect(gap.instant, DateTime.utc(2007, 3, 11, 7, 30));
    expect(gap.kind, ZoneResolutionKind.gap);
    expect(fold.instant, DateTime.utc(2007, 11, 4, 5, 30));
    expect(fold.kind, ZoneResolutionKind.fold);
  });

  test('Lord Howe half-hour gap is not assumed to be an hour', () {
    final result = resolver.resolve(
      civil(2026, 10, 4, 2, 15),
      zoneId: 'Australia/Lord_Howe',
    );
    expect(result.kind, ZoneResolutionKind.gap);
    expect(result.instant, DateTime.utc(2026, 10, 3, 15, 45));
    expect(result.interpretationOffset, const Duration(hours: 10, minutes: 30));
    expect(result.effectiveOffset, const Duration(hours: 11));
    expect(result.effectiveLocal, civil(2026, 10, 4, 2, 45));
  });

  test('Lord Howe half-hour fold chooses the first occurrence', () {
    final result = resolver.resolve(
      civil(2026, 4, 5, 1, 45),
      zoneId: 'Australia/Lord_Howe',
    );
    expect(result.kind, ZoneResolutionKind.fold);
    expect(result.instant, DateTime.utc(2026, 4, 4, 14, 45));
  });

  test(
    'Apia skipped date uses pre-gap offset without losing original date',
    () {
      final result = resolver.resolve(
        civil(2011, 12, 30, 12, 0),
        zoneId: 'Pacific/Apia',
      );
      expect(result.kind, ZoneResolutionKind.gap);
      expect(result.instant, DateTime.utc(2011, 12, 30, 22));
      expect(result.interpretationOffset, const Duration(hours: -10));
      expect(result.effectiveOffset, const Duration(hours: 14));
      expect(result.effectiveLocal, civil(2011, 12, 31, 12, 0));
      expect(result.local.date, CalendarDate(year: 2011, month: 12, day: 30));
    },
  );

  test('Kathmandu preserves quarter-hour offset and fractional seconds', () {
    final result = resolver.resolve(
      civil(2026, 1, 19, 9, 30, fraction: 999999),
      zoneId: 'Asia/Kathmandu',
    );
    expect(result.instant, DateTime.utc(2026, 1, 19, 3, 45, 0, 999, 999));
    expect(result.effectiveOffset, const Duration(hours: 5, minutes: 45));
  });

  test('negative epoch instants preserve single-microsecond precision', () {
    final result = resolver.resolve(
      civil(1930, 1, 10, 0, 0, fraction: 1),
      zoneId: 'America/New_York',
    );
    expect(result.instant, DateTime.utc(1930, 1, 10, 5, 0, 0, 0, 1));
  });

  test('legacy alias retains the exact supplied key', () {
    final local = civil(2026, 10, 25, 12, 0);
    final alias = resolver.resolve(local, zoneId: 'US/Eastern');
    expect(alias.zoneId, 'US/Eastern');
    expect(
      alias.instant,
      resolver.resolve(local, zoneId: 'America/New_York').instant,
    );
    expect(resolver.zoneIds, contains('US/Eastern'));
    expect(() => resolver.zoneIds.add('Injected/Zone'), throwsUnsupportedError);
  });

  for (final name in [
    '',
    'Europe/stockholm',
    ' Europe/Stockholm',
    'W. Europe Standard Time',
    'Europe/Imaginary',
    'CEST',
  ]) {
    test('rejects unknown exact zone key "$name" without guessing', () {
      expect(
        () => resolver.resolve(civil(2026, 1, 19, 9, 30), zoneId: name),
        throwsArgumentError,
      );
    });
  }

  test('fixed UTC supports both civil-year envelope boundaries', () {
    final first = resolver.resolve(
      civil(1900, 1, 1, 0, 0, fraction: 1),
      zoneId: 'Etc/UTC',
    );
    final last = resolver.resolve(
      civil(2037, 12, 31, 23, 59, second: 59, fraction: 999999),
      zoneId: 'Etc/UTC',
    );
    expect(first.instant, DateTime.utc(1900, 1, 1, 0, 0, 0, 0, 1));
    expect(last.instant, DateTime.utc(2037, 12, 31, 23, 59, 59, 999, 999));
  });

  for (final year in [1, 1899, 2038, 9999]) {
    test('rejects unsupported civil calculation year $year', () {
      expect(
        () => resolver.resolve(civil(year, 1, 1, 0, 0), zoneId: 'Etc/UTC'),
        throwsRangeError,
      );
    });
  }

  test('unknown-only Factory placeholder is not treated as UTC', () {
    expect(resolver.zoneIds, isNot(contains('Factory')));
    expect(
      () => resolver.resolve(civil(2026, 1, 1, 0, 0), zoneId: 'Factory'),
      throwsA(isA<ZoneCoverageException>()),
    );
  });

  test('unprovable historical offset is an explicit coverage failure', () {
    expect(
      () =>
          resolver.resolve(civil(1900, 1, 1, 12, 0), zoneId: 'Asia/Kathmandu'),
      throwsA(isA<ZoneCoverageException>()),
    );
  });

  test(
    'a truncated initial-only historical table is not used as a fixed zone',
    () {
      expect(
        () => resolver.resolve(
          civil(2026, 1, 1, 12, 0),
          zoneId: 'Africa/Abidjan',
        ),
        throwsA(isA<ZoneCoverageException>()),
      );
    },
  );

  test(
    'recurrence helper omits gaps but resolves folds with the first instant',
    () {
      expect(
        resolver.resolveRecurrenceCandidate(
          civil(2026, 3, 29, 2, 30),
          zoneId: 'Europe/Stockholm',
        ),
        isNull,
      );
      expect(
        resolver.resolveRecurrenceCandidate(
          civil(2011, 12, 30, 12, 0),
          zoneId: 'Pacific/Apia',
        ),
        isNull,
      );
      final fold = resolver.resolveRecurrenceCandidate(
        civil(2026, 10, 25, 2, 30),
        zoneId: 'Europe/Stockholm',
      );
      expect(fold!.kind, ZoneResolutionKind.fold);
      expect(fold.instant, DateTime.utc(2026, 10, 25, 0, 30));
    },
  );

  test(
    'recurrence helper never turns unknown coverage into a skipped occurrence',
    () {
      expect(
        () => resolver.resolveRecurrenceCandidate(
          civil(1900, 1, 1, 12, 0),
          zoneId: 'Asia/Kathmandu',
        ),
        throwsA(isA<ZoneCoverageException>()),
      );
      expect(
        () => resolver.resolveRecurrenceCandidate(
          civil(2026, 1, 1, 12, 0),
          zoneId: 'Unknown/Zone',
        ),
        throwsArgumentError,
      );
    },
  );
}
