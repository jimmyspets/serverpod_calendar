import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_protocol_values.dart';
import 'event_values.dart';
import 'event_wire_output.dart';
import 'event_wire_storage.dart';
import 'generated/protocol.dart';

/// Builds a bounded, untrusted REQUEST projection for an exceptional anchor.
/// An excluded anchor remains excluded; an exclusion alone does not prove a
/// cancellation or authority. Complete validation runs before and after.
IcalendarSyntaxDocument projectPublishedExceptionalRangeRestoration({
  required IcalendarSyntaxDocument basis,
  required CalendarEventTiming originalStart,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  try {
    return _projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: originalStart,
      sharedWorkBudget: sharedWorkBudget,
    );
  } on IcalendarSyntaxException catch (e) {
    if (e.kind == IcalendarSyntaxError.limitExceeded) {
      throw const RecurrenceLimitException('publishedRestorationSource');
    }
    throw ArgumentError('Unsupported published range restoration');
  } on IcalendarComponentException catch (e) {
    if (e.kind == IcalendarComponentError.limitExceeded) {
      throw const RecurrenceLimitException('publishedRestorationWork');
    }
    throw ArgumentError('Unsupported published range restoration');
  } on ZoneCoverageException {
    throw ArgumentError('Unsupported published range restoration');
  } on ArgumentError {
    throw ArgumentError('Unsupported published range restoration');
  } on StateError {
    throw ArgumentError('Unsupported published range restoration');
  }
}

IcalendarSyntaxDocument _projectPublishedExceptionalRangeRestoration({
  required IcalendarSyntaxDocument basis,
  required CalendarEventTiming originalStart,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  if (work.maxWork > eventMaxCandidateWork) {
    throw ArgumentError('Invalid restoration work limit');
  }
  validatePublishedRangeRestorationPair(
    basis: basis,
    candidate: basis,
    sharedWorkBudget: work,
  );
  final message = validateIcalendarSchedulingMessage(
    basis,
    sharedWorkBudget: work,
  );
  final root = basis.components.single;
  final calendar = validateIcalendarEventCalendar(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(root.name, [
        for (final entry in root.entries)
          if (entry is! IcalendarSyntaxProperty ||
              entry.canonicalName != 'METHOD')
            entry,
      ]),
    ]),
    sharedWorkBudget: work,
  );
  final projection = eventWireProjection(
    calendar.series.single,
    sharedWorkBudget: work,
  );
  final content = projection.content;
  final input =
      projection.edits ?? CalendarEventTimingOverrides(singles: [], future: []);
  final recurrence = content.recurrence;
  final anchorKey = eventComponentKey(originalStart, false);
  final excluded =
      recurrence?.exclusions.any(
        (v) => eventComponentKey(v, false) == anchorKey,
      ) ??
      false;
  final searchContent = excluded
      ? content.copyWith(
          recurrence: recurrence!.copyWith(
            exclusions: recurrence.exclusions
                .where((v) => eventComponentKey(v, false) != anchorKey)
                .toList(),
          ),
        )
      : content;
  if (excluded &&
      !eventSchedulingMember(
        searchContent,
        originalStart,
        sharedWorkBudget: work,
      )) {
    throw ArgumentError('Excluded anchor is not an original');
  }
  CalendarEventTiming? next;
  if (originalStart.kind == CalendarEventTimeKind.date) {
    final last = CalendarDate(year: 2099, month: 12, day: 31);
    final date = CalendarDate(
      year: originalStart.start.year,
      month: originalStart.start.month,
      day: originalStart.start.day,
    );
    if (date != last) {
      next = eventSchedulingNextDateInWindow(
        searchContent,
        originalStart,
        last,
        sharedWorkBudget: work,
      );
    }
  } else {
    final last = CalendarEventTiming(
      kind: originalStart.kind,
      zoneId: originalStart.zoneId,
      start: CalendarEventCivil(
        year: 2099,
        month: 12,
        day: 31,
        hour: 23,
        minute: 59,
        second: 59,
      ),
    );
    if (jsonEncode(originalStart.toJson()) != jsonEncode(last.toJson())) {
      next = eventSchedulingNextTimedInWindow(
        searchContent,
        originalStart,
        last,
        sharedWorkBudget: work,
      );
    }
  }
  final retained = <EventSchedulingOriginal>[
    for (final row in input.singles)
      EventSchedulingOriginal(row.originalStart, false),
    for (final row in input.future)
      EventSchedulingOriginal(row.originalStart, true),
  ];
  (CalendarEventTimingOverrides, List<EventSchedulingOriginal>) projected;
  if (excluded) {
    if (next == null) {
      final last = originalStart.kind == CalendarEventTimeKind.date
          ? eventSchedulingDateIsProvablyLast(
              searchContent,
              originalStart,
              sharedWorkBudget: work,
            )
          : eventSchedulingTimedIsProvablyLast(
              searchContent,
              originalStart,
              sharedWorkBudget: work,
            );
      if (!last) throw ArgumentError('Unable to establish final original');
      return basis;
    }
    projected = eventSchedulingRangeRestoration(
      content,
      input,
      retained,
      next,
      sharedWorkBudget: work,
    );
  } else {
    projected = eventSchedulingExceptionalAnchorStep(
      content,
      input,
      retained,
      originalStart,
      next,
      sharedWorkBudget: work,
    );
  }
  final existing = {
    for (final row in input.singles)
      eventComponentKey(row.originalStart, false),
    for (final row in input.future) eventComponentKey(row.originalStart, true),
  };
  final master = message.events.singleWhere((v) => !v.isOverride);
  final writer = EventComponentWriter();
  IcalendarSyntaxComponent component(
    CalendarEventTiming original,
    CalendarEventTiming timing,
    CalendarEventOccurrenceContent? own,
    bool future,
  ) => IcalendarSyntaxComponent('VEVENT', [
    for (final property
        in master.source.entries.whereType<IcalendarSyntaxProperty>())
      if ({
        'UID',
        'DTSTAMP',
        'SEQUENCE',
        'ORGANIZER',
        'ATTENDEE',
      }.contains(property.canonicalName))
        property,
    writer.time('RECURRENCE-ID', original, future: future),
    ...writer.span(timing),
    if (own?.summary != null &&
        !(own!.summary!.isEmpty && content.summary == null))
      writer.text('SUMMARY', own.summary!, own.textParameters?.summary),
    if (own?.description != null &&
        !(own!.description!.isEmpty && content.description == null))
      writer.text(
        'DESCRIPTION',
        own.description!,
        own.textParameters?.description,
      ),
    if (own?.location != null &&
        !(own!.location!.isEmpty && content.location == null))
      writer.text('LOCATION', own.location!, own.textParameters?.location),
  ]);
  final extra = <IcalendarSyntaxComponent>[
    for (final row in projected.$1.singles)
      if (!existing.contains(eventComponentKey(row.originalStart, false)))
        component(
          row.originalStart,
          row.replacement!,
          row.contentOverrides,
          false,
        ),
    for (final row in projected.$1.future)
      if (!existing.contains(eventComponentKey(row.originalStart, true)))
        component(
          row.originalStart,
          row.replacement,
          row.contentOverrides,
          true,
        ),
  ];
  final candidate = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent(root.name, [...root.entries, ...extra]),
  ]);
  validatePublishedRangeRestorationPair(
    basis: basis,
    candidate: candidate,
    sharedWorkBudget: work,
  );
  return candidate;
}

