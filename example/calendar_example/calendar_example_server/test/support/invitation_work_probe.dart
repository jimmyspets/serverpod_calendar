import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:calendar_example_server/src/generated/serverpod.dart'
    as generated;

import 'package:calendar_example_server/src/imip_ingress.dart';
import 'package:calendar_example_server/src/synthetic_imip_input.dart';
import 'package:crypto/crypto.dart';

File _responseFile(String scope, String suffix) => File(
  '../../../.local/invitation-response-probe-${scope.split(':').last}.$suffix',
);

final class _ResponseHost implements CalendarInvitationResponseHost {
  _ResponseHost(this.host);
  final _Host host;
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<CalendarInvitationResponseAuthority> resolve(
    Session s,
    CalendarInvitationResponsePolicyContext c,
    Transaction tx,
  ) async => CalendarInvitationResponseAuthority(
    attendeeAddress: host.recipient.calendarAddress,
    authorityRef: 'verified-probe',
    organizer: CalendarSchedulingRoute(
      c.invitation.organizer,
      'verified-probe-route',
    ),
  );
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session s,
    CalendarInvitationResponsePolicyContext c,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (!c.recipient.same(host.recipient) ||
        await _responseFile(host.scope, 'revoked').exists()) {
      return CalendarAuthorizationVerdict.deny;
    }
    if ({
          CalendarInvitationResponseOperation.dispatch,
          CalendarInvitationResponseOperation.dispatchOccurrence,
        }.contains(c.operation) &&
        c.actor != null) {
      throw StateError('Fabricated dispatch actor');
    }
    return CalendarAuthorizationVerdict.allow;
  }
}

final class _ResponseTransport implements CalendarInvitationResponseTransport {
  _ResponseTransport(this.host);
  final _Host host;
  @override
  Future<CalendarSchedulingTransportResult> submit(
    Session s,
    CalendarInvitationResponseSubmission input,
  ) async {
    final evidence = {
      'key': input.deliveryKey.toString(),
      'digest': sha256.convert(utf8.encode(input.payload)).toString(),
    };
    if (host.pause == 'response-before') {
      stdout.writeln('INVITATION_PAUSED ${jsonEncode(evidence)}');
      await Completer<void>().future;
    }
    await _responseFile(input.scopeKey, 'jsonl').writeAsString(
      '${jsonEncode(evidence)}\n',
      mode: FileMode.append,
      flush: true,
    );
    if (host.pause == 'response-after') {
      stdout.writeln('INVITATION_PAUSED ${jsonEncode(evidence)}');
      await Completer<void>().future;
    }
    return const CalendarSchedulingTransportResult(
      CalendarSchedulingTransportOutcome.accepted,
    );
  }
}

final class _Host implements CalendarInvitationHost {
  String scope = '', pause = '';
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  CalendarInvitationRecipient get recipient => CalendarInvitationRecipient(
    scopeKey: scope,
    key: 'recipient',
    calendarAddress: 'mailto:recipient@example.invalid',
  );
  @override
  Future<CalendarInvitationRecipient> resolveDelivery(
    Session s,
    CalendarInvitationDelivery d,
    IcalendarSchedulingMessage m,
  ) async {
    if (!scope.startsWith('invitation-probe:') ||
        d.originReference != 'verified-probe' ||
        m.events.any(
          (part) =>
              part.participants.organizer?.address !=
              'mailto:organizer@example.invalid',
        )) {
      throw StateError('Foreign fixture');
    }
    return recipient;
  }

