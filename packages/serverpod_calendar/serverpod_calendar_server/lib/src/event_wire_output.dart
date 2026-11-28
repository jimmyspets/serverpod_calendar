import 'dart:typed_data';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_authorization.dart';
import 'event_values.dart';
import 'event_protocol_values.dart';
import 'event_wire_storage.dart';
import 'generated/protocol.dart';

/// Current-state conversion only. The service must authorize every full source.
Uint8List eventExportBytes(List<CalendarEventPolicySnapshot> selection) {
  if (selection.isEmpty ||
      selection.length > const IcalendarComponentLimits().maxEvents) {
    throw ArgumentError('Invalid selection');
  }
  var count = 0;
  final uids = <String>{};
  for (final source in selection) {
    validateEventUid(source.protocolUid);
    if (!uids.add(source.protocolUid)) {
      throw ArgumentError('Duplicate source UID');
    }
    count +=
        1 +
        (source.timingOverrides?.singles.length ?? 0) +
        (source.timingOverrides?.future.length ?? 0);
  }
  if (count > const IcalendarComponentLimits().maxEvents) {
    throw const RecurrenceLimitException('exportComponents');
  }
  final writer = EventComponentWriter();
  final components = <IcalendarSyntaxComponent>[];
  for (final source in selection) {
    final content = validateEventContent(source.content);
    final edits = validateEventOverrides(content, source.timingOverrides);
    if (source.protocolState == null) {
      throw ArgumentError('Missing protocol state');
    }
    final state = validateEventProtocolState(
      source.protocolState!,
      content,
      edits,
    );
    components.addAll(
      writer.components(source.protocolUid, content, edits, state),
    );
  }
  final zones = writer.zones.toList()..sort();
  final document = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent('VCALENDAR', [
      IcalendarSyntaxProperty('VERSION', '2.0'),
      IcalendarSyntaxProperty(
        'PRODID',
        '-//Serverpod Calendar//Event export//EN',
      ),
      IcalendarSyntaxProperty('CALSCALE', 'GREGORIAN'),
      for (final zone in zones) createIcalendarTimeZone(zone),
      ...components,
    ]),
  ]);
  final validated = validateIcalendarEventCalendar(document);
  for (final source in selection) {
    final decoded = eventStorageProposal(
      validated.series.singleWhere((s) => s.master.uid == source.protocolUid),
    );
    // A PERIOD-only wire RDATE necessarily creates an empty recurrence wrapper
    // when decoded; the periods themselves live in a separate native field.
    // Compare that source-equivalent shape without changing native data/baselines.
    final expectedContent =
        source.content.recurrence == null &&
            (source.content.periods?.isNotEmpty ?? false)
        ? source.content.copyWith(
            recurrence: CalendarEventRecurrence(inclusions: [], exclusions: []),
          )
        : source.content;
    final expected = eventImportBaseline(
      source.protocolUid,
      expectedContent,
      source.timingOverrides,
      source.protocolState!,
    );
    if (expected.canonicalValue != decoded.importBaseline.canonicalValue) {
      throw ArgumentError(
        'Current event state is not faithfully wire representable',
      );
    }
  }
  return serializeIcalendarEventCalendar(validated);
}

