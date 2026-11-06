import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, failure, createInput;
import 'invitation_test.dart' show InvitationTestHost, invitationDelivery;
import 'invitation_bundles_test.dart' show bundleBytes;
import 'bundled_invitation_updates_test.dart' show updatedBundle;
import 'bundled_invitation_lifecycle_test.dart' show bundleCancellationBytes;
import 'invitation_responses_test.dart' show ResponseHost, ResponseTransport;
import 'test_tools/serverpod_test_tools.dart';

CalendarEventTiming bundleResponsePoint(int day, {String profile = 'utc'}) =>
    CalendarEventTiming(
      kind: profile == 'date'
          ? CalendarEventTimeKind.date
          : profile == 'utc'
          ? CalendarEventTimeKind.utc
          : CalendarEventTimeKind.zoned,
      zoneId: profile == 'date' || profile == 'utc' ? null : profile,
      start: CalendarEventCivil(
        year: 2030,
        month: 1,
        day: day,
        hour: profile == 'date' ? 0 : 9,
      ),
    );
void main() {
  withServerpod('independent bundled occurrence responses', (
    builder,
    endpoints,
  ) {
    late Session session;
    late InvitationTestHost invitations;
    late ResponseHost host;
    late ResponseTransport transport;
    late CalendarService service;
    void install({
      CalendarInvitationResponseOptions? options,
      CalendarInvitationOptions? invitationOptions,
    }) {
      CalendarModule.install(
        session.serverpod,
        policy: TestPolicy(),
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(
          host: invitations,
          options: invitationOptions,
          responses: CalendarInvitationResponseRuntime(
            host: host,
            transport: transport,
            options: options,
          ),
        ),
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
      invitations = InvitationTestHost();
      host = ResponseHost();
      transport = ResponseTransport();
      install();
    });
    Future<CalendarInvitationReceipt> receive({
      String profile = 'utc',
      Uint8List? bytes,
      String key = 'initial',
    }) => CalendarModule.receiveSchedulingInvitation(
      session,
      invitationDelivery(
        key: key,
        bytes:
            bytes ??
            bundleBytes(
              date: profile == 'date',
              zone: profile == 'date' || profile == 'utc' ? null : profile,
            ),
      ),
    );
    Future<CalendarInvitationBundleOccurrenceResponseRequest> command(
      CalendarInvitationReceipt source,
      CalendarEventTiming point, {
      CalendarInvitationResponseChoice choice =
          CalendarInvitationResponseChoice.accepted,
    }) async {
      final view = await service.invitationBundleOccurrenceResponse(
        source.entryId,
        point,
      );
      return CalendarInvitationBundleOccurrenceResponseRequest(
        originalStart: point,
        request: CalendarInvitationResponseRequest(
          invitationId: source.entryId,
          sourceId: view.currentSourceId!,
          expectedInvitationRevision: view.invitationRevision,
          expectedResponseRevision: view.response.revision,
          commandId: const Uuid().v4obj(),
          choice: choice,
        ),
      );
    }

    Future<void> advance(int day) async {
      final states = await CalendarInvitationResponseStateRecord.db.find(
        session,
      );
      final stamp = states
          .singleWhere((v) => v.responseOriginalStart?.start.day == day)
          .lastStamp;
      for (var i = 0; i < 50; i++) {
        final now =
            (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                    .single
                    .single
                as DateTime;
        if (now.millisecondsSinceEpoch ~/ 1000 >
            stamp.millisecondsSinceEpoch ~/ 1000) {
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      throw StateError('Database second did not advance');
    }

    Future<void> adopt(CalendarInvitationReceipt source) async {
      final calendar = (await service.create(createInput()))!;
      await service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: source.entryId,
          expectedRevision: source.entryRevision,
          sourceId: source.sourceId,
          calendarId: calendar.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
    }

    CalendarInvitationApplyRequest apply(
      CalendarInvitationBundleApplicationView view,
    ) => CalendarInvitationApplyRequest(
      invitationId: view.invitationId,
      sourceId: view.incomingSourceId!,
      expectedInvitationRevision: view.invitationRevision!,
      linkId: view.linkId,
      expectedEventRevision: view.eventRevision,
      expectedCalendarRevision: view.calendarRevision,
      expectedApplicationRevision: view.applicationRevision,
    );
    for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
      for (final (day, sequence, anchor) in [
        (1, 2, null),
        (2, null, 2),
        (4, 2, null),
        (5, 12, 5),
        (7, 12, 5),
      ]) {
        test(
          '$profile original $day binds effective version $sequence without adoption',
          () async {
            final source = await receive(profile: profile),
                point = bundleResponsePoint(day, profile: profile);
            final view = await service.invitationBundleOccurrenceResponse(
              source.entryId,
              point,
            );
            expect(view.response.revision, 0);
            expect(view.response.canSend, isTrue);
            expect(view.componentVersion!.sequence, sequence);
            expect(view.componentVersion!.originalStart?.start.day, anchor);
            final request = await command(source, point);
            final receipt = await service
                .sendInvitationBundleOccurrenceResponse(request);
            expect(
              (await service.sendInvitationBundleOccurrenceResponse(request))
                  .toJson(),
              receipt.toJson(),
            );
            final own = await service.invitationBundleOccurrenceResponse(
              source.entryId,
              point,
            );
            expect(own.response.sourceSequence, sequence);
            expect(own.response.originalStart!.toJson(), point.toJson());
            expect(
              (await service.invitationBundleResponse(source.entryId)).revision,
              0,
            );
            expect(await CalendarEventRecord.db.count(session), 0);
            expect(await CalendarInvitationLinkRecord.db.count(session), 0);
            await CalendarModule.runInvitationResponseMaintenance(session);
            final row = (await CalendarInvitationResponseRecord.db.find(
              session,
            )).single;
            expect(row.state, CalendarInvitationResponseDeliveryState.accepted);
            expect(row.responseOriginalStart!.toJson(), point.toJson());
            expect(row.targetKey, startsWith('bundle-occurrence-v1:'));
            final parsed = parseIcalendarSchedulingMessage(
              utf8.encode(transport.submissions.single.payload),
            );
            final event = parsed.events.single;
            expect(event.sequence, sequence);
            expect(event.isOverride, isTrue);
            expect(event.isThisAndFuture, isFalse);
            expect(
              event.originalDate?.day ?? event.originalTime!.civil.date.day,
              day,
            );
            expect(event.originalTime?.zoneId, point.zoneId);
            expect(
              host.contexts.any(
                (c) =>
                    c.operation ==
                        CalendarInvitationResponseOperation
                            .dispatchBundleOccurrence &&
                    c.actor == null &&
                    c.responseOriginalStart?.start.day == day,
              ),
              isTrue,
            );
            expect(
              (await service.invitationBundleOccurrenceResponseActivity(
                source.entryId,
                point,
              )).single.sourceSequence,
              sequence,
            );
          },
        );
      }
    }
    test(
      'master and sibling intents remain queued and independently accepted',
      () async {
        final source = await receive();
        final master = CalendarInvitationResponseRequest(
          invitationId: source.entryId,
          sourceId: source.sourceId,
          expectedInvitationRevision: 1,
          expectedResponseRevision: 0,
          commandId: const Uuid().v4obj(),
          choice: CalendarInvitationResponseChoice.declined,
        );
        await service.sendInvitationBundleResponse(master);
        for (final day in [1, 2, 7]) {
          await service.sendInvitationBundleOccurrenceResponse(
            await command(source, bundleResponsePoint(day)),
          );
        }
        final rows = await CalendarInvitationResponseRecord.db.find(session);
        expect(rows, hasLength(4));
        expect(
          rows.every(
            (r) => r.state == CalendarInvitationResponseDeliveryState.queued,
          ),
          isTrue,
        );
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          4,
        );
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(transport.submissions, hasLength(4));
        expect(
          (await service.invitationBundleResponse(source.entryId)).choice,
          CalendarInvitationResponseChoice.declined,
        );
      },
    );
    for (final denied in [
      CalendarInvitationResponseOperation.readBundleOccurrence,
      CalendarInvitationResponseOperation.sendBundleOccurrence,
    ]) {
      test('$denied is independent of master authority', () async {
        final source = await receive();
        final request = await command(source, bundleResponsePoint(3));
        host.denied.add(denied);
        await expectLater(
          service.sendInvitationBundleOccurrenceResponse(request),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      });
    }
    test(
      'dispatch target denial withdraws work without a fabricated actor',
      () async {
        final source = await receive();
        await service.sendInvitationBundleOccurrenceResponse(
          await command(source, bundleResponsePoint(3)),
        );
        host.denied.add(
          CalendarInvitationResponseOperation.dispatchBundleOccurrence,
        );
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(transport.submissions, isEmpty);
        expect(
          (await CalendarInvitationResponseRecord.db.find(session))
              .single
              .state,
          CalendarInvitationResponseDeliveryState.withdrawn,
        );
      },
    );
    test('pending quota includes sibling targets in the same entry', () async {
      install(
        options: CalendarInvitationResponseOptions(maxPendingPerRecipient: 1),
      );
      final source = await receive();
      await service.sendInvitationBundleOccurrenceResponse(
        await command(source, bundleResponsePoint(1)),
      );
      await expectLater(
        service.sendInvitationBundleOccurrenceResponse(
          await command(source, bundleResponsePoint(3)),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 1);
    });
    test(
      'retained response cap remains aggregate across entry targets',
      () async {
        install(
          options: CalendarInvitationResponseOptions(maxResponsesPerState: 1),
        );
        final source = await receive();
        await service.sendInvitationBundleOccurrenceResponse(
          await command(source, bundleResponsePoint(1)),
        );
        await CalendarModule.runInvitationResponseMaintenance(session);
        await expectLater(
          service.sendInvitationBundleOccurrenceResponse(
            await command(source, bundleResponsePoint(3)),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 1);
      },
    );
    test(
      'invalid member and exact profile errors cannot create target state',
      () async {
        final source = await receive();
        for (final point in [
          bundleResponsePoint(9),
          bundleResponsePoint(3, profile: 'date'),
        ]) {
          await expectLater(
            service.invitationBundleOccurrenceResponse(source.entryId, point),
            failure(CalendarFailureCode.validation),
          );
        }
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
      },
    );
    test('command identity cannot be reused for a different original or master family', () async {
      final source = await receive();
      final request = await command(source, bundleResponsePoint(1));
      await service.sendInvitationBundleOccurrenceResponse(request);
      await expectLater(
        service.sendInvitationBundleOccurrenceResponse(
          request.copyWith(originalStart: bundleResponsePoint(3)),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.sendInvitationBundleResponse(request.request),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarInvitationResponseRecord.db.count(session), 1);
    });
    test(
      'final target denial rolls back both target state and delivery',
      () async {
        final source = await receive();
        final request = await command(source, bundleResponsePoint(1));
        host.denyFinal = true;
        await expectLater(
          service.sendInvitationBundleOccurrenceResponse(request),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      },
    );
    for (final sequence in [null, 0]) {
      test('unlisted original preserves master SEQUENCE $sequence', () async {
        var text = utf8.decode(bundleBytes(sequence: sequence ?? 2));
        if (sequence == null) {
          text = text.replaceFirst('SEQUENCE:2\r\n', '');
        }
        final source = await receive(
          bytes: Uint8List.fromList(utf8.encode(text)),
        );
        final point = bundleResponsePoint(3);
        expect(
          (await service.invitationBundleOccurrenceResponse(
            source.entryId,
            point,
          )).componentVersion!.sequence,
          sequence,
        );
        await service.sendInvitationBundleOccurrenceResponse(
          await command(source, point),
        );
        expect(
          (await CalendarInvitationResponseRecord.db.find(session))
              .single
              .sourceSequence,
          sequence,
        );
      });
    }
    test('master-only permissions grant no implicit occurrence rights and are not occurrence prerequisites', () async {
      final source = await receive();
      final request = await command(source, bundleResponsePoint(1));
      host.denied.addAll([
        CalendarInvitationResponseOperation.readBundleMaster,
        CalendarInvitationResponseOperation.sendBundleMaster,
      ]);
      await service.sendInvitationBundleOccurrenceResponse(request);
      await expectLater(
        service.invitationBundleResponse(source.entryId),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await service.invitationBundleOccurrenceResponse(
          source.entryId,
          bundleResponsePoint(1),
        )).response.revision,
        1,
      );
    });
    test('same-target supersession preserves sibling queued intent and independent clocks', () async {
      final source = await receive();
      await service.sendInvitationBundleOccurrenceResponse(
        await command(source, bundleResponsePoint(1)),
      );
      await service.sendInvitationBundleOccurrenceResponse(
        await command(source, bundleResponsePoint(3)),
      );
      await advance(1);
      await service.sendInvitationBundleOccurrenceResponse(
        await command(
          source,
          bundleResponsePoint(1),
          choice: CalendarInvitationResponseChoice.declined,
        ),
      );
      final rows = await CalendarInvitationResponseRecord.db.find(session);
      expect(
        rows.where(
          (v) =>
              v.responseOriginalStart!.start.day == 1 &&
              v.state == CalendarInvitationResponseDeliveryState.withdrawn,
        ),
        hasLength(1),
      );
      expect(
        rows.singleWhere((v) => v.responseOriginalStart!.start.day == 3).state,
        CalendarInvitationResponseDeliveryState.queued,
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, hasLength(2));
      expect(
        (await service.invitationBundleOccurrenceResponse(
          source.entryId,
          bundleResponsePoint(1),
        )).response.revision,
        2,
      );
      expect(
        (await service.invitationBundleOccurrenceResponse(
          source.entryId,
          bundleResponsePoint(3),
        )).response.revision,
        1,
      );
    });
    test('one target with a clock floor ahead of actual time cannot fabricate a stamp or block a sibling', () async {
      final source = await receive();
      await service.sendInvitationBundleOccurrenceResponse(
        await command(source, bundleResponsePoint(1)),
      );
      final state = (await CalendarInvitationResponseStateRecord.db.find(
        session,
      )).single;
      state.lastStamp = state.lastStamp.add(const Duration(minutes: 1));
      await CalendarInvitationResponseStateRecord.db.updateRow(session, state);
      await expectLater(
        service.sendInvitationBundleOccurrenceResponse(
          await command(source, bundleResponsePoint(1)),
        ),
        failure(CalendarFailureCode.unavailable),
      );
      final sibling = await service.sendInvitationBundleOccurrenceResponse(
        await command(source, bundleResponsePoint(3)),
      );
      expect(sibling.stamp.isBefore(state.lastStamp), isTrue);
      expect(await CalendarInvitationResponseRecord.db.count(session), 2);
    });
    test('a child-only new packet withdraws every old target without rebasing its unchanged controller', () async {
      final source = await receive();
      await adopt(source);
      final first = await command(source, bundleResponsePoint(1)),
          second = await command(source, bundleResponsePoint(7));
      final receipt = await service.sendInvitationBundleOccurrenceResponse(
        first,
      );
      await service.sendInvitationBundleOccurrenceResponse(second);
      await receive(bytes: updatedBundle(child: 1), key: 'child-update');
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, isEmpty);
      expect(
        (await CalendarInvitationResponseRecord.db.find(session)).every(
          (r) => r.state == CalendarInvitationResponseDeliveryState.withdrawn,
        ),
        isTrue,
      );
      final view = await service.invitationBundleOccurrenceResponse(
        source.entryId,
        bundleResponsePoint(7),
      );
      expect(view.componentVersion!.sequence, 12);
      expect(view.response.appliesToCurrentSource, isFalse);
      expect(view.response.canSend, isTrue);
      expect(
        (await service.sendInvitationBundleOccurrenceResponse(first)).toJson(),
        receipt.toJson(),
      );
    });
    test('cancellation history retries and a new REQUEST remain separate from native reopening', () async {
      final source = await receive();
      await adopt(source);
      final request = await command(source, bundleResponsePoint(1));
      final receipt = await service.sendInvitationBundleOccurrenceResponse(
        request,
      );
      await receive(bytes: bundleCancellationBytes(), key: 'cancel');
      await service.applyInvitationBundleCancellation(
        apply(await service.invitationBundleApplication(source.entryId)),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      final cancelled = await service.invitationBundleOccurrenceResponse(
        source.entryId,
        bundleResponsePoint(1),
      );
      expect(cancelled.response.canSend, isFalse);
      expect(cancelled.componentVersion, isNull);
      expect(
        (await service.sendInvitationBundleOccurrenceResponse(request)).id,
        receipt.id,
      );
      final incoming = await receive(
        bytes: updatedBundle(master: 14),
        key: 'reopen-notice',
      );
      await advance(1);
      await service.sendInvitationBundleOccurrenceResponse(
        await command(incoming, bundleResponsePoint(1)),
      );
      expect(
        (await service.invitationBundleOccurrenceResponse(
          source.entryId,
          bundleResponsePoint(1),
        )).componentVersion!.sequence,
        14,
      );
      expect(
        (await CalendarEventDataRecord.db.find(session)).single.content.status,
        CalendarEventStatus.cancelled,
      );
    });
    test(
      'retained target state rejects a typed-original/key mismatch',
      () async {
        final source = await receive();
        await service.sendInvitationBundleOccurrenceResponse(
          await command(source, bundleResponsePoint(1)),
        );
        final state = (await CalendarInvitationResponseStateRecord.db.find(
          session,
        )).single;
        state.responseOriginalStart = bundleResponsePoint(3);
        await CalendarInvitationResponseStateRecord.db.updateRow(
          session,
          state,
        );
        await expectLater(
          service.invitationBundleOccurrenceResponse(
            source.entryId,
            bundleResponsePoint(1),
          ),
          failure(CalendarFailureCode.unavailable),
        );
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(transport.submissions, isEmpty);
      },
    );
    test('corrupt target command evidence fails unavailable without dispatching a sibling identity', () async {
      final source = await receive();
      final request = await command(source, bundleResponsePoint(1));
      await service.sendInvitationBundleOccurrenceResponse(request);
      final row = (await CalendarInvitationResponseRecord.db.find(session))
          .single;
      row.responseOriginalStart = bundleResponsePoint(3);
      await CalendarInvitationResponseRecord.db.updateRow(session, row);
      await expectLater(
        service.sendInvitationBundleOccurrenceResponse(request),
        failure(CalendarFailureCode.unavailable),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, isEmpty);
    });
    test(
      'raw source denial precedes target retry and activity lookup',
      () async {
        final source = await receive();
        final request = await command(source, bundleResponsePoint(1));
        await service.sendInvitationBundleOccurrenceResponse(request);
        invitations.denied.add(CalendarInvitationOperation.readSource);
        await expectLater(
          service.sendInvitationBundleOccurrenceResponse(request),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          service.invitationBundleOccurrenceResponseActivity(
            source.entryId,
            bundleResponsePoint(1),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test('nested command and receipt callback mutation cannot change a target intent', () async {
      final source = await receive();
      final request = await command(source, bundleResponsePoint(1));
      host.onCheck = (c, tx, phase) async {
        if (c.request != null) {
          c.request!.choice = CalendarInvitationResponseChoice.declined;
        }
        if (c.receipt != null) {
          c.receipt!.choice = CalendarInvitationResponseChoice.declined;
        }
        request.request.choice = CalendarInvitationResponseChoice.declined;
      };
      await service.sendInvitationBundleOccurrenceResponse(request);
      final row = (await CalendarInvitationResponseRecord.db.find(session))
          .single;
      expect(row.choice, CalendarInvitationResponseChoice.accepted);
      expect(row.receipt.choice, CalendarInvitationResponseChoice.accepted);
      expect(row.request.choice, CalendarInvitationResponseChoice.accepted);
      expect(row.responseOriginalStart!.start.day, 1);
    });
    test(
      'state limit counts every target together with master state',
      () async {
        install(
          options: CalendarInvitationResponseOptions(maxStatesPerRecipient: 2),
        );
        final source = await receive();
        for (final day in [1, 3]) {
          await service.sendInvitationBundleOccurrenceResponse(
            await command(source, bundleResponsePoint(day)),
          );
        }
        await expectLater(
          service.sendInvitationBundleOccurrenceResponse(
            await command(source, bundleResponsePoint(7)),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          2,
        );
      },
    );
    test('terminal pruning retains each active target revision then entry pruning scrubs them all', () async {
      install(
        options: CalendarInvitationResponseOptions(
          retention: const Duration(milliseconds: 1),
        ),
      );
      final source = await receive();
      final request = await command(source, bundleResponsePoint(1));
      await service.sendInvitationBundleOccurrenceResponse(request);
      await service.sendInvitationBundleOccurrenceResponse(
        await command(source, bundleResponsePoint(3)),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 2);
      expect(
        (await service.invitationBundleOccurrenceResponse(
          source.entryId,
          bundleResponsePoint(1),
        )).response.revision,
        1,
      );
      await expectLater(
        service.sendInvitationBundleOccurrenceResponse(request),
        failure(CalendarFailureCode.staleRevision),
      );
      await service.dismissInvitation(
        source.entryId,
        (await service.getInvitation(source.entryId)).revision,
      );
      final entry = (await CalendarInvitationRecord.db.findById(
        session,
        source.entryId,
      ))!;
      entry.dismissedAt = DateTime.utc(1970);
      await CalendarInvitationRecord.db.updateRow(session, entry);
      final body = (await CalendarInvitationSourceRecord.db.findById(
        session,
        source.sourceId,
      ))!;
      body.inactiveAt = DateTime.utc(1970);
      await CalendarInvitationSourceRecord.db.updateRow(session, body);
      await service.listInvitations();
      expect(
        await CalendarInvitationRecord.db.count(session),
        1,
        reason: 'Retained ingress receipts still pin the source and its target states',
      );
      for (final receipt in await CalendarInvitationReceiptRecord.db.find(
        session,
      )) {
        receipt.expiresAt = DateTime.utc(1970);
        await CalendarInvitationReceiptRecord.db.updateRow(session, receipt);
      }
      await service.listInvitations();
      expect(await CalendarInvitationRecord.db.count(session), 0);
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 0);
    });
  });
}
