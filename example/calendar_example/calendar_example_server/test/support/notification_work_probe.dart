import 'dart:convert';
import 'dart:io';

import 'package:serverpod_notifications_server/serverpod_notifications_server.dart';
import 'package:serverpod_notifications_server/src/notification_work_store.dart';
import 'package:calendar_example_server/src/generated/serverpod.dart';

/// Test-only independent process. No production endpoint or test-control API.
Future<void> main(List<String> args) async {
  final pod = Serverpod([
    '--mode=test',
    '--server-id=notification-work-probe-${args[1]}',
    '--apply-migrations',
  ]);
  final session = await pod.createSession(enableLogging: false);
  try {
    if ((await session.db.unsafeQuery('SELECT current_database()'))
            .single
            .single !=
        'calendar_example_test') {
      throw StateError('Synthetic test storage required');
    }
    await pod.start();
    NotificationModule.install(
      pod,
      policy: _Policy(),
      sources: [_Source()],
      publication: _Publication(),
    );
    final store = NotificationWorkStore(
      session,
      NotificationOptions(
        leaseDuration: const Duration(seconds: 5),
        maxClaims: 1,
      ),
    );
    stdout.writeln('NOTIFICATION_WORK_READY');
    final channel = File(args.first);
    var nonce = 0;
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      Map<String, dynamic> input;
      try {
        if (!await channel.exists()) continue;
        input =
            jsonDecode(await channel.readAsString()) as Map<String, dynamic>;
      } on FormatException {
        continue;
      }
      if (input['nonce'] == nonce) continue;
      nonce = input['nonce'] as int;
      Object result;
      switch (input['command']) {
        case 'seed':
          final id = const Uuid().v4obj();
          final scope = 'notification-work-probe:$id';
          final now = DateTime.now().toUtc();
          final due = DateTime.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch ~/ 1000 * 1000,
            isUtc: true,
          );
          final e = NotificationEnvelope(
            scopeKey: scope,
            recipient: NotificationRecipient('synthetic', 'probe'),
            sourceNamespace: 'synthetic.probe',
            sourceVersion: 1,
            requestId: '$id',
            reference: '$id',
            dueAt: due,
            expiresAt: due.add(const Duration(hours: 1)),
          );
          final record = await NotificationDeliveryRecord.db.insertRow(
            session,
            NotificationDeliveryRecord(
              scopeKey: scope,
              recipientNamespace: e.recipient.namespace,
              recipientKey: e.recipient.key,
              sourceNamespace: e.sourceNamespace,
              sourceVersion: e.sourceVersion,
              sourceRequestId: e.requestId,
              requestDigest: e.digest,
              sourceReference: e.reference,
              dueAt: e.dueAt,
              expiresAt: e.expiresAt,
              nextAttemptAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
          result = {'deliveryId': '${record.id}', 'scopeKey': scope};
        case 'accept':
          final v = input['fixture'] as Map<String, dynamic>;
          final stored = (await NotificationDeliveryRecord.db.findById(
            session,
            UuidValue.fromString(v['deliveryId']),
          ))!;
          result = (await NotificationModule.accept(
            session,
            NotificationEnvelope(
              scopeKey: stored.scopeKey,
              recipient: NotificationRecipient(
                stored.recipientNamespace,
                stored.recipientKey,
              ),
              sourceNamespace: stored.sourceNamespace,
              sourceVersion: stored.sourceVersion,
              requestId: '${stored.sourceRequestId}:race',
              reference: stored.sourceReference,
              dueAt: stored.dueAt,
              expiresAt: stored.expiresAt,
            ),
          )).toString();
        case 'removeRace':
          final v = input['fixture'] as Map<String, dynamic>;
          final stored = (await NotificationDeliveryRecord.db.findById(
            session,
            UuidValue.fromString(v['deliveryId']),
          ))!;
          await NotificationDeliveryRecord.db.deleteWhere(
            session,
            where: (t) =>
                t.scopeKey.equals(stored.scopeKey) &
                t.sourceRequestId.equals('${stored.sourceRequestId}:race'),
          );
          result = true;
        case 'claim':
          result = [
            for (final r in await store.claim())
              {
                'deliveryId': '${r.id}',
                'scopeKey': r.scopeKey,
                'owner': '${r.leaseOwner}',
                'fence': r.leaseFence,
              },
          ];
        case 'validate':
          final v = input['lease'] as Map<String, dynamic>;
          final row = await NotificationDeliveryRecord.db.findById(
            session,
            UuidValue.fromString(v['deliveryId']),
          );
          if (row == null) {
            result = false;
          } else {
            final old = row.copyWith(
              leaseOwner: UuidValue.fromString(v['owner']),
              leaseFence: v['fence'] as int,
            );
            result = await session.db.transaction(
              (tx) async => NotificationWorkStore.owns(
                row,
                old,
                await store.databaseTime(tx),
              ),
            );
          }
        case 'cleanup':
          final v = input['fixture'] as Map<String, dynamic>;
          if (!(v['scopeKey'] as String).startsWith(
            'notification-work-probe:',
          )) {
            throw StateError('Foreign fixture');
          }
          await NotificationDeliveryRecord.db.deleteWhere(
            session,
            where: (t) =>
                t.id.equals(UuidValue.fromString(v['deliveryId'])) &
                t.scopeKey.equals(v['scopeKey']),
          );
          await NotificationScopeRecord.db.deleteWhere(
            session,
            where: (t) => t.scopeKey.equals(v['scopeKey']),
          );
          result = true;
        default:
          throw ArgumentError('Unknown probe command');
      }
      stdout.writeln('NOTIFICATION_WORK_RESULT ${jsonEncode(result)}');
    }
  } finally {
    await session.close();
    await pod.shutdown();
  }
}

final class _Policy implements NotificationHostPolicy {
  @override
  NotificationGuarantee get guarantee => NotificationGuarantee.freshCheck;
  @override
  Future<NotificationActor> resolveContext(Session session) async =>
      throw StateError('No client projection in worker probe');
  @override
  Future<NotificationVerdict> authorize(
    Session session,
    NotificationActor actor,
    NotificationPermission operation,
    Transaction transaction,
    NotificationPhase phase,
  ) async => NotificationVerdict.deny;
}

final class _Source implements NotificationSourceAdapter {
  @override
  String get namespace => 'synthetic.probe';
  @override
  int get version => 1;
  @override
  NotificationGuarantee get guarantee => NotificationGuarantee.freshCheck;
  @override
  Future<NotificationVerdict> check(
    Session session,
    NotificationEnvelope envelope,
    NotificationSourceOperation operation,
    Transaction transaction,
    NotificationPhase phase,
  ) async => NotificationVerdict.allow;
  @override
  Future<NotificationContent?> project(
    Session session,
    NotificationEnvelope envelope,
    NotificationActor actor,
    Transaction transaction,
  ) async => null;
}

final class _Publication implements NotificationPublicationPort {
  @override
  Future<bool> publish(
    Session session,
    UuidValue notificationId,
    NotificationEnvelope envelope,
  ) async => false;
}
