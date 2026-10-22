import 'dart:typed_data';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'calendar_text_metadata.dart';
import 'icalendar_component_support.dart';
import 'icalendar_syntax.dart';
import 'icalendar_temporal_values.dart';
import 'icalendar_time_zone.dart';
import 'icalendar_event_recurrence.dart';

enum IcalendarEventStatus { tentative, confirmed, cancelled }

enum IcalendarEventTransparency { opaque, transparent }

final class IcalendarEventText {
  IcalendarEventText._(this.value, this.language, this.alternativeUri);
  final String value;
  final String? language, alternativeUri;
}

/// Read-only semantic projection of one supported source master event.
/// UID is source protocol identity, never a native UUID or authorization proof.
final class IcalendarEvent {
  IcalendarEvent._({
    required this.source,
    required this.uid,
    required this.stamp,
    required this.dateSpan,
    required this.timedSpan,
    this.created,
    this.lastModified,
    this.sequence,
    this.summary,
    this.description,
    this.location,
    this.status,
    this.transparency,
    this.recurrence,
  });
  final IcalendarSyntaxComponent source;
  final String uid;
  final DateTime stamp;
  final DateTime? created, lastModified;
  final int? sequence;
  final DateEventSpan? dateSpan;
  final TimedEventSpan? timedSpan;
  final IcalendarEventRecurrence? recurrence;
  final IcalendarEventText? summary, description, location;
  final IcalendarEventStatus? status;
  final IcalendarEventTransparency? transparency;
  bool get isTransparent =>
      transparency == IcalendarEventTransparency.transparent;
}

/// Supported standalone event-calendar profile. No host/storage authority.
final class IcalendarEventCalendar {
  IcalendarEventCalendar._(
    this.source,
    this.productId,
    List<IcalendarEvent> events,
    Map<String, IcalendarValidatedTimeZone> zones,
  ) : events = List.unmodifiable(events),
      timeZones = Map.unmodifiable(zones);
  final IcalendarSyntaxDocument source;
  final String productId;
  final List<IcalendarEvent> events;
  final Map<String, IcalendarValidatedTimeZone> timeZones;
}

IcalendarEventCalendar parseIcalendarEventCalendar(
  List<int> bytes, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) {
  limits.validate();
  return validateIcalendarEventCalendar(
    parseIcalendarSyntax(bytes, limits: syntaxLimits),
    syntaxLimits: syntaxLimits,
    limits: limits,
  );
}

