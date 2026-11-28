part of 'calendar_module.dart';

bool _occCycles(Map<String, dynamic>? state) => state?['version'] == 12;
bool _occActiveCancellation(Map<String, dynamic>? state) => _occCycles(state)
    ? state!['activeCycleKey'] != null
    : _occHasRangeCancellation(state) && !_occHasRangeRestoration(state);
bool _cycleEqual(Object? a, Object? b) =>
    jsonEncode(_occOrdered(a)) == jsonEncode(_occOrdered(b));
void _cycleKeys(Map<String, dynamic> value, Set<String> keys) {
  if (value.keys.toSet().difference(keys).isNotEmpty ||
      keys.difference(value.keys.toSet()).isNotEmpty) {
    throw StateError('Invalid cycle shape');
  }
}

String _cycleHash(CalendarInvitationLinkRecord link, Object? value) =>
    _invitationHash([
      'range-cycles-v12',
      link.scopeKey,
      link.recipientKey,
      link.id.toString(),
      link.calendarId.toString(),
      link.eventId.toString(),
      link.uid,
      link.organizer,
      jsonEncode(_occOrdered(value)),
    ]);
String _cycleRootDigest(
  CalendarInvitationLinkRecord link,
  Map<String, dynamic> state,
) => _cycleHash(
  link,
  Map<String, dynamic>.of(state)
    ..remove('compositionDigest')
    ..remove('receiptDigest'),
);
String _cycleReceiptDigest(Map<String, dynamic> state) => _invitationHash([
  'range-cycle-receipt-v12',
  state['compositionDigest'] as String,
  state['latestLayer'] as String,
  '${state['latestCycleKey']}',
  state['requestDigest'] as String,
  jsonEncode(_occOrdered(state['receipt'])),
  jsonEncode(_occOrdered(state['latestTarget'])),
]);

extension CalendarInvitationCycles on CalendarService {
  CalendarInvitationRangeCancellationProjection _cycleCancellationCandidate(
    CalendarInvitationLinkRecord link,
    _OccurrenceAccepted accepted,
    Map<String, dynamic> state,
    IcalendarSchedulingMessage message,
    String address,
  ) {
    final p = projectInvitationRangeRecancellation(
      protocolUid: link.uid,
      content: accepted.content,
      timingOverrides: accepted.edits,
      protocolState: accepted.protocol,
      previousRestorationVersion: _cycleRestorationVersion(state),
      message: message,
      recipientAddress: address,
    );
    return CalendarInvitationRangeCancellationProjection.fromRecancellation(p);
  }

  String _cycleLatestRestorationKey(Map<String, dynamic> state) =>
      ((state['cycles'] as List)
              .cast<Map<String, dynamic>>()
              .where((c) => c['restoration'] != null)
              .lastOrNull)?['key']
          as String? ??
      'legacy';
  Map<String, dynamic>? _cycleViewLayer(
    Map<String, dynamic> state,
    CalendarInvitationRecord entry,
    bool restoration,
  ) {
    Map<String, dynamic>? latest;
    for (final c in state['cycles'] as List) {
      for (final k in ['cancellation', 'restoration']) {
        final layer = c[k] as Map<String, dynamic>?;
        if (layer?['invitationId'] == entry.id.toString()) latest = layer;
      }
    }
    if (!restoration && latest != null) {
      final canonical = (state['targets'] as List)
          .cast<Map<String, dynamic>>()
          .where((t) => t['key'] == entry.targetKey)
          .firstOrNull;
      if (canonical != null &&
          (canonical['acceptedRevision'] as int? ?? 0) >
              CalendarInvitationOccurrenceApplyReceipt.fromJson(
                latest['receipt'],
              ).occurrenceRevision) {
        return null;
      }
    }
    return latest;
  }

