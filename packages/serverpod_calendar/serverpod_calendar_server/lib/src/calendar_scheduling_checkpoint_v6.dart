part of 'calendar_module.dart';

// The individual-state proof is v4/v5, with its ordinary non-recursive REQUEST
// basis. A v6 envelope is never embedded in another v6 envelope.
CalendarSchedulingPublicationRecord _schedulingPrivateStateRecord(
  CalendarSchedulingPublicationRecord p,
  dynamic input,
) {
  final v = input as Map<String, dynamic>;
  final snapshot = v['snapshot'] as String;
  if (!{4, 5}.contains((jsonDecode(snapshot) as Map)['version'])) {
    throw const FormatException();
  }
  final payload = v['payload'] as String;
  return p.copyWith(
    snapshot: snapshot,
    projection: v['projection'] as String,
    payload: payload,
    payloadDigest: _schedulingDigest(payload),
    method: v['method'] as String,
    sequence: v['sequence'] as int,
    stamp: DateTime.parse(v['stamp'] as String),
  );
}

IcalendarSchedulingMessage _schedulingUnmaskedSource(
  _SchedulingCheckpoint state,
) {
  final basis = _schedulingReadCheckpoint(state.basisRecord!);
  return _schedulingRestorationSource(
    basis,
    state.individuals.where((s) => s.active != null).map((s) => s.point),
    _schedulingCheckpointBytes,
  );
}

String _schedulingMaskedPayload(
  _SchedulingCheckpoint state,
  List<_SchedulingComponentVersion> ledger,
  List<CalendarEventTiming> masks,
  int maxBytes,
) {
  if (masks.length > 64 || ledger.length > 65) {
    throw _failure(CalendarFailureCode.limitExceeded);
  }
  final source = _schedulingUnmaskedSource(state);
  final versions = {for (final v in ledger) v.key: v};
  final hidden = masks.map(_schedulingWirePointKey).toSet();
  if (hidden.length != masks.length) throw const FormatException();
  final writer = EventComponentWriter();
  final root = source.source.components.single;
  final document = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent(root.name, [
      ...root.entries.whereType<IcalendarSyntaxProperty>(),
      ...root.entries.whereType<IcalendarSyntaxComponent>().where(
        (c) => c.canonicalName == 'VTIMEZONE',
      ),
      for (final event in source.events)
        if (!hidden.contains(_schedulingComponent(event).key))
          (() {
            final candidate = _schedulingComponent(event);
            final version = versions[candidate.key];
            if (version == null ||
                version.future != candidate.future ||
                version.projection != candidate.projection) {
              throw const FormatException();
            }
            return IcalendarSyntaxComponent('VEVENT', [
              ...event.source.entries.where(
                (e) =>
                    e is! IcalendarSyntaxProperty ||
                    !{'SEQUENCE', 'DTSTAMP'}.contains(e.canonicalName),
              ),
              if (!event.isOverride)
                for (final point in masks) writer.time('EXDATE', point),
              IcalendarSyntaxProperty('SEQUENCE', '${version.sequence}'),
              IcalendarSyntaxProperty('DTSTAMP', writer.utc(version.stamp)),
            ]);
          })(),
    ]),
  ]);
  return utf8.decode(
    serializeIcalendarSchedulingMessage(
      validateIcalendarSchedulingMessage(
        document,
        syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
      ),
      syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
    ),
  );
}

CalendarEventPolicySnapshot _schedulingUnmaskedOutgoing(
  _SchedulingCheckpoint state,
  List<_SchedulingComponentVersion> ledger,
) {
  final basis = _schedulingReadCheckpoint(state.basisRecord!);
  final source = _schedulingProjectionSource(
    basis.outgoing,
    state.projectionOriginals,
  );
  final versions = {for (final v in ledger) v.key: v};
  final master = versions['master']!;
  final protocol = source.protocolState!.copyWith(
    version: source.protocolState!.version.copyWith(
      sequence: master.sequence,
      stamp: master.stamp,
    ),
    overrides: [
      for (final o in source.protocolState!.overrides)
        o.copyWith(
          version: o.version.copyWith(
            sequence:
                versions[_schedulingWirePointKey(o.originalStart)]!.sequence,
            stamp: versions[_schedulingWirePointKey(o.originalStart)]!.stamp,
          ),
        ),
    ],
  );
  return CalendarEventPolicySnapshot(
    source.eventId,
    source.calendarId,
    source.revision,
    source.content,
    source.protocolUid,
    source.updatedAt,
    origin: source.origin,
    timingOverrides: source.timingOverrides,
    protocolState: protocol,
  );
}

