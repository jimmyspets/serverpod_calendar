part of 'calendar_module.dart';

extension CalendarTaskExportOperations on CalendarService {
  Future<ByteData> exportTasks(CalendarTaskExportRequest input) async {
    if (input.selection.isEmpty ||
        input.selection.length > const IcalendarComponentLimits().maxTasks) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final selection = List<CalendarTaskExportSelection>.unmodifiable(
      input.selection,
    );
    if (selection.map((s) => s.taskId).toSet().length != selection.length ||
        input.expectedRevision < 1 ||
        input.expectedRevision > CalendarService._maxRevision ||
        selection.any(
          (s) =>
              s.expectedRevision < 1 ||
              s.expectedRevision > CalendarService._maxRevision,
        )) {
      throw _failure(CalendarFailureCode.validation);
    }
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final parent = await _active(c, input.calendarId, tx);
      await _decide(
        c,
        [_tr(parent, CalendarPermission.exportTasks)],
        tx,
        CalendarAuthorizationPhase.read,
      );
      final members = <_Task>[];
      for (final target in selection) {
        final e = await _task(c, target.taskId, tx);
        if (e.identity.calendarId != parent.identity.id) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        members.add(e);
      }
      members.sort((a, b) => a.data.protocolUid.compareTo(b.data.protocolUid));
      final projected = <CalendarTaskExportMember>[];
      for (final member in members) {
        final rows = await _taskRecords(member, tx);
        final state =
            member.data.sourceState ??
            CalendarTaskSourceState(
              master: CalendarTaskSourceComponent(
                version: member.data.protocolVersion,
                content: member.data.content,
                progress: member.data.progress,
                textParameters: CalendarEventTextParameters(),
                metadata: emptyTaskSourceMetadata(),
              ),
              occurrences: [
                for (final row in rows)
                  CalendarTaskSourceComponent(
                    originalStart: row.originalStart,
                    version:
                        row.protocolVersion ??
                        (throw _failure(CalendarFailureCode.validation)),
                    content: CalendarTaskContent(
                      timing: CalendarTaskTiming(
                        kind: CalendarTaskTimeKind.undated,
                      ),
                    ),
                    progress: row.progress,
                    textParameters: CalendarEventTextParameters(),
                    metadata: emptyTaskSourceMetadata(),
                  ),
              ],
            );
        projected.add(
          _taskValue(
            () => CalendarTaskExportMember(
              current: member.snapshot,
              sourceState: state,
            ),
          ),
        );
      }
      final intent = CalendarTaskExportIntent(projected);
      CalendarAuthorizationRequest request(
        CalendarPermission operation, [
        _Task? member,
      ]) => CalendarAuthorizationRequest(
        key: '${operation.name}:${member?.identity.id ?? parent.identity.id}',
        operation: operation,
        calendarId: parent.identity.id,
        current: parent.snapshot,
        taskId: member?.identity.id,
        currentTask: member?.snapshot,
        taskExport: intent,
        taskGroups: CalendarTaskFieldGroup.values,
      );
      final requests = [
        request(CalendarPermission.exportTasks),
        for (final e in members) ...[
          request(CalendarPermission.exportTasks, e),
          request(CalendarPermission.readTask, e),
          request(CalendarPermission.readTaskSource, e),
        ],
      ];
      Future<void> authorize() async {
        await _verifyContext(c);
        for (var i = 0; i < requests.length; i += _options.policyBatchSize) {
          final chunk = requests.sublist(
            i,
            min(i + _options.policyBatchSize, requests.length),
          );
          final decisions = await _decide(
            c,
            chunk,
            tx,
            CalendarAuthorizationPhase.read,
          );
          for (final r in chunk.where(
            (r) => r.operation == CalendarPermission.readTask,
          )) {
            if (!decisions[r.key]!.taskDisclosedGroups.containsAll(
              CalendarTaskFieldGroup.values,
            )) {
              throw _failure(CalendarFailureCode.accessDenied);
            }
          }
        }
        await _verifyContext(c);
      }

      await authorize();
      if (parent.identity.revision != input.expectedRevision ||
          members.any(
            (m) =>
                m.identity.revision !=
                selection
                    .singleWhere((s) => s.taskId == m.identity.id)
                    .expectedRevision,
          )) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      late final Uint8List bytes;
      try {
        bytes = Uint8List.fromList(
          taskExportBytes([
            for (final m in intent.members)
              (uid: m.current.protocolUid, state: m.sourceState),
          ]),
        );
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
      await authorize();
      return ByteData.sublistView(bytes);
    });
  }
}
