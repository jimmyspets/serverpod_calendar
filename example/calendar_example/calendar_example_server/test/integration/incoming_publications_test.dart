import 'package:calendar_example_server/src/scheduling_mime.dart';

import 'scheduling_test.dart' show SchedulingHost, SchedulingTransport;

import 'package:calendar_example_server/src/imip_ingress.dart';
import 'package:calendar_example_server/src/synthetic_imip_input.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, eventInput, failure;
import 'test_tools/serverpod_test_tools.dart';

final class IncomingPublicationHost implements CalendarIncomingPublicationHost {
  final denied = <CalendarIncomingPublicationOperation>{};
  final hidden = <UuidValue>{};
  final hiddenSources = <UuidValue>{};
  bool denyFinal = false;
  void Function(
    CalendarIncomingPublicationPolicyContext,
    CalendarAuthorizationPhase,
  )?
  onCheck;
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<CalendarIncomingPublicationRecipient> resolveDelivery(
    Session s,
    CalendarIncomingPublicationDelivery d,
    IcalendarSchedulingMessage message,
  ) async => const CalendarIncomingPublicationRecipient(
    scopeKey: 'test:alice',
    key: 'alice',
    calendarAddress: 'mailto:alice@example.invalid',
  );
  @override
  Future<CalendarIncomingPublicationRecipient> resolveRecipient(
    Session s,
    CalendarHostContext actor,
  ) async => CalendarIncomingPublicationRecipient(
    scopeKey: actor.scopeKey,
    key: actor.principalId,
    calendarAddress: 'mailto:${actor.principalId}@example.invalid',
  );
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session s,
    CalendarIncomingPublicationPolicyContext c,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    onCheck?.call(c, phase);
    return denied.contains(c.operation) ||
            c.operation == CalendarIncomingPublicationOperation.readSource &&
                hiddenSources.contains(c.sourceId) ||
            hidden.contains(c.entry?.id) ||
            c.delivery != null &&
                c.delivery!.originReference != 'verified-publisher' ||
            denyFinal && phase == CalendarAuthorizationPhase.finalWrite
        ? CalendarAuthorizationVerdict.deny
        : CalendarAuthorizationVerdict.allow;
  }
}

String publicationWire({
  int sequence = 0,
  String method = 'PUBLISH',
  String summary = 'Published value',
  String uid = 'publication@example.invalid',
  List<String> extra = const [],
  bool minimal = false,
}) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:-//Synthetic publication//EN',
  'METHOD:$method',
  'BEGIN:VEVENT',
  'UID:$uid',
  'ORGANIZER:mailto:publisher@example.invalid',
  'DTSTAMP:20261113T070000Z',
  'SEQUENCE:$sequence',
  if (!minimal) ...[
    'DTSTART:20270328T090000Z',
    'DURATION:PT1H',
    'SUMMARY:$summary',
  ],
  if (method == 'CANCEL') 'STATUS:CANCELLED',
  ...extra,
  'END:VEVENT',
  'END:VCALENDAR',
  '',
].join('\r\n');

