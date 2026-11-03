part of 'calendar_module.dart';

String _occRestoredTargetsDigest(
  CalendarInvitationLinkRecord link,
  Map<String, dynamic> state,
) => _invitationHash([
  state['version'] == 11
      ? 'restored-target-composition-v11'
      : 'restored-target-composition-v10',
  link.scopeKey,
  link.recipientKey,
  link.id.toString(),
  link.calendarId.toString(),
  link.eventId.toString(),
  link.uid,
  link.organizer,
  jsonEncode(_occOrdered(state['frozenRestoration'])),
  state['masterKind'] as String,
  state['masterDigest'] as String,
  state['masterBaselineDigest'] as String,
  state['baselineDigest'] as String,
  state['expectedNativeDigest'] as String,
  jsonEncode(_occOrdered(state['targets'])),
]);

String _occRestoredTargetsReceipt(Map<String, dynamic> state) =>
    _invitationHash([
      state['version'] == 11
          ? 'restored-target-receipt-v11'
          : 'restored-target-receipt-v10',
      state['compositionDigest'] as String,
      state['latestTargetKey'] as String,
      state['requestDigest'] as String,
      jsonEncode(_occOrdered(state['receipt'])),
      _occLatestTarget(state)['digest'] as String,
    ]);

int _occRestoredRangeFloor(
  _OccurrenceAccepted accepted,
  Map<String, dynamic> state,
  CalendarEventTiming original,
) {
  final effective = _occFloor(accepted, original).sequence ?? 0;
  final historical =
      CalendarEventProtocolVersion.fromJson(
        (state['restoration'] as Map)['version'],
      ).sequence ??
      0;
  return effective > historical ? effective : historical;
}

