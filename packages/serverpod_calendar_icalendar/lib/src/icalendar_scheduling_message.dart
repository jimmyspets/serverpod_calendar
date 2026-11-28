part of 'icalendar_event_calendar.dart';

enum IcalendarSchedulingMethod {
  publish,
  request,
  reply,
  cancel,
  add,
  refresh,
  counter,
  declineCounter,
}

const _schedulingSingleComponentMethods = {
  IcalendarSchedulingMethod.add,
  IcalendarSchedulingMethod.refresh,
  IcalendarSchedulingMethod.counter,
};
const _schedulingResultMethods = {
  IcalendarSchedulingMethod.reply,
  IcalendarSchedulingMethod.counter,
  IcalendarSchedulingMethod.declineCounter,
};

/// One UID's untrusted scheduling envelope and independently versioned components.
/// Parsing establishes neither stored membership nor permission to reconcile.
final class IcalendarSchedulingMessage {
  IcalendarSchedulingMessage._(
    this.source,
    this.productId,
    this.method,
    this.uid,
    Iterable<IcalendarSchedulingEvent> events,
    Map<String, IcalendarValidatedTimeZone> timeZones,
  ) : events = List.unmodifiable(events),
      timeZones = Map.unmodifiable(timeZones);
  final IcalendarSyntaxDocument source;
  final String productId, uid;
  final IcalendarSchedulingMethod method;
  final List<IcalendarSchedulingEvent> events;
  final Map<String, IcalendarValidatedTimeZone> timeZones;
}

/// Untrusted component claims. No authority or reconciliation is implied.
/// Optional source values remain absent, including timing in REPLY/CANCEL.
final class IcalendarSchedulingEvent {
  IcalendarSchedulingEvent._({
    required this.source,
    required this.uid,
    required this.stamp,
    required this.participants,
    required this.metadata,
    required this.references,
    required Iterable<IcalendarSchedulingRequestStatus> requestStatuses,
    required Iterable<IcalendarSchedulingResourceGroup> resources,
    this.sequence,
    this.created,
    this.lastModified,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.duration,
    this.dateSpan,
    this.timedSpan,
    this.summary,
    this.description,
    this.location,
    this.status,
    this.transparency,
    this.priority,
    this.geographicPosition,
    this.recurrence,
    this.originalDate,
    this.originalTime,
    this.isThisAndFuture = false,
  }) : requestStatuses = List.unmodifiable(requestStatuses),
       resources = List.unmodifiable(resources);

  final IcalendarSyntaxComponent source;
  final String uid;
  final IcalendarEventRecurrence? recurrence;
  final CalendarDate? originalDate;
  final TimedValue? originalTime;
  final bool isThisAndFuture;
  Object? get originalStart => originalDate ?? originalTime;
  bool get isOverride => originalStart != null;
  final DateTime stamp;
  final int? sequence;
  final DateTime? created, lastModified;
  final CalendarDate? startDate, endDate;
  final TimedValue? startTime, endTime;
  final CalendarDuration? duration;

  /// Derived spans exist only when DTSTART is supplied. Standalone DTEND is
  /// retained above and never converted into an invented start or interval.
  final DateEventSpan? dateSpan;
  final TimedEventSpan? timedSpan;
  final IcalendarEventText? summary, description, location;
  final IcalendarEventStatus? status;
  final IcalendarEventTransparency? transparency;
  final IcalendarEventParticipants participants;
  final IcalendarEventMetadata metadata;
  final IcalendarEventReferences references;
  final List<IcalendarSchedulingRequestStatus> requestStatuses;
  final List<IcalendarSchedulingResourceGroup> resources;
  final int? priority;
  final IcalendarSchedulingGeographicPosition? geographicPosition;
}

