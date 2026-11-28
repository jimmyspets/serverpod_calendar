import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/invitation_occurrence_application_screen.dart';
import 'package:calendar_example_flutter/invitation_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runRangeInvitationApplicationJourney(
  WidgetTester tester,
  Client client,
) async {
  final api = client.modules.serverpod_calendar, id = const cal.Uuid().v4obj();
  final master = await client.invitationDemo.simulateRecurring(
    id,
    const cal.Uuid().v4obj(),
    1,
    'Range application journey',
  );
  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Range application journey',
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
  final source = await client.invitationDemo.simulateRange(
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
    await tester.tap(target);
    await tester.pump();
    await loaded();
  }

  try {
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => InvitationOccurrenceApplicationScreen(
          client: client,
          id: source.entryId,
          range: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await loaded();
    expect(find.text('Apply range update'), findsWidgets);
    final input = tester
        .widget<SelectableText>(
          find.byKey(const Key('invitation-occurrence-incoming-source')),
        )
        .data!;
    expect(input, contains('RANGE=THISANDFUTURE'));
    await tap('invitation-occurrence-apply');
    expect(
      find.byKey(const Key('invitation-occurrence-result')),
      findsOneWidget,
    );
    expect(
      (await api.calendarInvitation.rangeApplication(source.entryId))
          .acceptedVersion
          .sequence,
      2,
    );
    navigator.pop();
    await tester.pumpAndSettle();
    await client.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      3,
      'Master after range journey',
    );
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => InvitationUpdateScreen(
          client: client,
          invitationId: master.entryId,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await loaded();
    expect(
      find.byKey(const Key('invitation-master-composition-guard')),
      findsNothing,
    );
    await tap('invitation-update-apply');
    final retained = await api.calendarInvitation.rangeApplication(
      source.entryId,
    );
    expect(retained.currentOccurrence!.summary, 'Synthetic occurrence update');
    expect(retained.acceptedVersion.sequence, 2);
    expect(retained.occurrenceRevision, 2);
    navigator.pop();
    await tester.pumpAndSettle();
    await client.invitationDemo.simulateRange(
      id,
      const cal.Uuid().v4obj(),
      4,
      true,
    );
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => InvitationOccurrenceApplicationScreen(
          client: client,
          id: source.entryId,
          range: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await loaded();
    final button = find.byKey(const Key('invitation-occurrence-apply'));
    if (button.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        button,
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 30,
      );
    }
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
    expect(
      (await api.calendarInvitation.rangeApplication(source.entryId)).canApply,
      isTrue,
    );
    await tap('invitation-occurrence-apply');
    final acceptedCancellation = await api.calendarInvitation.rangeApplication(
      source.entryId,
    );
    expect(acceptedCancellation.hasAcceptedRangeCancellation, isTrue);
    expect(acceptedCancellation.hasLocalChanges, isFalse);
    expect(
      acceptedCancellation.currentOccurrence!.status,
      cal.CalendarEventStatus.cancelled,
    );
    navigator.pop();
    await tester.pumpAndSettle();
    await client.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      5,
      'Master retains cancelled suffix',
    );
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => InvitationUpdateScreen(
          client: client,
          invitationId: master.entryId,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await loaded();
    expect(
      find.byKey(const Key('invitation-master-range-cancellation')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('invitation-master-composition-guard')),
      findsNothing,
    );
    await tap('invitation-update-apply');
    final composedMask = await api.calendarInvitation.application(
      master.entryId,
    );
    expect(composedMask.hasAcceptedRangeCancellation, isTrue);
    expect(composedMask.acceptedSequence, 5);
    expect(composedMask.hasLocalChanges, isFalse);
    final rangeAfterMaster = await api.calendarInvitation.rangeApplication(
      source.entryId,
    );
    expect(rangeAfterMaster.acceptedVersion.sequence, 4);
    expect(
      rangeAfterMaster.currentOccurrence!.status,
      cal.CalendarEventStatus.cancelled,
    );
    navigator.pop();
    await tester.pumpAndSettle();
  } finally {
    final event = await api.calendarEvent.getEvent(link.eventId, []);
    await api.calendarEvent.deleteEvent(link.eventId, event.revision);
    await api.calendar.delete(calendar, 1);
    for (final e in [master.entryId, source.entryId]) {
      final view = await api.calendarInvitation.getInvitation(e);
      if (view.dismissedAt == null) {
        await api.calendarInvitation.dismiss(e, view.revision);
      }
    }
  }
}
