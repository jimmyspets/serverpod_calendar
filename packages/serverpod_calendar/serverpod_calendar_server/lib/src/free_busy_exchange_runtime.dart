import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_authorization.dart';
import 'scheduling_runtime.dart';

enum CalendarFreeBusyExchangeOperation {
  receivePublish,
  receiveRequest,
  receiveReply,
  readHeader,
  readSource,
  dismiss,
  publish,
  request,
  share,
  refuse,
  withdraw,
  readOutgoing,
  readActivity,
  dispatch,
}

/// Trusted private identity and exact native mailbox binding, never supplied by
/// a generated client. A mailbox represents this calendar, not an inferred set
/// of a person's calendars.
final class CalendarFreeBusyMailbox {
  const CalendarFreeBusyMailbox({
    required this.scopeKey,
    required this.ownerKey,
    required this.calendarId,
    required this.address,
    required this.bindingRef,
  });
  final String scopeKey, ownerKey, address, bindingRef;
  final UuidValue calendarId;
}

/// Host-only transport envelope. The host must validate it against every role
/// in the full message; supplying an address or origin reference is no grant.
final class CalendarFreeBusyIngress {
  const CalendarFreeBusyIngress({
    required this.mailbox,
    required this.namespace,
    required this.deliveryKey,
    required this.originRef,
    required this.payload,
  });
  final CalendarFreeBusyMailbox mailbox;
  final String namespace, deliveryKey, originRef, payload;
}

final class CalendarFreeBusyExchangePolicyContext {
  const CalendarFreeBusyExchangePolicyContext({
    required this.operation,
    required this.scopeKey,
    required this.ownerKey,
    this.mailbox,
    this.actor,
    this.calendar,
    this.message,
    this.sourceMessage,
    this.requestMessage,
    this.sourceId,
    this.commandId,
    this.payloadDigest,
    this.originRef,
    this.namespace,
    this.deliveryKey,
    this.isRetry = false,
    this.route,
  });
  final CalendarFreeBusyExchangeOperation operation;
  final CalendarFreeBusyMailbox? mailbox;
  final String scopeKey, ownerKey;
  final CalendarHostContext? actor;
  final CalendarPolicySnapshot? calendar;
  final IcalendarFreeBusyMessage? message, sourceMessage, requestMessage;
  final UuidValue? sourceId, commandId;
  final String? payloadDigest, originRef, namespace, deliveryKey;
  final bool isRetry;
  final CalendarSchedulingRoute? route;
}

abstract interface class CalendarFreeBusyExchangeHost {
  CalendarAuthorizationGuarantee get guarantee;

  Future<String> resolveOwner(
    Session session,
    CalendarHostContext actor,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );

  Future<CalendarFreeBusyMailbox> resolveMailbox(
    Session session,
    CalendarHostContext actor,
    UuidValue calendarId,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );

  /// Receipt checks every source organizer/respondent, local mailbox and actual
  /// trusted ingress route. Background calls have a null actor.
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarFreeBusyExchangePolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );

  /// Actor-free dispatch port: authorize the actual parent/read/export and each
  /// event/rule projection. These immutable requests are the same source
  /// snapshots used by the foreground policy; no saved grant is supplied.
  Future<CalendarAuthorizationVerdict> authorizeSources(
    Session session,
    CalendarFreeBusyExchangePolicyContext context,
    List<CalendarAuthorizationRequest> requests,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );

  Future<List<CalendarSchedulingRoute>> resolveRoutes(
    Session session,
    CalendarFreeBusyExchangePolicyContext context,
    List<String> addresses,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}

final class CalendarFreeBusyExchangeOptions {
  CalendarFreeBusyExchangeOptions({
    this.maxOwnerHeads = 128,
    this.maxScopeHeads = 4096,
    this.maxOwnerSources = 512,
    this.maxScopeSources = 8192,
    this.maxHeadVersions = 64,
    this.maxOwnerIngress = 1024,
    this.maxScopeIngress = 32768,
    this.maxOwnerCommands = 128,
    this.maxScopeCommands = 4096,
    this.maxOwnerReferences = 16384,
    this.maxScopeReferences = 262144,
    this.maxOwnerPendingDeliveries = 256,
    this.maxScopePendingDeliveries = 10000,
    this.maxOwnerBytes = 8388608,
    this.maxScopeBytes = 67108864,
    this.maxRecipients = 64,
    this.maxAttempts = 8,
    this.batchSize = 32,
    this.retention = const Duration(days: 30),
    this.reportExpiry = const Duration(minutes: 15),
    this.requestExpiry = const Duration(hours: 24),
    this.lease = const Duration(seconds: 120),
    this.transportTimeout = const Duration(seconds: 15),
    this.retryBase = const Duration(seconds: 30),
  }) {
    for (final pair in [
      (maxOwnerHeads, 128),
      (maxScopeHeads, 4096),
      (maxOwnerSources, 512),
      (maxScopeSources, 8192),
      (maxHeadVersions, 64),
      (maxOwnerIngress, 1024),
      (maxScopeIngress, 32768),
      (maxOwnerCommands, 128),
      (maxScopeCommands, 4096),
      (maxOwnerReferences, 16384),
      (maxScopeReferences, 262144),
      (maxOwnerPendingDeliveries, 256),
      (maxScopePendingDeliveries, 10000),
      (maxOwnerBytes, 8388608),
      (maxScopeBytes, 67108864),
      (maxRecipients, 64),
      (maxAttempts, 8),
      (batchSize, 32),
    ]) {
      RangeError.checkValueInInterval(pair.$1, 1, pair.$2);
    }
    if (retention <= Duration.zero ||
        retention > const Duration(days: 30) ||
        reportExpiry <= Duration.zero ||
        reportExpiry > const Duration(minutes: 15) ||
        requestExpiry <= Duration.zero ||
        requestExpiry > const Duration(hours: 24) ||
        transportTimeout <= Duration.zero ||
        transportTimeout > const Duration(seconds: 15) ||
        lease <= transportTimeout ||
        lease > const Duration(seconds: 120) ||
        retryBase <= Duration.zero ||
        retryBase > const Duration(seconds: 30)) {
      throw ArgumentError('Invalid free/busy exchange limits');
    }
  }
  final int maxOwnerHeads,
      maxScopeHeads,
      maxOwnerSources,
      maxScopeSources,
      maxHeadVersions,
      maxOwnerIngress,
      maxScopeIngress,
      maxOwnerCommands,
      maxScopeCommands,
      maxOwnerReferences,
      maxScopeReferences,
      maxOwnerPendingDeliveries,
      maxScopePendingDeliveries,
      maxOwnerBytes,
      maxScopeBytes,
      maxRecipients,
      maxAttempts,
      batchSize;
  final Duration retention,
      reportExpiry,
      requestExpiry,
      lease,
      transportTimeout,
      retryBase;
}

/// Optional private exchange execution, independent of ordinary busy queries,
/// authenticated file export and subscription feeds.
final class CalendarFreeBusyExchangeRuntime {
  CalendarFreeBusyExchangeRuntime({
    required this.host,
    required this.transport,
    CalendarFreeBusyExchangeOptions? options,
  }) : options = options ?? CalendarFreeBusyExchangeOptions();
  final CalendarFreeBusyExchangeHost host;
  final CalendarSchedulingTransport transport;
  final CalendarFreeBusyExchangeOptions options;
}
