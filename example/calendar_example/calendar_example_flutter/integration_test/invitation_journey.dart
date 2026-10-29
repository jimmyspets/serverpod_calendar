import 'invitation_adoption_journey.dart';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/invitation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runInvitationJourney(WidgetTester tester, Client client) async {
  final api = client.modules.serverpod_calendar.calendarInvitation;
  final id = const cal.Uuid().v4obj(), command = const cal.Uuid().v4obj();
  final receipt = await client.invitationDemo.simulate(
    id,
    command,
    null,
    'Synthetic invitation review',
  );
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  Future<void> loaded() async {
    for (var n = 0; n < 150; n++) {
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
    expect(
      find.byKey(ValueKey('invitation-${receipt.entryId}')),
      findsOneWidget,
    );
    expect(find.text('Synthetic invitation review'), findsOneWidget);
    expect(
      find.byKey(ValueKey('invitation-add-${receipt.entryId}')),
      findsOneWidget,
    );
    await tap(find.byKey(ValueKey('invitation-source-${receipt.entryId}')));
    await tap(find.byKey(ValueKey('invitation-history-${receipt.sourceId}')));
    final document = tester
        .widget<SelectableText>(find.byKey(const Key('invitation-document')))
        .data!;
    expect(document, contains('METHOD:REQUEST'));
    expect(document, isNot(contains('SEQUENCE:')));
    navigator.pop();
    await tester.pumpAndSettle();
    await client.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      1,
      'Updated invitation review',
    );
    await tap(find.byKey(ValueKey('invitation-dismiss-${receipt.entryId}')));
    expect(find.byKey(const Key('invitation-error')), findsOneWidget);
    expect((await api.getInvitation(receipt.entryId)).dismissedAt, isNull);
    await tap(find.byKey(const Key('invitations-refresh')));
    expect(find.byKey(const Key('invitation-error')), findsNothing);
    expect(find.text('Updated invitation review'), findsOneWidget);
    await tap(find.byKey(ValueKey('invitation-cancel-${receipt.entryId}')));
    expect(find.text('Meeting cancellation notice'), findsOneWidget);
    expect(find.text('No start time supplied.'), findsOneWidget);
    expect(
      find.text('Review only. The calendar event is unchanged.'),
      findsOneWidget,
    );
    final cancellation = await api.getInvitation(receipt.entryId);
    expect(
      cancellation.kind,
      cal.CalendarInvitationSourceKind.meetingCancellation,
    );
    expect(cancellation.timing, isNull);
    await tap(find.byKey(ValueKey('invitation-source-${receipt.entryId}')));
    await tap(
      find.byKey(ValueKey('invitation-history-${cancellation.sourceId}')),
    );
    expect(
      tester
          .widget<SelectableText>(find.byKey(const Key('invitation-document')))
          .data,
      contains('METHOD:CANCEL'),
    );
    navigator.pop();
    await tester.pumpAndSettle();
    await tap(find.byKey(ValueKey('invitation-dismiss-${receipt.entryId}')));
    expect(find.byKey(ValueKey('invitation-${receipt.entryId}')), findsNothing);
    final retained = await client.invitationDemo.simulate(
      id,
      command,
      null,
      'Synthetic invitation review',
    );
    expect(retained.id, receipt.id);
    expect((await api.getInvitation(receipt.entryId)).dismissedAt, isNotNull);
    navigator.pop();
    await tester.pumpAndSettle();
  } finally {
    final current = await api.getInvitation(receipt.entryId);
    if (current.dismissedAt == null) {
      await api.dismiss(current.id, current.revision);
    }
  }
  await runInvitationAdoptionJourney(tester, client);
}
