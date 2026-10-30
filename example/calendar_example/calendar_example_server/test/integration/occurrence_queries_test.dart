import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'test_tools/serverpod_test_tools.dart';

CalendarEventCivil civil(int day, [int hour = 9]) =>
    CalendarEventCivil(year: 2026, month: 1, day: day, hour: hour);
CalendarEventTiming timing(int day, [int hour = 9]) => CalendarEventTiming(
  kind: CalendarEventTimeKind.utc,
  start: civil(day, hour),
  duration: CalendarEventDuration(hours: 1),
);

void main() {
  withServerpod('calendar-wide occurrence queries', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late CalendarService service;
    late UuidValue calendar;
    void install({
      int work = 100000,
      int results = 10000,
      int scan = 1000,
      int batch = 64,
    }) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          maxOccurrenceCandidateWork: work,
          maxOccurrenceResults: results,
          maxScannedEvents: scan,
          policyBatchSize: batch,
        ),
      );
      service = CalendarModule.service(session);
    }

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
      install();
      calendar = (await service.create(createInput()))!.calendarId;
    });
    CalendarEventOccurrenceListQuery query({
      int size = 1,
      String? cursor,
      bool cancelled = true,
      List<CalendarEventFieldGroup>? groups,
    }) => CalendarEventOccurrenceListQuery(
      calendarId: calendar,
      fromUtc: DateTime.utc(2026, 1, 1),
      untilUtc: DateTime.utc(2026, 1, 10),
      pageSize: size,
      includeCancelled: cancelled,
      fieldGroups: groups ?? [CalendarEventFieldGroup.summary],
      cursor: cursor,
    );
    Future<UuidValue> create(
      int day, {
      String? text,
      CalendarEventStatus status = CalendarEventStatus.confirmed,
    }) async => (await service.createEvent(
      CalendarEventCreateRequest(
        calendarId: calendar,
        content: CalendarEventContent(
          summary: text ?? 'Event $day',
          status: status,
          timing: timing(day),
        ),
      ),
    ))!.eventId;
    Future<CalendarCursorRecord> cursorRow(String token) async =>
        (await CalendarCursorRecord.db.findFirstRow(
          session,
          where: (t) => t.token.equals(token),
        ))!;

    test(
      'pages are ordered by effective start and prove authorized exhaustion',
      () async {
        final later = await create(3),
            earlier = await create(1),
            hidden = await create(2);
        policy.hiddenEvents.add(hidden);
        final first = await service.listEventOccurrences(query());
        expect(first.occurrences.single.eventId, earlier);
        expect(first.nextCursor, isNotNull);
        final second = await service.listEventOccurrences(
          query(cursor: first.nextCursor),
        );
        expect(second.occurrences.single.eventId, later);
        expect(second.nextCursor, isNull);
        expect(first.toJson().containsKey('totalCount'), isFalse);
        expect(jsonEncode(first.toJson()), isNot(contains('protocolUid')));
      },
    );
    test('hidden trailing rows never manufacture a continuation', () async {
      final visible = await create(1), denied = await create(2);
      policy.hiddenEvents.add(denied);
      final page = await service.listEventOccurrences(query());
      expect(page.occurrences.single.eventId, visible);
      expect(page.nextCursor, isNull);
    });
    test(
      'mandatory state/timing are required; optional text can be withheld',
      () async {
        final denied = await create(1),
            visible = await create(2, text: 'Hidden summary');
        policy.eventGrantsById[denied] = {CalendarEventFieldGroup.timing};
        policy.eventGrantsById[visible] = {
          CalendarEventFieldGroup.timing,
          CalendarEventFieldGroup.state,
        };
        final page = await service.listEventOccurrences(query(size: 10));
        expect(page.occurrences.single.eventId, visible);
        expect(page.occurrences.single.occurrence.content, isNull);
        expect(
          page.occurrences.single.disclosedGroups,
          {
            CalendarEventFieldGroup.timing,
            CalendarEventFieldGroup.state,
          }.toList(),
        );
        expect(jsonEncode(page.toJson()), isNot(contains('Hidden summary')));
      },
    );
    test(
      'collection query permission is separate from ordinary lists',
      () async {
        await create(1);
        policy.denied.add(CalendarPermission.listEventOccurrences);
        await expectLater(
          service.listEventOccurrences(query()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await service.listEvents(
            calendar,
            pageSize: 10,
            fieldGroups: [],
          )).events,
          hasLength(1),
        );
      },
    );
    test(
      'text disclosure is the intersection of read and preview authority',
      () async {
        await create(1, text: 'Read-only secret title');
        policy.eventGrantsByOperation[CalendarPermission.readEvent] = {
          CalendarEventFieldGroup.timing,
          CalendarEventFieldGroup.state,
          CalendarEventFieldGroup.summary,
        };
        policy.eventGrantsByOperation[CalendarPermission
            .previewEventOccurrences] = {
          CalendarEventFieldGroup.timing,
          CalendarEventFieldGroup.state,
        };
        final page = await service.listEventOccurrences(query());
        expect(page.occurrences, hasLength(1));
        expect(page.occurrences.single.occurrence.content, isNull);
        expect(
          jsonEncode(page.toJson()),
          isNot(contains('Read-only secret title')),
        );
      },
    );
    test(
      'calendar zone changes alter DATE matching and fence old continuations',
      () async {
        await create(2);
        final date = (await service.createEvent(
          CalendarEventCreateRequest(
            calendarId: calendar,
            content: CalendarEventContent(
              timing: CalendarEventTiming(
                kind: CalendarEventTimeKind.date,
                start: civil(2, 0),
              ),
            ),
          ),
        ))!.eventId;
        final first = await service.listEventOccurrences(query());
        expect(first.occurrences.single.eventId, date);
        final narrow = query(size: 10).copyWith(
          fromUtc: DateTime.utc(2026, 1, 1, 23, 30),
          untilUtc: DateTime.utc(2026, 1, 2, 0, 30),
        );
        expect(
          (await service.listEventOccurrences(narrow))
              .occurrences
              .single
              .eventId,
          date,
        );
        await service.updateSettings(
          CalendarSettingsUpdateRequest(
            calendarId: calendar,
            expectedRevision: 1,
            availabilityZoneId: 'America/New_York',
            noRuleFallback: CalendarNoRuleFallback.free,
          ),
        );
        await expectLater(
          service.listEventOccurrences(query(cursor: first.nextCursor)),
          failure(CalendarFailureCode.invalidCursor),
        );
        expect(
          (await service.listEventOccurrences(narrow)).occurrences,
          isEmpty,
        );
      },
    );
    test('preview denial filters details without implying free time', () async {
      await create(1);
      policy.denied.add(CalendarPermission.previewEventOccurrences);
      final page = await service.listEventOccurrences(query());
      expect(page.occurrences, isEmpty);
      expect(page.nextCursor, isNull);
    });
    test(
      'canonical window/groups and actual parents are immutable policy context',
      () async {
        final event = await create(1);
        final mutable = [CalendarEventFieldGroup.summary];
        var seen = 0;
        policy.onOccurrenceRequest = (request) {
          seen++;
          mutable.clear();
          expect(request.calendarId, calendar);
          expect(request.current!.calendarId, calendar);
          expect(request.occurrenceListQuery!.fieldGroups, [
            CalendarEventFieldGroup.summary,
          ]);
          expect(
            () => request.occurrenceListQuery!.fieldGroups.clear(),
            throwsUnsupportedError,
          );
          expect(() => request.eventGroups.clear(), throwsUnsupportedError);
          if (request.eventId != null) {
            expect(request.currentEvent!.eventId, event);
          }
        };
        final page = await service.listEventOccurrences(query(groups: mutable));
        expect(page.occurrences.single.occurrence.content!.summary, 'Event 1');
        expect(seen, greaterThanOrEqualTo(4));
      },
    );
    test('candidate IDs cannot introduce a different calendar', () async {
      final own = await create(1);
      final other = (await service.create(createInput('Other')))!.calendarId;
      final foreign = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: other,
          content: CalendarEventContent(
            summary: 'Foreign secret',
            timing: timing(1),
          ),
        ),
      ))!.eventId;
      policy.eventCandidates = {foreign, own};
      final page = await service.listEventOccurrences(query(size: 10));
      expect(page.occurrences.map((v) => v.eventId), [own]);
      policy.scopeOverride = 'test:bob';
      await expectLater(
        service.listEventOccurrences(query()),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test(
      'cancellation flag filters only after counting and authorization',
      () async {
        final active = await create(1),
            cancelled = await create(2, status: CalendarEventStatus.cancelled);
        final all = await service.listEventOccurrences(query(size: 10));
        expect(all.occurrences.map((v) => v.eventId), [active, cancelled]);
        expect(all.occurrences.last.cancelled, isTrue);
        expect(all.occurrences.last.status, CalendarEventStatus.cancelled);
        final filtered = await service.listEventOccurrences(
          query(size: 10, cancelled: false),
        );
        expect(filtered.occurrences.map((v) => v.eventId), [active]);
      },
    );
    test(
      'one-request policy batches retain complete read and preview checks',
      () async {
        await create(1);
        await create(2);
        install(batch: 1);
        final page = await service.listEventOccurrences(query(size: 10));
        expect(page.occurrences, hasLength(2));
        expect(policy.lastOccurrenceQueryTransaction, isNotNull);
      },
    );
    test('ties page without duplication using native identity', () async {
      final ids = [await create(1), await create(1), await create(1)]
        ..sort((a, b) => a.toString().compareTo(b.toString()));
      final seen = <UuidValue>[];
      String? token;
      do {
        final page = await service.listEventOccurrences(query(cursor: token));
        seen.add(page.occurrences.single.eventId);
        token = page.nextCursor;
      } while (token != null);
      expect(seen, ids);
    });
    test('cursor binds normalized criteria and rejects old list families both ways', () async {
      await create(1);
      await create(2);
      final first = await service.listEventOccurrences(query());
      for (final changed in [
        query(cursor: first.nextCursor)
            .copyWith(untilUtc: DateTime.utc(2026, 1, 9)),
        query(size: 2, cursor: first.nextCursor),
        query(cancelled: false, cursor: first.nextCursor),
        query(groups: [], cursor: first.nextCursor),
      ]) {
        await expectLater(
          service.listEventOccurrences(changed),
          failure(CalendarFailureCode.invalidCursor),
        );
      }
      await expectLater(
        service.listEvents(
          calendar,
          pageSize: 1,
          fieldGroups: [
            CalendarEventFieldGroup.summary,
            CalendarEventFieldGroup.timing,
            CalendarEventFieldGroup.state,
          ],
          cursor: first.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      final ordinary = await service.listEvents(
        calendar,
        pageSize: 1,
        fieldGroups: [
          CalendarEventFieldGroup.summary,
          CalendarEventFieldGroup.timing,
          CalendarEventFieldGroup.state,
        ],
      );
      await expectLater(
        service.listEventOccurrences(query(cursor: ordinary.nextCursor)),
        failure(CalendarFailureCode.invalidCursor),
      );
    });
    test('data and policy changes fence continuations', () async {
      await create(1);
      await create(2);
      final first = await service.listEventOccurrences(query());
      policy.epoch = 'new';
      await expectLater(
        service.listEventOccurrences(query(cursor: first.nextCursor)),
        failure(CalendarFailureCode.invalidCursor),
      );
      policy.epoch = 'v1';
      await create(3);
      await expectLater(
        service.listEventOccurrences(query(cursor: first.nextCursor)),
        failure(CalendarFailureCode.invalidCursor),
      );
    });
    test(
      'current source revocation invalidates an already issued continuation',
      () async {
        final firstId = await create(1);
        await create(2);
        final first = await service.listEventOccurrences(query());
        policy.hiddenEvents.add(firstId);
        await expectLater(
          service.listEventOccurrences(query(cursor: first.nextCursor)),
          failure(CalendarFailureCode.invalidCursor),
        );
      },
    );
    for (final corrupt in [
      'version',
      'timezone',
      'expiry',
      'principal',
      'json',
    ]) {
      test('cursor rejects $corrupt corruption', () async {
        await create(1);
        await create(2);
        final token = (await service.listEventOccurrences(query())).nextCursor!;
        final row = await cursorRow(token);
        switch (corrupt) {
          case 'version':
            row.eventOccurrenceState = row.eventOccurrenceState!.copyWith(
              version: 2,
            );
          case 'timezone':
            row.eventOccurrenceState = row.eventOccurrenceState!.copyWith(
              timezoneIdentity: 'different',
            );
          case 'expiry':
            row.expiresAt = DateTime.utc(2000);
          case 'principal':
            row.principalId = 'bob';
          case 'json':
            await session.db.unsafeExecute(
              'UPDATE serverpod_calendar_cursor SET "eventOccurrenceState"=\'{}\'::json WHERE token=@token',
              parameters: QueryParameters.named({'token': token}),
            );
        }
        if (corrupt != 'json') {
          await CalendarCursorRecord.db.updateRow(session, row);
        }
        await expectLater(
          service.listEventOccurrences(query(cursor: token)),
          failure(CalendarFailureCode.invalidCursor),
        );
      });
    }
    test(
      'budgets reject instead of returning a successful first partial page',
      () async {
        await create(1);
        await create(2);
        await create(3, status: CalendarEventStatus.cancelled);
        for (final configuration in [
          (100000, 2, 1000),
          (2, 10000, 1000),
          (100000, 10000, 2),
        ]) {
          install(
            work: configuration.$1,
            results: configuration.$2,
            scan: configuration.$3,
          );
          await expectLater(
            service.listEventOccurrences(query(cancelled: false)),
            failure(CalendarFailureCode.limitExceeded),
          );
          expect(await CalendarCursorRecord.db.count(session), 0);
        }
      },
    );
    test(
      'invalid temporal windows and unsupported groups reject without writes',
      () async {
        for (final invalid in [
          query().copyWith(untilUtc: DateTime.utc(2026, 1, 1)),
          query().copyWith(untilUtc: DateTime.utc(2028)),
          query().copyWith(fromUtc: DateTime.utc(2026, 1, 1, 0, 0, 0, 1)),
          query(size: 0),
          query(groups: [CalendarEventFieldGroup.categories]),
        ]) {
          await expectLater(
            service.listEventOccurrences(invalid),
            failure(CalendarFailureCode.validation),
          );
        }
        expect(await CalendarCursorRecord.db.count(session), 0);
      },
    );
    test(
      'policy outage and revision change never produce an exhausted success',
      () async {
        await create(1);
        policy.unavailable = true;
        await expectLater(
          service.listEventOccurrences(query()),
          failure(CalendarFailureCode.unavailable),
        );
        policy.unavailable = false;
        policy.onOccurrenceRequest = (_) {
          policy.epoch = 'changed';
        };
        await expectLater(
          service.listEventOccurrences(query()),
          failure(CalendarFailureCode.unavailable),
        );
        expect(await CalendarCursorRecord.db.count(session), 0);
      },
    );
  });
}
