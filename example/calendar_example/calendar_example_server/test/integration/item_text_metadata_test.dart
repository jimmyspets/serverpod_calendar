import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/task_recurrence_values.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_test.dart' show TestPolicy, createInput, eventInput, failure;
import 'test_tools/serverpod_test_tools.dart';

CalendarItemTextMetadataPatch comments(String value) =>
    CalendarItemTextMetadataPatch(
      selectedFields: [CalendarItemTextMetadataField.comments],
      comments: [
        CalendarItemComment(
          value: value,
          parameters: CalendarTextParameters(
            language: 'sv',
            alternativeUri: 'cid:note@example.invalid',
          ),
        ),
      ],
    );
ByteData file(String component, List<String> extra) => ByteData.sublistView(
  Uint8List.fromList(
    utf8.encode(
      [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:Synthetic',
        'BEGIN:$component',
        'UID:text-source',
        'DTSTAMP:20261028T090000Z',
        if (component == 'VEVENT') 'DTSTART:20300101T090000Z',
        ...extra,
        'END:$component',
        'END:VCALENDAR',
        '',
      ].join('\r\n'),
    ),
  ),
);
void main() {
  withServerpod('native item text metadata', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late CalendarService service;
    late UuidValue parent;
    setUp(() async {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      policy = TestPolicy();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
      );
      service = CalendarModule.service(session);
      parent = (await service.create(createInput()))!.calendarId;
    });
    Future<CalendarEventDataRecord> event(UuidValue id) async =>
        (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(id),
        ))!;
    Future<CalendarTaskDataRecord> task(UuidValue id) async =>
        (await CalendarTaskDataRecord.db.findFirstRow(
          session,
          where: (t) => t.taskId.equals(id),
        ))!;
    test('event patch retains hidden/private fields and complete immutable host context', () async {
      final id = (await service.importEvents(
        CalendarEventImportRequest(
          calendarId: parent,
          expectedRevision: 1,
          bytes: file('VEVENT', [
            'URL:https://example.invalid/old',
            'CLASS:PRIVATE',
            'CONTACT:SECRET',
          ]),
        ),
      )).receipts.single.eventId;
      final before = await event(id);
      policy.eventGrants = {CalendarEventFieldGroup.comments};
      var finalSeen = false;
      policy.onItemTextMetadata = (r, phase) {
        expect(r.eventId, id);
        expect(r.calendarId, parent);
        expect(r.itemTextMetadataPatch!.selectedFields, [
          CalendarItemTextMetadataField.comments,
        ]);
        expect(
          () => r.itemTextMetadataPatch!.comments!.clear(),
          throwsUnsupportedError,
        );
        if (phase == CalendarAuthorizationPhase.finalWrite) {
          finalSeen = true;
          expect(
            r
                .currentEvent!
                .protocolState!
                .sourceMetadata!
                .contacts
                .single
                .value,
            'SECRET',
          );
          expect(
            r.proposedEventProtocolState!.sourceMetadata!.url,
            'https://example.invalid/old',
          );
        }
      };
      await service.updateEventTextMetadata(
        CalendarEventTextMetadataRequest(
          eventId: id,
          expectedRevision: 1,
          patch: comments('Å\nLine'),
        ),
      );
      final after = await event(id),
          view = await service.getEvent(id, CalendarEventFieldGroup.values);
      expect(finalSeen, isTrue);
      expect(view.comments!.single.value, 'Å\nLine');
      expect(view.url, isNull);
      expect(view.classification, isNull);
      expect(
        after.protocolState!.sourceMetadata!.contacts.single.value,
        'SECRET',
      );
      expect(after.importBaseline, before.importBaseline);
      expect(after.protocolState!.version.sequence, 1);
      await service.updateEventTextMetadata(
        CalendarEventTextMetadataRequest(
          eventId: id,
          expectedRevision: 2,
          patch: comments('Å\nLine'),
        ),
      );
      expect((await event(id)).protocolState, after.protocolState);
      await expectLater(
        service.exportEvents(
          CalendarEventExportRequest(
            calendarId: parent,
            expectedRevision: 1,
            selection: [
              CalendarEventExportSelection(eventId: id, expectedRevision: 3),
            ],
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test(
      'event patch separate denial stale rollback and explicit clears',
      () async {
        final id = (await service.createEvent(
          CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
        ))!.eventId;
        final old = await event(id);
        policy.denied.add(CalendarPermission.updateEventTextMetadata);
        await expectLater(
          service.updateEventTextMetadata(
            CalendarEventTextMetadataRequest(
              eventId: id,
              expectedRevision: 1,
              patch: comments('Denied'),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        policy.denyFinal = true;
        await expectLater(
          service.updateEventTextMetadata(
            CalendarEventTextMetadataRequest(
              eventId: id,
              expectedRevision: 1,
              patch: comments('Denied'),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await event(id)).toJson(), old.toJson());
        policy.denyFinal = false;
        await expectLater(
          service.updateEventTextMetadata(
            CalendarEventTextMetadataRequest(
              eventId: id,
              expectedRevision: 2,
              patch: comments('Stale'),
            ),
          ),
          failure(CalendarFailureCode.staleRevision),
        );
        await service.updateEventTextMetadata(
          CalendarEventTextMetadataRequest(
            eventId: id,
            expectedRevision: 1,
            patch: comments(''),
          ),
        );
        expect(
          (await service.getEvent(
            id,
            CalendarEventFieldGroup.values,
          )).comments!.single.value,
          '',
        );
        await service.updateEventTextMetadata(
          CalendarEventTextMetadataRequest(
            eventId: id,
            expectedRevision: 2,
            patch: CalendarItemTextMetadataPatch(
              selectedFields: [CalendarItemTextMetadataField.comments],
              comments: [],
            ),
          ),
        );
        expect(
          (await service.getEvent(id, CalendarEventFieldGroup.values)).comments,
          isEmpty,
        );
      },
    );
    test('task native metadata preserves progress assignments and no-op versions through export', () async {
      final id = (await service.createTask(
        CalendarTaskCreateRequest(
          calendarId: parent,
          content: CalendarTaskContent(
            summary: 'Task',
            timing: CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
          ),
          assignees: [],
        ),
      ))!.taskId;
      final before = await task(id);
      await service.updateTaskTextMetadata(
        CalendarTaskTextMetadataRequest(
          taskId: id,
          expectedRevision: 1,
          patch: comments('Note\nSecond'),
        ),
      );
      final after = await task(id);
      expect(after.sourceState!.nativeMetadataOnly, isTrue);
      expect(after.sourceState!.occurrences, isEmpty);
      expect(after.progress, before.progress);
      expect(after.hasRecordedProgress, before.hasRecordedProgress);
      expect(after.importBaseline, isNull);
      await service.updateTaskTextMetadata(
        CalendarTaskTextMetadataRequest(
          taskId: id,
          expectedRevision: 2,
          patch: comments('Note\nSecond'),
        ),
      );
      expect((await task(id)).protocolVersion, after.protocolVersion);
      final bytes = await service.exportTasks(
        CalendarTaskExportRequest(
          calendarId: parent,
          expectedRevision: 1,
          selection: [
            CalendarTaskExportSelection(taskId: id, expectedRevision: 3),
          ],
        ),
      );
      final decoded = parseIcalendarTaskCalendar(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      expect(
        decoded.tasks.single.metadata.comments.single.value,
        'Note\nSecond',
      );
      expect(
        utf8.decode(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        ),
        isNot(contains('nativeMetadataOnly')),
      );
      await service.changeTaskProgress(
        CalendarTaskProgressRequest(
          taskId: id,
          expectedRevision: 3,
          action: CalendarTaskProgressAction.complete,
        ),
      );
      expect(
        (await task(id)).sourceState!.master.progress.status,
        CalendarTaskStatus.completed,
      );
    });
    test('task imported metadata preserves independent progress private contacts and baseline', () async {
      final id = (await service.importTasks(
        CalendarTaskImportRequest(
          calendarId: parent,
          expectedRevision: 1,
          bytes: file('VTODO', [
            'SUMMARY:Imported',
            'PERCENT-COMPLETE:100',
            'CONTACT:SECRET',
          ]),
        ),
      )).receipts.single.taskId;
      final old = await task(id);
      policy.taskGrants = {CalendarTaskFieldGroup.comments};
      await service.updateTaskTextMetadata(
        CalendarTaskTextMetadataRequest(
          taskId: id,
          expectedRevision: 1,
          patch: comments('New'),
        ),
      );
      final next = await task(id),
          view = await service.getTask(id, CalendarTaskFieldGroup.values);
      expect(next.sourceState!.nativeMetadataOnly, isNull);
      expect(next.progress, old.progress);
      expect(next.hasRecordedProgress, isNull);
      expect(next.importBaseline, old.importBaseline);
      expect(next.sourceState!.master.metadata.contacts.single.value, 'SECRET');
      expect(view.comments!.single.value, 'New');
      expect(view.progress, isNull);
      expect(view.url, isNull);
      policy.denied.add(CalendarPermission.updateTaskTextMetadata);
      await expectLater(
        service.updateTaskTextMetadata(
          CalendarTaskTextMetadataRequest(
            taskId: id,
            expectedRevision: 2,
            patch: comments('Denied'),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect((await task(id)).toJson(), next.toJson());
    });
    test('native task metadata remains editable beyond wire occurrence limits and preserves rows/history', () async {
      final content = CalendarTaskContent(
        summary: 'Native many',
        timing: CalendarTaskTiming(
          kind: CalendarTaskTimeKind.date,
          start: CalendarEventCivil(year: 2030, month: 1, day: 1),
        ),
        recurrence: CalendarEventRecurrence(
          rule: CalendarEventRule(
            frequency: CalendarEventFrequency.daily,
            count: 200,
            byDay: [],
            byMonthDay: [],
            byYearDay: [],
            byWeekNo: [],
            byMonth: [],
            byHour: [],
            byMinute: [],
            bySetPosition: [],
          ),
          inclusions: [],
          exclusions: [],
        ),
      );
      final id = (await service.createTask(
        CalendarTaskCreateRequest(
          calendarId: parent,
          content: content,
          assignees: [],
        ),
      ))!.taskId;
      final rows = <CalendarTaskOccurrenceRecord>[];
      for (var n = 0; n < 130; n++) {
        final d = DateTime.utc(2030).add(Duration(days: n)),
            point = CalendarEventTiming(
              kind: CalendarEventTimeKind.date,
              start: CalendarEventCivil(
                year: d.year,
                month: d.month,
                day: d.day,
              ),
            );
        rows.add(
          CalendarTaskOccurrenceRecord(
            taskId: id,
            originalKey: taskOriginalKey(point),
            originalStart: point,
            progress: CalendarTaskProgress(
              status: CalendarTaskStatus.needsAction,
              percentComplete: 0,
            ),
            protocolVersion: CalendarTaskProtocolVersion(
              stamp: DateTime.utc(2026),
              sequence: 0,
            ),
          ),
        );
      }
      await CalendarTaskOccurrenceRecord.db.insert(session, rows);
      final before = jsonEncode(
        (await CalendarTaskOccurrenceRecord.db.find(session))
            .map((r) => r.toJson())
            .toList(),
      );
      await service.updateTaskTextMetadata(
        CalendarTaskTextMetadataRequest(
          taskId: id,
          expectedRevision: 1,
          patch: comments('Metadata'),
        ),
      );
      expect(
        jsonEncode(
          (await CalendarTaskOccurrenceRecord.db.find(session))
              .map((r) => r.toJson())
              .toList(),
        ),
        before,
      );
      expect((await task(id)).sourceState!.occurrences, isEmpty);
      await service.updateTask(
        CalendarTaskUpdateRequest(
          taskId: id,
          expectedRevision: 2,
          content: content.copyWith(summary: 'Changed master'),
        ),
      );
      await service.changeTaskOccurrenceProgress(
        CalendarTaskOccurrenceProgressRequest(
          taskId: id,
          expectedRevision: 3,
          originalStart: rows.first.originalStart,
          action: CalendarTaskProgressAction.complete,
        ),
      );
      final history = await CalendarTaskHistoryRecord.db.count(session);
      await expectLater(
        service.exportTasks(
          CalendarTaskExportRequest(
            calendarId: parent,
            expectedRevision: 1,
            selection: [
              CalendarTaskExportSelection(taskId: id, expectedRevision: 4),
            ],
          ),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      await service.updateTaskTextMetadata(
        CalendarTaskTextMetadataRequest(
          taskId: id,
          expectedRevision: 4,
          patch: comments('Still editable'),
        ),
      );
      expect(await CalendarTaskOccurrenceRecord.db.count(session), 130);
      expect(await CalendarTaskHistoryRecord.db.count(session), history);
      expect(
        (await task(id)).sourceState!.master.content.summary,
        'Changed master',
      );
      await service.deleteTask(id, 5);
      expect(await CalendarTaskOccurrenceRecord.db.count(session), 0);
      expect(await CalendarTaskHistoryRecord.db.count(session), 0);
      expect(await CalendarTaskDataRecord.db.count(session), 0);
    });
    test(
      'metadata-only storage does not invent a clean prior-progress checkpoint',
      () async {
        final content = CalendarTaskContent(
          timing: CalendarTaskTiming(
            kind: CalendarTaskTimeKind.date,
            start: CalendarEventCivil(year: 2030, month: 1, day: 1),
          ),
        );
        final id = (await service.createTask(
          CalendarTaskCreateRequest(
            calendarId: parent,
            content: content,
            assignees: [],
          ),
        ))!.taskId;
        final unknown = await task(id);
        await CalendarTaskDataRecord.db.updateRow(
          session,
          unknown.copyWith(hasRecordedProgress: null),
        );
        await service.updateTaskTextMetadata(
          CalendarTaskTextMetadataRequest(
            taskId: id,
            expectedRevision: 1,
            patch: comments('Known new metadata'),
          ),
        );
        expect((await task(id)).hasRecordedProgress, isNull);
        expect((await task(id)).importBaseline, isNull);
        final recurrence = CalendarEventRecurrence(
          rule: CalendarEventRule(
            frequency: CalendarEventFrequency.daily,
            count: 3,
            byDay: [],
            byMonthDay: [],
            byYearDay: [],
            byWeekNo: [],
            byMonth: [],
            byHour: [],
            byMinute: [],
            bySetPosition: [],
          ),
          inclusions: [],
          exclusions: [],
        );
        await expectLater(
          service.updateTask(
            CalendarTaskUpdateRequest(
              taskId: id,
              expectedRevision: 2,
              content: content.copyWith(recurrence: recurrence),
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect((await task(id)).sourceState!.nativeMetadataOnly, isTrue);
      },
    );
    test(
      'event and native task ALTREP rejection leaves all state unchanged',
      () async {
        final eid = (await service.createEvent(
          CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
        ))!.eventId;
        final tid = (await service.createTask(
          CalendarTaskCreateRequest(
            calendarId: parent,
            content: CalendarTaskContent(
              timing: CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
            ),
            assignees: [],
          ),
        ))!.taskId;
        final oldEvent = (await event(eid)).toJson(),
            oldTask = (await task(tid)).toJson();
        for (final uri in [
          'https://user:pass@example.invalid/',
          'https://example.invalid/%oops',
        ]) {
          final patch = CalendarItemTextMetadataPatch(
            selectedFields: [CalendarItemTextMetadataField.comments],
            comments: [
              CalendarItemComment(
                value: 'Note',
                parameters: CalendarTextParameters(alternativeUri: uri),
              ),
            ],
          );
          await expectLater(
            service.updateEventTextMetadata(
              CalendarEventTextMetadataRequest(
                eventId: eid,
                expectedRevision: 1,
                patch: patch,
              ),
            ),
            failure(CalendarFailureCode.validation),
          );
          await expectLater(
            service.updateTaskTextMetadata(
              CalendarTaskTextMetadataRequest(
                taskId: tid,
                expectedRevision: 1,
                patch: patch,
              ),
            ),
            failure(CalendarFailureCode.validation),
          );
        }
        expect((await event(eid)).toJson(), oldEvent);
        expect((await task(tid)).toJson(), oldTask);
      },
    );
    for (final kind in ['VEVENT', 'VTODO']) {
      test(
        '$kind replacement gates explicit metadata presence and native edits reject incompatible retained components',
        () async {
          ByteData source(bool own) {
            List<String> component(bool override) => [
              'BEGIN:$kind',
              'UID:presence',
              'DTSTAMP:20261028T090000Z',
              override
                  ? 'DTSTART:20300102T090000Z'
                  : 'DTSTART:20300101T090000Z',
              override
                  ? 'RECURRENCE-ID:20300102T090000Z'
                  : 'RRULE:FREQ=DAILY;COUNT=3',
              if (!override || own) ...[
                'URL:https://example.invalid/old',
                'CLASS:PRIVATE',
                'CATEGORIES;LANGUAGE=sv:Å,Å',
                'COMMENT;LANGUAGE=sv:Old',
              ],
              if (!override) 'CONTACT:SECRET',
              'END:$kind',
            ];
            return ByteData.sublistView(
              Uint8List.fromList(
                utf8.encode(
                  [
                    'BEGIN:VCALENDAR',
                    'VERSION:2.0',
                    'PRODID:Synthetic',
                    ...component(false),
                    ...component(true),
                    'END:VCALENDAR',
                    '',
                  ].join('\r\n'),
                ),
              ),
            );
          }

          final isEvent = kind == 'VEVENT';
          final id = isEvent
              ? (await service.importEvents(
                  CalendarEventImportRequest(
                    calendarId: parent,
                    expectedRevision: 1,
                    bytes: source(false),
                  ),
                )).receipts.single.eventId
              : (await service.importTasks(
                  CalendarTaskImportRequest(
                    calendarId: parent,
                    expectedRevision: 1,
                    bytes: source(false),
                  ),
                )).receipts.single.taskId;
          Future<Object> state() async =>
              isEvent ? (await event(id)).toJson() : (await task(id)).toJson();
          Future<void> replace(bool own, int revision) async {
            if (isEvent) {
              await service.replaceEventsFromImport(
                CalendarEventReplaceRequest(
                  calendarId: parent,
                  expectedRevision: 1,
                  selection: [
                    CalendarEventExportSelection(
                      eventId: id,
                      expectedRevision: revision,
                    ),
                  ],
                  bytes: source(own),
                ),
              );
            } else {
              await service.replaceTasksFromImport(
                CalendarTaskReplaceRequest(
                  calendarId: parent,
                  expectedRevision: 1,
                  selection: [
                    CalendarTaskExportSelection(
                      taskId: id,
                      expectedRevision: revision,
                    ),
                  ],
                  bytes: source(own),
                ),
              );
            }
          }

          final operation = isEvent
              ? CalendarPermission.updateEventTextMetadata
              : CalendarPermission.updateTaskTextMetadata;
          policy.onItemTextMetadata = (r, phase) {
            if (r.operation != operation) return;
            expect(
              r.itemTextMetadataPatch!.selectedFields.toSet(),
              CalendarItemTextMetadataField.values.toSet(),
            );
            expect(r.calendarId, parent);
          };
          final before = await state();
          policy.denied.add(operation);
          await expectLater(
            replace(true, 1),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(await state(), before);
          policy.denied.clear();
          await replace(true, 1);
          final pinned = await state();
          policy.denied.add(operation);
          await expectLater(
            replace(false, 2),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(await state(), pinned);
          policy.denied.clear();
          policy.onItemTextMetadata = null;
          if (isEvent) {
            await expectLater(
              service.updateEventTextMetadata(
                CalendarEventTextMetadataRequest(
                  eventId: id,
                  expectedRevision: 2,
                  patch: comments('Changed'),
                ),
              ),
              failure(CalendarFailureCode.validation),
            );
          } else {
            await expectLater(
              service.updateTaskTextMetadata(
                CalendarTaskTextMetadataRequest(
                  taskId: id,
                  expectedRevision: 2,
                  patch: comments('Changed'),
                ),
              ),
              failure(CalendarFailureCode.validation),
            );
          }
          expect(await state(), pinned);
        },
      );
    }
  });
}