  bool _cycleLatestMatchesView(
    Map<String, dynamic> state,
    CalendarInvitationRecord entry,
    bool restoration,
  ) {
    final selected =
        _cycleViewLayer(state, entry, restoration) ??
        (state['targets'] as List)
            .cast<Map<String, dynamic>>()
            .where((t) => t['key'] == entry.targetKey)
            .firstOrNull;
    return selected != null &&
        (restoration
            ? state['latestLayer'] == 'rangeRestoration'
            : state['latestLayer'] != 'rangeRestoration') &&
        selected['sourceId'] == state['latestTarget']['sourceId'] &&
        selected['kind'] == state['latestTarget']['kind'];
  }

  Map<String, dynamic> _cycleMasterSource(
    CalendarInvitationSourceRecord source,
    String address,
  ) {
    final message = _invParse(
      utf8.encode(source.normalizedSource),
      stored: true,
    );
    return {
      'key': 'master',
      'invitationId': source.entryId.toString(),
      'sourceId': source.id.toString(),
      'source': source.normalizedSource,
      'digest': source.digest,
      'recipientAddress': address,
      'kind': _invKind(message).name,
      'version': _occVersion(message).toJson(),
    };
  }

  void _cycleValidateMasterSource(
    CalendarInvitationLinkRecord link,
    Map<String, dynamic> source,
    CalendarInvitationApplicationRecord? master,
  ) {
    _cycleKeys(source, {
      'key',
      'invitationId',
      'sourceId',
      'source',
      'digest',
      'recipientAddress',
      'kind',
      'version',
    });
    final text = source['source'] as String,
        m = _invParse(utf8.encode(text), stored: true),
        v = CalendarEventProtocolVersion.fromJson(source['version']);
    if (source['key'] != 'master' ||
        source['sourceId'] != (master?.sourceId ?? link.sourceId).toString() ||
        source['invitationId'] !=
            (master?.invitationId ?? link.invitationId).toString() ||
        source['digest'] != (master?.digest ?? link.sourceDigest) ||
        utf8.encode(text).length > 262144 ||
        sha256.convert(utf8.encode(text)).toString() != source['digest'] ||
        m.uid != link.uid ||
        m.events.length != 1 ||
        m.events.single.isOverride ||
        _invKind(m).name != source['kind'] ||
        source['kind'] !=
            (master?.kind ?? CalendarInvitationSourceKind.request).name ||
        m.events.single.participants.organizer?.address != link.organizer ||
        !m.events.single.participants.attendees.any(
          (a) => a.address == source['recipientAddress'],
        ) ||
        !_cycleEqual(_occVersion(m).toJson(), v.toJson())) {
      throw StateError('Invalid retained master source');
    }
  }

