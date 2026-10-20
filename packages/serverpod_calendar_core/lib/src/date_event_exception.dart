import 'calendar_date.dart';
import 'date_event_span.dart';

/// A complete DATE-only cancellation or replacement, keyed by original start.
/// Membership and duplicate validation belong to DateEventExceptionSet.
final class DateEventException {
  DateEventException.cancel({required this.originalStart})
    : replacement = null {
    originalStart.requireOrdinary('originalStart');
  }

  DateEventException.replace({
    required this.originalStart,
    required DateEventSpan this.replacement,
  }) {
    originalStart.requireOrdinary('originalStart');
  }

  final CalendarDate originalStart;
  final DateEventSpan? replacement;
  bool get isCancelled => replacement == null;

  @override
  bool operator ==(Object other) =>
      other is DateEventException &&
      originalStart == other.originalStart &&
      replacement == other.replacement;

  @override
  int get hashCode => Object.hash(originalStart, replacement);
}
