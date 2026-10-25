import 'dart:async';
import 'dart:convert';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:serverpod_notifications_client/serverpod_notifications_client.dart'
    as notify;

/// Real generated-client recovery and Redis stream across independent hosts.
Future<void> notificationSmoke(
  List<Client> clients, {
  Future<void> Function()? loseProducer,
  Future<void> Function(bool)? setRecipientBlocked,
}) async {
  if (clients.length < 2) throw StateError('Two hosts required');
  final a = clients.first, b = clients.last;
  var api = a.modules.serverpod_calendar;
  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic live reminder',
      availabilityZoneId: 'Europe/Stockholm',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  cal.CalendarEventReceipt? event;
  StreamSubscription<notify.NotificationHint>? subscription;
  final hintIds = <cal.UuidValue>{};
  Future<void> subscribe() async {
    final ready = Completer<void>();
    subscription = b.notificationStream.watch().listen(
      (hint) {
        if (!ready.isCompleted) ready.complete();
        if (hint.notificationId != null) hintIds.add(hint.notificationId!);
      },
      onError: (Object error, StackTrace stack) {
        if (!ready.isCompleted) ready.completeError(error, stack);
      },
    );
    await ready.future.timeout(const Duration(seconds: 15));
  }

  Future<notify.NotificationView?> current(cal.UuidValue alarm) async {
    final page = await b.modules.serverpod_notifications.notification.recover(
      100,
      null,
    );
    return page.notifications
        .where(
          (v) =>
              v.sourceNamespace == 'calendar.alarm' &&
              (jsonDecode(v.actionReference!) as Map)['alarmId'] == '$alarm',
        )
        .firstOrNull;
  }

  try {
    await subscribe();
    final content = cal.CalendarEventContent(
      summary: 'Synthetic initial reminder',
      timing: cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.utc,
        start: cal.CalendarEventCivil(year: 2026, month: 10, day: 25, hour: 12),
      ),
    );
    event = (await api.calendarEvent.create(
      cal.CalendarEventCreateRequest(
        calendarId: calendar.calendarId,
        content: content,
      ),
    ))!;
    final parent = cal.CalendarAlarmParent(
      kind: cal.CalendarAlarmParentKind.event,
      id: event.eventId,
    );
    final due = DateTime.fromMillisecondsSinceEpoch(
      (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 - 30) * 1000,
      isUtc: true,
    );
    final alarm = (await api.calendarAlarm.create(
      cal.CalendarAlarmCreateRequest(
        parent: parent,
        definition: cal.CalendarAlarmDefinition(absoluteUtc: due),
      ),
    ))!;
    final armed = (await api.calendarAlarm.setArmed(
      parent,
      alarm.id,
      alarm.revision,
      true,
    ))!;
    notify.NotificationView? view;
    final deadline = DateTime.now().add(const Duration(seconds: 50));
    while (DateTime.now().isBefore(deadline)) {
      view = await current(alarm.id);
      if (view != null && hintIds.contains(view.id)) break;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (view == null ||
        !hintIds.contains(view.id) ||
        view.title != content.summary) {
      throw StateError(
        'Cross-host durable reminder and Redis hint were not both observed',
      );
    }
    final id = view.id;
    if (loseProducer != null) {
      await loseProducer();
      api = b.modules.serverpod_calendar;
    }
    await api.calendarEvent.update(
      cal.CalendarEventUpdateRequest(
        eventId: event.eventId,
        expectedRevision: 1,
        content: content.copyWith(
          summary: 'Synthetic current authorized reminder',
        ),
      ),
    );
    event = event.copyWith(revision: 2);
    final refreshedBy = DateTime.now().add(const Duration(seconds: 40));
    notify.NotificationView? refreshed;
    while (DateTime.now().isBefore(refreshedBy)) {
      try {
        refreshed = await current(alarm.id);
      } on notify.NotificationException catch (e) {
        if (e.code != notify.NotificationFailureCode.unavailable) rethrow;
      }
      if (refreshed?.title == 'Synthetic current authorized reminder') break;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (refreshed?.title != 'Synthetic current authorized reminder') {
      throw StateError('Recovery served stale copied source text');
    }
    await subscription?.cancel();
    subscription = null;
    await subscribe();
    view = await current(alarm.id);
    if (view?.id != id) {
      throw StateError('Reconnect did not recover the same durable live ID');
    }
    if (setRecipientBlocked != null) {
      try {
        await setRecipientBlocked(true);
        var denied = false;
        try {
          await current(alarm.id);
        } on notify.NotificationException catch (e) {
          denied =
              e.code == notify.NotificationFailureCode.accessDenied ||
              e.code == notify.NotificationFailureCode.unavailable;
        } on ServerpodClientUnauthorized {
          denied = true;
        }
        if (!denied) {
          throw StateError('Blocked recipient retained live source access');
        }
      } finally {
        await setRecipientBlocked(false);
      }
      await subscription?.cancel();
      subscription = null;
      await subscribe();
      view = await current(alarm.id);
      if (view?.id != id) {
        throw StateError('Restored authority lost the live reference');
      }
    }
    final action = jsonDecode(view!.actionReference!) as Map<String, dynamic>;
    await b.modules.serverpod_calendar.calendarAlarm.act(
      cal.CalendarAlarmActionRequest(
        parent: parent,
        alarmId: alarm.id,
        expectedAlarmRevision: armed.revision,
        expectedActionRevision: action['actionRevision'] as int,
        kind: cal.CalendarAlarmActionKind.acknowledge,
        firingId: cal.UuidValue.fromString(action['firingId'] as String),
      ),
    );
    if (await current(alarm.id) != null) {
      throw StateError('Acknowledged source remained in live recovery');
    }
    print(
      'PASS: two-host Redis hint, durable stable-ID recovery, fresh source text, reconnect and acknowledgement withdrawal.',
    );
  } finally {
    await subscription?.cancel();
    if (event != null) {
      await api.calendarEvent.deleteEvent(event.eventId, event.revision);
    }
    await api.calendar.delete(calendar.calendarId, calendar.revision);
  }
}
