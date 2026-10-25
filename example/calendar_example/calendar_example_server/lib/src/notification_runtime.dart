import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart'
    as cal;
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as notify;

/// Private demo scope only. Production hosts supply their own actor/recipient rules.
final class DemoNotificationPolicy implements notify.NotificationHostPolicy {
  @override
  notify.NotificationGuarantee get guarantee =>
      notify.NotificationGuarantee.freshCheck;
  @override
  Future<notify.NotificationActor> resolveContext(Session session) async {
    final token = session.authenticationKey;
    final handler = session.serverpod.authenticationHandler;
    final current = token == null || handler == null
        ? null
        : await handler(session, token);
    if (current == null ||
        current.userIdentifier != session.authenticated?.userIdentifier) {
      throw StateError('Current authentication required');
    }
    return notify.NotificationActor(
      principalId: current.userIdentifier,
      scopeKey: 'demo:user:${current.userIdentifier}',
      policyRevision: 'demo-notifications-v1',
      recipient: notify.NotificationRecipient('demo', current.userIdentifier),
    );
  }

  @override
  Future<notify.NotificationVerdict> authorize(
    Session session,
    notify.NotificationActor actor,
    notify.NotificationPermission operation,
    Transaction transaction,
    notify.NotificationPhase phase,
  ) async {
    if (actor.recipient.namespace != 'demo' ||
        actor.recipient.key != actor.principalId ||
        actor.scopeKey != 'demo:user:${actor.principalId}') {
      return notify.NotificationVerdict.deny;
    }
    final user = await AuthUser.db.findById(
      session,
      UuidValue.fromString(actor.principalId),
      transaction: transaction,
    );
    return user != null && !user.blocked
        ? notify.NotificationVerdict.allow
        : notify.NotificationVerdict.deny;
  }
}

String demoNotificationChannel(
  String scope,
  notify.NotificationRecipient recipient,
) =>
    'calendar_example_notifications_${sha256.convert(utf8.encode(jsonEncode([scope, recipient.namespace, recipient.key])))}';

final class DemoNotificationPublication
    implements notify.NotificationPublicationPort {
  @override
  Future<bool> publish(
    Session session,
    UuidValue id,
    notify.NotificationEnvelope envelope,
  ) => session.messages.postMessage(
    demoNotificationChannel(envelope.scopeKey, envelope.recipient),
    notify.NotificationHint(notificationId: id),
    scope: MessageScope.global,
  );
}

String _reference(cal.CalendarAlarmDeliveryIntent intent) => jsonEncode([
  intent.firingId.toString(),
  intent.alarmId.toString(),
  intent.generation,
  intent.recipient.namespace,
  intent.recipient.key,
  intent.parent.kind.name,
  intent.parent.id.toString(),
  intent.originalKey,
  intent.dueAt.toIso8601String(),
  intent.expiresAt.toIso8601String(),
]);

cal.CalendarAlarmDeliveryIntent _intent(String reference) {
  final v = jsonDecode(reference) as List<dynamic>;
  if (v.length != 10) throw ArgumentError('Invalid alarm source');
  return cal.CalendarAlarmDeliveryIntent(
    firingId: UuidValue.fromString(v[0] as String),
    alarmId: UuidValue.fromString(v[1] as String),
    generation: v[2] as int,
    recipient: cal.CalendarAlarmRecipient(v[3] as String, v[4] as String),
    parent: cal.CalendarAlarmParent(
      kind: cal.CalendarAlarmParentKind.values.byName(v[5] as String),
      id: UuidValue.fromString(v[6] as String),
    ),
    originalKey: v[7] as String,
    dueAt: DateTime.parse(v[8] as String),
    expiresAt: DateTime.parse(v[9] as String),
  );
}

