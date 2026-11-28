part of 'calendar_module.dart';

bool _schedulingIsCutoffLifecycle(CalendarSchedulingPublicationRecord row) =>
    row.snapshot.startsWith('{"version":9,');

bool _schedulingMayHaveActiveCutoff(CalendarSchedulingPublicationRecord row) =>
    _schedulingIsCutoffLifecycle(row) ||
    row.projection.startsWith('{"version":7,"kind":"rangeCancel",');

extension CalendarSchedulingCutoffLifecycle on CalendarService {
  List<CalendarAuthorizationRequest> _wholeCutoffRequests(
    _Event event,
    CalendarEventPolicySnapshot proposed,
    bool reopen, [
    CalendarSchedulingIntent? intent,
  ]) => [
    for (final operation in [
      reopen
          ? CalendarPermission.reopenScheduling
          : CalendarPermission.cancelScheduling,
      CalendarPermission.readScheduling,
      CalendarPermission.readEvent,
      CalendarPermission.readEventSource,
      CalendarPermission.changeEventStatus,
    ])
      CalendarAuthorizationRequest(
        key: '${operation.name}:${event.identity.id}',
        operation: operation,
        calendarId: event.identity.calendarId,
        current: event.parent.snapshot,
        eventId: event.identity.id,
        currentEvent: event.snapshot,
        proposedEvent: proposed.content,
        proposedEventProtocolState: proposed.protocolState,
        proposedTimingOverrides: proposed.timingOverrides,
        scheduling: intent,
        eventGroups: CalendarEventFieldGroup.values,
      ),
  ];

