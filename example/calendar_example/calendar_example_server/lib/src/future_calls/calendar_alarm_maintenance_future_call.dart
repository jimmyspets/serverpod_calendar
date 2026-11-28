import 'package:serverpod/serverpod.dart';
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as notify;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

/// Wake-up only. Durable module leases/work survive duplicate calls and loss.
class CalendarAlarmMaintenanceFutureCall extends FutureCall {
  Future<void> sweep(Session session) async {
    await CalendarModule.runAlarmMaintenance(session);
    await notify.NotificationModule.runMaintenance(session);
  }
}
