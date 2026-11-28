import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, eventInput, failure;
import 'scheduling_test.dart' show SchedulingHost, SchedulingTransport;
import 'test_tools/serverpod_test_tools.dart';

final class ReplyHost implements CalendarSchedulingReplyHost {
  bool denied = false, denyFinal = false;
  final contexts = <CalendarSchedulingReplyPolicyContext>[];
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<CalendarAuthorizationVerdict> authorizeReply(
    Session session,
    CalendarSchedulingReplyPolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    contexts.add(context);
    return denied ||
            context.delivery.originReference != 'verified-bob' ||
            denyFinal && phase == CalendarAuthorizationPhase.finalWrite
        ? CalendarAuthorizationVerdict.deny
        : CalendarAuthorizationVerdict.allow;
  }
}

void main() {
  withServerpod('authenticated attendee replies', (builder, endpoints) {
    late Session session;
    late CalendarService service;
    late TestPolicy policy;
    late ReplyHost host;
    late UuidValue eventId;
    late CalendarSchedulingPublicationRecord published;
    void install({CalendarSchedulingReplyOptions? options}) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        scheduling: CalendarSchedulingRuntime(
          host: SchedulingHost(),
          transport: SchedulingTransport(),
          replies: CalendarSchedulingReplyRuntime(host: host, options: options),
        ),
      );
      service = CalendarModule.service(session);
    }

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
      host = ReplyHost();
      install();
      final parent = (await service.create(createInput()))!.calendarId;
      eventId = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Original'),
        ),
      ))!.eventId;
      final receipt = await service.saveAndNotify(
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
        receipt.publicationId,
      ))!;
    });
    CalendarSchedulingReplyDelivery delivery({
      String? key,
      int? sequence,
      bool omitSequence = false,
      String stamp = '20261027T120000Z',
      String? participation = 'ACCEPTED',
      String? extra,
      String origin = 'verified-bob',
      String? uid,
      String address = 'mailto:bob@example.invalid',
    }) => CalendarSchedulingReplyDelivery(
      scopeKey: 'test:alice',
      eventId: eventId,
      namespace: 'synthetic',
      deliveryKey: key ?? const Uuid().v4(),
      originReference: origin,
      bytes: Uint8List.fromList(
        utf8.encode(
          [
            'BEGIN:VCALENDAR',
            'VERSION:2.0',
            'PRODID:-//Synthetic//EN',
            'METHOD:REPLY',
            'BEGIN:VEVENT',
            'UID:${uid ?? published.protocolUid}',
            'DTSTAMP:$stamp',
            if (!omitSequence) 'SEQUENCE:${sequence ?? published.sequence}',
            'ORGANIZER:mailto:alice@example.invalid',
            'ATTENDEE${participation == null ? '' : ';PARTSTAT=$participation'}:$address',
            ?extra,
            'END:VEVENT',
            'END:VCALENDAR',
            '',
          ].join('\r\n'),
        ),
      ),
    );
    Future<CalendarSchedulingReplyReceipt> receive(
      CalendarSchedulingReplyDelivery d,
    ) => CalendarModule.receiveSchedulingReply(session, d);
    Future<int> sources() =>
        CalendarSchedulingReplySourceRecord.db.count(session);
    Future<int> receipts() =>
        CalendarSchedulingReplyReceiptRecord.db.count(session);
    Future<CalendarSchedulingAttendeeResponseView> response() async =>
        (await service.schedulingResponses(eventId)).responses.single;

    test('verified response changes only private reply state and retries are stable', () async {
      final before = (await CalendarEventDataRecord.db.findFirstRow(session))!
          .toJson();
      final bindingBefore =
          (await CalendarSchedulingMeetingRecord.db.findFirstRow(session))!
              .toJson();
      final scopeBefore = (await CalendarScopeRecord.db.findFirstRow(session))!
          .toJson();
      final publicationBefore = published.toJson();
      final input = delivery(key: 'stable');
      final first = await receive(input);
      expect(first.outcome, CalendarSchedulingReplyOutcome.applied);
      expect(
        (await response()).effectiveParticipation,
        CalendarSchedulingParticipation.accepted,
      );
      final retry = await receive(input);
      expect(retry.receiptId, first.receiptId);
      expect(retry.unchanged, isTrue);
      final duplicate = await receive(delivery(key: 'other'));
      expect(duplicate.sourceId, first.sourceId);
      expect(duplicate.outcome, CalendarSchedulingReplyOutcome.duplicate);
      expect(await sources(), 1);
      expect(await receipts(), 2);
      expect((await response()).revision, 1);
      expect(
        (await CalendarEventDataRecord.db.findFirstRow(session))!.toJson(),
        before,
      );
      expect(
        (await CalendarSchedulingMeetingRecord.db.findFirstRow(session))!
            .toJson(),
        bindingBefore,
      );
      expect(
        (await CalendarScopeRecord.db.findFirstRow(session))!.toJson(),
        scopeBefore,
      );
      expect(
        (await CalendarSchedulingPublicationRecord.db.findById(
          session,
          published.id!,
        ))!.toJson(),
        publicationBefore,
      );
      expect(
        (await service.schedulingReplySource(
          eventId,
          first.sourceId,
        )).normalizedSource,
        contains('PARTSTAT=ACCEPTED'),
      );
      await receive(
        delivery(stamp: '20261027T130000Z', participation: 'DECLINED'),
      );
      expect((await receive(input)).unchanged, isTrue);
      expect(host.contexts.last.isRetry, isTrue);
      expect(
        host.contexts.last.currentResponse!.effectiveParticipation,
        CalendarSchedulingParticipation.declined,
      );
      host.denied = true;
      await expectLater(
        receive(input),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denied = false;
      expect(
        (await response()).effectiveParticipation,
        CalendarSchedulingParticipation.declined,
      );
    });

    test('no reply is unknown and omitted PARTSTAT remains absent with RFC default', () async {
      expect((await response()).effectiveParticipation, isNull);
      await receive(delivery(participation: null));
      final view = await response();
      expect(view.sourceParticipation, isNull);
      expect(
        view.effectiveParticipation,
        CalendarSchedulingParticipation.needsAction,
      );
      expect(view.isCurrent, isTrue);
    });

    test(
      'older newer and tied sources never overwrite the current stamp',
      () async {
        await receive(delivery());
        expect(
          (await receive(
            delivery(stamp: '20261027T110000Z', participation: 'DECLINED'),
          )).outcome,
          CalendarSchedulingReplyOutcome.stale,
        );
        expect(
          (await receive(delivery(participation: 'DECLINED'))).outcome,
          CalendarSchedulingReplyOutcome.conflict,
        );
        expect(
          (await receive(
            delivery(stamp: '20261027T130000Z', participation: 'TENTATIVE'),
          )).outcome,
          CalendarSchedulingReplyOutcome.applied,
        );
        expect(
          (await response()).effectiveParticipation,
          CalendarSchedulingParticipation.tentative,
        );
        expect((await response()).revision, 2);
      },
    );

    test('sequence and ordinary metadata conflicts remain reviewable and unapplied', () async {
      expect(
        (await receive(delivery(sequence: published.sequence + 1))).outcome,
        CalendarSchedulingReplyOutcome.unmatched,
      );
      if (published.sequence > 0) {
        expect(
          (await receive(delivery(sequence: published.sequence - 1))).outcome,
          CalendarSchedulingReplyOutcome.stale,
        );
      }
      expect(
        (await receive(delivery(extra: 'SUMMARY:Different'))).outcome,
        CalendarSchedulingReplyOutcome.conflict,
      );
      expect(
        (await receive(delivery(extra: 'SUMMARY:Published'))).outcome,
        CalendarSchedulingReplyOutcome.applied,
      );
      expect(
        (await receive(
          delivery(
            stamp: '20261027T140000Z',
            extra: 'REQUEST-STATUS:3.7;Invalid calendar user',
          ),
        )).outcome,
        CalendarSchedulingReplyOutcome.unappliedResult,
      );
      expect(
        (await response()).effectiveParticipation,
        CalendarSchedulingParticipation.accepted,
      );
    });

    test('unverified foreign delegated and key-reuse inputs cannot mutate private state', () async {
      for (final input in [
        delivery(origin: 'untrusted'),
        delivery(uid: 'foreign'),
        delivery(address: 'mailto:unknown@example.invalid'),
        delivery(participation: 'DELEGATED'),
      ]) {
        await expectLater(receive(input), throwsA(isA<CalendarException>()));
      }
      expect(await sources(), 0);
      await receive(delivery(key: 'same'));
      await expectLater(
        receive(delivery(key: 'same', participation: 'DECLINED')),
        failure(CalendarFailureCode.validation),
      );
      expect(await sources(), 1);
      expect(await receipts(), 1);
    });

    test('final host denial rolls back all three writes and exact retry then succeeds', () async {
      host.denyFinal = true;
      final input = delivery(key: 'rollback');
      await expectLater(
        receive(input),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await sources(), 0);
      expect(await receipts(), 0);
      expect(
        await CalendarSchedulingAttendeeResponseRecord.db.count(session),
        0,
      );
      host.denyFinal = false;
      expect(
        (await receive(input)).outcome,
        CalendarSchedulingReplyOutcome.applied,
      );
    });

    test('source and response authorization gates are independent and all-or-nothing', () async {
      final first = await receive(delivery());
      await receive(
        delivery(stamp: '20261027T130000Z', participation: 'DECLINED'),
      );
      policy.deniedReplySources.add(first.sourceId);
      await expectLater(
        service.schedulingReplySources(eventId),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await response()).effectiveParticipation,
        CalendarSchedulingParticipation.declined,
      );
      policy.deniedReplySources.clear();
      policy.denied.add(CalendarPermission.readSchedulingReplySource);
      expect((await response()).isCurrent, isTrue);
      await expectLater(
        service.schedulingReplySources(eventId),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.schedulingReplySource(eventId, first.sourceId),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.denied.add(CalendarPermission.readSchedulingResponses);
      await expectLater(response(), failure(CalendarFailureCode.accessDenied));
      await expectLater(
        service.schedulingReplySources(eventId),
        failure(CalendarFailureCode.accessDenied),
      );
    });

    test(
      'response revision overflow rejects without admitting source or receipt',
      () async {
        await receive(delivery());
        final current = (await CalendarSchedulingAttendeeResponseRecord.db
            .findFirstRow(session))!;
        current.revision = 9007199254740991;
        await CalendarSchedulingAttendeeResponseRecord.db.updateRow(
          session,
          current,
        );
        await expectLater(
          receive(delivery(stamp: '20261027T140000Z')),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await sources(), 1);
        expect(await receipts(), 1);
      },
    );

    test(
      'bounded capacity rejects atomically but same-key retry still succeeds',
      () async {
        install(
          options: CalendarSchedulingReplyOptions(
            maxSourcesPerBinding: 1,
            maxReceiptsPerBinding: 1,
          ),
        );
        final input = delivery(key: 'retained');
        await receive(input);
        await expectLater(
          receive(delivery(participation: 'DECLINED')),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect((await receive(input)).unchanged, isTrue);
        expect(await sources(), 1);
        expect(await receipts(), 1);
      },
    );

    test(
      'new published version makes response prior and old replies stay stale',
      () async {
        await receive(delivery());
        final old = published;
        final next = await service.saveAndNotify(
          CalendarSchedulingSaveRequest(
            eventId: eventId,
            expectedRevision: 2,
            commandId: const Uuid().v4obj(),
            recipients: old.recipients,
            content: eventInput(summary: 'Updated'),
          ),
        );
        published = (await CalendarSchedulingPublicationRecord.db.findById(
          session,
          next.publicationId,
        ))!;
        expect((await response()).isCurrent, isFalse);
        expect(
          (await CalendarSchedulingReplySourceRecord.db.findFirstRow(session))!
              .inactiveAt,
          isNotNull,
        );
        expect(
          (await receive(
            delivery(sequence: old.sequence, stamp: '20261027T150000Z'),
          )).outcome,
          CalendarSchedulingReplyOutcome.stale,
        );
        expect((await response()).isCurrent, isFalse);
        expect(
          (await receive(delivery(stamp: '20261027T160000Z'))).outcome,
          CalendarSchedulingReplyOutcome.applied,
        );
        expect((await response()).isCurrent, isTrue);
      },
    );

    test('published cancellation suppresses a matching-version reply without reopening', () async {
      await service.cancelAndNotify(
        CalendarSchedulingCancelRequest(
          eventId: eventId,
          expectedRevision: 2,
          commandId: const Uuid().v4obj(),
        ),
      );
      published = (await CalendarSchedulingPublicationRecord.db.findFirstRow(
        session,
        where: (t) => t.method.equals('CANCEL'),
      ))!;
      expect(
        (await receive(delivery())).outcome,
        CalendarSchedulingReplyOutcome.unappliedResult,
      );
      expect((await response()).effectiveParticipation, isNull);
      expect(
        (await service.schedulingResponses(eventId)).publishedCancelled,
        isTrue,
      );
      expect(
        (await CalendarEventDataRecord.db.findFirstRow(session))!
            .content
            .status,
        CalendarEventStatus.cancelled,
      );
    });

    test('zero omission and independent future clock are preserved exactly', () async {
      // Omission compares as zero, independently of this invitation's version.
      final first = await receive(
        delivery(omitSequence: true, stamp: '20991230T120000Z'),
      );
      expect(first.sourceSequence, isNull);
      expect(
        first.outcome,
        published.sequence == 0
            ? CalendarSchedulingReplyOutcome.applied
            : CalendarSchedulingReplyOutcome.stale,
      );
      await receive(delivery(stamp: '20991230T120001Z'));
      expect((await response()).isCurrent, isTrue);
      expect(
        (await receive(
          delivery(stamp: '20261027T150000Z', participation: 'DECLINED'),
        )).outcome,
        CalendarSchedulingReplyOutcome.stale,
      );
      final source = await service.schedulingReplySource(
        eventId,
        first.sourceId,
      );
      expect(source.normalizedSource, isNot(contains('SEQUENCE:')));
      expect(source.normalizedSource, contains('DTSTAMP:20991230T120000Z'));
    });

    test('active ordering survives pruning; duplicate receipt retains inactive source', () async {
      install(
        options: CalendarSchedulingReplyOptions(
          retention: const Duration(hours: 1),
        ),
      );
      final first = await receive(delivery(key: 'initial'));
      await receive(
        delivery(stamp: '20261027T130000Z', participation: 'DECLINED'),
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_scheduling_reply_source SET "receivedAt"=clock_timestamp()-interval \'2 days\', '
        '"inactiveAt"=CASE WHEN "inactiveAt" IS NULL THEN NULL ELSE clock_timestamp()-interval \'2 days\' END',
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_scheduling_reply_receipt SET "receivedAt"=clock_timestamp()-interval \'2 days\'',
      );
      // New transport key references the old exact source without applying it.
      await receive(delivery(key: 'fresh-reference'));
      await CalendarModule.runSchedulingMaintenance(session);
      expect(
        await CalendarSchedulingReplySourceRecord.db.findById(
          session,
          first.sourceId,
        ),
        isNotNull,
      );
      expect(await receipts(), 1);
      expect(
        (await response()).effectiveParticipation,
        CalendarSchedulingParticipation.declined,
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_scheduling_reply_receipt SET "receivedAt"=clock_timestamp()-interval \'2 days\'',
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_scheduling_reply_source SET "inactiveAt"=clock_timestamp()-interval \'2 days\' WHERE "inactiveAt" IS NOT NULL',
      );
      await CalendarModule.runSchedulingMaintenance(session);
      expect(
        await CalendarSchedulingReplySourceRecord.db.findById(
          session,
          first.sourceId,
        ),
        isNull,
      );
      expect(await sources(), 1);
      expect(
        (await response()).effectiveParticipation,
        CalendarSchedulingParticipation.declined,
      );
    });

    test('corrupt retained ordering state fails closed before overwrite or disclosure', () async {
      final first = await receive(delivery());
      final row = (await CalendarSchedulingReplySourceRecord.db.findById(
        session,
        first.sourceId,
      ))!;
      row.stamp = row.stamp.add(const Duration(seconds: 1));
      await CalendarSchedulingReplySourceRecord.db.updateRow(session, row);
      await expectLater(response(), failure(CalendarFailureCode.unavailable));
      await expectLater(
        service.schedulingReplySource(eventId, first.sourceId),
        failure(CalendarFailureCode.unavailable),
      );
      await expectLater(
        receive(delivery(stamp: '20261027T150000Z')),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await sources(), 1);
      row.stamp = row.stamp.subtract(const Duration(seconds: 1));
      await CalendarSchedulingReplySourceRecord.db.updateRow(session, row);
      final checkpoint = (await CalendarSchedulingAttendeeResponseRecord.db
          .findFirstRow(session))!;
      checkpoint.scopeKey = 'foreign:scope';
      await CalendarSchedulingAttendeeResponseRecord.db.updateRow(
        session,
        checkpoint,
      );
      await expectLater(
        service.schedulingReplySource(eventId, first.sourceId),
        failure(CalendarFailureCode.unavailable),
      );
    });

    test(
      'stored publication cannot retarget the actual trusted event identity',
      () async {
        final foreign = const Uuid().v4obj().toString();
        Object? replace(Object? value) => switch (value) {
          Map<String, dynamic> map => map.map(
            (key, item) =>
                MapEntry(key, key == 'eventId' ? foreign : replace(item)),
          ),
          List list => list.map(replace).toList(),
          _ => value,
        };
        published.snapshot = jsonEncode(
          replace(jsonDecode(published.snapshot)),
        );
        await CalendarSchedulingPublicationRecord.db.updateRow(
          session,
          published,
        );
        await expectLater(
          receive(delivery()),
          failure(CalendarFailureCode.unavailable),
        );
        await expectLater(response(), failure(CalendarFailureCode.unavailable));
        expect(await sources(), 0);
      },
    );

    test('byte input is frozen and unsupported recurrence cannot enter reply storage', () async {
      final original = delivery();
      final bytes = Uint8List.fromList(original.bytes);
      final frozen = CalendarSchedulingReplyDelivery(
        scopeKey: original.scopeKey,
        eventId: eventId,
        namespace: original.namespace,
        deliveryKey: original.deliveryKey,
        originReference: original.originReference,
        bytes: bytes,
      );
      bytes.fillRange(0, bytes.length, 0);
      expect(
        (await receive(frozen)).outcome,
        CalendarSchedulingReplyOutcome.applied,
      );
      await expectLater(
        receive(delivery(extra: 'RECURRENCE-ID;VALUE=DATE:20260329')),
        failure(CalendarFailureCode.validation),
      );
      expect(await sources(), 1);
    });
  });
}
