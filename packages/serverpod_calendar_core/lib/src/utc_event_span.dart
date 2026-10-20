import 'calendar_duration.dart';
import 'utc_arithmetic.dart';
import 'utc_window.dart';

/// UTC event timing preserving explicit end/duration or omitted point intent.
/// No zone resolution, busy status, authorization, recurrence or wire behavior.
final class UtcEventSpan {
  /// Requires explicit UTC values and either a strictly later [end], a positive
  /// nonzero [duration], or neither (a point event at [start]).
  factory UtcEventSpan({
    required DateTime start,
    DateTime? end,
    CalendarDuration? duration,
  }) {
    if (!start.isUtc || (end != null && !end.isUtc)) {
      throw ArgumentError('Event bounds must be explicitly UTC');
    }
    if (end != null && duration != null) {
      throw ArgumentError('Event end and duration are mutually exclusive');
    }
    if (end != null && !end.isAfter(start)) {
      throw ArgumentError('Explicit event end must follow start');
    }
    if (duration != null && (duration.sign != 1 || duration.isZero)) {
      throw ArgumentError('Event duration must be positive and nonzero');
    }
    final endExclusive = end ?? duration?.addToUtc(start) ?? start;
    return UtcEventSpan._(start, end, duration, endExclusive);
  }

  const UtcEventSpan._(this.start, this.end, this.duration, this.endExclusive);

  final DateTime start;
  final DateTime? end;
  final CalendarDuration? duration;

  /// Effective exclusive interval end, or the point instant when [isPoint].
  final DateTime endExclusive;

  bool get isPoint => endExclusive == start;

  /// Exact elapsed microseconds, including spans too large for an int Duration.
  BigInt get elapsedMicroseconds =>
      utcMicroseconds(endExclusive) - utcMicroseconds(start);

  /// Interval geometry only; point markers have no positive occupied interval.
  /// A non-null window does not by itself establish a blocking booking.
  UtcWindow? get occupiedWindow =>
      isPoint ? null : UtcWindow(start: start, end: endExclusive);

  /// Interval overlap, or point membership, in the half-open query window.
  /// A returned point marker still does not occupy a positive time interval.
  bool occursIn(UtcWindow window) => isPoint
      ? window.contains(start)
      : start.isBefore(window.end) && window.start.isBefore(endExclusive);

  /// Equality retains explicit end/duration/default form and duration units.
  @override
  bool operator ==(Object other) =>
      other is UtcEventSpan &&
      start == other.start &&
      end == other.end &&
      duration == other.duration;

  @override
  int get hashCode => Object.hash(start, end, duration);
}
