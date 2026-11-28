part of 'calendar_module.dart';

final class _InvitationResponseWorker {
  _InvitationResponseWorker(this.s);
  final CalendarService s;
  CalendarInvitationResponseOptions get o => s._irOptions;
  final UuidValue owner = const Uuid().v4obj();

  Future<void> run() async {
    s._irGuarantee();
    final due = await s._session.db.unsafeQuery(
      'SELECT id FROM serverpod_calendar_invitation_response WHERE "terminalAt" IS NULL '
      'AND "nextAttemptAt"<=clock_timestamp() AND ("leaseUntil" IS NULL OR "leaseUntil"<=clock_timestamp()) '
      'ORDER BY "nextAttemptAt",id LIMIT @limit',
      parameters: QueryParameters.named({'limit': o.batchSize}),
    );
    for (final tuple in due) {
      try {
        final claim = await _claim(
          UuidValue.fromString(tuple.single.toString()),
        );
        if (claim == null || !await _ready(claim)) continue;
        CalendarSchedulingTransportResult result;
        try {
          result = await s._irRuntime.transport
              .submit(
                s._session,
                CalendarInvitationResponseSubmission(
                  deliveryKey: claim.id!,
                  scopeKey: claim.scopeKey,
                  attendeeAddress: claim.recipientAddress,
                  organizer: CalendarSchedulingRoute(
                    claim.organizerAddress,
                    claim.routeRef,
                  ),
                  payload: claim.payload,
                ),
              )
              .timeout(o.transportTimeout);
        } catch (_) {
          result = const CalendarSchedulingTransportResult(
            CalendarSchedulingTransportOutcome.uncertain,
          );
        }
        await _finish(claim, result);
      } on CalendarException catch (e) {
        if (e.code != CalendarFailureCode.unavailable) rethrow;
        // Unknown/corrupt evidence never becomes a successful delivery and does
        // not prevent bounded work on the other independent response rows.
      }
    }
    final scopes = await s._session.db.unsafeQuery(
      'SELECT DISTINCT "scopeKey" FROM serverpod_calendar_invitation_response WHERE "terminalAt"<=clock_timestamp()-make_interval(secs=>@seconds) '
      'ORDER BY "scopeKey" LIMIT @limit',
      parameters: QueryParameters.named({
        'seconds': o.retention.inSeconds,
        'limit': o.batchSize,
      }),
    );
    for (final tuple in scopes) {
      final scope = tuple.single.toString();
      await s._scopeTransaction(scope, (tx, _) async {
        final before = await s._irRows(scope, tx),
            now = await s._revisionTime(tx);
        final recipients = <String, CalendarInvitationRecipient>{};
        for (final row in before.where(
          (r) =>
              r.terminalAt != null &&
              !r.terminalAt!.isAfter(now.subtract(o.retention)),
        )) {
          recipients[row.recipientKey] = CalendarInvitationRecipient(
            scopeKey: scope,
            key: row.recipientKey,
            calendarAddress: row.recipientAddress,
          );
        }
        await s._irCleanup(scope, tx, now);
        for (final recipient in recipients.values) {
          await s._invCleanup(recipient, tx, now);
        }
      });
    }
  }

  bool _owns(
    CalendarInvitationResponseRecord row,
    CalendarInvitationResponseRecord claim,
    DateTime now,
  ) =>
      row.terminalAt == null &&
      row.state == CalendarInvitationResponseDeliveryState.claimed &&
      row.leaseOwner == claim.leaseOwner &&
      row.leaseToken == claim.leaseToken &&
      row.leaseFence == claim.leaseFence &&
      row.leaseUntil != null &&
      row.leaseUntil!.isAfter(now);
  Future<CalendarInvitationResponseRecord?> _row(
    UuidValue id,
    String scope,
    Transaction tx,
  ) async {
    final row = await CalendarInvitationResponseRecord.db.findById(
      s._session,
      id,
      transaction: tx,
    );
    if (row != null && row.scopeKey != scope) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return row;
  }

  Future<void> _status(
    CalendarInvitationResponseRecord row,
    Transaction tx,
    DateTime now,
  ) async {
    await CalendarInvitationResponseRecord.db.updateRow(
      s._session,
      row,
      transaction: tx,
    );
    final state = await CalendarInvitationResponseStateRecord.db.findById(
      s._session,
      row.stateId,
      transaction: tx,
    );
    if (state == null ||
        state.scopeKey != row.scopeKey ||
        state.recipientKey != row.recipientKey ||
        state.entryId != row.entryId) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (state.latestResponseId == row.id && state.revision == row.generation) {
      state.outcome = row.state;
      state.updatedAt = now.isBefore(state.updatedAt) ? state.updatedAt : now;
      await CalendarInvitationResponseStateRecord.db.updateRow(
        s._session,
        state,
        transaction: tx,
      );
    }
  }

