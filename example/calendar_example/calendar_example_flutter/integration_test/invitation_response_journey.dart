import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/invitation_response_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runInvitationResponseJourney(
  WidgetTester tester,
  Client client, {
  bool recurring = false,
}) async {
  final simulate = recurring
      ? client.invitationDemo.simulateRecurring
      : client.invitationDemo.simulate;
  final api = client.modules.serverpod_calendar.calendarInvitation;
  final id = const cal.Uuid().v4obj();
  final incoming = await simulate(
    id,
    const cal.Uuid().v4obj(),
    null,
    'Respond without adoption',
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
  }

  Future<void> tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
    await loaded();
  }

  try {
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) =>
            InvitationResponseScreen(client: client, id: incoming.entryId),
      ),
    );
    await tester.pumpAndSettle();
    await loaded();
    if (recurring) {
      expect(
        find.text(
          'Recurring series: this response applies to the whole series.',
        ),
        findsOneWidget,
      );
    }
    expect(find.text('Response revision: 0'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('response-send')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('response-choice')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('declined').last);
    await tester.pumpAndSettle();
    await tap(find.byKey(const Key('response-send')));
    expect(find.byKey(const Key('response-error')), findsNothing);
    expect(find.byKey(const Key('response-receipt')), findsOneWidget);
    expect(find.text('Response revision: 1'), findsOneWidget);
    final first = (await api.responseActivity(incoming.entryId)).single;
    expect(first.choice, cal.CalendarInvitationResponseChoice.declined);
    expect(await api.link(incoming.entryId), isNull);
    expect((await api.getInvitation(incoming.entryId)).dismissedAt, isNull);
    // Retried UI commands retain their original identity, including across a
    // newer source; refreshing does not implicitly create another response.
    await tap(find.byKey(const Key('response-send')));
    expect((await api.responseActivity(incoming.entryId)).single.id, first.id);
    await simulate(
      id,
      const cal.Uuid().v4obj(),
      1,
      'New source needs a new decision',
    );
    await tap(find.byKey(const Key('response-refresh')));
    expect(
      find.text('Historical response; it does not accept the current source.'),
      findsOneWidget,
    );
    await tap(find.byKey(const Key('response-send')));
    expect(find.byKey(const Key('response-error')), findsNothing);
    expect((await api.responseActivity(incoming.entryId)).single.id, first.id);
    await tap(find.byKey(const Key('response-another')));
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('response-send')))
          .onPressed,
      isNull,
    );
    navigator.pop();
    await tester.pumpAndSettle();
  } finally {
    final current = await api.getInvitation(incoming.entryId);
    await api.dismiss(current.id, current.revision);
  }
}
