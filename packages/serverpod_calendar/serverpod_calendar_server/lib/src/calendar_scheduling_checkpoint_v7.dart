part of 'calendar_module.dart';

/// Current outgoing control only. Immutable publication receipts retain older
/// commands under the ordinary retention policy; no predecessor v7 is embedded.
final class _SchedulingRangeControl {
  const _SchedulingRangeControl(
    this.anchor,
    this.active,
    this.sequence,
    this.stamp, {
    this.installedRevision,
    this.installedKey,
  });
  final CalendarEventTiming anchor;
  final bool active;
  final int sequence;
  final DateTime stamp;
  final int? installedRevision;
  final String? installedKey;
  Map<String, dynamic> toJson() => {
    'anchor': anchor.toJson(),
    'active': active,
    'sequence': sequence,
    'stamp': stamp.toIso8601String(),
    'installedRevision': installedRevision,
    'installedKey': installedKey,
  };
  factory _SchedulingRangeControl.read(dynamic value) {
    final v = value as Map<String, dynamic>;
    final result = _SchedulingRangeControl(
      CalendarEventTiming.fromJson(v['anchor'] as Map<String, dynamic>),
      v['active'] as bool,
      v['sequence'] as int,
      DateTime.parse(v['stamp'] as String),
      installedRevision: v['installedRevision'] as int?,
      installedKey: v['installedKey'] as String?,
    );
    validateEventTiming(result.anchor);
    if (result.anchor.end != null ||
        result.anchor.duration != null ||
        result.sequence < 0 ||
        result.sequence > eventMaxSequence ||
        !result.stamp.isUtc ||
        eventProtocolInstant(result.stamp) != result.stamp ||
        (result.installedRevision == null) != (result.installedKey == null) ||
        (result.installedRevision != null && result.installedRevision! < 1)) {
      throw const FormatException();
    }
    return result;
  }
}

/// Flatten the supported current facts. v6's individual-state proof is expanded
/// into fields, never stored as an embedded v6 snapshot or a predecessor chain.
String _schedulingWriteV7(
  CalendarSchedulingPublicationRecord current,
  _SchedulingRangeControl control,
  CalendarSchedulingPublicationKind kind, {
  CalendarEventPolicySnapshot? canonical,
  CalendarEventPolicySnapshot? comparison,
}) {
  _schedulingReadCheckpoint(current);
  final facts = jsonDecode(current.snapshot) as Map<String, dynamic>;
  final version = facts.remove('version');
  if (version is! int || !{3, 4, 5, 6}.contains(version)) {
    throw _failure(CalendarFailureCode.validation);
  }
  if (version == 6) {
    final state = facts.remove('state') as Map<String, dynamic>;
    final stateFacts =
        jsonDecode(state.remove('snapshot') as String) as Map<String, dynamic>;
    facts['individualStateVersion'] = stateFacts.remove('version');
    facts['individualStateFacts'] = stateFacts;
    facts['individualMessage'] = state;
  }
  return _schedulingBound(
    jsonEncode({
      'version': 7,
      'kind': kind.name,
      'currentVersion': version,
      'facts': facts,
      'currentMessage': {
        ..._schedulingBasisMap(current)..remove('snapshot'),
      },
      'range': control.toJson(),
      'comparison': _schedulingSnapshotMap(
        comparison ??
            _schedulingExpectedState(_schedulingReadCheckpoint(current)),
      ),
      'canonical': _schedulingSnapshotMap(
        canonical ?? _schedulingReadCheckpoint(current).canonical,
      ),
    }),
  );
}

IcalendarSyntaxDocument _schedulingRangeSource(_SchedulingCheckpoint value) {
  final source = value.individuals.isEmpty
      ? value.outgoing
      : _schedulingUnmaskedOutgoing(value, value.ledger);
  return parseIcalendarSyntax(
    utf8.encode(
      _schedulingPayload(
        source,
        _schedulingCheckpointBytes,
        projectionOriginals: value.projectionOriginals,
      ),
    ),
  );
}

