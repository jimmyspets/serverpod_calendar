import 'dart:convert';

import 'package:calendar_example_server/src/invitation_response_mime.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_cancellation_test.dart' show cancellationBytes;
import 'invitation_responses_test.dart' show ResponseTransport;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'test_tools/serverpod_test_tools.dart';

final class AttendeeRefreshTestHost implements CalendarAttendeeRefreshHost {
  bool denyFinal = false;
  bool denyWorker = false;
  String route = 'verified-organizer';

  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;

  @override
  Future<CalendarInvitationResponseAuthority> resolve(
    Session session,
    CalendarAttendeeRefreshContext context,
    Transaction tx,
  ) async => CalendarInvitationResponseAuthority(
    attendeeAddress: context.recipient.calendarAddress,
    authorityRef: 'verified-attendee',
    organizer: CalendarSchedulingRoute(context.invitation.organizer, route),
  );

  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarAttendeeRefreshContext context,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (context.operation == CalendarAttendeeRefreshOperation.dispatch) {
      expect(context.actor, isNull);
      expect(context.sourceMessage!.method, IcalendarSchedulingMethod.request);
      expect(
        context.outgoingMessage!.method,
        IcalendarSchedulingMethod.refresh,
      );
      if (denyWorker || context.authority!.organizer.routeRef != route) {
        return CalendarAuthorizationVerdict.deny;
      }
    }
    return denyFinal && phase == CalendarAuthorizationPhase.finalWrite
        ? CalendarAuthorizationVerdict.deny
        : CalendarAuthorizationVerdict.allow;
  }
}

