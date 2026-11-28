import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

enum NotificationGuarantee { freshCheck, coordinated }

enum NotificationPhase { preliminary, finalCheck }

enum NotificationVerdict { allow, deny, unavailable }

enum NotificationSourceOperation { accept, publish, recover }

enum NotificationPermission { recover, subscribe }

void notificationOpaque(String value, {int maxBytes = 256}) {
  if (value.isEmpty ||
      utf8.encode(value).length > maxBytes ||
      value.runes.any((r) => r < 32 || r == 127)) {
    throw ArgumentError('Invalid notification identifier');
  }
}

void notificationInstant(DateTime value) {
  if (!value.isUtc ||
      value.microsecondsSinceEpoch % 1000000 != 0 ||
      value.year < 1 ||
      value.year > 9999) {
    throw ArgumentError('Notification instants require whole-second UTC');
  }
}

final class NotificationRecipient {
  NotificationRecipient(this.namespace, this.key) {
    notificationOpaque(namespace);
    notificationOpaque(key);
  }
  final String namespace, key;
}

/// Trusted producer value. No client endpoint accepts recipients or source refs.
final class NotificationEnvelope {
  NotificationEnvelope({
    required this.scopeKey,
    required this.recipient,
    required this.sourceNamespace,
    required this.sourceVersion,
    required this.requestId,
    required this.reference,
    required this.dueAt,
    required this.expiresAt,
  }) {
    for (final v in [scopeKey, sourceNamespace, requestId]) {
      notificationOpaque(v);
    }
    notificationOpaque(reference, maxBytes: 4096);
    if (sourceVersion < 1 || sourceVersion > 9007199254740991) {
      throw ArgumentError('Invalid source version');
    }
    notificationInstant(dueAt);
    notificationInstant(expiresAt);
    if (!expiresAt.isAfter(dueAt)) {
      throw ArgumentError('Notification expiry must follow due time');
    }
  }
  final String scopeKey, sourceNamespace, requestId, reference;
  final int sourceVersion;
  final NotificationRecipient recipient;
  final DateTime dueAt, expiresAt;
  String get digest => sha256
      .convert(
        utf8.encode(
          jsonEncode([
            scopeKey,
            recipient.namespace,
            recipient.key,
            sourceNamespace,
            sourceVersion,
            requestId,
            reference,
            dueAt.toIso8601String(),
            expiresAt.toIso8601String(),
          ]),
        ),
      )
      .toString();
}

final class NotificationActor {
  NotificationActor({
    required this.principalId,
    required this.scopeKey,
    required this.policyRevision,
    required this.recipient,
  }) {
    for (final v in [principalId, scopeKey, policyRevision]) {
      notificationOpaque(v);
    }
  }
  final String principalId, scopeKey, policyRevision;
  final NotificationRecipient recipient;
  bool same(NotificationActor other) =>
      principalId == other.principalId &&
      scopeKey == other.scopeKey &&
      policyRevision == other.policyRevision &&
      recipient.namespace == other.recipient.namespace &&
      recipient.key == other.recipient.key;
}

/// Ephemeral presentation. Never persisted in delivery/cursor rows.
final class NotificationContent {
  NotificationContent({required this.title, this.body, this.actionReference}) {
    if (title.trim().isEmpty ||
        title.runes.length > 512 ||
        title.contains(RegExp(r'[\r\n\x00]')) ||
        (body?.runes.length ?? 0) > 4096 ||
        (body?.contains('\u0000') ?? false)) {
      throw ArgumentError('Invalid notification presentation');
    }
    if (actionReference != null) {
      notificationOpaque(actionReference!, maxBytes: 4096);
    }
  }
  final String title;
  final String? body, actionReference;
}

abstract interface class NotificationHostPolicy {
  NotificationGuarantee get guarantee;
  Future<NotificationActor> resolveContext(Session session);
  Future<NotificationVerdict> authorize(
    Session session,
    NotificationActor actor,
    NotificationPermission operation,
    Transaction transaction,
    NotificationPhase phase,
  );
}

abstract interface class NotificationSourceAdapter {
  String get namespace;
  int get version;
  NotificationGuarantee get guarantee;
  Future<NotificationVerdict> check(
    Session session,
    NotificationEnvelope envelope,
    NotificationSourceOperation operation,
    Transaction transaction,
    NotificationPhase phase,
  );
  Future<NotificationContent?> project(
    Session session,
    NotificationEnvelope envelope,
    NotificationActor actor,
    Transaction transaction,
  );
}

abstract interface class NotificationPublicationPort {
  /// True means a hint was posted, never display or acknowledgement.
  Future<bool> publish(
    Session session,
    UuidValue notificationId,
    NotificationEnvelope envelope,
  );
}

final class NotificationOptions {
  NotificationOptions({
    this.requiredGuarantee = NotificationGuarantee.freshCheck,
    this.maxRetainedPerRecipient = 10000,
    this.maxClaims = 100,
    this.maxPageSize = 100,
    this.maxScanned = 1000,
    this.maxCursorsPerScope = 1000,
    this.leaseDuration = const Duration(seconds: 30),
    this.retryDelay = const Duration(seconds: 30),
    this.terminalRetention = const Duration(days: 30),
    this.cursorLifetime = const Duration(minutes: 15),
    this.callbackTimeout = const Duration(seconds: 5),
    this.publicationTimeout = const Duration(seconds: 20),
  }) {
    for (final v in [
      maxRetainedPerRecipient,
      maxClaims,
      maxPageSize,
      maxScanned,
      maxCursorsPerScope,
    ]) {
      RangeError.checkValueInInterval(v, 1, 100000);
    }
    if (maxClaims > 1000 ||
        maxPageSize > 1000 ||
        maxScanned < maxPageSize ||
        leaseDuration < const Duration(seconds: 1) ||
        leaseDuration > const Duration(minutes: 5) ||
        retryDelay <= Duration.zero ||
        retryDelay > const Duration(days: 1) ||
        terminalRetention <= Duration.zero ||
        terminalRetention > const Duration(days: 3660) ||
        cursorLifetime <= Duration.zero ||
        cursorLifetime > const Duration(hours: 1) ||
        callbackTimeout <= Duration.zero ||
        callbackTimeout > const Duration(seconds: 30) ||
        publicationTimeout <= Duration.zero ||
        publicationTimeout > const Duration(minutes: 1)) {
      throw ArgumentError('Invalid notification limits');
    }
  }
  final NotificationGuarantee requiredGuarantee;
  final int maxRetainedPerRecipient,
      maxClaims,
      maxPageSize,
      maxScanned,
      maxCursorsPerScope;
  final Duration leaseDuration,
      retryDelay,
      terminalRetention,
      cursorLifetime,
      callbackTimeout,
      publicationTimeout;
}
