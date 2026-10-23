import 'calendar_date.dart';
import 'calendar_duration.dart';
import 'named_zone_resolver.dart';
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
  DateTaskTiming at(
    CalendarDate occurrenceStart, {
    Map<CalendarDate, DateTaskTiming> replacements = const {},
    Map<CalendarDate, DateTaskTiming> futureChanges = const {},
    int maxChanges = 1000,
  }) {
    occurrenceStart.requireOrdinary('occurrenceStart');
    if (start == null) {
      throw StateError('Recurrence requires DTSTART');
    }
    if (replacements.isNotEmpty || futureChanges.isNotEmpty) {
      _taskReplacementLimits(
        replacements.length + futureChanges.length,
        maxChanges,
        1,
      );
      if (replacements.keys.any(futureChanges.containsKey) ||
          [
            ...replacements.values,
            ...futureChanges.values,
          ].any((v) => v.start == null)) {
        throw ArgumentError('Invalid task timing maps');
      }
      for (final a in {...replacements.keys, ...futureChanges.keys}) {
        a.requireOrdinary('originalStart');
      }
      final single = replacements[occurrenceStart];
      if (single != null) {
        return single;
      }
      final anchors = futureChanges.keys.toList()..sort();
      CalendarDate? active;
      for (final a in anchors) {
        if (a.compareTo(occurrenceStart) > 0) {
          break;
        }
        active = a;
      }
      if (active != null) {
        return futureChanges[active]!.at(
          occurrenceStart.addDays(
            active.daysUntil(futureChanges[active]!.start!),
          ),
        );
      }
    }
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
    Map<CalendarDate, DateTaskTiming> futureChanges = const {},
    int maxReplacements = 1000,
  }) {
    if (start == null || recurrence.start != start) {
      throw ArgumentError('Recurring task needs matching DTSTART');
    }
    if (replacements.isNotEmpty || futureChanges.isNotEmpty) {
      return _dateTaskReplacements(
        this,
        recurrence,
        replacements,
        futureChanges,
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
  TimedTaskProjection at(
    TimedValue occurrenceStart, {
    Map<TimedValue, TimedTaskTiming> replacements = const {},
    Map<TimedValue, TimedTaskTiming> futureChanges = const {},
    int maxChanges = 1000,
  }) {
    occurrenceStart.civil.date.requireOrdinary("occurrenceStart");
    if (start == null) throw StateError('Recurrence requires DTSTART');
    if (!start!.sameProfile(occurrenceStart)) {
      throw ArgumentError('Recurrence profile mismatch');
    }
    if (replacements.isNotEmpty || futureChanges.isNotEmpty) {
      _taskReplacementLimits(
        replacements.length + futureChanges.length,
        maxChanges,
        1,
      );
      if (replacements.keys.any(futureChanges.containsKey)) {
        throw ArgumentError('Ambiguous timing anchor');
      }
      for (final e in [...replacements.entries, ...futureChanges.entries]) {
        e.key.civil.date.requireOrdinary('originalStart');
        if (e.value.start == null ||
            !start!.sameProfile(e.key) ||
            !start!.sameProfile(e.value.start!)) {
          throw ArgumentError('Timing map profile mismatch');
        }
      }
      final single = replacements[occurrenceStart];
      if (single != null) {
        return TimedTaskProjection(
          single.start!,
          single.effectiveDue,
          duration: single.duration,
        );
      }
      final anchors = futureChanges.keys.toList()..sort();
      TimedValue? active;
      for (final a in anchors) {
        if (a.compareTo(occurrenceStart) > 0) {
          break;
        }
        active = a;
      }
      if (active != null) {
        final template = futureChanges[active]!;
        final shift =
            utcMicroseconds(civilEncoding(template.start!.civil)) -
            utcMicroseconds(civilEncoding(active.civil));
        return template.at(
          occurrenceStart.at(
            civilFields(
              utcFromMicroseconds(
                utcMicroseconds(civilEncoding(occurrenceStart.civil)) + shift,
              ),
            ),
          ),
        );
      }
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
    return TimedTaskProjection(occurrenceStart, finish, duration: duration);
  }

  List<TimedTaskOccurrence> expandStarts(
    TimedRecurrenceSet recurrence, {
    required UtcWindow window,
    required int maxCandidateWork,
    required int maxRuleOccurrences,
    required int maxResults,
    Map<TimedValue, TimedTaskTiming> replacements = const {},
    Map<TimedValue, TimedTaskTiming> futureChanges = const {},
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
    if (replacements.isNotEmpty || futureChanges.isNotEmpty) {
      return _timedTaskReplacements(
        this,
        recurrence,
        replacements,
        futureChanges,
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
  const TimedTaskProjection(this.start, this.dueInstant, {this.duration});
  final CalendarDuration? duration;
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
  Map<CalendarDate, DateTaskTiming> input,
  Map<CalendarDate, DateTaskTiming> rangeInput, {
  required CalendarDate from,
  required CalendarDate through,
  required int maxCandidateDays,
  required int maxRuleOccurrences,
  required int maxResults,
  required int maxReplacements,
}) {
  from.requireOrdinary('from');
  through.requireOrdinary('through');
  if (from.compareTo(through) > 0) {
    throw ArgumentError('from must not follow through');
  }
  _taskReplacementLimits(
    input.length + rangeInput.length,
    maxReplacements,
    maxResults,
  );
  final replacements = Map<CalendarDate, DateTaskTiming>.unmodifiable(input);
  final ranges = Map<CalendarDate, DateTaskTiming>.unmodifiable(rangeInput);
  if (replacements.keys.any(ranges.containsKey)) {
    throw ArgumentError('Ambiguous task timing anchor');
  }
  final anchors = {...replacements.keys, ...ranges.keys}.toList()..sort();
  if ([...replacements.values, ...ranges.values].any((v) => v.start == null)) {
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
  final rangeAnchors = ranges.keys.toList()..sort();
  var minShift = 0, maxShift = 0;
  for (final e in ranges.entries) {
    final shift = e.key.daysUntil(e.value.start!);
    if (shift < minShift) {
      minShift = shift;
    }
    if (shift > maxShift) {
      maxShift = shift;
    }
  }
  final epoch = CalendarDate(year: 1970, month: 1, day: 1),
      last = CalendarDate(year: 2099, month: 12, day: 31);
  final fromIndex = epoch.daysUntil(from),
      throughIndex = epoch.daysUntil(through),
      lastIndex = epoch.daysUntil(last);
  final base = recurrence.expand(
    from: epoch.addDays((fromIndex - maxShift).clamp(0, lastIndex)),
    through: epoch.addDays((throughIndex - minShift).clamp(0, lastIndex)),
    maxCandidateDays: maxCandidateDays,
    maxRuleOccurrences: maxRuleOccurrences,
    maxResults: maxRuleOccurrences,
    sharedWorkBudget: budget,
  );
  final result = <DateTaskOccurrence>[];
  for (final original in base) {
    if (replacements.containsKey(original)) {
      continue;
    }
    CalendarDate? active;
    for (final a in rangeAnchors) {
      if (a.compareTo(original) > 0) {
        break;
      }
      active = a;
    }
    final shift = active == null ? 0 : active.daysUntil(ranges[active]!.start!);
    final actualIndex = epoch.daysUntil(original) + shift;
    if (actualIndex < fromIndex || actualIndex > throughIndex) {
      continue;
    }
    result.add(
      DateTaskOccurrence(
        original,
        (active == null ? master : ranges[active]!).at(
          epoch.addDays(actualIndex),
        ),
      ),
    );
  }
  for (final e in replacements.entries) {
    if (e.value.start!.compareTo(from) >= 0 &&
        e.value.start!.compareTo(through) <= 0) {
      result.add(DateTaskOccurrence(e.key, e.value));
    }
  }
  result.sort((a, b) {
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
  Map<TimedValue, TimedTaskTiming> input,
  Map<TimedValue, TimedTaskTiming> rangeInput, {
  required UtcWindow window,
  required int maxCandidateWork,
  required int maxRuleOccurrences,
  required int maxResults,
  required int maxReplacements,
}) {
  _taskReplacementLimits(
    input.length + rangeInput.length,
    maxReplacements,
    maxResults,
  );
  final replacements = Map<TimedValue, TimedTaskTiming>.unmodifiable(input);
  final ranges = Map<TimedValue, TimedTaskTiming>.unmodifiable(rangeInput);
  if (replacements.keys.any(ranges.containsKey)) {
    throw ArgumentError('Ambiguous task timing anchor');
  }
  for (final e in [...replacements.entries, ...ranges.entries]) {
    if (e.value.start == null ||
        !master.start!.sameProfile(e.key) ||
        !master.start!.sameProfile(e.value.start!)) {
      throw ArgumentError('Replacement profile mismatch');
    }
  }
  final anchors = {...replacements.keys, ...ranges.keys}.toList()
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
  final rangeAnchors = ranges.keys.toList()..sort();
  BigInt shift(TimedValue a) =>
      utcMicroseconds(civilEncoding(ranges[a]!.start!.civil)) -
      utcMicroseconds(civilEncoding(a.civil));
  var minShift = BigInt.zero, maxShift = BigInt.zero;
  for (final a in rangeAnchors) {
    final d = shift(a);
    if (d < minShift) {
      minShift = d;
    }
    if (d > maxShift) {
      maxShift = d;
    }
  }
  final guard = ranges.isEmpty || master.start!.zoneId == null
      ? BigInt.zero
      : BigInt.from(
          NamedZoneResolver()
              .offsetRange(zoneId: master.start!.zoneId!)
              .inMicroseconds,
        );
  var lower = utcMicroseconds(window.start) - maxShift - guard,
      upper = utcMicroseconds(window.end) - minShift + guard;
  final low = utcMicroseconds(DateTime.utc(1969, 12, 30)),
      high = utcMicroseconds(DateTime.utc(2100, 1, 3));
  if (lower < low) {
    lower = low;
  }
  if (upper > high) {
    upper = high;
  }
  final base = recurrence.expand(
    window: UtcWindow(
      start: utcFromMicroseconds(lower),
      end: utcFromMicroseconds(upper),
    ),
    maxCandidateWork: maxCandidateWork,
    maxRuleOccurrences: maxRuleOccurrences,
    maxResults: maxRuleOccurrences,
    sharedWorkBudget: budget,
  );
  final result = <TimedTaskOccurrence>[];
  final civilLow = utcMicroseconds(DateTime.utc(1970)),
      civilHigh = utcMicroseconds(DateTime.utc(2100));
  for (final original in base) {
    if (replacements.containsKey(original)) {
      continue;
    }
    TimedValue? active;
    for (final a in rangeAnchors) {
      if (a.compareTo(original) > 0) {
        break;
      }
      active = a;
    }
    var actual = original;
    if (active != null) {
      final encoded =
          utcMicroseconds(civilEncoding(original.civil)) + shift(active);
      if (encoded < civilLow || encoded >= civilHigh) {
        continue;
      }
      actual = original.at(civilFields(utcFromMicroseconds(encoded)));
    }
    if (actual.instant.isBefore(window.start) ||
        !actual.instant.isBefore(window.end)) {
      continue;
    }
    result.add(
      TimedTaskOccurrence(
        original,
        (active == null ? master : ranges[active]!).at(actual),
      ),
    );
  }
  for (final e in replacements.entries) {
    if (!e.value.start!.instant.isBefore(window.start) &&
        e.value.start!.instant.isBefore(window.end)) {
      result.add(
        TimedTaskOccurrence(
          e.key,
          TimedTaskProjection(
            e.value.start!,
            e.value.effectiveDue,
            duration: e.value.duration,
          ),
        ),
      );
    }
  }
  result.sort((a, b) {
    final c = a.timing.start.instant.compareTo(b.timing.start.instant);
    return c == 0 ? a.originalStart.compareTo(b.originalStart) : c;
  });
  if (result.length > maxResults) {
    throw const RecurrenceLimitException('maxResults');
  }
  return List.unmodifiable(result);
}
