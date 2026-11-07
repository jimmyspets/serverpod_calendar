import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:calendar_example_server/src/free_busy_mime.dart';
import 'package:calendar_example_server/src/generated/serverpod.dart'
    as generated;
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

File _file(String scope, String suffix) =>
    File('../../../.local/freebusy-probe-${scope.split(':').last}.$suffix');
Future<void> _pause(String phase) async {
  stdout.writeln('FREEBUSY_PAUSED $phase');
  await stdout.flush();
  await Completer<void>().future;
}

final class _Host implements CalendarFreeBusyExchangeHost {
  String scope = '', pause = '';
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  Future<String> resolveOwner(
    Session s,
    CalendarHostContext c,
    Transaction tx,
    CalendarAuthorizationPhase p,
  ) async => 'synthetic';
  @override
  Future<CalendarFreeBusyMailbox> resolveMailbox(
    Session s,
    CalendarHostContext c,
    UuidValue id,
    Transaction tx,
    CalendarAuthorizationPhase p,
  ) async {
    final calendar = await CalendarIdentityRecord.db.findById(
      s,
      id,
      transaction: tx,
    );
    if (calendar == null ||
        calendar.scopeKey != c.scopeKey ||
        calendar.deletedAt != null) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Synthetic mailbox denied',
      );
    }
    return CalendarFreeBusyMailbox(
      scopeKey: c.scopeKey,
      ownerKey: 'synthetic',
      calendarId: id,
      address:
          'mailto:busy-${sha256.convert(utf8.encode('probe-mailbox:$id')).toString().substring(0, 32)}@example.invalid',
      bindingRef: 'calendar:$id',
    );
  }

  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session s,
    CalendarFreeBusyExchangePolicyContext c,
    Transaction tx,
    CalendarAuthorizationPhase p,
  ) async {
    if (!c.scopeKey.startsWith('freebusy-work:') ||
        c.ownerKey != 'synthetic' ||
        await _file(c.scopeKey, 'revoked').exists()) {
      return CalendarAuthorizationVerdict.deny;
    }
    if (c.operation == CalendarFreeBusyExchangeOperation.dispatch &&
        (c.actor != null || s.authenticated != null)) {
      throw StateError('Worker fabricated an actor');
    }
    if (pause == 'beforeCommit' &&
        p == CalendarAuthorizationPhase.finalWrite &&
        c.message != null &&
        c.operation != CalendarFreeBusyExchangeOperation.dispatch) {
      await _pause('beforeCommit');
    }
    if (pause == 'beforeSubmit' &&
        p == CalendarAuthorizationPhase.finalWrite &&
        c.operation == CalendarFreeBusyExchangeOperation.dispatch) {
      await _pause('beforeSubmit');
    }
    return CalendarAuthorizationVerdict.allow;
  }

  @override
  Future<CalendarAuthorizationVerdict> authorizeSources(
    Session s,
    CalendarFreeBusyExchangePolicyContext c,
    List<CalendarAuthorizationRequest> requests,
    Transaction tx,
    CalendarAuthorizationPhase p,
  ) async {
    if (s.authenticated != null ||
        c.actor != null ||
        c.mailbox == null ||
        requests.any(
          (r) =>
              r.calendarId != c.mailbox!.calendarId ||
              r.current?.calendarId != c.mailbox!.calendarId,
        )) {
      throw StateError('Invalid actor-free source context');
    }
    return await _file(c.scopeKey, 'source-revoked').exists()
        ? CalendarAuthorizationVerdict.deny
        : CalendarAuthorizationVerdict.allow;
  }

  @override
  Future<List<CalendarSchedulingRoute>> resolveRoutes(
    Session s,
    CalendarFreeBusyExchangePolicyContext c,
    List<String> addresses,
    Transaction tx,
    CalendarAuthorizationPhase p,
  ) async => [
    for (final a in addresses)
      CalendarSchedulingRoute(
        a,
        await _file(c.scopeKey, 'route-changed').exists() ? 'changed:$a' : a,
      ),
  ];
}

