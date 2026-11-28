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
  expect(published.eventRevision, 2);
  expect(published.hasLocalChanges, false);
  await api.calendarEvent.update(
    cal.CalendarEventUpdateRequest(
      eventId: event.id,
      expectedRevision: 2,
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
  expect(updated.eventRevision, 4);
  expect(updated.hasLocalChanges, false);
  await tester.pageBack();
  await tester.pumpAndSettle();
  // This profile deliberately has no binding deletion API. The root harness
  // owns and resets this isolated synthetic storage; no cleanup endpoint exists.
}
