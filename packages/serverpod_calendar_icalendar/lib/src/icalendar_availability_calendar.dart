part of 'icalendar_event_calendar.dart';

/// Typed AVAILABLE source. Source addresses/metadata never establish authority.
final class IcalendarAvailable {
  IcalendarAvailable._(this._value);
  final IcalendarEvent _value;
  IcalendarSyntaxComponent get source => _value.source;
  String get uid => _value.uid;
  DateTime get stamp => _value.stamp;
  DateTime? get created => _value.created;
  DateTime? get lastModified => _value.lastModified;
  TimedEventSpan get span => _value.timedSpan!;
  TimedValue? get originalStart => _value.recurrenceTime;
  bool get isThisAndFuture => _value.isThisAndFuture;
  TimedRecurrenceSet? get recurrence => _value.recurrence?.timedSet;
  IcalendarEventText? get summary => _value.summary;
  IcalendarEventText? get description => _value.description;
  IcalendarEventText? get location => _value.location;
}

final class IcalendarAvailableSeries {
  IcalendarAvailableSeries._(IcalendarEventSeries value)
    : master = IcalendarAvailable._(value.master),
      overrides = List.unmodifiable(value.overrides.map(IcalendarAvailable._)),
      timing = value.timedSeries!;
  final IcalendarAvailable master;
  final List<IcalendarAvailable> overrides;
  final TimedEventSeries timing;
}

/// A preserved envelope. Its independently specified bounds may use different
/// UTC/named profiles; DURATION is applied in the start's own profile.
final class IcalendarAvailabilityDefinition {
  IcalendarAvailabilityDefinition._({
    required this.source,
    required this.uid,
    required this.stamp,
    this.created,
    this.lastModified,
    this.sequence,
    this.start,
    this.end,
    this.duration,
    required this.priority,
    required this.closedKind,
    this.summary,
    this.description,
    this.location,
    required List<IcalendarAvailableSeries> openings,
  }) : openings = List.unmodifiable(openings);
  final IcalendarSyntaxComponent source;
  final String uid;
  final DateTime stamp;
  final DateTime? created, lastModified;
  final int? sequence;
  final TimedValue? start, end;
  final CalendarDuration? duration;
  final int priority;
  final AvailabilityKind closedKind;
  final IcalendarEventText? summary, description, location;
  final List<IcalendarAvailableSeries> openings;
  DateTime? get endExclusive =>
      end?.instant ?? (duration == null ? null : start!.add(duration!));
}

/// Pure availability snapshot, separate from VEVENT calendars and host storage.
final class IcalendarAvailabilityCalendar {
  IcalendarAvailabilityCalendar._(
    this.source,
    this.productId,
    List<IcalendarAvailabilityDefinition> definitions,
    Map<String, IcalendarValidatedTimeZone> zones,
  ) : definitions = List.unmodifiable(definitions),
      timeZones = Map.unmodifiable(zones);
  final IcalendarSyntaxDocument source;
  final String productId;
  final List<IcalendarAvailabilityDefinition> definitions;
  final Map<String, IcalendarValidatedTimeZone> timeZones;

