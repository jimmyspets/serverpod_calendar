import 'date_recurrence_generator.dart';
import 'date_recurrence_rule.dart';
import 'utc_window.dart';

/// A normalized offset change at an exact UTC instant, within a declared horizon.
final class ZoneOffsetChange {
  ZoneOffsetChange({required this.instant, required this.offset}) {
    if (!instant.isUtc) throw ArgumentError('Transition instant must be UTC');
    // Pinned IANA offsets and RFC UTC-OFFSET are within one day.
    RangeError.checkValueInInterval(
      offset.inMicroseconds,
      -86399999999,
      86399999999,
      'offset',
    );
  }
  final DateTime instant;
  final Duration offset;
  @override
  bool operator ==(Object other) =>
      other is ZoneOffsetChange &&
      instant == other.instant &&
      offset == other.offset;
  @override
  int get hashCode => Object.hash(instant, offset);
}

/// Offset-only calculation evidence. A future VTIMEZONE adapter must separately
/// validate syntax, observance expansion and coverage before constructing this.
/// Abbreviations/labels do not establish agreement or host authority.
final class ZoneRulesSnapshot {
  ZoneRulesSnapshot({
    required this.zoneId,
    required this.horizon,
    required this.initialOffset,
    required List<ZoneOffsetChange> changes,
    required int maxTransitions,
    this.dataVersion,
  }) {
    RangeError.checkValueInInterval(
      maxTransitions,
      0,
      DateRecurrenceRule.maxScalar,
      'maxTransitions',
    );
    if (changes.length > maxTransitions) {
      throw const RecurrenceLimitException('maxTransitions');
    }
    ZoneOffsetChange(instant: horizon.start, offset: initialOffset);
    final normalized = <ZoneOffsetChange>[];
    var last = horizon.start;
    var offset = initialOffset;
    for (final c in changes) {
      if (!c.instant.isAfter(last) || !c.instant.isBefore(horizon.end)) {
        throw ArgumentError(
          'Transitions must be ordered strictly inside the horizon',
        );
      }
      if (c.offset != offset) normalized.add(c);
      last = c.instant;
      offset = c.offset;
    }
    this.changes = List.unmodifiable(normalized);
  }
  final String zoneId;
  final UtcWindow horizon;
  final Duration initialOffset;
  final String? dataVersion;
  late final List<ZoneOffsetChange> changes;

  /// Same offsets throughout exactly the same horizon. Names/version labels
  /// are deliberately not evidence; the caller selects the known zone to test.
  bool matchesOffsets(ZoneRulesSnapshot other) =>
      horizon.start == other.horizon.start &&
      horizon.end == other.horizon.end &&
      initialOffset == other.initialOffset &&
      changes.length == other.changes.length &&
      Iterable<int>.generate(changes.length)
          .every((i) => changes[i] == other.changes[i]);

  /// Host-stored projections must be recalculated after any pinned-data change.
  /// Offset agreement in one horizon is insufficient for a version assertion.
  bool calculatedWith(String version) => dataVersion == version;
}
