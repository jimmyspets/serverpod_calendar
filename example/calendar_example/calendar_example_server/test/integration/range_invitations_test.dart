import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'test_tools/serverpod_test_tools.dart';

Uint8List rangeInvitationBytes({
  int sequence = 2,
  bool cancel = false,
  bool date = false,
  String? zone,
  String? original,
  List<String> extra = const [],
}) {
  var text = utf8.decode(
    invitationBytes(
      sequence: sequence,
      date: date,
      zone: zone,
      extra: [
        date
            ? 'RECURRENCE-ID;RANGE=THISANDFUTURE;VALUE=DATE:${original ?? '20300102'}'
            : zone == null
            ? 'RECURRENCE-ID;RANGE=THISANDFUTURE:${original ?? '20300102T090000Z'}'
            : 'RECURRENCE-ID;RANGE=THISANDFUTURE;TZID=$zone:${original ?? '20300102T090000'}',
        ...extra,
      ],
    ),
  );
  if (cancel) {
    text = text
        .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL')
        .replaceFirst(
          'BEGIN:VEVENT\r\n',
          'BEGIN:VEVENT\r\nSTATUS:CANCELLED\r\n',
        )
        .replaceFirst(
          date
              ? 'DTSTART;VALUE=DATE:20300101\r\n'
              : zone == null
              ? 'DTSTART:20300101T090000Z\r\n'
              : 'DTSTART;TZID=$zone:20300101T090000\r\n',
          '',
        );
  }
  return Uint8List.fromList(utf8.encode(text));
}

