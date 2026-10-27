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
import 'package:calendar_example_server/src/calendar_policy.dart';

final class _Host implements CalendarSchedulingHost {
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
  ) => throw StateError('No user entry point in worker probe');
  @override
  Future<CalendarAuthorizationVerdict> authorizeMessage(
    Session s,
    CalendarSchedulingPolicyContext c,
    Transaction t,
    CalendarAuthorizationPhase phase,
  ) async =>
      c.scopeKey.startsWith('scheduling-work-probe:') &&
          c.authority.authorityRef == c.scopeKey
      ? CalendarAuthorizationVerdict.allow
      : CalendarAuthorizationVerdict.deny;
}

final class _Transport implements CalendarSchedulingTransport {
  String pause = '';
  @override
  Future<CalendarSchedulingTransportResult> submit(
    Session s,
    CalendarSchedulingSubmission v,
  ) async {
    if (pause == 'before') {
      stdout.writeln('SCHEDULING_SUBMITTED');
      await Completer<void>().future;
    }
    final file = File('../../../.local/scheduling-worker-acceptance.jsonl');
    await file.writeAsString(
      '${jsonEncode({'key': v.deliveryKey.toString(), 'publication': v.publicationId.toString(), 'digest': sha256.convert(utf8.encode(v.payload)).toString()})}\n',
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
  CalendarModule.install(
    pod,
    policy: DemoCalendarPolicy(),
    options: const CalendarModuleOptions(
      requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
    ),
    scheduling: CalendarSchedulingRuntime(
      host: _Host(),
      transport: transport,
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
        case 'seed':
          result = await _seed(s, input['method'] as String? ?? 'REQUEST');
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
  final originals = method == 'REQUEST'
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
  final components = message.events.map((e) {
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
  }).toList();
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
