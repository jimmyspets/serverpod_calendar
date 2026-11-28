import 'dart:async';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/incoming_publications_screen.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> runIncomingPublicationJourney(
  WidgetTester tester,
  Client client, {
  bool fromHome = false,
}) async {
  Future<void> waitFor(Finder finder) async {
    for (var i = 0; i < 150 && finder.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finder, findsOneWidget);
  }

  Future<void> tap(String key) async {
    for (
      var i = 0;
      i < 150 && find.byType(LinearProgressIndicator).evaluate().isNotEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  final fixture = cal.Uuid().v4obj();
  final destination = 'Publication UI ${fixture.toString().substring(0, 8)}';
  late cal.CalendarIncomingPublicationIngressReceipt receipt;
  late cal.UuidValue calendar;
  await tester.runAsync(() async {
    calendar = (await client.modules.serverpod_calendar.calendar.create(
      cal.CalendarCreateRequest(
        displayName: destination,
        availabilityZoneId: 'Europe/Stockholm',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!.calendarId;
    receipt = await client.publicationDemo.simulate(
      fixture,
      cal.Uuid().v4obj(),
      0,
      false,
      true,
      'Published UI fixture',
    );
  });
  if (fromHome) {
    await tap('open-publications');
  } else {
    // The complete journey can call this from an existing calendar route.
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(
      nav.push<void>(
        MaterialPageRoute(
          builder: (_) => IncomingPublicationsScreen(client: client),
        ),
      ),
    );
    await tester.pump();
  }
  await waitFor(find.byKey(ValueKey('publication-${receipt.entryId}')));
  await tester.tap(find.byKey(ValueKey('publication-${receipt.entryId}')));
  await tester.pump();
  await waitFor(find.byKey(const Key('publication-calendar')));
  await tap('publication-source');
  await waitFor(find.byKey(const Key('publication-source-text')));
  expect(find.textContaining('UID:synthetic-publication:'), findsOneWidget);
  for (
    var page = 0;
    page < 20 && find.text('More calendars').evaluate().isNotEmpty;
    page++
  ) {
    final more = find.text('More calendars');
    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    for (
      var i = 0;
      i < 150 && find.byType(LinearProgressIndicator).evaluate().isNotEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
  await tap('publication-calendar');
  await tester.pumpAndSettle();
  await tester.tap(find.text(destination).last);
  await tester.pump();
  await tap('publication-add');
  await waitFor(find.byKey(const Key('publication-apply')));
  late cal.CalendarIncomingPublicationLinkView link;
  await tester.runAsync(() async {
    link = (await client.modules.serverpod_calendar.calendarIncomingPublication
        .getLink(receipt.entryId))!;
    expect(link.calendarId, calendar);
    expect(link.eventRevision, 1);
    await client.publicationDemo.simulate(
      fixture,
      cal.Uuid().v4obj(),
      1,
      false,
      true,
      'Published UI fixture',
    );
    await client.publicationDemo.simulate(
      fixture,
      cal.Uuid().v4obj(),
      2,
      true,
      true,
      'Published UI fixture',
    );
  });
  await tap('publication-review-refresh');
  await waitFor(find.text('Apply cancellation'));
  await tap('publication-apply');
  for (var i = 0; i < 50; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    if (find.textContaining('Accepted cancellation').evaluate().isNotEmpty) {
      break;
    }
  }
  expect(find.textContaining('Accepted cancellation'), findsOneWidget);
  await tester.runAsync(() async {
    await client.publicationDemo.simulate(
      fixture,
      cal.Uuid().v4obj(),
      3,
      false,
      true,
      'Published UI fixture',
    );
  });
  await tap('publication-review-refresh');
  await waitFor(find.text('Apply publication and reopen'));
  await tap('publication-apply');
  for (var i = 0; i < 50; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    if (find.textContaining('Accepted publication').evaluate().isNotEmpty) {
      break;
    }
  }
  expect(find.textContaining('Accepted publication'), findsOneWidget);
  await tester.runAsync(() async {
    final event = await client.modules.serverpod_calendar.calendarEvent
        .getEvent(link.eventId, cal.CalendarEventFieldGroup.values);
    expect(event.status, cal.CalendarEventStatus.confirmed);
    expect(event.revision, 3);
  });
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tester.pageBack();
  await tester.pumpAndSettle();
}
