part of 'calendar_module.dart';

CalendarEventPolicySnapshot _informationCopy(
  CalendarEventPolicySnapshot value, {
  int? revision,
  DateTime? updatedAt,
  CalendarEventContent? content,
  CalendarEventProtocolState? state,
}) => CalendarEventPolicySnapshot(
  value.eventId,
  value.calendarId,
  revision ?? value.revision,
  content ?? value.content,
  value.protocolUid,
  updatedAt ?? value.updatedAt,
  origin: value.origin,
  timingOverrides: value.timingOverrides,
  protocolState: state ?? value.protocolState,
);

CalendarEventPolicySnapshot _informationBundleSource(
  CalendarEventPolicySnapshot native,
  String organizer,
  CalendarEventProtocolVersion version,
  List<EventSchedulingOriginal> originals,
  RecurrenceWorkBudget work, {
  bool cancel = false,
}) {
  final metadata =
      native.protocolState!.sourceMetadata ??
      CalendarEventSourceMetadata(
        categoryGroups: [],
        comments: [],
        contacts: [],
      );
  if ((metadata.attendees?.isNotEmpty ?? false) ||
      (metadata.alarms?.isNotEmpty ?? false) ||
      metadata.organizer != null && metadata.organizer!.address != organizer ||
      native.timingOverrides?.cancelledFrom != null ||
      (native.timingOverrides?.singles.any((s) => s.cancelled) ?? false)) {
    throw _failure(CalendarFailureCode.validation);
  }
  final state = native.protocolState!.copyWith(
    version: version,
    overrides: cancel ? [] : native.protocolState!.overrides,
    statusPresent: cancel ? true : native.protocolState!.statusPresent,
    sourceMetadata: metadata.copyWith(
      organizer:
          metadata.organizer ??
          CalendarEventSourceParticipant(address: organizer, parameters: {}),
    ),
  );
  final source = CalendarEventPolicySnapshot(
    native.eventId,
    native.calendarId,
    native.revision,
    cancel
        ? native.content.copyWith(status: CalendarEventStatus.cancelled)
        : native.content,
    native.protocolUid,
    native.updatedAt,
    origin: native.origin,
    timingOverrides: cancel ? null : native.timingOverrides,
    protocolState: state,
  );
  return cancel
      ? source
      : _schedulingProjectionSource(source, originals, sharedWorkBudget: work);
}

/// Transfer only outgoing protocol versions, never native content/presence.
CalendarEventPolicySnapshot _informationBundleVersions(
  CalendarEventPolicySnapshot source,
  CalendarEventProtocolState versions,
) {
  final rows = {
    for (final row in versions.overrides)
      eventComponentKey(row.originalStart, row.isThisAndFuture): row.version,
  };
  if (rows.length != versions.overrides.length ||
      rows.length != source.protocolState!.overrides.length) {
    throw _failure(CalendarFailureCode.unavailable);
  }
  final state = source.protocolState!.copyWith(
    version: versions.version,
    overrides: [
      for (final row in source.protocolState!.overrides)
        row.copyWith(
          version:
              rows[eventComponentKey(row.originalStart, row.isThisAndFuture)] ??
              (throw _failure(CalendarFailureCode.unavailable)),
        ),
    ],
  );
  return _informationCopy(
    source,
    state: validateEventProtocolState(
      state,
      source.content,
      source.timingOverrides,
    ),
  );
}

CalendarEventPolicySnapshot _informationBundleWireVersions(
  CalendarEventPolicySnapshot source,
  IcalendarSchedulingMessage message,
) {
  final events = message.events.where((e) => e.isOverride).toList();
  final originals = _schedulingMessageOriginals(message);
  final byOriginal = {
    for (var i = 0; i < originals.length; i++)
      _schedulingOriginalKey(originals[i]): events[i],
  };
  final master = message.events.singleWhere((e) => !e.isOverride);
  return _informationBundleVersions(
    source,
    source.protocolState!.copyWith(
      version: source.protocolState!.version.copyWith(
        sequence: master.sequence,
        stamp: master.stamp,
      ),
      overrides: [
        for (final row in source.protocolState!.overrides)
          (() {
            final wire =
                byOriginal[eventComponentKey(
                  row.originalStart,
                  row.isThisAndFuture,
                )]!;
            return row.copyWith(
              version: row.version.copyWith(
                sequence: wire.sequence,
                stamp: wire.stamp,
              ),
            );
          })(),
      ],
    ),
  );
}

