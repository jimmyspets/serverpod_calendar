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
    await tester.pumpAndSettle();
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
    await client.invitationDemo.simulateCancellation(
      id,
      const cal.Uuid().v4obj(),
      6,
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
    await tap('invitation-cancellation-apply');
    final whole = await api.calendarInvitation.application(master.entryId);
    expect(whole.currentContent.status, cal.CalendarEventStatus.cancelled);
    expect(whole.hasAcceptedRangeCancellation, isTrue);
    navigator.pop();
    await tester.pumpAndSettle();
    await client.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      7,
      'Reopened meeting retains cancelled suffix',
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
    await tap('invitation-update-apply');
    final reopened = await api.calendarInvitation.application(master.entryId);
    expect(reopened.currentContent.status, cal.CalendarEventStatus.confirmed);
    expect(reopened.hasAcceptedRangeCancellation, isTrue);
    expect(
      (await api.calendarInvitation.rangeApplication(source.entryId))
          .currentOccurrence!
          .status,
      cal.CalendarEventStatus.cancelled,
    );
    navigator.pop();
    await tester.pumpAndSettle();
    await client.invitationDemo.simulateRange(
      id,
      const cal.Uuid().v4obj(),
      8,
      false,
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
    await tap('invitation-range-review-restoration');
    expect(find.text('Apply range restoration'), findsWidgets);
    final ready = await api.calendarInvitation.rangeRestorationApplication(
      source.entryId,
    );
    expect(
      ready.canApply,
      isTrue,
      reason: 'The matching source must be eligible for restoration.',
    );
    final applyButton = find.byKey(const Key('invitation-occurrence-apply'));
    expect(tester.widget<ElevatedButton>(applyButton).onPressed, isNotNull);
    await tap('invitation-occurrence-apply');
    final actionError = find.byKey(const Key('invitation-occurrence-error'));
    expect(
      actionError,
      findsNothing,
      reason: actionError.evaluate().isEmpty
          ? ''
          : tester.widget<Text>(actionError).data,
    );
    final restored = await api.calendarInvitation.rangeRestorationApplication(
      source.entryId,
    );
    expect(
      restored.hasAcceptedRangeRestoration,
      isTrue,
      reason: 'The explicit UI action must commit restoration.',
    );
    expect(restored.hasLocalChanges, isFalse);
    expect(
      restored.currentOccurrence!.status,
      cal.CalendarEventStatus.confirmed,
    );
    expect(restored.acceptedVersion.sequence, 8);
    final masterRestored = await api.calendarInvitation.application(
      master.entryId,
    );
    expect(masterRestored.hasAcceptedRangeRestoration, isTrue);
    expect(masterRestored.occurrenceCompositionBlocked, isFalse);
    navigator.pop();
    await tester.pumpAndSettle();
    await client.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      9,
      'Master preserves restored state',
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
      find.byKey(const Key('invitation-master-range-restoration')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('invitation-master-composition-guard')),
      findsNothing,
    );
    await tap('invitation-update-apply');
    final composed = await api.calendarInvitation.application(master.entryId);
    expect(composed.hasAcceptedRangeRestoration, isTrue);
    expect(composed.acceptedSequence, 9);
    expect(composed.hasLocalChanges, isFalse);
    final retainedRestoration = await api.calendarInvitation
        .rangeRestorationApplication(
          source.entryId,
        );
    expect(retainedRestoration.acceptedVersion.sequence, 8);
    expect(
      retainedRestoration.currentOccurrence!.status,
      cal.CalendarEventStatus.confirmed,
    );
    navigator.pop();
    await tester.pumpAndSettle();
    for (final cancelled in [true, false]) {
      if (cancelled) {
        await client.invitationDemo.simulateCancellation(
          id,
          const cal.Uuid().v4obj(),
          10,
        );
      } else {
        await client.invitationDemo.simulateRecurring(
          id,
          const cal.Uuid().v4obj(),
          11,
          'Reopened restored meeting',
        );
      }
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
        find.byKey(const Key('invitation-master-range-restoration')),
        findsOneWidget,
      );
      await tap(
        cancelled ? 'invitation-cancellation-apply' : 'invitation-update-apply',
      );
      final current = await api.calendarInvitation.application(master.entryId);
      expect(current.hasAcceptedRangeRestoration, isTrue);
      expect(current.hasLocalChanges, isFalse);
      expect(
        current.currentContent.status,
        cancelled
            ? cal.CalendarEventStatus.cancelled
            : cal.CalendarEventStatus.confirmed,
      );
      final history = await api.calendarInvitation.rangeRestorationApplication(
        source.entryId,
      );
      expect(history.acceptedVersion.sequence, 8);
      navigator.pop();
      await tester.pumpAndSettle();
    }
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
