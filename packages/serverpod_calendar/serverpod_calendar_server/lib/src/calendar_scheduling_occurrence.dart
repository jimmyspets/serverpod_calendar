part of 'calendar_module.dart';

extension CalendarSchedulingOccurrenceOperations on CalendarService {
  Future<CalendarSchedulingReceipt> cancelOccurrenceAndNotify(
    CalendarSchedulingOccurrenceCancelRequest input,
  ) async {
    final point = input.originalStart;
    final digest = _schedulingDigest(
      jsonEncode([
        'occurrenceCancel',
        input.eventId.toString(),
        input.expectedRevision,
        point.toJson(),
      ]),
    );
    final c = await _context();
    final options = _scheduling.options;
    return _transaction(c, (tx, scope) async {
      final e = await _event(c, input.eventId, tx);
      List<CalendarAuthorizationRequest> requests(
        CalendarSchedulingIntent? intent,
        CalendarEventPolicySnapshot proposed,
      ) => [
        for (final op in [
          CalendarPermission.cancelOccurrenceScheduling,
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
            t.scopeKey.equals(c.scopeKey) & t.commandId.equals(input.commandId),
        transaction: tx,
      );
      if (retry != null &&
          (retry.requestDigest != digest ||
              retry.actorId != c.principalId ||
              retry.meetingId != meeting.id ||
              _schedulingReadCheckpoint(retry).kind !=
                  CalendarSchedulingPublicationKind.occurrenceCancel)) {
        throw _failure(CalendarFailureCode.validation);
      }
      final receiptCheckpoint = retry == null
          ? null
          : _schedulingReadCheckpoint(retry);
      final basisRecord =
          receiptCheckpoint?.basisRecord ?? previous.basisRecord;
      if (basisRecord == null) throw _failure(CalendarFailureCode.validation);
      final basis = _schedulingReadCheckpoint(basisRecord);
      // Never treat validation/work failures as an absent native occurrence.
      _schedulingValue(() => _schedulingHistoricalTarget(basis, point));
      if (retry == null &&
          previous.kind == CalendarSchedulingPublicationKind.seriesCancel) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      if (retry == null) _eventRevision(e, input.expectedRevision);
      final matches = _schedulingValue(
        () => eventSchedulingMember(e.data.content, point),
      );
      final edits = retry != null || !matches
          ? e.data.timingOverrides
          : _schedulingValue(
              () => changeEventOverrides(
                e.data.content,
                e.data.timingOverrides,
                CalendarEventOccurrenceChange(
                  eventId: e.identity.id!,
                  expectedRevision: e.identity.revision,
                  originalStart: point,
                  action: CalendarEventOccurrenceAction.cancelSingle,
                ),
              ),
            );
      final nativeChanged =
          jsonEncode(edits?.toJson()) !=
          jsonEncode(e.data.timingOverrides?.toJson());
      final priorCancellation = previous.cancelled
          .where(
            (r) =>
                eventComponentKey(r.point, false) ==
                eventComponentKey(point, false),
          )
          .firstOrNull;
      final unchanged =
          retry == null && priorCancellation != null && !nativeChanged;
      // A no-op targets the original's own immutable receipt, not another instance.
      CalendarSchedulingPublicationRecord? receipt = retry;
      var prunedNoopReceipt = false;
      if (unchanged) {
        final candidates = await CalendarSchedulingPublicationRecord.db.find(
          _session,
          where: (t) => t.meetingId.equals(meeting.id!),
          orderBy: (t) => t.generation,
          limit: options.maxRetainedPublications + 1,
          transaction: tx,
        );
        receipt = candidates.where((p) => p.method == 'CANCEL').where((p) {
          final check = _schedulingReadCheckpoint(p);
          return check.kind ==
                  CalendarSchedulingPublicationKind.occurrenceCancel &&
              eventComponentKey(check.target!, false) ==
                  eventComponentKey(point, false) &&
              p.sequence == priorCancellation.version.sequence;
        }).firstOrNull;
        // Retention may have removed that receipt. The self-contained latest
        // checkpoint still proves the no-op; return it without inventing a row.
        if (receipt == null) {
          prunedNoopReceipt = true;
          receipt = last;
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
        final ids = publications.map((p) => p.id!).toSet();
        final pending = await CalendarSchedulingDeliveryRecord.db.count(
          _session,
          where: (t) =>
              t.scopeKey.equals(c.scopeKey) &
              t.terminalAt.equals(null) &
              t.publicationId.inSet(ids),
          transaction: tx,
        );
        if (pending != 0) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
      }
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
                e.data.content,
                edits,
                now,
              ),
            );
      final proposed = CalendarEventPolicySnapshot(
        e.identity.id!,
        e.identity.calendarId,
        receipt != null ? e.identity.revision : e.identity.revision + 1,
        e.data.content,
        e.data.protocolUid,
        receipt != null ? e.data.updatedAt : now,
        origin: e.data.origin,
        timingOverrides: receipt != null ? e.data.timingOverrides : edits,
        protocolState: state,
      );
      final authority = _schedulingAuthority(
        await _bounded(
          () => _scheduling.host.resolve(
            _session,
            c,
            e.snapshot,
            last.recipients,
            tx,
          ),
        ),
        last.recipients,
      );
      if (meeting.scopeKey != c.scopeKey ||
          meeting.calendarId != e.identity.calendarId ||
          authority.organizerAddress != meeting.organizerAddress ||
          authority.authorityRef != meeting.authorityRef) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final history = [...previous.cancelled];
      var sequence = 0;
      var stamp = eventProtocolInstant(now);
      String payload;
      if (receipt != null) {
        // A retained command retry uses its original exact bytes. A current
        // no-op whose old row was pruned authorizes the latest retained message.
        payload = prunedNoopReceipt
            ? _schedulingInstancePayload(
                basis,
                point,
                priorCancellation!.version.sequence,
                priorCancellation.version.stamp,
                options.maxPayloadBytes,
              )
            : receipt.payload;
      } else {
        final sample = parseIcalendarSchedulingMessage(
          utf8.encode(
            _schedulingInstancePayload(
              basis,
              point,
              0,
              stamp,
              options.maxPayloadBytes,
            ),
          ),
        );
        final key = _schedulingComponent(sample.events.single).key;
        final floor = basis.ledger.firstWhere(
          (v) => v.key == key,
          orElse: () => basis.ledger.singleWhere((v) => v.key == 'master'),
        );
        sequence = max(
          floor.sequence,
          priorCancellation?.version.sequence ?? -1,
        );
        if (floor.stamp.isAfter(stamp)) stamp = floor.stamp;
        if (priorCancellation != null &&
            priorCancellation.version.stamp.isAfter(stamp)) {
          stamp = priorCancellation.version.stamp;
        }
        for (final v in [
          state.version,
          ...state.overrides
              .where(
                (o) =>
                    eventComponentKey(o.originalStart, false) ==
                    eventComponentKey(point, false),
              )
              .map((o) => o.version),
        ]) {
          sequence = max(sequence, v.sequence ?? 0);
          if (v.stamp.isAfter(stamp)) stamp = v.stamp;
          if (v.lastModified != null && v.lastModified!.isAfter(stamp)) {
            stamp = v.lastModified!;
          }
        }
        sequence++;
        if (sequence > eventMaxSequence) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        payload = _schedulingValue(
          () => _schedulingInstancePayload(
            basis,
            point,
            sequence,
            stamp,
            options.maxPayloadBytes,
          ),
        );
        final version = _schedulingComponent(
          parseIcalendarSchedulingMessage(utf8.encode(payload)).events.single,
        );
        history.removeWhere(
          (r) =>
              eventComponentKey(r.point, false) ==
              eventComponentKey(point, false),
        );
        history.add(_SchedulingCancellation(point, version));
        final union = {
          ...basis.originals.map(
            (o) => eventComponentKey(o.originalStart, false),
          ),
          ...history.map((r) => eventComponentKey(r.point, false)),
        };
        if (union.length > 64) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
      }
      final outgoing = _schedulingValue(
        () => parseIcalendarSchedulingMessage(
          utf8.encode(payload),
          syntaxLimits: IcalendarSyntaxLimits(
            maxBytes: options.maxPayloadBytes,
          ),
        ),
      );
      final checkedReceipt = receipt == null || prunedNoopReceipt
          ? null
          : _schedulingReadCheckpoint(receipt);
      final intent = CalendarSchedulingIntent(
        method: 'CANCEL',
        publicationKind:
            checkedReceipt?.kind ??
            CalendarSchedulingPublicationKind.occurrenceCancel,
        originalStart: checkedReceipt?.target ?? point,
        organizerAddress: authority.organizerAddress,
        recipients: last.recipients,
        payload: payload,
        // A pruned no-op reconstructs the requested target from the ledger; it
        // must not claim that another target's latest receipt owns those bytes.
        publicationId: prunedNoopReceipt ? null : receipt?.id,
        generation: receipt?.generation ?? meeting.generation + 1,
      );
      final context = CalendarSchedulingPolicyContext(
        scopeKey: c.scopeKey,
        actor: c,
        calendar: e.parent.snapshot,
        currentEvent: e.snapshot,
        proposedEvent: proposed,
        publicationEvent:
            checkedReceipt?.canonical ??
            (prunedNoopReceipt ? previous.canonical : proposed),
        publishedRequest: basis.outgoing,
        exactNativeMatch: matches,
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
            last.recipients,
            tx,
          ),
        ),
        last.recipients,
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
          scopePending + last.recipients.length > options.maxScopeDeliveries) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final snapshot = _schedulingWriteV4(
        canonical: proposed,
        kind: CalendarSchedulingPublicationKind.occurrenceCancel,
        basis: basisRecord,
        cancelled: history,
        target: point,
        nativeMatch: matches,
      );
      final p = await CalendarSchedulingPublicationRecord.db.insertRow(
        _session,
        CalendarSchedulingPublicationRecord(
          scopeKey: c.scopeKey,
          meetingId: meeting.id!,
          generation: meeting.generation + 1,
          method: 'CANCEL',
          protocolUid: e.data.protocolUid,
          sequence: sequence,
          stamp: stamp,
          snapshot: snapshot,
          projection: _schedulingV4Projection(
            CalendarSchedulingPublicationKind.occurrenceCancel,
            point,
            [_schedulingComponent(outgoing.events.single)],
          ),
          payload: payload,
          payloadDigest: _schedulingDigest(payload),
          recipients: last.recipients,
          commandId: input.commandId,
          actorId: c.principalId,
          requestDigest: digest,
          expectedRevision: input.expectedRevision,
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
      await CalendarSchedulingMeetingRecord.db.updateRow(
        _session,
        meeting,
        transaction: tx,
      );
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
