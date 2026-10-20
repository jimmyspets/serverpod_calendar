import 'calendar_date.dart';
import 'date_recurrence_generator.dart';
import 'date_recurrence_rule.dart';

/// Immutable DATE-only DTSTART/optional RRULE/RDATE/EXDATE values.
///
/// Explicit dates are sorted and deduplicated; exclusions take precedence.
/// This does not represent timed/PERIOD inclusions or moved overrides.
final class DateRecurrenceSet {
  /// Snapshots explicit dates after checking their combined raw input count.
  ///
  /// Duplicates and out-of-query dates consume [maxExplicitDates] too. Zero
  /// permits no explicit dates. The host must choose a trusted practical cap.
  factory DateRecurrenceSet({
    required CalendarDate start,
    DateRecurrenceRule? rule,
    List<CalendarDate> inclusions = const [],
    List<CalendarDate> exclusions = const [],
    required int maxExplicitDates,
  }) {
    start.requireOrdinary('DTSTART');
    RangeError.checkValueInInterval(
      maxExplicitDates,
      0,
      DateRecurrenceRule.maxScalar,
      'maxExplicitDates',
    );
    if (inclusions.length > maxExplicitDates ||
        exclusions.length > maxExplicitDates - inclusions.length) {
      throw const RecurrenceLimitException('maxExplicitDates');
    }
    for (final date in [...inclusions, ...exclusions]) {
      date.requireOrdinary();
    }
    return DateRecurrenceSet._(
      start,
      rule,
      _dates(inclusions),
      _dates(exclusions),
    );
  }

  const DateRecurrenceSet._(
    this.start,
    this.rule,
    this.inclusions,
    this.exclusions,
  );

  /// Retained even when EXDATE removes it from emitted dates.
  final CalendarDate start;
  final DateRecurrenceRule? rule;
  final List<CalendarDate> inclusions;
  final List<CalendarDate> exclusions;

  /// Returns unique sorted start dates in the inclusive query range.
  ///
  /// COUNT/UNTIL constrain only RRULE. RDATE can add dates outside those bounds
  /// or before DTSTART, without moving it. EXDATE does not replenish COUNT.
  /// [maxRuleOccurrences] bounds raw in-query rule output before exclusions;
  /// [maxResults] bounds final output. Any limit throws without partial output.
  List<CalendarDate> expand({
    required CalendarDate from,
    required CalendarDate through,
    required int maxCandidateDays,
    required int maxRuleOccurrences,
    required int maxResults,
  }) {
    RangeError.checkValueInInterval(
      maxCandidateDays,
      1,
      DateRecurrenceRule.maxScalar,
      'maxCandidateDays',
    );
    RangeError.checkValueInInterval(
      maxRuleOccurrences,
      1,
      DateRecurrenceRule.maxScalar,
      'maxRuleOccurrences',
    );
    RangeError.checkValueInInterval(
      maxResults,
      1,
      DateRecurrenceRule.maxScalar,
      'maxResults',
    );
    if (from.compareTo(through) > 0) {
      throw ArgumentError('from must not follow through');
    }
    final sourceRule = rule;
    final List<CalendarDate> ruleDates;
    if (sourceRule == null) {
      ruleDates = start.compareTo(from) >= 0 && start.compareTo(through) <= 0
          ? [start]
          : const [];
    } else {
      try {
        ruleDates = DateRecurrenceGenerator().expand(
          start: start,
          rule: sourceRule,
          from: from,
          through: through,
          maxCandidateDays: maxCandidateDays,
          maxResults: maxRuleOccurrences,
        );
      } on RecurrenceLimitException catch (error) {
        if (error.limit == 'maxResults') {
          throw const RecurrenceLimitException('maxRuleOccurrences');
        }
        rethrow;
      }
    }
    final excluded = exclusions.toSet();
    final result = <CalendarDate>[];
    var i = 0;
    var j = 0;
    // Merge bounded sorted sources without allocating their complete union.
    while (i < ruleDates.length || j < inclusions.length) {
      final CalendarDate date;
      if (i == ruleDates.length) {
        date = inclusions[j++];
      } else if (j == inclusions.length ||
          ruleDates[i].compareTo(inclusions[j]) < 0) {
        date = ruleDates[i++];
      } else {
        date = inclusions[j++];
        if (ruleDates[i] == date) i++;
      }
      if (date.compareTo(from) < 0) continue;
      if (date.compareTo(through) > 0) break;
      if (excluded.contains(date)) continue;
      if (result.length >= maxResults) {
        throw const RecurrenceLimitException('maxResults');
      }
      result.add(date);
    }
    return List.unmodifiable(result);
  }

  static List<CalendarDate> _dates(List<CalendarDate> values) =>
      List.unmodifiable(values.toSet().toList()..sort());

  @override
  bool operator ==(Object other) =>
      other is DateRecurrenceSet &&
      start == other.start &&
      rule == other.rule &&
      _same(inclusions, other.inclusions) &&
      _same(exclusions, other.exclusions);

  static bool _same(List<CalendarDate> a, List<CalendarDate> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    start,
    rule,
    Object.hashAll(inclusions),
    Object.hashAll(exclusions),
  );
}
