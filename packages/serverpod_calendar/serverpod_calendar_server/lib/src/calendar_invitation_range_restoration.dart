part of 'calendar_module.dart';

bool _occHasRangeRestoration(Map<String, dynamic>? state) =>
    {7, 8, 9, 10, 11}.contains(state?['version']);

String _occRestorationReceiptDigest(Map<String, dynamic> state) =>
    _invitationHash([
      state['version'] == 9
          ? 'restored-receipt-v9'
          : state['version'] == 8
          ? 'restored-receipt-v8'
          : 'range-restore-receipt-v7',
      if ({8, 9}.contains(state['version']))
        state['compositionDigest'] as String,
      state['requestDigest'] as String,
      jsonEncode(_occOrdered(state['receipt'])),
      (state['restoration'] as Map)['binding'] as String,
    ]);

extension CalendarInvitationRangeRestorationOperations on CalendarService {
  String _occRestorationBinding(
    CalendarInvitationLinkRecord link,
    Map<String, dynamic> state,
  ) => _invitationHash([
    'range-restore-evidence-v7',
    link.scopeKey,
    link.recipientKey,
    link.id.toString(),
    link.calendarId.toString(),
    link.eventId.toString(),
    link.uid,
    link.organizer,
    jsonEncode(_occOrdered(state['preRestoration'])),
    jsonEncode(
      _occOrdered(
        Map<String, dynamic>.of(state['restoration'])..remove('binding'),
      ),
    ),
    state['masterDigest'] as String,
    state['baselineDigest'] as String,
    state['expectedNativeDigest'] as String,
  ]);

  CalendarInvitationRangeRestorationProjection _occRestorationCandidate(
    CalendarInvitationLinkRecord link,
    _Event event,
    Map<String, dynamic> state,
    IcalendarSchedulingMessage message,
    String address,
  ) {
    final accepted = _occAccepted(event.data.importBaseline!);
    final member = _occMaskMember(
      CalendarEventImportMember(
        eventId: link.eventId,
        protocolUid: link.uid,
        content: accepted.content,
        timingOverrides: accepted.edits,
        protocolState: accepted.protocol,
      ),
      state,
    );
    return projectInvitationRangeRestoration(
      protocolUid: link.uid,
      content: member.content,
      timingOverrides: member.timingOverrides,
      protocolState: member.protocolState,
      cancellationVersion: CalendarEventProtocolVersion.fromJson(
        (state['rangeCancellation'] as Map)['version'],
      ),
      message: message,
      recipientAddress: address,
    );
  }

  Map<String, dynamic> _occRestorationState({
    required CalendarInvitationLinkRecord link,
    required _Event event,
    required CalendarInvitationOccurrenceApplicationRecord row,
    required CalendarInvitationRecord entry,
    required CalendarInvitationSourceRecord source,
    required CalendarInvitationRecipient recipient,
    required CalendarInvitationRangeRestorationProjection projection,
    required CalendarInvitationOccurrenceApplyReceipt receipt,
    required String requestDigest,
  }) {
    final previous = jsonDecode(row.stateJson) as Map<String, dynamic>;
    final next = <String, dynamic>{
      'version': 7,
      'preRestoration': {
        'revision': row.revision,
        'eventRevision': row.eventRevision,
        'updatedAt': row.updatedAt.toIso8601String(),
        'state': previous,
      },
      'masterDigest': previous['masterDigest'],
      'baselineDigest': _invBaselineDigest(event.data.importBaseline!),
      'expectedNativeDigest': _occNativeDigest(link.uid, (
        content: projection.content,
        edits: projection.timingOverrides,
        protocol: projection.protocolState,
      )),
      'latestLayer': 'rangeRestoration',
      'latestTargetKey': entry.targetKey,
      'restoration': {
        'key': entry.targetKey,
        'original': projection.originalStart.toJson(),
        'kind': CalendarInvitationSourceKind.request.name,
        'invitationId': entry.id.toString(),
        'sourceId': source.id.toString(),
        'source': source.normalizedSource,
        'digest': source.digest,
        'recipientAddress': recipient.calendarAddress,
        'version': projection.restorationVersion.toJson(),
        'requiredAfterSequence': projection.requiredAfterSequence,
        'acceptedAt': receipt.appliedAt.toIso8601String(),
      },
      'requestDigest': requestDigest,
      'receipt': receipt.toJson(),
    };
    (next['restoration'] as Map)['binding'] = _occRestorationBinding(
      link,
      next,
    );
    next['receiptDigest'] = _occRestorationReceiptDigest(next);
    return next;
  }

