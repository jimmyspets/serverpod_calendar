part of 'event_values.dart';

void _proveDateRuleFinite(
  CalendarEventContent content,
  RecurrenceWorkBudget work,
) {
  final set = _dateMaster(content).recurrence;
  final rule = set.rule;
  if (rule == null || rule.until != null) return;
  final count = rule.count;
  if (count == null) {
    throw ArgumentError('DATE recurrence ending cannot be proven');
  }
  if (count > eventMaxRuleOccurrences) {
    throw const RecurrenceLimitException('maxRuleOccurrences');
  }
  final generated = DateRecurrenceGenerator().expand(
    start: set.start,
    rule: rule,
    from: CalendarDate(year: 1970, month: 1, day: 1),
    through: CalendarDate(year: 2099, month: 12, day: 31),
    maxCandidateDays: eventMaxCandidateWork,
    maxResults: eventMaxRuleOccurrences,
    sharedWorkBudget: work,
  );
  if (generated.length != count) {
    throw ArgumentError('DATE recurrence ending cannot be proven');
  }
}

void _proveTimedRuleFinite(
  CalendarEventContent content,
  RecurrenceWorkBudget work,
) {
  final set = _timedOverrides(content, null).recurrence;
  final rule = set.rule;
  if (rule == null) return;
  var maximum = Duration.zero;
  var minimum = Duration.zero;
  if (set.start.zoneId != null) {
    final resolver = NamedZoneResolver();
    maximum = resolver.maximumOffset(zoneId: set.start.zoneId!);
    minimum = maximum - resolver.offsetRange(zoneId: set.start.zoneId!);
  }
  // Do not extrapolate pinned offsets into the unsupported next year.
  final safeEnd = set.start.zoneId == null
      ? DateTime.utc(2100)
      : DateTime.utc(2099, 12, 30);
  if (rule.until != null && rule.until!.isBefore(safeEnd)) {
    return;
  }
  final count = rule.count;
  if (count == null) {
    throw ArgumentError('Timed recurrence ending cannot be proven');
  }
  if (count > eventMaxRuleOccurrences) {
    throw const RecurrenceLimitException('maxRuleOccurrences');
  }
  final generated = TimedRecurrenceGenerator().expand(
    start: set.start,
    rule: rule,
    window: UtcWindow(
      start: DateTime.utc(1970).subtract(maximum),
      end: DateTime.utc(2100).subtract(minimum),
    ),
    maxCandidateWork: eventMaxCandidateWork,
    maxResults: eventMaxRuleOccurrences,
    sharedWorkBudget: work,
  );
  if (generated.length != count) {
    throw ArgumentError('Timed recurrence ending cannot be proven');
  }
}

/// Finds the first timed original in a civil-identity window, not start order.
///
/// The result is after [anchor] and at or before [through]. Null proves only
/// that this bounded window has no original; it does not prove series end.
/// Offset bounds cover the exact pinned zone, and every generated candidate
/// still passes the recurrence engine's normal coverage and gap checks.
CalendarEventTiming? eventSchedulingNextTimedInWindow(
  CalendarEventContent content,
  CalendarEventTiming anchor,
  CalendarEventTiming through, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  if (anchor.kind == CalendarEventTimeKind.date ||
      anchor.end != null ||
      anchor.duration != null ||
      through.end != null ||
      through.duration != null ||
      anchor.kind != content.timing.kind ||
      anchor.zoneId != content.timing.zoneId ||
      through.kind != anchor.kind ||
      through.zoneId != anchor.zoneId) {
    throw ArgumentError('Expected matching timed original points');
  }
  final start = validateEventTiming(anchor).$2!.start;
  final end = validateEventTiming(through).$2!.start;
  if (start.compareTo(end) >= 0) {
    throw ArgumentError('Window must extend beyond the anchor');
  }
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  if (!eventSchedulingMember(content, anchor, sharedWorkBudget: work)) {
    throw ArgumentError('Anchor is not a recurrence original');
  }
  var maximum = Duration.zero;
  var minimum = Duration.zero;
  if (anchor.zoneId != null) {
    final resolver = NamedZoneResolver();
    maximum = resolver.maximumOffset(zoneId: anchor.zoneId!);
    minimum = maximum - resolver.offsetRange(zoneId: anchor.zoneId!);
  }
  final values =
      _timedOverrides(content, null).recurrence
          .expand(
            window: UtcWindow(
              start: _eventSchedulingCivilEncoding(start.civil)
                  .subtract(maximum),
              end: _eventSchedulingCivilEncoding(end.civil)
                  .subtract(minimum)
                  .add(const Duration(seconds: 1)),
            ),
            maxCandidateWork: eventMaxCandidateWork,
            maxRuleOccurrences: eventMaxRuleOccurrences,
            maxResults: eventMaxRuleOccurrences,
            sharedWorkBudget: work,
          )
          .where(
            (value) => value.compareTo(start) > 0 && value.compareTo(end) <= 0,
          )
          .toList()
        ..sort();
  if (values.isEmpty) return null;
  return CalendarEventTiming(
    kind: anchor.kind,
    start: eventCivil(values.first.civil),
    zoneId: anchor.zoneId,
  );
}

