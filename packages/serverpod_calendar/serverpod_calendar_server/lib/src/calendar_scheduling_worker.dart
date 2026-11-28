part of 'calendar_module.dart';

final class _SchedulingClaim {
  const _SchedulingClaim(this.delivery, this.publication, this.meeting);
  final CalendarSchedulingDeliveryRecord delivery;
  final CalendarSchedulingPublicationRecord publication;
  final CalendarSchedulingMeetingRecord meeting;
}

final class _SchedulingWorker {
  _SchedulingWorker(this.s);
  final CalendarService s;
  CalendarSchedulingOptions get options => s._scheduling.options;

  Future<void> run() async {
    final rows = await s._session.db.unsafeQuery(
      'SELECT id FROM serverpod_calendar_scheduling_delivery WHERE "terminalAt" IS NULL '
      'AND "nextAttemptAt"<=clock_timestamp() AND ("leaseUntil" IS NULL OR "leaseUntil"<=clock_timestamp()) '
      'ORDER BY "nextAttemptAt", id LIMIT @limit',
      parameters: QueryParameters.named({'limit': options.batchSize}),
    );
    for (final row in rows) {
      final id = UuidValue.fromString(row.first.toString());
      final claim = await _claim(id);
      if (claim == null || !await _ready(claim)) continue;
      CalendarSchedulingTransportResult result;
      try {
        result = await s._scheduling.transport
            .submit(
              s._session,
              CalendarSchedulingSubmission(
                deliveryKey: claim.delivery.deliveryKey,
                publicationId: claim.publication.id!,
                scopeKey: claim.meeting.scopeKey,
                organizerAddress: claim.meeting.organizerAddress,
                recipient: CalendarSchedulingRoute(
                  claim.delivery.recipientAddress,
                  claim.delivery.routeRef,
                ),
                payload: claim.publication.payload,
              ),
            )
            .timeout(options.transportTimeout);
      } catch (_) {
        result = const CalendarSchedulingTransportResult(
          CalendarSchedulingTransportOutcome.uncertain,
        );
      }
      await _finish(claim, result);
    }
    await _cleanup();
  }

  Future<CalendarSchedulingDeliveryRecord?> _delivery(
    UuidValue id,
    Transaction tx,
  ) => CalendarSchedulingDeliveryRecord.db.findById(
    s._session,
    id,
    transaction: tx,
  );

  Future<void> _aggregate(
    CalendarSchedulingPublicationRecord p,
    Transaction tx,
    DateTime now,
  ) async {
    final rows = await CalendarSchedulingDeliveryRecord.db.find(
      s._session,
      where: (t) => t.publicationId.equals(p.id!),
      limit: 65,
      transaction: tx,
    );
    if (rows.length != p.recipients.length || rows.length > 64) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (rows.every((d) => d.terminalAt != null)) {
      p.completedAt ??= now;
      p.outcome =
          rows.every((d) => d.state == CalendarSchedulingDeliveryState.accepted)
          ? 'accepted'
          : rows.any((d) => d.state == CalendarSchedulingDeliveryState.accepted)
          ? 'partial'
          : 'notAccepted';
      await CalendarSchedulingPublicationRecord.db.updateRow(
        s._session,
        p,
        transaction: tx,
      );
    }
  }

  Future<void> _stop(
    CalendarSchedulingDeliveryRecord d,
    CalendarSchedulingPublicationRecord p,
    Transaction tx,
    DateTime now,
    CalendarSchedulingDeliveryState state,
    String reason,
  ) async {
    d.state = state;
    d.resultCode = reason;
    d.terminalAt = now;
    d.leaseOwner = null;
    d.leaseToken = null;
    d.leaseUntil = null;
    await CalendarSchedulingDeliveryRecord.db.updateRow(
      s._session,
      d,
      transaction: tx,
    );
    await _aggregate(p, tx, now);
  }

