import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'event_values.dart';
import 'task_values.dart';
import 'generated/protocol.dart';

CalendarEventTiming taskAnchor(CalendarTaskTiming t) {
  if (t.start == null || t.kind == CalendarTaskTimeKind.undated) {
    throw ArgumentError('An explicit task start is required');
  }
  return CalendarEventTiming(
    kind: switch (t.kind) {
      CalendarTaskTimeKind.date => CalendarEventTimeKind.date,
      CalendarTaskTimeKind.utc => CalendarEventTimeKind.utc,
      CalendarTaskTimeKind.zoned => CalendarEventTimeKind.zoned,
      _ => throw ArgumentError('Undated task has no anchor'),
    },
    start: t.start!,
    zoneId: t.zoneId,
  );
}

CalendarDate _date(CalendarEventCivil c) =>
    CalendarDate(year: c.year, month: c.month, day: c.day);
CalendarDuration? _duration(CalendarEventDuration? d) => d == null
    ? null
    : CalendarDuration(
        weeks: d.weeks,
        days: d.days,
        hours: d.hours,
        minutes: d.minutes,
        seconds: d.seconds,
        microsecond: d.microsecond,
      );
TimedValue _timed(CalendarEventTiming t) => validateEventTiming(t).$2!.start;

DateRecurrenceSet _dates(CalendarTaskContent c) => DateRecurrenceSet(
  start: _date(c.timing.start!),
  rule: eventDateRule(c.recurrence?.rule),
  inclusions: [
    for (final v in c.recurrence?.inclusions ?? <CalendarEventTiming>[])
      _date(v.start),
  ],
  exclusions: [
    for (final v in c.recurrence?.exclusions ?? <CalendarEventTiming>[])
      _date(v.start),
  ],
  maxExplicitDates: eventMaxExplicitDates,
);
TimedRecurrenceSet _times(CalendarTaskContent c) => TimedRecurrenceSet(
  start: _timed(taskAnchor(c.timing)),
  rule: eventTimedRule(c.recurrence?.rule),
  inclusions: [
    for (final v in c.recurrence?.inclusions ?? <CalendarEventTiming>[])
      _timed(v),
  ],
  exclusions: [
    for (final v in c.recurrence?.exclusions ?? <CalendarEventTiming>[])
      _timed(v),
  ],
  maxExplicitDates: eventMaxExplicitDates,
);

/// Canonical original identity, never an actual due/completion instant.
String taskOriginalKey(CalendarEventTiming original) {
  if (original.end != null || original.duration != null) {
    throw ArgumentError('Original identity has no interval');
  }
  validateEventTiming(original);
  final c = original.start;
  return jsonEncode([
    original.kind.name,
    original.zoneId,
    c.year,
    c.month,
    c.day,
    c.hour,
    c.minute,
    c.second,
    c.microsecond,
  ]);
}

void requireTaskOriginal(
  CalendarTaskContent content,
  CalendarEventTiming original,
) {
  if (content.recurrence == null) throw ArgumentError('Task is not recurring');
  final anchor = taskAnchor(content.timing);
  taskOriginalKey(original);
  if (anchor.kind != original.kind || anchor.zoneId != original.zoneId) {
    throw ArgumentError('Original identity profile mismatch');
  }
  bool found;
  if (original.kind == CalendarEventTimeKind.date) {
    final date = _date(original.start);
    found = _dates(content)
        .expand(
          from: date,
          through: date,
          maxCandidateDays: eventMaxCandidateWork,
          maxRuleOccurrences: eventMaxRuleOccurrences,
          maxResults: eventMaxPreviewResults,
        )
        .contains(date);
  } else {
    final time = _timed(original);
    found = _times(content)
        .expand(
          window: UtcWindow(
            start: time.instant,
            end: time.instant.add(const Duration(seconds: 1)),
          ),
          maxCandidateWork: eventMaxCandidateWork,
          maxRuleOccurrences: eventMaxRuleOccurrences,
          maxResults: eventMaxPreviewResults,
        )
        .contains(time);
  }
  if (!found) throw ArgumentError('Original occurrence is absent or excluded');
}

