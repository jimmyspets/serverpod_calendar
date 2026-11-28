import 'dart:convert';
import 'dart:typed_data';

import 'package:calendar_example_server/src/imip_ingress.dart';
import 'package:calendar_example_server/src/imip_mime_input.dart';
import 'package:calendar_example_server/src/synthetic_imip_input.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, eventInput, failure;
import 'invitation_test.dart' show InvitationTestHost, invitationBytes;
import 'invitation_cancellation_test.dart' show cancellationBytes;
import 'scheduling_test.dart' show SchedulingHost, SchedulingTransport;
import 'scheduling_replies_test.dart' show ReplyHost;
import 'test_tools/serverpod_test_tools.dart';

// Independent framing vector; native retry identity must ignore transport.
List<int> mime(
  List<int> bytes, {
  String method = 'REQUEST',
  bool seven = false,
  bool quoted = false,
  bool flat = false,
  List<String> headers = const [],
}) {
  final encoded = base64.encode(bytes);
  final qp = bytes
      .map((b) => '=${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
      .join();
  final body = quoted
      ? RegExp('.{1,75}').allMatches(qp).map((m) => m[0]!).join('=\r\n')
      : seven
      ? ascii.decode(bytes)
      : RegExp('.{1,76}').allMatches(encoded).map((m) => m[0]!).join('\r\n');
  final leaf = [
    'Content-Type: text/calendar; charset=UTF-8; method=$method',
    'Content-Transfer-Encoding: ${quoted
        ? 'quoted-printable'
        : seven
        ? '7bit'
        : 'base64'}',
    ...headers,
    '',
    body,
  ].join('\r\n');
  return ascii.encode(
    flat
        ? [
            'MIME-Version: 1.0',
            'Content-Type: multipart/alternative; boundary="fixture"',
            '',
            '--fixture',
            'Content-Type: text/html; charset=UTF-8',
            '',
            '<script>inert()</script>',
            '--fixture',
            leaf,
            '--fixture--',
            '',
          ].join('\r\n')
        : 'MIME-Version: 1.0\r\n$leaf',
  );
}

Matcher mimeFailure(HostImipMimeError kind) =>
    throwsA(isA<HostImipMimeException>().having((e) => e.kind, 'kind', kind));

