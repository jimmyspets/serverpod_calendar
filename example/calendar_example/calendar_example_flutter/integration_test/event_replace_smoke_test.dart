import 'dart:convert';
import 'dart:typed_data';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/main.dart';
import 'package:calendar_example_flutter/event_import_screen.dart';
import 'package:calendar_example_flutter/event_replace_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('event source editor accepts a change after a true no-op', (
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
    await wait(
      tester,
      () => find.byKey(const Key('check')).evaluate().isNotEmpty,
    );
    final calendars = client.modules.serverpod_calendar.calendar;
    final events = client.modules.serverpod_calendar.calendarEvent;
    final parent = (await calendars.create(
      cal.CalendarCreateRequest(
        displayName: 'Focused event replacement',
        availabilityZoneId: 'UTC',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!.calendarId;
    final imported = (await events.importEvents(
      cal.CalendarEventImportRequest(
        calendarId: parent,
        expectedRevision: 1,
        bytes: ByteData.sublistView(
          Uint8List.fromList(
            utf8.encode(
              eventImportExample
                  .replaceAll('\r\n', '\n')
                  .replaceAll('\n', '\r\n'),
            ),
          ),
        ),
      ),
    )).receipts.single;
    try {
      final event = await events.getEvent(
        imported.eventId,
        cal.CalendarEventFieldGroup.values,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: EventReplaceScreen(client: client, event: event),
        ),
      );
      await wait(
        tester,
        () => find.byType(LinearProgressIndicator).evaluate().isEmpty,
      );
      final field = find.byKey(const Key('event-replace-source'));
      await tap(tester, 'event-replace-submit');
      expect(find.text('Identical source; nothing changed.'), findsOneWidget);
      final editor = tester.widget<TextField>(field);
      expect(editor.readOnly, isFalse);
      tester.testTextInput.register();
      addTearDown(tester.testTextInput.unregister);
      final changed = editor.controller!.text.replaceFirst(
        'END:VEVENT',
        'DESCRIPTION:Focused replacement\r\nEND:VEVENT',
      );
      await tester.enterText(field, changed);
      await tester.pump();
      expect(
        tester.widget<TextField>(field).controller!.text,
        contains('DESCRIPTION:Focused replacement'),
      );
      await tap(tester, 'event-replace-submit');
      final error = find.byKey(const Key('event-replace-error'));
      expect(
        error,
        findsNothing,
        reason: error.evaluate().isEmpty
            ? null
            : tester.widget<Text>(error).data,
      );
      expect(find.text('Event replaced.'), findsOneWidget);
      expect(
        (await events.getEvent(
          event.id,
          cal.CalendarEventFieldGroup.values,
        )).description,
        'Focused replacement',
      );
      final exported = await events.exportEvents(
        cal.CalendarEventExportRequest(
          calendarId: parent,
          expectedRevision: 1,
          selection: [
            cal.CalendarEventExportSelection(
              eventId: event.id,
              expectedRevision: 2,
            ),
          ],
        ),
      );
      final metadata = utf8.decode(
        exported.buffer.asUint8List(
          exported.offsetInBytes,
          exported.lengthInBytes,
        ),
      );
      expect(metadata, contains('CLASS:PRIVATE'));
      expect(metadata, contains('urn:source:file'));
      expect(metadata, contains('unresolved-source@example.invalid'));
      expect(metadata, contains('source-attendee@example.invalid'));
      expect(metadata, contains('Synthetic event desk'));
      expect(metadata, contains('CATEGORIES;LANGUAGE=en:Demo,Demo'));
    } finally {
      final event = await events.getEvent(imported.eventId, []);
      await events.deleteEvent(event.id, event.revision);
      await calendars.delete(parent, 1);
    }
  });
}

Future<void> wait(WidgetTester tester, bool Function() ready) async {
  for (var i = 0; i < 150; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    if (ready()) return;
  }
  fail('Event replacement did not become ready');
}

Future<void> tap(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await wait(
    tester,
    () => find.byType(LinearProgressIndicator).evaluate().isEmpty,
  );
}
