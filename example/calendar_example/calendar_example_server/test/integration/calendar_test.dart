import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const groups = CalendarFieldGroup.values;
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
  bool denyFinal = false,
      malformed = false,
      unavailable = false,
      sawActualSnapshot = false;
  String epoch = 'v1';
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
  Future<CalendarCandidatePlan> planQuery(
    Session s,
    CalendarHostContext c,
    Set<CalendarFieldGroup> groups,
  ) async => CalendarCandidatePlan();
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
    if (r.current != null) {
      sawActualSnapshot = true;
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