String _schedulingWriteV6({
  required CalendarEventPolicySnapshot canonical,
  required CalendarSchedulingPublicationKind kind,
  required CalendarSchedulingPublicationRecord state,
  required List<_SchedulingComponentVersion> ledger,
  required List<CalendarEventTiming> masks,
  required String fullPayload,
  required (int, DateTime) floor,
  CalendarEventTiming? target,
  bool? nativeMatch,
  CalendarSchedulingPublicationRecord? masterMessage,
}) => _schedulingBound(
  jsonEncode({
    'version': 6,
    'kind': kind.name,
    'canonical': _schedulingSnapshotMap(canonical),
    'state': _schedulingBasisMap(state),
    'ledger': ledger.map((v) => v.toJson()).toList(),
    'masks': masks.map((v) => v.toJson()).toList(),
    'fullPayload': fullPayload,
    'floor': [floor.$1, floor.$2.toIso8601String()],
    'target': target?.toJson(),
    'nativeMatch': nativeMatch,
    'masterMessage': masterMessage == null
        ? null
        : _schedulingBasisMap(masterMessage),
  }),
);

_SchedulingCheckpoint _schedulingReadV6(
  CalendarSchedulingPublicationRecord p,
  Map<String, dynamic> v,
) {
  final kind = CalendarSchedulingPublicationKind.values.byName(
    v['kind'] as String,
  );
  final proofRecord = _schedulingPrivateStateRecord(p, v['state']);
  final state = _schedulingReadCheckpoint(proofRecord);
  final canonical = _schedulingReadSnapshot(v['canonical']);
  if (state.individuals.isEmpty ||
      state.basisRecord == null ||
      canonical.eventId != state.canonical.eventId ||
      canonical.calendarId != state.canonical.calendarId ||
      canonical.protocolUid != p.protocolUid ||
      _schedulingDigest(p.payload) != p.payloadDigest ||
      utf8.encode(p.payload).length > _schedulingCheckpointBytes) {
    throw const FormatException();
  }
  final rows = v['ledger'] as List;
  final maskRows = v['masks'] as List;
  if (rows.isEmpty || rows.length > 65 || maskRows.length > 64) {
    throw const FormatException();
  }
  final ledger = rows.map(_SchedulingComponentVersion.read).toList();
  final masks = maskRows
      .map((e) => CalendarEventTiming.fromJson(e as Map<String, dynamic>))
      .toList();
  final old = {for (final e in state.ledger) e.key: e};
  final actual = {for (final e in ledger) e.key: e};
  if (actual.length != ledger.length || actual.length != old.length) {
    throw const FormatException();
  }
  final floorData = v['floor'] as List;
  if (floorData.length != 2) throw const FormatException();
  final floorSequence = floorData[0] as int;
  final floorStamp = DateTime.parse(floorData[1] as String);
  if (floorSequence < 0 ||
      floorSequence >= eventMaxSequence ||
      !floorStamp.isUtc ||
      eventProtocolInstant(floorStamp) != floorStamp) {
    throw const FormatException();
  }
  final cancelled = {
    for (final c in state.cancelled) _schedulingWirePointKey(c.point),
  };
  final maskKeys = masks.map(_schedulingWirePointKey).toSet();
  if (maskKeys.length != masks.length || !cancelled.containsAll(maskKeys)) {
    throw const FormatException();
  }
  for (final e in ledger) {
    final before = old[e.key];
    if (before == null ||
        before.future != e.future ||
        before.projection != e.projection ||
        e.sequence < before.sequence ||
        e.stamp.isBefore(before.stamp) ||
        !maskKeys.contains(e.key) &&
            (e.sequence <= floorSequence || e.stamp.isBefore(floorStamp))) {
      throw const FormatException();
    }
  }
  final fullPayload = v['fullPayload'] as String;
  if (fullPayload !=
      _schedulingMaskedPayload(
        state,
        ledger,
        masks,
        _schedulingCheckpointBytes,
      )) {
    throw const FormatException();
  }
  final target = v['target'] == null
      ? null
      : CalendarEventTiming.fromJson(v['target'] as Map<String, dynamic>);
  final nativeMatch = v['nativeMatch'] as bool?;
  final message = parseIcalendarSchedulingMessage(utf8.encode(p.payload));
  CalendarEventPolicySnapshot outgoing = _schedulingUnmaskedOutgoing(
    state,
    ledger,
  );
  List<_SchedulingComponentVersion> components;
  if (kind == CalendarSchedulingPublicationKind.seriesReopen ||
      kind == CalendarSchedulingPublicationKind.occurrenceRestoreWithMaster) {
    final restore =
        kind == CalendarSchedulingPublicationKind.occurrenceRestoreWithMaster;
    if (p.method != 'REQUEST' ||
        p.payload != fullPayload ||
        p.sequence != actual['master']!.sequence ||
        p.stamp != actual['master']!.stamp ||
        v['masterMessage'] != null ||
        canonical.content.status == CalendarEventStatus.cancelled ||
        !restore && (target != null || nativeMatch != null) ||
        restore && (target == null || nativeMatch == null)) {
      throw const FormatException();
    }
    if (restore) {
      final point = target!;
      final key = _schedulingWirePointKey(point);
      final restored = state.restored.singleWhere(
        (s) => _schedulingWirePointKey(s.point) == key,
      );
      if (maskKeys.contains(key) ||
          jsonEncode(restored.version.toJson()) !=
              jsonEncode(actual[key]!.toJson()) ||
          nativeMatch != eventSchedulingMember(canonical.content, point) ||
          (canonical.timingOverrides?.singles.any(
                (s) =>
                    s.cancelled &&
                    _schedulingWirePointKey(s.originalStart) == key,
              ) ??
              false)) {
        throw const FormatException();
      }
    }
    components = _schedulingComponents(message);
  } else if (kind == CalendarSchedulingPublicationKind.occurrenceCancel) {
    if (target == null ||
        nativeMatch == null ||
        v['masterMessage'] != null ||
        state.kind != kind ||
        state.target == null ||
        _schedulingWirePointKey(state.target!) !=
            _schedulingWirePointKey(target) ||
        nativeMatch != state.nativeMatch ||
        p.payload != proofRecord.payload ||
        p.sequence != proofRecord.sequence ||
        p.stamp != proofRecord.stamp ||
        p.method != 'CANCEL' ||
        _schedulingCanonicalKey(canonical) !=
            _schedulingCanonicalKey(state.canonical)) {
      throw const FormatException();
    }
    components = [_schedulingComponent(message.events.single)];
  } else if (kind == CalendarSchedulingPublicationKind.seriesCancel) {
    final masterRecord = _schedulingBasisRecord(p, v['masterMessage']);
    final master = _schedulingReadCheckpoint(masterRecord);
    if (target != null ||
        nativeMatch != null ||
        p.method != 'CANCEL' ||
        p.payload != masterRecord.payload ||
        p.sequence != masterRecord.sequence ||
        p.stamp != masterRecord.stamp ||
        _schedulingCanonicalKey(canonical) !=
            _schedulingCanonicalKey(master.canonical) ||
        master.outgoing.content.status != CalendarEventStatus.cancelled ||
        ledger.any(
          (e) => e.sequence >= p.sequence || e.stamp.isAfter(p.stamp),
        ) ||
        state.individuals.any(
          (s) =>
              s.version.sequence >= p.sequence ||
              s.version.stamp.isAfter(p.stamp),
        )) {
      throw const FormatException();
    }
    outgoing = master.outgoing;
    components = _schedulingComponents(message);
  } else {
    throw const FormatException();
  }
  if (p.projection !=
      _schedulingV4Projection(kind, target, components, version: 6)) {
    throw const FormatException();
  }
  return _SchedulingCheckpoint(
    canonical,
    outgoing,
    message,
    List.unmodifiable(ledger),
    state.projectionOriginals,
    state.originals,
    kind: kind,
    instanceVersionProfile: state.instanceVersionProfile,
    target: target,
    nativeMatch: nativeMatch,
    basisRecord: state.basisRecord,
    cancelled: state.cancelled,
    restored: state.restored,
    publicationExclusions: List.unmodifiable(masks),
    privateStateRecord: proofRecord,
    fullRequestPayload: fullPayload,
    reopenFloor: (floorSequence, floorStamp),
  );
}

