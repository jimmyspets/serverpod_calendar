part of 'icalendar_event_calendar.dart';

enum IcalendarTaskStatus { needsAction, inProcess, completed, cancelled }

final class IcalendarTaskText {
  IcalendarTaskText._(IcalendarEventText text)
    : value = text.value,
      language = text.language,
      alternativeUri = text.alternativeUri;
  final String value;
  final String? language, alternativeUri;
}

final class IcalendarTaskRecurrence {
  IcalendarTaskRecurrence._(IcalendarEventRecurrence value)
    : dateSet = value.dateSet,
      timedSet = value.timedSet;
  final DateRecurrenceSet? dateSet;
  final TimedRecurrenceSet? timedSet;
}

/// Source progress properties remain independently optional. This is not native
/// progress, assignment authority or retrospective completion-history evidence.
final class IcalendarTask {
  IcalendarTask._({
    required this.source,
    required this.uid,
    required this.stamp,
    required this.metadata,
    required this.participants,
    required this.references,
    required this.alarms,
    this.created,
    this.lastModified,
    this.sequence,
    this.dateTiming,
    this.timedTiming,
    this.recurrence,
    this.summary,
    this.description,
    this.location,
    this.priority,
    this.status,
    this.percentComplete,
    this.completed,
    this.recurrenceDate,
    this.recurrenceTime,
  });
  final IcalendarSyntaxComponent source;
  final String uid;
  final DateTime stamp;
  final DateTime? created, lastModified, completed;
  final int? sequence, priority, percentComplete;
  final IcalendarTaskStatus? status;
  final DateTaskTiming? dateTiming;
  final TimedTaskTiming? timedTiming;
  final IcalendarTaskRecurrence? recurrence;
  final IcalendarTaskText? summary, description, location;
  final IcalendarTaskMetadata metadata;
  final IcalendarTaskParticipants participants;
  final IcalendarTaskReferences references;
  final List<IcalendarDisplayAlarm> alarms;
  final CalendarDate? recurrenceDate;
  final TimedValue? recurrenceTime;
  Object? get originalStart => recurrenceDate ?? recurrenceTime;
  bool get isOverride => originalStart != null;
  bool get isUndated =>
      !isOverride && dateTiming == null && timedTiming == null;
}

/// Bounded standalone masters and progress components; no database authority.
final class IcalendarTaskCalendar {
  IcalendarTaskCalendar._(
    this.source,
    this.productId,
    Iterable<IcalendarTaskSeries> series,
    Map<String, IcalendarValidatedTimeZone> zones,
  ) : series = List.unmodifiable(series),
      tasks = List.unmodifiable(series.map((s) => s.master)),
      timeZones = Map.unmodifiable(zones);
  final IcalendarSyntaxDocument source;
  final String productId;
  final List<IcalendarTask> tasks;
  final List<IcalendarTaskSeries> series;
  final Map<String, IcalendarValidatedTimeZone> timeZones;
}

