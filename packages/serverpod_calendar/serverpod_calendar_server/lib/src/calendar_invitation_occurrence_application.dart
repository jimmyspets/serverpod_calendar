part of 'calendar_module.dart';

typedef _OccurrenceAccepted = ({
  CalendarEventContent content,
  CalendarEventTimingOverrides? edits,
  CalendarEventProtocolState protocol,
});

String _occCommandDigest(
  CalendarInvitationOccurrenceApplyRequest input,
  CalendarInvitationOperation operation, {
  required bool range,
  required bool cancellation,
  required bool restoration,
}) => _invitationHash([
  restoration
      ? 'range-restore-apply-v7'
      : range
      ? (cancellation ? 'range-cancel-apply-v4' : 'range-apply-v3')
      : 'occurrence-apply-v1',
  operation.name,
  jsonEncode(input.toJson()),
]);

String _occLatestKey(
  Map<String, dynamic> state,
  CalendarInvitationOccurrenceApplyReceipt receipt,
) => {3, 4, 5, 6, 7, 8, 9, 10, 11, 12}.contains(state['version'])
    ? state['latestTargetKey'] as String
    : _invTargetKey(receipt.originalStart);

String _occReceiptDigest(Map<String, dynamic> state) {
  final receipt = CalendarInvitationOccurrenceApplyReceipt.fromJson(
    state['receipt'],
  );
  final key = _occLatestKey(state, receipt);
  if (_occCycles(state)) return _cycleReceiptDigest(state);
  if ({10, 11}.contains(state['version'])) {
    return _occRestoredTargetsReceipt(state);
  }
  if (_occHasRangeRestoration(state)) {
    return _occRestorationReceiptDigest(state);
  }
  if (_occHasRangeCancellation(state)) {
    return _invitationHash([
      state['version'] == 6
          ? 'range-cancel-receipt-v6'
          : state['version'] == 5
          ? 'range-cancel-receipt-v5'
          : 'range-cancel-receipt-v4',
      if ({5, 6}.contains(state['version']))
        state['compositionDigest'] as String,
      key,
      state['requestDigest'] as String,
      jsonEncode(_occOrdered(receipt.toJson())),
      _occLatestTarget(state)['binding'] as String,
      state['expectedNativeDigest'] as String,
    ]);
  }
  final target = (state['targets'] as List).singleWhere((v) => v['key'] == key);
  return _invitationHash([
    if (state['version'] == 3) key,
    state['requestDigest'] as String,
    jsonEncode(_occOrdered(receipt.toJson())),
    target['digest'] as String,
  ]);
}

_OccurrenceAccepted _occAccepted(CalendarEventImportBaseline baseline) {
  final value = jsonDecode(baseline.canonicalValue) as Map<String, dynamic>;
  // Canonical baselines omit empty participant parameter maps.
  void restore(Object? node) {
    if (node is Map) {
      final metadata = node['sourceMetadata'];
      if (metadata is Map) {
        final participants = [
          metadata['organizer'],
          ...?metadata['attendees'] as List?,
        ];
        for (final p in participants) {
          if (p is Map) {
            p.putIfAbsent('parameters', () => <String, dynamic>{});
          }
        }
      }
      for (final child in node.values) {
        restore(child);
      }
    } else if (node is List) {
      for (final child in node) {
        restore(child);
      }
    }
  }

  restore(value);
  return (
    content: CalendarEventContent.fromJson(value['content']),
    edits: value['edits'] == null
        ? null
        : CalendarEventTimingOverrides.fromJson(value['edits']),
    protocol: CalendarEventProtocolState.fromJson(value['protocol']),
  );
}

Object? _occOrdered(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _occOrdered(value[key])};
  }
  if (value is List) {
    return value.map(_occOrdered).toList();
  }
  return value;
}

String _occComponent(
  _OccurrenceAccepted accepted,
  CalendarEventTiming original,
  String sourceDigest, {
  bool range = false,
}) {
  final key = eventComponentKey(original, false);
  final edit = range
      ? accepted.edits?.future
            .where((v) => eventComponentKey(v.originalStart, false) == key)
            .firstOrNull
      : accepted.edits?.singles
            .where((v) => eventComponentKey(v.originalStart, false) == key)
            .firstOrNull;
  final version = accepted.protocol.overrides
      .where(
        (v) =>
            v.isThisAndFuture == range &&
            eventComponentKey(v.originalStart, false) == key,
      )
      .firstOrNull;
  return _invitationHash([
    if (range) 'range-component-v3',
    sourceDigest,
    jsonEncode(
      _occOrdered(
        range
            ? (edit as CalendarEventFutureOverride?)?.toJson()
            : (edit as CalendarEventSingleOverride?)?.toJson(),
      ),
    ),
    jsonEncode(_occOrdered(version?.toJson())),
  ]);
}

CalendarEventProtocolVersion _occFloor(
  _OccurrenceAccepted accepted,
  CalendarEventTiming original,
) {
  final single = accepted.protocol.overrides
      .where(
        (v) => !v.isThisAndFuture && _replySamePoint(v.originalStart, original),
      )
      .firstOrNull;
  if (single != null) return single.version;
  final ranges =
      accepted.protocol.overrides
          .where(
            (v) =>
                v.isThisAndFuture &&
                _replyPointOrder(v.originalStart)
                        .compareTo(_replyPointOrder(original)) <=
                    0,
          )
          .toList()
        ..sort(
          (a, b) =>
              _replyPointOrder(a.originalStart)
                  .compareTo(_replyPointOrder(b.originalStart)),
        );
  return ranges.lastOrNull?.version ?? accepted.protocol.version;
}

CalendarEventContent? _occEffective(
  _OccurrenceAccepted accepted,
  CalendarEventTiming original,
) {
  final key = eventComponentKey(original, false);
  final edits = accepted.edits?.copyWith(
    cancelledFrom: null,
    singles: [
      for (final s in accepted.edits!.singles)
        eventComponentKey(s.originalStart, false) == key
            ? s.copyWith(cancelled: false)
            : s,
    ],
  );
  final value = eventSchedulingOccurrence(
    accepted.content,
    edits,
    original,
    sharedWorkBudget: RecurrenceWorkBudget(maxWork: eventMaxCandidateWork),
  );
  final cancelled =
      accepted.edits?.singles.any(
        (s) => s.cancelled && eventComponentKey(s.originalStart, false) == key,
      ) ??
      false;
  return (cancelled || eventFutureCancelled(accepted.edits, original))
      ? value?.copyWith(status: CalendarEventStatus.cancelled)
      : value;
}

extension CalendarInvitationOccurrenceApplicationOperations on CalendarService {
  Future<CalendarInvitationOccurrenceApplicationRecord?> _occRow(
    UuidValue linkId,
    Transaction tx,
  ) => CalendarInvitationOccurrenceApplicationRecord.db.findFirstRow(
    _session,
    where: (t) => t.linkId.equals(linkId),
    transaction: tx,
  );

