part of 'calendar_module.dart';

extension CalendarSchedulingOccurrenceOperations on CalendarService {
  Future<CalendarSchedulingReceipt> cancelOccurrenceAndNotify(
    CalendarSchedulingOccurrenceCancelRequest input,
  ) => _changeSchedulingOccurrence(
    input.eventId,
    input.expectedRevision,
    input.commandId,
    input.originalStart,
    restore: false,
  );

  Future<CalendarSchedulingReceipt> restoreOccurrenceAndNotify(
    CalendarSchedulingOccurrenceRestoreRequest input,
  ) => _changeSchedulingOccurrence(
    input.eventId,
    input.expectedRevision,
    input.commandId,
    input.originalStart,
    restore: true,
  );

  Future<CalendarSchedulingReceipt> reopenPublishedAndNotify(
    CalendarSchedulingReopenRequest input,
  ) => _changeSchedulingOccurrence(
    input.eventId,
    input.expectedRevision,
    input.commandId,
    null,
    restore: false,
    reopen: true,
  );

  Future<CalendarSchedulingReceipt> _changeSchedulingOccurrence(
    UuidValue eventId,
    int expectedRevision,
    UuidValue commandId,
    CalendarEventTiming? point, {
    required bool restore,
    bool reopen = false,
  }) async {
    var kind = reopen
        ? CalendarSchedulingPublicationKind.seriesReopen
        : restore
        ? CalendarSchedulingPublicationKind.occurrenceRestore
        : CalendarSchedulingPublicationKind.occurrenceCancel;
    final method = restore || reopen ? 'REQUEST' : 'CANCEL';
    final digest = _schedulingDigest(
      jsonEncode([
        kind.name,
        eventId.toString(),
        expectedRevision,
        point?.toJson(),
      ]),
    );
    final c = await _context();
    final options = _scheduling.options;
    return _transaction(c, (tx, scope) async {
      final e = await _event(c, eventId, tx);
      List<CalendarAuthorizationRequest> requests(
        CalendarSchedulingIntent? intent,
        CalendarEventPolicySnapshot proposed,
      ) => [
        for (final op in [
          reopen
              ? CalendarPermission.reopenScheduling
              : restore
              ? CalendarPermission.restoreOccurrenceScheduling
              : CalendarPermission.cancelOccurrenceScheduling,
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
      if (reopen && !_schedulingRecurring(e.data.content)) {
        throw _failure(CalendarFailureCode.validation);
      }
      final projected = reopen || previous.publicationExclusions != null;
      if (restore && projected) {
        kind = CalendarSchedulingPublicationKind.occurrenceRestoreWithMaster;
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
              !(restore
                  ? {
                      CalendarSchedulingPublicationKind.occurrenceRestore,
                      CalendarSchedulingPublicationKind
                          .occurrenceRestoreWithMaster,
                    }.contains(_schedulingReadCheckpoint(retry).kind)
                  : _schedulingReadCheckpoint(retry).kind == kind))) {
        throw _failure(CalendarFailureCode.validation);
      }
      final receiptCheckpoint = retry == null
          ? null
          : _schedulingReadCheckpoint(retry);
      if (receiptCheckpoint != null) kind = receiptCheckpoint.kind;
      final basisRecord =
          receiptCheckpoint?.basisRecord ?? previous.basisRecord;
      if (basisRecord == null) throw _failure(CalendarFailureCode.validation);
      final basis = _schedulingReadCheckpoint(basisRecord);
      // Never treat validation/work failures as an absent native occurrence.
      if (point != null) {
        _schedulingValue(() => _schedulingHistoricalTarget(basis, point));
      }
      if (retry == null &&
          (!reopen &&
                  previous.kind ==
                      CalendarSchedulingPublicationKind.seriesCancel ||
              restore &&
                  e.data.content.status == CalendarEventStatus.cancelled)) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      if (retry == null &&
          reopen &&
          (previous.cancelled.isEmpty ||
              !{
                CalendarSchedulingPublicationKind.seriesCancel,
                CalendarSchedulingPublicationKind.seriesReopen,
              }.contains(previous.kind))) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      if (retry == null) _eventRevision(e, expectedRevision);
      final bool? matches = point == null
          ? null
          : _schedulingValue(
              () => eventSchedulingMember(e.data.content, point),
            );
      final nativeCancelled =
          e.data.timingOverrides?.singles.any(
            (s) =>
                s.cancelled &&
                point != null &&
                eventComponentKey(s.originalStart, false) ==
                    eventComponentKey(point, false),
          ) ??
          false;
      final edits =
          retry != null ||
              reopen ||
              matches != true ||
              restore && !nativeCancelled
          ? e.data.timingOverrides
          : _schedulingValue(
              () => changeEventOverrides(
                e.data.content,
                e.data.timingOverrides,
                CalendarEventOccurrenceChange(
                  eventId: e.identity.id!,
                  expectedRevision: e.identity.revision,
                  originalStart: point!,
                  action: restore
                      ? CalendarEventOccurrenceAction.restoreSingle
                      : CalendarEventOccurrenceAction.cancelSingle,
                ),
              ),
            );
      final content = reopen
          ? e.data.content.copyWith(status: basis.outgoing.content.status)
          : e.data.content;
      final nativeChanged =
          jsonEncode(content.toJson()) != jsonEncode(e.data.content.toJson()) ||
          jsonEncode(edits?.toJson()) !=
              jsonEncode(e.data.timingOverrides?.toJson());
      final priorCancellation =
          (point == null ? <_SchedulingCancellation>[] : previous.individuals)
              .where(
                (r) =>
                    eventComponentKey(r.point, false) ==
                    eventComponentKey(point!, false),
              )
              .firstOrNull;
      if (restore && retry == null && priorCancellation == null) {
        throw _failure(CalendarFailureCode.validation);
      }
      final unchanged = reopen
          ? retry == null &&
                previous.kind ==
                    CalendarSchedulingPublicationKind.seriesReopen &&
                !nativeChanged
          : retry == null &&
                priorCancellation != null &&
                priorCancellation.restored == restore &&
                !nativeChanged;
      if (reopen &&
          retry == null &&
          !unchanged &&
          previous.kind != CalendarSchedulingPublicationKind.seriesCancel) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
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
        receipt = candidates.where((p) => p.method == method).where((p) {
          final check = _schedulingReadCheckpoint(p);
          return check.kind == kind &&
              (reopen ||
                  eventComponentKey(check.target!, false) ==
                      eventComponentKey(point!, false)) &&
              (reopen && p.id == last.id ||
                  !reopen &&
                      (check.kind ==
                                  CalendarSchedulingPublicationKind
                                      .occurrenceRestoreWithMaster
                              ? check.individuals
                                    .singleWhere(
                                      (s) =>
                                          _schedulingWirePointKey(s.point) ==
                                          _schedulingWirePointKey(point!),
                                    )
                                    .version
                                    .sequence
                              : p.sequence) ==
                          priorCancellation!.version.sequence);
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
      final history = [...previous.individuals];
      _SchedulingProjectionBuild? projectionBuild;
      var sequence = 0;
      var stamp = eventProtocolInstant(now);
      String buildPayload(int sequence, DateTime stamp) => restore
          ? _schedulingRestorationPayload(
              basis,
              point!,
              sequence,
              stamp,
              options.maxPayloadBytes,
            )
          : _schedulingInstancePayload(
              basis,
              point!,
              sequence,
              stamp,
              options.maxPayloadBytes,
            );
      String payload;
      if (receipt != null) {
        // A retained command retry uses its original exact bytes. A current
        // no-op whose old row was pruned authorizes the latest retained message.
        payload = prunedNoopReceipt && projected
            ? previous.fullRequestPayload!
            : prunedNoopReceipt
            ? _schedulingValue(
                () => buildPayload(
                  priorCancellation!.version.sequence,
                  priorCancellation.version.stamp,
                ),
              )
            : receipt.payload;
      } else if (reopen || restore && projected) {
        final built = _schedulingValue(
          () => _schedulingProjectedChange(
            last,
            previous,
            e.snapshot,
            proposed,
            point,
            matches,
            reopen,
            now,
            options.maxPayloadBytes,
          ),
        );
        projectionBuild = built;
        payload = built.payload;
        final master = built.ledger.singleWhere(
          (v) => v.key == 'master',
        );
        sequence = master.sequence;
        stamp = master.stamp;
      } else {
        final sample = _schedulingValue(
          () => parseIcalendarSchedulingMessage(
            utf8.encode(buildPayload(0, stamp)),
          ),
        );
        final key = _schedulingComponent(sample.events.single).key;
        final floor = previous.ledger.firstWhere(
          (v) => v.key == key,
          orElse: () => previous.ledger.singleWhere((v) => v.key == 'master'),
        );
        sequence = max(
          max(
            floor.sequence,
            previous.ledger.singleWhere((v) => v.key == 'master').sequence,
          ),
          priorCancellation?.version.sequence ?? -1,
        );
        if (floor.stamp.isAfter(stamp)) stamp = floor.stamp;
        final masterStamp = previous.ledger
            .singleWhere((v) => v.key == 'master')
            .stamp;
        if (masterStamp.isAfter(stamp)) stamp = masterStamp;
        if (priorCancellation != null &&
            priorCancellation.version.stamp.isAfter(stamp)) {
          stamp = priorCancellation.version.stamp;
        }
        for (final v in [
          e.data.protocolState!.version,
          ...e.data.protocolState!.overrides
              .where(
                (o) =>
                    eventComponentKey(o.originalStart, false) ==
                    eventComponentKey(point!, false),
              )
              .map((o) => o.version),
          state.version,
          ...state.overrides
              .where(
                (o) =>
                    eventComponentKey(o.originalStart, false) ==
                    eventComponentKey(point!, false),
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
        payload = _schedulingValue(() => buildPayload(sequence, stamp));
        final version = _schedulingComponent(
          parseIcalendarSchedulingMessage(utf8.encode(payload)).events.single,
        );
        history.removeWhere(
          (r) =>
              eventComponentKey(r.point, false) ==
              eventComponentKey(point!, false),
        );
        history.add(
          _SchedulingCancellation(
            point!,
            version,
            restored: restore,
            active: restore
                ? version
                : !projected
                ? priorCancellation?.active
                : previous.ledger
                          .where(
                            (v) => v.key == _schedulingWirePointKey(point),
                          )
                          .firstOrNull ??
                      priorCancellation?.active,
          ),
        );
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
        method: method,
        publicationKind: checkedReceipt?.kind ?? kind,
        originalStart: checkedReceipt?.target ?? point,
        organizerAddress: authority.organizerAddress,
        recipients: proposals,
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
        publicationExclusions:
            projectionBuild?.masks ??
            previous.publicationExclusions ??
            const [],
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
      final v5 = restore || history.any((s) => s.active != null);
      var snapshot = projectionBuild != null
          ? ''
          : v5
          ? _schedulingWriteV5(
              canonical: proposed,
              kind: kind,
              basis: basisRecord,
              individuals: history,
              target: point,
              nativeMatch: matches,
            )
          : _schedulingWriteV4(
              canonical: proposed,
              kind: kind,
              basis: basisRecord,
              cancelled: history,
              target: point,
              nativeMatch: matches,
            );
      if (projected) {
        final proof =
            projectionBuild?.state ??
            last.copyWith(
              snapshot: snapshot,
              projection: _schedulingV4Projection(kind, point, [
                _schedulingComponent(outgoing.events.single),
              ], version: v5 ? 5 : 4),
              payload: payload,
              payloadDigest: _schedulingDigest(payload),
              method: method,
              sequence: sequence,
              stamp: stamp,
            );
        snapshot = _schedulingWriteV6(
          canonical: proposed,
          kind: kind,
          state: proof,
          ledger: projectionBuild?.ledger ?? previous.ledger,
          masks: projectionBuild?.masks ?? previous.publicationExclusions!,
          fullPayload: projectionBuild?.payload ?? previous.fullRequestPayload!,
          floor: projectionBuild?.floor ?? previous.reopenFloor!,
          target: point,
          nativeMatch: matches,
        );
      }
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
          projection: _schedulingV4Projection(
            kind,
            point,
            reopen || restore && projected
                ? _schedulingComponents(outgoing)
                : [_schedulingComponent(outgoing.events.single)],
            version: projected
                ? 6
                : v5
                ? 5
                : 4,
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