/// Finds the first DATE original after [anchor] through [through], inclusive.
///
/// A null result proves absence only inside this explicit window. In
/// particular it does not prove that a recurrence ends at the horizon.
/// Exhausting any recurrence limit throws without returning a partial result.
CalendarEventTiming? eventSchedulingNextDateInWindow(
  CalendarEventContent content,
  CalendarEventTiming anchor,
  CalendarDate through, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  if (anchor.kind != CalendarEventTimeKind.date ||
      anchor.end != null ||
      anchor.duration != null ||
      content.timing.kind != CalendarEventTimeKind.date) {
    throw ArgumentError('Expected a DATE original point');
  }
  validateEventTiming(anchor);
  through.requireOrdinary('through');
  final date = _date(anchor.start);
  if (through.compareTo(date) <= 0) {
    throw ArgumentError('Window must extend beyond the anchor');
  }
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  if (!eventSchedulingMember(
    content,
    anchor,
    sharedWorkBudget: work,
  )) {
    throw ArgumentError('Anchor is not a recurrence original');
  }
  final dates = _dateMaster(content).recurrence.expand(
    from: date.addDays(1),
    through: through,
    maxCandidateDays: eventMaxCandidateWork,
    maxRuleOccurrences: eventMaxRuleOccurrences,
    maxResults: eventMaxRuleOccurrences,
    sharedWorkBudget: work,
  );
  if (dates.isEmpty) return null;
  return CalendarEventTiming(
    kind: CalendarEventTimeKind.date,
    start: eventDate(dates.first),
  );
}

/// Proves that a DATE original has no later original for an explicitly bounded
/// rule. COUNT is accepted only when all counted originals were generated;
/// reaching the supported horizon alone cannot prove exhaustion.
bool eventSchedulingDateIsProvablyLast(
  CalendarEventContent content,
  CalendarEventTiming anchor, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  if (content.timing.kind != CalendarEventTimeKind.date ||
      anchor.kind != CalendarEventTimeKind.date ||
      anchor.end != null ||
      anchor.duration != null) {
    throw ArgumentError('Expected a DATE original point');
  }
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  _proveDateRuleFinite(content, work);
  final date = _date(anchor.start);
  if (!eventSchedulingMember(content, anchor, sharedWorkBudget: work)) {
    throw ArgumentError('Anchor is not a recurrence original');
  }
  final last = CalendarDate(year: 2099, month: 12, day: 31);
  if (date == last) return true;
  return eventSchedulingNextDateInWindow(
        content,
        anchor,
        last,
        sharedWorkBudget: work,
      ) ==
      null;
}

/// Proves timed exhaustion with a safely bounded UTC UNTIL or by generating
/// every occurrence required by COUNT within the supported horizon.
bool eventSchedulingTimedIsProvablyLast(
  CalendarEventContent content,
  CalendarEventTiming anchor, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  if (anchor.kind == CalendarEventTimeKind.date ||
      anchor.kind != content.timing.kind ||
      anchor.zoneId != content.timing.zoneId ||
      anchor.end != null ||
      anchor.duration != null) {
    throw ArgumentError('Expected a matching timed original point');
  }
  final start = validateEventTiming(anchor).$2!.start;
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  _proveTimedRuleFinite(content, work);
  if (!eventSchedulingMember(content, anchor, sharedWorkBudget: work)) {
    throw ArgumentError('Anchor is not a recurrence original');
  }
  final last = CalendarEventTiming(
    kind: anchor.kind,
    zoneId: anchor.zoneId,
    start: CalendarEventCivil(
      year: 2099,
      month: 12,
      day: 31,
      hour: 23,
      minute: 59,
      second: 59,
    ),
  );
  final end = validateEventTiming(last).$2!.start;
  if (start.compareTo(end) == 0) return true;
  return eventSchedulingNextTimedInWindow(
        content,
        anchor,
        last,
        sharedWorkBudget: work,
      ) ==
      null;
}

