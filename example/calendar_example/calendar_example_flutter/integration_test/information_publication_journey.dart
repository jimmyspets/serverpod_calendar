import 'dart:async';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/event_information_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runInformationPublicationJourney(
  WidgetTester tester,
  Client client,
) async {
  final api = client.modules.serverpod_calendar;
  final parent = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Flutter information publication',
      availabilityZoneId: 'Europe/Stockholm',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  final content = cal.CalendarEventContent(
    summary: 'Flutter information',
    timing: cal.CalendarEventTiming(
      kind: cal.CalendarEventTimeKind.utc,
      start: cal.CalendarEventCivil(year: 2027, month: 4, day: 2, hour: 9),
    ),
  );
  final id = (await api.calendarEvent.create(
    cal.CalendarEventCreateRequest(calendarId: parent, content: content),
  ))!.eventId;
  final event = await api.calendarEvent.getEvent(
    id,
    cal.CalendarEventFieldGroup.values,
  );
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  unawaited(
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => EventInformationScreen(client: client, event: event),
      ),
    ),
  );
  Future<void> idle() async {
    await tester.pump();
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(LinearProgressIndicator).evaluate().isEmpty) break;
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('information-error')), findsNothing);
  }

  Future<void> tap(String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await idle();
  }

  await idle();
  expect(find.textContaining('not an attendance request'), findsOneWidget);
  await tester.enterText(
    find.byKey(const Key('information-recipients')),
    'mailto:bob@example.invalid',
  );
  await tap('information-publish');
  expect(find.textContaining('method: PUBLISH'), findsOneWidget);
  expect(
    tester
        .widget<TextField>(find.byKey(const Key('information-recipients')))
        .enabled,
    isFalse,
  );
  await tap('information-publish');
  expect(
    find.text('Already recorded; no new delivery queued.'),
    findsOneWidget,
  );
  final published = await api.calendarEvent.getEvent(id, []);
  expect(published.revision, 2);
  await api.calendarEvent.update(
    cal.CalendarEventUpdateRequest(
      eventId: id,
      expectedRevision: 2,
      content: content.copyWith(summary: 'New unpublished draft'),
    ),
  );
  await tap('information-refresh');
  expect(find.textContaining('local changes: true'), findsOneWidget);
  await tap('information-cancel');
  expect(find.textContaining('method: CANCEL'), findsOneWidget);
  await tap('information-reopen');
  expect(find.textContaining('method: PUBLISH'), findsOneWidget);
  final after = await api.calendarEvent.getEvent(
    id,
    cal.CalendarEventFieldGroup.values,
  );
  expect(after.summary, 'New unpublished draft');
  expect(after.status, cal.CalendarEventStatus.confirmed);
  await tap('information-publish');
  expect(find.textContaining('local changes: false'), findsOneWidget);
  await tester.pageBack();
  await tester.pumpAndSettle();
  // Publication dependency remains intentionally in disposable synthetic storage.
}
