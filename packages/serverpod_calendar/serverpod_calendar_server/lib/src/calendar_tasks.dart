part of 'calendar_module.dart';

T _taskValue<T>(T Function() body) {
  try {
    return body();
  } on IcalendarSyntaxException catch (e) {
    throw _failure(
      e.kind == IcalendarSyntaxError.limitExceeded
          ? CalendarFailureCode.limitExceeded
          : CalendarFailureCode.validation,
    );
  } on IcalendarComponentException catch (e) {
    throw _failure(
      e.kind == IcalendarComponentError.limitExceeded
          ? CalendarFailureCode.limitExceeded
          : CalendarFailureCode.validation,
    );
  } on IcalendarValueException {
    throw _failure(CalendarFailureCode.validation);
  } on ArgumentError {
    throw _failure(CalendarFailureCode.validation);
  } on ZoneCoverageException {
    throw _failure(CalendarFailureCode.validation);
  } on RecurrenceLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  }
}

final class _Task {
  _Task(this.identity, this.data, this.parent) {
    try {
      if (data.calendarId != identity.calendarId) {
        throw ArgumentError('Wrong task parent');
      }
      validateEventUid(data.protocolUid);
      data.content = validateTaskContent(data.content);
      data.progress = validateTaskProgress(data.progress);
      data.assignees = validateTaskAssignees(data.assignees);
      validateTaskVersion(data.protocolVersion);
      if (data.sourceState != null) {
        data.sourceState = validateTaskSourceState(
          data.protocolUid,
          data.sourceState!,
        );
        final master = data.sourceState!.master;
        if (master.content != data.content ||
            master.progress != data.progress ||
            master.version != data.protocolVersion) {
          throw ArgumentError('Task source projection mismatch');
        }
      }
      if (data.importBaseline != null) {
        validateTaskImportBaseline(data.importBaseline!, data.protocolUid);
      }
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }
  final CalendarTaskRecord identity;
  final CalendarTaskDataRecord data;
  final _Active parent;
  CalendarTaskPolicySnapshot get snapshot => CalendarTaskPolicySnapshot(
    taskId: identity.id!,
    calendarId: identity.calendarId,
    revision: identity.revision,
    content: data.content,
    progress: data.progress,
    assignees: data.assignees,
    protocolUid: data.protocolUid,
    protocolVersion: data.protocolVersion,
    updatedAt: data.updatedAt,
    hasRecordedProgress: data.hasRecordedProgress,
    sourceState: data.sourceState,
  );
}

extension CalendarTaskOperations on CalendarService {
  Set<CalendarTaskFieldGroup> _tgroups(List<CalendarTaskFieldGroup> groups) {
    if (groups.length > CalendarTaskFieldGroup.values.length) {
      throw _failure(CalendarFailureCode.validation);
    }
    return Set.unmodifiable(groups);
  }

