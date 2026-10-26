part of 'icalendar_event_calendar.dart';

enum IcalendarSchedulingMethod { publish, request, reply, cancel }

/// A validated, untrusted message. No authority or reconciliation is implied.
/// Optional source values remain absent, including timing in REPLY/CANCEL.
final class IcalendarSchedulingMessage {
  IcalendarSchedulingMessage._({
    required this.source,
    required this.productId,
    required this.method,
    required this.uid,
    required this.stamp,
    required this.participants,
    required this.metadata,
    required this.references,
    required Map<String, IcalendarValidatedTimeZone> timeZones,
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
  }) : timeZones = Map.unmodifiable(timeZones);

  final IcalendarSyntaxDocument source;
  final String productId, uid;
  final IcalendarSchedulingMethod method;
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
  final Map<String, IcalendarValidatedTimeZone> timeZones;
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

/// One non-recurring VEVENT; deliberately separate from ordinary import.
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
    if (producer.isEmpty) componentFail(IcalendarComponentError.invalidValue);
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
      _ => componentFail(IcalendarComponentError.unsupportedProperty),
    };
    final budget = ComponentBudget(limits);
    final zones = <String, IcalendarValidatedTimeZone>{};
    IcalendarSyntaxComponent? event;
    for (final c in calendar.entries.whereType<IcalendarSyntaxComponent>()) {
      if (c.canonicalName == 'VTIMEZONE') {
        // RFC 5546's REPLY table additionally restricts VTIMEZONE to at most one.
        if (zones.length >= limits.maxZones ||
            method == IcalendarSchedulingMethod.reply && zones.isNotEmpty) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        final zone = validateComponentTimeZone(c, budget);
        if (zones.containsKey(zone.zoneId)) {
          componentFail(IcalendarComponentError.duplicate);
        }
        zones[zone.zoneId] = zone;
      } else if (c.canonicalName == 'VEVENT') {
        if (event != null) {
          componentFail(IcalendarComponentError.unsupportedComponent);
        }
        event = c;
      } else {
        componentFail(IcalendarComponentError.unsupportedComponent);
      }
    }
    if (event == null) componentFail(IcalendarComponentError.missing);
    if (event.entries.any((e) => e is IcalendarSyntaxComponent)) {
      componentFail(IcalendarComponentError.unsupportedComponent);
    }
    final p = componentProperties(
      event,
      {
        'UID',
        'DTSTAMP',
        'DTSTART',
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
        ..._eventMetadataProperties,
      },
      repeated: {'ATTENDEE', 'RELATED-TO', 'ATTACH', ..._eventRepeatedMetadata},
    );
    final uid = componentText(requiredProperty(p, 'UID'));
    if (uid.isEmpty) componentFail(IcalendarComponentError.invalidValue);
    final stamp = componentUtc(requiredProperty(p, 'DTSTAMP'));
    requiredProperty(p, 'ORGANIZER');
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
        if (count == 0) componentFail(IcalendarComponentError.missing);
      case IcalendarSchedulingMethod.reply:
        if (count != 1) componentFail(IcalendarComponentError.invalidValue);
        // Delegated responses require a separately profiled multi-attendee
        // workflow (RFC 5546 3.2.2.3), not ordinary one-attendee REPLY handling.
        if (participants.attendees.single.participationStatus?.toUpperCase() ==
            'DELEGATED') {
          componentFail(IcalendarComponentError.unsupportedParameter);
        }
      case IcalendarSchedulingMethod.cancel:
        requiredProperty(p, 'SEQUENCE');
    }
    if (method == IcalendarSchedulingMethod.publish ||
        method == IcalendarSchedulingMethod.request) {
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
    if (method == IcalendarSchedulingMethod.request &&
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
      if (start == null) componentFail(IcalendarComponentError.missing);
      if (start is CalendarDate &&
          !RegExp(r'^\+?P[0-9]+[DW]$').hasMatch(property.value)) {
        componentFail(IcalendarComponentError.invalidValue);
      }
    }
    if (end != null && duration != null) {
      componentFail(IcalendarComponentError.invalidValue);
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

    return IcalendarSchedulingMessage._(
      source: source,
      productId: producer,
      method: method,
      uid: uid,
      stamp: stamp,
      participants: participants,
      metadata: _eventMetadata(event, budget),
      references: _eventReferences(event, budget),
      timeZones: zones,
      sequence: _componentInteger(p['SEQUENCE']?.single),
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
  });
}

/// Re-emits only this validated source profile, preserving omissions and claims.
/// Does not generate a new scheduling version, recipient or transmission.
Uint8List serializeIcalendarSchedulingMessage(
  IcalendarSchedulingMessage value, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
}) => serializeIcalendarSyntax(value.source, limits: syntaxLimits);
