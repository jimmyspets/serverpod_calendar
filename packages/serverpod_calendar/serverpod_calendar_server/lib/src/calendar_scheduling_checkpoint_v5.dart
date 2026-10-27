part of 'calendar_module.dart';

String _schedulingWirePointKey(CalendarEventTiming point) {
  final rid = EventComponentWriter().time('RECURRENCE-ID', point);
  return jsonEncode([
    rid.value,
    rid.parameters.map((p) => [p.canonicalName, p.values]).toList(),
  ]);
}

List<EventSchedulingOriginal> _schedulingActiveOriginals(
  _SchedulingCheckpoint basis,
  Iterable<_SchedulingCancellation> states,
) {
  final markers = {
    for (final o in basis.projectionOriginals) _schedulingOriginalKey(o): o,
  };
  for (final state in states) {
    if (state.active != null) {
      final original = EventSchedulingOriginal(state.point, false);
      markers[_schedulingOriginalKey(original)] = original;
    }
  }
  return List.unmodifiable(
    markers.values.toList()..sort(
      (a, b) => _schedulingOriginalKey(a).compareTo(_schedulingOriginalKey(b)),
    ),
  );
}

IcalendarSchedulingMessage _schedulingRestorationSource(
  _SchedulingCheckpoint basis,
  Iterable<CalendarEventTiming> points,
  int maxBytes,
) {
  final markers = {
    for (final o in basis.projectionOriginals) _schedulingOriginalKey(o): o,
  };
  for (final point in points) {
    final original = EventSchedulingOriginal(point, false);
    markers[_schedulingOriginalKey(original)] = original;
  }
  return parseIcalendarSchedulingMessage(
    utf8.encode(
      _schedulingPayload(
        basis.outgoing,
        maxBytes,
        projectionOriginals: markers.values.toList(),
      ),
    ),
    syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
  );
}

