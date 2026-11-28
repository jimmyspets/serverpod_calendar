import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'test_tools/serverpod_test_tools.dart';

Uint8List cancellationBytes({
  int sequence = 1,
  String stamp = '20260102T000000Z',
  String uid = 'meeting',
  bool status = true,
  bool attendee = true,
  List<String> extra = const [],
}) => Uint8List.fromList(
  utf8.encode(
    [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic//EN',
      'METHOD:CANCEL',
      'BEGIN:VEVENT',
      'UID:$uid',
      'DTSTAMP:$stamp',
      'SEQUENCE:$sequence',
      if (status) 'STATUS:CANCELLED',
      'ORGANIZER:mailto:organizer@example.invalid',
      if (attendee) 'ATTENDEE:mailto:alice@example.invalid',
      ...extra,
      'END:VEVENT',
      'END:VCALENDAR',
      '',
    ].join('\r\n'),
  ),
);

void main() {
  withServerpod('trusted cancellation intake and review', (builder, endpoints) {
    late Session session;
    late InvitationTestHost host;
    late CalendarService service;
    late CalendarInvitationReceipt original;
    CalendarInvitationAdoptionReceipt? link;
    CalendarInvitationAdoptionRequest? creation;
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
      link = null;
      creation = null;
    });
    Future<CalendarInvitationReceipt> receive(Uint8List bytes) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(
            key: const Uuid().v4obj().toString(),
            bytes: bytes,
          ),
        );
    Future<void> seed({bool adopt = false, int? sequence}) async {
      original = await receive(invitationBytes(sequence: sequence));
      if (adopt) {
        final calendar = (await service.create(createInput()))!;
        creation = CalendarInvitationAdoptionRequest(
          invitationId: original.entryId,
          sourceId: original.sourceId,
          expectedRevision: 1,
          calendarId: calendar.calendarId,
          expectedCalendarRevision: 1,
        );
        link = await service.adoptInvitation(creation!);
      }
    }

    Future<void> expire() async {
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation_receipt SET "expiresAt"=now()-interval \'40 days\'',
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation_source SET "inactiveAt"=now()-interval \'40 days\'',
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation SET "dismissedAt"=now()-interval \'40 days\'',
      );
      await service.listInvitations();
    }

    test('minimal cancellation retains omissions and makes no native or worker state', () async {
      await seed();
      final result = await receive(cancellationBytes());
      expect(result.outcome, CalendarInvitationOutcome.selected);
      final view = await service.getInvitation(original.entryId);
      expect(view.kind, CalendarInvitationSourceKind.meetingCancellation);
      expect(view.summary, isNull);
      expect(view.timing, isNull);
      expect(view.revision, 2);
      expect(view.dismissedAt, isNull);
      final source = await service.invitationSource(view.id, result.sourceId);
      expect(source.kind, CalendarInvitationSourceKind.meetingCancellation);
      expect(source.text, contains('METHOD:CANCEL'));
      expect(source.text, isNot(contains('DTSTART')));
      expect(await CalendarEventRecord.db.count(session), 0);
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
      expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      await service.dismissInvitation(view.id, view.revision);
      expect(await service.listInvitations(), isEmpty);
    });
    test(
      'unknown correlation and recipient mismatch reject without rows',
      () async {
        await expectLater(
          receive(cancellationBytes()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationRecord.db.count(session), 0);
        await seed();
        await expectLater(
          receive(cancellationBytes(uid: 'unknown')),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          receive(cancellationBytes(attendee: false)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarInvitationSourceRecord.db.count(session), 1);
      },
    );
    test(
      'attendee removal recurrence and delegated authority reject explicitly',
      () async {
        await seed();
        for (final bytes in [
          cancellationBytes(status: false),
          cancellationBytes(
            extra: ['DTSTART:20300101T090000Z', 'RRULE:FREQ=DAILY;COUNT=2'],
          ),
          cancellationBytes(extra: ['RECURRENCE-ID:20300101T090000Z']),
          Uint8List.fromList(
            utf8.encode(
              utf8
                  .decode(cancellationBytes())
                  .replaceFirst(
                    'ORGANIZER:',
                    'ORGANIZER;SENT-BY="mailto:delegate@example.invalid":',
                  ),
            ),
          ),
        ]) {
          await expectLater(
            receive(bytes),
            failure(CalendarFailureCode.validation),
          );
        }
        expect(await CalendarInvitationSourceRecord.db.count(session), 1);
      },
    );
    test(
      'both receive permissions and final denial preserve atomic state',
      () async {
        await seed();
        for (final op in [
          CalendarInvitationOperation.receive,
          CalendarInvitationOperation.receiveCancellation,
        ]) {
          host.denied.add(op);
          await expectLater(
            receive(cancellationBytes()),
            failure(CalendarFailureCode.accessDenied),
          );
          host.denied.clear();
        }
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.receiveCancellation &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            expect(c.current!.kind, CalendarInvitationSourceKind.request);
            expect(c.message!.method.name, 'cancel');
            host.denied.add(c.operation);
          }
        };
        await expectLater(
          receive(cancellationBytes()),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        host.onAuthorize = null;
        expect(await CalendarInvitationSourceRecord.db.count(session), 1);
        expect((await service.getInvitation(original.entryId)).revision, 1);
      },
    );
    test(
      'cancellation must increase known REQUEST sequence not only its stamp',
      () async {
        await seed(sequence: 4);
        final stale = await receive(
          cancellationBytes(sequence: 4, stamp: '20270101T000000Z'),
        );
        expect(stale.outcome, CalendarInvitationOutcome.stale);
        expect(
          (await service.getInvitation(original.entryId)).kind,
          CalendarInvitationSourceKind.request,
        );
        final newer = await receive(
          cancellationBytes(sequence: 5, stamp: '20200101T000000Z'),
        );
        expect(newer.outcome, CalendarInvitationOutcome.selected);
      },
    );
    test(
      'historical REQUEST and current CANCEL keep independent kinds',
      () async {
        await seed();
        final cancel = await receive(cancellationBytes());
        final sources = await service.invitationSources(original.entryId);
        expect(
          sources.singleWhere((s) => s.id == original.sourceId).kind,
          CalendarInvitationSourceKind.request,
        );
        expect(
          sources.singleWhere((s) => s.id == cancel.sourceId).kind,
          CalendarInvitationSourceKind.meetingCancellation,
        );
        expect(
          (await service.invitationSource(
            original.entryId,
            original.sourceId,
          )).text,
          contains('METHOD:REQUEST'),
        );
        expect(
          (await service.invitationSource(
            original.entryId,
            cancel.sourceId,
          )).text,
          contains('STATUS:CANCELLED'),
        );
      },
    );
    test(
      'exact and equivalent cancellation retries never dismiss newer REQUEST',
      () async {
        await seed();
        final bytes = cancellationBytes();
        final delivery = invitationDelivery(
          key: 'stable-cancellation',
          bytes: bytes,
        );
        final first = await CalendarModule.receiveSchedulingInvitation(
          session,
          delivery,
        );
        await service.dismissInvitation(first.entryId, first.entryRevision);
        final newer = await receive(invitationBytes(sequence: 2));
        expect(
          (await CalendarModule.receiveSchedulingInvitation(
            session,
            delivery,
          )).id,
          first.id,
        );
        expect(
          (await receive(bytes)).outcome,
          CalendarInvitationOutcome.duplicate,
        );
        final view = await service.getInvitation(first.entryId);
        expect(view.sourceId, newer.sourceId);
        expect(view.dismissedAt, isNull);
        expect(view.kind, CalendarInvitationSourceKind.request);
      },
    );
    test('unlinked cancellation cannot become a new native event', () async {
      await seed();
      final cancel = await receive(cancellationBytes());
      final parent = (await service.create(createInput()))!;
      await expectLater(
        service.adoptInvitation(
          CalendarInvitationAdoptionRequest(
            invitationId: cancel.entryId,
            sourceId: cancel.sourceId,
            expectedRevision: cancel.entryRevision,
            calendarId: parent.calendarId,
            expectedCalendarRevision: 1,
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarEventRecord.db.count(session), 0);
    });
    test(
      'linked review preserves draft baseline checkpoint and generation',
      () async {
        await seed(adopt: true);
        final before = (await CalendarEventDataRecord.db.find(session)).single;
        final beforeJson = jsonEncode(before.toJson());
        final scope = (await CalendarScopeRecord.db.find(session)).single;
        var saw = false;
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.receiveCancellation &&
              c.link != null) {
            expect(c.actor, isNull);
            expect(c.link!.id, link!.id);
            expect(c.linkSource!.sourceId, original.sourceId);
            expect(c.currentEvent!.eventId, link!.eventId);
            expect(c.currentApplication!.revision, 0);
            expect(c.linkedEventUnavailable, isFalse);
            saw = true;
          }
        };
        final cancel = await receive(cancellationBytes());
        expect(saw, isTrue);
        expect(
          jsonEncode(
            (await CalendarEventDataRecord.db.find(session)).single.toJson(),
          ),
          beforeJson,
        );
        expect(
          (await CalendarScopeRecord.db.find(session)).single.revision,
          scope.revision,
        );
        expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
        final view = await service.invitationApplication(cancel.entryId);
        expect(
          view.incomingKind,
          CalendarInvitationSourceKind.meetingCancellation,
        );
        expect(view.incomingContent, isNull);
        expect(view.canApply, isFalse);
        expect(view.incomingSourceText, contains('METHOD:CANCEL'));
        expect((await service.adoptInvitation(creation!)).id, link!.id);
        await expectLater(
          service.applyInvitationUpdate(
            CalendarInvitationApplyRequest(
              invitationId: cancel.entryId,
              sourceId: cancel.sourceId,
              expectedInvitationRevision: cancel.entryRevision,
              linkId: link!.id,
              expectedEventRevision: 1,
              expectedCalendarRevision: 1,
              expectedApplicationRevision: 0,
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
      },
    );
    test(
      'stable link supplies accepted floor after complete queue expiry',
      () async {
        await seed(adopt: true, sequence: 4);
        await expire();
        expect(await CalendarInvitationRecord.db.count(session), 0);
        await expectLater(
          receive(cancellationBytes(sequence: 4)),
          failure(CalendarFailureCode.staleRevision),
        );
        expect(await CalendarInvitationRecord.db.count(session), 0);
        final result = await receive(cancellationBytes(sequence: 5));
        expect(result.entryId, isNot(original.entryId));
        expect((await service.invitationLink(result.entryId))!.id, link!.id);
      },
    );
    test(
      'deleted linked payload fails unavailable and cannot recreate it',
      () async {
        await seed(adopt: true);
        await service.deleteEvent(link!.eventId, 1);
        var unavailable = false;
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.receiveCancellation &&
              c.linkedEventUnavailable == true) {
            expect(c.link!.id, link!.id);
            expect(c.currentEvent, isNull);
            unavailable = true;
          }
        };
        await expectLater(
          receive(cancellationBytes()),
          failure(CalendarFailureCode.unavailable),
        );
        expect(unavailable, isTrue);
        expect(await CalendarEventDataRecord.db.count(session), 0);
        expect(await CalendarInvitationSourceRecord.db.count(session), 1);
      },
    );
    test('current source kind corruption fails closed', () async {
      await seed();
      await receive(cancellationBytes());
      final row = (await CalendarInvitationRecord.db.find(session)).single;
      row.kind = CalendarInvitationSourceKind.request;
      await CalendarInvitationRecord.db.updateRow(session, row);
      await expectLater(
        service.getInvitation(row.id!),
        failure(CalendarFailureCode.unavailable),
      );
    });
    test('private summary and source permissions remain independent', () async {
      await seed();
      final cancel = await receive(cancellationBytes());
      host.denied.add(CalendarInvitationOperation.readSource);
      expect(
        (await service.getInvitation(cancel.entryId)).kind,
        CalendarInvitationSourceKind.meetingCancellation,
      );
      await expectLater(
        service.invitationSource(cancel.entryId, cancel.sourceId),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denied.clear();
      host.denied.add(CalendarInvitationOperation.readSummary);
      expect(await service.listInvitations(), isEmpty);
      await expectLater(
        service.getInvitation(cancel.entryId),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('later REQUEST is review only after cancellation notice', () async {
      await seed(adopt: true);
      await receive(cancellationBytes());
      final next = await receive(
        invitationBytes(sequence: 2, summary: 'Reopened source'),
      );
      final view = await service.invitationApplication(next.entryId);
      expect(view.canApply, isTrue);
      expect(view.currentContent.summary, 'Review');
      expect(view.incomingContent!.summary, 'Reopened source');
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
    });

    test('accepted update checkpoint and latest retry remain REQUEST after cancellation', () async {
      await seed(adopt: true);
      final incoming = await receive(invitationBytes(sequence: 4));
      final before = await service.invitationApplication(incoming.entryId);
      final input = CalendarInvitationApplyRequest(
        invitationId: incoming.entryId,
        sourceId: incoming.sourceId,
        expectedInvitationRevision: before.invitationRevision!,
        linkId: link!.id,
        expectedEventRevision: before.eventRevision,
        expectedCalendarRevision: before.calendarRevision,
        expectedApplicationRevision: 0,
      );
      final receipt = await service.applyInvitationUpdate(input);
      final checkpoint = (await CalendarInvitationApplicationRecord.db.find(
        session,
      )).single.toJson();
      await expire();
      await expectLater(
        receive(cancellationBytes(sequence: 3)),
        failure(CalendarFailureCode.staleRevision),
      );
      final cancel = await receive(cancellationBytes(sequence: 5));
      expect((await service.applyInvitationUpdate(input)).id, receipt.id);
      expect((await service.adoptInvitation(creation!)).id, link!.id);
      expect((await service.getInvitation(cancel.entryId)).dismissedAt, isNull);
      expect(
        (await CalendarInvitationApplicationRecord.db.find(session)).single
            .toJson(),
        checkpoint,
      );
    });
    test(
      'pruned cancellation marker retains kind without reconstructing a body',
      () async {
        await seed();
        final cancel = await receive(cancellationBytes());
        await service.dismissInvitation(cancel.entryId, cancel.entryRevision);
        await session.db.unsafeExecute(
          'UPDATE serverpod_calendar_invitation_receipt SET "expiresAt"=now()-interval \'40 days\'',
        );
        await session.db.unsafeExecute(
          'UPDATE serverpod_calendar_invitation_source SET "inactiveAt"=now()-interval \'40 days\'',
        );
        await service.listInvitations();
        final view = await service.getInvitation(cancel.entryId);
        expect(view.kind, CalendarInvitationSourceKind.meetingCancellation);
        expect(view.sourceId, isNull);
        expect(view.summary, isNull);
        expect(view.timing, isNull);
        await expectLater(
          receive(cancellationBytes()),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    test(
      'end-only cancellation remains raw source with no manufactured start',
      () async {
        await seed();
        final cancel = await receive(
          cancellationBytes(extra: ['DTEND:20300101T100000Z']),
        );
        expect((await service.getInvitation(cancel.entryId)).timing, isNull);
        expect(
          (await service.invitationSource(
            cancel.entryId,
            cancel.sourceId,
          )).text,
          contains('DTEND:20300101T100000Z'),
        );
      },
    );
    test(
      'personal alarms and existing local drafts survive cancellation review',
      () async {
        await seed(adopt: true);
        final alarm = (await service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: CalendarAlarmParent(
              kind: CalendarAlarmParentKind.event,
              id: link!.eventId,
            ),
            definition: CalendarAlarmDefinition(
              absoluteUtc: DateTime.utc(2030),
            ),
          ),
        ))!;
        final alarmBefore = (await CalendarAlarmRecord.db.findById(
          session,
          alarm.id,
        ))!.toJson();
        final row = (await CalendarEventDataRecord.db.find(session)).single;
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: link!.eventId,
            expectedRevision: 1,
            content: row.content.copyWith(summary: 'Private local draft'),
          ),
        );
        await receive(cancellationBytes());
        final view = await service.invitationApplication(original.entryId);
        expect(view.hasLocalChanges, isTrue);
        expect(view.currentContent.summary, 'Private local draft');
        expect(
          (await CalendarAlarmRecord.db.findById(session, alarm.id))!.toJson(),
          alarmBefore,
        );
        expect(await CalendarAlarmFiringRecord.db.count(session), 0);
      },
    );
  });
}
