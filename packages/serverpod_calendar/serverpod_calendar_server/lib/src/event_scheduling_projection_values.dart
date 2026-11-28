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
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final current = validateEventOverrides(
    content,
    input,
    sharedWorkBudget: sharedWorkBudget,
  );
  if (current?.cancelledFrom != null) {
    throw ArgumentError('Future cancellation has no REQUEST projection');
  }
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
    sharedWorkBudget: sharedWorkBudget,
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
    sharedWorkBudget: sharedWorkBudget,
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

/// Builds a faithful publication-only range anchor before a suffix is cancelled.
/// The returned edits never replace canonical state. PERIOD lengths are captured
/// as finite single projections so a new range cannot reinterpret those starts.
(CalendarEventTimingOverrides, List<EventSchedulingOriginal>)
eventSchedulingRangeRestoration(
  CalendarEventContent content,
  CalendarEventTimingOverrides? input,
  List<EventSchedulingOriginal> retained,
  CalendarEventTiming anchor, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final current = validateEventOverrides(
    content,
    input,
    sharedWorkBudget: work,
  );
  _profile(content.timing, anchor, anchor: true);
  if (!eventSchedulingMember(content, anchor, sharedWorkBudget: work)) {
    throw ArgumentError('Missing published original');
  }
  final key = _anchorKey(anchor);
  if (current?.cancelledFrom != null ||
      (current?.singles.any((s) => _anchorKey(s.originalStart) == key) ??
          false) ||
      retained.any((s) => s.key == key && !s.isThisAndFuture)) {
    throw ArgumentError('Unrestorable published anchor');
  }
  final ranges = [...?current?.future]
    ..sort(
      (a, b) =>
          _anchorKey(a.originalStart).compareTo(_anchorKey(b.originalStart)),
    );
  CalendarEventFutureOverride? active;
  for (final row in ranges) {
    if (_anchorKey(row.originalStart).compareTo(key) > 0) break;
    active = row;
  }
  // A special duration at this original must not become the suffix duration.
  if (active == null &&
      (content.periods?.any((p) => _anchorKey(p) == key) ?? false)) {
    throw ArgumentError('PERIOD anchor requires a separate profile');
  }
  final markers = {
    for (final row in retained) row.key: row,
  };
  if (markers.length != retained.length) {
    throw ArgumentError('Duplicate retained original');
  }
  markers[key] = EventSchedulingOriginal(anchor, true);
  for (final period in content.periods ?? <CalendarEventTiming>[]) {
    if (_anchorKey(period).compareTo(key) <= 0) continue;
    final periodKey = _anchorKey(period);
    if ((current?.singles.any(
              (s) => _anchorKey(s.originalStart) == periodKey,
            ) ??
            false) ||
        (current?.future.any((s) => _anchorKey(s.originalStart) == periodKey) ??
            false)) {
      continue;
    }
    markers.putIfAbsent(
      periodKey,
      () => EventSchedulingOriginal(
        period.copyWith(end: null, duration: null),
        false,
      ),
    );
  }
  final union = {
    ...markers.keys,
    for (final row in current?.singles ?? <CalendarEventSingleOverride>[])
      _anchorKey(row.originalStart),
    for (final row in ranges) _anchorKey(row.originalStart),
  };
  if (union.length > 64) {
    throw const RecurrenceLimitException('schedulingOriginals');
  }
  // Charge every finite projection to the caller's budget before materializing.
  for (final marker in markers.values) {
    if (!eventSchedulingMember(
      content,
      marker.originalStart,
      sharedWorkBudget: work,
    )) {
      throw ArgumentError('Missing retained original');
    }
  }
  final result = eventSchedulingProjection(
    content,
    current,
    markers.values.toList(),
    sharedWorkBudget: work,
  );
  return (result.$1!, result.$2);
}

/// Projects one original from already validated publication content/overrides.
/// Membership consumes the caller's aggregate budget; this allocates no edit.
CalendarEventContent? eventSchedulingOccurrence(
  CalendarEventContent content,
  CalendarEventTimingOverrides? overrides,
  CalendarEventTiming point, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  _profile(content.timing, point, anchor: true);
  if (!eventSchedulingMember(
    content,
    point,
    sharedWorkBudget: sharedWorkBudget,
  )) {
    return null;
  }
  final key = _anchorKey(point);
  final single = overrides?.singles
      .where((s) => _anchorKey(s.originalStart) == key)
      .firstOrNull;
  final ownRange = overrides?.future
      .where((s) => _anchorKey(s.originalStart) == key)
      .firstOrNull;
  if (single?.cancelled ?? false) throw ArgumentError('Cancelled original');
  final ranges = [...?overrides?.future]
    ..sort(
      (a, b) =>
          _anchorKey(a.originalStart).compareTo(_anchorKey(b.originalStart)),
    );
  CalendarEventFutureOverride? active;
  for (final change in ranges) {
    if (_anchorKey(change.originalStart).compareTo(key) > 0) break;
    active = change;
  }
  var template = content.timing;
  for (final period in content.periods ?? <CalendarEventTiming>[]) {
    if (_anchorKey(period) == key) template = period;
  }
  template = active?.replacement ?? template;
  final timing =
      single?.replacement ?? _eventSchedulingTiming(point, template, active);
  final own = eventEffectiveOccurrenceContent(
    content,
    single?.contentOverrides ?? ownRange?.contentOverrides,
  );
  return content.copyWith(
    timing: timing,
    recurrence: null,
    periods: null,
    summary: own.summary,
    description: own.description,
    location: own.location,
    textParameters: own.textParameters,
  );
}
