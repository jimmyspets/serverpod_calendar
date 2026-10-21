import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'generated/protocol.dart';

/// Native DTO conversion only; temporal rules remain in the independent core.
(DateEventSpan?, TimedEventSpan?) validateEventTiming(CalendarEventTiming v) {
  CivilDateTime civil(CalendarEventCivil c, {bool end = false}) {
    final date = end && c.year == 2100 && c.month == 1 && c.day == 1
        ? const CalendarDate.exclusiveEnd()
        : CalendarDate(year: c.year, month: c.month, day: c.day);
    return CivilDateTime(
      date: date,
      hour: c.hour,
      minute: c.minute,
      second: c.second,
      microsecond: c.microsecond,
    );
  }

  final start = civil(v.start);
  final end = v.end == null ? null : civil(v.end!, end: true);
  final d = v.duration;
  final duration = d == null
      ? null
      : CalendarDuration(
          weeks: d.weeks,
          days: d.days,
          hours: d.hours,
          minutes: d.minutes,
          seconds: d.seconds,
          microsecond: d.microsecond,
        );
  if (v.kind != CalendarEventTimeKind.zoned && v.zoneId != null) {
    throw ArgumentError('Only named-zone timing accepts a zone');
  }
  if (v.kind == CalendarEventTimeKind.date) {
    for (final c in [start, ?end]) {
      if (c.hour != 0 || c.minute != 0 || c.second != 0) {
        throw ArgumentError('DATE has no clock time');
      }
    }
    return (
      DateEventSpan(start: start.date, end: end?.date, duration: duration),
      null,
    );
  }
  if (v.kind == CalendarEventTimeKind.floating) {
    throw ArgumentError('Floating timing is unsupported');
  }
  TimedValue timed(CivilDateTime c, {bool finish = false}) {
    if (v.kind == CalendarEventTimeKind.utc) {
      final utc = DateTime.utc(
        c.date.year,
        c.date.month,
        c.date.day,
        c.hour,
        c.minute,
        c.second,
      );
      return finish ? TimedValue.utcEnd(utc) : TimedValue.utc(utc);
    }
    final zone = v.zoneId;
    if (zone == null || zone.isEmpty || zone.length > 255) {
      throw ArgumentError('Named zone required');
    }
    return finish
        ? TimedValue.zonedEnd(c, zoneId: zone)
        : TimedValue.zoned(c, zoneId: zone);
  }

  return (
    null,
    TimedEventSpan(
      start: timed(start),
      end: end == null ? null : timed(end, finish: true),
      duration: duration,
    ),
  );
}

CalendarEventContent validateEventContent(CalendarEventContent value) {
  if (value.summary != null) {
    validateCalendarPlainText(value.summary!, maxCodePoints: 4096);
  }
  if (value.description != null) {
    validateCalendarPlainText(value.description!, maxCodePoints: 16384);
  }
  if (value.location != null) {
    validateCalendarPlainText(value.location!, maxCodePoints: 4096);
  }
  validateEventTiming(value.timing);
  return value.copyWith(
    recurrence: validateEventRecurrence(value.timing, value.recurrence),
  );
}

// Trusted native-service budgets, charged before canonicalization/exclusions.
const eventMaxExplicitDates = 256;
const eventMaxCandidateWork = 200000;
const eventMaxRuleOccurrences = 10000;
const eventMaxPreviewResults = 500;

CalendarEventCivil eventCivil(CivilDateTime c) => CalendarEventCivil(
  year: c.date.year,
  month: c.date.month,
  day: c.date.day,
  hour: c.hour,
  minute: c.minute,
  second: c.second,
);
CalendarEventCivil eventDate(CalendarDate d) => CalendarEventCivil(
  year: d.year,
  month: d.month,
  day: d.day,
);
CalendarDate _date(CalendarEventCivil c, {bool end = false}) {
  final span = validateEventTiming(
    CalendarEventTiming(
      kind: CalendarEventTimeKind.date,
      start: end ? CalendarEventCivil(year: 2099, month: 12, day: 31) : c,
      end: end ? c : null,
    ),
  ).$1!;
  return end ? span.endExclusive : span.start;
}

DateRecurrenceRule? _dateRule(CalendarEventRule? r) {
  if (r == null) return null;
  if (r.frequency.index < CalendarEventFrequency.daily.index ||
      r.untilUtc != null ||
      r.byHour.isNotEmpty ||
      r.byMinute.isNotEmpty) {
    throw ArgumentError('DATE rule has timed fields');
  }
  return DateRecurrenceRule(
    frequency: DateRecurrenceFrequency.values[r.frequency.index - 2],
    interval: r.interval,
    count: r.count,
    until: r.untilDate == null ? null : _date(r.untilDate!),
    weekStart: Weekday.values[r.weekStart - 1],
    byDay: [
      for (final d in r.byDay)
        ByDayValue(weekday: Weekday.values[d.weekday - 1], ordinal: d.ordinal),
    ],
    byMonthDay: r.byMonthDay,
    byYearDay: r.byYearDay,
    byWeekNo: r.byWeekNo,
    byMonth: r.byMonth,
    bySetPosition: r.bySetPosition,
  );
}

