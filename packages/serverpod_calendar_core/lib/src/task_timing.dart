import 'calendar_date.dart';
import 'calendar_duration.dart';
import 'date_recurrence_set.dart';
import 'date_recurrence_generator.dart';
import 'date_recurrence_rule.dart';
import 'timed_recurrence_set.dart';
import 'timed_value.dart';
import 'utc_arithmetic.dart';
import 'utc_window.dart';

/// Task dates are milestones, never an implicit occupied event interval.
/// An undated, start-only or due-only task is valid; DURATION requires DTSTART.
final class DateTaskTiming {
  DateTaskTiming({this.start, this.due, this.duration}) {
    start?.requireOrdinary('start');
    due?.requireOrdinary('due');
    if (due != null && duration != null) {
      throw ArgumentError('DUE and DURATION are exclusive');
    }
    if (duration != null &&
        (start == null || duration!.sign < 0 || duration!.isZero)) {
      throw ArgumentError('Task duration requires a start and positive units');
    }
    final finish = effectiveDue;
    finish?.requireOrdinary('effectiveDue');
    if (start != null && finish != null && finish.compareTo(start!) <= 0) {
      throw ArgumentError('DUE must follow DTSTART');
    }
  }
  final CalendarDate? start, due;
  final CalendarDuration? duration;
  CalendarDate? get effectiveDue => due ?? duration?.addToDate(start!);
  DateTaskTiming at(CalendarDate occurrenceStart) {
    if (start == null) throw StateError('Recurrence requires DTSTART');
    return DateTaskTiming(
      start: occurrenceStart,
      due: due == null ? null : occurrenceStart.addDays(start!.daysUntil(due!)),
      duration: duration,
    );
  }

