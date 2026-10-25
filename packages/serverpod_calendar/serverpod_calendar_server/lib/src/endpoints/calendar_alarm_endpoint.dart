import 'package:serverpod/serverpod.dart';

import '../calendar_module.dart';
import '../generated/protocol.dart';

class CalendarAlarmEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<List<CalendarAlarmView>> list(
    Session session,
    CalendarAlarmParent parent,
  ) => CalendarModule.service(session).listPersonalAlarms(parent);
  Future<CalendarAlarmView?> create(
    Session session,
    CalendarAlarmCreateRequest request,
  ) => CalendarModule.service(session).createPersonalAlarm(request);
  Future<CalendarAlarmSourceTimings> sourceTimings(
    Session session,
    CalendarAlarmParent parent,
    String? dateZoneId,
  ) =>
      CalendarModule.service(session)
          .personalAlarmSourceTimings(parent, dateZoneId);
  Future<CalendarAlarmView?> adopt(
    Session session,
    CalendarAlarmParent parent,
    int expectedParentRevision,
    int sourceIndex,
    String? dateZoneId,
  ) => CalendarModule.service(
    session,
  ).adoptPersonalAlarm(parent, expectedParentRevision, sourceIndex, dateZoneId);
  Future<CalendarAlarmView?> update(
    Session session,
    CalendarAlarmUpdateRequest request,
  ) => CalendarModule.service(session).updatePersonalAlarm(request);
  Future<CalendarAlarmView?> setArmed(
    Session session,
    CalendarAlarmParent parent,
    UuidValue alarmId,
    int expectedRevision,
    bool armed,
  ) =>
      CalendarModule.service(session)
          .setPersonalAlarmArmed(parent, alarmId, expectedRevision, armed);
  Future<void> delete(
    Session session,
    CalendarAlarmParent parent,
    UuidValue alarmId,
    int expectedRevision,
  ) =>
      CalendarModule.service(session)
          .deletePersonalAlarm(parent, alarmId, expectedRevision);
  Future<CalendarAlarmActionView?> act(
    Session session,
    CalendarAlarmActionRequest request,
  ) => CalendarModule.service(session).actOnPersonalAlarm(request);
  Future<CalendarAlarmActivityPage> activity(
    Session session,
    CalendarAlarmParent parent,
    UuidValue alarmId,
    CalendarAlarmActivityKind kind,
    int pageSize,
    String? cursor,
  ) =>
      CalendarModule.service(session)
          .personalAlarmActivity(parent, alarmId, kind, pageSize, cursor);
}
