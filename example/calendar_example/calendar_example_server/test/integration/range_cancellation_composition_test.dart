import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'instance_invitations_test.dart' show instanceInvitationBytes;
import 'range_invitations_test.dart' show rangeInvitationBytes;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('master composition retaining range cancellation', (
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
    Future<CalendarInvitationOccurrenceApplyRequest> cancel({
      bool date = false,
      String? zone,
      int sequence = 3,
      String? original,
    }) async {
      final bytes = rangeInvitationBytes(
        cancel: true,
        original: original,
        sequence: sequence,
        date: date,
        zone: zone,
      );
      final r = await receive(
        Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(bytes)
                .split('\r\n')
                .where((line) => !line.startsWith('SUMMARY:'))
                .join('\r\n'),
          ),
        ),
      );
      final v = await service.invitationRangeApplication(r.entryId);
      expect(v.canApply, isTrue);
      return command(v);
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
        '$profile v4-v5 freezes acceptance and preserves cutoff across independent master versions',
        () async {
          final date = profile == 'date',
              zone = profile == 'Europe/Stockholm' ? profile : null;
          await setup(date: date, zone: zone);
          final originalBasis = (await data()).importBaseline!.toJson();
          final input = await cancel(date: date, zone: zone, sequence: 10);
          final cancelled = await service.applyInvitationRangeCancellation(
            input,
          );
          final originalState = jsonDecode((await row()).stateJson) as Map;
          for (final sequence in [2, 20]) {
            final v = await newerMaster(
              sequence: sequence,
              date: date,
              zone: zone,
            );
            expect(v.hasAcceptedRangeCancellation, isTrue);
            expect(v.occurrenceCompositionBlocked, isFalse);
            expect(v.hasLocalChanges, isFalse);
            expect(v.canApply, isTrue);
            final request = masterCommand(v);
            final result = await service.applyInvitationUpdate(request);
            final d = await data(),
                state = jsonDecode((await row()).stateJson) as Map;
            expect(state['version'], 5);
            expect(state['cancellationBasis'], originalBasis);
            expect(
              state['cancellationNativeDigest'],
              originalState['expectedNativeDigest'],
            );
            expect(
              state['rangeCancellation'],
              originalState['rangeCancellation'],
            );
            expect(d.protocolState!.version.sequence, sequence);
            expect(d.timingOverrides!.cancelledFrom!.start.day, 2);
            expect(d.content.summary, 'Updated master');
            expect(
              d.importBaseline!.canonicalValue,
              isNot(contains('cancelledFrom')),
            );
            final before = d.toJson(), beforeRow = (await row()).toJson();
            expect(
              (await service.applyInvitationUpdate(request)).id,
              result.id,
            );
            expect(
              (await service.applyInvitationRangeCancellation(input)).id,
              cancelled.id,
            );
            expect((await data()).toJson(), before);
            expect((await row()).toJson(), beforeRow);
            final retained = await service.invitationRangeApplication(
              input.invitationId,
            );
            expect(retained.hasLocalChanges, isFalse);
            expect(retained.acceptedVersion.sequence, 10);
            expect(
              retained.currentOccurrence!.status,
              CalendarEventStatus.cancelled,
            );
          }
        },
      );
    }
    for (final range in [false, true]) {
      test(
        'canonical ${range ? 'range' : 'single'} data and versions survive masked master composition',
        () async {
          await setup();
          final r = await receive(
            range
                ? rangeInvitationBytes(sequence: 2)
                : instanceInvitationBytes(
                    sequence: 2,
                    original: '20300102T090000Z',
                  ),
          );
          final v = await (range
              ? service.invitationRangeApplication
              : service.invitationOccurrenceApplication)(r.entryId);
          await (range
              ? service.applyInvitationRangeUpdate
              : service.applyInvitationOccurrenceUpdate)(command(v));
          final input = await cancel(sequence: 4);
          await service.applyInvitationRangeCancellation(input);
          final before = await data(),
              old = jsonDecode((await row()).stateJson) as Map;
          await service.applyInvitationUpdate(
            masterCommand(await newerMaster(sequence: 5)),
          );
          final after = await data(),
              state = jsonDecode((await row()).stateJson) as Map;
          expect(state['targets'], old['targets']);
          expect(
            after.protocolState!.overrides.map((v) => v.toJson()).toList(),
            before.protocolState!.overrides.map((v) => v.toJson()).toList(),
          );
          expect(
            after.timingOverrides!.singles.map((v) => v.toJson()).toList(),
            before.timingOverrides!.singles.map((v) => v.toJson()).toList(),
          );
          expect(
            after.timingOverrides!.future.map((v) => v.toJson()).toList(),
            before.timingOverrides!.future.map((v) => v.toJson()).toList(),
          );
        },
      );
    }
    for (final extra in [
      ['RRULE:FREQ=DAILY;COUNT=1'],
      ['RRULE:FREQ=DAILY;COUNT=6', 'EXDATE:20300102T090000Z'],
    ]) {
      test('orphaning cutoff $extra rejects without writes', () async {
        await setup();
        final input = await cancel();
        await service.applyInvitationRangeCancellation(input);
        final v = await newerMaster(sequence: 5, extra: extra);
        expect(v.occurrenceCompositionBlocked, isTrue);
        expect(v.canApply, isFalse);
        final before = (await data()).toJson(), oldRow = (await row()).toJson();
        await expectLater(
          service.applyInvitationUpdate(masterCommand(v)),
          failure(CalendarFailureCode.validation),
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), oldRow);
      });
    }
    for (final op in [
      CalendarInvitationOperation.composeAcceptedRangeCancellation,
      CalendarInvitationOperation.composeAcceptedOccurrences,
    ]) {
      test('independent $op denial disables preview and mutation', () async {
        await setup();
        final input = await cancel();
        await service.applyInvitationRangeCancellation(input);
        final v = await newerMaster(sequence: 5);
        final request = masterCommand(v);
        host.denied.add(op);
        final denied = await service.invitationApplication(v.invitationId);
        expect(denied.canApply, isFalse);
        expect(denied.hasAcceptedRangeCancellation, isTrue);
        await expectLater(
          service.applyInvitationUpdate(request),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(jsonDecode((await row()).stateJson)['version'], 4);
      });
      test('final $op rollback preserves original v4 evidence', () async {
        await setup();
        final input = await cancel();
        await service.applyInvitationRangeCancellation(input);
        final request = masterCommand(await newerMaster(sequence: 5));
        final oldData = (await data()).toJson(),
            oldRow = (await row()).toJson();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == op &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            expect(c.proposedEvent!.timingOverrides!.cancelledFrom, isNotNull);
            expect(
              jsonDecode(c.proposedOccurrenceApplication!.stateJson)['version'],
              5,
            );
            expect(
              c.proposedBaseline!.canonicalValue,
              isNot(contains('cancelledFrom')),
            );
            host.denied.add(op);
          }
        };
        await expectLater(
          service.applyInvitationUpdate(request),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await data()).toJson(), oldData);
        expect((await row()).toJson(), oldRow);
      });
    }
    test(
      'local restoration stays dirty and cannot be silently reapplied',
      () async {
        final link = await setup();
        final input = await cancel();
        await service.applyInvitationRangeCancellation(input);
        final m = await newerMaster(sequence: 5);
        final master = masterCommand(m);
        final result = await service.applyInvitationUpdate(master);
        await service.changeOccurrence(
          CalendarEventOccurrenceChange(
            eventId: link.eventId,
            expectedRevision: result.eventRevision,
            originalStart: (await data()).timingOverrides!.cancelledFrom!,
            action: CalendarEventOccurrenceAction.restoreFuture,
          ),
        );
        final v = await newerMaster(sequence: 6);
        expect(v.hasLocalChanges, isTrue);
        expect(v.canApply, isFalse);
        await expectLater(
          service.applyInvitationUpdate(masterCommand(v)),
          failure(CalendarFailureCode.dependencyConflict),
        );
        final old = (await data()).toJson(), oldRow = (await row()).toJson();
        expect((await service.applyInvitationUpdate(master)).id, result.id);
        await service.applyInvitationRangeCancellation(input);
        expect((await data()).toJson(), old);
        expect((await row()).toJson(), oldRow);
      },
    );
    for (final addition in [
      'RDATE:20291231T090000Z',
      'RDATE;VALUE=PERIOD:20300110T090000Z/PT2H',
    ]) {
      test('composition preserves exact added cutoff $addition', () async {
        await setup(extra: [addition]);
        final input = await cancel(
          original: addition.startsWith('RDATE;')
              ? '20300110T090000Z'
              : '20291231T090000Z',
        );
        await service.applyInvitationRangeCancellation(input);
        final m = await newerMaster(
          sequence: 5,
          extra: ['RRULE:FREQ=DAILY;COUNT=6', addition],
        );
        expect(m.canApply, isTrue);
        await service.applyInvitationUpdate(masterCommand(m));
        expect(
          (await service.invitationRangeApplication(input.invitationId))
              .hasLocalChanges,
          isFalse,
        );
      });
    }
    test('named-zone cutoff identity and retained basis survive DST master composition', () async {
      const zone = 'Europe/Stockholm';
      await setup(zone: zone, start: 'DTSTART;TZID=$zone:20300330T090000');
      final input = await cancel(zone: zone, original: '20300331T090000');
      await service.applyInvitationRangeCancellation(input);
      final raw = utf8
          .decode(
            invitationBytes(
              zone: zone,
              sequence: 5,
              extra: ['RRULE:FREQ=DAILY;COUNT=6'],
            ),
          )
          .replaceFirst(
            'DTSTART;TZID=$zone:20300101T090000',
            'DTSTART;TZID=$zone:20300330T090000',
          );
      final m = await receive(Uint8List.fromList(utf8.encode(raw)));
      final v = await service.invitationApplication(m.entryId);
      expect(v.canApply, isTrue);
      await service.applyInvitationUpdate(masterCommand(v));
      final d = await data();
      expect(d.timingOverrides!.cancelledFrom!.start.month, 3);
      expect(d.timingOverrides!.cancelledFrom!.zoneId, zone);
      expect(
        (await service.invitationRangeApplication(input.invitationId))
            .hasLocalChanges,
        isFalse,
      );
    });
    test(
      'frozen basis counts toward existing byte cap and rejects atomically',
      () async {
        await setup();
        final input = await cancel();
        await service.applyInvitationRangeCancellation(input);
        final v = await newerMaster(sequence: 5),
            oldData = (await data()).toJson(),
            oldRow = (await row()).toJson();
        install(
          options: CalendarInvitationOptions(
            maxOccurrenceCheckpointBytes:
                utf8.encode((await row()).stateJson).length + 16,
          ),
        );
        final blocked = await service.invitationApplication(v.invitationId);
        expect(blocked.canApply, isFalse);
        expect(blocked.occurrenceCompositionBlocked, isTrue);
        await expectLater(
          service.applyInvitationUpdate(masterCommand(v)),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect((await data()).toJson(), oldData);
        expect((await row()).toJson(), oldRow);
      },
    );
    test('source pruning, stable cancellation retries and deletion cover frozen v5 data', () async {
      final link = await setup();
      final input = await cancel();
      final cancelled = await service.applyInvitationRangeCancellation(input);
      final entry = (await CalendarInvitationRecord.db.findById(
        session,
        input.invitationId,
      ))!;
      await CalendarInvitationRecord.db.updateRow(
        session,
        entry.copyWith(currentSourceId: null),
      );
      await CalendarInvitationReceiptRecord.db.deleteWhere(
        session,
        where: (t) => t.sourceId.equals(input.sourceId),
      );
      await CalendarInvitationSourceRecord.db.deleteWhere(
        session,
        where: (t) => t.id.equals(input.sourceId),
      );
      final result = await service.applyInvitationUpdate(
        masterCommand(await newerMaster(sequence: 5)),
      );
      expect(
        (await service.applyInvitationRangeCancellation(input)).id,
        cancelled.id,
      );
      expect(
        (await service.invitationRangeApplication(input.invitationId))
            .acceptedSourceText,
        contains('METHOD:CANCEL'),
      );
      await service.deleteEvent(link.eventId, result.eventRevision);
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
    });
    test(
      'final actual cancellation-source denial rolls back composition',
      () async {
        await setup();
        final input = await cancel();
        await service.applyInvitationRangeCancellation(input);
        final request = masterCommand(await newerMaster(sequence: 5));
        final before = (await data()).toJson(), oldRow = (await row()).toJson();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.readSource &&
              c.sourceId == input.sourceId &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.denied.add(CalendarInvitationOperation.readSource);
          }
        };
        await expectLater(
          service.applyInvitationUpdate(request),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), oldRow);
      },
    );
    test('new occurrence commands remain guarded while whole cancellation retains the cutoff', () async {
      await setup();
      final input = await cancel();
      final cancelled = await service.applyInvitationRangeCancellation(input);
      await service.applyInvitationUpdate(
        masterCommand(await newerMaster(sequence: 5)),
      );
      final r = await receive(rangeInvitationBytes(sequence: 10));
      final range = await service.invitationRangeApplication(r.entryId);
      expect(range.canApply, isFalse);
      await expectLater(
        service.applyInvitationRangeUpdate(command(range)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final single = await receive(
        instanceInvitationBytes(sequence: 10, original: '20300105T090000Z'),
      );
      final v = await service.invitationOccurrenceApplication(single.entryId);
      expect(v.canApply, isFalse);
      await expectLater(
        service.applyInvitationOccurrenceUpdate(command(v)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      var text = utf8
          .decode(invitationBytes(sequence: 20))
          .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL')
          .replaceFirst(
            'BEGIN:VEVENT\r\n',
            'BEGIN:VEVENT\r\nSTATUS:CANCELLED\r\n',
          );
      text = text
          .split('\r\n')
          .where((l) => !l.startsWith('DTSTART') && !l.startsWith('SUMMARY'))
          .join('\r\n');
      final notice = await receive(Uint8List.fromList(utf8.encode(text)));
      final whole = await service.invitationApplication(notice.entryId);
      expect(whole.canApplyCancellation, isTrue);
      expect(whole.occurrenceCompositionBlocked, isFalse);
      await service.applyInvitationCancellation(masterCommand(whole));
      expect((await data()).content.status, CalendarEventStatus.cancelled);
      expect((await data()).timingOverrides!.cancelledFrom, isNotNull);
      expect(
        (await service.applyInvitationRangeCancellation(input)).id,
        cancelled.id,
      );
    });
    test('composition authority withdrawal blocks master retries while cancellation retry remains independent', () async {
      await setup();
      final input = await cancel();
      final cancelled = await service.applyInvitationRangeCancellation(input);
      final request = masterCommand(await newerMaster(sequence: 5));
      await service.applyInvitationUpdate(request);
      host.denied.add(
        CalendarInvitationOperation.composeAcceptedRangeCancellation,
      );
      await expectLater(
        service.applyInvitationUpdate(request),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await service.applyInvitationRangeCancellation(input)).id,
        cancelled.id,
      );
    });
    test('marker-only v5 upgrade is not inferred from v4', () async {
      await setup();
      final input = await cancel();
      await service.applyInvitationRangeCancellation(input);
      final r = await row(),
          state = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
      state['version'] = 5;
      await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
        session,
        r.copyWith(stateJson: jsonEncode(state)),
      );
      await expectLater(
        service.invitationRangeApplication(input.invitationId),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test(
      'masked master update invalidates plans once and retains cancelled booking',
      () async {
        final link = await setup(extra: ['DURATION:PT1H']);
        await service.applyInvitationRangeCancellation(await cancel());
        final input = masterCommand(
          await newerMaster(
            sequence: 5,
            extra: ['RRULE:FREQ=DAILY;COUNT=6', 'DURATION:PT1H'],
          ),
        );
        final query = CalendarFreeBusyQuery(
          calendarId: link.calendarId,
          fromUtc: DateTime.utc(2030),
          untilUtc: DateTime.utc(2030, 1, 4),
        );
        expect(
          (await service.freeBusy(query)).periods
              .where((v) => v.kind == CalendarFreeBusyKind.busy),
          hasLength(1),
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
        await service.applyInvitationUpdate(input);
        final busy = await service.freeBusy(query);
        expect(busy.coverage, CalendarFreeBusyCoverage.complete);
        expect(
          busy.periods.where((v) => v.kind == CalendarFreeBusyKind.busy),
          hasLength(1),
        );
        final changed = (await CalendarAlarmPlanRecord.db.findById(
          session,
          plan.id!,
        ))!;
        expect(changed.dirty, isTrue);
        expect(changed.leaseOwner, isNull);
        expect(changed.leaseFence, 9);
        await service.applyInvitationUpdate(input);
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
    for (final permission in [
      CalendarPermission.importEvents,
      CalendarPermission.replaceEventsFromImport,
      CalendarPermission.updateEvent,
    ]) {
      test(
        'masked preview respects native $permission without hiding readable state',
        () async {
          await setup();
          final input = await cancel();
          await service.applyInvitationRangeCancellation(input);
          final v = await newerMaster(sequence: 5);
          final request = masterCommand(v);
          policy.denied.add(permission);
          final blocked = await service.invitationApplication(v.invitationId);
          expect(blocked.hasAcceptedRangeCancellation, isTrue);
          expect(blocked.canApply, isFalse);
          await expectLater(
            service.applyInvitationUpdate(request),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(jsonDecode((await row()).stateJson)['version'], 4);
        },
      );
    }
    test(
      'masked preview also checks host master-application permission',
      () async {
        await setup();
        final input = await cancel();
        await service.applyInvitationRangeCancellation(input);
        final v = await newerMaster(sequence: 5);
        host.denied.add(CalendarInvitationOperation.apply);
        expect(
          (await service.invitationApplication(v.invitationId)).canApply,
          isFalse,
        );
        await expectLater(
          service.applyInvitationUpdate(masterCommand(v)),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    for (final field in [
      'cancellationBasis',
      'cancellationNativeDigest',
      'compositionDigest',
      'expectedNativeDigest',
      'receiptDigest',
    ]) {
      test('corrupt v5 $field fails unavailable', () async {
        await setup();
        final input = await cancel();
        await service.applyInvitationRangeCancellation(input);
        await service.applyInvitationUpdate(
          masterCommand(await newerMaster(sequence: 5)),
        );
        final r = await row(),
            state = jsonDecode((await row()).stateJson) as Map<String, dynamic>;
        if (field == 'cancellationBasis') {
          final basis = Map<String, dynamic>.from(state[field] as Map);
          basis['canonicalValue'] = '${basis['canonicalValue']} ';
          state[field] = basis;
        } else {
          state[field] = '0' * 64;
        }
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          r.copyWith(stateJson: jsonEncode(state)),
        );
        await expectLater(
          service.invitationRangeApplication(input.invitationId),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
  });
}