  Future<CalendarSchedulingPolicyContext> _context(
    CalendarSchedulingDeliveryRecord d,
    CalendarSchedulingPublicationRecord p,
    CalendarSchedulingMeetingRecord meeting,
    Transaction tx,
  ) async {
    final e = await s._eventInScope(meeting.scopeKey, meeting.eventId, tx);
    if (d.scopeKey != meeting.scopeKey ||
        p.scopeKey != meeting.scopeKey ||
        !{'REQUEST', 'CANCEL'}.contains(p.method) ||
        meeting.calendarId != e.identity.calendarId ||
        meeting.latestPublicationId != p.id ||
        meeting.generation != p.generation ||
        e.data.origin != CalendarEventOrigin.native ||
        p.method == 'REQUEST' &&
            e.data.content.status == CalendarEventStatus.cancelled ||
        e.data.protocolUid != p.protocolUid ||
        _schedulingDigest(p.payload) != p.payloadDigest) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    final checkpoint = _schedulingReadCheckpoint(p);
    final published = checkpoint.outgoing;
    if (_schedulingRecurring(published.content) !=
            _schedulingRecurring(e.data.content) ||
        published.eventId != e.identity.id ||
        published.calendarId != e.identity.calendarId ||
        published.protocolUid != p.protocolUid) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    // Revalidate immutable bytes too; corrupt state cannot become transport input.
    final parsed = parseIcalendarSchedulingMessage(
      utf8.encode(p.payload),
      syntaxLimits: IcalendarSyntaxLimits(maxBytes: options.maxPayloadBytes),
    );
    if (parsed.method !=
            (p.method == 'CANCEL'
                ? IcalendarSchedulingMethod.cancel
                : IcalendarSchedulingMethod.request) ||
        p.method == 'CANCEL' &&
            (checkpoint.kind ==
                        CalendarSchedulingPublicationKind.seriesCancel &&
                    published.content.status != CalendarEventStatus.cancelled ||
                parsed.events.single.status !=
                    IcalendarEventStatus.cancelled) ||
        parsed.uid != p.protocolUid ||
        parsed.events.any(
          (event) =>
              event.participants.organizer?.address !=
                  meeting.organizerAddress ||
              jsonEncode(
                    (event.participants.attendees.map((a) => a.address).toList()
                      ..sort()),
                  ) !=
                  jsonEncode(p.recipients),
        )) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final deliveries = await CalendarSchedulingDeliveryRecord.db.find(
      s._session,
      where: (t) => t.publicationId.equals(p.id!),
      limit: 65,
      transaction: tx,
    );
    final authority = _schedulingAuthority(
      CalendarSchedulingAuthority(
        organizerAddress: meeting.organizerAddress,
        authorityRef: meeting.authorityRef,
        routes: deliveries.map(
          (r) => CalendarSchedulingRoute(r.recipientAddress, r.routeRef),
        ),
      ),
      p.recipients,
    );
    if (!authority.routes.any(
      (r) => r.address == d.recipientAddress && r.routeRef == d.routeRef,
    )) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    return CalendarSchedulingPolicyContext(
      scopeKey: meeting.scopeKey,
      calendar: e.parent.snapshot,
      currentEvent: e.snapshot,
      proposedEvent: e.snapshot,
      publicationEvent: checkpoint.canonical,
      publicationExclusions: checkpoint.publicationExclusions ?? const [],
      publishedRequest: checkpoint.basisRecord == null
          ? null
          : _schedulingReadCheckpoint(checkpoint.basisRecord!).outgoing,
      exactNativeMatch: checkpoint.target == null
          ? null
          : eventSchedulingMember(e.data.content, checkpoint.target!),
      outgoingMessage: parsed,
      payloadDigest: p.payloadDigest,
      authority: authority,
      intent: CalendarSchedulingIntent(
        method: p.method,
        publicationKind: checkpoint.kind,
        originalStart: checkpoint.target,
        organizerAddress: meeting.organizerAddress,
        recipients: p.recipients,
        payload: p.payload,
        publicationId: p.id,
        generation: p.generation,
      ),
      recipient: CalendarSchedulingRoute(d.recipientAddress, d.routeRef),
    );
  }

  Future<bool> _authorize(
    CalendarSchedulingDeliveryRecord d,
    CalendarSchedulingPublicationRecord p,
    CalendarSchedulingMeetingRecord meeting,
    Transaction tx,
    DateTime now,
    CalendarAuthorizationPhase phase,
  ) async {
    if (!now.isBefore(p.expiresAt)) {
      await _stop(
        d,
        p,
        tx,
        now,
        CalendarSchedulingDeliveryState.expired,
        'expired',
      );
      return false;
    }
    if (meeting.latestPublicationId != p.id ||
        meeting.generation != p.generation) {
      await _stop(
        d,
        p,
        tx,
        now,
        CalendarSchedulingDeliveryState.superseded,
        'superseded',
      );
      return false;
    }
    try {
      final context = await _context(d, p, meeting, tx);
      await s._schedulingHostCheck(context, tx, phase);
      return true;
    } on CalendarException catch (e) {
      if (e.code == CalendarFailureCode.unavailable) {
        d.state = CalendarSchedulingDeliveryState.blocked;
        d.resultCode = 'policyUnavailable';
        d.nextAttemptAt = now.add(options.retryBase);
        d.leaseOwner = null;
        d.leaseToken = null;
        d.leaseUntil = null;
        await CalendarSchedulingDeliveryRecord.db.updateRow(
          s._session,
          d,
          transaction: tx,
        );
      } else {
        await _stop(
          d,
          p,
          tx,
          now,
          CalendarSchedulingDeliveryState.blocked,
          'authorityWithdrawn',
        );
      }
    } catch (_) {
      await _stop(
        d,
        p,
        tx,
        now,
        CalendarSchedulingDeliveryState.blocked,
        'invalidState',
      );
    }
    return false;
  }