  CalendarAuthorizationRequest _tr(
    _Active parent,
    CalendarPermission op, {
    _Task? task,
    UuidValue? newId,
    CalendarTaskContent? content,
    CalendarTaskProgress? progress,
    List<CalendarTaskAssignee>? assignees,
    CalendarTaskProtocolVersion? version,
    CalendarTaskProtocolVersion? occurrenceVersion,
    CalendarTaskSourceState? sourceState,
    CalendarItemTextMetadataPatch? textMetadataPatch,
    CalendarTaskProgressRequest? change,
    CalendarTaskOccurrenceQuery? occurrenceQuery,
    CalendarTaskOccurrenceProgressRequest? occurrenceChange,
    CalendarTaskOccurrenceTimingRequest? timingChange,
    CalendarTaskOccurrenceContentRequest? contentChange,
    CalendarTaskHistoryQuery? historyQuery,
    CalendarTaskOccurrence? currentOccurrence,
    CalendarTaskOccurrence? proposedOccurrence,
    List<CalendarTaskOccurrence> recordedOccurrences = const [],
    Set<CalendarTaskFieldGroup> groups = const {},
  }) => CalendarAuthorizationRequest(
    key: '${op.name}:${task?.identity.id ?? newId ?? parent.identity.id}',
    operation: op,
    calendarId: parent.identity.id,
    current: parent.snapshot,
    taskId: task?.identity.id ?? newId,
    currentTask: task?.snapshot,
    proposedTaskContent: content,
    proposedTaskProgress: progress,
    proposedTaskAssignees: assignees,
    proposedTaskVersion: version,
    proposedTaskOccurrenceVersion: occurrenceVersion,
    proposedTaskSourceState: sourceState,
    itemTextMetadataPatch: textMetadataPatch,
    taskProgressChange: change,
    taskOccurrenceQuery: occurrenceQuery,
    taskOccurrenceProgressChange: occurrenceChange,
    taskOccurrenceTimingChange: timingChange,
    taskOccurrenceContentChange: contentChange,
    taskHistoryQuery: historyQuery,
    currentTaskOccurrence: currentOccurrence,
    proposedTaskOccurrence: proposedOccurrence,
    recordedTaskOccurrences: recordedOccurrences,
    taskGroups: groups,
  );
  Future<_Task> _task(
    CalendarHostContext c,
    UuidValue id,
    Transaction tx, {
    CalendarTaskRecord? identity,
    _Active? parent,
  }) async {
    identity ??= await CalendarTaskRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    if (identity == null || identity.deletedAt != null) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    parent ??= await _active(c, identity.calendarId, tx);
    final data = await CalendarTaskDataRecord.db.findFirstRow(
      _session,
      where: (t) => t.taskId.equals(id),
      transaction: tx,
    );
    if (data == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return _Task(identity, data, parent);
  }

  void _taskRevision(_Task task, int expected) {
    if (expected < 1 || expected > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (expected != task.identity.revision) {
      throw _failure(CalendarFailureCode.staleRevision);
    }
    if (expected == CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
  }

  CalendarTaskReceipt? _taskReceipt(
    _Task task,
    Iterable<CalendarAuthorizationDecision> decisions, {
    bool deleted = false,
  }) => decisions.every((d) => d.discloseMutationReceipt)
      ? CalendarTaskReceipt(
          taskId: task.identity.id!,
          calendarId: task.identity.calendarId,
          revision: task.identity.revision,
          deleted: deleted,
        )
      : null;
  CalendarTaskView _taskView(
    _Task task,
    Set<CalendarTaskFieldGroup> requested,
    CalendarAuthorizationDecision decision,
  ) {
    final groups = requested.intersection(decision.taskDisclosedGroups).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    bool has(CalendarTaskFieldGroup group) => groups.contains(group);
    final d = task.data, c = d.content;
    final metadata = taskTextMetadata(d.sourceState?.master.metadata);
    return CalendarTaskView(
      id: task.identity.id!,
      calendarId: task.identity.calendarId,
      revision: task.identity.revision,
      disclosedGroups: groups,
      url: has(CalendarTaskFieldGroup.url) ? metadata.url : null,
      classification: has(CalendarTaskFieldGroup.classification)
          ? metadata.classification
          : null,
      categoryGroups: has(CalendarTaskFieldGroup.categories)
          ? metadata.categoryGroups
          : null,
      comments: has(CalendarTaskFieldGroup.comments) ? metadata.comments : null,
      summary: has(CalendarTaskFieldGroup.summary) ? c.summary : null,
      description: has(CalendarTaskFieldGroup.description)
          ? c.description
          : null,
      location: has(CalendarTaskFieldGroup.location) ? c.location : null,
      timing: has(CalendarTaskFieldGroup.timing) ? c.timing : null,
      recurrence: has(CalendarTaskFieldGroup.timing) ? c.recurrence : null,
      priority: has(CalendarTaskFieldGroup.priority) ? c.priority : null,
      progress: has(CalendarTaskFieldGroup.progress) ? d.progress : null,
      assignees: has(CalendarTaskFieldGroup.assignments) ? d.assignees : null,
      protocolUid: has(CalendarTaskFieldGroup.protocolIdentity)
          ? d.protocolUid
          : null,
      protocolVersion: has(CalendarTaskFieldGroup.protocolIdentity)
          ? d.protocolVersion
          : null,
    );
  }

  Future<String> _taskUid(UuidValue parent, Transaction tx) async {
    for (var i = 0; i < 3; i++) {
      final uid = const Uuid().v4();
      final candidates = await CalendarTaskDataRecord.db.find(
        _session,
        where: (t) =>
            t.calendarId.equals(parent) &
            t.uidDigest.equals(eventUidDigest(uid)),
        transaction: tx,
        limit: _options.maxScannedTasks + 1,
      );
      if (candidates.length > _options.maxScannedTasks) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (!eventUidConflicts(uid, candidates.map((v) => v.protocolUid))) {
        return uid;
      }
    }
    throw _failure(CalendarFailureCode.unavailable);
  }

  Future<CalendarTaskReceipt?> createTask(
    CalendarTaskCreateRequest input,
  ) async {
    final content = _taskValue(() => validateTaskContent(input.content));
    final assignees = _taskValue(
      () =>
          validateTaskAssignees(input.assignees, max: _options.maxAssociations),
    );
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, input.calendarId, tx),
          id = const Uuid().v4obj();
      final now = await _revisionTime(tx), stamp = eventProtocolInstant(now);
      final version = CalendarTaskProtocolVersion(
            sequence: 0,
            stamp: stamp,
            created: stamp,
            lastModified: stamp,
          ),
          progress = CalendarTaskProgress(
            status: CalendarTaskStatus.needsAction,
            percentComplete: 0,
          );
      final requests = [
        for (final op in [
          CalendarPermission.createTask,
          if (assignees.isNotEmpty) CalendarPermission.changeTaskAssignments,
        ])
          _tr(
            parent,
            op,
            newId: id,
            content: content,
            progress: progress,
            assignees: assignees,
            version: version,
          ),
      ];
      for (final request in requests) {
        await _decide(
          c,
          [request],
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
      }
      final uid = await _taskUid(input.calendarId, tx);
      final decisions = <String, CalendarAuthorizationDecision>{};
      for (final request in requests) {
        decisions.addAll(await _final(c, [request], tx));
      }
      final identity = await CalendarTaskRecord.db.insertRow(
        _session,
        CalendarTaskRecord(id: id, calendarId: input.calendarId, revision: 1),
        transaction: tx,
      );
      final data = await CalendarTaskDataRecord.db.insertRow(
        _session,
        CalendarTaskDataRecord(
          taskId: id,
          calendarId: input.calendarId,
          protocolUid: uid,
          uidDigest: eventUidDigest(uid),
          protocolVersion: version,
          content: content,
          progress: progress,
          hasRecordedProgress: false,
          assignees: assignees,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
      await _bump(scope, tx);
      return _taskReceipt(_Task(identity, data, parent), decisions.values);
    });
  }

  Future<CalendarTaskView> getTask(
    UuidValue id,
    List<CalendarTaskFieldGroup> requested,
  ) async {
    final groups = _tgroups(requested), c = await _context();
    return _transaction(c, (tx, _) async {
      final task = await _task(c, id, tx);
      final request = _tr(
        task.parent,
        CalendarPermission.readTask,
        task: task,
        groups: groups,
      );
      final decisions = await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.read,
      );
      await _verifyContext(c);
      return _taskView(task, groups, decisions[request.key]!);
    });
  }

  Future<CalendarTaskReceipt?> updateTask(CalendarTaskUpdateRequest input) =>
      _changeTask(
        input.taskId,
        input.expectedRevision,
        content: _taskValue(() => validateTaskContent(input.content)),
      );
  Future<CalendarTaskReceipt?> changeTaskProgress(
    CalendarTaskProgressRequest input,
  ) => _changeTask(input.taskId, input.expectedRevision, change: input);
  Future<CalendarTaskReceipt?> changeTaskAssignments(
    CalendarTaskAssignmentsRequest input,
  ) => _changeTask(
    input.taskId,
    input.expectedRevision,
    assignees: _taskValue(
      () =>
          validateTaskAssignees(input.assignees, max: _options.maxAssociations),
    ),
  );
  Future<CalendarTaskReceipt?> _changeTask(
    UuidValue id,
    int expected, {
    CalendarTaskContent? content,
    CalendarTaskProgressRequest? change,
    List<CalendarTaskAssignee>? assignees,
  }) async {
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final task = await _task(c, id, tx),
          op = content != null
              ? CalendarPermission.updateTask
              : change != null
              ? CalendarPermission.changeTaskProgress
              : CalendarPermission.changeTaskAssignments;
      final recorded = await _taskRecords(task, tx);
      final nextContent = content ?? task.data.content,
          nextAssignees = assignees ?? task.data.assignees;
      CalendarAuthorizationRequest request(
        CalendarTaskProgress progress, [
        CalendarTaskProtocolVersion? version,
        CalendarTaskSourceState? sourceState,
      ]) => _tr(
        task.parent,
        op,
        task: task,
        content: nextContent,
        progress: progress,
        assignees: nextAssignees,
        version: version,
        sourceState: sourceState ?? task.data.sourceState,
        change: change,
        recordedOccurrences: [for (final r in recorded) _taskRecordValue(r)],
      );
      await _decide(
        c,
        [request(task.data.progress)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _taskRevision(task, expected);
      if (change != null && task.data.content.recurrence != null) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (content != null) {
        _taskValue(() {
          for (final r in recorded) {
            if (r.futureTiming != null) {
              validateTaskReplacement(content, r.futureTiming!);
            }
            if (r.replacementTiming != null) {
              validateTaskReplacement(content, r.replacementTiming!);
            }
          }
        });
        if (task.data.content.recurrence == null &&
            content.recurrence != null &&
            (task.data.hasRecordedProgress != false ||
                task.data.progress.status != CalendarTaskStatus.needsAction ||
                task.data.progress.percentComplete != 0 ||
                task.data.progress.completedAt != null)) {
          throw _failure(CalendarFailureCode.validation);
        }
        _taskValue(
          () => requireTaskOriginals(content, [
            for (final r in recorded) r.originalStart,
          ]),
        );
      }
      final now = await _revisionTime(tx, previous: task.data.updatedAt);
      final progress = change == null
          ? task.data.progress
          : _taskValue(
              () => changeTaskProgressValue(task.data.progress, change, now),
            );
      final changed =
          nextContent != task.data.content || progress != task.data.progress;
      final version = changed
          ? _taskValue(() => advanceTaskVersion(task.data.protocolVersion, now))
          : task.data.protocolVersion;
      final sourceState = changed && task.data.sourceState != null
          ? _taskValue(
              () => changeTaskSourceMaster(
                task.data.protocolUid,
                task.data.sourceState!,
                nextContent,
                progress,
                version,
                now,
              ),
            )
          : task.data.sourceState;
      await _decide(
        c,
        [request(progress, version, sourceState)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, [
        request(progress, version, sourceState),
      ], tx);
      if (change != null && changed) task.data.hasRecordedProgress = true;
      task.data.content = nextContent;
      task.data.progress = progress;
      task.data.assignees = nextAssignees;
      task.data.protocolVersion = version;
      task.data.sourceState = sourceState;
      if (sourceState != null && sourceState.nativeMetadataOnly != true) {
        final byKey = {
          for (final o in sourceState.occurrences)
            taskOriginalKey(o.originalStart!): o,
        };
        for (final row in recorded) {
          final component = byKey[row.originalKey]!;
          if (row.protocolVersion != component.version) {
            row.protocolVersion = component.version;
            await CalendarTaskOccurrenceRecord.db.updateRow(
              _session,
              row,
              transaction: tx,
            );
          }
        }
      }
      task.data.updatedAt = now;
      task.identity.revision++;
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

  Future<CalendarTaskReceipt?> deleteTask(UuidValue id, int expected) async {
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final task = await _task(c, id, tx),
          request = _tr(
            task.parent,
            CalendarPermission.deleteTask,
            task: task,
          );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _taskRevision(task, expected);
      final decisions = await _final(c, [request], tx);
      await _deleteParentAlarms(
        c.scopeKey,
        CalendarAlarmParentKind.task,
        id,
        tx,
      );
      await CalendarTaskHistoryRecord.db.deleteWhere(
        _session,
        where: (t) => t.taskId.equals(id),
        transaction: tx,
        noReturn: true,
      );
      await CalendarTaskOccurrenceRecord.db.deleteWhere(
        _session,
        where: (t) => t.taskId.equals(id),
        transaction: tx,
        noReturn: true,
      );
      await CalendarTaskDataRecord.db.deleteRow(
        _session,
        task.data,
        transaction: tx,
      );
      task.identity.revision++;
      task.identity.deletedAt = DateTime.now().toUtc();
      await CalendarTaskRecord.db.updateRow(
        _session,
        task.identity,
        transaction: tx,
      );
      await _bump(scope, tx);
      return _taskReceipt(task, decisions.values, deleted: true);
    });
  }

  Future<CalendarTaskPage> listTasks(
    UuidValue calendarId, {
    required int pageSize,
    required List<CalendarTaskFieldGroup> fieldGroups,
    String? cursor,
  }) async {
    final groups = _tgroups(fieldGroups);
    if (pageSize < 1 || pageSize > _options.maxPageSize) {
      throw _failure(CalendarFailureCode.validation);
    }
    final canonical = groups.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, calendarId, tx);
      await _decide(
        c,
        [_tr(parent, CalendarPermission.listTasks, groups: groups)],
        tx,
        CalendarAuthorizationPhase.read,
      );
      final plan = await _bounded(
        () => _runtime.policy.planTaskQuery(
          _session,
          c,
          parent.snapshot,
          groups,
        ),
      );
      if ((plan.taskIds?.length ?? 0) > _options.maxScannedTasks) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
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
            saved.alarmActivityId != null ||
            saved.alarmActivityKind != null ||
            saved.taskHistoryTaskId != null ||
            saved.taskHistoryOriginalKey != null ||
            saved.taskHistoryAfterRevision != null ||
            saved.eventCalendarId != null ||
            saved.eventFieldGroups != null ||
            saved.taskCalendarId != calendarId ||
            saved.scopeKey != c.scopeKey ||
            saved.principalId != c.principalId ||
            saved.policyRevision != c.policyRevision ||
            saved.dataRevision != scope.revision ||
            saved.pageSize != pageSize ||
            !saved.expiresAt.isAfter(DateTime.now().toUtc()) ||
            saved.taskFieldGroups == null ||
            saved.taskFieldGroups!.length != canonical.length ||
            !Iterable<int>.generate(canonical.length)
                .every((i) => saved.taskFieldGroups![i] == canonical[i])) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        after = saved.afterId;
      }
      final visible = <CalendarTaskView>[];
      var scanned = 0;
      while (visible.length <= pageSize) {
        final rows = await CalendarTaskRecord.db.find(
          _session,
          where: (t) =>
              t.calendarId.equals(calendarId) &
              t.deletedAt.equals(null) &
              (after == null ? Constant.bool(true) : t.id > after),
          orderBy: (t) => t.id,
          limit: _options.policyBatchSize,
          transaction: tx,
        );
        if (rows.isEmpty) break;
        final active = <_Task>[];
        for (final row in rows) {
          if (++scanned > _options.maxScannedTasks) {
            throw _failure(CalendarFailureCode.limitExceeded);
          }
          if (plan.taskIds != null && !plan.taskIds!.contains(row.id)) {
            continue;
          }
          active.add(
            await _task(c, row.id!, tx, identity: row, parent: parent),
          );
        }
        if (active.isNotEmpty) {
          final requests = [
            for (final e in active)
              _tr(
                parent,
                CalendarPermission.readTask,
                task: e,
                groups: groups,
              ),
          ];
          final decisions = await _decide(
            c,
            requests,
            tx,
            CalendarAuthorizationPhase.read,
            filterDenied: true,
          );
          for (final e in active) {
            final key = '${CalendarPermission.readTask.name}:${e.identity.id}';
            final decision = decisions[key]!;
            if (decision.verdict == CalendarAuthorizationVerdict.allow) {
              visible.add(_taskView(e, groups, decision));
            }
            if (visible.length > pageSize) break;
          }
        }
        after = rows.last.id;
      }
      await _verifyContext(c);
      String? continuation;
      if (visible.length > pageSize) {
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
            afterId: visible[pageSize - 1].id,
            pageSize: pageSize,
            fieldGroups: [],
            taskCalendarId: calendarId,
            taskFieldGroups: canonical,
            expiresAt: DateTime.now().toUtc().add(_options.cursorLifetime),
          ),
          transaction: tx,
        );
      }
      return CalendarTaskPage(
        tasks: visible.take(pageSize).toList(),
        nextCursor: continuation,
      );
    });
  }
}