/// One aggregate generation budget for every retained original, not one budget
/// per record. Unresolvable membership fails without dropping any records.
void requireTaskOriginals(
  CalendarTaskContent content,
  List<CalendarEventTiming> originals,
) {
  if (originals.isEmpty) return;
  if (content.recurrence == null) {
    throw ArgumentError('Recorded originals require recurrence');
  }
  final anchor = taskAnchor(content.timing);
  for (final original in originals) {
    taskOriginalKey(original);
    if (original.kind != anchor.kind || original.zoneId != anchor.zoneId) {
      throw ArgumentError('Original profile changed');
    }
  }
  if (anchor.kind == CalendarEventTimeKind.date) {
    final dates = originals.map((v) => _date(v.start)).toList()..sort();
    final found = _dates(content)
        .expand(
          from: dates.first,
          through: dates.last,
          maxCandidateDays: eventMaxCandidateWork,
          maxRuleOccurrences: eventMaxRuleOccurrences,
          maxResults: eventMaxRuleOccurrences,
        )
        .toSet();
    if (!found.containsAll(dates)) {
      throw ArgumentError('Recorded original would be orphaned');
    }
  } else {
    final times = originals.map(_timed).toList()
      ..sort((a, b) => a.instant.compareTo(b.instant));
    final found = _times(content)
        .expand(
          window: UtcWindow(
            start: times.first.instant,
            end: times.last.instant.add(const Duration(seconds: 1)),
          ),
          maxCandidateWork: eventMaxCandidateWork,
          maxRuleOccurrences: eventMaxRuleOccurrences,
          maxResults: eventMaxRuleOccurrences,
        )
        .toSet();
    if (!found.containsAll(times)) {
      throw ArgumentError('Recorded original would be orphaned');
    }
  }
}

