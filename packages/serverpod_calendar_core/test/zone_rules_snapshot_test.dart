import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  final resolver = NamedZoneResolver();
  final horizon = UtcWindow(start: DateTime.utc(2026), end: DateTime.utc(2027));
  test('bounded snapshot captures both Stockholm transitions exactly', () {
    final s = resolver.snapshot(
      zoneId: 'Europe/Stockholm',
      horizon: horizon,
      maxTransitions: 10,
    );
    expect(s.initialOffset, const Duration(hours: 1));
    expect(s.changes.map((v) => v.instant), [
      DateTime.utc(2026, 3, 29, 1),
      DateTime.utc(2026, 10, 25, 1),
    ]);
    expect(s.changes.map((v) => v.offset), [
      const Duration(hours: 2),
      const Duration(hours: 1),
    ]);
    expect(s.calculatedWith(NamedZoneResolver.dataVersion), isTrue);
    expect(s.calculatedWith('old'), isFalse);
    expect(
      resolver.matchesDefinition(
        s,
        zoneId: 'Europe/Stockholm',
        maxTransitions: 10,
      ),
      isTrue,
    );
    expect(() => s.changes.clear(), throwsUnsupportedError);
  });
  test('same labels do not make different offsets match', () {
    final fake = ZoneRulesSnapshot(
      zoneId: 'Europe/Stockholm',
      horizon: horizon,
      initialOffset: const Duration(hours: 1),
      changes: [],
      maxTransitions: 0,
      dataVersion: NamedZoneResolver.dataVersion,
    );
    expect(
      resolver.matchesDefinition(
        fake,
        zoneId: 'Europe/Stockholm',
        maxTransitions: 10,
      ),
      isFalse,
    );
  });
  test(
    'comparison ignores redundant labels but requires identical horizons',
    () {
      final s = resolver.snapshot(
        zoneId: 'UTC',
        horizon: horizon,
        maxTransitions: 10,
      );
      final redundant = ZoneRulesSnapshot(
        zoneId: 'arbitrary imported label',
        horizon: horizon,
        initialOffset: Duration.zero,
        changes: [
          ZoneOffsetChange(
            instant: DateTime.utc(2026, 6),
            offset: Duration.zero,
          ),
        ],
        maxTransitions: 1,
      );
      expect(redundant.changes, isEmpty);
      expect(s.matchesOffsets(redundant), isTrue);
      final other = ZoneRulesSnapshot(
        zoneId: 'UTC',
        horizon: UtcWindow(
          start: DateTime.utc(2026),
          end: DateTime.utc(2026, 6),
        ),
        initialOffset: Duration.zero,
        changes: [],
        maxTransitions: 0,
      );
      expect(s.matchesOffsets(other), isFalse);
      expect(redundant.calculatedWith(NamedZoneResolver.dataVersion), isFalse);
    },
  );
  test('transition at horizon start uses new offset; end is excluded', () {
    final s = resolver.snapshot(
      zoneId: 'Europe/Stockholm',
      horizon: UtcWindow(
        start: DateTime.utc(2026, 3, 29, 1),
        end: DateTime.utc(2026, 10, 25, 1),
      ),
      maxTransitions: 0,
    );
    expect(s.initialOffset, const Duration(hours: 2));
    expect(s.changes, isEmpty);
  });
  test('raw cap, order, bounds, local instants and offsets validate', () {
    final a = ZoneOffsetChange(
      instant: DateTime.utc(2026, 3),
      offset: const Duration(hours: 1),
    );
    final b = ZoneOffsetChange(
      instant: DateTime.utc(2026, 2),
      offset: const Duration(hours: 2),
    );
    expect(
      () => ZoneRulesSnapshot(
        zoneId: 'x',
        horizon: horizon,
        initialOffset: Duration.zero,
        changes: [a, a],
        maxTransitions: 1,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    for (final changes in [
      [a, b],
      [a, a],
      [ZoneOffsetChange(instant: horizon.start, offset: Duration.zero)],
      [ZoneOffsetChange(instant: horizon.end, offset: Duration.zero)],
    ]) {
      expect(
        () => ZoneRulesSnapshot(
          zoneId: 'x',
          horizon: horizon,
          initialOffset: Duration.zero,
          changes: changes,
          maxTransitions: 10,
        ),
        throwsArgumentError,
      );
    }
    expect(
      () => ZoneOffsetChange(instant: DateTime(2026), offset: Duration.zero),
      throwsArgumentError,
    );
    expect(
      () => ZoneOffsetChange(
        instant: DateTime.utc(2026),
        offset: const Duration(days: 1),
      ),
      throwsRangeError,
    );
    expect(
      () => resolver.snapshot(
        zoneId: 'Europe/Stockholm',
        horizon: horizon,
        maxTransitions: 1,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('coverage failure never creates matching or fixed-offset evidence', () {
    expect(
      () => resolver.snapshot(
        zoneId: 'Europe/Stockholm',
        horizon: UtcWindow(
          start: DateTime.utc(2100, 1, 2),
          end: DateTime.utc(2100, 1, 3),
        ),
        maxTransitions: 10,
      ),
      throwsRangeError,
    );
    expect(
      () => resolver.snapshot(
        zoneId: 'Factory',
        horizon: UtcWindow(start: DateTime.utc(2026), end: DateTime.utc(2027)),
        maxTransitions: 10,
      ),
      throwsA(isA<ZoneCoverageException>()),
    );
    expect(
      () => resolver.snapshot(
        zoneId: 'europe/stockholm',
        horizon: horizon,
        maxTransitions: 10,
      ),
      throwsArgumentError,
    );
  });
  test('snapshot offset oracle agrees throughout the horizon', () {
    for (final zone in [
      'Europe/Stockholm',
      'Australia/Lord_Howe',
      'Pacific/Apia',
      'UTC',
    ]) {
      final s = resolver.snapshot(
        zoneId: zone,
        horizon: horizon,
        maxTransitions: 100,
      );
      for (
        var instant = horizon.start;
        instant.isBefore(horizon.end);
        instant = instant.add(const Duration(hours: 7))
      ) {
        var offset = s.initialOffset;
        for (final c in s.changes) {
          if (c.instant.isAfter(instant)) break;
          offset = c.offset;
        }
        final local = resolver.localAt(instant, zoneId: zone);
        final encoded = DateTime.utc(
          local.date.year,
          local.date.month,
          local.date.day,
          local.hour,
          local.minute,
          local.second,
        );
        expect(encoded.difference(instant), offset, reason: '$zone $instant');
      }
    }
  });
}
