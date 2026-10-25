import 'dart:convert';
import 'dart:typed_data';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

/// Synthetic generated-client adoption across independent hosts.
Future<void> alarmAdoptionSmoke(List<Client> clients) async {
  final a = clients.first.modules.serverpod_calendar;
  final b = clients.last.modules.serverpod_calendar;
  final calendar = (await a.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic source adoption',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  final due = DateTime.fromMillisecondsSinceEpoch(
    (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 - 30) * 1000,
    isUtc: true,
  );
  final wireDue =
      '${due.toIso8601String().replaceAll(RegExp('[-:]'), '').split('.').first}Z';
  final bytes = ByteData.sublistView(
    Uint8List.fromList(
      utf8.encode(
        [
          'BEGIN:VCALENDAR',
          'VERSION:2.0',
          'PRODID:Synthetic',
          'BEGIN:VEVENT',
          'UID:adoption@example.invalid',
          'DTSTAMP:20260301T000000Z',
          'DTSTART:20261025T120000Z',
          'SUMMARY:Imported item text',
          'BEGIN:VALARM',
          'ACTION:DISPLAY',
          'DESCRIPTION:Never use source reminder text',
          'TRIGGER:-PT5M',
          'UID:untrusted-alarm',
          'ACKNOWLEDGED:20260301T000000Z',
          'END:VALARM',
          'BEGIN:VALARM',
          'ACTION:DISPLAY',
          'DESCRIPTION:Untrusted snooze text',
          'TRIGGER;VALUE=DATE-TIME:$wireDue',
          'UID:untrusted-snooze',
          'RELATED-TO;RELTYPE=SNOOZE:untrusted-alarm',
          'END:VALARM',
          'END:VEVENT',
          'END:VCALENDAR',
          '',
        ].join('\r\n'),
      ),
    ),
  );
  final imported = (await a.calendarEvent.importEvents(
    cal.CalendarEventImportRequest(
      calendarId: calendar.calendarId,
      expectedRevision: 1,
      bytes: bytes,
    ),
  )).receipts.single;
  var revision = imported.revision;
  final parent = cal.CalendarAlarmParent(
    kind: cal.CalendarAlarmParentKind.event,
    id: imported.eventId,
  );
  try {
    final review = await b.calendarAlarm.sourceTimings(parent, null);
    if (review.definitions.length != 2) {
      throw StateError('Master source timing was not reviewed');
    }
    await a.calendarAlarm.adopt(parent, review.parentRevision, 0, null);
    final absolute = (await b.calendarAlarm.adopt(
      parent,
      review.parentRevision,
      1,
      null,
    ))!;
    if (absolute.armed ||
        (await a.calendarAlarm.activity(
          parent,
          absolute.id,
          cal.CalendarAlarmActivityKind.actions,
          10,
          null,
        )).actions.isNotEmpty) {
      throw StateError('Adoption activated or imported source action state');
    }
    await a.calendarEvent.update(
      cal.CalendarEventUpdateRequest(
        eventId: imported.eventId,
        expectedRevision: revision,
        content: cal.CalendarEventContent(
          summary: 'Current authorized copied reminder',
          timing: cal.CalendarEventTiming(
            kind: cal.CalendarEventTimeKind.utc,
            start: cal.CalendarEventCivil(
              year: 2026,
              month: 10,
              day: 25,
              hour: 12,
            ),
          ),
        ),
      ),
    );
    revision++;
    var stale = false;
    try {
      await b.calendarAlarm.adopt(parent, review.parentRevision, 0, null);
    } on cal.CalendarException catch (e) {
      stale = e.code == cal.CalendarFailureCode.staleRevision;
    }
    if (!stale) throw StateError('Stale source selection retargeted');
    for (var i = 2; i < 15; i++) {
      await a.calendarAlarm.adopt(parent, revision, 0, null);
    }
    Future<Object> race(dynamic api) async {
      try {
        return (await api.adopt(parent, revision, 0, null)) as Object;
      } on cal.CalendarException catch (e) {
        return e;
      }
    }

    final raced = await Future.wait([
      race(a.calendarAlarm),
      race(b.calendarAlarm),
    ]);
    if (raced.whereType<cal.CalendarAlarmView>().length != 1 ||
        raced.whereType<cal.CalendarException>().single.code !=
            cal.CalendarFailureCode.limitExceeded ||
        (await b.calendarAlarm.list(parent)).length != 16) {
      throw StateError('Cross-host adoption cap race failed');
    }
    await a.calendarAlarm.setArmed(
      parent,
      absolute.id,
      absolute.revision,
      true,
    );
    var delivered = false;
    final deadline = DateTime.now().add(const Duration(seconds: 45));
    while (DateTime.now().isBefore(deadline)) {
      final page = await clients
          .last
          .modules
          .serverpod_notifications
          .notification
          .recover(100, null);
      if (page.notifications.any(
        (v) => v.title == 'Current authorized copied reminder',
      )) {
        delivered = true;
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (!delivered) {
      throw StateError(
        'Explicitly armed copy did not use current authorized item text',
      );
    }
    print(
      'PASS: cross-host timing-only unarmed adoption, inert source actions, stale selection/cap race and explicit arming with current item text.',
    );
  } finally {
    await b.calendarEvent.deleteEvent(imported.eventId, revision);
    await a.calendar.delete(calendar.calendarId, calendar.revision);
  }
}
