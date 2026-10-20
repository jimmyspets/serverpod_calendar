import 'calendar_date.dart';
import 'calendar_duration.dart';

/// DATE-only event bounds retaining explicit end/duration/default intent.
///
/// This is not a task due date, UTC interval or availability decision. A span
/// does not imply that an event blocks time or that a caller can access it.
final class DateEventSpan {
  /// Validates a nonempty event span with an inclusive [start].
  ///
  /// [end] is exclusive and cannot accompany [duration]. A duration must be
  /// positive and contain only days or weeks. Omitting both means one day.
  /// The effective exclusive end must remain within date years 1 through 9999;
  /// overflow throws [RangeError] rather than clipping or creating year 10000.
  factory DateEventSpan({
    required CalendarDate start,
    CalendarDate? end,
    CalendarDuration? duration,
  }) {
    if (end != null && duration != null) {
      throw ArgumentError('Event end and duration are mutually exclusive');
    }
    if (duration != null && (duration.sign != 1 || duration.isZero)) {
      throw ArgumentError('Event duration must be positive and nonzero');
    }
    final endExclusive = end ?? duration?.addToDate(start) ?? start.addDays(1);
    if (endExclusive.compareTo(start) <= 0) {
      throw ArgumentError('Event end must follow start');
    }
    return DateEventSpan._(start, end, duration, endExclusive);
  }

  const DateEventSpan._(this.start, this.end, this.duration, this.endExclusive);

  final CalendarDate start;

  /// Explicit exclusive end, or null when duration/default semantics were used.
  final CalendarDate? end;

  /// Original unit-preserving duration, or null when end/default was used.
  final CalendarDuration? duration;

  /// Validated effective exclusive end, including duration/default application.
  final CalendarDate endExclusive;

  /// Calendar days, not elapsed 24-hour periods or a resolved instant duration.
  int get dayCount => start.daysUntil(endExclusive);

  bool contains(CalendarDate date) =>
      start.compareTo(date) <= 0 && date.compareTo(endExclusive) < 0;

  /// Adjacent spans that only touch at an exclusive end do not overlap.
  bool overlaps(DateEventSpan other) =>
      start.compareTo(other.endExclusive) < 0 &&
      other.start.compareTo(endExclusive) < 0;

  /// Structural equality retains end/duration/default form and duration units.
  /// Equal occupied dates alone do not make differently expressed spans equal.
  @override
  bool operator ==(Object other) =>
      other is DateEventSpan &&
      start == other.start &&
      end == other.end &&
      duration == other.duration;

  @override
  int get hashCode => Object.hash(start, end, duration);
}