List<CalendarTaskOccurrence> previewTaskValues(
  CalendarTaskContent content,
  CalendarTaskOccurrenceQuery query, {
  Map<CalendarEventTiming, CalendarTaskTiming> replacements = const {},
  Map<CalendarEventTiming, CalendarTaskTiming> futureChanges = const {},
}) {
  if (content.recurrence == null) throw ArgumentError('Task is not recurring');
  final t = content.timing, anchor = taskAnchor(t);
  _validateTaskTimingMaps(content, replacements, futureChanges);
  if (anchor.kind == CalendarEventTimeKind.date) {
    if (query.fromDate == null ||
        query.untilDate == null ||
        query.fromUtc != null ||
        query.untilUtc != null) {
      throw ArgumentError('DATE bounds required');
    }
    // Reuse strict query endpoint validation without giving tasks event spans.
    previewEventOccurrences(
      CalendarEventContent(timing: anchor),
      CalendarEventOccurrenceQuery(
        eventId: query.taskId,
        expectedRevision: query.expectedRevision,
        fromDate: query.fromDate,
        untilDate: query.untilDate,
      ),
    );
    final master = DateTaskTiming(
      start: _date(t.start!),
      due: t.due == null ? null : _date(t.due!),
      duration: _duration(t.duration),
    );
    return List.unmodifiable([
      for (final o in master.expandStarts(
        _dates(content),
        replacements: {
          for (final e in replacements.entries)
            _date(e.key.start): DateTaskTiming(
              start: _date(e.value.start!),
              due: e.value.due == null ? null : _date(e.value.due!),
              duration: _duration(e.value.duration),
            ),
        },
        futureChanges: {
          for (final e in futureChanges.entries)
            _date(e.key.start): _taskDateTiming(e.value),
        },
        from: _date(query.fromDate!),
        through:
            (query.untilDate!.year == 2100
                    ? const CalendarDate.exclusiveEnd()
                    : _date(query.untilDate!))
                .addDays(-1),
        maxCandidateDays: eventMaxCandidateWork,
        maxRuleOccurrences: eventMaxRuleOccurrences,
        maxResults: eventMaxPreviewResults,
      ))
        CalendarTaskOccurrence(
          originalStart: anchor.copyWith(start: eventDate(o.originalStart)),
          actualStart: anchor.copyWith(start: eventDate(o.timing.start!)),
          replacementTiming:
              replacements[anchor.copyWith(start: eventDate(o.originalStart))],
          futureTiming:
              futureChanges[anchor.copyWith(start: eventDate(o.originalStart))],
          duration: _taskNativeDuration(o.timing.duration),
          dueDate: o.timing.effectiveDue == null
              ? null
              : eventDate(o.timing.effectiveDue!),
          progress: CalendarTaskProgress(
            status: CalendarTaskStatus.needsAction,
            percentComplete: 0,
          ),
        ),
    ]);
  }
  if (query.fromUtc == null ||
      query.untilUtc == null ||
      query.fromDate != null ||
      query.untilDate != null) {
    throw ArgumentError('UTC bounds required');
  }
  TimedValue.utc(query.fromUtc!);
  TimedValue.utcEnd(query.untilUtc!);
  if (query.untilUtc!.difference(query.fromUtc!) > const Duration(days: 366)) {
    throw const RecurrenceLimitException('maxQueryDays');
  }
  final master = TimedTaskTiming(
    start: _timed(anchor),
    due: t.due == null ? null : _timed(anchor.copyWith(start: t.due!)),
    duration: _duration(t.duration),
  );
  return List.unmodifiable([
    for (final o in master.expandStarts(
      _times(content),
      replacements: {
        for (final e in replacements.entries)
          _timed(e.key): TimedTaskTiming(
            start: _timed(taskAnchor(e.value)),
            due: e.value.due == null
                ? null
                : _timed(taskAnchor(e.value).copyWith(start: e.value.due!)),
            duration: _duration(e.value.duration),
          ),
      },
      futureChanges: {
        for (final e in futureChanges.entries)
          _timed(e.key): _taskTimedTiming(e.value),
      },
      window: UtcWindow(start: query.fromUtc!, end: query.untilUtc!),
      maxCandidateWork: eventMaxCandidateWork,
      maxRuleOccurrences: eventMaxRuleOccurrences,
      maxResults: eventMaxPreviewResults,
    ))
      CalendarTaskOccurrence(
        originalStart: anchor.copyWith(
          start: eventCivil(o.originalStart.civil),
        ),
        actualStart: anchor.copyWith(start: eventCivil(o.timing.start.civil)),
        replacementTiming:
            replacements[anchor.copyWith(
              start: eventCivil(o.originalStart.civil),
            )],
        futureTiming:
            futureChanges[anchor.copyWith(
              start: eventCivil(o.originalStart.civil),
            )],
        duration: _taskNativeDuration(o.timing.duration),
        startUtc: o.timing.start.instant,
        dueUtc: o.timing.dueInstant,
        progress: CalendarTaskProgress(
          status: CalendarTaskStatus.needsAction,
          percentComplete: 0,
        ),
      ),
  ]);
}

DateTaskTiming _taskDateTiming(CalendarTaskTiming t) => DateTaskTiming(
  start: t.start == null ? null : _date(t.start!),
  due: t.due == null ? null : _date(t.due!),
  duration: _duration(t.duration),
);
TimedTaskTiming _taskTimedTiming(CalendarTaskTiming t) => TimedTaskTiming(
  start: t.start == null ? null : _timed(taskAnchor(t)),
  due: t.due == null ? null : _timed(taskAnchor(t).copyWith(start: t.due!)),
  duration: _duration(t.duration),
);
CalendarEventDuration? _taskNativeDuration(CalendarDuration? d) => d == null
    ? null
    : CalendarEventDuration(
        weeks: d.weeks,
        days: d.days,
        hours: d.hours,
        minutes: d.minutes,
        seconds: d.seconds,
      );
