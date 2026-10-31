import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_values.dart';
import 'event_protocol_values.dart';
import 'event_wire_output.dart';
import 'event_wire_storage.dart';
import 'generated/protocol.dart';

/// A pure proposal, never proof of origin, freshness, a clean baseline or rights.
final class CalendarInvitationOccurrenceProjection {
  const CalendarInvitationOccurrenceProjection._(
    this.protocolUid,
    this.content,
    this.timingOverrides,
    this.protocolState,
    this.originalStart,
    this.sourceMessage,
  );
  final String protocolUid;
  final CalendarEventContent content;
  final CalendarEventTimingOverrides timingOverrides;
  final CalendarEventProtocolState protocolState;
  final CalendarEventTiming originalStart;

  /// Keeps source omissions separate from retained canonical cancellation data.
  final IcalendarSchedulingMessage sourceMessage;
}

/// Proposes one detached REQUEST/CANCEL against accepted recurring values.
///
/// The caller must separately establish authority, freshness, concurrency and
/// the clean entire-series baseline before using these values in a write.
/// Throws for unsupported differences or exhausted bounded validation work.
CalendarInvitationOccurrenceProjection projectInvitationOccurrence({
  required String protocolUid,
  required CalendarEventContent content,
  CalendarEventTimingOverrides? timingOverrides,
  required CalendarEventProtocolState protocolState,
  required IcalendarSchedulingMessage message,
  required String recipientAddress,
  int maxCandidateWork = eventMaxCandidateWork,
}) {
  try {
    RangeError.checkValueInInterval(maxCandidateWork, 1, eventMaxCandidateWork);
    // A parsed message may have been accepted with larger caller limits.
    // Reapply this projection's syntax/shape ceilings before traversing claims.
    serializeIcalendarSyntax(message.source);
    if (message.timeZones.length > const IcalendarComponentLimits().maxZones) {
      throw const RecurrenceLimitException('invitationProjectionZones');
    }
    final work = RecurrenceWorkBudget(maxWork: maxCandidateWork);
    validateEventUid(protocolUid);
    final accepted = validateEventContent(content, sharedWorkBudget: work);
    final edits = validateEventOverrides(
      accepted,
      timingOverrides,
      sharedWorkBudget: work,
    );
    final state = validateEventProtocolState(protocolState, accepted, edits);
    if ((accepted.recurrence == null && (accepted.periods?.isEmpty ?? true)) ||
        accepted.status == CalendarEventStatus.cancelled ||
        message.uid != protocolUid ||
        message.events.length != 1 ||
        !{
          IcalendarSchedulingMethod.request,
          IcalendarSchedulingMethod.cancel,
        }.contains(message.method)) {
      throw ArgumentError('Unsupported occurrence projection');
    }
    final source = message.events.single;
    final organizer = state.sourceMetadata?.organizer;
    if (!source.isOverride ||
        source.isThisAndFuture ||
        source.recurrence != null ||
        organizer == null ||
        source.participants.organizer?.address != organizer.address ||
        source.participants.organizer?.sentBy != null ||
        !(state.sourceMetadata?.attendees ?? <CalendarEventSourceParticipant>[])
            .any((a) => a.address == recipientAddress) ||
        !source.participants.attendees.any(
          (a) => a.address == recipientAddress,
        ) ||
        source.participants.attendees.any(
          (a) =>
              a.sentBy != null ||
              a.delegatedTo.isNotEmpty ||
              a.delegatedFrom.isNotEmpty ||
              a.participationStatus?.toUpperCase() == 'DELEGATED',
        )) {
      throw ArgumentError('Unsupported occurrence projection');
    }
    final original = _point(source.originalDate ?? source.originalTime!);
    final key = eventComponentKey(original, false);
    if (!eventSchedulingMember(accepted, original, sharedWorkBudget: work) ||
        (edits?.future ?? <CalendarEventFutureOverride>[]).any(
          (v) => eventComponentKey(v.originalStart, false) == key,
        )) {
      throw ArgumentError('Unsupported occurrence projection');
    }
    final old = edits?.singles
        .where((v) => eventComponentKey(v.originalStart, false) == key)
        .firstOrNull;
    final oldState = state.overrides
        .where(
          (v) =>
              !v.isThisAndFuture &&
              eventComponentKey(v.originalStart, false) == key,
        )
        .firstOrNull;
    late final CalendarEventSingleOverride replacement;
    late final CalendarEventOverrideProtocolState checkpoint;
    if (message.method == IcalendarSchedulingMethod.request) {
      final writer = EventComponentWriter();
      final master = writer
          .components(
            protocolUid,
            accepted,
            null,
            state.copyWith(overrides: []),
          )
          .single;
      final zones = {
        for (final z in message.timeZones.values) z.zoneId: z.source,
      };
      for (final id in writer.zones) {
        zones.putIfAbsent(id, () => createIcalendarTimeZone(id));
      }
      final calendar = validateIcalendarEventCalendar(
        IcalendarSyntaxDocument([
          IcalendarSyntaxComponent('VCALENDAR', [
            IcalendarSyntaxProperty('VERSION', '2.0'),
            IcalendarSyntaxProperty(
              'PRODID',
              '-//Serverpod Calendar//Occurrence proposal//EN',
            ),
            ...zones.values,
            master,
            source.source,
          ]),
        ]),
        limits: IcalendarComponentLimits(maxCandidates: maxCandidateWork),
        sharedWorkBudget: work,
      );
      final projected = eventWireProjection(
        calendar.series.single,
        sharedWorkBudget: work,
      );
      replacement = projected.edits!.singles.single;
      checkpoint = projected.protocolState.overrides.single;
    } else {
      if (source.status != IcalendarEventStatus.cancelled) {
        throw ArgumentError('Unsupported cancellation');
      }
      final active = edits?.copyWith(
        singles: [
          for (final v in edits.singles)
            v == old ? v.copyWith(cancelled: false) : v,
        ],
      );
      final effective = eventSchedulingOccurrence(
        accepted,
        active,
        original,
        sharedWorkBudget: work,
      )!;
      _checkCancellationTiming(source, effective.timing);
      _checkCancellationProperties(
        source,
        effective,
        old,
        state.sourceMetadata,
      );
      replacement =
          old?.copyWith(cancelled: true) ??
          CalendarEventSingleOverride(originalStart: original, cancelled: true);
      checkpoint = CalendarEventOverrideProtocolState(
        originalStart: original,
        isThisAndFuture: false,
        version: CalendarEventProtocolVersion(
          sequence: source.sequence,
          stamp: source.stamp,
          created: source.created,
          lastModified: source.lastModified,
        ),
        statusPresent: true,
        summaryPresent: oldState?.summaryPresent ?? false,
        descriptionPresent: oldState?.descriptionPresent ?? false,
        locationPresent: oldState?.locationPresent ?? false,
        transparencyPresent: oldState?.transparencyPresent ?? false,
      );
    }
    final proposed = validateEventOverrides(
      accepted,
      CalendarEventTimingOverrides(
        singles: [
          for (final v in edits?.singles ?? <CalendarEventSingleOverride>[])
            if (eventComponentKey(v.originalStart, false) != key) v,
          replacement,
        ],
        future: edits?.future ?? [],
      ),
      sharedWorkBudget: work,
    )!;
    final nextState = validateEventProtocolState(
      state.copyWith(
        overrides: [
          for (final v in state.overrides)
            if (v.isThisAndFuture ||
                eventComponentKey(v.originalStart, false) != key)
              v,
          checkpoint,
        ],
      ),
      accepted,
      proposed,
    );
    return CalendarInvitationOccurrenceProjection._(
      protocolUid,
      accepted,
      proposed,
      nextState,
      original,
      message,
    );
  } on IcalendarSyntaxException catch (e) {
    if (e.kind == IcalendarSyntaxError.limitExceeded) {
      throw const RecurrenceLimitException('invitationProjectionSource');
    }
    throw ArgumentError('Unsupported occurrence projection');
  } on IcalendarComponentException catch (e) {
    if (e.kind == IcalendarComponentError.limitExceeded) {
      throw const RecurrenceLimitException('invitationProjectionWork');
    }
    throw ArgumentError('Unsupported occurrence projection');
  } on ArgumentError {
    throw ArgumentError('Unsupported occurrence projection');
  } on StateError {
    throw ArgumentError('Unsupported occurrence projection');
  }
}

