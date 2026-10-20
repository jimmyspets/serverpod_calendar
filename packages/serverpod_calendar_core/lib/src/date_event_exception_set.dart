import 'calendar_date.dart';
import 'date_event_exception.dart';
import 'date_event_expansion.dart';
import 'date_event_occurrence.dart';
import 'date_event_series.dart';
import 'date_recurrence_generator.dart';
import 'date_recurrence_rule.dart';

/// Validated single-occurrence DATE exceptions for one immutable series.
///
/// Targets must belong to the effective DTSTART/RRULE/RDATE minus EXDATE set.
/// This native policy rejects excluded/orphan targets; no import reconciliation,
/// THISANDFUTURE, task, persistence or authorization behavior is implied.
final class DateEventExceptionSet {
  /// Checks all targets together with one shared bounded recurrence expansion.
  /// Raw input count is checked before copying; duplicate targets are rejected.
  factory DateEventExceptionSet({
    required DateEventSeries series,
    required List<DateEventException> exceptions,
    required int maxExceptions,
    required int maxValidationCandidateDays,
    required int maxValidationRuleOccurrences,
    required int maxValidationResults,
  }) {
    _budget(maxExceptions, 'maxExceptions', minimum: 0);
    _budget(maxValidationCandidateDays, 'maxValidationCandidateDays');
    _budget(maxValidationRuleOccurrences, 'maxValidationRuleOccurrences');
    _budget(maxValidationResults, 'maxValidationResults');
    if (exceptions.length > maxExceptions) {
      throw const RecurrenceLimitException('maxExceptions');
    }
    final values = List<DateEventException>.of(exceptions)
      ..sort((a, b) => a.originalStart.compareTo(b.originalStart));
    for (var i = 1; i < values.length; i++) {
      if (values[i - 1].originalStart == values[i].originalStart) {
        throw ArgumentError('Duplicate exception target');
      }
    }
    if (values.isNotEmpty) {
      final Set<CalendarDate> members;
      try {
        members = series.recurrence
            .expand(
              from: values.first.originalStart,
              through: values.last.originalStart,
              maxCandidateDays: maxValidationCandidateDays,
              maxRuleOccurrences: maxValidationRuleOccurrences,
              maxResults: maxValidationResults,
            )
            .toSet();
      } on RecurrenceLimitException catch (error) {
        throw RecurrenceLimitException(switch (error.limit) {
          'maxCandidateDays' => 'maxValidationCandidateDays',
          'maxRuleOccurrences' => 'maxValidationRuleOccurrences',
          'maxResults' => 'maxValidationResults',
          _ => error.limit,
        });
      }
      if (values.any((value) => !members.contains(value.originalStart))) {
        throw ArgumentError('Exception target is not in the recurrence set');
      }
    }
    return DateEventExceptionSet._(series, List.unmodifiable(values));
  }

  DateEventExceptionSet._(this.series, this.exceptions)
    : _byOriginal = Map.unmodifiable({
        for (final value in exceptions) value.originalStart: value,
      });

  final DateEventSeries series;
  final List<DateEventException> exceptions;
  final Map<CalendarDate, DateEventException> _byOriginal;

  /// Returns actual-start order, breaking ties by original recurrence date.
  /// Complete replacement spans are considered independently of base lookback,
  /// so moved-in and lengthened occurrences cannot disappear from the query.
  /// [maxBaseOccurrences] caps selected base starts before exception suppression;
  /// [maxResults] caps final occurrences. Raw-rule/work caps retain their meaning.
  /// Any failure returns no partial successful list. Budgets must be host-trusted.
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
    final List<CalendarDate> starts;
    try {
      starts = series.recurrence.expand(
        from: dateEventLookback(series.span, from),
        through: until.addDays(-1),
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
    final result = <DateEventOccurrence>[];
    void add(DateEventOccurrence value) {
      if (result.length >= maxResults) {
        throw const RecurrenceLimitException('maxResults');
      }
      result.add(value);
    }

    for (final start in starts) {
      // Suppress the base before constructing its endpoint: a cancellation or
      // valid replacement can remove a base span that would otherwise overflow.
      if (_byOriginal.containsKey(start)) continue;
      add(
        DateEventOccurrence(
          originalStart: start,
          span: dateEventSpanAt(series.span, start),
        ),
      );
    }
    for (final value in exceptions) {
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
    if (other is! DateEventExceptionSet ||
        series != other.series ||
        exceptions.length != other.exceptions.length) {
      return false;
    }
    for (var i = 0; i < exceptions.length; i++) {
      if (exceptions[i] != other.exceptions[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(series, Object.hashAll(exceptions));
}