/// Validates a complete supported source before returning any semantic results.
///
/// Unsupported properties/parameters/components fail, including METHOD,
/// override components, alarms and unprofiled calendar metadata/extensions.
IcalendarEventCalendar validateIcalendarEventCalendar(
  IcalendarSyntaxDocument source, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) {
  limits.validate();
  // Also bounds/validates manually constructed trees; never trust constructors
  // as profile or syntax approval. No caller-provided mutable collections remain.
  serializeIcalendarSyntax(source, limits: syntaxLimits);
  return componentGuard(() {
    if (source.components.length != 1 ||
        source.components.single.canonicalName != 'VCALENDAR') {
      componentFail(IcalendarComponentError.unsupportedComponent);
    }
    final calendar = source.components.single;
    final p = componentProperties(calendar, {'PRODID', 'VERSION', 'CALSCALE'});
    final version = requiredProperty(p, 'VERSION');
    componentParameters(version, {});
    if (version.value != '2.0') {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final producer = componentText(requiredProperty(p, 'PRODID'));
    if (producer.isEmpty) componentFail(IcalendarComponentError.invalidValue);
    if (p['CALSCALE'] != null) {
      final scale = p['CALSCALE']!.single;
      componentParameters(scale, {});
      if (componentToken(scale.value) != 'GREGORIAN') {
        componentFail(IcalendarComponentError.invalidValue);
      }
    }
    final budget = ComponentBudget(limits);
    final zones = <String, IcalendarValidatedTimeZone>{};
    final rawEvents = <IcalendarSyntaxComponent>[];
    for (final c in calendar.entries.whereType<IcalendarSyntaxComponent>()) {
      if (c.canonicalName == 'VTIMEZONE') {
        if (zones.length >= limits.maxZones) {
          componentFail(IcalendarComponentError.limitExceeded);
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
        rawEvents.add(c);
      } else {
        componentFail(IcalendarComponentError.unsupportedComponent);
      }
    }
    if (rawEvents.isEmpty) componentFail(IcalendarComponentError.missing);
    final events = <IcalendarEvent>[];
    final uids = <String>{};
    for (final raw in rawEvents) {
      final event = _event(raw, zones, budget);
      if (!uids.add(event.uid)) {
        componentFail(IcalendarComponentError.duplicate);
      }
      events.add(event);
    }
    return IcalendarEventCalendar._(source, producer, events, zones);
  });
}

/// Re-emits validated source meaning/spelling/order with deterministic syntax
/// quoting/folding and FREQ-first RRULE output. The retained source is unchanged.
/// This is not an authorized export/feed projection.
Uint8List serializeIcalendarEventCalendar(
  IcalendarEventCalendar value, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
}) => serializeIcalendarSyntax(
  IcalendarSyntaxDocument(value.source.components.map(_outputComponent)),
  limits: syntaxLimits,
);

// Consumers accept unordered RECUR parts; RFC 5545 output puts FREQ first.
// The retained source tree is unchanged, including original part spelling/order.
IcalendarSyntaxComponent _outputComponent(IcalendarSyntaxComponent c) =>
    IcalendarSyntaxComponent(
      c.name,
      c.entries.map((e) {
        if (e is IcalendarSyntaxComponent) return _outputComponent(e);
        final p = e as IcalendarSyntaxProperty;
        if (p.canonicalName != 'RRULE') return p;
        final parts = p.value.split(';');
        final frequency = parts.indexWhere(
          (v) => v.split('=').first.toUpperCase() == 'FREQ',
        );
        if (frequency <= 0) return p;
        final first = parts.removeAt(frequency);
        return IcalendarSyntaxProperty(
          p.name,
          [first, ...parts].join(';'),
          parameters: p.parameters,
        );
      }),
    );

IcalendarEvent _event(
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
      'RRULE',
      'RDATE',
      'EXDATE',
    },
    repeated: {'RDATE', 'EXDATE'},
  );
  final uid = componentText(requiredProperty(p, 'UID'));
  if (uid.isEmpty) componentFail(IcalendarComponentError.invalidValue);
  final stamp = componentUtc(requiredProperty(p, 'DTSTAMP'));
  final start = _temporal(requiredProperty(p, 'DTSTART'), zones);
  final end = p['DTEND'] == null
      ? null
      : _temporal(p['DTEND']!.single, zones, exclusiveEnd: true);
  CalendarDuration? duration;
  if (p['DURATION'] != null) {
    final prop = p['DURATION']!.single;
    componentParameters(prop, {});
    duration = parseIcalendarDuration(prop.value);
    if (start is CalendarDate) {
      final match = RegExp(r'\+?P[0-9]+[DW]').firstMatch(prop.value);
      if (match == null || match.start != 0 || match.end != prop.value.length) {
        componentFail(IcalendarComponentError.invalidValue);
      }
    }
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
  } else {
    if (end != null && end is! TimedValue) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    timedSpan = TimedEventSpan(
      start: start as TimedValue,
      end: end as TimedValue?,
      duration: duration,
    );
  }
  IcalendarEventText? text(String name, int limit) {
    final property = p[name]?.single;
    if (property == null) return null;
    const allowed = {'LANGUAGE', 'ALTREP'};
    final parameters = componentParameters(property, allowed);
    final decoded = componentText(
      property,
      maxPoints: limit,
      parameters: allowed,
    );
    final language = parameters['LANGUAGE'];
    final alternative = parameters['ALTREP'];
    if (language != null) validateCalendarLanguageTag(language);
    if (alternative != null) componentUri(alternative);
    return IcalendarEventText._(decoded, language, alternative);
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
  final transparency = switch (token('TRANSP')) {
    null => null,
    'OPAQUE' => IcalendarEventTransparency.opaque,
    'TRANSPARENT' => IcalendarEventTransparency.transparent,
    _ => componentFail(IcalendarComponentError.invalidValue),
  };
  int? sequence;
  if (p['SEQUENCE'] != null) {
    final property = p['SEQUENCE']!.single;
    componentParameters(property, {});
    final value = property.value;
    final match = RegExp(r'\+?[0-9]+').firstMatch(value);
    if (value.length > 16 ||
        match == null ||
        match.start != 0 ||
        match.end != value.length) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final n = BigInt.parse(value);
    if (n > BigInt.from(2147483647)) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    sequence = n.toInt();
  }
  return IcalendarEvent._(
    source: source,
    uid: uid,
    stamp: stamp,
    dateSpan: dateSpan,
    timedSpan: timedSpan,
    recurrence: componentEventRecurrence(
      start,
      p,
      budget,
      (p) => _temporal(p, zones),
    ),
    created: p['CREATED'] == null ? null : componentUtc(p['CREATED']!.single),
    lastModified: p['LAST-MODIFIED'] == null
        ? null
        : componentUtc(p['LAST-MODIFIED']!.single),
    sequence: sequence,
    summary: text('SUMMARY', 4096),
    description: text('DESCRIPTION', 16384),
    location: text('LOCATION', 4096),
    status: status,
    transparency: transparency,
  );
}

Object _temporal(
  IcalendarSyntaxProperty p,
  Map<String, IcalendarValidatedTimeZone> zones, {
  bool exclusiveEnd = false,
}) {
  final parameters = componentParameters(p, {'VALUE', 'TZID'});
  final type = parameters['VALUE'] == null
      ? 'DATE-TIME'
      : componentToken(parameters['VALUE']!);
  final zoneId = parameters['TZID'];
  if (type == 'DATE') {
    if (zoneId != null) componentFail(IcalendarComponentError.invalidValue);
    return parseIcalendarDate(p.value, exclusiveEnd: exclusiveEnd);
  }
  if (type != 'DATE-TIME') componentFail(IcalendarComponentError.invalidValue);
  if (zoneId != null && !zones.containsKey(zoneId)) {
    componentFail(IcalendarComponentError.missing);
  }
  return parseIcalendarDateTime(
    p.value,
    zoneId: zoneId,
    exclusiveEnd: exclusiveEnd,
  );
}
