import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_authorization.dart';
import 'generated/protocol.dart';

/// Trusted carrier only; source claims and routing hints establish no authority.
final class CalendarIncomingPublicationDelivery {
  CalendarIncomingPublicationDelivery({
    required this.namespace,
    required this.deliveryKey,
    required this.originReference,
    required Uint8List bytes,
  }) : bytes = _copy(bytes);
  static Uint8List _copy(Uint8List bytes) {
    if (bytes.length > 524288) {
      throw ArgumentError('Publication exceeds input limit');
    }
    return Uint8List.fromList(bytes).asUnmodifiableView();
  }

  final String namespace, deliveryKey, originReference;
  final Uint8List bytes;
}

final class CalendarIncomingPublicationRecipient {
  const CalendarIncomingPublicationRecipient({
    required this.scopeKey,
    required this.key,
    required this.calendarAddress,
  });
  final String scopeKey, key, calendarAddress;
  bool same(CalendarIncomingPublicationRecipient other) =>
      scopeKey == other.scopeKey &&
      key == other.key &&
      calendarAddress == other.calendarAddress;
}

enum CalendarIncomingPublicationOperation {
  receive,
  receiveCancellation,
  list,
  readHeader,
  readSummary,
  readSource,
  dismiss,
  readLink,
  adopt,
  applyUpdate,
  applyCancellation,
  reopen,
}

/// Immutable source and actual target context, independently checked by the host.
final class CalendarIncomingPublicationPolicyContext {
  const CalendarIncomingPublicationPolicyContext({
    required this.operation,
    required this.recipient,
    this.actor,
    this.delivery,
    this.entry,
    this.source,
    this.sourceId,
    this.sourceDigest,
    this.acceptedBasis,
    this.sourceBasis,
    this.calendar,
    this.currentEvent,
    this.proposedEvent,
    this.targetCalendarId,
    this.targetEventId,
    this.targetDeleted = false,
    this.isRetry = false,
  });
  final CalendarIncomingPublicationOperation operation;
  final CalendarIncomingPublicationRecipient recipient;
  final CalendarHostContext? actor;
  final CalendarIncomingPublicationDelivery? delivery;
  final CalendarIncomingPublicationView? entry;
  final IcalendarSchedulingMessage? source, acceptedBasis, sourceBasis;
  final UuidValue? sourceId;
  final String? sourceDigest;
  final CalendarPolicySnapshot? calendar;
  final CalendarEventPolicySnapshot? currentEvent, proposedEvent;
  final UuidValue? targetCalendarId, targetEventId;
  final bool targetDeleted;
  final bool isRetry;
}

abstract interface class CalendarIncomingPublicationHost {
  CalendarAuthorizationGuarantee get guarantee;
  Future<CalendarIncomingPublicationRecipient> resolveDelivery(
    Session session,
    CalendarIncomingPublicationDelivery delivery,
    IcalendarSchedulingMessage source,
  );
  Future<CalendarIncomingPublicationRecipient> resolveRecipient(
    Session session,
    CalendarHostContext actor,
  );
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarIncomingPublicationPolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}

final class CalendarIncomingPublicationOptions {
  CalendarIncomingPublicationOptions({
    this.maxSourceBytes = 524288,
    this.maxEntriesPerRecipient = 256,
    this.maxEntriesPerScope = 1024,
    this.maxSourcesPerEntry = 32,
    this.maxReceiptsPerEntry = 64,
    this.maxRecipientBytes = 16777216,
    this.maxScopeBytes = 67108864,
    this.maxLinkBytes = 2097152,
    this.maxScannedEntries = 1000,
    this.retention = const Duration(days: 30),
  }) {
    final checks = [
      [maxSourceBytes, 524288],
      [maxEntriesPerRecipient, 256],
      [maxEntriesPerScope, 1024],
      [maxSourcesPerEntry, 32],
      [maxReceiptsPerEntry, 64],
      [maxRecipientBytes, 16777216],
      [maxScopeBytes, 67108864],
      [maxLinkBytes, 2097152],
      [maxScannedEntries, 1000],
    ];
    for (final values in checks) {
      RangeError.checkValueInInterval(values[0], 1, values[1]);
    }
    if (maxEntriesPerRecipient > maxScannedEntries ||
        maxEntriesPerRecipient > maxEntriesPerScope ||
        maxRecipientBytes > maxScopeBytes ||
        retention <= Duration.zero ||
        retention > const Duration(days: 365)) {
      throw ArgumentError('Invalid publication limits');
    }
  }
  final int maxSourceBytes,
      maxEntriesPerRecipient,
      maxEntriesPerScope,
      maxSourcesPerEntry,
      maxReceiptsPerEntry,
      maxRecipientBytes,
      maxScopeBytes,
      maxLinkBytes,
      maxScannedEntries;
  final Duration retention;
}

final class CalendarIncomingPublicationRuntime {
  CalendarIncomingPublicationRuntime({
    required this.host,
    CalendarIncomingPublicationOptions? options,
  }) : options = options ?? CalendarIncomingPublicationOptions();
  final CalendarIncomingPublicationHost host;
  final CalendarIncomingPublicationOptions options;
}
