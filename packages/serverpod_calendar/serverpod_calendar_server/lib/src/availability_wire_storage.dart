import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'availability_values.dart';
import 'availability_protocol_values.dart';
import 'event_values.dart';
import 'generated/protocol.dart';

/// Validated storage proposal only. No database writes or host approval.
final class AvailabilityStorageProposal {
  AvailabilityStorageProposal._(
    this.protocolUid,
    this.content,
    this.edits,
    this.protocolState,
  );
  final String protocolUid;
  final CalendarAvailabilityContent content;
  final List<CalendarAvailabilityOpeningEdits>? edits;
  final CalendarAvailabilityProtocolState protocolState;
}

CalendarEventDuration _duration(CalendarDuration d) => CalendarEventDuration(
  weeks: d.weeks,
  days: d.days,
  hours: d.hours,
  minutes: d.minutes,
  seconds: d.seconds,
  microsecond: d.microsecond,
);
CalendarEventTiming _value(TimedValue v) => CalendarEventTiming(
  kind: v.zoneId == null
      ? CalendarEventTimeKind.utc
      : CalendarEventTimeKind.zoned,
  zoneId: v.zoneId,
  start: eventCivil(v.civil),
);
CalendarEventTiming _span(TimedEventSpan v) => _value(v.start).copyWith(
  end: v.end == null ? null : eventCivil(v.end!.civil),
  duration: v.duration == null ? null : _duration(v.duration!),
);
CalendarTextParameters? _parameters(IcalendarEventText? t) =>
    t == null || (t.language == null && t.alternativeUri == null)
    ? null
    : CalendarTextParameters(
        language: t.language,
        alternativeUri: t.alternativeUri,
      );
CalendarAvailabilityText _text(IcalendarEventText t) =>
    CalendarAvailabilityText(
      value: t.value,
      language: t.language,
      alternativeUri: t.alternativeUri,
    );
List<CalendarAvailabilityCategoryGroup>? _categories(
  IcalendarAvailabilityMetadata m,
) => m.categoryGroups.isEmpty
    ? null
    : List.unmodifiable([
        for (final g in m.categoryGroups)
          CalendarAvailabilityCategoryGroup(
            values: List.unmodifiable(g.values),
            language: g.language,
          ),
      ]);
List<CalendarAvailabilityExtension>? _extensions(
  IcalendarAvailabilityMetadata m,
) => m.extensions.isEmpty
    ? null
    : List.unmodifiable([
        for (final v in m.extensions)
          CalendarAvailabilityExtension(name: v.name, value: v.value),
      ]);
List<CalendarAvailabilityText>? _contacts(IcalendarAvailabilityMetadata m) =>
    m.contacts.isEmpty ? null : List.unmodifiable(m.contacts.map(_text));
CalendarAvailabilityTextParameters _annotations(
  IcalendarEventText? summary,
  IcalendarEventText? description,
  IcalendarEventText? location,
  IcalendarAvailabilityMetadata metadata,
) => CalendarAvailabilityTextParameters(
  summary: _parameters(summary),
  description: _parameters(description),
  location: _parameters(location),
  comments: metadata.comments.isEmpty
      ? null
      : List.unmodifiable(metadata.comments.map(_parameters)),
);
CalendarAvailabilitySourceMetadata _source(IcalendarAvailable v) =>
    CalendarAvailabilitySourceMetadata(
      summary: v.summary == null ? null : _text(v.summary!),
      description: v.description == null ? null : _text(v.description!),
      location: v.location == null ? null : _text(v.location!),
      categories: _categories(v.metadata),
      comments: v.metadata.comments.isEmpty
          ? null
          : List.unmodifiable(v.metadata.comments.map(_text)),
      contacts: _contacts(v.metadata),
      extensions: _extensions(v.metadata),
    );
CalendarEventRecurrence? _recurrence(TimedRecurrenceSet? set) {
  if (set == null) return null;
  final r = set.rule;
  final d = r?.dateSelection;
  return CalendarEventRecurrence(
    rule: r == null
        ? null
        : CalendarEventRule(
            frequency: CalendarEventFrequency.values[r.frequency.index],
            interval: r.interval,
            count: r.count,
            untilUtc: r.until,
            weekStart: d!.weekStart.isoNumber,
            byDay: [
              for (final v in d.byDay)
                CalendarEventByDay(
                  weekday: v.weekday.isoNumber,
                  ordinal: v.ordinal,
                ),
            ],
            byMonthDay: d.byMonthDay,
            byYearDay: d.byYearDay,
            byWeekNo: d.byWeekNo,
            byMonth: d.byMonth,
            byHour: r.byHour,
            byMinute: r.byMinute,
            bySetPosition: r.bySetPosition,
          ),
    inclusions: List.unmodifiable(set.inclusions.map(_value)),
    exclusions: List.unmodifiable(set.exclusions.map(_value)),
  );
}

