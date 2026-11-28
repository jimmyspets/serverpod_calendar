part of 'calendar_module.dart';

extension CalendarSchedulingRangeOperations on CalendarService {
  Future<CalendarSchedulingReceipt> cancelFutureAndNotify(
    CalendarSchedulingFutureCancelRequest input,
  ) => _changeSchedulingRange(
    input.eventId,
    input.expectedRevision,
    input.commandId,
    input.originalStart,
    restore: false,
  );
  Future<CalendarSchedulingReceipt> restoreFutureAndNotify(
    CalendarSchedulingFutureRestoreRequest input,
  ) => _changeSchedulingRange(
    input.eventId,
    input.expectedRevision,
    input.commandId,
    input.originalStart,
    restore: true,
  );

  Future<CalendarSchedulingReceipt> _changeSchedulingRange(
    UuidValue eventId,
    int expectedRevision,
    UuidValue commandId,
    CalendarEventTiming point, {
    required bool restore,
  }) async {
    final kind = restore
        ? CalendarSchedulingPublicationKind.rangeRestore
        : CalendarSchedulingPublicationKind.rangeCancel;
    final method = restore ? 'REQUEST' : 'CANCEL';
    final digest = _schedulingDigest(
      jsonEncode([
        kind.name,
        eventId.toString(),
        expectedRevision,
        point.toJson(),
      ]),
    );
    final c = await _context();
    final options = _scheduling.options;
    return _transaction(c, (tx, scope) async {
      final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
      final e = await _event(c, eventId, tx);
      List<CalendarAuthorizationRequest> requests(
        CalendarSchedulingIntent? intent,
        CalendarEventPolicySnapshot proposed,
      ) => [
        for (final op in [
          restore
              ? CalendarPermission.restoreFutureScheduling
              : CalendarPermission.cancelFutureScheduling,
          CalendarPermission.readScheduling,
          CalendarPermission.readEvent,
          CalendarPermission.readEventSource,
          CalendarPermission.changeEventStatus,
        ])
          CalendarAuthorizationRequest(
            key: '${op.name}:${e.identity.id}',
            operation: op,
            calendarId: e.parent.identity.id,
            current: e.parent.snapshot,
            eventId: e.identity.id,
            currentEvent: e.snapshot,
            proposedEvent: proposed.content,
            proposedEventProtocolState: proposed.protocolState,
            proposedTimingOverrides: proposed.timingOverrides,
            scheduling: intent,
            eventGroups: CalendarEventFieldGroup.values,
          ),
      ];
      await _schedulingAuthorize(
        c,
        requests(null, e.snapshot),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final meeting = await _meeting(e.identity.id!, tx);
      final last = await _latest(meeting, tx);
      if (meeting == null ||
          last == null ||
          e.data.origin != CalendarEventOrigin.native ||
          e.data.importBaseline != null) {
        throw _failure(CalendarFailureCode.validation);
      }
      final previous = _schedulingReadCheckpoint(last);
      if (previous.canonical.eventId != e.identity.id ||
          previous.canonical.calendarId != e.identity.calendarId ||
          previous.outgoing.protocolUid != e.data.protocolUid) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final retry = await CalendarSchedulingPublicationRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(c.scopeKey) & t.commandId.equals(commandId),
        transaction: tx,
      );
      if (retry != null &&
          (retry.requestDigest != digest ||
              retry.actorId != c.principalId ||
              retry.meetingId != meeting.id ||
              _schedulingReadCheckpoint(retry).kind != kind)) {
        throw _failure(CalendarFailureCode.validation);
      }
      final range = previous.rangeControl;
      CalendarSchedulingPublicationRecord? receipt = retry;
      final basis = _schedulingReadCheckpoint(
        previous.basisRecord ?? _schedulingRangeCurrent(last),
      );
      if (retry == null) {
        _eventRevision(e, expectedRevision);
        if (!_schedulingRecurring(previous.outgoing.content) ||
            e.data.content.status == CalendarEventStatus.cancelled ||
            previous.kind == CalendarSchedulingPublicationKind.seriesCancel) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        if (range != null &&
            _replySamePoint(range.anchor, point) &&
            range.active == !restore &&
            previous.kind == kind) {
          receipt = last;
        }
        if (receipt == null &&
            (restore ? range?.active != true : range?.active == true)) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        if (restore &&
            (range == null || !_replySamePoint(range.anchor, point))) {
          throw _failure(CalendarFailureCode.validation);
        }
        if (!restore &&
            previous.individuals.any((s) => _replySamePoint(s.point, point))) {
          throw _failure(CalendarFailureCode.validation);
        }
        if (!_schedulingValue(
          () => eventSchedulingMember(
            previous.outgoing.content,
            point,
            sharedWorkBudget: work,
          ),
        )) {
          throw _failure(CalendarFailureCode.validation);
        }
      }
      if (receipt == null) {
        final publications = await CalendarSchedulingPublicationRecord.db.find(
          _session,
          where: (p) => p.meetingId.equals(meeting.id!),
          limit: options.maxRetainedPublications + 1,
          transaction: tx,
        );
        if (publications.length > options.maxRetainedPublications) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final pending = await CalendarSchedulingDeliveryRecord.db.count(
          _session,
          where: (t) =>
              t.publicationId.inSet(publications.map((p) => p.id!).toSet()) &
              t.terminalAt.equals(null),
          transaction: tx,
        );
        if (pending != 0) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
      }
      final matches = _schedulingValue(
        () => eventSchedulingMember(
          e.data.content,
          point,
          sharedWorkBudget: work,
        ),
      );
      final content = e.data.content;
      var edits = e.data.timingOverrides;
      var installed = false;
      if (receipt == null &&
          !restore &&
          matches &&
          edits?.cancelledFrom == null) {
        edits = changeEventOverrides(
          content,
          edits,
          CalendarEventOccurrenceChange(
            eventId: eventId,
            expectedRevision: e.identity.revision,
            originalStart: point,
            action: CalendarEventOccurrenceAction.cancelFuture,
          ),
        );
        installed = true;
      } else if (receipt == null &&
          restore &&
          range!.installedRevision == e.identity.revision &&
          range.installedKey == _schedulingCanonicalKey(e.snapshot) &&
          _replySamePoint(edits?.cancelledFrom, point)) {
        edits = changeEventOverrides(
          content,
          edits,
          CalendarEventOccurrenceChange(
            eventId: eventId,
            expectedRevision: e.identity.revision,
            originalStart: point,
            action: CalendarEventOccurrenceAction.restoreFuture,
          ),
        );
      }
      final nativeChanged =
          jsonEncode(edits?.toJson()) !=
          jsonEncode(e.data.timingOverrides?.toJson());
      final queuedAt = await _revisionTime(tx);
      final now = queuedAt.isAfter(e.data.updatedAt)
          ? queuedAt
          : e.data.updatedAt;
      final state = receipt != null || !nativeChanged
          ? e.data.protocolState!
          : _eventProtocolValue(
              () => advanceEventProtocol(
                e.data.protocolState!,
                e.data.content,
                e.data.timingOverrides,
                content,
                edits,
                now,
              ),
            );
      final proposed = CalendarEventPolicySnapshot(
        e.identity.id!,
        e.identity.calendarId,
        receipt != null ? e.identity.revision : e.identity.revision + 1,
        receipt != null ? e.data.content : content,
        e.data.protocolUid,
        receipt != null ? e.data.updatedAt : now,
        origin: e.data.origin,
        timingOverrides: receipt != null ? e.data.timingOverrides : edits,
        protocolState: state,
      );
      final proposals = _schedulingAddresses(
        last.recipients,
        options.maxRecipients,
      );
      final authority = _schedulingAuthority(
        await _bounded(
          () => _scheduling.host.resolve(
            _session,
            c,
            e.snapshot,
            proposals,
            tx,
          ),
        ),
        proposals,
      );
      if (meeting.scopeKey != c.scopeKey ||
          meeting.calendarId != e.identity.calendarId ||
          authority.organizerAddress != meeting.organizerAddress ||
          authority.authorityRef != meeting.authorityRef) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      var sequence = 0;
      var stamp = eventProtocolInstant(now);
      CalendarSchedulingPublicationRecord current = _schedulingRangeCurrent(
        last,
      );
      _SchedulingRangeControl? control;
      String payload;
      if (receipt != null) {
        payload = receipt.payload;
      } else {
        for (final v in previous.ledger.followedBy(
          previous.individuals.map((s) => s.version),
        )) {
          sequence = max(sequence, v.sequence);
          if (v.stamp.isAfter(stamp)) stamp = v.stamp;
        }
        sequence = max(sequence, range?.sequence ?? 0);
        if (range != null && range.stamp.isAfter(stamp)) stamp = range.stamp;
        for (final v in [
          e.data.protocolState!.version,
          ...e.data.protocolState!.overrides.map((o) => o.version),
          state.version,
          ...state.overrides.map((o) => o.version),
        ]) {
          sequence = max(sequence, v.sequence ?? 0);
          if (v.stamp.isAfter(stamp)) stamp = v.stamp;
          if (v.lastModified != null && v.lastModified!.isAfter(stamp)) {
            stamp = v.lastModified!;
          }
        }
        if (restore) {
          current = _schedulingValue(
            () => _schedulingRangeRestored(
              last,
              previous,
              proposed,
              point,
              sequence,
              stamp,
              options.maxPayloadBytes,
              sharedWorkBudget: work,
            ),
          );
          _schedulingReadCheckpoint(current);
          payload = current.payload;
          sequence = current.sequence;
          control = _SchedulingRangeControl(point, false, sequence, stamp);
        } else {
          sequence++;
          if (sequence > eventMaxSequence) {
            throw _failure(CalendarFailureCode.limitExceeded);
          }
          // Fully validate restoration and its final v7 footprint before admitting CANCEL.
          final restored = _schedulingValue(
            () => _schedulingRangeRestored(
              last,
              previous,
              proposed,
              point,
              sequence,
              stamp,
              options.maxPayloadBytes,
              sharedWorkBudget: work,
            ),
          );
          _schedulingReadCheckpoint(restored);
          _schedulingWriteV7(
            restored,
            _SchedulingRangeControl(point, false, restored.sequence, stamp),
            CalendarSchedulingPublicationKind.rangeRestore,
            canonical: proposed,
          );
          final cancelled = _schedulingValue(
            () => projectPublishedRangeCancellation(
              basis: _schedulingRangeSource(previous),
              originalStart: point,
              sequence: sequence,
              stamp: stamp,
              maxBytes: options.maxPayloadBytes,
              sharedWorkBudget: work,
            ),
          );
          payload = utf8.decode(
            serializeIcalendarSchedulingMessage(cancelled.message),
          );
          control = _SchedulingRangeControl(
            point,
            true,
            sequence,
            stamp,
            installedRevision: installed ? proposed.revision : null,
            installedKey: installed ? _schedulingCanonicalKey(proposed) : null,
          );
        }
      }
      final outgoing = _schedulingValue(
        () => parseIcalendarSchedulingMessage(
          utf8.encode(payload),
          syntaxLimits: IcalendarSyntaxLimits(
            maxBytes: options.maxPayloadBytes,
          ),
          sharedWorkBudget: work,
        ),
      );
      final checkedReceipt = receipt == null
          ? null
          : _schedulingReadCheckpoint(receipt);
      final intent = CalendarSchedulingIntent(
        method: method,
        publicationKind: checkedReceipt?.kind ?? kind,
        originalStart: checkedReceipt?.target ?? point,
        organizerAddress: authority.organizerAddress,
        recipients: proposals,
        payload: payload,
        publicationId: receipt?.id,
        generation: receipt?.generation ?? meeting.generation + 1,
      );
      final context = CalendarSchedulingPolicyContext(
        scopeKey: c.scopeKey,
        actor: c,
        calendar: e.parent.snapshot,
        currentEvent: e.snapshot,
        proposedEvent: proposed,
        publicationEvent: checkedReceipt?.canonical ?? proposed,
        publishedRequest: basis.outgoing,
        exactNativeMatch: matches,
        publicationExclusions: previous.publicationExclusions ?? const [],
        outgoingMessage: outgoing,
        payloadDigest: _schedulingDigest(payload),
        authority: authority,
        intent: intent,
      );
      final auth = requests(intent, proposed);
      await _schedulingAuthorize(
        c,
        auth,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      await _schedulingHostCheck(
        context,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final checked = _schedulingAuthority(
        await _bounded(
          () => _scheduling.host.resolve(
            _session,
            c,
            e.snapshot,
            proposals,
            tx,
          ),
        ),
        proposals,
      );
      if (_schedulingAuthorityKey(checked) !=
          _schedulingAuthorityKey(authority)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await _schedulingHostCheck(
        context,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      await _schedulingAuthorize(
        c,
        auth,
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
      if (meeting.generation >= CalendarService._maxRevision ||
          meeting.revision >= CalendarService._maxRevision ||
          e.identity.revision >= CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final retained = await CalendarSchedulingPublicationRecord.db.count(
        _session,
        where: (t) => t.meetingId.equals(meeting.id!),
        transaction: tx,
      );
      final scopePending = await CalendarSchedulingDeliveryRecord.db.count(
        _session,
        where: (t) => t.scopeKey.equals(c.scopeKey) & t.terminalAt.equals(null),
        transaction: tx,
      );
      if (retained >= options.maxRetainedPublications ||
          scopePending + proposals.length > options.maxScopeDeliveries) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final snapshot = _schedulingWriteV7(
        current,
        control!,
        kind,
        canonical: proposed,
        comparison: _schedulingRangeComparison(previous, control),
      );
      final p = await CalendarSchedulingPublicationRecord.db.insertRow(
        _session,
        CalendarSchedulingPublicationRecord(
          scopeKey: c.scopeKey,
          meetingId: meeting.id!,
          generation: meeting.generation + 1,
          method: method,
          protocolUid: e.data.protocolUid,
          sequence: sequence,
          stamp: stamp,
          snapshot: snapshot,
          projection: restore
              ? current.projection
              : _schedulingV4Projection(
                  kind,
                  point,
                  outgoing.events.map(_schedulingComponent).toList(),
                  version: 7,
                ),
          payload: payload,
          payloadDigest: _schedulingDigest(payload),
          recipients: proposals,
          commandId: commandId,
          actorId: c.principalId,
          requestDigest: digest,
          expectedRevision: expectedRevision,
          eventRevision: proposed.revision,
          createdAt: queuedAt,
          expiresAt: queuedAt.add(options.expiry),
          outcome: 'pending',
        ),
        transaction: tx,
      );
      // Run the complete private validator before committing any checkpoint.
      _schedulingReadCheckpoint(p);
      await CalendarSchedulingDeliveryRecord.db.insert(_session, [
        for (final r in authority.routes)
          CalendarSchedulingDeliveryRecord(
            scopeKey: c.scopeKey,
            publicationId: p.id!,
            recipientAddress: r.address,
            routeRef: r.routeRef,
            nextAttemptAt: queuedAt,
          ),
      ], transaction: tx);
      meeting.generation++;
      meeting.revision++;
      meeting.latestPublicationId = p.id;
      meeting.updatedAt = now;
      await _inactivateReplySources(meeting, p, tx, queuedAt);
      await CalendarSchedulingMeetingRecord.db.updateRow(
        _session,
        meeting,
        transaction: tx,
      );
      e.data.content = content;
      e.data.timingOverrides = edits;
      e.data.protocolState = state;
      e.data.updatedAt = now;
      e.identity.revision = proposed.revision;
      await CalendarEventDataRecord.db.updateRow(
        _session,
        e.data,
        transaction: tx,
      );
      await CalendarEventRecord.db.updateRow(
        _session,
        e.identity,
        transaction: tx,
      );
      await _bump(
        scope,
        tx,
        publishedEventCalendar: nativeChanged ? e.identity.calendarId : null,
      );
      return CalendarSchedulingReceipt(
        publicationId: p.id!,
        eventRevision: proposed.revision,
        unchanged: false,
      );
    });
  }
}
