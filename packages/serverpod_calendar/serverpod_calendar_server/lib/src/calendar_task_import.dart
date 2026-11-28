part of 'calendar_module.dart';

extension CalendarTaskImportOperations on CalendarService {
  /// Authenticated create-only import; no scheduling or publication side effects.
  Future<CalendarTaskImportResult> importTasks(
    CalendarTaskImportRequest input,
  ) async {
    if (input.bytes.lengthInBytes > const IcalendarSyntaxLimits().maxBytes) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final bytes = Uint8List.fromList(
      input.bytes.buffer.asUint8List(
        input.bytes.offsetInBytes,
        input.bytes.lengthInBytes,
      ),
    );
    final c = await _context();
    CalendarAuthorizationRequest batchRequest(
      _Active parent, [
      CalendarTaskImportIntent? intent,
    ]) => CalendarAuthorizationRequest(
      key: 'importTasks:${parent.identity.id}',
      operation: CalendarPermission.importTasks,
      calendarId: parent.identity.id,
      current: parent.snapshot,
      taskImport: intent,
    );
    void revision(_Active parent) {
      if (input.expectedRevision < 1 ||
          input.expectedRevision > CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (input.expectedRevision != parent.identity.revision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
    }

    await _transaction(c, (tx, _) async {
      final parent = await _active(c, input.calendarId, tx);
      await _decide(
        c,
        [batchRequest(parent)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      revision(parent);
    });
    late final CalendarTaskImportIntent intent;
    try {
      final parsed = parseIcalendarTaskCalendar(bytes);
      intent = CalendarTaskImportIntent([
        for (final source in parsed.series)
          (() {
            final proposal = taskStorageProposal(source);
            return CalendarTaskImportMember(
              taskId: const Uuid().v4obj(),
              protocolUid: proposal.protocolUid,
              sourceState: proposal.state,
            );
          })(),
      ]);
      if (intent.members.isEmpty) {
        throw _failure(CalendarFailureCode.validation);
      }
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
    } on RecurrenceLimitException {
      throw _failure(CalendarFailureCode.limitExceeded);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, input.calendarId, tx);
      final batch = batchRequest(parent, intent);
      CalendarAuthorizationRequest memberRequest(
        CalendarTaskImportMember m,
        CalendarPermission operation,
      ) => CalendarAuthorizationRequest(
        key: '${operation.name}:${m.taskId}',
        operation: operation,
        calendarId: parent.identity.id,
        current: parent.snapshot,
        taskId: m.taskId,
        proposedTaskContent: m.sourceState.master.content,
        proposedTaskProgress: m.sourceState.master.progress,
        proposedTaskAssignees: const [],
        proposedTaskVersion: m.sourceState.master.version,
        proposedTaskSourceState: m.sourceState,
        taskImport: intent,
      );
      final requests = <UuidValue, List<CalendarAuthorizationRequest>>{
        for (final m in intent.members)
          m.taskId: [
            memberRequest(m, CalendarPermission.createTask),
            if (m.requiresProgress)
              memberRequest(m, CalendarPermission.changeTaskProgress),
          ],
      };
      Future<Map<String, CalendarAuthorizationDecision>> authorize(
        CalendarAuthorizationPhase phase,
      ) async {
        final decisions = <String, CalendarAuthorizationDecision>{};
        final all = [batch, ...requests.values.expand((v) => v)];
        for (var i = 0; i < all.length; i += _options.policyBatchSize) {
          final chunk = all.sublist(
            i,
            min(i + _options.policyBatchSize, all.length),
          );
          decisions.addAll(
            phase == CalendarAuthorizationPhase.finalWrite
                ? await _final(c, chunk, tx)
                : await _decide(c, chunk, tx, phase),
          );
        }
        return decisions;
      }

      await authorize(CalendarAuthorizationPhase.preliminaryWrite);
      revision(parent);
      // Bound destination work without exposing its hidden object count.
      final count = await CalendarTaskRecord.db.count(
        _session,
        where: (t) =>
            t.calendarId.equals(input.calendarId) & t.deletedAt.equals(null),
        transaction: tx,
        limit: _options.maxScannedTasks + 1,
      );
      if (count + intent.members.length > _options.maxScannedTasks) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final seen = <String>{};
      for (final m in intent.members) {
        if (!seen.add(m.protocolUid)) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        final candidates = await CalendarTaskDataRecord.db.find(
          _session,
          where: (t) =>
              t.calendarId.equals(input.calendarId) &
              t.uidDigest.equals(eventUidDigest(m.protocolUid)),
          transaction: tx,
          limit: _options.maxScannedTasks + 1,
        );
        if (candidates.length > _options.maxScannedTasks) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        if (eventUidConflicts(
          m.protocolUid,
          candidates.map((v) => v.protocolUid),
        )) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
      }
      final decisions = await authorize(CalendarAuthorizationPhase.finalWrite);
      await _verifyContext(c);
      final now = await _revisionTime(tx);
      final receipts = <CalendarTaskReceipt>[];
      for (final m in intent.members) {
        final identity = await CalendarTaskRecord.db.insertRow(
          _session,
          CalendarTaskRecord(
            id: m.taskId,
            calendarId: input.calendarId,
            revision: 1,
          ),
          transaction: tx,
        );
        final data = await CalendarTaskDataRecord.db.insertRow(
          _session,
          CalendarTaskDataRecord(
            taskId: m.taskId,
            calendarId: input.calendarId,
            protocolUid: m.protocolUid,
            uidDigest: eventUidDigest(m.protocolUid),
            content: m.sourceState.master.content,
            progress: m.sourceState.master.progress,
            assignees: const [],
            protocolVersion: m.sourceState.master.version,
            sourceState: m.sourceState,
            importBaseline: _taskValue(
              () => taskImportBaseline(m.protocolUid, m.sourceState),
            ),
            hasRecordedProgress: null,
            createdAt: now,
            updatedAt: now,
          ),
          transaction: tx,
        );
        for (final o in m.sourceState.occurrences) {
          await CalendarTaskOccurrenceRecord.db.insertRow(
            _session,
            CalendarTaskOccurrenceRecord(
              taskId: m.taskId,
              originalStart: o.originalStart!,
              originalKey: taskOriginalKey(o.originalStart!),
              progress: o.progress,
              protocolVersion: o.version,
            ),
            transaction: tx,
          );
        }
        final receipt = _taskReceipt(_Task(identity, data, parent), [
          decisions[batch.key]!,
          for (final r in requests[m.taskId]!) decisions[r.key]!,
        ]);
        if (receipt != null) {
          receipts.add(receipt);
        }
      }
      await _bump(scope, tx);
      return CalendarTaskImportResult(receipts: List.unmodifiable(receipts));
    });
  }
}
