part of 'calendar_module.dart';

CalendarTaskOccurrence _taskRecordValue(CalendarTaskOccurrenceRecord r) =>
    CalendarTaskOccurrence(
      originalStart: r.originalStart,
      progress: r.progress,
    );

extension CalendarTaskOccurrenceOperations on CalendarService {
  Future<List<CalendarTaskOccurrenceRecord>> _taskRecords(
    _Task task,
    Transaction tx,
  ) async {
    final rows = await CalendarTaskOccurrenceRecord.db.find(
      _session,
      where: (t) => t.taskId.equals(task.identity.id!),
      orderBy: (t) => t.originalKey,
      limit: 1001,
      transaction: tx,
    );
    if (rows.length > 1000) throw _failure(CalendarFailureCode.limitExceeded);
    for (final row in rows) {
      try {
        if (row.originalKey != taskOriginalKey(row.originalStart)) {
          throw ArgumentError('Stored identity mismatch');
        }
        validateTaskProgress(row.progress);
      } catch (_) {
        throw _failure(CalendarFailureCode.unavailable);
      }
    }
    try {
      requireTaskOriginals(task.data.content, [
        for (final r in rows) r.originalStart,
      ]);
    } on RecurrenceLimitException {
      throw _failure(CalendarFailureCode.limitExceeded);
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return rows;
  }

  Future<List<CalendarTaskOccurrenceRecord>> _taskOccurrenceRead(
    CalendarHostContext c,
    _Task task,
    Transaction tx,
    CalendarPermission op, {
    CalendarTaskOccurrenceQuery? query,
    CalendarTaskHistoryQuery? history,
  }) async {
    final records = await _taskRecords(task, tx);
    CalendarTaskOccurrence? current;
    if (history != null) {
      final key = taskOriginalKey(history.originalStart);
      for (final r in records) {
        if (r.originalKey == key) current = _taskRecordValue(r);
      }
    }
    final groups = {
      CalendarTaskFieldGroup.timing,
      CalendarTaskFieldGroup.progress,
    };
    for (final operation in [CalendarPermission.readTask, op]) {
      final r = _tr(
        task.parent,
        operation,
        task: task,
        groups: groups,
        occurrenceQuery: query,
        historyQuery: history,
        currentOccurrence: current,
        recordedOccurrences: [for (final r in records) _taskRecordValue(r)],
      );
      final decisions = await _decide(
        c,
        [r],
        tx,
        CalendarAuthorizationPhase.read,
      );
      if (!decisions[r.key]!.taskDisclosedGroups.containsAll(groups)) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
    }
    return records;
  }

  void _taskReadRevision(_Task task, int expected) {
    if (expected < 1 || expected > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (expected != task.identity.revision) {
      throw _failure(CalendarFailureCode.staleRevision);
    }
  }

  Future<CalendarTaskOccurrencePreview> previewTaskOccurrences(
    CalendarTaskOccurrenceQuery query,
  ) async {
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final task = await _task(c, query.taskId, tx);
      final stored = await _taskOccurrenceRead(
        c,
        task,
        tx,
        CalendarPermission.previewTaskOccurrences,
        query: query,
      );
      _taskReadRevision(task, query.expectedRevision);
      final values = _taskValue(
        () => previewTaskValues(task.data.content, query),
      );
      final records = {
        for (final r in stored) r.originalKey: r.progress,
      };
      final result = CalendarTaskOccurrencePreview(
        taskId: query.taskId,
        revision: task.identity.revision,
        occurrences: [
          for (final o in values)
            o.copyWith(
              progress:
                  records[taskOriginalKey(o.originalStart)] ??
                  task.data.progress,
            ),
        ],
      );
      await _verifyContext(c);
      return result;
    });
  }