CalendarEventPolicySnapshot _schedulingRangeExpectedState(
  _SchedulingCheckpoint checkpoint,
) => checkpoint.rangeComparison ?? (throw const FormatException());

CalendarEventPolicySnapshot _schedulingRangeComparison(
  _SchedulingCheckpoint previous,
  _SchedulingRangeControl control,
) {
  final source = _schedulingExpectedState(previous);
  var edits = source.timingOverrides;
  if (control.active && control.installedRevision != null ||
      !control.active && previous.rangeControl?.installedRevision != null) {
    edits = changeEventOverrides(
      source.content,
      edits,
      CalendarEventOccurrenceChange(
        eventId: source.eventId,
        expectedRevision: source.revision,
        originalStart: control.anchor,
        action: control.active
            ? CalendarEventOccurrenceAction.cancelFuture
            : CalendarEventOccurrenceAction.restoreFuture,
      ),
    );
  }
  return CalendarEventPolicySnapshot(
    source.eventId,
    source.calendarId,
    source.revision,
    source.content,
    source.protocolUid,
    source.updatedAt,
    origin: source.origin,
    timingOverrides: edits,
    protocolState: source.protocolState,
  );
}

CalendarSchedulingPublicationRecord _schedulingRangeCurrent(
  CalendarSchedulingPublicationRecord value,
) {
  final map = jsonDecode(value.snapshot) as Map<String, dynamic>;
  return map['version'] == 7 ? _schedulingV7Current(value, map) : value;
}

void _schedulingCarryRange(
  CalendarSchedulingPublicationRecord value,
  _SchedulingCheckpoint? previous,
) {
  final control = previous?.rangeControl;
  if (control == null) return;
  if (control.active) throw _failure(CalendarFailureCode.dependencyConflict);
  final kind = _schedulingReadCheckpoint(value).kind;
  value.snapshot = _schedulingWriteV7(value, control, kind);
  _schedulingReadCheckpoint(value);
}

