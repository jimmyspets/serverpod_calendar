part of 'calendar_module.dart';

extension CalendarEventOccurrenceContentOperations on CalendarService {
  Future<CalendarEventReceipt?> changeOccurrenceContent(
    CalendarEventOccurrenceContentRequest input,
  ) async {
    if (input.changes.isEmpty || input.changes.length > 3) {
      throw _failure(CalendarFailureCode.validation);
    }
    input = input.copyWith(changes: List.unmodifiable(input.changes));
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final e = await _event(c, input.eventId, tx);
      CalendarAuthorizationRequest request(
        CalendarEventTimingOverrides? proposed, [
        CalendarEventProtocolState? state,
      ]) => _er(
        e.parent,
        CalendarPermission.updateEvent,
        event: e,
        contentChange: input,
        proposedOverrides: proposed,
        proposedState: state,
      );
      await _decide(
        c,
        [request(null)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _eventRevision(e, input.expectedRevision);
      late final CalendarEventTimingOverrides? proposed;
      try {
        proposed = changeEventContentOverrides(
          e.data.content,
          e.data.timingOverrides,
          input,
        );
      } on RecurrenceLimitException {
        throw _failure(CalendarFailureCode.limitExceeded);
      } on ArgumentError {
        throw _failure(CalendarFailureCode.validation);
      } on ZoneCoverageException {
        throw _failure(CalendarFailureCode.validation);
      }
      final now = await _revisionTime(tx, previous: e.data.updatedAt);
      final state = _eventProtocolValue(
        () => advanceEventProtocol(
          e.data.protocolState!,
          e.data.content,
          e.data.timingOverrides,
          e.data.content,
          proposed,
          now,
        ),
      );
      await _decide(
        c,
        [request(proposed, state)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, [request(proposed, state)], tx);
      e.data.protocolState = state;
      e.data.timingOverrides = proposed;
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
      await _bump(scope, tx);
      return _eventReceipt(e, decisions.values);
    });
  }
}
