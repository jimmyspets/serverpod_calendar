import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/invitation_adoption_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runInvitationAdoptionJourney(
  WidgetTester tester,
  Client client, {
  bool recurring = false,
  bool bundle = false,
}) async {
  final simulate = bundle
      ? client.invitationDemo.simulateBundle
      : recurring
      ? client.invitationDemo.simulateRecurring
      : client.invitationDemo.simulate;
  final module = client.modules.serverpod_calendar;
  final label = 'Invitation copy ${const cal.Uuid().v4obj()}';
  final calendar = (await module.calendar.create(
    cal.CalendarCreateRequest(
      displayName: label,
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  final id = const cal.Uuid().v4obj();
  final source = await simulate(
    id,
    const cal.Uuid().v4obj(),
    null,
    'Synthetic calendar copy',
  );
  final entry = await module.calendarInvitation.getInvitation(source.entryId);
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  cal.UuidValue? eventId;
  var parentRevision = 1;
  Future<void> loaded() async {
    for (var n = 0; n < 150; n++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final refresh = find.byKey(const Key('bundle-update-refresh'));
      final bundleBusy =
          refresh.evaluate().isNotEmpty &&
          tester.widget<IconButton>(refresh).onPressed == null;
      if (!bundleBusy &&
          find.byType(LinearProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
    // A completed request schedules a post-frame jump back to its result.
    // Settle the resulting list layout before looking for lazily built text.
    await tester.pumpAndSettle();
    final refresh = find.byKey(const Key('bundle-update-refresh'));
    if (refresh.evaluate().isNotEmpty) {
      expect(
        tester.widget<IconButton>(refresh).onPressed,
        isNotNull,
        reason: 'The complete-update request did not finish',
      );
    }
  }

  Future<void> visible(Finder target) async {
    if (target.evaluate().isEmpty &&
        find.byKey(const Key('bundle-update-scroll')).evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        target,
        300,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('bundle-update-scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
    }
    await tester.ensureVisible(target);
  }

  Future<void> tap(Finder target) async {
    await visible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
    await loaded();
  }

  Future<void> choose() async {
    for (
      var page = 0;
      page < 40 &&
          find
              .byKey(const Key('invitation-more-calendars'))
              .evaluate()
              .isNotEmpty;
      page++
    ) {
      await tap(find.byKey(const Key('invitation-more-calendars')));
    }
    await tap(find.byKey(const Key('invitation-calendar')));
    await tap(find.text(label).last);
  }

  try {
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => InvitationAdoptionScreen(client: client, entry: entry),
      ),
    );
    await tester.pumpAndSettle();
    await loaded();
    if (recurring) {
      expect(
        find.text(
          'Recurring series: adds the complete supported schedule as one local series.',
        ),
        findsOneWidget,
      );
    }
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const Key('invitation-add-confirm')),
          )
          .onPressed,
      isNull,
    );
    await choose();
    await module.calendar.updateMetadata(
      cal.CalendarMetadataUpdateRequest(
        calendarId: calendar,
        expectedRevision: 1,
        displayName: label,
      ),
    );
    parentRevision = 2;
    await tap(find.byKey(const Key('invitation-add-confirm')));
    expect(find.byKey(const Key('invitation-adoption-error')), findsOneWidget);
    expect(find.text('Retry the same calendar addition'), findsOneWidget);
    expect(await module.calendarInvitation.link(entry.id), isNull);
    await tap(find.byKey(const Key('invitation-adoption-refresh')));
    await choose();
    await tap(find.byKey(const Key('invitation-add-confirm')));
    expect(find.byKey(const Key('invitation-adoption-error')), findsNothing);
    expect(find.byKey(const Key('invitation-linked-event')), findsOneWidget);
    final link = (await module.calendarInvitation.link(entry.id))!;
    eventId = link.eventId;
    expect(
      (await module.calendarEvent.getEvent(
        link.eventId,
        cal.CalendarEventFieldGroup.values,
      )).summary,
      'Synthetic calendar copy',
    );
    expect(
      (await module.calendarInvitation.getInvitation(entry.id)).dismissedAt,
      isNotNull,
    );
    if (bundle) {
      expect(link.bundledRequest, isTrue);
      expect(find.byKey(const Key('invitation-review-update')), findsNothing);
      final preview = await module.calendarEvent.preview(
        cal.CalendarEventOccurrenceQuery(
          eventId: link.eventId,
          expectedRevision: 1,
          fromUtc: DateTime.utc(2030),
          untilUtc: DateTime.utc(2030, 1, 9),
        ),
      );
      expect(preview.occurrences.length, 3);
      await client.invitationDemo.simulateBundleUpdate(
        id,
        const cal.Uuid().v4obj(),
        1,
        null,
        'Synthetic calendar copy',
      );
      await tap(find.byKey(const Key('invitation-adoption-refresh')));
      expect(find.byKey(const Key('invitation-linked-event')), findsOneWidget);
      await tap(find.byKey(const Key('invitation-review-bundle-update')));
      expect(find.byKey(const Key('bundle-update-source')), findsOneWidget);
      final initialEvent = await module.calendarEvent.getEvent(
        link.eventId,
        cal.CalendarEventFieldGroup.values,
      );
      await module.calendarEvent.update(
        cal.CalendarEventUpdateRequest(
          eventId: link.eventId,
          expectedRevision: 1,
          content: cal.CalendarEventContent(
            timing: initialEvent.timing!,
            summary: initialEvent.summary,
            description: initialEvent.description,
            location: initialEvent.location,
            status: initialEvent.status!,
            transparency: initialEvent.transparency!,
            recurrence: initialEvent.recurrence,
            periods: initialEvent.periods,
            textParameters: initialEvent.textParameters,
          ),
        ),
      );
      await tap(find.byKey(const Key('bundle-update-apply')));
      expect(find.byKey(const Key('bundle-update-error')), findsOneWidget);
      await visible(find.byKey(const Key('bundle-update-apply')));
      expect(find.text('Retry the same complete update'), findsOneWidget);
      await tap(find.byKey(const Key('bundle-update-refresh')));
      final pending = await module.calendarInvitation.bundleApplication(
        entry.id,
      );
      final input = cal.CalendarInvitationApplyRequest(
        invitationId: entry.id,
        sourceId: pending.incomingSourceId!,
        expectedInvitationRevision: pending.invitationRevision!,
        linkId: pending.linkId,
        expectedEventRevision: pending.eventRevision,
        expectedCalendarRevision: pending.calendarRevision,
        expectedApplicationRevision: pending.applicationRevision,
      );
      await tap(find.byKey(const Key('bundle-update-apply')));
      expect(find.byKey(const Key('bundle-update-result')), findsOneWidget);
      final result = await module.calendarInvitation.applyBundleUpdate(input);
      expect(result.eventRevision, 3);
      final accepted = await module.calendarInvitation.bundleApplication(
        entry.id,
      );
      expect(
        accepted.acceptedComponents
            .singleWhere((v) => v.originalStart == null)
            .sequence,
        isNull,
      );
      await client.invitationDemo.simulateBundleUpdate(
        id,
        const cal.Uuid().v4obj(),
        2,
        1,
        'Incoming master and child',
      );
      await tap(find.byKey(const Key('bundle-update-refresh')));
      await tap(find.byKey(const Key('bundle-update-apply')));
      expect(find.byKey(const Key('bundle-update-result')), findsOneWidget);
      final next = await module.calendarInvitation.bundleApplication(entry.id);
      expect(next.applicationRevision, 2);
      expect(next.eventRevision, 4);
      for (final sequence in [13, 15]) {
        await client.invitationDemo.simulateCancellation(
          id,
          const cal.Uuid().v4obj(),
          sequence,
        );
        final received = await module.calendarInvitation.bundleApplication(
          entry.id,
        );
        expect(
          received.currentContent.status,
          cal.CalendarEventStatus.confirmed,
        );
        await tap(find.byKey(const Key('bundle-update-refresh')));
        await tap(find.byKey(const Key('bundle-update-apply')));
        expect(find.byKey(const Key('bundle-update-result')), findsOneWidget);
        await tap(find.byKey(const Key('bundle-update-refresh')));
        expect(
          find.byKey(const Key('bundle-accepted-cancellation')),
          findsOneWidget,
        );
        final cancelled = await module.calendarInvitation.bundleApplication(
          entry.id,
        );
        expect(
          cancelled.currentContent.status,
          cal.CalendarEventStatus.cancelled,
        );
        expect(cancelled.hasLocalChanges, isFalse);
        expect(cancelled.acceptedCancellationVersion!.sequence, sequence);
        await client.invitationDemo.simulateBundleUpdate(
          id,
          const cal.Uuid().v4obj(),
          2,
          sequence + 1,
          'Incoming master and child',
        );
        await tap(find.byKey(const Key('bundle-update-refresh')));
        await tap(find.byKey(const Key('bundle-update-apply')));
        expect(find.byKey(const Key('bundle-update-result')), findsOneWidget);
      }
      final postCycles = await module.calendarInvitation.bundleApplication(
        entry.id,
      );
      expect(
        postCycles.currentContent.status,
        cal.CalendarEventStatus.confirmed,
      );
      expect(postCycles.acceptedCancellationVersion, isNull);
      await module.calendarEvent.update(
        cal.CalendarEventUpdateRequest(
          eventId: link.eventId,
          expectedRevision: postCycles.eventRevision,
          content: postCycles.currentContent.copyWith(
            summary: 'Local Flutter draft',
          ),
        ),
      );
      await client.invitationDemo.simulateBundleUpdate(
        id,
        const cal.Uuid().v4obj(),
        3,
        16,
        'Incoming master and child',
      );
      await tap(find.byKey(const Key('bundle-update-refresh')));
      expect(find.byKey(const Key('bundle-update-conflict')), findsOneWidget);
      await visible(find.byKey(const Key('bundle-update-apply')));
      expect(
        tester
            .widget<ElevatedButton>(
              find.byKey(const Key('bundle-update-apply')),
            )
            .onPressed,
        isNull,
      );
      navigator.pop();
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();
      return;
    }
    await simulate(
      id,
      const cal.Uuid().v4obj(),
      1,
      'New invitation review',
    );
    await tap(find.byKey(const Key('invitation-adoption-refresh')));
    expect(find.byKey(const Key('invitation-linked-event')), findsOneWidget);
    expect(find.byKey(const Key('invitation-add-confirm')), findsNothing);
    expect(
      (await module.calendarInvitation.getInvitation(entry.id)).dismissedAt,
      isNull,
    );
    await tap(find.byKey(const Key('invitation-review-update')));
    expect(find.byKey(const Key('invitation-update-source')), findsOneWidget);
    final initialUpdate = await module.calendarInvitation.application(entry.id);
    await module.calendarEvent.update(
      cal.CalendarEventUpdateRequest(
        eventId: link.eventId,
        expectedRevision: initialUpdate.eventRevision,
        content: initialUpdate.currentContent,
      ),
    );
    await tap(find.byKey(const Key('invitation-update-apply')));
    expect(find.byKey(const Key('invitation-update-error')), findsOneWidget);
    expect(find.text('Retry the same update'), findsOneWidget);
    await tap(find.byKey(const Key('invitation-update-refresh')));
    await tap(find.byKey(const Key('invitation-update-apply')));
    expect(find.byKey(const Key('invitation-update-result')), findsOneWidget);
    final applied = await module.calendarInvitation.application(entry.id);
    expect(applied.applicationRevision, 1);
    expect(applied.currentContent.summary, 'New invitation review');
    await simulate(
      id,
      const cal.Uuid().v4obj(),
      2,
      'Pending second update',
    );
    final beforeLocal = await module.calendarInvitation.application(entry.id);
    await module.calendarEvent.update(
      cal.CalendarEventUpdateRequest(
        eventId: link.eventId,
        expectedRevision: beforeLocal.eventRevision,
        content: beforeLocal.currentContent.copyWith(
          summary: 'Local Flutter draft',
        ),
      ),
    );
    await tap(find.byKey(const Key('invitation-update-refresh')));
    expect(find.byKey(const Key('invitation-update-conflict')), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const Key('invitation-update-apply')),
          )
          .onPressed,
      isNull,
    );
    expect(
      (await module.calendarInvitation.getInvitation(entry.id)).dismissedAt,
      isNull,
    );

    final beforeCancellation = await module.calendarInvitation.application(
      entry.id,
    );
    await client.invitationDemo.simulateCancellation(
      id,
      const cal.Uuid().v4obj(),
      3,
    );
    await tap(find.byKey(const Key('invitation-update-refresh')));
    expect(
      find.byKey(const Key('invitation-update-cancellation')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('invitation-cancellation-source')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const Key('invitation-update-apply')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const Key('invitation-cancellation-apply')),
          )
          .onPressed,
      isNull,
    );
    final afterCancellation = await module.calendarInvitation.application(
      entry.id,
    );
    expect(afterCancellation.currentContent.summary, 'Local Flutter draft');
    expect(afterCancellation.eventRevision, beforeCancellation.eventRevision);
    expect(
      afterCancellation.applicationRevision,
      beforeCancellation.applicationRevision,
    );
    navigator.pop();
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();
  } finally {
    final current = await module.calendarInvitation.getInvitation(entry.id);
    if (current.dismissedAt == null) {
      await module.calendarInvitation.dismiss(entry.id, current.revision);
    }
    if (eventId != null) {
      final currentEvent = await module.calendarEvent.getEvent(eventId, []);
      await module.calendarEvent.deleteEvent(eventId, currentEvent.revision);
    }
    await module.calendar.delete(calendar, parentRevision);
  }
}
