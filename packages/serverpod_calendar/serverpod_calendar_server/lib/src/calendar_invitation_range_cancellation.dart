part of 'calendar_module.dart';

bool _occHasRangeCancellation(Map<String, dynamic>? state) =>
    state?['version'] == 4;

Map<String, dynamic> _occLatestTarget(Map<String, dynamic> state) {
  if (_occHasRangeCancellation(state)) {
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
String _occNativeDigest(String uid, _OccurrenceAccepted value) =>
    _invitationHash([
      'range-cancel-native-v4',
      eventImportBaseline(
        uid,
        value.content,
        value.edits,
        value.protocol,
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
    Map<String, dynamic> state,
  ) {
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
        layer['basisDigest'] != state['baselineDigest'] ||
        utf8.encode(text).length > 262144 ||
        sha256.convert(utf8.encode(text)).toString() != layer['digest'] ||
        DateTime.parse(layer['acceptedAt']).isAfter(row.updatedAt) ||
        sourceId.toString() != layer['sourceId'] ||
        entryId.toString() != layer['invitationId']) {
      throw StateError('Invalid cancellation evidence');
    }
    final accepted = _occAccepted(event.data.importBaseline!);
    final projection = projectInvitationRangeCancellation(
      protocolUid: link.uid,
      content: accepted.content,
      timingOverrides: accepted.edits,
      protocolState: accepted.protocol,
      message: _invParse(utf8.encode(text), stored: true),
      recipientAddress: layer['recipientAddress'] as String,
    );
    final expected = _occNativeDigest(link.uid, (
      content: projection.content,
      edits: projection.timingOverrides,
      protocol: projection.protocolState,
    ));
    if (!_replySamePoint(original, projection.originalStart) ||
        jsonEncode(_occOrdered(version.toJson())) !=
            jsonEncode(_occOrdered(projection.cancellationVersion.toJson())) ||
        layer['requiredAfterSequence'] != projection.requiredAfterSequence ||
        state['expectedNativeDigest'] != expected ||
        layer['binding'] != _occCancellationBinding(link, layer, expected)) {
      throw StateError('Invalid cancellation projection binding');
    }
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
      CalendarInvitationOperation.readRangeApplication,
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