  Future<bool> _authorize(
    CalendarInvitationResponseRecord row,
    Transaction tx,
    DateTime now,
    CalendarAuthorizationPhase phase,
  ) async {
    if (!now.isBefore(row.expiresAt)) {
      await s._irStop(
        row,
        tx,
        now,
        CalendarInvitationResponseDeliveryState.expired,
        'expired',
      );
      return false;
    }
    try {
      final recipient = CalendarInvitationRecipient(
        scopeKey: row.scopeKey,
        key: row.recipientKey,
        calendarAddress: row.recipientAddress,
      );
      final entry = await s._invEntry(row.entryId, recipient, tx),
          state = await s._irState(recipient, row.entryId, tx);
      if (state == null) throw _failure(CalendarFailureCode.unavailable);
      if (state.latestResponseId != row.id ||
          state.revision != row.generation ||
          entry.currentSourceId != row.sourceId ||
          entry.kind != CalendarInvitationSourceKind.request) {
        await s._irStop(
          row,
          tx,
          now,
          CalendarInvitationResponseDeliveryState.withdrawn,
          'sourceOrIntentChanged',
        );
        return false;
      }
      final source = await s._irSource(row.sourceId, entry, tx);
      s._irRecord(row, state, source, entry);
      final basis = s._invStored(source, entry);
      if (basis.method != IcalendarSchedulingMethod.request ||
          basis.events.single.status == IcalendarEventStatus.cancelled) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final authority = s._irAuthority(
        CalendarInvitationResponseAuthority(
          attendeeAddress: row.recipientAddress,
          authorityRef: row.authorityRef,
          organizer: CalendarSchedulingRoute(
            row.organizerAddress,
            row.routeRef,
          ),
        ),
        recipient,
        basis,
      );
      final context = s._irContext(
        operation: CalendarInvitationResponseOperation.dispatch,
        recipient: recipient,
        invitation: await s._invView(entry, tx),
        current: s._irView(entry, state),
        source: source,
        sourceRevision: row.sourceRevision,
        sourceMessage: basis,
        request: row.request,
        receipt: row.receipt,
        outgoing: s._irParse(utf8.encode(row.payload)),
        digest: row.payloadDigest,
        authority: authority,
      );
      await s._irAuthorize(context, tx, phase);
      return true;
    } on CalendarException catch (e) {
      if (e.code != CalendarFailureCode.unavailable) {
        await s._irStop(
          row,
          tx,
          now,
          CalendarInvitationResponseDeliveryState.withdrawn,
          'authorityWithdrawn',
        );
      } else {
        row.state = CalendarInvitationResponseDeliveryState.retrying;
        row.resultCode = 'policyOrEvidenceUnavailable';
        row.nextAttemptAt = now.add(o.retryBase);
        row.leaseOwner = null;
        row.leaseToken = null;
        row.leaseUntil = null;
        final unfinished = await CalendarInvitationResponseAttemptRecord.db
            .find(
              s._session,
              where: (t) =>
                  t.responseId.equals(row.id!) & t.finishedAt.equals(null),
              limit: 33,
              transaction: tx,
            );
        if (unfinished.length > 32) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        for (final attempt in unfinished) {
          attempt.finishedAt = now;
          attempt.outcome = 'uncertain';
          attempt.resultCode = 'policyOrEvidenceUnavailable';
          await CalendarInvitationResponseAttemptRecord.db.updateRow(
            s._session,
            attempt,
            transaction: tx,
          );
        }
        await _status(row, tx, now);
      }
      return false;
    }
  }

  Future<CalendarInvitationResponseRecord?> _claim(UuidValue id) async {
    final candidate = await CalendarInvitationResponseRecord.db.findById(
      s._session,
      id,
    );
    if (candidate == null) return null;
    return s._scopeTransaction(candidate.scopeKey, (tx, _) async {
      final row = await _row(id, candidate.scopeKey, tx),
          now = await s._revisionTime(tx);
      if (row == null ||
          row.terminalAt != null ||
          row.nextAttemptAt.isAfter(now) ||
          row.leaseUntil != null && row.leaseUntil!.isAfter(now)) {
        return null;
      }
      final unfinished = await CalendarInvitationResponseAttemptRecord.db.find(
        s._session,
        where: (t) => t.responseId.equals(id) & t.finishedAt.equals(null),
        limit: 33,
        transaction: tx,
      );
      if (unfinished.length > 32) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      for (final attempt in unfinished) {
        attempt.finishedAt = now;
        attempt.outcome = 'uncertain';
        attempt.resultCode = 'leaseLost';
        await CalendarInvitationResponseAttemptRecord.db.updateRow(
          s._session,
          attempt,
          transaction: tx,
        );
      }
      if (row.attemptCount >= o.maxAttempts ||
          row.leaseFence >= CalendarService._maxRevision) {
        await s._irStop(
          row,
          tx,
          now,
          CalendarInvitationResponseDeliveryState.failed,
          'attemptLimit',
        );
        return null;
      }
      if (!await _authorize(
        row,
        tx,
        now,
        CalendarAuthorizationPhase.preliminaryWrite,
      )) {
        return null;
      }
      final fresh = await s._revisionTime(tx);
      if (!fresh.isBefore(row.expiresAt)) {
        await s._irStop(
          row,
          tx,
          fresh,
          CalendarInvitationResponseDeliveryState.expired,
          'expired',
        );
        return null;
      }
      row.state = CalendarInvitationResponseDeliveryState.claimed;
      row.attemptCount++;
      row.leaseFence++;
      row.leaseOwner = owner;
      row.leaseToken = const Uuid().v4obj();
      row.leaseUntil = fresh.add(o.lease);
      row.resultCode = null;
      await _status(row, tx, fresh);
      await CalendarInvitationResponseAttemptRecord.db.insertRow(
        s._session,
        CalendarInvitationResponseAttemptRecord(
          responseId: id,
          attemptNumber: row.attemptCount,
          leaseToken: row.leaseToken!,
          leaseFence: row.leaseFence,
          startedAt: fresh,
          outcome: 'claimed',
        ),
        transaction: tx,
      );
      return row;
    });
  }

