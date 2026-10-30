part of 'calendar_module.dart';

CalendarTaskOccurrence _taskRecordValue(CalendarTaskOccurrenceRecord r) =>
    CalendarTaskOccurrence(
      originalStart: r.originalStart,
      actualStart: r.replacementTiming != null
          ? taskAnchor(r.replacementTiming!)
          : r.futureTiming != null
          ? taskAnchor(r.futureTiming!)
          : null,
      replacementTiming: r.replacementTiming,
      futureTiming: r.futureTiming,
      contentOverrides: r.contentOverrides,
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
        if (validateTaskOccurrenceContent(row.contentOverrides) !=
            row.contentOverrides) {
          throw ArgumentError('Noncanonical content overrides');
        }
        if (row.replacementTiming != null) {
          validateTaskReplacement(task.data.content, row.replacementTiming!);
        }
        if (row.futureTiming != null) {
          validateTaskReplacement(task.data.content, row.futureTiming!);
        }
        if (row.replacementTiming != null && row.futureTiming != null) {
          throw ArgumentError('Ambiguous stored timing');
        }
        if (row.protocolVersion != null) {
          validateTaskVersion(row.protocolVersion!);
        }
      } catch (_) {
        throw _failure(CalendarFailureCode.unavailable);
      }
    }
    if (task.data.sourceState != null &&
        task.data.sourceState!.nativeMetadataOnly != true) {
      final components = {
        for (final o in task.data.sourceState!.occurrences)
          taskOriginalKey(o.originalStart!): o,
      };
      if (components.length != rows.length ||
          rows.any(
            (r) =>
                components[r.originalKey]?.progress != r.progress ||
                components[r.originalKey]?.version != r.protocolVersion ||
                taskSourceReplacement(components[r.originalKey]!) !=
                    r.replacementTiming ||
                taskSourceFuture(components[r.originalKey]!) !=
                    r.futureTiming ||
                taskSourceContentOverrides(components[r.originalKey]!) !=
                    r.contentOverrides,
          )) {
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
    if (query != null) {
      final requested = query.fieldGroups ?? const <CalendarTaskFieldGroup>[];
      if (requested.length > 4 ||
          !taskOccurrenceContentGroups.containsAll(requested)) {
        throw _failure(CalendarFailureCode.validation);
      }
      groups.addAll(requested);
    }
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
    if ((query.fieldGroups?.length ?? 0) > 4) {
      throw _failure(CalendarFailureCode.validation);
    }
    query = query.copyWith(
      fieldGroups: query.fieldGroups == null
          ? null
          : List.unmodifiable(query.fieldGroups!),
    );
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
        () => previewTaskValues(
          task.data.content,
          query,
          futureChanges: {
            for (final r in stored)
              if (r.futureTiming != null) r.originalStart: r.futureTiming!,
          },
          replacements: {
            for (final r in stored)
              if (r.replacementTiming != null)
                r.originalStart: r.replacementTiming!,
          },
        ),
      );
      final records = {
        for (final r in stored) r.originalKey: r.progress,
      };
      final ownContent = {
        for (final r in stored) r.originalKey: r.contentOverrides,
      };
      final contentGroups =
          (query.fieldGroups ?? const <CalendarTaskFieldGroup>[]).toSet();
      final result = CalendarTaskOccurrencePreview(
        taskId: query.taskId,
        revision: task.identity.revision,
        disclosedGroups: [
          CalendarTaskFieldGroup.timing,
          CalendarTaskFieldGroup.progress,
          ...contentGroups,
        ],
        occurrences: [
          for (final o in values)
            o.copyWith(
              content: contentGroups.isEmpty
                  ? null
                  : taskDisclosedOccurrenceContent(
                      taskEffectiveOccurrenceContent(
                        task.data.content,
                        ownContent[taskOriginalKey(o.originalStart)],
                      ),
                      contentGroups,
                    ),
              contentOverrides: contentGroups.isEmpty
                  ? null
                  : taskDisclosedOccurrenceContent(
                      ownContent[taskOriginalKey(o.originalStart)],
                      contentGroups,
                    ),
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

  Future<CalendarTaskReceipt?> changeTaskOccurrenceTiming(
    CalendarTaskOccurrenceTimingRequest input,
  ) async {
    final key = _taskValue(() => taskOriginalKey(input.originalStart)),
        c = await _context();
    return _transaction(c, (tx, scope) async {
      final task = await _task(c, input.taskId, tx),
          rows = await _taskRecords(task, tx);
      final row = rows.where((r) => r.originalKey == key).firstOrNull;
      final progress = row?.progress ?? task.data.progress;
      final replacement = input.replacement == null
          ? null
          : _taskValue(
              () => validateTaskReplacement(
                task.data.content,
                input.replacement!,
              ),
            );
      if (replacement != null &&
          (input.thisAndFuture ? row?.replacementTiming : row?.futureTiming) !=
              null) {
        throw _failure(CalendarFailureCode.validation);
      }
      final singles = {
            for (final r in rows)
              if (r.replacementTiming != null)
                r.originalStart: r.replacementTiming!,
          },
          future = {
            for (final r in rows)
              if (r.futureTiming != null) r.originalStart: r.futureTiming!,
          };
      final proposedSingles = Map<CalendarEventTiming, CalendarTaskTiming>.of(
            singles,
          ),
          proposedFuture = Map<CalendarEventTiming, CalendarTaskTiming>.of(
            future,
          );
      final selected = input.thisAndFuture ? proposedFuture : proposedSingles;
      if (replacement == null) {
        selected.remove(input.originalStart);
      } else {
        selected[input.originalStart] = replacement;
      }
      final currentValue = _taskValue(
        () => taskTimingAt(
          task.data.content,
          input.originalStart,
          progress,
          replacements: singles,
          futureChanges: future,
        ),
      );
      final proposedValue = _taskValue(
        () => taskTimingAt(
          task.data.content,
          input.originalStart,
          progress,
          replacements: proposedSingles,
          futureChanges: proposedFuture,
        ),
      );
      CalendarAuthorizationRequest request(
        CalendarTaskProtocolVersion? version,
        CalendarTaskSourceState? sourceState,
      ) => _tr(
        task.parent,
        CalendarPermission.updateTask,
        task: task,
        timingChange: input,
        currentOccurrence: currentValue,
        proposedOccurrence: proposedValue,
        recordedOccurrences: [for (final r in rows) _taskRecordValue(r)],
        content: task.data.content,
        progress: task.data.progress,
        assignees: task.data.assignees,
        version: task.data.protocolVersion,
        occurrenceVersion: version,
        sourceState: sourceState,
      );
      await _decide(
        c,
        [request(row?.protocolVersion, task.data.sourceState)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _taskRevision(task, input.expectedRevision);
      _taskValue(
        () => requireTaskOriginals(task.data.content, [
          for (final r in rows) r.originalStart,
          if (row == null) input.originalStart,
        ]),
      );
      final changed =
          (input.thisAndFuture ? row?.futureTiming : row?.replacementTiming) !=
          replacement;
      if (changed && row == null && rows.length >= 1000) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final now = await _revisionTime(tx, previous: task.data.updatedAt);
      final version = changed
          ? _taskValue(
              () => row == null
                  ? taskOccurrenceInitialVersion(now)
                  : advanceTaskVersion(
                      row.protocolVersion ??
                          taskOccurrenceInitialVersion(
                            task.data.updatedAt,
                            legacy: true,
                          ),
                      now,
                    ),
            )
          : row?.protocolVersion;
      final sourceState = changed && task.data.sourceState != null
          ? _taskValue(
              () => changeTaskSourceTiming(
                task.data.protocolUid,
                task.data.sourceState!,
                input.originalStart,
                replacement,
                progress,
                version!,
                thisAndFuture: input.thisAndFuture,
              ),
            )
          : task.data.sourceState;
      await _decide(
        c,
        [request(version, sourceState)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, [request(version, sourceState)], tx);
      if (changed) {
        if (row == null) {
          await CalendarTaskOccurrenceRecord.db.insertRow(
            _session,
            CalendarTaskOccurrenceRecord(
              taskId: input.taskId,
              originalKey: key,
              originalStart: input.originalStart,
              replacementTiming: input.thisAndFuture ? null : replacement,
              futureTiming: input.thisAndFuture ? replacement : null,
              progress: progress,
              protocolVersion: version,
            ),
            transaction: tx,
          );
        } else {
          if (input.thisAndFuture) {
            row.futureTiming = replacement;
          } else {
            row.replacementTiming = replacement;
          }
          row.protocolVersion = version;
          await CalendarTaskOccurrenceRecord.db.updateRow(
            _session,
            row,
            transaction: tx,
          );
        }
      }
      task.identity.revision++;
      task.data.updatedAt = now;
      task.data.sourceState = sourceState;
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
        CalendarTaskSourceState? sourceState,
      ]) => _tr(
        task.parent,
        CalendarPermission.changeTaskProgress,
        task: task,
        occurrenceChange: input,
        currentOccurrence: _taskValue(
          () => taskTimingAt(
            task.data.content,
            input.originalStart,
            before,
            replacements: {
              for (final r in rows)
                if (r.replacementTiming != null)
                  r.originalStart: r.replacementTiming!,
            },
            futureChanges: {
              for (final r in rows)
                if (r.futureTiming != null) r.originalStart: r.futureTiming!,
            },
          ),
        ),
        proposedOccurrence: _taskValue(
          () => taskTimingAt(
            task.data.content,
            input.originalStart,
            after,
            replacements: {
              for (final r in rows)
                if (r.replacementTiming != null)
                  r.originalStart: r.replacementTiming!,
            },
            futureChanges: {
              for (final r in rows)
                if (r.futureTiming != null) r.originalStart: r.futureTiming!,
            },
          ),
        ),
        content: task.data.content,
        progress: task.data.progress,
        assignees: task.data.assignees,
        version: task.data.protocolVersion,
        occurrenceVersion: version ?? row?.protocolVersion,
        sourceState: sourceState ?? task.data.sourceState,
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
          ? _taskValue(
              () => row == null
                  ? taskOccurrenceInitialVersion(now)
                  : advanceTaskVersion(
                      row.protocolVersion ??
                          taskOccurrenceInitialVersion(
                            task.data.updatedAt,
                            legacy: true,
                          ),
                      now,
                    ),
            )
          : row?.protocolVersion;
      final sourceState = changed && task.data.sourceState != null
          ? _taskValue(
              () => changeTaskSourceOccurrence(
                task.data.protocolUid,
                task.data.sourceState!,
                input.originalStart,
                after,
                version!,
              ),
            )
          : task.data.sourceState;
      await _decide(
        c,
        [request(after, version, sourceState)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, [
        request(after, version, sourceState),
      ], tx);
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
              protocolVersion: version,
            ),
            transaction: tx,
          );
        } else {
          row.progress = after;
          row.protocolVersion = version;
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
      task.data.sourceState = sourceState;
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
            saved.eventOccurrenceState != null ||
            saved.alarmActivityId != null ||
            saved.alarmActivityKind != null ||
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
