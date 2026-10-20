import 'date_recurrence_generator.dart';
import 'date_recurrence_rule.dart';
import 'timed_event_span.dart';
import 'timed_recurrence.dart';
import 'timed_value.dart';
import 'utc_window.dart';

/// DTSTART/RRULE union RDATE minus EXDATE. PERIOD additions preserve their span.
/// All identities must use the exact master profile, including its zone alias.
final class TimedRecurrenceSet {
  TimedRecurrenceSet({
    required this.start,
    this.rule,
    List<TimedValue> inclusions = const [],
    List<TimedValue> exclusions = const [],
    List<TimedEventSpan> periods = const [],
    required int maxExplicitDates,
  }) {
    RangeError.checkValueInInterval(
      maxExplicitDates,
      0,
      DateRecurrenceRule.maxScalar,
      'maxExplicitDates',
    );
    if (inclusions.length + exclusions.length + periods.length >
        maxExplicitDates) {
      throw const RecurrenceLimitException('maxExplicitDates');
    }
    for (final value in [
      ...inclusions,
      ...exclusions,
      ...periods.map((p) => p.start),
    ]) {
      if (!start.sameProfile(value)) {
        throw ArgumentError('Mixed recurrence profiles');
      }
    }
    final byStart = <TimedValue, TimedEventSpan>{};
    for (final p in periods) {
      if (p.isPoint) {
        throw ArgumentError('RDATE PERIOD must have positive length');
      }
      if (byStart.containsKey(p.start) && byStart[p.start] != p) {
        throw ArgumentError('Conflicting PERIOD additions');
      }
      byStart[p.start] = p;
    }
    this.inclusions = List.unmodifiable(inclusions.toSet().toList()..sort());
    this.exclusions = Set.unmodifiable(exclusions);
    this.periods = Map.unmodifiable(byStart);
  }
  final TimedValue start;
  final TimedRecurrenceRule? rule;
  late final List<TimedValue> inclusions;
  late final Set<TimedValue> exclusions;
  late final Map<TimedValue, TimedEventSpan> periods;

  /// Budgets apply before exclusions and to the final union separately.
  List<TimedValue> expand({
    required UtcWindow window,
    required int maxCandidateWork,
    required int maxRuleOccurrences,
    required int maxResults,
  }) {
    for (final e in {
      'maxCandidateWork': maxCandidateWork,
      'maxRuleOccurrences': maxRuleOccurrences,
    }.entries) {
      RangeError.checkValueInInterval(
        e.value,
        1,
        DateRecurrenceRule.maxScalar,
        e.key,
      );
    }
    final values = <TimedValue>{};
    if (rule == null) {
      if (window.contains(start.instant)) values.add(start);
    } else {
      try {
        values.addAll(
          TimedRecurrenceGenerator().expand(
            start: start,
            rule: rule!,
            window: window,
            maxCandidateWork: maxCandidateWork,
            maxResults: maxRuleOccurrences,
          ),
        );
      } on RecurrenceLimitException catch (e) {
        if (e.limit == 'maxResults') {
          throw const RecurrenceLimitException('maxRuleOccurrences');
        }
        rethrow;
      }
    }
    for (final v in [...inclusions, ...periods.keys]) {
      if (window.contains(v.instant)) values.add(v);
    }
    RangeError.checkValueInInterval(
      maxResults,
      1,
      DateRecurrenceRule.maxScalar,
      'maxResults',
    );
    values.removeAll(exclusions);
    if (values.length > maxResults) {
      throw const RecurrenceLimitException('maxResults');
    }
    return List.unmodifiable(
      values.toList()..sort((a, b) {
        final order = a.instant.compareTo(b.instant);
        return order == 0 ? a.compareTo(b) : order;
      }),
    );
  }
}
