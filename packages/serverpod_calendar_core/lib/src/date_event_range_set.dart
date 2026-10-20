import 'calendar_date.dart';
import 'date_event_exception.dart';
import 'date_event_exception_set.dart';
import 'date_event_expansion.dart';
import 'date_event_occurrence.dart';
import 'date_event_range_change.dart';
import 'date_event_span.dart';
import 'date_recurrence_generator.dart';
import 'date_recurrence_rule.dart';

/// Bounded native DATE timing ranges layered over single-occurrence exceptions.
/// Anchors and subsequent order use original dates, never actual start order.
/// No rule rewriting, range cancellation, tasks or wire/storage behavior.
final class DateEventRangeSet {
  factory DateEventRangeSet({
    required DateEventExceptionSet base,
    required List<DateEventRangeChange> changes,
    required int maxRangeChanges,
    required int maxValidationCandidateDays,
    required int maxValidationRuleOccurrences,
    required int maxValidationResults,
  }) {
    _budget(maxRangeChanges, 'maxRangeChanges', minimum: 0);
    _budget(maxValidationCandidateDays, 'maxValidationCandidateDays');
    _budget(maxValidationRuleOccurrences, 'maxValidationRuleOccurrences');
    _budget(maxValidationResults, 'maxValidationResults');
    if (changes.length > maxRangeChanges) {
      throw const RecurrenceLimitException('maxRangeChanges');
    }
    final values = List<DateEventRangeChange>.of(changes)
      ..sort((a, b) => a.originalStart.compareTo(b.originalStart));
    // Reuse the same native effective-set membership/duplicate checks in one
    // shared expansion. These synthetic cancellations are validation only.
    DateEventExceptionSet(
      series: base.series,
      exceptions: [
        for (final value in values)
          DateEventException.cancel(originalStart: value.originalStart),
      ],
      maxExceptions: maxRangeChanges,
      maxValidationCandidateDays: maxValidationCandidateDays,
      maxValidationRuleOccurrences: maxValidationRuleOccurrences,
      maxValidationResults: maxValidationResults,
    );
    final singles = {for (final value in base.exceptions) value.originalStart};
    if (values.any((value) => singles.contains(value.originalStart))) {
      throw ArgumentError('Range and single exception share an anchor');
    }
    return DateEventRangeSet._(base, List.unmodifiable(values));
  }

  const DateEventRangeSet._(this.base, this.changes);

  final DateEventExceptionSet base;
  final List<DateEventRangeChange> changes;

  /// Queries complete occurrences in actual-start/original-date order.
  /// Each range uses an absolute shift from its original anchor until the next
  /// original anchor. Separately overridden instances retain their own spans.
  /// One envelope of inverse query ranges shares all recurrence budgets;
  /// intervening candidates consume raw/base capacity even if filtered later.
  List<DateEventOccurrence> expandOverlapping({
    required CalendarDate from,
    required CalendarDate until,
    required int maxCandidateDays,
    required int maxRuleOccurrences,
    required int maxBaseOccurrences,
    required int maxResults,
  }) {
    _budget(maxCandidateDays, 'maxCandidateDays');
    _budget(maxRuleOccurrences, 'maxRuleOccurrences');
    _budget(maxBaseOccurrences, 'maxBaseOccurrences');
    _budget(maxResults, 'maxResults');
    if (from.compareTo(until) >= 0) {
      throw ArgumentError('from must precede until');
    }
    final first = CalendarDate(year: 1970, month: 1, day: 1);
    final last = first.daysUntil(CalendarDate(year: 2099, month: 12, day: 31));
    final lowerQuery = first.daysUntil(from);
    final upperQuery = first.daysUntil(until);
    final segments = <_RangeSegment>[];
    for (var i = 0; i <= changes.length; i++) {
      final change = i == 0 ? null : changes[i - 1];
      segments.add(
        _RangeSegment(
          lower: change == null ? 0 : first.daysUntil(change.originalStart),
          upper: i == changes.length
              ? last
              : first.daysUntil(changes[i].originalStart) - 1,
          shift: change?.dayShift ?? 0,
          template: change?.replacement ?? base.series.span,
        ),
      );
    }
    int? envelopeLower;
    int? envelopeUpper;
    for (final segment in segments) {
      var lower = lowerQuery - (segment.template.dayCount - 1) - segment.shift;
      var upper = upperQuery - 1 - segment.shift;
      if (lower < segment.lower) lower = segment.lower;
      if (upper > segment.upper) upper = segment.upper;
      if (lower > upper) continue;
      if (envelopeLower == null || lower < envelopeLower) envelopeLower = lower;
      if (envelopeUpper == null || upper > envelopeUpper) envelopeUpper = upper;
    }
    final List<CalendarDate> starts;
    if (envelopeLower == null) {
      starts = const [];
    } else {
      try {
        starts = base.series.recurrence.expand(
          from: first.addDays(envelopeLower),
          through: first.addDays(envelopeUpper!),
          maxCandidateDays: maxCandidateDays,
          maxRuleOccurrences: maxRuleOccurrences,
          maxResults: maxBaseOccurrences,
        );
      } on RecurrenceLimitException catch (error) {
        if (error.limit == 'maxResults') {
          throw const RecurrenceLimitException('maxBaseOccurrences');
        }
        rethrow;
      }
    }
    final singles = {
      for (final value in base.exceptions) value.originalStart: value,
    };
    final result = <DateEventOccurrence>[];
    void add(DateEventOccurrence occurrence) {
      if (result.length >= maxResults) {
        throw const RecurrenceLimitException('maxResults');
      }
      result.add(occurrence);
    }

    var index = 0;
    for (final start in starts) {
      if (singles.containsKey(start)) continue;
      final original = first.daysUntil(start);
      while (index + 1 < segments.length &&
          original >= segments[index + 1].lower) {
        index++;
      }
      final segment = segments[index];
      final actual = original + segment.shift;
      final end = actual + segment.template.dayCount;
      // Envelope gaps may contain candidates not overlapping under their own
      // active segment. Do not materialize unrelated out-of-profile endpoints.
      if (actual >= upperQuery || end <= lowerQuery) continue;
      add(
        DateEventOccurrence(
          originalStart: start,
          span: dateEventSpanAt(segment.template, first.addDays(actual)),
        ),
      );
    }
    for (final value in base.exceptions) {
      final replacement = value.replacement;
      if (replacement == null ||
          replacement.start.compareTo(until) >= 0 ||
          replacement.endExclusive.compareTo(from) <= 0) {
        continue;
      }
      add(
        DateEventOccurrence(
          originalStart: value.originalStart,
          span: replacement,
        ),
      );
    }
    result.sort((a, b) {
      final actual = a.span.start.compareTo(b.span.start);
      return actual != 0 ? actual : a.originalStart.compareTo(b.originalStart);
    });
    return List.unmodifiable(result);
  }

  static void _budget(int value, String name, {int minimum = 1}) =>
      RangeError.checkValueInInterval(
        value,
        minimum,
        DateRecurrenceRule.maxScalar,
        name,
      );

  @override
  bool operator ==(Object other) {
    if (other is! DateEventRangeSet ||
        base != other.base ||
        changes.length != other.changes.length) {
      return false;
    }
    for (var i = 0; i < changes.length; i++) {
      if (changes[i] != other.changes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(base, Object.hashAll(changes));
}

final class _RangeSegment {
  const _RangeSegment({
    required this.lower,
    required this.upper,
    required this.shift,
    required this.template,
  });
  final int lower;
  final int upper;
  final int shift;
  final DateEventSpan template;
}
