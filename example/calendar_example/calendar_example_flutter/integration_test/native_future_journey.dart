import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/event_occurrence_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runNativeFutureJourney(WidgetTester tester, Client client) async {
  final api = client.modules.serverpod_calendar;
  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Native cutoff journey',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  cal.CalendarEventTiming anchor(int day) => cal.CalendarEventTiming(
    kind: cal.CalendarEventTimeKind.utc,
    start: cal.CalendarEventCivil(year: 2026, month: 1, day: day, hour: 9),
  );
  final event = (await api.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: calendar,
      content: cal.CalendarEventContent(
        summary: 'Native cutoff journey',
        timing: anchor(1)
            .copyWith(duration: cal.CalendarEventDuration(hours: 1)),
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
  await api.calendarEvent.changeOccurrence(
    cal.CalendarEventOccurrenceChange(
      eventId: event.eventId,
      expectedRevision: 1,
      originalStart: anchor(4),
      action: cal.CalendarEventOccurrenceAction.cancelSingle,
    ),
  );
  final view = await api.calendarEvent.getEvent(
    event.eventId,
    cal.CalendarEventFieldGroup.values,
  );
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  Future<void> loaded() async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(LinearProgressIndicator).evaluate().isEmpty) break;
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
  }

  Future<void> tap(String key) async {
    final target = find.byKey(Key(key));
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        target,
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 30,
      );
    } else {
      await tester.ensureVisible(target);
    }
    await tester.tap(target);
    await tester.pump();
    await loaded();
  }

  try {
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => EventOccurrenceScreen(client: client, event: view),
      ),
    );
    await tester.pumpAndSettle();
    await tap('preview-load');
    await tap('occurrence-cancel-future-2026-01-02T09:00:00');
    expect(find.byKey(const Key('occurrence-restore-future')), findsOneWidget);
    var current = await api.calendarEvent.getEvent(event.eventId, [
      cal.CalendarEventFieldGroup.timing,
    ]);
    expect(current.timingOverrides!.cancelledFrom!.start.day, 2);
    expect(current.timingOverrides!.singles.single.cancelled, isTrue);
    await tap('occurrence-restore-future');
    expect(find.byKey(const Key('occurrence-restore-future')), findsNothing);
    current = await api.calendarEvent.getEvent(event.eventId, [
      cal.CalendarEventFieldGroup.timing,
    ]);
    expect(current.timingOverrides!.cancelledFrom, isNull);
    expect(current.timingOverrides!.singles.single.cancelled, isTrue);
    expect(current.revision, 4);
    navigator.pop();
    await tester.pumpAndSettle();
  } finally {
    final saved = await api.calendarEvent.getEvent(event.eventId, []);
    await api.calendarEvent.deleteEvent(event.eventId, saved.revision);
    await api.calendar.delete(calendar, 1);
  }
}
