part of 'event_values.dart';

const eventMaxOverrides = 128;

void _profile(
  CalendarEventTiming master,
  CalendarEventTiming value, {
  bool anchor = false,
}) {
  if (master.kind != value.kind ||
      master.zoneId != value.zoneId ||
      (anchor && (value.end != null || value.duration != null))) {
    throw ArgumentError(
      'Occurrence timing requires the exact master profile; anchors have no span',
    );
  }
  validateEventTiming(value);
}

String _anchorKey(CalendarEventTiming v) {
  final c = v.start;
  return [
    c.year,
    c.month,
    c.day,
    c.hour,
    c.minute,
    c.second,
  ].map((n) => n.toString().padLeft(4, '0')).join(':');
}

DateEventSeries _dateMaster(CalendarEventContent c) => DateEventSeries(
  span: validateEventTiming(c.timing).$1!,
  recurrence: DateRecurrenceSet(
    start: _date(c.timing.start),
    rule: eventDateRule(c.recurrence?.rule),
    inclusions:
        c.recurrence?.inclusions.map((v) => _date(v.start)).toList() ?? [],
    exclusions:
        c.recurrence?.exclusions.map((v) => _date(v.start)).toList() ?? [],
    maxExplicitDates: eventMaxExplicitDates,
  ),
);

DateEventRangeSet _dateOverrides(
  CalendarEventContent c,
  CalendarEventTimingOverrides? v, {
  bool validateContentOnly = false,
  RecurrenceWorkBudget? sharedWorkBudget,
}) => DateEventRangeSet(
  base: DateEventExceptionSet(
    series: _dateMaster(c),
    exceptions: [
      for (final item in v?.singles ?? <CalendarEventSingleOverride>[])
        // Validation-only cancellation proves membership without inventing time.
        if (item.cancelled || (validateContentOnly && item.replacement == null))
          DateEventException.cancel(
            originalStart: _date(item.originalStart.start),
          )
        else if (item.replacement != null)
          DateEventException.replace(
            originalStart: _date(item.originalStart.start),
            replacement: validateEventTiming(item.replacement!).$1!,
          ),
    ],
    sharedWorkBudget: sharedWorkBudget,
    maxExceptions: eventMaxOverrides,
    maxValidationCandidateDays: eventMaxCandidateWork,
    maxValidationRuleOccurrences: eventMaxRuleOccurrences,
    maxValidationResults: eventMaxRuleOccurrences,
  ),
  changes: [
    for (final item in v?.future ?? <CalendarEventFutureOverride>[])
      DateEventRangeChange(
        originalStart: _date(item.originalStart.start),
        replacement: validateEventTiming(item.replacement).$1!,
      ),
  ],
  sharedWorkBudget: sharedWorkBudget,
  maxRangeChanges: eventMaxOverrides,
  maxValidationCandidateDays: eventMaxCandidateWork,
  maxValidationRuleOccurrences: eventMaxRuleOccurrences,
  maxValidationResults: eventMaxRuleOccurrences,
);

TimedEventSeries _timedOverrides(
  CalendarEventContent c,
  CalendarEventTimingOverrides? v, {
  List<CalendarEventTiming>? periods,
  RecurrenceWorkBudget? sharedWorkBudget,
  bool validateContentOnly = false,
}) {
  final span = validateEventTiming(c.timing).$2!;
  return TimedEventSeries(
    span: span,
    recurrence: TimedRecurrenceSet(
      start: span.start,
      rule: eventTimedRule(c.recurrence?.rule),
      inclusions:
          c.recurrence?.inclusions
              .map((v) => validateEventTiming(v).$2!.start)
              .toList() ??
          [],
      exclusions:
          c.recurrence?.exclusions
              .map((v) => validateEventTiming(v).$2!.start)
              .toList() ??
          [],
      periods: [
        for (final p in periods ?? c.periods ?? <CalendarEventTiming>[])
          validateEventTiming(p).$2!,
      ],
      maxExplicitDates: eventMaxExplicitDates,
    ),
    exceptions: [
      for (final item in v?.singles ?? <CalendarEventSingleOverride>[])
        if (item.cancelled || (validateContentOnly && item.replacement == null))
          TimedEventException.cancel(
            validateEventTiming(item.originalStart).$2!.start,
          )
        else if (item.replacement != null)
          TimedEventException.replace(
            validateEventTiming(item.originalStart).$2!.start,
            validateEventTiming(item.replacement!).$2!,
          ),
    ],
    changes: [
      for (final item in v?.future ?? <CalendarEventFutureOverride>[])
        TimedEventRangeChange(
          originalStart: validateEventTiming(item.originalStart).$2!.start,
          replacement: validateEventTiming(item.replacement).$2!,
        ),
    ],
    maxChanges: eventMaxOverrides,
    sharedWorkBudget: sharedWorkBudget,
    maxValidationCandidateWork: eventMaxCandidateWork,
    maxValidationOccurrences: eventMaxRuleOccurrences,
  );
}