void main() {
  withServerpod('host MIME to existing native ingress', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late InvitationTestHost invitations;
    late ReplyHost replies;
    late CalendarService service;
    late UuidValue eventId;
    late CalendarSchedulingPublicationRecord published;
    void install({
      CalendarInvitationOptions? invitationOptions,
      CalendarSchedulingReplyOptions? replyOptions,
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
        ),
        scheduling: CalendarSchedulingRuntime(
          host: SchedulingHost(),
          transport: SchedulingTransport(),
          replies: CalendarSchedulingReplyRuntime(
            host: replies,
            options: replyOptions,
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
      policy = TestPolicy();
      invitations = InvitationTestHost();
      replies = ReplyHost();
      install();
    });
    Future<CalendarInvitationReceipt> intake(
      List<int> raw, {
      String key = 'stable',
      String origin = 'trusted',
    }) => receiveHostImipInvitation(
      session,
      raw: raw,
      outerProtection: ImipProtection.none,
      namespace: 'mime-test',
      deliveryKey: key,
      originReference: origin,
    );
    Future<void> emptyInvitations() async {
      expect(await CalendarInvitationRecord.db.count(session), 0);
      expect(await CalendarInvitationSourceRecord.db.count(session), 0);
      expect(await CalendarInvitationReceiptRecord.db.count(session), 0);
    }

    Future<void> seedMeeting() async {
      final parent = (await service.create(createInput()))!.calendarId;
      eventId = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Draft'),
        ),
      ))!.eventId;
      final sent = await service.saveAndNotify(
        CalendarSchedulingSaveRequest(
          eventId: eventId,
          expectedRevision: 1,
          commandId: const Uuid().v4obj(),
          recipients: ['mailto:bob@example.invalid'],
          content: eventInput(summary: 'Published'),
        ),
      );
      published = (await CalendarSchedulingPublicationRecord.db.findById(
        session,
        sent.publicationId,
      ))!;
    }

    Uint8List replyBytes({
      int? sequence,
      bool omitSequence = false,
      String? participation = 'ACCEPTED',
      String? uid,
      String? comment,
    }) => Uint8List.fromList(
      utf8.encode(
        [
          'BEGIN:VCALENDAR',
          'VERSION:2.0',
          'PRODID:Independent',
          'METHOD:REPLY',
          'BEGIN:VEVENT',
          'UID:${uid ?? published.protocolUid}',
          'DTSTAMP:20261030T100000Z',
          if (!omitSequence) 'SEQUENCE:${sequence ?? published.sequence}',
          'ORGANIZER:mailto:alice@example.invalid',
          'ATTENDEE${participation == null ? '' : ';PARTSTAT=$participation'}:mailto:bob@example.invalid',
          if (comment != null) 'COMMENT:$comment',
          'END:VEVENT',
          'END:VCALENDAR',
          '',
        ].join('\r\n'),
      ),
    );
    Future<CalendarSchedulingReplyReceipt> respond(
      List<int> raw, {
      String key = 'stable',
      String origin = 'verified-bob',
      String scope = 'test:alice',
      UuidValue? target,
    }) => receiveHostImipReply(
      session,
      raw: raw,
      outerProtection: ImipProtection.none,
      scopeKey: scope,
      eventId: target ?? eventId,
      namespace: 'mime-test',
      deliveryKey: key,
      originReference: origin,
    );
    Future<void> emptyReplies() async {
      expect(await CalendarSchedulingReplySourceRecord.db.count(session), 0);
      expect(await CalendarSchedulingReplyReceiptRecord.db.count(session), 0);
      expect(
        await CalendarSchedulingAttendeeResponseRecord.db.count(session),
        0,
      );
    }

    test('invitation preserves exact immutable source and omissions, with no calendar mutation', () async {
      final bytes = invitationBytes(summary: 'Möte, synthetic');
      var checks = 0;
      invitations.onAuthorize = (context, tx, phase) async {
        if (context.delivery == null) return;
        checks++;
        expect(context.delivery!.bytes, bytes);
        expect(context.delivery!.namespace, 'mime-test');
        expect(context.delivery!.deliveryKey, 'stable');
        expect(context.message!.events.single.sequence, isNull);
        expect(() => context.delivery!.bytes[0] = 0, throwsUnsupportedError);
        expect(session.authenticated!.userIdentifier, 'alice');
      };
      final received = await intake(
        composeSyntheticIngressMime(
          bytes,
          method: IcalendarSchedulingMethod.request,
        ),
      );
      expect(checks, greaterThanOrEqualTo(2));
      expect(
        (await service.getInvitation(received.entryId)).summary,
        'Möte, synthetic',
      );
      expect(await CalendarEventRecord.db.count(session), 0);
      expect(await CalendarAlarmRecord.db.count(session), 0);
      expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
    });
    test('invitation stable retry ignores transfer/container and Message-ID changes', () async {
      final bytes = invitationBytes();
      final first = await intake(
        mime(bytes, headers: ['Message-ID: <first@example.invalid>']),
      );
      for (final raw in [
        mime(
          bytes,
          seven: true,
          headers: ['Message-ID: <other@example.invalid>'],
        ),
        mime(bytes, flat: true),
        mime(bytes, quoted: true),
      ]) {
        final retried = await intake(raw);
        expect(retried.toJson(), first.toJson());
      }
      expect(await CalendarInvitationSourceRecord.db.count(session), 1);
      expect(await CalendarInvitationReceiptRecord.db.count(session), 1);
    });
    test(
      'invitation same delivery key cannot replace different calendar content',
      () async {
        final first = await intake(mime(invitationBytes()));
        await expectLater(
          intake(mime(invitationBytes(summary: 'Conflicting content'))),
          failure(CalendarFailureCode.validation),
        );
        expect((await service.getInvitation(first.entryId)).summary, 'Review');
        expect(await CalendarInvitationSourceRecord.db.count(session), 1);
        expect(await CalendarInvitationReceiptRecord.db.count(session), 1);
      },
    );
    test('same fixed synthetic Message-ID does not deduplicate different host keys', () async {
      final raw = composeSyntheticIngressMime(
        invitationBytes(),
        method: IcalendarSchedulingMethod.request,
      );
      final first = await intake(raw);
      final second = await intake(raw, key: 'another');
      expect(second.sourceId, first.sourceId);
      expect(second.id, isNot(first.id));
      expect(second.outcome, CalendarInvitationOutcome.duplicate);
    });
    test(
      'forged headers cannot replace origin proof or determine recipient',
      () async {
        final raw = mime(
          invitationBytes(),
          headers: [
            'From: organizer@example.invalid',
            'To: bob@example.invalid',
            'Subject: trusted',
          ],
        );
        await expectLater(
          intake(raw, origin: 'unverified'),
          failure(CalendarFailureCode.accessDenied),
        );
        await emptyInvitations();
        final received = await intake(raw);
        final entry = (await CalendarInvitationRecord.db.findById(
          session,
          received.entryId,
        ))!;
        expect(entry.recipientKey, 'alice');
        expect(entry.scopeKey, 'test:alice');
      },
    );
    test(
      'invitation final host denial rolls back source, receipt and review',
      () async {
        invitations.denyFinal = true;
        await expectLater(
          intake(mime(invitationBytes())),
          failure(CalendarFailureCode.accessDenied),
        );
        await emptyInvitations();
      },
    );
    test('lower native invitation byte cap is retained', () async {
      install(
        invitationOptions: CalendarInvitationOptions(maxSourceBytes: 1024),
      );
      await expectLater(
        intake(mime(invitationBytes(summary: 'x' * 1500))),
        failure(CalendarFailureCode.limitExceeded),
      );
      await emptyInvitations();
    });
    test(
      'native non-recurring invitation restriction is not bypassed',
      () async {
        final bytes = invitationBytes(extra: ['RRULE:FREQ=DAILY;COUNT=2']);
        expect(
          parseHostImipMime(
            mime(bytes),
            outerProtection: ImipProtection.none,
          ).eventMessage!.events.single.recurrence,
          isNotNull,
        );
        await expectLater(
          intake(mime(bytes)),
          failure(CalendarFailureCode.validation),
        );
        await emptyInvitations();
      },
    );
    test(
      'raw cancellation only changes private review and retains missing timing',
      () async {
        final first = await intake(mime(invitationBytes()));
        final bytes = cancellationBytes();
        invitations.onAuthorize = (context, tx, phase) async {
          if (context.delivery == null) return;
          expect(context.message!.events.single.startTime, isNull);
          expect(context.delivery!.bytes, bytes);
        };
        final cancelled = await intake(
          mime(bytes, method: 'CANCEL'),
          key: 'cancel',
        );
        expect(cancelled.entryId, first.entryId);
        expect(
          (await service.getInvitation(first.entryId)).kind,
          CalendarInvitationSourceKind.meetingCancellation,
        );
        expect(await CalendarEventRecord.db.count(session), 0);
      },
    );
    test('native invitation version ordering survives MIME bridge', () async {
      await intake(mime(invitationBytes(sequence: 2)));
      final stale = await intake(
        mime(invitationBytes(sequence: 1)),
        key: 'stale',
      );
      expect(stale.outcome, CalendarInvitationOutcome.stale);
    });
    test(
      'host supplied target scope isolates the same invitation correlation',
      () async {
        final first = await intake(mime(invitationBytes()));
        invitations.target = const CalendarInvitationRecipient(
          scopeKey: 'test:bob',
          key: 'bob',
          calendarAddress: 'mailto:bob@example.invalid',
        );
        final second = await intake(mime(invitationBytes()));
        expect(second.entryId, isNot(first.entryId));
        await expectLater(
          service.getInvitation(second.entryId),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test(
      'malformed MIME fails before native host checks or private storage',
      () async {
        var checks = 0;
        invitations.onAuthorize = (c, t, p) async {
          checks++;
        };
        final raw = ascii.encode(
          'MIME-Version: 1.0\r\nContent-Type: text/calendar; method=REQUEST\r\nContent-Type: text/calendar\r\n\r\nPrivate',
        );
        await expectLater(intake(raw), mimeFailure(HostImipMimeError.profile));
        expect(checks, 0);
        await emptyInvitations();
      },
    );
    test('reply forwards exact source/version omissions and no invented participation', () async {
      await seedMeeting();
      final bytes = replyBytes(omitSequence: true, participation: null);
      await respond(
        composeSyntheticIngressMime(
          bytes,
          method: IcalendarSchedulingMethod.reply,
        ),
      );
      expect(replies.contexts, isNotEmpty);
      for (final context in replies.contexts) {
        expect(context.delivery.bytes, bytes);
        expect(context.message.events.single.sequence, isNull);
        expect(
          context
              .message
              .events
              .single
              .participants
              .attendees
              .single
              .participationStatus,
          isNull,
        );
        expect(context.delivery.eventId, eventId);
        expect(context.delivery.originReference, 'verified-bob');
      }
    });
    test('reply retry ignores MIME transfer/container while native event stays intact', () async {
      await seedMeeting();
      final bytes = replyBytes();
      final before = (await CalendarEventDataRecord.db.findFirstRow(session))!
          .toJson();
      final first = await respond(mime(bytes, method: 'REPLY'));
      final retry = await respond(mime(bytes, method: 'REPLY', seven: true));
      final flat = await respond(mime(bytes, method: 'REPLY', flat: true));
      final qp = await respond(mime(bytes, method: 'REPLY', quoted: true));
      expect(qp.receiptId, first.receiptId);
      expect(first.outcome, CalendarSchedulingReplyOutcome.applied);
      expect(retry.receiptId, first.receiptId);
      expect(flat.receiptId, first.receiptId);
      expect(retry.unchanged, isTrue);
      expect(flat.unchanged, isTrue);
      expect(
        (await CalendarEventDataRecord.db.findFirstRow(session))!.toJson(),
        before,
      );
      expect(await CalendarSchedulingReplySourceRecord.db.count(session), 1);
    });
    test('reply trusted origin and final approval cannot be forged with mail headers', () async {
      await seedMeeting();
      final raw = mime(
        replyBytes(),
        method: 'REPLY',
        headers: ['From: bob@example.invalid', 'To: alice@example.invalid'],
      );
      await expectLater(
        respond(raw, origin: 'unverified'),
        failure(CalendarFailureCode.accessDenied),
      );
      await emptyReplies();
      replies.denyFinal = true;
      await expectLater(
        respond(raw),
        failure(CalendarFailureCode.accessDenied),
      );
      await emptyReplies();
    });
    test('reply source UID must match the explicit stored target', () async {
      await seedMeeting();
      await expectLater(
        respond(mime(replyBytes(uid: 'foreign'), method: 'REPLY')),
        failure(CalendarFailureCode.validation),
      );
      await emptyReplies();
      await expectLater(
        respond(mime(replyBytes(), method: 'REPLY'), scope: 'other:scope'),
        failure(CalendarFailureCode.accessDenied),
      );
      await emptyReplies();
    });
    test('lower native reply byte cap remains enforced', () async {
      await seedMeeting();
      install(
        replyOptions: CalendarSchedulingReplyOptions(maxSourceBytes: 1024),
      );
      await expectLater(
        respond(mime(replyBytes(comment: 'x' * 1500), method: 'REPLY')),
        failure(CalendarFailureCode.limitExceeded),
      );
      await emptyReplies();
    });
    test('method mismatch and conflicting native reply key leave current response intact', () async {
      await seedMeeting();
      final bytes = replyBytes();
      await expectLater(
        respond(mime(bytes, method: 'REQUEST')),
        mimeFailure(HostImipMimeError.calendar),
      );
      await emptyReplies();
      final first = await respond(mime(bytes, method: 'REPLY'));
      await expectLater(
        respond(mime(replyBytes(participation: 'DECLINED'), method: 'REPLY')),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarSchedulingReplyReceiptRecord.db.count(session), 1);
      expect(
        (await service.schedulingResponses(eventId))
            .responses
            .single
            .effectiveParticipation,
        CalendarSchedulingParticipation.accepted,
      );
      final retry = await respond(mime(bytes, method: 'REPLY', flat: true));
      expect(retry.receiptId, first.receiptId);
    });
  });
}
