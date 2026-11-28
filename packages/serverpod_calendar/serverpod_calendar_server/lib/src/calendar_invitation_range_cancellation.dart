part of 'calendar_module.dart';

bool _occHasRangeCancellation(Map<String, dynamic>? state) =>
    {4, 5, 6, 7, 8, 9, 10, 11, 12}.contains(state?['version']);

Map<String, dynamic> _occLatestTarget(Map<String, dynamic> state) {
  if (_occCycles(state)) return state['latestTarget'] as Map<String, dynamic>;
  if (_occHasRangeRestoration(state) && !{10, 11}.contains(state['version'])) {
    return state['restoration'] as Map<String, dynamic>;
  }
  if (_occHasRangeCancellation(state) && !{10, 11}.contains(state['version'])) {
    return state['rangeCancellation'] as Map<String, dynamic>;
  }
  final receipt = CalendarInvitationOccurrenceApplyReceipt.fromJson(
    state['receipt'],
  );
  return (state['targets'] as List).cast<Map<String, dynamic>>().singleWhere(
    (v) => v['key'] == _occLatestKey(state, receipt),
  );
}

// A native comparison only; this value is never accepted as an import baseline.
String _occNativeDigest(
  String uid,
  _OccurrenceAccepted value, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) => _invitationHash([
  'range-cancel-native-v4',
  eventImportBaseline(
    uid,
    value.content,
    value.edits,
    value.protocol,
    sharedWorkBudget: sharedWorkBudget,
  ).canonicalValue,
]);

String _occCancellationBinding(
  CalendarInvitationLinkRecord link,
  Map<String, dynamic> layer,
  String expectedNativeDigest,
) {
  final fields = Map<String, dynamic>.of(layer)..remove('binding');
  return _invitationHash([
    'range-cancel-layer-v4',
    link.scopeKey,
    link.recipientKey,
    link.id.toString(),
    link.calendarId.toString(),
    link.eventId.toString(),
    link.uid,
    link.organizer,
    jsonEncode(_occOrdered(fields)),
    expectedNativeDigest,
  ]);
}