  /// Start-based query, with the recurrence set's original identities/budgets.
  List<DateTaskOccurrence> expandStarts(
    DateRecurrenceSet recurrence, {
    required CalendarDate from,
    required CalendarDate through,
    required int maxCandidateDays,
    required int maxRuleOccurrences,
    required int maxResults,
    Map<CalendarDate, DateTaskTiming> replacements = const {},
    int maxReplacements = 1000,
  }) {
    if (start == null || recurrence.start != start) {
      throw ArgumentError('Recurring task needs matching DTSTART');
    }
    if (replacements.isNotEmpty) {
      return _dateTaskReplacements(
        this,
        recurrence,
        replacements,
        from: from,
        through: through,
        maxCandidateDays: maxCandidateDays,
        maxRuleOccurrences: maxRuleOccurrences,
        maxResults: maxResults,
        maxReplacements: maxReplacements,
      );
    }
    return List.unmodifiable(
      recurrence
          .expand(
            from: from,
            through: through,
            maxCandidateDays: maxCandidateDays,
            maxRuleOccurrences: maxRuleOccurrences,
            maxResults: maxResults,
          )
          .map((v) => DateTaskOccurrence(v, at(v))),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DateTaskTiming &&
      start == other.start &&
      due == other.due &&
      duration == other.duration;
  @override
  int get hashCode => Object.hash(start, due, duration);
}

final class DateTaskOccurrence {
  const DateTaskOccurrence(this.originalStart, this.timing);
  final CalendarDate originalStart;
  final DateTaskTiming timing;
}

/// UTC/zoned task milestones, preserving explicit DUE versus nominal DURATION.
final class TimedTaskTiming {
  TimedTaskTiming({this.start, this.due, this.duration}) {
    start?.civil.date.requireOrdinary('start');
    due?.civil.date.requireOrdinary('due');
    if (due != null && duration != null) {
      throw ArgumentError('DUE and DURATION are exclusive');
    }
    if (start != null && due != null && !start!.sameProfile(due!)) {
      throw ArgumentError('DUE profile mismatch');
    }
    if (duration != null &&
        (start == null || duration!.sign < 0 || duration!.isZero)) {
      throw ArgumentError('Task duration requires a start and positive units');
    }
    final finish = effectiveDue;
    if (finish != null) {
      final zoneId = start?.zoneId ?? due?.zoneId;
      if (zoneId != null) {
        validateZonedInstant(finish, zoneId, allowExclusiveEnd: false);
      } else {
        TimedValue.utc(finish);
      }
    }
    if (start != null && finish != null && !finish.isAfter(start!.instant)) {
      throw ArgumentError('DUE must follow DTSTART');
    }
  }
  final TimedValue? start, due;
  final CalendarDuration? duration;
  DateTime? get effectiveDue =>
      due?.instant ?? (duration == null ? null : start!.add(duration!));

  /// Original explicit DUE propagates exact elapsed length; duration units stay
  /// nominal. The resolved due instant can retain a later-fold identity.
  TimedTaskProjection at(TimedValue occurrenceStart) {
    occurrenceStart.civil.date.requireOrdinary("occurrenceStart");
    if (start == null) throw StateError('Recurrence requires DTSTART');
    if (!start!.sameProfile(occurrenceStart)) {
      throw ArgumentError('Recurrence profile mismatch');
    }
    final finish = duration != null
        ? occurrenceStart.add(duration!)
        : due == null
        ? null
        : utcFromMicroseconds(
            utcMicroseconds(occurrenceStart.instant) +
                utcMicroseconds(due!.instant) -
                utcMicroseconds(start!.instant),
          );
    if (finish != null) {
      if (occurrenceStart.zoneId != null) {
        validateZonedInstant(
          finish,
          occurrenceStart.zoneId!,
          allowExclusiveEnd: false,
        );
      } else {
        TimedValue.utc(finish);
      }
    }
    return TimedTaskProjection(occurrenceStart, finish);
  }

  List<TimedTaskOccurrence> expandStarts(
    TimedRecurrenceSet recurrence, {
    required UtcWindow window,
    required int maxCandidateWork,
    required int maxRuleOccurrences,
    required int maxResults,
    Map<TimedValue, TimedTaskTiming> replacements = const {},
    int maxReplacements = 1000,
  }) {
    if (start == null || recurrence.start != start) {
      throw ArgumentError('Recurring task needs matching DTSTART');
    }
    if (recurrence.periods.isNotEmpty) {
      throw ArgumentError(
        'PERIOD RDATE is an event profile; not a task due override',
      );
    }
    if (replacements.isNotEmpty) {
      return _timedTaskReplacements(
        this,
        recurrence,
        replacements,
        window: window,
        maxCandidateWork: maxCandidateWork,
        maxRuleOccurrences: maxRuleOccurrences,
        maxResults: maxResults,
        maxReplacements: maxReplacements,
      );
    }
    return List.unmodifiable(
      recurrence
          .expand(
            window: window,
            maxCandidateWork: maxCandidateWork,
            maxRuleOccurrences: maxRuleOccurrences,
            maxResults: maxResults,
          )
          .map((v) => TimedTaskOccurrence(v, at(v))),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TimedTaskTiming &&
      start == other.start &&
      due == other.due &&
      duration == other.duration;
  @override
  int get hashCode => Object.hash(start, due, duration);
}

final class TimedTaskProjection {
  const TimedTaskProjection(this.start, this.dueInstant);
  final TimedValue start;
  final DateTime? dueInstant;
}

final class TimedTaskOccurrence {
  const TimedTaskOccurrence(this.originalStart, this.timing);
  final TimedValue originalStart;
  final TimedTaskProjection timing;
}

void _taskReplacementLimits(int size, int maxReplacements, int maxResults) {
  RangeError.checkValueInInterval(
    maxReplacements,
    0,
    DateRecurrenceRule.maxScalar,
    'maxReplacements',
  );
  RangeError.checkValueInInterval(
    maxResults,
    1,
    DateRecurrenceRule.maxScalar,
    'maxResults',
  );
  if (size > maxReplacements) {
    throw const RecurrenceLimitException('maxReplacements');
  }
}

List<DateTaskOccurrence> _dateTaskReplacements(
  DateTaskTiming master,
  DateRecurrenceSet recurrence,
  Map<CalendarDate, DateTaskTiming> input, {
  required CalendarDate from,
  required CalendarDate through,
  required int maxCandidateDays,
  required int maxRuleOccurrences,
  required int maxResults,
  required int maxReplacements,
}) {
  _taskReplacementLimits(input.length, maxReplacements, maxResults);
  final replacements = Map<CalendarDate, DateTaskTiming>.unmodifiable(input);
  final anchors = replacements.keys.toList()..sort();
  if (replacements.values.any((v) => v.start == null)) {
    throw ArgumentError('Replacement requires start');
  }
  final budget = RecurrenceWorkBudget(maxWork: maxCandidateDays);
  final found = recurrence
      .expand(
        from: anchors.first,
        through: anchors.last,
        maxCandidateDays: maxCandidateDays,
        maxRuleOccurrences: maxRuleOccurrences,
        maxResults: maxRuleOccurrences,
        sharedWorkBudget: budget,
      )
      .toSet();
  if (!found.containsAll(anchors)) {
    throw ArgumentError('Orphan task timing replacement');
  }
  final base = recurrence.expand(
    from: from,
    through: through,
    maxCandidateDays: maxCandidateDays,
    maxRuleOccurrences: maxRuleOccurrences,
    maxResults: maxRuleOccurrences,
    sharedWorkBudget: budget,
  );
  final result =
      <DateTaskOccurrence>[
        for (final original in base)
          if (!replacements.containsKey(original))
            DateTaskOccurrence(original, master.at(original)),
        for (final entry in replacements.entries)
          if (entry.value.start!.compareTo(from) >= 0 &&
              entry.value.start!.compareTo(through) <= 0)
            DateTaskOccurrence(entry.key, entry.value),
      ]..sort((a, b) {
        final c = a.timing.start!.compareTo(b.timing.start!);
        return c == 0 ? a.originalStart.compareTo(b.originalStart) : c;
      });
  if (result.length > maxResults) {
    throw const RecurrenceLimitException('maxResults');
  }
  return List.unmodifiable(result);
}

List<TimedTaskOccurrence> _timedTaskReplacements(
  TimedTaskTiming master,
  TimedRecurrenceSet recurrence,
  Map<TimedValue, TimedTaskTiming> input, {
  required UtcWindow window,
  required int maxCandidateWork,
  required int maxRuleOccurrences,
  required int maxResults,
  required int maxReplacements,
}) {
  _taskReplacementLimits(input.length, maxReplacements, maxResults);
  final replacements = Map<TimedValue, TimedTaskTiming>.unmodifiable(input);
  for (final e in replacements.entries) {
    if (e.value.start == null ||
        !master.start!.sameProfile(e.key) ||
        !master.start!.sameProfile(e.value.start!)) {
      throw ArgumentError('Replacement profile mismatch');
    }
  }
  final anchors = replacements.keys.toList()
    ..sort((a, b) => a.instant.compareTo(b.instant));
  final budget = RecurrenceWorkBudget(maxWork: maxCandidateWork);
  final found = recurrence
      .expand(
        window: UtcWindow(
          start: anchors.first.instant,
          end: anchors.last.instant.add(const Duration(seconds: 1)),
        ),
        maxCandidateWork: maxCandidateWork,
        maxRuleOccurrences: maxRuleOccurrences,
        maxResults: maxRuleOccurrences,
        sharedWorkBudget: budget,
      )
      .toSet();
  if (!found.containsAll(anchors)) {
    throw ArgumentError('Orphan task timing replacement');
  }
  final base = recurrence.expand(
    window: window,
    maxCandidateWork: maxCandidateWork,
    maxRuleOccurrences: maxRuleOccurrences,
    maxResults: maxRuleOccurrences,
    sharedWorkBudget: budget,
  );
  final result =
      <TimedTaskOccurrence>[
        for (final original in base)
          if (!replacements.containsKey(original))
            TimedTaskOccurrence(original, master.at(original)),
        for (final e in replacements.entries)
          if (!e.value.start!.instant.isBefore(window.start) &&
              e.value.start!.instant.isBefore(window.end))
            TimedTaskOccurrence(
              e.key,
              TimedTaskProjection(e.value.start!, e.value.effectiveDue),
            ),
      ]..sort((a, b) {
        final c = a.timing.start.instant.compareTo(b.timing.start.instant);
        return c == 0 ? a.originalStart.compareTo(b.originalStart) : c;
      });
  if (result.length > maxResults) {
    throw const RecurrenceLimitException('maxResults');
  }
  return List.unmodifiable(result);
}
