part of 'calendar_module.dart';

extension CalendarTaskReplacementOperations on CalendarService {
  Future<CalendarTaskReplaceResult> replaceTasksFromImport(
    CalendarTaskReplaceRequest input,
  ) async {
    if (input.bytes.lengthInBytes > const IcalendarSyntaxLimits().maxBytes ||
        input.selection.isEmpty ||
        input.selection.length > const IcalendarComponentLimits().maxTasks) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final selection = List<CalendarTaskExportSelection>.unmodifiable(
      input.selection,
    );
    if (selection.map((s) => s.taskId).toSet().length != selection.length ||
        [
          input.expectedRevision,
          ...selection.map((s) => s.expectedRevision),
        ].any((r) => r < 1 || r > CalendarService._maxRevision)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final bytes = Uint8List.fromList(
      input.bytes.buffer.asUint8List(
        input.bytes.offsetInBytes,
        input.bytes.lengthInBytes,
      ),
    );
    final c = await _context();
    await _transaction(c, (tx, _) async {
      final parent = await _active(c, input.calendarId, tx);
      await _decide(
        c,
        [
          _tr(parent, CalendarPermission.importTasks),
          _tr(parent, CalendarPermission.replaceTasksFromImport),
        ],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (parent.identity.revision != input.expectedRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
    });
    final parsed = _taskValue(() => parseIcalendarTaskCalendar(bytes));
    final proposals = _taskValue(
      () => {
        for (final s in parsed.series) s.master.uid: taskStorageProposal(s),
      },
    );
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, input.calendarId, tx);
      final tasks = <_Task>[];
      for (final target in selection) {
        final task = await _task(c, target.taskId, tx);
        if (task.identity.calendarId != input.calendarId) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        tasks.add(task);
      }
      CalendarTaskReplacementIntent? batch;
      CalendarAuthorizationRequest request(
        CalendarPermission op, [
        _Task? task,
      ]) {
        final proposed = task == null ? null : proposals[task.data.protocolUid];
        return CalendarAuthorizationRequest(
          key: '${op.name}:${task?.identity.id ?? parent.identity.id}',
          operation: op,
          calendarId: input.calendarId,
          current: parent.snapshot,
          taskId: task?.identity.id,
          currentTask: task?.snapshot,
          proposedTaskContent: proposed?.state.master.content,
          proposedTaskProgress: proposed?.state.master.progress,
          proposedTaskAssignees: task?.data.assignees,
          proposedTaskVersion: proposed?.state.master.version,
          proposedTaskSourceState: proposed?.state,
          itemTextMetadataPatch:
              op == CalendarPermission.updateTaskTextMetadata &&
                  task != null &&
                  proposed != null
              ? itemTextChanges(
                  taskTextState(task.data.sourceState!),
                  taskTextState(proposed.state),
                )
              : null,
          taskReplacement: batch,
          taskGroups: CalendarTaskFieldGroup.values,
        );
      }

      Future<Map<String, CalendarAuthorizationDecision>> authorize(
        List<CalendarAuthorizationRequest> requests,
        CalendarAuthorizationPhase phase,
      ) async {
        final decisions = <String, CalendarAuthorizationDecision>{};
        await _verifyContext(c);
        for (var i = 0; i < requests.length; i += _options.policyBatchSize) {
          final chunk = requests.sublist(
            i,
            min(i + _options.policyBatchSize, requests.length),
          );
          final result = phase == CalendarAuthorizationPhase.finalWrite
              ? await _final(c, chunk, tx)
              : await _decide(c, chunk, tx, phase);
          for (final r in chunk.where(
            (r) => r.operation == CalendarPermission.readTask,
          )) {
            if (!result[r.key]!.taskDisclosedGroups.containsAll(
              CalendarTaskFieldGroup.values,
            )) {
              throw _failure(CalendarFailureCode.accessDenied);
            }
          }
          decisions.addAll(result);
        }
        await _verifyContext(c);
        return decisions;
      }

      List<CalendarAuthorizationRequest> baseRequests() => [
        request(CalendarPermission.importTasks),
        request(CalendarPermission.replaceTasksFromImport),
        for (final task in tasks) ...[
          request(CalendarPermission.importTasks, task),
          request(CalendarPermission.replaceTasksFromImport, task),
          request(CalendarPermission.readTask, task),
          request(CalendarPermission.readTaskSource, task),
        ],
      ];
      await authorize(
        baseRequests(),
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (parent.identity.revision != input.expectedRevision ||
          tasks.any(
            (t) =>
                t.identity.revision !=
                selection
                    .singleWhere((s) => s.taskId == t.identity.id)
                    .expectedRevision,
          )) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      if (parsed.series.length != tasks.length ||
          proposals.length != tasks.length ||
          tasks.any((t) => !proposals.containsKey(t.data.protocolUid))) {
        throw _failure(CalendarFailureCode.validation);
      }
      final members = [
        for (final task in tasks)
          CalendarTaskImportMember(
            taskId: task.identity.id!,
            protocolUid: task.data.protocolUid,
            sourceState: proposals[task.data.protocolUid]!.state,
          ),
      ];
      final changed = <bool>[], local = <bool>[];
      final rows = <List<CalendarTaskOccurrenceRecord>>[];
      CalendarTaskReplacementIntent intent(bool classified) =>
          CalendarTaskReplacementIntent([
            for (var i = 0; i < tasks.length; i++)
              CalendarTaskReplacementMember(
                current: tasks[i].snapshot,
                proposed: members[i],
                baselineProfile: tasks[i].data.importBaseline?.profile,
                baselineSequence: tasks[i].data.importBaseline?.sourceSequence,
                changed: classified ? changed[i] : null,
                localChanges: classified ? local[i] : null,
              ),
          ]);
      batch = intent(false);
      await authorize(
        baseRequests(),
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i], proposal = proposals[task.data.protocolUid]!;
        final baseline = task.data.importBaseline,
            source = task.data.sourceState;
        if (baseline == null || source == null) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        // _task validates the private baseline and source projection fail-closed.
        final current = _taskValue(
          () => taskImportBaseline(task.data.protocolUid, source),
        );
        final isChanged =
            current.canonicalValue != proposal.importBaseline.canonicalValue;
        final isLocal = current.canonicalValue != baseline.canonicalValue;
        if ((proposal.state.master.version.sequence ?? 0) <
                (baseline.sourceSequence ?? 0) ||
            (isChanged && isLocal)) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        if (isChanged &&
            task.identity.revision == CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        rows.add(await _taskRecords(task, tx));
        if (isChanged) {
          final history = await CalendarTaskHistoryRecord.db.count(
            _session,
            where: (t) => t.taskId.equals(task.identity.id!),
            transaction: tx,
            limit: 1,
          );
          if (history != 0) {
            throw _failure(CalendarFailureCode.dependencyConflict);
          }
        }
        changed.add(isChanged);
        local.add(isLocal);
      }
      batch = intent(true);
      final requests = [
        ...baseRequests(),
        for (var i = 0; i < tasks.length; i++)
          if (changed[i]) ...[
            request(CalendarPermission.updateTask, tasks[i]),
            if (itemTextChanges(
                  taskTextState(tasks[i].data.sourceState!),
                  taskTextState(proposals[tasks[i].data.protocolUid]!.state),
                ) !=
                null)
              request(CalendarPermission.updateTaskTextMetadata, tasks[i]),
            if (members[i].requiresProgress ||
                CalendarTaskImportMember(
                  taskId: tasks[i].identity.id!,
                  protocolUid: tasks[i].data.protocolUid,
                  sourceState: tasks[i].data.sourceState!,
                ).requiresProgress)
              request(CalendarPermission.changeTaskProgress, tasks[i]),
          ],
      ];
      await authorize(requests, CalendarAuthorizationPhase.preliminaryWrite);
      final decisions = await authorize(
        requests,
        CalendarAuthorizationPhase.finalWrite,
      );
      final now = changed.any((v) => v) ? await _revisionTime(tx) : null;
      final receipts = <CalendarTaskReplaceReceipt>[];
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i], proposal = proposals[task.data.protocolUid]!;
        if (changed[i]) {
          final source = proposal.state;
          task.data.content = source.master.content;
          task.data.progress = source.master.progress;
          task.data.protocolVersion = source.master.version;
          task.data.sourceState = source;
          task.data.importBaseline = proposal.importBaseline;
          task.data.updatedAt = now!.isBefore(task.data.updatedAt)
              ? task.data.updatedAt
              : now;
          task.identity.revision++;
          final remaining = {for (final row in rows[i]) row.originalKey: row};
          for (final component in source.occurrences) {
            final key = taskOriginalKey(component.originalStart!);
            final old = remaining.remove(key);
            final row = CalendarTaskOccurrenceRecord(
              id: old?.id,
              taskId: task.identity.id!,
              originalKey: key,
              originalStart: component.originalStart!,
              replacementTiming: taskSourceReplacement(component),
              futureTiming: taskSourceFuture(component),
              contentOverrides: taskSourceContentOverrides(component),
              progress: component.progress,
              protocolVersion: component.version,
            );
            if (old == null) {
              await CalendarTaskOccurrenceRecord.db.insertRow(
                _session,
                row,
                transaction: tx,
              );
            } else {
              await CalendarTaskOccurrenceRecord.db.updateRow(
                _session,
                row,
                transaction: tx,
              );
            }
          }
          for (final row in remaining.values) {
            await CalendarTaskOccurrenceRecord.db.deleteRow(
              _session,
              row,
              transaction: tx,
            );
          }
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
        }
        final receipt = _taskReceipt(task, [
          for (final r in requests.where(
            (r) =>
                r.operation != CalendarPermission.readTask &&
                r.operation != CalendarPermission.readTaskSource &&
                (r.taskId == null || r.taskId == task.identity.id),
          ))
            decisions[r.key]!,
        ]);
        if (receipt != null) {
          receipts.add(
            CalendarTaskReplaceReceipt(receipt: receipt, changed: changed[i]),
          );
        }
      }
      if (changed.any((v) => v)) await _bump(scope, tx);
      return CalendarTaskReplaceResult(receipts: List.unmodifiable(receipts));
    });
  }
}
