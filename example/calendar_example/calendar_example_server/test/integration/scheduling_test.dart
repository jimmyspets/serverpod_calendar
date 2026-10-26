import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, eventInput, createInput, failure;
import 'test_tools/serverpod_test_tools.dart';

final class SchedulingObserver
    implements CalendarDependencyProvider, CalendarPublicationChangeObserver {
  int changes = 0;
  @override
  Future<bool> hasActiveDependencies(
    Session session,
    UuidValue calendarId,
    Transaction transaction,
  ) async => false;
  @override
  Future<void> eventsChanged(
    Session session,
    String scopeKey,
    UuidValue calendarId,
    Transaction transaction,
  ) async {
    changes++;
  }
}

final class SchedulingHost implements CalendarSchedulingHost {
  bool denied = false,
      unavailable = false,
      denyFinal = false,
      badRoutes = false;
  void Function(CalendarSchedulingPolicyContext)? onCheck;
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<CalendarSchedulingAuthority> resolve(
    Session session,
    CalendarHostContext actor,
    CalendarEventPolicySnapshot current,
    List<String> recipientProposals,
    Transaction transaction,
  ) async => CalendarSchedulingAuthority(
    organizerAddress: 'mailto:alice@example.invalid',
    authorityRef: actor.scopeKey,
    routes: recipientProposals.map(
      (r) => CalendarSchedulingRoute(r, badRoutes ? 'same' : r),
    ),
  );
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarSchedulingPolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    onCheck?.call(context);
    return unavailable
        ? CalendarAuthorizationVerdict.unavailable
        : denied || denyFinal && phase == CalendarAuthorizationPhase.finalWrite
        ? CalendarAuthorizationVerdict.deny
        : CalendarAuthorizationVerdict.allow;
  }
}

final class SchedulingTransport implements CalendarSchedulingTransport {
  final submissions = <CalendarSchedulingSubmission>[];
  CalendarSchedulingTransportOutcome outcome =
      CalendarSchedulingTransportOutcome.accepted;
  Future<CalendarSchedulingTransportResult> Function(
    CalendarSchedulingSubmission,
  )?
  callback;
  @override
  Future<CalendarSchedulingTransportResult> submit(
    Session session,
    CalendarSchedulingSubmission submission,
  ) async {
    submissions.add(submission);
    return callback == null
        ? CalendarSchedulingTransportResult(
            outcome,
            receipt: 'synthetic-receipt',
          )
        : await callback!(submission);
  }
}