  /// Complete bounded input for core composition; this is neither an authorized
  /// free/busy response nor a booking overlay. Work/results share calendar caps;
  /// raw-rule/base limits remain per opening. Failures return no partial list.
  List<AvailabilityDefinition> expand({
    required UtcWindow window,
    required int maxCandidateWork,
    required int maxRuleOccurrences,
    required int maxBaseOccurrences,
    required int maxOccurrences,
  }) => componentGuard(() {
    for (final limit in [
      maxCandidateWork,
      maxRuleOccurrences,
      maxBaseOccurrences,
      maxOccurrences,
    ]) {
      RangeError.checkValueInInterval(
        limit,
        1,
        DateRecurrenceRule.maxScalar,
        'limit',
      );
    }
    TimedValue.utc(window.start);
    TimedValue.utcEnd(window.end);
    final work = RecurrenceWorkBudget(maxWork: maxCandidateWork);
    var total = 0;
    final result = <AvailabilityDefinition>[];
    for (final d in definitions) {
      final lower = d.start?.instant;
      final upper = d.endExclusive;
      final from = lower != null && lower.isAfter(window.start)
          ? lower
          : window.start;
      final until = upper != null && upper.isBefore(window.end)
          ? upper
          : window.end;
      final intervals = <UtcWindow>[];
      if (from.isBefore(until)) {
        final clipped = UtcWindow(start: from, end: until);
        for (final opening in d.openings) {
          final occurrences = opening.timing.expandOverlapping(
            window: clipped,
            maxCandidateWork: maxCandidateWork,
            maxRuleOccurrences: maxRuleOccurrences,
            maxBaseOccurrences: maxBaseOccurrences,
            maxResults: maxOccurrences,
            sharedWorkBudget: work,
          );
          total += occurrences.length;
          if (total > maxOccurrences) {
            componentFail(IcalendarComponentError.limitExceeded);
          }
          for (final o in occurrences) {
            final intersection = clipped.intersection(
              UtcWindow(start: o.span.start, end: o.span.endExclusive),
            );
            if (intersection != null) intervals.add(intersection);
          }
        }
      }
      result.add(
        AvailabilityDefinition(
          start: lower,
          end: upper,
          priority: d.priority,
          closedKind: d.closedKind,
          openings: intervals,
        ),
      );
    }
    return List.unmodifiable(result);
  });
}

IcalendarAvailabilityCalendar parseIcalendarAvailabilityCalendar(
  List<int> bytes, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => validateIcalendarAvailabilityCalendar(
  parseIcalendarSyntax(bytes, limits: syntaxLimits),
  syntaxLimits: syntaxLimits,
  limits: limits,
);

IcalendarAvailabilityCalendar validateIcalendarAvailabilityCalendar(
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
    final raw = <IcalendarSyntaxComponent>[];
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
      } else if (c.canonicalName == 'VAVAILABILITY') {
        if (raw.length >= limits.maxAvailabilityDefinitions) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        raw.add(c);
      } else {
        componentFail(IcalendarComponentError.unsupportedComponent);
      }
    }
    if (raw.isEmpty) componentFail(IcalendarComponentError.missing);
    final definitions = <IcalendarAvailabilityDefinition>[];
    final ids = <String>{}, openingIds = <String>{};
    var components = 0;
    for (final c in raw) {
      final openings = <IcalendarEvent>[];
      for (final o in c.entries.whereType<IcalendarSyntaxComponent>()) {
        if (o.canonicalName != 'AVAILABLE') {
          componentFail(IcalendarComponentError.unsupportedComponent);
        }
        if (++components > limits.maxAvailableComponents) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        componentProperties(
          o,
          {
            'UID',
            'DTSTAMP',
            'DTSTART',
            'DTEND',
            'DURATION',
            'CREATED',
            'LAST-MODIFIED',
            'SUMMARY',
            'DESCRIPTION',
            'LOCATION',
            'RECURRENCE-ID',
            'RRULE',
            'RDATE',
            'EXDATE',
          },
          repeated: {'RDATE', 'EXDATE'},
        );
        final parsed = _event(o, zones, budget);
        if (parsed.timedSpan == null || parsed.timedSpan!.isPoint) {
          componentFail(IcalendarComponentError.invalidValue);
        }
        openings.add(parsed);
      }
      final masters = <String, IcalendarEvent>{};
      final changes = <String, List<IcalendarEvent>>{};
      for (final o in openings) {
        if (o.isOverride) {
          final list = changes.putIfAbsent(o.uid, () => []);
          if (list.length >= limits.maxAvailableOverrides) {
            componentFail(IcalendarComponentError.limitExceeded);
          }
          list.add(o);
        } else {
          if (masters.containsKey(o.uid) || !openingIds.add(o.uid)) {
            componentFail(IcalendarComponentError.duplicate);
          }
          masters[o.uid] = o;
        }
      }
      if (changes.keys.any((uid) => !masters.containsKey(uid))) {
        componentFail(IcalendarComponentError.missing);
      }
      final series = [
        for (final m in masters.values)
          IcalendarAvailableSeries._(
            _eventSeries(
              m,
              changes[m.uid] ?? [],
              budget,
              maxOverrides: limits.maxAvailableOverrides,
            ),
          ),
      ];
      final definition = _availability(c, zones, series);
      if (!ids.add(definition.uid)) {
        componentFail(IcalendarComponentError.duplicate);
      }
      definitions.add(definition);
    }
    return IcalendarAvailabilityCalendar._(
      source,
      producer,
      definitions,
      zones,
    );
  });
}