  Map<String, dynamic> _cycleFreeze(
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    CalendarInvitationApplicationRecord? master,
    Map<String, dynamic> state,
  ) =>
      state['frozenRestoration'] as Map<String, dynamic>? ??
      {
        'baseline': event.data.importBaseline!.toJson(),
        'master': master?.toJson(),
        'checkpoint': {
          'revision': row.revision,
          'eventRevision': row.eventRevision,
          'updatedAt': row.updatedAt.toIso8601String(),
          'state': jsonDecode(row.stateJson),
        },
      };
  CalendarEventProtocolVersion _cycleRestorationVersion(
    Map<String, dynamic> state,
  ) => CalendarEventProtocolVersion.fromJson(
    (state['restoration'] as Map)['version'],
  );
  Map<String, dynamic> _cycleBasis(
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    CalendarInvitationApplicationRecord? master,
    Map<String, dynamic> state,
  ) => {
    'baseline': event.data.importBaseline!.toJson(),
    'master': master?.toJson(),
    'masterSource': state['masterSource'] ?? state['_capturedMasterSource'],
    'masterBaseline': state['masterBaseline'],
    'targets': state['targets'],
    'eventRevision': event.identity.revision,
    'checkpointRevision': row.revision,
    'updatedAt': event.data.updatedAt.toIso8601String(),
  };
  Map<String, dynamic> _cycleState({
    required CalendarInvitationLinkRecord link,
    required _Event event,
    required CalendarInvitationOccurrenceApplicationRecord row,
    required CalendarInvitationApplicationRecord? master,
    required Map<String, dynamic> state,
    required CalendarEventImportMember member,
    required CalendarEventImportBaseline baseline,
    required List<Map<String, dynamic>> targets,
    required CalendarInvitationOccurrenceApplyReceipt receipt,
    required String requestDigest,
    required CalendarInvitationOccurrenceApplyRequest input,
    required CalendarInvitationSourceRecord source,
    required CalendarInvitationRecord entry,
    required CalendarInvitationRecipient recipient,
    required bool restoration,
    required bool cancellation,
    required bool range,
    required int? floor,
  }) {
    final cycles = [
      for (final c in (state['cycles'] as List? ?? []))
        Map<String, dynamic>.from(c),
    ];
    String? cycleKey = state['activeCycleKey'] as String?;
    final control = range && cancellation || restoration;
    Map<String, dynamic>? layer;
    if (control) {
      layer = {
        'key': entry.targetKey,
        'original': entry.originalStart!.toJson(),
        'kind': receipt.kind.name,
        'invitationId': entry.id.toString(),
        'sourceId': source.id.toString(),
        'source': source.normalizedSource,
        'digest': source.digest,
        'recipientAddress': recipient.calendarAddress,
        'version': _occVersion(
          _invParse(utf8.encode(source.normalizedSource), stored: true),
        ).toJson(),
        'requiredAfterSequence': floor,
        'acceptedAt': receipt.appliedAt.toIso8601String(),
        'receipt': receipt.toJson(),
        'request': input.toJson(),
        'requestDigest': requestDigest,
        'nativeDigest': _occNativeDigest(link.uid, (
          content: member.content,
          edits: member.timingOverrides,
          protocol: member.protocolState,
        )),
      };
      if (restoration) {
        if (cycleKey == null ||
            cycles.isEmpty ||
            cycles.last['key'] != cycleKey ||
            cycles.last['restoration'] != null) {
          throw StateError('Invalid active cycle');
        }
        cycles.last['restorationBasis'] = _cycleBasis(
          event,
          row,
          master,
          state,
        );
        cycles.last['restoration'] = layer;
      } else {
        cycleKey = _cycleHash(link, [source.id.toString(), source.digest]);
        cycles.add({
          'key': cycleKey,
          'cancellationBasis': _cycleBasis(event, row, master, state),
          'cancellation': layer,
          'restorationBasis': null,
          'restoration': null,
        });
      }
    }
    final result = <String, dynamic>{
      'version': 12,
      'frozenRestoration': _cycleFreeze(event, row, master, state),
      'cycles': cycles,
      'activeCycleKey': restoration ? null : cycleKey,
      'masterKind': (master?.kind ?? CalendarInvitationSourceKind.request).name,
      'masterSource': state['masterSource'] ?? state['_capturedMasterSource'],
      'masterBaseline': state['masterBaseline'],
      'masterBaselineDigest': state['masterBaselineDigest'],
      'masterDigest': _occMasterDigest(link, master),
      'baselineDigest': _invBaselineDigest(baseline),
      'expectedNativeDigest': _occNativeDigest(link.uid, (
        content: member.content,
        edits: member.timingOverrides,
        protocol: member.protocolState,
      )),
      'targets': targets,
      'latestLayer': control
          ? (restoration ? 'rangeRestoration' : 'rangeCancellation')
          : 'canonical',
      'latestCycleKey': control ? cycleKey : null,
      'latestTargetKey': entry.targetKey,
      'latestTarget':
          layer ?? targets.singleWhere((t) => t['key'] == entry.targetKey),
      'requestDigest': requestDigest,
      'receipt': receipt.toJson(),
    };
    return _cycleSeal(link, result);
  }

  Map<String, dynamic> _cycleSeal(
    CalendarInvitationLinkRecord link,
    Map<String, dynamic> value,
  ) {
    if ((value['targets'] as List).length +
            1 +
            (value['cycles'] as List).length >
        128) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    value['compositionDigest'] = _cycleRootDigest(link, value);
    value['receiptDigest'] = _cycleReceiptDigest(value);
    return value;
  }

