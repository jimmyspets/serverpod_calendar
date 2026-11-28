import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_authorization.dart';
import 'generated/protocol.dart';

/// Trusted server input. Neither this carrier nor parsed source proves origin.
final class CalendarInvitationDelivery {
  CalendarInvitationDelivery({
    required this.namespace,
    required this.deliveryKey,
    required this.originReference,
    required Uint8List bytes,
  }) : bytes = _copy(bytes);
  static Uint8List _copy(Uint8List bytes) {
    if (bytes.length > 262144) {
      throw ArgumentError('Invitation source exceeds limit');
    }
    return Uint8List.fromList(bytes).asUnmodifiableView();
  }

  final String namespace, deliveryKey, originReference;
  final Uint8List bytes;
}

final class CalendarInvitationRecipient {
  const CalendarInvitationRecipient({
    required this.scopeKey,
    required this.key,
    required this.calendarAddress,
  });
  final String scopeKey, key, calendarAddress;
  bool same(CalendarInvitationRecipient other) =>
      scopeKey == other.scopeKey &&
      key == other.key &&
      calendarAddress == other.calendarAddress;
}

enum CalendarInvitationOperation {
  receive,
  list,
  readSummary,
  readSource,
  dismiss,
}

/// Immutable actual source/target context; absent current means not yet loaded.
final class CalendarInvitationPolicyContext {
  const CalendarInvitationPolicyContext({
    required this.operation,
    required this.recipient,
    this.actor,
    this.delivery,
    this.message,
    this.normalizedSource,
    this.sourceDigest,
    this.current,
    this.proposedOutcome,
    this.proposedRevision,
    this.proposedDismissed,
    this.entryId,
    this.sourceId,
    this.receiptId,
    this.isRetry = false,
    this.receipt,
  });
  final CalendarInvitationOperation operation;
  final CalendarInvitationRecipient recipient;
  final CalendarHostContext? actor;
  final CalendarInvitationDelivery? delivery;
  final IcalendarSchedulingMessage? message;
  final String? normalizedSource, sourceDigest;
  final CalendarInvitationView? current;
  final CalendarInvitationOutcome? proposedOutcome;
  final int? proposedRevision;
  final bool? proposedDismissed;
  final UuidValue? entryId, sourceId, receiptId;
  final bool isRetry;
  final CalendarInvitationReceipt? receipt;
}

abstract interface class CalendarInvitationHost {
  CalendarAuthorizationGuarantee get guarantee;

  /// Resolve actual scope/recipient and verify origin for source ORGANIZER.
  /// Final receive authorization must recheck this mapping in the transaction.
  Future<CalendarInvitationRecipient> resolveDelivery(
    Session session,
    CalendarInvitationDelivery delivery,
    IcalendarSchedulingMessage message,
  );
  Future<CalendarInvitationRecipient> resolveCurrent(
    Session session,
    CalendarHostContext actor,
    Transaction transaction,
  );
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarInvitationPolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}

final class CalendarInvitationOptions {
  CalendarInvitationOptions({
    this.maxPending = 64,
    this.maxDismissed = 64,
    this.maxSourcesPerEntry = 16,
    this.maxSources = 256,
    this.maxSourceBytes = 262144,
    this.maxRetainedBytes = 16777216,
    this.maxReceipts = 1024,
    this.terminalRetention = const Duration(days: 30),
  }) {
    for (final pair in [
      (maxPending, 64),
      (maxDismissed, 64),
      (maxSourcesPerEntry, 16),
      (maxSources, 256),
      (maxSourceBytes, 262144),
      (maxRetainedBytes, 16777216),
      (maxReceipts, 1024),
    ]) {
      if (pair.$1 < 1 || pair.$1 > pair.$2) {
        throw ArgumentError('Invalid invitation limit');
      }
    }
    if (terminalRetention <= Duration.zero ||
        terminalRetention > const Duration(days: 365)) {
      throw ArgumentError('Invalid invitation retention');
    }
  }
  final int maxPending,
      maxDismissed,
      maxSourcesPerEntry,
      maxSources,
      maxSourceBytes,
      maxRetainedBytes,
      maxReceipts;
  final Duration terminalRetention;
}

final class CalendarInvitationRuntime {
  CalendarInvitationRuntime({
    required this.host,
    CalendarInvitationOptions? options,
  }) : options = options ?? CalendarInvitationOptions();
  final CalendarInvitationHost host;
  final CalendarInvitationOptions options;
}
