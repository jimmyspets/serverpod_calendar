part of 'calendar_module.dart';

final class _AttendeeRefreshWorker {
  _AttendeeRefreshWorker(this.service);
  final CalendarService service;
  Session get session => service._session;

  Future<void> run() async {
    final due = await session.db.unsafeQuery(
      'SELECT id, "scopeKey" FROM serverpod_calendar_attendee_refresh '
      'WHERE "terminalAt" IS NULL AND "nextAttemptAt" <= clock_timestamp() '
      'AND ("leaseUntil" IS NULL OR "leaseUntil" <= clock_timestamp()) '
      'ORDER BY "nextAttemptAt", id LIMIT @limit',
      parameters: QueryParameters.named({'limit': 100}),
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
                ? CalendarInvitationResponseDeliveryState.failed
                : CalendarInvitationResponseDeliveryState.expired,
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
        row.state = CalendarInvitationResponseDeliveryState.claimed;
        await CalendarAttendeeRefreshRecord.db.updateRow(
          session,
          row,
          transaction: tx,
        );
        await CalendarAttendeeRefreshAttemptRecord.db.insertRow(
          session,
          CalendarAttendeeRefreshAttemptRecord(
            deliveryId: row.id!,
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
            (await service._arRuntime.transport
                    .submit(session, ready)
                    .timeout(const Duration(seconds: 30)))
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
            CalendarInvitationResponseDeliveryState.accepted,
          CalendarSchedulingTransportOutcome.permanentFailure =>
            CalendarInvitationResponseDeliveryState.failed,
          _ when current.attemptCount >= 8 =>
            CalendarInvitationResponseDeliveryState.failed,
          _ => null,
        };
        await _save(current, now, tx, terminal: terminal, result: outcome.name);
      });
    }
    await _cleanup();
  }

  Future<CalendarAttendeeRefreshRecord?> _load(UuidValue id, Transaction tx) =>
      CalendarAttendeeRefreshRecord.db.findById(session, id, transaction: tx);

  bool _owns(
    CalendarAttendeeRefreshRecord? row,
    CalendarAttendeeRefreshRecord claim,
    DateTime now,
  ) =>
      row != null &&
      row.scopeKey == claim.scopeKey &&
      row.terminalAt == null &&
      row.state == CalendarInvitationResponseDeliveryState.claimed &&
      row.attemptCount == claim.attemptCount &&
      row.leaseToken == claim.leaseToken &&
      row.leaseUntil?.isAfter(now) == true;

  Future<CalendarInvitationResponseSubmission?> _eligible(
    CalendarAttendeeRefreshRecord row,
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
        terminal: CalendarInvitationResponseDeliveryState.expired,
        result: 'expired',
      );
      return null;
    }
    try {
      final recipient = CalendarInvitationRecipient(
        scopeKey: row.scopeKey,
        key: row.recipientKey,
        calendarAddress: row.attendeeAddress,
      );
      final entry = await service._invEntry(row.entryId, recipient, tx);
      service._arProfile(entry);
      if (entry.currentSourceId != row.sourceId ||
          entry.kind != CalendarInvitationSourceKind.request) {
        await _closeAttempt(row, now, tx, 'withdrawn');
        await _save(
          row,
          now,
          tx,
          terminal: CalendarInvitationResponseDeliveryState.withdrawn,
          result: 'sourceChanged',
        );
        return null;
      }
      final source = await service._irSource(row.sourceId, entry, tx);
      final outgoing = service._arStoredOutgoing(row, source, entry, recipient);
      final authority = service._arStoredAuthority(row);
      final context = await service._arContext(
        CalendarAttendeeRefreshOperation.dispatch,
        entry,
        recipient,
        tx,
        source: source,
        revision: row.sourceRevision,
        outgoing: outgoing,
        authority: authority,
        payloadDigest: row.payloadDigest,
      );
      await service._arAuthorize(context, tx, phase);
      return CalendarInvitationResponseSubmission(
        deliveryKey: row.id!,
        scopeKey: row.scopeKey,
        attendeeAddress: row.attendeeAddress,
        organizer: authority.organizer,
        payload: row.payload,
      );
    } on CalendarException catch (error) {
      final retryable = error.code == CalendarFailureCode.unavailable;
      await _closeAttempt(
        row,
        now,
        tx,
        retryable ? 'unavailable' : 'withdrawn',
      );
      await _save(
        row,
        now,
        tx,
        terminal: retryable
            ? null
            : CalendarInvitationResponseDeliveryState.withdrawn,
        result: retryable ? 'unavailable' : 'withdrawn',
      );
      return null;
    }
  }

  Future<void> _closeAttempt(
    CalendarAttendeeRefreshRecord row,
    DateTime now,
    Transaction tx,
    String outcome,
  ) async {
    if (row.leaseToken == null) return;
    final attempt = await CalendarAttendeeRefreshAttemptRecord.db.findFirstRow(
      session,
      where: (entry) =>
          entry.deliveryId.equals(row.id!) &
          entry.attemptNumber.equals(row.attemptCount),
      transaction: tx,
    );
    if (attempt == null || attempt.leaseToken != row.leaseToken) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (attempt.finishedAt == null) {
      attempt.finishedAt = now;
      attempt.outcome = outcome;
      await CalendarAttendeeRefreshAttemptRecord.db.updateRow(
        session,
        attempt,
        transaction: tx,
      );
    }
  }

  Future<void> _save(
    CalendarAttendeeRefreshRecord row,
    DateTime now,
    Transaction tx, {
    required CalendarInvitationResponseDeliveryState? terminal,
    required String result,
  }) async {
    row.state = terminal ?? CalendarInvitationResponseDeliveryState.retrying;
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
    await CalendarAttendeeRefreshRecord.db.updateRow(
      session,
      row,
      transaction: tx,
    );
  }

  Future<void> _cleanup() async {
    final cutoff = await session.db.unsafeQuery(
      'SELECT id, "scopeKey" FROM serverpod_calendar_attendee_refresh WHERE '
      '"terminalAt" < clock_timestamp() - interval \'30 days\' ORDER BY "terminalAt", id LIMIT @limit',
      parameters: QueryParameters.named({'limit': 100}),
    );
    for (final entry in cutoff) {
      final scope = entry[1].toString();
      await service._scopeTransaction(scope, (tx, _) async {
        final row = await _load(UuidValue.fromString(entry[0].toString()), tx);
        final now = await service._revisionTime(tx);
        if (row == null ||
            row.scopeKey != scope ||
            row.terminalAt?.isBefore(now.subtract(_attendeeRefreshRetention)) !=
                true) {
          return;
        }
        await CalendarAttendeeRefreshAttemptRecord.db.deleteWhere(
          session,
          where: (attempt) => attempt.deliveryId.equals(row.id!),
          transaction: tx,
        );
        await CalendarAttendeeRefreshRecord.db.deleteRow(
          session,
          row,
          transaction: tx,
        );
        await service._invCleanup(
          CalendarInvitationRecipient(
            scopeKey: scope,
            key: row.recipientKey,
            calendarAddress: row.attendeeAddress,
          ),
          tx,
          now,
        );
      });
    }
  }
}
