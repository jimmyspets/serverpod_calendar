part of 'calendar_module.dart';

final class _AlarmSnapshot {
  _AlarmSnapshot(
    this.row,
    this.parent,
    this.context,
    this.records,
    this.digest,
  );
  final CalendarAlarmRecord row;
  final _AlarmParent parent;
  final CalendarAlarmBackgroundContext context;
  final List<CalendarTaskOccurrence> records;
  final String digest;
}

final class _AlarmWorker {
  _AlarmWorker(this.service);
  final CalendarService service;
  Session get session => service._session;
  CalendarAlarmRuntime get runtime => service._runtime.alarms!;
  AlarmWorkStore get store => AlarmWorkStore(session, runtime.options);

  // Scope-only lookup carrier. It is never used as a request actor/policy proof.
  CalendarHostContext _lookup(String scope) => CalendarHostContext(
    principalId: 'background-lookup',
    scopeKey: scope,
    policyRevision: 'unused',
  );

  Future<T> _scope<T>(String scope, Future<T> Function(Transaction) body) =>
      service._transaction(_lookup(scope), (tx, _) => body(tx));

  Future<_AlarmSnapshot?> _snapshot(UuidValue id, Transaction tx) async {
    final row = await CalendarAlarmRecord.db.findById(
      session,
      id,
      transaction: tx,
    );
    if (row == null || !row.armed) return null;
    final parent = await service._alarmParent(
      _lookup(row.scopeKey),
      CalendarAlarmParent(kind: row.parentKind, id: row.parentId),
      tx,
    );
    final records = parent.task == null
        ? <CalendarTaskOccurrence>[]
        : [
            for (final r in await service._taskRecords(parent.task!, tx))
              _taskRecordValue(r),
          ];
    final event = parent.event;
    final task = parent.task;
    final timingState = event != null
        ? <Object?>[
            event.data.content.timing.toJson(),
            event.data.content.recurrence?.toJson(),
            event.data.content.periods?.map((v) => v.toJson()).toList(),
            event.data.content.status.name,
            [
              for (final v
                  in event.data.timingOverrides?.singles ??
                      <CalendarEventSingleOverride>[])
                [
                  v.originalStart.toJson(),
                  v.replacement?.toJson(),
                  v.cancelled,
                ],
            ],
            [
              for (final v
                  in event.data.timingOverrides?.future ??
                      <CalendarEventFutureOverride>[])
                [v.originalStart.toJson(), v.replacement.toJson()],
            ],
          ]
        : <Object?>[
            task!.data.content.timing.toJson(),
            task.data.content.recurrence?.toJson(),
            task.data.progress.toJson(),
            [
              for (final r in records)
                [
                  r.originalStart.toJson(),
                  r.replacementTiming?.toJson(),
                  r.futureTiming?.toJson(),
                  r.progress.toJson(),
                ],
            ],
          ];
    final digest = sha256
        .convert(
          utf8.encode(jsonEncode([row.definition.toJson(), timingState])),
        )
        .toString();
    return _AlarmSnapshot(
      row,
      parent,
      CalendarAlarmBackgroundContext(
        scopeKey: row.scopeKey,
        recipient: CalendarAlarmRecipient(
          row.recipientNamespace,
          row.recipientKey,
        ),
        alarm: service._alarmView(row, parent),
        calendar: parent.parent.snapshot,
        event: event?.snapshot,
        task: task?.snapshot,
        taskOccurrences: records,
      ),
      List.unmodifiable(records),
      digest,
    );
  }

