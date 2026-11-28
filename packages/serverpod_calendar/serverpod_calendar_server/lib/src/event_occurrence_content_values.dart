part of 'event_values.dart';

const eventOccurrenceContentGroups = {
  CalendarEventFieldGroup.summary,
  CalendarEventFieldGroup.description,
  CalendarEventFieldGroup.location,
};

CalendarEventOccurrenceContent? eventComponentContent(Object component) =>
    component is CalendarEventSingleOverride
    ? component.contentOverrides
    : (component as CalendarEventFutureOverride).contentOverrides;

CalendarEventTimingOverrides? eventDisclosedOverrides(
  CalendarEventTimingOverrides? value,
  Set<CalendarEventFieldGroup> groups,
) {
  if (value == null) return null;
  final singles = <CalendarEventSingleOverride>[];
  for (final row in value.singles) {
    final own = eventDisclosedOccurrenceContent(row.contentOverrides, groups);
    if (row.cancelled || row.replacement != null || own != null) {
      singles.add(row.copyWith(contentOverrides: own));
    }
  }
  final future = [
    for (final row in value.future)
      row.copyWith(
        contentOverrides: eventDisclosedOccurrenceContent(
          row.contentOverrides,
          groups,
        ),
      ),
  ];
  return singles.isEmpty && future.isEmpty
      ? null
      : CalendarEventTimingOverrides(
          singles: List.unmodifiable(singles),
          future: List.unmodifiable(future),
        );
}

CalendarEventOccurrenceContent? validateEventOccurrenceContent(
  CalendarEventOccurrenceContent? value,
) {
  if (value == null) return null;
  for (final pair in [
    (value.summary, 4096),
    (value.description, 16384),
    (value.location, 4096),
  ]) {
    if (pair.$1 != null) {
      validateCalendarPlainText(pair.$1!, maxCodePoints: pair.$2);
    }
  }
  final a = _eventTextParameter(value.textParameters?.summary, value.summary),
      b = _eventTextParameter(
        value.textParameters?.description,
        value.description,
      ),
      c = _eventTextParameter(value.textParameters?.location, value.location);
  if (value.summary == null &&
      value.description == null &&
      value.location == null) {
    return null;
  }
  return value.copyWith(
    textParameters: a == null && b == null && c == null
        ? null
        : CalendarEventTextParameters(summary: a, description: b, location: c),
  );
}

CalendarEventOccurrenceContent eventEffectiveOccurrenceContent(
  CalendarEventContent master,
  CalendarEventOccurrenceContent? own,
) =>
    validateEventOccurrenceContent(
      CalendarEventOccurrenceContent(
        summary: own?.summary ?? master.summary,
        description: own?.description ?? master.description,
        location: own?.location ?? master.location,
        textParameters: CalendarEventTextParameters(
          summary: own?.summary != null
              ? own?.textParameters?.summary
              : master.textParameters?.summary,
          description: own?.description != null
              ? own?.textParameters?.description
              : master.textParameters?.description,
          location: own?.location != null
              ? own?.textParameters?.location
              : master.textParameters?.location,
        ),
      ),
    ) ??
    CalendarEventOccurrenceContent();

CalendarEventOccurrenceContent? eventDisclosedOccurrenceContent(
  CalendarEventOccurrenceContent? value,
  Set<CalendarEventFieldGroup> groups,
) => value == null
    ? null
    : validateEventOccurrenceContent(
        CalendarEventOccurrenceContent(
          summary: groups.contains(CalendarEventFieldGroup.summary)
              ? value.summary
              : null,
          description: groups.contains(CalendarEventFieldGroup.description)
              ? value.description
              : null,
          location: groups.contains(CalendarEventFieldGroup.location)
              ? value.location
              : null,
          textParameters: CalendarEventTextParameters(
            summary: groups.contains(CalendarEventFieldGroup.summary)
                ? value.textParameters?.summary
                : null,
            description: groups.contains(CalendarEventFieldGroup.description)
                ? value.textParameters?.description
                : null,
            location: groups.contains(CalendarEventFieldGroup.location)
                ? value.textParameters?.location
                : null,
          ),
        ),
      );