CalendarEventTiming _point(Object value) {
  if (value is CalendarDate) {
    return CalendarEventTiming(
      kind: CalendarEventTimeKind.date,
      start: eventDate(value),
    );
  }
  final time = value as TimedValue;
  return CalendarEventTiming(
    kind: time.zoneId == null
        ? CalendarEventTimeKind.utc
        : CalendarEventTimeKind.zoned,
    start: eventCivil(time.civil),
    zoneId: time.zoneId,
  );
}

void _checkCancellationTiming(
  IcalendarSchedulingEvent source,
  CalendarEventTiming timing,
) {
  final (date, timed) = validateEventTiming(timing);
  bool sameProfile(TimedValue value) =>
      timed != null && value.sameProfile(timed.start);
  if (source.startDate != null &&
          (date == null || source.startDate != date.start) ||
      source.startTime != null &&
          (!sameProfile(source.startTime!) ||
              source.startTime != timed!.start) ||
      source.endDate != null &&
          (date == null || source.endDate != date.endExclusive) ||
      source.endTime != null &&
          (!sameProfile(source.endTime!) ||
              source.endTime!.instant != timed!.endExclusive)) {
    throw ArgumentError('Different cancellation timing');
  }
  final duration = source.duration;
  if (duration != null) {
    if (date != null &&
        !RegExp(r'^\+?P[0-9]+[DW]$').hasMatch(
          source.source.entries
              .whereType<IcalendarSyntaxProperty>()
              .singleWhere((p) => p.canonicalName == 'DURATION')
              .value,
        )) {
      throw ArgumentError(
        'DATE cancellation duration requires day/week syntax',
      );
    }
    final agrees = date != null
        ? DateEventSpan(start: date.start, duration: duration).endExclusive ==
              date.endExclusive
        : TimedEventSpan(
                start: timed!.start,
                duration: duration,
              ).endExclusive ==
              timed.endExclusive;
    if (!agrees) throw ArgumentError('Different cancellation duration');
  }
}

