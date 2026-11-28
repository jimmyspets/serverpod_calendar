import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> itemCategorySmoke(List<Client> clients) async {
  if (clients.length != 2) {
    throw StateError('Category probe needs two independent hosts');
  }
  final a = clients.first.modules.serverpod_calendar,
      b = clients.last.modules.serverpod_calendar;
  final parent = (await a.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic category search',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  for (final task in [false, true]) {
    final ids = <cal.UuidValue>[];
    cal.CalendarCategoryFilter query() =>
        cal.CalendarCategoryFilter(value: ' Å, 🧰 ', language: 'sv');
    cal.CalendarItemTextMetadataPatch patch(String value) =>
        cal.CalendarItemTextMetadataPatch(
          selectedFields: [cal.CalendarItemTextMetadataField.categories],
          categoryGroups: [
            cal.CalendarItemCategoryGroup(
              values: [value, value],
              language: 'SV',
            ),
          ],
        );
    try {
      for (var i = 0; i < 3; i++) {
        final id = task
            ? (await a.calendarTask.create(
                cal.CalendarTaskCreateRequest(
                  calendarId: parent.calendarId,
                  content: cal.CalendarTaskContent(
                    summary: 'Item $i',
                    timing: cal.CalendarTaskTiming(
                      kind: cal.CalendarTaskTimeKind.undated,
                    ),
                  ),
                  assignees: [],
                ),
              ))!.taskId
            : (await a.calendarEvent.create(
                cal.CalendarEventCreateRequest(
                  calendarId: parent.calendarId,
                  content: cal.CalendarEventContent(
                    summary: 'Item $i',
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
        if (task) {
          await a.calendarTask.updateTextMetadata(
            cal.CalendarTaskTextMetadataRequest(
              taskId: id,
              expectedRevision: 1,
              patch: patch(' Å, 🧰 '),
            ),
          );
        } else {
          await a.calendarEvent.updateTextMetadata(
            cal.CalendarEventTextMetadataRequest(
              eventId: id,
              expectedRevision: 1,
              patch: patch(' Å, 🧰 '),
            ),
          );
        }
      }
      late String cursor;
      if (task) {
        final first = await a.calendarTask.list(
          parent.calendarId,
          pageSize: 1,
          fieldGroups: [cal.CalendarTaskFieldGroup.summary],
          categoryFilter: query(),
        );
        cursor = first.nextCursor!;
        final second = await b.calendarTask.list(
          parent.calendarId,
          pageSize: 1,
          fieldGroups: [cal.CalendarTaskFieldGroup.summary],
          categoryFilter: query(),
          cursor: cursor,
        );
        if (first.tasks.single.id == second.tasks.single.id ||
            second.tasks.single.categoryGroups != null) {
          throw StateError(
            'Cross-host task continuation disclosed/duplicated data',
          );
        }
      } else {
        final first = await a.calendarEvent.list(
          parent.calendarId,
          pageSize: 1,
          fieldGroups: [cal.CalendarEventFieldGroup.summary],
          categoryFilter: query(),
        );
        cursor = first.nextCursor!;
        final second = await b.calendarEvent.list(
          parent.calendarId,
          pageSize: 1,
          fieldGroups: [cal.CalendarEventFieldGroup.summary],
          categoryFilter: query(),
          cursor: cursor,
        );
        if (first.events.single.id == second.events.single.id ||
            second.events.single.categoryGroups != null) {
          throw StateError(
            'Cross-host event continuation disclosed/duplicated data',
          );
        }
      }
      final outcomes = await Future.wait(
        clients.map((client) async {
          final api = client.modules.serverpod_calendar;
          try {
            if (task) {
              await api.calendarTask.updateTextMetadata(
                cal.CalendarTaskTextMetadataRequest(
                  taskId: ids.first,
                  expectedRevision: 2,
                  patch: patch('Other'),
                ),
              );
            } else {
              await api.calendarEvent.updateTextMetadata(
                cal.CalendarEventTextMetadataRequest(
                  eventId: ids.first,
                  expectedRevision: 2,
                  patch: patch('Other'),
                ),
              );
            }
            return 'saved';
          } on cal.CalendarException catch (e) {
            return e.code.name;
          }
        }),
      );
      if (outcomes.where((o) => o == 'saved').length != 1 ||
          outcomes.where((o) => o == 'staleRevision').length != 1) {
        throw StateError('Category race did not fence a stale write');
      }
      var rejected = false;
      try {
        if (task) {
          await b.calendarTask.list(
            parent.calendarId,
            pageSize: 1,
            fieldGroups: [cal.CalendarTaskFieldGroup.summary],
            categoryFilter: query(),
            cursor: cursor,
          );
        } else {
          await b.calendarEvent.list(
            parent.calendarId,
            pageSize: 1,
            fieldGroups: [cal.CalendarEventFieldGroup.summary],
            categoryFilter: query(),
            cursor: cursor,
          );
        }
      } on cal.CalendarException catch (e) {
        rejected = e.code == cal.CalendarFailureCode.invalidCursor;
      }
      if (!rejected) {
        throw StateError(
          'Category write failed to invalidate cross-host continuation',
        );
      }
      final fresh = task
          ? (await b.calendarTask.list(
              parent.calendarId,
              pageSize: 10,
              fieldGroups: [cal.CalendarTaskFieldGroup.summary],
              categoryFilter: query(),
            )).tasks.map((v) => v.id).toSet()
          : (await b.calendarEvent.list(
              parent.calendarId,
              pageSize: 10,
              fieldGroups: [cal.CalendarEventFieldGroup.summary],
              categoryFilter: query(),
            )).events.map((v) => v.id).toSet();
      if (fresh.length != 2 || fresh.contains(ids.first)) {
        throw StateError(
          'Fresh category result did not reflect committed metadata',
        );
      }
    } finally {
      for (final id in ids) {
        if (task) {
          final v = await b.calendarTask.getTask(
            id,
            cal.CalendarTaskFieldGroup.values,
          );
          await b.calendarTask.deleteTask(id, v.revision);
        } else {
          final v = await b.calendarEvent.getEvent(
            id,
            cal.CalendarEventFieldGroup.values,
          );
          await b.calendarEvent.deleteEvent(id, v.revision);
        }
      }
    }
  }
  await a.calendar.delete(parent.calendarId, parent.revision);
  stdout.writeln(
    'PASS: cross-host event/task exact-category continuation, write races, stale cursor fencing and fresh results.',
  );
}