String _schedulingRestorationPayload(
  _SchedulingCheckpoint basis,
  CalendarEventTiming point,
  int sequence,
  DateTime stamp,
  int maxBytes, {
  IcalendarSchedulingMessage? projected,
}) {
  final source =
      projected ?? _schedulingRestorationSource(basis, [point], maxBytes);
  final key = _schedulingWirePointKey(point);
  final event = source.events.singleWhere(
    (e) => _schedulingComponent(e).key == key && !e.isThisAndFuture,
  );
  final envelope = source.source.components.single;
  final document = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent('VCALENDAR', [
      ...envelope.entries.whereType<IcalendarSyntaxProperty>(),
      ...envelope.entries.whereType<IcalendarSyntaxComponent>().where(
        (e) => e.canonicalName == 'VTIMEZONE',
      ),
      IcalendarSyntaxComponent('VEVENT', [
        ...event.source.entries.where(
          (e) =>
              e is! IcalendarSyntaxProperty ||
              !{'SEQUENCE', 'DTSTAMP'}.contains(e.canonicalName),
        ),
        IcalendarSyntaxProperty('SEQUENCE', '$sequence'),
        IcalendarSyntaxProperty('DTSTAMP', EventComponentWriter().utc(stamp)),
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

String _schedulingWriteV5({
  required CalendarEventPolicySnapshot canonical,
  required CalendarSchedulingPublicationKind kind,
  required CalendarSchedulingPublicationRecord basis,
  required List<_SchedulingCancellation> individuals,
  CalendarSchedulingPublicationRecord? masterMessage,
  CalendarEventTiming? target,
  bool? nativeMatch,
}) => _schedulingBound(
  jsonEncode({
    'version': 5,
    'kind': kind.name,
    'canonical': _schedulingSnapshotMap(canonical),
    'basis': _schedulingBasisMap(basis),
    'masterMessage': masterMessage == null
        ? null
        : _schedulingBasisMap(masterMessage),
    'target': target?.toJson(),
    'nativeMatch': nativeMatch,
    'individuals': [
      for (final v in individuals)
        {
          ...v.toJson(),
          'restored': v.restored,
          'active': v.active?.toJson(),
        },
    ],
  }),
);

_SchedulingCheckpoint _schedulingReadV5(
  CalendarSchedulingPublicationRecord p,
  Map<String, dynamic> v,
) {
  final kind = CalendarSchedulingPublicationKind.values.byName(
    v['kind'] as String,
  );
  final basisRecord = _schedulingBasisRecord(p, v['basis']);
  if (basisRecord.method != 'REQUEST') throw const FormatException();
  final basis = _schedulingReadCheckpoint(basisRecord);
  final canonical = _schedulingReadSnapshot(v['canonical']);
  if (canonical.eventId != basis.canonical.eventId ||
      canonical.calendarId != basis.canonical.calendarId ||
      canonical.protocolUid != p.protocolUid) {
    throw const FormatException();
  }
  final inputs = v['individuals'] as List;
  if (inputs.isEmpty || inputs.length > 64) throw const FormatException();
  final states = inputs.map((input) {
    final row = input as Map<String, dynamic>;
    return _SchedulingCancellation(
      CalendarEventTiming.fromJson(row['point'] as Map<String, dynamic>),
      _SchedulingComponentVersion.read(row['version']),
      restored: row['restored'] as bool,
      active: row['active'] == null
          ? null
          : _SchedulingComponentVersion.read(row['active']),
    );
  }).toList();
  final keys = <String>{},
      union = basis.originals
          .map((o) => eventComponentKey(o.originalStart, false))
          .toSet();
  final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  for (final state in states) {
    final key = eventComponentKey(state.point, false);
    if (!keys.add(key)) throw const FormatException();
    union.add(key);
    _schedulingHistoricalTarget(basis, state.point, sharedWorkBudget: work);
  }
  if (union.length > 64 ||
      _schedulingDigest(p.payload) != p.payloadDigest ||
      utf8.encode(p.payload).length > _schedulingCheckpointBytes) {
    throw const FormatException();
  }
  final projected = _schedulingRestorationSource(
    basis,
    states.where((s) => s.active != null).map((s) => s.point),
    _schedulingCheckpointBytes,
  );
  final old = {for (final value in basis.ledger) value.key: value};
  final active = <String, _SchedulingComponentVersion>{};
  final master = old['master']!;
  for (final state in states) {
    final key = _schedulingWirePointKey(state.point),
        floor = old[_schedulingWirePointKey(state.point)] ?? master;
    final a = state.active;
    if (a != null) {
      final payload = _schedulingRestorationPayload(
        basis,
        state.point,
        a.sequence,
        a.stamp,
        _schedulingCheckpointBytes,
        projected: projected,
      );
      final actual = _schedulingComponent(
        parseIcalendarSchedulingMessage(utf8.encode(payload)).events.single,
      );
      if (jsonEncode(actual.toJson()) != jsonEncode(a.toJson()) ||
          a.sequence < floor.sequence ||
          a.stamp.isBefore(floor.stamp) ||
          a.sequence == floor.sequence &&
              jsonEncode(a.toJson()) != jsonEncode(floor.toJson())) {
        throw const FormatException();
      }
      active[key] = a;
    }
    if (state.restored) {
      if (a == null ||
          jsonEncode(a.toJson()) != jsonEncode(state.version.toJson())) {
        throw const FormatException();
      }
    } else {
      final payload = _schedulingInstancePayload(
        basis,
        state.point,
        state.version.sequence,
        state.version.stamp,
        _schedulingCheckpointBytes,
      );
      final actual = _schedulingComponent(
        parseIcalendarSchedulingMessage(utf8.encode(payload)).events.single,
      );
      if (jsonEncode(actual.toJson()) != jsonEncode(state.version.toJson()) ||
          state.version.sequence <= max(floor.sequence, a?.sequence ?? -1) ||
          state.version.stamp.isBefore(floor.stamp) ||
          a != null && state.version.stamp.isBefore(a.stamp)) {
        throw const FormatException();
      }
    }
  }
  final ledger = <_SchedulingComponentVersion>[];
  for (final candidate in _schedulingComponents(projected)) {
    final value = active[candidate.key] ?? old[candidate.key];
    if (value == null ||
        value.future != candidate.future ||
        value.projection != candidate.projection) {
      throw const FormatException();
    }
    ledger.add(value);
  }
  if (ledger.length != old.keys.toSet().union(active.keys.toSet()).length) {
    throw const FormatException();
  }
  final originals = {
    for (final original in basis.originals)
      _schedulingOriginalKey(original): original,
  };
  for (final state in states.where((s) => s.active != null)) {
    final original = EventSchedulingOriginal(state.point, false);
    originals[_schedulingOriginalKey(original)] = original;
  }
  final message = parseIcalendarSchedulingMessage(utf8.encode(p.payload));
  final target = v['target'] == null
      ? null
      : CalendarEventTiming.fromJson(v['target'] as Map<String, dynamic>);
  final nativeMatch = v['nativeMatch'] as bool?;
  final List<_SchedulingComponentVersion> components;
  final CalendarEventPolicySnapshot outgoing;
  if (kind == CalendarSchedulingPublicationKind.occurrenceRestore ||
      kind == CalendarSchedulingPublicationKind.occurrenceCancel) {
    if (target == null ||
        nativeMatch == null ||
        v['masterMessage'] != null ||
        message.events.length != 1) {
      throw const FormatException();
    }
    final state = states.singleWhere(
      (s) =>
          eventComponentKey(s.point, false) == eventComponentKey(target, false),
    );
    final restoring =
        kind == CalendarSchedulingPublicationKind.occurrenceRestore;
    final expected = restoring
        ? _schedulingRestorationPayload(
            basis,
            target,
            state.version.sequence,
            state.version.stamp,
            _schedulingCheckpointBytes,
            projected: projected,
          )
        : _schedulingInstancePayload(
            basis,
            target,
            state.version.sequence,
            state.version.stamp,
            _schedulingCheckpointBytes,
          );
    final nativeCancelled =
        canonical.timingOverrides?.singles.any(
          (s) =>
              s.cancelled &&
              eventComponentKey(s.originalStart, false) ==
                  eventComponentKey(target, false),
        ) ??
        false;
    final floor = old[_schedulingWirePointKey(target)] ?? master;
    if (state.restored != restoring ||
        p.payload != expected ||
        p.sequence != state.version.sequence ||
        p.stamp != state.version.stamp ||
        p.method != (restoring ? 'REQUEST' : 'CANCEL') ||
        state.version.sequence <= floor.sequence ||
        nativeMatch != eventSchedulingMember(canonical.content, target) ||
        restoring &&
            (nativeCancelled ||
                canonical.content.status == CalendarEventStatus.cancelled) ||
        !restoring && nativeMatch && !nativeCancelled) {
      throw const FormatException();
    }
    components = [state.version];
    outgoing = basis.outgoing;
  } else if (kind == CalendarSchedulingPublicationKind.request) {
    if (target != null ||
        nativeMatch != null ||
        v['masterMessage'] != null ||
        states.any((s) => !s.restored) ||
        p.method != 'REQUEST' ||
        p.payload != basisRecord.payload ||
        p.sequence != basisRecord.sequence ||
        p.stamp != basisRecord.stamp ||
        _schedulingCanonicalKey(canonical) !=
            _schedulingCanonicalKey(basis.canonical) ||
        _schedulingBundleProjection(ledger) !=
            _schedulingBundleProjection(basis.ledger)) {
      throw const FormatException();
    }
    components = _schedulingComponents(message);
    outgoing = basis.outgoing;
  } else {
    if (target != null ||
        nativeMatch != null ||
        kind != CalendarSchedulingPublicationKind.seriesCancel) {
      throw const FormatException();
    }
    final record = _schedulingBasisRecord(p, v['masterMessage']);
    final full = _schedulingReadCheckpoint(record);
    if (p.method != 'CANCEL' ||
        record.method != 'CANCEL' ||
        p.payload != record.payload ||
        p.sequence != record.sequence ||
        p.stamp != record.stamp ||
        _schedulingCanonicalKey(canonical) !=
            _schedulingCanonicalKey(full.canonical) ||
        _schedulingBundleProjection(ledger) !=
            _schedulingBundleProjection(full.ledger) ||
        states.any(
          (s) =>
              s.version.sequence >= p.sequence ||
              s.version.stamp.isAfter(p.stamp),
        )) {
      throw const FormatException();
    }
    components = _schedulingComponents(message);
    outgoing = full.outgoing;
  }
  if (p.projection !=
      _schedulingV4Projection(kind, target, components, version: 5)) {
    throw const FormatException();
  }
  return _SchedulingCheckpoint(
    canonical,
    outgoing,
    message,
    List.unmodifiable(ledger),
    _schedulingActiveOriginals(basis, states),
    List.unmodifiable(originals.values),
    kind: kind,
    target: target,
    nativeMatch: nativeMatch,
    basisRecord: basisRecord,
    cancelled: List.unmodifiable(states.where((s) => !s.restored)),
    restored: List.unmodifiable(states.where((s) => s.restored)),
  );
}
