import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/event_descriptive_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

void main() {
  testWidgets(
    'resource editor retains embedded newlines and separate empty labels on load',
    (tester) async {
      final client = Client('http://localhost/');
      addTearDown(client.close);
      final event = cal.CalendarEventView(
        id: const cal.Uuid().v4obj(),
        calendarId: const cal.Uuid().v4obj(),
        revision: 1,
        disclosedGroups: cal.CalendarEventFieldGroup.values,
        resourceGroups: [
          cal.CalendarEventResourceGroup(
            values: ['Room\nDesk', '', 'Room'],
            language: 'en',
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: EventDescriptiveEditor(client: client, event: event),
        ),
      );
      for (var i = 0; i < 3; i++) {
        final field = find.byKey(Key('event-resource-value-0-$i'));
        await tester.scrollUntilVisible(
          field,
          150,
          scrollable: find
              .descendant(
                of: find.byType(ListView).last,
                matching: find.byType(Scrollable),
              )
              .first,
          maxScrolls: 20,
        );
        expect(
          tester.widget<TextField>(field).controller!.text,
          ['Room\nDesk', '', 'Room'][i],
        );
      }
      final add = find.byKey(const Key('event-resource-label-add-0'));
      await tester.scrollUntilVisible(
        add,
        150,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
        maxScrolls: 20,
      );
      await tester.ensureVisible(add);
      await tester.pumpAndSettle();
      await tester.tap(add);
      await tester.pumpAndSettle();
      final added = find.byKey(const Key('event-resource-value-0-3'));
      await tester.scrollUntilVisible(
        added,
        150,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
        maxScrolls: 20,
      );
      expect(tester.widget<TextField>(added).controller!.text, '');
    },
  );
  testWidgets('descriptive editor cannot overwrite withheld groups', (
    tester,
  ) async {
    final client = Client('http://localhost/');
    addTearDown(client.close);
    await tester.pumpWidget(
      MaterialApp(
        home: EventDescriptiveEditor(
          client: client,
          event: cal.CalendarEventView(
            id: const cal.Uuid().v4obj(),
            calendarId: const cal.Uuid().v4obj(),
            revision: 1,
            disclosedGroups: [cal.CalendarEventFieldGroup.priority],
          ),
        ),
      ),
    );
    expect(
      tester.widget<TextField>(find.byKey(const Key('event-priority'))).enabled,
      isFalse,
    );
    final save = find.byKey(const Key('event-descriptive-save'));
    await tester.scrollUntilVisible(
      save,
      150,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
      maxScrolls: 20,
    );
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
  });
}
