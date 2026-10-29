import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/invitation_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runInvitationCancellationApplicationJourney(
  WidgetTester tester,
  Client client,
) async {
  final api = client.modules.serverpod_calendar;
  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Flutter cancellation lifecycle',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  final id = const cal.Uuid().v4obj();
  final source = await client.invitationDemo.simulate(
    id,
    const cal.Uuid().v4obj(),
    null,
    'Flutter retained content',
  );
  final link = await api.calendarInvitation.adopt(
    cal.CalendarInvitationAdoptionRequest(
      invitationId: source.entryId,
      sourceId: source.sourceId,
      expectedRevision: 1,
      calendarId: calendar.calendarId,
      expectedCalendarRevision: 1,
    ),
  );
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  Future<void> ready() async {
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
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pump();
    await ready();
  }

  try {
    await client.invitationDemo.simulateCancellation(
      id,
      const cal.Uuid().v4obj(),
      1,
    );
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => InvitationUpdateScreen(
          client: client,
          invitationId: source.entryId,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await ready();
    expect(find.text('Current status: confirmed'), findsOneWidget);
    final view = await api.calendarInvitation.application(source.entryId);
    await api.calendarEvent.update(
      cal.CalendarEventUpdateRequest(
        eventId: link.eventId,
        expectedRevision: view.eventRevision,
        content: view.currentContent,
      ),
    );
    await tap('invitation-cancellation-apply');
    expect(find.byKey(const Key('invitation-update-error')), findsOneWidget);
    expect(find.text('Retry the same cancellation'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const Key('invitation-update-apply')),
          )
          .onPressed,
      isNull,
    );
    await tap('invitation-update-refresh');
    await tap('invitation-cancellation-apply');
    expect(find.byKey(const Key('invitation-update-result')), findsOneWidget);
    expect(find.text('Current status: cancelled'), findsOneWidget);
    expect(find.text('Last accepted source: Cancellation'), findsOneWidget);
    var current = await api.calendarInvitation.application(source.entryId);
    expect(current.hasLocalChanges, isFalse);
    expect(current.currentContent.summary, 'Flutter retained content');
    await client.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      2,
      'Flutter reopened content',
    );
    expect(
      (await api.calendarInvitation.application(source.entryId))
          .currentContent
          .status,
      cal.CalendarEventStatus.cancelled,
    );
    await tap('invitation-update-refresh');
    expect(find.text('Apply update / reopen'), findsOneWidget);
    await tap('invitation-update-apply');
    current = await api.calendarInvitation.application(source.entryId);
    expect(current.currentContent.status, cal.CalendarEventStatus.confirmed);
    expect(current.currentContent.summary, 'Flutter reopened content');
    expect(current.acceptedKind, cal.CalendarInvitationSourceKind.request);
    expect(find.text('Current status: confirmed'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();
  } finally {
    final entry = await api.calendarInvitation.getInvitation(source.entryId);
    if (entry.dismissedAt == null) {
      await api.calendarInvitation.dismiss(entry.id, entry.revision);
    }
    final event = await api.calendarEvent.getEvent(link.eventId, []);
    await api.calendarEvent.deleteEvent(link.eventId, event.revision);
    await api.calendar.delete(calendar.calendarId, 1);
  }
}
