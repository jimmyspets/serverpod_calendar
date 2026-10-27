part of 'event_values.dart';

/// Exact original membership. An exhausted scan throws; it never means absent.
bool eventSchedulingMember(
  CalendarEventContent content,
  CalendarEventTiming point, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  if (point.end != null || point.duration != null) {
    throw ArgumentError('Original must be a point');
  }
  validateEventTiming(point);
  if (content.timing.kind != point.kind ||
      content.timing.zoneId != point.zoneId) {
    return false;
  }
  if (point.kind == CalendarEventTimeKind.date) {
    final date = _date(point.start);
    return _dateMaster(content).recurrence
        .expand(
          from: date,
          through: date,
          maxCandidateDays: eventMaxCandidateWork,
          maxRuleOccurrences: eventMaxRuleOccurrences,
          maxResults: eventMaxRuleOccurrences,
          sharedWorkBudget: sharedWorkBudget,
        )
        .contains(date);
  }
  final value = validateEventTiming(point).$2!.start;
  return _timedOverrides(content, null).recurrence
      .expand(
        window: UtcWindow(
          start: value.instant,
          end: value.instant.add(const Duration(seconds: 1)),
        ),
        maxCandidateWork: eventMaxCandidateWork,
        maxRuleOccurrences: eventMaxRuleOccurrences,
        maxResults: eventMaxRuleOccurrences,
        sharedWorkBudget: sharedWorkBudget,
      )
      .contains(value);
}

/// A private publication identity, never an extra canonical occurrence edit.
final class EventSchedulingOriginal {
  const EventSchedulingOriginal(this.originalStart, this.isThisAndFuture);
  final CalendarEventTiming originalStart;
  final bool isThisAndFuture;
  String get key => _anchorKey(originalStart);
  Map<String, dynamic> toJson() => {
    'originalStart': originalStart.toJson(),
    'isThisAndFuture': isThisAndFuture,
  };
  factory EventSchedulingOriginal.fromJson(Map<String, dynamic> value) =>
      EventSchedulingOriginal(
        CalendarEventTiming.fromJson(
          value['originalStart'] as Map<String, dynamic>,
        ),
        value['isThisAndFuture'] as bool,
      );
}

/// Scheduling-only full-value projection for already published originals.
/// Validates the union in bounded set scans, never one recurrence scan per slot.
/// Caller supplies complete authorized canonical data and protocol versions.
(CalendarEventTimingOverrides?, List<EventSchedulingOriginal>)
eventSchedulingProjection(
  CalendarEventContent content,
  CalendarEventTimingOverrides? input,
  List<EventSchedulingOriginal> originals, {
  bool membershipOnly = false,
}) {
  final current = validateEventOverrides(content, input);
  if (originals.length > 64 ||
      (current?.singles.length ?? 0) + (current?.future.length ?? 0) > 64) {
    throw const RecurrenceLimitException('schedulingOriginals');
  }
  final slots = <String, EventSchedulingOriginal>{};
  for (final slot in originals) {
    _profile(content.timing, slot.originalStart, anchor: true);
    if (slots.containsKey(slot.key)) throw ArgumentError('Duplicate original');
    slots[slot.key] = slot;
  }
  final singles = {
    for (final s in current?.singles ?? <CalendarEventSingleOverride>[])
      _anchorKey(s.originalStart): s,
  };
  final future = {
    for (final s in current?.future ?? <CalendarEventFutureOverride>[])
      _anchorKey(s.originalStart): s,
  };
  if (singles.values.any((s) => s.cancelled)) {
    throw ArgumentError('Unsupported cancellation');
  }
  for (final slot in slots.values) {
    if (singles.containsKey(slot.key) && slot.isThisAndFuture ||
        future.containsKey(slot.key) && !slot.isThisAndFuture) {
      throw ArgumentError('Published original kind changed');
    }
  }
  if ({...slots.keys, ...singles.keys, ...future.keys}.length > 64) {
    throw const RecurrenceLimitException('schedulingOriginals');
  }
  // Cancellation probes prove missing-slot membership without inventing edits.
  validateEventOverrides(
    content,
    CalendarEventTimingOverrides(
      singles: [
        ...singles.values,
        for (final slot in slots.values)
          if (!singles.containsKey(slot.key) && !future.containsKey(slot.key))
            CalendarEventSingleOverride(
              originalStart: slot.originalStart,
              cancelled: true,
            ),
      ],
      future: future.values.toList(),
    ),
  );
  if (membershipOnly) return (current, List.unmodifiable(slots.values));
  final changes = future.values.toList()
    ..sort(
      (a, b) =>
          _anchorKey(a.originalStart).compareTo(_anchorKey(b.originalStart)),
    );
  for (final slot in slots.values) {
    final single = singles[slot.key], ownFuture = future[slot.key];
    final effective = eventEffectiveOccurrenceContent(
      content,
      single?.contentOverrides ?? ownFuture?.contentOverrides,
    );
    final own = CalendarEventOccurrenceContent(
      summary: effective.summary ?? '',
      description: effective.description ?? '',
      location: effective.location ?? '',
      textParameters: effective.textParameters,
    );
    CalendarEventFutureOverride? active;
    for (final change in changes) {
      if (_anchorKey(change.originalStart).compareTo(slot.key) > 0) break;
      active = change;
    }
    var template = content.timing;
    for (final period in content.periods ?? <CalendarEventTiming>[]) {
      if (_anchorKey(period) == slot.key) template = period;
    }
    template = active?.replacement ?? template;
    final timing =
        single?.replacement ??
        _eventSchedulingTiming(slot.originalStart, template, active);
    if (slot.isThisAndFuture) {
      future[slot.key] = CalendarEventFutureOverride(
        originalStart: slot.originalStart,
        replacement: timing,
        contentOverrides: own,
        sourceMetadata: ownFuture?.sourceMetadata,
      );
    } else {
      singles[slot.key] = CalendarEventSingleOverride(
        originalStart: slot.originalStart,
        replacement: timing,
        contentOverrides: own,
        sourceMetadata: single?.sourceMetadata,
      );
    }
  }
  final result = validateEventOverrides(
    content,
    CalendarEventTimingOverrides(
      singles: singles.values.toList(),
      future: future.values.toList(),
    ),
  );
  return (result, List.unmodifiable(slots.values));
}