/// Publication profile: native identities, complete faithful series, no alarms.
/// Authorization belongs to the publication transaction port.
Uint8List eventPublicationBytes(List<CalendarEventPolicySnapshot> selection) {
  final ordered = [...selection]
    ..sort((a, b) => a.eventId.toString().compareTo(b.eventId.toString()));
  if (ordered.length > const IcalendarComponentLimits().maxEvents ||
      ordered.map((s) => s.eventId).toSet().length != ordered.length) {
    throw ArgumentError('Invalid publication selection');
  }
  final zones = <String, IcalendarSyntaxComponent>{};
  final events = <IcalendarSyntaxComponent>[];
  for (final source in ordered) {
    // Validate faithful source semantics before applying the explicit feed
    // projection. Separate calls allow copied source UIDs in different calendars.
    final document = parseIcalendarSyntax(eventExportBytes([source]));
    for (final component
        in document.components.single.entries
            .whereType<IcalendarSyntaxComponent>()) {
      if (component.canonicalName == 'VTIMEZONE') {
        final id = component.entries
            .whereType<IcalendarSyntaxProperty>()
            .singleWhere((p) => p.canonicalName == 'TZID')
            .value;
        zones.putIfAbsent(id, () => component);
      } else if (component.canonicalName == 'VEVENT') {
        final entries = <IcalendarSyntaxEntry>[];
        for (final entry in component.entries) {
          if (entry is IcalendarSyntaxComponent &&
              entry.canonicalName == 'VALARM') {
            continue;
          }
          if (entry is IcalendarSyntaxProperty &&
              entry.canonicalName == 'RELATED-TO') {
            throw ArgumentError('Unprofiled publication source reference');
          }
          entries.add(
            entry is IcalendarSyntaxProperty && entry.canonicalName == 'UID'
                ? IcalendarSyntaxProperty(
                    'UID',
                    'urn:uuid:${source.eventId.toString().toLowerCase()}',
                  )
                : entry,
          );
        }
        events.add(IcalendarSyntaxComponent('VEVENT', entries));
      }
    }
  }
  if (events.length > const IcalendarComponentLimits().maxEvents) {
    throw const RecurrenceLimitException('publicationComponents');
  }
  final zoneNames = zones.keys.toList()..sort();
  return serializeIcalendarSyntax(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [
        IcalendarSyntaxProperty('VERSION', '2.0'),
        IcalendarSyntaxProperty(
          'PRODID',
          '-//Serverpod Calendar//Event subscription v1//EN',
        ),
        IcalendarSyntaxProperty('CALSCALE', 'GREGORIAN'),
        for (final name in zoneNames) zones[name]!,
        ...events,
      ]),
    ]),
  );
}

final class EventComponentWriter {
  final zones = <String>{};
  IcalendarSyntaxProperty property(
    String name,
    String value, [
    List<IcalendarSyntaxParameter> parameters = const [],
  ]) => IcalendarSyntaxProperty(name, value, parameters: parameters);
  IcalendarSyntaxParameter parameter(String name, String value) =>
      IcalendarSyntaxParameter(name, [value]);
  IcalendarSyntaxProperty text(
    String name,
    String value, [
    CalendarTextParameters? annotation,
  ]) => property(name, encodeIcalendarText(value), [
    if (annotation?.language != null)
      parameter('LANGUAGE', annotation!.language!),
    if (annotation?.alternativeUri != null)
      parameter('ALTREP', annotation!.alternativeUri!),
  ]);
  String utc(DateTime value) =>
      serializeIcalendarDateTime(TimedValue.utc(value));
  String duration(CalendarEventDuration v) => serializeIcalendarDuration(
    CalendarDuration(
      weeks: v.weeks,
      days: v.days,
      hours: v.hours,
      minutes: v.minutes,
      seconds: v.seconds,
      microsecond: v.microsecond,
    ),
  );
  String civil(
    CalendarEventTiming value,
    CalendarEventCivil c, {
    bool end = false,
  }) {
    final date = end && c.year == 2100 && c.month == 1 && c.day == 1
        ? const CalendarDate.exclusiveEnd()
        : CalendarDate(year: c.year, month: c.month, day: c.day);
    if (value.kind == CalendarEventTimeKind.date) {
      return serializeIcalendarDate(date, exclusiveEnd: end);
    }
    final wall = CivilDateTime(
      date: date,
      hour: c.hour,
      minute: c.minute,
      second: c.second,
      microsecond: c.microsecond,
    );
    final TimedValue timed;
    if (value.kind == CalendarEventTimeKind.utc) {
      final instant = DateTime.utc(
        c.year,
        c.month,
        c.day,
        c.hour,
        c.minute,
        c.second,
      );
      timed = end ? TimedValue.utcEnd(instant) : TimedValue.utc(instant);
    } else if (value.kind == CalendarEventTimeKind.zoned &&
        value.zoneId != null) {
      timed = end
          ? TimedValue.zonedEnd(wall, zoneId: value.zoneId!)
          : TimedValue.zoned(wall, zoneId: value.zoneId!);
      zones.add(value.zoneId!);
    } else {
      throw ArgumentError('Unsupported availability timing');
    }
    return serializeIcalendarDateTime(timed, exclusiveEnd: end);
  }