final class _Policy implements CalendarHostPolicy {
  _Policy(this.host);
  final _Host host;
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  @override
  dynamic noSuchMethod(Invocation i) =>
      throw StateError('Unexpected synthetic foreground policy operation');
  @override
  Future<CalendarHostContext> resolveContext(Session s) async =>
      CalendarHostContext(
        principalId: 'synthetic',
        scopeKey: host.scope,
        policyRevision: 'freebusy-probe-v1',
      );
  @override
  Future<List<CalendarAuthorizationDecision>> authorizeBatch(
    Session s,
    CalendarHostContext c,
    List<CalendarAuthorizationRequest> requests,
    Transaction tx,
    CalendarAuthorizationPhase p,
  ) async => [
    for (final r in requests)
      CalendarAuthorizationDecision(
        key: r.key,
        verdict:
            c.scopeKey == host.scope && c.scopeKey.startsWith('freebusy-work:')
            ? CalendarAuthorizationVerdict.allow
            : CalendarAuthorizationVerdict.deny,
        disclosedGroups: CalendarFieldGroup.values,
        eventDisclosedGroups: CalendarEventFieldGroup.values,
        discloseMutationReceipt: true,
      ),
  ];
}

final class _Transport implements CalendarSchedulingTransport {
  _Transport(this.host);
  final _Host host;
  @override
  Future<CalendarSchedulingTransportResult> submit(
    Session s,
    CalendarSchedulingSubmission value,
  ) async {
    if (host.pause == 'afterLease') await _pause('afterLease');
    final mime = composeSyntheticFreeBusyMime(value);
    final file = _file(value.scopeKey, '${value.deliveryKey}.accepted');
    final body = jsonEncode({
      'key': value.deliveryKey.toString(),
      'payload': value.payload,
      'mime': mime,
    });
    if (await file.exists()) {
      if (await file.readAsString() != body) {
        throw StateError('Stable retry identity changed bytes');
      }
    } else {
      await file.writeAsString(body, flush: true);
    }
    if (host.pause == 'afterAcceptance') await _pause('afterAcceptance');
    return CalendarSchedulingTransportResult(
      CalendarSchedulingTransportOutcome.accepted,
      receipt: 'synthetic:${value.deliveryKey}',
      mimeDigest: sha256.convert(ascii.encode(mime)).toString(),
    );
  }
}