void _checkCancellationProperties(
  IcalendarSchedulingEvent source,
  CalendarEventContent effective,
  CalendarEventSingleOverride? single,
  CalendarEventSourceMetadata? masterMetadata,
) {
  final writer = EventComponentWriter();
  // Future timing propagates; future-anchor content/metadata remains local.
  final own = single?.sourceMetadata;
  final expected = <String, List<IcalendarSyntaxProperty>>{};
  final normalizedValues = <IcalendarSyntaxProperty, String>{};
  void add(Iterable<IcalendarSyntaxEntry> entries, {bool replace = false}) {
    final groups = <String, List<IcalendarSyntaxProperty>>{};
    for (final p in entries.whereType<IcalendarSyntaxProperty>()) {
      groups.putIfAbsent(p.canonicalName, () => []).add(p);
    }
    for (final entry in groups.entries) {
      if (replace || !expected.containsKey(entry.key)) {
        expected[entry.key] = entry.value;
      }
    }
  }

  add(writer.sourceMetadata(masterMetadata));
  add(writer.sourceMetadata(own), replace: true);
  add(writer.content(effective), replace: true);
  const ignored = {
    'UID',
    'RECURRENCE-ID',
    'DTSTAMP',
    'SEQUENCE',
    'CREATED',
    'LAST-MODIFIED',
    'DTSTART',
    'DTEND',
    'DURATION',
    'STATUS',
  };
  if (source.source.entries.whereType<IcalendarSyntaxComponent>().isNotEmpty) {
    throw ArgumentError('Unsupported cancellation component');
  }
  for (final p in source.source.entries.whereType<IcalendarSyntaxProperty>()) {
    if (ignored.contains(p.canonicalName)) continue;
    final candidates = expected[p.canonicalName] ?? [];
    final match = candidates.indexWhere(
      (v) => _sameSuppliedProperty(p, v, normalizedValues),
    );
    if (match < 0) throw ArgumentError('Different cancellation content');
    candidates.removeAt(match);
  }
}

bool _sameSuppliedProperty(
  IcalendarSyntaxProperty source,
  IcalendarSyntaxProperty expected,
  Map<IcalendarSyntaxProperty, String> normalizedValues,
) {
  Object value(IcalendarSyntaxProperty p) {
    if ({
      'SUMMARY',
      'DESCRIPTION',
      'LOCATION',
      'COMMENT',
      'CONTACT',
      'RELATED-TO',
    }.contains(p.canonicalName)) {
      return decodeIcalendarText(p.value);
    }
    if ({'CATEGORIES', 'RESOURCES'}.contains(p.canonicalName)) {
      return decodeIcalendarTextList(p.value);
    }
    if ({'CLASS', 'TRANSP'}.contains(p.canonicalName)) {
      return p.value.toUpperCase();
    }
    if (p.canonicalName == 'PRIORITY') return int.parse(p.value);
    return p.value;
  }

  String key(IcalendarSyntaxProperty p) =>
      normalizedValues.putIfAbsent(p, () => jsonEncode(value(p)));
  if (key(source) != key(expected)) return false;
  final params = {
    for (final p in expected.parameters) p.canonicalName: p.values,
  };
  for (final p in source.parameters) {
    final values = params[p.canonicalName];
    if (values == null) {
      if (p.canonicalName == 'VALUE' &&
          p.values.length == 1 &&
          (p.values.single.toUpperCase() == 'TEXT' &&
                  {
                    'SUMMARY',
                    'DESCRIPTION',
                    'LOCATION',
                    'COMMENT',
                    'CONTACT',
                    'RELATED-TO',
                    'CATEGORIES',
                    'RESOURCES',
                  }.contains(source.canonicalName) ||
              p.values.single.toUpperCase() == 'URI' &&
                  source.canonicalName == 'ATTACH')) {
        continue;
      }
      return false;
    }
    String token(String v) =>
        {
          'VALUE',
          'RELTYPE',
          'CUTYPE',
          'ROLE',
          'PARTSTAT',
          'RSVP',
        }.contains(p.canonicalName)
        ? v.toUpperCase()
        : v;
    if (jsonEncode(p.values.map(token).toList()) !=
        jsonEncode(values.map(token).toList())) {
      return false;
    }
  }
  return true;
}
