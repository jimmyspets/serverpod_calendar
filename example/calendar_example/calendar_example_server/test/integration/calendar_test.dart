import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const groups = CalendarFieldGroup.values;
const eventGroups = CalendarEventFieldGroup.values;
CalendarEventContent eventInput({
  String? summary,
  CalendarEventStatus status = CalendarEventStatus.confirmed,
}) => CalendarEventContent(
  summary: summary,
  status: status,
  timing: CalendarEventTiming(
    kind: CalendarEventTimeKind.date,
    start: CalendarEventCivil(year: 2026, month: 3, day: 29),
  ),
);

CalendarCreateRequest createInput([String name = 'Calendar']) =>
    CalendarCreateRequest(
      displayName: name,
      availabilityZoneId: 'Europe/Stockholm',
      noRuleFallback: CalendarNoRuleFallback.free,
    );
Matcher failure(CalendarFailureCode code) =>
    throwsA(isA<CalendarException>().having((e) => e.code, 'code', code));

void main() {
  withServerpod('calendar storage and replaceable policy', (
    builder,
    endpoints,
  ) {
    late Session session;
    late TestPolicy policy;
    late CalendarService service;
    setUp(() {
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
    });
    CalendarEventRule daily({int count = 3}) => CalendarEventRule(
      frequency: CalendarEventFrequency.daily,
      count: count,
      byDay: [],
      byMonthDay: [],
      byYearDay: [],
      byWeekNo: [],
      byMonth: [],
      byHour: [],
      byMinute: [],
      bySetPosition: [],
    );
    CalendarEventTiming day(
      int n, {
      CalendarEventTimeKind kind = CalendarEventTimeKind.date,
    }) => CalendarEventTiming(
      kind: kind,
      start: CalendarEventCivil(year: 2026, month: 3, day: n),
    );
    CalendarEventOccurrenceQuery preview(UuidValue id, {int revision = 1}) =>
        CalendarEventOccurrenceQuery(
          eventId: id,
          expectedRevision: revision,
          fromDate: CalendarEventCivil(year: 2026, month: 3, day: 1),
          untilDate: CalendarEventCivil(year: 2026, month: 4, day: 1),
        );
    CalendarEventOccurrenceChange occurrenceChange(
      UuidValue id,
      CalendarEventOccurrenceAction action, {
      int revision = 1,
      int dayNumber = 30,
      CalendarEventTiming? replacement,
    }) => CalendarEventOccurrenceChange(
      eventId: id,
      expectedRevision: revision,
      originalStart: day(dayNumber),
      action: action,
      replacement: replacement,
    );
    Future<UuidValue> recurringEvent() async {
      final parent = (await service.create(createInput()))!.calendarId;
      return (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput().copyWith(
            recurrence: CalendarEventRecurrence(
              rule: daily(),
              inclusions: [],
              exclusions: [],
            ),
          ),
        ),
      ))!.eventId;
    }

    CalendarFreeBusyQuery busyQuery(UuidValue calendar) =>
        CalendarFreeBusyQuery(
          calendarId: calendar,
          fromUtc: DateTime.utc(2026, 3, 29),
          untilUtc: DateTime.utc(2026, 3, 30),
        );
    Future<CalendarEventReceipt> booking(
      UuidValue calendar,
      int hour,
      int end, {
      CalendarEventStatus status = CalendarEventStatus.confirmed,
      CalendarEventTransparency transparency = CalendarEventTransparency.opaque,
    }) async => (await service.createEvent(
      CalendarEventCreateRequest(
        calendarId: calendar,
        content: CalendarEventContent(
          summary: 'Private booking',
          description: 'Private notes',
          location: 'Private room',
          status: status,
          transparency: transparency,
          timing: CalendarEventTiming(
            kind: CalendarEventTimeKind.utc,
            start: CalendarEventCivil(
              year: 2026,
              month: 3,
              day: 29,
              hour: hour,
            ),
            end: CalendarEventCivil(year: 2026, month: 3, day: 29, hour: end),
          ),
        ),
      ),
    ))!;
    CalendarAvailabilityTarget target([String id = 'alice']) =>
        CalendarAvailabilityTarget(
          namespace: 'test',
          kind: 'user',
          externalId: id,
        );
    CalendarAvailabilitySearchQuery searchQuery(
      List<CalendarAvailabilityTarget> targets, {
      CalendarAvailabilitySearchMode mode =
          CalendarAvailabilitySearchMode.commonFree,
      int minimum = 1,
    }) => CalendarAvailabilitySearchQuery(
      targets: targets,
      fromUtc: DateTime.utc(2026, 3, 29),
      untilUtc: DateTime.utc(2026, 3, 30),
      mode: mode,
      minimumSeconds: minimum,
    );
    Future<UuidValue> contributor(
      String name, {
      bool contributes = true,
    }) async {
      final calendar = (await service.create(createInput()))!.calendarId;
      await service.changeSubject(
        CalendarSubjectChangeRequest(
          calendarId: calendar,
          expectedRevision: 1,
          action: CalendarSubjectAction.attach,
          namespace: 'test',
          kind: 'user',
          externalId: name,
          contributesAvailability: contributes,
        ),
      );
      return calendar;
    }

    test('subject search unions bookings from complete contributors independently of direct calendar access', () async {
      final a = await contributor('alice'), b = await contributor('alice');
      final admin = await contributor('alice', contributes: false);
      await booking(a, 9, 10);
      await booking(b, 10, 11);
      await booking(admin, 12, 14);
      policy.denied.addAll([
        CalendarPermission.readFreeBusy,
        CalendarPermission.readEvent,
        CalendarPermission.listEvents,
        CalendarPermission.read,
        CalendarPermission.readAssociations,
      ]);
      final before = await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      );
      final result = await service.searchAvailability(searchQuery([target()]));
      expect(result.commonCoverage, CalendarFreeBusyCoverage.complete);
      final periods = result.results.single.periods;
      expect(periods.map((p) => p.kind), [
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.busy,
        CalendarFreeBusyKind.free,
      ]);
      expect(periods[1].startUtc, DateTime.utc(2026, 3, 29, 9));
      expect(periods[1].endUtc, DateTime.utc(2026, 3, 29, 11));
      final wire = result.toJson().toString();
      for (final secret in [
        a.toString(),
        b.toString(),
        admin.toString(),
        'Private booking',
        'test:alice',
      ]) {
        expect(wire, isNot(contains(secret)));
      }
      final projected = policy.searchRequests.where(
        (r) => r.operation == CalendarPermission.projectCalendarAvailability,
      );
      expect(projected.map((r) => r.calendarId).toSet(), {a, b});
      expect(
        projected.every(
          (r) =>
              r.availabilityTarget!.externalId == 'alice' &&
              r.current!.calendarId == r.calendarId,
        ),
        isTrue,
      );
      expect(result.calculatedAtUtc.microsecond, 0);
      expect(result.calculatedAtUtc.millisecond, 0);
      final after = await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      );
      expect(after!.revision, before!.revision);
    });
    test('subject search combines targets and deduplicates exact references without changing free semantics', () async {
      final a = await contributor('alice'), b = await contributor('bob');
      await booking(a, 9, 10);
      await booking(b, 10, 11);
      final query = searchQuery([target(), target('bob'), target()]);
      final result = await service.searchAvailability(query);
      expect(result.results.map((r) => r.target.externalId), ['alice', 'bob']);
      expect(result.commonCoverage, CalendarFreeBusyCoverage.complete);
      expect(result.commonSlots.map((w) => (w.startUtc, w.endUtc)), [
        (DateTime.utc(2026, 3, 29), DateTime.utc(2026, 3, 29, 9)),
        (DateTime.utc(2026, 3, 29, 11), DateTime.utc(2026, 3, 30)),
      ]);
      final perTarget = await service.searchAvailability(
        query.copyWith(mode: CalendarAvailabilitySearchMode.perTarget),
      );
      expect(perTarget.commonCoverage, isNull);
      expect(perTarget.commonSlots, isEmpty);
      expect(
        perTarget.results.every(
          (r) => r.coverage == CalendarFreeBusyCoverage.complete,
        ),
        isTrue,
      );
      expect(perTarget.snapshotId, isNot(result.snapshotId));
    });
    test('subject search denied targets and required projections never establish common free', () async {
      final a = await contributor('alice');
      await contributor('bob');
      await booking(a, 9, 10);
      policy.deniedSubjects.add('bob');
      final result = await service.searchAvailability(
        searchQuery([target(), target('bob')]),
      );
      expect(result.results.first.coverage, CalendarFreeBusyCoverage.complete);
      expect(result.results.last.coverage, CalendarFreeBusyCoverage.unknown);
      expect(result.results.last.periods, isEmpty);
      expect(result.results.last.freeSlots, isEmpty);
      expect(result.commonCoverage, CalendarFreeBusyCoverage.unknown);
      expect(result.commonSlots, isEmpty);
      for (final operation in [
        CalendarPermission.projectCalendarAvailability,
        CalendarPermission.projectEventBusy,
      ]) {
        policy.denied.add(operation);
        expect(
          (await service.searchAvailability(searchQuery([target()])))
              .results
              .single
              .coverage,
          CalendarFreeBusyCoverage.unknown,
        );
        policy.denied.remove(operation);
      }
    });
    test('subject search empty incomplete foreign and deleted contributor sets remain unknown', () async {
      final a = await contributor('alice');
      final query = searchQuery([target()]);
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: [],
      );
      expect(
        (await service.searchAvailability(query)).commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: false,
        revision: 'v',
        calendarIds: [a],
      );
      expect(
        (await service.searchAvailability(query)).results.single.periods,
        isEmpty,
      );
      policy.scopeOverride = 'test:foreign';
      final foreign = (await service.create(createInput()))!.calendarId;
      policy.scopeOverride = null;
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: [foreign],
      );
      expect(
        (await service.searchAvailability(query)).commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
      final deleted = (await service.create(createInput()))!.calendarId;
      await service.delete(deleted, 1);
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: [deleted],
      );
      expect(
        (await service.searchAvailability(query)).commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
    });
    test('subject search rechecks resolver revision set and summary access after calculation', () async {
      final a = await contributor('alice'), b = await contributor('bob');
      final query = searchQuery([target()]);
      for (final changeSet in [false, true]) {
        policy.resolverCalls.clear();
        policy.resolveOverride = (_, n) => CalendarSubjectResolution(
          complete: true,
          revision: !changeSet && n > 1 ? 'changed' : 'v',
          calendarIds: [changeSet && n > 1 ? b : a],
        );
        final result = await service.searchAvailability(query);
        expect(result.commonCoverage, CalendarFreeBusyCoverage.unknown);
        expect(result.results.single.periods, isEmpty);
      }
      policy.resolveOverride = null;
      policy.resolverCalls.clear();
      var calls = 0;
      policy.onSearchRead = (r) {
        if (++calls > 1) policy.deniedSubjects.add('alice');
      };
      expect(
        (await service.searchAvailability(query)).commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
    });
    test('subject search freezes query context and rejects malformed bounds minimums and raw target caps', () async {
      await contributor('alice');
      final originals = [target()];
      policy.onSearchRead = (r) {
        expect(
          () => r.availabilitySearchQuery!.targets.clear(),
          throwsUnsupportedError,
        );
        originals.clear();
      };
      expect(
        (await service.searchAvailability(searchQuery(originals))).results,
        hasLength(1),
      );
      policy.onSearchRead = null;
      for (final query in [
        searchQuery([]),
        searchQuery(List.generate(33, (_) => target())),
        searchQuery([target()], minimum: 0),
        searchQuery([target()], minimum: 2678401),
        searchQuery([target()])
            .copyWith(fromUtc: DateTime.utc(2026, 3, 29, 0, 0, 0, 1)),
        searchQuery([target()]).copyWith(untilUtc: DateTime.utc(2026, 5, 1)),
      ]) {
        await expectLater(
          service.searchAvailability(query),
          failure(CalendarFailureCode.validation),
        );
      }
      await expectLater(
        service.searchAvailability(
          searchQuery(List.generate(9, (n) => target('$n'))),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
    });
    test('subject search contributor raw caps and whole-query calendar budgets cannot produce partial common slots', () async {
      final ids = <UuidValue>[];
      for (var i = 0; i < 8; i++) {
        ids.add((await service.create(createInput()))!.calendarId);
      }
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: ids,
      );
      final result = await service.searchAvailability(
        searchQuery([target(), target('bob'), target('carol')]),
      );
      expect(
        result.results
            .take(2)
            .every((r) => r.coverage == CalendarFreeBusyCoverage.complete),
        isTrue,
      );
      expect(result.results.last.coverage, CalendarFreeBusyCoverage.unknown);
      expect(result.commonCoverage, CalendarFreeBusyCoverage.unknown);
      expect(result.commonSlots, isEmpty);
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: List.filled(9, ids.first),
      );
      expect(
        (await service.searchAvailability(searchQuery([target()])))
            .commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
    });

    CalendarAvailabilityContent hours({
      int priority = 0,
      bool closed = false,
    }) => CalendarAvailabilityContent(
      summary: 'Private working hours',
      priority: priority,
      openings: closed
          ? []
          : [
              CalendarAvailabilityOpening(
                timing: CalendarEventTiming(
                  kind: CalendarEventTimeKind.utc,
                  start: CalendarEventCivil(
                    year: 2026,
                    month: 3,
                    day: 29,
                    hour: 9,
                  ),
                  end: CalendarEventCivil(
                    year: 2026,
                    month: 3,
                    day: 29,
                    hour: 17,
                  ),
                ),
                recurrence: CalendarEventRecurrence(
                  rule: daily(),
                  inclusions: [],
                  exclusions: [],
                ),
              ),
            ],
    );
    test('subject search supports mixed people room and equipment references with the same external identifier', () async {
      final person = await contributor('shared');
      final targets = [target('shared')];
      final calendars = [person];
      for (final kind in ['room', 'equipment']) {
        final calendar = (await service.create(createInput()))!.calendarId;
        await service.changeSubject(
          CalendarSubjectChangeRequest(
            calendarId: calendar,
            expectedRevision: 1,
            action: CalendarSubjectAction.attach,
            namespace: 'test',
            kind: kind,
            externalId: 'shared',
            contributesAvailability: true,
          ),
        );
        targets.add(target('shared').copyWith(kind: kind));
        calendars.add(calendar);
      }
      for (var i = 0; i < calendars.length; i++) {
        await booking(calendars[i], 9 + i, 10 + i);
      }
      final result = await service.searchAvailability(searchQuery(targets));
      expect(result.results.map((r) => r.target.kind), [
        'user',
        'room',
        'equipment',
      ]);
      expect(
        result.results.every(
          (r) => r.coverage == CalendarFreeBusyCoverage.complete,
        ),
        isTrue,
      );
      expect(result.commonCoverage, CalendarFreeBusyCoverage.complete);
      expect(result.commonSlots.first.endUtc, DateTime.utc(2026, 3, 29, 9));
      expect(result.commonSlots.last.startUtc, DateTime.utc(2026, 3, 29, 12));
    });

    test('subject search intersects independently prioritized hours and filters minimum after combining', () async {
      final a = await contributor('alice'), b = await contributor('alice');
      await service.createAvailability(
        CalendarAvailabilityCreateRequest(calendarId: a, content: hours()),
      );
      await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: b,
          content: hours(priority: 1).copyWith(
            openings: [
              CalendarAvailabilityOpening(
                timing: hours().openings.single.timing.copyWith(
                  start: CalendarEventCivil(
                    year: 2026,
                    month: 3,
                    day: 29,
                    hour: 10,
                  ),
                  end: CalendarEventCivil(
                    year: 2026,
                    month: 3,
                    day: 29,
                    hour: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      final result = await service.searchAvailability(
        searchQuery([target()], minimum: 7 * 3600),
      );
      expect(result.commonSlots.single.startUtc, DateTime.utc(2026, 3, 29, 10));
      expect(result.commonSlots.single.endUtc, DateTime.utc(2026, 3, 29, 17));
      final tooLong = await service.searchAvailability(
        searchQuery([target()], minimum: 7 * 3600 + 1),
      );
      expect(tooLong.commonCoverage, CalendarFreeBusyCoverage.complete);
      expect(tooLong.commonSlots, isEmpty);
      expect(tooLong.results.single.periods, hasLength(3));
      policy.denied.add(CalendarPermission.projectAvailability);
      expect(
        (await service.searchAvailability(searchQuery([target()])))
            .commonCoverage,
        CalendarFreeBusyCoverage.unknown,
      );
    });
    test('subject search charges duplicate source reads against an aggregate event budget', () async {
      final a = await contributor('alice');
      for (var i = 0; i < 33; i++) {
        await booking(a, 9, 10);
      }
      policy.resolveOverride = (_, _) => CalendarSubjectResolution(
        complete: true,
        revision: 'v',
        calendarIds: [a],
      );
      final result = await service.searchAvailability(
        searchQuery(List.generate(8, (i) => target('person$i'))),
      );
      expect(
        result.results
            .take(7)
            .every((r) => r.coverage == CalendarFreeBusyCoverage.complete),
        isTrue,
      );
      expect(result.results.last.coverage, CalendarFreeBusyCoverage.unknown);
      expect(result.commonCoverage, CalendarFreeBusyCoverage.unknown);
      expect(result.commonSlots, isEmpty);
    });

    Future<CalendarAvailabilityView> editableHours() async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final created = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      return service.getAvailability(created.availabilityId);
    }

    CalendarAvailabilityOccurrenceChange openingChange(
      CalendarAvailabilityView rule,
      CalendarEventOccurrenceAction action, {
      CalendarEventTiming? replacement,
    }) => CalendarAvailabilityOccurrenceChange(
      availabilityId: rule.id,
      openingUid: rule.content.openings.single.uid!,
      expectedRevision: rule.revision,
      originalStart: rule.content.openings.single.timing.copyWith(
        end: null,
        duration: null,
      ),
      action: action,
      replacement: replacement,
    );
    CalendarAvailabilityOccurrenceQuery openingQuery(
      CalendarAvailabilityView rule,
    ) => CalendarAvailabilityOccurrenceQuery(
      availabilityId: rule.id,
      openingUid: rule.content.openings.single.uid!,
      expectedRevision: rule.revision,
      fromUtc: DateTime.utc(2026, 3, 29),
      untilUtc: DateTime.utc(2026, 4, 1),
    );
    test('lifecycle protocol versions distinguish identical saves metadata and opening changes', () async {
      var rule = await editableHours();
      final initial = rule.protocolState.toJson();
      expect(rule.protocolState.sequence, 0);
      expect(rule.protocolState.openings.single.created, isNotNull);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content,
        ),
      );
      expect(
        policy.lastAvailabilityRequest!.proposedAvailabilityProtocolState!
            .toJson(),
        initial,
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.revision, 2);
      expect(rule.protocolState.toJson(), initial);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(description: 'Changed metadata'),
        ),
      );
      expect(
        policy
            .lastAvailabilityRequest!
            .proposedAvailabilityProtocolState!
            .sequence,
        1,
      );
      rule = await service.getAvailability(rule.id);
      expect(
        rule.protocolState.openings.single.toJson(),
        (initial['openings'] as List).single,
      );
      expect(rule.lastModified, rule.protocolState.stamp);
      final before = rule.protocolState.toJson();
      policy.denyFinal = true;
      await expectLater(
        service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content.copyWith(description: 'Denied'),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      expect(
        (await service.getAvailability(rule.id)).protocolState.toJson(),
        before,
      );
      await expectLater(
        service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: 1,
            content: rule.content,
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      expect(
        () => policy
            .lastAvailabilityRequest!
            .currentAvailability!
            .protocolState
            .openings
            .clear(),
        throwsUnsupportedError,
      );
    });
    test('lifecycle occurrence mutations advance protocol once while redundant skips preserve it', () async {
      var rule = await editableHours();
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      expect(
        policy
            .lastAvailabilityRequest!
            .proposedAvailabilityProtocolState!
            .sequence,
        1,
      );
      rule = await service.getAvailability(rule.id);
      final state = rule.protocolState.toJson();
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.protocolState.toJson(), state);
      expect(rule.revision, 3);
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.restoreSingle),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.protocolState.sequence, 2);
    });
    test('lifecycle legacy baseline does not write on reads or invent opening creation', () async {
      var rule = await editableHours();
      var data = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(rule.id),
      ))!;
      data = data.copyWith(
        protocolState: null,
        createdAt: DateTime.utc(2020),
        updatedAt: DateTime.utc(2021),
      );
      await CalendarAvailabilityDataRecord.db.updateRow(session, data);
      rule = await service.getAvailability(rule.id);
      expect(rule.protocolState.created, DateTime.utc(2020));
      expect(rule.protocolState.stamp, DateTime.utc(2021));
      expect(rule.protocolState.openings.single.created, isNull);
      final stored = (await CalendarAvailabilityDataRecord.db.findFirstRow(
        session,
        where: (t) => t.availabilityId.equals(rule.id),
      ))!;
      expect(stored.protocolState, isNull);
      expect(stored.updatedAt, data.updatedAt);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(description: 'Envelope only'),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        rule.protocolState.openings.single.lastModified,
        DateTime.utc(2021),
      );
      expect(rule.protocolState.openings.single.created, isNull);
      await service.updateAvailability(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(
            openings: [
              ...rule.content.openings,
              rule.content.openings.single.copyWith(uid: null),
            ],
          ),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.protocolState.openings.last.created, isNotNull);
      expect(rule.protocolState.sequence, 2);
    });
    test('lifecycle envelope duration clips free busy and requires structural authority', () async {
      var rule = await editableHours();
      final next = rule.content.copyWith(
        openings: [],
        validFrom: CalendarEventTiming(
          kind: CalendarEventTimeKind.utc,
          start: CalendarEventCivil(year: 2026, month: 3, day: 29, hour: 8),
        ),
        validDuration: CalendarEventDuration(hours: 1),
      );
      final request = CalendarAvailabilityUpdateRequest(
        availabilityId: rule.id,
        expectedRevision: rule.revision,
        content: next,
      );
      await expectLater(
        service.updateAvailabilityMetadata(request),
        failure(CalendarFailureCode.validation),
      );
      policy.denied.add(CalendarPermission.updateAvailability);
      await expectLater(
        service.updateAvailability(request),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      await service.updateAvailability(request);
      rule = await service.getAvailability(rule.id);
      expect(rule.content.validDuration!.hours, 1);
      expect(rule.content.validUntil, isNull);
      final result = await service.freeBusy(
        CalendarFreeBusyQuery(
          calendarId: rule.calendarId,
          fromUtc: DateTime.utc(2026, 3, 29),
          untilUtc: DateTime.utc(2026, 3, 30),
        ),
      );
      expect(result.coverage, CalendarFreeBusyCoverage.complete);
      expect(result.periods.map((p) => p.kind), [
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.unavailable,
        CalendarFreeBusyKind.free,
      ]);
      expect(result.periods[1].startUtc, DateTime.utc(2026, 3, 29, 8));
      expect(result.periods[1].endUtc, DateTime.utc(2026, 3, 29, 9));
      expect(result.toJson().toString(), isNot(contains('sequence')));
    });
    test(
      'lifecycle sequence overflow cannot partially change active state',
      () async {
        var rule = await editableHours();
        final data = (await CalendarAvailabilityDataRecord.db.findFirstRow(
          session,
          where: (t) => t.availabilityId.equals(rule.id),
        ))!;
        await CalendarAvailabilityDataRecord.db.updateRow(
          session,
          data.copyWith(
            protocolState: data.protocolState!.copyWith(sequence: 2147483647),
          ),
        );
        rule = await service.getAvailability(rule.id);
        await expectLater(
          service.updateAvailabilityMetadata(
            CalendarAvailabilityUpdateRequest(
              availabilityId: rule.id,
              expectedRevision: rule.revision,
              content: rule.content.copyWith(description: 'Overflow'),
            ),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(
          (await service.getAvailability(rule.id)).revision,
          rule.revision,
        );
        await service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content,
          ),
        );
        expect(
          (await service.getAvailability(rule.id)).protocolState.sequence,
          2147483647,
        );
      },
    );
    test('publication organizer creation denial and adapter timeout leave no active data', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final input = CalendarAvailabilityCreateRequest(
        calendarId: parent,
        content: hours().copyWith(
          organizer: CalendarAvailabilityOrganizer(
            address: 'mailto:alice@example.invalid',
          ),
        ),
      );
      policy.denyFinalOrganizer = true;
      await expectLater(
        service.createAvailability(input),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await service.listAvailability(parent), isEmpty);
      policy.denyFinalOrganizer = false;
      policy.organizerDelay = const Duration(milliseconds: 100);
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          policyTimeout: Duration(milliseconds: 20),
        ),
      );
      service = CalendarModule.service(session);
      await expectLater(
        service.createAvailability(input),
        failure(CalendarFailureCode.unavailable),
      );
      policy.organizerDelay = Duration.zero;
      expect(await service.listAvailability(parent), isEmpty);
    });
    test(
      'publication organizer approval is independent, final checked and atomic',
      () async {
        var rule = await editableHours();
        final proposed = rule.content.copyWith(
          organizer: CalendarAvailabilityOrganizer(
            address: 'mailto:alice@example.invalid',
            commonName: 'Åsa',
            language: 'SV',
          ),
        );
        CalendarAvailabilityUpdateRequest request() =>
            CalendarAvailabilityUpdateRequest(
              availabilityId: rule.id,
              expectedRevision: rule.revision,
              content: proposed,
            );
        policy.denyOrganizer = true;
        await expectLater(
          service.updateAvailabilityMetadata(request()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await service.getAvailability(rule.id)).revision,
          rule.revision,
        );
        policy.denyOrganizer = false;
        policy.denyFinalOrganizer = true;
        await expectLater(
          service.updateAvailabilityMetadata(request()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await service.getAvailability(rule.id)).content.organizer,
          isNull,
        );
        policy.denyFinalOrganizer = false;
        policy.organizerUnavailable = true;
        await expectLater(
          service.updateAvailabilityMetadata(request()),
          failure(CalendarFailureCode.unavailable),
        );
        policy.organizerUnavailable = false;
        policy.denied.add(CalendarPermission.updateAvailabilityMetadata);
        final calls = policy.organizerPhases.length;
        await expectLater(
          service.updateAvailabilityMetadata(request()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(policy.organizerPhases.length, calls);
        policy.denied.clear();
        await service.updateAvailabilityMetadata(request());
        expect(
          policy.organizerPhases.last,
          CalendarAuthorizationPhase.finalWrite,
        );
        expect(policy.organizerRequest!.calendarId, rule.calendarId);
        expect(
          policy.organizerRequest!.currentAvailability!.availabilityId,
          rule.id,
        );
        expect(
          policy.organizerRequest!.proposedAvailability!.organizer!.commonName,
          'Åsa',
        );
        rule = await service.getAvailability(rule.id);
        expect(rule.content.organizer!.language, 'SV');
        policy.denyOrganizer = true;
        await expectLater(
          service.updateAvailabilityMetadata(
            CalendarAvailabilityUpdateRequest(
              availabilityId: rule.id,
              expectedRevision: rule.revision,
              content: rule.content.copyWith(organizer: null),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await service.getAvailability(rule.id)).content.organizer,
          isNotNull,
        );
      },
    );
    test('publication extension registry rejects names contexts values and failures atomically', () async {
      var rule = await editableHours();
      CalendarAvailabilityContent withExtension(String name, String value) =>
          rule.content.copyWith(
            extensions: [
              CalendarAvailabilityExtension(name: name, value: value),
            ],
          );
      Future<void> update(CalendarAvailabilityContent content) async {
        await service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: content,
          ),
        );
      }

      await expectLater(
        update(withExtension('X-HOST-LABEL', 'OK')),
        failure(CalendarFailureCode.validation),
      );
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        availabilityExtensions: [
          CalendarAvailabilityExtensionRegistration(
            name: 'X-HOST-LABEL',
            contexts: [CalendarAvailabilityExtensionContext.definition],
            validate: (v) {
              if (v == 'FAIL') throw StateError('Synthetic validator failure');
              return v == 'OK';
            },
          ),
        ],
      );
      service = CalendarModule.service(session);
      await expectLater(
        update(withExtension('X-HOST-LABEL', 'BAD')),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        update(withExtension('X-HOST-LABEL', 'FAIL')),
        failure(CalendarFailureCode.unavailable),
      );
      await expectLater(
        update(
          rule.content.copyWith(
            openings: [
              rule.content.openings.single.copyWith(
                extensions: [
                  CalendarAvailabilityExtension(
                    name: 'X-HOST-LABEL',
                    value: 'OK',
                  ),
                ],
              ),
            ],
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect((await service.getAvailability(rule.id)).revision, rule.revision);
      await update(withExtension('x-host-label', 'OK'));
      rule = await service.getAvailability(rule.id);
      expect(rule.content.extensions!.single.name, 'x-host-label');
      expect(
        () => policy
            .lastAvailabilityRequest!
            .currentAvailability!
            .content
            .extensions!
            .clear(),
        throwsUnsupportedError,
      );
    });
    test('publication annotations survive timing edits and stay out of busy summaries', () async {
      var rule = await editableHours();
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(
            summary: 'Private annotated hours',
            comments: ['One', 'Two'],
            textParameters: CalendarAvailabilityTextParameters(
              summary: CalendarTextParameters(
                language: 'SV',
                alternativeUri: 'cid:private@example.invalid',
              ),
              comments: [
                CalendarTextParameters(language: 'en'),
                CalendarTextParameters(language: 'sv'),
              ],
            ),
          ),
        ),
      );
      rule = await service.getAvailability(rule.id);
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.content.textParameters!.comments![1]!.language, 'sv');
      expect(
        rule.content.textParameters!.summary!.alternativeUri,
        'cid:private@example.invalid',
      );
      await service.updateAvailability(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(priority: 1),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.content.textParameters!.summary!.language, 'SV');
      final result = await service.freeBusy(
        CalendarFreeBusyQuery(
          calendarId: rule.calendarId,
          fromUtc: DateTime.utc(2026, 3, 29),
          untilUtc: DateTime.utc(2026, 3, 30),
        ),
      );
      expect(result.coverage, CalendarFreeBusyCoverage.complete);
      expect(
        result.toJson().toString(),
        isNot(contains('private@example.invalid')),
      );
      await expectLater(
        service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision - 1,
            content: rule.content,
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
    });
    test('opening lifecycle preserves single and future edits through metadata and rejects orphaning pattern changes', () async {
      var rule = await editableHours();
      final uid = rule.content.openings.single.uid;
      final replacement = rule.content.openings.single.timing.copyWith(
        start: CalendarEventCivil(year: 2026, month: 3, day: 29, hour: 10),
        end: CalendarEventCivil(year: 2026, month: 3, day: 29, hour: 18),
      );
      await service.changeAvailabilityOccurrence(
        openingChange(
          rule,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: replacement,
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        (await service.previewAvailabilityOccurrences(openingQuery(rule)))
            .occurrences
            .first
            .start
            .hour,
        10,
      );
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        (await service.previewAvailabilityOccurrences(openingQuery(rule)))
            .occurrences,
        hasLength(2),
      );
      expect(
        (await service.freeBusy(busyQuery(rule.calendarId)))
            .periods
            .single
            .kind,
        CalendarFreeBusyKind.unavailable,
      );
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(description: 'Preserved notes'),
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        rule.timingOverrides!.single.overrides.singles.single.cancelled,
        isTrue,
      );
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.restoreSingle),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        (await service.freeBusy(busyQuery(rule.calendarId)))
            .periods[1]
            .startUtc
            .hour,
        10,
      );
      expect(rule.content.openings.single.uid, uid);
      await expectLater(
        service.updateAvailability(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content.copyWith(
              openings: [
                rule.content.openings.single.copyWith(
                  recurrence: rule.content.openings.single.recurrence!.copyWith(
                    exclusions: [
                      rule.content.openings.single.timing.copyWith(
                        end: null,
                        duration: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.clearSingleTiming),
      );
      rule = await service.getAvailability(rule.id);
      await service.changeAvailabilityOccurrence(
        openingChange(
          rule,
          CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: replacement,
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(
        (await service.previewAvailabilityOccurrences(openingQuery(rule)))
            .occurrences
            .map((o) => o.start.hour),
        [10, 10, 10],
      );
      expect(
        policy.lastAvailabilityRequest!.currentAvailability!.timingOverrides,
        isNotNull,
      );
    });
    test('opening mutation and preview enforce independent rights current revision and complete host intent', () async {
      var rule = await editableHours();
      policy.denied.add(CalendarPermission.changeAvailabilityOccurrence);
      await expectLater(
        service.changeAvailabilityOccurrence(
          openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.denyFinal = true;
      await expectLater(
        service.changeAvailabilityOccurrence(
          openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      expect((await service.getAvailability(rule.id)).timingOverrides, isNull);
      policy.denied.add(CalendarPermission.previewAvailabilityOccurrences);
      await expectLater(
        service.previewAvailabilityOccurrences(openingQuery(rule)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      final old = openingQuery(rule);
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      await expectLater(
        service.previewAvailabilityOccurrences(old),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.changeAvailabilityOccurrence(
          openingChange(rule, CalendarEventOccurrenceAction.restoreSingle),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      rule = await service.getAvailability(rule.id);
      expect(policy.lastAvailabilityRequest!.calendarId, rule.calendarId);
      expect(policy.lastAvailabilityRequest!.availabilityId, rule.id);
      expect(
        () => rule.timingOverrides!.single.overrides.singles.clear(),
        throwsUnsupportedError,
      );
    });
    test('availability metadata is separate authority with exact authorized category search and no availability side effects', () async {
      var rule = await editableHours();
      final before = await service.freeBusy(busyQuery(rule.calendarId));
      final next = rule.content.copyWith(
        description: '  Notes\n',
        location: 'Private room',
        categories: ['Work', 'work', 'Work'],
        comments: ['one\ntwo', 'three'],
        url: 'https://example.invalid/info',
        classification: CalendarAvailabilityClass.confidential,
        openings: [
          rule.content.openings.single.copyWith(
            summary: 'Opening label',
            categories: ['Opening'],
          ),
        ],
      );
      policy.denied.add(CalendarPermission.updateAvailabilityMetadata);
      await expectLater(
        service.updateAvailability(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: next,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.denied.add(CalendarPermission.updateAvailability);
      await service.updateAvailabilityMetadata(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: next,
        ),
      );
      rule = await service.getAvailability(rule.id);
      expect(rule.content.categories, ['Work', 'work']);
      expect(rule.content.comments, ['one\ntwo', 'three']);
      expect(
        (await service.freeBusy(busyQuery(rule.calendarId))).toJson(),
        before.toJson(),
      );
      expect(
        await service.listAvailability(rule.calendarId, category: 'Work'),
        hasLength(1),
      );
      expect(
        await service.listAvailability(rule.calendarId, category: 'WORK'),
        isEmpty,
      );
      expect(
        await service.listAvailability(rule.calendarId, category: 'Opening'),
        hasLength(1),
      );
      await expectLater(
        service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content.copyWith(priority: 1),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      policy.denied.add(CalendarPermission.readAvailability);
      expect(
        await service.listAvailability(rule.calendarId, category: 'Work'),
        isEmpty,
      );
      final json = (await service.freeBusy(busyQuery(rule.calendarId)))
          .toJson()
          .toString();
      expect(json, isNot(contains('Private room')));
      expect(json, isNot(contains('Opening label')));
    });
    test('deleting an opening deliberately removes its edits and invalid metadata never partially commits', () async {
      var rule = await editableHours();
      await service.changeAvailabilityOccurrence(
        openingChange(rule, CalendarEventOccurrenceAction.cancelSingle),
      );
      rule = await service.getAvailability(rule.id);
      await expectLater(
        service.updateAvailabilityMetadata(
          CalendarAvailabilityUpdateRequest(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
            content: rule.content.copyWith(
              url: 'https://user:password@example.invalid',
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect((await service.getAvailability(rule.id)).revision, rule.revision);
      await service.updateAvailability(
        CalendarAvailabilityUpdateRequest(
          availabilityId: rule.id,
          expectedRevision: rule.revision,
          content: rule.content.copyWith(openings: []),
        ),
      );
      expect((await service.getAvailability(rule.id)).timingOverrides, isNull);
    });

    test('availability CRUD has stable identities stale protection markers and parent dependencies', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final receipt = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      final first = await service.getAvailability(receipt.availabilityId);
      expect(first.content.openings.single.uid, isNotNull);
      expect(policy.lastAvailabilityRequest!.calendarId, calendar);
      expect(
        policy.lastAvailabilityRequest!.currentAvailability!.availabilityId,
        first.id,
      );
      await expectLater(
        service.delete(calendar, 1),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final changed = (await service.updateAvailability(
        CalendarAvailabilityUpdateRequest(
          availabilityId: first.id,
          expectedRevision: 1,
          content: first.content.copyWith(summary: 'New hours'),
        ),
      ))!;
      expect(changed.revision, 2);
      final second = await service.getAvailability(first.id);
      expect(second.protocolUid, first.protocolUid);
      expect(
        second.content.openings.single.uid,
        first.content.openings.single.uid,
      );
      expect(second.lastModified.millisecond, 0);
      await expectLater(
        service.updateAvailability(
          CalendarAvailabilityUpdateRequest(
            availabilityId: first.id,
            expectedRevision: 1,
            content: first.content,
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      expect(await service.listAvailability(calendar), hasLength(1));
      await service.deleteAvailability(first.id, 2);
      expect(await service.listAvailability(calendar), isEmpty);
      expect(
        (await CalendarAvailabilityRecord.db.findById(
          session,
          first.id,
        ))!.deletedAt,
        isNotNull,
      );
      expect(
        await CalendarAvailabilityDataRecord.db.findFirstRow(
          session,
          where: (t) => t.availabilityId.equals(first.id),
        ),
        isNull,
      );
      await service.delete(calendar, 1);
    });
    test('availability rules replace fallback and higher priority closures do not erase bookings', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final rule = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      await booking(calendar, 10, 11);
      final result = await service.freeBusy(busyQuery(calendar));
      expect(result.coverage, CalendarFreeBusyCoverage.complete);
      expect(result.periods.map((p) => p.kind), [
        CalendarFreeBusyKind.unavailable,
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.busy,
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.unavailable,
      ]);
      expect(result.periods[1].startUtc, DateTime.utc(2026, 3, 29, 9));
      expect(
        result.toJson().toString(),
        isNot(contains('Private working hours')),
      );
      final closure = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(priority: 5, closed: true),
        ),
      ))!;
      expect(
        (await service.freeBusy(busyQuery(calendar))).periods.single.kind,
        CalendarFreeBusyKind.unavailable,
      );
      await service.deleteAvailability(closure.availabilityId, 1);
      await service.deleteAvailability(rule.availabilityId, 1);
      expect(
        (await service.freeBusy(busyQuery(calendar))).periods.first.kind,
        CalendarFreeBusyKind.free,
      );
    });
    test('availability raw disclosure is independent from complete projection; denial yields unknown', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final rule = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      policy.denied.add(CalendarPermission.readAvailability);
      await expectLater(
        service.getAvailability(rule.availabilityId),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await service.listAvailability(calendar), isEmpty);
      expect(
        (await service.freeBusy(busyQuery(calendar))).coverage,
        CalendarFreeBusyCoverage.complete,
      );
      policy.denied.add(CalendarPermission.projectAvailability);
      final result = await service.freeBusy(busyQuery(calendar));
      expect(result.coverage, CalendarFreeBusyCoverage.unknown);
      expect(result.periods, isEmpty);
    });
    test('availability update denial is atomic frozen and cannot cross scopes or spoof opening identities', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final receipt = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: hours(),
        ),
      ))!;
      final first = await service.getAvailability(receipt.availabilityId);
      policy.onPreliminary = () {
        expect(
          () => policy.lastAvailabilityRequest!.proposedAvailability!.openings
              .clear(),
          throwsUnsupportedError,
        );
        policy.denied.add(CalendarPermission.updateAvailability);
      };
      await expectLater(
        service.updateAvailability(
          CalendarAvailabilityUpdateRequest(
            availabilityId: first.id,
            expectedRevision: 1,
            content: first.content,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.onPreliminary = null;
      policy.denied.clear();
      expect((await service.getAvailability(first.id)).revision, 1);
      await expectLater(
        service.createAvailability(
          CalendarAvailabilityCreateRequest(
            calendarId: calendar,
            content: first.content,
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      policy.scopeOverride = 'other';
      await expectLater(
        service.getAvailability(first.id),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.createAvailability(
          CalendarAvailabilityCreateRequest(
            calendarId: calendar,
            content: hours(),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });

    test('availability named-zone hours survive calendar zone changes and source caps never imply free', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final input = hours().copyWith(
        openings: [
          CalendarAvailabilityOpening(
            timing: hours().openings.single.timing.copyWith(
              kind: CalendarEventTimeKind.zoned,
              zoneId: 'Europe/Stockholm',
            ),
          ),
        ],
      );
      await service.createAvailability(
        CalendarAvailabilityCreateRequest(calendarId: calendar, content: input),
      );
      final before = await service.freeBusy(busyQuery(calendar));
      await service.updateSettings(
        CalendarSettingsUpdateRequest(
          calendarId: calendar,
          expectedRevision: 1,
          availabilityZoneId: 'America/New_York',
          noRuleFallback: CalendarNoRuleFallback.free,
        ),
      );
      expect(
        (await service.freeBusy(busyQuery(calendar))).toJson(),
        before.toJson(),
      );
      expect(before.periods[1].startUtc, DateTime.utc(2026, 3, 29, 7));
      for (var n = 0; n < 4; n++) {
        await service.createAvailability(
          CalendarAvailabilityCreateRequest(
            calendarId: calendar,
            content: hours().copyWith(
              openings: List.generate(16, (_) => hours().openings.single),
            ),
          ),
        );
      }
      final limited = await service.freeBusy(busyQuery(calendar));
      expect(limited.coverage, CalendarFreeBusyCoverage.unknown);
      expect(limited.periods, isEmpty);
    });

    test('free busy merges private overlapping bookings and retains tentative classification', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final first = await booking(calendar, 9, 11);
      await booking(calendar, 10, 12, status: CalendarEventStatus.tentative);
      await booking(calendar, 13, 14);
      await booking(calendar, 14, 15);
      await booking(
        calendar,
        16,
        17,
        transparency: CalendarEventTransparency.transparent,
      );
      await booking(calendar, 18, 19, status: CalendarEventStatus.cancelled);
      final before = await service.getEvent(first.eventId, eventGroups);
      final result = await service.freeBusy(busyQuery(calendar));
      expect(result.coverage, CalendarFreeBusyCoverage.complete);
      expect(result.periods.map((p) => p.kind), [
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.busy,
        CalendarFreeBusyKind.tentative,
        CalendarFreeBusyKind.free,
        CalendarFreeBusyKind.busy,
        CalendarFreeBusyKind.free,
      ]);
      expect(result.periods[1].startUtc, DateTime.utc(2026, 3, 29, 9));
      expect(result.periods[1].endUtc, DateTime.utc(2026, 3, 29, 11));
      expect(result.periods[4].endUtc, DateTime.utc(2026, 3, 29, 15));
      final wire = result.toJson().toString();
      expect(wire, isNot(contains('Private')));
      expect(wire, isNot(contains(first.eventId.toString())));
      final after = await service.getEvent(first.eventId, eventGroups);
      expect(after.revision, before.revision);
      expect(after.lastModified, before.lastModified);
    });
    test('free busy is independent of detail plans; denied required projections return unknown without partial periods', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      await booking(calendar, 9, 11);
      final second = await booking(calendar, 13, 14);
      policy.denied.addAll([
        CalendarPermission.read,
        CalendarPermission.readEvent,
        CalendarPermission.listEvents,
      ]);
      policy.eventCandidates = {};
      policy.eventGrants = {};
      policy.grants = {};
      expect(
        (await service.freeBusy(busyQuery(calendar))).periods
            .where((p) => p.kind == CalendarFreeBusyKind.busy)
            .length,
        2,
      );
      expect(policy.lastEventRequest!.freeBusyQuery!.calendarId, calendar);
      expect(policy.lastEventRequest!.currentEvent!.calendarId, calendar);
      policy.busyDenied.add(second.eventId);
      final unknown = await service.freeBusy(busyQuery(calendar));
      expect(unknown.coverage, CalendarFreeBusyCoverage.unknown);
      expect(unknown.periods, isEmpty);
      policy.denied.add(CalendarPermission.readFreeBusy);
      await expectLater(
        service.freeBusy(busyQuery(calendar)),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('free busy DATE recurrence uses calendar zone, moved original identity and single cancellation', () async {
      final id = await recurringEvent();
      final view = await service.getEvent(id, eventGroups);
      final q = CalendarFreeBusyQuery(
        calendarId: view.calendarId,
        fromUtc: DateTime.utc(2026, 3, 28),
        untilUtc: DateTime.utc(2026, 4, 1),
      );
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: day(28),
        ),
      );
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.cancelSingle,
          revision: 2,
          dayNumber: 31,
        ),
      );
      final result = await service.freeBusy(q);
      final occupied = result.periods
          .where((p) => p.kind == CalendarFreeBusyKind.busy)
          .single;
      expect(occupied.startUtc, q.fromUtc);
      expect(occupied.endUtc, DateTime.utc(2026, 3, 29, 22));
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.cancelSingle,
          revision: 3,
        ),
      );
      final after = await service.freeBusy(q);
      expect(
        after.periods
            .singleWhere((p) => p.kind == CalendarFreeBusyKind.busy)
            .endUtc
            .difference(
              after.periods
                  .singleWhere((p) => p.kind == CalendarFreeBusyKind.busy)
                  .startUtc,
            ),
        const Duration(hours: 23),
      );
    });
    test('free busy uses configured no-rule fallback without pretending working-hours support', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      expect(
        (await service.freeBusy(busyQuery(calendar))).periods.single.kind,
        CalendarFreeBusyKind.free,
      );
      await service.updateSettings(
        CalendarSettingsUpdateRequest(
          calendarId: calendar,
          expectedRevision: 1,
          availabilityZoneId: 'Europe/Stockholm',
          noRuleFallback: CalendarNoRuleFallback.unavailable,
        ),
      );
      await booking(calendar, 9, 10);
      final result = await service.freeBusy(busyQuery(calendar));
      expect(result.coverage, CalendarFreeBusyCoverage.complete);
      expect(result.periods.single.kind, CalendarFreeBusyKind.unavailable);
    });
    test(
      'free busy source or recurrence caps cannot yield falsely free results',
      () async {
        final calendar = (await service.create(createInput()))!.calendarId;
        await booking(calendar, 9, 10);
        await booking(calendar, 11, 12);
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
            maxScannedEvents: 1,
          ),
        );
        service = CalendarModule.service(session);
        final limited = await service.freeBusy(busyQuery(calendar));
        expect(limited.coverage, CalendarFreeBusyCoverage.unknown);
        expect(limited.periods, isEmpty);
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          ),
        );
        // A new service observes installation options, not the previously captured runtime.
        service = CalendarModule.service(session);
        final dense = (await service.createEvent(
          CalendarEventCreateRequest(
            calendarId: calendar,
            content: CalendarEventContent(
              timing: CalendarEventTiming(
                kind: CalendarEventTimeKind.utc,
                start: CalendarEventCivil(year: 2026, month: 3, day: 29),
                duration: CalendarEventDuration(minutes: 1),
              ),
              recurrence: CalendarEventRecurrence(
                rule: daily().copyWith(
                  frequency: CalendarEventFrequency.minutely,
                  count: null,
                ),
                inclusions: [],
                exclusions: [],
              ),
            ),
          ),
        ))!;
        final unknown = await service.freeBusy(busyQuery(calendar));
        expect(unknown.coverage, CalendarFreeBusyCoverage.unknown);
        expect(unknown.periods, isEmpty);
        expect(
          (await service.getEvent(dense.eventId, eventGroups)).revision,
          1,
        );
      },
    );
    test('free busy validates UTC precision and bounded increasing windows and protects actual scope', () async {
      final calendar = (await service.create(createInput()))!.calendarId;
      final q = busyQuery(calendar);
      for (final bad in [
        q.copyWith(fromUtc: DateTime(2026, 3, 29)),
        q.copyWith(fromUtc: DateTime.utc(2026, 3, 29, 0, 0, 0, 1)),
        q.copyWith(untilUtc: q.fromUtc),
        q.copyWith(untilUtc: DateTime.utc(2026, 5, 1)),
      ]) {
        await expectLater(
          service.freeBusy(bad),
          failure(CalendarFailureCode.validation),
        );
      }
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      await expectLater(
        CalendarModule.service(bobSession).freeBusy(q),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('occurrence timing persists separately; cancellation restores prior timing without master changes', () async {
      final id = await recurringEvent();
      final before = await service.getEvent(id, eventGroups);
      final parent = await service.get(before.calendarId, groups);
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: day(28),
        ),
      );
      var view = await service.getEvent(id, eventGroups);
      expect(view.timing!.start.day, 29);
      expect(view.timingOverrides!.singles.single.replacement!.start.day, 28);
      expect(
        (await service.previewOccurrences(preview(id, revision: 2)))
            .occurrences
            .first
            .originalStart
            .day,
        30,
      );
      expect(
        policy.lastEventRequest!.currentEvent!.timingOverrides!.singles.length,
        1,
      );
      expect(
        () => policy.lastEventRequest!.currentEvent!.timingOverrides!.singles
            .clear(),
        throwsUnsupportedError,
      );
      policy.denied.add(CalendarPermission.updateEvent);
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.cancelSingle,
          revision: 2,
        ),
      );
      expect(
        (await service.previewOccurrences(preview(id, revision: 3)))
            .occurrences
            .length,
        2,
      );
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.restoreSingle,
          revision: 3,
        ),
      );
      view = await service.getEvent(id, eventGroups);
      expect(view.timingOverrides!.singles.single.replacement!.start.day, 28);
      expect(view.protocolUid, before.protocolUid);
      expect(view.revision, 4);
      expect(
        (await service.get(view.calendarId, groups)).updatedAt,
        parent.updatedAt,
      );
    });
    test('occurrence action permissions and immutable actual proposed context apply at final checks', () async {
      final id = await recurringEvent();
      policy.denied.add(CalendarPermission.changeEventStatus);
      await expectLater(
        service.changeOccurrence(
          occurrenceChange(id, CalendarEventOccurrenceAction.cancelSingle),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: day(31),
        ),
      );
      expect(
        policy.lastEventRequest!.occurrenceChange!.action,
        CalendarEventOccurrenceAction.replaceFutureTiming,
      );
      expect(policy.lastEventRequest!.currentEvent!.eventId, id);
      expect(
        policy.lastEventRequest!.current!.calendarId,
        policy.lastEventRequest!.calendarId,
      );
      expect(
        policy
            .lastEventRequest!
            .proposedTimingOverrides!
            .future
            .single
            .originalStart
            .start
            .day,
        30,
      );
      expect(
        () => policy.lastEventRequest!.proposedTimingOverrides!.future.clear(),
        throwsUnsupportedError,
      );
      policy.denied.clear();
      policy.denied.add(CalendarPermission.updateEvent);
      await expectLater(
        service.changeOccurrence(
          occurrenceChange(
            id,
            CalendarEventOccurrenceAction.clearFutureTiming,
            revision: 2,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      // Restore permission cannot erase timing. Cancellation at the exact range anchor rejects ambiguity.
      await expectLater(
        service.changeOccurrence(
          occurrenceChange(
            id,
            CalendarEventOccurrenceAction.cancelSingle,
            revision: 2,
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
    });
    test('occurrence overrides survive master edits and reject orphaning or incompatible profiles', () async {
      final id = await recurringEvent();
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: day(28),
        ),
      );
      final c = eventInput(summary: 'Master edit').copyWith(
        recurrence: CalendarEventRecurrence(
          rule: daily(),
          inclusions: [],
          exclusions: [],
        ),
      );
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 2,
          content: c,
        ),
      );
      var current = await service.getEvent(id, eventGroups);
      expect(current.timingOverrides!.singles.length, 1);
      expect(current.summary, 'Master edit');
      for (final bad in [
        c.copyWith(recurrence: c.recurrence!.copyWith(rule: daily(count: 1))),
        c.copyWith(timing: c.timing.copyWith(kind: CalendarEventTimeKind.utc)),
        c.copyWith(recurrence: c.recurrence!.copyWith(exclusions: [day(30)])),
      ]) {
        await expectLater(
          service.updateEvent(
            CalendarEventUpdateRequest(
              eventId: id,
              expectedRevision: 3,
              content: bad,
              replaceRecurrenceDates: true,
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
      }
      current = await service.getEvent(id, eventGroups);
      expect(current.revision, 3);
      await service.changeOccurrence(
        occurrenceChange(
          id,
          CalendarEventOccurrenceAction.clearSingleTiming,
          revision: 3,
        ),
      );
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 4,
          content: c.copyWith(
            recurrence: c.recurrence!.copyWith(rule: daily(count: 1)),
          ),
        ),
      );
      expect((await service.getEvent(id, eventGroups)).timingOverrides, isNull);
    });
    test('occurrence stale final-denied and post-write failures roll back timing content revision and time', () async {
      final id = await recurringEvent();
      final before = await service.getEvent(id, eventGroups);
      final request = occurrenceChange(
        id,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: day(28),
      );
      policy.denyFinal = true;
      await expectLater(
        service.changeOccurrence(request),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      await expectLater(
        service.changeOccurrence(request.copyWith(expectedRevision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      final scope = (await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      ))!;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.changeOccurrence(request),
        failure(CalendarFailureCode.limitExceeded),
      );
      final after = await service.getEvent(id, eventGroups);
      expect(after.revision, before.revision);
      expect(after.lastModified, before.lastModified);
      expect(after.timingOverrides, isNull);
      expect(after.protocolUid, before.protocolUid);
    });
    test('occurrence timing disclosure scope boundaries and payload deletion remain protected', () async {
      final id = await recurringEvent();
      await service.changeOccurrence(
        occurrenceChange(id, CalendarEventOccurrenceAction.cancelSingle),
      );
      policy.eventGrants = {CalendarEventFieldGroup.summary};
      expect((await service.getEvent(id, eventGroups)).timingOverrides, isNull);
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      await expectLater(
        CalendarModule.service(bobSession).changeOccurrence(
          occurrenceChange(
            id,
            CalendarEventOccurrenceAction.restoreSingle,
            revision: 2,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.eventGrants = eventGroups.toSet();
      await service.deleteEvent(id, 2);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      final marker = (await CalendarEventRecord.db.findById(session, id))!;
      expect(marker.deletedAt, isNotNull);
      await expectLater(
        service.changeOccurrence(
          occurrenceChange(
            id,
            CalendarEventOccurrenceAction.restoreSingle,
            revision: 3,
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('recurrence persists canonically, previews actual identity and preserves explicit dates on pattern replacement', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final c = eventInput().copyWith(
        recurrence: CalendarEventRecurrence(
          rule: daily(),
          inclusions: [day(27), day(27)],
          exclusions: [day(30)],
        ),
      );
      final receipt = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: c),
      ))!;
      final first = await service.getEvent(receipt.eventId, eventGroups);
      expect(first.recurrence!.inclusions.length, 1);
      final result = await service.previewOccurrences(preview(receipt.eventId));
      expect(result.occurrences.map((v) => v.originalStart.day), [27, 29, 31]);
      expect(policy.lastEventRequest!.eventId, receipt.eventId);
      expect(policy.lastEventRequest!.calendarId, parent);
      expect(
        policy.lastEventRequest!.occurrenceQuery!.eventId,
        receipt.eventId,
      );
      expect(
        () => policy
            .lastEventRequest!
            .currentEvent!
            .content
            .recurrence!
            .inclusions
            .clear(),
        throwsUnsupportedError,
      );
      expect(
        () => policy
            .lastEventRequest!
            .currentEvent!
            .content
            .recurrence!
            .rule!
            .byDay
            .clear(),
        throwsUnsupportedError,
      );
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: receipt.eventId,
          expectedRevision: 1,
          content: eventInput().copyWith(
            recurrence: CalendarEventRecurrence(
              rule: daily(count: 2),
              inclusions: [],
              exclusions: [],
            ),
          ),
        ),
      );
      final changed = await service.getEvent(receipt.eventId, eventGroups);
      expect(changed.recurrence!.inclusions.single.start.day, 27);
      expect(changed.recurrence!.exclusions.single.start.day, 30);
      expect(changed.protocolUid, first.protocolUid);
      await expectLater(
        service.previewOccurrences(preview(receipt.eventId)),
        failure(CalendarFailureCode.staleRevision),
      );
      expect(
        (await service.previewOccurrences(
          preview(receipt.eventId, revision: 2),
        )).occurrences.map((v) => v.start.day),
        [27, 29],
      );
    });
    test('incompatible pattern changes reject atomically; explicit replacement can clear dates', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final receipt = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput().copyWith(
            recurrence: CalendarEventRecurrence(
              rule: daily(),
              inclusions: [day(27)],
              exclusions: [],
            ),
          ),
        ),
      ))!;
      final change = CalendarEventUpdateRequest(
        eventId: receipt.eventId,
        expectedRevision: 1,
        content: eventInput().copyWith(
          timing: day(29, kind: CalendarEventTimeKind.utc),
        ),
      );
      await expectLater(
        service.updateEvent(change),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await service.getEvent(receipt.eventId, eventGroups)).revision,
        1,
      );
      policy.denyFinal = true;
      await expectLater(
        service.updateEvent(change.copyWith(replaceRecurrenceDates: true)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      expect(
        (await service.getEvent(
          receipt.eventId,
          eventGroups,
        )).recurrence!.inclusions.length,
        1,
      );
      await service.updateEvent(change.copyWith(replaceRecurrenceDates: true));
      expect(
        (await service.getEvent(receipt.eventId, eventGroups)).recurrence,
        isNull,
      );
    });
    test('preview requires both read and preview rights, timing disclosure and actual scope', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
      ))!.eventId;
      for (final permission in [
        CalendarPermission.readEvent,
        CalendarPermission.previewEventOccurrences,
      ]) {
        policy.denied
          ..clear()
          ..add(permission);
        await expectLater(
          service.previewOccurrences(preview(id)),
          failure(CalendarFailureCode.accessDenied),
        );
      }
      policy.denied.clear();
      policy.eventGrants = {CalendarEventFieldGroup.summary};
      await expectLater(
        service.previewOccurrences(preview(id)),
        failure(CalendarFailureCode.accessDenied),
      );
      final hidden = await service.getEvent(id, eventGroups);
      expect(hidden.timing, isNull);
      expect(hidden.recurrence, isNull);
      policy.eventGrants = eventGroups.toSet();
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      await expectLater(
        CalendarModule.service(bobSession).previewOccurrences(preview(id)),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test(
      'preview caps fail explicitly without changing event revision or time',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final input = eventInput().copyWith(
          timing: day(29, kind: CalendarEventTimeKind.utc),
          recurrence: CalendarEventRecurrence(
            rule: daily().copyWith(
              frequency: CalendarEventFrequency.minutely,
              count: null,
            ),
            inclusions: [],
            exclusions: [],
          ),
        );
        final id = (await service.createEvent(
          CalendarEventCreateRequest(calendarId: parent, content: input),
        ))!.eventId;
        final before = await service.getEvent(id, eventGroups);
        await expectLater(
          service.previewOccurrences(
            CalendarEventOccurrenceQuery(
              eventId: id,
              expectedRevision: 1,
              fromUtc: DateTime.utc(2026, 3, 29),
              untilUtc: DateTime.utc(2026, 3, 30),
            ),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        final after = await service.getEvent(id, eventGroups);
        expect(after.revision, before.revision);
        expect(after.lastModified, before.lastModified);
      },
    );
    test('previous non-recurring JSON payload upgrades without changing event identities', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final id = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
      ))!.eventId;
      final before = await service.getEvent(id, eventGroups);
      // Previous serializer wrote recurring:false and no recurrence property.
      await session.db.unsafeQuery(
        "UPDATE serverpod_calendar_event_data SET content = (content::jsonb - 'recurrence') || '{\"recurring\":false}'::jsonb WHERE \"eventId\" = '$id'",
      );
      final after = await service.getEvent(id, eventGroups);
      expect(after.recurrence, isNull);
      expect(after.protocolUid, before.protocolUid);
      expect(after.revision, before.revision);
      expect(after.lastModified, before.lastModified);
    });
    test('event lifecycle preserves UID, separates cancel/delete and blocks parent deletion', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final calendar = await service.get(parent, groups);
      final receipt = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
      ))!;
      final first = await service.getEvent(receipt.eventId, eventGroups);
      expect(first.summary, isNull);
      expect(first.timing!.kind, CalendarEventTimeKind.date);
      expect(first.protocolUid, isNot(receipt.eventId.toString()));
      await expectLater(
        service.delete(parent, 1),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.changeEventStatus(
        CalendarEventStatusRequest(
          eventId: receipt.eventId,
          expectedRevision: 1,
          status: CalendarEventStatus.cancelled,
        ),
      );
      expect(
        (await service.getEvent(receipt.eventId, eventGroups)).status,
        CalendarEventStatus.cancelled,
      );
      await expectLater(
        service.delete(parent, 1),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.changeEventStatus(
        CalendarEventStatusRequest(
          eventId: receipt.eventId,
          expectedRevision: 2,
          status: CalendarEventStatus.tentative,
        ),
      );
      final after = await service.getEvent(receipt.eventId, eventGroups);
      expect(after.protocolUid, first.protocolUid);
      expect(after.lastModified!.isBefore(first.lastModified!), isFalse);
      expect((await service.get(parent, groups)).updatedAt, calendar.updatedAt);
      expect((await service.get(parent, groups)).revision, 1);
      await service.deleteEvent(receipt.eventId, 3);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      final marker = (await CalendarEventRecord.db.findById(
        session,
        receipt.eventId,
      ))!;
      expect(marker.toJson().keys.toSet(), {
        '__className__',
        'id',
        'calendarId',
        'revision',
        'deletedAt',
      });
      await expectLater(
        service.getEvent(receipt.eventId, eventGroups),
        failure(CalendarFailureCode.accessDenied),
      );
      await service.delete(parent, 1);
    });
    test('event edit cannot bypass separate lifecycle checks including cancelled creation', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final event = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Original'),
        ),
      ))!;
      policy.denied.add(CalendarPermission.changeEventStatus);
      await expectLater(
        service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: event.eventId,
            expectedRevision: 1,
            content: eventInput(status: CalendarEventStatus.cancelled),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.createEvent(
          CalendarEventCreateRequest(
            calendarId: parent,
            content: eventInput(status: CalendarEventStatus.cancelled),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarEventRecord.db.count(session), 1);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: event.eventId,
          expectedRevision: 1,
          content: eventInput(summary: 'Edited'),
        ),
      );
      policy.denied.clear();
      policy.denied.add(CalendarPermission.updateEvent);
      await service.changeEventStatus(
        CalendarEventStatusRequest(
          eventId: event.eventId,
          expectedRevision: 2,
          status: CalendarEventStatus.cancelled,
        ),
      );
      expect(
        (await service.getEvent(event.eventId, eventGroups)).summary,
        'Edited',
      );
    });
    test('event context and disclosure are independent of calendar metadata rights', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final event = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Private'),
        ),
      ))!;
      policy.denied.add(CalendarPermission.read);
      policy.eventGrants = {CalendarEventFieldGroup.timing};
      final view = await service.getEvent(event.eventId, eventGroups);
      expect(view.summary, isNull);
      expect(view.status, isNull);
      expect(view.protocolUid, isNull);
      expect(view.timing, isNotNull);
      expect(policy.lastEventRequest!.calendarId, parent);
      expect(policy.lastEventRequest!.current!.calendarId, parent);
      expect(policy.lastEventRequest!.currentEvent!.eventId, event.eventId);
      expect(policy.lastEventRequest!.currentEvent!.content.summary, 'Private');
      expect(
        () => policy.lastEventRequest!.eventGroups.clear(),
        throwsUnsupportedError,
      );
      policy.denied.add(CalendarPermission.readEvent);
      await expectLater(
        service.getEvent(event.eventId, eventGroups),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await service.listEvents(
          parent,
          pageSize: 10,
          fieldGroups: eventGroups,
        )).events,
        isEmpty,
      );
    });
    test('event scopes and host candidate constraints cannot disclose other parents', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final other = (await service.create(createInput()))!.calendarId;
      final event = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
      ))!;
      policy.eventCandidates = {event.eventId};
      expect(
        (await service.listEvents(
          other,
          pageSize: 10,
          fieldGroups: eventGroups,
        )).events,
        isEmpty,
      );
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      final bob = CalendarModule.service(bobSession);
      await expectLater(
        bob.getEvent(event.eventId, eventGroups),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        bob.createEvent(
          CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.eventCandidates = {};
      expect(
        (await service.listEvents(
          parent,
          pageSize: 10,
          fieldGroups: eventGroups,
        )).events,
        isEmpty,
      );
    });
    test(
      'event cursors bind query kind parent groups policy data and page size',
      () async {
        final parent = (await service.create(createInput()))!.calendarId;
        final other = (await service.create(createInput()))!.calendarId;
        for (var i = 0; i < 3; i++) {
          await service.createEvent(
            CalendarEventCreateRequest(
              calendarId: parent,
              content: eventInput(),
            ),
          );
        }
        final page = await service.listEvents(
          parent,
          pageSize: 1,
          fieldGroups: eventGroups,
        );
        expect(page.nextCursor, isNotNull);
        final next = await service.listEvents(
          parent,
          pageSize: 1,
          fieldGroups: eventGroups,
          cursor: page.nextCursor,
        );
        expect(next.events.single.id, isNot(page.events.single.id));
        await expectLater(
          service.listEvents(
            other,
            pageSize: 1,
            fieldGroups: eventGroups,
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        await expectLater(
          service.listEvents(
            parent,
            pageSize: 2,
            fieldGroups: eventGroups,
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        await expectLater(
          service.listEvents(
            parent,
            pageSize: 1,
            fieldGroups: [],
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        await expectLater(
          service.list(
            pageSize: 1,
            fieldGroups: groups,
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        final calendars = await service.list(pageSize: 1, fieldGroups: groups);
        await expectLater(
          service.listEvents(
            parent,
            pageSize: 1,
            fieldGroups: eventGroups,
            cursor: calendars.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        policy.epoch = 'changed';
        await expectLater(
          service.listEvents(
            parent,
            pageSize: 1,
            fieldGroups: eventGroups,
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        policy.epoch = 'v1';
        await service.changeEventStatus(
          CalendarEventStatusRequest(
            eventId: page.events.single.id,
            expectedRevision: 1,
            status: CalendarEventStatus.cancelled,
          ),
        );
        await expectLater(
          service.listEvents(
            parent,
            pageSize: 1,
            fieldGroups: eventGroups,
            cursor: page.nextCursor,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
      },
    );
    test('event hidden scan exhaustion fails instead of reporting an empty complete list', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      for (var i = 0; i < 3; i++) {
        await service.createEvent(
          CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
        );
      }
      policy.denied.add(CalendarPermission.readEvent);
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          maxScannedEvents: 2,
        ),
      );
      await expectLater(
        CalendarModule.service(session)
            .listEvents(parent, pageSize: 1, fieldGroups: eventGroups),
        failure(CalendarFailureCode.limitExceeded),
      );
    });
    test('invalid stale final-denied and post-write-failed event commands are atomic', () async {
      final parent = (await service.create(createInput()))!.calendarId;
      final event = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Before'),
        ),
      ))!;
      final before = await service.getEvent(event.eventId, eventGroups);
      final update = CalendarEventUpdateRequest(
        eventId: event.eventId,
        expectedRevision: 1,
        content: eventInput(summary: 'After'),
      );
      policy.denyFinal = true;
      await expectLater(
        service.updateEvent(update),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      await expectLater(
        service.updateEvent(update.copyWith(expectedRevision: 2)),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.updateEvent(
          update.copyWith(
            content: update.content.copyWith(
              timing: update.content.timing.copyWith(
                kind: CalendarEventTimeKind.floating,
              ),
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      final scope = (await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      ))!;
      scope.revision = 9007199254740991;
      await CalendarScopeRecord.db.updateRow(session, scope);
      await expectLater(
        service.updateEvent(update),
        failure(CalendarFailureCode.limitExceeded),
      );
      final after = await service.getEvent(event.eventId, eventGroups);
      expect(after.summary, before.summary);
      expect(after.revision, 1);
      expect(after.lastModified, before.lastModified);
      expect(after.protocolUid, before.protocolUid);
    });
    test(
      'protocol identity is stable, separate and independently disclosed',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        final other = (await service.create(createInput()))!.calendarId;
        final first = await service.get(id, groups);
        final identity = first.protocolIdentity!;
        expect(
          identity.uid,
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
            ),
          ),
        );
        expect(identity.uid, isNot(id.toString()));
        expect(
          identity.uid,
          isNot((await service.get(other, groups)).protocolIdentity!.uid),
        );
        expect(identity.lastModified.isUtc, isTrue);
        expect(identity.lastModified.millisecond, 0);
        expect(identity.lastModified.microsecond, 0);
        final only = await service.get(id, [
          CalendarFieldGroup.protocolIdentity,
        ]);
        expect(only.protocolIdentity, identity);
        expect(policy.lastSnapshot!.protocolIdentity, identity);
        expect(only.displayName, isNull);
        expect(only.protocolMetadata, isNull);
        expect(only.supplementalMetadata, isNull);
        expect(only.updatedAt, isNull);
        expect(
          (await service.get(id, [
            CalendarFieldGroup.protocolMetadata,
          ])).protocolIdentity,
          isNull,
        );
        policy.grants = {CalendarFieldGroup.metadata};
        expect((await service.get(id, groups)).protocolIdentity, isNull);
        expect(
          (await service.list(
            pageSize: 10,
            fieldGroups: groups,
          )).calendars.every((v) => v.protocolIdentity == null),
          isTrue,
        );
        policy.grants = groups.toSet();
        expect((await service.get(id, groups)).protocolIdentity, identity);
      },
    );
    test('every calendar mutation touches automatic revision time without changing UID', () async {
      final id = (await service.create(createInput()))!.calendarId;
      final uid = (await service.get(id, groups)).protocolIdentity!.uid;
      var revision = 1;
      final mutations = <Future<dynamic> Function()>[
        () => service.updateMetadata(
          CalendarMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            displayName: 'Renamed',
          ),
        ),
        () => service.updatePresentation(
          CalendarPresentationUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            displayName: 'Presented',
            description: 'Notes',
            color: '#112233',
          ),
        ),
        () => service.updateProtocolMetadata(
          CalendarProtocolMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            metadata: CalendarProtocolMetadata(
              names: [],
              descriptions: [],
              color: 'red',
            ),
          ),
        ),
        () => service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            metadata: CalendarSupplementalMetadata(
              url: 'https://example.invalid/calendar',
              categories: [],
              images: [],
            ),
          ),
        ),
        () => service.updateSettings(
          CalendarSettingsUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            availabilityZoneId: 'UTC',
            noRuleFallback: CalendarNoRuleFallback.unavailable,
          ),
        ),
        for (final action in [
          CalendarSubjectAction.attach,
          CalendarSubjectAction.setContribution,
          CalendarSubjectAction.detach,
        ])
          () => service.changeSubject(
            CalendarSubjectChangeRequest(
              calendarId: id,
              expectedRevision: revision,
              action: action,
              namespace: 'fixture',
              kind: 'room',
              externalId: 'one',
              contributesAvailability: action == CalendarSubjectAction.attach,
            ),
          ),
      ];
      for (final change in mutations) {
        final row = (await CalendarDataRecord.db.findFirstRow(
          session,
          where: (t) => t.calendarId.equals(id),
        ))!;
        row.updatedAt = DateTime.utc(2020, 1, 1, 0, 0, 0, 123, 456);
        await CalendarDataRecord.db.updateRow(session, row);
        final before =
            (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                    .single
                    .single
                as DateTime;
        await change();
        revision++;
        final after = await service.get(id, groups);
        expect(after.revision, revision);
        expect(after.protocolIdentity!.uid, uid);
        expect(after.updatedAt!.isBefore(before), isFalse);
        expect(
          after.protocolIdentity!.lastModified.isBefore(
            before.subtract(const Duration(seconds: 1)),
          ),
          isFalse,
        );
        expect(
          after.protocolIdentity!.lastModified.isAfter(after.updatedAt!),
          isFalse,
        );
        expect(
          after.updatedAt!.difference(after.protocolIdentity!.lastModified),
          lessThan(const Duration(seconds: 1)),
        );
      }
    });
    test('clock correction preserves time while same-second revisions still advance', () async {
      final id = (await service.create(createInput()))!.calendarId;
      final row = (await CalendarDataRecord.db.findFirstRow(
        session,
        where: (t) => t.calendarId.equals(id),
      ))!;
      row.updatedAt = DateTime.utc(2080, 4, 5, 12, 34, 59, 987, 654);
      await CalendarDataRecord.db.updateRow(session, row);
      final original = await service.get(id, groups);
      for (final revision in [1, 2]) {
        await service.updateMetadata(
          CalendarMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: revision,
            displayName: 'Same label',
          ),
        );
        final view = await service.get(id, groups);
        expect(view.revision, revision + 1);
        expect(view.updatedAt, row.updatedAt);
        expect(
          view.protocolIdentity!.lastModified,
          DateTime.utc(2080, 4, 5, 12, 34, 59),
        );
        expect(view.protocolIdentity!.uid, original.protocolIdentity!.uid);
      }
    });
    test(
      'failed writes and reads preserve protocol identity and revision time',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        final before = await service.get(id, groups);
        final command = CalendarMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          displayName: 'Denied',
        );
        policy.denyFinal = true;
        await expectLater(
          service.updateMetadata(command),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denyFinal = false;
        command.expectedRevision = 2;
        await expectLater(
          service.updateMetadata(command),
          failure(CalendarFailureCode.staleRevision),
        );
        command.expectedRevision = 1;
        command.displayName = ' ';
        await expectLater(
          service.updateMetadata(command),
          failure(CalendarFailureCode.validation),
        );
        await service.list(pageSize: 10, fieldGroups: groups);
        final after = await service.get(id, groups);
        expect(after.protocolIdentity, before.protocolIdentity);
        expect(after.updatedAt, before.updatedAt);
        expect(after.revision, 1);
        await service.delete(id, 1);
        expect(
          await CalendarDataRecord.db.findFirstRow(
            session,
            where: (t) => t.calendarId.equals(id),
          ),
          isNull,
        );
        final marker = (await CalendarIdentityRecord.db.findById(session, id))!;
        expect(marker.toJson().containsKey('protocolUid'), isFalse);
        expect(marker.toJson().containsKey('lastModified'), isFalse);
      },
    );
    test(
      'duplicate names, independent fields and content-free deletion marker',
      () async {
        final first = (await service.create(createInput('  Shared  ')))!;
        final second = (await service.create(createInput('Shared')))!;
        expect(first.calendarId, isNot(second.calendarId));
        final view = await service.get(first.calendarId, groups);
        expect(view.displayName, 'Shared');
        expect(view.revision, 1);
        await service.delete(first.calendarId, 1);
        expect(
          await CalendarDataRecord.db.findFirstRow(
            session,
            where: (t) => t.calendarId.equals(first.calendarId),
          ),
          isNull,
        );
        final marker = (await CalendarIdentityRecord.db.findById(
          session,
          first.calendarId,
        ))!;
        expect(marker.revision, 2);
        expect(marker.deletedAt, isNotNull);
        expect(marker.toJson().keys.toSet(), {
          '__className__',
          'id',
          'scopeKey',
          'revision',
          'deletedAt',
        });
        await expectLater(
          service.get(first.calendarId, groups),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await service.list(
            pageSize: 10,
            fieldGroups: groups,
          )).calendars.single.id,
          second.calendarId,
        );
      },
    );
    test(
      'stale revision and settings permission are independent from rename',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        policy.denied.add(CalendarPermission.updateAvailabilitySettings);
        await service.updateMetadata(
          CalendarMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            displayName: 'Renamed',
          ),
        );
        await expectLater(
          service.updateSettings(
            CalendarSettingsUpdateRequest(
              calendarId: id,
              expectedRevision: 2,
              availabilityZoneId: 'UTC',
              noRuleFallback: CalendarNoRuleFallback.unavailable,
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          service.updateMetadata(
            CalendarMetadataUpdateRequest(
              calendarId: id,
              expectedRevision: 1,
              displayName: 'Stale',
            ),
          ),
          failure(CalendarFailureCode.staleRevision),
        );
        expect((await service.get(id, groups)).displayName, 'Renamed');
      },
    );
    test('actual object snapshots and field groups restrict object reads and pages', () async {
      final a = (await service.create(createInput('Hidden')))!;
      final b = (await service.create(createInput('Visible')))!;
      policy.hidden.add(a.calendarId);
      policy.grants = {CalendarFieldGroup.metadata};
      final page = await service.list(pageSize: 1, fieldGroups: groups);
      expect(page.calendars.single.id, b.calendarId);
      expect(page.nextCursor, isNull);
      expect(page.calendars.single.availabilityZoneId, isNull);
      expect(page.calendars.single.disclosedGroups, [
        CalendarFieldGroup.metadata,
      ]);
      await expectLater(
        service.get(a.calendarId, groups),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(policy.sawActualSnapshot, isTrue);
    });
    test('trusted scope isolates calendars even with the same label', () async {
      final id = (await service.create(createInput()))!.calendarId;
      final bobSession = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      final bob = CalendarModule.service(bobSession);
      await expectLater(
        bob.get(id, groups),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await bob.list(pageSize: 10, fieldGroups: groups)).calendars,
        isEmpty,
      );
    });
    test(
      'association changes block deletion and advance one revision',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        CalendarSubjectChangeRequest change(
          CalendarSubjectAction action,
          int revision,
        ) => CalendarSubjectChangeRequest(
          calendarId: id,
          expectedRevision: revision,
          action: action,
          namespace: 'host',
          kind: 'room',
          externalId: 'R1',
          contributesAvailability: true,
        );
        await service.changeSubject(change(CalendarSubjectAction.attach, 1));
        expect((await service.subjects(id)).single.externalId, 'R1');
        await expectLater(
          service.delete(id, 2),
          failure(CalendarFailureCode.dependencyConflict),
        );
        await service.changeSubject(change(CalendarSubjectAction.detach, 2));
        expect((await service.delete(id, 3))!.revision, 4);
      },
    );
    test(
      'final denial rolls back without changing data or aggregate revision',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        policy.denyFinal = true;
        await expectLater(
          service.updateMetadata(
            CalendarMetadataUpdateRequest(
              calendarId: id,
              expectedRevision: 1,
              displayName: 'Denied',
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        final view = await service.get(id, groups);
        expect(view.revision, 1);
        expect(view.displayName, 'Calendar');
      },
    );
    test(
      'missing policy responses fail closed without partial pages',
      () async {
        await service.create(createInput());
        policy.malformed = true;
        await expectLater(
          service.list(pageSize: 10, fieldGroups: groups),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test(
      'policy failure is unavailable rather than an empty successful page',
      () async {
        await service.create(createInput());
        policy.unavailable = true;
        await expectLater(
          service.list(pageSize: 10, fieldGroups: groups),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test('cursor binds query, policy epoch and scope data revision', () async {
      for (var i = 0; i < 3; i++) {
        await service.create(createInput());
      }
      final first = await service.list(pageSize: 1, fieldGroups: groups);
      final next = await service.list(
        pageSize: 1,
        fieldGroups: groups,
        cursor: first.nextCursor,
      );
      expect(first.nextCursor, isNotNull);
      expect(first.calendars.single.id, isNot(next.calendars.single.id));
      await expectLater(
        service.list(
          pageSize: 2,
          fieldGroups: groups,
          cursor: first.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      policy.epoch = 'changed';
      await expectLater(
        service.list(
          pageSize: 1,
          fieldGroups: groups,
          cursor: first.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      policy.epoch = 'v1';
      await service.create(createInput());
      await expectLater(
        service.list(
          pageSize: 1,
          fieldGroups: groups,
          cursor: first.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
    });
    test('strong mode rejects an adapter with only fresh-check capability', () {
      expect(
        () => CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.coordinated,
          ),
        ),
        throwsArgumentError,
      );
    });
    test('unavailable dependency checker prevents deletion', () async {
      final id = (await service.create(createInput()))!.calendarId;
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        dependencies: [BrokenDependency()],
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
      );
      await expectLater(
        CalendarModule.service(session).delete(id, 1),
        failure(CalendarFailureCode.unavailable),
      );
      expect((await service.get(id, groups)).revision, 1);
    });
    test(
      'mutable direct-call requests cannot change validated policy intent',
      () async {
        final input = createInput();
        policy.onPreliminary = () {
          input.displayName = 'Changed after validation';
          input.availabilityZoneId = 'invalid/zone';
        };
        final receipt = (await service.create(input))!;
        final view = await service.get(receipt.calendarId, groups);
        expect(view.displayName, 'Calendar');
        expect(view.availabilityZoneId, 'Europe/Stockholm');
      },
    );
    test('native and multilingual protocol values stay independent through unrelated edits', () async {
      final created = (await service.create(
        createInput('Native')
          ..description = '  Native\nnotes  '
          ..color = '#aabbcc',
      ))!;
      final id = created.calendarId;
      final initial = await service.get(id, groups);
      expect(initial.description, '  Native\nnotes  ');
      expect(initial.color, '#AABBCC');
      expect(initial.protocolMetadata!.names, isEmpty);
      await service.updateProtocolMetadata(
        CalendarProtocolMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          metadata: CalendarProtocolMetadata(
            names: [
              CalendarTextVariant(value: 'Protocol', language: 'en'),
              CalendarTextVariant(value: 'Protokoll', language: 'SV'),
            ],
            descriptions: [CalendarTextVariant(value: 'Protocol notes')],
            color: 'Blue',
          ),
        ),
      );
      await service.updateMetadata(
        CalendarMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 2,
          displayName: 'Renamed',
        ),
      );
      final renamed = await service.get(id, groups);
      expect(renamed.description, '  Native\nnotes  ');
      expect(renamed.color, '#AABBCC');
      expect(renamed.protocolMetadata!.names.last.language, 'SV');
      expect(renamed.protocolMetadata!.color, 'Blue');
      await service.updatePresentation(
        CalendarPresentationUpdateRequest(
          calendarId: id,
          expectedRevision: 3,
          displayName: 'New native',
        ),
      );
      final cleared = await service.get(id, groups);
      expect(cleared.description, isNull);
      expect(cleared.color, isNull);
      expect(
        cleared.protocolMetadata!.descriptions.single.value,
        'Protocol notes',
      );
      await service.delete(id, 4);
      expect(
        await CalendarDataRecord.db.findFirstRow(
          session,
          where: (t) => t.calendarId.equals(id),
        ),
        isNull,
      );
      final marker = (await CalendarIdentityRecord.db.findById(session, id))!;
      expect(marker.toJson().keys.toSet(), {
        '__className__',
        'id',
        'scopeKey',
        'revision',
        'deletedAt',
      });
    });
    test(
      'protocol writing and disclosure are separate host capabilities',
      () async {
        final id = (await service.create(createInput()))!.calendarId;
        policy.denied.add(CalendarPermission.updateProtocolMetadata);
        await service.updatePresentation(
          CalendarPresentationUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            displayName: 'Allowed',
            description: 'Native',
          ),
        );
        await expectLater(
          service.updateProtocolMetadata(
            CalendarProtocolMetadataUpdateRequest(
              calendarId: id,
              expectedRevision: 2,
              metadata: CalendarProtocolMetadata(
                names: [CalendarTextVariant(value: 'Denied')],
                descriptions: [],
              ),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.clear();
        policy.denied.add(CalendarPermission.updateMetadata);
        await service.updateProtocolMetadata(
          CalendarProtocolMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 2,
            metadata: CalendarProtocolMetadata(
              names: [CalendarTextVariant(value: 'Protocol')],
              descriptions: [],
            ),
          ),
        );
        await expectLater(
          service.updatePresentation(
            CalendarPresentationUpdateRequest(
              calendarId: id,
              expectedRevision: 3,
              displayName: 'Denied',
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.grants = {CalendarFieldGroup.metadata};
        final page = await service.list(pageSize: 10, fieldGroups: groups);
        expect(page.calendars.single.description, 'Native');
        expect(page.calendars.single.protocolMetadata, isNull);
        expect(page.calendars.single.disclosedGroups, [
          CalendarFieldGroup.metadata,
        ]);
      },
    );
    test('invalid or stale protocol replacement cannot partially commit or rename native fields', () async {
      final id = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.updateProtocolMetadata(
          CalendarProtocolMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarProtocolMetadata(
              names: [
                CalendarTextVariant(value: 'A', language: 'en'),
                CalendarTextVariant(value: 'B', language: 'EN'),
              ],
              descriptions: [],
              color: 'red',
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      var view = await service.get(id, groups);
      expect(view.revision, 1);
      expect(view.protocolMetadata!.names, isEmpty);
      expect(view.protocolMetadata!.color, isNull);
      await service.updateProtocolMetadata(
        CalendarProtocolMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          metadata: CalendarProtocolMetadata(
            names: [CalendarTextVariant(value: 'First')],
            descriptions: [],
          ),
        ),
      );
      await expectLater(
        service.updateProtocolMetadata(
          CalendarProtocolMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarProtocolMetadata(names: [], descriptions: []),
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      policy.denyFinal = true;
      await expectLater(
        service.updatePresentation(
          CalendarPresentationUpdateRequest(
            calendarId: id,
            expectedRevision: 2,
            displayName: 'No',
            description: 'No',
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denyFinal = false;
      view = await service.get(id, groups);
      expect(view.displayName, 'Calendar');
      expect(view.description, isNull);
      expect(view.revision, 2);
      expect(view.protocolMetadata!.names.single.value, 'First');
    });
    test('nested protocol commands and policy snapshots are immutable across callbacks', () async {
      final id = (await service.create(createInput()))!.calendarId;
      final metadata = CalendarProtocolMetadata(
        names: [CalendarTextVariant(value: 'Validated', language: 'en')],
        descriptions: [],
      );
      policy.onPreliminary = () {
        metadata.names.single.value = 'Changed';
        metadata.names.add(
          CalendarTextVariant(value: 'Duplicate', language: 'EN'),
        );
      };
      await service.updateProtocolMetadata(
        CalendarProtocolMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          metadata: metadata,
        ),
      );
      policy.onPreliminary = null;
      final view = await service.get(id, groups);
      expect(view.protocolMetadata!.names.single.value, 'Validated');
      expect(
        policy.lastProtocolIntent!.protocolMetadata!.names.single.value,
        'Validated',
      );
      expect(
        () => policy.lastProtocolIntent!.protocolMetadata!.names.clear(),
        throwsUnsupportedError,
      );
    });
    test('protocol edits invalidate old continuations and clearing preserves absence', () async {
      final id = (await service.create(createInput()))!.calendarId;
      await service.create(createInput());
      final page = await service.list(pageSize: 1, fieldGroups: groups);
      await service.updateProtocolMetadata(
        CalendarProtocolMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          metadata: CalendarProtocolMetadata(
            names: [],
            descriptions: [],
            color: 'red',
          ),
        ),
      );
      await expectLater(
        service.list(pageSize: 1, fieldGroups: groups, cursor: page.nextCursor),
        failure(CalendarFailureCode.invalidCursor),
      );
      await service.updateProtocolMetadata(
        CalendarProtocolMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 2,
          metadata: CalendarProtocolMetadata(names: [], descriptions: []),
        ),
      );
      expect((await service.get(id, groups)).protocolMetadata!.names, isEmpty);
      final row = (await CalendarDataRecord.db.findFirstRow(
        session,
        where: (t) => t.calendarId.equals(id),
      ))!;
      expect(row.protocolMetadata, isNull);
    });
    test(
      'supplemental metadata round trips separately and is group-redacted',
      () async {
        final id = (await service.create(createInput('Native')))!.calendarId;
        await service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarSupplementalMetadata(
              url: 'HTTP://EXAMPLE.INVALID/a%2Fb',
              categories: [CalendarCategory(value: ' Work ', language: 'SV')],
              images: [
                CalendarImageLink(
                  uri: 'https://example.invalid/a.png',
                  display: ['BADGE', 'X-PRIVATE'],
                  mediaType: 'image/png',
                ),
              ],
              refreshHint: CalendarRefreshHint(days: 1),
            ),
          ),
        );
        var view = await service.get(id, groups);
        expect(view.supplementalMetadata!.url, 'HTTP://EXAMPLE.INVALID/a%2Fb');
        expect(view.supplementalMetadata!.images.single.display, [
          'BADGE',
          'X-PRIVATE',
        ]);
        expect(view.supplementalMetadata!.refreshHint!.days, 1);
        expect(view.supplementalMetadata!.refreshHint!.hours, 0);
        expect(view.protocolMetadata!.names, isEmpty);
        await service.updateMetadata(
          CalendarMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 2,
            displayName: 'Renamed',
          ),
        );
        view = await service.get(id, groups);
        expect(view.supplementalMetadata!.categories.single.value, ' Work ');
        policy.grants = {CalendarFieldGroup.metadata};
        expect((await service.get(id, groups)).supplementalMetadata, isNull);
        policy.denied.add(CalendarPermission.updateSupplementalMetadata);
        await expectLater(
          service.updateSupplementalMetadata(
            CalendarSupplementalMetadataUpdateRequest(
              calendarId: id,
              expectedRevision: 3,
              metadata: CalendarSupplementalMetadata(
                categories: [],
                images: [],
              ),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test('category search checks disclosure and binds exact filter to continuation', () async {
      final ids = <UuidValue>[];
      for (final language in ['sv', 'en', 'de']) {
        final id = (await service.create(createInput(language)))!.calendarId;
        ids.add(id);
        await service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarSupplementalMetadata(
              categories: [CalendarCategory(value: 'Work', language: language)],
              images: [],
            ),
          ),
        );
      }
      final filter = CalendarCategoryFilter(value: 'Work');
      final page = await service.list(
        pageSize: 1,
        fieldGroups: [CalendarFieldGroup.metadata],
        categoryFilter: filter,
      );
      expect(page.calendars.single.supplementalMetadata, isNull);
      expect(page.nextCursor, isNotNull);
      expect(policy.sawCategoryFilter, isTrue);
      final second = await service.list(
        pageSize: 1,
        fieldGroups: [CalendarFieldGroup.metadata],
        categoryFilter: filter,
        cursor: page.nextCursor,
      );
      expect(second.calendars.single.id, isNot(page.calendars.single.id));
      await expectLater(
        service.list(
          pageSize: 1,
          fieldGroups: [CalendarFieldGroup.metadata],
          categoryFilter: CalendarCategoryFilter(value: 'work'),
          cursor: page.nextCursor,
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      expect(
        (await service.list(
          pageSize: 10,
          fieldGroups: groups,
          categoryFilter: CalendarCategoryFilter(value: 'Work', language: 'SV'),
        )).calendars.single.id,
        ids.first,
      );
      expect(
        (await service.list(
          pageSize: 10,
          fieldGroups: groups,
          categoryFilter: CalendarCategoryFilter(value: 'work'),
        )).calendars,
        isEmpty,
      );
      policy.grants = {CalendarFieldGroup.metadata};
      final hidden = await service.list(
        pageSize: 10,
        fieldGroups: groups,
        categoryFilter: filter,
      );
      expect(hidden.calendars, isEmpty);
      expect(hidden.nextCursor, isNull);
      expect(
        (await service.list(
          pageSize: 10,
          fieldGroups: [CalendarFieldGroup.metadata],
        )).calendars.length,
        3,
      );
    });
    test('invalid and final-denied supplemental replacements cannot partially commit', () async {
      final id = (await service.create(createInput()))!.calendarId;
      await expectLater(
        service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarSupplementalMetadata(
              categories: [CalendarCategory(value: 'Good')],
              images: [CalendarImageLink(uri: 'data:image/png;base64,x')],
            ),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      policy.denyFinal = true;
      await expectLater(
        service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarSupplementalMetadata(
              categories: [],
              images: [],
              refreshHint: CalendarRefreshHint(hours: 24),
            ),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      final view = await service.get(id, groups);
      expect(view.revision, 1);
      expect(view.supplementalMetadata!.images, isEmpty);
      expect(view.supplementalMetadata!.refreshHint, isNull);
    });
    test('nested supplemental commands freeze before host callbacks and deletion scrubs them', () async {
      final id = (await service.create(createInput()))!.calendarId;
      final value = CalendarSupplementalMetadata(
        categories: [CalendarCategory(value: 'Original')],
        images: [
          CalendarImageLink(
            uri: 'https://example.invalid/a',
            display: ['THUMBNAIL'],
          ),
        ],
        refreshHint: CalendarRefreshHint(hours: 24),
      );
      policy.onPreliminary = () {
        value.categories.single.value = 'Changed';
        value.images.single.display!.clear();
        value.refreshHint!.hours = 48;
      };
      await service.updateSupplementalMetadata(
        CalendarSupplementalMetadataUpdateRequest(
          calendarId: id,
          expectedRevision: 1,
          metadata: value,
        ),
      );
      policy.onPreliminary = null;
      final view = await service.get(id, groups);
      expect(view.supplementalMetadata!.categories.single.value, 'Original');
      expect(view.supplementalMetadata!.images.single.display, ['THUMBNAIL']);
      expect(view.supplementalMetadata!.refreshHint!.hours, 24);
      expect(
        () =>
            policy.lastSupplementalIntent!.supplementalMetadata!.images.clear(),
        throwsUnsupportedError,
      );
      await expectLater(
        service.updateSupplementalMetadata(
          CalendarSupplementalMetadataUpdateRequest(
            calendarId: id,
            expectedRevision: 1,
            metadata: CalendarSupplementalMetadata(categories: [], images: []),
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      await service.delete(id, 2);
      expect(
        await CalendarDataRecord.db.findFirstRow(
          session,
          where: (t) => t.calendarId.equals(id),
        ),
        isNull,
      );
      expect(
        (await CalendarIdentityRecord.db.findById(
          session,
          id,
        ))!.toJson().keys.toSet(),
        {'__className__', 'id', 'scopeKey', 'revision', 'deletedAt'},
      );
    });
    test('unauthenticated direct service calls fail closed', () {
      expect(
        () => CalendarModule.service(builder.build()),
        throwsA(isA<CalendarException>()),
      );
    });
    test(
      'policy timeout cannot create data after returning unavailable',
      () async {
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
            policyTimeout: Duration(milliseconds: 20),
          ),
        );
        policy.delay = const Duration(milliseconds: 30);
        await expectLater(
          CalendarModule.service(session).create(createInput()),
          failure(CalendarFailureCode.unavailable),
        );
        await Future<void>.delayed(const Duration(milliseconds: 40));
        expect(await CalendarIdentityRecord.db.count(session), 0);
      },
    );
    test('bounded hidden scan fails instead of reporting exhaustion', () async {
      for (var i = 0; i < 3; i++) {
        policy.hidden.add((await service.create(createInput()))!.calendarId);
      }
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          maxScannedCalendars: 2,
        ),
      );
      await expectLater(
        CalendarModule.service(session).list(pageSize: 1, fieldGroups: groups),
        failure(CalendarFailureCode.limitExceeded),
      );
    });
    test(
      'live capability downgrade cannot weaken a coordinated write',
      () async {
        policy.capability = CalendarAuthorizationGuarantee.coordinated;
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.coordinated,
          ),
        );
        policy.capability = CalendarAuthorizationGuarantee.freshCheck;
        await expectLater(
          CalendarModule.service(session).create(createInput()),
          failure(CalendarFailureCode.unavailable),
        );
        expect(await CalendarIdentityRecord.db.count(session), 0);
      },
    );
    test(
      'invalid name, zone and oversized subject reject atomically',
      () async {
        await expectLater(
          service.create(createInput(' ')),
          failure(CalendarFailureCode.validation),
        );
        final input = createInput()..availabilityZoneId = 'europe/stockholm';
        await expectLater(
          service.create(input),
          failure(CalendarFailureCode.validation),
        );
        final id = (await service.create(createInput()))!.calendarId;
        await expectLater(
          service.changeSubject(
            CalendarSubjectChangeRequest(
              calendarId: id,
              expectedRevision: 1,
              action: CalendarSubjectAction.attach,
              namespace: 'a' * 129,
              kind: 'room',
              externalId: 'R',
              contributesAvailability: true,
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect((await service.get(id, groups)).revision, 1);
      },
    );
  });
}

final class TestPolicy implements CalendarHostPolicy {
  Duration organizerDelay = Duration.zero;
  bool denyOrganizer = false, denyFinalOrganizer = false;
  bool organizerUnavailable = false;
  CalendarAuthorizationRequest? organizerRequest;
  final organizerPhases = <CalendarAuthorizationPhase>[];
  @override
  Future<CalendarAuthorizationVerdict> approveAvailabilityOrganizer(
    Session session,
    CalendarHostContext context,
    CalendarAuthorizationRequest request,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    await Future<void>.delayed(organizerDelay);
    organizerRequest = request;
    organizerPhases.add(phase);
    if (organizerUnavailable) {
      throw StateError('Synthetic organizer service failure');
    }
    return denyOrganizer ||
            (denyFinalOrganizer &&
                phase == CalendarAuthorizationPhase.finalWrite)
        ? CalendarAuthorizationVerdict.deny
        : CalendarAuthorizationVerdict.allow;
  }

  final resolverCalls = <String, int>{};
  CalendarSubjectResolution? Function(CalendarAvailabilityTarget, int)?
  resolveOverride;
  CalendarAuthorizationRequest? lastSearchRequest;
  final searchRequests = <CalendarAuthorizationRequest>[];
  final deniedSubjects = <String>{};
  void Function(CalendarAuthorizationRequest)? onSearchRead;
  final denied = <CalendarPermission>{};
  final hidden = <UuidValue>{};
  Set<CalendarFieldGroup> grants = groups.toSet();
  Set<CalendarEventFieldGroup> eventGrants = eventGroups.toSet();
  Set<UuidValue>? eventCandidates;
  CalendarAuthorizationRequest? lastEventRequest;
  CalendarAuthorizationRequest? lastAvailabilityRequest;
  final busyDenied = <UuidValue>{};
  bool denyFinal = false,
      malformed = false,
      unavailable = false,
      sawActualSnapshot = false;
  String epoch = 'v1';
  String? scopeOverride;
  CalendarPolicySnapshot? lastSnapshot;
  CalendarProposedChange? lastProtocolIntent;
  CalendarProposedChange? lastSupplementalIntent;
  bool sawCategoryFilter = false;
  void Function()? onPreliminary;
  Duration delay = Duration.zero;
  CalendarAuthorizationGuarantee capability =
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  CalendarAuthorizationGuarantee get guarantee => capability;
  @override
  Future<CalendarHostContext> resolveContext(Session session) async =>
      CalendarHostContext(
        principalId: session.authenticated!.userIdentifier,
        scopeKey:
            scopeOverride ?? 'test:${session.authenticated!.userIdentifier}',
        policyRevision: epoch,
      );
  @override
  Future<CalendarSubjectResolution> resolveAvailabilitySubject(
    Session session,
    CalendarHostContext context,
    CalendarAvailabilityTarget target,
    Transaction transaction,
  ) async {
    final number = resolverCalls.update(
      target.externalId,
      (v) => v + 1,
      ifAbsent: () => 1,
    );
    final override = resolveOverride?.call(target, number);
    if (override != null) return override;
    final active = await CalendarIdentityRecord.db.find(
      session,
      where: (t) =>
          t.scopeKey.equals(context.scopeKey) & t.deletedAt.equals(null),
      orderBy: (t) => t.id,
      limit: 257,
      transaction: transaction,
    );
    if (active.length > 256) {
      return CalendarSubjectResolution(
        complete: false,
        revision: context.policyRevision,
        calendarIds: [],
      );
    }
    final links = active.isEmpty
        ? <CalendarSubjectRecord>[]
        : await CalendarSubjectRecord.db.find(
            session,
            where: (t) =>
                t.calendarId.inSet(active.map((a) => a.id!).toSet()) &
                t.namespace.equals(target.namespace) &
                t.kind.equals(target.kind) &
                t.externalId.equals(target.externalId) &
                t.contributesAvailability.equals(true),
            orderBy: (t) => t.calendarId,
            limit: 9,
            transaction: transaction,
          );
    final scope = await CalendarScopeRecord.db.findFirstRow(
      session,
      where: (t) => t.scopeKey.equals(context.scopeKey),
      transaction: transaction,
    );
    return CalendarSubjectResolution(
      complete: links.length <= 8,
      revision: '${context.policyRevision}:${scope?.revision ?? 0}',
      calendarIds: links.map((l) => l.calendarId),
    );
  }

  @override
  Future<CalendarEventCandidatePlan> planEventQuery(
    Session s,
    CalendarHostContext c,
    CalendarPolicySnapshot calendar,
    Set<CalendarEventFieldGroup> groups,
  ) async => CalendarEventCandidatePlan(eventIds: eventCandidates);
  @override
  Future<CalendarCandidatePlan> planQuery(
    Session s,
    CalendarHostContext c,
    Set<CalendarFieldGroup> groups, {
    CalendarCategoryQuery? categoryFilter,
  }) async => CalendarCandidatePlan();
  @override
  Future<List<CalendarAuthorizationDecision>> authorizeBatch(
    Session s,
    CalendarHostContext c,
    List<CalendarAuthorizationRequest> requests,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    for (final request in requests) {
      if (request.availabilityId != null ||
          request.proposedAvailability != null) {
        lastAvailabilityRequest = request;
      }
    }
    if (phase == CalendarAuthorizationPhase.preliminaryWrite) {
      onPreliminary?.call();
    }
    await Future<void>.delayed(delay);
    if (unavailable) throw StateError('Synthetic policy outage');
    if (malformed) return [];
    return [for (final r in requests) decide(r, phase)];
  }

  CalendarAuthorizationDecision decide(
    CalendarAuthorizationRequest r,
    CalendarAuthorizationPhase phase,
  ) {
    if (r.availabilitySearchQuery != null) {
      lastSearchRequest = r;
      searchRequests.add(r);
      if (r.operation == CalendarPermission.readSubjectAvailability) {
        onSearchRead?.call(r);
      }
    }
    if (r.eventId != null) lastEventRequest = r;
    if (r.categoryFilter != null) {
      sawCategoryFilter = true;
    }
    if (r.proposed?.supplementalMetadata != null) {
      lastSupplementalIntent = r.proposed;
    }
    if (r.proposed?.protocolMetadata != null) {
      lastProtocolIntent = r.proposed;
    }
    if (r.current != null) {
      sawActualSnapshot = true;
      lastSnapshot = r.current;
      if (r.current!.calendarId != r.calendarId) {
        throw StateError('Wrong snapshot');
      }
    }
    return CalendarAuthorizationDecision(
      key: r.key,
      verdict:
          denied.contains(r.operation) ||
              (r.operation == CalendarPermission.readSubjectAvailability &&
                  deniedSubjects.contains(r.availabilityTarget?.externalId)) ||
              (r.operation == CalendarPermission.projectEventBusy &&
                  busyDenied.contains(r.eventId)) ||
              hidden.contains(r.calendarId) ||
              (denyFinal && phase == CalendarAuthorizationPhase.finalWrite)
          ? CalendarAuthorizationVerdict.deny
          : CalendarAuthorizationVerdict.allow,
      disclosedGroups: grants,
      eventDisclosedGroups: eventGrants,
      discloseMutationReceipt: true,
    );
  }
}

final class BrokenDependency implements CalendarDependencyProvider {
  @override
  Future<bool> hasActiveDependencies(
    Session s,
    UuidValue id,
    Transaction tx,
  ) async => throw StateError('Synthetic dependency outage');
}