/// Complete faithful active publication, with all outgoing versions newer than
/// the range control. Its v3/v6 carrier is transient; v7 persists flat facts.
CalendarSchedulingPublicationRecord _schedulingRangeRestored(
  CalendarSchedulingPublicationRecord last,
  _SchedulingCheckpoint previous,
  CalendarEventPolicySnapshot canonical,
  CalendarEventTiming anchor,
  int floor,
  DateTime stamp,
  int maxBytes, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  final source = previous.individuals.isEmpty
      ? previous.outgoing
      : _schedulingUnmaskedOutgoing(previous, previous.ledger);
  final projected = eventSchedulingRangeRestoration(
    source.content,
    source.timingOverrides,
    previous.projectionOriginals,
    anchor,
    sharedWorkBudget: sharedWorkBudget,
  );
  final markers = projected.$2;
  final outgoing = _schedulingProjectionSource(source, markers);
  final raw = parseIcalendarSchedulingMessage(
    utf8.encode(
      _schedulingPayload(outgoing, maxBytes, projectionOriginals: markers),
    ),
    sharedWorkBudget: sharedWorkBudget,
  );
  var next = floor;
  final ledger = [
    for (final v in _schedulingComponents(raw))
      _SchedulingComponentVersion(v.key, v.future, v.projection, ++next, stamp),
  ];
  if (next > eventMaxSequence) {
    throw _failure(CalendarFailureCode.limitExceeded);
  }
  String payloadFor(
    List<_SchedulingComponentVersion> versions,
    List<CalendarEventTiming> masks,
  ) {
    final hidden = masks.map(_schedulingWirePointKey).toSet();
    final root = raw.source.components.single;
    return utf8.decode(
      serializeIcalendarSchedulingMessage(
        validateIcalendarSchedulingMessage(
          IcalendarSyntaxDocument([
            IcalendarSyntaxComponent(root.name, [
              ...root.entries.whereType<IcalendarSyntaxProperty>(),
              ...root.entries.whereType<IcalendarSyntaxComponent>().where(
                (v) => v.canonicalName == 'VTIMEZONE',
              ),
              for (final event in raw.events)
                if (!hidden.contains(_schedulingComponent(event).key))
                  (() {
                    final version = versions.singleWhere(
                      (v) => v.key == _schedulingComponent(event).key,
                    );
                    return IcalendarSyntaxComponent('VEVENT', [
                      ...event.source.entries.where(
                        (e) =>
                            e is! IcalendarSyntaxProperty ||
                            !{'SEQUENCE', 'DTSTAMP'}.contains(e.canonicalName),
                      ),
                      if (!event.isOverride)
                        for (final mask in masks)
                          EventComponentWriter().time('EXDATE', mask),
                      IcalendarSyntaxProperty(
                        'SEQUENCE',
                        '${version.sequence}',
                      ),
                      IcalendarSyntaxProperty(
                        'DTSTAMP',
                        EventComponentWriter().utc(stamp),
                      ),
                    ]);
                  })(),
            ]),
          ]),
          syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
          sharedWorkBudget: sharedWorkBudget,
        ),
        syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
      ),
    );
  }

  final master = ledger.singleWhere((v) => v.key == 'master');
  // The ordinary bridge's comparison is the published native meaning, never
  // newer private drafts. v7 separately binds the actual final native snapshot.
  final publishedCanonical = _schedulingRangeComparison(
    previous,
    _SchedulingRangeControl(anchor, false, master.sequence, stamp),
  );
  if (previous.individuals.isEmpty) {
    final payload = payloadFor(ledger, []);
    return last.copyWith(
      method: 'REQUEST',
      sequence: master.sequence,
      stamp: stamp,
      payload: payload,
      payloadDigest: _schedulingDigest(payload),
      snapshot: _schedulingWriteCheckpoint(
        publishedCanonical,
        outgoing,
        ledger,
        markers,
        instanceVersionProfile: previous.instanceVersionProfile,
      ),
      projection: _schedulingBundleProjection(ledger),
    );
  }
  // Expand the fixed low-version source basis with the new projection marker.
  // The independent individual facts retain their original actual versions;
  // the current complete ledger is stored separately at its newer versions.
  final oldBasis = _schedulingReadCheckpoint(previous.basisRecord!);
  final basisOutgoing = _schedulingProjectionSource(oldBasis.outgoing, markers);
  final basisPayload = _schedulingPayload(
    basisOutgoing,
    maxBytes,
    projectionOriginals: markers,
  );
  final basisMessage = parseIcalendarSchedulingMessage(
    utf8.encode(basisPayload),
    sharedWorkBudget: sharedWorkBudget,
  );
  final basisLedger = _schedulingComponents(basisMessage);
  final basisMaster = basisLedger.singleWhere((v) => v.key == 'master');
  final basis = last.copyWith(
    method: 'REQUEST',
    payload: basisPayload,
    payloadDigest: _schedulingDigest(basisPayload),
    sequence: basisMaster.sequence,
    stamp: basisMaster.stamp,
    snapshot: _schedulingWriteCheckpoint(
      oldBasis.canonical,
      basisOutgoing,
      basisLedger,
      markers,
      instanceVersionProfile: oldBasis.instanceVersionProfile,
    ),
    projection: _schedulingBundleProjection(basisLedger),
  );
  final proof = previous.privateStateRecord ?? _schedulingRangeCurrent(last);
  final proofFacts = jsonDecode(proof.snapshot) as Map<String, dynamic>;
  if (!{4, 5}.contains(proofFacts['version'])) throw const FormatException();
  proofFacts['basis'] = _schedulingBasisMap(basis);
  final rebuilt = proof.copyWith(
    snapshot: _schedulingBound(jsonEncode(proofFacts)),
  );
  final state = _schedulingReadCheckpoint(rebuilt);
  final masks = state.cancelled.map((s) => s.point).toList()
    ..sort(
      (a, b) =>
          _schedulingWirePointKey(a).compareTo(_schedulingWirePointKey(b)),
    );
  // Keep masked slots' last-active versions, as in ordinary v6 projections.
  final masked = masks.map(_schedulingWirePointKey).toSet();
  final actual = [
    for (final v in ledger)
      if (masked.contains(v.key))
        state.ledger.singleWhere((e) => e.key == v.key)
      else
        v,
  ];
  final payload = _schedulingMaskedPayload(state, actual, masks, maxBytes);
  return last.copyWith(
    method: 'REQUEST',
    payload: payload,
    payloadDigest: _schedulingDigest(payload),
    sequence: master.sequence,
    stamp: stamp,
    snapshot: _schedulingWriteV6(
      canonical: publishedCanonical,
      kind: CalendarSchedulingPublicationKind.seriesReopen,
      state: rebuilt,
      ledger: actual,
      masks: masks,
      fullPayload: payload,
      floor: (floor, stamp),
    ),
    projection: _schedulingV4Projection(
      CalendarSchedulingPublicationKind.seriesReopen,
      null,
      _schedulingComponents(
        parseIcalendarSchedulingMessage(utf8.encode(payload)),
      ),
      version: 6,
    ),
  );
}

