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
  Future<CalendarAlarmView?> update(
    Session session,
    CalendarAlarmUpdateRequest request,
  ) => CalendarModule.service(session).updatePersonalAlarm(request);
  Future<void> delete(
    Session session,
    CalendarAlarmParent parent,
    UuidValue alarmId,
    int expectedRevision,
  ) =>
      CalendarModule.service(session)
          .deletePersonalAlarm(parent, alarmId, expectedRevision);
}
