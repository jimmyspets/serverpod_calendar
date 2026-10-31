import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, failure, createInput;
import 'test_tools/serverpod_test_tools.dart';

Uint8List invitationBytes({
  String uid = 'meeting',
  int? sequence,
  String stamp = '20260101T000000Z',
  String summary = 'Review',
  String? zone,
  bool date = false,
  List<String> extra = const [],
  String organizer = 'mailto:organizer@example.invalid',
}) {
  String? definition;
  if (zone != null) {
    final text = utf8.decode(
      serializeIcalendarSyntax(
        IcalendarSyntaxDocument([createIcalendarTimeZone(zone)]),
      ),
    );
    definition = text.substring(0, text.length - 2);
  }
  return Uint8List.fromList(
    utf8.encode(
      [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:-//Synthetic//EN',
        'METHOD:REQUEST',
        ?definition,
        'BEGIN:VEVENT',
        'UID:$uid',
        'DTSTAMP:$stamp',
        if (sequence != null) 'SEQUENCE:$sequence',
        date
            ? 'DTSTART;VALUE=DATE:20300101'
            : zone == null
            ? 'DTSTART:20300101T090000Z'
            : 'DTSTART;TZID=$zone:20300101T090000',
        'SUMMARY:${encodeIcalendarText(summary)}',
        'ORGANIZER:$organizer',
        'ATTENDEE:mailto:alice@example.invalid',
        'ATTENDEE:mailto:bob@example.invalid',
        'CONTACT:PRIVATE CONTACT',
        ...extra,
        'END:VEVENT',
        'END:VCALENDAR',
        '',
      ].join('\r\n'),
    ),
  );
}

CalendarInvitationDelivery invitationDelivery({
  String key = 'one',
  String origin = 'trusted',
  Uint8List? bytes,
}) => CalendarInvitationDelivery(
  namespace: 'fixture',
  deliveryKey: key,
  originReference: origin,
  bytes: bytes ?? invitationBytes(),
);

final class InvitationTestHost implements CalendarInvitationHost {
  CalendarAuthorizationGuarantee capability =
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  CalendarAuthorizationGuarantee get guarantee => capability;
  final denied = <CalendarInvitationOperation>{}, hidden = <UuidValue>{};
  bool unavailable = false, denyFinal = false;
  CalendarInvitationRecipient? currentOverride;
  CalendarInvitationRecipient target = const CalendarInvitationRecipient(
    scopeKey: 'test:alice',
    key: 'alice',
    calendarAddress: 'mailto:alice@example.invalid',
  );
  Future<void> Function(
    CalendarInvitationPolicyContext,
    Transaction,
    CalendarAuthorizationPhase,
  )?
  onAuthorize;
  @override
  Future<CalendarInvitationRecipient> resolveDelivery(
    Session session,
    CalendarInvitationDelivery delivery,
    IcalendarSchedulingMessage message,
  ) async {
    if (delivery.originReference != 'trusted' ||
        message.events.single.participants.organizer!.address !=
            'mailto:organizer@example.invalid') {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Synthetic origin denied',
      );
    }
    return target;
  }

  @override
  Future<CalendarInvitationRecipient> resolveCurrent(
    Session session,
    CalendarHostContext actor,
    Transaction tx,
  ) async =>
      currentOverride ??
      CalendarInvitationRecipient(
        scopeKey: actor.scopeKey,
        key: actor.principalId,
        calendarAddress: 'mailto:${actor.principalId}@example.invalid',
      );
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarInvitationPolicyContext context,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    await onAuthorize?.call(context, tx, phase);
    if (unavailable) return CalendarAuthorizationVerdict.unavailable;
    return denied.contains(context.operation) ||
            (context.operation == CalendarInvitationOperation.readSummary &&
                hidden.contains(context.entryId)) ||
            (denyFinal && phase == CalendarAuthorizationPhase.finalWrite)
        ? CalendarAuthorizationVerdict.deny
        : CalendarAuthorizationVerdict.allow;
  }
}

