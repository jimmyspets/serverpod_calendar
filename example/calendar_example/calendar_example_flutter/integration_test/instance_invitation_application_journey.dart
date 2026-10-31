import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/invitation_occurrence_application_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runInstanceInvitationApplicationJourney(
  WidgetTester tester,
  Client client,
) async {
  final api = client.modules.serverpod_calendar;
  final id = const cal.Uuid().v4obj();
  final master = await client.invitationDemo.simulateRecurring(
    id,
    const cal.Uuid().v4obj(),
    1,
    'Occurrence application journey',
  );
  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Occurrence application journey',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  final link = await api.calendarInvitation.adopt(
    cal.CalendarInvitationAdoptionRequest(
      invitationId: master.entryId,
      sourceId: master.sourceId,
      expectedRevision: 1,
      calendarId: calendar,
      expectedCalendarRevision: 1,
    ),
  );
  final incoming = await client.invitationDemo.simulateOccurrence(
    id,
    const cal.Uuid().v4obj(),
    2,
    false,
  );
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  Future<void> loaded() async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(LinearProgressIndicator).evaluate().isEmpty) {
        break;
      }
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
    if (key == 'invitation-occurrence-apply') {
      expect(tester.widget<ElevatedButton>(target).onPressed, isNotNull);
    }
    await tester.tap(target);
    await tester.pump();
    await loaded();
  }

  try {
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => InvitationOccurrenceApplicationScreen(
          client: client,
          id: incoming.entryId,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await loaded();
    expect(
      find.byKey(const Key('invitation-occurrence-incoming-source')),
      findsOneWidget,
    );
    await tap('invitation-occurrence-apply');
    expect(
      find.byKey(const Key('invitation-occurrence-result')),
      findsOneWidget,
    );
    await client.invitationDemo.simulateOccurrence(
      id,
      const cal.Uuid().v4obj(),
      3,
      true,
    );
    await tap('invitation-occurrence-reload');
    expect(find.text('Apply occurrence cancellation'), findsOneWidget);
    await tap('invitation-occurrence-apply');
    expect(
      (await api.calendarInvitation.occurrenceApplication(incoming.entryId))
          .acceptedKind,
      cal.CalendarInvitationSourceKind.instanceCancellation,
    );
    await client.invitationDemo.simulateOccurrence(
      id,
      const cal.Uuid().v4obj(),
      4,
      false,
    );
    await tap('invitation-occurrence-reload');
    await tap('invitation-occurrence-apply');
    expect(
      (await api.calendarInvitation.occurrenceApplication(incoming.entryId))
          .acceptedKind,
      cal.CalendarInvitationSourceKind.request,
    );
    navigator.pop();
    await tester.pumpAndSettle();
  } finally {
    final event = await api.calendarEvent.getEvent(link.eventId, []);
    await api.calendarEvent.deleteEvent(link.eventId, event.revision);
    await api.calendar.delete(calendar, 1);
    for (final e in [master.entryId, incoming.entryId]) {
      final v = await api.calendarInvitation.getInvitation(e);
      if (v.dismissedAt == null) {
        await api.calendarInvitation.dismiss(e, v.revision);
      }
    }
  }
}
