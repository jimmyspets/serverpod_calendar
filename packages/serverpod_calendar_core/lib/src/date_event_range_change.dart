import 'calendar_date.dart';
import 'date_event_span.dart';

/// Complete DATE-only THISANDFUTURE timing change at an original occurrence.
/// Applies the anchor's signed calendar-day shift and replacement span length.
/// It does not change the recurrence rule or represent range cancellation.
final class DateEventRangeChange {
  DateEventRangeChange({
    required this.originalStart,
    required this.replacement,
  }) {
    originalStart.requireOrdinary('originalStart');
  }

  final CalendarDate originalStart;
  final DateEventSpan replacement;

  /// Relative to the original occurrence, not an earlier range change.
  int get dayShift => originalStart.daysUntil(replacement.start);

  @override
  bool operator ==(Object other) =>
      other is DateEventRangeChange &&
      originalStart == other.originalStart &&
      replacement == other.replacement;

  @override
  int get hashCode => Object.hash(originalStart, replacement);
}