/// Freeze all stored/proposed timing state and validate original membership.
CalendarEventTimingOverrides? validateEventOverrides(
  CalendarEventContent c,
  CalendarEventTimingOverrides? input, {
  List<CalendarEventTiming>? periods,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  if (input == null) return null;
  if (input.singles.length + input.future.length > eventMaxOverrides) {
    throw const RecurrenceLimitException('maxOverrides');
  }
  if (input.singles.isEmpty && input.future.isEmpty) return null;
  final keys = <String>{};
  void anchor(CalendarEventTiming a) {
    _profile(c.timing, a, anchor: true);
    if (!keys.add(_anchorKey(a))) {
      throw ArgumentError('Duplicate or colliding single/future anchor');
    }
  }

  final singles = <CalendarEventSingleOverride>[],
      future = <CalendarEventFutureOverride>[];
  for (final item in input.singles) {
    anchor(item.originalStart);
    final own = validateEventOccurrenceContent(item.contentOverrides);
    final metadata = validateEventSourceMetadata(item.sourceMetadata);
    if ((own != null || metadata != null) &&
        c.recurrence == null &&
        (c.periods?.isEmpty ?? true)) {
      throw ArgumentError('Content exceptions require recurrence');
    }
    if (item.replacement == null &&
        !item.cancelled &&
        own == null &&
        metadata == null) {
      throw ArgumentError('Empty single override');
    }
    if (item.replacement != null) _profile(c.timing, item.replacement!);
    singles.add(item.copyWith(contentOverrides: own, sourceMetadata: metadata));
  }
  for (final item in input.future) {
    anchor(item.originalStart);
    _profile(c.timing, item.replacement);
    if ((item.contentOverrides != null || item.sourceMetadata != null) &&
        c.recurrence == null &&
        (c.periods?.isEmpty ?? true)) {
      throw ArgumentError('Content exceptions require recurrence');
    }
    future.add(
      item.copyWith(
        contentOverrides: validateEventOccurrenceContent(item.contentOverrides),
        sourceMetadata: validateEventSourceMetadata(item.sourceMetadata),
      ),
    );
  }
  final result = CalendarEventTimingOverrides(
    singles: List.unmodifiable(
      singles..sort(
        (a, b) =>
            _anchorKey(a.originalStart).compareTo(_anchorKey(b.originalStart)),
      ),
    ),
    future: List.unmodifiable(
      future..sort(
        (a, b) =>
            _anchorKey(a.originalStart).compareTo(_anchorKey(b.originalStart)),
      ),
    ),
  );
  if (c.timing.kind == CalendarEventTimeKind.date) {
    _dateOverrides(
      c,
      result,
      validateContentOnly: true,
      sharedWorkBudget: sharedWorkBudget,
    );
  } else {
    _timedOverrides(
      c,
      result,
      periods: periods,
      validateContentOnly: true,
      sharedWorkBudget: sharedWorkBudget,
    );
  }
  return result;
}

/// Dedicated action intent. Master content is never rewritten by this operation.
CalendarEventTimingOverrides? changeEventOverrides(
  CalendarEventContent c,
  CalendarEventTimingOverrides? current,
  CalendarEventOccurrenceChange request, {
  List<CalendarEventTiming>? periods,
}) {
  _profile(c.timing, request.originalStart, anchor: true);
  final replace =
      request.action == CalendarEventOccurrenceAction.replaceSingleTiming ||
      request.action == CalendarEventOccurrenceAction.replaceFutureTiming;
  if (replace != (request.replacement != null)) {
    throw ArgumentError('Replacement is required only for timing replacement');
  }
  if (request.replacement != null) _profile(c.timing, request.replacement!);
  final key = _anchorKey(request.originalStart);
  final singles = [...?current?.singles];
  final future = [...?current?.future];
  final index = singles.indexWhere((v) => _anchorKey(v.originalStart) == key);
  final rangeIndex = future.indexWhere(
    (v) => _anchorKey(v.originalStart) == key,
  );
  final previous = index < 0 ? null : singles[index];
  switch (request.action) {
    case CalendarEventOccurrenceAction.replaceSingleTiming:
    case CalendarEventOccurrenceAction.cancelSingle:
    case CalendarEventOccurrenceAction.restoreSingle:
    case CalendarEventOccurrenceAction.clearSingleTiming:
      if (rangeIndex >= 0) {
        throw ArgumentError(
          'Clear the future anchor explicitly before adding a single override there',
        );
      }
      if ((request.action == CalendarEventOccurrenceAction.restoreSingle &&
              previous?.cancelled != true) ||
          (request.action == CalendarEventOccurrenceAction.clearSingleTiming &&
              previous?.replacement == null)) {
        throw ArgumentError('No corresponding single change to remove');
      }
      if (index >= 0) singles.removeAt(index);
      final replacement = switch (request.action) {
        CalendarEventOccurrenceAction.replaceSingleTiming =>
          request.replacement,
        CalendarEventOccurrenceAction.clearSingleTiming => null,
        _ => previous?.replacement,
      };
      final cancelled = switch (request.action) {
        CalendarEventOccurrenceAction.cancelSingle => true,
        CalendarEventOccurrenceAction.restoreSingle => false,
        _ => previous?.cancelled ?? false,
      };
      if (replacement != null ||
          cancelled ||
          previous?.contentOverrides != null ||
          previous?.sourceMetadata != null) {
        singles.add(
          CalendarEventSingleOverride(
            originalStart: request.originalStart,
            replacement: replacement,
            cancelled: cancelled,
            contentOverrides: previous?.contentOverrides,
            sourceMetadata: previous?.sourceMetadata,
          ),
        );
      }
    case CalendarEventOccurrenceAction.replaceFutureTiming:
    case CalendarEventOccurrenceAction.clearFutureTiming:
      if (index >= 0 && (previous!.replacement != null || previous.cancelled)) {
        throw ArgumentError(
          'Clear the single anchor explicitly before adding a future override there',
        );
      }
      if (rangeIndex < 0 && !replace) {
        throw ArgumentError('No future change to remove');
      }
      final own = rangeIndex >= 0
          ? future[rangeIndex].contentOverrides
          : previous?.contentOverrides;
      final metadata = rangeIndex >= 0
          ? future[rangeIndex].sourceMetadata
          : previous?.sourceMetadata;
      if (rangeIndex >= 0) future.removeAt(rangeIndex);
      if (index >= 0) singles.removeAt(index);
      if (replace) {
        future.add(
          CalendarEventFutureOverride(
            originalStart: request.originalStart,
            replacement: request.replacement!,
            contentOverrides: own,
            sourceMetadata: metadata,
          ),
        );
      } else if (own != null || metadata != null) {
        singles.add(
          CalendarEventSingleOverride(
            originalStart: request.originalStart,
            contentOverrides: own,
            sourceMetadata: metadata,
          ),
        );
      }
  }
  return validateEventOverrides(
    c,
    CalendarEventTimingOverrides(singles: singles, future: future),
    periods: periods,
  );
}

/// Internal authenticated busy projection; no event details escape this adapter.
List<UtcWindow> eventOccupiedWindows(
  CalendarEventContent c,
  CalendarEventTimingOverrides? overrides,
  UtcWindow window, {
  required String dateZone,
  List<CalendarEventTiming>? periods,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  if (c.status == CalendarEventStatus.cancelled ||
      c.transparency == CalendarEventTransparency.transparent) {
    return const [];
  }
  final result = <UtcWindow>[];
  if (c.timing.kind == CalendarEventTimeKind.date) {
    final resolver = NamedZoneResolver();
    // Prove all queried offsets, not only two endpoints across unknown data.
    resolver.snapshot(zoneId: dateZone, horizon: window, maxTransitions: 256);
    final from = resolver.localAt(window.start, zoneId: dateZone).date;
    final until = resolver
        .localAt(
          window.end.subtract(const Duration(seconds: 1)),
          zoneId: dateZone,
        )
        .date
        .addDays(1);
    for (final occurrence in _dateOverrides(c, overrides).expandOverlapping(
      from: from,
      until: until,
      maxCandidateDays: eventMaxCandidateWork,
      maxRuleOccurrences: eventMaxRuleOccurrences,
      maxBaseOccurrences: eventMaxRuleOccurrences,
      maxResults: eventMaxPreviewResults,
    )) {
      final occupied = occurrence.span.occupiedWindowIn(zoneId: dateZone);
      final clipped = occupied?.intersection(window);
      if (clipped != null) result.add(clipped);
    }
  } else {
    for (final occurrence
        in _timedOverrides(
          c,
          overrides,
          periods: periods,
          sharedWorkBudget: sharedWorkBudget,
        ).expandOverlapping(
          window: window,
          sharedWorkBudget: sharedWorkBudget,
          maxCandidateWork: eventMaxCandidateWork,
          maxRuleOccurrences: eventMaxRuleOccurrences,
          maxBaseOccurrences: eventMaxRuleOccurrences,
          maxResults: eventMaxPreviewResults,
        )) {
      final clipped = occurrence.span.occupiedWindow?.intersection(window);
      if (clipped != null) result.add(clipped);
    }
  }
  return List.unmodifiable(result);
}