CalendarEventTiming _eventSchedulingTiming(
  CalendarEventTiming original,
  CalendarEventTiming template,
  CalendarEventFutureOverride? active,
) {
  if (original.kind == CalendarEventTimeKind.date) {
    final span = validateEventTiming(template).$1!;
    final shift = active == null
        ? 0
        : DateEventRangeChange(
            originalStart: _date(active.originalStart.start),
            replacement: span,
          ).dayShift;
    final start = _date(original.start).addDays(shift);
    return template.copyWith(
      start: eventDate(start),
      end: template.end == null
          ? null
          : eventDate(start.addDays(span.dayCount)),
    );
  }
  final identity = validateEventTiming(original).$2!.start;
  final span = validateEventTiming(template).$2!;
  final shift = active == null
      ? BigInt.zero
      : TimedEventRangeChange(
          originalStart: validateEventTiming(active.originalStart).$2!.start,
          replacement: span,
        ).civilShift;
  final actual = identity.at(
    _eventSchedulingCivilFields(
      _eventSchedulingCivilEncoding(identity.civil)
          .add(Duration(seconds: (shift ~/ BigInt.from(1000000)).toInt())),
    ),
  );
  if (actual == span.start) return template;
  final projected = span.projectAt(actual);
  final end = template.end == null
      ? null
      : template.kind == CalendarEventTimeKind.utc
      ? _eventSchedulingCivilFields(projected.endExclusive, end: true)
      : NamedZoneResolver().localAt(
          projected.endExclusive,
          zoneId: template.zoneId!,
        );
  final result = template.copyWith(
    start: eventCivil(actual.civil),
    end: end == null ? null : eventCivil(end),
  );
  // A later fold cannot be represented by RFC wall fields selecting the first.
  if (validateEventTiming(result).$2!.endExclusive != projected.endExclusive) {
    throw ArgumentError('Unrepresentable projected end');
  }
  return result;
}

DateTime _eventSchedulingCivilEncoding(CivilDateTime v) => DateTime.utc(
  v.date.year,
  v.date.month,
  v.date.day,
  v.hour,
  v.minute,
  v.second,
);

CivilDateTime _eventSchedulingCivilFields(DateTime v, {bool end = false}) =>
    CivilDateTime(
      date: end && v == DateTime.utc(2100)
          ? const CalendarDate.exclusiveEnd()
          : CalendarDate(year: v.year, month: v.month, day: v.day),
      hour: v.hour,
      minute: v.minute,
      second: v.second,
    );