/// Validates two complete REQUESTs as a bounded restoration projection.
/// This pure check does not construct a candidate or establish authority.
void validatePublishedRangeRestorationPair({
  required IcalendarSyntaxDocument basis,
  required IcalendarSyntaxDocument candidate,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  try {
    _validatePublishedRangeRestorationPair(
      basis: basis,
      candidate: candidate,
      sharedWorkBudget: sharedWorkBudget,
    );
  } on IcalendarSyntaxException catch (e) {
    if (e.kind == IcalendarSyntaxError.limitExceeded) {
      throw const RecurrenceLimitException('publishedRestorationSource');
    }
    throw ArgumentError('Unsupported published range restoration');
  } on IcalendarComponentException catch (e) {
    if (e.kind == IcalendarComponentError.limitExceeded) {
      throw const RecurrenceLimitException('publishedRestorationWork');
    }
    throw ArgumentError('Unsupported published range restoration');
  } on ZoneCoverageException {
    throw ArgumentError('Unsupported published range restoration');
  } on ArgumentError {
    throw ArgumentError('Unsupported published range restoration');
  } on StateError {
    throw ArgumentError('Unsupported published range restoration');
  }
}

void _validatePublishedRangeRestorationPair({
  required IcalendarSyntaxDocument basis,
  required IcalendarSyntaxDocument candidate,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final work =
      sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  if (work.maxWork > eventMaxCandidateWork) {
    throw ArgumentError('Invalid restoration work limit');
  }
  const syntaxLimits = IcalendarSyntaxLimits(maxBytes: 524288);
  const limits = IcalendarComponentLimits(
    maxEvents: 65,
    maxOverridesPerEvent: 64,
    maxZones: 32,
    maxCandidates: eventMaxCandidateWork,
  );

  ({EventWireProjection value, String uid}) read(
    IcalendarSyntaxDocument document,
  ) {
    final bytes = serializeIcalendarSyntax(document, limits: syntaxLimits);
    for (var i = 0; i < bytes.length; i += 64) {
      work.charge();
    }
    final message = validateIcalendarSchedulingMessage(
      document,
      syntaxLimits: syntaxLimits,
      limits: limits,
      sharedWorkBudget: work,
    );
    if (message.method != IcalendarSchedulingMethod.request ||
        document.components.length != 1) {
      throw ArgumentError('Expected one complete REQUEST');
    }
    final master = message.events.singleWhere((event) => !event.isOverride);
    String roster(IcalendarEventParticipants participants) {
      if (participants.organizer == null ||
          participants.attendees.isEmpty ||
          participants.attendees.length > 64 ||
          participants.attendees.map((v) => v.address).toSet().length !=
              participants.attendees.length) {
        throw ArgumentError('Invalid scheduling roster');
      }
      final attendees = participants.attendees.map((v) => v.address).toList()
        ..sort();
      return jsonEncode([participants.organizer!.address, attendees]);
    }

    final claims = roster(master.participants);
    for (final event in message.events) {
      work.charge();
      if (event.sequence == null ||
          event.status == IcalendarEventStatus.cancelled ||
          roster(event.participants) != claims) {
        throw ArgumentError('Unsupported published component');
      }
    }
    final root = document.components.single;
    if (root.canonicalName != 'VCALENDAR') {
      throw ArgumentError('Expected VCALENDAR');
    }
    final calendar = validateIcalendarEventCalendar(
      IcalendarSyntaxDocument([
        IcalendarSyntaxComponent(root.name, [
          for (final entry in root.entries)
            if (entry is! IcalendarSyntaxProperty ||
                entry.canonicalName != 'METHOD')
              entry,
        ]),
      ]),
      syntaxLimits: syntaxLimits,
      limits: limits,
      sharedWorkBudget: work,
    );
    if (calendar.series.length != 1) {
      throw ArgumentError('Expected one event series');
    }
    final series = calendar.series.single;
    return (
      value: eventWireProjection(series, sharedWorkBudget: work),
      uid: series.master.uid,
    );
  }

  final first = read(basis), second = read(candidate);
  final before = first.value, after = second.value;
  if (first.uid != second.uid ||
      jsonEncode(before.content.toJson()) !=
          jsonEncode(after.content.toJson()) ||
      jsonEncode(before.protocolState.version.toJson()) !=
          jsonEncode(after.protocolState.version.toJson()) ||
      before.protocolState.statusPresent != after.protocolState.statusPresent ||
      before.protocolState.transparencyPresent !=
          after.protocolState.transparencyPresent ||
      jsonEncode(before.protocolState.sourceMetadata?.toJson()) !=
          jsonEncode(after.protocolState.sourceMetadata?.toJson())) {
    throw ArgumentError('Published master changed');
  }
  final afterVersions = {
    for (final row in after.protocolState.overrides)
      eventComponentKey(row.originalStart, row.isThisAndFuture): row,
  };
  for (final row in before.protocolState.overrides) {
    final state =
        afterVersions[eventComponentKey(
          row.originalStart,
          row.isThisAndFuture,
        )];
    if (state == null ||
        jsonEncode(state.toJson()) != jsonEncode(row.toJson())) {
      throw ArgumentError('Published component protocol state changed');
    }
  }
  Map<String, CalendarEventSourceMetadata?> metadata(
    CalendarEventTimingOverrides? edits,
  ) => {
    for (final v in edits?.singles ?? <CalendarEventSingleOverride>[])
      eventComponentKey(v.originalStart, false): v.sourceMetadata,
    for (final v in edits?.future ?? <CalendarEventFutureOverride>[])
      eventComponentKey(v.originalStart, true): v.sourceMetadata,
  };
  final oldMetadata = metadata(before.edits),
      newMetadata = metadata(after.edits);
  Map<String, Object> components(CalendarEventTimingOverrides? edits) => {
    for (final v in edits?.singles ?? <CalendarEventSingleOverride>[])
      eventComponentKey(v.originalStart, false): v.toJson(),
    for (final v in edits?.future ?? <CalendarEventFutureOverride>[])
      eventComponentKey(v.originalStart, true): v.toJson(),
  };
  final oldComponents = components(before.edits),
      newComponents = components(after.edits);
  for (final entry in oldComponents.entries) {
    if (jsonEncode(entry.value) != jsonEncode(newComponents[entry.key])) {
      throw ArgumentError('Published component changed');
    }
  }
  for (final entry in newMetadata.entries) {
    final actual = jsonEncode(entry.value?.toJson());
    final expected = jsonEncode(oldMetadata[entry.key]?.toJson());
    final inherited = jsonEncode(before.protocolState.sourceMetadata?.toJson());
    if (oldMetadata.containsKey(entry.key)
        ? actual != expected
        : entry.value != null && actual != inherited) {
      throw ArgumentError('Occurrence source metadata changed');
    }
  }
  if (before.content.timing.kind == CalendarEventTimeKind.date) {
    eventSchedulingProveFiniteDateEquivalence(
      before.content,
      before.edits,
      after.edits,
      sharedWorkBudget: work,
    );
  } else {
    eventSchedulingProveFiniteTimedEquivalence(
      before.content,
      before.edits,
      after.edits,
      sharedWorkBudget: work,
    );
  }
}