  IcalendarSyntaxProperty time(
    String name,
    CalendarEventTiming value, {
    bool end = false,
    bool future = false,
  }) => property(name, civil(value, value.start, end: end), [
    if (value.kind == CalendarEventTimeKind.date) parameter('VALUE', 'DATE'),
    if (value.zoneId != null) parameter('TZID', value.zoneId!),
    if (future) parameter('RANGE', 'THISANDFUTURE'),
  ]);
  List<IcalendarSyntaxEntry> span(CalendarEventTiming value) => [
    time('DTSTART', value),
    if (value.end != null)
      property('DTEND', civil(value, value.end!, end: true), [
        if (value.kind == CalendarEventTimeKind.date)
          parameter('VALUE', 'DATE'),
        if (value.zoneId != null) parameter('TZID', value.zoneId!),
      ]),
    if (value.duration != null) property('DURATION', duration(value.duration!)),
  ];
  List<IcalendarSyntaxEntry> stamps(
    DateTime stamp,
    DateTime? created,
    DateTime? modified,
  ) => [
    property('DTSTAMP', utc(stamp)),
    if (created != null) property('CREATED', utc(created)),
    if (modified != null) property('LAST-MODIFIED', utc(modified)),
  ];
  String rule(CalendarEventRule v) {
    const weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    String numbers(String key, List<int> values) => '$key=${values.join(',')}';
    return [
      'FREQ=${v.frequency.name.toUpperCase()}',
      'INTERVAL=${v.interval}',
      if (v.count != null) 'COUNT=${v.count}',
      if (v.untilDate != null)
        'UNTIL=${civil(CalendarEventTiming(kind: CalendarEventTimeKind.date, start: v.untilDate!), v.untilDate!)}',
      if (v.untilUtc != null) 'UNTIL=${utc(v.untilUtc!)}',
      'WKST=${weekdays[v.weekStart - 1]}',
      if (v.byDay.isNotEmpty)
        'BYDAY=${v.byDay.map((d) => '${d.ordinal ?? ''}${weekdays[d.weekday - 1]}').join(',')}',
      for (final pair in [
        ('BYMONTHDAY', v.byMonthDay),
        ('BYYEARDAY', v.byYearDay),
        ('BYWEEKNO', v.byWeekNo),
        ('BYMONTH', v.byMonth),
        ('BYHOUR', v.byHour),
        ('BYMINUTE', v.byMinute),
        ('BYSETPOS', v.bySetPosition),
      ])
        if (pair.$2.isNotEmpty) numbers(pair.$1, pair.$2),
    ].join(';');
  }

  List<IcalendarSyntaxEntry> recurrence(CalendarEventContent v) => [
    if (v.recurrence?.rule != null)
      property('RRULE', rule(v.recurrence!.rule!)),
    for (final date in v.recurrence?.inclusions ?? <CalendarEventTiming>[])
      time('RDATE', date),
    for (final date in v.recurrence?.exclusions ?? <CalendarEventTiming>[])
      time('EXDATE', date),
    for (final period in v.periods ?? <CalendarEventTiming>[])
      property(
        'RDATE',
        '${civil(period, period.start)}/${period.end == null ? duration(period.duration!) : civil(period, period.end!, end: true)}',
        [
          parameter('VALUE', 'PERIOD'),
          if (period.zoneId != null) parameter('TZID', period.zoneId!),
        ],
      ),
  ];

