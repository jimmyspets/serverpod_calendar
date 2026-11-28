part of 'calendar_module.dart';

extension CalendarInvitationRestorationComposition on CalendarService {
  void _occCheckRestoredMember(
    CalendarEventImportMember member,
    Map<String, dynamic> state, {
    bool allowCancelled = false,
  }) {
    if (_occCycles(state)) {
      _cycleCheckAnchors(member, state);
      if (member.content.status == CalendarEventStatus.cancelled &&
          !allowCancelled) {
        throw ArgumentError('Inactive composition');
      }
      return;
    }
    if (member.content.status == CalendarEventStatus.cancelled &&
            !allowCancelled ||
        member.timingOverrides?.cancelledFrom != null ||
        !eventSchedulingMember(
          member.content,
          CalendarEventTiming.fromJson(
            (state['restoration'] as Map)['original'],
          ),
          sharedWorkBudget: RecurrenceWorkBudget(
            maxWork: eventMaxCandidateWork,
          ),
        )) {
      throw ArgumentError('Unsupported restored composition');
    }
  }

  String _occRestoredCompositionDigest(
    CalendarInvitationLinkRecord link,
    Map<String, dynamic> state,
  ) => _invitationHash([
    state['version'] == 9 ? 'restored-lifecycle-v9' : 'restored-composition-v8',
    if (state['version'] == 9) state['masterKind'] as String,
    link.scopeKey,
    link.recipientKey,
    link.id.toString(),
    link.calendarId.toString(),
    link.eventId.toString(),
    link.uid,
    link.organizer,
    jsonEncode(_occOrdered(state['frozenRestoration'])),
    state['masterDigest'] as String,
    state['masterBaselineDigest'] as String,
    state['baselineDigest'] as String,
    state['expectedNativeDigest'] as String,
  ]);

