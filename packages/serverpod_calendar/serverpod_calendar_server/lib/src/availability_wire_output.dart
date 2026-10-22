import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'availability_values.dart';
import 'availability_protocol_values.dart';
import 'generated/protocol.dart';

/// Builds current stored semantics, never an old raw source file. Authorization
/// belongs to the calling service. Revalidation enforces the same wire profile
/// and aggregate budgets as import, including full-horizon generated zones.
Uint8List availabilityExportBytes(
  List<CalendarAvailabilityView> definitions, {
  required IcalendarAvailabilityExtensionRegistry extensions,
}) {
  if (definitions.isEmpty || definitions.length > availabilityMaxDefinitions) {
    throw ArgumentError('Invalid export selection');
  }
  var componentCount = 0;
  for (final definition in definitions) {
    componentCount += definition.content.openings.length;
    for (final edits
        in definition.timingOverrides ?? <CalendarAvailabilityOpeningEdits>[]) {
      componentCount +=
          edits.overrides.singles.where((s) => s.replacement != null).length +
          edits.overrides.future.length;
    }
  }
  if (componentCount >
      const IcalendarComponentLimits().maxAvailableComponents) {
    throw const AvailabilityLimitException('exportComponents');
  }
  final writer = _Writer();
  final components = <IcalendarSyntaxComponent>[];
  for (final definition in definitions) {
    final content = validateAvailabilityContent(definition.content);
    final edits = validateAvailabilityEdits(
      content,
      definition.timingOverrides,
    );
    final protocol = validateAvailabilityProtocolState(
      definition.protocolState,
      content,
      edits: edits,
    );
    components.add(
      writer.definition(definition.protocolUid, content, edits, protocol),
    );
  }
  final zones = writer.zones.toList()..sort();
  if (zones.length > const IcalendarComponentLimits().maxZones) {
    throw const AvailabilityLimitException('exportZones');
  }
  final source = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent('VCALENDAR', [
      IcalendarSyntaxProperty('VERSION', '2.0'),
      IcalendarSyntaxProperty(
        'PRODID',
        '-//serverpod_calendar//Availability//EN',
      ),
      IcalendarSyntaxProperty('CALSCALE', 'GREGORIAN'),
      for (final zone in zones) createIcalendarTimeZone(zone),
      ...components,
    ]),
  ]);
  final validated = validateIcalendarAvailabilityCalendar(
    source,
    extensions: extensions,
  );
  return serializeIcalendarAvailabilityCalendar(validated);
}

