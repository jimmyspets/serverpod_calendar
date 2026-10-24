import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_values.dart';
import 'event_protocol_values.dart';
import 'generated/protocol.dart';

/// Pure conversion only: neither accepted syntax nor source identity grants
/// host authority or writes a database row.
final class EventStorageProposal {
  EventStorageProposal._(
    this.protocolUid,
    this.content,
    this.edits,
    this.protocolState,
    this.importBaseline,
  );
  final String protocolUid;
  final CalendarEventContent content;
  final CalendarEventTimingOverrides? edits;
  final CalendarEventProtocolState protocolState;
  final CalendarEventImportBaseline importBaseline;
}

CalendarEventDuration _duration(CalendarDuration d) => CalendarEventDuration(
  weeks: d.weeks,
  days: d.days,
  hours: d.hours,
  minutes: d.minutes,
  seconds: d.seconds,
  microsecond: d.microsecond,
);
CalendarEventTiming _value(Object value) {
  if (value is CalendarDate) {
    return CalendarEventTiming(
      kind: CalendarEventTimeKind.date,
      start: eventDate(value),
    );
  }
  final v = value as TimedValue;
  return CalendarEventTiming(
    kind: v.zoneId == null
        ? CalendarEventTimeKind.utc
        : CalendarEventTimeKind.zoned,
    zoneId: v.zoneId,
    start: eventCivil(v.civil),
  );
}

CalendarEventTiming _timedSpan(TimedEventSpan v) => _value(v.start).copyWith(
  end: v.end == null ? null : eventCivil(v.end!.civil),
  duration: v.duration == null ? null : _duration(v.duration!),
);
CalendarEventTiming _span(IcalendarEvent v) {
  final d = v.dateSpan;
  return d == null
      ? _timedSpan(v.timedSpan!)
      : _value(d.start).copyWith(
          end: d.end == null ? null : eventDate(d.end!),
          duration: d.duration == null ? null : _duration(d.duration!),
        );
}

CalendarTextParameters? _parameters(IcalendarEventText? text) =>
    text == null || text.language == null && text.alternativeUri == null
    ? null
    : CalendarTextParameters(
        language: text.language,
        alternativeUri: text.alternativeUri,
      );
CalendarEventProtocolVersion _version(IcalendarEvent v) =>
    CalendarEventProtocolVersion(
      sequence: v.sequence,
      stamp: v.stamp,
      created: v.created,
      lastModified: v.lastModified,
    );
CalendarEventRule _rule(DateRecurrenceRule d, TimedRecurrenceRule? t) =>
    CalendarEventRule(
      frequency: t == null
          ? CalendarEventFrequency.values[d.frequency.index + 2]
          : CalendarEventFrequency.values[t.frequency.index],
      interval: t?.interval ?? d.interval,
      count: t?.count ?? d.count,
      untilDate: d.until == null ? null : eventDate(d.until!),
      untilUtc: t?.until,
      weekStart: d.weekStart.isoNumber,
      byDay: [
        for (final v in d.byDay)
          CalendarEventByDay(weekday: v.weekday.isoNumber, ordinal: v.ordinal),
      ],
      byMonthDay: d.byMonthDay,
      byYearDay: d.byYearDay,
      byWeekNo: d.byWeekNo,
      byMonth: d.byMonth,
      byHour: t?.byHour ?? [],
      byMinute: t?.byMinute ?? [],
      bySetPosition: t?.bySetPosition ?? d.bySetPosition,
    );
CalendarEventRecurrence? _recurrence(IcalendarEventRecurrence? v) {
  if (v == null) return null;
  final d = v.dateSet;
  final t = v.timedSet;
  final tr = t?.rule, dr = d?.rule ?? tr?.dateSelection;
  return CalendarEventRecurrence(
    rule: dr == null ? null : _rule(dr, tr),
    inclusions: List.unmodifiable(
      d != null ? d.inclusions.map(_value) : t!.inclusions.map(_value),
    ),
    exclusions: List.unmodifiable(
      d != null ? d.exclusions.map(_value) : t!.exclusions.map(_value),
    ),
  );
}

CalendarEventSourceParticipant _participant(IcalendarEventParticipant v) =>
    CalendarEventSourceParticipant(
      address: v.address,
      parameters: v.parameters,
    );
