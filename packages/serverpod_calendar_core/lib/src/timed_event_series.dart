import 'date_recurrence_generator.dart';
import 'date_recurrence_rule.dart';
import 'named_zone_resolver.dart';
import 'timed_event_span.dart';
import 'timed_recurrence_set.dart';
import 'timed_value.dart';
import 'utc_arithmetic.dart';
import 'utc_event_span.dart';
import 'utc_window.dart';

/// One original identity and its resolved effective span, local to this series.
final class TimedEventOccurrence {
  const TimedEventOccurrence({
    required this.originalStart,
    required this.actualStart,
    required this.span,
  });
  final TimedValue originalStart;
  final TimedValue actualStart;
  final UtcEventSpan span;
}

final class TimedEventException {
  const TimedEventException.cancel(this.originalStart) : replacement = null;
  const TimedEventException.replace(this.originalStart, TimedEventSpan span)
    : replacement = span;
  final TimedValue originalStart;
  final TimedEventSpan? replacement;
}

/// Absolute civil shift from this original anchor, plus replacement span form.
/// Subsequent changes replace the active shift; shifts are not compounded.
final class TimedEventRangeChange {
  TimedEventRangeChange({
    required this.originalStart,
    required this.replacement,
  }) {
    if (!originalStart.sameProfile(replacement.start)) {
      throw ArgumentError('Range profile mismatch');
    }
  }
  final TimedValue originalStart;
  final TimedEventSpan replacement;
  BigInt get civilShift =>
      utcMicroseconds(civilEncoding(replacement.start.civil)) -
      utcMicroseconds(civilEncoding(originalStart.civil));
}

/// Native bounded timed series. Single overrides take precedence over ranges.
/// Construction validates all anchors in one shared bounded membership scan.
final class TimedEventSeries {
  TimedEventSeries({
    required this.recurrence,
    required this.span,
    List<TimedEventException> exceptions = const [],
    List<TimedEventRangeChange> changes = const [],
    required int maxChanges,
    required int maxValidationCandidateWork,
    required int maxValidationOccurrences,
  }) {
    if (span.start != recurrence.start) {
      throw ArgumentError('Master starts differ');
    }
    RangeError.checkValueInInterval(
      maxChanges,
      0,
      DateRecurrenceRule.maxScalar,
      'maxChanges',
    );
    if (exceptions.length + changes.length > maxChanges) {
      throw const RecurrenceLimitException('maxChanges');
    }
    for (final e in {
      'maxValidationCandidateWork': maxValidationCandidateWork,
      'maxValidationOccurrences': maxValidationOccurrences,
    }.entries) {
      RangeError.checkValueInInterval(
        e.value,
        1,
        DateRecurrenceRule.maxScalar,
        e.key,
      );
    }
    final anchors = <TimedValue>{};
    for (final e in exceptions) {
      if (!anchors.add(e.originalStart)) {
        throw ArgumentError('Duplicate exception anchor');
      }
      if (e.replacement != null &&
          !span.start.sameProfile(e.replacement!.start)) {
        throw ArgumentError('Replacement profile mismatch');
      }
    }
    for (final c in changes) {
      if (!anchors.add(c.originalStart)) {
        throw ArgumentError('Duplicate or ambiguous range anchor');
      }
    }
    for (final a in anchors) {
      if (!span.start.sameProfile(a)) {
        throw ArgumentError('Anchor profile mismatch');
      }
    }
    if (anchors.isNotEmpty) {
      final times = anchors.map((a) => a.instant).toList()..sort();
      final effective = recurrence
          .expand(
            window: UtcWindow(
              start: times.first,
              end: times.last.add(const Duration(microseconds: 1)),
            ),
            maxCandidateWork: maxValidationCandidateWork,
            maxRuleOccurrences: maxValidationOccurrences,
            maxResults: maxValidationOccurrences,
          )
          .toSet();
      if (!anchors.every(effective.contains)) {
        throw ArgumentError('Orphan or excluded recurrence anchor');
      }
    }
    this.exceptions = Map.unmodifiable({
      for (final e in exceptions) e.originalStart: e,
    });
    this.changes = List.unmodifiable(
      changes.toList()
        ..sort((a, b) => a.originalStart.compareTo(b.originalStart)),
    );
  }
  final TimedRecurrenceSet recurrence;
  final TimedEventSpan span;
  late final Map<TimedValue, TimedEventException> exceptions;
  late final List<TimedEventRangeChange> changes;

