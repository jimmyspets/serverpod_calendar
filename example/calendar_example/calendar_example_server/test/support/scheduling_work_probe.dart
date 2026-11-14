import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_output.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:calendar_example_server/src/generated/serverpod.dart'
    as generated;
import 'package:calendar_example_server/src/scheduling_mime.dart';
import 'package:calendar_example_server/src/imip_mime_input.dart';
import 'package:calendar_example_server/src/imip_ingress.dart';
import 'package:calendar_example_server/src/synthetic_imip_input.dart';

final class _Host implements CalendarSchedulingHost {
  String scope = '', pause = '';

  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<CalendarSchedulingAuthority> resolve(
    Session s,
    CalendarHostContext a,
    CalendarEventPolicySnapshot e,
    List<String> p,
    Transaction t,
  ) async => CalendarSchedulingAuthority(
    organizerAddress: 'mailto:organizer@example.invalid',
    authorityRef: a.scopeKey,
    routes: p.map((r) => CalendarSchedulingRoute(r, r)),
  );

  @override
  Future<CalendarAuthorizationVerdict> authorizeMessage(
    Session s,
    CalendarSchedulingPolicyContext c,
    Transaction t,
    CalendarAuthorizationPhase phase,
  ) async {
    if (pause == 'before' &&
        phase == CalendarAuthorizationPhase.finalWrite &&
        {
          CalendarSchedulingPublicationKind.rangeCancel,
          CalendarSchedulingPublicationKind.rangeRestore,
          CalendarSchedulingPublicationKind.informationCancel,
          CalendarSchedulingPublicationKind.informationReopen,
        }.contains(c.intent.publicationKind)) {
      stdout.writeln('SCHEDULING_SUBMITTED');
      await Completer<void>().future;
    }
    return c.scopeKey.startsWith('scheduling-work-probe:') &&
            c.authority.authorityRef == c.scopeKey
        ? CalendarAuthorizationVerdict.allow
        : CalendarAuthorizationVerdict.deny;
  }
}