_SchedulingCheckpoint _informationActiveAdapter(
  _InformationCheckpoint previous,
  int maxBytes,
  RecurrenceWorkBudget work,
) {
  final message = parseIcalendarSchedulingMessage(
    utf8.encode(
      _schedulingPayload(
        previous.active,
        maxBytes,
        method: 'PUBLISH',
        sharedWorkBudget: work,
      ),
    ),
    syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
    sharedWorkBudget: work,
  );
  return _SchedulingCheckpoint(
    previous.activeCanonical,
    previous.active,
    message,
    _schedulingComponents(message),
    previous.projectionOriginals,
    _schedulingMessageOriginals(message),
    instanceVersionProfile: true,
  );
}

List<EventSchedulingOriginal> _informationBundleOriginals(
  CalendarEventPolicySnapshot native,
  _InformationCheckpoint? previous,
  int maxBytes,
  RecurrenceWorkBudget work,
) => _schedulingResetOriginals(
  native,
  previous == null ? null : _informationActiveAdapter(previous, maxBytes, work),
);

_InformationCheckpoint _readInformationBundle(
  CalendarSchedulingPublicationRecord p,
  Map<String, dynamic> data,
  RecurrenceWorkBudget work,
) {
  const keys = {
    'informationVersion',
    'purpose',
    'kind',
    'canonical',
    'outgoing',
    'activeCanonical',
    'active',
    'priorSequence',
    'priorStamp',
    'projectionOriginals',
  };
  if (data.keys.toSet().difference(keys).isNotEmpty ||
      data['purpose'] != _informationPurpose.name ||
      _schedulingDigest(p.payload) != p.payloadDigest) {
    throw _failure(CalendarFailureCode.unavailable);
  }
  final canonical = _schedulingReadSnapshot(
    data['canonical'],
    sharedWorkBudget: work,
  );
  final outgoing = _schedulingReadSnapshot(
    data['outgoing'],
    sharedWorkBudget: work,
  );
  final activeCanonical = _schedulingReadSnapshot(
    data['activeCanonical'],
    sharedWorkBudget: work,
  );
  final active = _schedulingReadSnapshot(
    data['active'],
    sharedWorkBudget: work,
  );
  for (final value in [outgoing, active]) {
    final state = value.protocolState!;
    if (state.overrides.length > 64 ||
        state.version.sequence == null ||
        state.overrides.any((row) => row.version.sequence == null)) {
      throw const FormatException();
    }
  }
  if (p.projection != _schedulingCanonicalKey(canonical)) {
    throw const FormatException();
  }
  final originals = (data['projectionOriginals'] as List).map((raw) {
    final map = raw as Map<String, dynamic>;
    if (map.keys.toSet().difference({
      'originalStart',
      'isThisAndFuture',
    }).isNotEmpty) {
      throw const FormatException();
    }
    return EventSchedulingOriginal.fromJson(map);
  }).toList();
  if (originals.length > 64 ||
      originals.map(_schedulingOriginalKey).toSet().length !=
          originals.length) {
    throw const FormatException();
  }
  final kind = CalendarSchedulingPublicationKind.values.byName(
    data['kind'] as String,
  );
  final cancel = kind == CalendarSchedulingPublicationKind.informationCancel;
  if (!{
        CalendarSchedulingPublicationKind.informationPublish,
        CalendarSchedulingPublicationKind.informationCancel,
        CalendarSchedulingPublicationKind.informationReopen,
      }.contains(kind) ||
      p.method != (cancel ? 'CANCEL' : 'PUBLISH') ||
      canonical.revision != p.eventRevision ||
      (canonical.content.status == CalendarEventStatus.cancelled) != cancel ||
      active.content.status == CalendarEventStatus.cancelled ||
      activeCanonical.content.status == CalendarEventStatus.cancelled) {
    throw const FormatException();
  }
  for (final value in [canonical, outgoing, activeCanonical, active]) {
    if (value.eventId != canonical.eventId ||
        value.calendarId != canonical.calendarId ||
        value.protocolUid != p.protocolUid ||
        value.origin != CalendarEventOrigin.native) {
      throw const FormatException();
    }
  }
  final organizer = outgoing.protocolState!.sourceMetadata?.organizer?.address;
  if (organizer == null ||
      active.protocolState!.sourceMetadata?.organizer?.address != organizer) {
    throw const FormatException();
  }
  CalendarEventPolicySnapshot expected(
    CalendarEventPolicySnapshot basis,
    CalendarEventPolicySnapshot actual, {
    bool cancelled = false,
  }) => _informationBundleVersions(
    _informationBundleSource(
      _informationCopy(
        basis,
        revision: actual.revision,
        updatedAt: actual.updatedAt,
      ),
      organizer,
      actual.protocolState!.version,
      originals,
      work,
      cancel: cancelled,
    ),
    actual.protocolState!,
  );
  if (jsonEncode(_schedulingSnapshotMap(expected(activeCanonical, active))) !=
      jsonEncode(_schedulingSnapshotMap(active))) {
    throw const FormatException();
  }
  final basis = kind == CalendarSchedulingPublicationKind.informationPublish
      ? canonical
      : activeCanonical;
  if (jsonEncode(
            _schedulingSnapshotMap(
              expected(basis, outgoing, cancelled: cancel),
            ),
          ) !=
          jsonEncode(_schedulingSnapshotMap(outgoing)) ||
      !cancel &&
          jsonEncode(_schedulingSnapshotMap(active)) !=
              jsonEncode(_schedulingSnapshotMap(outgoing))) {
    throw const FormatException();
  }
  final message = parseIcalendarSchedulingMessage(
    utf8.encode(p.payload),
    sharedWorkBudget: work,
  );
  if (message.events.length > 65 ||
      message.events.any((e) => e.sequence == null)) {
    throw const FormatException();
  }
  final master = message.events.singleWhere((e) => !e.isOverride);
  final priorSequence = data['priorSequence'] as int;
  final priorStamp = data['priorStamp'] == null
      ? null
      : DateTime.parse(data['priorStamp'] as String);
  final activeMaximum = active.protocolState!.overrides.fold(
    active.protocolState!.version.sequence ?? 0,
    (int value, row) => max(value, row.version.sequence ?? 0),
  );
  if (message.uid != p.protocolUid ||
      master.sequence != p.sequence ||
      master.stamp != p.stamp ||
      p.sequence < 0 ||
      p.sequence > eventMaxSequence ||
      priorSequence < -1 ||
      p.sequence < priorSequence ||
      cancel && (p.sequence <= activeMaximum || p.sequence <= priorSequence) ||
      priorStamp != null &&
          (eventProtocolInstant(priorStamp) != priorStamp ||
              p.stamp.isBefore(priorStamp)) ||
      cancel &&
          (message.events.length != 1 ||
              outgoing.protocolState!.overrides.isNotEmpty ||
              _schedulingOverrides(outgoing.timingOverrides)) ||
      message.events.any(
        (e) =>
            e.participants.organizer?.address != organizer ||
            e.participants.attendees.isNotEmpty,
      ) ||
      _schedulingPayload(
            outgoing,
            _schedulingCheckpointBytes,
            method: p.method,
            sharedWorkBudget: work,
          ) !=
          p.payload) {
    throw const FormatException();
  }
  return _InformationCheckpoint(
    canonical,
    outgoing,
    activeCanonical,
    active,
    kind,
    message,
    version: 2,
    projectionOriginals: List.unmodifiable(originals),
  );
}

