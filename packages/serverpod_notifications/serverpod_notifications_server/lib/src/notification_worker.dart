part of 'notification_module.dart';

final class _NotificationWorker {
  _NotificationWorker(this.service);
  final NotificationService service;
  Session get session => service._session;
  NotificationOptions get options => service._options;
  NotificationWorkStore get store => NotificationWorkStore(session, options);
  Future<void> run() async {
    await store.prune();
    for (final claim in await store.claim()) {
      try {
        await _publish(claim);
      } catch (_) {
        /* Uncommitted leases expire; retry keeps the same logical ID. */
      }
    }
  }

  Future<void> _publish(NotificationDeliveryRecord claim) =>
      service._scope(claim.scopeKey, (tx) async {
        final row = await NotificationDeliveryRecord.db.findById(
          session,
          claim.id!,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        var now = await store.databaseTime(tx);
        if (!NotificationWorkStore.owns(row, claim, now)) return;
        final current = row!;
        final e = service._envelope(current);
        if (e.digest != current.requestDigest) {
          throw _failure(NotificationFailureCode.unavailable);
        }
        var outcome = NotificationDeliveryState.queued;
        String? reason;
        if (!current.expiresAt.isAfter(now)) {
          outcome = NotificationDeliveryState.expired;
          reason = 'expiry';
        } else {
          final preliminary = await service._source(
            e,
            NotificationSourceOperation.publish,
            tx,
            NotificationPhase.preliminary,
          );
          if (preliminary == NotificationVerdict.deny) {
            outcome = NotificationDeliveryState.suppressed;
            reason = 'sourceWithdrawn';
          } else if (preliminary == NotificationVerdict.unavailable) {
            reason = 'sourceUnavailable';
          } else {
            final verdict = await service._source(
              e,
              NotificationSourceOperation.publish,
              tx,
              NotificationPhase.finalCheck,
            );
            now = await store.databaseTime(tx);
            if (!NotificationWorkStore.owns(current, claim, now)) {
              throw _failure(NotificationFailureCode.unavailable);
            }
            if (!e.expiresAt.isAfter(now)) {
              outcome = NotificationDeliveryState.expired;
              reason = 'expiry';
            } else if (verdict == NotificationVerdict.deny) {
              outcome = NotificationDeliveryState.suppressed;
              reason = 'sourceWithdrawn';
            } else if (verdict == NotificationVerdict.unavailable) {
              reason = 'sourceUnavailable';
            } else {
              final posted = await service._runtime.publication
                  .publish(session, current.id!, e)
                  .timeout(options.publicationTimeout);
              outcome = posted
                  ? NotificationDeliveryState.published
                  : NotificationDeliveryState.queued;
              reason = posted ? null : 'publicationUnavailable';
            }
          }
        }
        now = await store.databaseTime(tx);
        if (!NotificationWorkStore.owns(current, claim, now)) {
          throw _failure(NotificationFailureCode.unavailable);
        }
        if (!current.expiresAt.isAfter(now)) {
          outcome = NotificationDeliveryState.expired;
          reason = 'expiry';
        }
        if (current.attemptCount >= NotificationService.maxCounter) {
          throw _failure(NotificationFailureCode.limitExceeded);
        }
        current.attemptCount++;
        current.updatedAt = now;
        current.state = outcome;
        current.reason = reason;
        current.leaseOwner = null;
        current.leaseUntil = null;
        if (outcome == NotificationDeliveryState.queued) {
          current.nextAttemptAt = now.add(options.retryDelay);
        } else {
          current.terminalAt = now;
          if (outcome == NotificationDeliveryState.published) {
            current.publishedAt = now;
          }
        }
        await NotificationDeliveryRecord.db.updateRow(
          session,
          current,
          transaction: tx,
        );
      });
}
