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
            isTrue,
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
    test('master new application guarded; creation retry and event deletion remain safe', () async {
      final link = await setup();
      final input = await update();
      await service.applyInvitationOccurrenceUpdate(input);
      final incoming = await receive(
        invitationBytes(sequence: 3, extra: ['RRULE:FREQ=DAILY;COUNT=4']),
      );
      final v = await service.invitationApplication(incoming.entryId);
      expect(v.occurrenceCompositionBlocked, isTrue);
      expect(v.canApply, isFalse);
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
        failure(CalendarFailureCode.dependencyConflict),
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
      row.stateJson = row.stateJson.replaceFirst('"version":1', '"version":2');
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