final class _InformationBundlePlan {
  const _InformationBundlePlan(
    this.outgoing,
    this.activeCanonical,
    this.active,
    this.payload,
    this.snapshot,
  );
  final CalendarEventPolicySnapshot outgoing, activeCanonical, active;
  final String payload, snapshot;
}

_InformationBundlePlan _informationPlan(
  CalendarEventPolicySnapshot proposed,
  String organizer,
  CalendarSchedulingPublicationKind kind,
  _InformationCheckpoint? previous,
  CalendarSchedulingPublicationRecord? last,
  DateTime now,
  int maxBytes,
  RecurrenceWorkBudget work,
) {
  final cancel = kind == CalendarSchedulingPublicationKind.informationCancel;
  final reopen = kind == CalendarSchedulingPublicationKind.informationReopen;
  final activeCanonical = cancel || reopen
      ? previous!.activeCanonical
      : proposed;
  final originals = cancel || reopen
      ? previous!.projectionOriginals
      : _informationBundleOriginals(proposed, previous, maxBytes, work);
  final old = previous == null
      ? null
      : _informationActiveAdapter(previous, maxBytes, work);
  var sequence = max(
    proposed.protocolState!.version.sequence ?? 0,
    (last?.sequence ?? -1) + 1,
  );
  for (final value in [
    ...proposed.protocolState!.overrides.map((s) => s.version.sequence ?? 0),
    ...old?.ledger.map((s) => s.sequence) ?? <int>[],
  ]) {
    sequence = max(sequence, cancel || reopen ? value + 1 : value);
  }
  if (sequence > eventMaxSequence) {
    throw _failure(CalendarFailureCode.limitExceeded);
  }
  var stamp = eventProtocolInstant(now);
  for (final floor in [
    proposed.protocolState!.version.stamp,
    last?.stamp,
    ...old?.ledger.map((s) => s.stamp) ?? <DateTime>[],
  ]) {
    if (floor != null && floor.isAfter(stamp)) stamp = floor;
  }
  var outgoing = _informationBundleSource(
    _informationCopy(
      activeCanonical,
      revision: proposed.revision,
      updatedAt: now,
    ),
    organizer,
    activeCanonical.protocolState!.version.copyWith(
      sequence: sequence,
      stamp: stamp,
    ),
    originals,
    work,
    cancel: cancel,
  );
  var payload = _schedulingPayload(
    outgoing,
    maxBytes,
    method: cancel ? 'CANCEL' : 'PUBLISH',
    sharedWorkBudget: work,
  );
  if (!cancel) {
    final candidate = parseIcalendarSchedulingMessage(
      utf8.encode(payload),
      sharedWorkBudget: work,
    );
    final currentMaster = _schedulingComponents(candidate)
        .singleWhere((s) => s.key == 'master');
    final priorMaster = old?.ledger.singleWhere((s) => s.key == 'master');
    if (!reopen &&
        priorMaster != null &&
        priorMaster.projection == currentMaster.projection) {
      outgoing = _informationCopy(
        outgoing,
        state: outgoing.protocolState!.copyWith(
          version: outgoing.protocolState!.version.copyWith(
            sequence: priorMaster.sequence,
            stamp: priorMaster.stamp,
          ),
        ),
      );
      payload = _schedulingPayload(
        outgoing,
        maxBytes,
        method: 'PUBLISH',
        sharedWorkBudget: work,
      );
    }
    payload = _schedulingVersionedPayload(
      payload,
      old,
      now,
      maxBytes,
      sharedWorkBudget: work,
    );
    final versioned = parseIcalendarSchedulingMessage(
      utf8.encode(payload),
      sharedWorkBudget: work,
    );
    outgoing = _informationBundleWireVersions(outgoing, versioned);
    // Store the deterministic native writer's property order after allocating
    // versions; the generic allocator appends version properties at the end.
    payload = _schedulingPayload(
      outgoing,
      maxBytes,
      method: 'PUBLISH',
      sharedWorkBudget: work,
    );
  }
  final active = cancel ? previous!.active : outgoing;
  final snapshot = _schedulingBound(
    jsonEncode({
      'informationVersion': 2,
      'purpose': _informationPurpose.name,
      'kind': kind.name,
      'canonical': _schedulingSnapshotMap(proposed),
      'outgoing': _schedulingSnapshotMap(outgoing),
      'activeCanonical': _schedulingSnapshotMap(activeCanonical),
      'active': _schedulingSnapshotMap(active),
      'priorSequence': last?.sequence ?? -1,
      'priorStamp': last?.stamp.toIso8601String(),
      'projectionOriginals': originals.map((o) => o.toJson()).toList(),
    }),
  );
  return _InformationBundlePlan(
    outgoing,
    activeCanonical,
    active,
    payload,
    snapshot,
  );
}