TimedRecurrenceRule? _timedRule(CalendarEventRule? r) {
  if (r == null) return null;
  if (r.untilDate != null) throw ArgumentError('Timed UNTIL must be UTC');
  if (r.untilUtc != null) TimedValue.utc(r.untilUtc!);
  return TimedRecurrenceRule(
    frequency: TimedRecurrenceFrequency.values[r.frequency.index],
    interval: r.interval,
    count: r.count,
    until: r.untilUtc,
    weekStart: Weekday.values[r.weekStart - 1],
    byDay: [
      for (final d in r.byDay)
        ByDayValue(weekday: Weekday.values[d.weekday - 1], ordinal: d.ordinal),
    ],
    byMonthDay: r.byMonthDay,
    byYearDay: r.byYearDay,
    byWeekNo: r.byWeekNo,
    byMonth: r.byMonth,
    byHour: r.byHour,
    byMinute: r.byMinute,
    bySetPosition: r.bySetPosition,
  );
}

CalendarEventRecurrence? validateEventRecurrence(
  CalendarEventTiming timing,
  CalendarEventRecurrence? input,
) {
  if (input == null) return null;
  if (input.inclusions.length + input.exclusions.length >
      eventMaxExplicitDates) {
    throw const RecurrenceLimitException('maxExplicitDates');
  }
  final r = input.rule;
  if (r != null) {
    RangeError.checkValueInInterval(r.weekStart, 1, 7, 'weekStart');
    final size =
        r.byDay.length +
        r.byMonthDay.length +
        r.byYearDay.length +
        r.byWeekNo.length +
        r.byMonth.length +
        r.byHour.length +
        r.byMinute.length +
        r.bySetPosition.length;
    if (size > 512) throw const RecurrenceLimitException('maxRuleParts');
    for (final d in r.byDay) {
      RangeError.checkValueInInterval(d.weekday, 1, 7, 'weekday');
    }
  }
  final (date, timed) = validateEventTiming(timing);
  CalendarEventTiming check(CalendarEventTiming v) {
    if (v.kind != timing.kind ||
        v.zoneId != timing.zoneId ||
        v.end != null ||
        v.duration != null) {
      throw ArgumentError(
        'Explicit recurrence dates require the exact master profile and no span',
      );
    }
    validateEventTiming(v);
    return v;
  }

  final additions = input.inclusions.map(check).toList();
  final exclusions = input.exclusions.map(check).toList();
  late final DateRecurrenceRule? selection;
  TimedRecurrenceRule? tr;
  if (date != null) {
    selection = _dateRule(r);
    DateRecurrenceSet(
      start: date.start,
      rule: selection,
      inclusions: additions.map((v) => _date(v.start)).toList(),
      exclusions: exclusions.map((v) => _date(v.start)).toList(),
      maxExplicitDates: eventMaxExplicitDates,
    ).expand(
      from: date.start,
      through: date.start,
      maxCandidateDays: eventMaxCandidateWork,
      maxRuleOccurrences: eventMaxRuleOccurrences,
      maxResults: eventMaxPreviewResults,
    );
  } else {
    tr = _timedRule(r);
    selection = tr?.dateSelection;
    TimedRecurrenceSet(
      start: timed!.start,
      rule: tr,
      inclusions: additions
          .map((v) => validateEventTiming(v).$2!.start)
          .toList(),
      exclusions: exclusions
          .map((v) => validateEventTiming(v).$2!.start)
          .toList(),
      maxExplicitDates: eventMaxExplicitDates,
    ).expand(
      window: UtcWindow(
        start: timed.start.instant,
        end: timed.start.instant.add(const Duration(seconds: 1)),
      ),
      maxCandidateWork: eventMaxCandidateWork,
      maxRuleOccurrences: eventMaxRuleOccurrences,
      maxResults: eventMaxPreviewResults,
    );
  }
  List<CalendarEventTiming> canonical(List<CalendarEventTiming> values) {
    final keyed = <String, CalendarEventTiming>{};
    for (final v in values) {
      final c = v.start;
      final key = [
        c.year,
        c.month,
        c.day,
        c.hour,
        c.minute,
        c.second,
      ].map((n) => n.toString().padLeft(4, '0')).join(':');
      keyed[key] = v;
    }
    return List.unmodifiable([
      for (final key in keyed.keys.toList()..sort()) keyed[key]!,
    ]);
  }

  return CalendarEventRecurrence(
    rule: r?.copyWith(
      byDay: List.unmodifiable([
        for (final d in selection!.byDay)
          CalendarEventByDay(weekday: d.weekday.isoNumber, ordinal: d.ordinal),
      ]),
      byMonthDay: selection.byMonthDay,
      byYearDay: selection.byYearDay,
      byWeekNo: selection.byWeekNo,
      byMonth: selection.byMonth,
      bySetPosition: tr?.bySetPosition ?? selection.bySetPosition,
      byHour: tr?.byHour ?? const [],
      byMinute: tr?.byMinute ?? const [],
    ),
    inclusions: canonical(additions),
    exclusions: canonical(exclusions),
  );
}

