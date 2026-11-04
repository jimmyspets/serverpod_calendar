part of 'invitation_occurrence_values.dart';

/// A pure restore-only candidate, not an accepted source or authority decision.
final class CalendarInvitationRangeRestorationProjection {
  const CalendarInvitationRangeRestorationProjection._(
    this.protocolUid,
    this.content,
    this.timingOverrides,
    this.protocolState,
    this.originalStart,
    this.cancellationVersion,
    this.restorationVersion,
    this.requiredAfterSequence,
    this.sourceMessage,
  );
  final String protocolUid;
  final CalendarEventContent content;
  final CalendarEventTimingOverrides? timingOverrides;
  final CalendarEventProtocolState protocolState;
  final CalendarEventTiming originalStart;
  final CalendarEventProtocolVersion cancellationVersion;
  final CalendarEventProtocolVersion restorationVersion;
  final int requiredAfterSequence;
  final IcalendarSchedulingMessage sourceMessage;
}

/// Matches a newer same-cutoff REQUEST without changing retained components.
/// The caller must independently verify the actual accepted cancellation,
/// clean state, source authority, concurrency and durable acceptance.
CalendarInvitationRangeRestorationProjection projectInvitationRangeRestoration({
  required String protocolUid,
  required CalendarEventContent content,
  CalendarEventTimingOverrides? timingOverrides,
  required CalendarEventProtocolState protocolState,
  required CalendarEventProtocolVersion cancellationVersion,
  required IcalendarSchedulingMessage message,
  required String recipientAddress,
  int maxCandidateWork = eventMaxCandidateWork,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  try {
    RangeError.checkValueInInterval(maxCandidateWork, 1, eventMaxCandidateWork);
    if (sharedWorkBudget != null &&
        sharedWorkBudget.maxWork > maxCandidateWork) {
      throw ArgumentError('Shared work exceeds selected ceiling');
    }
    serializeIcalendarSyntax(message.source);
    if (message.timeZones.length > const IcalendarComponentLimits().maxZones) {
      throw const RecurrenceLimitException('invitationProjectionZones');
    }
    final work =
        sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: maxCandidateWork);
    validateEventUid(protocolUid);
    final accepted = validateEventContent(content, sharedWorkBudget: work);
    final edits = validateEventOverrides(
      accepted,
      timingOverrides,
      sharedWorkBudget: work,
    );
    final state = validateEventProtocolState(protocolState, accepted, edits);
    final cancellation = validateEventProtocolVersion(cancellationVersion);
    if (edits?.cancelledFrom == null ||
        cancellation.sequence == null ||
        (accepted.recurrence == null && (accepted.periods?.isEmpty ?? true)) ||
        accepted.status == CalendarEventStatus.cancelled ||
        message.uid != protocolUid ||
        message.events.length != 1 ||
        message.method != IcalendarSchedulingMethod.request) {
      throw ArgumentError('Unsupported range restoration');
    }
    final source = message.events.single;
    final organizer = state.sourceMetadata?.organizer;
    if (!source.isOverride ||
        !source.isThisAndFuture ||
        source.sequence == null ||
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
      throw ArgumentError('Unsupported range restoration');
    }
    final original = _point(source.originalDate ?? source.originalTime!);
    final key = eventComponentKey(original, false);
    if (key != eventComponentKey(edits!.cancelledFrom!, false)) {
      throw ArgumentError('Different restoration original');
    }
    final single = edits.singles
        .where((v) => eventComponentKey(v.originalStart, false) == key)
        .firstOrNull;
    final ownRange = edits.future
        .where((v) => eventComponentKey(v.originalStart, false) == key)
        .firstOrNull;
    // Lift the anchor's private flag only for comparison, never in the result.
    final effective = eventSchedulingOccurrence(
      accepted,
      edits.copyWith(
        cancelledFrom: null,
        singles: [
          for (final v in edits.singles)
            v == single ? v.copyWith(cancelled: false) : v,
        ],
      ),
      original,
      sharedWorkBudget: work,
    );
    if (effective == null) throw ArgumentError('Invalid restoration original');
    _checkRestorationTiming(source, effective.timing);
    if (source.status != null && source.status!.name != effective.status.name) {
      throw ArgumentError('Different restoration status');
    }
    _checkCancellationProperties(
      source,
      effective,
      single?.sourceMetadata ?? ownRange?.sourceMetadata,
      state.sourceMetadata,
    );
    final floor = _rangeSourceSequenceFloor(
      state,
      original,
      minimum: cancellation.sequence!,
    );
    if (source.sequence! <= floor) throw ArgumentError('Stale restoration');
    final restoration = validateEventProtocolVersion(
      CalendarEventProtocolVersion(
        sequence: source.sequence,
        stamp: source.stamp,
        created: source.created,
        lastModified: source.lastModified,
      ),
    );
    final proposed = validateEventOverrides(
      accepted,
      edits.copyWith(cancelledFrom: null),
      sharedWorkBudget: work,
    );
    final retainedState = validateEventProtocolState(state, accepted, proposed);
    return CalendarInvitationRangeRestorationProjection._(
      protocolUid,
      accepted,
      proposed,
      retainedState,
      original,
      cancellation,
      restoration,
      floor,
      message,
    );
  } on IcalendarSyntaxException catch (e) {
    if (e.kind == IcalendarSyntaxError.limitExceeded) {
      throw const RecurrenceLimitException('invitationProjectionSource');
    }
    throw ArgumentError('Unsupported range restoration projection');
  } on IcalendarComponentException catch (e) {
    if (e.kind == IcalendarComponentError.limitExceeded) {
      throw const RecurrenceLimitException('invitationProjectionWork');
    }
    throw ArgumentError('Unsupported range restoration projection');
  } on ZoneCoverageException {
    throw ArgumentError('Unsupported range restoration projection');
  } on ArgumentError {
    throw ArgumentError('Unsupported range restoration projection');
  } on StateError {
    throw ArgumentError('Unsupported range restoration projection');
  }
}

void _checkRestorationTiming(
  IcalendarSchedulingEvent source,
  CalendarEventTiming timing,
) {
  final (date, timed) = validateEventTiming(timing);
  if (date != null
      ? source.startDate != date.start || source.startTime != null
      : source.startTime != timed!.start || source.startDate != null) {
    throw ArgumentError('Different restoration start');
  }
  if ((source.endDate != null || source.endTime != null) !=
          (timing.end != null) ||
      (source.duration != null) != (timing.duration != null)) {
    throw ArgumentError('Different restoration end form');
  }
  if (timing.end != null) {
    final same = date != null
        ? source.endDate == date.endExclusive
        : source.endTime == timed!.end;
    if (!same) throw ArgumentError('Different restoration end');
  }
  if (source.duration != (date?.duration ?? timed?.duration)) {
    throw ArgumentError('Different restoration duration units');
  }
}
