import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'invitation_cancellation_test.dart' show cancellationBytes;
import 'test_tools/serverpod_test_tools.dart';
import 'scheduling_test.dart' show SchedulingHost, SchedulingTransport;
import 'scheduling_replies_test.dart' show ReplyHost;
import 'calendar_test.dart' show createInput, eventInput;

import 'package:calendar_example_server/src/invitation_response_mime.dart';
import 'package:calendar_example_server/src/imip_ingress.dart';

final class LoopbackInvitationHost implements CalendarInvitationHost {
  final recipient = const CalendarInvitationRecipient(
    scopeKey: 'test:alice',
    key: 'bob',
    calendarAddress: 'mailto:bob@example.invalid',
  );
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<CalendarInvitationRecipient> resolveCurrent(
    Session s,
    CalendarHostContext actor,
    Transaction tx,
  ) async => recipient;
  @override
  Future<CalendarInvitationRecipient> resolveDelivery(
    Session s,
    CalendarInvitationDelivery d,
    IcalendarSchedulingMessage m,
  ) async {
    if (d.originReference != 'verified-alice' ||
        m.events.single.participants.organizer!.address !=
            'mailto:alice@example.invalid') {
      throw StateError('Unverified loopback fixture');
    }
    return recipient;
  }

  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session s,
    CalendarInvitationPolicyContext c,
    Transaction tx,
    CalendarAuthorizationPhase p,
  ) async => c.recipient.same(recipient)
      ? CalendarAuthorizationVerdict.allow
      : CalendarAuthorizationVerdict.deny;
}

final class ResponseHost implements CalendarInvitationResponseHost {
  final denied = <CalendarInvitationResponseOperation>{};
  final contexts = <CalendarInvitationResponsePolicyContext>[];
  bool denyFinal = false,
      unavailable = false,
      badIdentity = false,
      badRoute = false;
  CalendarAuthorizationGuarantee capability =
      CalendarAuthorizationGuarantee.freshCheck;
  Future<void> Function(
    CalendarInvitationResponsePolicyContext,
    Transaction,
    CalendarAuthorizationPhase,
  )?
  onCheck;
  @override
  CalendarAuthorizationGuarantee get guarantee => capability;
  @override
  Future<CalendarInvitationResponseAuthority> resolve(
    Session s,
    CalendarInvitationResponsePolicyContext c,
    Transaction tx,
  ) async => CalendarInvitationResponseAuthority(
    attendeeAddress: badIdentity
        ? 'mailto:bob@example.invalid'
        : c.recipient.calendarAddress,
    authorityRef: 'verified-fixture-attendee',
    organizer: CalendarSchedulingRoute(
      badRoute ? 'mailto:other@example.invalid' : c.invitation.organizer,
      'verified-fixture-organizer',
    ),
  );
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session s,
    CalendarInvitationResponsePolicyContext c,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    contexts.add(c);
    await onCheck?.call(c, tx, phase);
    if (unavailable) return CalendarAuthorizationVerdict.unavailable;
    if (denied.contains(c.operation) ||
        denyFinal && phase == CalendarAuthorizationPhase.finalWrite) {
      return CalendarAuthorizationVerdict.deny;
    }
    if (c.operation == CalendarInvitationResponseOperation.dispatch &&
        c.actor != null) {
      throw StateError('Worker fabricated an actor');
    }
    return CalendarAuthorizationVerdict.allow;
  }
}

final class ResponseTransport implements CalendarInvitationResponseTransport {
  final submissions = <CalendarInvitationResponseSubmission>[];
  CalendarSchedulingTransportOutcome outcome =
      CalendarSchedulingTransportOutcome.accepted;
  Completer<void>? entered, release;
  @override
  Future<CalendarSchedulingTransportResult> submit(
    Session s,
    CalendarInvitationResponseSubmission input,
  ) async {
    submissions.add(input);
    if (entered != null && !entered!.isCompleted) entered!.complete();
    await release?.future;
    return CalendarSchedulingTransportResult(
      outcome,
      receipt: 'fixture:${input.deliveryKey}',
    );
  }
}