IcalendarSchedulingMessage parseIcalendarSchedulingMessage(
  List<int> bytes, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => validateIcalendarSchedulingMessage(
  parseIcalendarSyntax(bytes, limits: syntaxLimits),
  syntaxLimits: syntaxLimits,
  limits: limits,
);

/// One source UID; recurring and detached components are distinct from import.
IcalendarSchedulingMessage validateIcalendarSchedulingMessage(
  IcalendarSyntaxDocument source, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) {
  limits.validate();
  // Bounds manually built trees too. Syntax collections are immutable.
  serializeIcalendarSyntax(source, limits: syntaxLimits);
  return componentGuard(() {
    if (source.components.length != 1 ||
        source.components.single.canonicalName != 'VCALENDAR') {
      componentFail(IcalendarComponentError.unsupportedComponent);
    }
    final calendar = source.components.single;
    final envelope = componentProperties(calendar, {
      'VERSION',
      'PRODID',
      'CALSCALE',
      'METHOD',
    });
    final version = requiredProperty(envelope, 'VERSION');
    componentParameters(version, {});
    if (version.value != '2.0') {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final producer = componentText(requiredProperty(envelope, 'PRODID'));
    if (producer.isEmpty) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final scale = envelope['CALSCALE']?.single;
    if (scale != null) {
      componentParameters(scale, {});
      if (componentToken(scale.value) != 'GREGORIAN') {
        componentFail(IcalendarComponentError.invalidValue);
      }
    }
    final methodProperty = requiredProperty(envelope, 'METHOD');
    componentParameters(methodProperty, {});
    final method = switch (componentToken(methodProperty.value)) {
      'PUBLISH' => IcalendarSchedulingMethod.publish,
      'REQUEST' => IcalendarSchedulingMethod.request,
      'REPLY' => IcalendarSchedulingMethod.reply,
      'CANCEL' => IcalendarSchedulingMethod.cancel,
      'ADD' => IcalendarSchedulingMethod.add,
      'REFRESH' => IcalendarSchedulingMethod.refresh,
      'COUNTER' => IcalendarSchedulingMethod.counter,
      'DECLINECOUNTER' => IcalendarSchedulingMethod.declineCounter,
      _ => componentFail(IcalendarComponentError.unsupportedProperty),
    };
    final budget = ComponentBudget(limits);
    final zones = <String, IcalendarValidatedTimeZone>{};
    final rawEvents = <IcalendarSyntaxComponent>[];
    for (final c in calendar.entries.whereType<IcalendarSyntaxComponent>()) {
      if (c.canonicalName == 'VTIMEZONE') {
        // RFC 5546's REPLY table additionally restricts VTIMEZONE to at most one.
        if (zones.length >= limits.maxZones ||
            method == IcalendarSchedulingMethod.reply && zones.isNotEmpty) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        // RFC 5546 common restrictions, including verified erratum 3932,
        // forbid mixing explicit and rule onsets within one observance.
        // Ordinary RFC 5545 source adaptation intentionally keeps its profile.
        for (final observance
            in c.entries.whereType<IcalendarSyntaxComponent>()) {
          final names = observance.entries
              .whereType<IcalendarSyntaxProperty>()
              .map((p) => p.canonicalName)
              .toSet();
          if (names.contains('RRULE') && names.contains('RDATE')) {
            componentFail(IcalendarComponentError.invalidValue);
          }
        }
        final zone = validateComponentTimeZone(c, budget);
        if (zones.containsKey(zone.zoneId)) {
          componentFail(IcalendarComponentError.duplicate);
        }
        zones[zone.zoneId] = zone;
      } else if (c.canonicalName == 'VEVENT') {
        if (rawEvents.length >= limits.maxEvents) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        if (_schedulingSingleComponentMethods.contains(method) &&
            rawEvents.isNotEmpty) {
          componentFail(IcalendarComponentError.unsupportedComponent);
        }
        rawEvents.add(c);
      } else {
        componentFail(IcalendarComponentError.unsupportedComponent);
      }
    }
    if (rawEvents.isEmpty) {
      componentFail(IcalendarComponentError.missing);
    }
    final events = [
      for (final raw in rawEvents) _schedulingEvent(raw, method, zones, budget),
    ];
    final uid = events.first.uid;
    final identities = <(Object?, bool)>{};
    var overrides = 0;
    IcalendarSchedulingEvent? master;
    for (final event in events) {
      if (event.uid != uid) {
        componentFail(IcalendarComponentError.invalidValue);
      }
      if (!identities.add((event.originalStart, event.isThisAndFuture))) {
        componentFail(IcalendarComponentError.duplicate);
      }
      if (event.isOverride) {
        if (++overrides > limits.maxOverridesPerEvent) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
      } else {
        master = event;
      }
    }
    final anchor = master?.startDate ?? master?.startTime;
    if (anchor != null) {
      for (final event in events.where((e) => e.isOverride)) {
        final original = event.originalStart;
        if (anchor is CalendarDate && original is! CalendarDate ||
            anchor is TimedValue &&
                (original is! TimedValue || !anchor.sameProfile(original))) {
          componentFail(IcalendarComponentError.invalidValue);
        }
      }
    }
    return IcalendarSchedulingMessage._(
      source,
      producer,
      method,
      uid,
      events,
      zones,
    );
  });
}

IcalendarSchedulingEvent _schedulingEvent(
  IcalendarSyntaxComponent event,
  IcalendarSchedulingMethod method,
  Map<String, IcalendarValidatedTimeZone> zones,
  ComponentBudget budget,
) {
  if (event.entries.any((e) => e is IcalendarSyntaxComponent)) {
    componentFail(IcalendarComponentError.unsupportedComponent);
  }
  final p = componentProperties(
    event,
    {
      'UID',
      'DTSTAMP',
      'DTSTART',
      'RRULE',
      'RDATE',
      'EXDATE',
      'RECURRENCE-ID',
      'DTEND',
      'DURATION',
      'SUMMARY',
      'DESCRIPTION',
      'LOCATION',
      'STATUS',
      'TRANSP',
      'CREATED',
      'LAST-MODIFIED',
      'SEQUENCE',
      'ORGANIZER',
      'ATTENDEE',
      'RELATED-TO',
      'ATTACH',
      'PRIORITY',
      'GEO',
      'RESOURCES',
      if (_schedulingResultMethods.contains(method)) 'REQUEST-STATUS',
      ..._eventMetadataProperties,
    },
    repeated: {
      'RDATE',
      'EXDATE',
      'ATTENDEE',
      'RELATED-TO',
      'ATTACH',
      'RESOURCES',
      if (_schedulingResultMethods.contains(method)) 'REQUEST-STATUS',
      ..._eventRepeatedMetadata,
    },
  );
  if (method == IcalendarSchedulingMethod.refresh &&
      p.keys.any(
        (name) => !const {
          'UID',
          'DTSTAMP',
          'ORGANIZER',
          'ATTENDEE',
          'COMMENT',
          'RECURRENCE-ID',
        }.contains(name),
      )) {
    componentFail(IcalendarComponentError.unsupportedProperty);
  }
  if (method == IcalendarSchedulingMethod.add &&
      const {'RRULE', 'RDATE', 'EXDATE', 'RECURRENCE-ID'}.any(p.containsKey)) {
    componentFail(IcalendarComponentError.unsupportedProperty);
  }
  final uid = componentText(requiredProperty(p, 'UID'));
  if (uid.isEmpty) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final stamp = componentUtc(requiredProperty(p, 'DTSTAMP'));
  requiredProperty(p, 'ORGANIZER');
  final sequence = _componentInteger(p['SEQUENCE']?.single);
  final participants = _eventParticipants(event, budget, isOverride: false);
  final count = participants.attendees.length;
  switch (method) {
    case IcalendarSchedulingMethod.publish:
      if (count != 0) {
        componentFail(IcalendarComponentError.unsupportedProperty);
      }
      if ((p['CONTACT']?.length ?? 0) > 1) {
        componentFail(IcalendarComponentError.duplicate);
      }
    case IcalendarSchedulingMethod.request:
    case IcalendarSchedulingMethod.declineCounter:
      if (count == 0) {
        componentFail(IcalendarComponentError.missing);
      }
    case IcalendarSchedulingMethod.reply:
      if (count != 1) {
        componentFail(IcalendarComponentError.invalidValue);
      }
      // Delegated responses require a separately profiled multi-attendee
      // workflow (RFC 5546 3.2.2.3), not ordinary one-attendee REPLY handling.
      if (participants.attendees.single.participationStatus?.toUpperCase() ==
          'DELEGATED') {
        componentFail(IcalendarComponentError.unsupportedParameter);
      }
    case IcalendarSchedulingMethod.cancel:
      requiredProperty(p, 'SEQUENCE');
    case IcalendarSchedulingMethod.add:
      if (sequence == null) {
        componentFail(IcalendarComponentError.missing);
      }
      if (sequence <= 0) {
        componentFail(IcalendarComponentError.invalidValue);
      }
    case IcalendarSchedulingMethod.refresh:
      if (count != 1) {
        componentFail(IcalendarComponentError.invalidValue);
      }
    case IcalendarSchedulingMethod.counter:
      break;
  }
  if (method == IcalendarSchedulingMethod.declineCounter) {
    requiredProperty(p, 'SEQUENCE');
  }
  if (const {
    IcalendarSchedulingMethod.publish,
    IcalendarSchedulingMethod.request,
    IcalendarSchedulingMethod.add,
    IcalendarSchedulingMethod.counter,
  }.contains(method)) {
    requiredProperty(p, 'DTSTART');
    requiredProperty(p, 'SUMMARY');
  }
  String? token(String name) {
    final property = p[name]?.single;
    if (property == null) return null;
    componentParameters(property, {});
    return componentToken(property.value);
  }

  final status = switch (token('STATUS')) {
    null => null,
    'TENTATIVE' => IcalendarEventStatus.tentative,
    'CONFIRMED' => IcalendarEventStatus.confirmed,
    'CANCELLED' => IcalendarEventStatus.cancelled,
    _ => componentFail(IcalendarComponentError.invalidValue),
  };
  if (const {
            IcalendarSchedulingMethod.request,
            IcalendarSchedulingMethod.add,
            IcalendarSchedulingMethod.declineCounter,
          }.contains(method) &&
          status == IcalendarEventStatus.cancelled ||
      method == IcalendarSchedulingMethod.cancel &&
          status != null &&
          status != IcalendarEventStatus.cancelled) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  // Without STATUS:CANCELLED this is attendee removal, not whole cancellation.
  if (method == IcalendarSchedulingMethod.cancel &&
      status == null &&
      count == 0) {
    componentFail(IcalendarComponentError.missing);
  }
  final transparency = switch (token('TRANSP')) {
    null => null,
    'OPAQUE' => IcalendarEventTransparency.opaque,
    'TRANSPARENT' => IcalendarEventTransparency.transparent,
    _ => componentFail(IcalendarComponentError.invalidValue),
  };
  final start = p['DTSTART'] == null
      ? null
      : _temporal(p['DTSTART']!.single, zones);
  final end = p['DTEND'] == null
      ? null
      : _temporal(p['DTEND']!.single, zones, exclusiveEnd: true);
  CalendarDuration? duration;
  if (p['DURATION'] != null) {
    final property = p['DURATION']!.single;
    componentParameters(property, {});
    duration = parseIcalendarDuration(property.value);
    if (duration.sign < 0 || duration.isZero) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    if (start == null) {
      componentFail(IcalendarComponentError.missing);
    }
    if (start is CalendarDate &&
        !RegExp(r'^\+?P[0-9]+[DW]$').hasMatch(property.value)) {
      componentFail(IcalendarComponentError.invalidValue);
    }
  }
  if (end != null && duration != null) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  Object? original;
  var future = false;
  final recurrenceId = p['RECURRENCE-ID']?.single;
  if (recurrenceId != null) {
    if (['RRULE', 'RDATE', 'EXDATE'].any(p.containsKey)) {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
    final parameters = componentParameters(recurrenceId, {
      'VALUE',
      'TZID',
      'RANGE',
    });
    if (parameters['RANGE'] != null) {
      if (componentToken(parameters['RANGE']!) != 'THISANDFUTURE') {
        componentFail(IcalendarComponentError.invalidValue);
      }
      future = true;
    }
    original = _temporal(
      IcalendarSyntaxProperty(
        recurrenceId.name,
        recurrenceId.value,
        parameters: recurrenceId.parameters.where(
          (p) => p.canonicalName != 'RANGE',
        ),
      ),
      zones,
    );
    if (start != null &&
        (start is CalendarDate && original is! CalendarDate ||
            start is TimedValue &&
                (original is! TimedValue || !start.sameProfile(original)))) {
      componentFail(IcalendarComponentError.invalidValue);
    }
  }
  IcalendarEventRecurrence? recurrence;
  if (['RRULE', 'RDATE', 'EXDATE'].any(p.containsKey)) {
    if (start == null) {
      componentFail(IcalendarComponentError.missing);
    }
    recurrence = componentEventRecurrence(
      start,
      p,
      budget,
      (property, end) => _temporal(property, zones, exclusiveEnd: end),
    );
  }
  DateEventSpan? dateSpan;
  TimedEventSpan? timedSpan;
  if (start is CalendarDate) {
    if (end != null && end is! CalendarDate) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    dateSpan = DateEventSpan(
      start: start,
      end: end as CalendarDate?,
      duration: duration,
    );
  } else if (start is TimedValue) {
    if (end != null && end is! TimedValue) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    timedSpan = TimedEventSpan(
      start: start,
      end: end as TimedValue?,
      duration: duration,
    );
  }
  IcalendarEventText? text(String name, int limit) {
    final value = _componentTextValue(p[name]?.single, limit);
    if (value != null) {
      budget.eventMetadata(
        value.value.runes.length +
            (value.language?.runes.length ?? 0) +
            (value.alternativeUri?.runes.length ?? 0),
      );
    }
    return value;
  }

  return IcalendarSchedulingEvent._(
    source: event,
    recurrence: recurrence,
    originalDate: original is CalendarDate ? original : null,
    originalTime: original is TimedValue ? original : null,
    isThisAndFuture: future,
    uid: uid,
    stamp: stamp,
    participants: participants,
    metadata: _eventMetadata(event, budget),
    references: _eventReferences(event, budget),
    requestStatuses: _schedulingRequestStatuses(
      p['REQUEST-STATUS'] ?? [],
      budget,
    ),
    resources: _schedulingResources(p['RESOURCES'] ?? [], budget),
    priority: _componentInteger(p['PRIORITY']?.single, maximum: 9),
    geographicPosition: _schedulingGeographicPosition(p['GEO']?.single, budget),
    sequence: sequence,
    created: p['CREATED'] == null ? null : componentUtc(p['CREATED']!.single),
    lastModified: p['LAST-MODIFIED'] == null
        ? null
        : componentUtc(p['LAST-MODIFIED']!.single),
    startDate: start is CalendarDate ? start : null,
    startTime: start is TimedValue ? start : null,
    endDate: end is CalendarDate ? end : null,
    endTime: end is TimedValue ? end : null,
    duration: duration,
    dateSpan: dateSpan,
    timedSpan: timedSpan,
    summary: text('SUMMARY', 4096),
    description: text('DESCRIPTION', 16384),
    location: text('LOCATION', 4096),
    status: status,
    transparency: transparency,
  );
}

/// Re-emits only this validated source profile, preserving omissions and claims.
/// Does not generate a new scheduling version, recipient or transmission.
Uint8List serializeIcalendarSchedulingMessage(
  IcalendarSchedulingMessage value, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
}) => serializeIcalendarSyntax(
  IcalendarSyntaxDocument(value.source.components.map(_outputComponent)),
  limits: syntaxLimits,
);
