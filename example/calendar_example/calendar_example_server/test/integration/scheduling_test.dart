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

    CalendarSchedulingCancelRequest cancelRequest(
      UuidValue id, {
      int revision = 2,
    }) => CalendarSchedulingCancelRequest(
      eventId: id,
      expectedRevision: revision,
      commandId: Uuid().v4obj(),
    );
    Future<CalendarEventDataRecord> eventData(UuidValue id) async =>
        (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(id),
        ))!;
    Future<CalendarSchedulingPublicationRecord> publication(
      UuidValue id,
    ) async =>
        (await CalendarSchedulingPublicationRecord.db.findById(session, id))!;

    test('local-only cancellation still requires explicit CANCEL and advances future-clock versions', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      await service.changeEventStatus(
        CalendarEventStatusRequest(
          eventId: id,
          expectedRevision: 2,
          status: CalendarEventStatus.cancelled,
        ),
      );
      final before = await eventData(id);
      final futureStamp = before.protocolState!.version.stamp.add(
        const Duration(days: 1),
      );
      final futureModified = futureStamp.add(const Duration(days: 1));
      before.protocolState = before.protocolState!.copyWith(
        version: before.protocolState!.version.copyWith(
          stamp: futureStamp,
          lastModified: futureModified,
        ),
      );
      await CalendarEventDataRecord.db.updateRow(session, before);
      final receipt = await service.cancelAndNotify(
        cancelRequest(id, revision: 3),
      );
      expect(receipt.unchanged, false);
      final p = await publication(receipt.publicationId),
          after = await eventData(id);
      expect(p.method, 'CANCEL');
      expect(p.sequence, greaterThan(before.protocolState!.version.sequence!));
      expect(p.stamp.isBefore(futureStamp), false);
      expect(
        after.protocolState!.version.lastModified!.isBefore(futureModified),
        false,
      );
    });
    test(
      'old cancellation retries cannot recancel a newer published reopening',
      () async {
        final id = await event();
        await service.saveAndNotify(request(id));
        final command = cancelRequest(id),
            old = await service.cancelAndNotify(command);
        await service.saveAndNotify(
          request(id, revision: 3, summary: 'New meeting state'),
        );
        final before = jsonEncode((await eventData(id)).toJson());
        expect(
          (await service.cancelAndNotify(command)).publicationId,
          old.publicationId,
        );
        expect(jsonEncode((await eventData(id)).toJson()), before);
        expect((await service.schedulingStatus(id)).method, 'REQUEST');
        expect(
          (await eventData(id)).content.status,
          CalendarEventStatus.confirmed,
        );
        expect((await publications()).length, 3);
      },
    );
    test('editing a cancelled draft does not make repeat cancellation publish those edits', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      final cancelled = await service.cancelAndNotify(cancelRequest(id));
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 3,
          content: eventInput(
            summary: 'Still unpublished',
            status: CalendarEventStatus.cancelled,
          ),
        ),
      );
      final before = jsonEncode((await eventData(id)).toJson());
      final repeated = await service.cancelAndNotify(
        cancelRequest(id, revision: 4),
      );
      expect(repeated.unchanged, true);
      expect(repeated.publicationId, cancelled.publicationId);
      expect(jsonEncode((await eventData(id)).toJson()), before);
      expect((await service.schedulingStatus(id)).hasLocalChanges, true);
      expect((await publications()).length, 2);
    });
    test('final cancellation dispatch denial closes its attempt without submitting', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      final cancelled = await service.cancelAndNotify(cancelRequest(id));
      host.denyFinal = true;
      await CalendarModule.runSchedulingMaintenance(session);
      final d = (await CalendarSchedulingDeliveryRecord.db.findFirstRow(
        session,
        where: (t) => t.publicationId.equals(cancelled.publicationId),
      ))!;
      final attempt = (await CalendarSchedulingAttemptRecord.db.findFirstRow(
        session,
        where: (t) => t.deliveryId.equals(d.id!),
      ))!;
      expect(d.state, CalendarSchedulingDeliveryState.blocked);
      expect(attempt.outcome, 'notSubmitted');
      expect(attempt.finishedAt, isNotNull);
      expect(transport.submissions, isEmpty);
    });

    test(
      'retry and no-op host context preserves exact final native audit state',
      () async {
        final id = await event();
        final original = request(id);
        await service.saveAndNotify(original);
        var actual = await eventData(id);
        host.onCheck = (c) {
          expect(c.proposedEvent.updatedAt, actual.updatedAt);
          expect(
            jsonEncode(c.proposedEvent.content.toJson()),
            jsonEncode(actual.content.toJson()),
          );
          expect(
            jsonEncode(c.proposedEvent.protocolState!.toJson()),
            jsonEncode(actual.protocolState!.toJson()),
          );
        };
        await service.saveAndNotify(original);
        await service.saveAndNotify(request(id, revision: 2));
        host.onCheck = null;
        final cancelled = cancelRequest(id);
        await service.cancelAndNotify(cancelled);
        actual = await eventData(id);
        host.onCheck = (c) {
          expect(c.proposedEvent.updatedAt, actual.updatedAt);
          expect(
            jsonEncode(c.proposedEvent.content.toJson()),
            jsonEncode(actual.content.toJson()),
          );
          expect(
            jsonEncode(c.proposedEvent.protocolState!.toJson()),
            jsonEncode(actual.protocolState!.toJson()),
          );
        };
        await service.cancelAndNotify(cancelled);
        await service.cancelAndNotify(cancelRequest(id, revision: 3));
      },
    );

    for (final cancel in [false, true]) {
      test(
        '${cancel ? 'CANCEL' : 'REQUEST'} delivery clock is independent of a future native audit floor',
        () async {
          final id = await event();
          if (cancel) await service.saveAndNotify(request(id));
          final before = await eventData(id);
          final futureAudit = before.updatedAt.add(const Duration(days: 1));
          before.updatedAt = futureAudit;
          await CalendarEventDataRecord.db.updateRow(session, before);
          final receipt = cancel
              ? await service.cancelAndNotify(cancelRequest(id))
              : await service.saveAndNotify(request(id));
          final queued = await publication(receipt.publicationId);
          expect(queued.createdAt.isBefore(futureAudit), true);
          expect(
            queued.expiresAt.difference(queued.createdAt),
            const Duration(days: 7),
          );
          expect((await eventData(id)).updatedAt, futureAudit);
          expect(
            queued.stamp.isBefore(
              futureAudit.subtract(const Duration(seconds: 1)),
            ),
            false,
          );
          await CalendarModule.runSchedulingMaintenance(session);
          expect(transport.submissions.length, 1);
          expect(
            transport.submissions.single.publicationId,
            receipt.publicationId,
          );
        },
      );
    }

    CalendarEventRule masterRule({
      int? count = 4,
      CalendarEventFrequency frequency = CalendarEventFrequency.daily,
      int weekStart = 1,
      CalendarEventCivil? untilDate,
      DateTime? untilUtc,
      List<CalendarEventByDay>? byDay,
    }) => CalendarEventRule(
      frequency: frequency,
      count: count,
      untilDate: untilDate,
      untilUtc: untilUtc,
      weekStart: weekStart,
      byDay: byDay ?? [],
      byMonthDay: [],
      byYearDay: [],
      byWeekNo: [],
      byMonth: [],
      byHour: [],
      byMinute: [],
      bySetPosition: [],
    );
    CalendarEventTiming masterTiming({
      CalendarEventTimeKind kind = CalendarEventTimeKind.date,
      int day = 27,
    }) => CalendarEventTiming(
      kind: kind,
      start: CalendarEventCivil(
        year: 2026,
        month: 3,
        day: day,
        hour: kind == CalendarEventTimeKind.date ? 0 : 9,
      ),
      duration: CalendarEventDuration(
        days: kind == CalendarEventTimeKind.date ? 1 : 0,
        hours: kind == CalendarEventTimeKind.date ? 0 : 1,
      ),
      zoneId: kind == CalendarEventTimeKind.zoned ? 'Europe/Stockholm' : null,
    );
    CalendarEventContent masterContent({
      CalendarEventTimeKind kind = CalendarEventTimeKind.date,
      int count = 4,
      String summary = 'Published master',
    }) => CalendarEventContent(
      summary: summary,
      timing: masterTiming(kind: kind),
      recurrence: CalendarEventRecurrence(
        rule: masterRule(count: count),
        inclusions: [],
        exclusions: [],
      ),
    );
    Future<UuidValue> masterEvent(CalendarEventContent content) async {
      final parent = (await service.create(createInput()))!.calendarId;
      return (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: content),
      ))!.eventId;
    }

    CalendarSchedulingSaveRequest masterRequest(
      UuidValue id,
      CalendarEventContent content, {
      int revision = 1,
    }) => request(id, revision: revision).copyWith(content: content);
    List<IcalendarSyntaxProperty> props(
      IcalendarSchedulingEvent event,
      String name,
    ) => event.source.entries
        .whereType<IcalendarSyntaxProperty>()
        .where((p) => p.canonicalName == name)
        .toList();
    CalendarEventTiming originalDay(int day) => CalendarEventTiming(
      kind: CalendarEventTimeKind.date,
      start: CalendarEventCivil(year: 2026, month: 3, day: day),
    );

    for (final kind in [
      CalendarEventTimeKind.date,
      CalendarEventTimeKind.utc,
      CalendarEventTimeKind.zoned,
    ]) {
      test(
        'recurring ${kind.name} master keeps count dates DST and last-published cancellation pattern',
        () async {
          var content = masterContent(kind: kind);
          content = content.copyWith(
            recurrence: content.recurrence!.copyWith(
              inclusions: [
                originalDay(26).copyWith(
                  kind: kind,
                  start: masterTiming(kind: kind, day: 26).start,
                  zoneId: content.timing.zoneId,
                ),
              ],
              exclusions: [
                originalDay(28).copyWith(
                  kind: kind,
                  start: masterTiming(kind: kind, day: 28).start,
                  zoneId: content.timing.zoneId,
                ),
              ],
            ),
          );
          final id = await masterEvent(content),
              first = await service.saveAndNotify(masterRequest(id, content));
          final published = await publication(first.publicationId);
          final message = parseIcalendarSchedulingMessage(
            utf8.encode(published.payload),
          );
          expect(message.events.length, 1);
          expect(message.events.single.isOverride, false);
          expect(
            props(message.events.single, 'RRULE').single.value,
            contains('COUNT=4'),
          );
          expect(
            props(message.events.single, 'RDATE').single.value,
            contains('20260326'),
          );
          expect(
            props(message.events.single, 'EXDATE').single.value,
            contains('20260328'),
          );
          if (kind == CalendarEventTimeKind.date) {
            expect(message.events.single.recurrence!.dateSet, isNotNull);
          } else {
            expect(message.events.single.recurrence!.timedSet, isNotNull);
            expect(
              message.events.single.startTime!.zoneId,
              content.timing.zoneId,
            );
          }
          if (kind == CalendarEventTimeKind.zoned) {
            final preview = await service.previewOccurrences(
              CalendarEventOccurrenceQuery(
                eventId: id,
                expectedRevision: 2,
                fromUtc: DateTime.utc(2026, 3, 25),
                untilUtc: DateTime.utc(2026, 4, 1),
                fieldGroups: [],
              ),
            );
            expect(
              preview.occurrences
                  .firstWhere((v) => v.originalStart.day == 27)
                  .startUtc!
                  .hour,
              8,
            );
            expect(
              preview.occurrences
                  .firstWhere((v) => v.originalStart.day == 29)
                  .startUtc!
                  .hour,
              7,
            );
            expect(preview.occurrences.every((v) => v.start.hour == 9), true);
          }
          final draft = content.copyWith(
            summary: 'Private pattern edit',
            recurrence: content.recurrence!.copyWith(
              rule: masterRule(count: 6),
            ),
          );
          await service.updateEvent(
            CalendarEventUpdateRequest(
              eventId: id,
              expectedRevision: 2,
              content: draft,
            ),
          );
          expect((await service.schedulingStatus(id)).hasLocalChanges, true);
          final cancelled = await service.cancelAndNotify(
            cancelRequest(id, revision: 3),
          );
          final outgoing = parseIcalendarSchedulingMessage(
            utf8.encode((await publication(cancelled.publicationId)).payload),
          );
          expect(outgoing.method, IcalendarSchedulingMethod.cancel);
          expect(
            props(outgoing.events.single, 'RRULE').single.value,
            contains('COUNT=4'),
          );
          expect(outgoing.events.single.summary!.value, 'Published master');
          expect((await eventData(id)).content.recurrence!.rule!.count, 6);
          expect((await eventData(id)).content.summary, 'Private pattern edit');
          await CalendarModule.runSchedulingMaintenance(session);
          expect(
            transport.submissions.single.publicationId,
            cancelled.publicationId,
          );
        },
      );
    }
    for (final kind in [
      CalendarEventTimeKind.utc,
      CalendarEventTimeKind.zoned,
    ]) {
      test(
        'recurring ${kind.name} PERIOD-only master preserves earlier duration additions',
        () async {
          final timing = masterTiming(kind: kind);
          final content = CalendarEventContent(
            summary: 'Period master',
            timing: timing,
            periods: [
              masterTiming(
                kind: kind,
                day: 26,
              ).copyWith(duration: CalendarEventDuration(hours: 2)),
            ],
          );
          final id = await masterEvent(content);
          final receipt = await service.saveAndNotify(
            masterRequest(id, content),
          );
          final message = parseIcalendarSchedulingMessage(
            utf8.encode((await publication(receipt.publicationId)).payload),
          );
          final rdate = props(message.events.single, 'RDATE').single;
          expect(
            rdate.parameters
                .singleWhere((p) => p.canonicalName == 'VALUE')
                .values,
            ['PERIOD'],
          );
          expect(rdate.value, contains('20260326T090000'));
          expect(rdate.value, endsWith('/PT2H'));
          expect(props(message.events.single, 'RRULE'), isEmpty);
          expect(message.events.single.recurrence!.timedSet, isNotNull);
          await expectLater(
            service.updateEvent(
              CalendarEventUpdateRequest(
                eventId: id,
                expectedRevision: 2,
                content: content.copyWith(periods: null),
                replacePeriods: true,
              ),
            ),
            failure(CalendarFailureCode.dependencyConflict),
          );
        },
      );
    }
    for (final kind in [
      CalendarEventTimeKind.date,
      CalendarEventTimeKind.utc,
    ]) {
      test(
        'recurring ${kind.name} UNTIL and Sunday WKST keep the existing rule profile',
        () async {
          final content = masterContent(kind: kind).copyWith(
            recurrence: CalendarEventRecurrence(
              rule: masterRule(
                count: null,
                frequency: CalendarEventFrequency.weekly,
                weekStart: 7,
                untilDate: kind == CalendarEventTimeKind.date
                    ? CalendarEventCivil(year: 2026, month: 4, day: 5)
                    : null,
                untilUtc: kind == CalendarEventTimeKind.utc
                    ? DateTime.utc(2026, 4, 5, 9)
                    : null,
                byDay: [CalendarEventByDay(weekday: 5)],
              ),
              inclusions: [],
              exclusions: [],
            ),
          );
          final id = await masterEvent(content),
              receipt = await service.saveAndNotify(masterRequest(id, content));
          final wire = parseIcalendarSchedulingMessage(
            utf8.encode((await publication(receipt.publicationId)).payload),
          );
          final text = props(wire.events.single, 'RRULE').single.value;
          expect(text, contains('WKST=SU'));
          expect(
            text,
            contains(
              kind == CalendarEventTimeKind.date
                  ? 'UNTIL=20260405'
                  : 'UNTIL=20260405T090000Z',
            ),
          );
          expect(text, isNot(contains('COUNT=')));
        },
      );
    }
    test('bound masters accept local pattern edits and explicit publication reuses the newer saved version', () async {
      final initial = masterContent(), id = await masterEvent(masterContent());
      final firstCommand = masterRequest(id, initial),
          first = await service.saveAndNotify(firstCommand);
      final changed = masterContent(count: 6, summary: 'New master');
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: 2,
          content: changed,
        ),
      );
      final before = (await eventData(id)).protocolState!.version;
      final next = await service.saveAndNotify(
        masterRequest(id, changed, revision: 3),
      );
      expect((await publication(next.publicationId)).sequence, before.sequence);
      expect(
        jsonEncode((await eventData(id)).protocolState!.version.toJson()),
        jsonEncode(before.toJson()),
      );
      expect(
        (await service.saveAndNotify(masterRequest(id, changed, revision: 4)))
            .unchanged,
        true,
      );
      expect(
        (await service.saveAndNotify(firstCommand)).publicationId,
        first.publicationId,
      );
      expect((await eventData(id)).content.recurrence!.rule!.count, 6);
      expect((await publications()).length, 2);
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions.single.publicationId, next.publicationId);
    });
    test('mode changes reject through native and publication paths without removing patterns', () async {
      final single = await event();
      await service.saveAndNotify(request(single));
      await expectLater(
        service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: single,
            expectedRevision: 2,
            content: masterContent(),
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await expectLater(
        service.saveAndNotify(
          masterRequest(single, masterContent(), revision: 2),
        ),
        failure(CalendarFailureCode.validation),
      );
      final content = masterContent(),
          recurring = await masterEvent(masterContent());
      await service.saveAndNotify(masterRequest(recurring, content));
      await expectLater(
        service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: recurring,
            expectedRevision: 2,
            content: content.copyWith(recurrence: null),
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await expectLater(
        service.saveAndNotify(
          masterRequest(
            recurring,
            content.copyWith(recurrence: null),
            revision: 2,
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect((await eventData(recurring)).content.recurrence!.rule!.count, 4);
    });
    test('first recurring publication cannot silently convert an existing single event', () async {
      final id = await event();
      await expectLater(
        service.saveAndNotify(masterRequest(id, masterContent())),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarSchedulingMeetingRecord.db.count(session), 0);
      expect((await eventData(id)).content.recurrence, isNull);
    });
    test(
      'stored occurrence state rejects first REQUEST without being cleared',
      () async {
        final content = masterContent(),
            id = await masterEvent(masterContent());
        await service.changeOccurrence(
          CalendarEventOccurrenceChange(
            eventId: id,
            expectedRevision: 1,
            originalStart: originalDay(28),
            action: CalendarEventOccurrenceAction.cancelSingle,
          ),
        );
        final before = jsonEncode((await eventData(id)).toJson());
        await expectLater(
          service.saveAndNotify(masterRequest(id, content, revision: 2)),
          failure(CalendarFailureCode.validation),
        );
        expect(jsonEncode((await eventData(id)).toJson()), before);
        expect((await publications()), isEmpty);
        await service.changeOccurrence(
          CalendarEventOccurrenceChange(
            eventId: id,
            expectedRevision: 2,
            originalStart: originalDay(28),
            action: CalendarEventOccurrenceAction.restoreSingle,
          ),
        );
        await service.saveAndNotify(masterRequest(id, content, revision: 3));
        expect((await publications()).length, 1);
      },
    );
    test('whole-series cancellation preserves private single future content and protocol exception state', () async {
      final content = masterContent(count: 6),
          id = await masterEvent(masterContent(count: 6));
      final command = masterRequest(id, content),
          published = await service.saveAndNotify(command);
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: 2,
          originalStart: originalDay(28),
          action: CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: originalDay(28)
              .copyWith(duration: CalendarEventDuration(days: 2)),
        ),
      );
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: 3,
          originalStart: originalDay(29),
          action: CalendarEventOccurrenceAction.cancelSingle,
        ),
      );
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: 4,
          originalStart: originalDay(30),
          action: CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: originalDay(31),
        ),
      );
      await service.changeOccurrenceContent(
        CalendarEventOccurrenceContentRequest(
          eventId: id,
          expectedRevision: 5,
          originalStart: originalDay(28),
          changes: [
            CalendarEventOccurrenceContentChange(
              field: CalendarEventContentField.summary,
              action: CalendarEventContentAction.setValue,
              text: 'Private exception',
            ),
          ],
        ),
      );
      final before = await eventData(id),
          jsonBefore = jsonEncode(before.toJson());
      expect((await service.schedulingStatus(id)).hasLocalChanges, true);
      await expectLater(
        service.saveAndNotify(masterRequest(id, content, revision: 6)),
        failure(CalendarFailureCode.validation),
      );
      expect(jsonEncode((await eventData(id)).toJson()), jsonBefore);
      expect(
        (await service.saveAndNotify(command)).publicationId,
        published.publicationId,
      );
      final contexts = <CalendarSchedulingPolicyContext>[];
      host.onCheck = contexts.add;
      final cancelled = await service.cancelAndNotify(
        cancelRequest(id, revision: 6),
      );
      expect(
        jsonEncode(policy.lastEventRequest!.proposedTimingOverrides!.toJson()),
        jsonEncode(before.timingOverrides!.toJson()),
      );
      final after = await eventData(id);
      expect(
        jsonEncode(after.timingOverrides!.toJson()),
        jsonEncode(before.timingOverrides!.toJson()),
      );
      expect(
        jsonEncode(
          after.protocolState!.overrides.map((v) => v.toJson()).toList(),
        ),
        jsonEncode(
          before.protocolState!.overrides.map((v) => v.toJson()).toList(),
        ),
      );
      expect(
        contexts.every(
          (v) =>
              jsonEncode(v.proposedEvent.timingOverrides!.toJson()) ==
                  jsonEncode(before.timingOverrides!.toJson()) &&
              v.outgoingEvent.timingOverrides == null &&
              v.outgoingEvent.protocolState!.overrides.isEmpty,
        ),
        true,
      );
      final wire = parseIcalendarSchedulingMessage(
        utf8.encode((await publication(cancelled.publicationId)).payload),
      );
      expect(wire.events.length, 1);
      expect(wire.events.single.isOverride, false);
      expect(wire.method, IcalendarSchedulingMethod.cancel);
      expect(
        (await publication(cancelled.publicationId)).payload,
        isNot(contains('Private exception')),
      );
      expect(
        (await service.cancelAndNotify(cancelRequest(id, revision: 7)))
            .unchanged,
        true,
      );
      await service.changeEventStatus(
        CalendarEventStatusRequest(
          eventId: id,
          expectedRevision: 7,
          status: CalendarEventStatus.confirmed,
        ),
      );
      await expectLater(
        service.saveAndNotify(masterRequest(id, content, revision: 8)),
        failure(CalendarFailureCode.validation),
      );
      await CalendarModule.runSchedulingMaintenance(session);
      expect(
        transport.submissions.single.publicationId,
        cancelled.publicationId,
      );
      expect((await eventData(id)).timingOverrides!.singles.length, 2);
    });
    test(
      'bound pattern edits still reject orphaning native exceptions',
      () async {
        final content = masterContent(),
            id = await masterEvent(masterContent());
        await service.saveAndNotify(masterRequest(id, content));
        await service.changeOccurrence(
          CalendarEventOccurrenceChange(
            eventId: id,
            expectedRevision: 2,
            originalStart: originalDay(28),
            action: CalendarEventOccurrenceAction.cancelSingle,
          ),
        );
        final before = jsonEncode((await eventData(id)).toJson());
        await expectLater(
          service.updateEvent(
            CalendarEventUpdateRequest(
              eventId: id,
              expectedRevision: 3,
              content: masterContent(count: 1),
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(jsonEncode((await eventData(id)).toJson()), before);
      },
    );
    test('corrupt private checkpoints fail without exposing source text during native pattern edits', () async {
      final content = masterContent(), id = await masterEvent(masterContent());
      final receipt = await service.saveAndNotify(masterRequest(id, content));
      final saved = await publication(receipt.publicationId);
      saved.snapshot = '{malformed PrivateCheckpointText';
      await CalendarSchedulingPublicationRecord.db.updateRow(session, saved);
      try {
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: id,
            expectedRevision: 2,
            content: masterContent(count: 6),
          ),
        );
        fail('Corrupt checkpoint was accepted');
      } on CalendarException catch (e) {
        expect(e.code, CalendarFailureCode.unavailable);
        expect(e.message, isNot(contains('PrivateCheckpointText')));
      }
      expect((await eventData(id)).content.recurrence!.rule!.count, 4);
    });
    test('recurring publication final denial and payload bounds roll back pattern changes', () async {
      final content = masterContent(), id = await masterEvent(masterContent());
      await service.saveAndNotify(masterRequest(id, content));
      final before = jsonEncode((await eventData(id)).toJson());
      host.denyFinal = true;
      await expectLater(
        service.saveAndNotify(
          masterRequest(id, masterContent(count: 6), revision: 2),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denyFinal = false;
      install(options: CalendarSchedulingOptions(maxPayloadBytes: 1024));
      await expectLater(
        service.saveAndNotify(
          masterRequest(
            id,
            masterContent(count: 6, summary: 'x' * 2000),
            revision: 2,
          ),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect(jsonEncode((await eventData(id)).toJson()), before);
      expect((await publications()).length, 1);
    });

    for (final kind in [
      CalendarEventTimeKind.date,
      CalendarEventTimeKind.utc,
      CalendarEventTimeKind.zoned,
    ]) {
      test(
        'cancellation preserves published ${kind.name} timing and hides saved drafts from recipients',
        () async {
          final id = await event();
          final timing = CalendarEventTiming(
            kind: kind,
            start: CalendarEventCivil(
              year: 2026,
              month: 3,
              day: 29,
              hour: kind == CalendarEventTimeKind.date ? 0 : 2,
            ),
            zoneId: kind == CalendarEventTimeKind.zoned
                ? 'Europe/Stockholm'
                : null,
          );
          final first = await service.saveAndNotify(
            request(id).copyWith(
              content: eventInput(summary: 'Published')
                  .copyWith(timing: timing),
            ),
          );
          final before = await publication(first.publicationId);
          final draft = eventInput(summary: 'Private local draft').copyWith(
            timing: timing.copyWith(start: timing.start.copyWith(day: 30)),
            description: 'Unsent description',
            location: 'Unsent place',
          );
          await service.updateEvent(
            CalendarEventUpdateRequest(
              eventId: id,
              expectedRevision: 2,
              content: draft,
            ),
          );
          final versionBefore = (await eventData(id)).protocolState!.version;
          final contexts = <CalendarSchedulingPolicyContext>[];
          host.onCheck = contexts.add;
          final receipt = await service.cancelAndNotify(
            cancelRequest(id, revision: 3),
          );
          expect(receipt.eventRevision, 4);
          final current = await eventData(id),
              cancelled = await publication(receipt.publicationId);
          expect(current.content.summary, 'Private local draft');
          expect(current.content.description, 'Unsent description');
          expect(current.content.timing.start.day, 30);
          expect(current.content.status, CalendarEventStatus.cancelled);
          final message = parseIcalendarSchedulingMessage(
            utf8.encode(cancelled.payload),
          );
          expect(message.method, IcalendarSchedulingMethod.cancel);
          expect(message.events.single.status, IcalendarEventStatus.cancelled);
          expect(message.events.single.summary!.value, 'Published');
          expect(cancelled.payload, isNot(contains('Unsent')));
          expect(cancelled.payload, isNot(contains('Private local draft')));
          expect(
            message.events.single.startDate?.day ??
                message.events.single.startTime!.civil.date.day,
            29,
          );
          expect(cancelled.protocolUid, before.protocolUid);
          expect(cancelled.recipients, before.recipients);
          expect(cancelled.sequence, greaterThan(versionBefore.sequence!));
          expect(cancelled.sequence, greaterThan(before.sequence));
          expect(cancelled.stamp.isBefore(versionBefore.stamp), false);
          expect(
            contexts.every(
              (c) =>
                  c.intent.method == 'CANCEL' &&
                  c.currentEvent.content.summary == 'Private local draft' &&
                  c.proposedEvent.content.summary == 'Private local draft' &&
                  c.proposedEvent.content.status ==
                      CalendarEventStatus.cancelled &&
                  c.outgoingEvent.content.summary == 'Published',
            ),
            true,
          );
          final status = await service.schedulingStatus(id);
          expect(status.method, 'CANCEL');
          expect(status.hasLocalChanges, true);
          await CalendarModule.runSchedulingMaintenance(session);
          expect(transport.submissions.single.payload, cancelled.payload);
          expect(
            (await service.schedulingStatus(id)).deliveries.single.state,
            CalendarSchedulingDeliveryState.accepted,
          );
        },
      );
    }
    for (final permission in [
      CalendarPermission.cancelScheduling,
      CalendarPermission.changeEventStatus,
      CalendarPermission.readEvent,
      CalendarPermission.readEventSource,
    ]) {
      test('cancellation independently requires ${permission.name}', () async {
        final id = await event();
        await service.saveAndNotify(request(id));
        policy.denied.add(permission);
        await expectLater(
          service.cancelAndNotify(cancelRequest(id)),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await publications()).length, 1);
        expect(
          (await eventData(id)).content.status,
          CalendarEventStatus.confirmed,
        );
        expect(
          (await CalendarEventRecord.db.findById(session, id))!.revision,
          2,
        );
      });
    }
    test('cancellation does not require ordinary text editing or REQUEST publication permission', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      policy.denied.addAll([
        CalendarPermission.updateEvent,
        CalendarPermission.publishScheduling,
      ]);
      await service.cancelAndNotify(cancelRequest(id));
      expect(
        (await eventData(id)).content.status,
        CalendarEventStatus.cancelled,
      );
    });
    test('cancellation final host denial and withheld disclosure roll back status and all intents', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      policy.eventGrants.remove(CalendarEventFieldGroup.location);
      await expectLater(
        service.cancelAndNotify(cancelRequest(id)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.eventGrants = CalendarEventFieldGroup.values.toSet();
      host.denyFinal = true;
      await expectLater(
        service.cancelAndNotify(cancelRequest(id)),
        failure(CalendarFailureCode.accessDenied),
      );
      expect((await publications()).length, 1);
      expect(
        (await eventData(id)).content.status,
        CalendarEventStatus.confirmed,
      );
      expect((await CalendarEventRecord.db.findById(session, id))!.revision, 2);
    });
    test('unbound cancellation, stale revisions and cross-method command reuse reject', () async {
      final id = await event();
      await expectLater(
        service.cancelAndNotify(cancelRequest(id, revision: 1)),
        failure(CalendarFailureCode.validation),
      );
      final original = request(id);
      await service.saveAndNotify(original);
      await expectLater(
        service.cancelAndNotify(cancelRequest(id, revision: 1)),
        failure(CalendarFailureCode.staleRevision),
      );
      await expectLater(
        service.cancelAndNotify(
          cancelRequest(id).copyWith(commandId: original.commandId),
        ),
        failure(CalendarFailureCode.validation),
      );
      final command = cancelRequest(id);
      await service.cancelAndNotify(command);
      await expectLater(
        service.saveAndNotify(
          request(id, revision: 3).copyWith(commandId: command.commandId),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect((await publications()).length, 2);
    });
    test('cancellation exact retries and semantic no-ops preserve revisions generation and protocol state', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      final command = cancelRequest(id),
          receipt = await service.cancelAndNotify(command);
      final before = jsonEncode((await eventData(id)).toJson());
      final meetingBefore = jsonEncode(
        (await CalendarSchedulingMeetingRecord.db.findFirstRow(session))!
            .toJson(),
      );
      final changes = observer.changes;
      expect(
        (await service.cancelAndNotify(command)).publicationId,
        receipt.publicationId,
      );
      expect(
        (await service.cancelAndNotify(cancelRequest(id, revision: 3)))
            .unchanged,
        true,
      );
      expect(jsonEncode((await eventData(id)).toJson()), before);
      expect(
        jsonEncode(
          (await CalendarSchedulingMeetingRecord.db.findFirstRow(session))!
              .toJson(),
        ),
        meetingBefore,
      );
      expect(observer.changes, changes);
      expect((await publications()).length, 2);
      policy.denied.add(CalendarPermission.cancelScheduling);
      await expectLater(
        service.cancelAndNotify(command),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('local reopen keeps CANCEL eligible while explicit REQUEST supersedes it and advances version', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      final cancelled = await service.cancelAndNotify(cancelRequest(id));
      await service.changeEventStatus(
        CalendarEventStatusRequest(
          eventId: id,
          expectedRevision: 3,
          status: CalendarEventStatus.confirmed,
        ),
      );
      expect((await service.schedulingStatus(id)).method, 'CANCEL');
      await CalendarModule.runSchedulingMaintenance(session);
      expect(
        parseIcalendarSchedulingMessage(
          utf8.encode(transport.submissions.single.payload),
        ).method,
        IcalendarSchedulingMethod.cancel,
      );
      final reopened = await service.saveAndNotify(request(id, revision: 4));
      expect(
        (await publication(reopened.publicationId)).sequence,
        greaterThan((await publication(cancelled.publicationId)).sequence),
      );
      await CalendarModule.runSchedulingMaintenance(session);
      expect(
        parseIcalendarSchedulingMessage(
          utf8.encode(transport.submissions.last.payload),
        ).method,
        IcalendarSchedulingMethod.request,
      );
      expect((await service.schedulingStatus(id)).hasLocalChanges, false);
    });
    test('explicit reopen changes lifecycle atomically and supersedes an unsent cancellation', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      final cancelled = await service.cancelAndNotify(cancelRequest(id));
      policy.denied.add(CalendarPermission.changeEventStatus);
      await expectLater(
        service.saveAndNotify(request(id, revision: 3)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      await service.saveAndNotify(request(id, revision: 3));
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions.length, 1);
      expect(
        parseIcalendarSchedulingMessage(
          utf8.encode(transport.submissions.single.payload),
        ).method,
        IcalendarSchedulingMethod.request,
      );
      final oldDelivery = (await CalendarSchedulingDeliveryRecord.db
          .findFirstRow(
            session,
            where: (t) => t.publicationId.equals(cancelled.publicationId),
          ))!;
      expect(oldDelivery.state, CalendarSchedulingDeliveryState.superseded);
    });
    test(
      'cancellation version overflow and capacity fail atomically',
      () async {
        final id = await event();
        await service.saveAndNotify(request(id));
        final data = await eventData(id);
        data.protocolState = data.protocolState!.copyWith(
          version: data.protocolState!.version.copyWith(sequence: 2147483647),
        );
        await CalendarEventDataRecord.db.updateRow(session, data);
        await expectLater(
          service.cancelAndNotify(cancelRequest(id)),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(
          (await eventData(id)).content.status,
          CalendarEventStatus.confirmed,
        );
        expect((await publications()).length, 1);
        data.protocolState = data.protocolState!.copyWith(
          version: data.protocolState!.version.copyWith(sequence: 1),
        );
        await CalendarEventDataRecord.db.updateRow(session, data);
        install(options: CalendarSchedulingOptions(maxPendingPublications: 1));
        await expectLater(
          service.cancelAndNotify(cancelRequest(id)),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(
          (await eventData(id)).content.status,
          CalendarEventStatus.confirmed,
        );
        expect((await publications()).length, 1);
      },
    );
    test('cancellation withdrawn authority blocks dispatch and uncertain retries keep exact cancellation identity', () async {
      final id = await event();
      await service.saveAndNotify(request(id));
      await service.cancelAndNotify(cancelRequest(id));
      host.denied = true;
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions, isEmpty);
      expect(
        (await service.schedulingStatus(id)).deliveries.single.state,
        CalendarSchedulingDeliveryState.blocked,
      );
      host.denied = false;
      await service.saveAndNotify(request(id, revision: 3));
      await service.cancelAndNotify(cancelRequest(id, revision: 4));
      transport.outcome = CalendarSchedulingTransportOutcome.uncertain;
      await CalendarModule.runSchedulingMaintenance(session);
      await due();
      transport.outcome = CalendarSchedulingTransportOutcome.accepted;
      await CalendarModule.runSchedulingMaintenance(session);
      expect(transport.submissions.length, 2);
      expect(
        transport.submissions.first.deliveryKey,
        transport.submissions.last.deliveryKey,
      );
      expect(
        transport.submissions.first.payload,
        transport.submissions.last.payload,
      );
      expect(
        parseIcalendarSchedulingMessage(
          utf8.encode(transport.submissions.first.payload),
        ).method,
        IcalendarSchedulingMethod.cancel,
      );
    });

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
