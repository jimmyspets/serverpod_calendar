part of 'calendar_module.dart';

extension CalendarTaskOccurrenceContentOperations on CalendarService {
  Future<CalendarTaskReceipt?> changeTaskOccurrenceContent(
    CalendarTaskOccurrenceContentRequest input,
  ) async {
    if (input.changes.length > 4) {
      throw _failure(CalendarFailureCode.validation);
    }
    input = input.copyWith(changes: List.unmodifiable(input.changes));
    final key = _taskValue(() => taskOriginalKey(input.originalStart)),
        c = await _context();
    return _transaction(c, (tx, scope) async {
      final task = await _task(c, input.taskId, tx),
          rows = await _taskRecords(task, tx);
      final row = rows.where((r) => r.originalKey == key).firstOrNull;
      final progress = row?.progress ?? task.data.progress;
      final proposed = _taskValue(
        () => changeTaskOccurrenceContentValues(
          row?.contentOverrides,
          input.changes,
        ),
      );
      CalendarTaskOccurrence value(CalendarTaskOccurrenceContent? own) =>
          _taskValue(
            () => taskTimingAt(
              task.data.content,
              input.originalStart,
              progress,
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
          ).copyWith(
            content: taskEffectiveOccurrenceContent(task.data.content, own),
            contentOverrides: own,
          );
      final currentValue = value(row?.contentOverrides),
          proposedValue = value(proposed);
      CalendarAuthorizationRequest request(
        CalendarTaskProtocolVersion? version,
        CalendarTaskSourceState? source,
      ) => _tr(
        task.parent,
        CalendarPermission.updateTask,
        task: task,
        contentChange: input,
        currentOccurrence: currentValue,
        proposedOccurrence: proposedValue,
        recordedOccurrences: [for (final r in rows) _taskRecordValue(r)],
        content: task.data.content,
        progress: task.data.progress,
        assignees: task.data.assignees,
        version: task.data.protocolVersion,
        occurrenceVersion: version,
        sourceState: source,
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
      final now = await _revisionTime(tx, previous: task.data.updatedAt);
      final initial =
          row?.protocolVersion ??
          taskOccurrenceInitialVersion(
            row == null ? now : task.data.updatedAt,
            legacy: row != null,
          );
      var changed = row?.contentOverrides != proposed;
      final candidate = task.data.sourceState == null
          ? null
          : _taskValue(
              () => changeTaskSourceContent(
                task.data.protocolUid,
                task.data.sourceState!,
                input.originalStart,
                proposed,
                input.changes,
                progress,
                initial,
              ),
            );
      if (candidate != null &&
          taskSourceJson(candidate) != taskSourceJson(task.data.sourceState!)) {
        changed = true;
      }
      if (changed && row == null && rows.length >= 1000) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final version = changed
          ? _taskValue(
              () => row == null ? initial : advanceTaskVersion(initial, now),
            )
          : row?.protocolVersion;
      final source = !changed
          ? task.data.sourceState
          : candidate == null
          ? null
          : _taskValue(
              () => changeTaskSourceContent(
                task.data.protocolUid,
                task.data.sourceState!,
                input.originalStart,
                proposed,
                input.changes,
                progress,
                version!,
              ),
            );
      await _decide(
        c,
        [request(version, source)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, [request(version, source)], tx);
      if (changed) {
        if (row == null) {
          await CalendarTaskOccurrenceRecord.db.insertRow(
            _session,
            CalendarTaskOccurrenceRecord(
              taskId: input.taskId,
              originalKey: key,
              originalStart: input.originalStart,
              contentOverrides: proposed,
              progress: progress,
              protocolVersion: version,
            ),
            transaction: tx,
          );
        } else {
          row.contentOverrides = proposed;
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
      task.data.sourceState = source;
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
}