extension CalendarInvitationRangeCancellationOperations on CalendarService {
  void _occValidateCancellation(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    Map<String, dynamic> state, {
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    final composed = {5, 6}.contains(state['version']);
    final basis = composed
        ? CalendarEventImportBaseline.fromJson(state['cancellationBasis'])
        : event.data.importBaseline!;
    validateEventImportBaseline(
      basis,
      link.uid,
      sharedWorkBudget: sharedWorkBudget,
    );
    final layer = state['rangeCancellation'] as Map<String, dynamic>;
    final original = CalendarEventTiming.fromJson(layer['original']);
    final text = layer['source'] as String;
    final version = CalendarEventProtocolVersion.fromJson(layer['version']);
    final sourceId = UuidValue.fromString(layer['sourceId'] as String);
    final entryId = UuidValue.fromString(layer['invitationId'] as String);
    if (state['latestLayer'] != 'rangeCancellation' ||
        state['latestTargetKey'] != layer['key'] ||
        layer['key'] != _invTargetKey(original, range: true) ||
        layer['kind'] != CalendarInvitationSourceKind.rangeCancellation.name ||
        layer['basisDigest'] != _invBaselineDigest(basis) ||
        utf8.encode(text).length > 262144 ||
        sha256.convert(utf8.encode(text)).toString() != layer['digest'] ||
        DateTime.parse(layer['acceptedAt']).isAfter(row.updatedAt) ||
        sourceId.toString() != layer['sourceId'] ||
        entryId.toString() != layer['invitationId']) {
      throw StateError('Invalid cancellation evidence');
    }
    final accepted = _occAccepted(basis);
    final projection = projectInvitationRangeCancellation(
      protocolUid: link.uid,
      content: accepted.content,
      timingOverrides: accepted.edits,
      protocolState: accepted.protocol,
      message: _invParse(utf8.encode(text), stored: true),
      recipientAddress: layer['recipientAddress'] as String,
      sharedWorkBudget: sharedWorkBudget,
    );
    final expected = _occNativeDigest(link.uid, (
      content: projection.content,
      edits: projection.timingOverrides,
      protocol: projection.protocolState,
    ), sharedWorkBudget: sharedWorkBudget);
    if (!_replySamePoint(original, projection.originalStart) ||
        jsonEncode(_occOrdered(version.toJson())) !=
            jsonEncode(_occOrdered(projection.cancellationVersion.toJson())) ||
        layer['requiredAfterSequence'] != projection.requiredAfterSequence ||
        (composed
                ? state['cancellationNativeDigest']
                : state['expectedNativeDigest']) !=
            expected ||
        layer['binding'] != _occCancellationBinding(link, layer, expected)) {
      throw StateError('Invalid cancellation projection binding');
    }
    if (composed) {
      final current = _occAccepted(event.data.importBaseline!);
      final candidate = _occMaskMember(
        CalendarEventImportMember(
          eventId: link.eventId,
          protocolUid: link.uid,
          content: current.content,
          timingOverrides: current.edits,
          protocolState: current.protocol,
        ),
        state,
        sharedWorkBudget: sharedWorkBudget,
      );
      if (state['expectedNativeDigest'] !=
              _occNativeDigest(link.uid, (
                content: candidate.content,
                edits: candidate.timingOverrides,
                protocol: candidate.protocolState,
              ), sharedWorkBudget: sharedWorkBudget) ||
          state['compositionDigest'] != _occCompositionDigest(link, state)) {
        throw StateError('Invalid current cancellation composition');
      }
    }
  }

  CalendarEventImportMember _occMaskMember(
    CalendarEventImportMember member,
    Map<String, dynamic> state, {
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    if (!_occActiveCancellation(state)) return member;
    final original = CalendarEventTiming.fromJson(
      (_occCycles(state)
          ? (state['cycles'] as List).last['cancellation']
                as Map<String, dynamic>
          : _occLatestTarget(state))['original'],
    );
    final edits = validateEventOverrides(
      member.content,
      CalendarEventTimingOverrides(
        singles: member.timingOverrides?.singles ?? [],
        future: member.timingOverrides?.future ?? [],
        cancelledFrom: original,
      ),
      sharedWorkBudget:
          sharedWorkBudget ??
          RecurrenceWorkBudget(maxWork: eventMaxCandidateWork),
    );
    final protocol = validateEventProtocolState(
      member.protocolState,
      member.content,
      edits,
    );
    return CalendarEventImportMember(
      eventId: member.eventId,
      protocolUid: member.protocolUid,
      content: member.content,
      timingOverrides: edits,
      protocolState: protocol,
    );
  }

  String _occCompositionDigest(
    CalendarInvitationLinkRecord link,
    Map<String, dynamic> state,
  ) => _invitationHash([
    state['version'] == 6
        ? 'range-cancel-composition-v6'
        : 'range-cancel-composition-v5',
    link.scopeKey,
    link.recipientKey,
    link.id.toString(),
    link.calendarId.toString(),
    link.eventId.toString(),
    link.uid,
    link.organizer,
    state['masterDigest'] as String,
    state['masterBaselineDigest'] as String,
    state['baselineDigest'] as String,
    _occLatestTarget(state)['binding'] as String,
    state['cancellationNativeDigest'] as String,
    state['expectedNativeDigest'] as String,
  ]);

  Map<String, dynamic> _occComposeCancellation({
    required CalendarInvitationLinkRecord link,
    required _Event event,
    required Map<String, dynamic> state,
    required CalendarEventImportBaseline masterBaseline,
    required CalendarEventImportBaseline baseline,
    required CalendarEventImportMember member,
    required CalendarInvitationApplicationRecord? master,
    bool lifecycle = false,
  }) {
    final next = <String, dynamic>{
      ...state,
      'version': lifecycle || state['version'] == 6 ? 6 : 5,
      'cancellationBasis': {5, 6}.contains(state['version'])
          ? state['cancellationBasis']
          : event.data.importBaseline!.toJson(),
      'cancellationNativeDigest': {5, 6}.contains(state['version'])
          ? state['cancellationNativeDigest']
          : state['expectedNativeDigest'],
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
    next['compositionDigest'] = _occCompositionDigest(link, next);
    next['receiptDigest'] = _occReceiptDigest(next);
    return next;
  }

  Map<String, dynamic> _occCancellationState({
    required CalendarInvitationLinkRecord link,
    required _Event event,
    required CalendarInvitationApplicationRecord? master,
    required Map<String, dynamic>? previous,
    required CalendarInvitationRecord entry,
    required CalendarInvitationSourceRecord source,
    required CalendarInvitationRecipient recipient,
    required CalendarInvitationRangeCancellationProjection projection,
    required CalendarInvitationOccurrenceApplyReceipt receipt,
    required String requestDigest,
  }) {
    final basisDigest = _invBaselineDigest(event.data.importBaseline!);
    final expected = _occNativeDigest(link.uid, (
      content: projection.content,
      edits: projection.timingOverrides,
      protocol: projection.protocolState,
    ));
    final layer = <String, dynamic>{
      'key': entry.targetKey,
      'original': projection.originalStart.toJson(),
      'kind': receipt.kind.name,
      'invitationId': entry.id.toString(),
      'sourceId': source.id.toString(),
      'source': source.normalizedSource,
      'digest': source.digest,
      'recipientAddress': recipient.calendarAddress,
      'version': projection.cancellationVersion.toJson(),
      'requiredAfterSequence': projection.requiredAfterSequence,
      'basisDigest': basisDigest,
      'acceptedAt': receipt.appliedAt.toIso8601String(),
    };
    layer['binding'] = _occCancellationBinding(link, layer, expected);
    final state = <String, dynamic>{
      'version': 4,
      'latestLayer': 'rangeCancellation',
      'latestTargetKey': entry.targetKey,
      'masterBaseline':
          previous?['masterBaseline'] ?? event.data.importBaseline!.toJson(),
      'masterBaselineDigest': previous?['masterBaselineDigest'] ?? basisDigest,
      'masterDigest': _occMasterDigest(link, master),
      'baselineDigest': basisDigest,
      'targets': previous?['targets'] ?? <dynamic>[],
      'rangeCancellation': layer,
      'expectedNativeDigest': expected,
      'requestDigest': requestDigest,
      'receipt': receipt.toJson(),
    };
    state['receiptDigest'] = _occReceiptDigest(state);
    return state;
  }

  /// Authorize the accepted source by its own identity, even at another notice.
  Future<void> _occAuthorizeCancellation(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    Transaction tx,
    CalendarAuthorizationPhase phase,
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord? row,
    Map<String, dynamic>? state,
  ) async {
    if (!_occHasRangeCancellation(state)) return;
    if (_occCycles(state)) {
      await _occAuthorizeCancellation(
        actor,
        recipient,
        tx,
        phase,
        link,
        event,
        row,
        state!['_legacyState'],
      );
      final layers = <Map<String, dynamic>>[
        state['masterSource'],
        for (final c in state['cycles'] as List) ...[
          c['cancellation'],
          c['cancellationBasis']['masterSource'],
          if (c['restorationBasis'] != null)
            c['restorationBasis']['masterSource'],
          if (c['restoration'] != null) c['restoration'],
          ...((c['cancellationBasis']['targets'] as List)
              .cast<Map<String, dynamic>>()),
          if (c['restorationBasis'] != null)
            ...((c['restorationBasis']['targets'] as List)
                .cast<Map<String, dynamic>>()),
        ],
        ...(state['targets'] as List).cast<Map<String, dynamic>>(),
      ];
      // Legacy proof can retain a canonical source later superseded before
      // entry into v12. Its raw body is still protected historical content.
      void historicalSources(Object? value) {
        if (value is Map<String, dynamic>) {
          if (value['key'] is String &&
              value['invitationId'] is String &&
              value['sourceId'] is String &&
              value['source'] is String &&
              value['digest'] is String) {
            layers.add(value);
          }
          for (final child in value.values) {
            historicalSources(child);
          }
        } else if (value is List) {
          for (final child in value) {
            historicalSources(child);
          }
        }
      }

      historicalSources(state['frozenRestoration']['checkpoint']['state']);
      final seen = <String>{};
      for (final layer in layers) {
        if (seen.add('${layer['sourceId']}:${layer['digest']}')) {
          await _occAuthorizeCancellation(
            actor,
            recipient,
            tx,
            phase,
            link,
            event,
            row,
            {'version': 4, 'rangeCancellation': layer},
          );
        }
      }
      return;
    }
    if (_occHasRangeRestoration(state)) {
      await _occAuthorizeCancellation(
        actor,
        recipient,
        tx,
        phase,
        link,
        event,
        row,
        (state!['preRestoration'] as Map<String, dynamic>)['state']
            as Map<String, dynamic>,
      );
      await _occAuthorizeCancellation(
        actor,
        recipient,
        tx,
        phase,
        link,
        event,
        row,
        {'version': 4, 'rangeCancellation': state['restoration']},
      );
      if ({10, 11}.contains(state['version'])) {
        for (final target
            in (state['targets'] as List).cast<Map<String, dynamic>>()) {
          await _occAuthorizeCancellation(
            actor,
            recipient,
            tx,
            phase,
            link,
            event,
            row,
            {'version': 4, 'rangeCancellation': target},
          );
        }
      }
      return;
    }
    final layer = _occLatestTarget(state!);
    if (layer['recipientAddress'] != recipient.calendarAddress) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    final id = UuidValue.fromString(layer['invitationId'] as String);
    final sourceId = UuidValue.fromString(layer['sourceId'] as String);
    final source = await CalendarInvitationSourceRecord.db.findById(
      _session,
      sourceId,
      transaction: tx,
    );
    if (source != null &&
        (source.entryId != id || source.digest != layer['digest'])) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final entry = await _invOptionalEntry(id, recipient, tx);
    final view = entry == null ? null : await _invView(entry, tx);
    final text = layer['source'] as String;
    for (final operation in {
      CalendarInvitationOperation.readSummary,
      CalendarInvitationOperation.readSource,
      CalendarInvitationOperation.readLink,
      layer['key'] == 'master'
          ? CalendarInvitationOperation.readApplication
          : (layer['key'] as String).startsWith('range-v1:')
          ? CalendarInvitationOperation.readRangeApplication
          : CalendarInvitationOperation.readOccurrenceApplication,
    }) {
      await _invAuthorize(
        CalendarInvitationPolicyContext(
          operation: operation,
          actor: actor,
          recipient: recipient,
          current: view,
          entryId: id,
          sourceId: sourceId,
          message: _invParse(utf8.encode(text), stored: true),
          normalizedSource: text,
          sourceDigest: layer['digest'] as String,
          link: _invLinkReceipt(link),
          linkSource: _invLinkSource(link),
          calendar: event.parent.snapshot,
          currentEvent: event.snapshot,
          currentOccurrenceApplication: _occSnapshot(row),
        ),
        tx,
        phase,
      );
    }
  }
}