/// Checks complete DATE-series effective values under an explicitly bounded
/// rule. The shared budget covers expansion and every membership projection;
/// neither a limit failure nor an unbounded rule can produce a positive proof.
/// Source metadata, component versions and wire validity need separate checks.
void eventSchedulingProveFiniteDateEquivalence(
  CalendarEventContent content,
  CalendarEventTimingOverrides? basis,
  CalendarEventTimingOverrides? candidate, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  if (content.timing.kind != CalendarEventTimeKind.date) {
    throw ArgumentError('Expected a DATE series');
  }
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  _proveDateRuleFinite(content, work);
  final before = validateEventOverrides(content, basis, sharedWorkBudget: work);
  final after = validateEventOverrides(
    content,
    candidate,
    sharedWorkBudget: work,
  );
  if (before?.cancelledFrom != null || after?.cancelledFrom != null) {
    throw ArgumentError('Masked series cannot establish an active basis');
  }
  final originals = _dateMaster(content).recurrence.expand(
    from: CalendarDate(year: 1970, month: 1, day: 1),
    through: CalendarDate(year: 2099, month: 12, day: 31),
    maxCandidateDays: eventMaxCandidateWork,
    maxRuleOccurrences: eventMaxRuleOccurrences,
    maxResults: eventMaxRuleOccurrences,
    sharedWorkBudget: work,
  );
  for (final original in originals) {
    final point = CalendarEventTiming(
      kind: CalendarEventTimeKind.date,
      start: eventDate(original),
    );
    _eventSchedulingProveOriginal(content, before, after, point, work);
  }
}

void _eventSchedulingProveOriginal(
  CalendarEventContent content,
  CalendarEventTimingOverrides? before,
  CalendarEventTimingOverrides? after,
  CalendarEventTiming point,
  RecurrenceWorkBudget work,
) {
  final key = _anchorKey(point);
  final a = before?.singles
      .where((v) => _anchorKey(v.originalStart) == key)
      .firstOrNull;
  final b = after?.singles
      .where((v) => _anchorKey(v.originalStart) == key)
      .firstOrNull;
  if ((a?.cancelled ?? false) || (b?.cancelled ?? false)) {
    if (!(a?.cancelled ?? false) ||
        !(b?.cancelled ?? false) ||
        jsonEncode(a!.toJson()) != jsonEncode(b!.toJson())) {
      throw ArgumentError('Cancellation projection changed');
    }
    return;
  }
  final first = eventSchedulingOccurrence(
    content,
    before,
    point,
    sharedWorkBudget: work,
  );
  final second = eventSchedulingOccurrence(
    content,
    after,
    point,
    sharedWorkBudget: work,
  );
  if (first == null ||
      second == null ||
      jsonEncode(first.toJson()) != jsonEncode(second.toJson())) {
    throw ArgumentError('Occurrence projection changed');
  }
}

/// Complete finite timed-series comparison, with exact zone identity and UTC
/// bounds covering every supported civil original. Unbounded rules reject.
/// Source metadata, component versions and wire validity need separate checks.
void eventSchedulingProveFiniteTimedEquivalence(
  CalendarEventContent content,
  CalendarEventTimingOverrides? basis,
  CalendarEventTimingOverrides? candidate, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  if (content.timing.kind == CalendarEventTimeKind.date) {
    throw ArgumentError('Expected a timed series');
  }
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  _proveTimedRuleFinite(content, work);
  final before = validateEventOverrides(content, basis, sharedWorkBudget: work);
  final after = validateEventOverrides(
    content,
    candidate,
    sharedWorkBudget: work,
  );
  if (before?.cancelledFrom != null || after?.cancelledFrom != null) {
    throw ArgumentError('Masked series cannot establish an active basis');
  }
  var maximum = Duration.zero;
  var minimum = Duration.zero;
  final zone = content.timing.zoneId;
  if (zone != null) {
    final resolver = NamedZoneResolver();
    maximum = resolver.maximumOffset(zoneId: zone);
    minimum = maximum - resolver.offsetRange(zoneId: zone);
  }
  final originals = _timedOverrides(content, null).recurrence.expand(
    window: UtcWindow(
      start: DateTime.utc(1970).subtract(maximum),
      end: DateTime.utc(2100).subtract(minimum),
    ),
    maxCandidateWork: eventMaxCandidateWork,
    maxRuleOccurrences: eventMaxRuleOccurrences,
    maxResults: eventMaxRuleOccurrences,
    sharedWorkBudget: work,
  );
  for (final value in originals) {
    _eventSchedulingProveOriginal(
      content,
      before,
      after,
      CalendarEventTiming(
        kind: content.timing.kind,
        zoneId: zone,
        start: eventCivil(value.civil),
      ),
      work,
    );
  }
}

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

