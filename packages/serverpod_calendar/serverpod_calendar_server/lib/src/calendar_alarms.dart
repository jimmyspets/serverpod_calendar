part of 'calendar_module.dart';

final class _AlarmParent {
  _AlarmParent(this.parent, this.event, this.task);
  final _Active parent;
  final _Event? event;
  final _Task? task;
  bool compatible(CalendarAlarmDefinition definition) => event != null
      ? alarmEventAnchorCompatible(definition, event!.data.content.timing)
      : alarmTaskAnchorCompatible(definition, task!.data.content.timing);
}

extension CalendarAlarmOperations on CalendarService {
  Future<_AlarmParent> _alarmParent(
    CalendarHostContext c,
    CalendarAlarmParent parent,
    Transaction tx,
  ) async {
    if (parent.kind == CalendarAlarmParentKind.event) {
      final event = await _event(c, parent.id, tx);
      return _AlarmParent(event.parent, event, null);
    }
    final task = await _task(c, parent.id, tx);
    return _AlarmParent(task.parent, null, task);
  }

  Future<CalendarAlarmRecipient> _alarmRecipient(
    CalendarHostContext c,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    final result = await _bounded(
      () => _runtime.policy.resolveAlarmRecipient(
        _session,
        c,
        tx,
        phase,
      ),
    );
    // Invalid trusted adapter results fail unavailable, never widen a query.
    try {
      validateCalendarOpaqueText(result.namespace, maxUtf8Bytes: 256);
      validateCalendarOpaqueText(result.key, maxUtf8Bytes: 256);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return result;
  }

  Future<void> _verifyAlarmRecipient(
    CalendarHostContext c,
    CalendarAlarmRecipient previous,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    await _verifyContext(c);
    final current = await _alarmRecipient(c, tx, phase);
    if (current.namespace != previous.namespace ||
        current.key != previous.key) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  CalendarAlarmView _alarmView(
    CalendarAlarmRecord row,
    _AlarmParent parent, {
    CalendarAlarmPlanRecord? plan,
  }) {
    try {
      validateAlarmDefinition(row.definition);
      if (row.generation < 1 ||
          row.generation > CalendarService._maxRevision ||
          row.revision < 1 ||
          row.revision > CalendarService._maxRevision ||
          row.calendarId != parent.parent.identity.id ||
          row.updatedAt.isBefore(row.createdAt)) {
        throw ArgumentError('Invalid stored alarm');
      }
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return CalendarAlarmView(
      id: row.id!,
      parent: CalendarAlarmParent(kind: row.parentKind, id: row.parentId),
      revision: row.revision,
      armed: row.armed,
      planningStatus: !row.armed
          ? null
          : plan == null ||
                (plan.dirty && plan.status == CalendarAlarmPlanStatus.ready)
          ? CalendarAlarmPlanStatus.pending
          : plan.status,
      planningWindowEnd:
          row.armed &&
              plan?.dirty == false &&
              plan?.status == CalendarAlarmPlanStatus.ready
          ? plan!.windowEnd
          : null,
      definition: row.definition,
      anchorCompatible: parent.compatible(row.definition),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  CalendarAuthorizationRequest _alarmRequest(
    _AlarmParent parent,
    CalendarPermission operation,
    CalendarAlarmRecipient recipient, {
    UuidValue? alarmId,
    CalendarAlarmView? current,
    CalendarAlarmDefinition? proposed,
    bool? armed,
  }) => CalendarAuthorizationRequest(
    key:
        '${operation.name}:${alarmId ?? parent.event?.identity.id ?? parent.task!.identity.id}',
    operation: operation,
    current: parent.parent.snapshot,
    calendarId: parent.parent.identity.id,
    eventId: parent.event?.identity.id,
    currentEvent: parent.event?.snapshot,
    taskId: parent.task?.identity.id,
    currentTask: parent.task?.snapshot,
    alarmRecipient: recipient,
    alarmId: alarmId,
    currentAlarm: current,
    proposedAlarmDefinition: proposed,
    proposedAlarmArmed: armed,
  );

  Future<List<CalendarAlarmRecord>> _privateAlarms(
    CalendarHostContext c,
    CalendarAlarmParent parent,
    CalendarAlarmRecipient recipient,
    Transaction tx, {
    UuidValue? alarmId,
  }) => CalendarAlarmRecord.db.find(
    _session,
    where: (t) =>
        t.scopeKey.equals(c.scopeKey) &
        t.parentKind.equals(parent.kind) &
        t.parentId.equals(parent.id) &
        t.recipientNamespace.equals(recipient.namespace) &
        t.recipientKey.equals(recipient.key) &
        (alarmId == null ? Constant.bool(true) : t.id.equals(alarmId)),
    orderBy: (t) => t.id,
    limit: 17,
    transaction: tx,
  );

  Future<List<CalendarAlarmView>> listPersonalAlarms(
    CalendarAlarmParent input,
  ) async {
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final parent = await _alarmParent(c, input, tx);
      final recipient = await _alarmRecipient(
        c,
        tx,
        CalendarAuthorizationPhase.read,
      );
      await _decide(
        c,
        [
          _alarmRequest(
            parent,
            CalendarPermission.readPersonalAlarms,
            recipient,
          ),
        ],
        tx,
        CalendarAuthorizationPhase.read,
      );
      final rows = await _privateAlarms(c, input, recipient, tx);
      if (rows.length > 16) throw _failure(CalendarFailureCode.limitExceeded);
      final plans = rows.isEmpty
          ? <CalendarAlarmPlanRecord>[]
          : await CalendarAlarmPlanRecord.db.find(
              _session,
              where: (t) => t.alarmId.inSet(rows.map((r) => r.id!).toSet()),
              limit: 17,
              transaction: tx,
            );
      if (plans.length > 16) throw _failure(CalendarFailureCode.unavailable);
      final byAlarm = {for (final p in plans) p.alarmId: p};
      final views = rows
          .map((r) => _alarmView(r, parent, plan: byAlarm[r.id]))
          .toList();
      for (final view in views) {
        await _decide(
          c,
          [
            _alarmRequest(
              parent,
              CalendarPermission.readPersonalAlarms,
              recipient,
              alarmId: view.id,
              current: view,
            ),
          ],
          tx,
          CalendarAuthorizationPhase.read,
        );
      }
      await _verifyAlarmRecipient(
        c,
        recipient,
        tx,
        CalendarAuthorizationPhase.read,
      );
      return List.unmodifiable(views);
    });
  }

  Future<CalendarAlarmView?> createPersonalAlarm(
    CalendarAlarmCreateRequest input,
  ) async {
    final c = await _context();
    final definition = _taskValue(
      () => validateAlarmDefinition(input.definition),
    );
    return _transaction(c, (tx, _) async {
      final parent = await _alarmParent(c, input.parent, tx);
      final recipient = await _alarmRecipient(
        c,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final id = const Uuid().v4obj();
      final requests = [
        _alarmRequest(
          parent,
          CalendarPermission.createPersonalAlarm,
          recipient,
          alarmId: id,
          proposed: definition,
        ),
      ];
      await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (!parent.compatible(definition)) {
        throw _failure(CalendarFailureCode.validation);
      }
      if ((await _privateAlarms(c, input.parent, recipient, tx)).length >= 16) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      await _verifyAlarmRecipient(
        c,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      final decisions = await _final(c, requests, tx);
      final now = await _revisionTime(tx);
      final row = await CalendarAlarmRecord.db.insertRow(
        _session,
        CalendarAlarmRecord(
          id: id,
          scopeKey: c.scopeKey,
          calendarId: parent.parent.identity.id!,
          parentKind: input.parent.kind,
          parentId: input.parent.id,
          recipientNamespace: recipient.namespace,
          recipientKey: recipient.key,
          revision: 1,
          definition: definition,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
      return decisions.values.every((d) => d.discloseMutationReceipt)
          ? _alarmView(row, parent)
          : null;
    });
  }

  Future<CalendarAlarmView?> updatePersonalAlarm(
    CalendarAlarmUpdateRequest input,
  ) async {
    final c = await _context();
    final definition = _taskValue(
      () => validateAlarmDefinition(input.definition),
    );
    return _transaction(c, (tx, _) async {
      final parent = await _alarmParent(c, input.parent, tx);
      final recipient = await _alarmRecipient(
        c,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final rows = await _privateAlarms(
        c,
        input.parent,
        recipient,
        tx,
        alarmId: input.alarmId,
      );
      if (rows.length != 1) throw _failure(CalendarFailureCode.accessDenied);
      final row = rows.single;
      final view = _alarmView(row, parent);
      final requests = [
        _alarmRequest(
          parent,
          CalendarPermission.updatePersonalAlarm,
          recipient,
          alarmId: row.id,
          current: view,
          proposed: definition,
        ),
      ];
      await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (input.expectedRevision != row.revision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      if (row.revision >= CalendarService._maxRevision ||
          row.generation >= CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (!parent.compatible(definition)) {
        throw _failure(CalendarFailureCode.validation);
      }
      await _verifyAlarmRecipient(
        c,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      final decisions = await _final(c, requests, tx);
      if (row.definition != definition) {
        row.definition = definition;
        row.generation++;
        await _invalidateAlarmWork(row, tx);
      }
      row.revision++;
      row.updatedAt = await _revisionTime(tx, previous: row.updatedAt);
      await CalendarAlarmRecord.db.updateRow(_session, row, transaction: tx);
      return decisions.values.every((d) => d.discloseMutationReceipt)
          ? _alarmView(row, parent)
          : null;
    });
  }

  Future<CalendarAlarmView?> setPersonalAlarmArmed(
    CalendarAlarmParent input,
    UuidValue alarmId,
    int expectedRevision,
    bool armed,
  ) async {
    final c = await _context();
    if (armed && _runtime.alarms == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return _transaction(c, (tx, _) async {
      final parent = await _alarmParent(c, input, tx);
      final recipient = await _alarmRecipient(
        c,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final rows = await _privateAlarms(
        c,
        input,
        recipient,
        tx,
        alarmId: alarmId,
      );
      if (rows.length != 1) throw _failure(CalendarFailureCode.accessDenied);
      final row = rows.single;
      final requests = [
        _alarmRequest(
          parent,
          CalendarPermission.armPersonalAlarm,
          recipient,
          alarmId: row.id,
          current: _alarmView(row, parent),
          armed: armed,
        ),
      ];
      await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (row.revision != expectedRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      if (row.revision >= CalendarService._maxRevision ||
          row.generation >= CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (armed && !parent.compatible(row.definition)) {
        throw _failure(CalendarFailureCode.validation);
      }
      await _verifyAlarmRecipient(
        c,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      final decisions = await _final(c, requests, tx);
      final changed = row.armed != armed;
      row.armed = armed;
      if (changed) row.generation++;
      row.revision++;
      row.updatedAt = await _revisionTime(tx, previous: row.updatedAt);
      if (changed) await _invalidateAlarmWork(row, tx);
      await CalendarAlarmRecord.db.updateRow(_session, row, transaction: tx);
      if (armed) {
        await CalendarAlarmPlanRecord.db.insert(
          _session,
          [
            CalendarAlarmPlanRecord(
              alarmId: row.id!,
              scopeKey: c.scopeKey,
              generation: row.generation,
              nextScanAt: row.updatedAt,
            ),
          ],
          transaction: tx,
          ignoreConflicts: true,
          noReturn: true,
        );
      }
      return decisions.values.every((d) => d.discloseMutationReceipt)
          ? _alarmView(row, parent)
          : null;
    });
  }

  Future<void> deletePersonalAlarm(
    CalendarAlarmParent input,
    UuidValue alarmId,
    int expectedRevision,
  ) async {
    final c = await _context();
    await _transaction(c, (tx, _) async {
      final parent = await _alarmParent(c, input, tx);
      final recipient = await _alarmRecipient(
        c,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final rows = await _privateAlarms(
        c,
        input,
        recipient,
        tx,
        alarmId: alarmId,
      );
      if (rows.length != 1) throw _failure(CalendarFailureCode.accessDenied);
      final row = rows.single;
      final requests = [
        _alarmRequest(
          parent,
          CalendarPermission.deletePersonalAlarm,
          recipient,
          alarmId: row.id,
          current: _alarmView(row, parent),
        ),
      ];
      await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (expectedRevision != row.revision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      await _verifyAlarmRecipient(
        c,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      await _final(c, requests, tx);
      await _deleteAlarmWork(row.id!, tx);
      await CalendarAlarmRecord.db.deleteRow(_session, row, transaction: tx);
    });
  }

  Future<void> _deleteAlarmWork(UuidValue alarmId, Transaction tx) async {
    for (final table in const [
      'serverpod_calendar_alarm_firing',
      'serverpod_calendar_alarm_action',
      'serverpod_calendar_alarm_plan',
    ]) {
      await _session.db.unsafeExecute(
        'DELETE FROM $table WHERE "alarmId"=CAST(@alarm AS uuid)',
        parameters: QueryParameters.named({'alarm': alarmId.toString()}),
        transaction: tx,
      );
    }
  }

  Future<void> _invalidateAlarmWork(
    CalendarAlarmRecord alarm,
    Transaction tx,
  ) async {
    await _session.db.unsafeExecute(
      'UPDATE serverpod_calendar_alarm_plan SET dirty=true, '
      'generation=@generation, "nextScanAt"=clock_timestamp(), '
      '"leaseOwner"=NULL, "leaseUntil"=NULL, "leaseFence"=CASE WHEN "leaseFence"<9007199254740991 THEN "leaseFence"+1 ELSE "leaseFence" END '
      'WHERE "alarmId"=CAST(@alarm AS uuid)',
      parameters: QueryParameters.named({
        'alarm': alarm.id!.toString(),
        'generation': alarm.generation,
      }),
      transaction: tx,
    );
    await _session.db.unsafeExecute(
      """UPDATE serverpod_calendar_alarm_firing SET state='suppressed',
      reason='generationChanged', "terminalAt"=clock_timestamp(),
      "updatedAt"=clock_timestamp(), "leaseOwner"=NULL, "leaseUntil"=NULL,
      "leaseFence"=CASE WHEN "leaseFence"<9007199254740991 THEN "leaseFence"+1 ELSE "leaseFence" END WHERE "alarmId"=CAST(@alarm AS uuid) AND state='pending'""",
      parameters: QueryParameters.named({'alarm': alarm.id!.toString()}),
      transaction: tx,
    );
  }

  Future<void> _deleteParentAlarms(
    String scopeKey,
    CalendarAlarmParentKind kind,
    UuidValue parentId,
    Transaction tx,
  ) async {
    // Set-based deletion avoids a private per-recipient cap on shared deletion.
    for (final table in const [
      'serverpod_calendar_alarm_firing',
      'serverpod_calendar_alarm_action',
      'serverpod_calendar_alarm_plan',
    ]) {
      await _session.db.unsafeExecute(
        'DELETE FROM $table WHERE "alarmId" IN '
        '(SELECT id FROM serverpod_calendar_alarm WHERE "scopeKey"=@scope '
        'AND "parentKind"=@kind AND "parentId"=CAST(@parent AS uuid))',
        parameters: QueryParameters.named({
          'scope': scopeKey,
          'kind': kind.name,
          'parent': parentId.toString(),
        }),
        transaction: tx,
      );
    }
    await CalendarAlarmRecord.db.deleteWhere(
      _session,
      where: (t) =>
          t.scopeKey.equals(scopeKey) &
          t.parentKind.equals(kind) &
          t.parentId.equals(parentId),
      transaction: tx,
      noReturn: true,
    );
  }
}
