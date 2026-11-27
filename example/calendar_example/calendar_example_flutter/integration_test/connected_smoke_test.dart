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
    final label = 'Flutter ${DateTime.now().microsecondsSinceEpoch}';
    final renamedLabel = '$label renamed';
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
    await _tap(tester, 'open-calendars');
    await _tap(tester, 'calendar-create');
    await tester.enterText(
      find.byKey(const Key('calendar-name')),
      label,
    );
    await _tap(tester, 'calendar-submit-create');
    await _waitFor(tester, find.text(label));
    await tester.tap(find.text(label));
    await _idle(tester);
    await tester.enterText(
      find.byKey(const Key('calendar-name')),
      renamedLabel,
    );
    await _tap(tester, 'calendar-save-name');
    await tester.enterText(find.byKey(const Key('calendar-zone')), 'UTC');
    await _tap(tester, 'calendar-save-settings');
    expect(find.text('UTC'), findsOneWidget);
    await _tap(tester, 'calendar-attach-self');
    await _tap(tester, 'calendar-delete');
    await _tap(tester, 'calendar-confirm-delete');
    expect(find.byKey(const Key('calendar-error')), findsOneWidget);
    await _tap(tester, 'calendar-detach');
    await _tap(tester, 'calendar-delete');
    await _tap(tester, 'calendar-confirm-delete');
    expect(find.text(renamedLabel), findsNothing);
    await tester.pageBack();
    await _idle(tester);
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

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  await _waitFor(tester, finder);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await _idle(tester, step: key);
}

Future<void> _idle(WidgetTester tester, {String step = 'calendar'}) async {
  await tester.pump(const Duration(milliseconds: 300));
  for (var i = 0; i < 120; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(AlertDialog).evaluate().isNotEmpty ||
        find.byType(LinearProgressIndicator).evaluate().isEmpty) {
      return;
    }
  }
  fail('Calendar request did not become idle: $step');
}