final class _SchedulingProjectionBuild {
  const _SchedulingProjectionBuild(
    this.state,
    this.ledger,
    this.masks,
    this.payload,
    this.floor,
  );
  final CalendarSchedulingPublicationRecord state;
  final List<_SchedulingComponentVersion> ledger;
  final List<CalendarEventTiming> masks;
  final String payload;
  final (int, DateTime) floor;
}

_SchedulingProjectionBuild _schedulingProjectedChange(
  CalendarSchedulingPublicationRecord last,
  _SchedulingCheckpoint previous,
  CalendarEventPolicySnapshot current,
  CalendarEventPolicySnapshot proposed,
  CalendarEventTiming? target,
  bool? nativeMatch,
  bool reopen,
  DateTime now,
  int maxBytes,
) {
  final basisRecord = previous.basisRecord!;
  final basis = _schedulingReadCheckpoint(basisRecord);
  var sequence = last.sequence;
  var stamp = eventProtocolInstant(now);
  for (final version in [
    ...previous.ledger,
    ...previous.individuals.map((s) => s.version),
  ]) {
    sequence = max(sequence, version.sequence);
    if (version.stamp.isAfter(stamp)) stamp = version.stamp;
  }
  for (final version in [
    current.protocolState!.version,
    ...current.protocolState!.overrides.map((o) => o.version),
    proposed.protocolState!.version,
    ...proposed.protocolState!.overrides.map((o) => o.version),
  ]) {
    sequence = max(sequence, version.sequence ?? 0);
    if (version.stamp.isAfter(stamp)) stamp = version.stamp;
    if (version.lastModified != null && version.lastModified!.isAfter(stamp)) {
      stamp = version.lastModified!;
    }
  }
  final masterSequence = sequence + 1;
  if (masterSequence + (reopen ? 0 : 1) > eventMaxSequence) {
    throw _failure(CalendarFailureCode.limitExceeded);
  }
  var proof = previous.privateStateRecord ?? last;
  if (!reopen) {
    final point = target!;
    final payload = _schedulingRestorationPayload(
      basis,
      point,
      masterSequence + 1,
      stamp,
      maxBytes,
    );
    final version = _schedulingComponent(
      parseIcalendarSchedulingMessage(utf8.encode(payload)).events.single,
    );
    final history = [...previous.individuals]
      ..removeWhere(
        (s) =>
            _schedulingWirePointKey(s.point) == _schedulingWirePointKey(point),
      )
      ..add(
        _SchedulingCancellation(
          point,
          version,
          restored: true,
          active: version,
        ),
      );
    proof = last.copyWith(
      snapshot: _schedulingWriteV5(
        canonical: proposed,
        kind: CalendarSchedulingPublicationKind.occurrenceRestore,
        basis: basisRecord,
        individuals: history,
        target: point,
        nativeMatch: nativeMatch,
      ),
      projection: _schedulingV4Projection(
        CalendarSchedulingPublicationKind.occurrenceRestore,
        point,
        [version],
        version: 5,
      ),
      payload: payload,
      payloadDigest: _schedulingDigest(payload),
      method: 'REQUEST',
      sequence: version.sequence,
      stamp: version.stamp,
    );
  }
  final state = _schedulingReadCheckpoint(proof);
  final floor = reopen ? (last.sequence, last.stamp) : previous.reopenFloor!;
  final masks = state.cancelled.map((s) => s.point).toList()
    ..sort(
      (a, b) =>
          _schedulingWirePointKey(a).compareTo(_schedulingWirePointKey(b)),
    );
  final maskKeys = masks.map(_schedulingWirePointKey).toSet();
  final before = {for (final v in previous.ledger) v.key: v};
  final ledger = [
    for (final value in state.ledger)
      (() {
        final old = before[value.key];
        var selected =
            old != null &&
                old.projection == value.projection &&
                old.future == value.future &&
                old.sequence > value.sequence
            ? old
            : value;
        if (value.key == 'master' || reopen && !maskKeys.contains(value.key)) {
          selected = _SchedulingComponentVersion(
            value.key,
            value.future,
            value.projection,
            masterSequence,
            stamp,
          );
        }
        return selected;
      })(),
  ];
  final payload = _schedulingMaskedPayload(state, ledger, masks, maxBytes);
  return _SchedulingProjectionBuild(
    proof,
    List.unmodifiable(ledger),
    List.unmodifiable(masks),
    payload,
    floor,
  );
}
