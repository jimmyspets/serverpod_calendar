import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/attendee_replies_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runAttendeeReplyJourney(WidgetTester tester, Client client) async {
  final api = client.modules.serverpod_calendar;
  final parent = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic Flutter replies',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  final content = cal.CalendarEventContent(
    summary: 'Reply UI meeting',
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
  final event = (await api.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: parent.calendarId,
      content: content,
    ),
  ))!;
  await api.calendarEvent.saveAndNotify(
    cal.CalendarSchedulingSaveRequest(
      eventId: event.eventId,
      expectedRevision: 1,
      content: content,
      recipients: ['mailto:bob@example.invalid'],
      commandId: const Uuid().v4obj(),
    ),
  );
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  navigator.push(
    MaterialPageRoute<void>(
      builder: (_) =>
          AttendeeRepliesScreen(client: client, eventId: event.eventId),
    ),
  );
  await tester.pumpAndSettle();
  Future<void> ready() async {
    for (var i = 0; i < 200; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final finder = find.byKey(const Key('replies-reload'));
      if (finder.evaluate().isNotEmpty &&
          tester.widget<TextButton>(finder).onPressed != null) {
        return;
      }
    }
    fail('Reply review did not finish bounded work');
  }

  Future<void> tap(String key) async {
    final finder = find.byKey(Key(key));
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).last,
        maxScrolls: 20,
      );
    }
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
    await ready();
  }

  await ready();
  expect(find.text('No recorded response'), findsOneWidget);
  expect(
    find.text(
      'Whole-series master response; single-occurrence responses are separate.',
    ),
    findsOneWidget,
  );
  expect(find.byKey(const Key('replies-error')), findsNothing);
  await tap('reply-simulate');
  expect(find.byKey(const Key('replies-error')), findsNothing);
  var response = (await api.calendarEvent.schedulingResponses(event.eventId))
      .responses
      .single;
  expect(response.isCurrent, isTrue);
  expect(
    response.effectiveParticipation,
    cal.CalendarSchedulingParticipation.accepted,
  );
  await tap('replies-reload');
  // Explicitly submit a verified source for the old version, then refresh the
  // UI and inspect its retained conflict-free stale classification.
  final before = await api.calendarEvent.schedulingResponses(event.eventId);
  final stale = await client.schedulingDemo.simulateReply(
    event.eventId,
    const Uuid().v4obj(),
    'mailto:bob@example.invalid',
    cal.CalendarSchedulingParticipation.declined,
    before.publishedSequence - 1,
    DateTime.utc(2026, 10, 27, 15),
    'Private stale comment',
    null,
  );
  await tap('replies-reload');
  final read = find.byKey(ValueKey('reply-read-${stale.sourceId}'));
  await tester.scrollUntilVisible(
    read,
    200,
    scrollable: find.byType(Scrollable).last,
    maxScrolls: 20,
  );
  await tester.ensureVisible(read);
  await tester.tap(read);
  await tester.pump();
  await ready();
  final source = find.byKey(const Key('reply-source'));
  if (source.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      source,
      200,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 20,
    );
  }
  expect(
    tester.widget<SelectableText>(source).data,
    contains('COMMENT:Private stale comment'),
  );
  response = (await api.calendarEvent.schedulingResponses(event.eventId))
      .responses
      .single;
  expect(
    response.effectiveParticipation,
    cal.CalendarSchedulingParticipation.accepted,
  );
  final masterSource = response.sourceId;
  final originalInput = find.byKey(const Key('reply-original'));
  await tester.scrollUntilVisible(
    originalInput,
    200,
    scrollable: find.byType(Scrollable).last,
    maxScrolls: 20,
  );
  await tester.ensureVisible(originalInput);
  await tester.enterText(originalInput, '2026-11-03');
  await tap('reply-open-instance');
  expect(
    find.text(
      'Single-occurrence response; other occurrences and the whole series stay independent.',
    ),
    findsOneWidget,
  );
  expect(find.text('No recorded response'), findsOneWidget);
  await tap('reply-simulate');
  expect(find.byKey(const Key('replies-error')), findsNothing);
  final instance = await api.calendarEvent.schedulingInstanceResponses(
    event.eventId,
    cal.CalendarEventTiming(
      kind: cal.CalendarEventTimeKind.date,
      start: cal.CalendarEventCivil(year: 2026, month: 11, day: 3),
    ),
  );
  expect(instance.responses.single.isCurrent, isTrue);
  expect(
    (await api.calendarEvent.schedulingResponses(event.eventId))
        .responses
        .single
        .sourceId,
    masterSource,
  );
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tester.pageBack();
  await tester.pumpAndSettle();
}
