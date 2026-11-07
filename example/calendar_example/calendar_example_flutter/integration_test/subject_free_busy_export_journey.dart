import 'dart:async';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/availability_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runSubjectFreeBusyExportJourney(
  WidgetTester tester,
  Client client,
) async {
  final module = client.modules.serverpod_calendar;
  final owner = await client.smoke.whoAmI();
  final parent = (await module.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Flutter subject export',
      availabilityZoneId: 'Europe/Stockholm',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  await module.calendar.changeSubject(
    cal.CalendarSubjectChangeRequest(
      calendarId: parent,
      expectedRevision: 1,
      action: cal.CalendarSubjectAction.attach,
      namespace: 'demo',
      kind: 'user',
      externalId: owner,
      contributesAvailability: true,
    ),
  );
  final event = (await module.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: parent,
      content: cal.CalendarEventContent(
        summary: 'Private subject export title',
        timing: cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: cal.CalendarEventCivil(year: 2032, month: 5, day: 3, hour: 9),
          duration: cal.CalendarEventDuration(hours: 1),
        ),
      ),
    ),
  ))!.eventId;
  Future<void> idle({bool error = false}) async {
    await tester.pump();
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(LinearProgressIndicator).evaluate().isEmpty) break;
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
    if (!error) expect(find.byKey(const Key('search-error')), findsNothing);
  }

  Future<void> tap(String key, {bool error = false}) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await idle(error: error);
  }

  Future<void> field(String key, String value) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.enterText(finder, value);
    await tester.pump();
  }

  String wire() => tester
      .widget<SelectableText>(find.byKey(const Key('search-export-result')))
      .data!;
  try {
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => AvailabilitySearchScreen(client: client),
        ),
      ),
    );
    await idle();
    await field('search-from', '2032-05-03T00:00:00Z');
    await field('search-until', '2032-05-04T00:00:00Z');
    await field('search-minimum', '86400');
    await tap('search-load');
    expect(find.byKey(const Key('search-common-complete')), findsOneWidget);
    expect(
      find.text('No interval meets the requested minimum duration.'),
      findsWidgets,
    );
    await tap('search-export');
    expect(wire(), contains('20320503T090000Z/20320503T100000Z'));
    expect(RegExp('BEGIN:VFREEBUSY').allMatches(wire()), hasLength(1));
    for (final secret in [
      parent.toString(),
      event.toString(),
      owner,
      'Private subject export title',
      'METHOD:',
      'ATTENDEE:',
    ]) {
      expect(wire(), isNot(contains(secret)));
    }
    await tap('search-mode');
    await tester.tap(find.text('Per person/resource').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-export-result')), findsNothing);
    await tap('search-export');
    expect(RegExp('BEGIN:VFREEBUSY').allMatches(wire()), hasLength(1));
    await tap('search-add');
    await field('search-reference-1', owner);
    await tap('search-export');
    expect(RegExp('BEGIN:VFREEBUSY').allMatches(wire()), hasLength(1));
    await field('search-reference-1', 'not-an-authorized-demo-target');
    expect(find.byKey(const Key('search-export-result')), findsNothing);
    await tap('search-export', error: true);
    expect(find.byKey(const Key('search-error')), findsOneWidget);
    expect(find.byKey(const Key('search-export-result')), findsNothing);
    await tap('search-remove-1', error: true);
    await tap('search-export');
    expect(wire(), contains('20320503T090000Z/20320503T100000Z'));
    expect((await module.calendar.getCalendar(parent, [])).revision, 2);
    expect((await module.calendarEvent.getEvent(event, [])).revision, 1);
    await tester.pageBack();
    await tester.pumpAndSettle();
  } finally {
    await module.calendarEvent.deleteEvent(event, 1);
    final current = await module.calendar.getCalendar(parent, []);
    await module.calendar.changeSubject(
      cal.CalendarSubjectChangeRequest(
        calendarId: parent,
        expectedRevision: current.revision,
        action: cal.CalendarSubjectAction.detach,
        namespace: 'demo',
        kind: 'user',
        externalId: owner,
        contributesAvailability: true,
      ),
    );
    final detached = await module.calendar.getCalendar(parent, []);
    await module.calendar.delete(parent, detached.revision);
  }
}