void _validateTaskTimingMaps(
  CalendarTaskContent content,
  Map<CalendarEventTiming, CalendarTaskTiming> singles,
  Map<CalendarEventTiming, CalendarTaskTiming> future,
) {
  final anchor = taskAnchor(content.timing);
  for (final e in [...singles.entries, ...future.entries]) {
    taskOriginalKey(e.key);
    if (e.key.kind != anchor.kind || e.key.zoneId != anchor.zoneId) {
      throw ArgumentError('Original profile mismatch');
    }
    validateTaskReplacement(content, e.value);
  }
}

/// Projection at an already validated original; does not invent membership.
CalendarTaskOccurrence taskTimingAt(
  CalendarTaskContent content,
  CalendarEventTiming original,
  CalendarTaskProgress progress, {
  Map<CalendarEventTiming, CalendarTaskTiming> replacements = const {},
  Map<CalendarEventTiming, CalendarTaskTiming> futureChanges = const {},
}) {
  _validateTaskTimingMaps(content, replacements, futureChanges);
  final anchor = taskAnchor(content.timing);
  taskOriginalKey(original);
  if (original.kind != anchor.kind || original.zoneId != anchor.zoneId) {
    throw ArgumentError('Original profile mismatch');
  }
  if (anchor.kind == CalendarEventTimeKind.date) {
    final t = _taskDateTiming(content.timing).at(
      _date(original.start),
      replacements: {
        for (final e in replacements.entries)
          _date(e.key.start): _taskDateTiming(e.value),
      },
      futureChanges: {
        for (final e in futureChanges.entries)
          _date(e.key.start): _taskDateTiming(e.value),
      },
    );
    return CalendarTaskOccurrence(
      originalStart: original,
      actualStart: anchor.copyWith(start: eventDate(t.start!)),
      replacementTiming: replacements[original],
      futureTiming: futureChanges[original],
      duration: _taskNativeDuration(t.duration),
      dueDate: t.effectiveDue == null ? null : eventDate(t.effectiveDue!),
      progress: progress,
    );
  }
  final t = _taskTimedTiming(content.timing).at(
    _timed(original),
    replacements: {
      for (final e in replacements.entries)
        _timed(e.key): _taskTimedTiming(e.value),
    },
    futureChanges: {
      for (final e in futureChanges.entries)
        _timed(e.key): _taskTimedTiming(e.value),
    },
  );
  return CalendarTaskOccurrence(
    originalStart: original,
    actualStart: anchor.copyWith(start: eventCivil(t.start.civil)),
    replacementTiming: replacements[original],
    futureTiming: futureChanges[original],
    duration: _taskNativeDuration(t.duration),
    startUtc: t.start.instant,
    dueUtc: t.dueInstant,
    progress: progress,
  );
}