  Map<String, dynamic> _cycleCompose({
    required CalendarInvitationLinkRecord link,
    required _Event event,
    required Map<String, dynamic> state,
    required CalendarInvitationApplicationRecord? master,
    required CalendarEventImportBaseline masterBaseline,
    required CalendarEventImportBaseline baseline,
    required CalendarEventImportMember member,
    required CalendarInvitationSourceKind kind,
    required Map<String, dynamic> masterSource,
  }) {
    _cycleCheckAnchors(member, state);
    final next = <String, dynamic>{
      for (final k in _cycleRootKeys)
        if (k != 'compositionDigest' && k != 'receiptDigest') k: state[k],
      'masterKind': kind.name,
      'masterSource': masterSource,
      'masterBaseline': masterBaseline.toJson(),
      'masterBaselineDigest': _invBaselineDigest(masterBaseline),
      'masterDigest': _occMasterDigest(link, master),
      'baselineDigest': _invBaselineDigest(baseline),
      'expectedNativeDigest': _occNativeDigest(link.uid, (
        content: member.content,
        edits: member.timingOverrides,
        protocol: member.protocolState,
      )),
    };
    return _cycleSeal(link, next);
  }

  void _cycleCheckAnchors(
    CalendarEventImportMember member,
    Map<String, dynamic> state, {
    RecurrenceWorkBudget? work,
  }) {
    final originals = [
      ((state['_legacyState'] as Map?)?['restoration'] as Map? ??
          state['restoration'] as Map)['original'],
      for (final c in state['cycles'] as List)
        (c['cancellation'] as Map)['original'],
    ];
    final budget = work ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    for (final raw in originals) {
      budget.charge();
      if (!eventSchedulingMember(
        member.content,
        CalendarEventTiming.fromJson(raw),
        sharedWorkBudget: budget,
      )) {
        throw ArgumentError('Orphaned cycle original');
      }
    }
  }

  _OccurrenceAccepted _cycleValidateBasis(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    Map<String, dynamic> basis,
    DateTime at,
    RecurrenceWorkBudget work,
    Map<String, ({CalendarEventProtocolVersion version, int revision})>
    restorations,
  ) {
    _cycleKeys(basis, {
      'baseline',
      'master',
      'masterBaseline',
      'masterSource',
      'targets',
      'eventRevision',
      'checkpointRevision',
      'updatedAt',
    });
    if (basis['eventRevision'] is! int ||
        (basis['eventRevision'] as int) < 2 ||
        (basis['eventRevision'] as int) >= row.eventRevision ||
        basis['checkpointRevision'] is! int ||
        (basis['checkpointRevision'] as int) < 1 ||
        (basis['checkpointRevision'] as int) >= row.revision ||
        DateTime.parse(basis['updatedAt']).isAfter(at)) {
      throw StateError('Invalid basis revision');
    }
    final b = CalendarEventImportBaseline.fromJson(basis['baseline']),
        m = CalendarEventImportBaseline.fromJson(basis['masterBaseline']);
    validateEventImportBaseline(b, link.uid, sharedWorkBudget: work);
    validateEventImportBaseline(m, link.uid, sharedWorkBudget: work);
    final accepted = _occAccepted(b), root = _occAccepted(m);
    final recorded = basis['master'] == null
        ? null
        : CalendarInvitationApplicationRecord.fromJson(basis['master']);
    final historical = _Event(
      event.identity.copyWith(revision: basis['eventRevision']),
      event.data.copyWith(
        content: accepted.content,
        timingOverrides: accepted.edits,
        protocolState: accepted.protocol,
        importBaseline: b,
      ),
      event.parent,
    );
    _invValidateMasterCheckpoint(link, historical, recorded, m);
    _cycleValidateMasterSource(link, basis['masterSource'], recorded);
    final targets = (basis['targets'] as List).cast<Map<String, dynamic>>();
    _occValidateTargets(link, accepted, targets, at, work: work);
    _cycleTargetFloors(targets, restorations, basis['checkpointRevision']);
    final composed = _invCompose(
      CalendarEventImportMember(
        eventId: link.eventId,
        protocolUid: link.uid,
        content: root.content,
        timingOverrides: root.edits,
        protocolState: root.protocol,
      ),
      historical,
      {'targets': targets},
      sharedWorkBudget: work,
    );
    if (eventImportBaseline(
          link.uid,
          composed.content,
          composed.timingOverrides,
          composed.protocolState,
          sharedWorkBudget: work,
        ).canonicalValue !=
        b.canonicalValue) {
      throw StateError('Invalid basis composition');
    }
    return accepted;
  }