  Map<String, dynamic> _occDecodeRestoration(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    CalendarInvitationApplicationRecord? master,
    Map<String, dynamic> state,
  ) {
    final descriptor = state['preRestoration'] as Map<String, dynamic>;
    final previous = descriptor['state'] as Map<String, dynamic>;
    final priorRevision = descriptor['revision'] as int;
    final priorEventRevision = descriptor['eventRevision'] as int;
    final priorTime = DateTime.parse(descriptor['updatedAt']);
    if (!{4, 5, 6}.contains(previous['version']) ||
        previous.containsKey('preRestoration') ||
        previous.containsKey('restoration') ||
        priorRevision + 1 != row.revision ||
        priorEventRevision >= row.eventRevision ||
        priorTime.isAfter(row.updatedAt) ||
        state['masterDigest'] != _occMasterDigest(link, master) ||
        state['baselineDigest'] !=
            _invBaselineDigest(event.data.importBaseline!) ||
        master?.kind == CalendarInvitationSourceKind.meetingCancellation) {
      throw StateError('Invalid restoration predecessor');
    }
    final prior = _occDecode(
      link,
      event,
      row.copyWith(
        revision: priorRevision,
        eventRevision: priorEventRevision,
        updatedAt: priorTime,
        stateJson: jsonEncode(previous),
      ),
      master,
    );
    final layer = state['restoration'] as Map<String, dynamic>;
    final text = layer['source'] as String;
    final receipt = CalendarInvitationOccurrenceApplyReceipt.fromJson(
      state['receipt'],
    );
    if (utf8.encode(text).length > 262144 ||
        sha256.convert(utf8.encode(text)).toString() != layer['digest'] ||
        state['latestLayer'] != 'rangeRestoration' ||
        state['latestTargetKey'] != layer['key'] ||
        layer['kind'] != CalendarInvitationSourceKind.request.name ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(state['requestDigest'] as String)) {
      throw StateError('Invalid restoration evidence');
    }
    final projection = _occRestorationCandidate(
      link,
      event,
      prior,
      _invParse(utf8.encode(text), stored: true),
      layer['recipientAddress'] as String,
    );
    final native = _occNativeDigest(link.uid, (
      content: projection.content,
      edits: projection.timingOverrides,
      protocol: projection.protocolState,
    ));
    if (jsonEncode(_occOrdered(projection.originalStart.toJson())) !=
            jsonEncode(_occOrdered(layer['original'])) ||
        jsonEncode(_occOrdered(projection.restorationVersion.toJson())) !=
            jsonEncode(_occOrdered(layer['version'])) ||
        projection.requiredAfterSequence != layer['requiredAfterSequence'] ||
        native != state['expectedNativeDigest'] ||
        layer['binding'] != _occRestorationBinding(link, state) ||
        state['receiptDigest'] != _occRestorationReceiptDigest(state) ||
        layer['key'] != _invTargetKey(projection.originalStart, range: true) ||
        receipt.linkId != link.id ||
        receipt.calendarId != link.calendarId ||
        receipt.eventId != link.eventId ||
        receipt.kind != CalendarInvitationSourceKind.request ||
        receipt.invitationId.toString() != layer['invitationId'] ||
        receipt.sourceId.toString() != layer['sourceId'] ||
        !_replySamePoint(receipt.originalStart, projection.originalStart) ||
        receipt.appliedAt != row.updatedAt ||
        receipt.appliedAt != DateTime.parse(layer['acceptedAt']) ||
        receipt.eventRevision != row.eventRevision ||
        receipt.occurrenceRevision != row.revision) {
      throw StateError('Invalid restoration projection binding');
    }
    // Derived legacy fields are never persisted twice in the v7 envelope.
    return {...prior, ...state};
  }
}
