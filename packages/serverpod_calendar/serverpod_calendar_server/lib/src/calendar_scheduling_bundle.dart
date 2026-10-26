part of 'calendar_module.dart';

const _schedulingCheckpointBytes = 524288;

String _schedulingBound(String value) {
  if (value.length > _schedulingCheckpointBytes ||
      utf8.encode(value).length > _schedulingCheckpointBytes) {
    throw _failure(CalendarFailureCode.limitExceeded);
  }
  return value;
}

Map<String, dynamic> _schedulingSnapshotMap(CalendarEventPolicySnapshot v) => {
  'eventId': v.eventId.toString(),
  'calendarId': v.calendarId.toString(),
  'revision': v.revision,
  'protocolUid': v.protocolUid,
  'updatedAt': v.updatedAt.toIso8601String(),
  'content': v.content.toJson(),
  'state': v.protocolState!.toJson(),
  'overrides': v.timingOverrides?.toJson(),
};

CalendarEventPolicySnapshot _schedulingReadSnapshot(dynamic input) {
  final v = input as Map<String, dynamic>;
  final content = validateEventContent(
    CalendarEventContent.fromJson(v['content'] as Map<String, dynamic>),
  );
  final edits = validateEventOverrides(
    content,
    v['overrides'] == null
        ? null
        : CalendarEventTimingOverrides.fromJson(
            v['overrides'] as Map<String, dynamic>,
          ),
  );
  final state = validateEventProtocolState(
    CalendarEventProtocolState.fromJson(v['state'] as Map<String, dynamic>),
    content,
    edits,
  );
  return CalendarEventPolicySnapshot(
    UuidValue.fromString(v['eventId'] as String),
    UuidValue.fromString(v['calendarId'] as String),
    v['revision'] as int,
    content,
    v['protocolUid'] as String,
    DateTime.parse(v['updatedAt'] as String),
    origin: CalendarEventOrigin.native,
    timingOverrides: edits,
    protocolState: state,
  );
}

String _schedulingCanonicalKey(CalendarEventPolicySnapshot v) => jsonEncode([
  _schedulingProjection(v.content, v.protocolState!),
  v.timingOverrides?.toJson(),
  // Presence/source data is canonical, but protocol version advancement alone
  // does not manufacture an outgoing content difference.
  v.protocolState!.overrides.map((o) {
    final fields = o.toJson()..remove('version');
    return fields;
  }).toList(),
]);

final class _SchedulingComponentVersion {
  const _SchedulingComponentVersion(
    this.key,
    this.future,
    this.projection,
    this.sequence,
    this.stamp,
  );
  final String key, projection;
  final bool future;
  final int sequence;
  final DateTime stamp;
  Map<String, dynamic> toJson() => {
    'key': key,
    'future': future,
    'projection': projection,
    'sequence': sequence,
    'stamp': stamp.toIso8601String(),
  };
  factory _SchedulingComponentVersion.read(dynamic input) {
    final v = input as Map<String, dynamic>;
    final sequence = v['sequence'] as int,
        stamp = DateTime.parse(v['stamp'] as String);
    if (sequence < 0 ||
        sequence > eventMaxSequence ||
        eventProtocolInstant(stamp) != stamp) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return _SchedulingComponentVersion(
      v['key'] as String,
      v['future'] as bool,
      v['projection'] as String,
      sequence,
      stamp,
    );
  }
}

_SchedulingComponentVersion _schedulingComponent(IcalendarSchedulingEvent e) {
  final source = e.source;
  final rid = source.entries
      .whereType<IcalendarSyntaxProperty>()
      .where((p) => p.canonicalName == 'RECURRENCE-ID')
      .firstOrNull;
  final key = rid == null
      ? 'master'
      : jsonEncode([
          rid.value,
          rid.parameters
              .where((p) => p.canonicalName != 'RANGE')
              .map((p) => [p.canonicalName, p.values])
              .toList(),
        ]);
  final projection = utf8.decode(
    serializeIcalendarSyntax(
      IcalendarSyntaxDocument([
        IcalendarSyntaxComponent(
          'VEVENT',
          source.entries.where(
            (entry) =>
                entry is! IcalendarSyntaxProperty ||
                !{'SEQUENCE', 'DTSTAMP'}.contains(entry.canonicalName),
          ),
        ),
      ]),
    ),
  );
  return _SchedulingComponentVersion(
    key,
    e.isThisAndFuture,
    projection,
    e.sequence ?? 0,
    e.stamp,
  );
}

List<_SchedulingComponentVersion> _schedulingComponents(
  IcalendarSchedulingMessage message,
) {
  final result = message.events.map(_schedulingComponent).toList();
  if (result.isEmpty ||
      result.length > 65 ||
      result.where((v) => v.key == 'master').length != 1 ||
      result.map((v) => v.key).toSet().length != result.length) {
    throw _failure(CalendarFailureCode.validation);
  }
  return result;
}

String _schedulingBundleProjection(List<_SchedulingComponentVersion> values) =>
    _schedulingBound(
      jsonEncode({
        'version': 2,
        'components': values.map((v) => v.toJson()).toList(),
      }),
    );