  List<IcalendarSyntaxEntry> version(CalendarEventProtocolVersion v) => [
    ...stamps(v.stamp, v.created, v.lastModified),
    if (v.sequence != null) property('SEQUENCE', '${v.sequence}'),
  ];
  List<IcalendarSyntaxEntry> content(
    CalendarEventContent v, {
    bool summary = true,
    bool description = true,
    bool location = true,
    bool status = true,
    bool transparency = true,
    bool cancelled = false,
  }) => [
    if (summary && v.summary != null)
      text('SUMMARY', v.summary!, v.textParameters?.summary),
    if (description && v.description != null)
      text('DESCRIPTION', v.description!, v.textParameters?.description),
    if (location && v.location != null)
      text('LOCATION', v.location!, v.textParameters?.location),
    if (status)
      property('STATUS', cancelled ? 'CANCELLED' : v.status.name.toUpperCase()),
    if (transparency) property('TRANSP', v.transparency.name.toUpperCase()),
  ];
  IcalendarSyntaxProperty participant(
    String name,
    CalendarEventSourceParticipant p,
  ) => IcalendarSyntaxProperty(
    name,
    p.address,
    parameters: [
      for (final e in p.parameters.entries)
        IcalendarSyntaxParameter(e.key, e.value),
    ],
  );
  List<IcalendarSyntaxEntry> sourceMetadata(
    CalendarEventSourceMetadata? value,
  ) => [
    if (value?.organizer != null) participant('ORGANIZER', value!.organizer!),
    for (final p in value?.attendees ?? <CalendarEventSourceParticipant>[])
      participant('ATTENDEE', p),
    for (final r in value?.relationships ?? <CalendarEventSourceRelationship>[])
      property('RELATED-TO', encodeIcalendarText(r.targetUid), [
        if (r.relationType != null) parameter('RELTYPE', r.relationType!),
      ]),
    for (final a in value?.attachments ?? <CalendarEventSourceAttachment>[])
      property('ATTACH', a.uri, [
        if (a.explicitUri) parameter('VALUE', 'URI'),
        if (a.mediaType != null) parameter('FMTTYPE', a.mediaType!),
      ]),
    if (value?.url != null) property('URL', value!.url!),
    if (value?.classification != null)
      property('CLASS', value!.classification!),
    for (final g
        in value?.categoryGroups ?? <CalendarEventSourceCategoryGroup>[])
      property('CATEGORIES', g.values.map(encodeIcalendarText).join(','), [
        if (g.language != null) parameter('LANGUAGE', g.language!),
      ]),
    for (final t in value?.comments ?? <CalendarEventSourceText>[])
      text('COMMENT', t.value, t.parameters),
    for (final t in value?.contacts ?? <CalendarEventSourceText>[])
      text('CONTACT', t.value, t.parameters),
  ];

  List<IcalendarSyntaxComponent> components(
    String uid,
    CalendarEventContent v,
    CalendarEventTimingOverrides? edits,
    CalendarEventProtocolState state,
  ) {
    IcalendarSyntaxComponent override(
      CalendarEventTiming original,
      CalendarEventTiming? replacement,
      bool future,
      bool cancelled,
      CalendarEventOccurrenceContent? own,
      CalendarEventSourceMetadata? metadata,
    ) {
      if (replacement == null) {
        throw ArgumentError(
          'Occurrence timing inheritance is not wire representable',
        );
      }
      final checkpoint = state.overrides.singleWhere(
        (s) =>
            eventComponentKey(s.originalStart, s.isThisAndFuture) ==
            eventComponentKey(original, future),
      );
      return IcalendarSyntaxComponent('VEVENT', [
        text('UID', uid),
        ...version(checkpoint.version),
        time('RECURRENCE-ID', original, future: future),
        ...span(replacement),
        ...sourceMetadata(metadata),
        ...content(
          v.copyWith(
            summary: own?.summary,
            description: own?.description,
            location: own?.location,
            textParameters: own?.textParameters,
          ),
          summary: checkpoint.summaryPresent,
          description: checkpoint.descriptionPresent,
          location: checkpoint.locationPresent,
          status: checkpoint.statusPresent,
          transparency: checkpoint.transparencyPresent,
          cancelled: cancelled,
        ),
        for (final a in metadata?.alarms ?? <CalendarEventSourceAlarm>[])
          eventAlarmSyntax(a),
      ]);
    }

    return [
      IcalendarSyntaxComponent('VEVENT', [
        text('UID', uid),
        ...version(state.version),
        ...sourceMetadata(state.sourceMetadata),
        ...span(v.timing),
        ...recurrence(v),
        ...content(
          v,
          status: state.statusPresent,
          transparency: state.transparencyPresent,
        ),
        for (final a
            in state.sourceMetadata?.alarms ?? <CalendarEventSourceAlarm>[])
          eventAlarmSyntax(a),
      ]),
      for (final s in edits?.singles ?? <CalendarEventSingleOverride>[])
        override(
          s.originalStart,
          s.replacement,
          false,
          s.cancelled,
          s.contentOverrides,
          s.sourceMetadata,
        ),
      for (final s in edits?.future ?? <CalendarEventFutureOverride>[])
        override(
          s.originalStart,
          s.replacement,
          true,
          false,
          s.contentOverrides,
          s.sourceMetadata,
        ),
    ];
  }
}