void main() {
  withServerpod('explicit attendee event refresh', (builder, endpoints) {
    late Session session;
    late InvitationTestHost invitations;
    late AttendeeRefreshTestHost host;
    late ResponseTransport transport;
    late CalendarService service;
    late CalendarInvitationReceipt source;

    Future<CalendarInvitationReceipt> receive({
      String key = 'first',
      int? sequence,
    }) => CalendarModule.receiveSchedulingInvitation(
      session,
      invitationDelivery(
        key: key,
        bytes: invitationBytes(sequence: sequence),
      ),
    );

    setUp(() async {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      invitations = InvitationTestHost();
      host = AttendeeRefreshTestHost();
      transport = ResponseTransport();
      CalendarModule.install(
        session.serverpod,
        policy: TestPolicy(),
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(
          host: invitations,
          attendeeRefresh: CalendarAttendeeRefreshRuntime(
            host: host,
            transport: transport,
          ),
        ),
      );
      service = CalendarModule.service(session);
      source = await receive();
    });

    CalendarAttendeeRefreshCommand command({int? revision}) =>
        CalendarAttendeeRefreshCommand(
          invitationId: source.entryId,
          expectedInvitationRevision: revision ?? source.entryRevision,
          commandId: const Uuid().v4obj(),
        );

    Future<CalendarAttendeeRefreshRecord> row(UuidValue id) async =>
        (await CalendarAttendeeRefreshRecord.db.findById(session, id))!;

    Future<void> work() =>
        CalendarModule.runInvitationResponseMaintenance(session);

    test(
      'dismissed review sends a minimal REFRESH without changing participation',
      () async {
        await service.dismissInvitation(source.entryId, source.entryRevision);
        final entry = await service.getInvitation(source.entryId);
        expect((await service.attendeeRefresh(entry.id)).canRequest, isTrue);
        final input = command(revision: entry.revision);
        final queued = await service.requestAttendeeRefresh(input);
        expect(queued.state, CalendarInvitationResponseDeliveryState.queued);
        expect(queued.canRequest, isFalse);
        expect((await row(queued.deliveryId!)).sourceSequence, isNull);
        await work();
        final sent = transport.submissions.single;
        expect(sent.deliveryKey, queued.deliveryId);
        final parsed = parseIcalendarSchedulingMessage(
          utf8.encode(sent.payload),
        );
        expect(parsed.method, IcalendarSchedulingMethod.refresh);
        final event = parsed.events.single;
        expect(event.sequence, isNull);
        expect(
          event.participants.attendees.single.address,
          sent.attendeeAddress,
        );
        expect(event.participants.organizer!.address, sent.organizer.address);
        expect(event.stamp, (await row(sent.deliveryKey)).stamp);
        expect(
          composeSyntheticInvitationResponseMime(
            sent,
            requireProtection: false,
            refresh: true,
          ),
          contains('method=REFRESH'),
        );
        final retry = await service.requestAttendeeRefresh(input);
        expect(retry.deliveryId, sent.deliveryKey);
        expect(retry.unchanged, isTrue);
        expect(retry.state, CalendarInvitationResponseDeliveryState.accepted);
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
        expect(await CalendarInvitationLinkRecord.db.count(session), 0);
        expect(
          (await service.getInvitation(entry.id)).revision,
          entry.revision,
        );
      },
    );

    test(
      'final denial is atomic and exact source read authority is required',
      () async {
        host.denyFinal = true;
        final input = command();
        await expectLater(
          service.requestAttendeeRefresh(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarAttendeeRefreshRecord.db.count(session), 0);
        host.denyFinal = false;
        invitations.denied.add(CalendarInvitationOperation.readSource);
        await expectLater(
          service.requestAttendeeRefresh(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarAttendeeRefreshRecord.db.count(session), 0);
      },
    );

    test('new source withdraws old delivery and exact historical retries reauthorize', () async {
      final input = command();
      final queued = await service.requestAttendeeRefresh(input);
      await expectLater(
        service.requestAttendeeRefresh(command()),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final newer = await receive(key: 'newer', sequence: 1);
      await work();
      expect(transport.submissions, isEmpty);
      await expectLater(
        service.requestAttendeeRefresh(command()),
        failure(CalendarFailureCode.staleRevision),
      );
      final retry = await service.requestAttendeeRefresh(input);
      expect(retry.deliveryId, queued.deliveryId);
      expect(retry.state, CalendarInvitationResponseDeliveryState.withdrawn);
      host.route = 'new-route';
      await expectLater(
        service.requestAttendeeRefresh(input),
        failure(CalendarFailureCode.accessDenied),
      );
      final next = await service.requestAttendeeRefresh(
        command(revision: newer.entryRevision),
      );
      expect((await row(next.deliveryId!)).sourceSequence, 1);
      host.denyWorker = true;
      await work();
      expect(
        (await row(next.deliveryId!)).state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      expect(transport.submissions, isEmpty);
    });

    test(
      'adopted source queues a separate refresh and cancellation withdraws it',
      () async {
        final calendar = (await service.create(createInput()))!;
        final link = await service.adoptInvitation(
          CalendarInvitationAdoptionRequest(
            invitationId: source.entryId,
            sourceId: source.sourceId,
            expectedRevision: source.entryRevision,
            calendarId: calendar.calendarId,
            expectedCalendarRevision: calendar.revision,
          ),
        );
        final entry = await service.getInvitation(source.entryId);
        final queued = await service.requestAttendeeRefresh(
          command(revision: entry.revision),
        );
        final before = (await CalendarEventRecord.db.findById(
          session,
          link.eventId,
        ))!.toJson();
        final cancelled = await CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(key: 'cancel', bytes: cancellationBytes()),
        );
        await work();
        expect(transport.submissions, isEmpty);
        expect(
          (await row(queued.deliveryId!)).state,
          CalendarInvitationResponseDeliveryState.withdrawn,
        );
        expect(
          (await service.attendeeRefresh(source.entryId)).canRequest,
          isFalse,
        );
        await expectLater(
          service.requestAttendeeRefresh(
            command(revision: cancelled.entryRevision),
          ),
          failure(CalendarFailureCode.unavailable),
        );
        expect(
          (await CalendarEventRecord.db.findById(
            session,
            link.eventId,
          ))!.toJson(),
          before,
        );
      },
    );

    test(
      'retained attempts pin an inactive source until terminal pruning',
      () async {
        final queued = await service.requestAttendeeRefresh(command());
        await work();
        await receive(key: 'new', sequence: 1);
        final old = (await CalendarInvitationSourceRecord.db.findById(
          session,
          source.sourceId,
        ))!;
        old.inactiveAt = DateTime.utc(2000);
        await CalendarInvitationSourceRecord.db.updateRow(session, old);
        final receipt = (await CalendarInvitationReceiptRecord.db.findById(
          session,
          source.id,
        ))!;
        receipt.expiresAt = DateTime.utc(2000);
        await CalendarInvitationReceiptRecord.db.updateRow(session, receipt);
        await service.listInvitations();
        expect(
          await CalendarInvitationSourceRecord.db.findById(
            session,
            source.sourceId,
          ),
          isNotNull,
        );
        final retained = await row(queued.deliveryId!);
        retained.terminalAt = DateTime.utc(2000);
        await CalendarAttendeeRefreshRecord.db.updateRow(session, retained);
        await work();
        expect(await CalendarAttendeeRefreshAttemptRecord.db.count(session), 0);
        expect(await CalendarAttendeeRefreshRecord.db.count(session), 0);
        expect(
          await CalendarInvitationSourceRecord.db.findById(
            session,
            source.sourceId,
          ),
          isNull,
        );
      },
    );

    test(
      'recurring source remains outside the attendee refresh profile',
      () async {
        final recurring = await CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(
            key: 'recurring',
            bytes: invitationBytes(
              uid: 'recurring',
              extra: ['DURATION:PT1H', 'RRULE:FREQ=DAILY;COUNT=2'],
            ),
          ),
        );
        await expectLater(
          service.requestAttendeeRefresh(
            CalendarAttendeeRefreshCommand(
              invitationId: recurring.entryId,
              expectedInvitationRevision: recurring.entryRevision,
              commandId: const Uuid().v4obj(),
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarAttendeeRefreshRecord.db.count(session), 0);
      },
    );

    test(
      'uncertain transport retries the same bytes and delivery identity',
      () async {
        transport.outcome = CalendarSchedulingTransportOutcome.uncertain;
        final queued = await service.requestAttendeeRefresh(command());
        await work();
        final saved = await row(queued.deliveryId!);
        expect(saved.state, CalendarInvitationResponseDeliveryState.retrying);
        saved.nextAttemptAt = DateTime.utc(2000);
        await CalendarAttendeeRefreshRecord.db.updateRow(session, saved);
        transport.outcome = CalendarSchedulingTransportOutcome.accepted;
        await work();
        expect(transport.submissions, hasLength(2));
        expect(
          transport.submissions.last.deliveryKey,
          transport.submissions.first.deliveryKey,
        );
        expect(
          transport.submissions.last.payload,
          transport.submissions.first.payload,
        );
        expect(await CalendarAttendeeRefreshAttemptRecord.db.count(session), 2);
        expect(
          (await row(queued.deliveryId!)).state,
          CalendarInvitationResponseDeliveryState.accepted,
        );
      },
    );
  });
}
