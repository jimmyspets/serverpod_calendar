part of 'calendar_module.dart';

final class _RefreshWorker {
  _RefreshWorker(this.service);
  final CalendarService service;
  Session get session => service._session;
  CalendarSchedulingOptions get options => service._scheduling.options;

  Future<void> run() async {
    final due = await session.db.unsafeQuery(
      'SELECT id, "scopeKey" FROM serverpod_calendar_refresh_resend '
      'WHERE "terminalAt" IS NULL AND "nextAttemptAt" <= clock_timestamp() '
      'AND ("leaseUntil" IS NULL OR "leaseUntil" <= clock_timestamp()) '
      'ORDER BY "nextAttemptAt", id LIMIT @limit',
      parameters: QueryParameters.named({'limit': options.batchSize}),
    );
    for (final entry in due) {
      final id = UuidValue.fromString(entry[0].toString());
      final scope = entry[1].toString();
      final claim = await service._scopeTransaction(scope, (tx, _) async {
        final row = await _load(id, tx);
        final now = await service._revisionTime(tx);
        if (row == null ||
            row.scopeKey != scope ||
            row.terminalAt != null ||
            row.nextAttemptAt.isAfter(now) ||
            row.leaseUntil?.isAfter(now) == true) {
          return null;
        }
        await _closeAttempt(row, now, tx, 'uncertain');
        if (!row.expiresAt.isAfter(now) || row.attemptCount >= 8) {
          await _save(
            row,
            now,
            tx,
            terminal: row.expiresAt.isAfter(now)
                ? CalendarSchedulingDeliveryState.failed
                : CalendarSchedulingDeliveryState.expired,
            result: 'attemptOrExpiryLimit',
          );
          return null;
        }
        if (await _eligible(
              row,
              now,
              tx,
              CalendarAuthorizationPhase.preliminaryWrite,
            ) ==
            null) {
          return null;
        }
        row.attemptCount++;
        row.leaseToken = const Uuid().v4obj();
        row.leaseUntil = now.add(const Duration(seconds: 120));
        row.state = CalendarSchedulingDeliveryState.claimed;
        await CalendarRefreshResendRecord.db.updateRow(
          session,
          row,
          transaction: tx,
        );
        await CalendarRefreshAttemptRecord.db.insertRow(
          session,
          CalendarRefreshAttemptRecord(
            resendId: row.id!,
            attemptNumber: row.attemptCount,
            leaseToken: row.leaseToken!,
            startedAt: now,
            outcome: 'claimed',
          ),
          transaction: tx,
        );
        return row;
      });
      if (claim == null) continue;
      final ready = await service._scopeTransaction(scope, (tx, _) async {
        final current = await _load(id, tx);
        final now = await service._revisionTime(tx);
        if (!_owns(current, claim, now)) return null;
        return _eligible(
          current!,
          now,
          tx,
          CalendarAuthorizationPhase.finalWrite,
        );
      });
      if (ready == null) continue;
      var outcome = CalendarSchedulingTransportOutcome.uncertain;
      try {
        outcome =
            (await service._scheduling.transport
                    .submit(session, ready)
                    .timeout(options.transportTimeout))
                .outcome;
      } catch (_) {
        // Reuse the same delivery key if submission may already have succeeded.
      }
      await service._scopeTransaction(scope, (tx, _) async {
        final current = await _load(id, tx);
        final now = await service._revisionTime(tx);
        if (!_owns(current, claim, now)) return;
        await _closeAttempt(current!, now, tx, outcome.name);
        final terminal = switch (outcome) {
          CalendarSchedulingTransportOutcome.accepted =>
            CalendarSchedulingDeliveryState.accepted,
          CalendarSchedulingTransportOutcome.permanentFailure =>
            CalendarSchedulingDeliveryState.failed,
          _ when current.attemptCount >= 8 =>
            CalendarSchedulingDeliveryState.failed,
          _ => null,
        };
        await _save(current, now, tx, terminal: terminal, result: outcome.name);
      });
    }
    await _cleanup();
  }

  Future<CalendarRefreshResendRecord?> _load(UuidValue id, Transaction tx) =>
      CalendarRefreshResendRecord.db.findById(session, id, transaction: tx);

  bool _owns(
    CalendarRefreshResendRecord? row,
    CalendarRefreshResendRecord claim,
    DateTime now,
  ) =>
      row != null &&
      row.scopeKey == claim.scopeKey &&
      row.terminalAt == null &&
      row.attemptCount == claim.attemptCount &&
      row.leaseToken == claim.leaseToken &&
      row.leaseUntil?.isAfter(now) == true;

