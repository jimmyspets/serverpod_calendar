import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/event_descriptive_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runEventDescriptiveJourney(
  WidgetTester tester,
  Client client,
) async {
  final api = client.modules.serverpod_calendar;
  final parent = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic descriptive editor',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  final event = (await api.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: parent.calendarId,
      content: cal.CalendarEventContent(
        summary: 'Descriptive fixture',
        timing: cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: cal.CalendarEventCivil(year: 2030, month: 1, day: 1, hour: 9),
        ),
      ),
    ),
  ))!;
  try {
    final view = await api.calendarEvent.getEvent(
      event.eventId,
      cal.CalendarEventFieldGroup.values,
    );
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => EventDescriptiveEditor(client: client, event: view),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> tap(String key) async {
      final target = find.byKey(Key(key));
      if (target.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          target,
          200,
          scrollable: find
              .descendant(
                of: find.byType(ListView).last,
                matching: find.byType(Scrollable),
              )
              .first,
          maxScrolls: 20,
        );
      }
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await tester.enterText(find.byKey(const Key('event-priority')), '0');
    await tester.enterText(
      find.byKey(const Key('event-latitude')),
      '90.000000000000000001',
    );
    await tester.enterText(
      find.byKey(const Key('event-longitude')),
      '-000.000',
    );
    await tap('event-descriptive-save');
    for (
      var i = 0;
      i < 100 &&
          find.byKey(const Key('event-descriptive-error')).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
    expect(find.byKey(const Key('event-descriptive-error')), findsOneWidget);
    expect(
      (await api.calendarEvent.getEvent(
        event.eventId,
        cal.CalendarEventFieldGroup.values,
      )).revision,
      1,
    );
    await tester.ensureVisible(find.byKey(const Key('event-latitude')));
    await tester.enterText(
      find.byKey(const Key('event-latitude')),
      '+090.000000000000000000',
    );
    await tap('event-resource-add');
    await tester.enterText(
      find.byKey(const Key('event-resource-value-0-0')),
      'Room\nDesk',
    );
    await tap('event-resource-label-add-0');
    await tap('event-resource-label-add-0');
    await tester.enterText(
      find.byKey(const Key('event-resource-value-0-2')),
      'Room',
    );
    await tester.enterText(
      find.byKey(const Key('event-resource-language-0')),
      'en',
    );
    await tester.enterText(
      find.byKey(const Key('event-resource-alternative-0')),
      'cid:labels@example.invalid',
    );
    await tap('event-descriptive-save');
    for (
      var i = 0;
      i < 150 && find.byType(EventDescriptiveEditor).evaluate().isNotEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(EventDescriptiveEditor), findsNothing);
    final saved = await api.calendarEvent.getEvent(
      event.eventId,
      cal.CalendarEventFieldGroup.values,
    );
    expect(saved.priority, 0);
    expect(saved.geographicPosition!.latitudeText, '+090.000000000000000000');
    expect(saved.resourceGroups!.single.values, ['Room\nDesk', '', 'Room']);
    expect(
      saved.resourceGroups!.single.alternativeUri,
      'cid:labels@example.invalid',
    );
  } finally {
    final saved = await api.calendarEvent.getEvent(
      event.eventId,
      cal.CalendarEventFieldGroup.values,
    );
    await api.calendarEvent.deleteEvent(event.eventId, saved.revision);
    await api.calendar.delete(parent.calendarId, parent.revision);
  }
}