  Future<_SchedulingClaim?> _claim(UuidValue id) async {
    final candidate = await CalendarSchedulingDeliveryRecord.db.findById(
      s._session,
      id,
    );
    if (candidate == null) return null;
    return s._scopeTransaction(candidate.scopeKey, (tx, _) async {
      final d = await _delivery(id, tx), now = await s._revisionTime(tx);
      if (d == null ||
          d.terminalAt != null ||
          d.nextAttemptAt.isAfter(now) ||
          d.leaseUntil != null && d.leaseUntil!.isAfter(now)) {
        return null;
      }
      final p = await CalendarSchedulingPublicationRecord.db.findById(
        s._session,
        d.publicationId,
        transaction: tx,
      );
      final meeting = p == null
          ? null
          : await CalendarSchedulingMeetingRecord.db.findById(
              s._session,
              p.meetingId,
              transaction: tx,
            );
      if (p == null ||
          meeting == null ||
          meeting.scopeKey != candidate.scopeKey) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      // A dead holder's persisted attempt remains uncertain, never accepted.
      final unfinished = await CalendarSchedulingAttemptRecord.db.find(
        s._session,
        where: (t) => t.deliveryId.equals(id) & t.finishedAt.equals(null),
        limit: 33,
        transaction: tx,
      );
      for (final attempt in unfinished) {
        attempt.finishedAt = now;
        attempt.outcome = 'uncertain';
        attempt.resultCode = 'leaseLost';
        await CalendarSchedulingAttemptRecord.db.updateRow(
          s._session,
          attempt,
          transaction: tx,
        );
      }
      if (d.attemptCount >= options.maxAttempts ||
          d.leaseFence >= CalendarService._maxRevision) {
        await _stop(
          d,
          p,
          tx,
          now,
          CalendarSchedulingDeliveryState.failed,
          'attemptLimit',
        );
        return null;
      }
      if (!await _authorize(
        d,
        p,
        meeting,
        tx,
        now,
        CalendarAuthorizationPhase.preliminaryWrite,
      )) {
        return null;
      }
      d.attemptCount++;
      d.leaseFence++;
      d.leaseOwner = Uuid().v4obj();
      d.leaseToken = Uuid().v4obj();
      d.leaseUntil = now.add(options.lease);
      d.state = CalendarSchedulingDeliveryState.claimed;
      d.resultCode = null;
      await CalendarSchedulingDeliveryRecord.db.updateRow(
        s._session,
        d,
        transaction: tx,
      );
      await CalendarSchedulingAttemptRecord.db.insertRow(
        s._session,
        CalendarSchedulingAttemptRecord(
          deliveryId: id,
          attemptNumber: d.attemptCount,
          leaseToken: d.leaseToken!,
          leaseFence: d.leaseFence,
          startedAt: now,
          outcome: 'started',
        ),
        transaction: tx,
      );
      return _SchedulingClaim(d, p, meeting);
    });
  }

  bool _owns(
    CalendarSchedulingDeliveryRecord? current,
    _SchedulingClaim claim,
    DateTime now,
  ) =>
      current != null &&
      current.terminalAt == null &&
      current.leaseToken == claim.delivery.leaseToken &&
      current.leaseFence == claim.delivery.leaseFence &&
      current.leaseUntil != null &&
      current.leaseUntil!.isAfter(now);

  Future<bool> _ready(_SchedulingClaim claim) =>
      s._scopeTransaction(claim.meeting.scopeKey, (tx, _) async {
        final now = await s._revisionTime(tx),
            d = await _delivery(claim.delivery.id!, tx);
        if (!_owns(d, claim, now)) return false;
        final p = await CalendarSchedulingPublicationRecord.db.findById(
          s._session,
          claim.publication.id!,
          transaction: tx,
        );
        final meeting = await CalendarSchedulingMeetingRecord.db.findById(
          s._session,
          claim.meeting.id!,
          transaction: tx,
        );
        if (p == null || meeting == null) return false;
        final ready = await _authorize(
          d!,
          p,
          meeting,
          tx,
          now,
          CalendarAuthorizationPhase.finalWrite,
        );
        if (!ready) {
          final attempt = await CalendarSchedulingAttemptRecord.db.findFirstRow(
            s._session,
            where: (t) =>
                t.deliveryId.equals(d.id!) &
                t.attemptNumber.equals(d.attemptCount),
            transaction: tx,
          );
          if (attempt != null) {
            attempt.finishedAt = now;
            attempt.outcome = 'notSubmitted';
            attempt.resultCode = d.resultCode;
            await CalendarSchedulingAttemptRecord.db.updateRow(
              s._session,
              attempt,
              transaction: tx,
            );
          }
        }
        return ready;
      });

