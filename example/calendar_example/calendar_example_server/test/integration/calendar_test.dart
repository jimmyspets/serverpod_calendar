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
          update.copyWith(content: update.content.copyWith(recurring: true)),
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
            policyTimeout: Duration(milliseconds: 5),
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
  final denied = <CalendarPermission>{};
  final hidden = <UuidValue>{};
  Set<CalendarFieldGroup> grants = groups.toSet();
  Set<CalendarEventFieldGroup> eventGrants = eventGroups.toSet();
  Set<UuidValue>? eventCandidates;
  CalendarAuthorizationRequest? lastEventRequest;
  bool denyFinal = false,
      malformed = false,
      unavailable = false,
      sawActualSnapshot = false;
  String epoch = 'v1';
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
        scopeKey: 'test:${session.authenticated!.userIdentifier}',
        policyRevision: epoch,
      );
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