CalendarSchedulingPublicationRecord _schedulingV7Current(
  CalendarSchedulingPublicationRecord p,
  Map<String, dynamic> v,
) {
  final version = v['currentVersion'] as int;
  if (!{3, 4, 5, 6}.contains(version)) throw const FormatException();
  final facts = Map<String, dynamic>.from(v['facts'] as Map);
  if (facts.containsKey('version')) throw const FormatException();
  if (version == 6) {
    final proofVersion = facts.remove('individualStateVersion');
    if (!{4, 5}.contains(proofVersion)) throw const FormatException();
    final proofFacts = facts.remove('individualStateFacts') as Map;
    if (proofFacts.containsKey('version')) throw const FormatException();
    final proofMessage = Map<String, dynamic>.from(
      facts.remove('individualMessage') as Map,
    );
    proofMessage['snapshot'] = _schedulingBound(
      jsonEncode({'version': proofVersion, ...proofFacts}),
    );
    facts['state'] = proofMessage;
  }
  final message = v['currentMessage'] as Map;
  return p.copyWith(
    snapshot: _schedulingBound(jsonEncode({'version': version, ...facts})),
    projection: message['projection'] as String,
    payload: message['payload'] as String,
    payloadDigest: _schedulingDigest(message['payload'] as String),
    method: message['method'] as String,
    sequence: message['sequence'] as int,
    stamp: DateTime.parse(message['stamp'] as String),
  );
}

