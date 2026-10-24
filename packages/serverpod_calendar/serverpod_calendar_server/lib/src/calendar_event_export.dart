part of 'calendar_module.dart';

extension CalendarEventExportOperations on CalendarService {
  Future<ByteData> exportEvents(CalendarEventExportRequest input) async {
    if (input.selection.isEmpty ||
        input.selection.length > const IcalendarComponentLimits().maxEvents) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final selection = List<CalendarEventExportSelection>.unmodifiable(
      input.selection,
    );
    if (selection.map((s) => s.eventId).toSet().length != selection.length ||
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
        [_er(parent, CalendarPermission.exportEvents)],
        tx,
        CalendarAuthorizationPhase.read,
      );
      final members = <_Event>[];
      for (final target in selection) {
        final e = await _event(c, target.eventId, tx);
        if (e.identity.calendarId != parent.identity.id) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        members.add(e);
      }
      members.sort((a, b) => a.data.protocolUid.compareTo(b.data.protocolUid));
      final intent = CalendarEventExportIntent(members.map((m) => m.snapshot));
      CalendarAuthorizationRequest request(
        CalendarPermission operation, [
        _Event? member,
      ]) => CalendarAuthorizationRequest(
        key: '${operation.name}:${member?.identity.id ?? parent.identity.id}',
        operation: operation,
        calendarId: parent.identity.id,
        current: parent.snapshot,
        eventId: member?.identity.id,
        currentEvent: member?.snapshot,
        eventExport: intent,
        eventGroups: CalendarEventFieldGroup.values,
      );
      final requests = [
        request(CalendarPermission.exportEvents),
        for (final e in members) ...[
          request(CalendarPermission.exportEvents, e),
          request(CalendarPermission.readEvent, e),
          request(CalendarPermission.readEventSource, e),
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
            (r) => r.operation == CalendarPermission.readEvent,
          )) {
            if (!decisions[r.key]!.eventDisclosedGroups.containsAll(
              CalendarEventFieldGroup.values,
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
                    .singleWhere((s) => s.eventId == m.identity.id)
                    .expectedRevision,
          )) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      late final Uint8List bytes;
      try {
        bytes = eventExportBytes(members.map((m) => m.snapshot).toList());
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
