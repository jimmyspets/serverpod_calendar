part of 'calendar_module.dart';

Map<String, dynamic> _schedulingFreezeCutoff(
  CalendarSchedulingPublicationRecord row,
) => row.toJson()
  ..remove('completedAt')
  ..remove('outcome');

CalendarEventPolicySnapshot _schedulingCutoffBasis(
  _SchedulingCheckpoint checkpoint,
  RecurrenceWorkBudget work,
) => checkpoint.individuals.isEmpty
    ? checkpoint.outgoing
    : _schedulingUnmaskedOutgoing(
        checkpoint,
        checkpoint.ledger,
        sharedWorkBudget: work,
      );

IcalendarSchedulingMessage _schedulingWholeCutoffCancel(
  CalendarEventPolicySnapshot source,
  int sequence,
  DateTime stamp,
  int maxBytes,
  RecurrenceWorkBudget work,
) {
  final content = source.content.copyWith(
    status: CalendarEventStatus.cancelled,
  );
  final state = source.protocolState!;
  final cancellation = CalendarEventPolicySnapshot(
    source.eventId,
    source.calendarId,
    source.revision,
    content,
    source.protocolUid,
    source.updatedAt,
    origin: source.origin,
    protocolState: state.copyWith(
      overrides: [],
      statusPresent: true,
      version: state.version.copyWith(sequence: sequence, stamp: stamp),
    ),
  );
  return parseIcalendarSchedulingMessage(
    utf8.encode(
      _schedulingPayload(
        cancellation,
        maxBytes,
        method: 'CANCEL',
        sharedWorkBudget: work,
      ),
    ),
    syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
    sharedWorkBudget: work,
  );
}

(int, DateTime) _schedulingCutoffFloor(
  CalendarSchedulingPublicationRecord row,
  _SchedulingCheckpoint previous,
  CalendarEventPolicySnapshot current,
  DateTime stamp,
) {
  var sequence = max(row.sequence, previous.rangeControl!.sequence);
  void include(int value, DateTime time) {
    sequence = max(sequence, value);
    if (time.isAfter(stamp)) stamp = time;
  }

  include(row.sequence, row.stamp);
  include(previous.rangeControl!.sequence, previous.rangeControl!.stamp);
  for (final value in previous.ledger.followedBy(
    previous.individuals.map((row) => row.version),
  )) {
    include(value.sequence, value.stamp);
  }
  final protocol = current.protocolState!;
  for (final value in [
    protocol.version,
    ...protocol.overrides.map((row) => row.version),
  ]) {
    include(value.sequence ?? 0, value.lastModified ?? value.stamp);
    include(value.sequence ?? 0, value.stamp);
  }
  return (sequence, stamp);
}