void main() {
  withServerpod('range invitation review', (builder, endpoints) {
    late Session session;
    late InvitationTestHost host;
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
      host = InvitationTestHost();
      CalendarModule.install(
        session.serverpod,
        policy: TestPolicy(),
        options: CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(host: host),
      );
      service = CalendarModule.service(session);
    });
    Future<CalendarInvitationReceipt> receive(Uint8List bytes, {String? key}) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(
            key: key ?? const Uuid().v4obj().toString(),
            bytes: bytes,
          ),
        );
    Future<CalendarInvitationReceipt> master({
      bool date = false,
      String? zone,
      int sequence = 1,
      List<String> extra = const [],
    }) => receive(
      invitationBytes(
        date: date,
        zone: zone,
        sequence: sequence,
        extra: ['RRULE:FREQ=DAILY;COUNT=3', ...extra],
      ),
    );
    Future<CalendarInvitationAdoptionReceipt> adopt(
      CalendarInvitationReceipt r,
    ) async {
      final calendar = (await service.create(createInput()))!.calendarId;
      return service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: r.entryId,
          sourceId: r.sourceId,
          expectedRevision: r.entryRevision,
          calendarId: calendar,
          expectedCalendarRevision: 1,
        ),
      );
    }

    for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
      test(
        '$profile keeps original separate from moved timing and master',
        () async {
          final date = profile == 'date',
              zone = profile == 'Europe/Stockholm' ? profile : null;
          final m = await master(date: date, zone: zone);
          final r = await receive(
            rangeInvitationBytes(date: date, zone: zone),
          );
          final v = await service.getInvitation(r.entryId);
          expect(v.isThisAndFuture, isTrue);
          expect(v.originalStart!.start.day, 2);
          expect(v.timing!.start.day, 1);
          expect(v.recurring, isTrue);
          expect((await service.getInvitation(m.entryId)).revision, 1);
          expect(await service.listInvitations(), hasLength(2));
          expect(await CalendarEventRecord.db.count(session), 0);
          final c = await receive(
            rangeInvitationBytes(
              date: date,
              zone: zone,
              cancel: true,
              sequence: 3,
            ),
          );
          expect(c.entryId, r.entryId);
          final cv = await service.getInvitation(c.entryId);
          expect(cv.kind, CalendarInvitationSourceKind.rangeCancellation);
          expect(cv.timing, isNull);
          expect(cv.originalStart, v.originalStart);
        },
      );
    }
    test('unknown series rejects without queue creation', () async {
      await expectLater(
        receive(rangeInvitationBytes()),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarInvitationRecord.db.count(session), 0);
    });
    test('non-recurring known series rejects', () async {
      await receive(invitationBytes());
      await expectLater(
        receive(rangeInvitationBytes()),
        failure(CalendarFailureCode.validation),
      );
    });
    test(
      'excluded original rejects while earlier and PERIOD additions admit',
      () async {
        await master(
          extra: [
            'EXDATE:20300102T090000Z',
            'RDATE:20291230T090000Z',
            'RDATE;VALUE=PERIOD:20300105T090000Z/PT2H',
          ],
        );
        await expectLater(
          receive(rangeInvitationBytes()),
          failure(CalendarFailureCode.validation),
        );
        for (final original in ['20291230T090000Z', '20300105T090000Z']) {
          await receive(rangeInvitationBytes(original: original));
        }
        expect(await CalendarInvitationRecord.db.count(session), 3);
      },
    );
    test(
      'moved start does not substitute for missing original membership',
      () async {
        await master();
        await expectLater(
          receive(rangeInvitationBytes(original: '20300104T090000Z')),
          failure(CalendarFailureCode.validation),
        );
      },
    );
    test(
      'first cancellation advances parent floor and creates no stale entry',
      () async {
        await master(sequence: 5);
        await expectLater(
          receive(rangeInvitationBytes(cancel: true, sequence: 5)),
          failure(CalendarFailureCode.staleRevision),
        );
        expect(await CalendarInvitationRecord.db.count(session), 1);
        await receive(rangeInvitationBytes(cancel: true, sequence: 6));
      },
    );
    test(
      'own sequence ordering does not borrow newer master or sibling floor',
      () async {
        await master();
        final r = await receive(rangeInvitationBytes());
        await master(sequence: 20);
        final c = await receive(
          rangeInvitationBytes(cancel: true, sequence: 3),
        );
        expect(c.entryId, r.entryId);
        expect(c.outcome, CalendarInvitationOutcome.selected);
        final sibling = await receive(
          rangeInvitationBytes(original: '20300103T090000Z', sequence: 30),
        );
        expect(sibling.entryId, isNot(r.entryId));
        final stale = await receive(rangeInvitationBytes(sequence: 2));
        expect(stale.outcome, CalendarInvitationOutcome.duplicate);
      },
    );
    test(
      'independent occurrence gate denies and final denial rolls back',
      () async {
        await master();
        host.denied.add(CalendarInvitationOperation.receiveRange);
        await expectLater(
          receive(rangeInvitationBytes()),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        host.denyFinal = true;
        await expectLater(
          receive(rangeInvitationBytes()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationRecord.db.count(session), 1);
        expect(await CalendarInvitationSourceRecord.db.count(session), 1);
      },
    );
    test(
      'host sees complete immutable retained-master evidence at final check',
      () async {
        await master();
        var checked = false;
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.receiveRange &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            checked = true;
            expect(
              c.occurrenceBasis!.kind,
              CalendarInvitationOccurrenceBasisKind.retainedMaster,
            );
            expect(c.occurrenceBasis!.master!.originalStart, isNull);
            expect(c.occurrenceBasis!.message, isNotNull);
            expect(c.occurrenceBasis!.originalStart.start.day, 2);
            expect(c.proposedOutcome, CalendarInvitationOutcome.selected);
          }
        };
        await receive(rangeInvitationBytes());
        expect(checked, isTrue);
      },
    );
    test('retained exact retry survives parent pattern removal and master cancellation', () async {
      await master();
      final bytes = rangeInvitationBytes();
      final r = await receive(bytes, key: 'retained');
      await receive(
        invitationBytes(sequence: 10, extra: ['RRULE:FREQ=WEEKLY;COUNT=3']),
      );
      expect((await receive(bytes, key: 'retained')).id, r.id);
      await expectLater(
        receive(bytes),
        failure(CalendarFailureCode.validation),
      );
      final cancel = utf8
          .decode(invitationBytes(sequence: 11))
          .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL')
          .replaceFirst(
            'BEGIN:VEVENT\r\n',
            'BEGIN:VEVENT\r\nSTATUS:CANCELLED\r\n',
          );
      await receive(Uint8List.fromList(utf8.encode(cancel)));
      expect((await receive(bytes, key: 'retained')).id, r.id);
      await expectLater(
        receive(bytes),
        failure(CalendarFailureCode.validation),
      );
    });
    test(
      'instance notices cannot use master link or application fallback',
      () async {
        await adopt(await master());
        final r = await receive(rangeInvitationBytes());
        await expectLater(
          service.invitationLink(r.entryId),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(
          service.invitationApplication(r.entryId),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(adopt(r), failure(CalendarFailureCode.validation));
        expect(await CalendarEventRecord.db.count(session), 1);
      },
    );
    test(
      'source review and dismissal remain independent of native state',
      () async {
        await master();
        final r = await receive(rangeInvitationBytes());
        expect(await service.invitationSources(r.entryId), hasLength(1));
        await service.dismissInvitation(r.entryId, r.entryRevision);
        expect(await service.listInvitations(), hasLength(1));
        expect(await CalendarEventRecord.db.count(session), 0);
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      },
    );
    test('tampered typed target fails closed before reading body', () async {
      await master();
      final r = await receive(rangeInvitationBytes());
      final row = (await CalendarInvitationRecord.db.findById(
        session,
        r.entryId,
      ))!;
      row.targetKey = 'range-v1:wrong';
      await CalendarInvitationRecord.db.updateRow(session, row);
      await expectLater(
        service.getInvitation(r.entryId),
        failure(CalendarFailureCode.unavailable),
      );
    });
    Future<void> pruneMaster(UuidValue id) async {
      final entry = (await CalendarInvitationRecord.db.findById(session, id))!;
      entry.dismissedAt = DateTime.utc(2020);
      await CalendarInvitationRecord.db.updateRow(session, entry);
      final sources = await CalendarInvitationSourceRecord.db.find(
        session,
        where: (t) => t.entryId.equals(id),
      );
      for (final row in sources) {
        row.inactiveAt = DateTime.utc(2020);
        await CalendarInvitationSourceRecord.db.updateRow(session, row);
      }
      for (final row in await CalendarInvitationReceiptRecord.db.find(
        session,
      )) {
        if (!sources.any((s) => s.id == row.sourceId)) continue;
        row.expiresAt = DateTime.utc(2020);
        await CalendarInvitationReceiptRecord.db.updateRow(session, row);
      }
      await service.listInvitations();
      expect(await CalendarInvitationRecord.db.findById(session, id), isNull);
    }

    test(
      'accepted baseline survives queue expiry and differs from local draft',
      () async {
        final m = await master();
        final link = await adopt(m);
        final data = (await CalendarEventDataRecord.db.find(session)).single;
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: link.eventId,
            expectedRevision: 1,
            content: data.content.copyWith(recurrence: null),
          ),
        );
        await pruneMaster(m.entryId);
        var sawBaseline = false;
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.receiveRange &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            sawBaseline = true;
            expect(
              c.occurrenceBasis!.kind,
              CalendarInvitationOccurrenceBasisKind.acceptedBaseline,
            );
            expect(c.occurrenceBasis!.message, isNull);
            expect(c.occurrenceBasis!.accepted, isNotNull);
            expect(c.occurrenceBasis!.content.recurrence, isNotNull);
          }
        };
        await receive(rangeInvitationBytes());
        expect(sawBaseline, isTrue);
      },
    );
    test(
      'current retained master takes precedence over accepted pattern',
      () async {
        final m = await master();
        await adopt(m);
        await receive(
          invitationBytes(sequence: 5, extra: ['RRULE:FREQ=WEEKLY;COUNT=3']),
        );
        await expectLater(
          receive(rangeInvitationBytes()),
          failure(CalendarFailureCode.validation),
        );
      },
    );
    test(
      'baseline corruption fails unavailable without inventing series evidence',
      () async {
        final m = await master();
        await adopt(m);
        await pruneMaster(m.entryId);
        final row = (await CalendarEventDataRecord.db.find(session)).single;
        row.importBaseline = row.importBaseline!.copyWith(canonicalValue: '{}');
        await CalendarEventDataRecord.db.updateRow(session, row);
        await expectLater(
          receive(rangeInvitationBytes()),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test(
      'historical receipt and review survive complete parent queue removal',
      () async {
        final m = await master();
        final bytes = rangeInvitationBytes();
        final r = await receive(bytes, key: 'historical');
        await pruneMaster(m.entryId);
        expect((await receive(bytes, key: 'historical')).id, r.id);
        expect(
          (await service.getInvitation(r.entryId)).originalStart!.start.day,
          2,
        );
        await expectLater(
          receive(bytes),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.add(CalendarInvitationOperation.receiveRange);
        await expectLater(
          receive(bytes, key: 'historical'),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test(
      'retained receipt key cannot change occurrence identity or origin',
      () async {
        await master();
        await receive(rangeInvitationBytes(), key: 'bound');
        await expectLater(
          receive(
            rangeInvitationBytes(original: '20300103T090000Z'),
            key: 'bound',
          ),
          failure(CalendarFailureCode.validation),
        );
      },
    );
    test(
      'master checkpoint rejects the new instance-only source kind',
      () async {
        final m = await master();
        await adopt(m);
        final update = await master(sequence: 2);
        final view = await service.invitationApplication(update.entryId);
        await service.applyInvitationUpdate(
          CalendarInvitationApplyRequest(
            invitationId: update.entryId,
            sourceId: update.sourceId,
            expectedInvitationRevision: view.invitationRevision!,
            linkId: view.linkId,
            expectedEventRevision: view.eventRevision,
            expectedCalendarRevision: view.calendarRevision,
            expectedApplicationRevision: view.applicationRevision,
          ),
        );
        final row = (await CalendarInvitationApplicationRecord.db.find(session))
            .single;
        row.kind = CalendarInvitationSourceKind.rangeCancellation;
        await CalendarInvitationApplicationRecord.db.updateRow(session, row);
        await expectLater(
          service.invitationApplication(update.entryId),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    for (final linked in [false, true]) {
      test(
        'duration-only cancellation remains review-only; linked=$linked',
        () async {
          final m = await master();
          if (linked) await adopt(m);
          final before = jsonEncode(
            (await CalendarEventDataRecord.db.find(session))
                .map((v) => v.toJson())
                .toList(),
          );
          final r = await receive(
            rangeInvitationBytes(cancel: true, extra: ['DURATION:PT1H']),
          );
          final view = await service.getInvitation(r.entryId);
          expect(view.kind, CalendarInvitationSourceKind.rangeCancellation);
          expect(view.timing, isNull);
          final document = await service.invitationSource(
            r.entryId,
            r.sourceId,
          );
          expect(document.text, contains('DURATION:PT1H'));
          expect(document.text, isNot(contains('DTSTART:')));
          expect(
            jsonEncode(
              (await CalendarEventDataRecord.db.find(session))
                  .map((v) => v.toJson())
                  .toList(),
            ),
            before,
          );
          expect(
            await CalendarInvitationApplicationRecord.db.count(session),
            0,
          );
          expect(await CalendarInvitationResponseRecord.db.count(session), 0);
        },
      );
    }

    test(
      'single/range same anchor and different range anchors are independent',
      () async {
        final m = await master();
        final range = await receive(rangeInvitationBytes(sequence: 20));
        final singleBytes = Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(rangeInvitationBytes())
                .replaceAll(';RANGE=THISANDFUTURE', ''),
          ),
        );
        final single = await receive(singleBytes);
        final other = await receive(
          rangeInvitationBytes(original: '20300103T090000Z'),
        );
        expect({
          m.entryId,
          range.entryId,
          single.entryId,
          other.entryId,
        }, hasLength(4));
        final sv = await service.getInvitation(single.entryId);
        expect(sv.isThisAndFuture, isFalse);
        expect(
          sv.originalStart,
          (await service.getInvitation(range.entryId)).originalStart,
        );
        await receive(rangeInvitationBytes(cancel: true, sequence: 21));
        expect((await service.getInvitation(single.entryId)).revision, 1);
        expect((await service.getInvitation(other.entryId)).revision, 1);
        expect((await service.getInvitation(m.entryId)).revision, 1);
        expect(await CalendarEventRecord.db.count(session), 0);
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      },
    );
    test(
      'range gate is independent of single gate and final gate rolls back',
      () async {
        await master();
        host.denied.add(CalendarInvitationOperation.receiveOccurrence);
        await receive(rangeInvitationBytes());
        host.denied.clear();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.receiveRange &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            expect(c.message!.events.single.isThisAndFuture, isTrue);
            expect(c.occurrenceBasis, isNotNull);
            host.denied.add(CalendarInvitationOperation.receiveRange);
          }
        };
        await expectLater(
          receive(rangeInvitationBytes(sequence: 3)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationSourceRecord.db.count(session), 2);
        expect(await CalendarInvitationReceiptRecord.db.count(session), 2);
      },
    );
    test(
      'every calendar and personal response action rejects before fallback',
      () async {
        final link = await adopt(await master());
        final r = await receive(rangeInvitationBytes());
        final apply = CalendarInvitationApplyRequest(
          invitationId: r.entryId,
          sourceId: r.sourceId,
          expectedInvitationRevision: r.entryRevision,
          linkId: link.id,
          expectedEventRevision: 1,
          expectedCalendarRevision: 1,
          expectedApplicationRevision: 0,
        );
        final occurrence = CalendarInvitationOccurrenceApplyRequest(
          invitationId: r.entryId,
          sourceId: r.sourceId,
          linkId: link.id,
          expectedInvitationRevision: r.entryRevision,
          expectedEventRevision: 1,
          expectedCalendarRevision: 1,
          expectedApplicationRevision: 0,
          expectedOccurrenceRevision: 0,
        );
        for (final call in <Future<Object?> Function()>[
          () => service.invitationLink(r.entryId),
          () => service.invitationApplication(r.entryId),
          () => adopt(r),
          () => service.applyInvitationUpdate(apply),
          () => service.applyInvitationCancellation(apply),
          () => service.invitationOccurrenceApplication(r.entryId),
          () => service.applyInvitationOccurrenceUpdate(occurrence),
          () => service.applyInvitationOccurrenceCancellation(occurrence),
          () => service.invitationResponse(r.entryId),
          () => service.invitationResponseActivity(r.entryId),
          () => service.sendInvitationResponse(
            CalendarInvitationResponseRequest(
              invitationId: r.entryId,
              sourceId: r.sourceId,
              expectedInvitationRevision: r.entryRevision,
              expectedResponseRevision: 0,
              commandId: const Uuid().v4obj(),
              choice: CalendarInvitationResponseChoice.accepted,
            ),
          ),
        ]) {
          await expectLater(call(), failure(CalendarFailureCode.validation));
        }
        expect(await CalendarEventRecord.db.count(session), 1);
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
      },
    );
    for (final historical in [false, true]) {
      test(
        'source RANGE cannot be dropped despite valid hashes; historical=$historical',
        () async {
          await master();
          final r = await receive(rangeInvitationBytes());
          if (historical) await receive(rangeInvitationBytes(sequence: 3));
          final source = (await CalendarInvitationSourceRecord.db.findById(
            session,
            r.sourceId,
          ))!;
          source.normalizedSource = source.normalizedSource.replaceAll(
            ';RANGE=THISANDFUTURE',
            '',
          );
          source.byteCount = utf8.encode(source.normalizedSource).length;
          source.digest = sha256
              .convert(utf8.encode(source.normalizedSource))
              .toString();
          await CalendarInvitationSourceRecord.db.updateRow(session, source);
          if (!historical) {
            final entry = (await CalendarInvitationRecord.db.findById(
              session,
              r.entryId,
            ))!;
            entry.digest = source.digest;
            await CalendarInvitationRecord.db.updateRow(session, entry);
          }
          await expectLater(
            service.invitationSource(r.entryId, r.sourceId),
            failure(CalendarFailureCode.unavailable),
          );
        },
      );
    }
    test(
      'range keys cannot masquerade as an unknown target namespace',
      () async {
        await master();
        final r = await receive(rangeInvitationBytes());
        final row = (await CalendarInvitationRecord.db.findById(
          session,
          r.entryId,
        ))!;
        row.targetKey = row.targetKey.replaceFirst('range-v1:', 'range-v2:');
        await CalendarInvitationRecord.db.updateRow(session, row);
        await expectLater(
          service.getInvitation(r.entryId),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test(
      'range source quota is shared and rejection leaves no target',
      () async {
        await master();
        CalendarModule.install(
          session.serverpod,
          policy: TestPolicy(),
          options: CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          ),
          invitations: CalendarInvitationRuntime(
            host: host,
            options: CalendarInvitationOptions(maxPending: 1),
          ),
        );
        await expectLater(
          receive(rangeInvitationBytes()),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await CalendarInvitationRecord.db.count(session), 1);
      },
    );
    test(
      'source denial hides target type on response APIs before history lookup',
      () async {
        await master();
        final r = await receive(rangeInvitationBytes());
        host.denied.add(CalendarInvitationOperation.readSource);
        for (final call in <Future<Object?> Function()>[
          () => service.invitationResponse(r.entryId),
          () => service.invitationResponseActivity(r.entryId),
          () => service.sendInvitationResponse(
            CalendarInvitationResponseRequest(
              invitationId: r.entryId,
              sourceId: r.sourceId,
              expectedInvitationRevision: r.entryRevision,
              expectedResponseRevision: 0,
              commandId: const Uuid().v4obj(),
              choice: CalendarInvitationResponseChoice.accepted,
            ),
          ),
        ]) {
          await expectLater(call(), failure(CalendarFailureCode.accessDenied));
        }
        expect(
          await CalendarInvitationResponseStateRecord.db.count(session),
          0,
        );
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      },
    );
    test('omitted and explicit zero source sequences stay distinct', () async {
      await master();
      final omitted = Uint8List.fromList(
        utf8.encode(
          utf8
              .decode(rangeInvitationBytes())
              .replaceFirst('SEQUENCE:2\r\n', ''),
        ),
      );
      final r = await receive(omitted);
      expect((await service.getInvitation(r.entryId)).sequence, isNull);
      expect(
        (await service.invitationSource(r.entryId, r.sourceId)).text,
        isNot(contains('SEQUENCE:')),
      );
      final zero = Uint8List.fromList(
        utf8.encode(
          utf8
              .decode(rangeInvitationBytes(sequence: 0))
              .replaceFirst(
                'DTSTAMP:20260101T000000Z',
                'DTSTAMP:20260101T000001Z',
              ),
        ),
      );
      final next = await receive(zero);
      expect(next.entryId, r.entryId);
      expect(next.outcome, CalendarInvitationOutcome.selected);
      expect((await service.getInvitation(r.entryId)).sequence, 0);
      expect(
        (await service.invitationSource(r.entryId, r.sourceId)).text,
        isNot(contains('SEQUENCE:')),
      );
    });
    test('unsupported range token and named profile mismatch reject', () async {
      await master(zone: 'Europe/Stockholm');
      await expectLater(
        receive(rangeInvitationBytes()),
        failure(CalendarFailureCode.validation),
      );
      final invalid = Uint8List.fromList(
        utf8.encode(
          utf8
              .decode(rangeInvitationBytes(zone: 'Europe/Stockholm'))
              .replaceAll('RANGE=THISANDFUTURE', 'RANGE=THISANDPRIOR'),
        ),
      );
      await expectLater(
        receive(invalid),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarInvitationRecord.db.count(session), 1);
    });
    test('candidate exhaustion is explicit and commits no target', () async {
      await receive(invitationBytes(extra: ['RRULE:FREQ=MINUTELY']));
      await expectLater(
        receive(rangeInvitationBytes(original: '20310101T090000Z')),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(await CalendarInvitationRecord.db.count(session), 1);
    });
    test(
      'named-zone original membership crosses DST without UTC retargeting',
      () async {
        final masterText = utf8
            .decode(
              invitationBytes(
                zone: 'Europe/Stockholm',
                extra: ['RRULE:FREQ=DAILY;COUNT=3'],
              ),
            )
            .replaceFirst(
              'DTSTART;TZID=Europe/Stockholm:20300101T090000',
              'DTSTART;TZID=Europe/Stockholm:20300330T090000',
            );
        await receive(Uint8List.fromList(utf8.encode(masterText)));
        final moved = utf8
            .decode(
              rangeInvitationBytes(
                zone: 'Europe/Stockholm',
                original: '20300331T090000',
              ),
            )
            .replaceFirst(
              'DTSTART;TZID=Europe/Stockholm:20300101T090000',
              'DTSTART;TZID=Europe/Stockholm:20300331T110000',
            );
        final r = await receive(Uint8List.fromList(utf8.encode(moved)));
        final v = await service.getInvitation(r.entryId);
        expect(v.originalStart!.start.day, 31);
        expect(v.originalStart!.start.hour, 9);
        expect(v.originalStart!.zoneId, 'Europe/Stockholm');
        expect(v.timing!.start.hour, 11);
      },
    );
    test('recurrence-generated DST gap is not a known original', () async {
      final text = utf8
          .decode(
            invitationBytes(
              zone: 'Europe/Stockholm',
              extra: ['RRULE:FREQ=DAILY;COUNT=3'],
            ),
          )
          .replaceFirst(
            'DTSTART;TZID=Europe/Stockholm:20300101T090000',
            'DTSTART;TZID=Europe/Stockholm:20300330T023000',
          );
      await receive(Uint8List.fromList(utf8.encode(text)));
      await expectLater(
        receive(
          rangeInvitationBytes(
            zone: 'Europe/Stockholm',
            original: '20300331T023000',
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarInvitationRecord.db.count(session), 1);
    });
  });
}