  Future<CalendarSchedulingReceipt> _changeWholePublishedCutoff(
    CalendarHostContext actor,
    Transaction tx,
    CalendarScopeRecord scope,
    _Event event,
    CalendarSchedulingMeetingRecord meeting,
    CalendarSchedulingPublicationRecord last,
    CalendarSchedulingPublicationRecord? retry,
    int expectedRevision,
    UuidValue commandId,
    String digest, {
    required bool reopen,
  }) async {
    final options = _scheduling.options;
    final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    final current = event.snapshot;
    final kind = reopen
        ? CalendarSchedulingPublicationKind.seriesReopen
        : CalendarSchedulingPublicationKind.seriesCancel;
    await _schedulingAuthorize(
      actor,
      _wholeCutoffRequests(event, current, reopen),
      tx,
      CalendarAuthorizationPhase.preliminaryWrite,
    );
    final previous = _schedulingReadCheckpoint(
      retry ?? last,
      sharedWorkBudget: work,
    );
    final range = previous.rangeControl;
    if (range == null ||
        !range.active ||
        previous.canonical.eventId != current.eventId ||
        previous.canonical.calendarId != current.calendarId ||
        previous.canonical.protocolUid != current.protocolUid ||
        current.origin != CalendarEventOrigin.native ||
        event.data.importBaseline != null ||
        !_schedulingRecurring(current.content) ||
        meeting.generation != last.generation ||
        meeting.calendarId != current.calendarId ||
        meeting.scopeKey != actor.scopeKey) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (retry != null && previous.kind != kind) {
      throw _failure(CalendarFailureCode.validation);
    }
    CalendarSchedulingPublicationRecord? receipt = retry;
    if (retry == null) {
      _eventRevision(event, expectedRevision);
      if (previous.kind == kind &&
          (current.content.status == CalendarEventStatus.cancelled) ==
              !reopen) {
        receipt = last;
      } else if (reopen
          ? previous.kind != CalendarSchedulingPublicationKind.seriesCancel
          : previous.kind == CalendarSchedulingPublicationKind.seriesCancel) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
    }

    final history = previous.cutoffPredecessor;
    final frozen = history ?? last;
    final frozenCheckpoint = history == null
        ? previous
        : _schedulingReadCheckpoint(history, sharedWorkBudget: work);
    final source = _schedulingValue(
      () => _schedulingCutoffBasis(frozenCheckpoint, work),
    );
    final recipients = _schedulingAddresses(
      (receipt ?? last).recipients,
      options.maxRecipients,
    );
    Future<CalendarSchedulingAuthority> resolve() async => _schedulingAuthority(
      await _bounded(
        () =>
            _scheduling.host.resolve(_session, actor, current, recipients, tx),
      ),
      recipients,
    );
    final authority = await resolve();
    if (authority.organizerAddress != meeting.organizerAddress ||
        authority.authorityRef != meeting.authorityRef ||
        jsonEncode(recipients) != jsonEncode(last.recipients)) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    if (receipt != null) {
      final retained = await CalendarSchedulingDeliveryRecord.db.find(
        _session,
        where: (row) => row.publicationId.equals(receipt!.id!),
        limit: options.maxRecipients + 1,
        transaction: tx,
      );
      if (retained.length != authority.routes.length ||
          authority.routes.any(
            (route) => !retained.any(
              (delivery) =>
                  delivery.scopeKey == actor.scopeKey &&
                  delivery.recipientAddress == route.address &&
                  delivery.routeRef == route.routeRef,
            ),
          )) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
    }

    var proposed = current;
    var publication = receipt;
    var checkpoint = previous;
    final queuedAt = await _revisionTime(tx);
    final now = queuedAt.isBefore(current.updatedAt)
        ? current.updatedAt
        : queuedAt;
    if (receipt == null) {
      final retained = await CalendarSchedulingPublicationRecord.db.find(
        _session,
        where: (row) => row.meetingId.equals(meeting.id!),
        limit: options.maxRetainedPublications,
        transaction: tx,
      );
      if (retained.length >= options.maxRetainedPublications ||
          current.revision >= CalendarService._maxRevision ||
          meeting.generation >= CalendarService._maxRevision ||
          meeting.revision >= CalendarService._maxRevision ||
          !reopen &&
              [current.revision, meeting.generation, meeting.revision].any(
                (value) => value >= CalendarService._maxRevision - 1,
              )) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final pending = await CalendarSchedulingDeliveryRecord.db.count(
        _session,
        where: (row) =>
            row.publicationId.inSet(retained.map((row) => row.id!).toSet()) &
            row.terminalAt.equals(null),
        transaction: tx,
      );
      if (pending != 0) throw _failure(CalendarFailureCode.dependencyConflict);
      final scopePending = await CalendarSchedulingDeliveryRecord.db.count(
        _session,
        where: (row) =>
            row.scopeKey.equals(actor.scopeKey) & row.terminalAt.equals(null),
        transaction: tx,
      );
      if (scopePending + recipients.length > options.maxScopeDeliveries) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }

      final content = current.content.copyWith(
        status: reopen ? source.content.status : CalendarEventStatus.cancelled,
      );
      final state = _eventProtocolValue(
        () => advanceEventProtocol(
          current.protocolState!,
          current.content,
          current.timingOverrides,
          content,
          current.timingOverrides,
          now,
        ),
      );
      proposed = CalendarEventPolicySnapshot(
        current.eventId,
        current.calendarId,
        current.revision + 1,
        content,
        current.protocolUid,
        now,
        origin: current.origin,
        timingOverrides: current.timingOverrides,
        protocolState: state,
      );
      final (frozenFloor, frozenStamp) = _schedulingCutoffFloor(
        frozen,
        frozenCheckpoint,
        proposed,
        eventProtocolInstant(now),
      );
      final (currentFloor, stamp) = _schedulingCutoffFloor(
        last,
        previous,
        proposed,
        frozenStamp,
      );
      final floor = max(currentFloor, frozenFloor);
      if (floor >= eventMaxSequence) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final basis = _schedulingValue(
        () => _schedulingRangeSource(
          frozenCheckpoint,
          sharedWorkBudget: work,
        ),
      );
      final (reopening, suffix) = _schedulingValue(
        () => composePublishedCutoffReopening(
          basis: basis,
          cutoff: range.anchor,
          individualMasks: previous.cancelled.map((row) => row.point).toList(),
          sequenceFloor: reopen ? floor : floor + 1,
          stamp: stamp,
          maxBytes: options.maxPayloadBytes,
          work: work,
        ),
      );
      if (!reopen) {
        _schedulingV4Projection(
          CalendarSchedulingPublicationKind.seriesReopen,
          range.anchor,
          _schedulingComponents(reopening),
          version: 9,
        );
      }
      final message = reopen
          ? reopening
          : _schedulingValue(
              () => _schedulingWholeCutoffCancel(
                source,
                floor + 1,
                stamp,
                options.maxPayloadBytes,
                work,
              ),
            );
      final payload = utf8.decode(serializeIcalendarSchedulingMessage(message));
      final owned =
          range.installedRevision == current.revision &&
          range.installedKey == _schedulingCanonicalKey(current) &&
          _replySamePoint(current.timingOverrides?.cancelledFrom, range.anchor);
      _SchedulingRangeControl controlFor(CalendarEventPolicySnapshot value) =>
          owned
          ? _SchedulingRangeControl(
              range.anchor,
              true,
              range.sequence,
              range.stamp,
              installedRevision: value.revision,
              installedKey: _schedulingCanonicalKey(value),
            )
          : range;
      String encodeSnapshot(
        CalendarSchedulingPublicationKind action,
        CalendarEventPolicySnapshot value,
        int versionFloor,
      ) => _schedulingBound(
        jsonEncode({
          'version': 9,
          'kind': action.name,
          'predecessor': _schedulingFreezeCutoff(frozen),
          'canonical': _schedulingSnapshotMap(value),
          'range': controlFor(value).toJson(),
          'floor': versionFloor,
          'suffix': suffix.exclusions.map((point) => point.toJson()).toList(),
        }),
      );
      if (!reopen) {
        final reopenedContent = content.copyWith(status: source.content.status);
        final reopenedState = _eventProtocolValue(
          () => advanceEventProtocol(
            state,
            content,
            current.timingOverrides,
            reopenedContent,
            current.timingOverrides,
            now,
          ),
        );
        encodeSnapshot(
          CalendarSchedulingPublicationKind.seriesReopen,
          CalendarEventPolicySnapshot(
            current.eventId,
            current.calendarId,
            proposed.revision + 1,
            reopenedContent,
            current.protocolUid,
            now,
            origin: current.origin,
            timingOverrides: current.timingOverrides,
            protocolState: reopenedState,
          ),
          floor + 1,
        );
      }
      final snapshot = encodeSnapshot(kind, proposed, floor);
      publication = CalendarSchedulingPublicationRecord(
        scopeKey: actor.scopeKey,
        meetingId: meeting.id!,
        generation: meeting.generation + 1,
        method: reopen ? 'REQUEST' : 'CANCEL',
        protocolUid: current.protocolUid,
        sequence: floor + 1,
        stamp: stamp,
        snapshot: snapshot,
        projection: _schedulingV4Projection(
          kind,
          range.anchor,
          _schedulingComponents(message),
          version: 9,
        ),
        payload: payload,
        payloadDigest: _schedulingDigest(payload),
        recipients: recipients,
        commandId: commandId,
        actorId: actor.principalId,
        requestDigest: digest,
        expectedRevision: expectedRevision,
        eventRevision: proposed.revision,
        createdAt: queuedAt,
        expiresAt: queuedAt.add(options.expiry),
        outcome: 'pending',
      );
      checkpoint = _schedulingReadCheckpoint(
        publication,
        sharedWorkBudget: work,
      );
    }
    final prepared = publication!;
    final intent = CalendarSchedulingIntent(
      method: prepared.method,
      publicationKind: checkpoint.kind,
      originalStart: range.anchor,
      organizerAddress: authority.organizerAddress,
      recipients: recipients,
      payload: prepared.payload,
      publicationId: receipt?.id,
      generation: prepared.generation,
    );
    final context = CalendarSchedulingPolicyContext(
      scopeKey: actor.scopeKey,
      actor: actor,
      calendar: event.parent.snapshot,
      currentEvent: current,
      proposedEvent: proposed,
      publicationEvent: checkpoint.canonical,
      publishedRequest: source,
      publicationExclusions: checkpoint.publicationExclusions ?? const [],
      suffixMask: CalendarSchedulingSuffixMask(
        range.anchor,
        checkpoint.suffixExclusions!,
      ),
      outgoingMessage: checkpoint.message,
      payloadDigest: prepared.payloadDigest,
      authority: authority,
      intent: intent,
    );
    final requests = _wholeCutoffRequests(event, proposed, reopen, intent);
    await _schedulingAuthorize(
      actor,
      requests,
      tx,
      CalendarAuthorizationPhase.preliminaryWrite,
    );
    await _schedulingHostCheck(
      context,
      tx,
      CalendarAuthorizationPhase.preliminaryWrite,
    );
    if (_schedulingAuthorityKey(await resolve()) !=
        _schedulingAuthorityKey(authority)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    await _schedulingHostCheck(
      context,
      tx,
      CalendarAuthorizationPhase.finalWrite,
    );
    await _schedulingAuthorize(
      actor,
      requests,
      tx,
      CalendarAuthorizationPhase.finalWrite,
    );
    if (receipt != null) {
      return CalendarSchedulingReceipt(
        publicationId: receipt.id!,
        eventRevision: receipt.eventRevision,
        unchanged: true,
      );
    }

    final saved = await CalendarSchedulingPublicationRecord.db.insertRow(
      _session,
      prepared,
      transaction: tx,
    );
    await CalendarSchedulingDeliveryRecord.db.insert(_session, [
      for (final route in authority.routes)
        CalendarSchedulingDeliveryRecord(
          scopeKey: actor.scopeKey,
          publicationId: saved.id!,
          recipientAddress: route.address,
          routeRef: route.routeRef,
          nextAttemptAt: queuedAt,
        ),
    ], transaction: tx);
    meeting.generation = saved.generation;
    meeting.revision++;
    meeting.latestPublicationId = saved.id;
    meeting.updatedAt = now;
    await _inactivateReplySources(meeting, saved, tx, queuedAt);
    await CalendarSchedulingMeetingRecord.db.updateRow(
      _session,
      meeting,
      transaction: tx,
    );
    event.data.content = proposed.content;
    event.data.protocolState = proposed.protocolState;
    event.data.updatedAt = now;
    event.identity.revision = proposed.revision;
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
    await _bump(
      scope,
      tx,
      publishedEventCalendar: proposed.content.status != current.content.status
          ? current.calendarId
          : null,
    );
    return CalendarSchedulingReceipt(
      publicationId: saved.id!,
      eventRevision: saved.eventRevision,
      unchanged: false,
    );
  }
}