/// Internal complete task projection; completion signals do not change source.
Iterable<AlarmFiringCandidate> taskAlarmCandidates(
  CalendarTaskContent content,
  List<CalendarTaskOccurrence> records,
  AlarmTiming alarm,
  UtcWindow anchorWindow,
) sync* {
  if (alarm.absoluteUtc != null) {
    final values = alarm.resolveUndatedTask();
    for (var i = 0; i < values.length; i++) {
      yield AlarmFiringCandidate(
        originalKey: 'item',
        repeatOrdinal: i,
        dueAt: values[i],
      );
    }
    return;
  }
  if (content.recurrence == null) {
    final values = content.timing.kind == CalendarTaskTimeKind.date
        ? alarm.resolveDateTask(_taskDateTiming(content.timing))
        : content.timing.kind == CalendarTaskTimeKind.undated
        ? alarm.resolveUndatedTask()
        : alarm.resolveTimedTask(_taskTimedTiming(content.timing));
    for (var i = 0; i < values.length; i++) {
      yield AlarmFiringCandidate(
        originalKey: 'item',
        repeatOrdinal: i,
        dueAt: values[i],
      );
    }
    return;
  }
  final singles = {
    for (final r in records)
      if (r.replacementTiming != null) r.originalStart: r.replacementTiming!,
  };
  final future = {
    for (final r in records)
      if (r.futureTiming != null) r.originalStart: r.futureTiming!,
  };
  if (content.timing.kind == CalendarTaskTimeKind.date) {
    CalendarDate date(DateTime v) =>
        CalendarDate(year: v.year, month: v.month, day: v.day);
    final first = DateTime.utc(1970), last = DateTime.utc(2099, 12, 31);
    final lower = anchorWindow.start.subtract(const Duration(days: 2));
    final upper = anchorWindow.end.add(const Duration(days: 2));
    for (final occurrence in _taskDateTiming(content.timing).expandStarts(
      _dates(content),
      replacements: {
        for (final e in singles.entries)
          _date(e.key.start): _taskDateTiming(e.value),
      },
      futureChanges: {
        for (final e in future.entries)
          _date(e.key.start): _taskDateTiming(e.value),
      },
      from: date(lower.isBefore(first) ? first : lower),
      through: date(upper.isAfter(last) ? last : upper),
      maxCandidateDays: eventMaxCandidateWork,
      maxRuleOccurrences: eventMaxRuleOccurrences,
      maxResults: eventMaxRuleOccurrences,
    )) {
      final original = taskAnchor(content.timing)
          .copyWith(start: eventDate(occurrence.originalStart));
      final key = taskOriginalKey(original);
      // Still enumerate/calculates suppressed originals; caller counts them before suppression.
      final values = alarm.resolveDateTask(occurrence.timing);
      for (var i = 0; i < values.length; i++) {
        yield AlarmFiringCandidate(
          originalKey: key,
          repeatOrdinal: i,
          dueAt: values[i],
        );
      }
    }
  } else {
    final master = _taskTimedTiming(content.timing);
    final timedSingles = {
      for (final e in singles.entries) _timed(e.key): _taskTimedTiming(e.value),
    };
    final timedFuture = {
      for (final e in future.entries) _timed(e.key): _taskTimedTiming(e.value),
    };
    final changes = timedFuture.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final occurrence in master.expandStarts(
      _times(content),
      replacements: timedSingles,
      futureChanges: timedFuture,
      window: anchorWindow,
      maxCandidateWork: eventMaxCandidateWork,
      maxRuleOccurrences: eventMaxRuleOccurrences,
      maxResults: eventMaxRuleOccurrences,
    )) {
      final original = taskAnchor(content.timing)
          .copyWith(start: eventCivil(occurrence.originalStart.civil));
      var template = master;
      for (final change in changes) {
        if (change.key.compareTo(occurrence.originalStart) > 0) break;
        template = change.value;
      }
      template = timedSingles[occurrence.originalStart] ?? template;
      final values =
          template.start == occurrence.timing.start &&
              template.effectiveDue == occurrence.timing.dueInstant
          ? alarm.resolveTimedTask(template)
          : alarm.resolveTimedProjection(
              start: occurrence.timing.start,
              end: occurrence.timing.dueInstant,
            );
      for (var i = 0; i < values.length; i++) {
        yield AlarmFiringCandidate(
          originalKey: taskOriginalKey(original),
          repeatOrdinal: i,
          dueAt: values[i],
        );
      }
    }
  }
}

/// Max actual template milestone separation plus offset-change padding.
Duration taskAlarmEndLookback(
  CalendarTaskContent content,
  List<CalendarTaskOccurrence> records,
) {
  var result = Duration.zero;
  for (final t in [
    content.timing,
    for (final r in records) ...[
      if (r.replacementTiming != null) r.replacementTiming!,
      if (r.futureTiming != null) r.futureTiming!,
    ],
  ]) {
    if (t.start == null) continue;
    Duration length;
    if (t.kind == CalendarTaskTimeKind.date) {
      final timing = _taskDateTiming(t);
      length = Duration(
        days: timing.effectiveDue == null
            ? 0
            : timing.start!.daysUntil(timing.effectiveDue!),
      );
    } else {
      final timing = _taskTimedTiming(t);
      length =
          timing.effectiveDue?.difference(timing.start!.instant) ??
          Duration.zero;
    }
    if (length > result) result = length;
  }
  return result + const Duration(days: 2);
}