  Map<String, dynamic> _occComposeRestoration({
    required CalendarInvitationLinkRecord link,
    required _Event event,
    required CalendarInvitationOccurrenceApplicationRecord row,
    required Map<String, dynamic> state,
    required CalendarInvitationApplicationRecord? previousMaster,
    required CalendarInvitationApplicationRecord? master,
    required CalendarEventImportBaseline masterBaseline,
    required CalendarEventImportBaseline baseline,
    required CalendarEventImportMember member,
    required CalendarInvitationSourceKind kind,
    Map<String, dynamic>? masterSource,
  }) {
    if (_occCycles(state)) {
      return _cycleCompose(
        link: link,
        event: event,
        state: state,
        master: master,
        masterBaseline: masterBaseline,
        baseline: baseline,
        member: member,
        kind: kind,
        masterSource: masterSource!,
      );
    }
    if ({10, 11}.contains(state['version'])) {
      return _occRestoredTargetsState(
        link: link,
        event: event,
        row: row,
        state: state,
        master: master,
        previousMaster: previousMaster,
        kind: kind,
        masterBaseline: masterBaseline,
        baseline: baseline,
        member: member,
        targets: (state['targets'] as List).cast<Map<String, dynamic>>(),
        receipt: CalendarInvitationOccurrenceApplyReceipt.fromJson(
          state['receipt'],
        ),
        requestDigest: state['requestDigest'] as String,
      );
    }
    final cancelled = kind == CalendarInvitationSourceKind.meetingCancellation;
    if ((member.content.status == CalendarEventStatus.cancelled) != cancelled) {
      throw ArgumentError('Invalid restored lifecycle');
    }
    _occCheckRestoredMember(member, state, allowCancelled: cancelled);
    final lifecycle =
        cancelled ||
        previousMaster?.kind ==
            CalendarInvitationSourceKind.meetingCancellation ||
        state['version'] == 9;
    final next = <String, dynamic>{
      'version': lifecycle ? 9 : 8,
      if (lifecycle) 'masterKind': kind.name,
      'frozenRestoration': {8, 9}.contains(state['version'])
          ? state['frozenRestoration']
          : {
              'baseline': event.data.importBaseline!.toJson(),
              'master': previousMaster?.toJson(),
              'checkpoint': {
                'revision': row.revision,
                'eventRevision': row.eventRevision,
                'updatedAt': row.updatedAt.toIso8601String(),
                'state': jsonDecode(row.stateJson),
              },
            },
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
    next['compositionDigest'] = _occRestoredCompositionDigest(link, next);
    next['receiptDigest'] = _occRestorationReceiptDigest({...state, ...next});
    return next;
  }

  ({_Event event, Map<String, dynamic> state}) _occFrozenRestoration(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    Map<String, dynamic> state, {
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    final frozen = state['frozenRestoration'] as Map<String, dynamic>;
    final descriptor = frozen['checkpoint'] as Map<String, dynamic>;
    final original = descriptor['state'] as Map<String, dynamic>;
    final baseline = CalendarEventImportBaseline.fromJson(frozen['baseline']);
    validateEventImportBaseline(
      baseline,
      link.uid,
      sharedWorkBudget: sharedWorkBudget,
    );
    final recordedMaster = frozen['master'] == null
        ? null
        : CalendarInvitationApplicationRecord.fromJson(frozen['master']);
    if (original['version'] != 7 ||
        original.containsKey('frozenRestoration') ||
        descriptor['revision'] is! int ||
        (descriptor['revision'] as int) >= row.revision ||
        descriptor['eventRevision'] is! int ||
        (descriptor['eventRevision'] as int) >= row.eventRevision ||
        DateTime.parse(descriptor['updatedAt']).isAfter(row.updatedAt)) {
      throw StateError('Invalid restored composition');
    }
    final historical = _occAccepted(baseline);
    final historicalEvent = _Event(
      event.identity.copyWith(revision: descriptor['eventRevision'] as int),
      event.data.copyWith(
        content: historical.content,
        timingOverrides: historical.edits,
        protocolState: historical.protocol,
        importBaseline: baseline,
      ),
      event.parent,
    );
    final accepted = _occDecode(
      link,
      historicalEvent,
      row.copyWith(
        revision: descriptor['revision'] as int,
        eventRevision: descriptor['eventRevision'] as int,
        updatedAt: DateTime.parse(descriptor['updatedAt']),
        stateJson: jsonEncode(original),
      ),
      recordedMaster,
      sharedWorkBudget: sharedWorkBudget,
    );
    _invValidateMasterCheckpoint(
      link,
      historicalEvent,
      recordedMaster,
      CalendarEventImportBaseline.fromJson(accepted['masterBaseline']),
    );
    return (event: historicalEvent, state: accepted);
  }

  Map<String, dynamic> _occDecodeRestorationComposition(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    CalendarInvitationApplicationRecord? master,
    Map<String, dynamic> state,
  ) {
    if (state.containsKey('targets') ||
        state.containsKey('restoration') ||
        state.containsKey('receipt') ||
        state.containsKey('preRestoration') ||
        master == null ||
        !{
          CalendarInvitationSourceKind.request,
          CalendarInvitationSourceKind.meetingCancellation,
        }.contains(master.kind) ||
        state['version'] == 8 &&
            (master.kind != CalendarInvitationSourceKind.request ||
                state.containsKey('masterKind')) ||
        state['version'] == 9 && state['masterKind'] != master.kind.name ||
        state['masterDigest'] != _occMasterDigest(link, master) ||
        state['baselineDigest'] !=
            _invBaselineDigest(event.data.importBaseline!)) {
      throw StateError('Invalid restored composition');
    }
    final replay = _occFrozenRestoration(link, event, row, state);
    final historicalEvent = replay.event, accepted = replay.state;
    final currentMaster = CalendarEventImportBaseline.fromJson(
      state['masterBaseline'],
    );
    validateEventImportBaseline(currentMaster, link.uid);
    if (_invBaselineDigest(currentMaster) != state['masterBaselineDigest']) {
      throw StateError('Invalid current master');
    }
    _invValidateMasterCheckpoint(link, event, master, currentMaster);
    final current = _occAccepted(currentMaster);
    final composed = _invCompose(
      CalendarEventImportMember(
        eventId: link.eventId,
        protocolUid: link.uid,
        content: current.content,
        timingOverrides: current.edits,
        protocolState: current.protocol,
      ),
      historicalEvent,
      accepted,
    );
    _occCheckRestoredMember(
      composed,
      accepted,
      allowCancelled:
          master.kind == CalendarInvitationSourceKind.meetingCancellation,
    );
    final actual = eventImportBaseline(
      link.uid,
      composed.content,
      composed.timingOverrides,
      composed.protocolState,
    );
    final derived = {...accepted, ...state};
    if (actual.canonicalValue != event.data.importBaseline!.canonicalValue ||
        _occNativeDigest(link.uid, (
              content: composed.content,
              edits: composed.timingOverrides,
              protocol: composed.protocolState,
            )) !=
            state['expectedNativeDigest'] ||
        _occRestoredCompositionDigest(link, state) !=
            state['compositionDigest'] ||
        _occRestorationReceiptDigest(derived) != state['receiptDigest']) {
      throw StateError('Invalid restored composition binding');
    }
    return derived;
  }
}
