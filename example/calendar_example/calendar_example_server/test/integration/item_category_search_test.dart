import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, eventInput, failure;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('authorized item category search', (builder, endpoints) {
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
    for (final isTask in [false, true]) {
      final label = isTask ? 'task' : 'event';
      Future<void> patch(
        UuidValue id,
        String category, {
        String? language = 'SV',
        int revision = 1,
      }) async {
        final patch = CalendarItemTextMetadataPatch(
          selectedFields: [CalendarItemTextMetadataField.categories],
          categoryGroups: [
            CalendarItemCategoryGroup(
              values: [category, category],
              language: language,
            ),
            CalendarItemCategoryGroup(values: [category], language: 'en'),
          ],
        );
        if (isTask) {
          await service.updateTaskTextMetadata(
            CalendarTaskTextMetadataRequest(
              taskId: id,
              expectedRevision: revision,
              patch: patch,
            ),
          );
        } else {
          await service.updateEventTextMetadata(
            CalendarEventTextMetadataRequest(
              eventId: id,
              expectedRevision: revision,
              patch: patch,
            ),
          );
        }
      }

      Future<UuidValue> create({
        String name = 'Item',
        String category = ' Å, label ',
        String? language = 'SV',
      }) async {
        final id = isTask
            ? (await service.createTask(
                CalendarTaskCreateRequest(
                  calendarId: parent,
                  content: CalendarTaskContent(
                    summary: name,
                    timing: CalendarTaskTiming(
                      kind: CalendarTaskTimeKind.undated,
                    ),
                  ),
                  assignees: [],
                ),
              ))!.taskId
            : (await service.createEvent(
                CalendarEventCreateRequest(
                  calendarId: parent,
                  content: eventInput(summary: name),
                ),
              ))!.eventId;
        await patch(id, category, language: language);
        return id;
      }

      CalendarCategoryFilter filter([
        String value = ' Å, label ',
        String? language = 'sv',
      ]) => CalendarCategoryFilter(value: value, language: language);
      Future<(List<UuidValue>, String?)> page({
        CalendarService? api,
        CalendarCategoryFilter? query,
        String? cursor,
        int size = 1,
        UuidValue? calendar,
        bool categories = false,
      }) async {
        final current = api ?? service;
        if (isTask) {
          final p = await current.listTasks(
            calendar ?? parent,
            pageSize: size,
            fieldGroups: [
              CalendarTaskFieldGroup.summary,
              if (categories) CalendarTaskFieldGroup.categories,
            ],
            categoryFilter: query,
            cursor: cursor,
          );
          if (!categories) {
            for (final v in p.tasks) {
              expect(v.categoryGroups, isNull);
              expect(v.disclosedGroups, [CalendarTaskFieldGroup.summary]);
            }
          }
          return (p.tasks.map((v) => v.id).toList(), p.nextCursor);
        }
        final p = await current.listEvents(
          calendar ?? parent,
          pageSize: size,
          fieldGroups: [
            CalendarEventFieldGroup.summary,
            if (categories) CalendarEventFieldGroup.categories,
          ],
          categoryFilter: query,
          cursor: cursor,
        );
        if (!categories) {
          for (final v in p.events) {
            expect(v.categoryGroups, isNull);
            expect(v.disclosedGroups, [CalendarEventFieldGroup.summary]);
          }
        }
        return (p.events.map((v) => v.id).toList(), p.nextCursor);
      }

      test(
        '$label exact Unicode spacing language groups and output separation',
        () async {
          final id = await create();
          await create(category: 'Other');
          var plans = 0, reads = 0;
          policy.onItemQueryPlan = (q) {
            plans++;
            expect(q!.value, ' Å, label ');
            expect(q.language, 'sv');
          };
          policy.onCategoryRequest = (r) {
            expect(r.calendarId, parent);
            expect(r.current!.calendarId, parent);
            if (r.eventId != null || r.taskId != null) reads++;
            if (isTask) {
              expect(r.taskGroups, contains(CalendarTaskFieldGroup.categories));
              expect(() => r.taskGroups.clear(), throwsUnsupportedError);
            } else {
              expect(
                r.eventGroups,
                contains(CalendarEventFieldGroup.categories),
              );
              expect(() => r.eventGroups.clear(), throwsUnsupportedError);
            }
          };
          expect((await page(query: filter(), size: 10)).$1, [id]);
          expect(plans, 1);
          expect(reads, 2);
          policy.onItemQueryPlan = null;
          policy.onCategoryRequest = null;
          expect((await page(query: filter(' Å, label ', null))).$1, [id]);
          expect((await page(query: filter(' Å, label ', 'EN'))).$1, [id]);
          for (final q in [
            filter('Å, label'),
            filter(' å, label '),
            filter(' Å, label ', 'fr'),
            filter(' Å, label extra '),
          ]) {
            expect((await page(query: q)).$1, isEmpty);
          }
          expect((await page(size: 10)).$1, hasLength(2));
        },
      );
      test(
        '$label category membership withheld and read denial never qualify',
        () async {
          await create();
          if (isTask) {
            policy.taskGrants.remove(CalendarTaskFieldGroup.categories);
          } else {
            policy.eventGrants.remove(CalendarEventFieldGroup.categories);
          }
          expect((await page(query: filter())).$1, isEmpty);
          expect((await page(query: filter('nonmatch'))).$1, isEmpty);
          expect((await page()).$1, hasLength(1));
          if (isTask) {
            policy.taskGrants.add(CalendarTaskFieldGroup.categories);
          } else {
            policy.eventGrants.add(CalendarEventFieldGroup.categories);
          }
          policy.denied.add(
            isTask ? CalendarPermission.readTask : CalendarPermission.readEvent,
          );
          expect((await page(query: filter())).$1, isEmpty);
          policy.denied.clear();
          policy.hidden.add(parent);
          await expectLater(
            page(query: filter()),
            failure(CalendarFailureCode.accessDenied),
          );
        },
      );
      test(
        '$label freezes transport before awaits and rejects malformed filters',
        () async {
          final id = await create();
          final q = filter();
          policy.onCategoryRequest = (r) {
            q.value = 'Changed';
            q.language = 'fr';
            expect(r.categoryFilter!.value, ' Å, label ');
          };
          expect((await page(query: q)).$1, [id]);
          policy.onCategoryRequest = null;
          for (final bad in ['', ' ', 'a\nb', 'x' * 257]) {
            await expectLater(
              page(query: filter(bad)),
              failure(CalendarFailureCode.validation),
            );
          }
          await expectLater(
            page(query: filter('x', 'not_a_tag')),
            failure(CalendarFailureCode.validation),
          );
        },
      );
      test('$label cursor binds criteria family parent groups page and expiry', () async {
        final ids = [await create(), await create(), await create()];
        final other = (await service.create(createInput('Other')))!.calendarId;
        final first = await page(query: filter());
        final cursor = first.$2!;
        final second = await page(
          query: filter(' Å, label ', 'SV'),
          cursor: cursor,
        );
        expect({...first.$1, ...second.$1}, hasLength(2));
        for (final q in [
          null,
          filter('Other'),
          filter(' Å, label ', null),
          filter(' Å, label ', 'en'),
        ]) {
          await expectLater(
            page(query: q, cursor: cursor),
            failure(CalendarFailureCode.invalidCursor),
          );
        }
        await expectLater(
          page(query: filter(), cursor: cursor, size: 2),
          failure(CalendarFailureCode.invalidCursor),
        );
        await expectLater(
          page(query: filter(), cursor: cursor, categories: true),
          failure(CalendarFailureCode.invalidCursor),
        );
        await expectLater(
          page(query: filter(), cursor: cursor, calendar: other),
          failure(CalendarFailureCode.invalidCursor),
        );
        if (isTask) {
          await expectLater(
            service.listEvents(
              parent,
              pageSize: 1,
              fieldGroups: [CalendarEventFieldGroup.summary],
              categoryFilter: filter(),
              cursor: cursor,
            ),
            failure(CalendarFailureCode.invalidCursor),
          );
        } else {
          await expectLater(
            service.listTasks(
              parent,
              pageSize: 1,
              fieldGroups: [CalendarTaskFieldGroup.summary],
              categoryFilter: filter(),
              cursor: cursor,
            ),
            failure(CalendarFailureCode.invalidCursor),
          );
        }
        // A separate principal in the same trusted scope still cannot reuse it.
        final bob = builder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'bob',
                {},
              ),
            )
            .build();
        policy.scopeOverride = 'test:alice';
        await expectLater(
          page(
            api: CalendarModule.service(bob),
            query: filter(),
            cursor: cursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        policy.scopeOverride = null;
        final renewed = await page(query: filter());
        final c = renewed.$2!;
        final record = (await CalendarCursorRecord.db.findFirstRow(
          session,
          where: (t) => t.token.equals(c),
        ))!;
        record.expiresAt = DateTime.utc(2000);
        await CalendarCursorRecord.db.updateRow(session, record);
        await expectLater(
          page(query: filter(), cursor: c),
          failure(CalendarFailureCode.invalidCursor),
        );
        expect(ids.toSet(), hasLength(3));
      });
      test(
        '$label permission epochs and metadata writes invalidate continuation',
        () async {
          final ids = [await create(), await create()];
          var cursor = (await page(query: filter())).$2!;
          policy.epoch = 'changed';
          await expectLater(
            page(query: filter(), cursor: cursor),
            failure(CalendarFailureCode.invalidCursor),
          );
          cursor = (await page(query: filter())).$2!;
          await patch(ids.first, 'Other', revision: 2);
          await expectLater(
            page(query: filter(), cursor: cursor),
            failure(CalendarFailureCode.invalidCursor),
          );
          expect((await page(query: filter(), size: 10)).$1, [ids.last]);
        },
      );
      test(
        '$label bounded raw scan and policy outage never return partial search',
        () async {
          await create(category: 'Other');
          await create();
          CalendarModule.install(
            session.serverpod,
            policy: policy,
            options: const CalendarModuleOptions(
              requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
              maxScannedEvents: 1,
              maxScannedTasks: 1,
            ),
          );
          service = CalendarModule.service(session);
          await expectLater(
            page(query: filter('absent')),
            failure(CalendarFailureCode.limitExceeded),
          );
          CalendarModule.install(
            session.serverpod,
            policy: policy,
            options: const CalendarModuleOptions(
              requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
            ),
          );
          service = CalendarModule.service(session);
          policy.onCategoryRequest = (r) {
            if (r.eventId != null || r.taskId != null) {
              throw StateError('Synthetic unavailable');
            }
          };
          await expectLater(
            page(query: filter()),
            failure(CalendarFailureCode.unavailable),
          );
        },
      );
      test(
        '$label imported grouped source matching and absent categories',
        () async {
          final component = isTask ? 'VTODO' : 'VEVENT';
          final bytes = Uint8List.fromList(
            utf8.encode(
              [
                'BEGIN:VCALENDAR',
                'VERSION:2.0',
                'PRODID:-//Synthetic//EN',
                'BEGIN:$component',
                'UID:category-source',
                'DTSTAMP:20260101T000000Z',
                if (!isTask) 'DTSTART:20300101T090000Z',
                'CATEGORIES;LANGUAGE=sv: Å\\, label ,Other',
                'CATEGORIES;LANGUAGE=en: Å\\, label ',
                'END:$component',
                'END:VCALENDAR',
                '',
              ].join('\r\n'),
            ),
          );
          final id = isTask
              ? (await service.importTasks(
                  CalendarTaskImportRequest(
                    calendarId: parent,
                    expectedRevision: 1,
                    bytes: ByteData.sublistView(bytes),
                  ),
                )).receipts.single.taskId
              : (await service.importEvents(
                  CalendarEventImportRequest(
                    calendarId: parent,
                    expectedRevision: 1,
                    bytes: ByteData.sublistView(bytes),
                  ),
                )).receipts.single.eventId;
          expect((await page(query: filter())).$1, [id]);
          expect((await page(query: filter('Other', 'sv'))).$1, [id]);
          if (isTask) {
            await service.createTask(
              CalendarTaskCreateRequest(
                calendarId: parent,
                content: CalendarTaskContent(
                  timing: CalendarTaskTiming(
                    kind: CalendarTaskTimeKind.undated,
                  ),
                ),
                assignees: [],
              ),
            );
          } else {
            await service.createEvent(
              CalendarEventCreateRequest(
                calendarId: parent,
                content: eventInput(),
              ),
            );
          }
          expect((await page(query: filter(), size: 10)).$1, [id]);
        },
      );
    }
  });
}
