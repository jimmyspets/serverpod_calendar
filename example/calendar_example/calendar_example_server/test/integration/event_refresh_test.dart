import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'attendee_event_refresh_test.dart' show AttendeeRefreshTestHost;
import 'calendar_test.dart' show TestPolicy, createInput, eventInput, failure;
import 'invitation_responses_test.dart'
    show LoopbackInvitationHost, ResponseTransport;
import 'scheduling_test.dart' show SchedulingHost, SchedulingTransport;
import 'test_tools/serverpod_test_tools.dart';

final class _RefreshHost implements CalendarRefreshHost {
  bool denyFinalReceipt = false;
  bool denyWorker = false;

  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;

  @override
  Future<CalendarAuthorizationVerdict> authorizeReceipt(
    Session session,
    CalendarRefreshDelivery delivery,
    CalendarEventPolicySnapshot event,
    String attendeeAddress,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async =>
      delivery.originReference == 'verified:$attendeeAddress' &&
          !(denyFinalReceipt && phase == CalendarAuthorizationPhase.finalWrite)
      ? CalendarAuthorizationVerdict.allow
      : CalendarAuthorizationVerdict.deny;

  @override
  Future<CalendarAuthorizationVerdict> authorizeResend(
    Session session,
    CalendarSchedulingPolicyContext context,
    String originReference,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async =>
      context.recipient != null &&
          originReference == 'verified:${context.recipient!.address}' &&
          !(denyWorker && context.actor == null)
      ? CalendarAuthorizationVerdict.allow
      : CalendarAuthorizationVerdict.deny;
}

void main() {
  withServerpod('authenticated event refresh', (builder, endpoints) {
    const recipient = 'mailto:bob@example.invalid';
    late Session session;
    late CalendarService service;
    late _RefreshHost host;
    late SchedulingTransport transport;
    late UuidValue eventId;
    late CalendarSchedulingPublicationRecord publication;
    late CalendarEventContent content;
    late ResponseTransport attendeeTransport;

    setUp(() async {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      host = _RefreshHost();
      transport = SchedulingTransport();
      attendeeTransport = ResponseTransport();
      CalendarModule.install(
        session.serverpod,
        policy: TestPolicy()..scopeOverride = 'test:alice',
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        scheduling: CalendarSchedulingRuntime(
          host: SchedulingHost(),
          transport: transport,
          refresh: host,
        ),
        invitations: CalendarInvitationRuntime(
          host: LoopbackInvitationHost(),
          attendeeRefresh: CalendarAttendeeRefreshRuntime(
            host: AttendeeRefreshTestHost(),
            transport: attendeeTransport,
          ),
        ),
      );
      service = CalendarModule.service(session);
      final calendar = (await service.create(createInput()))!.calendarId;
      content = eventInput(summary: 'Published content');
      eventId = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: calendar, content: content),
      ))!.eventId;
      final receipt = await service.saveAndNotify(
        CalendarSchedulingSaveRequest(
          eventId: eventId,
          expectedRevision: 1,
          commandId: const Uuid().v4obj(),
          content: content,
          recipients: [recipient, 'mailto:carol@example.invalid'],
        ),
      );
      publication = (await CalendarSchedulingPublicationRecord.db.findById(
        session,
        receipt.publicationId,
      ))!;
    });

    CalendarRefreshDelivery input(
      String key, {
      String? origin,
      String comment = 'Latest copy please',
    }) => CalendarRefreshDelivery(
      scopeKey: 'test:alice',
      eventId: eventId,
      namespace: 'synthetic',
      deliveryKey: key,
      originReference: origin ?? 'verified:$recipient',
      bytes: Uint8List.fromList(
        utf8.encode(
          [
            'BEGIN:VCALENDAR',
            'VERSION:2.0',
            'PRODID:-//Synthetic refresh//EN',
            'METHOD:REFRESH',
            'BEGIN:VEVENT',
            'UID:${publication.protocolUid}',
            'DTSTAMP:20261128T100000Z',
            'ORGANIZER:mailto:alice@example.invalid',
            'ATTENDEE:$recipient',
            'COMMENT:$comment',
            'END:VEVENT',
            'END:VCALENDAR',
            '',
          ].join('\r\n'),
        ),
      ),
    );

    CalendarRefreshResendCommand command(UuidValue requestId) =>
        CalendarRefreshResendCommand(
          eventId: eventId,
          requestId: requestId,
          commandId: const Uuid().v4obj(),
          publicationId: publication.id!,
          generation: publication.generation,
        );

    test('attendee origin, verified organizer resend and normal receipt form a round trip', () async {
      final attendee = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'bob',
              {},
            ),
          )
          .build();
      final attendeeService = CalendarModule.service(attendee);
      Future<CalendarInvitationReceipt> receive(
        String deliveryKey,
        String payload,
      ) => CalendarModule.receiveSchedulingInvitation(
        attendee,
        CalendarInvitationDelivery(
          namespace: 'synthetic-loopback',
          deliveryKey: deliveryKey,
          originReference: 'verified-alice',
          bytes: Uint8List.fromList(utf8.encode(payload)),
        ),
      );
      await CalendarModule.runSchedulingMaintenance(session);
      final initial = transport.submissions.singleWhere(
        (row) => row.recipient.address == recipient,
      );
      final invitation = await receive('published', initial.payload);
      final queued = await attendeeService.requestAttendeeRefresh(
        CalendarAttendeeRefreshCommand(
          invitationId: invitation.entryId,
          expectedInvitationRevision: invitation.entryRevision,
          commandId: const Uuid().v4obj(),
        ),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      final refresh = attendeeTransport.submissions.single;
      expect(refresh.deliveryKey, queued.deliveryId);
      final refreshId = await CalendarModule.receiveEventRefresh(
        session,
        CalendarRefreshDelivery(
          scopeKey: 'test:alice',
          eventId: eventId,
          namespace: 'synthetic-loopback',
          deliveryKey: refresh.deliveryKey.toString(),
          originReference: 'verified:$recipient',
          bytes: Uint8List.fromList(utf8.encode(refresh.payload)),
        ),
      );
      expect(transport.submissions, hasLength(2));
      final resend = await service.resendEventRefresh(command(refreshId));
      await CalendarModule.runSchedulingMaintenance(session);
      final returned = transport.submissions.last;
      expect(returned.deliveryKey, resend.resendId);
      expect(returned.payload, initial.payload);
      final reviewed = await receive('returned', returned.payload);
      expect(reviewed.entryId, invitation.entryId);
      expect(reviewed.sourceId, invitation.sourceId);
      expect(await CalendarInvitationLinkRecord.db.count(session), 0);
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 0);
    });

    test('intake is idempotent and explicit resend preserves bytes, recipients and generation', () async {
      final delivery = input('one');
      final id = await CalendarModule.receiveEventRefresh(session, delivery);
      expect(await CalendarModule.receiveEventRefresh(session, delivery), id);
      expect(transport.submissions, isEmpty);
      final resend = command(id);
      await expectLater(
        service.resendEventRefresh(resend),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions, hasLength(2));
      final page = await service.listEventRefresh(eventId, 1, null);
      expect(page.entries.single.comments, ['Latest copy please']);
      expect(page.publicationId, publication.id);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: eventId,
          expectedRevision: publication.eventRevision,
          content: content.copyWith(summary: 'Private draft'),
        ),
      );
      final receipt = await service.resendEventRefresh(resend);
      expect(receipt.unchanged, isFalse);
      final retry = await service.resendEventRefresh(resend);
      expect(retry.resendId, receipt.resendId);
      expect(retry.unchanged, isTrue);
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions, hasLength(3));
      final sent = transport.submissions.last;
      expect(sent.recipient.address, recipient);
      expect(sent.payload, publication.payload);
      expect(sent.deliveryKey, receipt.resendId);
      expect(sent.publicationId, publication.id);
      final after = await service.listEventRefresh(eventId, 1, null);
      expect(after.generation, publication.generation);
      expect(
        after.entries.single.resendState,
        CalendarSchedulingDeliveryState.accepted,
      );
    });

    test(
      'origin and final denial roll back, and dismissal invalidates the cursor',
      () async {
        await expectLater(
          CalendarModule.receiveEventRefresh(
            session,
            input('denied', origin: 'unknown'),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denyFinalReceipt = true;
        await expectLater(
          CalendarModule.receiveEventRefresh(session, input('final-denial')),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarRefreshRequestRecord.db.count(session), 0);
        host.denyFinalReceipt = false;
        await CalendarModule.receiveEventRefresh(session, input('one'));
        await CalendarModule.receiveEventRefresh(session, input('two'));
        final page = await service.listEventRefresh(eventId, 1, null);
        expect(
          (await service.listEventRefresh(eventId, 1, page.nextCursor)).entries,
          hasLength(1),
        );
        await service.dismissEventRefresh(
          eventId,
          page.entries.single.requestId,
        );
        await expectLater(
          service.listEventRefresh(eventId, 1, page.nextCursor),
          failure(CalendarFailureCode.invalidCursor),
        );
        await expectLater(
          CalendarModule.receiveEventRefresh(
            session,
            input('one', comment: 'Changed'),
          ),
          failure(CalendarFailureCode.validation),
        );
      },
    );

    test('publication changes fence queued work and retained receipts pin the source', () async {
      await CalendarModule.runSchedulingMaintenance(session);
      final id = await CalendarModule.receiveEventRefresh(
        session,
        input('one'),
      );
      final request = command(id);
      final receipt = await service.resendEventRefresh(request);
      await service.saveAndNotify(
        CalendarSchedulingSaveRequest(
          eventId: eventId,
          expectedRevision: publication.eventRevision,
          commandId: const Uuid().v4obj(),
          content: content.copyWith(summary: 'New published content'),
          recipients: publication.recipients,
        ),
      );
      final old = (await CalendarSchedulingPublicationRecord.db.findById(
        session,
        publication.id!,
      ))!;
      old.completedAt = DateTime.utc(2000);
      await CalendarSchedulingPublicationRecord.db.updateRow(session, old);
      await CalendarModule.runSchedulingMaintenance(session);
      final resend = (await CalendarRefreshResendRecord.db.findById(
        session,
        receipt.resendId,
      ))!;
      expect(resend.state, CalendarSchedulingDeliveryState.superseded);
      expect(
        transport.submissions.map((row) => row.deliveryKey),
        isNot(contains(resend.id)),
      );
      expect(
        await CalendarSchedulingPublicationRecord.db.findById(
          session,
          publication.id!,
        ),
        isNotNull,
      );
      final retry = await service.resendEventRefresh(request);
      expect(retry.resendId, receipt.resendId);
      expect(retry.unchanged, isTrue);
      resend.terminalAt = DateTime.utc(2000);
      await CalendarRefreshResendRecord.db.updateRow(session, resend);
      await CalendarModule.runSchedulingMaintenance(session);
      expect(
        await CalendarRefreshResendRecord.db.findById(
          session,
          receipt.resendId,
        ),
        isNull,
      );
      expect(
        await CalendarSchedulingPublicationRecord.db.findById(
          session,
          publication.id!,
        ),
        isNull,
      );
    });

    test('actor-free denial blocks a queued resend and preserves the original deliveries', () async {
      await CalendarModule.runSchedulingMaintenance(session);
      final id = await CalendarModule.receiveEventRefresh(
        session,
        input('one'),
      );
      final receipt = await service.resendEventRefresh(command(id));
      host.denyWorker = true;
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions, hasLength(2));
      final row = await CalendarRefreshResendRecord.db.findById(
        session,
        receipt.resendId,
      );
      expect(row!.state, CalendarSchedulingDeliveryState.blocked);
      expect(
        (await service.schedulingStatus(eventId)).deliveries
            .map((row) => row.state),
        everyElement(CalendarSchedulingDeliveryState.accepted),
      );
    });
  });
}