/// A native-only candidate retaining every individual cancellation verbatim.
/// Wire projection and publication authority must be checked independently.
(CalendarEventTimingOverrides, List<EventSchedulingOriginal>)
eventSchedulingCancelledAnchorStep(
  CalendarEventContent content,
  CalendarEventTimingOverrides input,
  List<EventSchedulingOriginal> retained,
  CalendarEventTiming anchor,
  CalendarEventTiming? next, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final current = validateEventOverrides(
    content,
    input,
    sharedWorkBudget: work,
  )!;
  _profile(content.timing, anchor, anchor: true);
  for (final marker in retained) {
    _profile(content.timing, marker.originalStart, anchor: true);
  }
  final anchorKey = _anchorKey(anchor);
  final cancelled = current.singles.where((s) => s.cancelled).toList();
  if (current.cancelledFrom != null ||
      !cancelled.any((s) => _anchorKey(s.originalStart) == anchorKey)) {
    throw ArgumentError('Expected an individually cancelled anchor');
  }
  final cancellationKeys = cancelled
      .map((s) => _anchorKey(s.originalStart))
      .toSet();
  final frozenMarkers = retained
      .where((v) => cancellationKeys.contains(v.key))
      .toList();
  if (frozenMarkers.any((v) => v.isThisAndFuture) ||
      frozenMarkers.map((v) => v.key).toSet().length != frozenMarkers.length) {
    throw ArgumentError('Invalid retained cancellation identity');
  }
  final active = CalendarEventTimingOverrides(
    singles: current.singles.where((s) => !s.cancelled).toList(),
    future: current.future,
  );
  final activeMarkers = retained
      .where((v) => !cancellationKeys.contains(v.key))
      .toList();
  (CalendarEventTimingOverrides?, List<EventSchedulingOriginal>) projected;
  if (next == null) {
    final last = anchor.kind == CalendarEventTimeKind.date
        ? eventSchedulingDateIsProvablyLast(
            content,
            anchor,
            sharedWorkBudget: work,
          )
        : eventSchedulingTimedIsProvablyLast(
            content,
            anchor,
            sharedWorkBudget: work,
          );
    if (!last) throw ArgumentError('Anchor is not the last original');
    projected = eventSchedulingProjection(
      content,
      active,
      activeMarkers,
      sharedWorkBudget: work,
    );
  } else {
    _profile(content.timing, next, anchor: true);
    final successor = anchor.kind == CalendarEventTimeKind.date
        ? eventSchedulingNextDateInWindow(
            content,
            anchor,
            _date(next.start),
            sharedWorkBudget: work,
          )
        : eventSchedulingNextTimedInWindow(
            content,
            anchor,
            next,
            sharedWorkBudget: work,
          );
    if (successor == null ||
        _anchorKey(successor) != _anchorKey(next) ||
        cancellationKeys.contains(_anchorKey(next))) {
      throw ArgumentError('Unsupported successor identity');
    }
    projected = eventSchedulingRangeRestoration(
      content,
      active,
      activeMarkers,
      next,
      sharedWorkBudget: work,
    );
  }
  final restored = validateEventOverrides(
    content,
    CalendarEventTimingOverrides(
      singles: [...?projected.$1?.singles, ...cancelled],
      future: projected.$1?.future ?? [],
    ),
    sharedWorkBudget: work,
  )!;
  final markers = [...projected.$2, ...frozenMarkers];
  if ({
        for (final v in markers) v.key,
        for (final v in restored.singles) _anchorKey(v.originalStart),
        for (final v in restored.future) _anchorKey(v.originalStart),
      }.length >
      64) {
    throw const RecurrenceLimitException('schedulingOriginals');
  }
  return (restored, List.unmodifiable(markers));
}

