import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
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
    await tester.enterText(
      find.byKey(const Key('calendar-description')),
      '  Native notes\n',
    );
    await tester.enterText(find.byKey(const Key('calendar-color')), '#a0b1c2');
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
    expect(find.text('#A0B1C2'), findsOneWidget);
    await _tap(tester, 'protocol-name-add');
    await tester.enterText(
      find.byKey(const Key('protocol-name-language-0')),
      'sv',
    );
    await tester.enterText(
      find.byKey(const Key('protocol-name-value-0')),
      'Protocol Swedish',
    );
    await _tap(tester, 'protocol-copy-name');
    await _tap(tester, 'protocol-copy-description');
    await tester.enterText(find.byKey(const Key('protocol-color')), 'red');
    await _tap(tester, 'protocol-save');
    final saved = await client.modules.serverpod_calendar.calendar.list(
      pageSize: 25,
      fieldGroups: cal.CalendarFieldGroup.values,
    );
    final calendar = saved.calendars.singleWhere(
      (v) => v.displayName == renamedLabel,
    );
    expect(calendar.protocolMetadata!.names.length, 2);
    expect(calendar.protocolMetadata!.names.first.value, renamedLabel);
    expect(calendar.protocolMetadata!.names.last.value, 'Protocol Swedish');
    expect(calendar.protocolMetadata!.names.last.language, 'sv');
    expect(
      calendar.protocolMetadata!.descriptions.single.value,
      '  Native notes\n',
    );
    expect(calendar.protocolMetadata!.color, 'red');
    expect(calendar.color, '#A0B1C2');
    // Another native edit must retain saved protocol text and color.
    await tester.enterText(
      find.byKey(const Key('calendar-description')),
      'Changed native description',
    );
    await _tap(tester, 'calendar-save-name');
    final retained = await client.modules.serverpod_calendar.calendar
        .getCalendar(calendar.id, cal.CalendarFieldGroup.values);
    expect(retained.description, 'Changed native description');
    expect(
      retained.protocolMetadata!.descriptions.single.value,
      '  Native notes\n',
    );
    await client.modules.serverpod_calendar.calendar.updateProtocolMetadata(
      cal.CalendarProtocolMetadataUpdateRequest(
        calendarId: calendar.id,
        expectedRevision: retained.revision,
        metadata: cal.CalendarProtocolMetadata(
          names: retained.protocolMetadata!.names,
          descriptions: [cal.CalendarTextVariant(value: 'External change')],
          color: 'blue',
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('calendar-description')),
      'Stale draft',
    );
    await _tap(tester, 'calendar-save-name');
    expect(find.byKey(const Key('calendar-error')), findsOneWidget);
    final afterConflict = await client.modules.serverpod_calendar.calendar
        .getCalendar(calendar.id, cal.CalendarFieldGroup.values);
    expect(afterConflict.description, 'Changed native description');
    expect(
      afterConflict.protocolMetadata!.descriptions.single.value,
      'External change',
    );
    await _tap(tester, 'calendar-reload');
    expect(find.text('External change'), findsOneWidget);
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
