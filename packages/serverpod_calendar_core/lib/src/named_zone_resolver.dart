import 'package:timezone/data/latest_all.dart' as data;
import 'package:timezone/timezone.dart' as tz;

import 'calendar_date.dart';
import 'civil_date_time.dart';

/// How explicit wall-clock fields map to an instant under RFC 5545.
enum ZoneResolutionKind { unique, fold, gap }

/// Known-zone calculations lack enough verified offset coverage.
///
/// Callers must propagate unknown coverage, never interpret it as free time.
final class ZoneCoverageException implements Exception {
  ZoneCoverageException(this.zoneId, this.local);
  final String zoneId;
  final CivilDateTime local;

  @override
  String toString() =>
      'Insufficient pinned offset coverage for $zoneId at $local';
}

/// A resolution retaining the requested fields and exact supplied identifier.
final class ZoneResolution {
  ZoneResolution._({
    required this.local,
    required this.zoneId,
    required this.instant,
    required this.kind,
    required this.interpretationOffset,
    required this.effectiveOffset,
  });

  final CivilDateTime local;
  final String zoneId;
  final DateTime instant;
  final ZoneResolutionKind kind;

  /// Offset used to interpret the input; for a gap, the pre-gap offset.
  final Duration interpretationOffset;

  /// Actual offset in effect at the resulting instant.
  final Duration effectiveOffset;

  String get dataVersion => NamedZoneResolver.dataVersion;

  /// Actual wall fields at [instant], which differ from [local] for a gap.
  CivilDateTime get effectiveLocal {
    final fields = instant.add(effectiveOffset);
    return CivilDateTime(
      date: CalendarDate(
        year: fields.year,
        month: fields.month,
        day: fields.day,
      ),
      hour: fields.hour,
      minute: fields.minute,
      second: fields.second,
      microsecond: fields.millisecond * 1000 + fields.microsecond,
    );
  }
}

/// Resolves exact names/aliases from a pinned, immutable IANA rules snapshot.
///
/// Civil years are limited to 1900–2037. Historical coverage can be narrower
/// per zone: the upstream data discards its first transition's timestamp.
/// Unprovable periods and unknown offsets throw [ZoneCoverageException].
/// This does not validate imported VTIMEZONE data or expand recurrence rules.
final class NamedZoneResolver {
  NamedZoneResolver();

  static const dataVersion = 'iana-2026e/timezone-0.11.2/all/profile-1';
  static final Map<String, _Rules> _rules = _loadRules();

  /// Exact database keys, including aliases, excluding unknown-only placeholders.
  List<String> get zoneIds => List.unmodifiable(
    (_rules.entries
        .where((e) => e.value.hasKnownOffset)
        .map((e) => e.key)
        .toList()
      ..sort()),
  );

  /// Applies RFC explicit-time rules: earliest fold instant, pre-gap offset.
  ///
  /// Throws [ArgumentError] for an unknown/case-mismatched name, [RangeError]
  /// outside the civil-year envelope, or [ZoneCoverageException] when the pinned
  /// table cannot safely resolve the input. No name guessing is performed.
  ZoneResolution resolve(CivilDateTime local, {required String zoneId}) {
    RangeError.checkValueInInterval(
      local.date.year,
      1900,
      2037,
      'local.date.year',
    );
    final rules = _rules[zoneId];
    if (rules == null) {
      throw ArgumentError.value(zoneId, 'zoneId', 'Unknown exact IANA name.');
    }
    // This is only a numeric encoding of wall fields for offset arithmetic.
    // It is not an implicit conversion of the civil value into a UTC instant.
    final wall = DateTime.utc(
      local.date.year,
      local.date.month,
      local.date.day,
      local.hour,
      local.minute,
      local.second,
      local.microsecond ~/ 1000,
      local.microsecond % 1000,
    ).microsecondsSinceEpoch;
    final candidates = <int>[];
    for (final offset in rules.offsets) {
      final candidate = wall - offset;
      if (!rules.covers(candidate)) throw ZoneCoverageException(zoneId, local);
      final actual = rules.at(candidate);
      if (!actual.known) throw ZoneCoverageException(zoneId, local);
      if (actual.micros == offset) candidates.add(candidate);
    }
    candidates.sort();
    ZoneResolution result(int instant, ZoneResolutionKind kind, int offset) =>
        ZoneResolution._(
          local: local,
          zoneId: zoneId,
          instant: DateTime.fromMicrosecondsSinceEpoch(instant, isUtc: true),
          kind: kind,
          interpretationOffset: Duration(microseconds: offset),
          effectiveOffset: Duration(microseconds: rules.at(instant).micros),
        );
    if (candidates.isNotEmpty) {
      final first = candidates.first;
      return result(
        first,
        candidates.length == 1
            ? ZoneResolutionKind.unique
            : ZoneResolutionKind.fold,
        wall - first,
      );
    }
    for (var i = 0; i < rules.transitions.length; i++) {
      final transition = rules.transitions[i];
      if (!rules.covers(transition - 1)) continue;
      final before = rules.at(transition - 1);
      final after = rules.at(transition);
      if (!before.known || !after.known) continue;
      if (after.micros > before.micros &&
          wall >= transition + before.micros &&
          wall < transition + after.micros) {
        final instant = wall - before.micros;
        if (!rules.covers(instant) || !rules.at(instant).known) {
          throw ZoneCoverageException(zoneId, local);
        }
        return result(instant, ZoneResolutionKind.gap, before.micros);
      }
    }
    throw ZoneCoverageException(zoneId, local);
  }