final class _Policy implements CalendarHostPolicy {
  _Policy(this.host);
  final _Host host;
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected synthetic policy operation');
  @override
  Future<CalendarHostContext> resolveContext(Session session) async =>
      CalendarHostContext(
        principalId: 'synthetic',
        scopeKey: host.scope,
        policyRevision: 'range-command-probe-v1',
      );
  @override
  Future<List<CalendarAuthorizationDecision>> authorizeBatch(
    Session s,
    CalendarHostContext c,
    List<CalendarAuthorizationRequest> requests,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async => [
    for (final r in requests)
      CalendarAuthorizationDecision(
        key: r.key,
        verdict:
            c.scopeKey == host.scope &&
                c.scopeKey.startsWith('scheduling-work-probe:')
            ? CalendarAuthorizationVerdict.allow
            : CalendarAuthorizationVerdict.deny,
        discloseMutationReceipt: true,
        disclosedGroups: CalendarFieldGroup.values,
        eventDisclosedGroups: CalendarEventFieldGroup.values,
      ),
  ];
}

final class _Transport implements CalendarSchedulingTransport {
  String pause = '';
  @override
  Future<CalendarSchedulingTransportResult> submit(
    Session s,
    CalendarSchedulingSubmission v,
  ) async {
    final mime = composeSyntheticSchedulingMime(v, requireProtection: false);
    final decoded = parseHostImipMime(
      ascii.encode(mime),
      outerProtection: ImipProtection.none,
    ).source.body;
    final payloadDigest = sha256.convert(utf8.encode(v.payload)).toString();
    if (sha256.convert(decoded).toString() != payloadDigest) {
      throw StateError('Synthetic MIME changed authorized calendar bytes');
    }
    if (pause == 'before') {
      stdout.writeln('SCHEDULING_SUBMITTED');
      await Completer<void>().future;
    }
    final file = File('../../../.local/scheduling-worker-acceptance.jsonl');
    await file.writeAsString(
      '${jsonEncode({'key': v.deliveryKey.toString(), 'publication': v.publicationId.toString(), 'digest': payloadDigest, 'mimeDigest': sha256.convert(ascii.encode(mime)).toString(), 'decodedDigest': sha256.convert(decoded).toString()})}\n',
      mode: FileMode.append,
      flush: true,
    );
    if (pause == 'after') {
      stdout.writeln('SCHEDULING_SUBMITTED');
      await Completer<void>().future;
    }
    return const CalendarSchedulingTransportResult(
      CalendarSchedulingTransportOutcome.accepted,
    );
  }
}

final class _ReplyHost implements CalendarSchedulingReplyHost {
  String pause = '';
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<CalendarAuthorizationVerdict> authorizeReply(
    Session s,
    CalendarSchedulingReplyPolicyContext c,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (pause == 'before' && phase == CalendarAuthorizationPhase.finalWrite) {
      stdout.writeln('SCHEDULING_SUBMITTED');
      await Completer<void>().future;
    }
    return c.delivery.scopeKey.startsWith('scheduling-work-probe:') &&
            c.delivery.originReference == 'synthetic-verified-bob'
        ? CalendarAuthorizationVerdict.allow
        : CalendarAuthorizationVerdict.deny;
  }
}

/// Internal isolated-storage process fixture. No endpoint or real mail transport.
Future<void> main(List<String> args) async {
  final pod = generated.Serverpod([
    '--mode=test',
    '--server-id=scheduling-probe-${args.first}',
    '--apply-migrations',
  ]);
  final s = await pod.createSession(enableLogging: false);
  if ((await s.db.unsafeQuery('SELECT current_database()')).single.single !=
      'calendar_example_test') {
    throw StateError('Synthetic test storage required');
  }
  final transport = _Transport();
  final replies = _ReplyHost();
  final host = _Host();
  CalendarModule.install(
    pod,
    policy: _Policy(host),
    options: const CalendarModuleOptions(
      requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
      policyTimeout: Duration(seconds: 30),
    ),
    scheduling: CalendarSchedulingRuntime(
      host: host,
      transport: transport,
      replies: CalendarSchedulingReplyRuntime(host: replies),
      options: CalendarSchedulingOptions(
        lease: const Duration(seconds: 6),
        transportTimeout: const Duration(seconds: 5),
        retryBase: const Duration(seconds: 1),
      ),
    ),
  );
  await pod.start();
  stdout.writeln('SCHEDULING_READY');
  try {
    await for (final line
        in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
      final input = jsonDecode(line) as Map<String, dynamic>;
      Object? result;
      switch (input['command']) {
        case 'information-command':
          final id = UuidValue.fromString(input['eventId'] as String);
          final meeting = (await CalendarSchedulingMeetingRecord.db
              .findFirstRow(s, where: (t) => t.eventId.equals(id)))!;
          host.scope = meeting.scopeKey;
          host.pause = input['pause'] as String? ?? '';
          s.updateAuthenticated(
            AuthenticationInfo(
              'synthetic',
              {},
              authId: 'information-command-probe',
            ),
          );
          try {
            final service = CalendarModule.service(s);
            final receipt = input['restore'] == true
                ? await service.reopenPublishedInformation(
                    CalendarSchedulingReopenRequest(
                      eventId: id,
                      expectedRevision: input['revision'] as int,
                      commandId: UuidValue.fromString(input['key'] as String),
                    ),
                  )
                : await service.cancelPublishedInformation(
                    CalendarSchedulingCancelRequest(
                      eventId: id,
                      expectedRevision: input['revision'] as int,
                      commandId: UuidValue.fromString(input['key'] as String),
                    ),
                  );
            if (host.pause == 'after') {
              stdout.writeln('SCHEDULING_SUBMITTED');
              await Completer<void>().future;
            }
            result = {
              'publicationId': receipt.publicationId.toString(),
              'unchanged': receipt.unchanged,
              'revision': receipt.eventRevision,
              'publications': await CalendarSchedulingPublicationRecord.db
                  .count(s, where: (t) => t.meetingId.equals(meeting.id!)),
            };
          } finally {
            host.pause = '';
            s.updateAuthenticated(null);
          }
          break;
        case 'range-command':
          final id = UuidValue.fromString(input['eventId'] as String);
          final meeting = (await CalendarSchedulingMeetingRecord.db
              .findFirstRow(s, where: (t) => t.eventId.equals(id)))!;
          host.scope = meeting.scopeKey;
          host.pause = input['pause'] as String? ?? '';
          s.updateAuthenticated(
            AuthenticationInfo('synthetic', {}, authId: 'range-command-probe'),
          );
          try {
            final point = CalendarEventTiming(
              kind: CalendarEventTimeKind.utc,
              start: CalendarEventCivil(year: 2026, month: 11, day: 4, hour: 9),
            );
            final service = CalendarModule.service(s);
            final receipt = input['restore'] == true
                ? await service.restoreFutureAndNotify(
                    CalendarSchedulingFutureRestoreRequest(
                      eventId: id,
                      expectedRevision: input['revision'] as int,
                      commandId: UuidValue.fromString(input['key'] as String),
                      originalStart: point,
                    ),
                  )
                : await service.cancelFutureAndNotify(
                    CalendarSchedulingFutureCancelRequest(
                      eventId: id,
                      expectedRevision: input['revision'] as int,
                      commandId: UuidValue.fromString(input['key'] as String),
                      originalStart: point,
                    ),
                  );
            if (host.pause == 'after') {
              stdout.writeln('SCHEDULING_SUBMITTED');
              await Completer<void>().future;
            }
            result = {
              'publicationId': receipt.publicationId.toString(),
              'unchanged': receipt.unchanged,
              'revision': receipt.eventRevision,
              'publications': await CalendarSchedulingPublicationRecord.db
                  .count(s, where: (t) => t.meetingId.equals(meeting.id!)),
            };
          } finally {
            host.pause = '';
            s.updateAuthenticated(null);
          }
          break;
        case 'reply':
          replies.pause = input['pause'] as String? ?? '';
          final eventId = UuidValue.fromString(input['eventId'] as String);
          final meeting = (await CalendarSchedulingMeetingRecord.db
              .findFirstRow(s, where: (t) => t.eventId.equals(eventId)))!;
          if (!meeting.scopeKey.startsWith('scheduling-work-probe:')) {
            throw StateError('Foreign reply fixture');
          }
          final publication = (await CalendarSchedulingPublicationRecord.db
              .findById(s, meeting.latestPublicationId!))!;
          final body = [
            'BEGIN:VCALENDAR',
            'VERSION:2.0',
            'PRODID:-//Synthetic reply//EN',
            'METHOD:REPLY',
            'BEGIN:VEVENT',
            'UID:${publication.protocolUid}',
            'DTSTAMP:20261027T120000Z',
            'SEQUENCE:${publication.sequence}',
            if (input['instance'] == true) 'RECURRENCE-ID:20261103T090000Z',
            'ORGANIZER:${meeting.organizerAddress}',
            'ATTENDEE;PARTSTAT=ACCEPTED:mailto:bob@example.invalid',
            'END:VEVENT',
            'END:VCALENDAR',
            '',
          ].join('\r\n');
          final receipt = await receiveHostImipReply(
            s,
            scopeKey: meeting.scopeKey,
            eventId: eventId,
            namespace: 'process-loss-fixture',
            deliveryKey: input['key'] as String,
            originReference: 'synthetic-verified-bob',
            outerProtection: ImipProtection.none,
            raw: composeSyntheticIngressMime(
              utf8.encode(body),
              method: IcalendarSchedulingMethod.reply,
            ),
          );
          if (replies.pause == 'after') {
            stdout.writeln('SCHEDULING_SUBMITTED');
            await Completer<void>().future;
          }
          result = {
            'receiptId': receipt.receiptId.toString(),
            'sourceId': receipt.sourceId.toString(),
            'unchanged': receipt.unchanged,
            'outcome': receipt.outcome.name,
            'instance':
                (await CalendarSchedulingReplySourceRecord.db.findById(
                  s,
                  receipt.sourceId,
                ))!.originalStart !=
                null,
            'sources': await CalendarSchedulingReplySourceRecord.db.count(
              s,
              where: (t) => t.meetingId.equals(meeting.id!),
            ),
            'receipts': await CalendarSchedulingReplyReceiptRecord.db.count(
              s,
              where: (t) => t.meetingId.equals(meeting.id!),
            ),
            'responses': await CalendarSchedulingAttendeeResponseRecord.db
                .count(s, where: (t) => t.meetingId.equals(meeting.id!)),
          };
        case 'seed':
          result = (input['method'] as String? ?? '').startsWith('INFORMATION')
              ? await _informationSeed(
                  s,
                  host,
                  input['method'] as String,
                  occurrences: input['occurrences'] == true,
                )
              : await _seed(s, input['method'] as String? ?? 'REQUEST');
        case 'work':
          transport.pause = input['pause'] as String? ?? '';
          await CalendarModule.runSchedulingMaintenance(s);
          result = true;
        case 'inspect':
          final publication = UuidValue.fromString(
            input['publicationId'] as String,
          );
          final delivery = (await CalendarSchedulingDeliveryRecord.db.find(
            s,
            where: (t) => t.publicationId.equals(publication),
          )).single;
          final attempts = await CalendarSchedulingAttemptRecord.db.find(
            s,
            where: (t) => t.deliveryId.equals(delivery.id!),
            orderBy: (t) => t.attemptNumber,
          );
          result = {
            'state': delivery.state.name,
            'key': delivery.deliveryKey.toString(),
            'attempts': attempts.map((a) => a.outcome).toList(),
          };
        case 'cleanup':
          final eventId = UuidValue.fromString(input['eventId'] as String);
          final meeting = await CalendarSchedulingMeetingRecord.db.findFirstRow(
            s,
            where: (t) => t.eventId.equals(eventId),
          );
          if (meeting == null ||
              !meeting.scopeKey.startsWith('scheduling-work-probe:')) {
            throw StateError('Foreign fixture');
          }
          await CalendarSchedulingAttendeeResponseRecord.db.deleteWhere(
            s,
            where: (t) => t.meetingId.equals(meeting.id!),
          );
          await CalendarSchedulingReplyReceiptRecord.db.deleteWhere(
            s,
            where: (t) => t.meetingId.equals(meeting.id!),
          );
          await CalendarSchedulingReplySourceRecord.db.deleteWhere(
            s,
            where: (t) => t.meetingId.equals(meeting.id!),
          );
          for (final p in await CalendarSchedulingPublicationRecord.db.find(
            s,
            where: (t) => t.meetingId.equals(meeting.id!),
          )) {
            for (final d in await CalendarSchedulingDeliveryRecord.db.find(
              s,
              where: (t) => t.publicationId.equals(p.id!),
            )) {
              await CalendarSchedulingAttemptRecord.db.deleteWhere(
                s,
                where: (t) => t.deliveryId.equals(d.id!),
              );
              await CalendarSchedulingDeliveryRecord.db.deleteRow(s, d);
            }
            await CalendarSchedulingPublicationRecord.db.deleteRow(s, p);
          }
          await CalendarSchedulingMeetingRecord.db.deleteRow(s, meeting);
          await CalendarEventDataRecord.db.deleteWhere(
            s,
            where: (t) => t.eventId.equals(eventId),
          );
          await CalendarEventRecord.db.deleteWhere(
            s,
            where: (t) => t.id.equals(eventId),
          );
          await CalendarDataRecord.db.deleteWhere(
            s,
            where: (t) => t.calendarId.equals(meeting.calendarId),
          );
          await CalendarIdentityRecord.db.deleteWhere(
            s,
            where: (t) => t.id.equals(meeting.calendarId),
          );
          await CalendarScopeRecord.db.deleteWhere(
            s,
            where: (t) => t.scopeKey.equals(meeting.scopeKey),
          );
          result = true;
        default:
          throw StateError('Unknown fixture command');
      }
      stdout.writeln('SCHEDULING_RESULT ${jsonEncode(result)}');
    }
  } finally {
    await s.close();
    await pod.shutdown(exitProcess: false);
  }
}

Future<Map<String, String>> _seed(
  Session s,
  String method,
) => s.db.transaction((tx) async {
  final instanceReply = method == 'INSTANCE_REPLY';
  final recurringReply = method == 'RECURRING_REPLY' || instanceReply;
  final replyMode = method == 'REPLY' || recurringReply;
  if (replyMode) method = 'REQUEST';
  final rangeCancel = method == 'RANGE_CANCEL';
  final rangeRestore = method == 'RANGE_RESTORE';
  if (rangeCancel || rangeRestore) method = 'REQUEST';
  final maskedRestore = method == 'MASKRESTORE';
  final reopening = method == 'REOPEN';
  final projectedMode = reopening || maskedRestore;
  final restoring = method == 'RESTORE' || maskedRestore;
  final instance = method == 'INSTANCE' || restoring || reopening;
  if (instance) method = 'REQUEST';
  if (!{'REQUEST', 'CANCEL'}.contains(method)) {
    throw StateError('Unsupported fixture method');
  }
  final now =
      ((await s.db.unsafeQuery(
                'SELECT clock_timestamp()',
                transaction: tx,
              )).single.single
              as DateTime)
          .toUtc();
  final scope = 'scheduling-work-probe:${Uuid().v4obj()}';
  final calendar = await CalendarIdentityRecord.db.insertRow(
    s,
    CalendarIdentityRecord(scopeKey: scope, revision: 1),
    transaction: tx,
  );
  await CalendarDataRecord.db.insertRow(
    s,
    CalendarDataRecord(
      calendarId: calendar.id!,
      displayName: 'Synthetic worker fixture',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: CalendarNoRuleFallback.free,
      createdAt: now,
      updatedAt: now,
    ),
    transaction: tx,
  );
  final event = await CalendarEventRecord.db.insertRow(
    s,
    CalendarEventRecord(calendarId: calendar.id!, revision: 2),
    transaction: tx,
  );
  final content = CalendarEventContent(
    summary: 'Synthetic worker publication',
    recurrence: replyMode && !recurringReply
        ? null
        : CalendarEventRecurrence(
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
    status: method == 'CANCEL'
        ? CalendarEventStatus.cancelled
        : CalendarEventStatus.confirmed,
    timing: CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2026, month: 11, day: 2, hour: 9),
    ),
  );
  final uid = Uuid().v4obj().toString(),
      recipient = 'mailto:bob@example.invalid';
  final originals = method == 'REQUEST' && (!replyMode || recurringReply)
      ? [
          EventSchedulingOriginal(
            content.timing.copyWith(
              start: CalendarEventCivil(year: 2026, month: 11, day: 3, hour: 9),
            ),
            false,
          ),
        ]
      : <EventSchedulingOriginal>[];
  final state = eventProtocolBaseline(content, null, now, now).copyWith(
    sourceMetadata: CalendarEventSourceMetadata(
      categoryGroups: [],
      comments: [],
      contacts: [],
      organizer: CalendarEventSourceParticipant(
        address: 'mailto:organizer@example.invalid',
        parameters: {},
      ),
      attendees: [
        CalendarEventSourceParticipant(address: recipient, parameters: {}),
      ],
    ),
  );
  final edits = method == 'REQUEST'
      ? eventSchedulingProjection(content, null, originals).$1
      : null;
  final projectedState = state.copyWith(
    overrides: [
      for (final original in originals)
        CalendarEventOverrideProtocolState(
          originalStart: original.originalStart,
          version: CalendarEventProtocolVersion(
            sequence: 0,
            stamp: state.version.stamp,
          ),
          summaryPresent: true,
          descriptionPresent: true,
          locationPresent: true,
          statusPresent: true,
          transparencyPresent: true,
        ),
    ],
  );
  final snapshot = CalendarEventPolicySnapshot(
    event.id!,
    calendar.id!,
    2,
    content,
    uid,
    now,
    origin: CalendarEventOrigin.native,
    timingOverrides: edits,
    protocolState: projectedState,
  );
  final source = parseIcalendarSyntax(eventExportBytes([snapshot]))
      .components
      .single;
  final payload = utf8.decode(
    serializeIcalendarSchedulingMessage(
      method == 'REQUEST'
          ? projectIcalendarRequestFields(
              parseIcalendarEventCalendar(eventExportBytes([snapshot])),
            )
          : validateIcalendarSchedulingMessage(
              IcalendarSyntaxDocument([
                IcalendarSyntaxComponent('VCALENDAR', [
                  ...source.entries,
                  IcalendarSyntaxProperty('METHOD', method),
                ]),
              ]),
            ),
    ),
  );
  final message = parseIcalendarSchedulingMessage(utf8.encode(payload));
  Map<String, dynamic> component(IcalendarSchedulingEvent e) {
    final rid = e.source.entries
        .whereType<IcalendarSyntaxProperty>()
        .where((p) => p.canonicalName == 'RECURRENCE-ID')
        .firstOrNull;
    return {
      'key': rid == null
          ? 'master'
          : jsonEncode([
              rid.value,
              rid.parameters
                  .where((p) => p.canonicalName != 'RANGE')
                  .map((p) => [p.canonicalName, p.values])
                  .toList(),
            ]),
      'future': e.isThisAndFuture,
      'projection': utf8.decode(
        serializeIcalendarSyntax(
          IcalendarSyntaxDocument([
            IcalendarSyntaxComponent(
              'VEVENT',
              e.source.entries.where(
                (p) =>
                    p is! IcalendarSyntaxProperty ||
                    !{'SEQUENCE', 'DTSTAMP'}.contains(p.canonicalName),
              ),
            ),
          ]),
        ),
      ),
      'sequence': e.sequence ?? 0,
      'stamp': e.stamp.toIso8601String(),
    };
  }

  final components = message.events.map(component).toList();
  final checkpoint = {
    'eventId': event.id.toString(),
    'calendarId': calendar.id.toString(),
    'revision': 2,
    'protocolUid': uid,
    'updatedAt': now.toIso8601String(),
    'content': content.toJson(),
    'state': state.toJson(),
    'overrides': null,
  };
  await CalendarEventDataRecord.db.insertRow(
    s,
    CalendarEventDataRecord(
      eventId: event.id!,
      calendarId: calendar.id!,
      origin: CalendarEventOrigin.native,
      protocolUid: uid,
      uidDigest: eventUidDigest(uid),
      protocolState: state,
      content: content,
      createdAt: now,
      updatedAt: now,
    ),
    transaction: tx,
  );
  final meeting = await CalendarSchedulingMeetingRecord.db.insertRow(
    s,
    CalendarSchedulingMeetingRecord(
      scopeKey: scope,
      calendarId: calendar.id!,
      eventId: event.id!,
      organizerAddress: 'mailto:organizer@example.invalid',
      authorityRef: scope,
      revision: 1,
      generation: 1,
      createdAt: now,
      updatedAt: now,
    ),
    transaction: tx,
  );
  final p = await CalendarSchedulingPublicationRecord.db.insertRow(
    s,
    CalendarSchedulingPublicationRecord(
      scopeKey: scope,
      meetingId: meeting.id!,
      generation: 1,
      method: method,
      protocolUid: uid,
      sequence: state.version.sequence!,
      stamp: state.version.stamp,
      snapshot: method == 'REQUEST'
          ? jsonEncode({
              'version': 3,
              if (instanceReply) 'instanceVersionProfile': 1,
              'canonical': checkpoint,
              'outgoing': checkpoint,
              'ledger': components,
              'projectionOriginals': originals.map((v) => v.toJson()).toList(),
            })
          : jsonEncode({
              'eventId': event.id.toString(),
              'calendarId': calendar.id.toString(),
              'revision': 2,
              'protocolUid': uid,
              'updatedAt': now.toIso8601String(),
              'content': content.toJson(),
              'state': state.toJson(),
            }),
      projection: method == 'REQUEST'
          ? jsonEncode({'version': 3, 'components': components})
          : jsonEncode([
              content.toJson(),
              state.sourceMetadata!.toJson(),
              state.statusPresent,
              state.transparencyPresent,
            ]),
      payload: payload,
      payloadDigest: sha256.convert(utf8.encode(payload)).toString(),
      recipients: [recipient],
      commandId: Uuid().v4obj(),
      actorId: 'synthetic',
      requestDigest: 'synthetic',
      expectedRevision: 1,
      eventRevision: 2,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 1)),
      outcome: 'pending',
    ),
    transaction: tx,
  );

  if (instance) {
    final point = CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2026, month: 11, day: 4, hour: 9),
    );
    final edits = restoring
        ? null
        : changeEventOverrides(
            content,
            null,
            CalendarEventOccurrenceChange(
              eventId: event.id!,
              expectedRevision: 2,
              originalStart: point,
              action: CalendarEventOccurrenceAction.cancelSingle,
            ),
          );
    final nextState = advanceEventProtocol(
      state,
      content,
      null,
      content,
      edits,
      now,
    );
    final data = (await CalendarEventDataRecord.db.findFirstRow(
      s,
      where: (t) => t.eventId.equals(event.id!),
      transaction: tx,
    ))!;
    data.timingOverrides = edits;
    data.protocolState = nextState;
    await CalendarEventDataRecord.db.updateRow(s, data, transaction: tx);
    final basis = {
      'snapshot': p.snapshot,
      'projection': p.projection,
      'payload': p.payload,
      'method': p.method,
      'sequence': p.sequence,
      'stamp': p.stamp.toIso8601String(),
    };
    final writer = EventComponentWriter();
    var payload = utf8.decode(
      serializeIcalendarSchedulingMessage(
        validateIcalendarSchedulingMessage(
          IcalendarSyntaxDocument([
            IcalendarSyntaxComponent('VCALENDAR', [
              IcalendarSyntaxProperty('VERSION', '2.0'),
              IcalendarSyntaxProperty(
                'PRODID',
                '-//Serverpod Calendar//Instance cancellation//EN',
              ),
              IcalendarSyntaxProperty('METHOD', 'CANCEL'),
              IcalendarSyntaxComponent('VEVENT', [
                for (final prop
                    in message.events.first.source.entries
                        .whereType<IcalendarSyntaxProperty>())
                  if ({
                    'UID',
                    'ORGANIZER',
                    'ATTENDEE',
                  }.contains(prop.canonicalName))
                    prop,
                writer.time('RECURRENCE-ID', point),
                IcalendarSyntaxProperty('SEQUENCE', '1'),
                IcalendarSyntaxProperty(
                  'DTSTAMP',
                  writer.utc(state.version.stamp),
                ),
                IcalendarSyntaxProperty('STATUS', 'CANCELLED'),
              ]),
            ]),
          ]),
        ),
      ),
    );

    IcalendarSchedulingMessage? restoredSource;
    if (restoring) {
      final projectedOriginals = [
        ...originals,
        EventSchedulingOriginal(point, false),
      ];
      final projection = eventSchedulingProjection(
        content,
        null,
        projectedOriginals,
      ).$1;
      final projected = CalendarEventPolicySnapshot(
        event.id!,
        calendar.id!,
        2,
        content,
        uid,
        now,
        origin: CalendarEventOrigin.native,
        timingOverrides: projection,
        protocolState: state.copyWith(
          overrides: [
            for (final original in projectedOriginals)
              CalendarEventOverrideProtocolState(
                originalStart: original.originalStart,
                version: CalendarEventProtocolVersion(
                  sequence: 0,
                  stamp: state.version.stamp,
                ),
                summaryPresent: true,
                descriptionPresent: true,
                locationPresent: true,
                statusPresent: true,
                transparencyPresent: true,
              ),
          ],
        ),
      );
      final full = projectIcalendarRequestFields(
        parseIcalendarEventCalendar(eventExportBytes([projected])),
      );
      restoredSource = full;
      final target = full.events
          .singleWhere((e) => e.originalTime?.civil.date.day == 4)
          .source;
      payload = utf8.decode(
        serializeIcalendarSchedulingMessage(
          validateIcalendarSchedulingMessage(
            IcalendarSyntaxDocument([
              IcalendarSyntaxComponent('VCALENDAR', [
                ...full.source.components.single.entries
                    .whereType<IcalendarSyntaxProperty>(),
                IcalendarSyntaxComponent('VEVENT', [
                  ...target.entries.where(
                    (e) =>
                        e is! IcalendarSyntaxProperty ||
                        !{'SEQUENCE', 'DTSTAMP'}.contains(e.canonicalName),
                  ),
                  IcalendarSyntaxProperty(
                    'SEQUENCE',
                    maskedRestore ? '4' : '2',
                  ),
                  IcalendarSyntaxProperty(
                    'DTSTAMP',
                    writer.utc(state.version.stamp),
                  ),
                ]),
              ]),
            ]),
          ),
        ),
      );
    }
    final part = component(
      parseIcalendarSchedulingMessage(utf8.encode(payload)).events.single,
    );
    p.snapshot = jsonEncode({
      'version': restoring ? 5 : 4,
      'kind': restoring ? 'occurrenceRestore' : 'occurrenceCancel',
      'canonical': {
        ...checkpoint,
        'state': nextState.toJson(),
        'overrides': edits?.toJson(),
      },
      'basis': basis,
      'masterMessage': null,
      'target': point.toJson(),
      'nativeMatch': true,
      if (restoring)
        'individuals': [
          {
            'point': point.toJson(),
            'version': part,
            'restored': true,
            'active': part,
          },
        ]
      else
        'cancelled': [
          {'point': point.toJson(), 'version': part},
        ],
    });
    p.projection = jsonEncode({
      'version': restoring ? 5 : 4,
      'kind': restoring ? 'occurrenceRestore' : 'occurrenceCancel',
      'target': point.toJson(),
      'components': [part],
    });
    p.payload = payload;
    p.payloadDigest = sha256.convert(utf8.encode(payload)).toString();
    p.method = restoring ? 'REQUEST' : 'CANCEL';
    p.sequence = restoring ? (maskedRestore ? 4 : 2) : 1;
    if (projectedMode) {
      final proof = {
        'snapshot': p.snapshot,
        'projection': p.projection,
        'payload': p.payload,
        'method': p.method,
        'sequence': p.sequence,
        'stamp': p.stamp.toIso8601String(),
      };
      final source = maskedRestore ? restoredSource! : message;
      final unmaskedLedger = [
        for (final e in source.events)
          {
            ...component(e),
            'sequence': e.isOverride && e.originalTime!.civil.date.day == 4
                ? 4
                : 3,
          },
      ];
      final fullPayload = utf8.decode(
        serializeIcalendarSchedulingMessage(
          validateIcalendarSchedulingMessage(
            IcalendarSyntaxDocument([
              IcalendarSyntaxComponent('VCALENDAR', [
                ...source.source.components.single.entries
                    .whereType<IcalendarSyntaxProperty>(),
                for (var i = 0; i < source.events.length; i++)
                  IcalendarSyntaxComponent('VEVENT', [
                    ...source.events[i].source.entries.where(
                      (e) =>
                          e is! IcalendarSyntaxProperty ||
                          !{'SEQUENCE', 'DTSTAMP'}.contains(e.canonicalName),
                    ),
                    if (reopening && !source.events[i].isOverride)
                      writer.time('EXDATE', point),
                    IcalendarSyntaxProperty(
                      'SEQUENCE',
                      '${unmaskedLedger[i]['sequence']}',
                    ),
                    IcalendarSyntaxProperty(
                      'DTSTAMP',
                      writer.utc(state.version.stamp),
                    ),
                  ]),
              ]),
            ]),
          ),
        ),
      );
      final kind = reopening ? 'seriesReopen' : 'occurrenceRestoreWithMaster';
      p.snapshot = jsonEncode({
        'version': 6,
        'kind': kind,
        'canonical': (jsonDecode(p.snapshot) as Map)['canonical'],
        'state': proof,
        'ledger': unmaskedLedger,
        'masks': [if (reopening) point.toJson()],
        'fullPayload': fullPayload,
        'floor': [2, p.stamp.toIso8601String()],
        'target': reopening ? null : point.toJson(),
        'nativeMatch': reopening ? null : true,
        'masterMessage': null,
      });
      final fullMessage = parseIcalendarSchedulingMessage(
        utf8.encode(fullPayload),
      );
      p.projection = jsonEncode({
        'version': 6,
        'kind': kind,
        'target': reopening ? null : point.toJson(),
        'components': fullMessage.events.map(component).toList(),
      });
      p.payload = fullPayload;
      p.payloadDigest = sha256.convert(utf8.encode(fullPayload)).toString();
      p.method = 'REQUEST';
      p.sequence = 3;
    }
    await CalendarSchedulingPublicationRecord.db.updateRow(
      s,
      p,
      transaction: tx,
    );
  }
  if (rangeCancel || rangeRestore) {
    final point = CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2026, month: 11, day: 4, hour: 9),
    );
    Map<String, dynamic> facts = jsonDecode(p.snapshot) as Map<String, dynamic>;
    if (rangeRestore) {
      final projected = eventSchedulingRangeRestoration(
        content,
        null,
        [],
        point,
      );
      final protocol = state.copyWith(
        version: state.version.copyWith(sequence: 1),
        overrides: [
          CalendarEventOverrideProtocolState(
            originalStart: point,
            isThisAndFuture: true,
            version: state.version.copyWith(sequence: 2),
            summaryPresent: true,
            descriptionPresent: true,
            locationPresent: true,
            statusPresent: true,
            transparencyPresent: true,
          ),
        ],
      );
      final source = CalendarEventPolicySnapshot(
        event.id!,
        calendar.id!,
        2,
        content,
        uid,
        now,
        origin: CalendarEventOrigin.native,
        timingOverrides: projected.$1,
        protocolState: protocol,
      );
      final calendarTree = parseIcalendarSyntax(eventExportBytes([source]));
      final restored = projectIcalendarRequestFields(
        validateIcalendarEventCalendar(calendarTree),
      );
      p.payload = utf8.decode(serializeIcalendarSchedulingMessage(restored));
      p.payloadDigest = sha256.convert(utf8.encode(p.payload)).toString();
      p.sequence = 1;
      final ledger = restored.events.map(component).toList();
      final outgoing = {
        ...checkpoint,
        'state': protocol.toJson(),
        'overrides': projected.$1.toJson(),
      };
      facts = {
        'version': 3,
        'canonical': checkpoint,
        'outgoing': outgoing,
        'ledger': ledger,
        'projectionOriginals': projected.$2.map((v) => v.toJson()).toList(),
      };
      p.projection = jsonEncode({'version': 3, 'components': ledger});
    }
    final current = {
      'projection': p.projection,
      'payload': p.payload,
      'method': p.method,
      'sequence': p.sequence,
      'stamp': p.stamp.toIso8601String(),
    };
    final kind = rangeCancel ? 'rangeCancel' : 'rangeRestore';
    if (rangeCancel) {
      final cancelled = projectPublishedRangeCancellation(
        basis: message.source,
        originalStart: point,
        sequence: 1,
        stamp: state.version.stamp,
      );
      p.payload = utf8.decode(
        serializeIcalendarSchedulingMessage(cancelled.message),
      );
      p.payloadDigest = sha256.convert(utf8.encode(p.payload)).toString();
      p.method = 'CANCEL';
      p.sequence = 1;
      p.projection = jsonEncode({
        'version': 7,
        'kind': kind,
        'target': point.toJson(),
        'components': cancelled.message.events.map(component).toList(),
      });
    }
    facts.remove('version');
    p.snapshot = jsonEncode({
      'version': 7,
      'kind': kind,
      'currentVersion': 3,
      'facts': facts,
      'currentMessage': current,
      'canonical': checkpoint,
      'comparison': checkpoint,
      'range': {
        'anchor': point.toJson(),
        'active': rangeCancel,
        'sequence': 1,
        'stamp': p.stamp.toIso8601String(),
        'installedRevision': null,
        'installedKey': null,
      },
    });
    await CalendarSchedulingPublicationRecord.db.updateRow(
      s,
      p,
      transaction: tx,
    );
  }
  meeting.latestPublicationId = p.id;
  await CalendarSchedulingMeetingRecord.db.updateRow(
    s,
    meeting,
    transaction: tx,
  );
  await CalendarSchedulingDeliveryRecord.db.insertRow(
    s,
    CalendarSchedulingDeliveryRecord(
      scopeKey: scope,
      publicationId: p.id!,
      recipientAddress: recipient,
      routeRef: recipient,
      nextAttemptAt: now,
    ),
    transaction: tx,
  );
  return {'eventId': event.id.toString(), 'publicationId': p.id.toString()};
});