CalendarEventSourceMetadata? _metadata(IcalendarEvent event) =>
    validateEventSourceMetadata(
      CalendarEventSourceMetadata(
        url: event.metadata.url,
        relationships: event.references.relationships
            .map(
              (r) => CalendarEventSourceRelationship(
                targetUid: r.targetUid,
                relationType: r.relationType,
              ),
            )
            .toList(),
        attachments: event.references.attachments
            .map(
              (a) => CalendarEventSourceAttachment(
                uri: a.uri,
                mediaType: a.mediaType,
                explicitUri: a.source.parameters.any(
                  (p) => p.canonicalName == 'VALUE',
                ),
              ),
            )
            .toList(),
        organizer: event.participants.organizer == null
            ? null
            : _participant(event.participants.organizer!),
        attendees: event.participants.attendees.map(_participant).toList(),
        classification: event.metadata.classification,
        categoryGroups: [
          for (final g in event.metadata.categoryGroups)
            CalendarEventSourceCategoryGroup(
              values: List.unmodifiable(g.values),
              language: g.language,
            ),
        ],
        comments: [
          for (final v in event.metadata.comments)
            CalendarEventSourceText(value: v.value, parameters: _parameters(v)),
        ],
        contacts: [
          for (final v in event.metadata.contacts)
            CalendarEventSourceText(value: v.value, parameters: _parameters(v)),
        ],
      ),
    );

EventStorageProposal eventStorageProposal(IcalendarEventSeries source) {
  final m = source.master;
  CalendarEventOccurrenceContent? own(IcalendarEvent value) =>
      validateEventOccurrenceContent(
        CalendarEventOccurrenceContent(
          summary: value.summary?.value,
          description: value.description?.value,
          location: value.location?.value,
          textParameters: CalendarEventTextParameters(
            summary: _parameters(value.summary),
            description: _parameters(value.description),
            location: _parameters(value.location),
          ),
        ),
      );
  validateEventUid(m.uid);
  final content = validateEventContent(
    CalendarEventContent(
      summary: m.summary?.value,
      description: m.description?.value,
      location: m.location?.value,
      textParameters: CalendarEventTextParameters(
        summary: _parameters(m.summary),
        description: _parameters(m.description),
        location: _parameters(m.location),
      ),
      timing: _span(m),
      status: m.status == null
          ? CalendarEventStatus.confirmed
          : CalendarEventStatus.values.byName(m.status!.name),
      transparency: m.isTransparent
          ? CalendarEventTransparency.transparent
          : CalendarEventTransparency.opaque,
      recurrence: _recurrence(m.recurrence),
      periods: m.recurrence?.timedSet?.periods.values.map(_timedSpan).toList(),
    ),
  );
  final edits = validateEventOverrides(
    content,
    CalendarEventTimingOverrides(
      singles: [
        for (final v in source.overrides.where((v) => !v.isThisAndFuture))
          CalendarEventSingleOverride(
            originalStart: _value(v.originalStart!),
            replacement: _span(v),
            cancelled: v.status == IcalendarEventStatus.cancelled,
            contentOverrides: own(v),
            sourceMetadata: _metadata(v),
          ),
      ],
      future: [
        for (final v in source.overrides.where((v) => v.isThisAndFuture))
          CalendarEventFutureOverride(
            originalStart: _value(v.originalStart!),
            replacement: _span(v),
            contentOverrides: own(v),
            sourceMetadata: _metadata(v),
          ),
      ],
    ),
  );
  final state = validateEventProtocolState(
    CalendarEventProtocolState(
      version: _version(m),
      sourceMetadata: _metadata(m),
      statusPresent: m.status != null,
      transparencyPresent: m.transparency != null,
      overrides: [
        for (final v in source.overrides)
          CalendarEventOverrideProtocolState(
            originalStart: _value(v.originalStart!),
            isThisAndFuture: v.isThisAndFuture,
            version: _version(v),
            summaryPresent: v.summary != null,
            descriptionPresent: v.description != null,
            locationPresent: v.location != null,
            statusPresent: v.status != null,
            transparencyPresent: v.transparency != null,
          ),
      ],
    ),
    content,
    edits,
  );
  return EventStorageProposal._(
    m.uid,
    content,
    edits,
    state,
    eventImportBaseline(m.uid, content, edits, state),
  );
}
