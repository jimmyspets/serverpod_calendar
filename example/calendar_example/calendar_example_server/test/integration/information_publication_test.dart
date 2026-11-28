import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, eventInput, failure;
import 'scheduling_test.dart' show SchedulingHost, SchedulingTransport;
import 'scheduling_replies_test.dart' show ReplyHost;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('native information publication', (builder, endpoints) {
    late Session session;
    late CalendarService service;
    late TestPolicy policy;
    late SchedulingHost host;
    late SchedulingTransport transport;
    late UuidValue parent, event;
    void install({CalendarSchedulingOptions? options}) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        scheduling: CalendarSchedulingRuntime(
          host: host,
          transport: transport,
          options: options,
          replies: CalendarSchedulingReplyRuntime(host: ReplyHost()),
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
      host = SchedulingHost();
      transport = SchedulingTransport();
      install();
      parent = (await service.create(createInput()))!.calendarId;
      event = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Native title'),
        ),
      ))!.eventId;
    });
    CalendarSchedulingSaveRequest save({
      int revision = 1,
      String? summary = 'Published title',
    }) => CalendarSchedulingSaveRequest(
      eventId: event,
      expectedRevision: revision,
      commandId: const Uuid().v4obj(),
      content: eventInput(summary: summary),
      recipients: ['mailto:bob@example.invalid'],
    );
    Future<CalendarSchedulingPublicationRecord> publication(
      UuidValue id,
    ) async =>
        (await CalendarSchedulingPublicationRecord.db.findById(session, id))!;
    Future<CalendarEventView> current() =>
        service.getEvent(event, CalendarEventFieldGroup.values);
    test('PUBLISH has routing recipients without attendees and separate native source claims', () async {
      final result = await service.saveAndPublishInformation(save());
      final record = await publication(result.publicationId);
      final parsed = parseIcalendarSchedulingMessage(
        utf8.encode(record.payload),
      );
      expect(parsed.method, IcalendarSchedulingMethod.publish);
      expect(parsed.events.single.participants.attendees, isEmpty);
      expect(record.recipients, ['mailto:bob@example.invalid']);
      expect(
        (await CalendarSchedulingMeetingRecord.db.find(session)).single.purpose,
        CalendarSchedulingBindingPurpose.informationPublication,
      );
      expect(
        (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(event),
        ))!.protocolState!.sourceMetadata?.organizer,
        isNull,
      );
      final status = await service.informationPublicationStatus(event);
      expect(
        status.purpose,
        CalendarSchedulingBindingPurpose.informationPublication,
      );
      expect(status.hasLocalChanges, isFalse);
    });
    test(
      'missing summary becomes empty outgoing text without stored placeholder',
      () async {
        final r = await service.saveAndPublishInformation(save(summary: null));
        expect((await current()).summary, isNull);
        expect(
          (await publication(r.publicationId)).payload,
          contains('SUMMARY:\r\n'),
        );
      },
    );
    test(
      'exact retries and normalized no-ops do not resend or advance revisions',
      () async {
        final input = save();
        final first = await service.saveAndPublishInformation(input);
        final retry = await service.saveAndPublishInformation(input);
        final noop = await service.saveAndPublishInformation(
          save(revision: first.eventRevision),
        );
        expect(retry.publicationId, first.publicationId);
        expect(noop.publicationId, first.publicationId);
        expect(noop.unchanged, isTrue);
        expect((await current()).revision, first.eventRevision);
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 1);
        await expectLater(
          service.saveAndPublishInformation(
            input.copyWith(content: eventInput(summary: 'Different')),
          ),
          failure(CalendarFailureCode.validation),
        );
      },
    );
    test('invitation and information APIs reject cross-purpose before legacy fallback', () async {
      await service.saveAndPublishInformation(save());
      await expectLater(
        service.saveAndNotify(save(revision: 2)),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.schedulingStatus(event),
        failure(CalendarFailureCode.accessDenied),
      );
      await expectLater(
        service.cancelAndNotify(
          CalendarSchedulingCancelRequest(
            eventId: event,
            expectedRevision: 2,
            commandId: const Uuid().v4obj(),
          ),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test(
      'information APIs cannot convert an existing invitation binding',
      () async {
        await service.saveAndNotify(save());
        await expectLater(
          service.saveAndPublishInformation(save(revision: 2)),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          service.informationPublicationStatus(event),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test('cancel and reopen preserve private drafts and historical retries cannot recancel', () async {
      final first = await service.saveAndPublishInformation(save());
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: event,
          expectedRevision: first.eventRevision,
          content: eventInput(summary: 'Private draft'),
        ),
      );
      host.onCheck = (context) {
        expect(context.publicationEvent.content.summary, 'Published title');
        expect(context.proposedEvent.content.summary, 'Private draft');
      };
      final cancel = CalendarSchedulingCancelRequest(
        eventId: event,
        expectedRevision: 3,
        commandId: const Uuid().v4obj(),
      );
      final cancelled = await service.cancelPublishedInformation(cancel);
      expect(
        (await publication(cancelled.publicationId)).payload,
        isNot(contains('Private draft')),
      );
      expect((await current()).summary, 'Private draft');
      expect((await current()).status, CalendarEventStatus.cancelled);
      expect(
        (await service.informationPublicationStatus(event)).hasLocalChanges,
        isTrue,
      );
      final reopened = await service.reopenPublishedInformation(
        CalendarSchedulingReopenRequest(
          eventId: event,
          expectedRevision: 4,
          commandId: const Uuid().v4obj(),
        ),
      );
      expect(
        (await publication(reopened.publicationId)).payload,
        contains('Published title'),
      );
      expect(
        (await publication(reopened.publicationId)).payload,
        isNot(contains('Private draft')),
      );
      expect((await current()).summary, 'Private draft');
      expect((await current()).status, CalendarEventStatus.confirmed);
      await service.cancelPublishedInformation(cancel);
      expect((await current()).revision, 5);
      expect((await current()).status, CalendarEventStatus.confirmed);
      expect(
        (await publication(reopened.publicationId)).sequence,
        greaterThan((await publication(cancelled.publicationId)).sequence),
      );
    });
    test('fixed recipient and revision checks reject atomically', () async {
      await service.saveAndPublishInformation(save());
      await expectLater(
        service.saveAndPublishInformation(
          save(revision: 2)
              .copyWith(recipients: ['mailto:other@example.invalid']),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.saveAndPublishInformation(save()),
        failure(CalendarFailureCode.staleRevision),
      );
      expect(await CalendarSchedulingPublicationRecord.db.count(session), 1);
    });
    for (final origin in [
      CalendarEventOrigin.imported,
      CalendarEventOrigin.unknown,
    ]) {
      test(
        '$origin cannot acquire publisher authority from a missing baseline',
        () async {
          final data = (await CalendarEventDataRecord.db.find(session)).single;
          data.origin = origin;
          await CalendarEventDataRecord.db.updateRow(session, data);
          await expectLater(
            service.saveAndPublishInformation(save()),
            failure(CalendarFailureCode.validation),
          );
          expect(await CalendarSchedulingMeetingRecord.db.count(session), 0);
        },
      );
    }
    for (final permission in [
      CalendarPermission.publishEventInformation,
      CalendarPermission.readEventSource,
      CalendarPermission.updateEvent,
    ]) {
      test('independent $permission gate rejects all writes', () async {
        policy.denied.add(permission);
        await expectLater(
          service.saveAndPublishInformation(save()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await current()).revision, 1);
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      });
    }
    test(
      'final host denial rolls back event, binding and all recipient intents',
      () async {
        host.denyFinal = true;
        await expectLater(
          service.saveAndPublishInformation(save()),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await current()).summary, 'Native title');
        expect(await CalendarSchedulingMeetingRecord.db.count(session), 0);
        expect(await CalendarSchedulingDeliveryRecord.db.count(session), 0);
      },
    );
    test('worker receives trusted purpose and no fabricated actor and accepts stable payload', () async {
      final first = await service.saveAndPublishInformation(save());
      host.onCheck = (c) {
        expect(c.actor, isNull);
        expect(
          c.purpose,
          CalendarSchedulingBindingPurpose.informationPublication,
        );
        expect(c.intent.purpose, c.purpose);
        expect(c.outgoingMessage.events.single.participants.attendees, isEmpty);
      };
      await CalendarModule.runSchedulingMaintenance(session);
      expect(
        transport.submissions.single.payload,
        (await publication(first.publicationId)).payload,
      );
      expect(
        (await CalendarSchedulingDeliveryRecord.db.find(session)).single.state,
        CalendarSchedulingDeliveryState.accepted,
      );
    });
    test(
      'malformed purpose-bound checkpoint never reaches transport',
      () async {
        final first = await service.saveAndPublishInformation(save());
        final p = await publication(first.publicationId);
        final data = jsonDecode(p.snapshot) as Map<String, dynamic>;
        data['purpose'] = 'invitation';
        p.snapshot = jsonEncode(data);
        await CalendarSchedulingPublicationRecord.db.updateRow(session, p);
        await expectLater(
          service.informationPublicationStatus(event),
          failure(CalendarFailureCode.unavailable),
        );
        await CalendarModule.runSchedulingMaintenance(session);
        expect(transport.submissions, isEmpty);
      },
    );
    for (final kind in [
      CalendarEventTimeKind.date,
      CalendarEventTimeKind.utc,
      CalendarEventTimeKind.zoned,
    ]) {
      test(
        'recurring ${kind.name} master preserves timing, rules and lifecycle versions',
        () async {
          final timing = CalendarEventTiming(
            kind: kind,
            start: CalendarEventCivil(
              year: 2026,
              month: 3,
              day: 28,
              hour: kind == CalendarEventTimeKind.date ? 0 : 9,
            ),
            zoneId: kind == CalendarEventTimeKind.zoned
                ? 'Europe/Stockholm'
                : null,
            duration: CalendarEventDuration(
              days: kind == CalendarEventTimeKind.date ? 1 : 0,
              hours: kind == CalendarEventTimeKind.date ? 0 : 1,
            ),
          );
          final content = eventInput(summary: 'Recurring publication').copyWith(
            timing: timing,
            recurrence: CalendarEventRecurrence(
              rule: CalendarEventRule(
                frequency: CalendarEventFrequency.daily,
                count: 4,
                byDay: [],
                byMonthDay: [],
                byYearDay: [],
                byWeekNo: [],
                byMonth: [],
                byHour: [],
                byMinute: [],
                bySetPosition: [],
              ),
              inclusions: [],
              exclusions: [],
            ),
          );
          final id = (await service.createEvent(
            CalendarEventCreateRequest(calendarId: parent, content: content),
          ))!.eventId;
          final first = await service.saveAndPublishInformation(
            save().copyWith(eventId: id, content: content),
          );
          final body = (await publication(first.publicationId)).payload;
          expect(body, contains('RRULE:'));
          expect(body, contains('COUNT=4'));
          if (kind == CalendarEventTimeKind.zoned) {
            expect(body, contains('BEGIN:VTIMEZONE'));
          }
          expect(
            (await service.getEvent(
              id,
              CalendarEventFieldGroup.values,
            )).timing!.toJson(),
            timing.toJson(),
          );
          final cancelled = await service.cancelPublishedInformation(
            CalendarSchedulingCancelRequest(
              eventId: id,
              expectedRevision: 2,
              commandId: const Uuid().v4obj(),
            ),
          );
          final reopened = await service.reopenPublishedInformation(
            CalendarSchedulingReopenRequest(
              eventId: id,
              expectedRevision: 3,
              commandId: const Uuid().v4obj(),
            ),
          );
          expect(
            (await publication(reopened.publicationId)).sequence,
            greaterThan((await publication(cancelled.publicationId)).sequence),
          );
          expect(
            (await publication(reopened.publicationId)).payload,
            contains('RRULE:'),
          );
        },
      );
    }
    for (final permission in [
      CalendarPermission.cancelEventInformation,
      CalendarPermission.changeEventStatus,
    ]) {
      test('cancellation independently requires ${permission.name}', () async {
        await service.saveAndPublishInformation(save());
        policy.denied.add(permission);
        await expectLater(
          service.cancelPublishedInformation(
            CalendarSchedulingCancelRequest(
              eventId: event,
              expectedRevision: 2,
              commandId: const Uuid().v4obj(),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 1);
        expect((await current()).status, CalendarEventStatus.confirmed);
      });
    }
    test(
      'status read has independent authority and exposes no raw source',
      () async {
        await service.saveAndPublishInformation(save());
        policy.denied.add(CalendarPermission.readEventInformationPublication);
        await expectLater(
          service.informationPublicationStatus(event),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test(
      'shared scope delivery quota rejects another purpose without native changes',
      () async {
        install(options: CalendarSchedulingOptions(maxScopeDeliveries: 1));
        await service.saveAndNotify(save());
        final other = (await service.createEvent(
          CalendarEventCreateRequest(calendarId: parent, content: eventInput()),
        ))!.eventId;
        await expectLater(
          service.saveAndPublishInformation(save().copyWith(eventId: other)),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(
          (await service.getEvent(
            other,
            CalendarEventFieldGroup.values,
          )).revision,
          1,
        );
        expect(await CalendarSchedulingMeetingRecord.db.count(session), 1);
      },
    );
    test('fresh dispatch denial withdraws without submitting', () async {
      await service.saveAndPublishInformation(save());
      host.denied = true;
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions, isEmpty);
      expect(
        (await CalendarSchedulingDeliveryRecord.db.find(session)).single.state,
        CalendarSchedulingDeliveryState.blocked,
      );
    });
    test('new publication supersedes old unsent work and retains exact old receipt', () async {
      final command = save();
      final first = await service.saveAndPublishInformation(command);
      final second = await service.saveAndPublishInformation(
        save(revision: 2, summary: 'Updated information'),
      );
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions.single.publicationId, second.publicationId);
      expect(
        (await service.saveAndPublishInformation(command)).publicationId,
        first.publicationId,
      );
      expect((await current()).summary, 'Updated information');
    });
    test('source DISPLAY alarms remain stored and cannot be silently removed for publication', () async {
      final data = (await CalendarEventDataRecord.db.find(session)).single;
      data.protocolState = data.protocolState!.copyWith(
        sourceMetadata: CalendarEventSourceMetadata(
          categoryGroups: [],
          comments: [],
          contacts: [],
          alarms: [
            CalendarEventSourceAlarm(
              description: CalendarEventSourceText(value: 'Inert source alarm'),
              absoluteUtc: DateTime.utc(2026, 3, 28),
            ),
          ],
        ),
      );
      await CalendarEventDataRecord.db.updateRow(session, data);
      await expectLater(
        service.saveAndPublishInformation(save()),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await CalendarEventDataRecord.db.find(session))
            .single
            .protocolState!
            .sourceMetadata!
            .alarms,
        hasLength(1),
      );
      expect(await CalendarSchedulingMeetingRecord.db.count(session), 0);
    });
    test(
      'outgoing version overflow rolls back the native lifecycle and outbox',
      () async {
        final data = (await CalendarEventDataRecord.db.find(session)).single;
        data.protocolState = data.protocolState!.copyWith(
          version: data.protocolState!.version.copyWith(sequence: 2147483647),
        );
        await CalendarEventDataRecord.db.updateRow(session, data);
        await service.saveAndPublishInformation(save(summary: 'Native title'));
        await expectLater(
          service.cancelPublishedInformation(
            CalendarSchedulingCancelRequest(
              eventId: event,
              expectedRevision: 2,
              commandId: const Uuid().v4obj(),
            ),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect((await current()).revision, 2);
        expect((await current()).status, CalendarEventStatus.confirmed);
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 1);
      },
    );
    test('reopening independently requires its publication and native lifecycle gates', () async {
      await service.saveAndPublishInformation(save());
      await service.cancelPublishedInformation(
        CalendarSchedulingCancelRequest(
          eventId: event,
          expectedRevision: 2,
          commandId: const Uuid().v4obj(),
        ),
      );
      for (final gate in [
        CalendarPermission.reopenEventInformation,
        CalendarPermission.changeEventStatus,
      ]) {
        policy.denied.add(gate);
        await expectLater(
          service.reopenPublishedInformation(
            CalendarSchedulingReopenRequest(
              eventId: event,
              expectedRevision: 3,
              commandId: const Uuid().v4obj(),
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.denied.remove(gate);
      }
      expect((await current()).revision, 3);
    });
    for (final mutation in ['eventRevision', 'sequence', 'recipients']) {
      test(
        'corrupt $mutation correspondence fails status and dispatch closed',
        () async {
          final first = await service.saveAndPublishInformation(save());
          final p = await publication(first.publicationId);
          if (mutation == 'eventRevision') {
            p.eventRevision++;
          }
          if (mutation == 'sequence') {
            p.sequence++;
          }
          if (mutation == 'recipients') {
            p.recipients = [];
          }
          await CalendarSchedulingPublicationRecord.db.updateRow(session, p);
          await expectLater(
            service.informationPublicationStatus(event),
            failure(CalendarFailureCode.unavailable),
          );
          await CalendarModule.runSchedulingMaintenance(session);
          expect(transport.submissions, isEmpty);
        },
      );
    }
    test('private occurrence cancellations block active publication but survive whole lifecycle', () async {
      final content = eventInput(summary: 'Published recurring master')
          .copyWith(
            recurrence: CalendarEventRecurrence(
              rule: CalendarEventRule(
                frequency: CalendarEventFrequency.daily,
                count: 3,
                byDay: [],
                byMonthDay: [],
                byYearDay: [],
                byWeekNo: [],
                byMonth: [],
                byHour: [],
                byMinute: [],
                bySetPosition: [],
              ),
              inclusions: [],
              exclusions: [],
            ),
          );
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: event,
          expectedRevision: 1,
          content: content,
        ),
      );
      await service.saveAndPublishInformation(
        save(revision: 2).copyWith(content: content),
      );
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: event,
          expectedRevision: 3,
          originalStart: CalendarEventTiming(
            kind: CalendarEventTimeKind.date,
            start: CalendarEventCivil(year: 2026, month: 3, day: 30),
          ),
          action: CalendarEventOccurrenceAction.cancelSingle,
        ),
      );
      await expectLater(
        service.saveAndPublishInformation(
          save(revision: 4).copyWith(content: content),
        ),
        failure(CalendarFailureCode.validation),
      );
      final before = (await CalendarEventDataRecord.db.find(session))
          .single
          .timingOverrides!
          .toJson();
      await service.cancelPublishedInformation(
        CalendarSchedulingCancelRequest(
          eventId: event,
          expectedRevision: 4,
          commandId: const Uuid().v4obj(),
        ),
      );
      await service.reopenPublishedInformation(
        CalendarSchedulingReopenRequest(
          eventId: event,
          expectedRevision: 5,
          commandId: const Uuid().v4obj(),
        ),
      );
      expect(
        (await CalendarEventDataRecord.db.find(session)).single.timingOverrides!
            .toJson(),
        before,
      );
      expect((await current()).status, CalendarEventStatus.confirmed);
    });
    test(
      'routing recipients cannot create attendee response state for PUBLISH',
      () async {
        final first = await service.saveAndPublishInformation(save());
        final p = await publication(first.publicationId);
        final bytes = Uint8List.fromList(
          utf8.encode(
            [
              'BEGIN:VCALENDAR',
              'VERSION:2.0',
              'PRODID:-//Synthetic//EN',
              'METHOD:REPLY',
              'BEGIN:VEVENT',
              'UID:${p.protocolUid}',
              'DTSTAMP:20261107T100000Z',
              'SEQUENCE:${p.sequence}',
              'ORGANIZER:mailto:alice@example.invalid',
              'ATTENDEE;PARTSTAT=ACCEPTED:mailto:bob@example.invalid',
              'END:VEVENT',
              'END:VCALENDAR',
              '',
            ].join('\r\n'),
          ),
        );
        await expectLater(
          CalendarModule.receiveSchedulingReply(
            session,
            CalendarSchedulingReplyDelivery(
              scopeKey: 'test:alice',
              eventId: event,
              namespace: 'synthetic',
              deliveryKey: const Uuid().v4(),
              originReference: 'verified-bob',
              bytes: bytes,
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarSchedulingReplySourceRecord.db.count(session), 0);
        expect(await CalendarSchedulingReplyReceiptRecord.db.count(session), 0);
        expect(
          await CalendarSchedulingAttendeeResponseRecord.db.count(session),
          0,
        );
      },
    );
    test(
      'canonical attendees cannot be stripped to manufacture PUBLISH',
      () async {
        final data = (await CalendarEventDataRecord.db.find(session)).single;
        data.protocolState = data.protocolState!.copyWith(
          sourceMetadata: CalendarEventSourceMetadata(
            categoryGroups: [],
            comments: [],
            contacts: [],
            organizer: CalendarEventSourceParticipant(
              address: 'mailto:alice@example.invalid',
              parameters: {},
            ),
            attendees: [
              CalendarEventSourceParticipant(
                address: 'mailto:bob@example.invalid',
                parameters: {},
              ),
            ],
          ),
        );
        await CalendarEventDataRecord.db.updateRow(session, data);
        await expectLater(
          service.saveAndPublishInformation(save()),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      },
    );
  });
}
