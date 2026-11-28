import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, eventInput, failure;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('free/busy exchange source deletion', (builder, endpoints) {
    late Session session;
    late CalendarService service;
    late TestPolicy policy;
    late TestFreeBusyTransport transport;
    late UuidValue calendar;
    final now = DateTime.utc(2026, 11, 6);

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
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
      );
      service = CalendarModule.service(session);
      calendar = (await service.create(createInput()))!.calendarId;
    });

    CalendarFreeBusyIngress incoming(
      String key,
      String stamp, {
      String comment = 'Synthetic request',
      String method = 'REQUEST',
      String end = '20261107T000000Z',
    }) => CalendarFreeBusyIngress(
      mailbox: CalendarFreeBusyMailbox(
        scopeKey: 'test:alice',
        ownerKey: 'private:alice',
        calendarId: calendar,
        address: 'mailto:alice@example.invalid',
        bindingRef: 'synthetic-binding',
      ),
      namespace: 'synthetic-test',
      deliveryKey: key,
      originRef: 'verified-synthetic-origin',
      payload: [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:-//Synthetic//EN',
        'METHOD:$method',
        'BEGIN:VFREEBUSY',
        'UID:synthetic-source-uid',
        'DTSTAMP:$stamp',
        'DTSTART:20261106T000000Z',
        'DTEND:$end',
        'ORGANIZER:mailto:remote@example.invalid',
        if (method == 'REQUEST') 'ATTENDEE:mailto:alice@example.invalid',
        'COMMENT:$comment',
        'END:VFREEBUSY',
        'END:VCALENDAR',
        '',
      ].join('\r\n'),
    );
    TestFreeBusyHost installExchange({
      CalendarFreeBusyExchangeOptions? options,
    }) {
      final host = TestFreeBusyHost();
      transport = TestFreeBusyTransport();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
          policyTimeout: Duration(seconds: 5),
        ),
        freeBusyExchanges: CalendarFreeBusyExchangeRuntime(
          host: host,
          transport: transport,
          options: options,
        ),
      );
      service = CalendarModule.service(session);
      return host;
    }

    test(
      'intake stores source without booking or changing domain generation',
      () async {
        final host = installExchange();
        final before = (await CalendarScopeRecord.db.findFirstRow(session))!
            .revision;
        final receipt = await CalendarModule.receiveFreeBusy(
          session,
          incoming('one', '20261101T000000Z'),
        );
        expect(receipt.outcome, 'current');
        expect(host.sawBackground, isTrue);
        expect(await CalendarEventRecord.db.count(session), 0);
        expect(
          (await CalendarScopeRecord.db.findFirstRow(session))!.revision,
          before,
        );
        final source = (await CalendarFreeBusySourceRecord.db.findById(
          session,
          receipt.sourceId,
        ))!;
        expect(source.payload, contains('UID:synthetic-source-uid'));
        expect(source.header, isNot(contains('synthetic-source-uid')));
        expect(source.header, isNot(contains('FREEBUSY')));
        expect(source.header, isNot(contains('COMMENT')));
      },
    );

    test(
      'higher source replaces, stale/conflicting data cannot silently select',
      () async {
        installExchange();
        final first = await CalendarModule.receiveFreeBusy(
          session,
          incoming('one', '20261102T000000Z'),
        );
        final stale = await CalendarModule.receiveFreeBusy(
          session,
          incoming('old', '20261101T000000Z'),
        );
        expect(stale.outcome, 'stale');
        final conflict = await CalendarModule.receiveFreeBusy(
          session,
          incoming('conflict', '20261102T000000Z', comment: 'Different source'),
        );
        expect(conflict.outcome, 'conflict');
        final head = (await CalendarFreeBusyRequestHeadRecord.db.findById(
          session,
          first.headId!,
        ))!;
        expect(head.currentSourceId, first.sourceId);
        expect(head.conflicted, isTrue);
        final next = await CalendarModule.receiveFreeBusy(
          session,
          incoming('new', '20261103T000000Z'),
        );
        expect(next.outcome, 'current');
        expect(
          (await CalendarFreeBusyRequestHeadRecord.db.findById(
            session,
            first.headId!,
          ))!.conflicted,
          isFalse,
        );
        final retry = await CalendarModule.receiveFreeBusy(
          session,
          incoming('one', '20261102T000000Z'),
        );
        expect(retry.toJson(), first.toJson());
        expect(
          (await CalendarFreeBusyRequestHeadRecord.db.findById(
            session,
            first.headId!,
          ))!.currentSourceId,
          next.sourceId,
        );
      },
    );

    test('same UID cannot change its immutable window', () async {
      installExchange();
      await CalendarModule.receiveFreeBusy(
        session,
        incoming('one', '20261101T000000Z'),
      );
      await expectLater(
        CalendarModule.receiveFreeBusy(
          session,
          incoming(
            'changed-window',
            '20261102T000000Z',
            end: '20261108T000000Z',
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(await CalendarFreeBusySourceRecord.db.count(session), 1);
      expect(await CalendarFreeBusyIngressReceiptRecord.db.count(session), 1);
    });

    test('historical retries precede admission and final denial rolls back all rows', () async {
      final host = installExchange(
        options: CalendarFreeBusyExchangeOptions(maxOwnerSources: 1),
      );
      final first = await CalendarModule.receiveFreeBusy(
        session,
        incoming('one', '20261101T000000Z'),
      );
      final duplicate = await CalendarModule.receiveFreeBusy(
        session,
        incoming('one', '20261101T000000Z'),
      );
      expect(duplicate.toJson(), first.toJson());
      await expectLater(
        CalendarModule.receiveFreeBusy(
          session,
          incoming('two', '20261102T000000Z'),
        ),
        failure(CalendarFailureCode.limitExceeded),
      );
      host.denyFinal = true;
      await expectLater(
        CalendarModule.receiveFreeBusy(
          session,
          incoming('one', '20261101T000000Z'),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarFreeBusyIngressReceiptRecord.db.count(session), 1);
    });

    test('final ingress denial leaves no source, head or receipt', () async {
      installExchange().denyFinal = true;
      await expectLater(
        CalendarModule.receiveFreeBusy(
          session,
          incoming('one', '20261101T000000Z'),
        ),
        failure(CalendarFailureCode.accessDenied),
      );
      expect(await CalendarFreeBusyRequestHeadRecord.db.count(session), 0);
      expect(await CalendarFreeBusySourceRecord.db.count(session), 0);
      expect(await CalendarFreeBusyIngressReceiptRecord.db.count(session), 0);
    });

    CalendarFreeBusyPublishRequest publishRequest() =>
        CalendarFreeBusyPublishRequest(
          commandId: UuidValue.fromString(const Uuid().v4()),
          calendarId: calendar,
          fromUtc: now,
          untilUtc: now.add(const Duration(days: 1)),
          recipients: ['mailto:remote@example.invalid'],
        );

    test('explicit publication captures complete sources and stable private intent', () async {
      installExchange();
      final event = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: calendar, content: eventInput()),
      ))!.eventId;
      final request = publishRequest();
      final receipt = await service.publishFreeBusy(request);
      final retry = await service.publishFreeBusy(request);
      expect(retry.toJson(), receipt.toJson());
      final command = (await CalendarFreeBusyCommandRecord.db.findById(
        session,
        receipt.id,
      ))!;
      expect(command.payload, contains('METHOD:PUBLISH'));
      expect(command.payload, isNot(contains('SUMMARY')));
      final refs = await CalendarFreeBusySourceReferenceRecord.db.find(session);
      expect(refs.single.eventId, event);
      expect(await CalendarFreeBusyDeliveryRecord.db.count(session), 1);
      await expectLater(
        service.publishFreeBusy(
          request.copyWith(untilUtc: now.add(const Duration(days: 2))),
        ),
        failure(CalendarFailureCode.validation),
      );
    });

    test(
      'malformed native recipient rejects as validation without intent',
      () async {
        installExchange();
        for (final recipient in [
          'not an absolute calendar address',
          'mailto:x@example.invalid\r\nFREEBUSY:bad',
        ]) {
          await expectLater(
            service.requestFreeBusy(
              publishRequest().copyWith(recipients: [recipient]),
            ),
            failure(CalendarFailureCode.validation),
          );
        }
        expect(await CalendarFreeBusyCommandRecord.db.count(session), 0);
        expect(await CalendarFreeBusyDeliveryRecord.db.count(session), 0);
      },
    );

    test('unknown source calculation cannot queue a report', () async {
      installExchange();
      final event = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: calendar, content: eventInput()),
      ))!.eventId;
      policy.busyDenied.add(event);
      await expectLater(
        service.publishFreeBusy(publishRequest()),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await CalendarFreeBusyCommandRecord.db.count(session), 0);
      expect(await CalendarFreeBusyDeliveryRecord.db.count(session), 0);
    });

    test(
      'data-free REQUEST and refusal need no booking projection permission',
      () async {
        installExchange();
        policy.denied.addAll([
          CalendarPermission.readFreeBusy,
          CalendarPermission.exportFreeBusy,
          CalendarPermission.projectEventBusy,
          CalendarPermission.projectAvailability,
        ]);
        final requested = await service.requestFreeBusy(publishRequest());
        final outgoing = (await CalendarFreeBusyCommandRecord.db.findById(
          session,
          requested.id,
        ))!;
        expect(outgoing.payload, contains('METHOD:REQUEST'));
        expect(outgoing.payload, isNot(contains('FREEBUSY;')));
        expect(
          await CalendarFreeBusySourceReferenceRecord.db.count(session),
          0,
        );
        final source = await CalendarModule.receiveFreeBusy(
          session,
          incoming('request', '20261101T000000Z'),
        );
        final head = (await CalendarFreeBusyRequestHeadRecord.db.findById(
          session,
          source.headId!,
        ))!;
        final refusal = await service.refuseFreeBusy(
          CalendarFreeBusyReplyRequest(
            commandId: UuidValue.fromString(const Uuid().v4()),
            sourceId: source.sourceId,
            expectedSourceRevision: head.sourceRevision,
            expectedReplyRevision: head.replyRevision,
          ),
        );
        final refused = (await CalendarFreeBusyCommandRecord.db.findById(
          session,
          refusal.id,
        ))!;
        expect(refused.payload, contains('REQUEST-STATUS:3.8;No authority'));
        expect(refused.payload, contains('UID:synthetic-source-uid'));
        expect(
          refused.payload,
          contains('ATTENDEE:mailto:alice@example.invalid'),
        );
      },
    );

    test(
      'source change fences earlier replies without touching other commands',
      () async {
        installExchange();
        final one = await CalendarModule.receiveFreeBusy(
          session,
          incoming('one', '20261101T000000Z'),
        );
        final refusal = await service.refuseFreeBusy(
          CalendarFreeBusyReplyRequest(
            commandId: UuidValue.fromString(const Uuid().v4()),
            sourceId: one.sourceId,
            expectedSourceRevision: one.sourceRevision!,
            expectedReplyRevision: 0,
          ),
        );
        final unrelated = await service.requestFreeBusy(publishRequest());
        await CalendarModule.receiveFreeBusy(
          session,
          incoming('new', '20261102T000000Z'),
        );
        final withdrawn = (await CalendarFreeBusyDeliveryRecord.db.findFirstRow(
          session,
          where: (t) => t.commandId.equals(refusal.id),
        ))!;
        expect(withdrawn.state, 'withdrawn');
        expect(withdrawn.generation, 2);
        expect(
          (await CalendarFreeBusyDeliveryRecord.db.findFirstRow(
            session,
            where: (t) => t.commandId.equals(unrelated.id),
          ))!.state,
          'queued',
        );
      },
    );

    test('worker uses actor-free actual source checks and accepts each delivery once', () async {
      final host = installExchange();
      await service.createEvent(
        CalendarEventCreateRequest(calendarId: calendar, content: eventInput()),
      );
      final receipt = await service.publishFreeBusy(publishRequest());
      // The SDK rollback proxy forbids simultaneous transactions. Competing
      // processes must be validated by the separate real-storage recovery harness.
      expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 1);
      expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 0);
      expect(transport.sent, hasLength(1));
      expect(transport.sent.single.deliveryKey, receipt.deliveryIds.single);
      expect(
        host.sourceRequests.map((r) => r.operation),
        containsAll([
          CalendarPermission.readFreeBusy,
          CalendarPermission.exportFreeBusy,
          CalendarPermission.projectEventBusy,
        ]),
      );
      expect(host.sourceActors, everyElement(isNull));
      expect(
        (await CalendarFreeBusyDeliveryRecord.db.findById(
          session,
          receipt.deliveryIds.single,
        ))!.state,
        'accepted',
      );
      expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 0);
    });

    test('source addition withdraws a snapshot but unrelated calendar writes do not', () async {
      installExchange();
      final unchanged = await service.publishFreeBusy(publishRequest());
      await service.create(createInput('Unrelated calendar'));
      expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 1);
      expect(transport.sent.single.deliveryKey, unchanged.deliveryIds.single);
      final changed = await service.publishFreeBusy(publishRequest());
      await service.createEvent(
        CalendarEventCreateRequest(calendarId: calendar, content: eventInput()),
      );
      expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 0);
      expect(
        (await CalendarFreeBusyDeliveryRecord.db.findById(
          session,
          changed.deliveryIds.single,
        ))!.state,
        'withdrawn',
      );
      expect(transport.sent, hasLength(1));
    });

    test('background source revocation withdraws without transport', () async {
      final host = installExchange();
      final queued = await service.publishFreeBusy(publishRequest());
      host.sourceVerdict = CalendarAuthorizationVerdict.deny;
      expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 0);
      expect(transport.sent, isEmpty);
      expect(
        (await CalendarFreeBusyDeliveryRecord.db.findById(
          session,
          queued.deliveryIds.single,
        ))!.state,
        'withdrawn',
      );
    });

    test(
      'uncertain transport retries the same UUID and exact payload',
      () async {
        installExchange();
        final queued = await service.requestFreeBusy(publishRequest());
        transport.outcome = CalendarSchedulingTransportOutcome.uncertain;
        expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 1);
        final row = (await CalendarFreeBusyDeliveryRecord.db.findById(
          session,
          queued.deliveryIds.single,
        ))!;
        expect(row.state, 'queued');
        row.nextAttemptAt = DateTime.utc(1970);
        await CalendarFreeBusyDeliveryRecord.db.updateRow(session, row);
        transport.outcome = CalendarSchedulingTransportOutcome.accepted;
        expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 1);
        expect(transport.sent, hasLength(2));
        expect(transport.sent[0].deliveryKey, transport.sent[1].deliveryKey);
        expect(transport.sent[0].payload, transport.sent[1].payload);
        expect(await CalendarFreeBusyAttemptRecord.db.count(session), 2);
      },
    );

    test('deletion during submission fences acceptance without reactivating a report', () async {
      installExchange();
      final event = (await service.createEvent(
        CalendarEventCreateRequest(calendarId: calendar, content: eventInput()),
      ))!.eventId;
      final queued = await service.publishFreeBusy(publishRequest());
      transport.onSubmit = () async {
        await service.deleteEvent(event, 1);
      };
      expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 1);
      final row = (await CalendarFreeBusyDeliveryRecord.db.findById(
        session,
        queued.deliveryIds.single,
      ))!;
      expect(row.state, 'withdrawn');
      expect(
        (await CalendarFreeBusyCommandRecord.db.findById(
          session,
          queued.id,
        ))!.payload,
        isNull,
      );
      expect(
        (await CalendarFreeBusyAttemptRecord.db.findFirstRow(session))!.outcome,
        'superseded',
      );
      expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 0);
      expect(transport.sent, hasLength(1));
    });

    test(
      'header/raw permissions and private cursor families stay independent',
      () async {
        final host = installExchange();
        final first = await CalendarModule.receiveFreeBusy(
          session,
          incoming('one', '20261101T000000Z'),
        );
        await CalendarModule.receiveFreeBusy(
          session,
          incoming('two', '20261102T000000Z'),
        );
        final page = await service.listFreeBusyInbox(pageSize: 1);
        expect(page.items, hasLength(1));
        expect(page.cursor, isNotNull);
        host.denied.add(CalendarFreeBusyExchangeOperation.readSource);
        expect(
          (await service.getFreeBusyMessage(first.sourceId)).header,
          isNot(contains('COMMENT')),
        );
        await expectLater(
          service.getFreeBusySource(first.sourceId),
          failure(CalendarFailureCode.accessDenied),
        );
        await expectLater(
          service.listFreeBusyOutgoing(pageSize: 1, cursor: page.cursor),
          failure(CalendarFailureCode.invalidCursor),
        );
        await expectLater(
          service.list(
            pageSize: 1,
            cursor: page.cursor,
            fieldGroups: CalendarFieldGroup.values,
          ),
          failure(CalendarFailureCode.invalidCursor),
        );
        final revision = (await CalendarScopeRecord.db.findFirstRow(session))!
            .revision;
        await service.dismissFreeBusyMessage(first.sourceId);
        expect(
          (await CalendarScopeRecord.db.findFirstRow(session))!.revision,
          revision,
        );
        await expectLater(
          service.listFreeBusyInbox(pageSize: 1, cursor: page.cursor),
          failure(CalendarFailureCode.invalidCursor),
        );
      },
    );

    test(
      'private withdrawal preserves accepted outcomes and retry identity',
      () async {
        installExchange();
        final request = publishRequest();
        final queued = await service.requestFreeBusy(request);
        final withdrawn = await service.withdrawFreeBusyCommand(queued.id);
        expect(withdrawn.toJson(), queued.toJson());
        expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 0);
        expect(
          (await service.requestFreeBusy(request)).toJson(),
          queued.toJson(),
        );
        final other = await service.requestFreeBusy(publishRequest());
        expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 1);
        await service.withdrawFreeBusyCommand(other.id);
        expect(
          (await service.freeBusyDeliveryActivity(other.id)).items.single.state,
          'accepted',
        );
      },
    );

    test(
      'REPLY correlates the exact retained request UID and window',
      () async {
        installExchange();
        final request = await service.requestFreeBusy(publishRequest());
        final outgoing = (await CalendarFreeBusyCommandRecord.db.findById(
          session,
          request.id,
        ))!;
        final payload = outgoing.payload!.replaceFirst(
          'METHOD:REQUEST',
          'METHOD:REPLY',
        );
        CalendarFreeBusyIngress response(String key, String body) =>
            CalendarFreeBusyIngress(
              mailbox: CalendarFreeBusyMailbox(
                scopeKey: 'test:alice',
                ownerKey: 'private:alice',
                calendarId: calendar,
                address: 'mailto:alice@example.invalid',
                bindingRef: 'synthetic-binding',
              ),
              namespace: 'synthetic-test',
              deliveryKey: key,
              originRef: 'verified-synthetic-origin',
              payload: body,
            );
        final accepted = await CalendarModule.receiveFreeBusy(
          session,
          response('reply', payload),
        );
        final stored = (await CalendarFreeBusySourceRecord.db.findById(
          session,
          accepted.sourceId,
        ))!;
        expect(stored.requestCommandId, request.id);
        expect(stored.payload, payload);
        await expectLater(
          CalendarModule.receiveFreeBusy(
            session,
            response(
              'bad-window',
              payload.replaceFirst('20261107T000000Z', '20261108T000000Z'),
            ),
          ),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarEventRecord.db.count(session), 0);
      },
    );

    test(
      'ordered retention releases pins without retaining intervals in markers',
      () async {
        installExchange();
        final incomingReceipt = await CalendarModule.receiveFreeBusy(
          session,
          incoming('one', '20261101T000000Z'),
        );
        final queued = await service.refuseFreeBusy(
          CalendarFreeBusyReplyRequest(
            commandId: UuidValue.fromString(const Uuid().v4()),
            sourceId: incomingReceipt.sourceId,
            expectedSourceRevision: incomingReceipt.sourceRevision!,
            expectedReplyRevision: 0,
          ),
        );
        await CalendarModule.runFreeBusyExchangeMaintenance(session);
        final command = (await CalendarFreeBusyCommandRecord.db.findById(
          session,
          queued.id,
        ))!;
        command.terminalAt = DateTime.utc(1970);
        await CalendarFreeBusyCommandRecord.db.updateRow(session, command);
        final source = (await CalendarFreeBusySourceRecord.db.findById(
          session,
          incomingReceipt.sourceId,
        ))!;
        source.expiresAt = DateTime.utc(1970);
        await CalendarFreeBusySourceRecord.db.updateRow(session, source);
        final receipt = (await CalendarFreeBusyIngressReceiptRecord.db.findById(
          session,
          incomingReceipt.id,
        ))!;
        receipt.expiresAt = DateTime.utc(1970);
        await CalendarFreeBusyIngressReceiptRecord.db.updateRow(
          session,
          receipt,
        );
        await CalendarModule.runFreeBusyExchangeMaintenance(session);
        expect(
          (await CalendarFreeBusyCommandRecord.db.findById(
            session,
            command.id!,
          ))!.payload,
          isNull,
        );
        await CalendarModule.runFreeBusyExchangeMaintenance(session);
        final marker = (await CalendarFreeBusySourceRecord.db.findById(
          session,
          source.id!,
        ))!;
        expect(marker.payload, isNull);
        expect(marker.header, isNull);
        expect(marker.originRef, isNull);
        expect(marker.requestCommandId, isNull);
        expect(marker.headId, isNull);
        marker.purgedAt = DateTime.utc(1970);
        await CalendarFreeBusySourceRecord.db.updateRow(session, marker);
        final commandMarker = (await CalendarFreeBusyCommandRecord.db.findById(
          session,
          command.id!,
        ))!;
        commandMarker.scrubbedAt = DateTime.utc(1970);
        await CalendarFreeBusyCommandRecord.db.updateRow(
          session,
          commandMarker,
        );
        final head = (await CalendarFreeBusyRequestHeadRecord.db.findById(
          session,
          incomingReceipt.headId!,
        ))!;
        head.purgedAt = DateTime.utc(1970);
        await CalendarFreeBusyRequestHeadRecord.db.updateRow(session, head);
        await CalendarModule.runFreeBusyExchangeMaintenance(session);
        expect(await CalendarFreeBusySourceRecord.db.count(session), 0);
        expect(await CalendarFreeBusyCommandRecord.db.count(session), 0);
        expect(await CalendarFreeBusyRequestHeadRecord.db.count(session), 0);
        expect(await CalendarFreeBusyDeliveryRecord.db.count(session), 0);
        expect(await CalendarFreeBusyAttemptRecord.db.count(session), 0);
      },
    );

    test(
      'distinct verified local recipients keep independent heads for one UID',
      () async {
        final host = installExchange();
        final secondCalendar = (await service.create(
          createInput('Second mailbox'),
        ))!.calendarId;
        host.mailboxes[secondCalendar] = 'mailto:room@example.invalid';
        final original = incoming('for-alice', '20261101T000000Z');
        final body = original.payload.replaceFirst(
          'ATTENDEE:mailto:alice@example.invalid',
          'ATTENDEE:mailto:alice@example.invalid\r\nATTENDEE:mailto:room@example.invalid',
        );
        CalendarFreeBusyIngress envelope(
          String key,
          CalendarFreeBusyMailbox mailbox,
        ) => CalendarFreeBusyIngress(
          mailbox: mailbox,
          namespace: original.namespace,
          deliveryKey: key,
          originRef: original.originRef,
          payload: body,
        );
        final one = await CalendarModule.receiveFreeBusy(
          session,
          envelope('for-alice', original.mailbox),
        );
        final two = await CalendarModule.receiveFreeBusy(
          session,
          envelope(
            'for-room',
            CalendarFreeBusyMailbox(
              scopeKey: original.mailbox.scopeKey,
              ownerKey: original.mailbox.ownerKey,
              calendarId: secondCalendar,
              address: 'mailto:room@example.invalid',
              bindingRef: 'synthetic-binding',
            ),
          ),
        );
        expect(one.headId, isNot(two.headId));
        for (final result in [one, two]) {
          await service.refuseFreeBusy(
            CalendarFreeBusyReplyRequest(
              commandId: Uuid().v4obj(),
              sourceId: result.sourceId,
              expectedSourceRevision: 1,
              expectedReplyRevision: 0,
            ),
          );
        }
        expect(await CalendarFreeBusyRequestHeadRecord.db.count(session), 2);
      },
    );

    test('expired source aliases cannot create fresh retention pins; exact receipts stay stable', () async {
      installExchange();
      final original = incoming('one', '20261101T000000Z');
      final receipt = await CalendarModule.receiveFreeBusy(session, original);
      final source = (await CalendarFreeBusySourceRecord.db.findById(
        session,
        receipt.sourceId,
      ))!;
      source.expiresAt = DateTime.utc(1970);
      await CalendarFreeBusySourceRecord.db.updateRow(session, source);
      expect(
        (await CalendarModule.receiveFreeBusy(session, original)).toJson(),
        receipt.toJson(),
      );
      await expectLater(
        CalendarModule.receiveFreeBusy(
          session,
          incoming('new-key', '20261101T000000Z'),
        ),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await CalendarFreeBusyIngressReceiptRecord.db.count(session), 1);
    });

    test(
      'action authority precedes stale revision and retry-criteria errors',
      () async {
        final host = installExchange();
        final received = await CalendarModule.receiveFreeBusy(
          session,
          incoming('one', '20261101T000000Z'),
        );
        host.denied.add(CalendarFreeBusyExchangeOperation.share);
        await expectLater(
          service.replyFreeBusy(
            CalendarFreeBusyReplyRequest(
              commandId: Uuid().v4obj(),
              sourceId: received.sourceId,
              expectedSourceRevision: 99,
              expectedReplyRevision: 99,
            ),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
        final request = publishRequest();
        await service.publishFreeBusy(request);
        host.denied.add(CalendarFreeBusyExchangeOperation.publish);
        await expectLater(
          service.publishFreeBusy(
            request.copyWith(untilUtc: now.add(const Duration(days: 2))),
          ),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );

    test(
      'source digest/header tampering fails unavailable without queued work',
      () async {
        installExchange();
        final received = await CalendarModule.receiveFreeBusy(
          session,
          incoming('one', '20261101T000000Z'),
        );
        final source = (await CalendarFreeBusySourceRecord.db.findById(
          session,
          received.sourceId,
        ))!;
        source.payload = source.payload!.replaceFirst(
          'Synthetic request',
          'Changed source',
        );
        await CalendarFreeBusySourceRecord.db.updateRow(session, source);
        await expectLater(
          service.getFreeBusyMessage(source.id!),
          failure(CalendarFailureCode.unavailable),
        );
        await expectLater(
          service.replyFreeBusy(
            CalendarFreeBusyReplyRequest(
              commandId: Uuid().v4obj(),
              sourceId: received.sourceId,
              expectedSourceRevision: 1,
              expectedReplyRevision: 0,
            ),
          ),
          failure(CalendarFailureCode.unavailable),
        );
        expect(await CalendarFreeBusyCommandRecord.db.count(session), 0);
      },
    );

    test(
      'long escaped source UID survives an authorized native share',
      () async {
        installExchange();
        final input = incoming('long', '20261101T000000Z');
        final uid = '${List.filled(2048, 'ü').join()},;\\\n';
        final receipt = await CalendarModule.receiveFreeBusy(
          session,
          CalendarFreeBusyIngress(
            mailbox: input.mailbox,
            namespace: input.namespace,
            deliveryKey: input.deliveryKey,
            originRef: input.originRef,
            payload: input.payload.replaceFirst(
              'UID:synthetic-source-uid',
              'UID:${encodeIcalendarText(uid)}',
            ),
          ),
        );
        final sent = await service.replyFreeBusy(
          CalendarFreeBusyReplyRequest(
            commandId: Uuid().v4obj(),
            sourceId: receipt.sourceId,
            expectedSourceRevision: 1,
            expectedReplyRevision: 0,
          ),
        );
        final body = (await CalendarFreeBusyCommandRecord.db.findById(
          session,
          sent.id,
        ))!.payload!;
        expect(
          parseIcalendarFreeBusyMessage(utf8.encode(body))
              .components
              .single
              .uid,
          uid,
        );
        expect(body, isNot(contains('partition-validation')));
      },
    );

    test('expiry is checked after slow final authorization, before leasing or submitting', () async {
      final host = installExchange();
      final receipt = await service.requestFreeBusy(publishRequest());
      final row = (await CalendarFreeBusyDeliveryRecord.db.findById(
        session,
        receipt.deliveryIds.single,
      ))!;
      final dbNow =
          (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                  .single
                  .single
              as DateTime;
      row.expiresAt = dbNow.toUtc().add(const Duration(seconds: 2));
      await CalendarFreeBusyDeliveryRecord.db.updateRow(session, row);
      host.dispatchDelay = const Duration(seconds: 3);
      expect(await CalendarModule.runFreeBusyExchangeMaintenance(session), 0);
      expect(host.didDelay, isTrue);
      expect(transport.sent, isEmpty);
      expect(
        (await CalendarFreeBusyDeliveryRecord.db.findById(
          session,
          row.id!,
        ))!.state,
        'expired',
      );
      expect(await CalendarFreeBusyAttemptRecord.db.count(session), 0);
    });

    test('a storage failure after command/reference writes rolls back the whole intent', () async {
      installExchange();
      await service.createEvent(
        CalendarEventCreateRequest(calendarId: calendar, content: eventInput()),
      );
      await session.db.unsafeExecute(
        'ALTER TABLE serverpod_calendar_fb_delivery ADD CONSTRAINT freebusy_probe_fail CHECK ("scopeKey" <> \'test:alice\')',
      );
      try {
        await expectLater(
          service.publishFreeBusy(publishRequest()),
          throwsA(
            predicate((e) => e.toString().contains('freebusy_probe_fail')),
          ),
        );
        expect(await CalendarFreeBusyCommandRecord.db.count(session), 0);
        expect(
          await CalendarFreeBusySourceReferenceRecord.db.count(session),
          0,
        );
        expect(await CalendarFreeBusyDeliveryRecord.db.count(session), 0);
      } finally {
        await session.db.unsafeExecute(
          'ALTER TABLE serverpod_calendar_fb_delivery DROP CONSTRAINT freebusy_probe_fail',
        );
      }
    });

    Future<CalendarFreeBusyCommandRecord> report({
      UuidValue? event,
      UuidValue? availability,
      String state = 'queued',
      UuidValue? parent,
    }) async {
      final command = await CalendarFreeBusyCommandRecord.db.insertRow(
        session,
        CalendarFreeBusyCommandRecord(
          scopeKey: 'test:alice',
          ownerKey: 'private:alice',
          commandId: UuidValue.fromString(const Uuid().v4()),
          criteriaDigest: 'synthetic-criteria',
          method: 'publish',
          action: 'publish',
          calendarId: parent ?? calendar,
          stamp: now,
          timezoneIdentity: 'synthetic-tz-profile',
          calculationProfile: 1,
          parentSettingsDigest: 'synthetic-settings',
          arguments: 'synthetic private query and sender',
          payload: 'synthetic busy interval body',
          payloadDigest: 'synthetic-digest',
          byteCount: 28,
          generation: 1,
          receipt: 'opaque-result',
          createdAt: now,
          expiresAt: now.add(const Duration(minutes: 15)),
        ),
      );
      await CalendarFreeBusyDeliveryRecord.db.insertRow(
        session,
        CalendarFreeBusyDeliveryRecord(
          scopeKey: command.scopeKey,
          ownerKey: command.ownerKey,
          commandId: command.id!,
          recipientAddress: 'mailto:synthetic@example.invalid',
          routeRef: 'synthetic-route',
          authorityRef: 'synthetic-authority',
          generation: 1,
          state: state,
          nextAttemptAt: now,
          leaseOwner: UuidValue.fromString(const Uuid().v4()),
          leaseToken: UuidValue.fromString(const Uuid().v4()),
          leaseUntil: now.add(const Duration(minutes: 2)),
          createdAt: now,
          expiresAt: command.expiresAt,
          terminalAt: state == 'accepted' ? now : null,
          providerReceipt: state == 'accepted'
              ? 'synthetic-private-acceptance'
              : null,
        ),
      );
      if (event != null || availability != null) {
        await CalendarFreeBusySourceReferenceRecord.db.insertRow(
          session,
          CalendarFreeBusySourceReferenceRecord(
            scopeKey: command.scopeKey,
            ownerKey: command.ownerKey,
            commandId: command.id!,
            sourceKey: 'synthetic-source',
            eventId: event,
            availabilityId: availability,
            revision: 1,
            contentDigest: 'synthetic-content',
          ),
        );
      }
      return command;
    }

    Future<void> expectScrubbed(
      CalendarFreeBusyCommandRecord original,
      String state,
    ) async {
      final row = (await CalendarFreeBusyCommandRecord.db.findById(
        session,
        original.id!,
      ))!;
      expect(row.payload, isNull);
      expect(row.arguments, isNull);
      expect(row.parentSettingsDigest, isNull);
      expect(row.timezoneIdentity, isNull);
      expect(row.calculationProfile, isNull);
      expect(row.byteCount, 0);
      expect(row.generation, 2);
      expect(row.scrubbedAt, isNotNull);
      expect(row.receipt, original.receipt);
      expect(row.payloadDigest, original.payloadDigest);
      final delivery = (await CalendarFreeBusyDeliveryRecord.db.findFirstRow(
        session,
        where: (t) => t.commandId.equals(row.id!),
      ))!;
      expect(delivery.state, state);
      expect(delivery.terminalAt, isNotNull);
      expect(delivery.recipientAddress, isNull);
      expect(delivery.routeRef, isNull);
      expect(delivery.authorityRef, isNull);
      expect(delivery.providerReceipt, isNull);
      expect(delivery.leaseToken, isNull);
      expect(delivery.leaseOwner, isNull);
      expect(delivery.leaseUntil, isNull);
      expect(delivery.generation, row.generation);
      expect(
        await CalendarFreeBusySourceReferenceRecord.db.count(
          session,
          where: (t) => t.commandId.equals(row.id!),
        ),
        0,
      );
    }

    test('calendar deletion scrubs queued and accepted bodies without a transport installed', () async {
      final queued = await report();
      final accepted = await report(state: 'accepted');
      final otherCalendar = (await service.create(createInput('Other')))!
          .calendarId;
      final unrelated = await report(parent: otherCalendar);
      await service.delete(calendar, 1);
      await expectScrubbed(queued, 'withdrawn');
      await expectScrubbed(accepted, 'accepted');
      expect(
        (await CalendarFreeBusyCommandRecord.db.findById(
          session,
          unrelated.id!,
        ))!.payload,
        unrelated.payload,
      );
    });

    test(
      'event deletion scrubs indexed reports and removes the complete vector',
      () async {
        final event = (await service.createEvent(
          CalendarEventCreateRequest(
            calendarId: calendar,
            content: eventInput(),
          ),
        ))!.eventId;
        final queued = await report(event: event);
        final accepted = await report(event: event, state: 'accepted');
        final unrelated = await report();
        await service.deleteEvent(event, 1);
        await expectScrubbed(queued, 'withdrawn');
        await expectScrubbed(accepted, 'accepted');
        expect(
          (await CalendarFreeBusyCommandRecord.db.findById(
            session,
            unrelated.id!,
          ))!.scrubbedAt,
          isNull,
        );
      },
    );

    test('rule deletion uses its own reverse index', () async {
      final rule = (await service.createAvailability(
        CalendarAvailabilityCreateRequest(
          calendarId: calendar,
          content: CalendarAvailabilityContent(openings: []),
        ),
      ))!.availabilityId;
      final queued = await report(availability: rule);
      await service.deleteAvailability(rule, 1);
      await expectScrubbed(queued, 'withdrawn');
    });

    test(
      'denied or dependency-conflicting deletion leaves reports unchanged',
      () async {
        final event = (await service.createEvent(
          CalendarEventCreateRequest(
            calendarId: calendar,
            content: eventInput(),
          ),
        ))!.eventId;
        final queued = await report(event: event);
        await expectLater(
          service.delete(calendar, 1),
          failure(CalendarFailureCode.dependencyConflict),
        );
        policy.denyFinal = true;
        await expectLater(
          service.deleteEvent(event, 1),
          failure(CalendarFailureCode.accessDenied),
        );
        final unchanged = (await CalendarFreeBusyCommandRecord.db.findById(
          session,
          queued.id!,
        ))!;
        expect(unchanged.payload, queued.payload);
        expect(unchanged.generation, 1);
        expect(unchanged.scrubbedAt, isNull);
        expect(
          await CalendarFreeBusySourceReferenceRecord.db.count(session),
          1,
        );
      },
    );
  });
}

final class TestFreeBusyHost implements CalendarFreeBusyExchangeHost {
  @override
  Future<String> resolveOwner(
    Session session,
    CalendarHostContext actor,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async => 'private:${actor.principalId}';

  final mailboxes = <UuidValue, String>{};
  Duration dispatchDelay = Duration.zero;
  bool didDelay = false;
  final denied = <CalendarFreeBusyExchangeOperation>{};
  bool denyFinal = false, sawBackground = false;
  CalendarAuthorizationVerdict sourceVerdict =
      CalendarAuthorizationVerdict.allow;
  final sourceRequests = <CalendarAuthorizationRequest>[];
  final sourceActors = <CalendarHostContext?>[];
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarFreeBusyExchangePolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    sawBackground |= context.actor == null;
    if (context.operation == CalendarFreeBusyExchangeOperation.dispatch &&
        phase == CalendarAuthorizationPhase.finalWrite &&
        dispatchDelay > Duration.zero) {
      didDelay = true;
      await Future<void>.delayed(dispatchDelay);
    }
    return denied.contains(context.operation) ||
            denyFinal && phase == CalendarAuthorizationPhase.finalWrite
        ? CalendarAuthorizationVerdict.deny
        : CalendarAuthorizationVerdict.allow;
  }

  @override
  Future<CalendarAuthorizationVerdict> authorizeSources(
    Session session,
    CalendarFreeBusyExchangePolicyContext context,
    List<CalendarAuthorizationRequest> requests,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    sourceRequests.addAll(requests);
    sourceActors.add(context.actor);
    return sourceVerdict;
  }

  @override
  Future<CalendarFreeBusyMailbox> resolveMailbox(
    Session session,
    CalendarHostContext actor,
    UuidValue calendarId,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async => CalendarFreeBusyMailbox(
    scopeKey: actor.scopeKey,
    ownerKey: 'private:${actor.principalId}',
    calendarId: calendarId,
    address: mailboxes[calendarId] ?? 'mailto:alice@example.invalid',
    bindingRef: 'synthetic-binding',
  );
  @override
  Future<List<CalendarSchedulingRoute>> resolveRoutes(
    Session session,
    CalendarFreeBusyExchangePolicyContext context,
    List<String> addresses,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async => [
    for (final a in addresses) CalendarSchedulingRoute(a, 'synthetic-route:$a'),
  ];
}

final class TestFreeBusyTransport implements CalendarSchedulingTransport {
  final sent = <CalendarSchedulingSubmission>[];
  CalendarSchedulingTransportOutcome outcome =
      CalendarSchedulingTransportOutcome.accepted;
  Future<void> Function()? onSubmit;
  @override
  Future<CalendarSchedulingTransportResult> submit(
    Session session,
    CalendarSchedulingSubmission submission,
  ) async {
    sent.add(submission);
    await onSubmit?.call();
    return CalendarSchedulingTransportResult(
      outcome,
      receipt: 'synthetic-accepted',
    );
  }
}
