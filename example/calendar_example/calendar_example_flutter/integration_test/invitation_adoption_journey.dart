import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/invitation_adoption_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runInvitationAdoptionJourney(
  WidgetTester tester,
  Client client,
) async {
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
  final source = await client.invitationDemo.simulate(
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
      if (find.byType(LinearProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
  }

  Future<void> tap(Finder target) async {
    await tester.ensureVisible(target);
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
    await client.invitationDemo.simulate(
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
    await client.invitationDemo.simulate(
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