bool _schedulingWireUnchanged(
  CalendarEventPolicySnapshot proposed,
  _SchedulingCheckpoint previous,
  int maxBytes,
) {
  final candidate = parseIcalendarSchedulingMessage(
    utf8.encode(_schedulingPayload(proposed, maxBytes)),
    syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
  );
  String projection(List<_SchedulingComponentVersion> values) =>
      jsonEncode(values.map((v) => [v.key, v.future, v.projection]).toList());
  return projection(_schedulingComponents(candidate)) ==
      projection(previous.ledger);
}

final class _SchedulingCheckpoint {
  const _SchedulingCheckpoint(
    this.canonical,
    this.outgoing,
    this.message,
    this.ledger,
  );
  final CalendarEventPolicySnapshot canonical, outgoing;
  final IcalendarSchedulingMessage message;
  final List<_SchedulingComponentVersion> ledger;
}

_SchedulingCheckpoint _schedulingReadCheckpoint(
  CalendarSchedulingPublicationRecord p,
) {
  try {
    _schedulingBound(p.snapshot);
    _schedulingBound(p.projection);
    if (p.payload.length > _schedulingCheckpointBytes ||
        _schedulingDigest(p.payload) != p.payloadDigest) {
      throw const FormatException();
    }
    final message = parseIcalendarSchedulingMessage(
      utf8.encode(p.payload),
      syntaxLimits: const IcalendarSyntaxLimits(
        maxBytes: _schedulingCheckpointBytes,
      ),
    );
    final components = _schedulingComponents(message);
    final master = components.singleWhere((v) => v.key == 'master');
    final value = jsonDecode(p.snapshot) as Map<String, dynamic>;
    final legacy = !value.containsKey('version');
    if (!legacy && value['version'] != 2) throw const FormatException();
    final canonical = _schedulingReadSnapshot(
      legacy ? value : value['canonical'],
    );
    final outgoing = legacy
        ? canonical
        : _schedulingReadSnapshot(value['outgoing']);
    final ledger = legacy
        ? components
        : (value['ledger'] as List)
              .map(_SchedulingComponentVersion.read)
              .toList();
    if (ledger.isEmpty ||
        ledger.length > 65 ||
        ledger.where((v) => v.key == 'master').length != 1 ||
        ledger.map((v) => v.key).toSet().length != ledger.length ||
        legacy &&
            (components.length != 1 ||
                _schedulingOverrides(outgoing.timingOverrides)) ||
        message.uid != p.protocolUid ||
        outgoing.protocolUid != p.protocolUid ||
        canonical.protocolUid != p.protocolUid ||
        canonical.eventId != outgoing.eventId ||
        canonical.calendarId != outgoing.calendarId ||
        master.sequence != p.sequence ||
        master.stamp != p.stamp ||
        message.method.name.toUpperCase() != p.method ||
        (p.method == 'CANCEL' &&
            (components.length != 1 ||
                message.events.single.status !=
                    IcalendarEventStatus.cancelled)) ||
        (legacy
            ? _schedulingProjection(
                    outgoing.content,
                    outgoing.protocolState!,
                  ) !=
                  p.projection
            : _schedulingBundleProjection(components) != p.projection) ||
        p.method == 'REQUEST' &&
            _schedulingBundleProjection(ledger) !=
                _schedulingBundleProjection(components)) {
      throw const FormatException();
    }
    // Verify canonical-to-wire projection as well as stored comparison strings.
    final expected = parseIcalendarSchedulingMessage(
      utf8.encode(
        _schedulingPayload(
          outgoing,
          _schedulingCheckpointBytes,
          method: p.method,
        ),
      ),
    );
    final expectedComponents = _schedulingComponents(expected);
    if (jsonEncode(
          expectedComponents
              .map((v) => [v.key, v.future, v.projection])
              .toList(),
        ) !=
        jsonEncode(
          components.map((v) => [v.key, v.future, v.projection]).toList(),
        )) {
      throw const FormatException();
    }
    // Reconstruct the retained REQUEST ledger under the actual envelope/zones.
    // Even a CANCEL checkpoint must not accept arbitrary keys/version strings.
    final envelope = message.source.components.single;
    final cancellationLedger =
        p.method == 'CANCEL' &&
        ledger.length == 1 &&
        parseIcalendarSyntax(utf8.encode(ledger.single.projection))
            .components
            .single
            .entries
            .whereType<IcalendarSyntaxProperty>()
            .any((p) => p.canonicalName == 'STATUS' && p.value == 'CANCELLED');
    final ledgerSource = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [
        ...envelope.entries.whereType<IcalendarSyntaxProperty>().where(
          (p) => p.canonicalName != 'METHOD',
        ),
        IcalendarSyntaxProperty(
          'METHOD',
          cancellationLedger ? 'CANCEL' : 'REQUEST',
        ),
        ...envelope.entries.whereType<IcalendarSyntaxComponent>().where(
          (c) => c.canonicalName == 'VTIMEZONE',
        ),
        for (final v in ledger)
          IcalendarSyntaxComponent('VEVENT', [
            ...parseIcalendarSyntax(utf8.encode(v.projection))
                .components
                .single
                .entries,
            IcalendarSyntaxProperty('SEQUENCE', '${v.sequence}'),
            IcalendarSyntaxProperty(
              'DTSTAMP',
              EventComponentWriter().utc(v.stamp),
            ),
          ]),
      ]),
    ]);
    // Legacy CANCELs predate a retained REQUEST ledger and contain only their
    // cancellation master. Never invent a prior active component for them.
    {
      final validatedLedger = validateIcalendarSchedulingMessage(ledgerSource);
      if (validatedLedger.uid != p.protocolUid ||
          !legacy &&
              p.method == 'CANCEL' &&
              ledger.any((v) => v.sequence >= p.sequence) ||
          _schedulingBundleProjection(_schedulingComponents(validatedLedger)) !=
              _schedulingBundleProjection(ledger) ||
          validatedLedger.events.any(
            (e) =>
                jsonEncode(
                  e.participants.attendees.map((a) => a.address).toList()
                    ..sort(),
                ) !=
                jsonEncode(p.recipients),
          )) {
        throw const FormatException();
      }
    }
    // Ledger projections are separately bounded syntax, not arbitrary opaque keys.
    for (final v in ledger) {
      final document = parseIcalendarSyntax(utf8.encode(v.projection));
      if (document.components.length != 1 ||
          document.components.single.canonicalName != 'VEVENT') {
        throw const FormatException();
      }
    }
    return _SchedulingCheckpoint(
      canonical,
      outgoing,
      message,
      List.unmodifiable(ledger),
    );
  } catch (_) {
    throw _failure(CalendarFailureCode.unavailable);
  }
}

