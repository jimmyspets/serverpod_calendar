part of 'calendar_module.dart';

extension CalendarRecurringResponseOperations on CalendarService {
  String _rrKey(CalendarEventTiming original) =>
      'recurring-occurrence-v1:${eventComponentKey(original, false)}';
  CalendarInvitationBundleResponseTarget _rrTarget(
    CalendarRecurringResponseEvidence proof,
    CalendarEventTiming original,
    String recipient,
    RecurrenceWorkBudget work,
  ) {
    final data = jsonDecode(proof.snapshotJson) as Map<String, dynamic>;
    if (data['complete'] != true) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final target = _schedulingValue(
      () => selectRecurringResponseHistory(
        data,
        proof.packets,
        original,
        recipient,
        work,
      ),
    );
    return CalendarInvitationBundleResponseTarget(
      original,
      CalendarInvitationBundleComponentVersion(
        originalStart: target.sourceOriginalStart,
        isThisAndFuture: target.role == RecurringInvitationResponseRole.range,
        sequence: target.sequence,
        stamp: target.stamp,
      ),
      target.blocked || data['wholeCancelled'] == true,
    );
  }

  String _rrCriteria(
    CalendarInvitationResponseRequest request,
    CalendarEventTiming original,
    UuidValue opened,
    CalendarRecurringResponseEvidence proof,
  ) => _invitationHash([
    'recurring-occurrence-response-v1',
    jsonEncode(
      CalendarInvitationRecurringOccurrenceResponseRequest(
        request: request,
        openedInvitationId: opened,
        originalStart: original,
        selectionHeadId: proof.headId,
        expectedSelectionRevision: proof.revision,
        selectionEvidenceId: proof.evidenceId,
        selectionDigest: proof.digest,
      ).toJson(),
    ),
  ]);
  Future<void> _rrSourcesRead(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    _RecurringSelection s,
    Transaction tx,
    RecurrenceWorkBudget work, {
    bool retry = false,
    CalendarAuthorizationPhase phase = CalendarAuthorizationPhase.read,
  }) async {
    for (final source in s.sources.values) {
      work.charge();
      await _irSourceRead(
        actor,
        recipient,
        s.entries[source.entryId]!,
        source,
        tx,
        retry: retry,
        work: work,
        phase: phase,
      );
    }
  }

