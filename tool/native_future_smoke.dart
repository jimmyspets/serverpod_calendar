import 'dart:convert';
import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:serverpod_calendar_feed_client/serverpod_calendar_feed_client.dart'
    as feed;

Future<void> nativeFutureSmoke(List<Client> clients) async {
  final a = clients.first.modules.serverpod_calendar,
      b = clients.last.modules.serverpod_calendar;
  final manager = clients.first.modules.serverpod_calendar_feed.calendarFeed;
  void require(bool value, String label) {
    if (!value) throw StateError(label);
  }

  final calendar = (await a.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Native future client',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  final event = (await a.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: calendar,
      content: cal.CalendarEventContent(
        summary: 'Synthetic native cutoff',
        timing: cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: cal.CalendarEventCivil(year: 2026, month: 1, day: 1, hour: 9),
          duration: cal.CalendarEventDuration(hours: 1),
        ),
        recurrence: cal.CalendarEventRecurrence(
          rule: cal.CalendarEventRule(
            frequency: cal.CalendarEventFrequency.daily,
            count: 5,
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
      ),
    ),
  ))!;
  feed.CalendarFeedView? subscription;
  Future<(int, String?)> fetch(Uri uri, [String? validator]) async {
    final http = HttpClient();
    try {
      final request = await http.getUrl(uri);
      request.followRedirects = false;
      if (validator != null) {
        request.headers.set(HttpHeaders.ifNoneMatchHeader, validator);
      }
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      await response.transform(utf8.decoder).join();
      return (
        response.statusCode,
        response.headers.value(HttpHeaders.etagHeader),
      );
    } finally {
      http.close(force: true);
    }
  }

  cal.CalendarEventTiming anchor(int day) => cal.CalendarEventTiming(
    kind: cal.CalendarEventTimeKind.utc,
    start: cal.CalendarEventCivil(year: 2026, month: 1, day: day, hour: 9),
  );
  Future<cal.CalendarEventOccurrencePage> rows(bool cancelled) =>
      b.calendarEvent.listOccurrences(
        cal.CalendarEventOccurrenceListQuery(
          calendarId: calendar,
          fromUtc: DateTime.utc(2026),
          untilUtc: DateTime.utc(2026, 1, 10),
          pageSize: 20,
          includeCancelled: cancelled,
          fieldGroups: [],
        ),
      );
  try {
    subscription = await manager.create(
      feed.CalendarFeedSettings(
        displayName: 'Native cutoff feed',
        calendarIds: [calendar],
      ),
    );
    final credential = await manager.createCredential(
      subscription.id,
      subscription.revision,
      'Synthetic local URL',
    );
    final url = Uri.parse(credential.url).replace(port: 18282),
        before = await fetch(Uri.parse(credential.url).replace(port: 18282));
    require(
      before.$1 == 200 && before.$2 != null,
      'Initial native feed unavailable',
    );
    final command = cal.CalendarEventOccurrenceChange(
      eventId: event.eventId,
      expectedRevision: 1,
      originalStart: anchor(3),
      action: cal.CalendarEventOccurrenceAction.cancelFuture,
    );
    final race = await Future.wait(
      clients.map((client) async {
        try {
          await client.modules.serverpod_calendar.calendarEvent
              .changeOccurrence(command);
          return true;
        } on cal.CalendarException catch (error) {
          if (error.code != cal.CalendarFailureCode.staleRevision) rethrow;
          return false;
        }
      }),
    );
    require(
      race.where((v) => v).length == 1,
      'Concurrent native cutoff writes did not have one winner',
    );
    final masked = await b.calendarEvent.getEvent(event.eventId, [
      cal.CalendarEventFieldGroup.timing,
      cal.CalendarEventFieldGroup.state,
    ]);
    require(
      masked.revision == 2 &&
          masked.timingOverrides?.cancelledFrom?.start.day == 3,
      'Other host lost stored cutoff',
    );
    require(
      (await rows(false)).occurrences.length == 2 &&
          (await rows(true)).occurrences.where((v) => v.cancelled).length == 3,
      'Native cutoff page projections disagree',
    );
    final failedFeed = await fetch(url, before.$2);
    require(
      failedFeed.$1 != 200 && failedFeed.$1 != 304,
      'Unsupported cutoff returned content or stale 304',
    );
    await b.calendarEvent.changeOccurrence(
      command.copyWith(
        expectedRevision: 2,
        action: cal.CalendarEventOccurrenceAction.restoreFuture,
      ),
    );
    final restored = await fetch(url, before.$2);
    require(
      restored.$1 == 200 && restored.$2 != before.$2,
      'Restored native feed failed to advance validator',
    );
    require(
      (await fetch(url, restored.$2)).$1 == 304 &&
          (await rows(false)).occurrences.length == 5,
      'Restored feed/page state disagrees',
    );
    stdout.writeln(
      'PASS: native cancellation/restoration generated clients, actual two-host write race, cancelled pages and HTTP feed rejection/no stale 304/restored ETags.',
    );
  } finally {
    if (subscription != null) {
      final current = await manager.read(subscription.id);
      await manager.delete(current.id, current.revision);
    }
    final current = await a.calendarEvent.getEvent(event.eventId, []);
    await a.calendarEvent.deleteEvent(event.eventId, current.revision);
    await a.calendar.delete(calendar, 1);
  }
}
