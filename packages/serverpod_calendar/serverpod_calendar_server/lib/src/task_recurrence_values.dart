import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'event_values.dart';
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
  CalendarTaskOccurrenceQuery query,
) {
  if (content.recurrence == null) throw ArgumentError('Task is not recurring');
  final t = content.timing, anchor = taskAnchor(t);
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
        from: _date(query.fromDate!),
        through: _date(query.untilDate!).addDays(-1),
        maxCandidateDays: eventMaxCandidateWork,
        maxRuleOccurrences: eventMaxRuleOccurrences,
        maxResults: eventMaxPreviewResults,
      ))
        CalendarTaskOccurrence(
          originalStart: anchor.copyWith(start: eventDate(o.originalStart)),
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
      window: UtcWindow(start: query.fromUtc!, end: query.untilUtc!),
      maxCandidateWork: eventMaxCandidateWork,
      maxRuleOccurrences: eventMaxRuleOccurrences,
      maxResults: eventMaxPreviewResults,
    ))
      CalendarTaskOccurrence(
        originalStart: anchor.copyWith(
          start: eventCivil(o.originalStart.civil),
        ),
        startUtc: o.originalStart.instant,
        dueUtc: o.timing.dueInstant,
        progress: CalendarTaskProgress(
          status: CalendarTaskStatus.needsAction,
          percentComplete: 0,
        ),
      ),
  ]);
}