void main() {
  withServerpod('trusted invitation intake and private review', (
    builder,
    endpoints,
  ) {
    late Session session;
    late TestPolicy policy;
    late InvitationTestHost host;
    late CalendarService service;
    void install([
      CalendarInvitationOptions? options,
      CalendarAuthorizationGuarantee required =
          CalendarAuthorizationGuarantee.freshCheck,
    ]) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: CalendarModuleOptions(requiredWriteGuarantee: required),
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
      policy = TestPolicy();
      host = InvitationTestHost();
      install();
    });
    Future<CalendarInvitationReceipt> receive({
      String key = 'one',
      Uint8List? bytes,
      String origin = 'trusted',
    }) => CalendarModule.receiveSchedulingInvitation(
      session,
      invitationDelivery(key: key, bytes: bytes, origin: origin),
    );
    Future<CalendarInvitationRecord> entry(UuidValue id) async =>
        (await CalendarInvitationRecord.db.findById(session, id))!;
    Future<List<CalendarInvitationSourceRecord>> sources() =>
        CalendarInvitationSourceRecord.db.find(session);
    Future<List<CalendarInvitationReceiptRecord>> receipts() =>
        CalendarInvitationReceiptRecord.db.find(session);
    Future<void> noCalendarWrites() async {
      expect(await CalendarIdentityRecord.db.count(session), 0);
      expect(await CalendarEventRecord.db.count(session), 0);
      expect(await CalendarTaskRecord.db.count(session), 0);
      expect(await CalendarAlarmRecord.db.count(session), 0);
      expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      final scope = await CalendarScopeRecord.db.findFirstRow(
        session,
        where: (t) => t.scopeKey.equals('test:alice'),
      );
      expect(scope?.revision, 1);
    }

    test('receipt preserves source omissions and private data without calendar effects', () async {
      final receipt = await receive();
      final view = await service.getInvitation(receipt.entryId);
      expect(receipt.outcome, CalendarInvitationOutcome.selected);
      expect(view.sequence, isNull);
      expect(view.stamp, DateTime.utc(2026));
      expect(view.timing!.kind, CalendarEventTimeKind.utc);
      expect(view.summary, 'Review');
      expect(view.toJson().toString(), isNot(contains('PRIVATE CONTACT')));
      expect(view.toJson().toString(), isNot(contains('bob@example.invalid')));
      expect((await service.listInvitations()).single.id, receipt.entryId);
      final source = await service.invitationSource(
        receipt.entryId,
        receipt.sourceId,
      );
      expect(source.text, contains('CONTACT:PRIVATE CONTACT'));
      expect(source.text, isNot(contains('SEQUENCE:')));
      expect(source.text, contains('METHOD:REQUEST'));
      await noCalendarWrites();
    });
    test('DATE and full-horizon named zone source remain distinct', () async {
      final date = await receive(
        bytes: invitationBytes(uid: 'date', date: true),
      );
      final named = await receive(
        key: 'named',
        bytes: invitationBytes(uid: 'named', zone: 'Europe/Stockholm'),
      );
      expect(
        (await service.getInvitation(date.entryId)).timing!.kind,
        CalendarEventTimeKind.date,
      );
      expect(
        (await service.getInvitation(named.entryId)).timing!.zoneId,
        'Europe/Stockholm',
      );
      expect(
        (await service.invitationSource(named.entryId, named.sourceId)).text,
        contains('BEGIN:VTIMEZONE'),
      );
    });
    test(
      'verified origin and exact target are required before history lookup',
      () async {
        await expectLater(
          receive(origin: 'spoofed'),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          receive(
            bytes: invitationBytes(organizer: 'mailto:spoof@example.invalid'),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        host.target = const CalendarInvitationRecipient(
          scopeKey: 'test:alice',
          key: 'alice',
          calendarAddress: 'mailto:absent@example.invalid',
        );
        await expectLater(receive(), failure(CalendarFailureCode.accessDenied));
        expect(await CalendarInvitationRecord.db.count(session), 0);
        expect(await sources(), isEmpty);
        expect(await receipts(), isEmpty);
      },
    );
    test('unsupported recurrence profiles methods delegation and fractions reject atomically', () async {
      for (final extra in [
        <String>['RRULE:FREQ=SECONDLY;COUNT=2'],
        <String>['RDATE;VALUE=DATE:20300102'],
        <String>['EXDATE:20300102T090000'],
      ]) {
        await expectLater(
          receive(bytes: invitationBytes(extra: extra)),
          failure(CalendarFailureCode.validation),
        );
      }
      for (final replacement in [
        invitationBytes().replace('METHOD:REQUEST', 'METHOD:PUBLISH'),
        invitationBytes().replace(
          'ORGANIZER:',
          'ORGANIZER;SENT-BY="mailto:delegate@example.invalid":',
        ),
        invitationBytes().replace(
          'ATTENDEE:mailto:alice',
          'ATTENDEE;DELEGATED-TO="mailto:delegate@example.invalid":mailto:alice',
        ),
        invitationBytes().replace('090000Z', '090000.001Z'),
      ]) {
        await expectLater(
          receive(bytes: replacement),
          failure(CalendarFailureCode.validation),
        );
      }
      expect(await sources(), isEmpty);
      expect(await receipts(), isEmpty);
    });
    test(
      'sequence dominates stamp and same-version stamp orders source updates',
      () async {
        await receive(bytes: invitationBytes(sequence: 1));
        final high = await receive(
          key: 'higher',
          bytes: invitationBytes(
            sequence: 2,
            stamp: '20250101T000000Z',
            summary: 'Newer sequence',
          ),
        );
        expect(high.entryRevision, 2);
        expect(
          (await service.getInvitation(high.entryId)).stamp,
          DateTime.utc(2025),
        );
        final low = await receive(
          key: 'lower',
          bytes: invitationBytes(sequence: 1, stamp: '20270101T000000Z'),
        );
        expect(low.outcome, CalendarInvitationOutcome.stale);
        expect(low.entryRevision, 2);
        final conflict = await receive(
          key: 'conflict',
          bytes: invitationBytes(
            sequence: 2,
            stamp: '20250101T000000Z',
            summary: 'Different same version',
          ),
        );
        expect(conflict.outcome, CalendarInvitationOutcome.conflict);
        final later = await receive(
          key: 'later',
          bytes: invitationBytes(
            sequence: 2,
            stamp: '20250101T000001Z',
            summary: 'Later stamp',
          ),
        );
        expect(later.outcome, CalendarInvitationOutcome.selected);
        expect(later.entryRevision, 3);
        expect(
          (await service.getInvitation(high.entryId)).summary,
          'Later stamp',
        );
        expect(
          (await service.invitationSources(high.entryId))
              .where((v) => v.isCurrent)
              .single
              .id,
          later.sourceId,
        );
        await noCalendarWrites();
      },
    );
    test('exact and cross-key duplicates retain source and current state after dismissal', () async {
      final first = await receive();
      await service.dismissInvitation(first.entryId, 1);
      final before = (await entry(first.entryId)).toJson();
      var seen = false;
      host.onAuthorize = (c, tx, phase) async {
        if (phase == CalendarAuthorizationPhase.finalWrite && c.isRetry) {
          seen = true;
          expect(c.current!.revision, 2);
          expect(c.proposedRevision, 2);
          expect(c.proposedDismissed, isTrue);
          expect(c.receipt!.entryRevision, 1);
          expect(c.receipt!.id, first.id);
        }
      };
      final retry = await receive();
      expect(retry.toJson(), first.toJson());
      expect(seen, isTrue);
      final duplicate = await receive(key: 'duplicate');
      expect(duplicate.outcome, CalendarInvitationOutcome.duplicate);
      expect(duplicate.sourceId, first.sourceId);
      expect(duplicate.entryRevision, 2);
      expect(await service.listInvitations(), isEmpty);
      expect((await entry(first.entryId)).toJson(), before);
      expect(await sources(), hasLength(1));
      expect(await receipts(), hasLength(2));
    });
    test('a newer source reopens only review and stale/conflict sources never reopen it', () async {
      final first = await receive();
      await service.dismissInvitation(first.entryId, 1);
      final conflict = await receive(
        key: 'conflict',
        bytes: invitationBytes(summary: 'Conflict'),
      );
      expect(conflict.outcome, CalendarInvitationOutcome.conflict);
      expect(await service.listInvitations(), isEmpty);
      final newer = await receive(
        key: 'newer',
        bytes: invitationBytes(sequence: 1),
      );
      expect(newer.entryRevision, 3);
      expect((await service.listInvitations()).single.id, first.entryId);
      await noCalendarWrites();
    });
    test('conflicting delivery-key payload and origin evidence do not overwrite rows', () async {
      final first = await receive();
      await expectLater(
        receive(bytes: invitationBytes(summary: 'Changed')),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        receive(bytes: invitationBytes(uid: 'other')),
        failure(CalendarFailureCode.validation),
      );
      expect((await entry(first.entryId)).revision, 1);
      expect(await sources(), hasLength(1));
      expect(await receipts(), hasLength(1));
    });
    test(
      'immutable proposal/final context and late denial roll back every row',
      () async {
        var finalSeen = false;
        host.onAuthorize = (c, tx, phase) async {
          expect(c.recipient.key, 'alice');
          expect(() => c.delivery!.bytes[0] = 0, throwsUnsupportedError);
          expect(() => c.message!.events.clear(), throwsUnsupportedError);
          if (phase == CalendarAuthorizationPhase.finalWrite) {
            finalSeen = true;
            expect(c.entryId, isNotNull);
            expect(c.sourceId, isNotNull);
            expect(c.receiptId, isNotNull);
            expect(c.receipt!.outcome, CalendarInvitationOutcome.selected);
            expect(
              await CalendarInvitationReceiptRecord.db.count(
                session,
                transaction: tx,
              ),
              1,
            );
          }
        };
        host.denyFinal = true;
        await expectLater(receive(), failure(CalendarFailureCode.accessDenied));
        expect(finalSeen, isTrue);
        expect(await CalendarInvitationRecord.db.count(session), 0);
        expect(await sources(), isEmpty);
        expect(await receipts(), isEmpty);
      },
    );
    test('independent list summary source and dismiss authority', () async {
      final first = await receive();
      host.denied.add(CalendarInvitationOperation.readSource);
      expect((await service.listInvitations()).single.id, first.entryId);
      await expectLater(
        service.invitationSources(first.entryId),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.invitationSource(first.entryId, first.sourceId),
        failure(CalendarFailureCode.accessDenied),
      );
      host.hidden.add(first.entryId);
      expect(await service.listInvitations(), isEmpty);
      await expectLater(
        service.getInvitation(first.entryId),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denied.add(CalendarInvitationOperation.dismiss);
      await expectLater(
        service.dismissInvitation(first.entryId, 1),
        failure(CalendarFailureCode.accessDenied),
      );
      expect((await entry(first.entryId)).dismissedAt, isNull);
    });
    test(
      'foreign recipient and scope cannot read source even with known UUIDs',
      () async {
        final first = await receive();
        final bob = builder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'bob',
                {},
              ),
            )
            .build();
        policy.scopeOverride = 'test:alice';
        final other = CalendarModule.service(bob);
        expect(await other.listInvitations(), isEmpty);
        await expectLater(
          other.getInvitation(first.entryId),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          other.invitationSource(first.entryId, first.sourceId),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.scopeOverride = null;
        await expectLater(
          other.getInvitation(first.entryId),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test(
      'stale dismissal and final denial preserve source and marker state',
      () async {
        final first = await receive();
        await expectLater(
          service.dismissInvitation(first.entryId, 2),
          failure(CalendarFailureCode.staleRevision),
        );
        host.denyFinal = true;
        await expectLater(
          service.dismissInvitation(first.entryId, 1),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await entry(first.entryId)).revision, 1);
        expect((await sources()).single.inactiveAt, isNull);
        host.denyFinal = false;
        await service.dismissInvitation(first.entryId, 1);
        final before = (await entry(first.entryId)).toJson();
        await service.dismissInvitation(first.entryId, 2);
        expect((await entry(first.entryId)).toJson(), before);
      },
    );
    test(
      'pending source and unexpired receipts survive terminal cleanup',
      () async {
        final first = await receive();
        final second = await receive(
          key: 'second',
          bytes: invitationBytes(sequence: 1),
        );
        final old = (await sources()).singleWhere(
          (s) => s.id == first.sourceId,
        );
        old.inactiveAt = DateTime.utc(2000);
        await CalendarInvitationSourceRecord.db.updateRow(session, old);
        await service.listInvitations();
        expect(await sources(), hasLength(2));
        final r = (await receipts()).singleWhere(
          (r) => r.sourceId == first.sourceId,
        );
        r.expiresAt = DateTime.utc(2000);
        await CalendarInvitationReceiptRecord.db.updateRow(session, r);
        await service.listInvitations();
        expect((await sources()).single.id, second.sourceId);
        final pending = (await sources()).single;
        pending.receivedAt = DateTime.utc(2000);
        await CalendarInvitationSourceRecord.db.updateRow(session, pending);
        await service.listInvitations();
        expect((await sources()).single.id, second.sourceId);
      },
    );
    test('expired dismissed marker prunes safely and old delivery can return only to review', () async {
      final first = await receive();
      await service.dismissInvitation(first.entryId, 1);
      final e = await entry(first.entryId);
      e.dismissedAt = DateTime.utc(2000);
      await CalendarInvitationRecord.db.updateRow(session, e);
      final source = (await sources()).single;
      source.inactiveAt = DateTime.utc(2000);
      await CalendarInvitationSourceRecord.db.updateRow(session, source);
      final r = (await receipts()).single;
      r.expiresAt = DateTime.utc(2000);
      await CalendarInvitationReceiptRecord.db.updateRow(session, r);
      expect(await service.listInvitations(), isEmpty);
      expect(await CalendarInvitationRecord.db.count(session), 0);
      expect(await sources(), isEmpty);
      expect(await receipts(), isEmpty);
      final again = await receive();
      expect(again.entryId, isNot(first.entryId));
      expect((await service.listInvitations()).single.id, again.entryId);
      await noCalendarWrites();
    });
    test('source and receipt caps are atomic while retained retries remain possible', () async {
      install(
        CalendarInvitationOptions(
          maxSources: 1,
          maxSourcesPerEntry: 1,
          maxReceipts: 1,
        ),
      );
      final first = await receive();
      await expectLater(
        receive(key: 'new', bytes: invitationBytes(sequence: 1)),
        failure(CalendarFailureCode.limitExceeded),
      );
      await expectLater(
        receive(key: 'dup'),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect((await receive()).id, first.id);
      expect((await entry(first.entryId)).revision, 1);
      expect(await sources(), hasLength(1));
      expect(await receipts(), hasLength(1));
    });
    test('message byte pending marker and aggregate-byte caps reject without partial rows', () async {
      install(CalendarInvitationOptions(maxSourceBytes: 1));
      await expectLater(receive(), failure(CalendarFailureCode.limitExceeded));
      install(CalendarInvitationOptions(maxRetainedBytes: 1));
      await expectLater(receive(), failure(CalendarFailureCode.limitExceeded));
      install(CalendarInvitationOptions(maxPending: 1, maxDismissed: 1));
      final first = await receive();
      await expectLater(
        receive(
          key: 'other',
          bytes: invitationBytes(uid: 'other'),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      await service.dismissInvitation(first.entryId, 1);
      final second = await receive(
        key: 'other',
        bytes: invitationBytes(uid: 'other'),
      );
      await expectLater(
        service.dismissInvitation(second.entryId, 1),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect((await entry(second.entryId)).dismissedAt, isNull);
    });
    test(
      'unavailable authorization and guarantee downgrade roll back writes',
      () async {
        host.unavailable = true;
        await expectLater(receive(), failure(CalendarFailureCode.unavailable));
        host.unavailable = false;
        policy.capability = CalendarAuthorizationGuarantee.coordinated;
        host.capability = CalendarAuthorizationGuarantee.coordinated;
        install(null, CalendarAuthorizationGuarantee.coordinated);
        host.onAuthorize = (c, tx, phase) async {
          if (phase == CalendarAuthorizationPhase.finalWrite) {
            host.capability = CalendarAuthorizationGuarantee.freshCheck;
          }
        };
        await expectLater(receive(), failure(CalendarFailureCode.unavailable));
        expect(await sources(), isEmpty);
        expect(await receipts(), isEmpty);
      },
    );

    test('input bytes are copied and retained source reads survive lower admission limits', () async {
      final bytes = invitationBytes();
      final delivery = invitationDelivery(bytes: bytes);
      bytes.fillRange(0, bytes.length, 0);
      final first = await CalendarModule.receiveSchedulingInvitation(
        session,
        delivery,
      );
      install(CalendarInvitationOptions(maxSourceBytes: 1));
      expect((await service.getInvitation(first.entryId)).summary, 'Review');
      expect(
        (await service.invitationSource(first.entryId, first.sourceId)).text,
        contains('SUMMARY:Review'),
      );
    });
    test('expired marker cleanup frees dismissal capacity and final denial rolls cleanup back', () async {
      install(CalendarInvitationOptions(maxDismissed: 1));
      final first = await receive();
      await service.dismissInvitation(first.entryId, 1);
      final e = await entry(first.entryId);
      e.dismissedAt = DateTime.utc(2000);
      await CalendarInvitationRecord.db.updateRow(session, e);
      final source = (await sources()).single;
      source.inactiveAt = DateTime.utc(2000);
      await CalendarInvitationSourceRecord.db.updateRow(session, source);
      final r = (await receipts()).single;
      r.expiresAt = DateTime.utc(2000);
      await CalendarInvitationReceiptRecord.db.updateRow(session, r);
      // Create the second fixture directly before expiry is made visible to ingress cleanup.
      // Restore expiry while receiving, then expire the prior marker for dismissal.
      e.dismissedAt = DateTime.now().toUtc();
      await CalendarInvitationRecord.db.updateRow(session, e);
      source.inactiveAt = DateTime.now().toUtc();
      await CalendarInvitationSourceRecord.db.updateRow(session, source);
      r.expiresAt = DateTime.now().toUtc().add(const Duration(days: 30));
      await CalendarInvitationReceiptRecord.db.updateRow(session, r);
      final second = await receive(
        key: 'second',
        bytes: invitationBytes(uid: 'second'),
      );
      e.dismissedAt = DateTime.utc(2000);
      await CalendarInvitationRecord.db.updateRow(session, e);
      source.inactiveAt = DateTime.utc(2000);
      await CalendarInvitationSourceRecord.db.updateRow(session, source);
      r.expiresAt = DateTime.utc(2000);
      await CalendarInvitationReceiptRecord.db.updateRow(session, r);
      host.denyFinal = true;
      await expectLater(
        service.dismissInvitation(second.entryId, 1),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        await CalendarInvitationRecord.db.findById(session, first.entryId),
        isNotNull,
      );
      expect(
        await CalendarInvitationSourceRecord.db.findById(
          session,
          first.sourceId,
        ),
        isNotNull,
      );
      host.denyFinal = false;
      await service.dismissInvitation(second.entryId, 1);
      expect(
        await CalendarInvitationRecord.db.findById(session, first.entryId),
        isNull,
      );
      expect((await entry(second.entryId)).dismissedAt, isNotNull);
    });
    test('digest-only dismissed marker never fabricates exact source equality or reopens', () async {
      final first = await receive();
      await service.dismissInvitation(first.entryId, 1);
      final conflict = await receive(
        key: 'conflict',
        bytes: invitationBytes(summary: 'Retained conflict'),
      );
      final old = (await sources()).singleWhere((v) => v.id == first.sourceId);
      old.inactiveAt = DateTime.utc(2000);
      await CalendarInvitationSourceRecord.db.updateRow(session, old);
      final r = (await receipts()).singleWhere(
        (v) => v.sourceId == first.sourceId,
      );
      r.expiresAt = DateTime.utc(2000);
      await CalendarInvitationReceiptRecord.db.updateRow(session, r);
      expect(await service.listInvitations(), isEmpty);
      expect((await entry(first.entryId)).currentSourceId, isNull);
      expect(
        (await service.invitationSources(first.entryId)).single.id,
        conflict.sourceId,
      );
      await expectLater(
        receive(key: 'body-pruned'),
        failure(CalendarFailureCode.unavailable),
      );
      expect((await entry(first.entryId)).revision, 2);
      final newer = await receive(
        key: 'newer',
        bytes: invitationBytes(sequence: 1),
      );
      expect((await service.listInvitations()).single.sourceId, newer.sourceId);
    });
    test('unavailable read policy fails complete queue and mutable recipient mapping rolls back', () async {
      final first = await receive();
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.readSummary) {
          host.unavailable = true;
        }
      };
      await expectLater(
        service.listInvitations(),
        failure(CalendarFailureCode.unavailable),
      );
      host.unavailable = false;
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.readSummary) {
          host.currentOverride = const CalendarInvitationRecipient(
            scopeKey: 'test:alice',
            key: 'other',
            calendarAddress: 'mailto:other@example.invalid',
          );
        }
      };
      await expectLater(
        service.listInvitations(),
        failure(CalendarFailureCode.unavailable),
      );
      host.currentOverride = null;
      host.onAuthorize = null;
      expect((await service.getInvitation(first.entryId)).revision, 1);
    });
    test(
      'cross-key duplicate validates retained historical source fields',
      () async {
        final first = await receive();
        await receive(key: 'newer', bytes: invitationBytes(sequence: 1));
        final old = (await sources()).singleWhere(
          (s) => s.id == first.sourceId,
        );
        old.sequence = 99;
        await CalendarInvitationSourceRecord.db.updateRow(session, old);
        await expectLater(
          receive(key: 'historical-duplicate'),
          failure(CalendarFailureCode.unavailable),
        );
        expect(await receipts(), hasLength(2));
        expect((await entry(first.entryId)).revision, 2);
      },
    );
    test('inbox-only receipt dismissal and cleanup preserve existing calendar continuation', () async {
      await service.create(createInput('One'));
      await service.create(createInput('Two'));
      final page = await service.list(
        pageSize: 1,
        fieldGroups: [CalendarFieldGroup.metadata],
      );
      final receipt = await receive();
      await service.dismissInvitation(receipt.entryId, 1);
      await service.listInvitations();
      final continued = await service.list(
        pageSize: 1,
        fieldGroups: [CalendarFieldGroup.metadata],
        cursor: page.nextCursor,
      );
      expect(continued.calendars.single.id, isNot(page.calendars.single.id));
    });
    test('revision overflow and corrupt stored digests fail closed', () async {
      final first = await receive();
      final e = await entry(first.entryId);
      e.revision = 9007199254740991;
      await CalendarInvitationRecord.db.updateRow(session, e);
      await expectLater(
        receive(key: 'new', bytes: invitationBytes(sequence: 1)),
        failure(CalendarFailureCode.limitExceeded),
      );
      await expectLater(
        service.dismissInvitation(first.entryId, e.revision),
        failure(CalendarFailureCode.limitExceeded),
      );
      final source = (await sources()).single;
      source.digest = 'bad';
      await CalendarInvitationSourceRecord.db.updateRow(session, source);
      await expectLater(
        service.getInvitation(first.entryId),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await receipts(), hasLength(1));
    });
  });
}

extension _InvitationBytes on Uint8List {
  Uint8List replace(String from, String to) =>
      Uint8List.fromList(utf8.encode(utf8.decode(this).replaceAll(from, to)));
}