  /// Scans original history once, including pre-query candidates, under shared
  /// caps. Conservative inverse range bounds include future originals moved in.
  /// No process-local cache, truncation or partial coverage result is returned.
  List<TimedEventOccurrence> expandOverlapping({
    required UtcWindow window,
    required int maxCandidateWork,
    required int maxRuleOccurrences,
    required int maxBaseOccurrences,
    required int maxResults,
  }) {
    for (final e in {
      'maxBaseOccurrences': maxBaseOccurrences,
      'maxResults': maxResults,
    }.entries) {
      RangeError.checkValueInInterval(
        e.value,
        1,
        DateRecurrenceRule.maxScalar,
        e.key,
      );
    }
    var inverse = BigInt.zero;
    for (final c in changes) {
      if (-c.civilShift > inverse) inverse = -c.civilShift;
    }
    if (changes.isNotEmpty && span.start.zoneId != null) {
      final resolver = NamedZoneResolver();
      inverse += BigInt.from(
        resolver.offsetRange(zoneId: span.start.zoneId!).inMicroseconds,
      );
    }
    var upper = utcFromMicroseconds(utcMicroseconds(window.end) + inverse);
    if (!upper.isAfter(recurrence.start.instant)) {
      upper = recurrence.start.instant.add(const Duration(microseconds: 1));
    }
    // Include all earlier explicit additions separately, including before DTSTART.
    var lower = recurrence.start.instant;
    if (span.start.zoneId != null) {
      lower = lower.subtract(
        NamedZoneResolver().offsetRange(zoneId: span.start.zoneId!),
      );
    }
    for (final v in [...recurrence.inclusions, ...recurrence.periods.keys]) {
      if (v.instant.isBefore(lower)) lower = v.instant;
    }
    late final List<TimedValue> originals;
    try {
      originals = recurrence.expand(
        window: UtcWindow(start: lower, end: upper),
        maxCandidateWork: maxCandidateWork,
        maxRuleOccurrences: maxRuleOccurrences,
        maxResults: maxBaseOccurrences,
      );
    } on RecurrenceLimitException catch (e) {
      if (e.limit == 'maxResults') {
        throw const RecurrenceLimitException('maxBaseOccurrences');
      }
      rethrow;
    }
    final result = <TimedEventOccurrence>[];
    void add(TimedValue identity, TimedValue actual, UtcEventSpan projection) {
      if (!projection.occursIn(window)) return;
      if (result.length >= maxResults) {
        throw const RecurrenceLimitException('maxResults');
      }
      result.add(
        TimedEventOccurrence(
          originalStart: identity,
          actualStart: actual,
          span: projection,
        ),
      );
    }

    for (final original in originals) {
      if (exceptions.containsKey(original)) continue;
      TimedEventRangeChange? active;
      for (final c in changes) {
        if (c.originalStart.compareTo(original) > 0) break;
        active = c;
      }
      final template =
          active?.replacement ?? recurrence.periods[original] ?? span;
      final actual = active == null
          ? original
          : original.at(
              civilFields(
                utcFromMicroseconds(
                  utcMicroseconds(civilEncoding(original.civil)) +
                      active.civilShift,
                ),
              ),
            );
      if (!actual.instant.isBefore(window.end)) continue;
      add(original, actual, template.projectAt(actual));
    }
    // An overridden occurrence can move into the query from either direction.
    for (final e in exceptions.values) {
      if (e.replacement != null) {
        add(e.originalStart, e.replacement!.start, e.replacement!.resolved);
      }
    }
    result.sort((a, b) {
      final order = a.span.start.compareTo(b.span.start);
      return order == 0 ? a.originalStart.compareTo(b.originalStart) : order;
    });
    return List.unmodifiable(result);
  }
}