  @override
  Future<CalendarInvitationRecipient> resolveCurrent(
    Session s,
    CalendarHostContext actor,
    Transaction tx,
  ) async => recipient;
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session s,
    CalendarInvitationPolicyContext c,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (!c.recipient.same(recipient)) return CalendarAuthorizationVerdict.deny;
    if (pause == 'before' &&
        c.operation == CalendarInvitationOperation.receive &&
        phase == CalendarAuthorizationPhase.finalWrite) {
      stdout.writeln('INVITATION_PAUSED ${jsonEncode(c.receipt!.toJson())}');
      await Completer<void>().future;
    }
    if (pause == 'adopt-before' &&
        c.operation == CalendarInvitationOperation.adopt &&
        phase == CalendarAuthorizationPhase.finalWrite) {
      stdout.writeln('INVITATION_PAUSED ${jsonEncode(c.link!.toJson())}');
      await Completer<void>().future;
    }
    if (pause == 'bundle-before' &&
        {
          CalendarInvitationOperation.applyBundleUpdate,
          CalendarInvitationOperation.applyBundleCancellation,
          CalendarInvitationOperation.reopenBundle,
        }.contains(c.operation) &&
        phase == CalendarAuthorizationPhase.finalWrite) {
      stdout.writeln(
        'INVITATION_PAUSED ${jsonEncode(c.applicationReceipt!.toJson())}',
      );
      await Completer<void>().future;
    }
    if (pause == 'apply-before' &&
        c.operation == CalendarInvitationOperation.apply &&
        phase == CalendarAuthorizationPhase.finalWrite) {
      stdout.writeln(
        'INVITATION_PAUSED ${jsonEncode(c.applicationReceipt!.toJson())}',
      );
      await Completer<void>().future;
    }
    if (pause == 'occurrence-before' &&
        {
          CalendarInvitationOperation.applyOccurrenceUpdate,
          CalendarInvitationOperation.applyOccurrenceCancellation,
          CalendarInvitationOperation.applyRangeUpdate,
          CalendarInvitationOperation.applyRangeCancellation,
          CalendarInvitationOperation.applyRangeRestoration,
        }.contains(c.operation) &&
        phase == CalendarAuthorizationPhase.finalWrite) {
      stdout.writeln(
        'INVITATION_PAUSED ${jsonEncode(c.occurrenceReceipt!.toJson())}',
      );
      await Completer<void>().future;
    }
    if (pause == 'cancel-apply-before' &&
        c.operation == CalendarInvitationOperation.applyCancellation &&
        phase == CalendarAuthorizationPhase.finalWrite) {
      stdout.writeln(
        'INVITATION_PAUSED ${jsonEncode(c.applicationReceipt!.toJson())}',
      );
      await Completer<void>().future;
    }
    return CalendarAuthorizationVerdict.allow;
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
  Future<List<CalendarAuthorizationDecision>> authorizeBatch(
    Session s,
    CalendarHostContext c,
    List<CalendarAuthorizationRequest> requests,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (host.pause == 'native-before' &&
        phase == CalendarAuthorizationPhase.finalWrite &&
        requests.any(
          (r) =>
              r.occurrenceChange?.action ==
                  CalendarEventOccurrenceAction.cancelFuture ||
              r.occurrenceChange?.action ==
                  CalendarEventOccurrenceAction.restoreFuture,
        )) {
      stdout.writeln('INVITATION_PAUSED {}');
      await Completer<void>().future;
    }
    return [
      for (final r in requests)
        CalendarAuthorizationDecision(
          key: r.key,
          verdict: c.scopeKey == host.scope
              ? CalendarAuthorizationVerdict.allow
              : CalendarAuthorizationVerdict.deny,
          discloseMutationReceipt: true,
          disclosedGroups: CalendarFieldGroup.values,
          eventDisclosedGroups: CalendarEventFieldGroup.values,
        ),
    ];
  }

  @override
  Future<CalendarHostContext> resolveContext(Session s) async =>
      CalendarHostContext(
        principalId: 'recipient',
        scopeKey: host.scope,
        policyRevision: 'synthetic-probe-v1',
      );
}

