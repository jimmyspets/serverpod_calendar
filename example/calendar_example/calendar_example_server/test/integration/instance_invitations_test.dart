import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'test_tools/serverpod_test_tools.dart';

Uint8List instanceInvitationBytes({
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
            ? 'RECURRENCE-ID;VALUE=DATE:${original ?? '20300102'}'
            : zone == null
            ? 'RECURRENCE-ID:${original ?? '20300102T090000Z'}'
            : 'RECURRENCE-ID;TZID=$zone:${original ?? '20300102T090000'}',
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
  withServerpod('single-instance invitation review', (builder, endpoints) {
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
            instanceInvitationBytes(date: date, zone: zone),
          );
          final v = await service.getInvitation(r.entryId);
          expect(v.originalStart!.start.day, 2);
          expect(v.timing!.start.day, 1);
          expect(v.recurring, isTrue);
          expect((await service.getInvitation(m.entryId)).revision, 1);
          expect(await service.listInvitations(), hasLength(2));
          expect(await CalendarEventRecord.db.count(session), 0);
          final c = await receive(
            instanceInvitationBytes(
              date: date,
              zone: zone,
              cancel: true,
              sequence: 3,
            ),
          );
          expect(c.entryId, r.entryId);
          final cv = await service.getInvitation(c.entryId);
          expect(cv.kind, CalendarInvitationSourceKind.instanceCancellation);
          expect(cv.timing, isNull);
          expect(cv.originalStart, v.originalStart);
        },
      );
    }
    test('unknown series rejects without queue creation', () async {
      await expectLater(
        receive(instanceInvitationBytes()),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarInvitationRecord.db.count(session), 0);
    });
    test('non-recurring known series rejects', () async {
      await receive(invitationBytes());
      await expectLater(
        receive(instanceInvitationBytes()),
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
          receive(instanceInvitationBytes()),
          failure(CalendarFailureCode.validation),
        );
        for (final original in ['20291230T090000Z', '20300105T090000Z']) {
          await receive(instanceInvitationBytes(original: original));
        }
        expect(await CalendarInvitationRecord.db.count(session), 3);
      },
    );
    test(
      'moved start does not substitute for missing original membership',
      () async {
        await master();
        await expectLater(
          receive(instanceInvitationBytes(original: '20300104T090000Z')),
          failure(CalendarFailureCode.validation),
        );
      },
    );
    test(
      'first cancellation advances parent floor and creates no stale entry',
      () async {
        await master(sequence: 5);
        await expectLater(
          receive(instanceInvitationBytes(cancel: true, sequence: 5)),
          failure(CalendarFailureCode.staleRevision),
        );
        expect(await CalendarInvitationRecord.db.count(session), 1);
        await receive(instanceInvitationBytes(cancel: true, sequence: 6));
      },
    );
    test(
      'own sequence ordering does not borrow newer master or sibling floor',
      () async {
        await master();
        final r = await receive(instanceInvitationBytes());
        await master(sequence: 20);
        final c = await receive(
          instanceInvitationBytes(cancel: true, sequence: 3),
        );
        expect(c.entryId, r.entryId);
        expect(c.outcome, CalendarInvitationOutcome.selected);
        final sibling = await receive(
          instanceInvitationBytes(original: '20300103T090000Z', sequence: 30),
        );
        expect(sibling.entryId, isNot(r.entryId));
        final stale = await receive(instanceInvitationBytes(sequence: 2));
        expect(stale.outcome, CalendarInvitationOutcome.duplicate);
      },
    );
    test(
      'independent occurrence gate denies and final denial rolls back',
      () async {
        await master();
        host.denied.add(CalendarInvitationOperation.receiveOccurrence);
        await expectLater(
          receive(instanceInvitationBytes()),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        host.denyFinal = true;
        await expectLater(
          receive(instanceInvitationBytes()),
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
          if (c.operation == CalendarInvitationOperation.receiveOccurrence &&
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
        await receive(instanceInvitationBytes());
        expect(checked, isTrue);
      },
    );
    test('retained exact retry survives parent pattern removal and master cancellation', () async {
      await master();
      final bytes = instanceInvitationBytes();
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
        final r = await receive(instanceInvitationBytes());
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
        final r = await receive(instanceInvitationBytes());
        expect(await service.invitationSources(r.entryId), hasLength(1));
        await service.dismissInvitation(r.entryId, r.entryRevision);
        expect(await service.listInvitations(), hasLength(1));
        expect(await CalendarEventRecord.db.count(session), 0);
        expect(await CalendarInvitationResponseRecord.db.count(session), 0);
      },
    );
    test('tampered typed target fails closed before reading body', () async {
      await master();
      final r = await receive(instanceInvitationBytes());
      final row = (await CalendarInvitationRecord.db.findById(
        session,
        r.entryId,
      ))!;
      row.targetKey = 'instance-v1:wrong';
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
          if (c.operation == CalendarInvitationOperation.receiveOccurrence &&
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
        await receive(instanceInvitationBytes());
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
          receive(instanceInvitationBytes()),
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
          receive(instanceInvitationBytes()),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test(
      'historical receipt and review survive complete parent queue removal',
      () async {
        final m = await master();
        final bytes = instanceInvitationBytes();
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
        host.denied.add(CalendarInvitationOperation.receiveOccurrence);
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
        await receive(instanceInvitationBytes(), key: 'bound');
        await expectLater(
          receive(
            instanceInvitationBytes(original: '20300103T090000Z'),
            key: 'bound',
          ),
          failure(CalendarFailureCode.validation),
        );
      },
    );
    test('profile mismatch and future range reject explicitly', () async {
      await master(zone: 'Europe/Stockholm');
      await expectLater(
        receive(instanceInvitationBytes()),
        failure(CalendarFailureCode.validation),
      );
      final text = utf8
          .decode(instanceInvitationBytes(zone: 'Europe/Stockholm'))
          .replaceFirst(
            'RECURRENCE-ID;TZID=',
            'RECURRENCE-ID;RANGE=THISANDFUTURE;TZID=',
          );
      await expectLater(
        receive(Uint8List.fromList(utf8.encode(text))),
        failure(CalendarFailureCode.validation),
      );
    });
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
        row.kind = CalendarInvitationSourceKind.instanceCancellation;
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
            instanceInvitationBytes(cancel: true, extra: ['DURATION:PT1H']),
          );
          final view = await service.getInvitation(r.entryId);
          expect(view.kind, CalendarInvitationSourceKind.instanceCancellation);
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
    test('candidate exhaustion is explicit and commits no target', () async {
      await receive(invitationBytes(extra: ['RRULE:FREQ=MINUTELY']));
      await expectLater(
        receive(instanceInvitationBytes(original: '20310101T090000Z')),
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
              instanceInvitationBytes(
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
          instanceInvitationBytes(
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
