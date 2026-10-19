import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('real host sign-in, generated module calls and sign-out', (
    tester,
  ) async {
    const password = String.fromEnvironment('DEMO_PASSWORD');
    expect(
      password,
      isNotEmpty,
      reason: 'Pass --dart-define-from-file=.local/test_defines.json',
    );
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
    await tester.enterText(find.byKey(const Key('password')), password);
    await tester.tap(find.byKey(const Key('sign-in')));
    await _waitFor(tester, find.byKey(const Key('check')));
    await tester.tap(find.byKey(const Key('check')));
    await _waitFor(tester, find.byKey(const Key('result')));
    expect(
      find.textContaining('Connected: host, calendar and notifications'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('sign-out')));
    await _waitFor(tester, find.byKey(const Key('sign-in')));
    expect(find.byKey(const Key('result')), findsNothing);
  });
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 120; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
  }
  fail('Timed out waiting for $finder');
}