IcalendarTaskCalendar parseIcalendarTaskCalendar(
  List<int> bytes, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => validateIcalendarTaskCalendar(
  parseIcalendarSyntax(bytes, limits: syntaxLimits),
  syntaxLimits: syntaxLimits,
  limits: limits,
);

IcalendarTaskCalendar validateIcalendarTaskCalendar(
  IcalendarSyntaxDocument source, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) {
  limits.validate();
  serializeIcalendarSyntax(source, limits: syntaxLimits);
  return componentGuard(() {
    if (source.components.length != 1 ||
        source.components.single.canonicalName != 'VCALENDAR') {
      componentFail(IcalendarComponentError.unsupportedComponent);
    }
    final calendar = source.components.single;
    final properties = componentProperties(calendar, {
      'PRODID',
      'VERSION',
      'CALSCALE',
    });
    final version = requiredProperty(properties, 'VERSION');
    componentParameters(version, {});
    if (version.value != '2.0') {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final producer = componentText(requiredProperty(properties, 'PRODID'));
    if (producer.isEmpty) componentFail(IcalendarComponentError.invalidValue);
    final scale = properties['CALSCALE']?.single;
    if (scale != null) {
      componentParameters(scale, {});
      if (componentToken(scale.value) != 'GREGORIAN') {
        componentFail(IcalendarComponentError.invalidValue);
      }
    }
    final budget = ComponentBudget(limits),
        zones = <String, IcalendarValidatedTimeZone>{},
        raw = <IcalendarSyntaxComponent>[];
    for (final component
        in calendar.entries.whereType<IcalendarSyntaxComponent>()) {
      if (component.canonicalName == 'VTIMEZONE') {
        if (zones.length >= limits.maxZones) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        final zone = validateComponentTimeZone(component, budget);
        if (zones.containsKey(zone.zoneId)) {
          componentFail(IcalendarComponentError.duplicate);
        }
        zones[zone.zoneId] = zone;
      } else if (component.canonicalName == 'VTODO') {
        if (raw.length >= limits.maxTasks) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        raw.add(component);
      } else {
        componentFail(IcalendarComponentError.unsupportedComponent);
      }
    }
    if (raw.isEmpty) componentFail(IcalendarComponentError.missing);
    final tasks = <String, IcalendarTask>{},
        overrides = <String, List<IcalendarTask>>{};
    for (final component in raw) {
      final task = _taskComponent(component, zones, budget);
      if (task.isOverride) {
        final group = overrides.putIfAbsent(task.uid, () => []);
        if (group.length >= limits.maxOverridesPerTask) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        group.add(task);
      } else {
        if (tasks.containsKey(task.uid)) {
          componentFail(IcalendarComponentError.duplicate);
        }
        tasks[task.uid] = task;
      }
    }
    if (overrides.keys.any((uid) => !tasks.containsKey(uid))) {
      componentFail(IcalendarComponentError.missing);
    }
    return IcalendarTaskCalendar._(source, producer, [
      for (final master in tasks.values)
        _taskSeries(master, overrides[master.uid] ?? [], budget),
    ], zones);
  });
}

Uint8List serializeIcalendarTaskCalendar(
  IcalendarTaskCalendar value, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
}) => serializeIcalendarSyntax(
  IcalendarSyntaxDocument(value.source.components.map(_outputComponent)),
  limits: syntaxLimits,
);

IcalendarTask _taskComponent(
  IcalendarSyntaxComponent source,
  Map<String, IcalendarValidatedTimeZone> zones,
  ComponentBudget budget,
) {
  if (source.entries.whereType<IcalendarSyntaxComponent>().any(
    (e) => e.canonicalName != 'VALARM',
  )) {
    componentFail(IcalendarComponentError.unsupportedComponent);
  }
  final p = componentProperties(
    source,
    {
      'UID',
      'DTSTAMP',
      'DTSTART',
      'DUE',
      'DURATION',
      'SUMMARY',
      'DESCRIPTION',
      'LOCATION',
      'PRIORITY',
      'STATUS',
      'PERCENT-COMPLETE',
      'COMPLETED',
      'CREATED',
      'LAST-MODIFIED',
      'SEQUENCE',
      'RRULE',
      'RDATE',
      'EXDATE',
      'RECURRENCE-ID',
      ..._taskMetadataProperties,
      'RELATED-TO',
      'ATTACH',
      'ORGANIZER',
      'ATTENDEE',
    },
    repeated: {
      'RDATE',
      'EXDATE',
      ..._taskRepeatedMetadata,
      'ATTENDEE',
      'RELATED-TO',
      'ATTACH',
    },
  );
  final uid = componentText(requiredProperty(p, 'UID'));
  if (uid.isEmpty) componentFail(IcalendarComponentError.invalidValue);
  budget.taskMetadata(uid.runes.length);
  final stamp = componentUtc(requiredProperty(p, 'DTSTAMP'));
  Object? temporal(String name) =>
      p[name] == null ? null : _temporal(p[name]!.single, zones);
  final original = temporal('RECURRENCE-ID');
  if (original != null && ['RRULE', 'RDATE', 'EXDATE'].any(p.containsKey)) {
    componentFail(IcalendarComponentError.unsupportedProperty);
  }
  final start = temporal('DTSTART'), due = temporal('DUE');
  CalendarDuration? duration;
  if (p['DURATION'] != null) {
    final prop = p['DURATION']!.single;
    componentParameters(prop, {});
    duration = parseIcalendarDuration(prop.value);
  }
  DateTaskTiming? dateTiming;
  TimedTaskTiming? timedTiming;
  if (start is CalendarDate || (start == null && due is CalendarDate)) {
    if (due != null && due is! CalendarDate) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    dateTiming = DateTaskTiming(
      start: start as CalendarDate?,
      due: due as CalendarDate?,
      duration: duration,
    );
  } else if (start is TimedValue || due is TimedValue) {
    if ((start != null && start is! TimedValue) ||
        (due != null && due is! TimedValue)) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    timedTiming = TimedTaskTiming(
      start: start as TimedValue?,
      due: due as TimedValue?,
      duration: duration,
    );
  } else if (duration != null) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  for (final property in p['RDATE'] ?? <IcalendarSyntaxProperty>[]) {
    final parameters = componentParameters(property, {'VALUE', 'TZID'});
    if (parameters['VALUE'] != null &&
        componentToken(parameters['VALUE']!) == 'PERIOD') {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
  }
  IcalendarTaskRecurrence? recurrence;
  if (['RRULE', 'RDATE', 'EXDATE'].any(p.containsKey)) {
    if (start == null) componentFail(IcalendarComponentError.missing);
    recurrence = IcalendarTaskRecurrence._(
      componentEventRecurrence(
        start,
        p,
        budget,
        (property, exclusiveEnd) =>
            _temporal(property, zones, exclusiveEnd: exclusiveEnd),
      )!,
    );
  }
  IcalendarTaskText? text(String name, int limit) {
    final parsed = _componentTextValue(p[name]?.single, limit);
    if (parsed == null) return null;
    budget.taskMetadata(
      parsed.value.runes.length +
          (parsed.language?.runes.length ?? 0) +
          (parsed.alternativeUri?.runes.length ?? 0),
    );
    return IcalendarTaskText._(parsed);
  }

  IcalendarTaskStatus? status;
  if (p['STATUS'] != null) {
    final property = p['STATUS']!.single;
    componentParameters(property, {});
    status = switch (componentToken(property.value)) {
      'NEEDS-ACTION' => IcalendarTaskStatus.needsAction,
      'IN-PROCESS' => IcalendarTaskStatus.inProcess,
      'COMPLETED' => IcalendarTaskStatus.completed,
      'CANCELLED' => IcalendarTaskStatus.cancelled,
      _ => componentFail(IcalendarComponentError.invalidValue),
    };
  }
  final task = IcalendarTask._(
    source: source,
    metadata: _taskMetadata(source, budget),
    references: _taskReferences(source, budget),
    alarms: _displayAlarms(source, budget),
    participants: _taskParticipants(
      source,
      budget,
      isOverride: original != null,
    ),
    recurrenceDate: original is CalendarDate ? original : null,
    recurrenceTime: original is TimedValue ? original : null,
    uid: uid,
    stamp: stamp,
    dateTiming: dateTiming,
    timedTiming: timedTiming,
    recurrence: recurrence,
    summary: text('SUMMARY', 4096),
    description: text('DESCRIPTION', 16384),
    location: text('LOCATION', 4096),
    priority: _componentInteger(p['PRIORITY']?.single, maximum: 9),
    status: status,
    percentComplete: _componentInteger(
      p['PERCENT-COMPLETE']?.single,
      maximum: 100,
    ),
    completed: p['COMPLETED'] == null
        ? null
        : componentUtc(p['COMPLETED']!.single),
    sequence: _componentInteger(p['SEQUENCE']?.single),
    created: p['CREATED'] == null ? null : componentUtc(p['CREATED']!.single),
    lastModified: p['LAST-MODIFIED'] == null
        ? null
        : componentUtc(p['LAST-MODIFIED']!.single),
  );
  if (!task.isOverride) _taskAlarmAnchors(task);
  return task;
}
