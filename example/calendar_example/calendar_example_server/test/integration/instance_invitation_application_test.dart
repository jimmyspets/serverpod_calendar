import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'instance_invitations_test.dart' show instanceInvitationBytes;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('explicit occurrence application', (builder, endpoints) {
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
      service = CalendarModule.service(session);
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
    }) async {
      final master = await receive(
        invitationBytes(
          sequence: 1,
          date: date,
          zone: zone,
          extra: ['RRULE:FREQ=DAILY;COUNT=4'],
        ),
      );
      final calendar = (await service.create(createInput()))!;
      return service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: master.entryId,
          sourceId: master.sourceId,
          expectedRevision: master.entryRevision,
          calendarId: calendar.calendarId,
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
      bool cancel = false,
      bool date = false,
      String? zone,
      String? original,
    }) async {
      final r = await receive(
        instanceInvitationBytes(
          sequence: sequence,
          cancel: cancel,
          date: date,
          zone: zone,
          original: original,
        ),
      );
      final v = await service.invitationOccurrenceApplication(r.entryId);
      expect(v.canApply, isTrue);
      return command(v);
    }

    CalendarInvitationApplyRequest masterCommand(
      CalendarInvitationApplicationView v,
    ) => CalendarInvitationApplyRequest(
      invitationId: v.invitationId,
      sourceId: v.incomingSourceId!,
      linkId: v.linkId,
      expectedInvitationRevision: v.invitationRevision!,
      expectedEventRevision: v.eventRevision,
      expectedCalendarRevision: v.calendarRevision,
      expectedApplicationRevision: v.applicationRevision,
      expectedOccurrenceRevision: v.occurrenceRevision,
    );
    Future<CalendarInvitationApplicationView> newerMaster({
      int sequence = 3,
      bool date = false,
      String? zone,
      String summary = 'New master',
      List<String> extra = const ['RRULE:FREQ=DAILY;COUNT=4'],
    }) async {
      final source = await receive(
        invitationBytes(
          sequence: sequence,
          date: date,
          zone: zone,
          summary: summary,
          extra: extra,
        ),
      );
      return service.invitationApplication(source.entryId);
    }

    Future<CalendarInvitationApplicationView> wholeCancel(int sequence) async {
      final bytes = utf8
          .decode(invitationBytes(sequence: sequence))
          .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL')
          .replaceFirst('BEGIN:VEVENT', 'BEGIN:VEVENT\r\nSTATUS:CANCELLED');
      final source = await receive(Uint8List.fromList(utf8.encode(bytes)));
      return service.invitationApplication(source.entryId);
    }

    Future<CalendarEventDataRecord> data() async =>
        (await CalendarEventDataRecord.db.findFirstRow(session))!;
    Future<CalendarInvitationOccurrenceApplicationRecord> occRow() async =>
        (await CalendarInvitationOccurrenceApplicationRecord.db.findFirstRow(
          session,
        ))!;
    for (final profile in ['utc', 'date', 'Europe/Stockholm']) {
      test(
        '$profile replaces one occurrence and preserves master/version/identity',
        () async {
          final date = profile == 'date',
              zone = profile == 'Europe/Stockholm' ? profile : null;
          final link = await setup(date: date, zone: zone);
          final before = (await CalendarEventDataRecord.db.findFirstRow(
            session,
          ))!;
          final input = await update(date: date, zone: zone);
          final result = await service.applyInvitationOccurrenceUpdate(input);
          final after = (await CalendarEventDataRecord.db.findFirstRow(
            session,
          ))!;
          expect(
            after.protocolState!.version.toJson(),
            before.protocolState!.version.toJson(),
          );
          expect(after.content.toJson(), before.content.toJson());
          expect(
            after.timingOverrides!.singles.single.originalStart.start.day,
            2,
          );
          expect(
            after.timingOverrides!.singles.single.replacement!.start.day,
            1,
          );
          expect(result.eventId, link.eventId);
          expect(result.eventRevision, 2);
          expect(
            await CalendarInvitationApplicationRecord.db.count(session),
            0,
          );
          expect(
            await CalendarInvitationOccurrenceApplicationRecord.db.count(
              session,
            ),
            1,
          );
          expect(
            (await service.applyInvitationOccurrenceUpdate(input)).toJson(),
            result.toJson(),
          );
          expect(
            (await service.invitationApplication(link.invitationId))
                .occurrenceCompositionBlocked,
            isFalse,
          );
        },
      );
    }
    test('minimal cancellation preserves inheritance and source omissions; newer REQUEST reopens', () async {
      await setup();
      final input = await update(sequence: 2, cancel: true);
      final result = await service.applyInvitationOccurrenceCancellation(input);
      final after = (await CalendarEventDataRecord.db.findFirstRow(session))!;
      expect(after.timingOverrides!.singles.single.cancelled, isTrue);
      expect(after.timingOverrides!.singles.single.replacement, isNull);
      final view = await service.invitationOccurrenceApplication(
        input.invitationId,
      );
      expect(view.acceptedSourceText, contains('METHOD:CANCEL'));
      expect(view.acceptedSourceText, isNot(contains('DTSTART:')));
      expect(view.acceptedVersion.sequence, 2);
      expect(view.currentOccurrence!.status, CalendarEventStatus.cancelled);
      expect(
        (await service.applyInvitationOccurrenceCancellation(input)).id,
        result.id,
      );
      final reopened = await update(sequence: 3);
      await service.applyInvitationOccurrenceUpdate(reopened);
      expect(
        (await CalendarEventDataRecord.db.findFirstRow(session))!
            .timingOverrides!
            .singles
            .single
            .cancelled,
        isFalse,
      );
      await expectLater(
        service.applyInvitationOccurrenceCancellation(input),
        failure(CalendarFailureCode.staleRevision),
      );
    });
    test('sibling application preserves prior target and supersedes link retry slot', () async {
      await setup();
      final first = await update();
      await service.applyInvitationOccurrenceUpdate(first);
      final second = await update(original: '20300103T090000Z');
      await service.applyInvitationOccurrenceUpdate(second);
      final row = (await CalendarInvitationOccurrenceApplicationRecord.db
          .findFirstRow(session))!;
      expect((jsonDecode(row.stateJson)['targets'] as List), hasLength(2));
      expect(
        (await CalendarEventDataRecord.db.findFirstRow(session))!
            .timingOverrides!
            .singles,
        hasLength(2),
      );
      await expectLater(
        service.applyInvitationOccurrenceUpdate(first),
        failure(CalendarFailureCode.staleRevision),
      );
    });
    test(
      'any local series edit blocks application; final denial rolls back',
      () async {
        final link = await setup();
        final input = await update();
        final data = (await CalendarEventDataRecord.db.findFirstRow(session))!;
        data.content = data.content.copyWith(summary: 'local');
        await CalendarEventDataRecord.db.updateRow(session, data);
        await expectLater(
          service.applyInvitationOccurrenceUpdate(input),
          failure(CalendarFailureCode.dependencyConflict),
        );
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
        data.content = data.content.copyWith(summary: 'Review');
        await CalendarEventDataRecord.db.updateRow(session, data);
        host.onAuthorize = (c, tx, phase) async {
          if (phase == CalendarAuthorizationPhase.finalWrite &&
              c.operation ==
                  CalendarInvitationOperation.applyOccurrenceUpdate) {
            throw CalendarException(
              code: CalendarFailureCode.accessDenied,
              message: 'Final denial',
            );
          }
        };
        await expectLater(
          service.applyInvitationOccurrenceUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await CalendarEventRecord.db.findById(
            session,
            link.eventId,
          ))!.revision,
          1,
        );
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
        expect(
          (await service.getInvitation(input.invitationId)).dismissedAt,
          isNull,
        );
      },
    );
    for (final op in [
      CalendarInvitationOperation.readOccurrenceApplication,
      CalendarInvitationOperation.applyOccurrenceUpdate,
      CalendarInvitationOperation.readSource,
      CalendarInvitationOperation.readApplication,
    ]) {
      test('independent $op denial precedes mutation', () async {
        await setup();
        final input = await update();
        host.denied.add(op);
        await expectLater(
          service.applyInvitationOccurrenceUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
      });
    }
    test('master new application requires occurrence revision; deletion remains safe', () async {
      final link = await setup();
      final input = await update();
      await service.applyInvitationOccurrenceUpdate(input);
      final incoming = await receive(
        invitationBytes(sequence: 3, extra: ['RRULE:FREQ=DAILY;COUNT=4']),
      );
      final v = await service.invitationApplication(incoming.entryId);
      expect(v.occurrenceCompositionBlocked, isFalse);
      expect(v.canApply, isTrue);
      expect(v.hasLocalChanges, isFalse);
      await expectLater(
        service.applyInvitationUpdate(
          CalendarInvitationApplyRequest(
            invitationId: v.invitationId,
            sourceId: v.incomingSourceId!,
            expectedInvitationRevision: v.invitationRevision!,
            linkId: v.linkId,
            expectedEventRevision: v.eventRevision,
            expectedCalendarRevision: v.calendarRevision,
            expectedApplicationRevision: v.applicationRevision,
          ),
        ),
        failure(CalendarFailureCode.staleRevision),
      );
      await service.deleteEvent(link.eventId, 2);
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
      expect(await CalendarInvitationLinkRecord.db.count(session), 1);
    });
    test('malformed checkpoint fails unavailable and byte quota rejects atomically', () async {
      await setup();
      final input = await update();
      install(
        options: CalendarInvitationOptions(maxOccurrenceCheckpointBytes: 1),
      );
      service = CalendarModule.service(session);
      await expectLater(
        service.applyInvitationOccurrenceUpdate(input),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
      install();
      service = CalendarModule.service(session);
      await service.applyInvitationOccurrenceUpdate(input);
      final row = (await CalendarInvitationOccurrenceApplicationRecord.db
          .findFirstRow(session))!;
      row.stateJson = row.stateJson.replaceFirst('"version":1', '"version":99');
      await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
        session,
        row,
      );
      await expectLater(
        service.invitationOccurrenceApplication(input.invitationId),
        failure(CalendarFailureCode.unavailable),
      );
    });

    test('retained source and exact retry survive body pruning without reactivation', () async {
      await setup();
      final input = await update();
      final first = await service.applyInvitationOccurrenceUpdate(input);
      final source = (await CalendarInvitationSourceRecord.db.findById(
        session,
        input.sourceId,
      ))!;
      final entry = (await CalendarInvitationRecord.db.findById(
        session,
        input.invitationId,
      ))!;
      entry.currentSourceId = null;
      await CalendarInvitationRecord.db.updateRow(session, entry);
      await CalendarInvitationReceiptRecord.db.deleteWhere(
        session,
        where: (t) => t.sourceId.equals(source.id!),
      );
      await CalendarInvitationSourceRecord.db.deleteRow(session, source);
      final v = await service.invitationOccurrenceApplication(entry.id!);
      expect(v.incomingSourceText, isNull);
      expect(v.acceptedSourceText, contains('RECURRENCE-ID'));
      expect(
        (await service.applyInvitationOccurrenceUpdate(input)).id,
        first.id,
      );
      final newer = await receive(instanceInvitationBytes(sequence: 3));
      expect(newer.entryId, entry.id);
      await service.applyInvitationOccurrenceUpdate(input);
      expect((await service.getInvitation(entry.id!)).dismissedAt, isNull);
    });
    test('accepted master checkpoint stays frozen and its exact retry survives instance apply', () async {
      final link = await setup();
      final source = await receive(
        invitationBytes(sequence: 2, extra: ['RRULE:FREQ=DAILY;COUNT=4']),
      );
      final v = await service.invitationApplication(source.entryId);
      final masterRequest = CalendarInvitationApplyRequest(
        invitationId: source.entryId,
        sourceId: source.sourceId,
        linkId: link.id,
        expectedInvitationRevision: v.invitationRevision!,
        expectedEventRevision: v.eventRevision,
        expectedCalendarRevision: v.calendarRevision,
        expectedApplicationRevision: v.applicationRevision,
      );
      final masterResult = await service.applyInvitationUpdate(masterRequest);
      final before = (await CalendarInvitationApplicationRecord.db.findFirstRow(
        session,
      ))!.toJson();
      final input = await update(sequence: 3);
      await service.applyInvitationOccurrenceUpdate(input);
      expect(
        (await CalendarInvitationApplicationRecord.db.findFirstRow(session))!
            .toJson(),
        before,
      );
      expect(
        (await service.applyInvitationUpdate(masterRequest)).id,
        masterResult.id,
      );
      expect(
        (await service.invitationApplication(link.invitationId))
            .hasLocalChanges,
        isFalse,
      );
    });
    test(
      'reopening requires lifecycle authority; private history is not inferred',
      () async {
        await setup();
        final cancel = await update(cancel: true);
        await service.applyInvitationOccurrenceCancellation(cancel);
        final reopen = await update(sequence: 3);
        policy.denied.add(CalendarPermission.changeEventStatus);
        await expectLater(
          service.applyInvitationOccurrenceUpdate(reopen),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await CalendarEventDataRecord.db.findFirstRow(session))!
              .timingOverrides!
              .singles
              .single
              .cancelled,
          isTrue,
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      },
    );
    for (final permission in [
      CalendarPermission.readEvent,
      CalendarPermission.readEventSource,
      CalendarPermission.importEvents,
      CalendarPermission.replaceEventsFromImport,
      CalendarPermission.updateEvent,
    ]) {
      test('native $permission remains required', () async {
        await setup();
        final input = await update();
        policy.denied.add(permission);
        await expectLater(
          service.applyInvitationOccurrenceUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
      });
    }
    for (final limit in ['recipient', 'scope']) {
      test('$limit checkpoint byte ceiling rejects atomically', () async {
        await setup();
        final input = await update();
        install(
          options: CalendarInvitationOptions(
            maxRecipientOccurrenceBytes: limit == 'recipient' ? 1 : 16777216,
            maxScopeOccurrenceBytes: limit == 'scope' ? 1 : 67108864,
          ),
        );
        service = CalendarModule.service(session);
        await expectLater(
          service.applyInvitationOccurrenceUpdate(input),
          failure(CalendarFailureCode.limitExceeded),
        );
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
    for (final field in [
      'baselineDigest',
      'masterDigest',
      'masterBaselineDigest',
      'component',
      'digest',
    ]) {
      test('corrupt $field binding fails unavailable', () async {
        await setup();
        final input = await update();
        await service.applyInvitationOccurrenceUpdate(input);
        final row = (await CalendarInvitationOccurrenceApplicationRecord.db
            .findFirstRow(session))!;
        final state = jsonDecode(row.stateJson) as Map<String, dynamic>;
        if (field == 'component' || field == 'digest') {
          state['targets'][0][field] = 'bad';
        } else {
          state[field] = 'bad';
        }
        row.stateJson = jsonEncode(state);
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          session,
          row,
        );
        await expectLater(
          service.invitationOccurrenceApplication(input.invitationId),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }

    test('source/component binding survives parameter map order and rejects rebound source', () async {
      Uint8List annotated(Uint8List bytes) => Uint8List.fromList(
        utf8.encode(
          utf8
              .decode(bytes)
              .replaceAll('ORGANIZER:', 'ORGANIZER;LANGUAGE=en;CN=Organizer:'),
        ),
      );
      final master = await receive(
        annotated(
          invitationBytes(sequence: 1, extra: ['RRULE:FREQ=DAILY;COUNT=4']),
        ),
      );
      final parent = (await service.create(createInput()))!;
      await service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: master.entryId,
          sourceId: master.sourceId,
          expectedRevision: master.entryRevision,
          calendarId: parent.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
      final incoming = await receive(
        annotated(instanceInvitationBytes(sequence: 2)),
      );
      final input = command(
        await service.invitationOccurrenceApplication(incoming.entryId),
      );
      final first = await service.applyInvitationOccurrenceUpdate(input);
      expect(
        (await service.applyInvitationOccurrenceUpdate(input)).id,
        first.id,
      );
      final row = (await CalendarInvitationOccurrenceApplicationRecord.db
          .findFirstRow(session))!;
      final state = jsonDecode(row.stateJson) as Map<String, dynamic>;
      final target = state['targets'][0] as Map<String, dynamic>;
      target['source'] = (target['source'] as String).replaceFirst(
        'SUMMARY:Review',
        'SUMMARY:Changed',
      );
      target['digest'] = sha256
          .convert(utf8.encode(target['source'] as String))
          .toString();
      row.stateJson = jsonEncode(state);
      await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
        session,
        row,
      );
      await expectLater(
        service.invitationOccurrenceApplication(input.invitationId),
        failure(CalendarFailureCode.unavailable),
      );
    });

    test('reopening lifecycle policy sees actual before and validated proposed overrides at commit', () async {
      await setup();
      final cancelled = await update(cancel: true);
      await service.applyInvitationOccurrenceCancellation(cancelled);
      final reopened = await update(sequence: 3);
      final phases = <CalendarAuthorizationPhase>[];
      policy.onEventLifecycle = (request, phase) {
        phases.add(phase);
        expect(
          request.currentEvent!.timingOverrides!.singles.single.cancelled,
          isTrue,
        );
        expect(
          request.proposedTimingOverrides!.singles.single.cancelled,
          isFalse,
        );
        expect(
          request.proposedEventProtocolState!.overrides.single.version.sequence,
          3,
        );
      };
      await service.applyInvitationOccurrenceUpdate(reopened);
      expect(
        phases,
        containsAll([
          CalendarAuthorizationPhase.preliminaryWrite,
          CalendarAuthorizationPhase.finalWrite,
        ]),
      );
    });

    test('preliminary missing source context is unknown rather than falsely unavailable', () async {
      await setup();
      final input = await update();
      var sawUnknown = false, sawLoaded = false;
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.applyOccurrenceUpdate) {
          if (c.link == null) {
            expect(c.historicalSourceUnavailable, isNull);
            sawUnknown = true;
          }
          if (c.message != null) {
            expect(c.historicalSourceUnavailable, isFalse);
            sawLoaded = true;
          }
        }
      };
      await service.applyInvitationOccurrenceUpdate(input);
      expect(sawUnknown, isTrue);
      expect(sawLoaded, isTrue);
    });

    for (final profile in ['utc', 'date', 'Europe/Stockholm']) {
      test(
        '$profile master composition preserves moved instance and historical retries',
        () async {
          final date = profile == 'date',
              zone = profile == 'Europe/Stockholm' ? profile : null;
          await setup(date: date, zone: zone);
          final input = await update(sequence: 20, date: date, zone: zone);
          final receipt = await service.applyInvitationOccurrenceUpdate(input);
          final old = await data(), checkpoint = await occRow();
          final preview = await newerMaster(
            sequence: 2,
            date: date,
            zone: zone,
          );
          expect(preview.canApply, isTrue);
          expect(preview.occurrenceRevision, 1);
          final master = masterCommand(preview);
          final result = await service.applyInvitationUpdate(master);
          final saved = await data();
          expect(saved.content.summary, 'New master');
          expect(
            saved.timingOverrides!.toJson(),
            old.timingOverrides!.toJson(),
          );
          expect(saved.protocolState!.overrides.single.version.sequence, 20);
          expect(saved.protocolState!.version.sequence, 2);
          expect(saved.origin, old.origin);
          final row = await occRow(), state = jsonDecode(row.stateJson) as Map;
          expect(row.revision, 2);
          expect(row.eventRevision, 3);
          expect(state['version'], 2);
          expect(
            state['receipt'],
            (jsonDecode(checkpoint.stateJson) as Map)['receipt'],
          );
          expect(
            (await service.applyInvitationOccurrenceUpdate(input)).toJson(),
            receipt.toJson(),
          );
          expect(
            (await service.applyInvitationUpdate(master)).toJson(),
            result.toJson(),
          );
          expect((await occRow()).revision, 2);
          // Another occurrence action remains valid on the converted v2 checkpoint.
          final next = await update(sequence: 21, date: date, zone: zone);
          await service.applyInvitationOccurrenceUpdate(next);
          expect((jsonDecode((await occRow()).stateJson) as Map)['version'], 2);
          expect(
            (await service.invitationApplication(preview.invitationId))
                .occurrenceRevision,
            3,
          );
        },
      );
    }
    test('whole cancel floor exceeds all targets; reopen preserves independent cancellation and inheritance', () async {
      await setup();
      final input = await update(sequence: 20, cancel: true);
      final historical = await service.applyInvitationOccurrenceCancellation(
        input,
      );
      final before = await data();
      final blocked = await wholeCancel(3);
      expect(blocked.canApplyCancellation, isFalse);
      expect(blocked.occurrenceCompositionBlocked, isTrue);
      await expectLater(
        service.applyInvitationCancellation(masterCommand(blocked)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(
        (await data()).importBaseline!.canonicalValue,
        before.importBaseline!.canonicalValue,
      );
      final cancel = await wholeCancel(21);
      expect(cancel.canApplyCancellation, isTrue);
      final command = masterCommand(cancel);
      final cancellation = await service.applyInvitationCancellation(command);
      expect((await data()).content.status, CalendarEventStatus.cancelled);
      expect((await data()).timingOverrides!.singles.single.cancelled, isTrue);
      expect(
        (await service.applyInvitationOccurrenceCancellation(input)).id,
        historical.id,
      );
      final reopen = await newerMaster(sequence: 22);
      expect(reopen.canApply, isTrue);
      await service.applyInvitationUpdate(masterCommand(reopen));
      final current = await data();
      expect(current.content.status, CalendarEventStatus.confirmed);
      expect(current.timingOverrides!.singles.single.cancelled, isTrue);
      expect(current.timingOverrides!.singles.single.replacement, isNull);
      expect(current.protocolState!.overrides.single.version.sequence, 20);
      expect(
        (await service.applyInvitationOccurrenceCancellation(input)).id,
        historical.id,
      );
      expect(cancellation.eventRevision, 3);
    });
    for (final pattern in [
      <String>['RRULE:FREQ=DAILY;COUNT=1'],
      <String>['RRULE:FREQ=DAILY;COUNT=4', 'EXDATE:20300102T090000Z'],
    ]) {
      test('reject orphaning master $pattern atomically', () async {
        await setup();
        await service.applyInvitationOccurrenceUpdate(await update());
        final before = await data(), row = await occRow();
        final preview = await newerMaster(extra: pattern);
        expect(preview.occurrenceCompositionBlocked, isTrue);
        expect(preview.canApply, isFalse);
        await expectLater(
          service.applyInvitationUpdate(masterCommand(preview)),
          throwsA(isA<CalendarException>()),
        );
        expect(
          (await data()).importBaseline!.canonicalValue,
          before.importBaseline!.canonicalValue,
        );
        expect((await occRow()).stateJson, row.stateJson);
        expect(
          (await service.getInvitation(preview.invitationId)).dismissedAt,
          isNull,
        );
      });
    }
    for (final op in [
      CalendarInvitationOperation.composeAcceptedOccurrences,
      CalendarInvitationOperation.readOccurrenceApplication,
    ]) {
      test(
        'composition requires $op independently and rolls back final denial',
        () async {
          await setup();
          await service.applyInvitationOccurrenceUpdate(await update());
          final preview = await newerMaster();
          final input = masterCommand(preview);
          final before = await data();
          var finalSeen = false;
          host.onAuthorize = (c, tx, phase) async {
            if (c.operation == op &&
                phase == CalendarAuthorizationPhase.finalWrite) {
              finalSeen = true;
              expect(c.currentOccurrenceApplication!.revision, 1);
              expect(c.proposedOccurrenceApplication!.revision, 2);
              expect(c.currentApplication!.revision, 0);
              expect(c.proposedApplication!.revision, 1);
              expect(c.proposedEvent!.timingOverrides!.singles, hasLength(1));
              host.denied.add(op);
            }
          };
          await expectLater(
            service.applyInvitationUpdate(input),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(finalSeen, isTrue);
          host.onAuthorize = null;
          expect((await occRow()).revision, 1);
          expect(
            (await data()).importBaseline!.canonicalValue,
            before.importBaseline!.canonicalValue,
          );
        },
      );
    }
    test('PERIOD originals, cancelled inheritance and own text survive master changes', () async {
      final master = await receive(
        invitationBytes(
          sequence: 1,
          extra: [
            'RRULE:FREQ=DAILY;COUNT=4',
            'RDATE;VALUE=PERIOD:20300107T090000Z/PT2H',
          ],
        ),
      );
      final calendar = (await service.create(createInput()))!;
      await service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: master.entryId,
          sourceId: master.sourceId,
          expectedRevision: master.entryRevision,
          calendarId: calendar.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
      final original = await update(original: '20300107T090000Z', cancel: true);
      await service.applyInvitationOccurrenceCancellation(original);
      await service.applyInvitationOccurrenceUpdate(
        await update(original: '20300102T090000Z', sequence: 7),
      );
      final preview = await newerMaster(
        sequence: 3,
        extra: [
          'RRULE:FREQ=DAILY;COUNT=5',
          'RDATE;VALUE=PERIOD:20300107T090000Z/PT3H',
        ],
      );
      expect(preview.canApply, isTrue);
      await service.applyInvitationUpdate(masterCommand(preview));
      final cancelled = await service.invitationOccurrenceApplication(
        original.invitationId,
      );
      expect(cancelled.currentOccurrence!.summary, 'New master');
      expect(cancelled.currentOccurrence!.timing.duration!.hours, 3);
      expect(
        cancelled.currentOccurrence!.status,
        CalendarEventStatus.cancelled,
      );
      final saved = await data();
      final own = saved.timingOverrides!.singles.singleWhere(
        (v) => v.originalStart.start.day == 2,
      );
      expect(own.contentOverrides!.summary, 'Review');
      expect(
        saved.protocolState!.overrides.map((v) => v.version.sequence),
        containsAll([2, 7]),
      );
    });
    test(
      'DST-bound named original survives composition without being retargeted',
      () async {
        Uint8List march(Uint8List bytes) => Uint8List.fromList(
          utf8.encode(
            utf8.decode(bytes).replaceAll('20300101T090000', '20300330T090000'),
          ),
        );
        final master = await receive(
          march(
            invitationBytes(
              sequence: 1,
              zone: 'Europe/Stockholm',
              extra: ['RRULE:FREQ=DAILY;COUNT=4'],
            ),
          ),
        );
        final calendar = (await service.create(createInput()))!;
        await service.adoptInvitation(
          CalendarInvitationAdoptionRequest(
            invitationId: master.entryId,
            sourceId: master.sourceId,
            expectedRevision: master.entryRevision,
            calendarId: calendar.calendarId,
            expectedCalendarRevision: 1,
          ),
        );
        final input = await update(
          zone: 'Europe/Stockholm',
          original: '20300331T090000',
        );
        await service.applyInvitationOccurrenceUpdate(input);
        final before = (await data()).timingOverrides!.toJson();
        final source = await receive(
          march(
            invitationBytes(
              sequence: 3,
              summary: 'DST master',
              zone: 'Europe/Stockholm',
              extra: ['RRULE:FREQ=DAILY;COUNT=5'],
            ),
          ),
        );
        final preview = await service.invitationApplication(source.entryId);
        expect(preview.canApply, isTrue);
        await service.applyInvitationUpdate(masterCommand(preview));
        expect((await data()).timingOverrides!.toJson(), before);
        expect(
          (await service.applyInvitationOccurrenceUpdate(input)).eventRevision,
          2,
        );
      },
    );
    test('master composition rejects local edits, incompatible DATE profile and lower host quotas', () async {
      await setup();
      await service.applyInvitationOccurrenceUpdate(await update());
      final incompatible = await newerMaster(date: true);
      expect(incompatible.occurrenceCompositionBlocked, isTrue);
      final preview = await newerMaster(sequence: 4);
      final input = masterCommand(preview), before = await data();
      install(
        options: CalendarInvitationOptions(maxOccurrenceCheckpointBytes: 1),
      );
      service = CalendarModule.service(session);
      expect(
        (await service.invitationApplication(preview.invitationId))
            .occurrenceCompositionBlocked,
        isTrue,
      );
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.limitExceeded),
      );
      install();
      service = CalendarModule.service(session);
      final local = before.copyWith(
        content: before.content.copyWith(summary: 'Private draft'),
      );
      await CalendarEventDataRecord.db.updateRow(session, local);
      expect(
        (await service.invitationApplication(preview.invitationId))
            .hasLocalChanges,
        isTrue,
      );
      await expectLater(
        service.applyInvitationUpdate(input),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await data()).content.summary, 'Private draft');
      expect((await occRow()).revision, 1);
    });
    test('v2 historical retries survive pruning; deletion scrubs composed evidence', () async {
      final link = await setup();
      final input = await update();
      final result = await service.applyInvitationOccurrenceUpdate(input);
      final preview = await newerMaster();
      await service.applyInvitationUpdate(masterCommand(preview));
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
      final pending = await receive(instanceInvitationBytes(sequence: 4));
      expect(
        (await service.applyInvitationOccurrenceUpdate(input)).toJson(),
        result.toJson(),
      );
      expect(
        (await service.getInvitation(pending.entryId)).dismissedAt,
        isNull,
      );
      expect(
        (await service.invitationOccurrenceApplication(input.invitationId))
            .acceptedSourceText,
        contains('RECURRENCE-ID'),
      );
      await service.deleteEvent(link.eventId, 3);
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
        0,
      );
      expect(await CalendarEventDataRecord.db.count(session), 0);
    });
    test('composition refuses occurrence revision overflow without altering accepted layers', () async {
      await setup();
      await service.applyInvitationOccurrenceUpdate(await update());
      final preview = await newerMaster();
      await service.applyInvitationUpdate(masterCommand(preview));
      final row = await occRow();
      row.revision = 9007199254740991;
      await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
        session,
        row,
      );
      final incoming = await newerMaster(sequence: 4);
      expect(incoming.occurrenceCompositionBlocked, isTrue);
      final before = await data();
      await expectLater(
        service.applyInvitationUpdate(masterCommand(incoming)),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(
        (await data()).importBaseline!.canonicalValue,
        before.importBaseline!.canonicalValue,
      );
      expect((await occRow()).revision, row.revision);
    });
    test(
      'v2 composition rejects corrupt master layer and historical receipt',
      () async {
        await setup();
        await service.applyInvitationOccurrenceUpdate(await update());
        final preview = await newerMaster();
        await service.applyInvitationUpdate(masterCommand(preview));
        final row = await occRow(), valid = (await occRow()).stateJson;
        for (final corrupt in ['master', 'receipt']) {
          final state = jsonDecode(valid) as Map<String, dynamic>;
          if (corrupt == 'master') {
            state['masterBaseline'] =
                (jsonDecode(valid) as Map)['masterBaseline'];
            state['masterBaselineDigest'] = '0' * 64;
          } else {
            state['receipt']['appliedAt'] = '20000101T000000Z';
          }
          row.stateJson = jsonEncode(state);
          await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
            session,
            row,
          );
          await expectLater(
            service.invitationApplication(preview.invitationId),
            failure(CalendarFailureCode.unavailable),
          );
          row.stateJson = valid;
          await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
            session,
            row,
          );
        }
      },
    );
    test('pending instance preview identifies an accepted whole-master cancellation', () async {
      final link = await setup();
      final pending = await receive(instanceInvitationBytes(sequence: 2));
      final bytes = Uint8List.fromList(
        utf8.encode(
          utf8
              .decode(invitationBytes(sequence: 3))
              .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL')
              .replaceFirst(
                'BEGIN:VEVENT\r\n',
                'BEGIN:VEVENT\r\nSTATUS:CANCELLED\r\n',
              ),
        ),
      );
      final source = await receive(bytes);
      final master = await service.invitationApplication(source.entryId);
      await service.applyInvitationCancellation(
        CalendarInvitationApplyRequest(
          invitationId: source.entryId,
          sourceId: source.sourceId,
          linkId: link.id,
          expectedInvitationRevision: master.invitationRevision!,
          expectedEventRevision: master.eventRevision,
          expectedCalendarRevision: master.calendarRevision,
          expectedApplicationRevision: master.applicationRevision,
        ),
      );
      final view = await service.invitationOccurrenceApplication(
        pending.entryId,
      );
      expect(
        view.acceptedKind,
        CalendarInvitationSourceKind.meetingCancellation,
      );
      expect(view.acceptedVersion.sequence, 3);
      expect(view.currentOccurrence!.status, CalendarEventStatus.cancelled);
      expect(view.canApply, isFalse);
    });
  });
}
