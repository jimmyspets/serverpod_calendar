import 'dart:convert';
import 'dart:typed_data';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/main.dart';
import 'package:calendar_example_flutter/event_import_screen.dart';
import 'package:calendar_example_flutter/event_occurrence_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'event content editor sets and restores one original without pinning timing',
    (
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
          displayName: 'Focused event content',
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
            home: EventOccurrenceScreen(client: client, event: event),
          ),
        );
        await wait(
          tester,
          () => find.byType(LinearProgressIndicator).evaluate().isEmpty,
        );
        tester.testTextInput.register();
        addTearDown(tester.testTextInput.unregister);
        await tap(tester, 'preview-load');
        final list = find.byType(ListView).last;
        final scrollable = find
            .descendant(of: list, matching: find.byType(Scrollable))
            .first;
        // Locate the actual imported start rather than guessing its date/hour.
        final civil = event.timing!.start;
        final key =
            'event-content-${civil.year}-${civil.month.toString().padLeft(2, '0')}-${civil.day.toString().padLeft(2, '0')}T${civil.hour.toString().padLeft(2, '0')}:${civil.minute.toString().padLeft(2, '0')}:${civil.second.toString().padLeft(2, '0')}';
        final button = find.byKey(Key(key));
        await tester.scrollUntilVisible(
          button,
          200,
          scrollable: scrollable,
          maxScrolls: 30,
        );
        await tap(tester, key);
        await tap(tester, 'event-content-action-summary');
        await tester.tap(find.text('Set own value').last);
        await tester.pump();
        await tester.enterText(
          find.byKey(const Key('event-content-value-summary')),
          'Focused own title',
        );
        await tap(tester, 'event-content-save');
        final saved = await events.getEvent(
          event.id,
          cal.CalendarEventFieldGroup.values,
        );
        expect(saved.timingOverrides!.singles.single.replacement, isNull);
        expect(
          saved.timingOverrides!.singles.single.contentOverrides!.summary,
          'Focused own title',
        );
        await tester.drag(scrollable, const Offset(0, 10000));
        await tester.pump();
        await tester.scrollUntilVisible(
          button,
          200,
          scrollable: scrollable,
          maxScrolls: 30,
        );
        await tap(tester, key);
        await tap(tester, 'event-content-action-summary');
        await tester.tap(find.text('Follow series').last);
        await tester.pump();
        await tap(tester, 'event-content-save');
        expect(
          (await events.getEvent(
            event.id,
            cal.CalendarEventFieldGroup.values,
          )).timingOverrides,
          isNull,
        );
      } finally {
        final event = await events.getEvent(imported.eventId, []);
        await events.deleteEvent(event.id, event.revision);
        await calendars.delete(parent, 1);
      }
    },
  );
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
