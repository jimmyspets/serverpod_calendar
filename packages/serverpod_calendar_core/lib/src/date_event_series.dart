import 'calendar_date.dart';
import 'date_event_span.dart';
import 'date_recurrence_set.dart';

/// A DATE-only recurrence set paired with one validated event-span template.
///
/// This has no moved overrides, per-occurrence lengths, tenant/series identity,
/// busy-status policy, authorization or UTC occupancy conversion.
final class DateEventSeries {
  DateEventSeries({required this.recurrence, required this.span}) {
    if (recurrence.start != span.start) {
      throw ArgumentError('Recurrence DTSTART must match the span start');
    }
  }

  final DateRecurrenceSet recurrence;
  final DateEventSpan span;

  /// Returns complete spans overlapping the half-open date range [from, until).
  ///
  /// The lower start-date bound includes the template's possible lookback,
  /// bounded by year 1. Raw-rule and result limits apply to that widened range;
  /// work still includes rule history. No partial result escapes any budget or
  /// endpoint overflow failure. Query bounds never clip the returned spans.
  List<DateEventSpan> expandOverlapping({
    required CalendarDate from,
    required CalendarDate until,
    required int maxCandidateDays,
    required int maxRuleOccurrences,
    required int maxResults,
  }) {
    if (from.compareTo(until) >= 0) {
      throw ArgumentError('from must precede until');
    }
    final first = CalendarDate(year: 1, month: 1, day: 1);
    final available = first.daysUntil(from);
    final wanted = span.dayCount - 1;
    final lookback = wanted < available ? wanted : available;
    // For a fixed positive L-day span, overlap is equivalent to a start in
    // [from - (L - 1), until - 1]. Every selected start therefore overlaps.
    final starts = recurrence.expand(
      from: from.addDays(-lookback),
      through: until.addDays(-1),
      maxCandidateDays: maxCandidateDays,
      maxRuleOccurrences: maxRuleOccurrences,
      maxResults: maxResults,
    );
    return List.unmodifiable(starts.map(_spanAt));
  }

  DateEventSpan _spanAt(CalendarDate start) {
    if (span.end != null) {
      return DateEventSpan(start: start, end: start.addDays(span.dayCount));
    }
    return DateEventSpan(start: start, duration: span.duration);
  }

  @override
  bool operator ==(Object other) =>
      other is DateEventSeries &&
      recurrence == other.recurrence &&
      span == other.span;

  @override
  int get hashCode => Object.hash(recurrence, span);
}