/// Source is accepted by the pure adapter; current host import/organizer/extension
/// authority must still be checked in the future authenticated import service.
AvailabilityStorageProposal availabilityStorageProposal(
  IcalendarAvailabilityDefinition source, {
  UuidValue Function()? newOpeningId,
}) {
  validateAvailabilityUid(source.uid);
  final makeId = newOpeningId ?? () => const Uuid().v4obj();
  final openings = <CalendarAvailabilityOpening>[];
  final edits = <CalendarAvailabilityOpeningEdits>[];
  final states = <CalendarAvailabilityOpeningProtocolState>[];
  final ids = <UuidValue>{};
  for (final series in source.openings) {
    final m = series.master;
    final id = makeId();
    if (!ids.add(id)) throw ArgumentError('Duplicate native opening ID');
    openings.add(
      CalendarAvailabilityOpening(
        uid: id,
        protocolUid: m.uid,
        timing: _span(m.span),
        recurrence: _recurrence(m.recurrence),
        periods: m.recurrence?.periods.isNotEmpty == true
            ? List.unmodifiable(m.recurrence!.periods.values.map(_span))
            : null,
        summary: m.summary?.value,
        description: m.description?.value,
        location: m.location?.value,
        categoryGroups: _categories(m.metadata),
        comments: m.metadata.comments.isEmpty
            ? null
            : List.unmodifiable(m.metadata.comments.map((v) => v.value)),
        contacts: _contacts(m.metadata),
        extensions: _extensions(m.metadata),
        textParameters: _annotations(
          m.summary,
          m.description,
          m.location,
          m.metadata,
        ),
      ),
    );
    if (series.overrides.isNotEmpty) {
      edits.add(
        CalendarAvailabilityOpeningEdits(
          openingUid: id,
          overrides: CalendarEventTimingOverrides(
            singles: [
              for (final o in series.overrides)
                if (!o.isThisAndFuture)
                  CalendarEventSingleOverride(
                    originalStart: _value(o.originalStart!),
                    replacement: _span(o.span),
                  ),
            ],
            future: [
              for (final o in series.overrides)
                if (o.isThisAndFuture)
                  CalendarEventFutureOverride(
                    originalStart: _value(o.originalStart!),
                    replacement: _span(o.span),
                  ),
            ],
          ),
        ),
      );
    }
    states.add(
      CalendarAvailabilityOpeningProtocolState(
        openingUid: id,
        stamp: m.stamp,
        created: m.created,
        lastModified: m.lastModified,
        overrides: series.overrides.isEmpty
            ? null
            : List.unmodifiable([
                for (final o in series.overrides)
                  CalendarAvailabilityOverrideProtocolState(
                    originalStart: _value(o.originalStart!),
                    isThisAndFuture: o.isThisAndFuture,
                    stamp: o.stamp,
                    created: o.created,
                    lastModified: o.lastModified,
                    metadata: _source(o),
                  ),
              ]),
      ),
    );
  }
  final organizer = source.metadata.organizer;
  final content = validateAvailabilityContent(
    CalendarAvailabilityContent(
      summary: source.summary?.value,
      description: source.description?.value,
      location: source.location?.value,
      validFrom: source.start == null ? null : _value(source.start!),
      validUntil: source.end == null ? null : _value(source.end!),
      validDuration: source.duration == null
          ? null
          : _duration(source.duration!),
      priority: source.priority,
      closedKind: CalendarFreeBusyKind.values.byName(source.closedKind.name),
      openings: openings,
      categoryGroups: _categories(source.metadata),
      comments: source.metadata.comments.isEmpty
          ? null
          : List.unmodifiable(source.metadata.comments.map((v) => v.value)),
      contacts: _contacts(source.metadata),
      extensions: _extensions(source.metadata),
      url: source.metadata.url,
      classification: source.metadata.classification == null
          ? null
          : CalendarAvailabilityClass.values.byName(
              source.metadata.classification!.toLowerCase(),
            ),
      organizer: organizer == null
          ? null
          : CalendarAvailabilityOrganizer(
              address: organizer.address,
              commonName: organizer.commonName,
              language: organizer.language,
              directoryUri: organizer.directoryUri,
            ),
      textParameters: _annotations(
        source.summary,
        source.description,
        source.location,
        source.metadata,
      ),
    ),
  );
  final changes = validateAvailabilityEdits(content, edits);
  final protocol = validateAvailabilityProtocolState(
    CalendarAvailabilityProtocolState(
      sequence: source.sequence,
      stamp: source.stamp,
      created: source.created,
      lastModified: source.lastModified,
      openings: List.unmodifiable(states),
    ),
    content,
    edits: changes,
  );
  return AvailabilityStorageProposal._(source.uid, content, changes, protocol);
}