  Future<CalendarSchedulingSubmission?> _eligible(
    CalendarRefreshResendRecord row,
    DateTime now,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (!row.expiresAt.isAfter(now)) {
      await _closeAttempt(row, now, tx, 'expired');
      await _save(
        row,
        now,
        tx,
        terminal: CalendarSchedulingDeliveryState.expired,
        result: 'expired',
      );
      return null;
    }
    try {
      final meeting = await CalendarSchedulingMeetingRecord.db.findById(
        session,
        row.meetingId,
        transaction: tx,
      );
      if (meeting == null ||
          meeting.scopeKey != row.scopeKey ||
          meeting.purpose != CalendarSchedulingBindingPurpose.invitation) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      if (meeting.generation != row.generation ||
          meeting.latestPublicationId != row.publicationId) {
        await _closeAttempt(row, now, tx, 'superseded');
        await _save(
          row,
          now,
          tx,
          terminal: CalendarSchedulingDeliveryState.superseded,
          result: 'superseded',
        );
        return null;
      }
      final request = await service._refreshRequest(meeting, row.requestId, tx);
      final event = await service._eventInScope(
        row.scopeKey,
        meeting.eventId,
        tx,
      );
      final actual = await service._refreshMeeting(event, row.scopeKey, tx);
      final publication = (await service._latest(actual, tx))!;
      if (request.attendeeAddress != row.recipientAddress ||
          publication.payloadDigest != row.payloadDigest ||
          event.data.content.status == CalendarEventStatus.cancelled ||
          utf8.encode(publication.payload).length > options.maxPayloadBytes) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final checkpoint = service._refreshPublished(
        event,
        meeting,
        publication,
        row.recipientAddress,
      );
      final route = CalendarSchedulingRoute(row.recipientAddress, row.routeRef);
      final authority = _schedulingAuthority(
        CalendarSchedulingAuthority(
          organizerAddress: meeting.organizerAddress,
          authorityRef: meeting.authorityRef,
          routes: [route],
        ),
        [row.recipientAddress],
      );
      final context = service._refreshContext(
        event,
        publication,
        checkpoint,
        authority,
      );
      await service._refreshHostDecision(
        () => service._refresh.authorizeResend(
          session,
          context,
          request.originReference,
          tx,
          phase,
        ),
      );
      return CalendarSchedulingSubmission(
        deliveryKey: row.id!,
        publicationId: row.publicationId,
        scopeKey: row.scopeKey,
        organizerAddress: meeting.organizerAddress,
        recipient: route,
        payload: publication.payload,
      );
    } on CalendarException catch (error) {
      final retryable = error.code == CalendarFailureCode.unavailable;
      await _closeAttempt(row, now, tx, retryable ? 'unavailable' : 'blocked');
      await _save(
        row,
        now,
        tx,
        terminal: retryable ? null : CalendarSchedulingDeliveryState.blocked,
        result: retryable ? 'unavailable' : 'blocked',
      );
      return null;
    }
  }

  Future<void> _closeAttempt(
    CalendarRefreshResendRecord row,
    DateTime now,
    Transaction tx,
    String outcome,
  ) async {
    if (row.leaseToken == null) return;
    final attempt = await CalendarRefreshAttemptRecord.db.findFirstRow(
      session,
      where: (entry) =>
          entry.resendId.equals(row.id!) &
          entry.attemptNumber.equals(row.attemptCount),
      transaction: tx,
    );
    if (attempt == null || attempt.leaseToken != row.leaseToken) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (attempt.finishedAt == null) {
      attempt.finishedAt = now;
      attempt.outcome = outcome;
      await CalendarRefreshAttemptRecord.db.updateRow(
        session,
        attempt,
        transaction: tx,
      );
    }
  }

  Future<void> _save(
    CalendarRefreshResendRecord row,
    DateTime now,
    Transaction tx, {
    required CalendarSchedulingDeliveryState? terminal,
    required String result,
  }) async {
    row.state = terminal ?? CalendarSchedulingDeliveryState.pending;
    row.resultCode = result;
    row.leaseToken = null;
    row.leaseUntil = null;
    if (terminal == null) {
      row.nextAttemptAt = now.add(
        Duration(seconds: min(3600, 30 << min(row.attemptCount, 7))),
      );
    } else {
      row.terminalAt = now;
    }
    await CalendarRefreshResendRecord.db.updateRow(
      session,
      row,
      transaction: tx,
    );
  }

  Future<void> _cleanup() async {
    final cutoff = await session.db.unsafeQuery(
      'SELECT id, "scopeKey" FROM serverpod_calendar_refresh_resend WHERE '
      '"terminalAt" < clock_timestamp() - interval \'30 days\' ORDER BY "terminalAt", id LIMIT @limit',
      parameters: QueryParameters.named({'limit': options.batchSize}),
    );
    for (final entry in cutoff) {
      final scope = entry[1].toString();
      await service._scopeTransaction(scope, (tx, _) async {
        final row = await _load(UuidValue.fromString(entry[0].toString()), tx);
        final now = await service._revisionTime(tx);
        if (row == null ||
            row.scopeKey != scope ||
            row.terminalAt?.isBefore(now.subtract(_refreshRetention)) != true) {
          return;
        }
        await CalendarRefreshAttemptRecord.db.deleteWhere(
          session,
          where: (attempt) => attempt.resendId.equals(row.id!),
          transaction: tx,
        );
        await CalendarRefreshResendRecord.db.deleteRow(
          session,
          row,
          transaction: tx,
        );
      });
    }
    final expired = await session.db.unsafeQuery(
      'SELECT r.id, r."scopeKey" FROM serverpod_calendar_refresh_request r '
      'WHERE r."expiresAt" < clock_timestamp() - interval \'30 days\' AND NOT EXISTS '
      '(SELECT 1 FROM serverpod_calendar_refresh_resend s WHERE s."requestId"=r.id) '
      'ORDER BY r."expiresAt", r.id LIMIT @limit',
      parameters: QueryParameters.named({'limit': options.batchSize}),
    );
    for (final entry in expired) {
      final scope = entry[1].toString();
      await service._scopeTransaction(scope, (tx, _) async {
        final row = await CalendarRefreshRequestRecord.db.findById(
          session,
          UuidValue.fromString(entry[0].toString()),
          transaction: tx,
        );
        final now = await service._revisionTime(tx);
        if (row == null ||
            row.scopeKey != scope ||
            !row.expiresAt.isBefore(now.subtract(_refreshRetention)) ||
            await CalendarRefreshResendRecord.db.count(
                  session,
                  where: (resend) => resend.requestId.equals(row.id!),
                  transaction: tx,
                ) !=
                0) {
          return;
        }
        await CalendarRefreshRequestRecord.db.deleteRow(
          session,
          row,
          transaction: tx,
        );
      });
    }
  }
}
