import 'dart:async';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/event_scheduling_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> _wait(WidgetTester tester, bool Function() ready) async {
  for (var i = 0; i < 150; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (ready()) return;
  }
  fail('Scheduling UI did not reach expected state');
}

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 20,
    );
  }
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
  await _wait(
    tester,
    () => find.byType(LinearProgressIndicator).evaluate().isEmpty,
  );
}

Future<void> runSchedulingJourney(WidgetTester tester, Client client) async {
  final api = client.modules.serverpod_calendar;
  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic Flutter scheduling',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  cal.CalendarEventContent content(String title) => cal.CalendarEventContent(
    summary: title,
    recurrence: cal.CalendarEventRecurrence(
      rule: cal.CalendarEventRule(
        frequency: cal.CalendarEventFrequency.daily,
        count: 4,
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
    timing: cal.CalendarEventTiming(
      kind: cal.CalendarEventTimeKind.date,
      start: cal.CalendarEventCivil(year: 2026, month: 11, day: 2),
    ),
  );
  final receipt = (await api.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: calendar.calendarId,
      content: content('Draft'),
    ),
  ))!;
  await api.calendarEvent.changeOccurrence(
    cal.CalendarEventOccurrenceChange(
      eventId: receipt.eventId,
      expectedRevision: 1,
      originalStart: cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.date,
        start: cal.CalendarEventCivil(year: 2026, month: 11, day: 4),
      ),
      action: cal.CalendarEventOccurrenceAction.replaceSingleTiming,
      replacement: cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.date,
        start: cal.CalendarEventCivil(year: 2026, month: 11, day: 5),
      ),
    ),
  );
  final event = await api.calendarEvent.getEvent(
    receipt.eventId,
    cal.CalendarEventFieldGroup.values,
  );
  unawaited(
    Navigator.of(tester.element(find.byType(Scaffold).first)).push<void>(
      MaterialPageRoute(
        builder: (_) => EventSchedulingScreen(client: client, event: event),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await _wait(
    tester,
    () =>
        find.byKey(const Key('scheduling-status')).evaluate().isNotEmpty &&
        find.byType(LinearProgressIndicator).evaluate().isEmpty,
  );
  await tester.enterText(
    find.byKey(const Key('scheduling-summary')),
    'Explicit Flutter invitation',
  );
  await tester.enterText(
    find.byKey(const Key('scheduling-recipients')),
    'mailto:bob@example.invalid',
  );
  await _tap(tester, 'scheduling-publish');
  expect(find.byKey(const Key('scheduling-error')), findsNothing);
  expect(find.text('Current saved content is published'), findsOneWidget);
  final published = await api.calendarEvent.schedulingStatus(event.id);
  expect(published.eventRevision, 3);
  expect(published.hasLocalChanges, false);
  await api.calendarEvent.update(
    cal.CalendarEventUpdateRequest(
      eventId: event.id,
      expectedRevision: 3,
      content: content('Local Flutter edit'),
    ),
  );
  await _tap(tester, 'scheduling-reload');
  expect(find.text('Local changes have not been published'), findsOneWidget);
  expect(
    (await api.calendarEvent.schedulingStatus(event.id)).publicationId,
    published.publicationId,
  );
  await _tap(tester, 'scheduling-publish');
  expect(find.byKey(const Key('scheduling-error')), findsNothing);
  final updated = await api.calendarEvent.schedulingStatus(event.id);
  expect(updated.publicationId, isNot(published.publicationId));
  expect(updated.eventRevision, 5);
  expect(updated.hasLocalChanges, false);
  await api.calendarEvent.update(
    cal.CalendarEventUpdateRequest(
      eventId: event.id,
      expectedRevision: 5,
      content: content('Saved private draft before cancellation'),
    ),
  );
  await _tap(tester, 'scheduling-reload');
  await _tap(tester, 'scheduling-cancel');
  expect(find.byKey(const Key('scheduling-error')), findsNothing);
  final cancelled = await api.calendarEvent.schedulingStatus(event.id);
  expect(cancelled.method, 'CANCEL');
  expect(cancelled.eventRevision, 7);
  expect(cancelled.hasLocalChanges, true);
  final saved = await api.calendarEvent.getEvent(
    event.id,
    cal.CalendarEventFieldGroup.values,
  );
  expect(saved.summary, 'Saved private draft before cancellation');
  expect(saved.status, cal.CalendarEventStatus.cancelled);
  expect(find.text('Reopen and notify'), findsOneWidget);
  await _tap(tester, 'scheduling-publish');
  expect(find.byKey(const Key('scheduling-error')), findsNothing);
  final reopened = await api.calendarEvent.schedulingStatus(event.id);
  expect(reopened.method, 'REQUEST');
  expect(reopened.eventRevision, 8);
  expect(reopened.hasLocalChanges, false);
  await api.calendarEvent.changeOccurrence(
    cal.CalendarEventOccurrenceChange(
      eventId: event.id,
      expectedRevision: 8,
      originalStart: cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.date,
        start: cal.CalendarEventCivil(year: 2026, month: 11, day: 3),
      ),
      action: cal.CalendarEventOccurrenceAction.cancelSingle,
    ),
  );
  await _tap(tester, 'scheduling-reload');
  final publishButton = find.byKey(const Key('scheduling-publish'));
  if (publishButton.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      publishButton,
      250,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 20,
    );
  }
  await tester.ensureVisible(publishButton);
  expect(tester.widget<FilledButton>(publishButton).onPressed, isNotNull);
  final priorPublication = (await api.calendarEvent.schedulingStatus(event.id))
      .publicationId;
  await _tap(tester, 'scheduling-publish');
  expect(find.byKey(const Key('scheduling-error')), findsOneWidget);
  expect(
    (await api.calendarEvent.schedulingStatus(event.id)).publicationId,
    priorPublication,
  );
  await _tap(tester, 'scheduling-reload');
  await _tap(tester, 'scheduling-cancel');
  expect(find.byKey(const Key('scheduling-error')), findsNothing);
  final withException = await api.calendarEvent.getEvent(
    event.id,
    cal.CalendarEventFieldGroup.values,
  );
  expect(withException.revision, 10);
  expect(withException.status, cal.CalendarEventStatus.cancelled);
  expect(withException.timingOverrides!.singles.any((v) => v.cancelled), true);
  expect(
    withException.timingOverrides!.singles
        .firstWhere((v) => v.cancelled)
        .originalStart
        .start
        .day,
    3,
  );
  await tester.pageBack();
  await tester.pumpAndSettle();
  // This profile deliberately has no binding deletion API. The root harness
  // owns and resets this isolated synthetic storage; no cleanup endpoint exists.
}
