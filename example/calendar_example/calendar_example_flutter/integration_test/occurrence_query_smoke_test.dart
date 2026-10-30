import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'occurrence_query_journey.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('focused calendar-wide occurrence queries', (
    tester,
  ) async {
    final client = Client(
      const String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost:18180/',
      ),
    )..authSessionManager = FlutterAuthSessionManager();
    addTearDown(client.close);
    await tester.pumpWidget(CalendarExampleApp(client: client));
    await tester.enterText(
      find.byKey(const Key('email')),
      const String.fromEnvironment('DEMO_EMAIL'),
    );
    await tester.enterText(
      find.byKey(const Key('password')),
      const String.fromEnvironment('DEMO_PASSWORD'),
    );
    await tester.tap(find.byKey(const Key('sign-in')));
    for (
      var i = 0;
      i < 150 && find.byKey(const Key('check')).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('check')), findsOneWidget);
    tester.testTextInput.register();
    addTearDown(tester.testTextInput.unregister);
    await runOccurrenceQueryJourney(tester, client);
  });
}