/// Complete overlap preview for one already-authorized event. No truncation.
CalendarEventOccurrencePreview previewEventOccurrences(
  CalendarEventContent content,
  CalendarEventOccurrenceQuery q,
) {
  final (date, timed) = validateEventTiming(content.timing);
  final r = content.recurrence;
  final result = <CalendarEventOccurrence>[];
  if (date != null) {
    if (q.fromDate == null ||
        q.untilDate == null ||
        q.fromUtc != null ||
        q.untilUtc != null) {
      throw ArgumentError('DATE preview requires only date bounds');
    }
    final from = _date(q.fromDate!);
    // An exclusive endpoint is accepted only at 2100-01-01 midnight.
    final rawEnd = q.untilDate!;
    final until = rawEnd.year == 2100
        ? _date(rawEnd, end: true)
        : _date(rawEnd);
    if (from.daysUntil(until) > 366) {
      throw const RecurrenceLimitException('maxQueryDays');
    }
    final series = DateEventSeries(
      span: date,
      recurrence: DateRecurrenceSet(
        start: date.start,
        rule: _dateRule(r?.rule),
        inclusions: r?.inclusions.map((v) => _date(v.start)).toList() ?? [],
        exclusions: r?.exclusions.map((v) => _date(v.start)).toList() ?? [],
        maxExplicitDates: eventMaxExplicitDates,
      ),
    );
    for (final span in series.expandOverlapping(
      from: from,
      until: until,
      maxCandidateDays: eventMaxCandidateWork,
      maxRuleOccurrences: eventMaxRuleOccurrences,
      maxResults: eventMaxPreviewResults,
    )) {
      result.add(
        CalendarEventOccurrence(
          originalStart: eventDate(span.start),
          start: eventDate(span.start),
          endDate: eventDate(span.endExclusive),
        ),
      );
    }
  } else {
    if (q.fromUtc == null ||
        q.untilUtc == null ||
        q.fromDate != null ||
        q.untilDate != null) {
      throw ArgumentError('Timed preview requires only UTC bounds');
    }
    // Validate supported UTC fields and whole seconds; spillover is not input permission.
    TimedValue.utc(q.fromUtc!);
    TimedValue.utcEnd(q.untilUtc!);
    if (q.untilUtc!.difference(q.fromUtc!) > const Duration(days: 366)) {
      throw const RecurrenceLimitException('maxQueryDays');
    }
    final series = TimedEventSeries(
      span: timed!,
      recurrence: TimedRecurrenceSet(
        start: timed.start,
        rule: _timedRule(r?.rule),
        inclusions:
            r?.inclusions
                .map((v) => validateEventTiming(v).$2!.start)
                .toList() ??
            [],
        exclusions:
            r?.exclusions
                .map((v) => validateEventTiming(v).$2!.start)
                .toList() ??
            [],
        maxExplicitDates: eventMaxExplicitDates,
      ),
      maxChanges: 0,
      maxValidationCandidateWork: eventMaxCandidateWork,
      maxValidationOccurrences: eventMaxRuleOccurrences,
    );
    for (final occurrence in series.expandOverlapping(
      window: UtcWindow(start: q.fromUtc!, end: q.untilUtc!),
      maxCandidateWork: eventMaxCandidateWork,
      maxRuleOccurrences: eventMaxRuleOccurrences,
      maxBaseOccurrences: eventMaxRuleOccurrences,
      maxResults: eventMaxPreviewResults,
    )) {
      result.add(
        CalendarEventOccurrence(
          originalStart: eventCivil(occurrence.originalStart.civil),
          start: eventCivil(occurrence.actualStart.civil),
          startUtc: occurrence.span.start,
          endUtc: occurrence.span.endExclusive,
        ),
      );
    }
  }
  return CalendarEventOccurrencePreview(
    eventId: q.eventId,
    revision: q.expectedRevision,
    kind: content.timing.kind,
    zoneId: content.timing.zoneId,
    occurrences: result,
  );
}