/// A separate source transaction provides an explicit fresh check, not coordination.
final class CalendarNotificationSource
    implements notify.NotificationSourceAdapter {
  @override
  String get namespace => 'calendar.alarm';
  @override
  int get version => 1;
  @override
  notify.NotificationGuarantee get guarantee =>
      notify.NotificationGuarantee.freshCheck;
  @override
  Future<notify.NotificationVerdict> check(
    Session session,
    notify.NotificationEnvelope e,
    notify.NotificationSourceOperation operation,
    Transaction transaction,
    notify.NotificationPhase phase,
  ) async {
    cal.CalendarAlarmDeliveryIntent intent;
    try {
      intent = _intent(e.reference);
      if (_reference(intent) != e.reference ||
          e.scopeKey != 'demo:user:${intent.recipient.key}' ||
          intent.recipient.namespace != 'demo' ||
          e.recipient.namespace != intent.recipient.namespace ||
          e.recipient.key != intent.recipient.key ||
          e.requestId != intent.firingId.toString() ||
          e.dueAt != intent.dueAt ||
          e.expiresAt != intent.expiresAt) {
        return notify.NotificationVerdict.deny;
      }
    } catch (_) {
      return notify.NotificationVerdict.deny;
    }
    final check = await cal.CalendarModule.checkAlarmDelivery(
      session,
      intent,
      forProjection: operation == notify.NotificationSourceOperation.recover,
    );
    return switch (check) {
      cal.CalendarAlarmDeliveryCheck.eligible =>
        notify.NotificationVerdict.allow,
      cal.CalendarAlarmDeliveryCheck.withdrawn =>
        notify.NotificationVerdict.deny,
      cal.CalendarAlarmDeliveryCheck.unavailable =>
        notify.NotificationVerdict.unavailable,
    };
  }

  @override
  Future<notify.NotificationContent?> project(
    Session session,
    notify.NotificationEnvelope e,
    notify.NotificationActor actor,
    Transaction transaction,
  ) async {
    if (actor.scopeKey != e.scopeKey ||
        actor.recipient.namespace != e.recipient.namespace ||
        actor.recipient.key != e.recipient.key) {
      return null;
    }
    final p = await cal.CalendarModule.projectAlarmNotification(
      session,
      _intent(e.reference),
    );
    if (p == null || p.scopeKey != e.scopeKey) return null;
    final fallback = p.parent.kind == cal.CalendarAlarmParentKind.event
        ? 'Untitled event'
        : 'Untitled task';
    final full = p.summary == null || p.summary!.trim().isEmpty
        ? fallback
        : p.summary!;
    // Bounded presentation only; canonical/native text is never changed.
    final title = full.runes.length <= 512
        ? full
        : '${String.fromCharCodes(full.runes.take(511))}…';
    return notify.NotificationContent(
      title: title.replaceAll(RegExp(r'[\r\n]'), ' '),
      body: p.parent.kind == cal.CalendarAlarmParentKind.event
          ? 'Event reminder'
          : 'Task reminder',
      actionReference: jsonEncode({
        'parentKind': p.parent.kind.name,
        'parentId': p.parent.id.toString(),
        'alarmId': p.alarmId.toString(),
        'firingId': p.firingId.toString(),
        'alarmRevision': p.alarmRevision,
        'actionRevision': p.actionRevision,
        'snoozeAllowed': p.snoozeAllowed,
      }),
    );
  }
}

final class CalendarNotificationDelivery
    implements cal.CalendarAlarmDeliveryPort {
  @override
  Future<bool> accept(
    Session session,
    cal.CalendarAlarmDeliveryIntent intent,
  ) async {
    await notify.NotificationModule.accept(
      session,
      notify.NotificationEnvelope(
        scopeKey: 'demo:user:${intent.recipient.key}',
        recipient: notify.NotificationRecipient(
          intent.recipient.namespace,
          intent.recipient.key,
        ),
        sourceNamespace: 'calendar.alarm',
        sourceVersion: 1,
        requestId: intent.firingId.toString(),
        reference: _reference(intent),
        dueAt: intent.dueAt,
        expiresAt: intent.expiresAt,
      ),
    );
    return true;
  }
}