String _schedulingWriteCheckpoint(
  CalendarEventPolicySnapshot canonical,
  CalendarEventPolicySnapshot outgoing,
  List<_SchedulingComponentVersion> ledger,
) => _schedulingBound(
  jsonEncode({
    'version': 2,
    'canonical': _schedulingSnapshotMap(canonical),
    'outgoing': _schedulingSnapshotMap(outgoing),
    'ledger': ledger.map((v) => v.toJson()).toList(),
  }),
);

String _schedulingVersionedPayload(
  String payload,
  _SchedulingCheckpoint? previous,
  DateTime now,
  int maxBytes,
) {
  final parsed = parseIcalendarSchedulingMessage(
    utf8.encode(payload),
    syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
  );
  final values = _schedulingComponents(parsed);
  final old = {
    for (final v in previous?.ledger ?? <_SchedulingComponentVersion>[])
      v.key: v,
  };
  final current = {for (final v in values) v.key: v};
  for (final entry in old.entries) {
    if (!current.containsKey(entry.key) ||
        current[entry.key]!.future != entry.value.future) {
      throw _failure(CalendarFailureCode.validation);
    }
  }
  final reopenFloor =
      previous?.message.method == IcalendarSchedulingMethod.cancel
      ? previous!.message.events.single.sequence!
      : null;
  final versions = <String, _SchedulingComponentVersion>{};
  for (final value in values) {
    if (value.key == 'master') {
      versions[value.key] = value;
      continue;
    }
    final prior = old[value.key];
    if (prior != null &&
        prior.projection == value.projection &&
        reopenFloor == null) {
      versions[value.key] = prior;
    } else {
      final sequence = max(
        value.sequence,
        max(
          prior == null ? 0 : prior.sequence + 1,
          reopenFloor == null ? 0 : reopenFloor + 1,
        ),
      );
      if (sequence > eventMaxSequence) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      var stamp = now.isAfter(value.stamp) ? now : value.stamp;
      if (prior != null && prior.stamp.isAfter(stamp)) stamp = prior.stamp;
      versions[value.key] = _SchedulingComponentVersion(
        value.key,
        value.future,
        value.projection,
        sequence,
        eventProtocolInstant(stamp),
      );
    }
  }
  final original = parsed.source.components.single;
  var index = 0;
  final writer = EventComponentWriter();
  final result = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent(original.name, [
      for (final entry in original.entries)
        if (entry is IcalendarSyntaxComponent &&
            entry.canonicalName == 'VEVENT')
          (() {
            final version = versions[values[index++].key]!;
            return IcalendarSyntaxComponent(entry.name, [
              ...entry.entries.where(
                (e) =>
                    e is! IcalendarSyntaxProperty ||
                    !{'SEQUENCE', 'DTSTAMP'}.contains(e.canonicalName),
              ),
              IcalendarSyntaxProperty('SEQUENCE', '${version.sequence}'),
              IcalendarSyntaxProperty('DTSTAMP', writer.utc(version.stamp)),
            ]);
          })()
        else
          entry,
    ]),
  ]);
  return utf8.decode(
    serializeIcalendarSchedulingMessage(
      validateIcalendarSchedulingMessage(
        result,
        syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
      ),
      syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
    ),
  );
}
