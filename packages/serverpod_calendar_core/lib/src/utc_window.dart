/// A finite, increasing interval of UTC instants: `[start, end)`.
///
/// The start is included and the end is excluded. Adjacent windows do not
/// overlap. This value represents query bounds, not event date-only values,
/// zoned civil times, recurrence rules or evidence that a period is free.
final class UtcWindow {
  /// Creates a window with explicit UTC bounds and a strictly later end.
  ///
  /// Throws [ArgumentError] for local bounds, equal bounds or reversed bounds.
  UtcWindow({required this.start, required this.end}) {
    if (!start.isUtc) {
      throw ArgumentError.value(start, 'start', 'Must be explicitly UTC.');
    }
    if (!end.isUtc) {
      throw ArgumentError.value(end, 'end', 'Must be explicitly UTC.');
    }
    if (!end.isAfter(start)) {
      throw ArgumentError.value(end, 'end', 'Must be later than start.');
    }
  }

  /// Inclusive lower bound.
  final DateTime start;

  /// Exclusive upper bound.
  final DateTime end;

  /// Elapsed UTC time between the bounds, not a nominal calendar duration.
  Duration get duration => end.difference(start);

  /// Whether an explicit UTC [instant] belongs to this window.
  ///
  /// Throws [ArgumentError] for a local instant rather than converting it.
  bool contains(DateTime instant) {
    if (!instant.isUtc) {
      throw ArgumentError.value(instant, 'instant', 'Must be explicitly UTC.');
    }
    return !instant.isBefore(start) && instant.isBefore(end);
  }

  /// Whether this window and [other] share a nonempty interval.
  bool overlaps(UtcWindow other) =>
      start.isBefore(other.end) && other.start.isBefore(end);

  /// The shared interval, or null for disjoint or adjacent windows.
  UtcWindow? intersection(UtcWindow other) {
    if (!overlaps(other)) return null;
    return UtcWindow(
      start: start.isAfter(other.start) ? start : other.start,
      end: end.isBefore(other.end) ? end : other.end,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UtcWindow && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}
