import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

void main() {
  testWidgets('empty sign-in stays on form and validates required fields', (
    tester,
  ) async {
    final client = Client('http://localhost:18180/')
      ..authSessionManager = FlutterAuthSessionManager();
    addTearDown(client.close);
    await tester.pumpWidget(CalendarExampleApp(client: client));
    await tester.tap(find.byKey(const Key('sign-in')));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.byKey(const Key('check')), findsNothing);
  });
}
