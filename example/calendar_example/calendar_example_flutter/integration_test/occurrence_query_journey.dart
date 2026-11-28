import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/calendar_occurrences_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runOccurrenceQueryJourney(
  WidgetTester tester,
  Client client,
) async {
  final module = client.modules.serverpod_calendar, api = module.calendarEvent;
  final calendar = (await module.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Flutter occurrence window',
      availabilityZoneId: 'Europe/Stockholm',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  final ids = <cal.UuidValue>[];
  cal.CalendarEventCivil civil(int day, [int hour = 9]) =>
      cal.CalendarEventCivil(year: 2030, month: 1, day: day, hour: hour);
  final content = cal.CalendarEventContent(
    summary: 'Flutter occurrence series',
    timing: cal.CalendarEventTiming(
      kind: cal.CalendarEventTimeKind.utc,
      start: civil(1),
      duration: cal.CalendarEventDuration(hours: 1),
    ),
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

  Future<void> top() async {
    await tester.drag(find.byType(ListView).last, const Offset(0, 3000));
    await tester.pumpAndSettle();
  }

  Future<void> tap(Finder target) async {
    await top();
    await tester.scrollUntilVisible(
      target,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(target);
    await tester.pump();
    await loaded();
  }

  try {
    final series = (await api.create(
      cal.CalendarEventCreateRequest(calendarId: calendar, content: content),
    ))!.eventId;
    ids.add(series);
    await api.changeOccurrence(
      cal.CalendarEventOccurrenceChange(
        eventId: series,
        expectedRevision: 1,
        originalStart: cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: civil(1),
        ),
        action: cal.CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: civil(2, 12),
          duration: cal.CalendarEventDuration(hours: 2),
        ),
      ),
    );
    ids.add(
      (await api.create(
        cal.CalendarEventCreateRequest(
          calendarId: calendar,
          content: cal.CalendarEventContent(
            summary: 'Flutter civil day',
            timing: cal.CalendarEventTiming(
              kind: cal.CalendarEventTimeKind.date,
              start: civil(1, 0),
            ),
          ),
        ),
      ))!.eventId,
    );
    ids.add(
      (await api.create(
        cal.CalendarEventCreateRequest(
          calendarId: calendar,
          content: cal.CalendarEventContent(
            summary: 'Flutter cancelled point',
            status: cal.CalendarEventStatus.cancelled,
            timing: cal.CalendarEventTiming(
              kind: cal.CalendarEventTimeKind.utc,
              start: civil(3, 12),
            ),
          ),
        ),
      ))!.eventId,
    );
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => CalendarOccurrencesScreen(
          client: client,
          calendarId: calendar,
          initialFromUtc: DateTime.utc(2030, 1, 1),
          initialUntilUtc: DateTime.utc(2030, 1, 5),
          pageSize: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await loaded();
    expect(
      find.text('DATE 2030-01-01 → 2030-01-02 (exclusive)'),
      findsOneWidget,
    );
    await tap(find.byKey(const Key('occurrences-more')));
    await tap(find.byKey(const Key('occurrences-more')));
    await tester.scrollUntilVisible(
      find.text('Moved occurrence'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Moved occurrence'), findsOneWidget);
    await tap(find.byKey(const Key('occurrences-more')));
    await tap(find.byKey(const Key('occurrences-more')));
    await tester.scrollUntilVisible(
      find.text('Cancelled occurrence'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cancelled occurrence'), findsOneWidget);
    expect(find.byKey(const Key('occurrences-more')), findsNothing);
    await tap(find.byKey(const Key('occurrences-cancelled')));
    await tap(find.byKey(const Key('occurrences-apply')));
    for (var i = 0; i < 3; i++) {
      await tap(find.byKey(const Key('occurrences-more')));
    }
    expect(find.byKey(const Key('occurrences-more')), findsNothing);
    expect(find.text('Cancelled occurrence'), findsNothing);
    // Reject nonzero fractions before Dart parsing can truncate nanoseconds.
    await top();
    await tester.enterText(
      find.byKey(const Key('occurrences-from')),
      '2030-01-01T00:00:00.000000001Z',
    );
    await tap(find.byKey(const Key('occurrences-apply')));
    expect(find.byKey(const Key('occurrences-error')), findsOneWidget);
    await top();
    await tester.enterText(
      find.byKey(const Key('occurrences-from')),
      '2030-01-01T00:00:00.00000Z',
    );
    await tap(find.byKey(const Key('occurrences-apply')));
    expect(find.byKey(const Key('occurrences-error')), findsNothing);
    await api.update(
      cal.CalendarEventUpdateRequest(
        eventId: series,
        expectedRevision: 2,
        content: content.copyWith(summary: 'Updated Flutter occurrence'),
      ),
    );
    await tap(find.byKey(const Key('occurrences-more')));
    expect(find.byKey(const Key('occurrences-error')), findsOneWidget);
    expect(find.byType(Card), findsNothing);
    await tap(find.byKey(const Key('occurrences-refresh')));
    await tap(find.byKey(const Key('occurrences-more')));
    expect(find.text('Updated Flutter occurrence'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();
  } finally {
    for (final id in ids.reversed) {
      final current = await api.getEvent(id, []);
      await api.deleteEvent(id, current.revision);
    }
    final current = await module.calendar.getCalendar(calendar, []);
    await module.calendar.delete(calendar, current.revision);
  }
}