void main() {
  withServerpod('private explicit attendee responses', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late InvitationTestHost invitations;
    late ResponseHost host;
    late ResponseTransport transport;
    late CalendarService service;
    late CalendarInvitationReceipt incoming;
    void install({
      CalendarInvitationResponseOptions? options,
      CalendarInvitationOptions? invitationOptions,
    }) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
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

    Future<CalendarInvitationReceipt> receive({
      String key = 'first',
      List<int>? bytes,
    }) => CalendarModule.receiveSchedulingInvitation(
      session,
      invitationDelivery(
        key: key,
        bytes: bytes == null ? null : Uint8List.fromList(bytes),
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
      policy = TestPolicy();
      invitations = InvitationTestHost();
      host = ResponseHost();
      transport = ResponseTransport();
      install();
      incoming = await receive();
    });
    CalendarInvitationResponseRequest request({
      CalendarInvitationResponseChoice choice =
          CalendarInvitationResponseChoice.accepted,
      int revision = 0,
      int? invitationRevision,
      UuidValue? command,
      UuidValue? source,
    }) => CalendarInvitationResponseRequest(
      invitationId: incoming.entryId,
      expectedInvitationRevision: invitationRevision ?? incoming.entryRevision,
      sourceId: source ?? incoming.sourceId,
      expectedResponseRevision: revision,
      commandId: command ?? const Uuid().v4obj(),
      choice: choice,
    );
    Future<List<CalendarInvitationResponseRecord>> rows() =>
        CalendarInvitationResponseRecord.db.find(session);
    Future<CalendarInvitationResponseStateRecord> state() async =>
        (await CalendarInvitationResponseStateRecord.db.findFirstRow(session))!;
    Future<void> due() async {
      for (final row in await rows()) {
        if (row.terminalAt == null) {
          row.nextAttemptAt = DateTime.utc(2020);
          row.leaseUntil = null;
          await CalendarInvitationResponseRecord.db.updateRow(session, row);
        }
      }
    }

    Future<void> advance() async {
      final stamp = (await state()).lastStamp;
      for (var i = 0; i < 30; i++) {
        final time =
            (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                    .single
                    .single
                as DateTime;
        if (time.millisecondsSinceEpoch ~/ 1000 >
            stamp.millisecondsSinceEpoch ~/ 1000) {
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      throw StateError('Database clock did not advance');
    }

    Future<void> noCalendarEffects() async {
      expect(await CalendarIdentityRecord.db.count(session), 0);
      expect(await CalendarEventRecord.db.count(session), 0);
      expect(await CalendarInvitationLinkRecord.db.count(session), 0);
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
      expect(await CalendarAlarmRecord.db.count(session), 0);
      expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      expect((await CalendarScopeRecord.db.findFirstRow(session))!.revision, 1);
    }

    test(
      'missing personal state is revision zero, with no invented intent',
      () async {
        final view = await service.invitationResponse(incoming.entryId);
        expect(view.revision, 0);
        expect(view.choice, isNull);
        expect(view.appliesToCurrentSource, isFalse);
        expect(await rows(), isEmpty);
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
        expect(
          await service.invitationResponseActivity(incoming.entryId),
          isEmpty,
        );
      },
    );
    test('explicit decline queues minimal source-preserving reply without adopting or dismissing', () async {
      final entry = (await CalendarInvitationRecord.db.findById(
        session,
        incoming.entryId,
      ))!.toJson();
      final source = (await CalendarInvitationSourceRecord.db.findById(
        session,
        incoming.sourceId,
      ))!.toJson();
      final receipt = await service.sendInvitationResponse(
        request(choice: CalendarInvitationResponseChoice.declined),
      );
      final row = (await rows()).single,
          wire = parseIcalendarSchedulingMessage(utf8.encode(row.payload));
      expect(receipt.choice, CalendarInvitationResponseChoice.declined);
      expect(receipt.stamp.microsecond, 0);
      expect(receipt.stamp.millisecond, 0);
      expect(wire.method, IcalendarSchedulingMethod.reply);
      expect(wire.events.single.sequence, isNull);
      expect(wire.events.single.startTime, isNull);
      expect(wire.events.single.summary, isNull);
      expect(
        wire.events.single.participants.attendees.single.address,
        'mailto:alice@example.invalid',
      );
      expect(
        wire.events.single.participants.attendees.single.participationStatus,
        'DECLINED',
      );
      expect(row.payload, isNot(contains('PRIVATE CONTACT')));
      expect(row.payload, isNot(contains('SUMMARY')));
      expect(
        (await CalendarInvitationRecord.db.findById(
          session,
          incoming.entryId,
        ))!.toJson(),
        entry,
      );
      expect(
        (await CalendarInvitationSourceRecord.db.findById(
          session,
          incoming.sourceId,
        ))!.toJson(),
        source,
      );
      await noCalendarEffects();
      expect(transport.submissions, isEmpty);
    });
    test(
      'explicit zero sequence remains distinct from source omission',
      () async {
        incoming = await receive(
          key: 'zero',
          bytes: invitationBytes(uid: 'zero', sequence: 0),
        );
        await service.sendInvitationResponse(request());
        expect(
          parseIcalendarSchedulingMessage(
            utf8.encode((await rows()).single.payload),
          ).events.single.sequence,
          0,
        );
        expect((await rows()).single.payload, contains('SEQUENCE:0'));
      },
    );
    test(
      'retained exact command retries return unchanged receipts and no writes',
      () async {
        final body = request(),
            first = await service.sendInvitationResponse(body);
        final before = (await rows()).single.toJson(),
            beforeState = (await state()).toJson();
        final retry = await service.sendInvitationResponse(body);
        expect(retry.toJson(), first.toJson());
        expect((await rows()).single.toJson(), before);
        expect((await state()).toJson(), beforeState);
        expect(host.contexts.last.isRetry, isTrue);
        await expectLater(
          service.sendInvitationResponse(
            body.copyWith(choice: CalendarInvitationResponseChoice.declined),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(await rows(), hasLength(1));
      },
    );
    test('new command is deliberate resend, supersedes pending work and requires strict later second', () async {
      final first = await service.sendInvitationResponse(request());
      await advance();
      final second = await service.sendInvitationResponse(request(revision: 1));
      expect(second.id, isNot(first.id));
      expect(second.stamp.isAfter(first.stamp), isTrue);
      final history = await service.invitationResponseActivity(
        incoming.entryId,
      );
      expect(history.map((r) => r.id), [second.id, first.id]);
      expect(
        history.last.deliveryState,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      expect((await state()).revision, 2);
      await expectLater(
        service.sendInvitationResponse(request(revision: 1)),
        failure(CalendarFailureCode.staleRevision),
      );
    });
    test(
      'clock rollback/equal-or-earlier managed stamp rejects atomically',
      () async {
        await service.sendInvitationResponse(request());
        final stored = await state();
        stored.lastStamp = DateTime.utc(2099);
        await CalendarInvitationResponseStateRecord.db.updateRow(
          session,
          stored,
        );
        final before = (await rows()).single.toJson(),
            beforeState = (await state()).toJson();
        await expectLater(
          service.sendInvitationResponse(request(revision: 1)),
          failure(CalendarFailureCode.unavailable),
        );
        expect((await rows()).single.toJson(), before);
        expect((await state()).toJson(), beforeState);
      },
    );
    test('source selection and both revisions are authoritative', () async {
      final old = request();
      incoming = await receive(
        key: 'update',
        bytes: invitationBytes(sequence: 1),
      );
      await expectLater(
        service.sendInvitationResponse(old),
        failure(CalendarFailureCode.staleRevision),
      );
      await service.sendInvitationResponse(request());
      expect((await state()).sourceId, incoming.sourceId);
    });
    test('read/send/raw-source permissions are independent and final denial rolls back', () async {
      invitations.denied.add(CalendarInvitationOperation.readSource);
      await expectLater(
        service.sendInvitationResponse(request()),
        failure(CalendarFailureCode.accessDenied),
      );
      invitations.denied.clear();
      host.denied.add(CalendarInvitationResponseOperation.read);
      await expectLater(
        service.sendInvitationResponse(request()),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denied.clear();
      host.denied.add(CalendarInvitationResponseOperation.send);
      await expectLater(
        service.sendInvitationResponse(request()),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denied.clear();
      host.denyFinal = true;
      await expectLater(
        service.sendInvitationResponse(request()),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await rows(), isEmpty);
      expect(await CalendarInvitationResponseStateRecord.db.count(session), 0);
      await noCalendarEffects();
    });
    test('recipient and organizer authority must exactly match verified source claims', () async {
      host.badIdentity = true;
      await expectLater(
        service.sendInvitationResponse(request()),
        failure(CalendarFailureCode.accessDenied),
      );
      host.badIdentity = false;
      host.badRoute = true;
      await expectLater(
        service.sendInvitationResponse(request()),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await rows(), isEmpty);
    });
    test('retained retry after newer request/cancel is historical and never reactivates', () async {
      final body = request(),
          first = await service.sendInvitationResponse(body);
      await receive(key: 'cancel', bytes: cancellationBytes());
      await CalendarModule.runInvitationResponseMaintenance(session);
      final before = (await rows()).single.toJson(),
          beforeState = (await state()).toJson();
      expect(
        (await rows()).single.state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      expect(
        (await service.sendInvitationResponse(body)).toJson(),
        first.toJson(),
      );
      expect((await rows()).single.toJson(), before);
      expect((await state()).toJson(), beforeState);
      expect(transport.submissions, isEmpty);
    });
    test('cancellation is not a new response basis', () async {
      incoming = await receive(key: 'cancel', bytes: cancellationBytes());
      await expectLater(
        service.sendInvitationResponse(request()),
        failure(CalendarFailureCode.validation),
      );
      expect(await rows(), isEmpty);
    });
    test(
      'dismissal does not implicitly cancel an independently queued reply',
      () async {
        await service.sendInvitationResponse(request());
        await service.dismissInvitation(
          incoming.entryId,
          incoming.entryRevision,
        );
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(
          (await rows()).single.state,
          CalendarInvitationResponseDeliveryState.accepted,
        );
        expect(transport.submissions, hasLength(1));
      },
    );
    test('worker reauthorizes without an actor and records acceptance independently', () async {
      final receipt = await service.sendInvitationResponse(request());
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions.single.deliveryKey, receipt.id);
      expect(
        (await state()).outcome,
        CalendarInvitationResponseDeliveryState.accepted,
      );
      final calls = host.contexts.where(
        (c) => c.operation == CalendarInvitationResponseOperation.dispatch,
      );
      expect(calls.length, greaterThanOrEqualTo(2));
      expect(calls.every((c) => c.actor == null), isTrue);
      expect(
        await CalendarInvitationResponseAttemptRecord.db.count(session),
        1,
      );
      await noCalendarEffects();
    });
    test('policy revocation withdraws; unavailability retries boundedly without submission', () async {
      await service.sendInvitationResponse(request());
      host.unavailable = true;
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(
        (await rows()).single.state,
        CalendarInvitationResponseDeliveryState.retrying,
      );
      expect(transport.submissions, isEmpty);
      host.unavailable = false;
      host.denied.add(CalendarInvitationResponseOperation.dispatch);
      await due();
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(
        (await rows()).single.state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      expect(transport.submissions, isEmpty);
    });
    test(
      'transport uncertainty retries with the same immutable key/payload',
      () async {
        await service.sendInvitationResponse(request());
        transport.outcome = CalendarSchedulingTransportOutcome.uncertain;
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(
          (await rows()).single.state,
          CalendarInvitationResponseDeliveryState.retrying,
        );
        await due();
        transport.outcome = CalendarSchedulingTransportOutcome.accepted;
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(transport.submissions, hasLength(2));
        expect(
          transport.submissions.first.deliveryKey,
          transport.submissions.last.deliveryKey,
        );
        expect(
          transport.submissions.first.payload,
          transport.submissions.last.payload,
        );
        expect(
          (await rows()).single.state,
          CalendarInvitationResponseDeliveryState.accepted,
        );
      },
    );
    test('expired intent terminates before transport', () async {
      await service.sendInvitationResponse(request());
      final row = (await rows()).single;
      row.expiresAt = DateTime.utc(2020);
      await CalendarInvitationResponseRecord.db.updateRow(session, row);
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, isEmpty);
      expect(
        (await rows()).single.state,
        CalendarInvitationResponseDeliveryState.expired,
      );
    });
    test('synthetic minimal response traverses MIME and trusted organizer reconciliation', () async {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        scheduling: CalendarSchedulingRuntime(
          host: SchedulingHost(),
          transport: SchedulingTransport(),
          replies: CalendarSchedulingReplyRuntime(host: ReplyHost()),
        ),
        invitations: CalendarInvitationRuntime(
          host: LoopbackInvitationHost(),
          responses: CalendarInvitationResponseRuntime(
            host: host,
            transport: transport,
          ),
        ),
      );
      service = CalendarModule.service(session);
      final parent = (await service.create(createInput()))!.calendarId;
      final event = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Loopback source'),
        ),
      ))!;
      final published = await service.saveAndNotify(
        CalendarSchedulingSaveRequest(
          eventId: event.eventId,
          expectedRevision: 1,
          commandId: const Uuid().v4obj(),
          recipients: ['mailto:bob@example.invalid'],
          content: eventInput(summary: 'Loopback published'),
        ),
      );
      final publication = (await CalendarSchedulingPublicationRecord.db
          .findById(session, published.publicationId))!;
      final received = await CalendarModule.receiveSchedulingInvitation(
        session,
        CalendarInvitationDelivery(
          namespace: 'loopback',
          deliveryKey: 'request',
          originReference: 'verified-alice',
          bytes: Uint8List.fromList(utf8.encode(publication.payload)),
        ),
      );
      await service.sendInvitationResponse(
        CalendarInvitationResponseRequest(
          invitationId: received.entryId,
          expectedInvitationRevision: received.entryRevision,
          sourceId: received.sourceId,
          expectedResponseRevision: 0,
          commandId: const Uuid().v4obj(),
          choice: CalendarInvitationResponseChoice.accepted,
        ),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      final submission = transport.submissions.single;
      var raw = composeSyntheticInvitationResponseMime(
        submission,
        requireProtection: false,
      );
      Future<CalendarSchedulingReplyReceipt> reconcile(
        String key,
        String proof,
      ) => receiveHostImipReply(
        session,
        raw: utf8.encode(raw),
        outerProtection: ImipProtection.none,
        scopeKey: 'test:alice',
        eventId: event.eventId,
        namespace: 'loopback',
        deliveryKey: key,
        originReference: proof,
      );
      await expectLater(
        reconcile('forged', 'unverified'),
        failure(CalendarFailureCode.accessDenied),
      );
      final first = await reconcile('verified', 'verified-bob');
      expect(first.outcome, CalendarSchedulingReplyOutcome.applied);
      expect(
        (await service.schedulingResponses(event.eventId))
            .responses
            .single
            .effectiveParticipation,
        CalendarSchedulingParticipation.accepted,
      );
      expect(
        (await reconcile('verified', 'verified-bob')).receiptId,
        first.receiptId,
      );
      final current = (await CalendarEventRecord.db.findById(
        session,
        event.eventId,
      ))!;
      await service.saveAndNotify(
        CalendarSchedulingSaveRequest(
          eventId: event.eventId,
          expectedRevision: current.revision,
          commandId: const Uuid().v4obj(),
          content: eventInput(summary: 'Changed invitation'),
          recipients: ['mailto:bob@example.invalid'],
        ),
      );
      await advance();
      await service.sendInvitationResponse(
        CalendarInvitationResponseRequest(
          invitationId: received.entryId,
          expectedInvitationRevision: received.entryRevision,
          sourceId: received.sourceId,
          expectedResponseRevision: 1,
          commandId: const Uuid().v4obj(),
          choice: CalendarInvitationResponseChoice.declined,
        ),
      );
      await CalendarModule.runInvitationResponseMaintenance(session);
      raw = composeSyntheticInvitationResponseMime(
        transport.submissions.last,
        requireProtection: false,
      );
      expect(
        (await reconcile('older-source', 'verified-bob')).outcome,
        CalendarSchedulingReplyOutcome.stale,
      );
    });
    test('new source during submission withdraws work and records actual acceptance', () async {
      await service.sendInvitationResponse(request());
      transport.entered = Completer<void>();
      transport.release = Completer<void>();
      final worker = CalendarModule.runInvitationResponseMaintenance(session);
      await transport.entered!.future.timeout(const Duration(seconds: 10));
      await receive(key: 'newer', bytes: invitationBytes(sequence: 1));
      transport.release!.complete();
      await worker;
      expect(
        (await rows()).single.state,
        CalendarInvitationResponseDeliveryState.withdrawn,
      );
      expect((await rows()).single.resultCode, 'acceptedAfterSourceChange');
      expect(
        (await CalendarInvitationResponseAttemptRecord.db.find(session))
            .single
            .outcome,
        'accepted',
      );
      expect(
        (await service.invitationResponse(incoming.entryId))
            .appliesToCurrentSource,
        isFalse,
      );
    });
    test('lease takeover fences a late previous owner result', () async {
      await service.sendInvitationResponse(request());
      transport.entered = Completer<void>();
      final release = transport.release = Completer<void>();
      final oldWorker = CalendarModule.runInvitationResponseMaintenance(
        session,
      );
      await transport.entered!.future.timeout(const Duration(seconds: 10));
      await due();
      transport.release = null;
      await CalendarModule.runInvitationResponseMaintenance(session);
      final accepted = (await rows()).single.toJson();
      release.complete();
      await oldWorker;
      expect((await rows()).single.toJson(), accepted);
      expect((await rows()).single.attemptCount, 2);
      expect(
        transport.submissions.first.deliveryKey,
        transport.submissions.last.deliveryKey,
      );
      expect(
        transport.submissions.first.payload,
        transport.submissions.last.payload,
      );
      final attempts = await CalendarInvitationResponseAttemptRecord.db.find(
        session,
      );
      expect(attempts.map((a) => a.outcome).toSet(), {'uncertain', 'accepted'});
    });
    test('raw-source denial occurs before response nonce lookup', () async {
      final original = request();
      await service.sendInvitationResponse(original);
      invitations.denied.add(CalendarInvitationOperation.readSource);
      await expectLater(
        service.sendInvitationResponse(original),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.sendInvitationResponse(request()),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await rows(), hasLength(1));
    });
    test('attempt cap terminates without replay', () async {
      install(options: CalendarInvitationResponseOptions(maxAttempts: 1));
      await service.sendInvitationResponse(request());
      transport.outcome = CalendarSchedulingTransportOutcome.transientFailure;
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(
        (await rows()).single.state,
        CalendarInvitationResponseDeliveryState.failed,
      );
      await due();
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, hasLength(1));
    });
    test('corrupt immutable reply fails closed before transport', () async {
      await service.sendInvitationResponse(request());
      final row = (await rows()).single;
      row.payload = row.payload.replaceFirst('ACCEPTED', 'DECLINED');
      row.payloadDigest = sha256.convert(utf8.encode(row.payload)).toString();
      row.byteCount = utf8.encode(row.payload).length;
      await CalendarInvitationResponseRecord.db.updateRow(session, row);
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(transport.submissions, isEmpty);
      expect(
        (await rows()).single.state,
        CalendarInvitationResponseDeliveryState.retrying,
      );
    });
    test(
      'configured capacity rejects atomically without evicting retained work',
      () async {
        install(
          options: CalendarInvitationResponseOptions(maxResponsesPerState: 1),
        );
        await service.sendInvitationResponse(request());
        await advance();
        await expectLater(
          service.sendInvitationResponse(request(revision: 1)),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await rows(), hasLength(1));
        expect((await state()).revision, 1);
        expect(
          (await rows()).single.state,
          CalendarInvitationResponseDeliveryState.queued,
        );
      },
    );
    test(
      'retained response pins dismissed source until delivery history expires',
      () async {
        install(
          invitationOptions: CalendarInvitationOptions(
            terminalRetention: const Duration(milliseconds: 1),
          ),
        );
        await service.sendInvitationResponse(request());
        await service.dismissInvitation(
          incoming.entryId,
          incoming.entryRevision,
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await service.listInvitations();
        expect(
          await CalendarInvitationSourceRecord.db.findById(
            session,
            incoming.sourceId,
          ),
          isNotNull,
        );
        expect(
          await CalendarInvitationRecord.db.findById(session, incoming.entryId),
          isNotNull,
        );
        await CalendarModule.runInvitationResponseMaintenance(session);
        expect(
          (await rows()).single.state,
          CalendarInvitationResponseDeliveryState.accepted,
        );
      },
    );
    test('terminal history pruning preserves active personal state and retry fence', () async {
      install(
        options: CalendarInvitationResponseOptions(
          retention: const Duration(milliseconds: 1),
        ),
      );
      final old = request();
      await service.sendInvitationResponse(old);
      await CalendarModule.runInvitationResponseMaintenance(session);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await CalendarModule.runInvitationResponseMaintenance(session);
      expect(await rows(), isEmpty);
      expect(
        await CalendarInvitationResponseAttemptRecord.db.count(session),
        0,
      );
      final view = await service.invitationResponse(incoming.entryId);
      expect(view.revision, 1);
      expect(view.choice, CalendarInvitationResponseChoice.accepted);
      await expectLater(
        service.sendInvitationResponse(old),
        failure(CalendarFailureCode.staleRevision),
      );
    });
  });
}
