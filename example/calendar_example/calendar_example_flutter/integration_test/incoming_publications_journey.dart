import 'dart:async';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/incoming_publications_screen.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> runIncomingPublicationJourney(
  WidgetTester tester,
  Client client, {
  bool fromHome = false,
  bool bundled = false,
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

  Future<void> show(String key) async {
    debugPrint('Publication ${bundled ? "bundle" : "master"} journey: $key');
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
    await tester.pumpAndSettle();
    final finder = find.byKey(Key(key));
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      return;
    }
    final scrollable = find.byType(Scrollable).first;
    tester.state<ScrollableState>(scrollable).position.jumpTo(0);
    await tester.pump();
    try {
      await tester.scrollUntilVisible(
        finder,
        300,
        scrollable: scrollable,
        maxScrolls: 100,
      );
    } on StateError {
      fail('Publication journey could not display control $key');
    }
  }

  Future<void> tap(String key) async {
    await show(key);
    final finder = find.byKey(Key(key));
    final widget = tester.widget(finder);
    if (widget is ButtonStyleButton) expect(widget.onPressed, isNotNull);
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
      bundled: bundled,
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
  if (bundled) {
    expect(find.byKey(const Key('publication-bundle')), findsOneWidget);
  }
  await tap('publication-source');
  await waitFor(find.byKey(const Key('publication-source-text')));
  expect(find.textContaining('UID:synthetic-publication:'), findsOneWidget);
  for (var page = 0; page < 20; page++) {
    await show('publication-calendar');
    final dropdown = tester.widget<DropdownButton<cal.UuidValue>>(
      find.descendant(
        of: find.byKey(const Key('publication-calendar')),
        matching: find.byType(DropdownButton<cal.UuidValue>),
      ),
    );
    if (dropdown.items!.any((item) => item.value == calendar)) break;
    await tap('publication-more-calendars');
  }
  await tap('publication-calendar');
  await tester.pumpAndSettle();
  try {
    await tester.scrollUntilVisible(
      find.text(destination),
      200,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 100,
    );
  } on StateError {
    fail('Publication destination menu did not expose its loaded calendar');
  }
  await tester.tap(find.text(destination).last);
  await tester.pump();
  await tap('publication-add');
  await waitFor(find.byKey(const Key('publication-apply')));
  late cal.CalendarIncomingPublicationLinkView link;
  Future<cal.CalendarIncomingPublicationLinkView> currentLink() async => bundled
      ? (await client.modules.serverpod_calendar.calendarIncomingPublication
                .getBundleLink(receipt.entryId))!
            .link
      : (await client.modules.serverpod_calendar.calendarIncomingPublication
            .getLink(receipt.entryId))!;
  await tester.runAsync(() async {
    link = await currentLink();
    expect(link.calendarId, calendar);
    expect(link.eventRevision, 1);
  });
  if (bundled) {
    await tester.runAsync(() async {
      await client.publicationDemo.simulate(
        fixture,
        cal.Uuid().v4obj(),
        0,
        false,
        true,
        'Published UI fixture',
        bundled: true,
        occurrenceSequence: 1,
      );
    });
    await tap('publication-review-refresh');
    await waitFor(find.text('Apply update'));
    await tap('publication-apply');
    await tap('publication-source');
    await waitFor(find.byKey(const Key('publication-source-text')));
    await tester.runAsync(() async {
      final saved = (await client
          .modules
          .serverpod_calendar
          .calendarIncomingPublication
          .getBundleLink(receipt.entryId))!;
      expect(saved.link.eventRevision, 2);
      expect(saved.acceptedComponentVersions!.map((v) => v.sequence), [0, 1]);
    });
  }
  await tester.runAsync(() async {
    await client.publicationDemo.simulate(
      fixture,
      cal.Uuid().v4obj(),
      1,
      false,
      true,
      'Published UI fixture',
      bundled: bundled,
    );
    await client.publicationDemo.simulate(
      fixture,
      cal.Uuid().v4obj(),
      2,
      true,
      true,
      'Published UI fixture',
      bundled: bundled,
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
      bundled: bundled,
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
    expect(event.revision, bundled ? 4 : 3);
  });
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tester.pageBack();
  await tester.pumpAndSettle();
}
