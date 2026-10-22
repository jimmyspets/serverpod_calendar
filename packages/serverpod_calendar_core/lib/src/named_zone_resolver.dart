import 'zone_rules_snapshot.dart';
import 'utc_window.dart';
import 'date_recurrence_generator.dart';
import 'date_recurrence_rule.dart';

import 'dart:convert';

// Pinned timezone 0.11.2 decoder; generation verifies serialization compatibility.
// ignore: implementation_imports
import 'package:timezone/src/tzdb.dart' show tzdbDeserialize;

import 'bounded_timezone_data.dart';
import 'utc_arithmetic.dart';

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
      date: fields.year == 2100 && fields.month == 1 && fields.day == 1
          ? const CalendarDate.exclusiveEnd()
          : CalendarDate(
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
/// Ordinary civil dates are in [1970, 2100), with an explicit midnight end
/// boundary. Generated IANA transitions include UTC padding; unknown offsets
/// are still rejected. The pinned timezone decoder never mutates host globals.
/// Unprovable periods and unknown offsets throw [ZoneCoverageException].
/// This does not validate imported VTIMEZONE data or expand recurrence rules.
final class NamedZoneResolver {
  NamedZoneResolver();

  static const dataVersion = boundedTimezoneVersion;
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
      1970,
      2100,
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
      if (!rules.covers(transition - 1000000)) continue;
      final before = rules.at(transition - 1000000);
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
  /// [1970, 2100), or the midnight exclusive endpoint. Unknown offsets fail.
  CivilDateTime localAt(DateTime instant, {required String zoneId}) {
    if (!instant.isUtc) {
      throw ArgumentError.value(instant, 'instant', 'Must be UTC');
    }
    // Padding supports valid civil boundaries; it is not ordinary date storage.
    utcMicroseconds(instant);
    if (instant.isBefore(DateTime.utc(1969, 12, 30)) ||
        !instant.isBefore(DateTime.utc(2100, 1, 3))) {
      throw RangeError('UTC instant is outside calculation padding');
    }
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

    final local = CivilDateTime(
      date: fields.year == 2100 && fields.month == 1 && fields.day == 1
          ? const CalendarDate.exclusiveEnd()
          : CalendarDate(
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

  /// Conservative candidate bound, not evidence that a period is covered.
  /// Every generated local value still requires normal guarded resolution.
  Duration maximumOffset({required String zoneId}) {
    final rules = _rules[zoneId];
    if (rules == null || !rules.hasKnownOffset) {
      throw ArgumentError.value(zoneId, 'zoneId', 'Unknown usable IANA name');
    }
    return Duration(
      microseconds: rules.offsets.reduce((a, b) => a > b ? a : b),
    );
  }

  /// Largest possible offset difference in this pinned zone's known table.
  Duration offsetRange({required String zoneId}) {
    final rules = _rules[zoneId];
    if (rules == null || !rules.hasKnownOffset) {
      throw ArgumentError.value(zoneId, 'zoneId', 'Unknown usable IANA name');
    }
    final low = rules.offsets.reduce((a, b) => a < b ? a : b);
    final high = rules.offsets.reduce((a, b) => a > b ? a : b);
    return Duration(microseconds: high - low);
  }

  /// Proves all offset segments in a bounded horizon, including its endpoints.
  /// Unsupported periods fail; no unverified historical/future tail is added.
  ZoneRulesSnapshot snapshot({
    required String zoneId,
    required UtcWindow horizon,
    required int maxTransitions,
  }) {
    RangeError.checkValueInInterval(
      maxTransitions,
      0,
      DateRecurrenceRule.maxScalar,
      'maxTransitions',
    );
    final local = localAt(horizon.start, zoneId: zoneId);
    localAt(horizon.end.subtract(const Duration(seconds: 1)), zoneId: zoneId);
    final rules = _rules[zoneId]!;
    final first = horizon.start.microsecondsSinceEpoch;
    final last = horizon.end.microsecondsSinceEpoch;
    final initial = rules.at(first);
    final changes = <ZoneOffsetChange>[];
    for (var i = 0; i < rules.transitions.length; i++) {
      final instant = rules.transitions[i];
      if (instant <= first || instant >= last) continue;
      if (!rules.covers(instant) || !rules.after[i].known) {
        throw ZoneCoverageException(zoneId, local);
      }
      // Validate local envelope at both sides, including unusual historical jumps.
      localAt(
        DateTime.fromMicrosecondsSinceEpoch(instant - 1000000, isUtc: true),
        zoneId: zoneId,
      );
      localAt(
        DateTime.fromMicrosecondsSinceEpoch(instant, isUtc: true),
        zoneId: zoneId,
      );
      if (changes.length >= maxTransitions) {
        throw const RecurrenceLimitException('maxTransitions');
      }
      changes.add(
        ZoneOffsetChange(
          instant: DateTime.fromMicrosecondsSinceEpoch(instant, isUtc: true),
          offset: Duration(microseconds: rules.after[i].micros),
        ),
      );
    }
    return ZoneRulesSnapshot(
      zoneId: zoneId,
      horizon: horizon,
      initialOffset: Duration(microseconds: initial.micros),
      changes: changes,
      maxTransitions: maxTransitions,
      dataVersion: dataVersion,
    );
  }

  /// Offset evidence over all supported civil dates plus UTC calculation edges.
  ///
  /// The fixed UTC horizon [1969-12-31, 2100-01-02) covers every ordinary local
  /// value/exclusive endpoint under offsets smaller than one day. Unlike
  /// [snapshot], this does not require padding instants to be ordinary civil
  /// values. It never makes those dates valid for event storage or resolution.
  ZoneRulesSnapshot calendarProfileSnapshot({
    required String zoneId,
    required int maxTransitions,
  }) {
    RangeError.checkValueInInterval(
      maxTransitions,
      0,
      DateRecurrenceRule.maxScalar,
      'maxTransitions',
    );
    final rules = _rules[zoneId];
    if (rules == null) throw ArgumentError('Unknown exact IANA name');
    final horizon = UtcWindow(
      start: DateTime.utc(1969, 12, 31),
      end: DateTime.utc(2100, 1, 2),
    );
    final first = horizon.start.microsecondsSinceEpoch;
    final last = horizon.end.microsecondsSinceEpoch;
    // This diagnostic field is a representative in-profile boundary, not an
    // attempt to construct ordinary civil values from UTC padding.
    final boundary = CivilDateTime(
      date: CalendarDate(year: 1970, month: 1, day: 1),
      hour: 0,
      minute: 0,
    );
    void requireKnown(int at) {
      if (!rules.covers(at) || !rules.at(at).known) {
        throw ZoneCoverageException(zoneId, boundary);
      }
    }

    requireKnown(first);
    requireKnown(last - 1000000);
    final changes = <ZoneOffsetChange>[];
    for (final at in rules.transitions) {
      if (at <= first || at >= last) continue;
      requireKnown(at);
      if (changes.length >= maxTransitions) {
        throw const RecurrenceLimitException('maxTransitions');
      }
      changes.add(
        ZoneOffsetChange(
          instant: DateTime.fromMicrosecondsSinceEpoch(at, isUtc: true),
          offset: Duration(microseconds: rules.at(at).micros),
        ),
      );
    }
    return ZoneRulesSnapshot(
      zoneId: zoneId,
      horizon: horizon,
      initialOffset: Duration(microseconds: rules.at(first).micros),
      changes: changes,
      maxTransitions: maxTransitions,
      dataVersion: dataVersion,
    );
  }

  /// Known-zone matching is limited to the supplied, fully expanded horizon.
  /// This does not parse or trust an imported VTIMEZONE component.
  bool matchesDefinition(
    ZoneRulesSnapshot definition, {
    required String zoneId,
    required int maxTransitions,
  }) => snapshot(
    zoneId: zoneId,
    horizon: definition.horizon,
    maxTransitions: maxTransitions,
  ).matchesOffsets(definition);

  static Map<String, _Rules> _loadRules() => Map.unmodifiable({
    for (final location in tzdbDeserialize(base64Decode(boundedTimezoneData)))
      location.name: _Rules.fromLocation(location),
  });
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
      instant >= -172800000000 && instant < 4102617600000000;

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
