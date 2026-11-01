import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'range_invitations_test.dart' show rangeInvitationBytes;
import 'instance_invitations_test.dart' show instanceInvitationBytes;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('explicit range application and composition', (
    builder,
    endpoints,
  ) {
    late Session session;
    late InvitationTestHost host;
    late TestPolicy policy;
    late CalendarService service;
    void install({CalendarInvitationOptions? options}) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(host: host, options: options),
      );
      service = CalendarModule.service(session);
    }

    setUp(() {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      host = InvitationTestHost();
      policy = TestPolicy();
      install();
    });
    Future<CalendarInvitationReceipt> receive(Uint8List bytes) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(
            key: const Uuid().v4obj().toString(),
            bytes: bytes,
          ),
        );
    Future<CalendarInvitationAdoptionReceipt> setup({
      bool date = false,
      String? zone,
      int? sequence = 1,
      String? start,
      List<String> extra = const [],
    }) async {
      var bytes = invitationBytes(
        sequence: sequence,
        date: date,
        zone: zone,
        extra: ['RRULE:FREQ=DAILY;COUNT=6', ...extra],
      );
      if (start != null) {
        final oldStart = date
            ? 'DTSTART;VALUE=DATE:20300101'
            : zone == null
            ? 'DTSTART:20300101T090000Z'
            : 'DTSTART;TZID=$zone:20300101T090000';
        bytes = Uint8List.fromList(
          utf8.encode(utf8.decode(bytes).replaceFirst(oldStart, start)),
        );
      }
      final m = await receive(bytes);
      final c = (await service.create(createInput()))!;
      return service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: m.entryId,
          sourceId: m.sourceId,
          expectedRevision: m.entryRevision,
          calendarId: c.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
    }

    CalendarInvitationOccurrenceApplyRequest command(
      CalendarInvitationOccurrenceApplicationView v,
    ) => CalendarInvitationOccurrenceApplyRequest(
      invitationId: v.invitationId,
      sourceId: v.incomingSourceId!,
      linkId: v.linkId,
      expectedInvitationRevision: v.invitationRevision,
      expectedEventRevision: v.eventRevision,
      expectedCalendarRevision: v.calendarRevision,
      expectedApplicationRevision: v.applicationRevision,
      expectedOccurrenceRevision: v.occurrenceRevision,
    );
    Future<CalendarInvitationOccurrenceApplyRequest> update({
      int sequence = 2,
      bool date = false,
      String? zone,
      String? original,
      List<String> extra = const [],
    }) async {
      final r = await receive(
        rangeInvitationBytes(
          sequence: sequence,
          date: date,
          zone: zone,
          original: original,
          extra: extra,
        ),
      );
      final view = await service.invitationRangeApplication(r.entryId);
      expect(view.isThisAndFuture, isTrue);
      expect(view.canApply, isTrue);
      return command(view);
    }

    Future<CalendarEventDataRecord> data() async =>
        (await CalendarEventDataRecord.db.find(session)).single;
    Future<CalendarInvitationOccurrenceApplicationRecord> row() async =>
        (await CalendarInvitationOccurrenceApplicationRecord.db.find(session))
            .single;
    CalendarInvitationApplyRequest masterCommand(
      CalendarInvitationApplicationView v,
    ) => CalendarInvitationApplyRequest(
      invitationId: v.invitationId,
      sourceId: v.incomingSourceId!,
      expectedInvitationRevision: v.invitationRevision!,
      linkId: v.linkId,
      expectedEventRevision: v.eventRevision,
      expectedCalendarRevision: v.calendarRevision,
      expectedApplicationRevision: v.applicationRevision,
      expectedOccurrenceRevision: v.occurrenceRevision,
    );
    Future<CalendarInvitationApplicationView> newerMaster({
      int sequence = 3,
      bool date = false,
      String? zone,
      List<String> extra = const ['RRULE:FREQ=DAILY;COUNT=6'],
    }) async {
      final m = await receive(
        invitationBytes(
          sequence: sequence,
          date: date,
          zone: zone,
          summary: 'Updated master',
          extra: extra,
        ),
      );
      return service.invitationApplication(m.entryId);
    }

    for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
      test(
        '$profile range saves once with exact retry, versions and source binding',
        () async {
          final date = profile == 'date',
              zone = profile == 'Europe/Stockholm' ? profile : null;
          await setup(date: date, zone: zone);
          final input = await update(
            date: date,
            zone: zone,
            extra: [date ? 'DURATION:P1D' : 'DURATION:PT1H'],
          );
          final result = await service.applyInvitationRangeUpdate(input);
          expect(result.eventRevision, 2);
          expect(
            (await service.applyInvitationRangeUpdate(input)).id,
            result.id,
          );
          final d = await data(),
              checkpoint = jsonDecode((await row()).stateJson) as Map;
          expect(d.timingOverrides!.singles, isEmpty);
          expect(d.timingOverrides!.future.single.originalStart.start.day, 2);
          expect(d.timingOverrides!.future.single.replacement.start.day, 1);
          expect(d.protocolState!.version.sequence, 1);
          expect(d.protocolState!.overrides.single.version.sequence, 2);
          expect(checkpoint['version'], 3);
          expect(checkpoint['latestTargetKey'], startsWith('range-v1:'));
          expect(
            (checkpoint['targets'] as List).single['key'],
            checkpoint['latestTargetKey'],
          );
          expect(
            (await service.invitationRangeApplication(input.invitationId))
                .acceptedSourceText,
            contains('RANGE=THISANDFUTURE'),
          );
          expect(
            (await service.getInvitation(input.invitationId)).dismissedAt,
            isNotNull,
          );
          expect(await CalendarInvitationResponseRecord.db.count(session), 0);
        },
      );
    }
    test(
      'single APIs and source denial cannot bypass range authority',
      () async {
        await setup();
        final input = await update();
        host.denied.add(CalendarInvitationOperation.readSource);
        await expectLater(
          service.invitationRangeApplication(input.invitationId),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          service.applyInvitationRangeUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        host.denied.add(CalendarInvitationOperation.readOccurrenceApplication);
        expect(
          (await service.invitationRangeApplication(input.invitationId))
              .canApply,
          isTrue,
        );
        host.denied.clear();
        await expectLater(
          service.invitationOccurrenceApplication(input.invitationId),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(
          service.applyInvitationOccurrenceUpdate(input),
          failure(CalendarFailureCode.validation),
        );
        host.denied.add(CalendarInvitationOperation.applyRangeUpdate);
        await expectLater(
          service.applyInvitationRangeUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
        expect((await data()).timingOverrides, isNull);
      },
    );
    for (final op in [
      CalendarInvitationOperation.applyRangeUpdate,
      CalendarInvitationOperation.readRangeApplication,
      CalendarInvitationOperation.readSource,
    ]) {
      test('final $op denial rolls back event/checkpoint/review', () async {
        await setup();
        final input = await update();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == op &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            expect(c.proposedOccurrenceApplication, isNotNull);
            expect(
              jsonDecode(c.proposedOccurrenceApplication!.stateJson)['version'],
              3,
            );
            expect(c.message!.events.single.isThisAndFuture, isTrue);
            host.denied.add(op);
          }
        };
        await expectLater(
          service.applyInvitationRangeUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await data()).timingOverrides, isNull);
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
        expect(
          (await service.getInvitation(input.invitationId)).dismissedAt,
          isNull,
        );
      });
    }
    test('local content/timing state blocks new range writes', () async {
      final link = await setup();
      final input = await update();
      final before = await data();
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: link.eventId,
          expectedRevision: 1,
          content: before.content.copyWith(summary: 'Local draft'),
        ),
      );
      final view = await service.invitationRangeApplication(input.invitationId);
      expect(view.hasLocalChanges, isTrue);
      expect(view.canApply, isFalse);
      await expectLater(
        service.applyInvitationRangeUpdate(command(view)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await data()).content.summary, 'Local draft');
    });
    test('range CANCEL stays read-only and retained REQUEST retries do not dismiss it', () async {
      await setup();
      final input = await update();
      final result = await service.applyInvitationRangeUpdate(input);
      final cancel = await receive(
        rangeInvitationBytes(sequence: 3, cancel: true),
      );
      final view = await service.invitationRangeApplication(cancel.entryId);
      expect(view.canApply, isFalse);
      expect(view.incomingKind, CalendarInvitationSourceKind.rangeCancellation);
      await expectLater(
        service.applyInvitationRangeUpdate(command(view)),
        failure(CalendarFailureCode.validation),
      );
      expect((await service.applyInvitationRangeUpdate(input)).id, result.id);
      expect((await service.getInvitation(cancel.entryId)).dismissedAt, isNull);
      expect((await data()).content.status, CalendarEventStatus.confirmed);
      await expectLater(
        service.invitationResponse(cancel.entryId),
        failure(CalendarFailureCode.validation),
      );
    });
    test(
      'single plus multiple ranges preserve independent canonical components',
      () async {
        await setup();
        final single = await receive(
          instanceInvitationBytes(sequence: 2, original: '20300105T090000Z'),
        );
        await service.applyInvitationOccurrenceUpdate(
          command(
            await service.invitationOccurrenceApplication(single.entryId),
          ),
        );
        final legacy = await row();
        expect(jsonDecode(legacy.stateJson)['version'], 1);
        final first = await update(sequence: 3);
        await service.applyInvitationRangeUpdate(first);
        final before = await data();
        await service.applyInvitationRangeUpdate(
          await update(sequence: 4, original: '20300104T090000Z'),
        );
        expect(
          (await data()).timingOverrides!.singles,
          before.timingOverrides!.singles,
        );
        expect((await data()).timingOverrides!.future, hasLength(2));
        expect(
          (await data()).protocolState!.overrides.map(
            (v) => v.version.sequence,
          ),
          containsAll([2, 3, 4]),
        );
        final r = await receive(
          instanceInvitationBytes(sequence: 5, original: '20300106T090000Z'),
        );
        await service.applyInvitationOccurrenceUpdate(
          command(await service.invitationOccurrenceApplication(r.entryId)),
        );
        expect(jsonDecode((await row()).stateJson)['version'], 3);
        expect(
          jsonDecode((await row()).stateJson)['latestTargetKey'],
          startsWith('instance-v1:'),
        );
        await expectLater(
          service.applyInvitationRangeUpdate(first),
          failure(CalendarFailureCode.staleRevision),
        );
        expect(
          (await service.invitationRangeApplication(first.invitationId))
              .canApply,
          isFalse,
        );
      },
    );
    test(
      'effective earlier range version fences new range, not a later component',
      () async {
        await setup();
        await service.applyInvitationRangeUpdate(
          await update(sequence: 5, original: '20300104T090000Z'),
        );
        await service.applyInvitationRangeUpdate(await update(sequence: 3));
        final r = await receive(
          rangeInvitationBytes(sequence: 2, original: '20300103T090000Z'),
        );
        final view = await service.invitationRangeApplication(r.entryId);
        expect(view.acceptedVersion.sequence, 3);
        expect(view.canApply, isFalse);
        await expectLater(
          service.applyInvitationRangeUpdate(command(view)),
          failure(CalendarFailureCode.dependencyConflict),
        );
        expect((await data()).timingOverrides!.future, hasLength(2));
      },
    );
    test(
      'selected single collision rejects without changing either notice',
      () async {
        await setup();
        final r = await receive(instanceInvitationBytes());
        await service.applyInvitationOccurrenceUpdate(
          command(await service.invitationOccurrenceApplication(r.entryId)),
        );
        final incoming = await receive(rangeInvitationBytes(sequence: 3));
        final view = await service.invitationRangeApplication(incoming.entryId);
        expect(view.canApply, isFalse);
        await expectLater(
          service.applyInvitationRangeUpdate(command(view)),
          failure(CalendarFailureCode.validation),
        );
        expect((await data()).timingOverrides!.singles, hasLength(1));
        expect((await data()).timingOverrides!.future, isEmpty);
      },
    );
    test('master composition and cancellation/reopening retain range values and exact old receipt', () async {
      await setup();
      final input = await update();
      final result = await service.applyInvitationRangeUpdate(input);
      final before = (await data()).timingOverrides!;
      final master = await newerMaster();
      expect(master.occurrenceCompositionBlocked, isFalse);
      await service.applyInvitationUpdate(masterCommand(master));
      expect((await data()).timingOverrides, before);
      expect(jsonDecode((await row()).stateJson)['version'], 3);
      expect((await service.applyInvitationRangeUpdate(input)).id, result.id);
      var cancelText = utf8
          .decode(invitationBytes(sequence: 4))
          .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL')
          .replaceFirst(
            'BEGIN:VEVENT\r\n',
            'BEGIN:VEVENT\r\nSTATUS:CANCELLED\r\n',
          );
      final cancellation = await receive(
        Uint8List.fromList(utf8.encode(cancelText)),
      );
      final c = await service.invitationApplication(cancellation.entryId);
      await service.applyInvitationCancellation(masterCommand(c));
      expect((await data()).content.status, CalendarEventStatus.cancelled);
      expect((await data()).timingOverrides, before);
      final reopen = await newerMaster(sequence: 5);
      await service.applyInvitationUpdate(masterCommand(reopen));
      expect((await data()).content.status, CalendarEventStatus.confirmed);
      expect((await data()).timingOverrides, before);
      expect((await service.applyInvitationRangeUpdate(input)).id, result.id);
    });
    test(
      'orphaning and profile-changing master proposals remain blocked',
      () async {
        await setup();
        await service.applyInvitationRangeUpdate(await update());
        final orphan = await newerMaster(extra: ['RRULE:FREQ=WEEKLY;COUNT=3']);
        expect(orphan.occurrenceCompositionBlocked, isTrue);
        await expectLater(
          service.applyInvitationUpdate(masterCommand(orphan)),
          failure(CalendarFailureCode.validation),
        );
        final profile = await newerMaster(sequence: 4, date: true);
        expect(profile.occurrenceCompositionBlocked, isTrue);
        expect(
          (await data()).protocolState!.overrides.single.version.sequence,
          2,
        );
      },
    );
    for (final corrupt in [
      'key',
      'latestTargetKey',
      'receiptDigest',
      'version',
      'sourceRange',
      'component',
    ]) {
      test('corrupt v3 $corrupt fails unavailable', () async {
        await setup();
        final input = await update();
        await service.applyInvitationRangeUpdate(input);
        final r = await row(),
            value = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
        if (corrupt == 'key') {
          (value['targets'] as List).single['key'] = 'range-v2:bad';
        }
        if (corrupt == 'latestTargetKey') {
          value['latestTargetKey'] = 'instance-v1:bad';
        }
        if (corrupt == 'receiptDigest') {
          value['receiptDigest'] = 'bad';
        }
        if (corrupt == 'version') {
          value['version'] = 2;
        }
        if (corrupt == 'sourceRange') {
          final target = (value['targets'] as List).single;
          target['source'] = (target['source'] as String).replaceAll(
            ';RANGE=THISANDFUTURE',
            '',
          );
        }
        if (corrupt == 'component') {
          (value['targets'] as List).single['component'] = 'bad';
        }
        r.stateJson = jsonEncode(value);
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          r,
        );
        await expectLater(
          service.invitationRangeApplication(input.invitationId),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
    test('lower host byte limits reject atomically', () async {
      await setup();
      final input = await update();
      install(
        options: CalendarInvitationOptions(maxOccurrenceCheckpointBytes: 1),
      );
      await expectLater(
        service.applyInvitationRangeUpdate(input),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect((await data()).timingOverrides, isNull);
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
    });
    test('accepted source survives queue body pruning and deletion scrubs checkpoint', () async {
      final link = await setup();
      final input = await update();
      final result = await service.applyInvitationRangeUpdate(input);
      final entry = (await CalendarInvitationRecord.db.findById(
        session,
        input.invitationId,
      ))!;
      entry.currentSourceId = null;
      await CalendarInvitationRecord.db.updateRow(session, entry);
      await CalendarInvitationReceiptRecord.db.deleteWhere(
        session,
        where: (t) => t.sourceId.equals(input.sourceId),
      );
      await CalendarInvitationSourceRecord.db.deleteWhere(
        session,
        where: (t) => t.id.equals(input.sourceId),
      );
      expect(
        (await service.invitationRangeApplication(input.invitationId))
            .acceptedSourceText,
        contains('THISANDFUTURE'),
      );
      expect((await service.applyInvitationRangeUpdate(input)).id, result.id);
      await service.deleteEvent(link.eventId, 2);
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
      expect(await CalendarEventDataRecord.db.count(session), 0);
    });

    test('equal effective sequence accepts later source stamp while preserving omission', () async {
      await setup(sequence: null);
      final omitted = Uint8List.fromList(
        utf8.encode(
          utf8
              .decode(rangeInvitationBytes())
              .replaceFirst('SEQUENCE:2\r\n', '')
              .replaceFirst(
                'DTSTAMP:20260101T000000Z',
                'DTSTAMP:20260101T000001Z',
              ),
        ),
      );
      final source = await receive(omitted);
      final first = command(
        await service.invitationRangeApplication(source.entryId),
      );
      await service.applyInvitationRangeUpdate(first);
      expect(
        (await data()).protocolState!.overrides.single.version.sequence,
        isNull,
      );
      final zero = Uint8List.fromList(
        utf8.encode(
          utf8
              .decode(rangeInvitationBytes(sequence: 0))
              .replaceFirst(
                'DTSTAMP:20260101T000000Z',
                'DTSTAMP:20260101T000002Z',
              ),
        ),
      );
      final next = await receive(zero);
      final view = await service.invitationRangeApplication(next.entryId);
      expect(view.canApply, isTrue);
      await service.applyInvitationRangeUpdate(command(view));
      expect((await data()).protocolState!.version.sequence, isNull);
      expect(
        (await data()).protocolState!.overrides.single.version.sequence,
        0,
      );
    });
    test(
      'wrong-target APIs authorize before rejecting a single as a range',
      () async {
        await setup();
        final single = await receive(instanceInvitationBytes());
        final input = command(
          await service.invitationOccurrenceApplication(single.entryId),
        );
        host.denied.add(CalendarInvitationOperation.readSource);
        await expectLater(
          service.invitationRangeApplication(single.entryId),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          service.applyInvitationRangeUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        await expectLater(
          service.invitationRangeApplication(single.entryId),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(
          service.applyInvitationRangeUpdate(input),
          failure(CalendarFailureCode.validation),
        );
      },
    );
    test(
      'range changes booking results and durably invalidates alarm plans once',
      () async {
        final link = await setup();
        final input = await update(extra: ['DURATION:PT1H']);
        final query = CalendarFreeBusyQuery(
          calendarId: link.calendarId,
          fromUtc: DateTime.utc(2030),
          untilUtc: DateTime.utc(2030, 1, 4),
        );
        expect(
          (await service.freeBusy(query)).periods
              .where((v) => v.kind == CalendarFreeBusyKind.busy),
          isEmpty,
        );
        final alarm = await CalendarAlarmRecord.db.insertRow(
          session,
          CalendarAlarmRecord(
            scopeKey: 'test:alice',
            calendarId: link.calendarId,
            parentKind: CalendarAlarmParentKind.event,
            parentId: link.eventId,
            recipientNamespace: 'fixture',
            recipientKey: 'alice',
            revision: 1,
            definition: CalendarAlarmDefinition(
              absoluteUtc: DateTime.utc(2030),
            ),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
        final plan = await CalendarAlarmPlanRecord.db.insertRow(
          session,
          CalendarAlarmPlanRecord(
            alarmId: alarm.id!,
            scopeKey: 'test:alice',
            generation: 1,
            dirty: false,
            nextScanAt: DateTime.utc(2031),
            leaseOwner: const Uuid().v4obj(),
            leaseUntil: DateTime.utc(2031),
            leaseFence: 8,
          ),
        );
        await service.applyInvitationRangeUpdate(input);
        final busy = await service.freeBusy(query);
        expect(busy.coverage, CalendarFreeBusyCoverage.complete);
        expect(
          busy.periods.where((v) => v.kind == CalendarFreeBusyKind.busy),
          isNotEmpty,
        );
        final changed = (await CalendarAlarmPlanRecord.db.findById(
          session,
          plan.id!,
        ))!;
        expect(changed.dirty, isTrue);
        expect(changed.leaseOwner, isNull);
        expect(changed.leaseFence, 9);
        await service.applyInvitationRangeUpdate(input);
        expect(
          (await CalendarAlarmPlanRecord.db.findById(
            session,
            plan.id!,
          ))!.leaseFence,
          9,
        );
        expect(
          (await CalendarAlarmRecord.db.findById(session, alarm.id!))!.revision,
          1,
        );
      },
    );
    test(
      'zoned range previews preserve civil shifts across DST after storage',
      () async {
        final link = await setup(
          zone: 'Europe/Stockholm',
          start: 'DTSTART;TZID=Europe/Stockholm:20300330T090000',
        );
        final bytes = Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(
                  rangeInvitationBytes(
                    zone: 'Europe/Stockholm',
                    original: '20300330T090000',
                    extra: ['DURATION:P1D'],
                  ),
                )
                .replaceFirst(
                  'DTSTART;TZID=Europe/Stockholm:20300101T090000',
                  'DTSTART;TZID=Europe/Stockholm:20300330T110000',
                ),
          ),
        );
        final source = await receive(bytes);
        await service.applyInvitationRangeUpdate(
          command(await service.invitationRangeApplication(source.entryId)),
        );
        final result = await service.previewOccurrences(
          CalendarEventOccurrenceQuery(
            eventId: link.eventId,
            expectedRevision: 2,
            fromUtc: DateTime.utc(2030, 3, 30),
            untilUtc: DateTime.utc(2030, 4, 2),
          ),
        );
        final next = result.occurrences.singleWhere(
          (v) => v.originalStart.day == 31,
        );
        expect(next.start.hour, 11);
        expect(next.startUtc, DateTime.utc(2030, 3, 31, 9));
      },
    );
    test(
      'earlier inclusion and PERIOD originals can each become accepted ranges',
      () async {
        await setup(
          extra: [
            'RDATE:20291230T090000Z',
            'RDATE;VALUE=PERIOD:20300110T090000Z/PT2H',
          ],
        );
        await service.applyInvitationRangeUpdate(
          await update(original: '20291230T090000Z'),
        );
        await service.applyInvitationRangeUpdate(
          await update(sequence: 3, original: '20300110T090000Z'),
        );
        expect(
          (await data()).timingOverrides!.future.map(
            (v) => v.originalStart.start.day,
          ),
          [30, 10],
        );
        expect((await data()).content.periods, hasLength(1));
      },
    );
    test('all accepted components fence whole-master cancellation', () async {
      await setup();
      await service.applyInvitationRangeUpdate(await update(sequence: 5));
      final text = utf8
          .decode(invitationBytes(sequence: 4))
          .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL')
          .replaceFirst(
            'BEGIN:VEVENT\r\n',
            'BEGIN:VEVENT\r\nSTATUS:CANCELLED\r\n',
          );
      final notice = await receive(Uint8List.fromList(utf8.encode(text)));
      final view = await service.invitationApplication(notice.entryId);
      expect(view.occurrenceCompositionBlocked, isTrue);
      await expectLater(
        service.applyInvitationCancellation(masterCommand(view)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await data()).content.status, CalendarEventStatus.confirmed);
      expect(
        (await data()).protocolState!.overrides.single.version.sequence,
        5,
      );
    });
    test('recipient and scope checkpoint limits reject with no partial source acceptance', () async {
      await setup();
      final input = await update();
      for (final options in [
        CalendarInvitationOptions(maxRecipientOccurrenceBytes: 1),
        CalendarInvitationOptions(maxScopeOccurrenceBytes: 1),
      ]) {
        install(options: options);
        await expectLater(
          service.applyInvitationRangeUpdate(input),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect((await data()).timingOverrides, isNull);
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
      }
    });
  });
}
