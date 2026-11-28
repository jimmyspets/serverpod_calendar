import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/invitation_bundle_occurrence_response_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runBundleOccurrenceResponseJourney(
  WidgetTester tester,
  Client client,
) async {
  final api = client.modules.serverpod_calendar.calendarInvitation;
  final source = await client.invitationDemo.simulateBundle(
    const cal.Uuid().v4obj(),
    const cal.Uuid().v4obj(),
    2,
    'Select an original without adoption',
  );
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  Future<void> loaded() async {
    for (var i = 0; i < 150; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(LinearProgressIndicator).evaluate().isEmpty) break;
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.pumpAndSettle();
  }

  Future<void> tap(Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    expect(target.hitTestable(), findsOneWidget);
    await tester.tap(target);
    await tester.pump();
    await loaded();
  }

  try {
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => InvitationBundleOccurrenceResponseScreen(
          client: client,
          id: source.entryId,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await loaded();
    for (final (day, sequence) in [(1, 2), (3, null), (5, 12)]) {
      await tester.enterText(
        find.byKey(const Key('bundle-occurrence-date')),
        '2030-01-${day.toString().padLeft(2, '0')}',
      );
      await tap(find.byKey(const Key('bundle-occurrence-check')));
      expect(find.byKey(const Key('bundle-occurrence-error')), findsNothing);
      expect(
        find.text(
          'Effective invitation SEQUENCE: ${sequence?.toString() ?? 'omitted'}',
        ),
        findsOneWidget,
      );
      await tap(find.byKey(const Key('bundle-occurrence-open')));
      expect(find.byKey(const Key('response-original')), findsOneWidget);
      expect(
        find.byKey(const Key('response-effective-version')),
        findsOneWidget,
      );
      expect(find.text('Response revision: 0'), findsOneWidget);
      await tester.tap(find.byKey(const Key('response-choice')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('accepted').last);
      await tester.pumpAndSettle();
      await tap(find.byKey(const Key('response-send')));
      expect(find.byKey(const Key('response-error')), findsNothing);
      expect(find.text('Response revision: 1'), findsOneWidget);
      final original = cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.utc,
        start: cal.CalendarEventCivil(year: 2030, month: 1, day: day, hour: 9),
      );
      final first = (await api.bundleOccurrenceResponseActivity(
        source.entryId,
        original,
      )).single;
      expect(first.sourceSequence, sequence);
      await tap(find.byKey(const Key('response-send')));
      expect(
        (await api.bundleOccurrenceResponseActivity(
          source.entryId,
          original,
        )).single.id,
        first.id,
      );
      expect((await api.bundleResponse(source.entryId)).revision, 0);
      expect(await api.link(source.entryId), isNull);
      navigator.pop();
      await tester.pumpAndSettle();
    }
    navigator.pop();
    await tester.pumpAndSettle();
  } finally {
    final current = await api.getInvitation(source.entryId);
    if (current.dismissedAt == null) {
      await api.dismiss(current.id, current.revision);
    }
  }
}
