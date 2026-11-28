import 'package:serverpod/serverpod.dart';
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as notify;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_feed_server/serverpod_calendar_feed_server.dart'
    as feed;

/// Wake-up only. Durable module leases/work survive duplicate calls and loss.
class CalendarAlarmMaintenanceFutureCall extends FutureCall {
  Future<void> sweep(Session session) async {
    await runExampleMaintenanceStages([
      () => CalendarModule.runAlarmMaintenance(session),
      () => notify.NotificationModule.runMaintenance(session),
      () => CalendarModule.runSchedulingMaintenance(session),
      () => CalendarModule.runFreeBusyExchangeMaintenance(session),
      () => CalendarModule.runIncomingPublicationMaintenance(session),
      () => CalendarModule.runInvitationResponseMaintenance(session),
      () => feed.CalendarFeedModule.runMaintenance(session),
    ]);
  }
}

/// Independent durable modules must all receive their wake-up, even if another
/// module fails. Preserve the first error/stack for Serverpod diagnostics.
Future<void> runExampleMaintenanceStages(
  List<Future<void> Function()> stages,
) async {
  Object? firstError;
  StackTrace? firstStack;
  for (final work in stages) {
    try {
      await work();
    } catch (error, stack) {
      firstError ??= error;
      firstStack ??= stack;
    }
  }
  if (firstError != null) {
    Error.throwWithStackTrace(firstError, firstStack!);
  }
}