void main() {
  withServerpod('incoming publication review and calendar workflow', (
    builder,
    endpoints,
  ) {
    late Session session;
    late CalendarService service;
    late IncomingPublicationHost host;
    late TestPolicy policy;
    late UuidValue parent;
    void install({
      CalendarIncomingPublicationOptions? options,
      CalendarSchedulingRuntime? scheduling,
    }) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        scheduling: scheduling,
        incomingPublications: CalendarIncomingPublicationRuntime(
          host: host,
          options: options,
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
      host = IncomingPublicationHost();
      policy = TestPolicy();
      install();
      parent = (await service.create(createInput()))!.calendarId;
    });
    Future<CalendarIncomingPublicationIngressReceipt> receive(
      String wire, {
      String? key,
      String origin = 'verified-publisher',
    }) => CalendarModule.receiveIncomingPublication(
      session,
      CalendarIncomingPublicationDelivery(
        namespace: 'synthetic',
        deliveryKey: key ?? const Uuid().v4(),
        originReference: origin,
        bytes: Uint8List.fromList(utf8.encode(wire)),
      ),
    );
    Future<CalendarIncomingPublicationView> entry(UuidValue id) =>
        service.incomingPublicationGet(id);
    Future<CalendarIncomingPublicationCommandReceipt> add(
      CalendarIncomingPublicationIngressReceipt receipt, {
      UuidValue? command,
    }) => service.incomingPublicationAdd(
      CalendarIncomingPublicationAddRequest(
        entryId: receipt.entryId,
        sourceId: receipt.sourceId,
        expectedRevision: receipt.entryRevision,
        calendarId: parent,
        expectedCalendarRevision: 1,
        commandId: command ?? const Uuid().v4obj(),
      ),
    );
    Future<CalendarIncomingPublicationCommandReceipt> apply(
      CalendarIncomingPublicationIngressReceipt receipt,
      int revision, {
      UuidValue? command,
    }) => service.incomingPublicationApply(
      CalendarIncomingPublicationApplyRequest(
        entryId: receipt.entryId,
        sourceId: receipt.sourceId,
        expectedRevision: receipt.entryRevision,
        expectedEventRevision: revision,
        commandId: command ?? const Uuid().v4obj(),
      ),
    );
    Future<CalendarEventView> event(UuidValue id) =>
        service.getEvent(id, CalendarEventFieldGroup.values);

    test(
      'receipt is private review only, not a booking or participation response',
      () async {
        host.onCheck = (c, p) {
          if (c.delivery != null) expect(c.actor, isNull);
        };
        final receipt = await receive(publicationWire());
        expect(receipt.outcome, CalendarIncomingPublicationOutcome.selected);
        expect(await CalendarEventRecord.db.count(session), 0);
        expect(
          await CalendarSchedulingAttendeeResponseRecord.db.count(session),
          0,
        );
        final page = await service.incomingPublicationList(
          CalendarIncomingPublicationQuery(),
        );
        expect(page.entries.single.id, receipt.entryId);
        expect(page.entries.single.summary, 'Published value');
        expect(page.continuation, isNull);
      },
    );
    test(
      'verified purpose and origin are independent of organizer text',
      () async {
        await expectLater(
          receive(publicationWire(), origin: 'forged'),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(await CalendarIncomingPublicationRecord.db.count(session), 0);
        expect(
          await CalendarIncomingPublicationSourceRecord.db.count(session),
          0,
        );
        expect(
          await CalendarIncomingPublicationReceiptRecord.db.count(session),
          0,
        );
      },
    );
    test(
      'ingress retry retains identity and does not reactivate dismissal',
      () async {
        final key = const Uuid().v4();
        final first = await receive(publicationWire(), key: key);
        await service.incomingPublicationDismiss(
          first.entryId,
          first.entryRevision,
        );
        final before = (await entry(first.entryId)).revision;
        final retry = await receive(publicationWire(), key: key);
        expect(retry.id, first.id);
        expect(retry.entryRevision, first.entryRevision);
        expect((await entry(first.entryId)).revision, before);
        expect(
          (await service.incomingPublicationList(
            CalendarIncomingPublicationQuery(),
          )).entries,
          isEmpty,
        );
        await expectLater(
          receive(publicationWire(summary: 'Changed'), key: key),
          failure(CalendarFailureCode.validation),
        );
      },
    );
    test('exact new-delivery duplicate and lower/equal-tuple conflict do not replace review', () async {
      final selected = await receive(publicationWire(sequence: 3));
      expect(
        (await receive(publicationWire(sequence: 3))).outcome,
        CalendarIncomingPublicationOutcome.duplicate,
      );
      expect(
        (await receive(publicationWire(sequence: 2))).outcome,
        CalendarIncomingPublicationOutcome.stale,
      );
      expect(
        (await receive(publicationWire(sequence: 3, summary: 'Different')))
            .outcome,
        CalendarIncomingPublicationOutcome.conflict,
      );
      final current = await entry(selected.entryId);
      expect(current.revision, 1);
      expect(current.summary, 'Published value');
    });
    test(
      'Add creates one imported event and stable historical creation receipt',
      () async {
        final source = await receive(publicationWire());
        final command = const Uuid().v4obj();
        final created = await add(source, command: command);
        final retry = await add(source, command: command);
        expect(retry.eventId, created.eventId);
        expect(retry.unchanged, isTrue);
        expect(await CalendarEventRecord.db.count(session), 1);
        final stored = (await CalendarEventDataRecord.db.find(session)).single;
        expect(stored.origin, CalendarEventOrigin.imported);
        expect(stored.protocolUid, 'publication@example.invalid');
        expect(stored.importBaseline, isNotNull);
        expect(
          (await service.incomingPublicationLink(source.entryId))!
              .hasLocalChanges,
          isFalse,
        );
      },
    );
    test('explicit update, whole cancellation and reopening are independent of receipt', () async {
      final first = await receive(publicationWire());
      final created = await add(first);
      final update = await receive(
        publicationWire(sequence: 1, summary: 'Updated publication'),
      );
      expect((await event(created.eventId)).summary, 'Published value');
      final changed = await apply(update, 1);
      expect(changed.eventRevision, 2);
      expect((await event(created.eventId)).summary, 'Updated publication');
      final cancel = await receive(
        publicationWire(
          sequence: 2,
          method: 'CANCEL',
          summary: 'Updated publication',
        ),
      );
      final cancelled = await apply(cancel, 2);
      expect(cancelled.eventRevision, 3);
      expect(
        (await event(created.eventId)).status,
        CalendarEventStatus.cancelled,
      );
      expect((await event(created.eventId)).summary, 'Updated publication');
      final reopen = await receive(
        publicationWire(sequence: 3, summary: 'Reopened values'),
      );
      await apply(reopen, 3);
      expect(
        (await event(created.eventId)).status,
        CalendarEventStatus.confirmed,
      );
      expect((await event(created.eventId)).summary, 'Reopened values');
      expect(
        (await service.incomingPublicationLink(first.entryId))!.hasLocalChanges,
        isFalse,
      );
    });
    test('CANCEL of a pending update preserves accepted native values and separate source proof', () async {
      final first = await receive(publicationWire());
      final created = await add(first);
      final pending = await receive(
        publicationWire(sequence: 1, summary: 'Not adopted'),
      );
      final cancel = await receive(
        publicationWire(sequence: 2, method: 'CANCEL', summary: 'Not adopted'),
      );
      final cancelSource = await service.incomingPublicationSource(
        cancel.entryId,
        cancel.sourceId,
      );
      expect(cancelSource.basisSourceId, pending.sourceId);
      final applied = await apply(cancel, 1);
      expect(applied.eventRevision, 2);
      final native = await event(created.eventId);
      expect(native.summary, 'Published value');
      expect(native.status, CalendarEventStatus.cancelled);
      final link = (await CalendarIncomingPublicationLinkRecord.db.find(
        session,
      )).single;
      expect(link.basisSourceId, first.sourceId);
      expect(link.acceptedSourceId, cancel.sourceId);
      expect(
        (await service.incomingPublicationLink(first.entryId))!.hasLocalChanges,
        isFalse,
      );
      final newer = await receive(
        publicationWire(sequence: 3, summary: 'Explicitly reopened'),
      );
      await apply(newer, 2);
      expect((await event(created.eventId)).summary, 'Explicitly reopened');
    });
    test('local native edits block source updates without overwriting either state', () async {
      final first = await receive(publicationWire());
      final created = await add(first);
      final current = await event(created.eventId);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: created.eventId,
          expectedRevision: 1,
          content: CalendarEventContent(
            summary: 'Private local edit',
            timing: current.timing!,
            status: current.status!,
            transparency: current.transparency!,
          ),
        ),
      );
      final update = await receive(
        publicationWire(sequence: 1, summary: 'New source'),
      );
      await expectLater(
        apply(update, 2),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect((await event(created.eventId)).summary, 'Private local edit');
      expect(
        (await service.incomingPublicationLink(first.entryId))!.hasLocalChanges,
        isTrue,
      );
      expect((await entry(first.entryId)).sourceId, update.sourceId);
    });
    test(
      'final adoption denial rolls back event/link and review changes',
      () async {
        final first = await receive(publicationWire());
        host.denyFinal = true;
        await expectLater(
          add(first),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denyFinal = false;
        expect(await CalendarEventRecord.db.count(session), 0);
        expect(
          await CalendarIncomingPublicationLinkRecord.db.count(session),
          0,
        );
        expect((await entry(first.entryId)).revision, 1);
      },
    );
    test(
      'independent source read and native lifecycle gates reject atomically',
      () async {
        final first = await receive(publicationWire());
        host.denied.add(CalendarIncomingPublicationOperation.readSource);
        await expectLater(
          add(first),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        final created = await add(first);
        final cancel = await receive(
          publicationWire(sequence: 1, method: 'CANCEL', minimal: true),
        );
        policy.denied.add(CalendarPermission.changeEventStatus);
        await expectLater(
          apply(cancel, 1),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          (await event(created.eventId)).status,
          CalendarEventStatus.confirmed,
        );
      },
    );
    test('bounded authorized pages bind cursor family, criteria and private source basis', () async {
      for (var i = 0; i < 3; i++) {
        await receive(publicationWire(uid: 'publication-$i@example.invalid'));
      }
      final query = CalendarIncomingPublicationQuery(pageSize: 1);
      final first = await service.incomingPublicationList(query);
      expect(first.entries, hasLength(1));
      expect(first.continuation, isNotNull);
      final second = await service.incomingPublicationList(
        query.copyWith(cursor: first.continuation),
      );
      expect(second.entries.single.id, isNot(first.entries.single.id));
      await expectLater(
        service.incomingPublicationList(
          query.copyWith(cursor: first.continuation, includeDismissed: true),
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
      await expectLater(
        service.list(pageSize: 1, fieldGroups: [], cursor: first.continuation),
        failure(CalendarFailureCode.invalidCursor),
      );
      await receive(
        publicationWire(sequence: 1, uid: 'publication-0@example.invalid'),
      );
      await expectLater(
        service.incomingPublicationList(
          query.copyWith(cursor: first.continuation),
        ),
        failure(CalendarFailureCode.invalidCursor),
      );
    });
    test(
      'foreign private recipient cannot list or access another inbox entry',
      () async {
        final first = await receive(publicationWire());
        final other = builder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'bob',
                {},
              ),
            )
            .build();
        final b = CalendarModule.service(other);
        expect(
          (await b.incomingPublicationList(CalendarIncomingPublicationQuery()))
              .entries,
          isEmpty,
        );
        await expectLater(
          b.incomingPublicationGet(first.entryId),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          b.incomingPublicationSource(first.entryId, first.sourceId),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test(
      'source byte and entry limits reject without partial admission',
      () async {
        install(
          options: CalendarIncomingPublicationOptions(
            maxEntriesPerRecipient: 1,
          ),
        );
        await receive(publicationWire());
        await expectLater(
          receive(publicationWire(uid: 'other@example.invalid')),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(await CalendarIncomingPublicationRecord.db.count(session), 1);
        expect(
          await CalendarIncomingPublicationSourceRecord.db.count(session),
          1,
        );
      },
    );
    test('latest Apply receipt stays historical across local edits and newer review', () async {
      final initial = await receive(publicationWire());
      final created = await add(initial);
      final update = await receive(
        publicationWire(sequence: 1, summary: 'Accepted update'),
      );
      final command = const Uuid().v4obj();
      final result = await apply(update, 1, command: command);
      final current = await event(created.eventId);
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: created.eventId,
          expectedRevision: 2,
          content: CalendarEventContent(
            summary: 'Later local change',
            timing: current.timing!,
            status: current.status!,
            transparency: current.transparency!,
          ),
        ),
      );
      await receive(publicationWire(sequence: 2, summary: 'Waiting source'));
      final retry = await apply(update, 1, command: command);
      expect(retry.eventRevision, result.eventRevision);
      expect(retry.unchanged, isTrue);
      expect((await event(created.eventId)).summary, 'Later local change');
      expect((await event(created.eventId)).revision, 3);
    });
    test('identical accepted Apply is write-free and does not invent a new receipt', () async {
      final first = await receive(publicationWire());
      final created = await add(first);
      final before = (await CalendarIncomingPublicationLinkRecord.db.find(
        session,
      )).single.toJson();
      final current = await entry(first.entryId);
      final noop = await service.incomingPublicationApply(
        CalendarIncomingPublicationApplyRequest(
          entryId: first.entryId,
          sourceId: first.sourceId,
          expectedRevision: current.revision,
          expectedEventRevision: 1,
          commandId: const Uuid().v4obj(),
        ),
      );
      expect(noop.unchanged, isTrue);
      expect((await event(created.eventId)).revision, 1);
      expect(
        (await CalendarIncomingPublicationLinkRecord.db.find(session)).single
            .toJson(),
        before,
      );
    });
    test(
      'one destination protocol UID rejects a second entry copy atomically',
      () async {
        final original = await receive(publicationWire());
        await add(original);
        final entryRow = (await CalendarIncomingPublicationRecord.db.find(
          session,
        )).single;
        // A different trusted publisher can use the same source UID; destination identity still conflicts.
        final another = await receive(
          publicationWire().replaceAll(
            'mailto:publisher@example.invalid',
            'mailto:another@example.invalid',
          ),
        );
        expect(another.entryId, isNot(entryRow.id));
        await expectLater(
          add(another),
          failure(CalendarFailureCode.dependencyConflict),
        );
        expect(await CalendarEventRecord.db.count(session), 1);
        expect(
          await CalendarIncomingPublicationLinkRecord.db.count(session),
          1,
        );
      },
    );
    test('full-series local occurrence state blocks replacement even if master text is unchanged', () async {
      final first = await receive(
        publicationWire(extra: ['RRULE:FREQ=DAILY;COUNT=3']),
      );
      final created = await add(first);
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: created.eventId,
          expectedRevision: 1,
          originalStart: CalendarEventTiming(
            kind: CalendarEventTimeKind.utc,
            start: CalendarEventCivil(year: 2027, month: 3, day: 29, hour: 9),
          ),
          action: CalendarEventOccurrenceAction.cancelSingle,
        ),
      );
      final update = await receive(
        publicationWire(sequence: 1, extra: ['RRULE:FREQ=DAILY;COUNT=4']),
      );
      await expectLater(
        apply(update, 2),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(
        (await event(created.eventId)).timingOverrides!.singles,
        hasLength(1),
      );
    });
    test('cancellation source basis pins an unapplied update through ordinary retention', () async {
      final first = await receive(publicationWire());
      await add(first);
      final pending = await receive(
        publicationWire(sequence: 1, summary: 'Pending values'),
      );
      final cancel = await receive(
        publicationWire(
          sequence: 2,
          method: 'CANCEL',
          summary: 'Pending values',
        ),
      );
      await apply(cancel, 1);
      for (final source
          in await CalendarIncomingPublicationSourceRecord.db.find(session)) {
        source.inactiveAt = DateTime.utc(2000);
        await CalendarIncomingPublicationSourceRecord.db.updateRow(
          session,
          source,
        );
      }
      for (final receipt
          in await CalendarIncomingPublicationReceiptRecord.db.find(session)) {
        receipt.expiresAt = DateTime.utc(2000);
        await CalendarIncomingPublicationReceiptRecord.db.updateRow(
          session,
          receipt,
        );
      }
      await CalendarModule.runIncomingPublicationMaintenance(session);
      expect(
        await CalendarIncomingPublicationReceiptRecord.db.count(session),
        0,
      );
      expect(
        (await service.incomingPublicationSource(
          cancel.entryId,
          cancel.sourceId,
        )).basisSourceId,
        pending.sourceId,
      );
      expect(
        await CalendarIncomingPublicationSourceRecord.db.count(session),
        3,
      );
      expect(
        (await service.incomingPublicationLink(first.entryId))!.hasLocalChanges,
        isFalse,
      );
    });
    test('unaccepted dismissed entries and terminal proof expire without leaving slot leaks', () async {
      final first = await receive(publicationWire());
      await service.incomingPublicationDismiss(first.entryId, 1);
      final row = (await CalendarIncomingPublicationRecord.db.find(session))
          .single;
      row.dismissedAt = DateTime.utc(2000);
      await CalendarIncomingPublicationRecord.db.updateRow(session, row);
      for (final receipt
          in await CalendarIncomingPublicationReceiptRecord.db.find(session)) {
        receipt.expiresAt = DateTime.utc(2000);
        await CalendarIncomingPublicationReceiptRecord.db.updateRow(
          session,
          receipt,
        );
      }
      await CalendarModule.runIncomingPublicationMaintenance(session);
      expect(await CalendarIncomingPublicationRecord.db.count(session), 0);
      expect(
        await CalendarIncomingPublicationSourceRecord.db.count(session),
        0,
      );
      expect(
        await CalendarIncomingPublicationReceiptRecord.db.count(session),
        0,
      );
    });
    test('deletion scrubs native/link proof and stable creation retry never recreates an event', () async {
      final first = await receive(publicationWire());
      final command = const Uuid().v4obj();
      final created = await add(first, command: command);
      final update = await receive(
        publicationWire(sequence: 1, summary: 'New accepted value'),
      );
      await apply(update, 1);
      await service.deleteEvent(created.eventId, 2);
      final link = (await CalendarIncomingPublicationLinkRecord.db.find(
        session,
      )).single;
      expect(link.deletedAt, isNotNull);
      expect(link.creationSourceId, isNull);
      expect(link.acceptedSourceId, isNull);
      expect(link.basisSourceId, isNull);
      expect(link.baselineDigest, isNull);
      expect(await CalendarEventDataRecord.db.count(session), 0);
      for (final receipt
          in await CalendarIncomingPublicationReceiptRecord.db.find(session)) {
        receipt.expiresAt = DateTime.utc(2000);
        await CalendarIncomingPublicationReceiptRecord.db.updateRow(
          session,
          receipt,
        );
      }
      final original = (await CalendarIncomingPublicationSourceRecord.db
          .findById(session, first.sourceId))!;
      original.inactiveAt = DateTime.utc(2000);
      await CalendarIncomingPublicationSourceRecord.db.updateRow(
        session,
        original,
      );
      await CalendarModule.runIncomingPublicationMaintenance(session);
      expect(
        await CalendarIncomingPublicationSourceRecord.db.findById(
          session,
          first.sourceId,
        ),
        isNull,
      );
      final retry = await add(first, command: command);
      expect(retry.eventId, created.eventId);
      expect(retry.unchanged, isTrue);
      expect(
        (await service.incomingPublicationLink(first.entryId))!.eventRevision,
        3,
      );
      final latest = await entry(first.entryId);
      await expectLater(
        service.incomingPublicationAdd(
          CalendarIncomingPublicationAddRequest(
            entryId: latest.id,
            sourceId: latest.sourceId,
            expectedRevision: latest.revision,
            calendarId: parent,
            expectedCalendarRevision: 1,
            commandId: const Uuid().v4obj(),
          ),
        ),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(await CalendarEventDataRecord.db.count(session), 0);
    });
    test(
      'source replacement guard works on a host without an incoming runtime',
      () async {
        final first = await receive(publicationWire());
        final created = await add(first);
        CalendarModule.install(
          session.serverpod,
          policy: policy,
          options: const CalendarModuleOptions(
            requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          ),
        );
        final plain = CalendarModule.service(session);
        final wire = Uint8List.fromList(
          utf8.encode(
            publicationWire(sequence: 1).replaceFirst('METHOD:PUBLISH\r\n', ''),
          ),
        );
        await expectLater(
          plain.replaceEventsFromImport(
            CalendarEventReplaceRequest(
              calendarId: parent,
              expectedRevision: 1,
              selection: [
                CalendarEventExportSelection(
                  eventId: created.eventId,
                  expectedRevision: 1,
                ),
              ],
              bytes: ByteData.sublistView(wire),
            ),
          ),
          failure(CalendarFailureCode.dependencyConflict),
        );
      },
    );
    test(
      'source summary and raw-source disclosure remain independent',
      () async {
        final first = await receive(publicationWire());
        host.denied.add(CalendarIncomingPublicationOperation.readSummary);
        final view = await entry(first.entryId);
        expect(view.summary, isNull);
        expect(view.timing, isNull);
        expect(
          (await service.incomingPublicationSource(
            first.entryId,
            first.sourceId,
          )).normalizedSource,
          contains('SUMMARY:Published value'),
        );
        host.denied.add(CalendarIncomingPublicationOperation.readSource);
        await expectLater(
          service.incomingPublicationSource(first.entryId, first.sourceId),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test('equal sequence with later stamp updates, lower sequence never wins on stamp', () async {
      await receive(publicationWire(sequence: 2));
      final update = await receive(
        publicationWire(
          sequence: 2,
          summary: 'Later stamp',
        ).replaceFirst('DTSTAMP:20261113T070000Z', 'DTSTAMP:20261113T070001Z'),
      );
      expect(update.outcome, CalendarIncomingPublicationOutcome.selected);
      final lower = await receive(
        publicationWire(
          sequence: 1,
        ).replaceFirst('DTSTAMP:20261113T070000Z', 'DTSTAMP:20271113T070000Z'),
      );
      expect(lower.outcome, CalendarIncomingPublicationOutcome.stale);
      expect((await entry(update.entryId)).summary, 'Later stamp');
    });
    test(
      'accepted and cancellation bases require their own source-read authority',
      () async {
        final first = await receive(publicationWire());
        final created = await add(first);
        final update = await receive(publicationWire(sequence: 1));
        final cancellation = await receive(
          publicationWire(sequence: 2, method: 'CANCEL'),
        );
        host.hiddenSources.add(update.sourceId);
        await expectLater(
          apply(cancellation, 1),
          failure(CalendarFailureCode.accessDenied),
        );
        host.hiddenSources.clear();
        host.hiddenSources.add(first.sourceId);
        await expectLater(
          apply(cancellation, 1),
          failure(CalendarFailureCode.accessDenied),
        );
        host.hiddenSources.clear();
        expect((await event(created.eventId)).revision, 1);
        expect(
          (await event(created.eventId)).status,
          CalendarEventStatus.confirmed,
        );
      },
    );
    test('unsupported attendees and detached components are never repaired into publications', () async {
      await expectLater(
        receive(
          publicationWire(extra: ['ATTENDEE:mailto:alice@example.invalid']),
        ),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        receive(publicationWire(extra: ['RECURRENCE-ID:20270328T090000Z'])),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarIncomingPublicationRecord.db.count(session), 0);
    });
    test('real native outbox PUBLISH/update/CANCEL/reopen MIME traverses the dedicated receiver', () async {
      final transport = SchedulingTransport();
      install(
        scheduling: CalendarSchedulingRuntime(
          host: SchedulingHost(),
          transport: transport,
        ),
      );
      final native = (await service.createEvent(
        CalendarEventCreateRequest(
          calendarId: parent,
          content: eventInput(summary: 'Native published value'),
        ),
      ))!.eventId;
      parent = (await service.create(createInput()))!.calendarId;
      Future<CalendarIncomingPublicationIngressReceipt> deliver(
        CalendarSchedulingReceipt receipt,
      ) async {
        await CalendarModule.runSchedulingMaintenance(session);
        final submission = transport.submissions.lastWhere(
          (s) => s.publicationId == receipt.publicationId,
        );
        final raw = utf8.encode(
          composeSyntheticSchedulingMime(submission, requireProtection: false),
        );
        return receiveHostImipPublication(
          session,
          raw: raw,
          outerProtection: ImipProtection.none,
          namespace: 'native-publication',
          deliveryKey: submission.deliveryKey.toString(),
          originReference: 'verified-publisher',
        );
      }

      final first = await service.saveAndPublishInformation(
        CalendarSchedulingSaveRequest(
          eventId: native,
          expectedRevision: 1,
          commandId: const Uuid().v4obj(),
          content: eventInput(summary: 'Native published value'),
          recipients: ['mailto:alice@example.invalid'],
        ),
      );
      final incoming = await deliver(first);
      final created = await add(incoming);
      expect((await event(created.eventId)).summary, 'Native published value');
      final updated = await service.saveAndPublishInformation(
        CalendarSchedulingSaveRequest(
          eventId: native,
          expectedRevision: 2,
          commandId: const Uuid().v4obj(),
          content: eventInput(summary: 'Native updated value'),
          recipients: ['mailto:alice@example.invalid'],
        ),
      );
      await apply(await deliver(updated), 1);
      final cancelled = await service.cancelPublishedInformation(
        CalendarSchedulingCancelRequest(
          eventId: native,
          expectedRevision: 3,
          commandId: const Uuid().v4obj(),
        ),
      );
      await apply(await deliver(cancelled), 2);
      expect((await event(created.eventId)).summary, 'Native updated value');
      expect(
        (await event(created.eventId)).status,
        CalendarEventStatus.cancelled,
      );
      final reopened = await service.reopenPublishedInformation(
        CalendarSchedulingReopenRequest(
          eventId: native,
          expectedRevision: 4,
          commandId: const Uuid().v4obj(),
        ),
      );
      await apply(await deliver(reopened), 3);
      expect(
        (await event(created.eventId)).status,
        CalendarEventStatus.confirmed,
      );
      expect(
        await CalendarSchedulingAttendeeResponseRecord.db.count(session),
        0,
      );
    });
    test('named-zone publications validate the full horizon and retain civil DST meaning', () async {
      final wire = publicationWire().replaceFirst(
        'DTSTART:20270328T090000Z',
        'DTSTART;TZID=Europe/Stockholm:20270328T090000',
      );
      final document = parseIcalendarSyntax(
        Uint8List.fromList(utf8.encode(wire)),
      );
      final envelope = document.components.single;
      final withZone = IcalendarSyntaxDocument([
        IcalendarSyntaxComponent(envelope.name, [
          ...envelope.entries,
          createIcalendarTimeZone('Europe/Stockholm'),
        ]),
      ]);
      final first = await receive(
        utf8.decode(serializeIcalendarSyntax(withZone)),
      );
      final created = await add(first);
      final before = (await event(created.eventId)).timing!;
      expect(before.zoneId, 'Europe/Stockholm');
      expect(before.start.hour, 9);
      final cancelled = await receive(
        publicationWire(sequence: 1, method: 'CANCEL', minimal: true),
      );
      await apply(cancelled, 1);
      expect((await event(created.eventId)).timing!.toJson(), before.toJson());
    });
    test('DATE publication keeps civil timing through cancellation', () async {
      String wire(int sequence, {String method = 'PUBLISH'}) =>
          publicationWire(sequence: sequence, method: method)
              .replaceFirst(
                'DTSTART:20270328T090000Z',
                'DTSTART;VALUE=DATE:20270328',
              )
              .replaceFirst('DURATION:PT1H', 'DURATION:P1D');
      final first = await receive(wire(0));
      final created = await add(first);
      final before = (await event(created.eventId)).timing!.toJson();
      final cancellation = await receive(wire(1, method: 'CANCEL'));
      await apply(cancellation, 1);
      expect((await event(created.eventId)).timing!.toJson(), before);
      final reopened = await receive(wire(2));
      await apply(reopened, 2);
      expect((await event(created.eventId)).timing!.toJson(), before);
    });
    test('recurrence PERIOD additions retain the complete master', () async {
      final first = await receive(
        publicationWire(
          extra: [
            'RRULE:FREQ=DAILY;COUNT=3',
            'RDATE;VALUE=PERIOD:20270403T090000Z/PT2H',
            'EXDATE:20270329T090000Z',
          ],
        ),
      );
      await add(first);
      expect(
        (await service.incomingPublicationLink(first.entryId))!.hasLocalChanges,
        isFalse,
      );
      expect((await entry(first.entryId)).recurring, isTrue);
      final source = await service.incomingPublicationSource(
        first.entryId,
        first.sourceId,
      );
      expect(source.normalizedSource, contains('RDATE;VALUE=PERIOD:'));
      expect(source.normalizedSource, contains('EXDATE:'));
    });
    test('optional source versions remain absent', () async {
      final first = await receive(
        publicationWire().replaceFirst('SEQUENCE:0\r\n', ''),
      );
      await add(first);
      expect((await entry(first.entryId)).sequence, isNull);
      final source = await service.incomingPublicationSource(
        first.entryId,
        first.sourceId,
      );
      expect(source.sequence, isNull);
      expect(source.normalizedSource, isNot(contains('SEQUENCE:')));
      expect(
        (await service.incomingPublicationLink(first.entryId))!.hasLocalChanges,
        isFalse,
      );
    });
    test(
      'MIME bridge preserves publication purpose and trusted origin gate',
      () async {
        final raw = composeSyntheticIngressMime(
          utf8.encode(publicationWire()),
          method: IcalendarSchedulingMethod.publish,
        );
        final receipt = await receiveHostImipPublication(
          session,
          raw: raw,
          outerProtection: ImipProtection.none,
          namespace: 'synthetic',
          deliveryKey: 'mime-publication',
          originReference: 'verified-publisher',
        );
        expect((await entry(receipt.entryId)).summary, 'Published value');
        expect(await CalendarEventRecord.db.count(session), 0);
        await expectLater(
          receiveHostImipPublication(
            session,
            raw: raw,
            outerProtection: ImipProtection.none,
            namespace: 'synthetic',
            deliveryKey: 'mime-forged',
            originReference: 'forged',
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        expect(
          await CalendarIncomingPublicationReceiptRecord.db.count(session),
          1,
        );
      },
    );
    test('final apply revocation rolls back native and review state', () async {
      final first = await receive(publicationWire());
      final created = await add(first);
      final update = await receive(
        publicationWire(sequence: 1, summary: 'Uncommitted'),
      );
      final before = await CalendarIncomingPublicationLinkRecord.db
          .findFirstRow(session);
      host.denyFinal = true;
      await expectLater(
        apply(update, 1),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denyFinal = false;
      expect((await event(created.eventId)).summary, 'Published value');
      expect((await event(created.eventId)).revision, 1);
      final after = await CalendarIncomingPublicationLinkRecord.db.findFirstRow(
        session,
      );
      expect(after!.acceptedSourceId, before!.acceptedSourceId);
      expect(after.lastCommandId, isNull);
      expect((await entry(first.entryId)).dismissedAt, isNull);
    });
    test(
      'unknown whole cancellation cannot create a placeholder event or entry',
      () async {
        await expectLater(
          receive(
            publicationWire(sequence: 2, method: 'CANCEL', minimal: true),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarIncomingPublicationRecord.db.count(session), 0);
        expect(await CalendarEventRecord.db.count(session), 0);
      },
    );
  });
}
