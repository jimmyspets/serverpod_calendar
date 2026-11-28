import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'scheduling_test.dart' show SchedulingHost, SchedulingTransport;
import 'incoming_publications_test.dart' show IncomingPublicationHost;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('information occurrence publication', (builder, endpoints) {
    late Session session;
    late CalendarService service;
    late SchedulingHost host;
    late SchedulingTransport transport;
    late UuidValue parent, event;

    CalendarEventTiming timing(
      int offset, {
      CalendarEventTimeKind kind = CalendarEventTimeKind.utc,
      bool point = false,
    }) {
      final day = DateTime.utc(2026, 3, 29).add(Duration(days: offset));
      return CalendarEventTiming(
        kind: kind,
        start: CalendarEventCivil(
          year: day.year,
          month: day.month,
          day: day.day,
          hour: kind == CalendarEventTimeKind.date ? 0 : 9,
        ),
        zoneId: kind == CalendarEventTimeKind.zoned ? 'Europe/Stockholm' : null,
        duration: point
            ? null
            : CalendarEventDuration(
                days: kind == CalendarEventTimeKind.date ? 1 : 0,
                hours: kind == CalendarEventTimeKind.date ? 0 : 1,
              ),
      );
    }

    CalendarEventContent content({
      String summary = 'Series',
      CalendarEventTimeKind kind = CalendarEventTimeKind.utc,
      int count = 4,
    }) => CalendarEventContent(
      summary: summary,
      description: 'Shared description',
      timing: timing(0, kind: kind),
      recurrence: CalendarEventRecurrence(
        rule: CalendarEventRule(
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
        ),
        inclusions: [],
        exclusions: [],
      ),
    );
    Future<CalendarEventView> current() =>
        service.getEvent(event, CalendarEventFieldGroup.values);
    Future<void> change(
      int offset,
      CalendarEventOccurrenceAction action, {
      int? replacement,
      CalendarEventTimeKind kind = CalendarEventTimeKind.utc,
    }) async {
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: event,
          expectedRevision: (await current()).revision,
          originalStart: timing(offset, kind: kind, point: true),
          action: action,
          replacement: replacement == null
              ? null
              : timing(replacement, kind: kind),
        ),
      );
    }

    Future<CalendarSchedulingReceipt> publish({
      String summary = 'Series',
    }) async => service.saveAndPublishInformation(
      CalendarSchedulingSaveRequest(
        eventId: event,
        expectedRevision: (await current()).revision,
        commandId: const Uuid().v4obj(),
        content: (await current()).timing!.kind == CalendarEventTimeKind.utc
            ? content(summary: summary)
            : content(summary: summary, kind: (await current()).timing!.kind),
        recipients: ['mailto:bob@example.invalid'],
      ),
    );
    Future<CalendarSchedulingPublicationRecord> record(
      CalendarSchedulingReceipt r,
    ) async => (await CalendarSchedulingPublicationRecord.db.findById(
      session,
      r.publicationId,
    ))!;
    Future<IcalendarSchedulingMessage> message(
      CalendarSchedulingReceipt r,
    ) async =>
        parseIcalendarSchedulingMessage(utf8.encode((await record(r)).payload));
    Future<CalendarEventDataRecord> data() async =>
        (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(event),
        ))!;
    setUp(() async {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      host = SchedulingHost();
      transport = SchedulingTransport();
      CalendarModule.install(
        session.serverpod,
        policy: TestPolicy(),
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        scheduling: CalendarSchedulingRuntime(host: host, transport: transport),
        incomingPublications: CalendarIncomingPublicationRuntime(
          host: IncomingPublicationHost(),
        ),
      );
      service = CalendarModule.service(session);
      parent = (await service.create(createInput()))!.calendarId;
      event = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: parent, content: content()),
      ))!.eventId;
    });
    for (final kind in [
      CalendarEventTimeKind.date,
      CalendarEventTimeKind.utc,
      CalendarEventTimeKind.zoned,
    ]) {
      test(
        '$kind publishes exact single and future original identities',
        () async {
          if (kind != CalendarEventTimeKind.utc) {
            await service.updateEvent(
              CalendarEventUpdateRequest(
                eventId: event,
                expectedRevision: 1,
                content: content(kind: kind),
              ),
            );
          }
          await change(
            1,
            CalendarEventOccurrenceAction.replaceFutureTiming,
            replacement: 2,
            kind: kind,
          );
          await change(
            2,
            CalendarEventOccurrenceAction.replaceSingleTiming,
            replacement: 4,
            kind: kind,
          );
          final before = (await data()).timingOverrides!.toJson();
          host.onCheck = (c) {
            expect(c.proposedEvent.timingOverrides!.singles, hasLength(1));
            expect(c.outgoingMessage.events, hasLength(3));
          };
          final result = await publish(), wire = await message(result);
          expect(wire.events, hasLength(3));
          expect(
            wire.events
                .where((e) => e.isOverride)
                .every(
                  (e) =>
                      e.summary!.value == 'Series' &&
                      e.participants.attendees.isEmpty,
                ),
            isTrue,
          );
          expect(wire.events.where((e) => e.isThisAndFuture), hasLength(1));
          expect((await data()).timingOverrides!.toJson(), before);
          expect(
            (await service.informationPublicationStatus(event)).hasLocalChanges,
            isFalse,
          );
          expect(
            jsonDecode((await record(result)).snapshot)['informationVersion'],
            2,
          );
        },
      );
    }
    test('inherited summary advances its component; own summary retains its version', () async {
      await change(
        1,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: 2,
      );
      await change(
        2,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: 3,
      );
      await service.changeOccurrenceContent(
        CalendarEventOccurrenceContentRequest(
          eventId: event,
          expectedRevision: (await current()).revision,
          originalStart: timing(2, point: true),
          changes: [
            CalendarEventOccurrenceContentChange(
              field: CalendarEventContentField.summary,
              action: CalendarEventContentAction.setValue,
              text: 'Own',
            ),
          ],
        ),
      );
      final first = await message(await publish()),
          second = await message(await publish(summary: 'New series'));
      final inherited = first.events.singleWhere(
        (e) => e.isOverride && e.summary!.value == 'Series',
      );
      final changed = second.events.singleWhere(
        (e) => e.isOverride && e.summary!.value == 'New series',
      );
      expect(changed.sequence, greaterThan(inherited.sequence!));
      final own = first.events.singleWhere((e) => e.summary?.value == 'Own'),
          retained = second.events.singleWhere(
            (e) => e.summary?.value == 'Own',
          );
      expect(retained.sequence, own.sequence);
      expect(retained.stamp, own.stamp);
    });
    test('child changes preserve an unchanged emitted master, including source dates', () async {
      await change(
        1,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: 2,
      );
      final first = await message(await publish());
      await change(
        1,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: 3,
      );
      final second = await message(await publish());
      // LAST-MODIFIED is preserved source data. If the native edit crosses a
      // database second it is an observable master-field change as well.
      List<String> sourceDate(IcalendarSchedulingEvent value) => value
          .source
          .entries
          .whereType<IcalendarSyntaxProperty>()
          .where((p) => p.canonicalName == 'LAST-MODIFIED')
          .map((p) => p.value)
          .toList();
      if (jsonEncode(sourceDate(first.events.first)) ==
          jsonEncode(sourceDate(second.events.first))) {
        expect(second.events.first.sequence, first.events.first.sequence);
        expect(second.events.first.stamp, first.events.first.stamp);
      } else {
        expect(
          second.events.first.sequence,
          greaterThan(first.events.first.sequence!),
        );
      }
      expect(
        second.events.last.sequence,
        greaterThan(first.events.last.sequence!),
      );
    });
    test(
      'retained reset reprojects current series without inventing native edits',
      () async {
        await change(
          1,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: 2,
        );
        await publish();
        await change(1, CalendarEventOccurrenceAction.clearSingleTiming);
        final reset = await publish();
        expect((await data()).timingOverrides?.singles ?? [], isEmpty);
        expect((await message(reset)).events, hasLength(2));
        final snapshot = jsonDecode((await record(reset)).snapshot) as Map;
        expect(snapshot['projectionOriginals'], hasLength(1));
        final updated = await message(await publish(summary: 'Later master'));
        expect(updated.events.last.summary!.value, 'Later master');
        expect((await data()).timingOverrides?.singles ?? [], isEmpty);
      },
    );
    test('whole cancellation and reopen preserve component versions and newer drafts', () async {
      await change(
        1,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: 2,
      );
      final first = await message(await publish());
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: event,
          expectedRevision: (await current()).revision,
          content: content(summary: 'Private draft'),
        ),
      );
      final cancel = await service.cancelPublishedInformation(
        CalendarSchedulingCancelRequest(
          eventId: event,
          expectedRevision: (await current()).revision,
          commandId: const Uuid().v4obj(),
        ),
      );
      final cancelled = await message(cancel);
      expect(cancelled.events, hasLength(1));
      expect(
        cancelled.events.single.sequence,
        greaterThan(first.events.last.sequence!),
      );
      expect((await current()).summary, 'Private draft');
      final reopened = await service.reopenPublishedInformation(
        CalendarSchedulingReopenRequest(
          eventId: event,
          expectedRevision: (await current()).revision,
          commandId: const Uuid().v4obj(),
        ),
      );
      final wire = await message(reopened);
      expect(wire.events, hasLength(2));
      expect(wire.events.last.sequence, first.events.last.sequence);
      expect(wire.events.last.stamp, first.events.last.stamp);
      expect(wire.events.last.summary!.value, 'Series');
      expect((await current()).summary, 'Private draft');
      expect(
        (await service.informationPublicationStatus(event)).hasLocalChanges,
        isTrue,
      );
    });
    for (final action in [
      CalendarEventOccurrenceAction.cancelSingle,
      CalendarEventOccurrenceAction.cancelFuture,
    ]) {
      test('never strips $action to manufacture PUBLISH', () async {
        await change(1, action);
        final before = (await data()).toJson();
        await expectLater(publish(), failure(CalendarFailureCode.validation));
        expect((await data()).toJson(), before);
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      });
    }
    test(
      'a first follow-series content-only exception remains unrepresentable',
      () async {
        await service.changeOccurrenceContent(
          CalendarEventOccurrenceContentRequest(
            eventId: event,
            expectedRevision: 1,
            originalStart: timing(1, point: true),
            changes: [
              CalendarEventOccurrenceContentChange(
                field: CalendarEventContentField.summary,
                action: CalendarEventContentAction.setValue,
                text: 'Own',
              ),
            ],
          ),
        );
        await expectLater(publish(), failure(CalendarFailureCode.validation));
        expect(
          (await data()).timingOverrides!.singles.single.replacement,
          isNull,
        );
      },
    );
    test(
      'complete-message denial rolls back native state and every outbox row',
      () async {
        await change(
          1,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: 2,
        );
        final before = (await data()).toJson();
        host.onCheck = (c) {
          if (c.outgoingMessage.events.length > 1) host.denied = true;
        };
        await expectLater(
          publish(summary: 'Uncommitted'),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await data()).toJson(), before);
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
      },
    );
    test(
      'master-only incoming publication intake still rejects a complete bundle',
      () async {
        await change(
          1,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: 2,
        );
        final outgoing = await record(await publish());
        await expectLater(
          CalendarModule.receiveIncomingPublication(
            session,
            CalendarIncomingPublicationDelivery(
              namespace: 'synthetic',
              deliveryKey: 'bundle',
              originReference: 'verified-publisher',
              bytes: Uint8List.fromList(utf8.encode(outgoing.payload)),
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarIncomingPublicationRecord.db.count(session), 0);
      },
    );
    test(
      'corrupted component protocol versions fail status and worker closed',
      () async {
        await change(
          1,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: 2,
        );
        final row = await record(await publish());
        final snapshot = jsonDecode(row.snapshot) as Map<String, dynamic>;
        final state = (snapshot['outgoing'] as Map)['state'] as Map;
        final version =
            ((state['overrides'] as List).single as Map)['version'] as Map;
        version['sequence'] = (version['sequence'] as int) + 1;
        row.snapshot = jsonEncode(snapshot);
        await CalendarSchedulingPublicationRecord.db.updateRow(session, row);
        await expectLater(
          service.informationPublicationStatus(event),
          failure(CalendarFailureCode.unavailable),
        );
        await CalendarModule.runSchedulingMaintenance(session);
        expect(transport.submissions, isEmpty);
      },
    );
    test(
      'worker receives the complete authorized bundle without an actor',
      () async {
        await change(
          1,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: 2,
        );
        final saved = await record(await publish());
        host.onCheck = (context) {
          expect(context.actor, isNull);
          expect(context.outgoingMessage.events, hasLength(2));
          expect(
            context.publicationEvent.timingOverrides!.singles,
            hasLength(1),
          );
        };
        await CalendarModule.runSchedulingMaintenance(session);
        expect(transport.submissions, hasLength(1));
        expect(transport.submissions.single.payload, saved.payload);
      },
    );
    test('legacy v1 remains readable and upgrades only on a changed explicit publication', () async {
      final first = await publish(), old = await record(first);
      final v1 = jsonDecode(old.snapshot) as Map<String, dynamic>;
      v1['informationVersion'] = 1;
      v1.remove('projectionOriginals');
      old.snapshot = jsonEncode(v1);
      await CalendarSchedulingPublicationRecord.db.updateRow(session, old);
      expect(
        (await service.informationPublicationStatus(event)).hasLocalChanges,
        isFalse,
      );
      expect((await publish()).unchanged, isTrue);
      expect((await record(first)).snapshot, old.snapshot);
      await change(
        1,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: 2,
      );
      final upgraded = await record(await publish());
      expect(jsonDecode(upgraded.snapshot)['informationVersion'], 2);
      expect(
        (await message(
          CalendarSchedulingReceipt(
            publicationId: upgraded.id!,
            eventRevision: upgraded.eventRevision,
            unchanged: false,
          ),
        )).events,
        hasLength(2),
      );
      expect((await record(first)).snapshot, old.snapshot);
    });
    test(
      'unchanged bundles and retained command retries never allocate or resend',
      () async {
        await change(
          1,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: 2,
        );
        final request = CalendarSchedulingSaveRequest(
          eventId: event,
          expectedRevision: (await current()).revision,
          commandId: const Uuid().v4obj(),
          content: content(),
          recipients: ['mailto:bob@example.invalid'],
        );
        final first = await service.saveAndPublishInformation(request),
            saved = await record(first);
        final duplicate = await service.saveAndPublishInformation(request);
        final noop = await publish();
        expect(duplicate.unchanged, isTrue);
        expect(noop.unchanged, isTrue);
        expect(duplicate.publicationId, first.publicationId);
        expect(noop.publicationId, first.publicationId);
        expect((await record(first)).payload, saved.payload);
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 1);
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: event,
            expectedRevision: (await current()).revision,
            content: content(summary: 'Private later'),
          ),
        );
        expect(
          (await service.saveAndPublishInformation(request)).publicationId,
          first.publicationId,
        );
        expect((await current()).summary, 'Private later');
      },
    );
    test(
      'reset future anchors retain kind and do not pin native range timing',
      () async {
        await change(
          1,
          CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: 2,
        );
        final first = await message(await publish());
        await change(1, CalendarEventOccurrenceAction.clearFutureTiming);
        final second = await message(await publish());
        expect(first.events.last.isThisAndFuture, isTrue);
        expect(second.events.last.isThisAndFuture, isTrue);
        expect(second.events.last.startTime!.civil.date.day, 30);
        expect((await data()).timingOverrides?.future ?? [], isEmpty);
      },
    );
    test('removing a retained reset original rejects publication without undoing the draft', () async {
      await change(
        2,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: 3,
      );
      await publish();
      await change(2, CalendarEventOccurrenceAction.clearSingleTiming);
      await publish();
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: event,
          expectedRevision: (await current()).revision,
          content: content(count: 2),
        ),
      );
      final before = (await data()).toJson();
      final request = CalendarSchedulingSaveRequest(
        eventId: event,
        expectedRevision: (await current()).revision,
        commandId: const Uuid().v4obj(),
        content: content(count: 2),
        recipients: ['mailto:bob@example.invalid'],
      );
      await expectLater(
        service.saveAndPublishInformation(request),
        failure(CalendarFailureCode.validation),
      );
      expect((await data()).toJson(), before);
      expect(await CalendarSchedulingPublicationRecord.db.count(session), 2);
    });
    test(
      'final complete-message denial rolls back a bundle publication',
      () async {
        await change(
          1,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: 2,
        );
        final before = (await data()).toJson();
        host.denyFinal = true;
        await expectLater(publish(), failure(CalendarFailureCode.accessDenied));
        expect((await data()).toJson(), before);
        expect(await CalendarSchedulingMeetingRecord.db.count(session), 0);
        expect(await CalendarSchedulingPublicationRecord.db.count(session), 0);
        expect(await CalendarSchedulingDeliveryRecord.db.count(session), 0);
      },
    );
    for (final malformed in [
      'duplicate',
      'wrong-kind',
      'missing-version',
      'foreign-zone',
      'null-version',
      'over-capacity',
    ]) {
      test('corrupt $malformed retained projection fails closed', () async {
        await change(
          1,
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: 2,
        );
        await publish();
        await change(1, CalendarEventOccurrenceAction.clearSingleTiming);
        final receipt = await publish();
        final row = await record(receipt);
        final proof = jsonDecode(row.snapshot) as Map<String, dynamic>;
        final originals = proof['projectionOriginals'] as List;
        final original = originals.single as Map<String, dynamic>;
        if (malformed == 'duplicate') {
          originals.add(Map<String, dynamic>.from(original));
        }
        if (malformed == 'wrong-kind') original['isThisAndFuture'] = true;
        if (malformed == 'foreign-zone') {
          (original['originalStart'] as Map)['zoneId'] = 'Europe/Stockholm';
        }
        if (malformed == 'missing-version') {
          (((proof['active'] as Map)['state'] as Map)['overrides'] as List)
              .clear();
        }
        if (malformed == 'null-version') {
          (((((proof['active'] as Map)['state'] as Map)['overrides'] as List)
                          .single
                      as Map)['version']
                  as Map)['sequence'] =
              null;
        }
        if (malformed == 'over-capacity') {
          originals.addAll(
            List.generate(64, (_) => Map<String, dynamic>.from(original)),
          );
        }
        row.snapshot = jsonEncode(proof);
        await CalendarSchedulingPublicationRecord.db.updateRow(session, row);
        await expectLater(
          service.informationPublicationStatus(event),
          failure(CalendarFailureCode.unavailable),
        );
        await CalendarModule.runSchedulingMaintenance(session);
        expect(transport.submissions, isEmpty);
      });
    }
    test('retained reset explicitly clears old optional text while native fields inherit', () async {
      await change(
        1,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: 2,
      );
      await service.changeOccurrenceContent(
        CalendarEventOccurrenceContentRequest(
          eventId: event,
          expectedRevision: (await current()).revision,
          originalStart: timing(1, point: true),
          changes: [
            CalendarEventOccurrenceContentChange(
              field: CalendarEventContentField.description,
              action: CalendarEventContentAction.setValue,
              text: 'Old own text',
            ),
          ],
        ),
      );
      await publish();
      await change(1, CalendarEventOccurrenceAction.clearSingleTiming);
      await service.changeOccurrenceContent(
        CalendarEventOccurrenceContentRequest(
          eventId: event,
          expectedRevision: (await current()).revision,
          originalStart: timing(1, point: true),
          changes: [
            CalendarEventOccurrenceContentChange(
              field: CalendarEventContentField.description,
              action: CalendarEventContentAction.inheritSeries,
            ),
          ],
        ),
      );
      final receipt = await service.saveAndPublishInformation(
        CalendarSchedulingSaveRequest(
          eventId: event,
          expectedRevision: (await current()).revision,
          commandId: const Uuid().v4obj(),
          content: content().copyWith(description: null),
          recipients: ['mailto:bob@example.invalid'],
        ),
      );
      final wire = await message(receipt);
      expect(wire.events.last.description!.value, '');
      expect((await current()).description, isNull);
      expect((await data()).timingOverrides?.singles ?? [], isEmpty);
    });
  });
}
