import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/item_text_metadata_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runItemTextMetadataJourney(
  WidgetTester tester,
  Client client,
) async {
  final api = client.modules.serverpod_calendar;
  final parent = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic text editors',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  for (final isTask in [false, true]) {
    final id = isTask
        ? (await api.calendarTask.create(
            cal.CalendarTaskCreateRequest(
              calendarId: parent.calendarId,
              content: cal.CalendarTaskContent(
                summary: 'Task',
                timing: cal.CalendarTaskTiming(
                  kind: cal.CalendarTaskTimeKind.undated,
                ),
              ),
              assignees: [],
            ),
          ))!.taskId
        : (await api.calendarEvent.create(
            cal.CalendarEventCreateRequest(
              calendarId: parent.calendarId,
              content: cal.CalendarEventContent(
                summary: 'Event',
                timing: cal.CalendarEventTiming(
                  kind: cal.CalendarEventTimeKind.utc,
                  start: cal.CalendarEventCivil(
                    year: 2030,
                    month: 1,
                    day: 1,
                    hour: 9,
                  ),
                ),
              ),
            ),
          ))!.eventId;
    try {
      final event = isTask
          ? null
          : await api.calendarEvent.getEvent(
              id,
              cal.CalendarEventFieldGroup.values,
            );
      final task = isTask
          ? await api.calendarTask.getTask(
              id,
              cal.CalendarTaskFieldGroup.values,
            )
          : null;
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              ItemTextMetadataEditor(client: client, event: event, task: task),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> visible(Finder target) async {
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
            maxScrolls: 30,
          );
        }
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
      }

      Future<void> tap(String key) async {
        final f = find.byKey(Key(key));
        await visible(f);
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      await tester.enterText(
        find.byKey(const Key('item-text-url')),
        'https://example.invalid/info',
      );
      await tap('item-category-add');
      await tester.enterText(
        find.byKey(const Key('item-category-value-0-0')),
        '  Å 🧰  ',
      );
      await tester.enterText(
        find.byKey(const Key('item-category-language-0')),
        'SV',
      );
      await tap('item-comment-add');
      await tester.enterText(
        find.byKey(const Key('item-comment-value-0')),
        'First\nSecond',
      );
      await tester.enterText(
        find.byKey(const Key('item-comment-language-0')),
        'sv',
      );
      await tester.enterText(
        find.byKey(const Key('item-comment-alternative-0')),
        'cid:note@example.invalid',
      );
      await tap('item-text-save');
      for (
        var n = 0;
        n < 150 && find.byType(ItemTextMetadataEditor).evaluate().isNotEmpty;
        n++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(ItemTextMetadataEditor), findsNothing);
      if (isTask) {
        final saved = await api.calendarTask.getTask(
          id,
          cal.CalendarTaskFieldGroup.values,
        );
        expect(saved.comments!.single.value, 'First\nSecond');
        expect(saved.categoryGroups!.single.values, ['  Å 🧰  ']);
        expect(saved.categoryGroups!.single.language, 'SV');
        expect(saved.progress, task!.progress);
      } else {
        final saved = await api.calendarEvent.getEvent(
          id,
          cal.CalendarEventFieldGroup.values,
        );
        expect(saved.comments!.single.value, 'First\nSecond');
        expect(saved.categoryGroups!.single.values, ['  Å 🧰  ']);
        expect(saved.url, 'https://example.invalid/info');
      }
    } finally {
      if (isTask) {
        final v = await api.calendarTask.getTask(
          id,
          cal.CalendarTaskFieldGroup.values,
        );
        await api.calendarTask.deleteTask(id, v.revision);
      } else {
        final v = await api.calendarEvent.getEvent(
          id,
          cal.CalendarEventFieldGroup.values,
        );
        await api.calendarEvent.deleteEvent(id, v.revision);
      }
    }
  }
  await api.calendar.delete(parent.calendarId, parent.revision);
}
