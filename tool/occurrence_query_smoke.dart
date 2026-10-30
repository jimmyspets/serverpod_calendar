import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> occurrenceQuerySmoke(List<Client> clients) async {
  if (clients.length != 2) {
    throw StateError('Occurrence probe requires two hosts');
  }
  final a = clients.first.modules.serverpod_calendar,
      b = clients.last.modules.serverpod_calendar;
  final calendar = (await a.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Occurrence query probe',
      availabilityZoneId: 'Europe/Stockholm',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  final ids = <cal.UuidValue>[];
  cal.CalendarEventCivil civil(int day, [int hour = 9]) =>
      cal.CalendarEventCivil(year: 2030, month: 1, day: day, hour: hour);
  cal.CalendarEventTiming timing(int day, [int hour = 9]) =>
      cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.utc,
        start: civil(day, hour),
        duration: cal.CalendarEventDuration(hours: 1),
      );
  final content = cal.CalendarEventContent(
    summary: 'Query series',
    timing: timing(1),
    recurrence: cal.CalendarEventRecurrence(
      rule: cal.CalendarEventRule(
        frequency: cal.CalendarEventFrequency.daily,
        count: 3,
        byDay: [],
        byMonthDay: [],
        byYearDay: [],
        byWeekNo: [],
        byMonth: [],
        byHour: [],
        byMinute: [],
        bySetPosition: [],
      ),
      inclusions: [],
      exclusions: [],
    ),
  );
  try {
    final series = (await a.calendarEvent.create(
      cal.CalendarEventCreateRequest(calendarId: calendar, content: content),
    ))!.eventId;
    ids.add(series);
    await a.calendarEvent.changeOccurrence(
      cal.CalendarEventOccurrenceChange(
        eventId: series,
        expectedRevision: 1,
        originalStart: timing(2).copyWith(duration: null),
        action: cal.CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: timing(3, 12),
      ),
    );
    await b.calendarEvent.changeOccurrence(
      cal.CalendarEventOccurrenceChange(
        eventId: series,
        expectedRevision: 2,
        originalStart: timing(2).copyWith(duration: null),
        action: cal.CalendarEventOccurrenceAction.cancelSingle,
      ),
    );
    await a.calendarEvent.changeOccurrence(
      cal.CalendarEventOccurrenceChange(
        eventId: series,
        expectedRevision: 3,
        originalStart: timing(3).copyWith(duration: null),
        action: cal.CalendarEventOccurrenceAction.replaceFutureTiming,
        replacement: timing(4, 10),
      ),
    );
    ids.add(
      (await b.calendarEvent.create(
        cal.CalendarEventCreateRequest(
          calendarId: calendar,
          content: cal.CalendarEventContent(
            summary: 'Civil day',
            timing: cal.CalendarEventTiming(
              kind: cal.CalendarEventTimeKind.date,
              start: civil(1, 0),
            ),
          ),
        ),
      ))!.eventId,
    );
    ids.add(
      (await a.calendarEvent.create(
        cal.CalendarEventCreateRequest(
          calendarId: calendar,
          content: cal.CalendarEventContent(
            summary: 'Transparent point',
            transparency: cal.CalendarEventTransparency.transparent,
            timing: cal.CalendarEventTiming(
              kind: cal.CalendarEventTimeKind.utc,
              start: civil(2),
            ),
          ),
        ),
      ))!.eventId,
    );
    final q = cal.CalendarEventOccurrenceListQuery(
      calendarId: calendar,
      fromUtc: DateTime.utc(2030, 1, 1),
      untilUtc: DateTime.utc(2030, 1, 5),
      pageSize: 1,
      fieldGroups: [cal.CalendarEventFieldGroup.summary],
    );
    final raced = await Future.wait([
      a.calendarEvent.listOccurrences(q),
      b.calendarEvent.listOccurrences(q),
    ]);
    if (raced.first.occurrences.single.eventId !=
            raced.last.occurrences.single.eventId ||
        raced.first.nextCursor == null ||
        raced.last.nextCursor == null ||
        raced.first.nextCursor == raced.last.nextCursor) {
      throw StateError(
        'Concurrent occurrence pages lost stable ordering or private cursor identity',
      );
    }
    final rows = <cal.CalendarEventOccurrenceListItem>[
      ...raced.first.occurrences,
    ];
    var cursor = raced.first.nextCursor;
    var alternate = false;
    while (cursor != null) {
      final page = await (alternate ? a : b).calendarEvent.listOccurrences(
        q.copyWith(cursor: cursor),
      );
      rows.addAll(page.occurrences);
      cursor = page.nextCursor;
      alternate = !alternate;
    }
    if (rows.length != 5 ||
        rows.first.originalStart.kind != cal.CalendarEventTimeKind.date ||
        rows.first.occurrence.startUtc != null ||
        rows.where((r) => r.cancelled).length != 1 ||
        rows
                .map((r) => '${r.eventId}:${r.originalStart.start.toJson()}')
                .toSet()
                .length !=
            5) {
      throw StateError(
        'Cross-host occurrence pages lost date meaning, identity or cancellation',
      );
    }
    final moved = rows.singleWhere((r) => r.cancelled);
    if (moved.originalStart.start.day != 2 ||
        moved.occurrence.startUtc != DateTime.utc(2030, 1, 3, 12)) {
      throw StateError('Cancelled moved-in original was retargeted');
    }
    final active = await a.calendarEvent.listOccurrences(
      q.copyWith(pageSize: 100, includeCancelled: false),
    );
    if (active.occurrences.length != 4 ||
        active.nextCursor != null ||
        active.occurrences.any((r) => r.cancelled)) {
      throw StateError(
        'Cancellation filtering falsely exhausted or retained rows',
      );
    }
    final current = await b.calendarEvent.getEvent(series, [
      cal.CalendarEventFieldGroup.timing,
      cal.CalendarEventFieldGroup.state,
    ]);
    if (current.revision != 4 ||
        current.timingOverrides!.singles.single.cancelled != true) {
      throw StateError('Detail projection changed canonical state');
    }
    await b.calendarEvent.update(
      cal.CalendarEventUpdateRequest(
        eventId: series,
        expectedRevision: 4,
        content: content.copyWith(summary: 'Updated query series'),
      ),
    );
    var stale = false;
    try {
      await a.calendarEvent.listOccurrences(
        q.copyWith(cursor: raced.first.nextCursor),
      );
    } on cal.CalendarException catch (e) {
      stale = e.code == cal.CalendarFailureCode.invalidCursor;
    }
    if (!stale) {
      throw StateError(
        'Remote native edit did not fence occurrence continuation',
      );
    }
    stdout.writeln(
      'PASS: two-host occurrence pages, concurrent cursor writes, DATE/point/transparent/recurring projections, cancelled moved originals, canonical-state preservation and remote-edit fencing.',
    );
  } finally {
    for (final id in ids.reversed) {
      final value = await b.calendarEvent.getEvent(id, []);
      await b.calendarEvent.deleteEvent(id, value.revision);
    }
    final value = await b.calendar.getCalendar(calendar, []);
    await b.calendar.delete(calendar, value.revision);
  }
}