Future<void> main(List<String> args) async {
  final pod = generated.Serverpod([
    '--mode=test',
    '--server-id=freebusy-probe-${args.single}',
    '--apply-migrations',
  ]);
  final session = await pod.createSession(enableLogging: false);
  if ((await session.db.unsafeQuery('SELECT current_database()'))
          .single
          .single !=
      'calendar_example_test') {
    throw StateError('Disposable test database required');
  }
  final host = _Host();
  CalendarModule.install(
    pod,
    policy: _Policy(host),
    options: const CalendarModuleOptions(
      requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
    ),
    freeBusyExchanges: CalendarFreeBusyExchangeRuntime(
      host: host,
      transport: _Transport(host),
      options: CalendarFreeBusyExchangeOptions(
        lease: const Duration(seconds: 6),
        transportTimeout: const Duration(seconds: 5),
        retryBase: const Duration(seconds: 1),
      ),
    ),
  );
  await pod.start();
  stdout.writeln('FREEBUSY_READY');
  try {
    await for (final line
        in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
      final input = jsonDecode(line) as Map<String, dynamic>;
      final caseId = input['case'] as String;
      if (!RegExp(r'^[a-f0-9-]{36}$').hasMatch(caseId)) {
        throw StateError('Invalid synthetic case');
      }
      host.scope = 'freebusy-work:$caseId';
      host.pause = input['pause'] as String? ?? '';
      session.updateAuthenticated(
        AuthenticationInfo('synthetic', {}, authId: 'freebusy-probe'),
      );
      Object? result;
      try {
        final service = CalendarModule.service(session);
        switch (input['command']) {
          case 'create':
            final receipt = (await service.create(
              CalendarCreateRequest(
                displayName: 'Synthetic busy calendar',
                availabilityZoneId: 'Europe/Stockholm',
                noRuleFallback: CalendarNoRuleFallback.free,
              ),
            ))!;
            final event = (await service.createEvent(
              CalendarEventCreateRequest(
                calendarId: receipt.calendarId,
                content: CalendarEventContent(
                  summary: 'Synthetic private text must stay private',
                  timing: CalendarEventTiming(
                    kind: CalendarEventTimeKind.utc,
                    start: CalendarEventCivil(
                      year: 2030,
                      month: 11,
                      day: 6,
                      hour: 9,
                    ),
                    duration: CalendarEventDuration(hours: 1),
                  ),
                ),
              ),
            ))!;
            result = {
              'calendar': receipt.calendarId.toString(),
              'event': event.eventId.toString(),
            };
          case 'queue':
            final request = CalendarFreeBusyPublishRequest.fromJson(
              Map<String, dynamic>.from(input['request'] as Map),
            );
            final receipt = await service.publishFreeBusy(request);
            if (host.pause == 'afterCommit') await _pause('afterCommit');
            result = receipt.toJson();
          case 'work':
            final worker = await pod.createSession(enableLogging: false);
            try {
              result = await CalendarModule.runFreeBusyExchangeMaintenance(
                worker,
              );
            } finally {
              await worker.close();
            }
          case 'expire-lease':
            final rows = await CalendarFreeBusyDeliveryRecord.db.find(
              session,
              where: (t) =>
                  t.scopeKey.equals(host.scope) & t.terminalAt.equals(null),
            );
            for (final row in rows) {
              row.leaseUntil = DateTime.utc(1970);
              row.nextAttemptAt = DateTime.utc(1970);
              await CalendarFreeBusyDeliveryRecord.db.updateRow(session, row);
            }
            result = rows.length;
          case 'delete-event':
            result = (await service.deleteEvent(
              UuidValue.fromString(input['event'] as String),
              1,
            ))?.deleted;
          case 'flag':
            final suffix = input['flag'] as String;
            if (!{
              'revoked',
              'source-revoked',
              'route-changed',
            }.contains(suffix)) {
              throw StateError('Unknown synthetic flag');
            }
            await _file(
              host.scope,
              suffix,
            ).writeAsString('synthetic', flush: true);
            result = true;
          case 'state':
            final commands = await CalendarFreeBusyCommandRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            final deliveries = await CalendarFreeBusyDeliveryRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            final attempts = await CalendarFreeBusyAttemptRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            result = {
              'commands': [
                for (final c in commands)
                  {
                    'id': c.id.toString(),
                    'payload': c.payload,
                    'receipt': c.receipt,
                    'scrubbed': c.scrubbedAt != null,
                  },
              ],
              'deliveries': [
                for (final d in deliveries)
                  {
                    'id': d.id.toString(),
                    'state': d.state,
                    'attempts': d.attemptCount,
                    'generation': d.generation,
                  },
              ],
              'attempts': [
                for (final a in attempts)
                  {
                    'outcome': a.outcome,
                    'finished': a.finishedAt != null,
                    'mimeDigest': a.mimeDigest,
                  },
              ],
            };
          case 'cleanup':
            final sources = await CalendarFreeBusySourceRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            for (final row in sources) {
              row.requestCommandId = null;
              await CalendarFreeBusySourceRecord.db.updateRow(session, row);
            }
            final commands = await CalendarFreeBusyCommandRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            for (final row in commands) {
              row.sourceId = null;
              await CalendarFreeBusyCommandRecord.db.updateRow(session, row);
            }
            await CalendarFreeBusyAttemptRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarFreeBusyDeliveryRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarFreeBusySourceReferenceRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarFreeBusyIngressReceiptRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarFreeBusyCommandRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarFreeBusySourceRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarFreeBusyRequestHeadRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            final calendars = await CalendarIdentityRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            for (final c in calendars) {
              final events = await CalendarEventRecord.db.find(
                session,
                where: (t) => t.calendarId.equals(c.id!),
              );
              for (final e in events) {
                await CalendarEventDataRecord.db.deleteWhere(
                  session,
                  where: (t) => t.eventId.equals(e.id!),
                );
              }
              await CalendarEventRecord.db.deleteWhere(
                session,
                where: (t) => t.calendarId.equals(c.id!),
              );
              await CalendarSubjectRecord.db.deleteWhere(
                session,
                where: (t) => t.calendarId.equals(c.id!),
              );
              await CalendarDataRecord.db.deleteWhere(
                session,
                where: (t) => t.calendarId.equals(c.id!),
              );
              await CalendarIdentityRecord.db.deleteRow(session, c);
            }
            await CalendarCursorRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            await CalendarScopeRecord.db.deleteWhere(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            result = true;
          default:
            throw StateError('Unknown synthetic command');
        }
        stdout.writeln('FREEBUSY_RESULT ${jsonEncode(result)}');
      } on CalendarException catch (e) {
        stdout.writeln(
          'FREEBUSY_RESULT ${jsonEncode({'failure': e.code.name})}',
        );
      }
    }
  } finally {
    await session.close();
    await pod.shutdown(exitProcess: false);
  }
}