_SchedulingCheckpoint _schedulingReadV9(
  CalendarSchedulingPublicationRecord row,
  RecurrenceWorkBudget work,
) {
  final data = jsonDecode(row.snapshot) as Map<String, dynamic>;
  final frozen = CalendarSchedulingPublicationRecord.fromJson({
    ...data['predecessor'] as Map<String, dynamic>,
    'outcome': 'frozen',
  });
  final version = (jsonDecode(frozen.snapshot) as Map)['version'];
  if (!{7, 8}.contains(version) ||
      frozen.id == null ||
      frozen.id == row.id ||
      frozen.scopeKey != row.scopeKey ||
      frozen.meetingId != row.meetingId ||
      frozen.protocolUid != row.protocolUid ||
      frozen.generation < 1 ||
      frozen.generation >= row.generation ||
      frozen.eventRevision > row.expectedRevision ||
      jsonEncode(frozen.recipients) != jsonEncode(row.recipients) ||
      !frozen.expiresAt.isAfter(frozen.createdAt)) {
    throw const FormatException();
  }
  final previous = _schedulingReadCheckpoint(frozen, sharedWorkBudget: work);
  final range = previous.rangeControl;
  if (previous.kind != CalendarSchedulingPublicationKind.rangeCancel ||
      range == null ||
      !range.active) {
    throw const FormatException();
  }
  final expectedFrozenDigest = _schedulingDigest(
    jsonEncode([
      CalendarSchedulingPublicationKind.rangeCancel.name,
      previous.canonical.eventId.toString(),
      frozen.expectedRevision,
      range.anchor.toJson(),
    ]),
  );
  final canonical = _schedulingReadSnapshot(
    data['canonical'],
    sharedWorkBudget: work,
  );
  final cancelled = (row.generation - frozen.generation).isOdd;
  final kind = cancelled
      ? CalendarSchedulingPublicationKind.seriesCancel
      : CalendarSchedulingPublicationKind.seriesReopen;
  final control = _SchedulingRangeControl.read(data['range']);
  final floor = data['floor'] as int;
  final request = cancelled
      ? ['CANCEL', canonical.eventId.toString(), row.expectedRevision]
      : [kind.name, canonical.eventId.toString(), row.expectedRevision, null];
  final oldest = _schedulingCutoffFloor(
    frozen,
    previous,
    canonical,
    frozen.stamp,
  );
  if (data['kind'] != kind.name ||
      frozen.requestDigest != expectedFrozenDigest ||
      row.requestDigest != _schedulingDigest(jsonEncode(request)) ||
      canonical.eventId != previous.canonical.eventId ||
      canonical.calendarId != previous.canonical.calendarId ||
      canonical.protocolUid != row.protocolUid ||
      canonical.revision != row.eventRevision ||
      row.expectedRevision + 1 != row.eventRevision ||
      (canonical.content.status == CalendarEventStatus.cancelled) !=
          cancelled ||
      row.method != (cancelled ? 'CANCEL' : 'REQUEST') ||
      floor < oldest.$1 ||
      floor >= eventMaxSequence ||
      row.sequence != floor + 1 ||
      row.stamp.isBefore(oldest.$2) ||
      !row.stamp.isUtc ||
      eventProtocolInstant(row.stamp) != row.stamp ||
      !control.active ||
      control.sequence != range.sequence ||
      control.stamp != range.stamp ||
      !_replySamePoint(control.anchor, range.anchor) ||
      (control.installedRevision == null) !=
          (range.installedRevision == null) ||
      (control.installedRevision != null &&
          (range.installedRevision == null ||
              control.installedRevision! < range.installedRevision! ||
              control.installedRevision! > canonical.revision ||
              (control.installedRevision == range.installedRevision &&
                  control.installedKey != range.installedKey) ||
              (control.installedRevision == canonical.revision &&
                  (control.installedKey != _schedulingCanonicalKey(canonical) ||
                      !_replySamePoint(
                        canonical.timingOverrides?.cancelledFrom,
                        range.anchor,
                      ))))) ||
      _schedulingDigest(row.payload) != row.payloadDigest) {
    throw const FormatException();
  }
  final source = _schedulingCutoffBasis(previous, work);
  final basis = parseIcalendarSyntax(
    utf8.encode(
      _schedulingPayload(
        source,
        _schedulingCheckpointBytes,
        projectionOriginals: previous.projectionOriginals,
        sharedWorkBudget: work,
      ),
    ),
  );
  final individuals = previous.cancelled.map((value) => value.point).toList();
  final (reopened, suffix) = composePublishedCutoffReopening(
    basis: basis,
    cutoff: range.anchor,
    individualMasks: individuals,
    sequenceFloor: cancelled ? row.sequence : floor,
    stamp: row.stamp,
    maxBytes: _schedulingCheckpointBytes,
    work: work,
  );
  final message = cancelled
      ? _schedulingWholeCutoffCancel(
          source,
          row.sequence,
          row.stamp,
          _schedulingCheckpointBytes,
          work,
        )
      : reopened;
  final ledger = _schedulingComponents(message);
  if (row.payload !=
          utf8.decode(serializeIcalendarSchedulingMessage(message)) ||
      row.projection !=
          _schedulingV4Projection(kind, range.anchor, ledger, version: 9) ||
      jsonEncode(data['suffix']) !=
          jsonEncode(
            suffix.exclusions.map((point) => point.toJson()).toList(),
          ) ||
      message.uid != row.protocolUid ||
      message.events.any(
        (event) =>
            event.participants.organizer?.address !=
                previous
                    .message
                    .events
                    .single
                    .participants
                    .organizer
                    ?.address ||
            jsonEncode(
                  event.participants.attendees.map((a) => a.address).toList()
                    ..sort(),
                ) !=
                jsonEncode(row.recipients),
      )) {
    throw const FormatException();
  }
  final outgoing = cancelled
      ? CalendarEventPolicySnapshot(
          source.eventId,
          source.calendarId,
          source.revision,
          source.content.copyWith(status: CalendarEventStatus.cancelled),
          source.protocolUid,
          source.updatedAt,
          origin: source.origin,
          protocolState: source.protocolState,
        )
      : source;
  final comparison = _schedulingRangeExpectedState(previous);
  return _SchedulingCheckpoint(
    canonical,
    outgoing,
    message,
    ledger,
    previous.projectionOriginals,
    previous.originals,
    kind: kind,
    target: range.anchor,
    cancelled: previous.cancelled,
    restored: previous.restored,
    publicationExclusions: List.unmodifiable(individuals),
    instanceVersionProfile: previous.instanceVersionProfile,
    rangeControl: control,
    rangeComparison: CalendarEventPolicySnapshot(
      comparison.eventId,
      comparison.calendarId,
      comparison.revision,
      comparison.content.copyWith(status: outgoing.content.status),
      comparison.protocolUid,
      comparison.updatedAt,
      origin: comparison.origin,
      timingOverrides: comparison.timingOverrides,
      protocolState: comparison.protocolState!.copyWith(statusPresent: true),
    ),
    exceptionalRangeProof: previous.exceptionalRangeProof,
    cutoffPredecessor: frozen,
    suffixExclusions: suffix.exclusions,
    cutoffRequest: source,
  );
}