_SchedulingCheckpoint _schedulingReadV7(
  CalendarSchedulingPublicationRecord p,
  Map<String, dynamic> v,
) {
  final control = _SchedulingRangeControl.read(v['range']);
  final kind = CalendarSchedulingPublicationKind.values.byName(
    v['kind'] as String,
  );
  final currentRecord = _schedulingV7Current(p, v);
  final current = _schedulingReadCheckpoint(currentRecord);
  final canonical = _schedulingReadSnapshot(v['canonical']);
  final comparison = _schedulingReadSnapshot(v['comparison']);
  final rangeKind =
      kind == CalendarSchedulingPublicationKind.rangeCancel ||
      kind == CalendarSchedulingPublicationKind.rangeRestore;
  if (comparison.eventId != canonical.eventId ||
      canonical.revision < 2 ||
      canonical.revision > CalendarService._maxRevision ||
      p.expectedRevision < 1 ||
      p.eventRevision != canonical.revision ||
      p.expectedRevision + 1 != p.eventRevision ||
      comparison.calendarId != canonical.calendarId ||
      comparison.protocolUid != canonical.protocolUid ||
      canonical.eventId != current.outgoing.eventId ||
      canonical.calendarId != current.outgoing.calendarId ||
      canonical.protocolUid != p.protocolUid ||
      current.canonical.protocolUid != p.protocolUid ||
      _schedulingDigest(p.payload) != p.payloadDigest ||
      (control.active &&
          kind != CalendarSchedulingPublicationKind.rangeCancel) ||
      (rangeKind &&
          control.active !=
              (kind == CalendarSchedulingPublicationKind.rangeCancel))) {
    throw const FormatException();
  }
  if (!rangeKind && kind != current.kind ||
      kind == CalendarSchedulingPublicationKind.rangeRestore &&
          (currentRecord.method != 'REQUEST' ||
              p.sequence != control.sequence ||
              p.stamp != control.stamp) ||
      control.active &&
          control.installedRevision != null &&
          (control.installedRevision != canonical.revision ||
              control.installedKey != _schedulingCanonicalKey(canonical) ||
              !_replySamePoint(
                canonical.timingOverrides?.cancelledFrom,
                control.anchor,
              ))) {
    throw const FormatException();
  }
  final message = parseIcalendarSchedulingMessage(
    utf8.encode(_schedulingBound(p.payload)),
  );
  if (control.active) {
    for (final version in [
      canonical.protocolState!.version,
      ...canonical.protocolState!.overrides.map((v) => v.version),
    ]) {
      if (control.sequence <= (version.sequence ?? 0) ||
          control.stamp.isBefore(version.stamp) ||
          version.lastModified != null &&
              control.stamp.isBefore(version.lastModified!)) {
        throw const FormatException();
      }
    }
    for (final state in current.individuals) {
      if (control.sequence <= state.version.sequence ||
          control.stamp.isBefore(state.version.stamp)) {
        throw const FormatException();
      }
    }
    final source = _schedulingRangeSource(current);
    final expected = projectPublishedRangeCancellation(
      basis: source,
      originalStart: control.anchor,
      sequence: control.sequence,
      stamp: control.stamp,
    );
    final payload = utf8.decode(
      serializeIcalendarSchedulingMessage(expected.message),
    );
    if (p.method != 'CANCEL' ||
        p.sequence != control.sequence ||
        p.stamp != control.stamp ||
        p.payload != payload ||
        p.projection !=
            _schedulingV4Projection(
              kind,
              control.anchor,
              message.events.map(_schedulingComponent).toList(),
              version: 7,
            )) {
      throw const FormatException();
    }
  } else {
    if (p.payload != currentRecord.payload ||
        p.projection != currentRecord.projection ||
        p.method != currentRecord.method ||
        p.sequence != currentRecord.sequence ||
        p.stamp != currentRecord.stamp ||
        current.ledger.singleWhere((e) => e.key == 'master').sequence <
            control.sequence ||
        current.ledger
            .singleWhere((e) => e.key == 'master')
            .stamp
            .isBefore(control.stamp) ||
        !current.originals.any(
          (o) =>
              o.isThisAndFuture &&
              _replySamePoint(o.originalStart, control.anchor),
        )) {
      throw const FormatException();
    }
  }
  if ((control.active && control.installedRevision != null)
      ? !_replySamePoint(
          comparison.timingOverrides?.cancelledFrom,
          control.anchor,
        )
      : comparison.timingOverrides?.cancelledFrom != null) {
    throw const FormatException();
  }
  return _SchedulingCheckpoint(
    canonical,
    current.outgoing,
    message,
    current.ledger,
    current.projectionOriginals,
    current.originals,
    kind: kind,
    target: rangeKind ? control.anchor : current.target,
    nativeMatch: current.nativeMatch,
    basisRecord: current.basisRecord,
    cancelled: current.cancelled,
    restored: current.restored,
    publicationExclusions: current.publicationExclusions,
    privateStateRecord: current.privateStateRecord,
    fullRequestPayload:
        current.fullRequestPayload ??
        utf8.decode(serializeIcalendarSyntax(_schedulingRangeSource(current))),
    reopenFloor: current.reopenFloor,
    instanceVersionProfile: current.instanceVersionProfile,
    rangeControl: control,
    rangeComparison: comparison,
  );
}