  void _cycleTargetFloors(
    List<Map<String, dynamic>> targets,
    Map<String, ({CalendarEventProtocolVersion version, int revision})>
    restorations,
    int maximumRevision,
  ) {
    for (final t in targets) {
      final keys = t.keys.toSet();
      const required = {
        'key',
        'original',
        'kind',
        'invitationId',
        'sourceId',
        'source',
        'digest',
        'version',
        'recipientAddress',
        'acceptedAt',
        'reopened',
        'component',
      };
      if (!keys.containsAll(required) ||
          keys.difference({
            ...required,
            'acceptedRevision',
            'restorationKey',
            'requiredAfterSequence',
          }).isNotEmpty ||
          t.containsKey('acceptedRevision') &&
              (t['acceptedRevision'] is! int ||
                  t['acceptedRevision'] < 1 ||
                  t['acceptedRevision'] > maximumRevision)) {
        throw StateError('Invalid target revision or fields');
      }
      if (t.containsKey('restorationKey') &&
          (!restorations.containsKey(t['restorationKey']) ||
              t['acceptedRevision'] is! int ||
              (t['acceptedRevision'] as int) <=
                  restorations[t['restorationKey']]!.revision)) {
        throw StateError('Invalid target history reference');
      }
      if (t.containsKey('requiredAfterSequence')) {
        final v = CalendarEventProtocolVersion.fromJson(t['version']),
            floor = t['requiredAfterSequence'];
        final previous = restorations[t['restorationKey'] ?? 'legacy'];
        if (!(t['key'] as String).startsWith('range-v1:') ||
            previous == null ||
            floor is! int ||
            floor < (previous.version.sequence ?? 0) ||
            floor > eventMaxSequence ||
            v.sequence == null ||
            v.sequence! <= floor) {
          throw StateError('Invalid range floor');
        }
      } else if (t.containsKey('restorationKey')) {
        throw StateError('Unexpected history reference');
      }
    }
  }

