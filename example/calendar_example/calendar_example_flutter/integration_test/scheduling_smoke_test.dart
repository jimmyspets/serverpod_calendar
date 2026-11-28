import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

import 'scheduling_journey.dart';
import 'attendee_reply_journey.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('focused organizer scheduling journey', (tester) async {
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
    if (const bool.fromEnvironment('REFRESH_ONLY')) {
      final api = client.modules.serverpod_calendar;
      final calendar = (await api.calendar.create(
        cal.CalendarCreateRequest(
          displayName: 'Synthetic Flutter REFRESH',
          availabilityZoneId: 'Etc/UTC',
          noRuleFallback: cal.CalendarNoRuleFallback.free,
        ),
      ))!;
      await runEventRefreshJourney(tester, client, calendar.calendarId);
    } else {
      await runSchedulingJourney(tester, client);
      await runAttendeeReplyJourney(tester, client);
    }
  });
}
