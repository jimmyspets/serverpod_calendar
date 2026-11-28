import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/invitation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runRangeInvitationJourney(
  WidgetTester tester,
  Client client,
) async {
  final id = const cal.Uuid().v4obj();
  final master = await client.invitationDemo.simulateRecurring(
    id,
    const cal.Uuid().v4obj(),
    null,
    'Range journey basis',
  );
  cal.CalendarInvitationView? instance;
  final api = client.modules.serverpod_calendar.calendarInvitation;
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
  }

  Future<void> tap(Finder target) async {
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pump();
    await loaded();
  }

  try {
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => InvitationScreen(client: client)),
    );
    await tester.pumpAndSettle();
    await loaded();
    await tap(find.byKey(ValueKey('invitation-range-${master.entryId}')));
    final uid = (await api.getInvitation(master.entryId)).uid;
    instance = (await api.list()).singleWhere(
      (v) => v.uid == uid && v.isThisAndFuture,
    );
    expect(find.text('This and future update notice'), findsOneWidget);
    expect(
      find.byKey(ValueKey('invitation-response-${instance.id}')),
      findsNothing,
    );
    expect(instance.isThisAndFuture, isTrue);
    expect(
      find.byKey(ValueKey('invitation-occurrence-apply-view-${instance.id}')),
      findsNothing,
    );
    expect(find.byKey(ValueKey('invitation-add-${instance.id}')), findsNothing);
    await tap(find.byKey(ValueKey('invitation-source-${instance.id}')));
    await tap(find.byKey(ValueKey('invitation-history-${instance.sourceId}')));
    expect(
      tester
          .widget<SelectableText>(find.byKey(const Key('invitation-document')))
          .data,
      contains('RECURRENCE-ID;RANGE=THISANDFUTURE:20300103T090000Z'),
    );
    navigator.pop();
    await tester.pumpAndSettle();
    await tap(find.byKey(ValueKey('invitation-range-${instance.id}')));
    expect(find.text('This and future cancellation notice'), findsOneWidget);
    final current = await api.getInvitation(instance.id);
    expect(current.timing, isNull);
    expect(current.originalStart!.start.day, 3);
    await tap(find.byKey(ValueKey('invitation-dismiss-${instance.id}')));
    expect(find.byKey(ValueKey('invitation-${instance.id}')), findsNothing);
    expect((await api.getInvitation(master.entryId)).revision, 1);
    navigator.pop();
    await tester.pumpAndSettle();
  } finally {
    for (final entry in [master.entryId, if (instance != null) instance.id]) {
      final current = await api.getInvitation(entry);
      if (current.dismissedAt == null) {
        await api.dismiss(entry, current.revision);
      }
    }
  }
}