/// Checks a cancellation-preserving native candidate against every supported
/// original in a bounded series. It does not validate a scheduling message.
(CalendarEventTimingOverrides, List<EventSchedulingOriginal>)
eventSchedulingProvenCancelledAnchorStep(
  CalendarEventContent content,
  CalendarEventTimingOverrides input,
  List<EventSchedulingOriginal> retained,
  CalendarEventTiming anchor,
  CalendarEventTiming? next, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final result = eventSchedulingCancelledAnchorStep(
    content,
    input,
    retained,
    anchor,
    next,
    sharedWorkBudget: work,
  );
  if (content.timing.kind == CalendarEventTimeKind.date) {
    eventSchedulingProveFiniteDateEquivalence(
      content,
      input,
      result.$1,
      sharedWorkBudget: work,
    );
  } else {
    eventSchedulingProveFiniteTimedEquivalence(
      content,
      input,
      result.$1,
      sharedWorkBudget: work,
    );
  }
  return result;
}

/// Projects an active exceptional anchor and its proven next original, or a
/// last original when the bounded recurrence can be proved exhausted.
///
/// This native projection is one step in constructing a scheduling candidate;
/// it does not validate a wire message or establish publication authority.
/// Individual cancellations and wire/version handling are
/// deliberately outside this helper and must not be inferred from its result.
(CalendarEventTimingOverrides, List<EventSchedulingOriginal>)
eventSchedulingExceptionalAnchorStep(
  CalendarEventContent content,
  CalendarEventTimingOverrides input,
  List<EventSchedulingOriginal> retained,
  CalendarEventTiming anchor,
  CalendarEventTiming? next, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final current = validateEventOverrides(
    content,
    input,
    sharedWorkBudget: work,
  );
  final key = _anchorKey(anchor);
  final own = current?.singles
      .where((s) => _anchorKey(s.originalStart) == key)
      .firstOrNull;
  if (own == null ||
      own.cancelled ||
      current?.cancelledFrom != null ||
      (current?.singles.any((s) => s.cancelled) ?? false)) {
    throw ArgumentError('Expected an active exceptional anchor');
  }
  if (next == null) {
    final last = anchor.kind == CalendarEventTimeKind.date
        ? eventSchedulingDateIsProvablyLast(
            content,
            anchor,
            sharedWorkBudget: work,
          )
        : eventSchedulingTimedIsProvablyLast(
            content,
            anchor,
            sharedWorkBudget: work,
          );
    if (!last) throw ArgumentError('Anchor is not the last original');
  } else {
    _profile(content.timing, next, anchor: true);
    final actualNext = anchor.kind == CalendarEventTimeKind.date
        ? eventSchedulingNextDateInWindow(
            content,
            anchor,
            _date(next.start),
            sharedWorkBudget: work,
          )
        : eventSchedulingNextTimedInWindow(
            content,
            anchor,
            next,
            sharedWorkBudget: work,
          );
    if (actualNext == null || _anchorKey(actualNext) != _anchorKey(next)) {
      throw ArgumentError('Next original is not the first successor');
    }
  }
  final markers = [...retained];
  final anchorMarkers = markers.where((m) => m.key == key).toList();
  if (anchorMarkers.length > 1 ||
      (anchorMarkers.isNotEmpty && anchorMarkers.single.isThisAndFuture)) {
    throw ArgumentError('Incompatible retained anchor');
  }
  if (anchorMarkers.isEmpty) {
    markers.add(EventSchedulingOriginal(anchor, false));
  }
  if (next == null) {
    final result = eventSchedulingProjection(
      content,
      current,
      markers,
      sharedWorkBudget: work,
    );
    return (result.$1!, result.$2);
  }
  return eventSchedulingRangeRestoration(
    content,
    current,
    markers,
    next,
    sharedWorkBudget: work,
  );
}

/// Builds and checks the native portion of an exceptional-anchor candidate.
/// This bounded proof is deliberately separate from wire validation and must
/// not be used as evidence of authority or a completed scheduling message.
(CalendarEventTimingOverrides, List<EventSchedulingOriginal>)
eventSchedulingProvenExceptionalAnchorStep(
  CalendarEventContent content,
  CalendarEventTimingOverrides input,
  List<EventSchedulingOriginal> retained,
  CalendarEventTiming anchor,
  CalendarEventTiming? next, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final result = eventSchedulingExceptionalAnchorStep(
    content,
    input,
    retained,
    anchor,
    next,
    sharedWorkBudget: work,
  );
  if (content.timing.kind == CalendarEventTimeKind.date) {
    eventSchedulingProveFiniteDateEquivalence(
      content,
      input,
      result.$1,
      sharedWorkBudget: work,
    );
  } else {
    eventSchedulingProveFiniteTimedEquivalence(
      content,
      input,
      result.$1,
      sharedWorkBudget: work,
    );
  }
  return result;
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
