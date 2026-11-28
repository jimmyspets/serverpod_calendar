part of 'calendar_module.dart';

CalendarAlarmActionView _alarmActionView(CalendarAlarmActionRecord row) =>
    CalendarAlarmActionView(
      id: row.id!,
      alarmId: row.alarmId,
      originalKey: row.originalKey,
      revision: row.revision,
      acknowledgedAt: row.acknowledgedAt,
      dismissedAt: row.dismissedAt,
      pendingSnoozeAt: row.pendingSnoozeAt,
      resetAt: row.resetAt,
      updatedAt: row.updatedAt,
    );

CalendarAlarmFiringView _alarmFiringView(
  CalendarAlarmFiringRecord row,
  CalendarAlarmActionRecord? action,
) => CalendarAlarmFiringView(
  id: row.id!,
  alarmId: row.alarmId,
  originalKey: row.originalKey,
  kind: row.kind,
  dueAt: row.dueAt,
  expiresAt: row.expiresAt,
  state: row.state,
  acceptedAt: row.acceptedAt,
  action: action == null ? null : _alarmActionView(action),
);

bool _alarmOriginalActive(
  _AlarmParent parent,
  String key,
  List<CalendarTaskOccurrence> records,
) {
  try {
    if (parent.event?.data.content.status == CalendarEventStatus.cancelled) {
      return false;
    }
    CalendarEventTiming? original;
    if (key != 'item') {
      final v = jsonDecode(key) as List<dynamic>;
      if (v.length != 9) return false;
      original = CalendarEventTiming(
        kind: CalendarEventTimeKind.values.byName(v[0] as String),
        zoneId: v[1] as String?,
        start: CalendarEventCivil(
          year: v[2] as int,
          month: v[3] as int,
          day: v[4] as int,
          hour: v[5] as int,
          minute: v[6] as int,
          second: v[7] as int,
          microsecond: v[8] as int,
        ),
      );
      if (taskOriginalKey(original) != key) return false;
    }
    final event = parent.event;
    if (event != null && original != null) {
      validateEventOverrides(
        event.data.content,
        CalendarEventTimingOverrides(
          singles: [
            CalendarEventSingleOverride(
              originalStart: original,
              cancelled: true,
            ),
          ],
          future: [],
        ),
      );
      if (event.data.timingOverrides?.singles.any(
            (v) => taskOriginalKey(v.originalStart) == key && v.cancelled,
          ) ==
          true) {
        return false;
      }
    }
    final task = parent.task;
    if (task == null) return true;
    if (original != null) requireTaskOriginal(task.data.content, original);
    final own = records
        .where((r) => taskOriginalKey(r.originalStart) == key)
        .firstOrNull;
    final progress = own?.progress ?? task.data.progress;
    return progress.status != CalendarTaskStatus.completed &&
        progress.status != CalendarTaskStatus.cancelled &&
        progress.percentComplete != 100 &&
        progress.completedAt == null;
  } catch (_) {
    return false;
  }
}

