part of 'calendar_module.dart';

extension CalendarAlarmAdoptionOperations on CalendarService {
  CalendarAuthorizationRequest _alarmSourceRead(
    _AlarmParent parent,
  ) => CalendarAuthorizationRequest(
    key: 'alarmSource:${parent.event?.identity.id ?? parent.task!.identity.id}',
    operation: parent.event != null
        ? CalendarPermission.readEventSource
        : CalendarPermission.readTaskSource,
    current: parent.parent.snapshot,
    calendarId: parent.parent.identity.id,
    eventId: parent.event?.identity.id,
    currentEvent: parent.event?.snapshot,
    taskId: parent.task?.identity.id,
    currentTask: parent.task?.snapshot,
  );

  int _alarmSourceRevision(_AlarmParent parent) =>
      parent.event?.identity.revision ?? parent.task!.identity.revision;

  List<CalendarAlarmDefinition> _alarmSourceDefinitions(
    _AlarmParent parent,
    String? dateZoneId,
  ) {
    CalendarAlarmDuration? eventDuration(CalendarEventSourceDuration? d) =>
        d == null
        ? null
        : CalendarAlarmDuration(
            sign: d.sign,
            weeks: d.weeks,
            days: d.days,
            hours: d.hours,
            minutes: d.minutes,
            seconds: d.seconds,
          );
    CalendarAlarmDuration? taskDuration(CalendarTaskSourceDuration? d) =>
        d == null
        ? null
        : CalendarAlarmDuration(
            sign: d.sign,
            weeks: d.weeks,
            days: d.days,
            hours: d.hours,
            minutes: d.minutes,
            seconds: d.seconds,
          );
    CalendarAlarmDefinition definition(
      DateTime? absolute,
      CalendarAlarmDuration? relative,
      String? related,
      int? repeat,
      CalendarAlarmDuration? interval,
    ) {
      if (related != null && related != 'START' && related != 'END') {
        throw _failure(CalendarFailureCode.validation);
      }
      return _taskValue(
        () => validateAlarmDefinition(
          CalendarAlarmDefinition(
            absoluteUtc: absolute,
            relativeDuration: relative,
            anchor: relative == null
                ? null
                : related == 'END'
                ? CalendarAlarmAnchor.end
                : CalendarAlarmAnchor.start,
            dateZoneId: relative == null ? null : dateZoneId,
            repeat: repeat,
            repeatInterval: interval,
          ),
        ),
      );
    }

    final result = parent.event != null
        ? [
            for (final a
                in parent.event!.data.protocolState?.sourceMetadata?.alarms ??
                    <CalendarEventSourceAlarm>[])
              definition(
                a.absoluteUtc,
                eventDuration(a.relativeDuration),
                a.related,
                a.repeat,
                eventDuration(a.repeatInterval),
              ),
          ]
        : [
            for (final a
                in parent.task!.data.sourceState?.master.metadata.alarms ??
                    <CalendarTaskSourceAlarm>[])
              definition(
                a.absoluteUtc,
                taskDuration(a.relativeDuration),
                a.related,
                a.repeat,
                taskDuration(a.repeatInterval),
              ),
          ];
    if (result.length > 16) throw _failure(CalendarFailureCode.limitExceeded);
    return List.unmodifiable(result);
  }

  Future<CalendarAlarmSourceTimings> personalAlarmSourceTimings(
    CalendarAlarmParent input,
    String? dateZoneId,
  ) async {
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final parent = await _alarmParent(c, input, tx);
      final request = _alarmSourceRead(parent);
      await _decide(c, [request], tx, CalendarAuthorizationPhase.read);
      final definitions = _alarmSourceDefinitions(parent, dateZoneId);
      await _verifyContext(c);
      await _decide(c, [request], tx, CalendarAuthorizationPhase.read);
      await _verifyContext(c);
      return CalendarAlarmSourceTimings(
        parentRevision: _alarmSourceRevision(parent),
        definitions: definitions,
      );
    });
  }

  Future<CalendarAlarmView?> adoptPersonalAlarm(
    CalendarAlarmParent input,
    int expectedParentRevision,
    int sourceIndex,
    String? dateZoneId,
  ) async {
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final parent = await _alarmParent(c, input, tx);
      final sourceRead = _alarmSourceRead(parent);
      // Do not expose source-dependent revision, cardinality or validation
      // results to callers without source-read authority.
      await _decide(
        c,
        [sourceRead],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (expectedParentRevision != _alarmSourceRevision(parent)) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      final definitions = _alarmSourceDefinitions(parent, dateZoneId);
      if (sourceIndex < 0 || sourceIndex >= definitions.length) {
        throw _failure(CalendarFailureCode.validation);
      }
      final definition = definitions[sourceIndex];
      final recipient = await _alarmRecipient(
        c,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      return _createPrivateAlarm(
        c,
        input,
        parent,
        recipient,
        definition,
        tx,
        additionalRequests: [
          sourceRead,
          _alarmRequest(
            parent,
            CalendarPermission.adoptPersonalAlarm,
            recipient,
            sourceIndex: sourceIndex,
            proposed: definition,
            armed: false,
          ),
        ],
      );
    });
  }
}
