import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/event_screen.dart';
import 'package:calendar_example_flutter/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> runItemCategorySearchJourney(
  WidgetTester tester,
  Client client,
) async {
  final api = client.modules.serverpod_calendar;
  final parent = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic category UI',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  for (final task in [false, true]) {
    final prefix = task ? 'task' : 'event', ids = <cal.UuidValue>[];
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    try {
      for (var i = 0; i < 2; i++) {
        final id = task
            ? (await api.calendarTask.create(
                cal.CalendarTaskCreateRequest(
                  calendarId: parent.calendarId,
                  content: cal.CalendarTaskContent(
                    summary: 'Category UI $i',
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
                    summary: 'Category UI $i',
                    timing: cal.CalendarEventTiming(
                      kind: cal.CalendarEventTimeKind.date,
                      start: cal.CalendarEventCivil(
                        year: 2030,
                        month: 1,
                        day: 1,
                      ),
                    ),
                  ),
                ),
              ))!.eventId;
        ids.add(id);
        final patch = cal.CalendarItemTextMetadataPatch(
          selectedFields: [cal.CalendarItemTextMetadataField.categories],
          categoryGroups: [
            cal.CalendarItemCategoryGroup(
              values: [i == 0 ? ' Å, 🧰 ' : 'Other'],
              language: 'SV',
            ),
          ],
        );
        if (task) {
          await api.calendarTask.updateTextMetadata(
            cal.CalendarTaskTextMetadataRequest(
              taskId: id,
              expectedRevision: 1,
              patch: patch,
            ),
          );
        } else {
          await api.calendarEvent.updateTextMetadata(
            cal.CalendarEventTextMetadataRequest(
              eventId: id,
              expectedRevision: 1,
              patch: patch,
            ),
          );
        }
      }
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => task
              ? TaskScreen(
                  client: client,
                  calendarId: parent.calendarId,
                  initialZone: 'Etc/UTC',
                )
              : EventScreen(
                  client: client,
                  calendarId: parent.calendarId,
                  initialZone: 'Etc/UTC',
                ),
        ),
      );
      Future<void> loaded() async {
        for (var n = 0; n < 150; n++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)),
          );
          await tester.pump(const Duration(milliseconds: 100));
          if (find.byType(LinearProgressIndicator).evaluate().isEmpty) break;
        }
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.byKey(Key('$prefix-error')), findsNothing);
      }

      await tester.pumpAndSettle();
      await loaded();
      Future<void> tap(String suffix) async {
        final f = find.byKey(Key('$prefix-category-$suffix'));
        await tester.ensureVisible(f);
        await tester.tap(f);
        await tester.pump();
        await loaded();
      }

      expect(find.byKey(ValueKey('$prefix-${ids[0]}')), findsOneWidget);
      expect(find.byKey(ValueKey('$prefix-${ids[1]}')), findsOneWidget);
      await tester.enterText(
        find.byKey(Key('$prefix-category-value')),
        ' Å, 🧰 ',
      );
      await tester.enterText(
        find.byKey(Key('$prefix-category-language')),
        'sv',
      );
      await tap('apply');
      expect(find.byKey(ValueKey('$prefix-${ids[0]}')), findsOneWidget);
      expect(find.byKey(ValueKey('$prefix-${ids[1]}')), findsNothing);
      await tester.enterText(
        find.byKey(Key('$prefix-category-value')),
        'no-match',
      );
      await tap('apply');
      expect(find.byKey(ValueKey('$prefix-${ids[0]}')), findsNothing);
      await tap('clear');
      expect(find.byKey(ValueKey('$prefix-${ids[0]}')), findsOneWidget);
      expect(find.byKey(ValueKey('$prefix-${ids[1]}')), findsOneWidget);
      navigator.pop();
      await tester.pumpAndSettle();
    } finally {
      for (final id in ids) {
        if (task) {
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
  }
  await api.calendar.delete(parent.calendarId, parent.revision);
}
