import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart' show InvitationTestHost, invitationDelivery;
import 'invitation_bundles_test.dart' show bundleBytes;
import 'bundled_invitation_updates_test.dart' show updatedBundle;
import 'bundled_invitation_lifecycle_test.dart' show bundleCancellationBytes;
import 'invitation_responses_test.dart' show ResponseHost, ResponseTransport;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('explicit bundled master attendee responses', (
    builder,
    endpoints,
  ) {
    late Session session;
    late InvitationTestHost invitations;
    late ResponseHost host;
    late ResponseTransport transport;
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
      invitations = InvitationTestHost();
      host = ResponseHost();
      transport = ResponseTransport();
      CalendarModule.install(
        session.serverpod,
        policy: TestPolicy(),
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(
          host: invitations,
          responses: CalendarInvitationResponseRuntime(
            host: host,
            transport: transport,
          ),
        ),
      );
      service = CalendarModule.service(session);
    });
    Future<CalendarInvitationReceipt> receive(Uint8List bytes, String key) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(key: key, bytes: bytes),
        );
    CalendarInvitationResponseRequest command(
      CalendarInvitationReceipt source, {
      int revision = 0,
      CalendarInvitationResponseChoice choice =
          CalendarInvitationResponseChoice.accepted,
    }) => CalendarInvitationResponseRequest(
      invitationId: source.entryId,
      expectedInvitationRevision: source.entryRevision,
      sourceId: source.sourceId,
      expectedResponseRevision: revision,
      commandId: const Uuid().v4obj(),
      choice: choice,
    );
    CalendarInvitationApplyRequest applyCommand(
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
    Future<void> advance() async {
      final stamp = (await CalendarInvitationResponseStateRecord.db.find(
        session,
      )).single.lastStamp;
      for (var i = 0; i < 40; i++) {
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

    for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
      for (final sequence in [null, 0, 2]) {
        test(
          '$profile exact master sequence $sequence, one reply and no calendar effects',
          () async {
            var bytes = bundleBytes(
              date: profile == 'date',
              zone: profile == 'date' || profile == 'utc' ? null : profile,
              sequence: sequence ?? 2,
            );
            if (sequence == null) {
              bytes = Uint8List.fromList(
                utf8.encode(
                  utf8.decode(bytes).replaceFirst('SEQUENCE:2\r\n', ''),
                ),
              );
            }
            final source = await receive(bytes, 'initial');
            final view = await service.invitationBundleResponse(source.entryId);
            expect(view.canSend, isTrue);
            expect(view.revision, 0);
            final request = command(source);
            final result = await service.sendInvitationBundleResponse(request);
            expect(
              (await service.sendInvitationBundleResponse(request)).toJson(),
              result.toJson(),
            );
            final row = (await CalendarInvitationResponseRecord.db.find(
              session,
            )).single;
            final reply = parseIcalendarSchedulingMessage(
              utf8.encode(row.payload),
            );
            expect(reply.method, IcalendarSchedulingMethod.reply);
            expect(reply.events, hasLength(1));
            expect(reply.events.single.sequence, sequence);
            expect(reply.events.single.isOverride, isFalse);
            expect(reply.events.single.participants.attendees, hasLength(1));
            expect(
              reply.events.single.participants.attendees.single.address,
              'mailto:alice@example.invalid',
            );
            expect(row.payload, isNot(contains('RECURRENCE-ID')));
            expect(row.payload, isNot(contains('SUMMARY')));
            expect(await CalendarIdentityRecord.db.count(session), 0);
            expect(await CalendarEventRecord.db.count(session), 0);
            expect(await CalendarInvitationLinkRecord.db.count(session), 0);
            expect(await CalendarAlarmRecord.db.count(session), 0);
            expect(
              await CalendarSchedulingPublicationRecord.db.count(session),
              0,
            );
            await CalendarModule.runInvitationResponseMaintenance(session);
            expect(transport.submissions, hasLength(1));
            expect(
              (await service.invitationBundleResponse(source.entryId))
                  .deliveryState,
              CalendarInvitationResponseDeliveryState.accepted,
            );
            expect(
              host.contexts.any(
                (c) =>
                    c.operation ==
                        CalendarInvitationResponseOperation.sendBundleMaster &&
                    c.sourceMessage!.events.length == 3 &&
                    c.outgoingMessage!.events.length == 1,
              ),
              isTrue,
            );
            expect(
              host.contexts
                  .where(
                    (c) =>
                        c.operation ==
                        CalendarInvitationResponseOperation
                            .dispatchBundleMaster,
                  )
                  .every((c) => c.actor == null),
              isTrue,
            );
          },
        );
      }
    }
    test('child-only selected source withdraws pending reply with unchanged master version', () async {
      final source = await receive(updatedBundle(), 'initial');
      final calendar = (await service.create(createInput()))!;
      await service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: source.entryId,
          expectedRevision: 1,
          sourceId: source.sourceId,
          calendarId: calendar.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
      final current = await service.getInvitation(source.entryId);
      final request = command(source)
        ..expectedInvitationRevision = current.revision;
      final result = await service.sendInvitationBundleResponse(request);
      await receive(updatedBundle(child: 1), 'child');
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, isEmpty);
      expect(
        (await CalendarInvitationResponseRecord.db.find(session)).single.state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      final view = await service.invitationBundleResponse(source.entryId);
      expect(view.appliesToCurrentSource, isFalse);
      expect(view.choice, CalendarInvitationResponseChoice.accepted);
      expect(
        (await service.sendInvitationBundleResponse(request)).toJson(),
        result.toJson(),
      );
    });
    test(
      'decline, adoption and dismissal are independent of queued master intent',
      () async {
        final source = await receive(bundleBytes(), 'initial');
        await service.sendInvitationBundleResponse(
          command(source, choice: CalendarInvitationResponseChoice.declined),
        );
        final calendar = (await service.create(createInput()))!;
        await service.adoptInvitation(
          CalendarInvitationAdoptionRequest(
            invitationId: source.entryId,
            expectedRevision: 1,
            sourceId: source.sourceId,
            calendarId: calendar.calendarId,
            expectedCalendarRevision: 1,
          ),
        );
        final current = await service.getInvitation(source.entryId);
        await service.dismissInvitation(source.entryId, current.revision);
        final view = await service.invitationBundleResponse(source.entryId);
        expect(view.appliesToCurrentSource, isTrue);
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(transport.submissions, hasLength(1));
        expect(
          (await CalendarEventDataRecord.db.find(session))
              .single
              .content
              .status,
          CalendarEventStatus.confirmed,
        );
      },
    );
    test('whole cancellation withdraws work, history and exact retry remain private', () async {
      final source = await receive(bundleBytes(), 'initial');
      final calendar = (await service.create(createInput()))!;
      await service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: source.entryId,
          expectedRevision: 1,
          sourceId: source.sourceId,
          calendarId: calendar.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
      final entry = await service.getInvitation(source.entryId);
      final request = command(source)
        ..expectedInvitationRevision = entry.revision;
      final result = await service.sendInvitationBundleResponse(request);
      await receive(bundleCancellationBytes(), 'cancel');
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, isEmpty);
      final view = await service.invitationBundleResponse(source.entryId);
      expect(view.canSend, isFalse);
      expect(view.appliesToCurrentSource, isFalse);
      expect(
        await service.invitationBundleResponseActivity(source.entryId),
        hasLength(1),
      );
      expect(
        (await service.sendInvitationBundleResponse(request)).toJson(),
        result.toJson(),
      );
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
    });
    test(
      'applying the selected bundle does not withdraw a queued response',
      () async {
        final source = await receive(updatedBundle(), 'initial');
        final calendar = (await service.create(createInput()))!;
        await service.adoptInvitation(
          CalendarInvitationAdoptionRequest(
            invitationId: source.entryId,
            expectedRevision: 1,
            sourceId: source.sourceId,
            calendarId: calendar.calendarId,
            expectedCalendarRevision: 1,
          ),
        );
        final incoming = await receive(updatedBundle(child: 1), 'child');
        await service.sendInvitationBundleResponse(command(incoming));
        await service.applyInvitationBundleUpdate(
          applyCommand(
            await service.invitationBundleApplication(source.entryId),
          ),
        );
        expect(
          (await service.invitationBundleResponse(source.entryId))
              .appliesToCurrentSource,
          isTrue,
        );
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(transport.submissions, hasLength(1));
        expect(
          (await CalendarInvitationResponseRecord.db.find(session))
              .single
              .state,
          CalendarInvitationResponseDeliveryState.accepted,
        );
      },
    );
    test(
      'a new REQUEST can be answered before explicit native reopening',
      () async {
        final source = await receive(bundleBytes(), 'initial');
        final calendar = (await service.create(createInput()))!;
        await service.adoptInvitation(
          CalendarInvitationAdoptionRequest(
            invitationId: source.entryId,
            expectedRevision: 1,
            sourceId: source.sourceId,
            calendarId: calendar.calendarId,
            expectedCalendarRevision: 1,
          ),
        );
        await receive(bundleCancellationBytes(), 'cancel');
        await service.applyInvitationBundleCancellation(
          applyCommand(
            await service.invitationBundleApplication(source.entryId),
          ),
        );
        final incoming = await receive(
          updatedBundle(master: 14),
          'reopen-notice',
        );
        await service.sendInvitationBundleResponse(command(incoming));
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(transport.submissions, hasLength(1));
        expect(
          (await CalendarEventDataRecord.db.find(session))
              .single
              .content
              .status,
          CalendarEventStatus.cancelled,
        );
        expect(
          (await service.invitationBundleApplication(source.entryId)).canReopen,
          isTrue,
        );
      },
    );
    for (final denied in [
      CalendarInvitationResponseOperation.readBundleMaster,
      CalendarInvitationResponseOperation.sendBundleMaster,
    ]) {
      test(
        '$denied independently gates query/send without a stored intent',
        () async {
          final source = await receive(bundleBytes(), 'initial');
          host.denied.add(denied);
          await expectLater(
            service.sendInvitationBundleResponse(command(source)),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(await CalendarInvitationResponseRecord.db.count(session), 0);
        },
      );
    }
    test('bundle dispatch authority withdraws eligible work', () async {
      final source = await receive(bundleBytes(), 'initial');
      await service.sendInvitationBundleResponse(command(source));
      host.denied.add(CalendarInvitationResponseOperation.dispatchBundleMaster);
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, isEmpty);
      expect(
        (await CalendarInvitationResponseRecord.db.find(session)).single.state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
    });
    test(
      'legacy APIs reject bundle entry before reading response state or retry',
      () async {
        final source = await receive(bundleBytes(), 'initial');
        final request = command(source);
        await service.sendInvitationBundleResponse(request);
        await expectLater(
          service.invitationResponse(source.entryId),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(
          service.invitationResponseActivity(source.entryId),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(
          service.sendInvitationResponse(request),
          failure(CalendarFailureCode.validation),
        );
      },
    );
    test('digest family corruption cannot reinterpret a bundle command as ordinary', () async {
      final source = await receive(bundleBytes(), 'initial');
      final request = command(source);
      await service.sendInvitationBundleResponse(request);
      final row = (await CalendarInvitationResponseRecord.db.find(session))
          .single;
      final bytes = utf8.encode(jsonEncode(row.request.toJson()));
      row.criteriaDigest = sha256.convert([
        ...utf8.encode('${bytes.length}:'),
        ...bytes,
      ]).toString();
      await CalendarInvitationResponseRecord.db.updateRow(session, row);
      await expectLater(
        service.sendInvitationBundleResponse(request),
        failure(CalendarFailureCode.unavailable),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, isEmpty);
    });
    test(
      'actual database second and immutable callback command identity',
      () async {
        final source = await receive(bundleBytes(), 'initial');
        final request = command(source);
        host.onCheck = (c, tx, phase) async {
          if (c.request != null) {
            c.request!.choice = CalendarInvitationResponseChoice.declined;
          }
          if (c.receipt != null) {
            c.receipt!.choice = CalendarInvitationResponseChoice.declined;
          }
          request.choice = CalendarInvitationResponseChoice.declined;
        };
        await service.sendInvitationBundleResponse(request);
        final row = (await CalendarInvitationResponseRecord.db.find(session))
            .single;
        expect(row.choice, CalendarInvitationResponseChoice.accepted);
        expect(row.request.choice, CalendarInvitationResponseChoice.accepted);
        expect(row.receipt.choice, CalendarInvitationResponseChoice.accepted);
        host.onCheck = null;
        await advance();
        final next = command(
          source,
          revision: 1,
          choice: CalendarInvitationResponseChoice.tentative,
        );
        final result = await service.sendInvitationBundleResponse(next);
        expect(result.stamp.isAfter(row.stamp), isTrue);
      },
    );
    test(
      'complete child evidence is checked before any master projection',
      () async {
        final source = await receive(bundleBytes(), 'initial');
        final row = (await CalendarInvitationSourceRecord.db.findById(
          session,
          source.sourceId,
        ))!;
        row.normalizedSource = row.normalizedSource.replaceFirst(
          'RANGE=THISANDFUTURE',
          'RANGE=INVALID',
        );
        row.digest = sha256
            .convert(utf8.encode(row.normalizedSource))
            .toString();
        await CalendarInvitationSourceRecord.db.updateRow(session, row);
        await expectLater(
          service.sendInvitationBundleResponse(command(source)),
          failure(CalendarFailureCode.unavailable),
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      },
    );
    test('raw source permission gates retained bundle retries', () async {
      final source = await receive(bundleBytes(), 'initial');
      final request = command(source);
      await service.sendInvitationBundleResponse(request);
      invitations.denied.add(CalendarInvitationOperation.readSource);
      await expectLater(
        service.sendInvitationBundleResponse(request),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.invitationBundleResponseActivity(source.entryId),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarInvitationResponseRecord.db.count(session), 1);
    });
    test(
      'final denial rolls back personal state and immutable delivery together',
      () async {
        final source = await receive(bundleBytes(), 'initial');
        host.denyFinal = true;
        await expectLater(
          service.sendInvitationBundleResponse(command(source)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
      },
    );
  });
}
