import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:serverpod_calendar_feed_client/serverpod_calendar_feed_client.dart'
    as feed;

Future<void> _wait(WidgetTester tester, bool Function() ready) async {
  for (var i = 0; i < 120; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (ready()) return;
  }
  fail('Feed journey did not reach its expected UI state');
}

Future<void> _idle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
  await _wait(
    tester,
    () =>
        find.byType(AlertDialog).evaluate().isNotEmpty ||
        find.byType(LinearProgressIndicator).evaluate().isEmpty,
  );
}

Future<void> _tap(WidgetTester tester, String key) async {
  await _idle(tester);
  // Route completion can start its parent's reload. Yield real I/O before
  // locating the next control; settling an active spinner can starve that I/O.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await _idle(tester);
  final target = find.byKey(Key(key));
  if (target.evaluate().isEmpty) {
    final scrollable = find
        .descendant(
          of: find.byType(Scaffold).first,
          matching: find.byType(Scrollable),
        )
        .first;
    tester.state<ScrollableState>(scrollable).position.jumpTo(0);
    await tester.pump();
    try {
      await tester.scrollUntilVisible(
        target,
        300,
        scrollable: scrollable,
        maxScrolls: 100,
      );
    } on StateError {
      final bar = tester.widget<AppBar>(find.byType(AppBar).first);
      final title = bar.title is Text ? (bar.title! as Text).data : 'feed page';
      fail('Feed journey could not display control $key on $title');
    }
  }
  await tester.ensureVisible(target);
  final widget = tester.widget(target);
  if (widget is ButtonStyleButton) expect(widget.onPressed, isNotNull);
  await tester.tap(target);
  await _idle(tester);
}

/// Shared focused/full browser journey; all fixture data is synthetic.
Future<void> runFeedJourney(WidgetTester tester, Client client) async {
  final priorError = FlutterError.onError;
  FlutterError.onError = (details) {
    final safe = details.exceptionAsString().replaceAll(
      RegExp(r'/calendar-feed/[A-Za-z0-9_-]{43}\.ics'),
      '/calendar-feed/[redacted].ics',
    );
    debugPrint('FEED_TEST_ERROR: $safe');
    priorError?.call(details);
  };
  final calendars = client.modules.serverpod_calendar.calendar;
  final manager = client.modules.serverpod_calendar_feed.calendarFeed;
  final source = (await calendars.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic Flutter feed source',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  final label =
      'Synthetic Flutter subscription ${source.calendarId.toString().substring(0, 8)}';
  feed.CalendarFeedView? created;
  var completed = false;
  try {
    await _tap(tester, 'open-feeds');
    await _tap(tester, 'feed-create');
    await tester.enterText(find.byKey(const Key('feed-name')), label);
    for (
      var page = 0;
      page < 40 &&
          find
              .byKey(Key('feed-calendar-${source.calendarId}'))
              .evaluate()
              .isEmpty;
      page++
    ) {
      await _tap(tester, 'feed-more-calendars');
    }
    await _tap(tester, 'feed-calendar-${source.calendarId}');
    final tile = find.text('Publication text and color');
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await _tap(tester, 'protocol-copy-name');
    await _tap(tester, 'feed-save');
    created = (await manager.list()).singleWhere((v) => v.displayName == label);
    expect(created.protocolMetadata!.names.single.value, label);
    expect(
      (await calendars.getCalendar(source.calendarId, [
        cal.CalendarFieldGroup.metadata,
      ])).displayName,
      'Synthetic Flutter feed source',
    );
    await _tap(tester, 'feed-urls-${created.id}');
    await _tap(tester, 'feed-url-create');
    await tester.enterText(
      find.byKey(const Key('feed-url-label')),
      'Synthetic subscriber',
    );
    await _tap(tester, 'feed-url-confirm');
    await _wait(
      tester,
      () => find.byKey(const Key('feed-created-url')).evaluate().isNotEmpty,
    );
    final url = tester
        .widget<SelectableText>(find.byKey(const Key('feed-created-url')))
        .data!;
    expect(Uri.parse(url).path, startsWith('/calendar-feed/'));
    await _tap(tester, 'feed-url-close');
    await _wait(
      tester,
      () =>
          find.byType(AlertDialog).evaluate().isEmpty &&
          find.byType(LinearProgressIndicator).evaluate().isEmpty,
    );
    expect(find.byKey(const Key('feed-created-url')), findsNothing);
    expect(find.text(url), findsNothing);
    final credential = (await manager.credentials(created.id)).single;
    await _tap(tester, 'feed-revoke-${credential.id}');
    await _tap(tester, 'feed-confirm-revoke');
    await _wait(tester, () => find.text('Revoked').evaluate().isNotEmpty);
    expect((await manager.credentials(created.id)).single.revokedAt, isNotNull);
    await tester.pageBack();
    await _idle(tester);
    await _tap(tester, 'feed-edit-${created.id}');
    final before = await manager.read(created.id);
    await manager.update(
      before.id,
      before.revision,
      feed.CalendarFeedSettings(
        displayName: 'Changed through another client',
        calendarIds: before.calendarIds,
        protocolMetadata: before.protocolMetadata,
        supplementalMetadata: before.supplementalMetadata,
      ),
    );
    await tester.enterText(
      find.byKey(const Key('feed-name')),
      'Stale UI change',
    );
    await _tap(tester, 'feed-save');
    await _wait(
      tester,
      () => find.byKey(const Key('feed-error')).evaluate().isNotEmpty,
    );
    expect(
      (await manager.read(created.id)).displayName,
      'Changed through another client',
    );
    final reload = find.text('Reload saved settings');
    await tester.ensureVisible(reload);
    await tester.tap(reload);
    await _idle(tester);
    await tester.enterText(
      find.byKey(const Key('feed-name')),
      'Renamed Flutter subscription',
    );
    await _tap(tester, 'feed-save');
    expect(find.byKey(const Key('feed-error')), findsNothing);
    final renamed = await manager.read(created.id);
    expect(renamed.displayName, 'Renamed Flutter subscription');
    expect(renamed.protocolUid, created.protocolUid);
    expect(renamed.protocolMetadata!.names.single.value, label);
    await _tap(tester, 'feed-edit-${created.id}');
    await _tap(tester, 'feed-delete');
    await _tap(tester, 'feed-confirm-delete');
    await _wait(
      tester,
      () =>
          find.byKey(const Key('feed-create')).evaluate().isNotEmpty &&
          find.byType(LinearProgressIndicator).evaluate().isEmpty,
    );
    expect((await manager.list()).where((v) => v.id == created!.id), isEmpty);
    await tester.pageBack();
    await _idle(tester);
    completed = true;
  } finally {
    FlutterError.onError = priorError;
    try {
      for (final value in await manager.list()) {
        if (value.id == created?.id ||
            value.calendarIds.contains(source.calendarId)) {
          await manager.delete(value.id, value.revision);
        }
      }
      await calendars.delete(source.calendarId, source.revision);
    } catch (_) {
      if (completed) rethrow;
      debugPrint(
        'Feed fixture cleanup failed; preserving the original test failure.',
      );
    }
  }
}