  Future<({CalendarInvitationRecord opened, _RecurringSelection selection})>
  _rrRoute(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    UuidValue openedId,
    CalendarEventTiming original,
    Transaction tx,
    RecurrenceWorkBudget work, {
    UuidValue? evidenceId,
    bool retry = false,
  }) async {
    final opened = await _invEntry(openedId, recipient, tx);
    await _irSourceRead(
      actor,
      recipient,
      opened,
      null,
      tx,
      work: work,
      retry: retry,
    );
    _invTargetValid(opened);
    if (_invBundleKind(opened.kind) || !opened.recurring) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (original.end != null || original.duration != null) {
      throw _failure(CalendarFailureCode.validation);
    }
    _schedulingValue(() => validateEventTiming(original));
    if (opened.originalStart != null &&
        (!_invRange(opened)
            ? eventComponentKey(opened.originalStart!, false) !=
                  eventComponentKey(original, false)
            : recurringResponseOrder(original, opened.originalStart!) < 0)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final head = await _rrHead(recipient, opened.correlationDigest, tx);
    if (head == null ||
        head.currentEvidenceId == null ||
        head.state == 'purged') {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final s = await _rrLoad(
      recipient,
      evidenceId ?? head.currentEvidenceId!,
      tx,
      work,
    );
    if (s.head.id != head.id || !s.entries.containsKey(openedId)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    await _rrSourcesRead(actor, recipient, s, tx, work, retry: retry);
    return (opened: opened, selection: s);
  }

  Future<CalendarInvitationRecurringOccurrenceResponseView>
  recurringOccurrenceResponse(
    UuidValue openedId,
    CalendarEventTiming original,
  ) {
    final point = original.copyWith();
    return _invNative(
      (actor, recipient, tx) => _rrRead(actor, recipient, openedId, point, tx),
    );
  }

  Future<CalendarInvitationRecurringOccurrenceResponseView> _rrRead(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    UuidValue openedId,
    CalendarEventTiming original,
    Transaction tx,
  ) async {
    final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    final route = await _rrRoute(
          actor,
          recipient,
          openedId,
          original,
          tx,
          work,
        ),
        s = route.selection;
    final state = await _irState(
      recipient,
      s.master.id!,
      tx,
      targetKey: _rrKey(original),
    );
    final complete =
        s.data['complete'] == true &&
        s.head.state == 'active' &&
        _rrVectorCurrent(s);
    final target = complete
        ? _rrTarget(s.proof, original, recipient.calendarAddress, work)
        : null;
    var view = _irView(s.master, state, responseOriginal: original).copyWith(
      canSend: _rrOptions.enabled && complete && !(target?.cancelled ?? true),
      appliesToCurrentSource:
          state != null && state.sourceDigest == s.proof.digest && complete,
    );
    final context = _irContext(
      operation: CalendarInvitationResponseOperation.read,
      recipient: recipient,
      invitation: await _invView(s.master, tx, sharedWorkBudget: work),
      current: view,
      actor: actor,
      source: s.membership,
      sourceRevision: s.master.revision,
      sourceMessage: s.proof.packets[s.membership.id.toString()],
      responseOriginal: original,
      recurring: s.proof,
      recurringOpened: await _invView(route.opened, tx, sharedWorkBudget: work),
    );
    await _irAuthorize(
      context,
      tx,
      CalendarAuthorizationPhase.read,
      work: work,
    );
    if (!complete) {
      view = view.copyWith(canSend: false);
    }
    String? controller;
    String? role;
    if (complete) {
      final selected = selectRecurringResponseHistory(
        s.data,
        s.proof.packets,
        original,
        recipient.calendarAddress,
        work,
      );
      final encoded = serializeIcalendarSchedulingMessage(
        selected.sourceMessage,
      );
      for (final entry in s.proof.packets.entries) {
        work.charge();
        if (utf8.decode(serializeIcalendarSchedulingMessage(entry.value)) ==
            utf8.decode(encoded)) {
          controller = entry.key;
          break;
        }
      }
      role = selected.role.name;
      if (controller == null) {
        throw _failure(CalendarFailureCode.unavailable);
      }
    }
    return CalendarInvitationRecurringOccurrenceResponseView(
      response: view,
      openedInvitationId: openedId,
      openedInvitationRevision: route.opened.revision,
      masterInvitationId: s.master.id!,
      masterInvitationRevision: s.master.revision,
      membershipSourceId: s.membership.id,
      originalStart: original,
      selectionHeadId: s.head.id!,
      selectionRevision: s.row.revision,
      selectionEvidenceId: s.row.id,
      selectionDigest: s.row.digest,
      canSend: view.canSend,
      blockedReason: !complete
          ? 'incompleteEvidence'
          : target!.cancelled
          ? 'cancelled'
          : !_rrOptions.enabled
          ? 'disabled'
          : null,
      controllingSourceId: controller == null
          ? null
          : UuidValue.fromString(controller),
      controllingInvitationId: controller == null
          ? null
          : s.sources[UuidValue.fromString(controller)]!.entryId,
      controllingRole: role,
      componentVersion: target?.componentVersion,
    );
  }

  Future<List<CalendarInvitationResponseActivityView>>
  recurringOccurrenceResponseActivity(
    UuidValue openedId,
    CalendarEventTiming original,
  ) {
    final point = original.copyWith();
    return _invNative(
      (actor, recipient, tx) =>
          _rrActivity(actor, recipient, openedId, point, tx),
    );
  }

  Future<List<CalendarInvitationResponseActivityView>> _rrActivity(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    UuidValue openedId,
    CalendarEventTiming original,
    Transaction tx,
  ) async {
    final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    final route = await _rrRoute(
          actor,
          recipient,
          openedId,
          original,
          tx,
          work,
        ),
        s = route.selection;
    final state = await _irState(
      recipient,
      s.master.id!,
      tx,
      targetKey: _rrKey(original),
    );
    final context = _irContext(
      operation: CalendarInvitationResponseOperation.read,
      recipient: recipient,
      invitation: await _invView(s.master, tx, sharedWorkBudget: work),
      current: _irView(s.master, state, responseOriginal: original),
      actor: actor,
      source: s.membership,
      sourceMessage: s.proof.packets[s.membership.id.toString()],
      responseOriginal: original,
      recurring: s.proof,
      recurringOpened: await _invView(route.opened, tx, sharedWorkBudget: work),
    );
    await _irAuthorize(
      context,
      tx,
      CalendarAuthorizationPhase.read,
      work: work,
    );
    final rows = await CalendarInvitationResponseRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(recipient.scopeKey) &
          t.recipientKey.equals(recipient.key) &
          t.entryId.equals(s.master.id!) &
          t.targetKey.equals(_rrKey(original)),
      orderBy: (t) => t.stamp.desc(),
      limit: 33,
      transaction: tx,
    );
    if (rows.length > 32) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final result = <CalendarInvitationResponseActivityView>[];
    for (final row in rows) {
      if (state == null || row.selectionEvidenceId == null) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final proof = await _rrLoad(
        recipient,
        row.selectionEvidenceId!,
        tx,
        work,
      );
      await _rrSourcesRead(actor, recipient, proof, tx, work, retry: true);
      await _irRecord(row, state, proof.membership, s.master, tx, work: work);
      result.add(
        CalendarInvitationResponseActivityView(
          id: row.id!,
          stateRevision: row.generation,
          choice: row.choice,
          sourceId: row.sourceId,
          sourceRevision: row.sourceRevision,
          sourceSequence: row.sourceSequence,
          sourceStamp: row.sourceStamp,
          stamp: row.stamp,
          deliveryState: row.state,
          attemptCount: row.attemptCount,
          queuedAt: row.createdAt,
          expiresAt: row.expiresAt,
          terminalAt: row.terminalAt,
          resultCode: row.resultCode,
        ),
      );
    }
    await _irAuthorize(
      context,
      tx,
      CalendarAuthorizationPhase.read,
      work: work,
    );
    return List.unmodifiable(result);
  }

  Future<CalendarInvitationResponseReceipt> sendRecurringOccurrenceResponse(
    CalendarInvitationRecurringOccurrenceResponseRequest request,
  ) => _sendInvitationResponse(
    request.request,
    responseOriginal: request.originalStart,
    recurringRequest: request,
  );
}