  Map<String, dynamic> _cycleDecode(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    CalendarInvitationApplicationRecord? master,
    Map<String, dynamic> state,
  ) {
    _cycleKeys(state, _cycleRootKeys);
    final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    final sources = <String, String>{};
    void charge(Object? n, [int depth = 0]) {
      work.charge();
      // The fixed proof shapes are shallow; corrupted storage must not turn
      // bounded node work into unbounded recursive stack use.
      if (depth > 64) {
        throw StateError('Invalid proof nesting');
      }
      if (n is Map) {
        if (n['sourceId'] is String &&
            n['source'] is String &&
            n['digest'] is String) {
          final identity = '${n['digest']}:${n['source']}';
          final old = sources[n['sourceId']];
          if (old != null && old != identity) {
            throw StateError('Conflicting retained source');
          }
          sources[n['sourceId']] = identity;
        }
        for (final v in n.values) {
          charge(v, depth + 1);
        }
      } else if (n is List) {
        for (final v in n) {
          charge(v, depth + 1);
        }
      } else if (n is String) {
        for (var i = 0; i < utf8.encode(n).length; i += 256) {
          work.charge();
        }
      }
    }

    charge(state);
    _cycleKeys(state['frozenRestoration'], {
      'baseline',
      'master',
      'checkpoint',
    });
    _cycleKeys(state['frozenRestoration']['checkpoint'], {
      'revision',
      'eventRevision',
      'updatedAt',
      'state',
    });
    void legacyShape(Object? value) {
      if (value is Map) {
        if (value.containsKey('cycles') ||
            value.containsKey('frozenRestoration')) {
          throw StateError('Nested history');
        }
        for (final child in value.values) {
          legacyShape(child);
        }
      } else if (value is List) {
        for (final child in value) {
          legacyShape(child);
        }
      }
    }

    legacyShape(state['frozenRestoration']['checkpoint']['state']);
    final history = _occFrozenRestoration(
      link,
      event,
      row,
      state,
      sharedWorkBudget: work,
    );
    final legacy = history.state;
    final restorations =
        <String, ({CalendarEventProtocolVersion version, int revision})>{
          'legacy': (
            version: CalendarEventProtocolVersion.fromJson(
              (legacy['restoration'] as Map)['version'],
            ),
            revision: CalendarInvitationOccurrenceApplyReceipt.fromJson(
              legacy['receipt'],
            ).occurrenceRevision,
          ),
        };
    final cycles = (state['cycles'] as List).cast<Map<String, dynamic>>();
    if (cycles.isEmpty ||
        cycles.length + 1 + (state['targets'] as List).length > 128) {
      throw StateError('Invalid cycle capacity');
    }
    var previous = restorations['legacy']!.version;
    int priorRevision =
        (state['frozenRestoration']['checkpoint']['revision'] as int);
    final seen = <String>{};
    Map<String, dynamic>? active;
    for (final cycle in cycles) {
      _cycleKeys(cycle, {
        'key',
        'cancellationBasis',
        'cancellation',
        'restorationBasis',
        'restoration',
      });
      final c = cycle['cancellation'] as Map<String, dynamic>;
      if (cycle['key'] != _cycleHash(link, [c['sourceId'], c['digest']]) ||
          !seen.add(cycle['key'])) {
        throw StateError('Invalid cycle key');
      }
      void checkLayer(Map<String, dynamic> layer, bool restore) {
        _cycleKeys(layer, {
          'key',
          'original',
          'kind',
          'invitationId',
          'sourceId',
          'source',
          'digest',
          'recipientAddress',
          'version',
          'requiredAfterSequence',
          'acceptedAt',
          'receipt',
          'request',
          'requestDigest',
          'nativeDigest',
        });
        final r = CalendarInvitationOccurrenceApplyReceipt.fromJson(
          layer['receipt'],
        );
        final q = CalendarInvitationOccurrenceApplyRequest.fromJson(
          layer['request'],
        );
        final op = restore
            ? CalendarInvitationOperation.applyRangeRestoration
            : CalendarInvitationOperation.applyRangeCancellation;
        if (r.occurrenceRevision <= priorRevision ||
            r.occurrenceRevision > row.revision ||
            r.eventRevision > row.eventRevision ||
            r.appliedAt.isAfter(row.updatedAt) ||
            r.appliedAt != DateTime.parse(layer['acceptedAt']) ||
            q.invitationId != r.invitationId ||
            q.sourceId != r.sourceId ||
            q.linkId != link.id ||
            q.expectedOccurrenceRevision + 1 != r.occurrenceRevision ||
            q.expectedEventRevision + 1 != r.eventRevision ||
            q.expectedInvitationRevision + 1 != r.invitationRevision ||
            r.linkId != link.id ||
            r.eventId != link.eventId ||
            r.calendarId != link.calendarId ||
            r.invitationId.toString() != layer['invitationId'] ||
            r.sourceId.toString() != layer['sourceId'] ||
            r.kind.name != layer['kind'] ||
            !_replySamePoint(
              r.originalStart,
              CalendarEventTiming.fromJson(layer['original']),
            ) ||
            layer['key'] != _invTargetKey(r.originalStart, range: true) ||
            layer['requestDigest'] !=
                _occCommandDigest(
                  q,
                  op,
                  range: true,
                  cancellation: !restore,
                  restoration: restore,
                )) {
          throw StateError('Invalid cycle receipt');
        }
        final text = layer['source'] as String;
        if (utf8.encode(text).length > 262144 ||
            sha256.convert(utf8.encode(text)).toString() != layer['digest']) {
          throw StateError('Invalid cycle source');
        }
        final message = _invParse(utf8.encode(text), stored: true);
        final basis =
            cycle[restore ? 'restorationBasis' : 'cancellationBasis']
                as Map<String, dynamic>;
        if (basis['checkpointRevision'] != q.expectedOccurrenceRevision ||
            basis['eventRevision'] != q.expectedEventRevision ||
            q.expectedApplicationRevision !=
                (basis['master']?['revision'] ?? 0) ||
            q.expectedCalendarRevision < 1 ||
            q.expectedInvitationRevision < 1) {
          throw StateError('Invalid acceptance basis');
        }
        final b = _cycleValidateBasis(
          link,
          event,
          row,
          basis,
          r.appliedAt,
          work,
          restorations,
        );
        if (restore) {
          final original = CalendarEventTiming.fromJson(c['original']);
          final masked = validateEventOverrides(
            b.content,
            CalendarEventTimingOverrides(
              singles: b.edits?.singles ?? [],
              future: b.edits?.future ?? [],
              cancelledFrom: original,
            ),
            sharedWorkBudget: work,
          );
          final p = projectInvitationRangeRestoration(
            protocolUid: link.uid,
            content: b.content,
            timingOverrides: masked,
            protocolState: b.protocol,
            cancellationVersion: CalendarEventProtocolVersion.fromJson(
              c['version'],
            ),
            message: message,
            recipientAddress: layer['recipientAddress'],
            sharedWorkBudget: work,
          );
          if (!_cycleEqual(p.restorationVersion.toJson(), layer['version']) ||
              !_cycleEqual(p.originalStart.toJson(), layer['original']) ||
              p.requiredAfterSequence != layer['requiredAfterSequence'] ||
              _occNativeDigest(link.uid, (
                    content: p.content,
                    edits: p.timingOverrides,
                    protocol: p.protocolState,
                  ), sharedWorkBudget: work) !=
                  layer['nativeDigest']) {
            throw StateError('Invalid restoration proof');
          }
        } else {
          final p = projectInvitationRangeRecancellation(
            protocolUid: link.uid,
            content: b.content,
            timingOverrides: b.edits,
            protocolState: b.protocol,
            previousRestorationVersion: previous,
            message: message,
            recipientAddress: layer['recipientAddress'],
            sharedWorkBudget: work,
          );
          if (!_cycleEqual(p.cancellationVersion.toJson(), layer['version']) ||
              !_cycleEqual(p.originalStart.toJson(), layer['original']) ||
              p.requiredAfterSequence != layer['requiredAfterSequence'] ||
              _occNativeDigest(link.uid, (
                    content: p.content,
                    edits: p.timingOverrides,
                    protocol: p.protocolState,
                  ), sharedWorkBudget: work) !=
                  layer['nativeDigest']) {
            throw StateError('Invalid cancellation proof');
          }
        }
        priorRevision = r.occurrenceRevision;
      }

      checkLayer(c, false);
      if (cycle['restoration'] == null) {
        if (cycle['restorationBasis'] != null ||
            !identical(cycle, cycles.last)) {
          throw StateError('Invalid open cycle');
        }
        active = cycle;
      } else {
        checkLayer(cycle['restoration'], true);
        previous = CalendarEventProtocolVersion.fromJson(
          cycle['restoration']['version'],
        );
        restorations[cycle['key']] = (
          version: previous,
          revision: priorRevision,
        );
      }
    }
    if (state['activeCycleKey'] != active?['key'] ||
        state['masterKind'] !=
            (master?.kind ?? CalendarInvitationSourceKind.request).name ||
        state['masterDigest'] != _occMasterDigest(link, master) ||
        state['baselineDigest'] !=
            _invBaselineDigest(event.data.importBaseline!)) {
      throw StateError('Invalid current cycle binding');
    }
    final basis = CalendarEventImportBaseline.fromJson(state['masterBaseline']);
    validateEventImportBaseline(basis, link.uid, sharedWorkBudget: work);
    _invValidateMasterCheckpoint(link, event, master, basis);
    _cycleValidateMasterSource(link, state['masterSource'], master);
    if (state['masterBaselineDigest'] != _invBaselineDigest(basis)) {
      throw StateError('Invalid master baseline');
    }
    final accepted = _occAccepted(event.data.importBaseline!),
        targets = (state['targets'] as List).cast<Map<String, dynamic>>();
    _occValidateTargets(link, accepted, targets, row.updatedAt, work: work);
    _cycleTargetFloors(targets, restorations, row.revision);
    final root = _occAccepted(basis),
        composed = _invCompose(
          CalendarEventImportMember(
            eventId: link.eventId,
            protocolUid: link.uid,
            content: root.content,
            timingOverrides: root.edits,
            protocolState: root.protocol,
          ),
          event,
          {'targets': targets},
          sharedWorkBudget: work,
        );
    if (eventImportBaseline(
          link.uid,
          composed.content,
          composed.timingOverrides,
          composed.protocolState,
          sharedWorkBudget: work,
        ).canonicalValue !=
        event.data.importBaseline!.canonicalValue) {
      throw StateError('Invalid current composition');
    }
    final derived = <String, dynamic>{
      ...legacy,
      ...state,
      '_legacyState': legacy,
      'rangeCancellation': cycles.last['cancellation'],
      'restoration': active == null
          ? cycles.last['restoration']
          : cycles.length == 1
          ? legacy['restoration']
          : cycles[cycles.length - 2]['restoration'],
    };
    _cycleCheckAnchors(composed, derived, work: work);
    final masked = _occMaskMember(composed, derived, sharedWorkBudget: work);
    if (state['expectedNativeDigest'] !=
            _occNativeDigest(link.uid, (
              content: masked.content,
              edits: masked.timingOverrides,
              protocol: masked.protocolState,
            ), sharedWorkBudget: work) ||
        state['compositionDigest'] != _cycleRootDigest(link, state) ||
        state['receiptDigest'] != _cycleReceiptDigest(state)) {
      throw StateError('Invalid current cycle digest');
    }
    Map<String, dynamic> selected;
    if (state['latestLayer'] == 'canonical') {
      if (state['latestCycleKey'] != null) {
        throw StateError('Unexpected canonical cycle');
      }
      selected = targets.singleWhere(
        (t) => t['key'] == state['latestTargetKey'],
      );
    } else {
      final cycle = cycles.singleWhere(
        (c) => c['key'] == state['latestCycleKey'],
      );
      selected =
          cycle[state['latestLayer'] == 'rangeCancellation'
              ? 'cancellation'
              : state['latestLayer'] == 'rangeRestoration'
              ? 'restoration'
              : 'invalid'];
    }
    final receipt = CalendarInvitationOccurrenceApplyReceipt.fromJson(
      state['receipt'],
    );
    if (!_cycleEqual(selected, state['latestTarget']) ||
        selected['key'] != state['latestTargetKey'] ||
        receipt.linkId != link.id ||
        receipt.eventId != link.eventId ||
        receipt.calendarId != link.calendarId ||
        receipt.sourceId.toString() != selected['sourceId'] ||
        receipt.invitationId.toString() != selected['invitationId'] ||
        receipt.kind.name != selected['kind'] ||
        !_replySamePoint(
          receipt.originalStart,
          CalendarEventTiming.fromJson(selected['original']),
        ) ||
        receipt.appliedAt != DateTime.parse(selected['acceptedAt']) ||
        receipt.occurrenceRevision > row.revision ||
        receipt.eventRevision > row.eventRevision ||
        receipt.occurrenceRevision < 1 ||
        receipt.eventRevision < 2 ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(state['requestDigest']) ||
        state['latestLayer'] != 'canonical' &&
            (!_cycleEqual(selected['receipt'], state['receipt']) ||
                selected['requestDigest'] != state['requestDigest'])) {
      throw StateError('Invalid latest cycle command');
    }
    return derived;
  }
}

const _cycleRootKeys = {
  'version',
  'frozenRestoration',
  'cycles',
  'activeCycleKey',
  'masterKind',
  'masterSource',
  'masterBaseline',
  'masterBaselineDigest',
  'masterDigest',
  'baselineDigest',
  'expectedNativeDigest',
  'targets',
  'latestLayer',
  'latestCycleKey',
  'latestTargetKey',
  'latestTarget',
  'requestDigest',
  'receipt',
  'compositionDigest',
  'receiptDigest',
};
