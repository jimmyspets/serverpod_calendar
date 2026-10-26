import 'dart:async';
import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

/// Real generated-client writes race across independent example host processes.
Future<void> schedulingSmoke(List<Client> clients) async {
  final a = clients.first.modules.serverpod_calendar;
  final b = clients.last.modules.serverpod_calendar;
  final calendar = (await a.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic organizer publication',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  cal.CalendarEventContent content(String title) => cal.CalendarEventContent(
    summary: title,
    timing: cal.CalendarEventTiming(
      kind: cal.CalendarEventTimeKind.utc,
      start: cal.CalendarEventCivil(year: 2026, month: 11, day: 1, hour: 9),
    ),
  );
  final event = (await a.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: calendar.calendarId,
      content: content('Local draft'),
    ),
  ))!;
  final command = cal.CalendarSchedulingSaveRequest(
    eventId: event.eventId,
    expectedRevision: 1,
    content: content('Explicit invitation'),
    recipients: ['mailto:bob@example.invalid'],
    commandId: cal.Uuid().v4obj(),
  );
  final receipts = await Future.wait([
    a.calendarEvent.saveAndNotify(command),
    b.calendarEvent.saveAndNotify(command),
  ]);
  if (receipts[0].publicationId != receipts[1].publicationId ||
      receipts.where((r) => !r.unchanged).length != 1) {
    throw StateError('Concurrent idempotent publication was not atomic');
  }
  final status = await b.calendarEvent.schedulingStatus(event.eventId);
  if (status.eventRevision != 2 ||
      status.hasLocalChanges ||
      status.origin != cal.CalendarEventOrigin.native) {
    throw StateError('Cross-host publication checkpoint differs');
  }
  final writes = await Future.wait([
    for (final api in [a, b])
      () async {
        try {
          await api.calendarEvent.saveAndNotify(
            command.copyWith(
              expectedRevision: 2,
              commandId: cal.Uuid().v4obj(),
              content: content('Concurrent update ${api == a ? 'A' : 'B'}'),
            ),
          );
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code != cal.CalendarFailureCode.staleRevision) rethrow;
          return false;
        }
      }(),
  ]);
  if (writes.where((v) => v).length != 1) {
    throw StateError('Expected revision race accepted both publications');
  }
  final before = await a.calendarEvent.schedulingStatus(event.eventId);
  await a.calendarEvent.update(
    cal.CalendarEventUpdateRequest(
      eventId: event.eventId,
      expectedRevision: before.eventRevision,
      content: content('Unpublished local edit'),
    ),
  );
  if (!(await b.calendarEvent.schedulingStatus(event.eventId))
      .hasLocalChanges) {
    throw StateError('Local edit was silently published');
  }
  // Recurring host maintenance claims shared work; acceptance is synthetic only.
  var accepted = false;
  for (var i = 0; i < 100; i++) {
    final current = await b.calendarEvent.schedulingStatus(event.eventId);
    if (current.deliveries.every(
      (d) => d.state == cal.CalendarSchedulingDeliveryState.accepted,
    )) {
      accepted = true;
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  if (!accepted) {
    throw StateError('Independent hosts did not dispatch synthetic intent');
  }
  stdout.writeln(
    'PASS: two-host explicit organizer publication, idempotency/revision races, local draft isolation and synthetic acceptance.',
  );
  // Bindings deliberately reject deletion in the first profile. Isolated test
  // storage is reset by the root harness; no public cleanup backdoor is added.
}