final class _Writer {
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
    if (value.zoneId != null) parameter('TZID', value.zoneId!),
    if (future) parameter('RANGE', 'THISANDFUTURE'),
  ]);
  List<IcalendarSyntaxEntry> span(CalendarEventTiming value) => [
    time('DTSTART', value),
    if (value.end != null)
      property('DTEND', civil(value, value.end!, end: true), [
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
  List<IcalendarSyntaxEntry> metadata(CalendarAvailabilitySourceMetadata? m) {
    if (m == null) return [];
    IcalendarSyntaxProperty annotated(
      String name,
      CalendarAvailabilityText v,
    ) => text(
      name,
      v.value,
      CalendarTextParameters(
        language: v.language,
        alternativeUri: v.alternativeUri,
      ),
    );
    return [
      if (m.summary != null) annotated('SUMMARY', m.summary!),
      if (m.description != null) annotated('DESCRIPTION', m.description!),
      if (m.location != null) annotated('LOCATION', m.location!),
      for (final g in m.categories ?? <CalendarAvailabilityCategoryGroup>[])
        property('CATEGORIES', g.values.map(encodeIcalendarText).join(','), [
          if (g.language != null) parameter('LANGUAGE', g.language!),
        ]),
      for (final c in m.comments ?? <CalendarAvailabilityText>[])
        annotated('COMMENT', c),
      for (final c in m.contacts ?? <CalendarAvailabilityText>[])
        annotated('CONTACT', c),
      for (final e in m.extensions ?? <CalendarAvailabilityExtension>[])
        text(e.name, e.value),
    ];
  }

  CalendarAvailabilitySourceMetadata definitionMetadata(
    CalendarAvailabilityContent v,
  ) {
    CalendarAvailabilityText? annotated(
      String? text,
      CalendarTextParameters? p,
    ) => text == null
        ? null
        : CalendarAvailabilityText(
            value: text,
            language: p?.language,
            alternativeUri: p?.alternativeUri,
          );
    return CalendarAvailabilitySourceMetadata(
      summary: annotated(v.summary, v.textParameters?.summary),
      description: annotated(v.description, v.textParameters?.description),
      location: annotated(v.location, v.textParameters?.location),
      categories:
          v.categoryGroups ??
          ((v.categories?.isNotEmpty ?? false)
              ? [
                  CalendarAvailabilityCategoryGroup(
                    values: v.categories!,
                    language: v.textParameters?.categoryLanguage,
                  ),
                ]
              : null),
      comments: [
        for (var i = 0; i < (v.comments?.length ?? 0); i++)
          annotated(v.comments![i], v.textParameters?.comments?[i])!,
      ],
      contacts: v.contacts,
      extensions: v.extensions,
    );
  }

  String rule(CalendarEventRule v) {
    const weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    String numbers(String key, List<int> values) => '$key=${values.join(',')}';
    return [
      'FREQ=${v.frequency.name.toUpperCase()}',
      'INTERVAL=${v.interval}',
      if (v.count != null) 'COUNT=${v.count}',
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

  List<IcalendarSyntaxEntry> recurrence(CalendarAvailabilityOpening v) => [
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
  IcalendarSyntaxComponent definition(
    String uid,
    CalendarAvailabilityContent v,
    List<CalendarAvailabilityOpeningEdits>? edits,
    CalendarAvailabilityProtocolState protocol,
  ) {
    final organizer = v.organizer;
    return IcalendarSyntaxComponent('VAVAILABILITY', [
      text('UID', uid),
      ...stamps(protocol.stamp, protocol.created, protocol.lastModified),
      if (protocol.sequence != null)
        property('SEQUENCE', '${protocol.sequence}'),
      if (v.validFrom != null) time('DTSTART', v.validFrom!),
      if (v.validUntil != null) time('DTEND', v.validUntil!, end: true),
      if (v.validDuration != null)
        property('DURATION', duration(v.validDuration!)),
      property('PRIORITY', '${v.priority}'),
      property('BUSYTYPE', switch (v.closedKind) {
        CalendarFreeBusyKind.busy => 'BUSY',
        CalendarFreeBusyKind.tentative => 'BUSY-TENTATIVE',
        CalendarFreeBusyKind.unavailable => 'BUSY-UNAVAILABLE',
        _ => throw ArgumentError('Invalid closed type'),
      }),
      ...metadata(definitionMetadata(v)),
      if (v.url != null) property('URL', v.url!),
      if (v.classification != null)
        property('CLASS', v.classification!.name.toUpperCase()),
      if (organizer != null)
        property('ORGANIZER', organizer.address, [
          if (organizer.commonName != null)
            parameter('CN', organizer.commonName!),
          if (organizer.language != null)
            parameter('LANGUAGE', organizer.language!),
          if (organizer.directoryUri != null)
            parameter('DIR', organizer.directoryUri!),
        ]),
      for (final opening in v.openings)
        ...openingComponents(
          opening,
          openingEdits(edits, opening.uid),
          protocol.openings.singleWhere((s) => s.openingUid == opening.uid),
        ),
    ]);
  }

  List<IcalendarSyntaxComponent> openingComponents(
    CalendarAvailabilityOpening v,
    CalendarEventTimingOverrides? edits,
    CalendarAvailabilityOpeningProtocolState state,
  ) {
    if (edits?.singles.any((s) => s.cancelled) ?? false) {
      throw ArgumentError(
        'Native skipped occurrence state is not wire representable',
      );
    }
    IcalendarSyntaxComponent override(
      CalendarEventTiming original,
      CalendarEventTiming replacement,
      bool future,
    ) {
      final versions =
          state.overrides
              ?.where(
                (s) =>
                    s.isThisAndFuture == future &&
                    jsonEncode(s.originalStart.toJson()) ==
                        jsonEncode(original.toJson()),
              )
              .toList() ??
          [];
      if (versions.length != 1) {
        throw ArgumentError('Missing component version');
      }
      final version = versions.single;
      return IcalendarSyntaxComponent('AVAILABLE', [
        text('UID', v.protocolUid!),
        ...stamps(version.stamp, version.created, version.lastModified),
        time('RECURRENCE-ID', original, future: future),
        ...span(replacement),
        ...metadata(version.metadata),
      ]);
    }

    return [
      IcalendarSyntaxComponent('AVAILABLE', [
        text('UID', v.protocolUid!),
        ...stamps(state.stamp, state.created, state.lastModified),
        ...span(v.timing),
        ...recurrence(v),
        ...metadata(availabilitySourceMetadata(v)),
      ]),
      for (final single in edits?.singles ?? <CalendarEventSingleOverride>[])
        if (single.replacement != null)
          override(single.originalStart, single.replacement!, false),
      for (final future in edits?.future ?? <CalendarEventFutureOverride>[])
        override(future.originalStart, future.replacement, true),
    ];
  }
}
