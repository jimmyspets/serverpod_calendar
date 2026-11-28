part of 'calendar_module.dart';

final class _SchedulingCancellation {
  const _SchedulingCancellation(
    this.point,
    this.version, {
    this.restored = false,
    this.active,
  });
  final CalendarEventTiming point;
  final _SchedulingComponentVersion version;
  final bool restored;
  final _SchedulingComponentVersion? active;
  Map<String, dynamic> toJson() => {
    'point': point.toJson(),
    'version': version.toJson(),
  };
}

Map<String, dynamic> _schedulingBasisMap(
  CalendarSchedulingPublicationRecord p,
) => {
  'snapshot': p.snapshot,
  'projection': p.projection,
  'payload': p.payload,
  'method': p.method,
  'sequence': p.sequence,
  'stamp': p.stamp.toIso8601String(),
};

CalendarSchedulingPublicationRecord _schedulingBasisRecord(
  CalendarSchedulingPublicationRecord p,
  dynamic input,
) {
  final v = input as Map<String, dynamic>;
  final snapshot = v['snapshot'] as String;
  if ({4, 5}.contains((jsonDecode(snapshot) as Map)['version'])) {
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

String _schedulingInstancePayload(
  _SchedulingCheckpoint basis,
  CalendarEventTiming point,
  int sequence,
  DateTime stamp,
  int maxBytes,
) {
  final writer = EventComponentWriter();
  final rid = writer.time('RECURRENCE-ID', point);
  final master = basis.message.events.singleWhere((e) => !e.isOverride).source;
  final document = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent('VCALENDAR', [
      IcalendarSyntaxProperty('VERSION', '2.0'),
      IcalendarSyntaxProperty(
        'PRODID',
        '-//Serverpod Calendar//Instance cancellation//EN',
      ),
      IcalendarSyntaxProperty('METHOD', 'CANCEL'),
      if (point.zoneId != null) createIcalendarTimeZone(point.zoneId!),
      IcalendarSyntaxComponent('VEVENT', [
        for (final p in master.entries.whereType<IcalendarSyntaxProperty>())
          if ({'UID', 'ORGANIZER', 'ATTENDEE'}.contains(p.canonicalName)) p,
        rid,
        IcalendarSyntaxProperty('SEQUENCE', '$sequence'),
        IcalendarSyntaxProperty('DTSTAMP', writer.utc(stamp)),
        IcalendarSyntaxProperty('STATUS', 'CANCELLED'),
      ]),
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

String _schedulingV4Projection(
  CalendarSchedulingPublicationKind kind,
  CalendarEventTiming? target,
  List<_SchedulingComponentVersion> components, {
  int version = 4,
}) => _schedulingBound(
  jsonEncode({
    'version': version,
    'kind': kind.name,
    'target': target?.toJson(),
    'components': components.map((v) => v.toJson()).toList(),
  }),
);

String _schedulingWriteV4({
  required CalendarEventPolicySnapshot canonical,
  required CalendarSchedulingPublicationKind kind,
  required CalendarSchedulingPublicationRecord basis,
  required List<_SchedulingCancellation> cancelled,
  CalendarSchedulingPublicationRecord? masterMessage,
  CalendarEventTiming? target,
  bool? nativeMatch,
}) => _schedulingBound(
  jsonEncode({
    'version': 4,
    'kind': kind.name,
    'canonical': _schedulingSnapshotMap(canonical),
    'basis': _schedulingBasisMap(basis),
    'masterMessage': masterMessage == null
        ? null
        : _schedulingBasisMap(masterMessage),
    'target': target?.toJson(),
    'nativeMatch': nativeMatch,
    'cancelled': cancelled.map((v) => v.toJson()).toList(),
  }),
);

void _schedulingHistoricalTarget(
  _SchedulingCheckpoint basis,
  CalendarEventTiming point, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  if (!_schedulingRecurring(basis.outgoing.content) ||
      !eventSchedulingMember(
        basis.outgoing.content,
        point,
        sharedWorkBudget: sharedWorkBudget,
      ) ||
      basis.originals.any(
        (o) =>
            o.isThisAndFuture &&
            eventComponentKey(o.originalStart, false) ==
                eventComponentKey(point, false),
      )) {
    throw _failure(CalendarFailureCode.validation);
  }
}

_SchedulingCheckpoint _schedulingReadV4(
  CalendarSchedulingPublicationRecord p,
  Map<String, dynamic> v,
) {
  final kind = CalendarSchedulingPublicationKind.values.byName(
    v['kind'] as String,
  );
  if (kind != CalendarSchedulingPublicationKind.occurrenceCancel &&
      kind != CalendarSchedulingPublicationKind.seriesCancel) {
    throw const FormatException();
  }
  final basisRecord = _schedulingBasisRecord(p, v['basis']);
  if (basisRecord.method != 'REQUEST') throw const FormatException();
  final basis = _schedulingReadCheckpoint(basisRecord);
  final canonical = _schedulingReadSnapshot(v['canonical']);
  if (canonical.eventId != basis.canonical.eventId ||
      canonical.calendarId != basis.canonical.calendarId ||
      canonical.protocolUid != p.protocolUid) {
    throw const FormatException();
  }
  final cancelled = (v['cancelled'] as List).map((input) {
    final row = input as Map<String, dynamic>;
    return _SchedulingCancellation(
      CalendarEventTiming.fromJson(row['point'] as Map<String, dynamic>),
      _SchedulingComponentVersion.read(row['version']),
    );
  }).toList();
  if (cancelled.isEmpty || cancelled.length > 64) throw const FormatException();
  final keys = <String>{};
  final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  final union = basis.originals
      .map((o) => eventComponentKey(o.originalStart, false))
      .toSet();
  for (final row in cancelled) {
    final key = eventComponentKey(row.point, false);
    if (!keys.add(key)) throw const FormatException();
    union.add(key);
    _schedulingHistoricalTarget(basis, row.point, sharedWorkBudget: work);
    final payload = _schedulingInstancePayload(
      basis,
      row.point,
      row.version.sequence,
      row.version.stamp,
      _schedulingCheckpointBytes,
    );
    final actual = _schedulingComponent(
      parseIcalendarSchedulingMessage(utf8.encode(payload)).events.single,
    );
    final floor = basis.ledger.firstWhere(
      (e) => e.key == actual.key,
      orElse: () => basis.ledger.singleWhere((e) => e.key == 'master'),
    );
    if (jsonEncode(actual.toJson()) != jsonEncode(row.version.toJson()) ||
        actual.sequence <= floor.sequence ||
        actual.stamp.isBefore(floor.stamp)) {
      throw const FormatException();
    }
  }
  if (union.length > 64 ||
      _schedulingDigest(p.payload) != p.payloadDigest ||
      utf8.encode(p.payload).length > _schedulingCheckpointBytes) {
    throw const FormatException();
  }
  final message = parseIcalendarSchedulingMessage(utf8.encode(p.payload));
  final target = v['target'] == null
      ? null
      : CalendarEventTiming.fromJson(v['target'] as Map<String, dynamic>);
  final nativeMatch = v['nativeMatch'] as bool?;
  final List<_SchedulingComponentVersion> components;
  final CalendarEventPolicySnapshot outgoing;
  if (kind == CalendarSchedulingPublicationKind.occurrenceCancel) {
    if (target == null ||
        nativeMatch == null ||
        v['masterMessage'] != null ||
        message.events.length != 1) {
      throw const FormatException();
    }
    final row = cancelled.singleWhere(
      (r) =>
          eventComponentKey(r.point, false) == eventComponentKey(target, false),
    );
    if (p.payload !=
            _schedulingInstancePayload(
              basis,
              target,
              row.version.sequence,
              row.version.stamp,
              _schedulingCheckpointBytes,
            ) ||
        p.sequence != row.version.sequence ||
        p.stamp != row.version.stamp ||
        p.method != 'CANCEL' ||
        nativeMatch != eventSchedulingMember(canonical.content, target)) {
      throw const FormatException();
    }
    if (nativeMatch &&
        !(canonical.timingOverrides?.singles.any(
              (s) =>
                  s.cancelled &&
                  eventComponentKey(s.originalStart, false) ==
                      eventComponentKey(target, false),
            ) ??
            false)) {
      throw const FormatException();
    }
    components = [row.version];
    outgoing = basis.outgoing;
  } else {
    if (target != null || nativeMatch != null) throw const FormatException();
    final masterRecord = _schedulingBasisRecord(p, v['masterMessage']);
    if (masterRecord.method != 'CANCEL' ||
        masterRecord.payload != p.payload ||
        masterRecord.sequence != p.sequence ||
        masterRecord.stamp != p.stamp ||
        p.method != 'CANCEL') {
      throw const FormatException();
    }
    final master = _schedulingReadCheckpoint(masterRecord);
    if (_schedulingCanonicalKey(master.canonical) !=
            _schedulingCanonicalKey(canonical) ||
        _schedulingBundleProjection(master.ledger) !=
            _schedulingBundleProjection(basis.ledger) ||
        cancelled.any(
          (r) =>
              r.version.sequence >= p.sequence ||
              r.version.stamp.isAfter(p.stamp),
        )) {
      throw const FormatException();
    }
    outgoing = master.outgoing;
    components = _schedulingComponents(message);
  }
  if (p.projection != _schedulingV4Projection(kind, target, components)) {
    throw const FormatException();
  }
  return _SchedulingCheckpoint(
    canonical,
    outgoing,
    message,
    basis.ledger,
    basis.projectionOriginals,
    basis.originals,
    kind: kind,
    target: target,
    nativeMatch: nativeMatch,
    basisRecord: basisRecord,
    cancelled: List.unmodifiable(cancelled),
  );
}

CalendarEventPolicySnapshot _schedulingExpectedState(
  _SchedulingCheckpoint checkpoint,
) {
  if (checkpoint.individuals.isEmpty) {
    return checkpoint.message.method == IcalendarSchedulingMethod.cancel
        ? checkpoint.outgoing
        : checkpoint.canonical;
  }
  final basis = _schedulingReadCheckpoint(checkpoint.basisRecord!);
  final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  var value = checkpoint.kind == CalendarSchedulingPublicationKind.seriesCancel
      ? checkpoint.outgoing
      : basis.canonical;
  for (final row in checkpoint.cancelled) {
    if (!eventSchedulingMember(
      value.content,
      row.point,
      sharedWorkBudget: work,
    )) {
      continue;
    }
    final edits = changeEventOverrides(
      value.content,
      value.timingOverrides,
      CalendarEventOccurrenceChange(
        eventId: value.eventId,
        expectedRevision: value.revision,
        originalStart: row.point,
        action: CalendarEventOccurrenceAction.cancelSingle,
      ),
    );
    final state = advanceEventProtocol(
      value.protocolState!,
      value.content,
      value.timingOverrides,
      value.content,
      edits,
      value.updatedAt,
    );
    value = CalendarEventPolicySnapshot(
      value.eventId,
      value.calendarId,
      value.revision,
      value.content,
      value.protocolUid,
      value.updatedAt,
      origin: value.origin,
      timingOverrides: edits,
      protocolState: state,
    );
  }
  return value;
}