  /// Projects a UTC instant to local fields without re-resolving a fold.
  ///
  /// Requires UTC input and exact zone names. The resulting local year must be
  /// 1900–2037; unproved coverage and unknown offsets still fail explicitly.
  CivilDateTime localAt(DateTime instant, {required String zoneId}) {
    if (!instant.isUtc) {
      throw ArgumentError.value(instant, 'instant', 'Must be UTC');
    }
    // Avoid arithmetic on distant dates before the offset is inspected.
    RangeError.checkValueInInterval(instant.year, 1899, 2038, 'instant.year');
    final rules = _rules[zoneId];
    if (rules == null) {
      throw ArgumentError.value(zoneId, 'zoneId', 'Unknown exact IANA name.');
    }
    final micros = instant.microsecondsSinceEpoch;
    final offset = rules.at(micros);
    final fields = DateTime.fromMicrosecondsSinceEpoch(
      micros + offset.micros,
      isUtc: true,
    );
    RangeError.checkValueInInterval(fields.year, 1900, 2037, 'local.date.year');
    final local = CivilDateTime(
      date: CalendarDate(
        year: fields.year,
        month: fields.month,
        day: fields.day,
      ),
      hour: fields.hour,
      minute: fields.minute,
      second: fields.second,
      microsecond: fields.millisecond * 1000 + fields.microsecond,
    );
    if (!rules.covers(micros) || !offset.known) {
      throw ZoneCoverageException(zoneId, local);
    }
    return local;
  }

  /// Resolves one already-valid recurrence candidate; a gap returns null.
  ///
  /// Unknown names, unsupported years and incomplete coverage still throw.
  /// A future recurrence engine must skip invalid dates too and not count
  /// omitted instances; this helper itself does not implement RRULE/COUNT.
  ZoneResolution? resolveRecurrenceCandidate(
    CivilDateTime local, {
    required String zoneId,
  }) {
    final result = resolve(local, zoneId: zoneId);
    return result.kind == ZoneResolutionKind.gap ? null : result;
  }

  static Map<String, _Rules> _loadRules() {
    // The upstream embedded initializer uses a global registry. Capture only
    // immutable primitive rules, synchronously restoring the host's registry
    // and any existing local-zone setting, so calculations never rely on it.
    final registry = tz.timeZoneDatabase.locations;
    final previous = Map<String, tz.Location>.of(registry);
    tz.Location? previousLocal;
    try {
      previousLocal = tz.local;
    } on Error {
      // The package's late local field is unset before its first initialization.
    }
    try {
      data.initializeTimeZones();
      return Map.unmodifiable({
        for (final e in registry.entries) e.key: _Rules.fromLocation(e.value),
      });
    } finally {
      registry
        ..clear()
        ..addAll(previous);
      tz.setLocalLocation(previousLocal ?? tz.UTC);
    }
  }
}

final class _Offset {
  _Offset(tz.TimeZone value)
    : micros = value.offset.inMicroseconds,
      known = value.abbreviation != '-00';
  final int micros;
  final bool known;
}

final class _Rules {
  _Rules.fromLocation(tz.Location location)
    : initial = _Offset(
        location.transitionAt.isEmpty
            ? location.zones.first
            : location.zones[location.transitionZone.first],
      ),
      transitions = List.unmodifiable([
        for (final t in location.transitionAt)
          if (t != tz.minTime) t * 1000,
      ]),
      after = List.unmodifiable([
        for (var i = 0; i < location.transitionAt.length; i++)
          if (location.transitionAt[i] != tz.minTime)
            _Offset(location.zones[location.transitionZone[i]]),
      ]),
      offsets = Set.unmodifiable(
        location.zones.map((z) => z.offset.inMicroseconds),
      ),
      fixedKnown =
          location.zones.every((z) => z.abbreviation != '-00') &&
          location.zones.map((z) => z.offset).toSet().length == 1,
      hasKnownOffset = location.zones.any((z) => z.abbreviation != '-00');

  final _Offset initial;
  final List<int> transitions;
  final List<_Offset> after;
  final Set<int> offsets;
  final bool fixedKnown;
  final bool hasKnownOffset;

  bool covers(int instant) =>
      fixedKnown || (transitions.isNotEmpty && instant >= transitions.first);

  _Offset at(int instant) {
    var low = 0;
    var high = transitions.length;
    while (low < high) {
      final middle = (low + high) ~/ 2;
      if (transitions[middle] <= instant) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return low == 0 ? initial : after[low - 1];
  }
}
