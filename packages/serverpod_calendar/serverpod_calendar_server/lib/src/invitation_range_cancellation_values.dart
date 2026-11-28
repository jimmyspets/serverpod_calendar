part of 'invitation_occurrence_values.dart';

/// One pure cutoff proposal and its independent source cancellation version.
/// Neither the accepted basis nor a source address proves permission/freshness.
final class CalendarInvitationRangeCancellationProjection {
  const CalendarInvitationRangeCancellationProjection._(
    this.protocolUid,
    this.content,
    this.timingOverrides,
    this.protocolState,
    this.originalStart,
    this.cancellationVersion,
    this.requiredAfterSequence,
    this.sourceMessage,
  );
  final String protocolUid;
  final CalendarEventContent content;
  final CalendarEventTimingOverrides timingOverrides;

  /// Retained master/component versions; never overwritten by the CANCEL.
  final CalendarEventProtocolState protocolState;
  final CalendarEventTiming originalStart;
  final CalendarEventProtocolVersion cancellationVersion;

  /// Maximum comparison floor; missing accepted sequences compare as zero.
  final int requiredAfterSequence;
  final IcalendarSchedulingMessage sourceMessage;
}

/// Validates a first THISANDFUTURE CANCEL against an unmasked accepted basis.
/// The result is not an accepted import baseline or a durable retry receipt.
CalendarInvitationRangeCancellationProjection
projectInvitationRangeCancellation({
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
    serializeIcalendarSyntax(message.source);
    if (message.timeZones.length > const IcalendarComponentLimits().maxZones) {
      throw const RecurrenceLimitException('invitationProjectionZones');
    }
    if (timingOverrides?.cancelledFrom != null) {
      throw ArgumentError('Existing cutoff requires reconciliation');
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
        message.method != IcalendarSchedulingMethod.cancel) {
      throw ArgumentError('Unsupported range cancellation');
    }
    final source = message.events.single;
    final organizer = state.sourceMetadata?.organizer;
    if (!source.isOverride ||
        !source.isThisAndFuture ||
        source.status != IcalendarEventStatus.cancelled ||
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
      throw ArgumentError('Unsupported range cancellation');
    }
    final original = _point(source.originalDate ?? source.originalTime!);
    final key = eventComponentKey(original, false);
    final single = edits?.singles
        .where((v) => eventComponentKey(v.originalStart, false) == key)
        .firstOrNull;
    final ownRange = edits?.future
        .where((v) => eventComponentKey(v.originalStart, false) == key)
        .firstOrNull;
    // A retained single cancellation cannot prevent validation of its original.
    final effective = eventSchedulingOccurrence(
      accepted,
      edits?.copyWith(
        singles: [
          for (final v in edits.singles)
            v == single ? v.copyWith(cancelled: false) : v,
        ],
      ),
      original,
      sharedWorkBudget: work,
    );
    if (effective == null) throw ArgumentError('Invalid original');
    _checkCancellationTiming(source, effective.timing);
    _checkCancellationProperties(
      source,
      effective,
      single?.sourceMetadata ?? ownRange?.sourceMetadata,
      state.sourceMetadata,
    );
    final cutoffOrder = _rangeCancellationOrder(original);
    CalendarEventOverrideProtocolState? underlying;
    var floor = 0;
    void consider(CalendarEventProtocolVersion version) {
      final sequence = version.sequence ?? 0;
      if (sequence > floor) floor = sequence;
    }

    for (final component in state.overrides) {
      final order = _rangeCancellationOrder(component.originalStart);
      if (order.compareTo(cutoffOrder) >= 0) consider(component.version);
      if (component.isThisAndFuture &&
          order.compareTo(cutoffOrder) <= 0 &&
          (underlying == null ||
              order.compareTo(
                    _rangeCancellationOrder(underlying.originalStart),
                  ) >
                  0)) {
        underlying = component;
      }
    }
    // A single at the anchor must not hide a newer surrounding segment.
    consider(underlying?.version ?? state.version);
    if (source.sequence! <= floor) throw ArgumentError('Stale cancellation');
    final cancellationVersion = validateEventProtocolVersion(
      CalendarEventProtocolVersion(
        sequence: source.sequence,
        stamp: source.stamp,
        created: source.created,
        lastModified: source.lastModified,
      ),
    );
    final proposed = validateEventOverrides(
      accepted,
      CalendarEventTimingOverrides(
        singles: edits?.singles ?? [],
        future: edits?.future ?? [],
        cancelledFrom: original,
      ),
      sharedWorkBudget: work,
    )!;
    return CalendarInvitationRangeCancellationProjection._(
      protocolUid,
      accepted,
      proposed,
      state,
      original,
      cancellationVersion,
      floor,
      message,
    );
  } on IcalendarSyntaxException catch (e) {
    if (e.kind == IcalendarSyntaxError.limitExceeded) {
      throw const RecurrenceLimitException('invitationProjectionSource');
    }
    throw ArgumentError('Unsupported range cancellation projection');
  } on IcalendarComponentException catch (e) {
    if (e.kind == IcalendarComponentError.limitExceeded) {
      throw const RecurrenceLimitException('invitationProjectionWork');
    }
    throw ArgumentError('Unsupported range cancellation projection');
  } on ZoneCoverageException {
    throw ArgumentError('Unsupported range cancellation projection');
  } on ArgumentError {
    throw ArgumentError('Unsupported range cancellation projection');
  } on StateError {
    throw ArgumentError('Unsupported range cancellation projection');
  }
}

// Exact validated profile identity; civil order is independent of moved starts.
String _rangeCancellationOrder(CalendarEventTiming value) {
  final c = value.start;
  return [
    c.year,
    c.month,
    c.day,
    c.hour,
    c.minute,
    c.second,
  ].map((n) => n.toString().padLeft(4, '0')).join(':');
}