  Future<bool> _authorized(
    _AlarmSnapshot snapshot,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    CalendarAlarmBackgroundOperation operation =
        CalendarAlarmBackgroundOperation.plan,
  }) async {
    if (service._options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        runtime.policy.guarantee !=
            CalendarAuthorizationGuarantee.coordinated) {
      return false;
    }
    return await service._bounded(
          () => runtime.policy.authorize(
            session,
            snapshot.context.forOperation(operation),
            tx,
            phase,
          ),
        ) ==
        CalendarAuthorizationVerdict.allow;
  }

  Future<void> run() async {
    await store.pruneTerminalHistory();
    for (final lease in await store.claimPlans()) {
      try {
        await _plan(lease);
      } on AlarmPlanLimitException {
        await _fail(
          lease,
          CalendarAlarmPlanStatus.needsAttention,
          'workBudget',
        );
      } catch (_) {
        await _fail(
          lease,
          CalendarAlarmPlanStatus.unavailable,
          'planningUnavailable',
        );
      }
    }
    await _dispatch();
  }

  Future<void> _fail(
    AlarmPlanLease lease,
    CalendarAlarmPlanStatus status,
    String reason,
  ) => _scope(lease.scopeKey, (tx) async {
    final row = await store.ownedPlan(lease, tx);
    if (row == null) return;
    row.status = status;
    row.reason = reason;
    row.dirty = true;
    row.windowStart = null;
    row.windowEnd = null;
    row.leaseOwner = null;
    row.leaseUntil = null;
    row.nextScanAt = (await store.databaseTime(tx))
        .add(const Duration(hours: 1));
    await CalendarAlarmPlanRecord.db.updateRow(session, row, transaction: tx);
  });

  Future<void> _plan(AlarmPlanLease lease) async {
    final captured = await _scope(lease.scopeKey, (tx) async {
      if (await store.ownedPlan(lease, tx) == null) return null;
      final snapshot = await _snapshot(lease.alarmId, tx);
      if (snapshot == null ||
          snapshot.row.scopeKey != lease.scopeKey ||
          snapshot.row.generation != lease.generation ||
          !await _authorized(snapshot, tx, CalendarAuthorizationPhase.read)) {
        return null;
      }
      final actions = await CalendarAlarmActionRecord.db.find(
        session,
        where: (t) => t.alarmId.equals(lease.alarmId),
        limit: runtime.options.maxRetainedFirings + 1,
        transaction: tx,
      );
      if (actions.length > runtime.options.maxRetainedFirings) {
        throw const AlarmPlanLimitException();
      }
      return (
        snapshot,
        List<CalendarAlarmActionRecord>.unmodifiable(actions),
        await store.databaseTime(tx),
      );
    });
    if (captured == null) {
      await _fail(
        lease,
        CalendarAlarmPlanStatus.unavailable,
        'recipientOrSourceUnavailable',
      );
      return;
    }
    final (snapshot, actions, clock) = captured;
    AlarmPlan plan;
    try {
      if (!snapshot.parent.compatible(snapshot.row.definition)) {
        throw ArgumentError('Current master anchor unavailable');
      }
      final now = DateTime.fromMillisecondsSinceEpoch(
        clock.millisecondsSinceEpoch ~/ 1000 * 1000,
        isUtc: true,
      );
      final target = UtcWindow(
        start: now.subtract(runtime.grace).isBefore(DateTime.utc(1970))
            ? DateTime.utc(1970)
            : now.subtract(runtime.grace),
        end: now.add(const Duration(days: 30)),
      );
      TimedValue.utcEnd(
        target.end,
      ); // no partial 30-day window at the profile edge
      final timing = alarmTiming(snapshot.row.definition);
      final task = snapshot.parent.task;
      final lookback =
          timing.anchor == AlarmAnchor.end &&
              task != null &&
              task.data.content.recurrence != null
          ? taskAlarmEndLookback(task.data.content, snapshot.records)
          : Duration.zero;
      final anchors = alarmAnchorWindow(timing, target, endLookback: lookback);
      final source = snapshot.parent.event != null
          ? eventAlarmCandidates(
              snapshot.parent.event!.data.content,
              snapshot.parent.event!.data.timingOverrides,
              timing,
              anchors,
            )
          : taskAlarmCandidates(
              task!.data.content,
              snapshot.records,
              timing,
              anchors,
            );
      final candidates = <AlarmFiringCandidate>[];
      for (final candidate in source) {
        if (candidates.length >= 100000) throw const AlarmPlanLimitException();
        candidates.add(candidate);
      }
      bool completed(CalendarTaskProgress p) =>
          p.status == CalendarTaskStatus.completed ||
          p.status == CalendarTaskStatus.cancelled ||
          p.percentComplete == 100 ||
          p.completedAt != null;
      final progress = {
        for (final r in snapshot.records)
          taskOriginalKey(r.originalStart): r.progress,
      };
      final suppressed = <String>{
        for (final a in actions)
          if (a.acknowledgedAt != null || a.dismissedAt != null) a.originalKey,
        if (task != null)
          for (final c in candidates)
            if (completed(progress[c.originalKey] ?? task.data.progress))
              c.originalKey,
      };
      plan = AlarmPlan.complete(
        window: target,
        now: clock,
        candidates: candidates,
        grace: runtime.grace,
        maxFirings: runtime.options.maxFirings,
        suppressedOriginals: suppressed,
        lifecycleSuppressed:
            snapshot.parent.event?.data.content.status ==
            CalendarEventStatus.cancelled,
      );
    } catch (_) {
      await _fail(
        lease,
        CalendarAlarmPlanStatus.needsAttention,
        'incompleteOrInvalidWindow',
      );
      return;
    }
    await _scope(lease.scopeKey, (tx) async {
      final row = await store.ownedPlan(lease, tx);
      if (row == null) return;
      final current = await _snapshot(lease.alarmId, tx);
      if (current == null ||
          current.row.scopeKey != lease.scopeKey ||
          current.row.generation != lease.generation ||
          current.digest != snapshot.digest ||
          !await _authorized(
            current,
            tx,
            CalendarAuthorizationPhase.finalWrite,
          )) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final now = await store.databaseTime(tx);
      // A policy callback may have outlived the lease. Recheck after it returns.
      if (await store.ownedPlan(lease, tx) == null) return;
      final existingCount = await CalendarAlarmFiringRecord.db.count(
        session,
        where: (t) => t.alarmId.equals(lease.alarmId),
        transaction: tx,
      );
      if (row.timingDigest != null && row.timingDigest != snapshot.digest) {
        if (current.row.generation >= CalendarService._maxRevision) {
          throw const AlarmPlanLimitException();
        }
        current.row.generation++;
        await service._invalidateAlarmWork(current.row, tx);
        await CalendarAlarmRecord.db.updateRow(
          session,
          current.row,
          transaction: tx,
        );
      }
      final generation = current.row.generation;
      final existing = await CalendarAlarmFiringRecord.db.find(
        session,
        where: (t) =>
            t.alarmId.equals(lease.alarmId) & t.generation.equals(generation),
        limit: runtime.options.maxRetainedFirings + 1,
        transaction: tx,
      );
      final keys = {
        for (final r in existing)
          (r.originalKey, r.repeatOrdinal, r.kind, r.snoozeRevision),
      };
      final additions = plan.firings
          .where(
            (f) => !keys.contains((
              f.candidate.originalKey,
              f.candidate.repeatOrdinal,
              CalendarAlarmFiringKind.automatic,
              0,
            )),
          )
          .length;
      if (existingCount + additions > runtime.options.maxRetainedFirings) {
        throw const AlarmPlanLimitException();
      }
      for (final firing in plan.firings) {
        final c = firing.candidate;
        if (keys.contains((
          c.originalKey,
          c.repeatOrdinal,
          CalendarAlarmFiringKind.automatic,
          0,
        ))) {
          continue;
        }
        final state = switch (firing.disposition) {
          AlarmFiringDisposition.pending => CalendarAlarmFiringState.pending,
          AlarmFiringDisposition.suppressed =>
            CalendarAlarmFiringState.suppressed,
          AlarmFiringDisposition.expired => CalendarAlarmFiringState.expired,
        };
        await CalendarAlarmFiringRecord.db.insertRow(
          session,
          CalendarAlarmFiringRecord(
            alarmId: lease.alarmId,
            generation: generation,
            originalKey: c.originalKey,
            kind: CalendarAlarmFiringKind.automatic,
            repeatOrdinal: c.repeatOrdinal,
            dueAt: c.dueAt,
            expiresAt: firing.expiresAt,
            state: state,
            reason: state == CalendarAlarmFiringState.pending
                ? null
                : 'initialClassification',
            nextAttemptAt: c.dueAt,
            terminalAt: state == CalendarAlarmFiringState.pending ? null : now,
            createdAt: now,
            updatedAt: now,
          ),
          transaction: tx,
        );
      }
      // Large complete inserts can consume the remaining lease. Roll back all
      // candidate rows rather than committing after its checked ownership ends.
      final completedAt = await store.databaseTime(tx);
      if (row.leaseUntil == null || !row.leaseUntil!.isAfter(completedAt)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      row.generation = generation;
      row.timingDigest = snapshot.digest;
      row.windowStart = plan.window.start;
      row.windowEnd = plan.window.end;
      row.status = CalendarAlarmPlanStatus.ready;
      row.reason = null;
      row.dirty = false;
      row.lastCompletedAt = completedAt;
      row.nextScanAt = completedAt.add(const Duration(hours: 1));
      row.leaseOwner = null;
      row.leaseUntil = null;
      // Invalidation above may have advanced the fence in the same transaction.
      final persisted = (await CalendarAlarmPlanRecord.db.findById(
        session,
        row.id!,
        transaction: tx,
      ))!;
      row.leaseFence = persisted.leaseFence;
      await CalendarAlarmPlanRecord.db.updateRow(session, row, transaction: tx);
    });
  }

  Future<void> _dispatch() async {
    final claims = await session.db.transaction((tx) async {
      final now = await store.databaseTime(tx);
      // Inactive/dirty plans cannot monopolize the bounded due scan. Claim only
      // ready current generations; unknown policy retains pending work for retry.
      final ids = await session.db.unsafeQuery(
        """SELECT f.id FROM serverpod_calendar_alarm_firing f
        JOIN serverpod_calendar_alarm a ON a.id=f."alarmId" AND a.armed
        JOIN serverpod_calendar_alarm_plan p ON p."alarmId"=a.id
          AND p.generation=a.generation AND p.generation=f.generation
          AND NOT p.dirty AND p.status='ready'
        WHERE f.state='pending' AND f."nextAttemptAt"<=@now AND f."dueAt"<=@now
          AND (f."leaseUntil" IS NULL OR f."leaseUntil"<=@now)
          AND f."leaseFence"<9007199254740991 AND f."attemptCount"<9007199254740991
        ORDER BY f."nextAttemptAt", f.id LIMIT @limit FOR UPDATE OF f SKIP LOCKED""",
        parameters: QueryParameters.named({
          'now': now,
          'limit': runtime.options.maxClaims,
        }),
        transaction: tx,
      );
      final rows = <CalendarAlarmFiringRecord>[];
      for (final entry in ids) {
        final row = await CalendarAlarmFiringRecord.db.findById(
          session,
          UuidValue.fromString(entry.single.toString()),
          transaction: tx,
        );
        if (row != null) rows.add(row);
      }
      final result = <CalendarAlarmFiringRecord>[];
      for (final row in rows) {
        if (row.leaseFence >= CalendarService._maxRevision) continue;
        row.leaseOwner = const Uuid().v4obj();
        row.leaseFence++;
        row.leaseUntil = now.add(runtime.options.leaseDuration);
        await CalendarAlarmFiringRecord.db.updateRow(
          session,
          row,
          transaction: tx,
        );
        result.add(row.copyWith());
      }
      return result;
    });
    for (final claim in claims) {
      try {
        final prepared = await _prepare(claim);
        if (prepared == null) continue;
        final (owned, intent, scope) = prepared;
        var accepted = false;
        try {
          // Fresh check immediately before handoff, after all queue/claim delays.
          if (await validateDelivery(intent)) {
            accepted = await runtime.delivery
                .accept(session, intent)
                .timeout(const Duration(seconds: 20));
          }
        } catch (_) {
          /* Same logical ID is retried after the fenced lease. */
        }
        await _scope(scope, (tx) async {
          final row = await CalendarAlarmFiringRecord.db.findById(
            session,
            owned.id!,
            transaction: tx,
            lockMode: LockMode.forUpdate,
          );
          final now = await store.databaseTime(tx);
          if (!_ownsFiring(row, owned, now)) return;
          row!.attemptCount++;
          row.leaseOwner = null;
          row.leaseUntil = null;
          row.updatedAt = now;
          if (accepted) {
            row.state = CalendarAlarmFiringState.accepted;
            row.acceptedAt = now;
            row.terminalAt = now;
          } else {
            row.nextAttemptAt = now.add(const Duration(seconds: 30));
          }
          await CalendarAlarmFiringRecord.db.updateRow(
            session,
            row,
            transaction: tx,
          );
        });
      } catch (_) {
        /* Lease expiry makes interrupted work claimable by any host. */
      }
    }
  }

  bool _ownsFiring(
    CalendarAlarmFiringRecord? row,
    CalendarAlarmFiringRecord lease,
    DateTime now,
  ) =>
      row != null &&
      row.state == CalendarAlarmFiringState.pending &&
      row.leaseOwner == lease.leaseOwner &&
      row.leaseFence == lease.leaseFence &&
      row.leaseUntil != null &&
      row.leaseUntil!.isAfter(now);

  CalendarAlarmDeliveryIntent _intent(
    CalendarAlarmFiringRecord firing,
    CalendarAlarmRecord alarm,
  ) => CalendarAlarmDeliveryIntent(
    firingId: firing.id!,
    alarmId: alarm.id!,
    generation: firing.generation,
    recipient: CalendarAlarmRecipient(
      alarm.recipientNamespace,
      alarm.recipientKey,
    ),
    parent: CalendarAlarmParent(kind: alarm.parentKind, id: alarm.parentId),
    originalKey: firing.originalKey,
    dueAt: firing.dueAt,
    expiresAt: firing.expiresAt,
  );

  Future<(CalendarAlarmFiringRecord, CalendarAlarmDeliveryIntent, String)?>
  _prepare(CalendarAlarmFiringRecord claim) async {
    final alarm = await CalendarAlarmRecord.db.findById(session, claim.alarmId);
    if (alarm == null) return null;
    return _scope(alarm.scopeKey, (tx) async {
      final row = await CalendarAlarmFiringRecord.db.findById(
        session,
        claim.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final now = await store.databaseTime(tx);
      if (!_ownsFiring(row, claim, now)) return null;
      final plan = await CalendarAlarmPlanRecord.db.findFirstRow(
        session,
        where: (t) => t.alarmId.equals(alarm.id!),
        transaction: tx,
      );
      if (plan == null ||
          plan.dirty ||
          plan.status != CalendarAlarmPlanStatus.ready ||
          plan.generation != row!.generation) {
        return null;
      }
      final pending = await CalendarAlarmFiringRecord.db.find(
        session,
        where: (t) =>
            t.alarmId.equals(alarm.id!) &
            t.generation.equals(row.generation) &
            t.state.equals(CalendarAlarmFiringState.pending) &
            (t.dueAt <= now),
        limit: runtime.options.maxRetainedFirings + 1,
        transaction: tx,
      );
      if (pending.length > runtime.options.maxRetainedFirings) {
        throw const AlarmPlanLimitException();
      }
      pending.sort((a, b) {
        final due = a.dueAt.compareTo(b.dueAt);
        if (due != 0) return due;
        final original = a.originalKey.compareTo(b.originalKey);
        if (original != 0) return original;
        final repeat = a.repeatOrdinal.compareTo(b.repeatOrdinal);
        if (repeat != 0) return repeat;
        final kind = a.kind.index.compareTo(b.kind.index);
        if (kind != 0) return kind;
        final snooze = a.snoozeRevision.compareTo(b.snoozeRevision);
        return snooze != 0
            ? snooze
            : a.id.toString().compareTo(b.id.toString());
      });
      final eligible = pending.where((r) => r.expiresAt.isAfter(now)).toList();
      final latest = eligible.isEmpty ? null : eligible.last;
      for (final firing in pending) {
        if (firing.id == latest?.id) continue;
        firing.state = firing.expiresAt.isAfter(now)
            ? CalendarAlarmFiringState.suppressed
            : CalendarAlarmFiringState.expired;
        firing.reason = firing.state == CalendarAlarmFiringState.expired
            ? 'lateExpiry'
            : 'lateCoalesced';
        firing.terminalAt = now;
        firing.updatedAt = now;
        firing.leaseOwner = null;
        firing.leaseUntil = null;
        firing.leaseFence++;
        await CalendarAlarmFiringRecord.db.updateRow(
          session,
          firing,
          transaction: tx,
        );
      }
      if (latest == null || latest.nextAttemptAt.isAfter(now)) return null;
      if (latest.id != row.id) {
        if (latest.leaseUntil != null && latest.leaseUntil!.isAfter(now)) {
          return null;
        }
        if (latest.leaseFence >= CalendarService._maxRevision) return null;
        latest.leaseOwner = claim.leaseOwner;
        latest.leaseFence++;
        latest.leaseUntil = now.add(runtime.options.leaseDuration);
        await CalendarAlarmFiringRecord.db.updateRow(
          session,
          latest,
          transaction: tx,
        );
      }
      return (latest.copyWith(), _intent(latest, alarm), alarm.scopeKey);
    });
  }

  Future<bool> validateDelivery(CalendarAlarmDeliveryIntent intent) async {
    try {
      final alarm = await CalendarAlarmRecord.db.findById(
        session,
        intent.alarmId,
      );
      if (alarm == null) return false;
      return await _scope(alarm.scopeKey, (tx) async {
        final snapshot = await _snapshot(intent.alarmId, tx);
        if (snapshot == null ||
            snapshot.row.generation != intent.generation ||
            snapshot.row.parentId != intent.parent.id ||
            snapshot.row.parentKind != intent.parent.kind ||
            snapshot.row.recipientNamespace != intent.recipient.namespace ||
            snapshot.row.recipientKey != intent.recipient.key) {
          return false;
        }
        final firing = await CalendarAlarmFiringRecord.db.findById(
          session,
          intent.firingId,
          transaction: tx,
        );
        final plan = await CalendarAlarmPlanRecord.db.findFirstRow(
          session,
          where: (t) => t.alarmId.equals(intent.alarmId),
          transaction: tx,
        );
        if (firing == null ||
            firing.alarmId != intent.alarmId ||
            firing.generation != intent.generation ||
            firing.originalKey != intent.originalKey ||
            firing.dueAt != intent.dueAt ||
            firing.expiresAt != intent.expiresAt ||
            (firing.state != CalendarAlarmFiringState.pending &&
                firing.state != CalendarAlarmFiringState.accepted) ||
            plan == null ||
            plan.dirty ||
            plan.status != CalendarAlarmPlanStatus.ready ||
            plan.generation != intent.generation ||
            plan.timingDigest != snapshot.digest) {
          return false;
        }
        final action = await CalendarAlarmActionRecord.db.findFirstRow(
          session,
          where: (t) =>
              t.alarmId.equals(intent.alarmId) &
              t.originalKey.equals(intent.originalKey),
          transaction: tx,
        );
        if (firing.kind == CalendarAlarmFiringKind.automatic &&
            (action?.acknowledgedAt != null || action?.dismissedAt != null)) {
          return false;
        }
        if (firing.kind == CalendarAlarmFiringKind.snooze &&
            (action?.snoozeRevision != firing.snoozeRevision ||
                action?.pendingSnoozeAt != firing.dueAt)) {
          return false;
        }
        if (snapshot.parent.event?.data.content.status ==
            CalendarEventStatus.cancelled) {
          return false;
        }
        final task = snapshot.parent.task;
        if (task != null) {
          final own = snapshot.records
              .where(
                (r) => taskOriginalKey(r.originalStart) == intent.originalKey,
              )
              .firstOrNull;
          final progress = own?.progress ?? task.data.progress;
          if (progress.status == CalendarTaskStatus.completed ||
              progress.status == CalendarTaskStatus.cancelled ||
              progress.percentComplete == 100 ||
              progress.completedAt != null) {
            return false;
          }
        }
        if (!await _authorized(
          snapshot,
          tx,
          CalendarAuthorizationPhase.finalWrite,
          operation: CalendarAlarmBackgroundOperation.dispatch,
        )) {
          return false;
        }
        // Authorization may be external/slow; check shared time after it returns.
        final now = await store.databaseTime(tx);
        return !firing.dueAt.isAfter(now) && firing.expiresAt.isAfter(now);
      });
    } catch (_) {
      return false;
    }
  }
}