Future<void> main(List<String> args) async {
  final pod = generated.Serverpod([
    '--mode=test',
    '--server-id=invitation-probe-${args.first}',
    '--apply-migrations',
  ]);
  final session = await pod.createSession(enableLogging: false);
  if ((await session.db.unsafeQuery('SELECT current_database()'))
          .single
          .single !=
      'calendar_example_test') {
    throw StateError('Synthetic test storage required');
  }
  final host = _Host();
  CalendarModule.install(
    pod,
    policy: _Policy(host),
    options: const CalendarModuleOptions(
      requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
      policyTimeout: Duration(seconds: 30),
    ),
    invitations: CalendarInvitationRuntime(
      host: host,
      responses: CalendarInvitationResponseRuntime(
        host: _ResponseHost(host),
        transport: _ResponseTransport(host),
      ),
    ),
  );
  await pod.start();
  stdout.writeln('INVITATION_READY');
  try {
    await for (final line
        in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
      final input = jsonDecode(line) as Map<String, dynamic>;
      final caseId = UuidValue.fromString(input['caseId'] as String).toString();
      host.scope = 'invitation-probe:$caseId';
      host.pause = input['pause'] as String? ?? '';
      Object? result;
      try {
        switch (input['command']) {
          case 'native-seed':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              final service = CalendarModule.service(session);
              final parent = (await service.create(
                CalendarCreateRequest(
                  displayName: 'Synthetic native future',
                  availabilityZoneId: 'UTC',
                  noRuleFallback: CalendarNoRuleFallback.free,
                ),
              ))!;
              result = (await service.createEvent(
                CalendarEventCreateRequest(
                  calendarId: parent.calendarId,
                  content: CalendarEventContent(
                    timing: CalendarEventTiming(
                      kind: CalendarEventTimeKind.utc,
                      start: CalendarEventCivil(
                        year: 2026,
                        month: 1,
                        day: 1,
                        hour: 9,
                      ),
                      duration: CalendarEventDuration(hours: 1),
                    ),
                    recurrence: CalendarEventRecurrence(
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
                    ),
                  ),
                ),
              ))!.toJson();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'native-change':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              final receipt = await CalendarModule.service(session)
                  .changeOccurrence(
                    CalendarEventOccurrenceChange.fromJson(
                      input['request'] as Map<String, dynamic>,
                    ),
                  );
              if (host.pause == 'native-after') {
                stdout.writeln('INVITATION_PAUSED {}');
                await Completer<void>().future;
              }
              result = receipt!.toJson();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'native-inspect':
            final id = UuidValue.fromString(input['eventId'] as String);
            final row = (await CalendarEventRecord.db.findById(session, id))!;
            final calendar = (await CalendarIdentityRecord.db.findById(
              session,
              row.calendarId,
            ))!;
            if (calendar.scopeKey != host.scope) {
              throw StateError('Wrong synthetic scope');
            }
            final data = (await CalendarEventDataRecord.db.findFirstRow(
              session,
              where: (t) => t.eventId.equals(id),
            ))!;
            result = {
              'revision': row.revision,
              'cutoff': data.timingOverrides?.cancelledFrom?.start.day,
            };
          case 'response':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              result =
                  (await CalendarModule.service(session).sendInvitationResponse(
                    CalendarInvitationResponseRequest.fromJson(
                      input['request'] as Map<String, dynamic>,
                    ),
                  )).toJson();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'response-work':
            await CalendarModule.runInvitationResponseMaintenance(session);
            result = true;
          case 'response-expire-lease':
            final rows = await CalendarInvitationResponseRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            for (final row in rows.where((r) => r.terminalAt == null)) {
              row.nextAttemptAt = DateTime.utc(2020);
              row.leaseUntil = DateTime.utc(2020);
              await CalendarInvitationResponseRecord.db.updateRow(session, row);
            }
            result = true;
          case 'response-revoke':
            await _responseFile(
              host.scope,
              'revoked',
            ).writeAsString('Synthetic test revocation');
            result = true;
          case 'receive':
            final body = [
              'BEGIN:VCALENDAR',
              'VERSION:2.0',
              'PRODID:-//Synthetic probe//EN',
              input['cancel'] == true ? 'METHOD:CANCEL' : 'METHOD:REQUEST',
              'BEGIN:VEVENT',
              'UID:invitation:$caseId',
              'DTSTAMP:20260101T000000Z',
              if (input['sequence'] != null) 'SEQUENCE:${input['sequence']}',
              if (input['instance'] == true)
                'RECURRENCE-ID${input['range'] == true ? ';RANGE=THISANDFUTURE' : ''}:${input['original'] ?? '20300103T090000Z'}',
              if (input['cancel'] == true) 'STATUS:CANCELLED',
              if (input['cancel'] != true)
                'DTSTART:${input['restore'] == true ? '20300103T090000Z' : '20300101T090000Z'}',
              if (input['restore'] == true) 'DTEND:20300103T100000Z',
              if (input['cancel'] != true &&
                  input['instance'] != true &&
                  Platform.environment['CALENDAR_INVITATION_PROBE_RECURRING'] ==
                      'true') ...[
                'DTEND:20300101T100000Z',
                'RRULE:FREQ=DAILY;COUNT=3',
                'EXDATE:20300102T090000Z',
                'RDATE;VALUE=PERIOD:20300105T090000Z/PT2H',
              ],
              if (input['cancel'] != true)
                'SUMMARY:${encodeIcalendarText(input['summary'] as String? ?? 'Review')}',
              'ORGANIZER:mailto:organizer@example.invalid',
              'ATTENDEE:mailto:recipient@example.invalid',
              'END:VEVENT',
              if (input['bundle'] == true)
                for (final future in [false, true]) ...[
                  'BEGIN:VEVENT',
                  'UID:invitation:$caseId',
                  'DTSTAMP:20260102T000000Z',
                  if (future)
                    'SEQUENCE:12'
                  else if (input['bundleChild'] != null)
                    'SEQUENCE:${input['bundleChild']}',
                  'RECURRENCE-ID${future ? ';RANGE=THISANDFUTURE' : ''}:2030010${future ? '5' : '3'}T090000Z',
                  'DTSTART:2030010${future ? '5' : '3'}T110000Z',
                  'DTEND:2030010${future ? '5' : '3'}T120000Z',
                  'SUMMARY:${!future && input['bundleChild'] != null ? 'Synthetic exception ${input['bundleChild']}' : 'Synthetic exception'}',
                  'ORGANIZER:mailto:organizer@example.invalid',
                  'ATTENDEE:mailto:recipient@example.invalid',
                  'END:VEVENT',
                ],
              'END:VCALENDAR',
              '',
            ].join('\r\n');
            final receipt = await receiveHostImipInvitation(
              session,
              namespace: 'process-loss',
              deliveryKey: input['key'] as String,
              originReference: 'verified-probe',
              outerProtection: ImipProtection.none,
              raw: composeSyntheticIngressMime(
                utf8.encode(body),
                method: input['cancel'] == true
                    ? IcalendarSchedulingMethod.cancel
                    : IcalendarSchedulingMethod.request,
              ),
            );
            if (host.pause == 'after') {
              stdout.writeln(
                'INVITATION_PAUSED ${jsonEncode(receipt.toJson())}',
              );
              await Completer<void>().future;
            }
            result = receipt.toJson();
          case 'calendar':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              result = (await CalendarModule.service(session).create(
                CalendarCreateRequest(
                  displayName: 'Synthetic adoption',
                  availabilityZoneId: 'UTC',
                  noRuleFallback: CalendarNoRuleFallback.free,
                ),
              ))!.calendarId.toString();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'adopt':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              final receipt = await CalendarModule.service(session)
                  .adoptInvitation(
                    CalendarInvitationAdoptionRequest.fromJson(
                      input['request'] as Map<String, dynamic>,
                    ),
                  );
              if (host.pause == 'adopt-after') {
                stdout.writeln(
                  'INVITATION_PAUSED ${jsonEncode(receipt.toJson())}',
                );
                await Completer<void>().future;
              }
              result = receipt.toJson();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'bundle-view':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              result =
                  (await CalendarModule.service(session)
                          .invitationBundleApplication(
                            UuidValue.fromString(input['entryId'] as String),
                          ))
                      .toJson();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'bundle-apply':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              final service = CalendarModule.service(session);
              final request = CalendarInvitationApplyRequest.fromJson(
                input['request'] as Map<String, dynamic>,
              );
              final receipt = await switch (input['mode']) {
                'cancel' => service.applyInvitationBundleCancellation(request),
                'reopen' => service.applyInvitationBundleReopening(request),
                _ => service.applyInvitationBundleUpdate(request),
              };
              if (host.pause == 'bundle-after') {
                stdout.writeln(
                  'INVITATION_PAUSED ${jsonEncode(receipt.toJson())}',
                );
                await Completer<void>().future;
              }
              result = receipt.toJson();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'occurrence-view':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              result =
                  (await (input['restore'] == true
                          ? CalendarModule.service(session)
                                .invitationRangeRestorationApplication
                          : input['range'] == true
                          ? CalendarModule.service(session)
                                .invitationRangeApplication
                          : CalendarModule.service(session)
                                .invitationOccurrenceApplication)(
                        UuidValue.fromString(input['entryId'] as String),
                      ))
                      .toJson();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'occurrence-apply':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              final service = CalendarModule.service(session);
              final request = CalendarInvitationOccurrenceApplyRequest.fromJson(
                input['request'] as Map<String, dynamic>,
              );
              final receipt = input['restore'] == true
                  ? await service.applyInvitationRangeRestoration(request)
                  : input['range'] == true
                  ? input['cancel'] == true
                        ? await service.applyInvitationRangeCancellation(
                            request,
                          )
                        : await service.applyInvitationRangeUpdate(request)
                  : input['cancel'] == true
                  ? await service.applyInvitationOccurrenceCancellation(request)
                  : await service.applyInvitationOccurrenceUpdate(request);
              if (host.pause == 'occurrence-after') {
                stdout.writeln(
                  'INVITATION_PAUSED ${jsonEncode(receipt.toJson())}',
                );
                await Completer<void>().future;
              }
              result = receipt.toJson();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'application':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              result =
                  (await CalendarModule.service(session).invitationApplication(
                    UuidValue.fromString(input['entryId'] as String),
                  )).toJson();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'apply':
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              final service = CalendarModule.service(session);
              final request = CalendarInvitationApplyRequest.fromJson(
                input['request'] as Map<String, dynamic>,
              );
              final receipt = input['cancel'] == true
                  ? await service.applyInvitationCancellation(request)
                  : await service.applyInvitationUpdate(request);
              if (host.pause == 'apply-after' ||
                  host.pause == 'cancel-apply-after') {
                stdout.writeln(
                  'INVITATION_PAUSED ${jsonEncode(receipt.toJson())}',
                );
                await Completer<void>().future;
              }
              result = receipt.toJson();
            } finally {
              session.updateAuthenticated(null);
            }
          case 'inspect':
            final entries = await CalendarInvitationRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            final sources = entries.isEmpty
                ? <CalendarInvitationSourceRecord>[]
                : await CalendarInvitationSourceRecord.db.find(
                    session,
                    where: (t) =>
                        t.entryId.inSet(entries.map((e) => e.id!).toSet()),
                  );
            final calendars = await CalendarIdentityRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            final eventRows = calendars.isEmpty
                ? <CalendarEventDataRecord>[]
                : await CalendarEventDataRecord.db.find(
                    session,
                    where: (t) =>
                        t.calendarId.inSet(calendars.map((c) => c.id!).toSet()),
                  );
            final application = await CalendarInvitationApplicationRecord.db
                .findFirstRow(
                  session,
                  where: (t) => t.scopeKey.equals(host.scope),
                );
            result = {
              'responses': [
                for (final r in await CalendarInvitationResponseRecord.db.find(
                  session,
                  where: (t) => t.scopeKey.equals(host.scope),
                ))
                  {
                    'id': r.id.toString(),
                    'state': r.state.name,
                    'attempts': r.attemptCount,
                    'digest': r.payloadDigest,
                  },
              ],
              'occurrenceApplications':
                  await CalendarInvitationOccurrenceApplicationRecord.db.count(
                    session,
                    where: (t) => t.scopeKey.equals(host.scope),
                  ),
              'acceptedKind': application?.kind.name,
              'eventStatus': eventRows.firstOrNull?.content.status.name,
              'bundleVersions': eventRows.firstOrNull?.protocolState?.overrides
                  .map((v) => v.version.sequence)
                  .toList(),
              'singleCount':
                  eventRows.firstOrNull?.timingOverrides?.singles.length,
              'futureCount':
                  eventRows.firstOrNull?.timingOverrides?.future.length,
              'bundledLinks': await CalendarInvitationLinkRecord.db.count(
                session,
                where: (t) =>
                    t.scopeKey.equals(host.scope) &
                    t.bundledRequest.equals(true),
              ),
              'cutoff': eventRows.firstOrNull?.timingOverrides?.cancelledFrom
                  ?.toJson(),
              'checkpointVersion':
                  await CalendarInvitationOccurrenceApplicationRecord.db
                      .findFirstRow(
                        session,
                        where: (t) => t.scopeKey.equals(host.scope),
                      )
                      .then(
                        (v) => v == null
                            ? null
                            : (jsonDecode(v.stateJson) as Map)['version'],
                      ),
              'events': await session.db
                  .unsafeQuery(
                    'SELECT e.id FROM serverpod_calendar_event e JOIN serverpod_calendar_identity c ON c.id=e."calendarId" WHERE c."scopeKey"=@scope',
                    parameters: QueryParameters.named({'scope': host.scope}),
                  )
                  .then((r) => r.length),
              'links': await CalendarInvitationLinkRecord.db.count(
                session,
                where: (t) => t.scopeKey.equals(host.scope),
              ),
              'applications': await CalendarInvitationApplicationRecord.db
                  .count(session, where: (t) => t.scopeKey.equals(host.scope)),
              'occurrenceRevision':
                  (await CalendarInvitationOccurrenceApplicationRecord.db
                          .findFirstRow(
                            session,
                            where: (t) => t.scopeKey.equals(host.scope),
                          ))
                      ?.revision,
              'eventRevision': await session.db
                  .unsafeQuery(
                    'SELECT e.revision FROM serverpod_calendar_event e JOIN serverpod_calendar_identity c ON c.id=e."calendarId" WHERE c."scopeKey"=@scope',
                    parameters: QueryParameters.named({'scope': host.scope}),
                  )
                  .then((r) => r.firstOrNull?.first),
              'kind': entries.firstOrNull?.kind.name,
              'targets': [
                for (final e in entries)
                  {
                    'id': e.id.toString(),
                    'target': e.targetKey,
                    'original': e.originalStart?.toJson(),
                    'revision': e.revision,
                    'kind': e.kind.name,
                  },
              ],
              'entries': entries.length,
              'sources': sources.length,
              'receipts': await CalendarInvitationReceiptRecord.db.count(
                session,
                where: (t) => t.scopeKey.equals(host.scope),
              ),
              'revision': entries.firstOrNull?.revision,
              'dismissed': entries.firstOrNull?.dismissedAt != null,
            };
          case 'dismiss':
            // Explicit test-only native identity; trusted ingress stays unauthenticated.
            session.updateAuthenticated(
              AuthenticationInfo('recipient', {}, authId: 'invitation-probe'),
            );
            try {
              await CalendarModule.service(session).dismissInvitation(
                UuidValue.fromString(input['entryId'] as String),
                input['revision'] as int,
              );
            } finally {
              session.updateAuthenticated(null);
            }
            result = true;
          case 'cleanup':
            final responseRows = await CalendarInvitationResponseRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            if (responseRows.isNotEmpty) {
              await CalendarInvitationResponseAttemptRecord.db.deleteWhere(
                session,
                where: (t) =>
                    t.responseId.inSet(responseRows.map((r) => r.id!).toSet()),
              );
              await CalendarInvitationResponseRecord.db.delete(
                session,
                responseRows,
              );
            }
            await CalendarInvitationResponseStateRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarInvitationOccurrenceApplicationRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarInvitationApplicationRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarInvitationLinkRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            final calendars = await CalendarIdentityRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            for (final c in calendars) {
              await CalendarEventDataRecord.db.deleteWhere(
                session,
                where: (t) => t.calendarId.equals(c.id!),
              );
              await CalendarEventRecord.db.deleteWhere(
                session,
                where: (t) => t.calendarId.equals(c.id!),
              );
              await CalendarDataRecord.db.deleteWhere(
                session,
                where: (t) => t.calendarId.equals(c.id!),
              );
              await CalendarIdentityRecord.db.deleteRow(session, c);
            }
            final entries = await CalendarInvitationRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarInvitationReceiptRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            if (entries.isNotEmpty) {
              await CalendarInvitationSourceRecord.db.deleteWhere(
                session,
                where: (t) =>
                    t.entryId.inSet(entries.map((e) => e.id!).toSet()),
              );
              await CalendarInvitationRecord.db.delete(session, entries);
            }
            await CalendarScopeRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            result = true;
          default:
            throw StateError('Unknown fixture command');
        }
      } on CalendarException catch (e) {
        result = {'error': e.code.name};
      }
      stdout.writeln('INVITATION_RESULT ${jsonEncode(result)}');
    }
  } finally {
    await session.close();
    await pod.shutdown();
  }
}
