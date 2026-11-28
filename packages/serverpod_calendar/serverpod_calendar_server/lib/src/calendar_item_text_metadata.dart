part of 'calendar_module.dart';

extension CalendarItemTextMetadataOperations on CalendarService {
  Future<CalendarEventReceipt?> updateEventTextMetadata(
    CalendarEventTextMetadataRequest input,
  ) async {
    final patch = _eventProtocolValue(() => validateItemTextPatch(input.patch)),
        c = await _context();
    return _transaction(c, (tx, scope) async {
      final e = await _event(c, input.eventId, tx);
      await _decide(
        c,
        [
          _er(
            e.parent,
            CalendarPermission.updateEventTextMetadata,
            event: e,
            textMetadataPatch: patch,
          ),
        ],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _eventRevision(e, input.expectedRevision);
      final now = await _revisionTime(tx, previous: e.data.updatedAt),
          old = e.data.protocolState!;
      final state = _eventProtocolValue(
        () => advanceEventProtocol(
          old,
          e.data.content,
          e.data.timingOverrides,
          e.data.content,
          e.data.timingOverrides,
          now,
          replaceSourceMetadata: true,
          sourceMetadata: applyEventTextPatch(old.sourceMetadata, patch),
        ),
      );
      final request = _er(
        e.parent,
        CalendarPermission.updateEventTextMetadata,
        event: e,
        textMetadataPatch: patch,
        proposed: e.data.content,
        proposedState: state,
        proposedOverrides: e.data.timingOverrides,
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, [request], tx);
      final changed = jsonEncode(old.toJson()) != jsonEncode(state.toJson());
      e.data.protocolState = state;
      e.data.updatedAt = now;
      e.identity.revision++;
      await CalendarEventDataRecord.db.updateRow(
        _session,
        e.data,
        transaction: tx,
      );
      await CalendarEventRecord.db.updateRow(
        _session,
        e.identity,
        transaction: tx,
      );
      await _bump(
        scope,
        tx,
        publishedEventCalendar: changed ? e.identity.calendarId : null,
      );
      return _eventReceipt(e, decisions.values);
    });
  }

  Future<CalendarTaskReceipt?> updateTaskTextMetadata(
    CalendarTaskTextMetadataRequest input,
  ) async {
    final patch = _taskValue(() => validateItemTextPatch(input.patch)),
        c = await _context();
    return _transaction(c, (tx, scope) async {
      final t = await _task(c, input.taskId, tx);
      await _decide(
        c,
        [
          _tr(
            t.parent,
            CalendarPermission.updateTaskTextMetadata,
            task: t,
            textMetadataPatch: patch,
          ),
        ],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _taskRevision(t, input.expectedRevision);
      final old = t.data.sourceState;
      final metadata = _taskValue(
        () => applyTaskTextPatch(
          old?.master.metadata ?? emptyTaskSourceMetadata(),
          patch,
        ),
      );
      final changed =
          jsonEncode(taskTextMetadata(old?.master.metadata).toJson()) !=
          jsonEncode(taskTextMetadata(metadata).toJson());
      final now = await _revisionTime(tx, previous: t.data.updatedAt);
      final version = changed
          ? _taskValue(() => advanceTaskVersion(t.data.protocolVersion, now))
          : t.data.protocolVersion;
      final state = !changed
          ? old
          : _taskValue(
              () => validateTaskSourceState(
                t.data.protocolUid,
                old == null
                    ? CalendarTaskSourceState(
                        nativeMetadataOnly: true,
                        master: CalendarTaskSourceComponent(
                          version: version,
                          content: t.data.content,
                          progress: t.data.progress,
                          textParameters: CalendarEventTextParameters(),
                          metadata: metadata,
                        ),
                        occurrences: [],
                      )
                    : old.copyWith(
                        master: old.master.copyWith(
                          metadata: metadata,
                          version: version,
                        ),
                      ),
              ),
            );
      final request = _tr(
        t.parent,
        CalendarPermission.updateTaskTextMetadata,
        task: t,
        textMetadataPatch: patch,
        content: t.data.content,
        progress: t.data.progress,
        assignees: t.data.assignees,
        version: version,
        sourceState: state,
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, [request], tx);
      t.data.sourceState = state;
      t.data.protocolVersion = version;
      t.data.updatedAt = now;
      t.identity.revision++;
      await CalendarTaskDataRecord.db.updateRow(
        _session,
        t.data,
        transaction: tx,
      );
      await CalendarTaskRecord.db.updateRow(
        _session,
        t.identity,
        transaction: tx,
      );
      await _bump(scope, tx);
      return _taskReceipt(t, decisions.values);
    });
  }
}