Future<Map<String, String>> _informationSeed(
  Session s,
  _Host host,
  String method, {
  bool occurrences = false,
}) async {
  host.scope = 'scheduling-work-probe:${Uuid().v4obj()}';
  s.updateAuthenticated(
    AuthenticationInfo('synthetic', {}, authId: 'information-probe'),
  );
  try {
    final service = CalendarModule.service(s);
    final calendar = (await service.create(
      CalendarCreateRequest(
        displayName: 'Synthetic information worker',
        availabilityZoneId: 'Etc/UTC',
        noRuleFallback: CalendarNoRuleFallback.free,
      ),
    ))!;
    final content = CalendarEventContent(
      summary: 'Information worker fixture',
      recurrence: occurrences
          ? CalendarEventRecurrence(
              rule: CalendarEventRule(
                frequency: CalendarEventFrequency.daily,
                count: 5,
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
            )
          : null,
      timing: CalendarEventTiming(
        kind: CalendarEventTimeKind.utc,
        start: CalendarEventCivil(year: 2027, month: 1, day: 2, hour: 9),
      ),
    );
    final event = (await service.createEvent(
      CalendarEventCreateRequest(
        calendarId: calendar.calendarId,
        content: content,
      ),
    ))!;
    var revision = 1;
    CalendarEventTiming point(int day) => CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2027, month: 1, day: day, hour: 9),
    );
    if (occurrences) {
      for (final future in [false, true]) {
        await service.changeOccurrence(
          CalendarEventOccurrenceChange(
            eventId: event.eventId,
            expectedRevision: revision++,
            originalStart: point(future ? 4 : 3),
            action: future
                ? CalendarEventOccurrenceAction.replaceFutureTiming
                : CalendarEventOccurrenceAction.replaceSingleTiming,
            replacement: point(future ? 5 : 4),
          ),
        );
      }
    }
    var receipt = await service.saveAndPublishInformation(
      CalendarSchedulingSaveRequest(
        eventId: event.eventId,
        expectedRevision: revision++,
        commandId: Uuid().v4obj(),
        content: content,
        recipients: ['mailto:guest@example.invalid'],
      ),
    );
    if (occurrences) {
      for (final future in [false, true]) {
        await service.changeOccurrence(
          CalendarEventOccurrenceChange(
            eventId: event.eventId,
            expectedRevision: revision++,
            originalStart: point(future ? 4 : 3),
            action: future
                ? CalendarEventOccurrenceAction.clearFutureTiming
                : CalendarEventOccurrenceAction.clearSingleTiming,
          ),
        );
      }
      receipt = await service.saveAndPublishInformation(
        CalendarSchedulingSaveRequest(
          eventId: event.eventId,
          expectedRevision: revision++,
          commandId: Uuid().v4obj(),
          content: content,
          recipients: ['mailto:guest@example.invalid'],
        ),
      );
      final saved = (await CalendarSchedulingPublicationRecord.db.findById(
        s,
        receipt.publicationId,
      ))!;
      final message = parseIcalendarSchedulingMessage(
        utf8.encode(saved.payload),
      );
      if (message.events.length != 3 ||
          message.events.where((e) => e.isOverride).length != 2) {
        throw StateError('Retained information reset packet was incomplete');
      }
    }
    if (method != 'INFORMATION') {
      receipt = await service.cancelPublishedInformation(
        CalendarSchedulingCancelRequest(
          eventId: event.eventId,
          expectedRevision: revision++,
          commandId: Uuid().v4obj(),
        ),
      );
    }
    if (method == 'INFORMATION_REOPEN') {
      receipt = await service.reopenPublishedInformation(
        CalendarSchedulingReopenRequest(
          eventId: event.eventId,
          expectedRevision: revision++,
          commandId: Uuid().v4obj(),
        ),
      );
    }
    return {
      'eventId': event.eventId.toString(),
      'publicationId': receipt.publicationId.toString(),
      'revision': revision.toString(),
    };
  } finally {
    s.updateAuthenticated(null);
  }
}