extension CalendarAlarmActions on CalendarService {
  Future<CalendarAlarmActionView?> actOnPersonalAlarm(
    CalendarAlarmActionRequest input,
  ) async {
    final c = await _context();
    if ((input.kind == CalendarAlarmActionKind.reset
            ? input.actionId == null || input.firingId != null
            : input.firingId == null || input.actionId != null) ||
        (input.kind == CalendarAlarmActionKind.snooze) !=
            (input.snoozeAt != null)) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (input.snoozeAt != null) {
      _taskValue(() => TimedValue.utc(input.snoozeAt!));
    }
    return _transaction(c, (tx, _) async {
      final parent = await _alarmParent(c, input.parent, tx);
      final recipient = await _alarmRecipient(
        c,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final alarms = await _privateAlarms(
        c,
        input.parent,
        recipient,
        tx,
        alarmId: input.alarmId,
      );
      if (alarms.length != 1) throw _failure(CalendarFailureCode.accessDenied);
      final alarm = alarms.single;
      final firing = input.firingId == null
          ? null
          : await CalendarAlarmFiringRecord.db.findById(
              _session,
              input.firingId!,
              transaction: tx,
            );
      CalendarAlarmActionRecord? action;
      if (input.actionId != null) {
        action = await CalendarAlarmActionRecord.db.findById(
          _session,
          input.actionId!,
          transaction: tx,
        );
        if (action == null || action.alarmId != alarm.id) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
      } else {
        if (firing == null || firing.alarmId != alarm.id) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        action = await CalendarAlarmActionRecord.db.findFirstRow(
          _session,
          where: (t) =>
              t.alarmId.equals(alarm.id!) &
              t.originalKey.equals(firing.originalKey),
          transaction: tx,
        );
      }
      final key = action?.originalKey ?? firing!.originalKey;
      final operation = switch (input.kind) {
        CalendarAlarmActionKind.acknowledge =>
          CalendarPermission.acknowledgePersonalAlarm,
        CalendarAlarmActionKind.dismiss =>
          CalendarPermission.dismissPersonalAlarm,
        CalendarAlarmActionKind.snooze =>
          CalendarPermission.snoozePersonalAlarm,
        CalendarAlarmActionKind.reset => CalendarPermission.resetPersonalAlarm,
      };
      final now = await _revisionTime(tx);
      final proposed =
          action?.copyWith() ??
          CalendarAlarmActionRecord(
            id: const Uuid().v4obj(),
            alarmId: alarm.id!,
            originalKey: key,
            revision: 0,
            createdAt: now,
            updatedAt: now,
          );
      final exhausted =
          proposed.revision >= CalendarService._maxRevision ||
          (input.kind == CalendarAlarmActionKind.snooze &&
              proposed.snoozeRevision >= CalendarService._maxRevision);
      if (!exhausted) proposed.revision++;
      proposed.updatedAt = action != null && action.updatedAt.isAfter(now)
          ? action.updatedAt
          : now;
      proposed.pendingSnoozeAt = null;
      switch (input.kind) {
        case CalendarAlarmActionKind.acknowledge:
          proposed.acknowledgedAt = now;
        case CalendarAlarmActionKind.dismiss:
          proposed.dismissedAt = now;
        case CalendarAlarmActionKind.snooze:
          proposed.acknowledgedAt = now;
          proposed.dismissedAt = null;
          proposed.pendingSnoozeAt = input.snoozeAt;
          if (!exhausted) proposed.snoozeRevision++;
        case CalendarAlarmActionKind.reset:
          proposed.acknowledgedAt = null;
          proposed.dismissedAt = null;
          proposed.resetAt =
              action?.resetAt != null && action!.resetAt!.isAfter(now)
              ? action.resetAt
              : now;
      }
      final requests = [
        _alarmRequest(
          parent,
          operation,
          recipient,
          alarmId: alarm.id,
          current: _alarmView(alarm, parent),
          firing: firing == null ? null : _alarmFiringView(firing, action),
          action: action == null ? null : _alarmActionView(action),
          proposedAction: _alarmActionView(proposed),
          actionKind: input.kind,
        ),
      ];
      await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (alarm.revision != input.expectedAlarmRevision ||
          (action?.revision ?? 0) != input.expectedActionRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      if (exhausted) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final options = _runtime.alarms?.options ?? CalendarAlarmWorkOptions();
      if (action == null &&
          await CalendarAlarmActionRecord.db.count(
                _session,
                where: (t) => t.alarmId.equals(alarm.id!),
                transaction: tx,
                limit: options.maxRetainedFirings,
              ) >=
              options.maxRetainedFirings) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (input.kind == CalendarAlarmActionKind.snooze) {
        await _validatePersonalSnooze(
          alarm,
          parent,
          firing!,
          action,
          input,
          tx,
          await _revisionTime(tx),
        );
      }
      await _verifyAlarmRecipient(
        c,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      final decisions = await _final(c, requests, tx);
      final checkedAt = await _revisionTime(tx);
      if (input.kind == CalendarAlarmActionKind.snooze) {
        await _validatePersonalSnooze(
          alarm,
          parent,
          firing!,
          action,
          input,
          tx,
          checkedAt,
        );
      }
      if (input.kind == CalendarAlarmActionKind.reset) {
        proposed.resetAt =
            action?.resetAt != null && action!.resetAt!.isAfter(checkedAt)
            ? action.resetAt
            : checkedAt;
      }
      if (checkedAt.isAfter(proposed.updatedAt)) proposed.updatedAt = checkedAt;
      if (action == null) {
        await CalendarAlarmActionRecord.db.insertRow(
          _session,
          proposed,
          transaction: tx,
        );
      } else {
        await CalendarAlarmActionRecord.db.updateRow(
          _session,
          proposed,
          transaction: tx,
        );
      }
      // A plan captured before this action may not commit over it. Other originals
      // retain their generation and durable accepted IDs.
      await _session.db.unsafeExecute(
        'UPDATE serverpod_calendar_alarm_plan SET dirty=true, "nextScanAt"=clock_timestamp(), '
        '"leaseOwner"=NULL, "leaseUntil"=NULL, "leaseFence"=LEAST("leaseFence"+1,9007199254740991) '
        'WHERE "alarmId"=CAST(@alarm AS uuid)',
        parameters: QueryParameters.named({'alarm': alarm.id!.toString()}),
        transaction: tx,
      );
      final rows = await CalendarAlarmFiringRecord.db.find(
        _session,
        where: (t) =>
            t.alarmId.equals(alarm.id!) &
            t.originalKey.equals(key) &
            t.generation.equals(alarm.generation) &
            t.state.equals(CalendarAlarmFiringState.pending),
        limit: options.maxRetainedFirings + 1,
        transaction: tx,
      );
      if (rows.length > options.maxRetainedFirings) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      for (final row in rows) {
        row.state = CalendarAlarmFiringState.suppressed;
        row.reason =
            input.kind == CalendarAlarmActionKind.snooze && row.id == firing?.id
            ? 'personalSnoozeOrigin'
            : 'personalAction';
        row.terminalAt = checkedAt;
        row.updatedAt = checkedAt;
        row.leaseOwner = null;
        row.leaseUntil = null;
        if (row.leaseFence >= CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        row.leaseFence++;
        await CalendarAlarmFiringRecord.db.updateRow(
          _session,
          row,
          transaction: tx,
        );
      }
      if (input.kind == CalendarAlarmActionKind.reset) {
        // Only future suppressed automatic rows may be reconsidered. Pending and
        // accepted human-visible work is never replayed as a consequence of reset.
        await CalendarAlarmFiringRecord.db.deleteWhere(
          _session,
          where: (t) =>
              t.alarmId.equals(alarm.id!) &
              t.originalKey.equals(key) &
              t.generation.equals(alarm.generation) &
              t.kind.equals(CalendarAlarmFiringKind.automatic) &
              t.state.equals(CalendarAlarmFiringState.suppressed) &
              (t.dueAt > checkedAt),
          transaction: tx,
        );
      }
      return decisions.values.every((d) => d.discloseMutationReceipt)
          ? _alarmActionView(proposed)
          : null;
    });
  }

  Future<void> _validatePersonalSnooze(
    CalendarAlarmRecord alarm,
    _AlarmParent parent,
    CalendarAlarmFiringRecord firing,
    CalendarAlarmActionRecord? action,
    CalendarAlarmActionRequest input,
    Transaction tx,
    DateTime now,
  ) async {
    final runtime = _runtime.alarms;
    final rescheduling =
        action?.pendingSnoozeAt != null &&
        action?.acknowledgedAt != null &&
        firing.state == CalendarAlarmFiringState.suppressed &&
        firing.reason == 'personalSnoozeOrigin';
    if (runtime == null ||
        !alarm.armed ||
        firing.kind != CalendarAlarmFiringKind.automatic ||
        firing.generation != alarm.generation ||
        !(rescheduling ||
            firing.state == CalendarAlarmFiringState.accepted ||
            (firing.state == CalendarAlarmFiringState.pending &&
                !firing.dueAt.isAfter(now) &&
                firing.expiresAt.isAfter(now))) ||
        !input.snoozeAt!.isAfter(now) ||
        input.snoozeAt!.isAfter(now.add(const Duration(days: 7)))) {
      throw _failure(CalendarFailureCode.validation);
    }
    final snapshot = await _AlarmWorker(this)._snapshot(alarm.id!, tx);
    final plan = await CalendarAlarmPlanRecord.db.findFirstRow(
      _session,
      where: (t) => t.alarmId.equals(alarm.id!),
      transaction: tx,
    );
    if (snapshot == null ||
        plan == null ||
        plan.dirty ||
        plan.status != CalendarAlarmPlanStatus.ready ||
        plan.generation != alarm.generation ||
        plan.timingDigest != snapshot.digest ||
        !_alarmOriginalActive(parent, firing.originalKey, snapshot.records)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final automatic = await CalendarAlarmFiringRecord.db.count(
      _session,
      where: (t) =>
          t.alarmId.equals(alarm.id!) &
          t.generation.equals(alarm.generation) &
          t.kind.equals(CalendarAlarmFiringKind.automatic) &
          (t.dueAt >= plan.windowStart!) &
          (t.dueAt < plan.windowEnd!),
      transaction: tx,
    );
    final snoozes = await CalendarAlarmActionRecord.db.count(
      _session,
      where: (t) =>
          t.alarmId.equals(alarm.id!) &
          t.originalKey.notEquals(firing.originalKey) &
          (t.pendingSnoozeAt >= plan.windowStart!) &
          (t.pendingSnoozeAt < plan.windowEnd!),
      transaction: tx,
    );
    final retained = await CalendarAlarmFiringRecord.db.count(
      _session,
      where: (t) => t.alarmId.equals(alarm.id!),
      transaction: tx,
    );
    if (automatic + snoozes + 1 > runtime.options.maxFirings ||
        retained + 1 > runtime.options.maxRetainedFirings) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    // Recheck shared time after all database/source validation as well.
    final checked = await _revisionTime(tx);
    if (!input.snoozeAt!.isAfter(checked) ||
        input.snoozeAt!.isAfter(checked.add(const Duration(days: 7)))) {
      throw _failure(CalendarFailureCode.validation);
    }
  }

  Future<CalendarAlarmActivityPage> personalAlarmActivity(
    CalendarAlarmParent input,
    UuidValue alarmId,
    CalendarAlarmActivityKind kind,
    int pageSize,
    String? cursor,
  ) async {
    if (pageSize < 1 || pageSize > _options.maxPageSize) {
      throw _failure(CalendarFailureCode.validation);
    }
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final parent = await _alarmParent(c, input, tx);
      final recipient = await _alarmRecipient(
        c,
        tx,
        CalendarAuthorizationPhase.read,
      );
      final alarms = await _privateAlarms(
        c,
        input,
        recipient,
        tx,
        alarmId: alarmId,
      );
      if (alarms.length != 1) throw _failure(CalendarFailureCode.accessDenied);
      await _decide(
        c,
        [
          _alarmRequest(
            parent,
            CalendarPermission.readPersonalAlarmActivity,
            recipient,
            alarmId: alarmId,
            current: _alarmView(alarms.single, parent),
            activityKind: kind,
          ),
        ],
        tx,
        CalendarAuthorizationPhase.read,
      );
      UuidValue? after;
      if (cursor != null) {
        if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(cursor)) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        final saved = await CalendarCursorRecord.db.findFirstRow(
          _session,
          where: (t) => t.token.equals(cursor),
          transaction: tx,
        );
        if (saved == null ||
            saved.eventOccurrenceState != null ||
            saved.alarmActivityId != alarmId ||
            saved.alarmActivityKind != kind ||
            saved.scopeKey != c.scopeKey ||
            saved.principalId != c.principalId ||
            saved.policyRevision != c.policyRevision ||
            saved.dataRevision != scope.revision ||
            saved.pageSize != pageSize ||
            !saved.expiresAt.isAfter(await _revisionTime(tx)) ||
            saved.fieldGroups.isNotEmpty ||
            saved.taskCalendarId != null ||
            saved.eventCalendarId != null ||
            saved.taskHistoryTaskId != null ||
            saved.taskHistoryOriginalKey != null ||
            saved.taskHistoryAfterRevision != null ||
            saved.taskFieldGroups != null ||
            saved.eventFieldGroups != null ||
            saved.categoryFilter != null) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        after = saved.afterId;
      }
      final firings = kind == CalendarAlarmActivityKind.firings
          ? await CalendarAlarmFiringRecord.db.find(
              _session,
              where: (t) =>
                  t.alarmId.equals(alarmId) &
                  (after == null ? Constant.bool(true) : t.id > after),
              orderBy: (t) => t.id,
              limit: pageSize + 1,
              transaction: tx,
            )
          : <CalendarAlarmFiringRecord>[];
      final actions = kind == CalendarAlarmActivityKind.actions
          ? await CalendarAlarmActionRecord.db.find(
              _session,
              where: (t) =>
                  t.alarmId.equals(alarmId) &
                  (after == null ? Constant.bool(true) : t.id > after),
              orderBy: (t) => t.id,
              limit: pageSize + 1,
              transaction: tx,
            )
          : <CalendarAlarmActionRecord>[];
      final related = firings.isEmpty
          ? <CalendarAlarmActionRecord>[]
          : await CalendarAlarmActionRecord.db.find(
              _session,
              where: (t) =>
                  t.alarmId.equals(alarmId) &
                  t.originalKey.inSet(
                    firings.take(pageSize).map((f) => f.originalKey).toSet(),
                  ),
              limit: pageSize,
              transaction: tx,
            );
      final byKey = {for (final a in related) a.originalKey: a};
      String? continuation;
      if (firings.length > pageSize || actions.length > pageSize) {
        final now = await _revisionTime(tx);
        await CalendarCursorRecord.db.deleteWhere(
          _session,
          where: (t) => t.scopeKey.equals(c.scopeKey) & (t.expiresAt < now),
          transaction: tx,
        );
        if (await CalendarCursorRecord.db.count(
              _session,
              where: (t) => t.scopeKey.equals(c.scopeKey),
              transaction: tx,
              limit: _options.maxCursorsPerScope,
            ) >=
            _options.maxCursorsPerScope) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final random = Random.secure();
        continuation = base64UrlEncode(
          List.generate(32, (_) => random.nextInt(256)),
        ).replaceAll('=', '');
        await CalendarCursorRecord.db.insertRow(
          _session,
          CalendarCursorRecord(
            token: continuation,
            scopeKey: c.scopeKey,
            principalId: c.principalId,
            policyRevision: c.policyRevision,
            dataRevision: scope.revision,
            afterId: kind == CalendarAlarmActivityKind.firings
                ? firings[pageSize - 1].id!
                : actions[pageSize - 1].id!,
            pageSize: pageSize,
            fieldGroups: [],
            alarmActivityId: alarmId,
            alarmActivityKind: kind,
            expiresAt: now.add(_options.cursorLifetime),
          ),
          transaction: tx,
        );
      }
      await _verifyAlarmRecipient(
        c,
        recipient,
        tx,
        CalendarAuthorizationPhase.read,
      );
      return CalendarAlarmActivityPage(
        firings: [
          for (final f in firings.take(pageSize))
            _alarmFiringView(f, byKey[f.originalKey]),
        ],
        actions: [for (final a in actions.take(pageSize)) _alarmActionView(a)],
        nextCursor: continuation,
      );
    });
  }
}