  Future<bool> _ready(CalendarInvitationResponseRecord claim) =>
      s._scopeTransaction(claim.scopeKey, (tx, _) async {
        final row = await _row(claim.id!, claim.scopeKey, tx),
            now = await s._revisionTime(tx);
        if (row == null || !_owns(row, claim, now)) return false;
        if (!await _authorize(
          row,
          tx,
          now,
          CalendarAuthorizationPhase.finalWrite,
        )) {
          return false;
        }
        return _owns(row, claim, await s._revisionTime(tx));
      });
  String? _receipt(String? value) {
    if (value == null) return null;
    try {
      validateCalendarOpaqueText(value, maxUtf8Bytes: 512);
      return value;
    } catch (_) {
      return null;
    }
  }

  Future<void> _finish(
    CalendarInvitationResponseRecord claim,
    CalendarSchedulingTransportResult result,
  ) => s._scopeTransaction(claim.scopeKey, (tx, _) async {
    final row = await _row(claim.id!, claim.scopeKey, tx),
        now = await s._revisionTime(tx);
    if (row == null || !_owns(row, claim, now)) return;
    final attempt = await CalendarInvitationResponseAttemptRecord.db
        .findFirstRow(
          s._session,
          where: (t) =>
              t.responseId.equals(row.id!) &
              t.attemptNumber.equals(row.attemptCount),
          transaction: tx,
        );
    if (attempt == null ||
        attempt.finishedAt != null ||
        attempt.leaseToken != row.leaseToken ||
        attempt.leaseFence != row.leaseFence) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    attempt.finishedAt = now;
    attempt.outcome = result.outcome.name;
    attempt.adapterReceipt = _receipt(result.receipt);
    await CalendarInvitationResponseAttemptRecord.db.updateRow(
      s._session,
      attempt,
      transaction: tx,
    );
    final state = await CalendarInvitationResponseStateRecord.db.findById(
      s._session,
      row.stateId,
      transaction: tx,
    );
    final entry = await CalendarInvitationRecord.db.findById(
      s._session,
      row.entryId,
      transaction: tx,
    );
    if (state == null || entry == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (state.latestResponseId != row.id ||
        state.revision != row.generation ||
        entry.currentSourceId != row.sourceId ||
        entry.kind != CalendarInvitationSourceKind.request) {
      await s._irStop(
        row,
        tx,
        now,
        CalendarInvitationResponseDeliveryState.withdrawn,
        result.outcome == CalendarSchedulingTransportOutcome.accepted
            ? 'acceptedAfterSourceChange'
            : 'sourceOrIntentChanged',
      );
      return;
    }
    if (!now.isBefore(row.expiresAt)) {
      await s._irStop(
        row,
        tx,
        now,
        CalendarInvitationResponseDeliveryState.expired,
        'expired',
      );
      return;
    }
    switch (result.outcome) {
      case CalendarSchedulingTransportOutcome.accepted:
        await s._irStop(
          row,
          tx,
          now,
          CalendarInvitationResponseDeliveryState.accepted,
          'accepted',
        );
      case CalendarSchedulingTransportOutcome.permanentFailure:
        await s._irStop(
          row,
          tx,
          now,
          CalendarInvitationResponseDeliveryState.failed,
          'transportFailure',
        );
      case CalendarSchedulingTransportOutcome.transientFailure:
      case CalendarSchedulingTransportOutcome.uncertain:
        if (row.attemptCount >= o.maxAttempts) {
          await s._irStop(
            row,
            tx,
            now,
            CalendarInvitationResponseDeliveryState.failed,
            'attemptLimit',
          );
          return;
        }
        row.state = CalendarInvitationResponseDeliveryState.retrying;
        row.resultCode = result.outcome.name;
        row.nextAttemptAt = now.add(
          Duration(
            seconds: min(
              3600,
              o.retryBase.inSeconds * pow(2, row.attemptCount - 1).toInt(),
            ),
          ),
        );
        row.leaseOwner = null;
        row.leaseToken = null;
        row.leaseUntil = null;
        await _status(row, tx, now);
    }
  });
}
