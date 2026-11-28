import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, eventInput, failure;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('complete subject freebusy export', (builder, endpoints) {
    late Session session;
    late CalendarService service;
    late TestPolicy policy;
    final from = DateTime.utc(2026, 3, 29), until = DateTime.utc(2026, 3, 30);
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
    });
    CalendarAvailabilityTarget target([String id = 'alice']) =>
        CalendarAvailabilityTarget(
          namespace: 'test',
          kind: 'user',
          externalId: id,
        );
    CalendarSubjectFreeBusyExportRequest request([
      List<CalendarAvailabilityTarget>? targets,
      CalendarAvailabilitySearchMode mode =
          CalendarAvailabilitySearchMode.perTarget,
    ]) => CalendarSubjectFreeBusyExportRequest(
      targets: targets ?? [target()],
      fromUtc: from,
      untilUtc: until,
      mode: mode,
    );
    Future<UuidValue> contributor(String id, {bool contributes = true}) async {
      final parent = (await service.create(createInput('Private calendar')))!;
      await service.changeSubject(
        CalendarSubjectChangeRequest(
          calendarId: parent.calendarId,
          expectedRevision: 1,
          action: CalendarSubjectAction.attach,
          namespace: 'test',
          kind: 'user',
          externalId: id,
          contributesAvailability: contributes,
        ),
      );
      return parent.calendarId;
    }

    Future<CalendarEventReceipt> booking(
      UuidValue parent,
      int hour,
      int end, {
      CalendarEventStatus status = CalendarEventStatus.confirmed,
    }) async => (await service.createEvent(
      CalendarEventCreateRequest(
        calendarId: parent,
        content: eventInput(summary: 'Private title', status: status).copyWith(
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
    String text(ByteData bytes) => utf8.decode(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    List<IcalendarSyntaxComponent> components(ByteData bytes) =>
        parseIcalendarSyntax(
              bytes.buffer.asUint8List(
                bytes.offsetInBytes,
                bytes.lengthInBytes,
              ),
            ).components.single.entries
            .whereType<IcalendarSyntaxComponent>()
            .toList();
    List<IcalendarSyntaxProperty> values(
      IcalendarSyntaxComponent c,
      String name,
    ) => c.entries
        .whereType<IcalendarSyntaxProperty>()
        .where((p) => p.canonicalName == name)
        .toList();

    test('per-target order deduplicates exact references and excludes hidden source identities', () async {
      final a = await contributor('alice'),
          b = await contributor('bob'),
          admin = await contributor('alice', contributes: false);
      final event = await booking(
        a,
        9,
        10,
        status: CalendarEventStatus.tentative,
      );
      await booking(b, 12, 13);
      await booking(admin, 14, 15);
      policy.denied.addAll([
        CalendarPermission.readFreeBusy,
        CalendarPermission.exportFreeBusy,
        CalendarPermission.readEvent,
        CalendarPermission.listEvents,
      ]);
      final before = (await CalendarScopeRecord.db.find(session))
          .single
          .revision;
      final bytes = await service.exportSubjectFreeBusy(
        request([target('bob'), target(), target('bob')]),
      );
      final result = components(bytes);
      expect(result, hasLength(2));
      expect(
        values(result.first, 'FREEBUSY').single.value,
        '20260329T120000Z/20260329T130000Z',
      );
      expect(values(result.last, 'FREEBUSY').single.parameters.single.values, [
        'BUSY-TENTATIVE',
      ]);
      expect(
        values(result.first, 'UID').single.value,
        isNot(values(result.last, 'UID').single.value),
      );
      for (final secret in [
        a.toString(),
        b.toString(),
        admin.toString(),
        event.eventId.toString(),
        'alice',
        'bob',
        'Private title',
        'Private calendar',
        'METHOD:',
        'ORGANIZER:',
        'ATTENDEE:',
      ]) {
        expect(text(bytes), isNot(contains(secret)));
      }
      expect(
        (await CalendarScopeRecord.db.find(session)).single.revision,
        before,
      );
    });
    test('common output uses full partitions, including free intervals shorter than a search filter', () async {
      final a = await contributor('alice'), b = await contributor('bob');
      await booking(a, 9, 10);
      await booking(b, 11, 12);
      final result = components(
        await service.exportSubjectFreeBusy(
          request([
            target(),
            target('bob'),
          ], CalendarAvailabilitySearchMode.commonFree),
        ),
      ).single;
      expect(values(result, 'FREEBUSY').map((p) => p.value), [
        '20260329T090000Z/20260329T100000Z',
        '20260329T110000Z/20260329T120000Z',
      ]);
      final filtered = await service.searchAvailability(
        CalendarAvailabilitySearchQuery(
          targets: [target(), target('bob')],
          fromUtc: from,
          untilUtc: until,
          mode: CalendarAvailabilitySearchMode.commonFree,
          minimumSeconds: 7200,
        ),
      );
      expect(
        filtered.commonSlots.any(
          (s) => s.startUtc == from.add(const Duration(hours: 10)),
        ),
        isFalse,
      );
      expect(
        values(result, 'FREEBUSY').length,
        2,
      ); // The short 10–11 free interval remains free.
    });
    test(
      'complete all-free output is distinct from an unresolved target',
      () async {
        await contributor('alice');
        expect(
          values(
            components(await service.exportSubjectFreeBusy(request())).single,
            'FREEBUSY',
          ),
          isEmpty,
        );
        await expectLater(
          service.exportSubjectFreeBusy(request([target(), target('missing')])),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    for (final permission in [
      CalendarPermission.exportSubjectFreeBusy,
      CalendarPermission.readSubjectAvailability,
      CalendarPermission.projectCalendarAvailability,
      CalendarPermission.projectEventBusy,
    ]) {
      test('independent $permission denial rejects the whole file', () async {
        final parent = await contributor('alice');
        await booking(parent, 9, 10);
        policy.denied.add(permission);
        await expectLater(
          service.exportSubjectFreeBusy(request()),
          failure(
            permission == CalendarPermission.projectEventBusy
                ? CalendarFailureCode.unavailable
                : CalendarFailureCode.accessDenied,
          ),
        );
      });
    }
    test(
      'denied later target never returns the earlier authorized component',
      () async {
        await contributor('alice');
        await contributor('bob');
        policy.deniedSubjects.add('bob');
        await expectLater(
          service.exportSubjectFreeBusy(request([target(), target('bob')])),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    for (final field in ['revision', 'set', 'complete']) {
      test('final changed resolver $field fails unavailable', () async {
        final a = await contributor('alice'), b = await contributor('bob');
        policy.resolveOverride = (_, n) => CalendarSubjectResolution(
          complete: field != 'complete' || n == 1,
          revision: field == 'revision' && n > 1 ? 'new' : 'old',
          calendarIds: [field == 'set' && n > 1 ? b : a],
        );
        await expectLater(
          service.exportSubjectFreeBusy(request()),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
    test(
      'final source and export revocation reject after candidate serialization',
      () async {
        final parent = await contributor('alice');
        final event = await booking(parent, 9, 10);
        for (final revokeSource in [false, true]) {
          policy.denied.clear();
          policy.busyDenied.clear();
          var calls = 0;
          policy.onSearchRead = (_) {
            if (++calls == 2) {
              if (revokeSource) {
                policy.busyDenied.add(event.eventId);
              } else {
                policy.denied.add(CalendarPermission.exportSubjectFreeBusy);
              }
            }
          };
          await expectLater(
            service.exportSubjectFreeBusy(request()),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(calls, 2);
        }
      },
    );
    test(
      'overlapping contributors preserve each target context on final checks',
      () async {
        final parent = await contributor('alice');
        final event = await booking(parent, 9, 10);
        policy.resolveOverride = (_, _) => CalendarSubjectResolution(
          complete: true,
          revision: 'shared',
          calendarIds: [parent],
        );
        await service.exportSubjectFreeBusy(request([target(), target('bob')]));
        final checks = policy.searchRequests
            .where(
              (r) =>
                  r.eventId == event.eventId &&
                  r.operation == CalendarPermission.projectEventBusy,
            )
            .toList();
        expect(checks.map((r) => r.availabilityTarget!.externalId), [
          'alice',
          'bob',
          'alice',
          'bob',
        ]);
      },
    );
    test(
      'input lists freeze before callbacks and nested target list is immutable',
      () async {
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
          components(await service.exportSubjectFreeBusy(request(originals))),
          hasLength(1),
        );
      },
    );
    test('raw and distinct target limits reject before resolution', () async {
      for (final targets in [
        <CalendarAvailabilityTarget>[],
        List.filled(33, target()),
        List.generate(9, (i) => target('target-$i')),
      ]) {
        await expectLater(
          service.exportSubjectFreeBusy(request(targets)),
          failure(
            targets.length == 9
                ? CalendarFailureCode.limitExceeded
                : CalendarFailureCode.validation,
          ),
        );
      }
      expect(policy.resolverCalls, isEmpty);
    });
    test(
      'one shared calendar-evaluation budget applies across distinct targets',
      () async {
        final parents = [
          await contributor('a'),
          await contributor('b'),
          await contributor('c'),
        ];
        policy.resolveOverride = (_, _) => CalendarSubjectResolution(
          complete: true,
          revision: 'shared',
          calendarIds: parents,
        );
        await expectLater(
          service.exportSubjectFreeBusy(
            request(List.generate(6, (i) => target('target-$i'))),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
      },
    );
    test(
      'foreign, missing and deleted contributors cannot produce free output',
      () async {
        final parent = await contributor('alice');
        for (final id in [const Uuid().v4obj(), parent]) {
          policy.resolveOverride = (_, _) => CalendarSubjectResolution(
            complete: true,
            revision: 'v',
            calendarIds: [id],
          );
          if (id == parent) {
            policy.scopeOverride = 'test:foreign';
          }
          await expectLater(
            service.exportSubjectFreeBusy(request()),
            failure(CalendarFailureCode.accessDenied),
          );
        }
        policy.scopeOverride = null;
        final deleted = (await service.create(createInput()))!.calendarId;
        await service.delete(deleted, 1);
        policy.resolveOverride = (_, _) => CalendarSubjectResolution(
          complete: true,
          revision: 'v',
          calendarIds: [deleted],
        );
        await expectLater(
          service.exportSubjectFreeBusy(request()),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test(
      'fractional, reversed and overlong windows reject without normalization',
      () async {
        for (final q in [
          request().copyWith(
            fromUtc: from.add(const Duration(microseconds: 1)),
          ),
          request().copyWith(untilUtc: from),
          request().copyWith(untilUtc: from.add(const Duration(days: 32))),
        ]) {
          await expectLater(
            service.exportSubjectFreeBusy(q),
            failure(CalendarFailureCode.validation),
          );
        }
      },
    );
    test('working-hours closure is applied and raw rule projection remains independent', () async {
      final parent = await contributor('alice');
      await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: parent,
          content: CalendarAvailabilityContent(openings: []),
        ),
      );
      final result = components(await service.exportSubjectFreeBusy(request()))
          .single;
      expect(values(result, 'FREEBUSY').single.parameters.single.values, [
        'BUSY-UNAVAILABLE',
      ]);
      policy.denied.add(CalendarPermission.projectAvailability);
      await expectLater(
        service.exportSubjectFreeBusy(request()),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test(
      'final policy revision change never returns the serialized candidate',
      () async {
        await contributor('alice');
        var reads = 0;
        policy.onSearchRead = (_) {
          if (++reads == 2) policy.epoch = 'changed';
        };
        await expectLater(
          service.exportSubjectFreeBusy(request()),
          throwsA(isA<CalendarException>()),
        );
        expect(reads, 2);
      },
    );
    test('exclusive 2100 end remains a valid boundary, ordinary 2100 starts reject', () async {
      await contributor('alice');
      final bytes = await service.exportSubjectFreeBusy(
        request().copyWith(
          fromUtc: DateTime.utc(2099, 12, 31),
          untilUtc: DateTime.utc(2100),
        ),
      );
      expect(
        values(components(bytes).single, 'DTEND').single.value,
        '21000101T000000Z',
      );
      await expectLater(
        service.exportSubjectFreeBusy(
          request().copyWith(
            fromUtc: DateTime.utc(2100),
            untilUtc: DateTime.utc(2100, 1, 2),
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
    });
    test(
      'declared coordinated policy cannot downgrade during final checks',
      () async {
        await contributor('alice');
        policy.capability = CalendarAuthorizationGuarantee.coordinated;
        var reads = 0;
        policy.onSearchRead = (_) {
          if (++reads == 2) {
            policy.capability = CalendarAuthorizationGuarantee.freshCheck;
          }
        };
        await expectLater(
          service.exportSubjectFreeBusy(request()),
          failure(CalendarFailureCode.unavailable),
        );
        expect(reads, 2);
      },
    );
    test(
      'DATE and explicit zoned DST-gap timing keep their UTC meaning',
      () async {
        final a = await contributor('alice'), b = await contributor('bob');
        await service.createEvent(
          CalendarEventCreateRequest(calendarId: a, content: eventInput()),
        );
        await service.createEvent(
          CalendarEventCreateRequest(
            calendarId: b,
            content: eventInput().copyWith(
              timing: CalendarEventTiming(
                kind: CalendarEventTimeKind.zoned,
                zoneId: 'Europe/Stockholm',
                start: CalendarEventCivil(
                  year: 2026,
                  month: 3,
                  day: 29,
                  hour: 2,
                  minute: 30,
                ),
                end: CalendarEventCivil(
                  year: 2026,
                  month: 3,
                  day: 29,
                  hour: 4,
                  minute: 30,
                ),
              ),
            ),
          ),
        );
        final result = components(
          await service.exportSubjectFreeBusy(
            request([target(), target('bob')]),
          ),
        );
        expect(
          values(result.first, 'FREEBUSY').single.value,
          '20260329T000000Z/20260329T220000Z',
        );
        expect(
          values(result.last, 'FREEBUSY').single.value,
          '20260329T013000Z/20260329T023000Z',
        );
      },
    );
  });
}