Uint8List serializeIcalendarAvailabilityCalendar(
  IcalendarAvailabilityCalendar value, {
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
}) => serializeIcalendarSyntax(
  IcalendarSyntaxDocument(value.source.components.map(_outputComponent)),
  limits: syntaxLimits,
);

IcalendarAvailabilityDefinition _availability(
  IcalendarSyntaxComponent source,
  Map<String, IcalendarValidatedTimeZone> zones,
  List<IcalendarAvailableSeries> openings,
) {
  final p = componentProperties(source, {
    'UID',
    'DTSTAMP',
    'DTSTART',
    'DTEND',
    'DURATION',
    'PRIORITY',
    'BUSYTYPE',
    'CREATED',
    'LAST-MODIFIED',
    'SEQUENCE',
    'SUMMARY',
    'DESCRIPTION',
    'LOCATION',
  });
  final uid = componentText(requiredProperty(p, 'UID'));
  if (uid.isEmpty) componentFail(IcalendarComponentError.invalidValue);
  TimedValue? bound(String name, bool end) {
    final prop = p[name]?.single;
    if (prop == null) return null;
    final value = _temporal(prop, zones, exclusiveEnd: end);
    if (value is! TimedValue) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    return value;
  }

  final start = bound('DTSTART', false), end = bound('DTEND', true);
  CalendarDuration? duration;
  if (p['DURATION'] != null) {
    final prop = p['DURATION']!.single;
    componentParameters(prop, {});
    duration = parseIcalendarDuration(prop.value);
    if (start == null || end != null) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    TimedEventSpan(start: start, duration: duration);
  }
  final finish =
      end?.instant ?? (duration == null ? null : start!.add(duration));
  if (start != null && finish != null && !start.instant.isBefore(finish)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  var busy = AvailabilityKind.unavailable;
  if (p['BUSYTYPE'] != null) {
    final prop = p['BUSYTYPE']!.single;
    componentParameters(prop, {});
    busy = switch (componentToken(prop.value)) {
      'BUSY' => AvailabilityKind.busy,
      'BUSY-UNAVAILABLE' => AvailabilityKind.unavailable,
      'BUSY-TENTATIVE' => AvailabilityKind.tentative,
      _ => componentFail(IcalendarComponentError.invalidValue),
    };
  }
  return IcalendarAvailabilityDefinition._(
    source: source,
    uid: uid,
    stamp: componentUtc(requiredProperty(p, 'DTSTAMP')),
    created: p['CREATED'] == null ? null : componentUtc(p['CREATED']!.single),
    lastModified: p['LAST-MODIFIED'] == null
        ? null
        : componentUtc(p['LAST-MODIFIED']!.single),
    sequence: _componentInteger(p['SEQUENCE']?.single),
    start: start,
    end: end,
    duration: duration,
    priority: _componentInteger(p['PRIORITY']?.single, maximum: 9) ?? 0,
    closedKind: busy,
    summary: _componentTextValue(p['SUMMARY']?.single, 4096),
    description: _componentTextValue(p['DESCRIPTION']?.single, 16384),
    location: _componentTextValue(p['LOCATION']?.single, 4096),
    openings: openings,
  );
}