CalendarEventOccurrenceContent? eventOriginalContent(
  CalendarEventTimingOverrides? overrides,
  CalendarEventTiming original,
) {
  final key = _anchorKey(original);
  for (final s in overrides?.singles ?? <CalendarEventSingleOverride>[]) {
    if (_anchorKey(s.originalStart) == key) return s.contentOverrides;
  }
  for (final s in overrides?.future ?? <CalendarEventFutureOverride>[]) {
    if (_anchorKey(s.originalStart) == key) return s.contentOverrides;
  }
  return null;
}

CalendarEventOccurrenceContent? changeEventOccurrenceContentValues(
  CalendarEventContent master,
  CalendarEventOccurrenceContent? before,
  List<CalendarEventOccurrenceContentChange> changes,
) {
  if (changes.isEmpty ||
      changes.length > 3 ||
      changes.map((c) => c.field).toSet().length != changes.length) {
    throw ArgumentError('One to three unique content fields required');
  }
  var own = before ?? CalendarEventOccurrenceContent();
  for (final change in changes) {
    if (change.action == CalendarEventContentAction.setValue
        ? change.text == null || change.text!.isEmpty
        : change.text != null) {
      throw ArgumentError(
        'Set requires nonempty text; clear/inherit has no value',
      );
    }
    final effective = eventEffectiveOccurrenceContent(master, own);
    final text = switch (change.action) {
      CalendarEventContentAction.setValue => change.text,
      CalendarEventContentAction.clearValue => '',
      CalendarEventContentAction.inheritSeries => null,
    };
    var annotations = own.textParameters ?? CalendarEventTextParameters();
    switch (change.field) {
      case CalendarEventContentField.summary:
        annotations = annotations.copyWith(
          summary: change.action == CalendarEventContentAction.setValue
              ? effective.textParameters?.summary
              : null,
        );
        own = own.copyWith(summary: text, textParameters: annotations);
      case CalendarEventContentField.description:
        annotations = annotations.copyWith(
          description: change.action == CalendarEventContentAction.setValue
              ? effective.textParameters?.description
              : null,
        );
        own = own.copyWith(description: text, textParameters: annotations);
      case CalendarEventContentField.location:
        annotations = annotations.copyWith(
          location: change.action == CalendarEventContentAction.setValue
              ? effective.textParameters?.location
              : null,
        );
        own = own.copyWith(location: text, textParameters: annotations);
    }
  }
  return validateEventOccurrenceContent(own);
}

CalendarEventTimingOverrides? changeEventContentOverrides(
  CalendarEventContent content,
  CalendarEventTimingOverrides? current,
  CalendarEventOccurrenceContentRequest request,
) {
  if (content.recurrence == null && (content.periods?.isEmpty ?? true)) {
    throw ArgumentError('Content exceptions require recurrence');
  }
  _profile(content.timing, request.originalStart, anchor: true);
  final key = _anchorKey(request.originalStart),
      singles = [...?current?.singles],
      future = [...?current?.future];
  final i = singles.indexWhere((v) => _anchorKey(v.originalStart) == key),
      r = future.indexWhere((v) => _anchorKey(v.originalStart) == key);
  final own = changeEventOccurrenceContentValues(
    content,
    eventOriginalContent(current, request.originalStart),
    request.changes,
  );
  if (i < 0 && r < 0 && own == null) {
    // Validate even an inherit-only no-op at a new original; never store this probe.
    validateEventOverrides(
      content,
      CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: request.originalStart,
            cancelled: true,
          ),
        ],
        future: const [],
      ),
    );
    // A membership probe must not consume a stored override slot at capacity.
    return validateEventOverrides(content, current);
  }
  if (r >= 0) {
    future[r] = future[r].copyWith(contentOverrides: own);
  } else if (i >= 0) {
    final old = singles.removeAt(i);
    if (old.replacement != null || old.cancelled || own != null) {
      singles.add(old.copyWith(contentOverrides: own));
    }
  } else {
    singles.add(
      CalendarEventSingleOverride(
        originalStart: request.originalStart,
        contentOverrides: own,
      ),
    );
  }
  return validateEventOverrides(
    content,
    CalendarEventTimingOverrides(singles: singles, future: future),
  );
}