void main() {
  withServerpod('durable organizer scheduling', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late SchedulingHost host;
    late SchedulingTransport transport;
    late CalendarService service;
    late SchedulingObserver observer;
    void install({CalendarSchedulingOptions? options}) {
      CalendarModule.install(
        session.serverpod,
        dependencies: [observer],
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        scheduling: CalendarSchedulingRuntime(
          host: host,
          transport: transport,
          options: options,
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
      observer = SchedulingObserver();
      policy = TestPolicy();
      host = SchedulingHost();
      transport = SchedulingTransport();
      install();
    });
    Future<UuidValue> event() async {
      final parent = (await service.create(createInput()))!.calendarId;
      return (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Initial'),
        ),
      ))!.eventId;
    }

    CalendarSchedulingSaveRequest request(
      UuidValue id, {
      int revision = 1,
      String summary = 'Published',
      List<String>? recipients,
    }) => CalendarSchedulingSaveRequest(
      eventId: id,
      expectedRevision: revision,
      content: eventInput(summary: summary),
      recipients: recipients ?? ['mailto:bob@example.invalid'],
      commandId: Uuid().v4obj(),
    );
    Future<List<CalendarSchedulingPublicationRecord>> publications() =>
        CalendarSchedulingPublicationRecord.db.find(session);
    Future<void> due() => session.db.unsafeExecute(
      'UPDATE serverpod_calendar_scheduling_delivery SET "nextAttemptAt"=clock_timestamp()-interval \'1 second\', "leaseUntil"=NULL WHERE "terminalAt" IS NULL',
    );

    for (final kind in [
      CalendarEventTimeKind.date,
      CalendarEventTimeKind.utc,
      CalendarEventTimeKind.zoned,
    ]) {
      test(
        'publication preserves ${kind.name} civil timing and validates named zones',
        () async {
          final id = await event();
          final timing = CalendarEventTiming(
            kind: kind,
            start: CalendarEventCivil(
              year: 2026,
              month: 3,
              day: 29,
              hour: kind == CalendarEventTimeKind.date ? 0 : 2,
              minute: kind == CalendarEventTimeKind.date ? 0 : 30,
            ),
            zoneId: kind == CalendarEventTimeKind.zoned
                ? 'Europe/Stockholm'
                : null,
          );
          await service.saveAndNotify(
            request(id)
                .copyWith(content: eventInput().copyWith(timing: timing)),
          );
          final p = (await publications()).single,
              parsed = parseIcalendarSchedulingMessage(utf8.encode(p.payload));
          final wire = parsed.events.single;
          expect(wire.summary!.value, '');
          if (kind == CalendarEventTimeKind.date) {
            expect(wire.startDate!.day, 29);
          } else {
            expect(wire.startTime!.civil.hour, 2);
            expect(wire.startTime!.civil.minute, 30);
            expect(wire.startTime!.zoneId, timing.zoneId);
          }
          expect(
            (await service.getEvent(
              id,
              CalendarEventFieldGroup.values,
            )).summary,
            isNull,
          );
        },
      );
    }
    test(
      'floating timing is rejected before any publication or mutation',
      () async {
        final id = await event();
        final input = request(id);
        await expectLater(
          service.saveAndNotify(
            input.copyWith(
              content: input.content.copyWith(
                timing: input.content.timing.copyWith(
                  kind: CalendarEventTimeKind.floating,
                ),
              ),
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
        expect(
          (await service.getEvent(id, CalendarEventFieldGroup.values)).revision,
          1,
        );
      },
    );
    test('create-only import explicitly records imported provenance', () async {
      final parent = (await service.create(createInput()))!;
      final bytes = utf8.encode(
        [
          'BEGIN:VCALENDAR',
          'VERSION:2.0',
          'PRODID:-//Synthetic//EN',
          'BEGIN:VEVENT',
          'UID:imported-organizer-source',
          'DTSTAMP:20261026T080000Z',
          'DTSTART;VALUE=DATE:20261101',
          'END:VEVENT',
          'END:VCALENDAR',
          '',
        ].join('\r\n'),
      );
      final result = await service.importEvents(
        CalendarEventImportRequest(
          calendarId: parent.calendarId,
          expectedRevision: parent.revision,
          bytes: ByteData.sublistView(Uint8List.fromList(bytes)),
        ),
      );
      final id = result.receipts.single.eventId;
      expect(
        (await service.schedulingStatus(id)).origin,
        CalendarEventOrigin.imported,
      );
      await expectLater(
        service.saveAndNotify(request(id)),
        failure(CalendarFailureCode.validation),
      );
    });
    test('publication retains text annotations when ordinary proposed text changes', () async {
      final parent = (await service.create(createInput()))!;
      final e = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent.calendarId,
          content: eventInput(summary: 'Before').copyWith(
            textParameters: CalendarEventTextParameters(
              summary: CalendarTextParameters(
                language: 'sv',
                alternativeUri: 'https://example.invalid/title',
              ),
            ),
          ),
        ),
      ))!;
      await service.saveAndNotify(request(e.eventId));
      final parsed = parseIcalendarSchedulingMessage(
        utf8.encode((await publications()).single.payload),
      );
      expect(parsed.events.single.summary!.language, 'sv');
      expect(
        parsed.events.single.summary!.alternativeUri,
        'https://example.invalid/title',
      );
    });
    test('publishing a saved local edit reuses its already newer component version', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 2,
          content: eventInput(summary: 'Already saved'),
        ),
      );
      final before = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      ))!.protocolState!.version;
      final changesBeforePublication = observer.changes;
      await service.saveAndNotify(
        request(id, revision: 3, summary: 'Already saved'),
      );
      final after = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      ))!.protocolState!.version;
      expect(jsonEncode(after.toJson()), jsonEncode(before.toJson()));
      expect(observer.changes, changesBeforePublication);
    });
    test('native origin, atomic publication, stable canonical identity and synthetic acceptance', () async {
      final id = await event(), input = request(id);
      final receipt = await service.saveAndNotify(input);
      expect(receipt.eventRevision, 2);
      expect(receipt.unchanged, false);
      final p = (await publications()).single;
      final parsed = parseIcalendarSchedulingMessage(utf8.encode(p.payload));
      expect(parsed.method, IcalendarSchedulingMethod.request);
      expect(parsed.events.single.summary!.value, 'Published');
      expect(
        parsed.events.single.participants.organizer!.address,
        'mailto:alice@example.invalid',
      );
      final view = await service.schedulingStatus(id);
      expect(view.origin, CalendarEventOrigin.native);
      expect(view.hasLocalChanges, false);
      expect(
        view.deliveries.single.state,
        CalendarSchedulingDeliveryState.pending,
      );
      final source = await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(id),
      );
      expect(source!.protocolUid, parsed.uid);
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions.single.payload, p.payload);
      expect(
        (await service.schedulingStatus(id)).deliveries.single.state,
        CalendarSchedulingDeliveryState.accepted,
      );
      expect(
        (await CalendarSchedulingAttemptRecord.db.find(session)).single.outcome,
        'accepted',
      );
    });
    test('exact retry and unchanged publication preserve all versions and intent counts', () async {
      final id = await event(), input = request(id);
      final first = await service.saveAndNotify(input);
      final retry = await service.saveAndNotify(input);
      expect(retry.publicationId, first.publicationId);
      expect(retry.unchanged, true);
      final unchanged = await service.saveAndNotify(request(id, revision: 2));
      expect(unchanged.publicationId, first.publicationId);
      expect(unchanged.eventRevision, 2);
      expect((await publications()).length, 1);
      expect(await CalendarSchedulingDeliveryRecord.db.count(session), 1);
      expect(
        (await service.getEvent(id, CalendarEventFieldGroup.values)).revision,
        2,
      );
    });
    test(
      'ordinary edits stay local and never regenerate a queued payload',
      () async {
        final id = await event();
        await service.saveAndNotify(request(id));
        final before = (await publications()).single;
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: id,
            expectedRevision: 2,
            content: eventInput(summary: 'Local only'),
          ),
        );
        expect((await service.schedulingStatus(id)).hasLocalChanges, true);
        await CalendarModule.runSchedulingMaintenance(session);
        expect(transport.submissions.single.payload, before.payload);
        expect(
          transport.submissions.single.payload,
          isNot(contains('Local only')),
        );
        expect((await publications()).length, 1);
      },
    );
    for (final permission in [
      CalendarPermission.publishScheduling,
      CalendarPermission.updateEvent,
      CalendarPermission.readEvent,
      CalendarPermission.readEventSource,
    ]) {
      test('publication independently requires ${permission.name}', () async {
        final id = await event();
        policy.denied.add(permission);
        await expectLater(
          service.saveAndNotify(request(id)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarSchedulingMeetingRecord.db.count(session), 0);
        expect(
          (await CalendarEventRecord.db.findById(session, id))!.revision,
          1,
        );
      });
    }
    test(
      'withheld detail group and final organizer denial roll back all work',
      () async {
        final id = await event();
        policy.eventGrants.remove(CalendarEventFieldGroup.summary);
        await expectLater(
          service.saveAndNotify(request(id)),
          failure(CalendarFailureCode.accessDenied),
        );
        policy.eventGrants = CalendarEventFieldGroup.values.toSet();
        host.denyFinal = true;
        await expectLater(
          service.saveAndNotify(request(id)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarSchedulingMeetingRecord.db.count(session), 0);
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
        expect(await CalendarSchedulingDeliveryRecord.db.count(session), 0);
      },
    );
    test(
      'unknown and imported origins cannot establish organizer authority',
      () async {
        final id = await event();
        final data = (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(id),
        ))!;
        for (final origin in [
          CalendarEventOrigin.unknown,
          CalendarEventOrigin.imported,
        ]) {
          data.origin = origin;
          await CalendarEventDataRecord.db.updateRow(session, data);
          await expectLater(
            service.saveAndNotify(request(id)),
            failure(CalendarFailureCode.validation),
          );
        }
        expect(await CalendarSchedulingMeetingRecord.db.count(session), 0);
      },
    );
    test('stale revisions, reused command meaning, changed recipients and bound deletion reject', () async {
      final id = await event(), input = request(id);
      await service.saveAndNotify(input);
      await expectLater(
        service.saveAndNotify(request(id)),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.saveAndNotify(
          input.copyWith(content: eventInput(summary: 'Other')),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.saveAndNotify(
          request(
            id,
            revision: 2,
            recipients: ['mailto:other@example.invalid'],
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.deleteEvent(id, 2),
        failure(CalendarFailureCode.dependencyConflict),
      );
    });
    test(
      'scope capacity and unsupported content reject without partial save',
      () async {
        install(options: CalendarSchedulingOptions(maxScopeDeliveries: 1));
        final id = await event();
        await expectLater(
          service.saveAndNotify(
            request(
              id,
              recipients: [
                'mailto:bob@example.invalid',
                'mailto:other@example.invalid',
              ],
            ),
          ),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await CalendarSchedulingMeetingRecord.db.count(session), 0);
        expect(
          (await service.getEvent(id, CalendarEventFieldGroup.values)).summary,
          'Initial',
        );
      },
    );
    test('new publication supersedes prior unsubmitted work without changing its snapshot', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      final before = (await publications()).single;
      await service.saveAndNotify(
        request(id, revision: 2, summary: 'New publication'),
      );
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions.length, 1);
      expect(transport.submissions.single.payload, contains('New publication'));
      expect(
        (await CalendarSchedulingPublicationRecord.db.findById(
          session,
          before.id!,
        ))!.payload,
        before.payload,
      );
      final deliveries = await CalendarSchedulingDeliveryRecord.db.find(
        session,
      );
      expect(
        deliveries.any(
          (d) => d.state == CalendarSchedulingDeliveryState.superseded,
        ),
        true,
      );
    });
    test('withdrawn organizer rights and local cancellation suppress queued requests', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      host.denied = true;
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions, isEmpty);
      expect(
        (await service.schedulingStatus(id)).deliveries.single.state,
        CalendarSchedulingDeliveryState.blocked,
      );
    });
    test('uncertain acceptance retries the same delivery key bytes and component version', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      transport.outcome = CalendarSchedulingTransportOutcome.uncertain;
      await CalendarModule.runSchedulingMaintenance(session);
      final first = transport.submissions.single;
      await due();
      transport.outcome = CalendarSchedulingTransportOutcome.accepted;
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions[1].deliveryKey, first.deliveryKey);
      expect(transport.submissions[1].payload, first.payload);
      expect(
        (await service.schedulingStatus(id)).deliveries.single.attemptCount,
        2,
      );
    });
    test(
      'expiry and bounded attempts terminate without further submission',
      () async {
        install(options: CalendarSchedulingOptions(maxAttempts: 1));
        final id = await event();
        await service.saveAndNotify(request(id));
        transport.outcome = CalendarSchedulingTransportOutcome.transientFailure;
        await CalendarModule.runSchedulingMaintenance(session);
        await due();
        await CalendarModule.runSchedulingMaintenance(session);
        expect(transport.submissions.length, 1);
        expect(
          (await service.schedulingStatus(id)).deliveries.single.state,
          CalendarSchedulingDeliveryState.failed,
        );
      },
    );
    test(
      'expired publication never submits and status has an independent gate',
      () async {
        final id = await event();
        await service.saveAndNotify(request(id));
        await session.db.unsafeExecute(
          'UPDATE serverpod_calendar_scheduling_publication SET "expiresAt"=clock_timestamp()-interval \'1 second\'',
        );
        await CalendarModule.runSchedulingMaintenance(session);
        expect(transport.submissions, isEmpty);
        expect(
          (await service.schedulingStatus(id)).deliveries.single.state,
          CalendarSchedulingDeliveryState.expired,
        );
        policy.denied.add(CalendarPermission.readScheduling);
        await expectLater(
          service.schedulingStatus(id),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test(
      'native cancellation suppresses delivery without sending implicit CANCEL',
      () async {
        final id = await event();
        await service.saveAndNotify(request(id));
        await service.changeEventStatus(
          CalendarEventStatusRequest(
            eventId: id,
            expectedRevision: 2,
            status: CalendarEventStatus.cancelled,
          ),
        );
        await CalendarModule.runSchedulingMaintenance(session);
        expect(transport.submissions, isEmpty);
        expect(
          (await service.schedulingStatus(id)).deliveries.single.state,
          CalendarSchedulingDeliveryState.blocked,
        );
      },
    );
    test(
      'unavailable background authority remains retryable without submission',
      () async {
        final id = await event();
        await service.saveAndNotify(request(id));
        host.unavailable = true;
        await CalendarModule.runSchedulingMaintenance(session);
        final blocked = (await CalendarSchedulingDeliveryRecord.db.find(
          session,
        )).single;
        expect(blocked.state, CalendarSchedulingDeliveryState.blocked);
        expect(blocked.terminalAt, isNull);
        expect(transport.submissions, isEmpty);
        host.unavailable = false;
        await due();
        await CalendarModule.runSchedulingMaintenance(session);
        expect(transport.submissions.length, 1);
      },
    );
    test(
      'serialization budget failure cannot save event or partial outbox',
      () async {
        install(options: CalendarSchedulingOptions(maxPayloadBytes: 1024));
        final id = await event();
        await expectLater(
          service.saveAndNotify(request(id, summary: 'a' * 2000)),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
        expect(
          (await service.getEvent(id, CalendarEventFieldGroup.values)).summary,
          'Initial',
        );
      },
    );
    test('retention scrubs superseded bodies and attempts while keeping latest checkpoint', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      await CalendarModule.runSchedulingMaintenance(session);
      final old = (await publications()).single;
      await service.saveAndNotify(request(id, revision: 2, summary: 'Later'));
      await CalendarModule.runSchedulingMaintenance(session);
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_scheduling_publication SET "completedAt"=timestamp \'2000-01-01\'',
      );
      await CalendarModule.runSchedulingMaintenance(session);
      expect(
        await CalendarSchedulingPublicationRecord.db.findById(session, old.id!),
        isNull,
      );
      expect((await publications()).length, 1);
      expect(await CalendarSchedulingAttemptRecord.db.count(session), 1);
      expect((await service.schedulingStatus(id)).hasLocalChanges, false);
    });
    test('claim takeover fences a late accepted holder and retains uncertain attempt history', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      final entered = Completer<void>(), release = Completer<void>();
      transport.callback = (submission) async {
        if (transport.submissions.length == 1) {
          entered.complete();
          await release.future;
        }
        return const CalendarSchedulingTransportResult(
          CalendarSchedulingTransportOutcome.accepted,
        );
      };
      final first = CalendarModule.runSchedulingMaintenance(session);
      await entered.future;
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_scheduling_delivery SET "leaseUntil"=clock_timestamp()-interval \'1 second\' WHERE "terminalAt" IS NULL',
      );
      final secondSession = builder.build();
      try {
        await CalendarModule.runSchedulingMaintenance(secondSession);
      } finally {
        await secondSession.close();
        release.complete();
      }
      await first;
      final attempts = await CalendarSchedulingAttemptRecord.db.find(
        session,
        orderBy: (t) => t.attemptNumber,
      );
      expect(attempts.map((a) => a.outcome), ['uncertain', 'accepted']);
      expect(
        (await service.schedulingStatus(id)).deliveries.single.state,
        CalendarSchedulingDeliveryState.accepted,
      );
      expect(
        transport.submissions[0].deliveryKey,
        transport.submissions[1].deliveryKey,
      );
    });
  });
}