extension CalendarInvitationRestorationTargets on CalendarService {
  Map<String, dynamic> _occRestoredTargetsState({
    required CalendarInvitationLinkRecord link,
    required _Event event,
    required CalendarInvitationOccurrenceApplicationRecord row,
    required Map<String, dynamic> state,
    required CalendarInvitationApplicationRecord? master,
    required CalendarInvitationApplicationRecord? previousMaster,
    required CalendarInvitationSourceKind kind,
    required CalendarEventImportBaseline masterBaseline,
    required CalendarEventImportBaseline baseline,
    required CalendarEventImportMember member,
    required List<Map<String, dynamic>> targets,
    required CalendarInvitationOccurrenceApplyReceipt receipt,
    required String requestDigest,
  }) {
    if (master != null && master.kind != kind) {
      throw ArgumentError('Invalid master kind');
    }
    if ((member.content.status == CalendarEventStatus.cancelled) !=
            (kind == CalendarInvitationSourceKind.meetingCancellation) ||
        targets.length + 1 > 128) {
      throw ArgumentError('Invalid restored targets');
    }
    _occCheckRestoredMember(
      member,
      state,
      allowCancelled: kind == CalendarInvitationSourceKind.meetingCancellation,
    );
    final selected = targets.singleWhere(
      (t) => t['sourceId'] == receipt.sourceId.toString(),
    );
    final latestKey = selected['key'] as String;
    final range = latestKey.startsWith('range-v1:');
    final next = <String, dynamic>{
      'version': state['version'] == 11 || range ? 11 : 10,
      'masterKind': kind.name,
      'frozenRestoration':
          state['frozenRestoration'] ??
          {
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
      'targets': targets,
      'latestTargetKey': latestKey,
      'requestDigest': requestDigest,
      'receipt': receipt.toJson(),
    };
    next['compositionDigest'] = _occRestoredTargetsDigest(link, next);
    next['receiptDigest'] = _occRestoredTargetsReceipt(next);
    return next;
  }

  Map<String, dynamic> _occDecodeRestoredTargets(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    CalendarInvitationApplicationRecord? master,
    Map<String, dynamic> state,
  ) {
    const keys = {
      'version',
      'masterKind',
      'frozenRestoration',
      'masterBaseline',
      'masterBaselineDigest',
      'masterDigest',
      'baselineDigest',
      'expectedNativeDigest',
      'targets',
      'latestTargetKey',
      'requestDigest',
      'receipt',
      'compositionDigest',
      'receiptDigest',
    };
    if (state.keys.toSet().difference(keys).isNotEmpty ||
        keys.difference(state.keys.toSet()).isNotEmpty ||
        state['masterKind'] !=
            (master?.kind ?? CalendarInvitationSourceKind.request).name ||
        !{
          CalendarInvitationSourceKind.request,
          CalendarInvitationSourceKind.meetingCancellation,
        }.contains(master?.kind ?? CalendarInvitationSourceKind.request) ||
        (state['targets'] as List).isEmpty ||
        (state['targets'] as List).length + 1 > 128 ||
        state['version'] == 10 &&
            (state['latestTargetKey'] as String).startsWith('range-v1:')) {
      throw StateError('Invalid restored targets');
    }
    final history = _occFrozenRestoration(link, event, row, state);
    if (state['version'] == 11) {
      final historicalFloor =
          CalendarEventProtocolVersion.fromJson(
            (history.state['restoration'] as Map)['version'],
          ).sequence ??
          0;
      final historicalTargets = (history.state['targets'] as List)
          .cast<Map<String, dynamic>>();
      for (final target
          in (state['targets'] as List).cast<Map<String, dynamic>>()) {
        final range = (target['key'] as String).startsWith('range-v1:');
        final inherited = historicalTargets.any(
          (old) =>
              jsonEncode(_occOrdered(old)) == jsonEncode(_occOrdered(target)),
        );
        if (range && !inherited) {
          final floor = target['requiredAfterSequence'];
          final version = CalendarEventProtocolVersion.fromJson(
            target['version'],
          );
          if (floor is! int ||
              floor < historicalFloor ||
              floor < 0 ||
              floor > 2147483647 ||
              version.sequence == null ||
              version.sequence! <= floor) {
            throw StateError('Invalid restored range floor');
          }
        } else if (target.containsKey('requiredAfterSequence')) {
          throw StateError('Unexpected range floor');
        }
      }
    }
    final masterBaseline = CalendarEventImportBaseline.fromJson(
      state['masterBaseline'],
    );
    validateEventImportBaseline(masterBaseline, link.uid);
    _invValidateMasterCheckpoint(link, event, master, masterBaseline);
    // Reuse strict canonical target/source/component and composition validation.
    // Only the receipt namespace differs; the persisted v10 binding is checked separately.
    final legacy = <String, dynamic>{
      'version': 3,
      for (final key in [
        'masterBaseline',
        'masterBaselineDigest',
        'masterDigest',
        'baselineDigest',
        'targets',
        'latestTargetKey',
        'requestDigest',
        'receipt',
      ])
        key: state[key],
    };
    legacy['receiptDigest'] = _occReceiptDigest(legacy);
    _occDecode(
      link,
      event,
      row.copyWith(stateJson: jsonEncode(legacy)),
      master,
    );
    final accepted = _occAccepted(event.data.importBaseline!);
    final cancelled =
        master?.kind == CalendarInvitationSourceKind.meetingCancellation;
    if ((accepted.content.status == CalendarEventStatus.cancelled) !=
        cancelled) {
      throw StateError('Invalid restored lifecycle');
    }
    _occCheckRestoredMember(
      CalendarEventImportMember(
        eventId: link.eventId,
        protocolUid: link.uid,
        content: accepted.content,
        timingOverrides: accepted.edits,
        protocolState: accepted.protocol,
      ),
      history.state,
      allowCancelled: cancelled,
    );
    if (_occNativeDigest(link.uid, accepted) != state['expectedNativeDigest'] ||
        _occRestoredTargetsDigest(link, state) != state['compositionDigest'] ||
        _occRestoredTargetsReceipt(state) != state['receiptDigest']) {
      throw StateError('Invalid restored target binding');
    }
    return {...history.state, ...state};
  }
}
