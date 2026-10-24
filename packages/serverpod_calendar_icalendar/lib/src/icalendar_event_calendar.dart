import 'dart:typed_data';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'calendar_text_metadata.dart';
import 'calendar_supplemental_metadata.dart';
import 'icalendar_component_support.dart';
import 'icalendar_syntax.dart';
import 'icalendar_temporal_values.dart';
import 'icalendar_time_zone.dart';
import 'icalendar_event_recurrence.dart';

part 'icalendar_event_series.dart';
part 'icalendar_event_metadata.dart';
part 'icalendar_event_participants.dart';
part 'icalendar_event_references.dart';
part 'icalendar_task_calendar.dart';
part 'icalendar_task_series.dart';
part 'icalendar_task_metadata.dart';
part 'icalendar_task_participants.dart';
part 'icalendar_task_references.dart';
part 'icalendar_display_alarm.dart';
part 'icalendar_availability_calendar.dart';
part 'icalendar_availability_metadata.dart';

enum IcalendarEventStatus { tentative, confirmed, cancelled }

enum IcalendarEventTransparency { opaque, transparent }

final class IcalendarEventText {
  IcalendarEventText._(this.value, this.language, this.alternativeUri);
  final String value;
  final String? language, alternativeUri;
}

/// Read-only semantic projection of one supported source event component.
/// UID is source protocol identity, never a native UUID or authorization proof.
final class IcalendarEvent {
  IcalendarEvent._({
    required this.source,
    required this.uid,
    required this.stamp,
    required this.dateSpan,
    required this.timedSpan,
    required this.metadata,
    required this.participants,
    required this.references,
    required this.alarms,
    this.created,
    this.lastModified,
    this.sequence,
    this.summary,
    this.description,
    this.location,
    this.status,
    this.transparency,
    this.recurrence,
    this.recurrenceDate,
    this.recurrenceTime,
    this.isThisAndFuture = false,
  });
  final IcalendarEventMetadata metadata;
  final IcalendarEventParticipants participants;
  final IcalendarEventReferences references;
  final List<IcalendarDisplayAlarm> alarms;
  final IcalendarSyntaxComponent source;
  final String uid;
  final DateTime stamp;
  final DateTime? created, lastModified;
  final int? sequence;
  final DateEventSpan? dateSpan;
  final TimedEventSpan? timedSpan;
  final IcalendarEventRecurrence? recurrence;
  final CalendarDate? recurrenceDate;
  final TimedValue? recurrenceTime;
  final bool isThisAndFuture;
  Object? get originalStart => recurrenceDate ?? recurrenceTime;
  bool get isOverride => originalStart != null;
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
    List<IcalendarEventSeries> series,
    Map<String, IcalendarValidatedTimeZone> zones,
  ) : series = List.unmodifiable(series),
      events = List.unmodifiable(series.map((s) => s.master)),
      timeZones = Map.unmodifiable(zones);
  final IcalendarSyntaxDocument source;
  final String productId;

  /// Master components only, in master source order; see [series] for overrides.
  final List<IcalendarEvent> events;
  final List<IcalendarEventSeries> series;
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
/// future content/cancellation, unsupported alarm actions and unprofiled metadata.
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
    final masters = <String, IcalendarEvent>{};
    final overrides = <String, List<IcalendarEvent>>{};
    for (final raw in rawEvents) {
      final event = _event(raw, zones, budget, allowAlarms: true);
      if (event.isOverride) {
        final list = overrides.putIfAbsent(event.uid, () => []);
        if (list.length >= limits.maxOverridesPerEvent) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        list.add(event);
      } else if (masters.containsKey(event.uid)) {
        componentFail(IcalendarComponentError.duplicate);
      } else {
        masters[event.uid] = event;
      }
    }
    if (overrides.keys.any((uid) => !masters.containsKey(uid))) {
      componentFail(IcalendarComponentError.missing);
    }
    final series = [
      for (final master in masters.values)
        _eventSeries(master, overrides[master.uid] ?? [], budget),
    ];
    return IcalendarEventCalendar._(source, producer, series, zones);
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
  ComponentBudget budget, {
  bool allowAlarms = false,
}) {
  if (!allowAlarms &&
      source.entries.any((e) => e is IcalendarSyntaxComponent)) {
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
      'RECURRENCE-ID',
      ..._eventMetadataProperties,
      'ORGANIZER',
      'ATTENDEE',
      'RELATED-TO',
      'ATTACH',
    },
    repeated: {
      'RDATE',
      'EXDATE',
      'ATTENDEE',
      'RELATED-TO',
      'ATTACH',
      ..._eventRepeatedMetadata,
    },
  );
  final uid = componentText(requiredProperty(p, 'UID'));
  if (uid.isEmpty) componentFail(IcalendarComponentError.invalidValue);
  final stamp = componentUtc(requiredProperty(p, 'DTSTAMP'));
  Object? original;
  var future = false;
  final identity = p['RECURRENCE-ID']?.single;
  if (identity != null) {
    if (['RRULE', 'RDATE', 'EXDATE'].any(p.containsKey)) {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
    final parameters = componentParameters(identity, {
      'VALUE',
      'TZID',
      'RANGE',
    });
    final range = parameters['RANGE'];
    if (range != null) {
      if (componentToken(range) != 'THISANDFUTURE') {
        componentFail(IcalendarComponentError.invalidValue);
      }
      future = true;
    }
    original = _temporal(
      IcalendarSyntaxProperty(
        identity.name,
        identity.value,
        parameters: identity.parameters.where(
          (p) => p.canonicalName != 'RANGE',
        ),
      ),
      zones,
    );
  }
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
  IcalendarEventText? text(String name, int limit) =>
      _componentTextValue(p[name]?.single, limit);

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
  final sequence = _componentInteger(p['SEQUENCE']?.single);
  final event = IcalendarEvent._(
    source: source,
    uid: uid,
    stamp: stamp,
    dateSpan: dateSpan,
    timedSpan: timedSpan,
    recurrenceDate: original is CalendarDate ? original : null,
    recurrenceTime: original is TimedValue ? original : null,
    isThisAndFuture: future,
    recurrence: componentEventRecurrence(
      start,
      p,
      budget,
      (p, exclusiveEnd) => _temporal(p, zones, exclusiveEnd: exclusiveEnd),
    ),
    created: p['CREATED'] == null ? null : componentUtc(p['CREATED']!.single),
    lastModified: p['LAST-MODIFIED'] == null
        ? null
        : componentUtc(p['LAST-MODIFIED']!.single),
    sequence: sequence,
    metadata: _eventMetadata(source, budget),
    references: _eventReferences(source, budget),
    alarms: allowAlarms
        ? _displayAlarms(source, budget, forEvent: true)
        : const [],
    participants: _eventParticipants(
      source,
      budget,
      isOverride: original != null,
    ),
    summary: text('SUMMARY', 4096),
    description: text('DESCRIPTION', 16384),
    location: text('LOCATION', 4096),
    status: status,
    transparency: transparency,
  );
  if (!event.isOverride) _eventAlarmAnchors(event, event.alarms);
  return event;
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

IcalendarEventText? _componentTextValue(
  IcalendarSyntaxProperty? property,
  int limit,
) {
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

int? _componentInteger(
  IcalendarSyntaxProperty? property, {
  int maximum = 2147483647,
}) {
  if (property == null) return null;
  componentParameters(property, {});
  final value = property.value;
  final match = RegExp(r'\+?[0-9]+').firstMatch(value);
  if (value.length > 16 ||
      match == null ||
      match.start != 0 ||
      match.end != value.length) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final number = BigInt.parse(value);
  if (number > BigInt.from(maximum)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  return number.toInt();
}