  Future<void> _finish(
    _SchedulingClaim claim,
    CalendarSchedulingTransportResult result,
  ) => s._scopeTransaction(claim.meeting.scopeKey, (tx, _) async {
    final now = await s._revisionTime(tx),
        d = await _delivery(claim.delivery.id!, tx);
    if (!_owns(d, claim, now)) return;
    final p = await CalendarSchedulingPublicationRecord.db.findById(
      s._session,
      claim.publication.id!,
      transaction: tx,
    );
    if (p == null) return;
    final attempt = await CalendarSchedulingAttemptRecord.db.findFirstRow(
      s._session,
      where: (t) =>
          t.deliveryId.equals(d!.id!) & t.attemptNumber.equals(d.attemptCount),
      transaction: tx,
    );
    if (attempt == null ||
        attempt.leaseToken != d!.leaseToken ||
        attempt.leaseFence != d.leaseFence) {
      return;
    }
    attempt.finishedAt = now;
    attempt.outcome = result.outcome.name;
    if (result.receipt != null) {
      try {
        validateCalendarOpaqueText(result.receipt!, maxUtf8Bytes: 512);
        attempt.adapterReceipt = result.receipt;
      } catch (_) {
        /* Never persist arbitrary adapter output. */
      }
    }
    attempt.resultCode = result.outcome.name;
    await CalendarSchedulingAttemptRecord.db.updateRow(
      s._session,
      attempt,
      transaction: tx,
    );
    if (result.outcome == CalendarSchedulingTransportOutcome.accepted) {
      await _stop(
        d,
        p,
        tx,
        now,
        CalendarSchedulingDeliveryState.accepted,
        'accepted',
      );
    } else if (result.outcome ==
            CalendarSchedulingTransportOutcome.permanentFailure ||
        d.attemptCount >= options.maxAttempts) {
      await _stop(
        d,
        p,
        tx,
        now,
        CalendarSchedulingDeliveryState.failed,
        result.outcome.name,
      );
    } else {
      d.state = CalendarSchedulingDeliveryState.pending;
      d.resultCode = result.outcome.name;
      final seconds = min(
        3600,
        options.retryBase.inSeconds * (1 << min(d.attemptCount - 1, 20)),
      );
      d.nextAttemptAt = now.add(Duration(seconds: seconds));
      d.leaseOwner = null;
      d.leaseToken = null;
      d.leaseUntil = null;
      await CalendarSchedulingDeliveryRecord.db.updateRow(
        s._session,
        d,
        transaction: tx,
      );
    }
  });

  Future<void> _cleanup() async {
    final candidates = await s._session.db.unsafeQuery(
      'SELECT p.id FROM serverpod_calendar_scheduling_publication p WHERE "completedAt" IS NOT NULL '
      'AND "completedAt"<clock_timestamp()-(@seconds * interval \'1 second\') AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_scheduling_meeting m WHERE m."latestPublicationId"=p.id) ORDER BY "completedAt" LIMIT @limit',
      parameters: QueryParameters.named({
        'seconds': options.retention.inSeconds,
        'limit': options.batchSize,
      }),
    );
    for (final row in candidates) {
      final p = await CalendarSchedulingPublicationRecord.db.findById(
        s._session,
        UuidValue.fromString(row.first.toString()),
      );
      if (p == null) continue;
      await s._scopeTransaction(p.scopeKey, (tx, _) async {
        final current = await CalendarSchedulingPublicationRecord.db.findById(
          s._session,
          p.id!,
          transaction: tx,
        );
        final meeting = await CalendarSchedulingMeetingRecord.db.findById(
          s._session,
          p.meetingId,
          transaction: tx,
        );
        final now = await s._revisionTime(tx);
        if (current?.completedAt == null ||
            meeting == null ||
            meeting.latestPublicationId == p.id ||
            !current!.completedAt!.isBefore(now.subtract(options.retention))) {
          return;
        }
        final deliveries = await CalendarSchedulingDeliveryRecord.db.find(
          s._session,
          where: (t) => t.publicationId.equals(p.id!),
          limit: 65,
          transaction: tx,
        );
        if (deliveries.length > 64 ||
            deliveries.any((d) => d.terminalAt == null)) {
          return;
        }
        for (final d in deliveries) {
          await CalendarSchedulingAttemptRecord.db.deleteWhere(
            s._session,
            where: (t) => t.deliveryId.equals(d.id!),
            transaction: tx,
          );
          await CalendarSchedulingDeliveryRecord.db.deleteRow(
            s._session,
            d,
            transaction: tx,
          );
        }
        await CalendarSchedulingPublicationRecord.db.deleteRow(
          s._session,
          current,
          transaction: tx,
        );
      });
    }
  }
}
