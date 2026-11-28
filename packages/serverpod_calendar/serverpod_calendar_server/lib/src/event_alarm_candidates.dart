part of 'event_values.dart';

/// Internal complete source projection, never derived from filtered detail lists.
Iterable<AlarmFiringCandidate> eventAlarmCandidates(
  CalendarEventContent content,
  CalendarEventTimingOverrides? overrides,
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
  if (content.timing.kind == CalendarEventTimeKind.date) {
    CalendarDate date(DateTime v) =>
        CalendarDate(year: v.year, month: v.month, day: v.day);
    final first = DateTime.utc(1970), last = DateTime.utc(2100);
    final lower = anchorWindow.start.subtract(const Duration(days: 2));
    final upper = anchorWindow.end.add(const Duration(days: 2));
    final from = date(lower.isBefore(first) ? first : lower);
    final until = upper.isBefore(last)
        ? date(upper)
        : const CalendarDate.exclusiveEnd();
    for (final occurrence
        in _dateOverrides(content, overrides).expandOverlapping(
          from: from,
          until: until,
          maxCandidateDays: eventMaxCandidateWork,
          maxRuleOccurrences: eventMaxRuleOccurrences,
          maxBaseOccurrences: eventMaxRuleOccurrences,
          maxResults: eventMaxRuleOccurrences,
        )) {
      final original = content.timing.copyWith(
        start: eventDate(occurrence.originalStart),
        end: null,
        duration: null,
      );
      final key = _alarmOriginalKey(original);
      final values = alarm.resolveDateEvent(occurrence.span);
      for (var i = 0; i < values.length; i++) {
        yield AlarmFiringCandidate(
          originalKey: key,
          repeatOrdinal: i,
          dueAt: values[i],
        );
      }
    }
  } else {
    final master = validateEventTiming(content.timing).$2!;
    final periods = {
      for (final v in content.periods ?? <CalendarEventTiming>[])
        validateEventTiming(v).$2!.start: validateEventTiming(v).$2!,
    };
    final singles = {
      for (final v in overrides?.singles ?? <CalendarEventSingleOverride>[])
        if (v.replacement != null)
          validateEventTiming(v.originalStart)
              .$2!
              .start: validateEventTiming(v.replacement!)
              .$2!,
    };
    final changes = [
      for (final v in overrides?.future ?? <CalendarEventFutureOverride>[])
        (
          validateEventTiming(v.originalStart).$2!.start,
          validateEventTiming(v.replacement).$2!,
        ),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    for (final occurrence
        in _timedOverrides(content, overrides).expandOverlapping(
          window: anchorWindow,
          maxCandidateWork: eventMaxCandidateWork,
          maxRuleOccurrences: eventMaxRuleOccurrences,
          maxBaseOccurrences: eventMaxRuleOccurrences,
          maxResults: eventMaxRuleOccurrences,
        )) {
      final original = content.timing.copyWith(
        start: eventCivil(occurrence.originalStart.civil),
        end: null,
        duration: null,
      );
      var template = periods[occurrence.originalStart] ?? master;
      for (final change in changes) {
        if (change.$1.compareTo(occurrence.originalStart) > 0) break;
        template = change.$2;
      }
      template = singles[occurrence.originalStart] ?? template;
      // Keep explicit gap wall fields at their own template anchor; later
      // projected ends remain resolved instants, including the later fold.
      final values =
          template.start == occurrence.actualStart &&
              template.endExclusive == occurrence.span.endExclusive
          ? alarm.resolveTimedEvent(template)
          : alarm.resolveTimedProjection(
              start: occurrence.actualStart,
              end: occurrence.span.isPoint
                  ? null
                  : occurrence.span.endExclusive,
            );
      for (var i = 0; i < values.length; i++) {
        yield AlarmFiringCandidate(
          originalKey: _alarmOriginalKey(original),
          repeatOrdinal: i,
          dueAt: values[i],
        );
      }
    }
  }
}

String _alarmOriginalKey(CalendarEventTiming t) {
  final c = t.start;
  // Exact same identity grammar as task originals; item/absolute is separate.
  return jsonEncode([
    t.kind.name,
    t.zoneId,
    c.year,
    c.month,
    c.day,
    c.hour,
    c.minute,
    c.second,
    c.microsecond,
  ]);
}