  Future<CalendarTaskReceipt?> changeTaskOccurrenceProgress(
    CalendarTaskOccurrenceProgressRequest input,
  ) async {
    final key = _taskValue(() => taskOriginalKey(input.originalStart)),
        c = await _context();
    return _transaction(c, (tx, scope) async {
      final task = await _task(c, input.taskId, tx),
          rows = await _taskRecords(task, tx);
      CalendarTaskOccurrenceRecord? row;
      for (final r in rows) {
        if (r.originalKey == key) row = r;
      }
      final before = row?.progress ?? task.data.progress;
      CalendarAuthorizationRequest request(
        CalendarTaskProgress after, [
        CalendarTaskProtocolVersion? version,
      ]) => _tr(
        task.parent,
        CalendarPermission.changeTaskProgress,
        task: task,
        occurrenceChange: input,
        currentOccurrence: CalendarTaskOccurrence(
          originalStart: input.originalStart,
          progress: before,
        ),
        proposedOccurrence: CalendarTaskOccurrence(
          originalStart: input.originalStart,
          progress: after,
        ),
        content: task.data.content,
        progress: task.data.progress,
        assignees: task.data.assignees,
        version: version,
      );
      await _decide(
        c,
        [request(before)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _taskRevision(task, input.expectedRevision);
      _taskValue(
        () => requireTaskOriginal(task.data.content, input.originalStart),
      );
      final now = await _revisionTime(tx, previous: task.data.updatedAt);
      final after = _taskValue(
        () => changeTaskProgressValue(
          before,
          CalendarTaskProgressRequest(
            taskId: input.taskId,
            expectedRevision: input.expectedRevision,
            action: input.action,
            percentComplete: input.percentComplete,
          ),
          now,
        ),
      );
      final changed = jsonEncode(before.toJson()) != jsonEncode(after.toJson());
      if (changed && row == null && rows.length >= 1000) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final version = changed
          ? _taskValue(() => advanceTaskVersion(task.data.protocolVersion, now))
          : task.data.protocolVersion;
      await _decide(
        c,
        [request(after, version)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, [request(after, version)], tx);
      task.identity.revision++;
      if (changed) {
        if (row == null) {
          await CalendarTaskOccurrenceRecord.db.insertRow(
            _session,
            CalendarTaskOccurrenceRecord(
              taskId: input.taskId,
              originalKey: key,
              originalStart: input.originalStart,
              progress: after,
            ),
            transaction: tx,
          );
        } else {
          row.progress = after;
          await CalendarTaskOccurrenceRecord.db.updateRow(
            _session,
            row,
            transaction: tx,
          );
        }
        await CalendarTaskHistoryRecord.db.insertRow(
          _session,
          CalendarTaskHistoryRecord(
            taskId: input.taskId,
            originalKey: key,
            originalStart: input.originalStart,
            revision: task.identity.revision,
            action: input.action,
            before: before,
            after: after,
            recordedAt: eventProtocolInstant(now),
          ),
          transaction: tx,
        );
      }
      task.data.updatedAt = now;
      task.data.protocolVersion = version;
      await CalendarTaskDataRecord.db.updateRow(
        _session,
        task.data,
        transaction: tx,
      );
      await CalendarTaskRecord.db.updateRow(
        _session,
        task.identity,
        transaction: tx,
      );
      await _bump(scope, tx);
      return _taskReceipt(task, decisions.values);
    });
  }

  Future<CalendarTaskHistoryPage> taskOccurrenceHistory(
    CalendarTaskHistoryQuery query,
  ) async {
    if (query.pageSize < 1 || query.pageSize > _options.maxPageSize) {
      throw _failure(CalendarFailureCode.validation);
    }
    final key = _taskValue(() => taskOriginalKey(query.originalStart)),
        c = await _context();
    return _transaction(c, (tx, scope) async {
      final task = await _task(c, query.taskId, tx);
      await _taskOccurrenceRead(
        c,
        task,
        tx,
        CalendarPermission.readTaskHistory,
        history: query,
      );
      _taskReadRevision(task, query.expectedRevision);
      _taskValue(
        () => requireTaskOriginal(task.data.content, query.originalStart),
      );
      int after = 0;
      if (query.cursor != null) {
        if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(query.cursor!)) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        final saved = await CalendarCursorRecord.db.findFirstRow(
          _session,
          where: (t) => t.token.equals(query.cursor!),
          transaction: tx,
        );
        if (saved == null ||
            saved.taskHistoryTaskId != query.taskId ||
            saved.taskHistoryOriginalKey != key ||
            saved.taskHistoryAfterRevision == null ||
            saved.taskCalendarId != task.identity.calendarId ||
            saved.scopeKey != c.scopeKey ||
            saved.principalId != c.principalId ||
            saved.policyRevision != c.policyRevision ||
            saved.dataRevision != scope.revision ||
            saved.pageSize != query.pageSize ||
            !saved.expiresAt.isAfter(DateTime.now().toUtc())) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        after = saved.taskHistoryAfterRevision!;
      }
      final rows = await CalendarTaskHistoryRecord.db.find(
        _session,
        where: (t) =>
            t.taskId.equals(query.taskId) &
            t.originalKey.equals(key) &
            (t.revision > after),
        orderBy: (t) => t.revision,
        limit: query.pageSize + 1,
        transaction: tx,
      );
      final entries = <CalendarTaskHistoryEntry>[];
      for (final r in rows.take(query.pageSize)) {
        try {
          if (r.originalKey != taskOriginalKey(r.originalStart) ||
              r.revision > task.identity.revision ||
              r.revision < 2 ||
              !r.recordedAt.isUtc) {
            throw ArgumentError('Invalid history');
          }
          validateTaskProgress(r.before);
          validateTaskProgress(r.after);
          TimedValue.utc(r.recordedAt);
          final replay = changeTaskProgressValue(
            r.before,
            CalendarTaskProgressRequest(
              taskId: query.taskId,
              expectedRevision: r.revision - 1,
              action: r.action,
              percentComplete:
                  r.action == CalendarTaskProgressAction.setPercentage
                  ? r.after.percentComplete
                  : null,
            ),
            r.recordedAt,
          );
          if (jsonEncode(replay.toJson()) != jsonEncode(r.after.toJson()) ||
              jsonEncode(r.before.toJson()) == jsonEncode(r.after.toJson())) {
            throw ArgumentError('Invalid transition evidence');
          }
        } catch (_) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        entries.add(
          CalendarTaskHistoryEntry(
            revision: r.revision,
            action: r.action,
            before: r.before,
            after: r.after,
            recordedAt: r.recordedAt,
          ),
        );
      }
      await _verifyContext(c);
      String? cursor;
      if (rows.length > query.pageSize) {
        final expired = await CalendarCursorRecord.db.find(
          _session,
          where: (t) =>
              t.scopeKey.equals(c.scopeKey) &
              (t.expiresAt < DateTime.now().toUtc()),
          limit: _options.maxCursorsPerScope,
          transaction: tx,
        );
        if (expired.isNotEmpty) {
          await CalendarCursorRecord.db.delete(
            _session,
            expired,
            transaction: tx,
          );
        }
        if (await CalendarCursorRecord.db.count(
              _session,
              where: (t) => t.scopeKey.equals(c.scopeKey),
              limit: _options.maxCursorsPerScope,
              transaction: tx,
            ) >=
            _options.maxCursorsPerScope) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final random = Random.secure();
        cursor = base64UrlEncode(List.generate(32, (_) => random.nextInt(256)))
            .replaceAll('=', '');
        await CalendarCursorRecord.db.insertRow(
          _session,
          CalendarCursorRecord(
            token: cursor,
            scopeKey: c.scopeKey,
            principalId: c.principalId,
            policyRevision: c.policyRevision,
            dataRevision: scope.revision,
            afterId: query.taskId,
            pageSize: query.pageSize,
            fieldGroups: [],
            taskCalendarId: task.identity.calendarId,
            taskFieldGroups: [
              CalendarTaskFieldGroup.timing,
              CalendarTaskFieldGroup.progress,
            ],
            taskHistoryTaskId: query.taskId,
            taskHistoryOriginalKey: key,
            taskHistoryAfterRevision: entries.last.revision,
            expiresAt: DateTime.now().toUtc().add(_options.cursorLifetime),
          ),
          transaction: tx,
        );
      }
      return CalendarTaskHistoryPage(
        taskId: query.taskId,
        revision: task.identity.revision,
        originalStart: query.originalStart,
        entries: entries,
        nextCursor: cursor,
      );
    });
  }
}
