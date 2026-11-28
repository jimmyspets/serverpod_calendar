import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:calendar_example_server/src/generated/serverpod.dart'
    as generated;

/// Process-owned test fixture. Never installed in the example application.
final class _Host implements CalendarIncomingPublicationHost {
  String scope = '';
  String pause = '';
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  CalendarIncomingPublicationRecipient get recipient =>
      CalendarIncomingPublicationRecipient(
        scopeKey: scope,
        key: 'recipient',
        calendarAddress: 'mailto:recipient@example.invalid',
      );
  @override
  Future<CalendarIncomingPublicationRecipient> resolveDelivery(
    Session s,
    CalendarIncomingPublicationDelivery d,
    IcalendarSchedulingMessage m,
  ) async => recipient;
  @override
  Future<CalendarIncomingPublicationRecipient> resolveRecipient(
    Session s,
    CalendarHostContext a,
  ) async => recipient;
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session s,
    CalendarIncomingPublicationPolicyContext c,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (await File(
      '../../../.local/publication-${scope.split(':').last}.revoked',
    ).exists()) {
      return CalendarAuthorizationVerdict.deny;
    }
    if (pause == 'before' && phase == CalendarAuthorizationPhase.finalWrite) {
      stdout.writeln('PUBLICATION_PAUSED');
      await Completer<void>().future;
    }
    return c.recipient.same(recipient)
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
  dynamic noSuchMethod(Invocation i) =>
      throw StateError('Unexpected probe policy operation');
  @override
  Future<CalendarHostContext> resolveContext(Session s) async =>
      CalendarHostContext(
        principalId: 'recipient',
        scopeKey: host.scope,
        policyRevision: 'synthetic-publication-probe',
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
        verdict: c.scopeKey == host.scope
            ? CalendarAuthorizationVerdict.allow
            : CalendarAuthorizationVerdict.deny,
        discloseMutationReceipt: true,
        disclosedGroups: CalendarFieldGroup.values,
        eventDisclosedGroups: CalendarEventFieldGroup.values,
      ),
  ];
}

Future<void> main(List<String> args) async {
  final pod = generated.Serverpod([
    '--mode=test',
    '--server-id=publication-probe-${args.first}',
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
    incomingPublications: CalendarIncomingPublicationRuntime(host: host),
  );
  await pod.start();
  stdout.writeln('PUBLICATION_READY');
  try {
    await for (final line
        in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
      final input = jsonDecode(line) as Map<String, dynamic>;
      host.scope =
          'publication-probe:${UuidValue.fromString(input['caseId'] as String)}';
      host.pause = input['pause'] as String? ?? '';
      session.updateAuthenticated(
        AuthenticationInfo(
          'recipient',
          {},
          authId: 'synthetic-publication-probe',
        ),
      );
      try {
        final service = CalendarModule.service(session);
        Object? result;
        switch (input['command']) {
          case 'receive':
            result = (await CalendarModule.receiveIncomingPublication(
              session,
              CalendarIncomingPublicationDelivery(
                namespace: 'synthetic-probe',
                deliveryKey: input['key'] as String,
                originReference: 'verified-probe',
                bytes: Uint8List.fromList(utf8.encode(input['wire'] as String)),
              ),
            )).toJson();
          case 'calendar':
            result = (await service.create(
              CalendarCreateRequest(
                displayName: 'Publication recovery probe',
                availabilityZoneId: 'UTC',
                noRuleFallback: CalendarNoRuleFallback.free,
              ),
            ))!.toJson();
          case 'add':
            result = (await service.incomingPublicationAdd(
              CalendarIncomingPublicationAddRequest.fromJson(
                input['request'] as Map<String, dynamic>,
              ),
            )).toJson();
          case 'apply':
            result = (await service.incomingPublicationApply(
              CalendarIncomingPublicationApplyRequest.fromJson(
                input['request'] as Map<String, dynamic>,
              ),
            )).toJson();
          case 'inspect':
            final entries = await CalendarIncomingPublicationRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            final parents = await CalendarIdentityRecord.db.find(
              session,
              where: (t) => t.scopeKey.equals(host.scope),
            );
            final events = <CalendarEventRecord>[];
            for (final parent in parents) {
              events.addAll(
                await CalendarEventRecord.db.find(
                  session,
                  where: (t) => t.calendarId.equals(parent.id!),
                ),
              );
            }
            result = {
              'entries': entries.length,
              'events': events.length,
              'revisions': [for (final e in events) e.revision],
            };
          default:
            throw ArgumentError('Unknown command');
        }
        if (host.pause == 'after') {
          stdout.writeln('PUBLICATION_PAUSED');
          await Completer<void>().future;
        }
        stdout.writeln('PUBLICATION_RESULT ${jsonEncode(result)}');
      } on CalendarException catch (e) {
        stdout.writeln(
          'PUBLICATION_RESULT ${jsonEncode({'error': e.code.name})}',
        );
      }
    }
  } finally {
    await session.close();
    await pod.shutdown(exitProcess: false);
  }
}
