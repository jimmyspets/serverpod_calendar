import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

/// Wake-up only. Durable module leases/work survive duplicate calls and loss.
class CalendarAlarmMaintenanceFutureCall extends FutureCall {
  Future<void> sweep(Session session) =>
      CalendarModule.runAlarmMaintenance(session);
}
