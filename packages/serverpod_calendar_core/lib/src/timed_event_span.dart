import 'calendar_duration.dart';
import 'timed_value.dart';
import 'utc_arithmetic.dart';
import 'utc_event_span.dart';
import 'utc_window.dart';

/// Preserved UTC or zoned event bounds, including an omitted-end point.
final class TimedEventSpan {
  TimedEventSpan({required this.start, this.end, this.duration}) {
    if (end != null && duration != null) {
      throw ArgumentError('End and duration are exclusive');
    }
    if (end != null && !start.sameProfile(end!)) {
      throw ArgumentError('End must use the start temporal profile');
    }
    if (duration != null && (duration!.sign < 0 || duration!.isZero)) {
      throw ArgumentError('Event duration must be positive');
    }
    final finish = endExclusive;
    if (start.zoneId == null) TimedValue.utc(finish);
    if ((end != null || duration != null) && !finish.isAfter(start.instant)) {
      throw ArgumentError('Event end must follow start');
    }
  }
  final TimedValue start;
  final TimedValue? end;
  final CalendarDuration? duration;
  DateTime get endExclusive =>
      end?.instant ?? (duration == null ? start.instant : start.add(duration!));
  BigInt get elapsedMicroseconds =>
      utcMicroseconds(endExclusive) - utcMicroseconds(start.instant);
  bool get isPoint => end == null && duration == null;
  UtcEventSpan get resolved => isPoint
      ? UtcEventSpan(start: start.instant)
      : UtcEventSpan(start: start.instant, end: endExclusive);
  bool occursIn(UtcWindow window) => resolved.occursIn(window);

  /// RRULE instances inherit exact length for explicit end, nominal units for
  /// DURATION. The resolved projection never replaces the preserved template.
  UtcEventSpan projectAt(TimedValue value) {
    if (!start.sameProfile(value)) {
      throw ArgumentError('Different temporal profiles');
    }
    if (isPoint) return UtcEventSpan(start: value.instant);
    final finish = duration != null
        ? value.add(duration!)
        : utcFromMicroseconds(
            utcMicroseconds(value.instant) + elapsedMicroseconds,
          );
    // Duration application validates zone endpoints. Exact-end propagation must
    // also prove coverage; do not re-resolve a later-fold endpoint.
    if (value.zoneId != null) {
      validateZonedInstant(finish, value.zoneId!);
    } else {
      TimedValue.utc(finish);
    }
    return UtcEventSpan(start: value.instant, end: finish);
  }

  @override
  bool operator ==(Object other) =>
      other is TimedEventSpan &&
      start == other.start &&
      end == other.end &&
      duration == other.duration;
  @override
  int get hashCode => Object.hash(start, end, duration);
}
