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
  bool get isUndated => dateTiming == null && timedTiming == null;
}

/// Complete bounded standalone masters; no database or scheduling authority.
final class IcalendarTaskCalendar {
  IcalendarTaskCalendar._(
    this.source,
    this.productId,
    Iterable<IcalendarTask> tasks,
    Map<String, IcalendarValidatedTimeZone> zones,
  ) : tasks = List.unmodifiable(tasks),
      timeZones = Map.unmodifiable(zones);
  final IcalendarSyntaxDocument source;
  final String productId;
  final List<IcalendarTask> tasks;
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
    final tasks = <String, IcalendarTask>{};
    for (final component in raw) {
      final task = _taskComponent(component, zones, budget);
      if (tasks.containsKey(task.uid)) {
        componentFail(IcalendarComponentError.duplicate);
      }
      tasks[task.uid] = task;
    }
    return IcalendarTaskCalendar._(source, producer, tasks.values, zones);
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
  if (source.entries.any((e) => e is IcalendarSyntaxComponent)) {
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
    },
    repeated: {'RDATE', 'EXDATE'},
  );
  final uid = componentText(requiredProperty(p, 'UID'));
  if (uid.isEmpty) componentFail(IcalendarComponentError.invalidValue);
  budget.taskMetadata(uid.runes.length);
  final stamp = componentUtc(requiredProperty(p, 'DTSTAMP'));
  Object? temporal(String name) =>
      p[name] == null ? null : _temporal(p[name]!.single, zones);
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
  return IcalendarTask._(
    source: source,
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
}
