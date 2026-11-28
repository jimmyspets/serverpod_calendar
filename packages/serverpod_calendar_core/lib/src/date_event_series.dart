import 'calendar_date.dart';
import 'date_event_expansion.dart';
import 'date_event_span.dart';
import 'date_recurrence_set.dart';
import 'date_recurrence_generator.dart';

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
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    if (from.compareTo(until) >= 0) {
      throw ArgumentError('from must precede until');
    }
    // For a fixed positive L-day span, overlap is equivalent to a start in
    // [from - (L - 1), until - 1]. Every selected start therefore overlaps.
    final starts = recurrence.expand(
      from: dateEventLookback(span, from),
      through: until.addDays(-1),
      maxCandidateDays: maxCandidateDays,
      maxRuleOccurrences: maxRuleOccurrences,
      maxResults: maxResults,
      sharedWorkBudget: sharedWorkBudget,
    );
    return List.unmodifiable(
      starts.map((start) => dateEventSpanAt(span, start)),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DateEventSeries &&
      recurrence == other.recurrence &&
      span == other.span;

  @override
  int get hashCode => Object.hash(recurrence, span);
}
