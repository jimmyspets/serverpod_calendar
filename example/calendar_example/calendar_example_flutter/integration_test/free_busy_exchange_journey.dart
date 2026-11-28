import 'dart:async';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/free_busy_exchange_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runFreeBusyExchangeJourney(
  WidgetTester tester,
  Client client,
) async {
  final module = client.modules.serverpod_calendar;
  final api = module.calendarFreeBusyExchange;
  final calendar = (await module.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Flutter private busy messages',
      availabilityZoneId: 'Europe/Stockholm',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  final event = (await module.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: calendar,
      content: cal.CalendarEventContent(
        summary: 'Private Flutter event text',
        status: cal.CalendarEventStatus.tentative,
        timing: cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: cal.CalendarEventCivil(year: 2030, month: 11, day: 6, hour: 9),
          duration: cal.CalendarEventDuration(hours: 1),
        ),
      ),
    ),
  ))!.eventId;
  final busyQuery = cal.CalendarFreeBusyQuery(
    calendarId: calendar,
    fromUtc: DateTime.utc(2030, 11, 6),
    untilUtc: DateTime.utc(2030, 11, 7),
  );
  final busyBefore = (await module.calendar.freeBusy(busyQuery)).toJson();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  Future<void> idle({bool allowError = false}) async {
    // This screen-level marker stays mounted while the list is scrolled.
    // An offscreen lazy-list spinner cannot establish command completion.
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const Key('freebusy-progress')).evaluate().isEmpty) break;
    }
    expect(find.byKey(const Key('freebusy-progress')), findsNothing);
    if (!allowError) {
      expect(find.byKey(const Key('freebusy-error')), findsNothing);
    }
  }

  Future<void> top() async {
    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(0);
    await tester.pump();
  }

  Future<void> tap(Finder finder, {bool allowError = false}) async {
    // Source inspection/dismissal can rebuild the outgoing command controls.
    // Wait before locating the button as well as after invoking its action.
    await idle(allowError: true);
    await top();
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(finder);
    final control = tester.widget<Widget>(finder);
    if (control is ButtonStyleButton) {
      expect(
        control.onPressed,
        isNotNull,
        reason: 'Command control is disabled',
      );
    }
    await tester.tap(finder);
    await tester.pump();
    await idle(allowError: allowError);
  }

  Future<List<cal.CalendarFreeBusyOutgoingView>> outgoing() async {
    final items = <cal.CalendarFreeBusyOutgoingView>[];
    String? cursor;
    do {
      final page = await api.listFreeBusyOutgoing(pageSize: 50, cursor: cursor);
      items.addAll(page.items);
      cursor = page.cursor;
    } while (cursor != null);
    return items;
  }

  Future<List<cal.CalendarFreeBusyMessageView>> incoming() async {
    final items = <cal.CalendarFreeBusyMessageView>[];
    String? cursor;
    do {
      final page = await api.listFreeBusyInbox(pageSize: 50, cursor: cursor);
      items.addAll(page.items);
      cursor = page.cursor;
    } while (cursor != null);
    return items;
  }

  try {
    unawaited(
      navigator.push<void>(
        MaterialPageRoute(
          builder: (_) =>
              FreeBusyExchangeScreen(client: client, calendarId: calendar),
        ),
      ),
    );
    await tester.pump();
    await idle();
    await tester.enterText(
      find.byKey(const Key('freebusy-from')),
      '2030-11-06T00:00:00.000000001Z',
    );
    await tester.enterText(
      find.byKey(const Key('freebusy-until')),
      '2030-11-07T00:00:00Z',
    );
    await tap(find.byKey(const Key('freebusy-publish')), allowError: true);
    expect(find.byKey(const Key('freebusy-error')), findsOneWidget);
    await top();
    await tester.enterText(
      find.byKey(const Key('freebusy-from')),
      '2030-11-06T00:00:00.00000Z',
    );
    final before = (await outgoing()).map((v) => v.id).toSet();
    await tap(find.byKey(const Key('freebusy-publish')));
    final published = (await outgoing())
        .where((v) => !before.contains(v.id))
        .single;
    expect(published.method, 'publish');
    await tap(find.byKey(Key('freebusy-activity-${published.id}')));
    final deliveryKey = Key(
      'freebusy-delivery-${(await api.freeBusyDeliveryActivity(published.id, pageSize: 50)).items.single.id}',
    );
    await top();
    await tester.scrollUntilVisible(
      find.byKey(deliveryKey),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(deliveryKey), findsOneWidget);

    final prior = (await outgoing()).map((v) => v.id).toSet();
    await tap(find.byKey(const Key('freebusy-request')));
    final requested = (await outgoing())
        .where((v) => !prior.contains(v.id))
        .single;
    expect(requested.method, 'request');
    final beforeReply = (await incoming()).map((v) => v.id).toSet();
    await tap(
      find.descendant(
        of: find.byKey(Key('freebusy-command-${requested.id}')),
        matching: find.text('Simulate respondent report'),
      ),
    );
    expect(
      (await incoming())
          .where((v) => !beforeReply.contains(v.id))
          .single
          .method,
      'reply',
    );

    final beforePublish = (await incoming()).map((v) => v.id).toSet();
    await tap(find.byKey(const Key('freebusy-simulate-publish')));
    expect(
      (await incoming())
          .where((v) => !beforePublish.contains(v.id))
          .single
          .method,
      'publish',
    );
    final beforeRequest = (await incoming()).map((v) => v.id).toSet();
    await tap(find.byKey(const Key('freebusy-simulate-request')));
    final request = (await incoming()).singleWhere(
      (v) => !beforeRequest.contains(v.id),
    );
    expect(request.method, 'request');
    expect(request.isCurrent, isTrue);
    expect(request.replyRevision, 0);
    await tap(find.byKey(Key('freebusy-share-${request.id}')));
    expect((await api.getFreeBusyMessage(request.id)).replyRevision, 1);
    // A second reply uses a later actual database second, never an invented
    // future stamp. Wait outside the fake widget clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tap(find.byKey(Key('freebusy-refuse-${request.id}')));
    expect((await api.getFreeBusyMessage(request.id)).replyRevision, 2);
    await tap(
      find.descendant(
        of: find.byKey(Key('freebusy-source-${request.id}')),
        matching: find.text('View iCalendar source'),
      ),
    );
    await top();
    await tester.scrollUntilVisible(
      find.byKey(const Key('freebusy-source-text')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final sourceText = tester
        .widget<SelectableText>(find.byKey(const Key('freebusy-source-text')))
        .data!;
    expect(sourceText, contains('BEGIN:VFREEBUSY'));
    expect(sourceText, isNot(contains('Private Flutter event text')));
    expect(sourceText, isNot(contains(calendar.toString())));
    expect(sourceText, isNot(contains(event.toString())));
    await tap(
      find.descendant(
        of: find.byKey(Key('freebusy-source-${request.id}')),
        matching: find.text('Dismiss'),
      ),
    );
    final dismissed = await api.getFreeBusyMessage(request.id);
    expect(dismissed.dismissedAt, isNotNull);
    expect(dismissed.isCurrent, isTrue);
    expect(dismissed.replyRevision, 2);
    await tap(find.byKey(Key('freebusy-withdraw-${requested.id}')));
    expect(
      (await api.freeBusyDeliveryActivity(
        requested.id,
        pageSize: 50,
      )).items.single.state,
      anyOf('withdrawn', 'accepted'),
    ); // Already accepted mail cannot be recalled.
    expect((await module.calendar.freeBusy(busyQuery)).toJson(), busyBefore);
    expect(
      (await module.calendar.getCalendar(
        calendar,
        cal.CalendarFieldGroup.values,
      )).revision,
      1,
    );
    expect(
      (await module.calendarEvent.getEvent(
        event,
        cal.CalendarEventFieldGroup.values,
      )).revision,
      1,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
  } finally {
    await module.calendarEvent.deleteEvent(event, 1);
    await module.calendar.delete(calendar, 1);
  }
}
