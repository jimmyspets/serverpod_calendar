import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_wire_output.dart'
    show EventComponentWriter;
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'scheduling_test.dart' show SchedulingHost, SchedulingTransport;
import 'scheduling_replies_test.dart' show ReplyHost;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('recurring master attendee replies', (builder, endpoints) {
    late Session session;
    late CalendarService service;
    late ReplyHost host;
    late TestPolicy policy;
    late UuidValue id;
    late CalendarEventContent content;
    late CalendarSchedulingPublicationRecord carrier;
    late IcalendarSchedulingMessage active;
    late int masterSequence;
    var stampCounter = 0;
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
      host = ReplyHost();
      stampCounter = 0;
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        scheduling: CalendarSchedulingRuntime(
          host: SchedulingHost(),
          transport: SchedulingTransport(),
          replies: CalendarSchedulingReplyRuntime(host: host),
        ),
      );
      service = CalendarModule.service(session);
    });
    CalendarEventRule rule({int count = 4}) => CalendarEventRule(
      frequency: CalendarEventFrequency.daily,
      count: count,
      byDay: [],
      byMonthDay: [],
      byYearDay: [],
      byWeekNo: [],
      byMonth: [],
      byHour: [],
      byMinute: [],
      bySetPosition: [],
    );
    CalendarEventTiming timing(
      int day, {
      CalendarEventTimeKind kind = CalendarEventTimeKind.date,
    }) => CalendarEventTiming(
      kind: kind,
      start: CalendarEventCivil(
        year: 2026,
        month: 11,
        day: day,
        hour: kind == CalendarEventTimeKind.date ? 0 : 9,
      ),
      zoneId: kind == CalendarEventTimeKind.zoned ? 'Europe/Stockholm' : null,
    );
    Future<int> revision() async =>
        (await service.getEvent(id, CalendarEventFieldGroup.values)).revision;
    Future<void> capture(CalendarSchedulingReceipt receipt) async {
      carrier = (await CalendarSchedulingPublicationRecord.db.findById(
        session,
        receipt.publicationId,
      ))!;
      final message = parseIcalendarSchedulingMessage(
        utf8.encode(carrier.payload),
      );
      final masters = message.events.where((e) => !e.isOverride).toList();
      if (masters.isNotEmpty) {
        masterSequence = masters.single.sequence!;
        if (message.method == IcalendarSchedulingMethod.request) {
          active = message;
        }
      }
    }

    Future<void> publish({CalendarEventContent? value}) async {
      await capture(
        await service.saveAndNotify(
          CalendarSchedulingSaveRequest(
            eventId: id,
            expectedRevision: await revision(),
            commandId: const Uuid().v4obj(),
            content: value ?? content,
            recipients: ['mailto:bob@example.invalid'],
          ),
        ),
      );
    }

    Future<void> seed({
      CalendarEventTimeKind kind = CalendarEventTimeKind.date,
      bool periods = false,
    }) async {
      final parent = (await service.create(createInput()))!.calendarId;
      content = CalendarEventContent(
        summary: 'Published master',
        timing: timing(2, kind: kind),
        recurrence: CalendarEventRecurrence(
          rule: rule(),
          inclusions: [],
          exclusions: [],
        ),
        periods: periods
            ? [
                timing(
                  8,
                  kind: kind,
                ).copyWith(duration: CalendarEventDuration(hours: 2)),
              ]
            : null,
      );
      id = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: content),
      ))!.eventId;
      await publish();
    }

    IcalendarSchedulingEvent getMaster() =>
        active.events.singleWhere((e) => !e.isOverride);
    List<IcalendarSyntaxProperty> properties(Set<String> names) => getMaster()
        .source
        .entries
        .whereType<IcalendarSyntaxProperty>()
        .where((p) => names.contains(p.canonicalName))
        .toList();
    Future<CalendarSchedulingReplyReceipt> reply({
      int? sequence,
      String? key,
      List<IcalendarSyntaxProperty> ordinary = const [],
      String participation = 'ACCEPTED',
      CalendarEventTiming? original,
      String? stamp,
    }) async {
      final message = IcalendarSyntaxDocument([
        IcalendarSyntaxComponent('VCALENDAR', [
          IcalendarSyntaxProperty('VERSION', '2.0'),
          IcalendarSyntaxProperty('PRODID', '-//Synthetic recurring reply//EN'),
          IcalendarSyntaxProperty('METHOD', 'REPLY'),
          ...active.source.components.single.entries
              .whereType<IcalendarSyntaxComponent>()
              .where((c) => c.canonicalName == 'VTIMEZONE'),
          IcalendarSyntaxComponent('VEVENT', [
            IcalendarSyntaxProperty('UID', encodeIcalendarText(active.uid)),
            IcalendarSyntaxProperty(
              'DTSTAMP',
              stamp ??
                  '20261027T1200${(stampCounter++).toString().padLeft(2, '0')}Z',
            ),
            IcalendarSyntaxProperty(
              'SEQUENCE',
              '${sequence ?? masterSequence}',
            ),
            IcalendarSyntaxProperty(
              'ORGANIZER',
              'mailto:alice@example.invalid',
            ),
            IcalendarSyntaxProperty(
              'ATTENDEE',
              'mailto:bob@example.invalid',
              parameters: [
                IcalendarSyntaxParameter('PARTSTAT', [participation]),
              ],
            ),
            if (original != null)
              EventComponentWriter().time('RECURRENCE-ID', original),
            ...ordinary,
          ]),
        ]),
      ]);
      return CalendarModule.receiveSchedulingReply(
        session,
        CalendarSchedulingReplyDelivery(
          scopeKey: 'test:alice',
          eventId: id,
          namespace: 'synthetic-recurring',
          deliveryKey: key ?? const Uuid().v4(),
          originReference: 'verified-bob',
          bytes: serializeIcalendarSyntax(message),
        ),
      );
    }

    Future<CalendarSchedulingResponsesView> view() =>
        service.schedulingResponses(id);
    Future<CalendarSchedulingReplySourceRecord> source(
      UuidValue sourceId,
    ) async => (await CalendarSchedulingReplySourceRecord.db.findById(
      session,
      sourceId,
    ))!;
    Future<void> terminal() => CalendarModule.runSchedulingMaintenance(session);
    Future<void> cancelPoint(int day) async {
      await terminal();
      await capture(
        await service.cancelOccurrenceAndNotify(
          CalendarSchedulingOccurrenceCancelRequest(
            eventId: id,
            expectedRevision: await revision(),
            commandId: const Uuid().v4obj(),
            originalStart: timing(day),
          ),
        ),
      );
    }

    Future<void> restorePoint(int day) async {
      await terminal();
      await capture(
        await service.restoreOccurrenceAndNotify(
          CalendarSchedulingOccurrenceRestoreRequest(
            eventId: id,
            expectedRevision: await revision(),
            commandId: const Uuid().v4obj(),
            originalStart: timing(day),
          ),
        ),
      );
    }

    for (final kind in [
      CalendarEventTimeKind.date,
      CalendarEventTimeKind.utc,
      CalendarEventTimeKind.zoned,
    ]) {
      test(
        '${kind.name} master minimal and complete recurrence replies preserve source',
        () async {
          await seed(kind: kind);
          expect(
            (await reply()).outcome,
            CalendarSchedulingReplyOutcome.applied,
          );
          final next = await reply(ordinary: properties({'DTSTART', 'RRULE'}));
          expect(next.outcome, CalendarSchedulingReplyOutcome.applied);
          final current = await view();
          expect(current.recurring, isTrue);
          expect(current.responses.single.isCurrent, isTrue);
          expect(host.contexts.last.publishedMaster.sequence, masterSequence);
          expect(
            host.contexts.last.publishedMessage.events.single.uid,
            active.uid,
          );
          expect(
            (await service.schedulingReplySource(
              id,
              next.sourceId,
            )).normalizedSource,
            contains('RRULE:'),
          );
        },
      );
    }

    test('canonical rule equality accepts explicit defaults and preserves mismatched source as conflict', () async {
      await seed();
      final start = properties({'DTSTART'});
      final accepted = await reply(
        ordinary: [
          ...start,
          IcalendarSyntaxProperty(
            'RRULE',
            'COUNT=4;INTERVAL=1;WKST=MO;FREQ=DAILY',
          ),
        ],
      );
      expect(accepted.outcome, CalendarSchedulingReplyOutcome.applied);
      expect(
        (await reply(
          ordinary: [
            ...start,
            IcalendarSyntaxProperty('RRULE', 'FREQ=DAILY;COUNT=3'),
          ],
        )).outcome,
        CalendarSchedulingReplyOutcome.conflict,
      );
      expect((await view()).responses.single.sourceId, accepted.sourceId);
    });

    test('PERIOD additions compare preserved end-duration forms without flattening', () async {
      await seed(kind: CalendarEventTimeKind.utc, periods: true);
      expect(
        (await reply(ordinary: properties({'DTSTART', 'RDATE'}))).outcome,
        CalendarSchedulingReplyOutcome.applied,
      );
      expect(
        (await reply(
          ordinary: [
            ...properties({'DTSTART'}),
            IcalendarSyntaxProperty(
              'RDATE',
              '20261108T090000Z/20261108T110000Z',
              parameters: [
                IcalendarSyntaxParameter('VALUE', ['PERIOD']),
              ],
            ),
          ],
        )).outcome,
        CalendarSchedulingReplyOutcome.conflict,
      );
    });

    test('native drafts never replace the published master used for response matching', () async {
      await seed();
      final changed = content.copyWith(
        summary: 'Private draft',
        recurrence: CalendarEventRecurrence(
          rule: rule(count: 2),
          inclusions: [],
          exclusions: [],
        ),
      );
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: id,
          expectedRevision: await revision(),
          content: changed,
        ),
      );
      expect(
        (await reply(ordinary: properties({'DTSTART', 'RRULE', 'SUMMARY'})))
            .outcome,
        CalendarSchedulingReplyOutcome.applied,
      );
      expect(host.contexts.last.currentEvent.content.summary, 'Private draft');
      expect(
        host.contexts.last.publishedEvent.content.summary,
        'Published master',
      );
    });

    test('partial CANCEL and restore preserve master currentness, inactivity and version', () async {
      await seed();
      final first = await reply();
      final originalSequence = masterSequence;
      await cancelPoint(3);
      expect(carrier.sequence, greaterThan(originalSequence));
      expect((await view()).publishedCancelled, isFalse);
      expect((await view()).publishedSequence, originalSequence);
      expect((await view()).publicationId, carrier.id);
      expect((await view()).responses.single.isCurrent, isTrue);
      expect((await source(first.sourceId)).inactiveAt, isNull);
      expect((await reply()).outcome, CalendarSchedulingReplyOutcome.applied);
      expect(
        host.contexts.last.latestPublicationKind,
        CalendarSchedulingPublicationKind.occurrenceCancel,
      );
      expect(
        host.contexts.last.publishedMessage.method,
        IcalendarSchedulingMethod.request,
      );
      await restorePoint(3);
      expect((await view()).publishedSequence, originalSequence);
      expect((await view()).responses.single.isCurrent, isTrue);
    });

    test(
      'v6 reopening masks and complete restoration use the actual full master',
      () async {
        await seed();
        await reply();
        await cancelPoint(3);
        await terminal();
        await capture(
          await service.cancelAndNotify(
            CalendarSchedulingCancelRequest(
              eventId: id,
              expectedRevision: await revision(),
              commandId: const Uuid().v4obj(),
            ),
          ),
        );
        expect((await view()).publishedCancelled, isTrue);
        expect(
          (await reply()).outcome,
          CalendarSchedulingReplyOutcome.unappliedResult,
        );
        await terminal();
        await capture(
          await service.reopenPublishedAndNotify(
            CalendarSchedulingReopenRequest(
              eventId: id,
              expectedRevision: await revision(),
              commandId: const Uuid().v4obj(),
            ),
          ),
        );
        final reopened = await reply(
          ordinary: properties({'DTSTART', 'RRULE', 'EXDATE'}),
        );
        expect(reopened.outcome, CalendarSchedulingReplyOutcome.applied);
        final reopenedSequence = masterSequence;
        expect(
          getMaster().source.entries.whereType<IcalendarSyntaxProperty>().any(
            (p) => p.canonicalName == 'EXDATE',
          ),
          isTrue,
        );
        await cancelPoint(4);
        expect((await view()).publishedSequence, reopenedSequence);
        expect((await source(reopened.sourceId)).inactiveAt, isNull);
        await restorePoint(3);
        expect(masterSequence, greaterThan(reopenedSequence));
        expect((await view()).responses.single.isCurrent, isFalse);
        expect((await source(reopened.sourceId)).inactiveAt, isNotNull);
        expect(
          (await reply(ordinary: properties({'DTSTART', 'RRULE', 'EXDATE'})))
              .outcome,
          CalendarSchedulingReplyOutcome.applied,
        );
        expect(
          host.contexts.last.currentEvent.content.recurrence!.exclusions,
          isEmpty,
        );
        expect(
          host.contexts.last.latestPublicationKind,
          CalendarSchedulingPublicationKind.occurrenceRestoreWithMaster,
        );
      },
    );

    test('complete occurrence bundles retain unchanged master ordering and full host context', () async {
      await seed();
      final first = await reply();
      final before = masterSequence;
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: await revision(),
          originalStart: timing(3),
          action: CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: timing(8),
        ),
      );
      await publish();
      expect(active.events.length, 2);
      expect(masterSequence, before);
      expect((await view()).responses.single.isCurrent, isTrue);
      expect((await source(first.sourceId)).inactiveAt, isNull);
      await reply();
      expect(host.contexts.last.publishedMessage.events.length, 2);
      expect(host.contexts.last.publishedMaster.isOverride, isFalse);
    });

    test('partial carrier sequence cannot turn future or stale master replies into current responses', () async {
      await seed();
      await cancelPoint(3);
      expect(carrier.sequence, greaterThan(masterSequence));
      expect(
        (await reply(sequence: carrier.sequence)).outcome,
        CalendarSchedulingReplyOutcome.unmatched,
      );
      expect(
        (await reply(sequence: masterSequence - 1)).outcome,
        CalendarSchedulingReplyOutcome.stale,
      );
      expect((await view()).responses.single.effectiveParticipation, isNull);
      expect((await reply()).outcome, CalendarSchedulingReplyOutcome.applied);
    });

    test('final host denial rolls back recurring intake and raw-source denial stays independent', () async {
      await seed();
      host.denyFinal = true;
      await expectLater(reply(), failure(CalendarFailureCode.accessDenied));
      expect((await view()).responses.single.sourceId, isNull);
      expect(await service.schedulingReplySources(id), isEmpty);
      host.denyFinal = false;
      final accepted = await reply();
      policy.deniedReplySources.add(accepted.sourceId);
      await expectLater(
        service.schedulingReplySources(id),
        failure(CalendarFailureCode.accessDenied),
      );
      expect((await view()).responses.single.isCurrent, isTrue);
    });

    test('self-contained partial proof survives pruned publication rows and rejects malformed proof', () async {
      await seed();
      final basisId = carrier.id!;
      await cancelPoint(3);
      // Real cleanup can remove terminal rows; the partial checkpoint is its own proof.
      final deliveries = await CalendarSchedulingDeliveryRecord.db.find(
        session,
        where: (t) => t.publicationId.equals(basisId),
      );
      for (final delivery in deliveries) {
        await CalendarSchedulingAttemptRecord.db.deleteWhere(
          session,
          where: (t) => t.deliveryId.equals(delivery.id!),
        );
      }
      await CalendarSchedulingDeliveryRecord.db.deleteWhere(
        session,
        where: (t) => t.publicationId.equals(basisId),
      );
      await CalendarSchedulingPublicationRecord.db.deleteWhere(
        session,
        where: (t) => t.id.equals(basisId),
      );
      expect((await reply()).outcome, CalendarSchedulingReplyOutcome.applied);
      carrier.snapshot = '{}';
      await CalendarSchedulingPublicationRecord.db.updateRow(session, carrier);
      await expectLater(view(), failure(CalendarFailureCode.unavailable));
      await expectLater(reply(), failure(CalendarFailureCode.unavailable));
    });

    test('date inclusion groups normalize order and duplicates without losing source groups', () async {
      await seed();
      content = content.copyWith(
        recurrence: CalendarEventRecurrence(
          rule: rule(),
          inclusions: [timing(8), timing(9)],
          exclusions: [timing(3), timing(4)],
        ),
      );
      await publish();
      final accepted = await reply(
        ordinary: [
          ...properties({'DTSTART'}),
          IcalendarSyntaxProperty(
            'RDATE',
            '20261109,20261108',
            parameters: [
              IcalendarSyntaxParameter('VALUE', ['DATE']),
            ],
          ),
          IcalendarSyntaxProperty(
            'RDATE',
            '20261108',
            parameters: [
              IcalendarSyntaxParameter('VALUE', ['DATE']),
            ],
          ),
          IcalendarSyntaxProperty(
            'EXDATE',
            '20261104,20261103',
            parameters: [
              IcalendarSyntaxParameter('VALUE', ['DATE']),
            ],
          ),
        ],
      );
      expect(accepted.outcome, CalendarSchedulingReplyOutcome.applied);
      final document = await service.schedulingReplySource(
        id,
        accepted.sourceId,
      );
      expect('RDATE;'.allMatches(document.normalizedSource).length, 2);
      expect(
        (await reply(
          ordinary: [
            ...properties({'DTSTART'}),
            IcalendarSyntaxProperty(
              'EXDATE',
              '20261103',
              parameters: [
                IcalendarSyntaxParameter('VALUE', ['DATE']),
              ],
            ),
          ],
        )).outcome,
        CalendarSchedulingReplyOutcome.conflict,
      );
    });

    test('legacy profile upgrade publishes a newer invitation without changing native source versions', () async {
      await seed();
      final first = await reply();
      final originalVersion = masterSequence;
      final stored = jsonDecode(carrier.snapshot) as Map<String, dynamic>;
      expect(stored.remove('instanceVersionProfile'), 1);
      carrier.snapshot = jsonEncode(stored);
      await CalendarSchedulingPublicationRecord.db.updateRow(session, carrier);
      final before = await service.getEvent(id, CalendarEventFieldGroup.values);
      final sourceState = jsonEncode(
        (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(id),
        ))!.protocolState!.toJson(),
      );
      await publish();
      expect(masterSequence, greaterThan(originalVersion));
      expect(
        (jsonDecode(carrier.snapshot) as Map)['instanceVersionProfile'],
        1,
      );
      expect((await view()).responses.single.isCurrent, isFalse);
      expect((await source(first.sourceId)).inactiveAt, isNotNull);
      final after = await service.getEvent(id, CalendarEventFieldGroup.values);
      expect(
        jsonEncode(
          (await CalendarEventDataRecord.db.findFirstRow(
            session,
            where: (t) => t.eventId.equals(id),
          ))!.protocolState!.toJson(),
        ),
        sourceState,
      );
      expect(after.revision, before.revision + 1);
      final upgradedId = carrier.id;
      await publish();
      expect(carrier.id, upgradedId);
    });

    test('new single component versions exceed prior effective invitation versions', () async {
      await seed();
      final prior = masterSequence;
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: await revision(),
          originalStart: timing(3),
          action: CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: timing(8),
        ),
      );
      await publish();
      expect(masterSequence, prior);
      expect(
        active.events.singleWhere((e) => e.isOverride).sequence,
        greaterThan(prior),
      );
    });

    test('future applicability changes advance outgoing versions without pinning native state', () async {
      await seed();
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: await revision(),
          originalStart: timing(3),
          action: CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: timing(8),
        ),
      );
      await publish();
      final before = active.events.singleWhere((e) => e.isOverride).sequence!;
      content = content.copyWith(
        recurrence: CalendarEventRecurrence(
          rule: rule(),
          inclusions: [],
          exclusions: [timing(4)],
        ),
      );
      await publish();
      expect(
        active.events.singleWhere((e) => e.isOverride).sequence,
        greaterThan(before),
      );
      final saved = await service.getEvent(id, CalendarEventFieldGroup.values);
      expect(saved.timingOverrides!.future.single.originalStart.start.day, 3);
    });

    for (final kind in [
      CalendarEventTimeKind.date,
      CalendarEventTimeKind.utc,
      CalendarEventTimeKind.zoned,
    ]) {
      test(
        'instance ${kind.name} reply accepts an unexceptional original without changing master response',
        () async {
          await seed(kind: kind);
          final point = timing(3, kind: kind);
          final before = await service.schedulingInstanceResponses(id, point);
          expect(before.responses.single.sourceId, isNull);
          final accepted = await reply(
            original: point,
            sequence: before.publishedSequence,
          );
          expect(accepted.outcome, CalendarSchedulingReplyOutcome.applied);
          expect((await view()).responses.single.sourceId, isNull);
          expect(
            (await service.schedulingInstanceResponses(
              id,
              point,
            )).responses.single.isCurrent,
            isTrue,
          );
          expect(
            (await service.schedulingInstanceResponses(
              id,
              timing(4, kind: kind),
            )).responses.single.sourceId,
            isNull,
          );
          expect(host.contexts.last.originalStart!.start.day, 3);
          expect(host.contexts.last.publishedTarget!.isOverride, isFalse);
          final document = await service.schedulingReplySource(
            id,
            accepted.sourceId,
          );
          expect(document.normalizedSource, contains('RECURRENCE-ID'));
        },
      );
    }

    test('instance uses single then range then master versions and matches effective timing', () async {
      await seed();
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: await revision(),
          originalStart: timing(3),
          action: CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: timing(8),
        ),
      );
      await publish();
      final ranged = await service.schedulingInstanceResponses(id, timing(4));
      expect(ranged.publishedSequence, greaterThan(masterSequence));
      expect(
        (await reply(
          original: timing(4),
          sequence: ranged.publishedSequence,
          ordinary: [EventComponentWriter().time('DTSTART', timing(9))],
        )).outcome,
        CalendarSchedulingReplyOutcome.applied,
      );
      expect(host.contexts.last.publishedTarget!.isThisAndFuture, isTrue);
      expect(host.contexts.last.effectiveOccurrence!.timing.start.day, 9);
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: id,
          expectedRevision: await revision(),
          originalStart: timing(4),
          action: CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: timing(10),
        ),
      );
      await publish();
      final single = await service.schedulingInstanceResponses(id, timing(4));
      expect(single.publishedSequence, greaterThan(ranged.publishedSequence!));
      expect(single.responses.single.isCurrent, isFalse);
      expect(
        (await reply(
          original: timing(4),
          sequence: single.publishedSequence,
          ordinary: [EventComponentWriter().time('DTSTART', timing(10))],
        )).outcome,
        CalendarSchedulingReplyOutcome.applied,
      );
      expect(host.contexts.last.publishedTarget!.isThisAndFuture, isFalse);
      expect(host.contexts.last.publishedTarget!.isOverride, isTrue);
      await expectLater(
        reply(original: timing(10)),
        failure(CalendarFailureCode.validation),
      );
    });

    test('instance cancellation restoration and v6 masks preserve independent response histories', () async {
      await seed();
      final first = await reply(original: timing(3));
      await reply(original: timing(4));
      await cancelPoint(3);
      var target = await service.schedulingInstanceResponses(id, timing(3));
      expect(target.publishedCancelled, isTrue);
      expect(target.responses.single.isCurrent, isFalse);
      expect((await source(first.sourceId)).inactiveAt, isNotNull);
      expect(
        (await service.schedulingInstanceResponses(
          id,
          timing(4),
        )).responses.single.isCurrent,
        isTrue,
      );
      expect(
        (await reply(
          original: timing(3),
          sequence: target.publishedSequence,
        )).outcome,
        CalendarSchedulingReplyOutcome.unappliedResult,
      );
      await terminal();
      await capture(
        await service.cancelAndNotify(
          CalendarSchedulingCancelRequest(
            eventId: id,
            expectedRevision: await revision(),
            commandId: const Uuid().v4obj(),
          ),
        ),
      );
      await terminal();
      await capture(
        await service.reopenPublishedAndNotify(
          CalendarSchedulingReopenRequest(
            eventId: id,
            expectedRevision: await revision(),
            commandId: const Uuid().v4obj(),
          ),
        ),
      );
      expect(
        (await service.schedulingInstanceResponses(
          id,
          timing(3),
        )).publishedCancelled,
        isTrue,
      );
      await restorePoint(3);
      target = await service.schedulingInstanceResponses(id, timing(3));
      expect(target.publishedCancelled, isFalse);
      expect(
        (await reply(
          original: timing(3),
          sequence: target.publishedSequence,
        )).outcome,
        CalendarSchedulingReplyOutcome.applied,
      );
      expect((await view()).responses.single.sourceId, isNull);
    });

    test('instance rejects unknown excluded and legacy originals and retains removed history', () async {
      await seed();
      await expectLater(
        reply(original: timing(9)),
        failure(CalendarFailureCode.validation),
      );
      final first = await reply(original: timing(5));
      content = content.copyWith(
        recurrence: CalendarEventRecurrence(
          rule: rule(count: 2),
          inclusions: [],
          exclusions: [],
        ),
      );
      await publish();
      final prior = await service.schedulingInstanceResponses(id, timing(5));
      expect(prior.publishedSequence, isNull);
      expect(prior.responses.single.sourceId, first.sourceId);
      expect(prior.responses.single.isCurrent, isFalse);
      await expectLater(
        reply(original: timing(5)),
        failure(CalendarFailureCode.validation),
      );
      final legacy = jsonDecode(carrier.snapshot) as Map<String, dynamic>;
      legacy.remove('instanceVersionProfile');
      carrier.snapshot = jsonEncode(legacy);
      await CalendarSchedulingPublicationRecord.db.updateRow(session, carrier);
      await expectLater(
        reply(original: timing(3)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await publish();
      final target = await service.schedulingInstanceResponses(id, timing(3));
      expect(
        (await reply(
          original: timing(3),
          sequence: target.publishedSequence,
        )).outcome,
        CalendarSchedulingReplyOutcome.applied,
      );
    });

    test('instance final denial and per-source review cannot leak or change other targets', () async {
      await seed();
      host.denyFinal = true;
      await expectLater(
        reply(original: timing(3)),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await service.schedulingInstanceResponses(
          id,
          timing(3),
        )).responses.single.sourceId,
        isNull,
      );
      host.denyFinal = false;
      final first = await reply(original: timing(3));
      final other = await reply(original: timing(4));
      policy.deniedReplySources.add(first.sourceId);
      await expectLater(
        service.schedulingReplySources(id),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(
        (await service.schedulingInstanceResponses(
          id,
          timing(4),
        )).responses.single.sourceId,
        other.sourceId,
      );
      policy.deniedReplySources.clear();
      final broken = await source(first.sourceId);
      broken.originalStart = timing(4);
      await CalendarSchedulingReplySourceRecord.db.updateRow(session, broken);
      await expectLater(
        service.schedulingInstanceResponses(id, timing(3)),
        failure(CalendarFailureCode.unavailable),
      );
    });

    test(
      'instance PERIOD form and earlier inclusion use the original identity',
      () async {
        await seed(kind: CalendarEventTimeKind.utc, periods: true);
        final point = timing(8, kind: CalendarEventTimeKind.utc);
        expect(
          (await reply(
            original: point,
            ordinary: [
              EventComponentWriter().time('DTSTART', point),
              IcalendarSyntaxProperty('DURATION', 'PT2H'),
            ],
          )).outcome,
          CalendarSchedulingReplyOutcome.applied,
        );
        final earlier = point.copyWith(
          start: point.start.copyWith(month: 10, day: 30),
        );
        content = content.copyWith(
          recurrence: CalendarEventRecurrence(
            rule: rule(),
            inclusions: [earlier],
            exclusions: [],
          ),
        );
        await publish();
        expect(
          (await reply(original: earlier)).outcome,
          CalendarSchedulingReplyOutcome.applied,
        );
      },
    );

    test('instance stable keys cannot cross originals or overwrite a newer checkpoint', () async {
      await seed();
      final first = await reply(
        original: timing(3),
        key: 'stable-instance',
        stamp: '20261027T160000Z',
      );
      final newer = await reply(
        original: timing(3),
        participation: 'DECLINED',
        stamp: '20261027T170000Z',
      );
      final retried = await reply(
        original: timing(3),
        key: 'stable-instance',
        stamp: '20261027T160000Z',
      );
      expect(retried.receiptId, first.receiptId);
      expect(retried.unchanged, isTrue);
      expect(
        (await service.schedulingInstanceResponses(
          id,
          timing(3),
        )).responses.single.sourceId,
        newer.sourceId,
      );
      expect(host.contexts.last.currentResponse!.sourceId, newer.sourceId);
      await expectLater(
        reply(
          original: timing(4),
          key: 'stable-instance',
          stamp: '20261027T160000Z',
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await service.schedulingInstanceResponses(
          id,
          timing(4),
        )).responses.single.sourceId,
        isNull,
      );
    });

    test(
      'instance work exhaustion fails rather than claiming an absent original',
      () async {
        await seed(kind: CalendarEventTimeKind.utc);
        content = content.copyWith(
          recurrence: CalendarEventRecurrence(
            rule: rule(count: 1000000)
                .copyWith(frequency: CalendarEventFrequency.hourly),
            inclusions: [],
            exclusions: [],
          ),
        );
        await publish();
        final far = CalendarEventTiming(
          kind: CalendarEventTimeKind.utc,
          start: CalendarEventCivil(year: 2099, month: 11, day: 2, hour: 9),
        );
        await expectLater(
          reply(original: far),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await service.schedulingReplySources(id), isEmpty);
      },
    );

    test('instance source inactivity is coordinated on publishers without an inbound adapter', () async {
      await seed();
      final first = await reply(original: timing(3));
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        scheduling: CalendarSchedulingRuntime(
          host: SchedulingHost(),
          transport: SchedulingTransport(),
        ),
      );
      service = CalendarModule.service(session);
      content = content.copyWith(
        summary: 'New invitation without reply adapter',
      );
      await publish();
      expect((await source(first.sourceId)).inactiveAt, isNotNull);
    });

    test('instance retained exact retry survives removal without admitting a new removed original', () async {
      await seed();
      final sequence = masterSequence;
      final first = await reply(
        original: timing(5),
        sequence: sequence,
        key: 'removed-retry',
        stamp: '20261027T160000Z',
      );
      content = content.copyWith(
        recurrence: CalendarEventRecurrence(
          rule: rule(count: 2),
          inclusions: [],
          exclusions: [],
        ),
      );
      await publish();
      final retried = await reply(
        original: timing(5),
        sequence: sequence,
        key: 'removed-retry',
        stamp: '20261027T160000Z',
      );
      expect(retried.receiptId, first.receiptId);
      expect(retried.unchanged, isTrue);
      expect(host.contexts.last.publishedSequence, isNull);
      expect(host.contexts.last.currentResponse!.isCurrent, isFalse);
      await expectLater(
        reply(
          original: timing(5),
          sequence: sequence,
          stamp: '20261027T170000Z',
        ),
        failure(CalendarFailureCode.validation),
      );
    });

    test('instance capacity is shared across targets and unknown queries allocate no rows', () async {
      await seed();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        scheduling: CalendarSchedulingRuntime(
          host: SchedulingHost(),
          transport: SchedulingTransport(),
          replies: CalendarSchedulingReplyRuntime(
            host: host,
            options: CalendarSchedulingReplyOptions(maxSourcesPerBinding: 2),
          ),
        ),
      );
      service = CalendarModule.service(session);
      await reply(original: timing(3));
      await reply(original: timing(4));
      final before = await service.schedulingInstanceResponses(id, timing(5));
      expect(before.responses.single.sourceId, isNull);
      await expectLater(
        reply(original: timing(5)),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect((await service.schedulingReplySources(id)).length, 2);
      expect((await view()).responses.single.sourceId, isNull);
    });

    test('instance pattern and RANGE replies and malformed profile markers reject atomically', () async {
      await seed();
      await expectLater(
        reply(original: timing(3), ordinary: properties({'DTSTART', 'RRULE'})),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        reply(
          ordinary: [
            IcalendarSyntaxProperty(
              'RECURRENCE-ID',
              '20261103',
              parameters: [
                IcalendarSyntaxParameter('VALUE', ['DATE']),
                IcalendarSyntaxParameter('RANGE', ['THISANDFUTURE']),
              ],
            ),
          ],
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(await service.schedulingReplySources(id), isEmpty);
      final header = jsonDecode(carrier.snapshot) as Map<String, dynamic>;
      header['instanceVersionProfile'] = 1.0;
      carrier.snapshot = jsonEncode(header);
      await CalendarSchedulingPublicationRecord.db.updateRow(session, carrier);
      await expectLater(view(), failure(CalendarFailureCode.unavailable));
    });
  });
}