  String _occMasterDigest(
    CalendarInvitationLinkRecord link,
    CalendarInvitationApplicationRecord? master,
  ) =>
      _invitationHash([_invCreationDigest(link), jsonEncode(master?.toJson())]);

  Map<String, dynamic> _occDecode(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    CalendarInvitationApplicationRecord? master, {
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    try {
      if (row.scopeKey != link.scopeKey ||
          row.recipientKey != link.recipientKey ||
          row.linkId != link.id ||
          row.revision < 1 ||
          row.revision > CalendarService._maxRevision ||
          row.eventRevision < 2 ||
          row.eventRevision > event.identity.revision ||
          utf8.encode(row.stateJson).length > 4194304) {
        throw StateError('Invalid checkpoint');
      }
      final state = jsonDecode(row.stateJson) as Map<String, dynamic>;
      if (_occCycles(state)) {
        return _cycleDecode(link, event, row, master, state);
      }
      if ({10, 11}.contains(state['version'])) {
        return _occDecodeRestoredTargets(link, event, row, master, state);
      }
      if ({8, 9}.contains(state['version'])) {
        return _occDecodeRestorationComposition(
          link,
          event,
          row,
          master,
          state,
        );
      }
      if (_occHasRangeRestoration(state)) {
        return _occDecodeRestoration(
          link,
          event,
          row,
          master,
          state,
          sharedWorkBudget: sharedWorkBudget,
        );
      }
      if (!{1, 2, 3, 4, 5, 6}.contains(state['version']) ||
          state['masterDigest'] != _occMasterDigest(link, master) ||
          state['baselineDigest'] !=
              _invBaselineDigest(event.data.importBaseline!)) {
        throw StateError('Invalid checkpoint binding');
      }
      final frozen = CalendarEventImportBaseline.fromJson(
        state['masterBaseline'],
      );
      validateEventImportBaseline(
        frozen,
        link.uid,
        sharedWorkBudget: sharedWorkBudget,
      );
      if (state['masterBaselineDigest'] != _invBaselineDigest(frozen)) {
        throw StateError('Invalid frozen baseline');
      }
      final targets = (state['targets'] as List).cast<Map<String, dynamic>>();
      if ((targets.isEmpty && !_occHasRangeCancellation(state)) ||
          targets.length + (_occHasRangeCancellation(state) ? 1 : 0) > 128) {
        throw StateError('Invalid targets');
      }
      final accepted = _occAccepted(event.data.importBaseline!);
      if (!{3, 4, 5, 6}.contains(state['version']) &&
          targets.any((t) => (t['key'] as String).startsWith('range-v1:'))) {
        throw StateError('Legacy range target');
      }
      _occValidateTargets(
        link,
        accepted,
        targets,
        row.updatedAt,
        work: sharedWorkBudget,
      );
      final receipt = CalendarInvitationOccurrenceApplyReceipt.fromJson(
        state['receipt'],
      );
      if (_occHasRangeCancellation(state)) {
        _occValidateCancellation(
          link,
          event,
          row,
          state,
          sharedWorkBudget: sharedWorkBudget,
        );
      }
      final latestKey = _occLatestKey(state, receipt);
      final selected = _occLatestTarget(state);
      if (state['version'] == 6 &&
          (master == null ||
              !{
                CalendarInvitationSourceKind.request,
                CalendarInvitationSourceKind.meetingCancellation,
              }.contains(master.kind) ||
              (accepted.content.status == CalendarEventStatus.cancelled) !=
                  (master.kind ==
                      CalendarInvitationSourceKind.meetingCancellation))) {
        throw StateError('Invalid lifecycle kind/status');
      }
      if ({5, 6}.contains(state['version']) &&
          (master == null ||
              state['version'] == 5 &&
                  master.kind != CalendarInvitationSourceKind.request ||
              receipt.occurrenceRevision >= row.revision ||
              receipt.eventRevision >= row.eventRevision)) {
        throw StateError('Invalid composed cancellation history');
      }
      if (receipt.linkId != link.id ||
          receipt.calendarId != link.calendarId ||
          receipt.eventId != link.eventId ||
          receipt.occurrenceRevision < 1 ||
          receipt.occurrenceRevision > row.revision ||
          receipt.eventRevision < 2 ||
          receipt.eventRevision > row.eventRevision ||
          receipt.appliedAt != DateTime.parse(selected['acceptedAt']) ||
          ({1, 4}.contains(state['version']) &&
              (receipt.occurrenceRevision != row.revision ||
                  receipt.eventRevision != row.eventRevision ||
                  receipt.appliedAt != row.updatedAt)) ||
          receipt.invitationId.toString() != selected['invitationId'] ||
          receipt.sourceId.toString() != selected['sourceId'] ||
          receipt.kind.name != selected['kind'] ||
          selected['key'] !=
              _invTargetKey(
                receipt.originalStart,
                range: latestKey.startsWith('range-v1:'),
              ) ||
          !RegExp(r'^[0-9a-f]{64}$')
              .hasMatch(state['requestDigest'] as String)) {
        throw StateError('Invalid result');
      }
      if ({2, 3, 4, 5, 6}.contains(state['version'])) {
        if (state['receiptDigest'] != _occReceiptDigest(state)) {
          throw StateError('Invalid retained result binding');
        }
        final layer = _occAccepted(frozen);
        final composed = _invCompose(
          CalendarEventImportMember(
            eventId: link.eventId,
            protocolUid: link.uid,
            content: layer.content,
            timingOverrides: layer.edits,
            protocolState: layer.protocol,
          ),
          event,
          state,
          sharedWorkBudget: sharedWorkBudget,
        );
        if (eventImportBaseline(
              link.uid,
              composed.content,
              composed.timingOverrides,
              composed.protocolState,
              sharedWorkBudget: sharedWorkBudget,
            ).canonicalValue !=
            event.data.importBaseline!.canonicalValue) {
          throw StateError('Invalid composition');
        }
      }
      return state;
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  void _occValidateTargets(
    CalendarInvitationLinkRecord link,
    _OccurrenceAccepted accepted,
    List<Map<String, dynamic>> targets,
    DateTime updatedAt, {
    RecurrenceWorkBudget? work,
  }) {
    final seen = <String>{};
    for (final target in targets) {
      work?.charge();
      if (target['reopened'] is! bool) {
        throw StateError('Invalid lifecycle evidence');
      }
      final original = CalendarEventTiming.fromJson(target['original']);
      final range = (target['key'] as String).startsWith('range-v1:');

      final key = _invTargetKey(original, range: range);
      final text = target['source'] as String;
      if (!seen.add(_invTargetKey(original)) ||
          key != target['key'] ||
          utf8.encode(text).length > 262144 ||
          sha256.convert(utf8.encode(text)).toString() != target['digest'] ||
          _occComponent(
                accepted,
                original,
                target['digest'] as String,
                range: range,
              ) !=
              target['component']) {
        throw StateError('Invalid target');
      }
      final message = _invParse(utf8.encode(text), stored: true);
      final source = message.events.single;
      final version = CalendarEventProtocolVersion.fromJson(
        target['version'],
      );
      validateEventProtocolVersion(version);
      final single = accepted.edits?.singles
          .where((v) => _replySamePoint(v.originalStart, original))
          .firstOrNull;
      final future = accepted.edits?.future
          .where((v) => _replySamePoint(v.originalStart, original))
          .firstOrNull;
      if (source.isThisAndFuture != range ||
          range &&
              (future == null ||
                  single != null ||
                  message.method != IcalendarSchedulingMethod.request ||
                  target['reopened'] != false) ||
          message.uid != link.uid ||
          source.participants.organizer?.address != link.organizer ||
          !source.participants.attendees.any(
            (a) => a.address == target['recipientAddress'],
          ) ||
          !_replySamePoint(_replyOriginal(source), original) ||
          _invKind(message).name != target['kind'] ||
          source.sequence != version.sequence ||
          source.stamp != version.stamp ||
          source.created != version.created ||
          source.lastModified != version.lastModified ||
          jsonEncode(_occFloor(accepted, original).toJson()) !=
              jsonEncode(version.toJson()) ||
          !range &&
              (single == null ||
                  single.cancelled !=
                      (message.method == IcalendarSchedulingMethod.cancel))) {
        throw StateError('Invalid accepted component');
      }
      UuidValue.fromString(target['invitationId']);
      UuidValue.fromString(target['sourceId']);
      final time = DateTime.parse(target['acceptedAt']);
      if (time.isAfter(updatedAt)) {
        throw StateError('Invalid acceptance time');
      }
    }
  }

  CalendarInvitationOccurrenceApplicationSnapshot? _occSnapshot(
    CalendarInvitationOccurrenceApplicationRecord? row,
  ) => row == null
      ? null
      : CalendarInvitationOccurrenceApplicationSnapshot(
          revision: row.revision,
          stateJson: row.stateJson,
          eventRevision: row.eventRevision,
          updatedAt: row.updatedAt,
        );

  Future<CalendarInvitationLinkRecord?> _occLink(
    CalendarInvitationRecord? entry,
    CalendarInvitationRecipient recipient,
    Transaction tx, {
    UuidValue? retainedLink,
    bool range = false,
  }) async {
    if (entry != null) {
      _invTargetValid(entry);
      if (entry.targetKey == 'master' || _invRange(entry) != range) {
        throw _failure(CalendarFailureCode.validation);
      }
    }
    final candidate = entry == null
        ? retainedLink == null
              ? null
              : await CalendarInvitationLinkRecord.db.findById(
                  _session,
                  retainedLink,
                  transaction: tx,
                )
        : await CalendarInvitationLinkRecord.db.findFirstRow(
            _session,
            where: (t) =>
                t.scopeKey.equals(recipient.scopeKey) &
                t.recipientKey.equals(recipient.key) &
                t.correlationDigest.equals(entry.correlationDigest),
            transaction: tx,
          );
    if (candidate == null ||
        candidate.scopeKey != recipient.scopeKey ||
        candidate.recipientKey != recipient.key) {
      return null;
    }
    final link = await _invFindLink(
      candidate.invitationId,
      null,
      recipient,
      tx,
    );
    if (entry != null &&
        (entry.uid != link?.uid || entry.organizer != link?.organizer)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return link;
  }

  Future<void> _occHost(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    required CalendarInvitationOperation operation,
    CalendarInvitationView? view,
    CalendarInvitationLinkRecord? link,
    _Event? event,
    CalendarEventPolicySnapshot? before,
    CalendarEventPolicySnapshot? proposed,
    IcalendarSchedulingMessage? message,
    String? text,
    CalendarInvitationApplicationState? master,
    CalendarInvitationOccurrenceApplicationRecord? current,
    CalendarInvitationOccurrenceApplicationRecord? next,
    CalendarInvitationOccurrenceApplyRequest? request,
    CalendarInvitationOccurrenceApplyReceipt? receipt,
    CalendarEventImportBaseline? baseline,
    bool? dirty,
    bool? historicalUnavailable,
    bool retry = false,
  }) async {
    for (final op in {
      CalendarInvitationOperation.readSummary,
      CalendarInvitationOperation.readSource,
      CalendarInvitationOperation.readLink,
      CalendarInvitationOperation.readApplication,
      operation == CalendarInvitationOperation.readRangeApplication ||
              operation == CalendarInvitationOperation.applyRangeUpdate ||
              operation == CalendarInvitationOperation.applyRangeCancellation ||
              operation == CalendarInvitationOperation.applyRangeRestoration ||
              operation ==
                  CalendarInvitationOperation.readRangeRestorationApplication
          ? CalendarInvitationOperation.readRangeApplication
          : CalendarInvitationOperation.readOccurrenceApplication,
      if (operation == CalendarInvitationOperation.applyRangeRestoration ||
          operation ==
              CalendarInvitationOperation.readRangeRestorationApplication) ...{
        CalendarInvitationOperation.readRangeRestorationApplication,
        CalendarInvitationOperation.composeAcceptedOccurrences,
        CalendarInvitationOperation.composeAcceptedRangeCancellation,
      },
      if (current != null &&
          _occHasRangeRestoration(
            jsonDecode(current.stateJson) as Map<String, dynamic>,
          ) &&
          ({
                10,
                11,
                12,
              }.contains((jsonDecode(current.stateJson) as Map)['version']) ||
              {
                CalendarInvitationOperation.readOccurrenceApplication,
                CalendarInvitationOperation.applyOccurrenceUpdate,
                CalendarInvitationOperation.applyOccurrenceCancellation,
                CalendarInvitationOperation.readRangeApplication,
                CalendarInvitationOperation.applyRangeUpdate,
                CalendarInvitationOperation.applyRangeCancellation,
              }.contains(operation))) ...{
        CalendarInvitationOperation.composeAcceptedOccurrences,
        CalendarInvitationOperation.composeAcceptedRangeCancellation,
        CalendarInvitationOperation.composeAcceptedRangeRestoration,
      },
      operation,
    }) {
      await _invAuthorize(
        CalendarInvitationPolicyContext(
          operation: op,
          actor: actor,
          recipient: recipient,
          current: view,
          entryId: request?.invitationId ?? view?.id,
          sourceId: request?.sourceId ?? view?.sourceId,
          message: message,
          normalizedSource: text,
          sourceDigest: text == null
              ? null
              : sha256.convert(utf8.encode(text)).toString(),
          link: link == null ? null : _invLinkReceipt(link),
          linkSource: link == null ? null : _invLinkSource(link),
          calendar: event?.parent.snapshot,
          currentEvent: before ?? event?.snapshot,
          proposedEvent: proposed,
          currentApplication: master,
          currentOccurrenceApplication: _occSnapshot(current),
          proposedOccurrenceApplication: _occSnapshot(next),
          occurrenceRequest: request,
          occurrenceReceipt: receipt,
          proposedBaseline: baseline,
          localChanges: dirty,
          isRetry: retry,
          historicalSourceUnavailable:
              historicalUnavailable ?? (message == null ? null : false),
          proposedDismissed: next == null ? null : true,
          proposedRevision: receipt?.invitationRevision,
        ),
        tx,
        phase,
      );
    }
  }

  Future<void> _occQuota(
    CalendarInvitationRecipient recipient,
    CalendarInvitationOccurrenceApplicationRecord next,
    Transaction tx,
  ) async {
    final size = utf8.encode(next.stateJson).length;
    if (size > _invOptions.maxOccurrenceCheckpointBytes) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final rows = await CalendarInvitationOccurrenceApplicationRecord.db.find(
      _session,
      where: (t) => t.scopeKey.equals(recipient.scopeKey),
      transaction: tx,
    );
    var scopeBytes = size, recipientBytes = size;
    for (final row in rows) {
      if (row.linkId == next.linkId) {
        continue;
      }
      final bytes = utf8.encode(row.stateJson).length;
      scopeBytes += bytes;
      if (row.recipientKey == recipient.key) {
        recipientBytes += bytes;
      }
    }
    if (scopeBytes > _invOptions.maxScopeOccurrenceBytes ||
        recipientBytes > _invOptions.maxRecipientOccurrenceBytes) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
  }

  Future<CalendarInvitationOccurrenceApplicationView>
  invitationOccurrenceApplication(UuidValue id) => _occApplication(id, false);

  Future<CalendarInvitationOccurrenceApplicationView>
  invitationRangeApplication(UuidValue id) => _occApplication(id, true);

  Future<CalendarInvitationOccurrenceApplicationView>
  invitationRangeRestorationApplication(UuidValue id) =>
      _occApplication(id, true, restoration: true);
  Future<CalendarInvitationOccurrenceApplicationView> _occApplication(
    UuidValue id,
    bool range, {
    bool restoration = false,
  }) => _invNativeScoped((
    actor,
    recipient,
    tx,
    scope,
  ) async {
    final entry = await _invEntry(id, recipient, tx);
    final view = await _invView(entry, tx);
    await _occHost(
      actor,
      recipient,
      tx,
      CalendarAuthorizationPhase.read,
      operation: restoration
          ? CalendarInvitationOperation.readRangeRestorationApplication
          : range
          ? CalendarInvitationOperation.readRangeApplication
          : CalendarInvitationOperation.readOccurrenceApplication,
      view: view,
    );
    final link = await _occLink(entry, recipient, tx, range: range);
    if (link == null) throw _failure(CalendarFailureCode.accessDenied);
    final event = await _invLinkedEvent(link, actor, tx);
    await _invApplicationNative(
      actor,
      event,
      tx,
      CalendarAuthorizationPhase.read,
    );
    final masterRow = await _invCheckpoint(link, event, tx);
    final master = await _invApplicationState(link, event, masterRow, tx);
    final row = await _occRow(link.id!, tx);
    final state = row == null ? null : _occDecode(link, event, row, masterRow);
    final accepted = _occAccepted(event.data.importBaseline!);
    final retainedTarget = (state?['targets'] as List?)
        ?.cast<Map<String, dynamic>>()
        .where((v) => v['key'] == entry.targetKey)
        .firstOrNull;
    await _occAuthorizeCancellation(
      actor,
      recipient,
      tx,
      CalendarAuthorizationPhase.read,
      link,
      event,
      row,
      state,
    );
    final cancellationLayer = _occCycles(state)
        ? _cycleViewLayer(state!, entry, restoration)
        : _occHasRangeCancellation(state)
        ? (_occHasRangeRestoration(state)
              ? state!['restoration'] as Map<String, dynamic>
              : _occLatestTarget(state!))
        : null;
    final selectedCancellation =
        cancellationLayer?['invitationId'] == entry.id.toString() &&
        (_occCycles(state) ||
            restoration ||
            state?['version'] != 11 ||
            retainedTarget?['requiredAfterSequence'] == null);
    final target = selectedCancellation ? cancellationLayer : retainedTarget;
    final source = entry.currentSourceId == null
        ? null
        : await CalendarInvitationSourceRecord.db.findById(
            _session,
            entry.currentSourceId!,
            transaction: tx,
          );
    final message = source == null ? null : _invStored(source, entry);
    final dirty = _invLocalChanges(event, occurrenceState: state);
    final floor = selectedCancellation
        ? CalendarEventProtocolVersion.fromJson(target!['version'])
        : _occFloor(accepted, entry.originalStart!);
    _OccurrenceAccepted? projection;
    if (message != null) {
      try {
        if (restoration) {
          if (state == null ||
              !_occHasRangeCancellation(state) ||
              !_occActiveCancellation(state)) {
            throw ArgumentError('Unavailable restoration');
          }
          final p = _occRestorationCandidate(
            link,
            event,
            state,
            message,
            recipient.calendarAddress,
          );
          projection = (
            content: p.content,
            edits: p.timingOverrides,
            protocol: p.protocolState,
          );
          await _invApplicationNative(
            actor,
            event,
            tx,
            CalendarAuthorizationPhase.read,
            writing: true,
            cancellation: true,
            member: CalendarEventImportMember(
              eventId: link.eventId,
              protocolUid: link.uid,
              content: p.content,
              timingOverrides: p.timingOverrides,
              protocolState: p.protocolState,
            ),
          );
          await _occHost(
            actor,
            recipient,
            tx,
            CalendarAuthorizationPhase.read,
            operation: CalendarInvitationOperation.applyRangeRestoration,
            view: view,
            link: link,
            event: event,
            message: message,
            master: master,
            current: row,
          );
        } else if (range &&
            message.method == IcalendarSchedulingMethod.cancel) {
          final p = _occHasRangeRestoration(state)
              ? _cycleCancellationCandidate(
                  link,
                  accepted,
                  state!,
                  message,
                  recipient.calendarAddress,
                )
              : projectInvitationRangeCancellation(
                  protocolUid: link.uid,
                  content: accepted.content,
                  timingOverrides: accepted.edits,
                  protocolState: accepted.protocol,
                  message: message,
                  recipientAddress: recipient.calendarAddress,
                );
          projection = (
            content: p.content,
            edits: p.timingOverrides,
            protocol: p.protocolState,
          );
          if (_occHasRangeRestoration(state)) {
            if (_occActiveCancellation(state) ||
                accepted.content.status == CalendarEventStatus.cancelled) {
              projection = null;
            } else {
              await _invApplicationNative(
                actor,
                event,
                tx,
                CalendarAuthorizationPhase.read,
                writing: true,
                cancellation: true,
                member: CalendarEventImportMember(
                  eventId: link.eventId,
                  protocolUid: link.uid,
                  content: p.content,
                  timingOverrides: p.timingOverrides,
                  protocolState: p.protocolState,
                ),
              );
              await _occHost(
                actor,
                recipient,
                tx,
                CalendarAuthorizationPhase.read,
                operation: CalendarInvitationOperation.applyRangeCancellation,
                view: view,
                link: link,
                event: event,
                message: message,
                text: source!.normalizedSource,
                master: master,
                current: row,
              );
            }
          }
        } else {
          final p =
              (range
              ? projectInvitationRangeRequest
              : projectInvitationOccurrence)(
                protocolUid: link.uid,
                content: accepted.content,
                timingOverrides: accepted.edits,
                protocolState: accepted.protocol,
                message: message,
                recipientAddress: recipient.calendarAddress,
              );
          projection = (
            content: p.content,
            edits: p.timingOverrides,
            protocol: p.protocolState,
          );
          if (!restoration && _occHasRangeRestoration(state)) {
            final collision = (state!['targets'] as List)
                .cast<Map<String, dynamic>>()
                .any(
                  (target) =>
                      target['key'] != entry.targetKey &&
                      _replySamePoint(
                        CalendarEventTiming.fromJson(target['original']),
                        entry.originalStart,
                      ),
                );
            if (collision ||
                accepted.content.status == CalendarEventStatus.cancelled ||
                accepted.edits?.cancelledFrom != null) {
              projection = null;
            } else {
              await _invApplicationNative(
                actor,
                event,
                tx,
                CalendarAuthorizationPhase.read,
                writing: true,
                cancellation:
                    message.method == IcalendarSchedulingMethod.cancel,
                member: CalendarEventImportMember(
                  eventId: link.eventId,
                  protocolUid: link.uid,
                  content: p.content,
                  timingOverrides: p.timingOverrides,
                  protocolState: p.protocolState,
                ),
              );
              await _occHost(
                actor,
                recipient,
                tx,
                CalendarAuthorizationPhase.read,
                operation: range
                    ? CalendarInvitationOperation.applyRangeUpdate
                    : message.method == IcalendarSchedulingMethod.cancel
                    ? CalendarInvitationOperation.applyOccurrenceCancellation
                    : CalendarInvitationOperation.applyOccurrenceUpdate,
                view: view,
                link: link,
                event: event,
                message: message,
                proposed: CalendarEventPolicySnapshot(
                  link.eventId,
                  link.calendarId,
                  event.identity.revision + 1,
                  p.content,
                  link.uid,
                  event.data.updatedAt,
                  origin: event.data.origin,
                  timingOverrides: p.timingOverrides,
                  protocolState: p.protocolState,
                ),
                text: source!.normalizedSource,
                master: master,
                current: row,
              );
            }
          }
        }
      } on CalendarException catch (e) {
        if ((!restoration && !_occHasRangeRestoration(state)) ||
            e.code != CalendarFailureCode.accessDenied) {
          rethrow;
        }
        projection = null;
      } on ArgumentError {
        /* Unsupported proposed differences remain reviewable. */
      } on RecurrenceLimitException {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
    }
    final cancelled =
        target?['kind'] ==
        CalendarInvitationSourceKind.instanceCancellation.name;
    final newer =
        message != null &&
        _occNewer(message, floor, cancelled: cancelled) &&
        (!range ||
            restoration ||
            !_occHasRangeRestoration(state) ||
            (message.events.single.sequence != null &&
                message.events.single.sequence! >
                    _occRestoredRangeFloor(
                      accepted,
                      state!,
                      entry.originalStart!,
                    )));
    await _occHost(
      actor,
      recipient,
      tx,
      CalendarAuthorizationPhase.read,
      operation: restoration
          ? CalendarInvitationOperation.readRangeRestorationApplication
          : range
          ? CalendarInvitationOperation.readRangeApplication
          : CalendarInvitationOperation.readOccurrenceApplication,
      view: view,
      link: link,
      event: event,
      message:
          message ??
          (target == null
              ? null
              : _invParse(
                  utf8.encode(target['source'] as String),
                  stored: true,
                )),
      text: source?.normalizedSource ?? target?['source'] as String?,
      historicalUnavailable: message == null && target == null,
      master: master,
      current: row,
      dirty: dirty,
    );
    CalendarEventContent? effective(_OccurrenceAccepted a) {
      try {
        return _occEffective(a, entry.originalStart!);
      } on ArgumentError {
        return null;
      } on RecurrenceLimitException {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
    }

    final latest = state == null
        ? null
        : CalendarInvitationOccurrenceApplyReceipt.fromJson(state['receipt']);
    return CalendarInvitationOccurrenceApplicationView(
      isThisAndFuture: range,
      hasAcceptedRangeCancellation: _occHasRangeCancellation(state),
      hasAcceptedRangeRestoration: _occHasRangeRestoration(state),
      hasActiveAcceptedRangeCancellation: _occActiveCancellation(state),
      linkId: link.id!,
      invitationId: id,
      calendarId: link.calendarId,
      eventId: link.eventId,
      calendarRevision: event.parent.identity.revision,
      eventRevision: event.identity.revision,
      applicationRevision: master.revision,
      occurrenceRevision: row?.revision ?? 0,
      originalStart: entry.originalStart!,
      hasLocalChanges: dirty,
      acceptedVersion: floor,
      acceptedKind: selectedCancellation
          ? ((_occCycles(state)
                    ? target!['kind'] ==
                          CalendarInvitationSourceKind.request.name
                    : _occHasRangeRestoration(state))
                ? CalendarInvitationSourceKind.request
                : CalendarInvitationSourceKind.rangeCancellation)
          : target == null
          ? master.kind
          : cancelled
          ? CalendarInvitationSourceKind.instanceCancellation
          : CalendarInvitationSourceKind.request,
      currentOccurrence: effective((
        content: event.data.content,
        edits: event.data.timingOverrides,
        protocol: event.data.protocolState!,
      )),
      proposedOccurrence: projection == null ? null : effective(projection),
      incomingKind: message == null ? null : _invKind(message),
      incomingSourceId: source?.id,
      invitationRevision: entry.revision,
      incomingVersion: message == null ? null : _occVersion(message),
      incomingSourceText: source?.normalizedSource,
      acceptedSourceText: target?['source'] as String?,
      canApply:
          projection != null &&
          newer &&
          !dirty &&
          entry.dismissedAt == null &&
          (restoration
              ? _occActiveCancellation(state)
              : (!_occHasRangeCancellation(state) ||
                    !restoration &&
                        _occHasRangeRestoration(state) &&
                        !_occActiveCancellation(state) &&
                        (message.method == IcalendarSchedulingMethod.request ||
                            range &&
                                message.method ==
                                    IcalendarSchedulingMethod.cancel) ||
                    !range &&
                        _occHasRangeRestoration(state) &&
                        !_occActiveCancellation(state))),
      latestResult:
          latest != null &&
              !(_occCycles(state)
                  ? !_cycleLatestMatchesView(state!, entry, restoration)
                  : restoration && {10, 11}.contains(state?['version'])) &&
              _occLatestKey(state!, latest) == entry.targetKey
          ? latest
          : null,
    );
  });

  CalendarEventProtocolVersion _occVersion(IcalendarSchedulingMessage m) {
    final s = m.events.single;
    return CalendarEventProtocolVersion(
      sequence: s.sequence,
      stamp: s.stamp,
      created: s.created,
      lastModified: s.lastModified,
    );
  }

  bool _occNewer(
    IcalendarSchedulingMessage message,
    CalendarEventProtocolVersion floor, {
    required bool cancelled,
  }) =>
      _invSourceOrder(
            message.events.single.sequence,
            message.events.single.stamp,
            floor.sequence,
            floor.stamp,
          ) >
          0 &&
      (!(message.method == IcalendarSchedulingMethod.cancel || cancelled) ||
          (message.events.single.sequence ?? 0) > (floor.sequence ?? 0));

  Future<CalendarInvitationOccurrenceApplyReceipt>
  applyInvitationOccurrenceUpdate(
    CalendarInvitationOccurrenceApplyRequest request,
  ) => _occApply(request, false);
  Future<CalendarInvitationOccurrenceApplyReceipt>
  applyInvitationOccurrenceCancellation(
    CalendarInvitationOccurrenceApplyRequest request,
  ) => _occApply(request, true);

  Future<CalendarInvitationOccurrenceApplyReceipt> applyInvitationRangeUpdate(
    CalendarInvitationOccurrenceApplyRequest request,
  ) => _occApply(request, false, range: true);

  Future<CalendarInvitationOccurrenceApplyReceipt>
  applyInvitationRangeCancellation(
    CalendarInvitationOccurrenceApplyRequest request,
  ) => _occApply(request, true, range: true);

  Future<CalendarInvitationOccurrenceApplyReceipt>
  applyInvitationRangeRestoration(
    CalendarInvitationOccurrenceApplyRequest request,
  ) => _occApply(request, false, range: true, restoration: true);
  Future<CalendarInvitationOccurrenceApplyReceipt> _occApply(
    CalendarInvitationOccurrenceApplyRequest input,
    bool cancellation, {
    bool range = false,
    bool restoration = false,
  }) {
    if ([
          input.expectedInvitationRevision,
          input.expectedEventRevision,
          input.expectedCalendarRevision,
        ].any((r) => r < 1 || r > CalendarService._maxRevision) ||
        [
          input.expectedApplicationRevision,
          input.expectedOccurrenceRevision,
        ].any((r) => r < 0 || r > CalendarService._maxRevision)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final operation = restoration
        ? CalendarInvitationOperation.applyRangeRestoration
        : range
        ? cancellation
              ? CalendarInvitationOperation.applyRangeCancellation
              : CalendarInvitationOperation.applyRangeUpdate
        : cancellation
        ? CalendarInvitationOperation.applyOccurrenceCancellation
        : CalendarInvitationOperation.applyOccurrenceUpdate;
    final digest = _occCommandDigest(
      input,
      operation,
      range: range,
      cancellation: cancellation,
      restoration: restoration,
    );
    return _invNativeScoped((actor, recipient, tx, scope) async {
      final entry = await _invOptionalEntry(input.invitationId, recipient, tx);
      final view = entry == null ? null : await _invView(entry, tx);
      await _occHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        request: input,
      );
      final link = await _occLink(
        entry,
        recipient,
        tx,
        retainedLink: input.linkId,
        range: range,
      );
      if (link == null || link.id != input.linkId) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final event = await _invLinkedEvent(link, actor, tx),
          before = event.snapshot;
      final masterRow = await _invCheckpoint(link, event, tx),
          master = await _invApplicationState(link, event, masterRow, tx);
      final row = await _occRow(link.id!, tx);
      final state = row == null
          ? null
          : _occDecode(link, event, row, masterRow);
      await _invApplicationNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        writing: true,
        cancellation: cancellation || restoration,
      );
      await _occAuthorizeCancellation(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        link,
        event,
        row,
        state,
      );
      if (state?['requestDigest'] == digest) {
        final receipt = CalendarInvitationOccurrenceApplyReceipt.fromJson(
          state!['receipt'],
        );
        if (receipt.invitationId != input.invitationId ||
            receipt.sourceId != input.sourceId ||
            _occLatestKey(state, receipt).startsWith('range-v1:') != range ||
            ({
                  CalendarInvitationSourceKind.instanceCancellation,
                  CalendarInvitationSourceKind.rangeCancellation,
                }.contains(receipt.kind)) !=
                cancellation) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final target = _occLatestTarget(state);
        final message = _invParse(
          utf8.encode(target['source'] as String),
          stored: true,
        );
        for (final phase in [
          CalendarAuthorizationPhase.preliminaryWrite,
          CalendarAuthorizationPhase.finalWrite,
        ]) {
          await _invApplicationNative(
            actor,
            event,
            tx,
            phase,
            writing: true,
            cancellation: cancellation || restoration,
          );
          await _occAuthorizeCancellation(
            actor,
            recipient,
            tx,
            phase,
            link,
            event,
            row,
            state,
          );
          if (!cancellation && target['reopened'] == true) {
            await _occLifecycle(actor, event, tx, phase);
          }
          await _occHost(
            actor,
            recipient,
            tx,
            phase,
            operation: operation,
            view: view,
            link: link,
            event: event,
            message: message,
            text: target['source'],
            master: master,
            current: row,
            request: input,
            receipt: receipt,
            dirty: _invLocalChanges(event, occurrenceState: state),
            retry: true,
          );
        }
        return receipt;
      }
      final cycleControl =
          range &&
          (cancellation || restoration) &&
          _occHasRangeRestoration(state);
      final restoredChange =
          !restoration &&
          (!range || !cancellation) &&
          _occHasRangeRestoration(state);
      if (cycleControl
          ? event.data.content.status == CalendarEventStatus.cancelled ||
                (restoration
                    ? !_occActiveCancellation(state)
                    : _occActiveCancellation(state)) ||
                (!restoration &&
                    event.data.timingOverrides?.cancelledFrom != null)
          : restoredChange
          ? event.data.content.status == CalendarEventStatus.cancelled ||
                event.data.timingOverrides?.cancelledFrom != null
          : _occHasRangeRestoration(state) ||
                (restoration
                    ? !_occHasRangeCancellation(state)
                    : _occHasRangeCancellation(state))) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      await _occHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        link: link,
        event: event,
        master: master,
        current: row,
        request: input,
      );
      if (entry == null ||
          entry.revision != input.expectedInvitationRevision ||
          entry.currentSourceId != input.sourceId ||
          entry.dismissedAt != null ||
          event.identity.revision != input.expectedEventRevision ||
          event.parent.identity.revision != input.expectedCalendarRevision ||
          master.revision != input.expectedApplicationRevision ||
          (row?.revision ?? 0) != input.expectedOccurrenceRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      final source = await CalendarInvitationSourceRecord.db.findById(
        _session,
        input.sourceId,
        transaction: tx,
      );
      if (source == null || source.entryId != entry.id) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final message = _invStored(source, entry);
      if ((message.method == IcalendarSchedulingMethod.cancel) !=
          cancellation) {
        throw _failure(CalendarFailureCode.validation);
      }
      final accepted = _occAccepted(event.data.importBaseline!);
      final target = (state?['targets'] as List?)
          ?.cast<Map<String, dynamic>>()
          .where((v) => v['key'] == entry.targetKey)
          .firstOrNull;
      if (restoredChange &&
          (state!['targets'] as List).cast<Map<String, dynamic>>().any(
            (target) =>
                target['key'] != entry.targetKey &&
                _replySamePoint(
                  CalendarEventTiming.fromJson(target['original']),
                  entry.originalStart,
                ),
          )) {
        throw _failure(CalendarFailureCode.validation);
      }
      final cancelled =
          accepted.edits?.singles.any(
            (v) =>
                v.cancelled &&
                _replySamePoint(v.originalStart, entry.originalStart),
          ) ??
          false;
      final dirty = _invLocalChanges(event, occurrenceState: state);
      await _occHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        link: link,
        event: event,
        message: message,
        text: source.normalizedSource,
        master: master,
        current: row,
        request: input,
        dirty: dirty,
      );
      if (dirty ||
          (restoredChange &&
              range &&
              (message.events.single.sequence == null ||
                  message.events.single.sequence! <=
                      _occRestoredRangeFloor(
                        accepted,
                        state!,
                        entry.originalStart!,
                      ))) ||
          !_occNewer(
            message,
            _occFloor(accepted, entry.originalStart!),
            cancelled: cancelled,
          )) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      if (target != null &&
          target['recipientAddress'] != recipient.calendarAddress) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      CalendarInvitationRangeCancellationProjection? cancellationProjection;
      CalendarInvitationRangeRestorationProjection? restorationProjection;
      final projected = _eventReplacementValue(() {
        if (restoration) {
          final p = _occRestorationCandidate(
            link,
            event,
            state!,
            message,
            recipient.calendarAddress,
          );
          restorationProjection = p;
          return (
            content: p.content,
            timingOverrides: p.timingOverrides,
            protocolState: p.protocolState,
          );
        }
        if (range && cancellation) {
          final p = _occHasRangeRestoration(state)
              ? _cycleCancellationCandidate(
                  link,
                  accepted,
                  state!,
                  message,
                  recipient.calendarAddress,
                )
              : projectInvitationRangeCancellation(
                  protocolUid: link.uid,
                  content: accepted.content,
                  timingOverrides: accepted.edits,
                  protocolState: accepted.protocol,
                  message: message,
                  recipientAddress: recipient.calendarAddress,
                );
          cancellationProjection = p;
          return (
            content: p.content,
            timingOverrides: p.timingOverrides,
            protocolState: p.protocolState,
          );
        }
        final p =
            (range
            ? projectInvitationRangeRequest
            : projectInvitationOccurrence)(
              protocolUid: link.uid,
              content: accepted.content,
              timingOverrides: accepted.edits,
              protocolState: accepted.protocol,
              message: message,
              recipientAddress: recipient.calendarAddress,
            );
        return (
          content: p.content,
          timingOverrides: p.timingOverrides,
          protocolState: p.protocolState,
        );
      });
      final member = CalendarEventImportMember(
        eventId: link.eventId,
        protocolUid: link.uid,
        content: projected.content,
        timingOverrides: projected.timingOverrides,
        protocolState: projected.protocolState,
      );
      final baseline = restoration || range && cancellation
          ? event.data.importBaseline!
          : eventImportBaseline(
              link.uid,
              member.content,
              member.timingOverrides,
              member.protocolState,
            );
      if ([
        event.identity.revision,
        entry.revision,
        row?.revision ?? 0,
      ].any((v) => v == CalendarService._maxRevision)) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final now = await _revisionTime(
        tx,
        previous: event.data.updatedAt.isAfter(entry.updatedAt)
            ? event.data.updatedAt
            : entry.updatedAt,
      );
      final receipt = CalendarInvitationOccurrenceApplyReceipt(
        id: const Uuid().v4obj(),
        kind: _invKind(message),
        originalStart: entry.originalStart!,
        linkId: link.id!,
        invitationId: entry.id!,
        sourceId: source.id!,
        calendarId: link.calendarId,
        eventId: link.eventId,
        occurrenceRevision: (row?.revision ?? 0) + 1,
        eventRevision: event.identity.revision + 1,
        invitationRevision: entry.revision + 1,
        appliedAt: now,
      );
      if (cycleControl && state!['masterSource'] == null) {
        final body = await CalendarInvitationSourceRecord.db.findById(
          _session,
          master.sourceId,
          transaction: tx,
        );
        if (body == null) throw _failure(CalendarFailureCode.unavailable);
        state['_capturedMasterSource'] = _cycleMasterSource(
          body,
          recipient.calendarAddress,
        );
        await _occAuthorizeCancellation(
          actor,
          recipient,
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
          link,
          event,
          row,
          {'version': 4, 'rangeCancellation': state['_capturedMasterSource']},
        );
      }
      final targets = <Map<String, dynamic>>[
        for (final v
            in (state?['targets'] as List? ?? []).cast<Map<String, dynamic>>())
          if (restoration ||
              range && cancellation ||
              v['key'] != entry.targetKey)
            v,
        if (!restoration && !(range && cancellation))
          {
            'key': entry.targetKey,
            'original': entry.originalStart!.toJson(),
            'kind': receipt.kind.name,
            'invitationId': entry.id.toString(),
            'sourceId': source.id.toString(),
            'source': source.normalizedSource,
            'digest': source.digest,
            'version': _occVersion(message).toJson(),
            'recipientAddress': recipient.calendarAddress,
            'acceptedAt': now.toIso8601String(),
            'reopened': !range && !cancellation && cancelled,
            if (_occCycles(state))
              'acceptedRevision': receipt.occurrenceRevision,
            if (_occCycles(state) && range)
              'restorationKey': _cycleLatestRestorationKey(state!),
            if (restoredChange && range)
              'requiredAfterSequence': _occRestoredRangeFloor(
                accepted,
                state!,
                entry.originalStart!,
              ),
            'component': _occComponent(
              (
                content: member.content,
                edits: member.timingOverrides,
                protocol: member.protocolState,
              ),
              entry.originalStart!,
              source.digest,
              range: range,
            ),
          },
      ];
      if (targets.length + (range && cancellation || restoredChange ? 1 : 0) >
          128) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final next = CalendarInvitationOccurrenceApplicationRecord(
        id: row?.id ?? const Uuid().v4obj(),
        scopeKey: recipient.scopeKey,
        recipientKey: recipient.key,
        linkId: link.id!,
        revision: receipt.occurrenceRevision,
        eventRevision: receipt.eventRevision,
        updatedAt: now,
        stateJson: jsonEncode(
          (_occCycles(state) || cycleControl)
              ? _cycleState(
                  link: link,
                  event: event,
                  row: row!,
                  master: masterRow,
                  state: state!,
                  member: member,
                  baseline: baseline,
                  targets: targets,
                  receipt: receipt,
                  requestDigest: digest,
                  input: input,
                  source: source,
                  entry: entry,
                  recipient: recipient,
                  restoration: restoration,
                  cancellation: cancellation,
                  range: range,
                  floor:
                      restorationProjection?.requiredAfterSequence ??
                      cancellationProjection?.requiredAfterSequence,
                )
              : restoredChange
              ? _occRestoredTargetsState(
                  link: link,
                  event: event,
                  row: row!,
                  state: state!,
                  master: masterRow,
                  previousMaster: masterRow,
                  kind: masterRow?.kind ?? CalendarInvitationSourceKind.request,
                  masterBaseline: CalendarEventImportBaseline.fromJson(
                    state['masterBaseline'],
                  ),
                  baseline: baseline,
                  member: member,
                  targets: targets,
                  receipt: receipt,
                  requestDigest: digest,
                )
              : restoration
              ? _occRestorationState(
                  link: link,
                  event: event,
                  row: row!,
                  entry: entry,
                  source: source,
                  recipient: recipient,
                  projection: restorationProjection!,
                  receipt: receipt,
                  requestDigest: digest,
                )
              : range && cancellation
              ? _occCancellationState(
                  link: link,
                  event: event,
                  master: masterRow,
                  previous: state,
                  entry: entry,
                  source: source,
                  recipient: recipient,
                  projection: cancellationProjection!,
                  receipt: receipt,
                  requestDigest: digest,
                )
              : {
                  'version': range || state?['version'] == 3
                      ? 3
                      : state?['version'] ?? 1,
                  if (range || state?['version'] == 3)
                    'latestTargetKey': entry.targetKey,
                  'masterBaseline':
                      state?['masterBaseline'] ??
                      event.data.importBaseline!.toJson(),
                  'masterBaselineDigest':
                      state?['masterBaselineDigest'] ??
                      _invBaselineDigest(event.data.importBaseline!),
                  'masterDigest': _occMasterDigest(link, masterRow),
                  'baselineDigest': _invBaselineDigest(baseline),
                  'targets': targets,
                  'requestDigest': digest,
                  'receipt': receipt.toJson(),
                  if (range || state?['version'] == 3 || state?['version'] == 2)
                    'receiptDigest': _invitationHash([
                      if (range || state?['version'] == 3) entry.targetKey,
                      digest,
                      jsonEncode(_occOrdered(receipt.toJson())),
                      source.digest,
                    ]),
                },
        ),
      );
      final proposed = CalendarEventPolicySnapshot(
        link.eventId,
        link.calendarId,
        receipt.eventRevision,
        member.content,
        link.uid,
        now,
        origin: event.data.origin,
        timingOverrides: member.timingOverrides,
        protocolState: member.protocolState,
      );
      await _invApplicationNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        writing: true,
        cancellation: cancellation || restoration,
        member: member,
        before: before,
      );
      if (!cancellation && cancelled) {
        await _occLifecycle(
          actor,
          event,
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
          before: before,
          member: member,
        );
      }
      await _occHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        link: link,
        event: event,
        before: before,
        proposed: proposed,
        message: message,
        text: source.normalizedSource,
        master: master,
        current: row,
        next: next,
        request: input,
        receipt: receipt,
        baseline: baseline,
        dirty: dirty,
      );
      if (_occCycles(jsonDecode(next.stateJson))) {
        _occDecode(
          link,
          _Event(
            event.identity.copyWith(revision: receipt.eventRevision),
            event.data.copyWith(
              content: member.content,
              timingOverrides: member.timingOverrides,
              protocolState: member.protocolState,
              importBaseline: baseline,
              updatedAt: now,
            ),
            event.parent,
          ),
          next,
          masterRow,
        );
      }
      await _occQuota(recipient, next, tx);
      await _invCleanup(recipient, tx, now);
      if ((await _invEntries(
            recipient,
            tx,
          )).where((e) => e.dismissedAt != null).length >=
          _invOptions.maxDismissed) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      event.data.content = member.content;
      event.data.timingOverrides = member.timingOverrides;
      event.data.protocolState = member.protocolState;
      event.data.importBaseline = baseline;
      event.data.updatedAt = now;
      event.identity.revision = receipt.eventRevision;
      await CalendarEventDataRecord.db.updateRow(
        _session,
        event.data,
        transaction: tx,
      );
      await CalendarEventRecord.db.updateRow(
        _session,
        event.identity,
        transaction: tx,
      );
      if (row == null) {
        await CalendarInvitationOccurrenceApplicationRecord.db.insertRow(
          _session,
          next,
          transaction: tx,
        );
      } else {
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          _session,
          next,
          transaction: tx,
        );
      }
      entry.revision = receipt.invitationRevision;
      entry.dismissedAt = now;
      entry.updatedAt = now;
      source.inactiveAt = now;
      await CalendarInvitationRecord.db.updateRow(
        _session,
        entry,
        transaction: tx,
      );
      await CalendarInvitationSourceRecord.db.updateRow(
        _session,
        source,
        transaction: tx,
      );
      await _bump(scope, tx, publishedEventCalendar: link.calendarId);
      await _invApplicationNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        writing: true,
        cancellation: cancellation || restoration,
        member: member,
        before: before,
      );
      if (!cancellation && cancelled) {
        await _occLifecycle(
          actor,
          event,
          tx,
          CalendarAuthorizationPhase.finalWrite,
          before: before,
          member: member,
        );
      }
      await _occHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        operation: operation,
        view: view,
        link: link,
        event: event,
        before: before,
        proposed: proposed,
        message: message,
        text: source.normalizedSource,
        master: master,
        current: row,
        next: next,
        request: input,
        receipt: receipt,
        baseline: baseline,
        dirty: dirty,
      );
      if (restoration || restoredChange || cycleControl) {
        await _occAuthorizeCancellation(
          actor,
          recipient,
          tx,
          CalendarAuthorizationPhase.finalWrite,
          link,
          event,
          next,
          _occDecode(link, event, next, masterRow),
        );
      }
      return receipt;
    });
  }

  Future<void> _deleteOccurrenceAcceptance(
    UuidValue eventId,
    Transaction tx,
  ) async {
    final links = await CalendarInvitationLinkRecord.db.find(
      _session,
      where: (t) => t.eventId.equals(eventId),
      transaction: tx,
    );
    for (final link in links) {
      await CalendarInvitationOccurrenceApplicationRecord.db.deleteWhere(
        _session,
        where: (t) => t.linkId.equals(link.id!),
        transaction: tx,
      );
    }
  }

  Future<void> _occLifecycle(
    CalendarHostContext actor,
    _Event event,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    CalendarEventPolicySnapshot? before,
    CalendarEventImportMember? member,
  }) async {
    final request = CalendarAuthorizationRequest(
      key: '${CalendarPermission.changeEventStatus.name}:${event.identity.id}',
      operation: CalendarPermission.changeEventStatus,
      calendarId: event.parent.identity.id,
      current: event.parent.snapshot,
      eventId: event.identity.id,
      currentEvent: before ?? event.snapshot,
      proposedEvent: member?.content,
      proposedEventProtocolState: member?.protocolState,
      proposedTimingOverrides: member?.timingOverrides,
      eventGroups: CalendarEventFieldGroup.values,
    );
    final decisions = phase == CalendarAuthorizationPhase.finalWrite
        ? await _final(actor, [request], tx)
        : await _decide(actor, [request], tx, phase);
    if (phase == CalendarAuthorizationPhase.finalWrite &&
        !decisions[request.key]!.discloseMutationReceipt) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
  }
}
