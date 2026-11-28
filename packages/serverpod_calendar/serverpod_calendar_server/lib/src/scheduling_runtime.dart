import 'package:serverpod/serverpod.dart';

import 'calendar_authorization.dart';

/// Trusted routing result. Neither the stored reference nor address grants access.
final class CalendarSchedulingRoute {
  const CalendarSchedulingRoute(this.address, this.routeRef);
  final String address, routeRef;
}

final class CalendarSchedulingAuthority {
  CalendarSchedulingAuthority({
    required this.organizerAddress,
    required this.authorityRef,
    required Iterable<CalendarSchedulingRoute> routes,
  }) : routes = List.unmodifiable(routes);
  final String organizerAddress, authorityRef;
  final List<CalendarSchedulingRoute> routes;
}

/// Dedicated execution context; background work never fabricates a login.
final class CalendarSchedulingPolicyContext {
  const CalendarSchedulingPolicyContext({
    required this.scopeKey,
    required this.calendar,
    required this.currentEvent,
    required this.proposedEvent,
    required this.authority,
    required this.intent,
    this.actor,
    this.recipient,
  });
  final String scopeKey;
  final CalendarHostContext? actor;
  final CalendarPolicySnapshot calendar;
  final CalendarEventPolicySnapshot currentEvent, proposedEvent;
  final CalendarSchedulingAuthority authority;
  final CalendarSchedulingIntent intent;
  final CalendarSchedulingRoute? recipient;
}

abstract interface class CalendarSchedulingHost {
  CalendarAuthorizationGuarantee get guarantee;

  /// Resolve a verified organizer and approved routes; proposals are untrusted.
  Future<CalendarSchedulingAuthority> resolve(
    Session session,
    CalendarHostContext actor,
    CalendarEventPolicySnapshot current,
    List<String> recipientProposals,
    Transaction transaction,
  );

  /// Approve the exact payload and roster for every recipient. During background
  /// dispatch this also enforces current edit/detail/source/publication rights.
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarSchedulingPolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}

enum CalendarSchedulingTransportOutcome {
  accepted,
  transientFailure,
  permanentFailure,
  uncertain,
}

final class CalendarSchedulingTransportResult {
  const CalendarSchedulingTransportResult(this.outcome, {this.receipt});
  final CalendarSchedulingTransportOutcome outcome;
  final String? receipt;
}

final class CalendarSchedulingSubmission {
  const CalendarSchedulingSubmission({
    required this.deliveryKey,
    required this.publicationId,
    required this.scopeKey,
    required this.organizerAddress,
    required this.recipient,
    required this.payload,
  });
  final UuidValue deliveryKey, publicationId;
  final String scopeKey, organizerAddress, payload;
  final CalendarSchedulingRoute recipient;
}

abstract interface class CalendarSchedulingTransport {
  /// Stable deliveryKey survives retries. Acceptance is not receipt or display.
  Future<CalendarSchedulingTransportResult> submit(
    Session session,
    CalendarSchedulingSubmission submission,
  );
}

final class CalendarSchedulingOptions {
  CalendarSchedulingOptions({
    this.maxRecipients = 64,
    this.maxPayloadBytes = 524288,
    this.maxPendingPublications = 16,
    this.maxRetainedPublications = 256,
    this.maxScopeDeliveries = 10000,
    this.maxAttempts = 8,
    this.batchSize = 100,
    this.lease = const Duration(seconds: 120),
    this.transportTimeout = const Duration(seconds: 30),
    this.retryBase = const Duration(seconds: 30),
    this.expiry = const Duration(days: 7),
    this.retention = const Duration(days: 30),
  }) {
    RangeError.checkValueInInterval(maxRecipients, 1, 64);
    RangeError.checkValueInInterval(maxPayloadBytes, 1024, 524288);
    for (final n in [
      maxPendingPublications,
      maxRetainedPublications,
      maxScopeDeliveries,
    ]) {
      RangeError.checkValueInInterval(n, 1, 100000);
    }
    RangeError.checkValueInInterval(maxAttempts, 1, 32);
    RangeError.checkValueInInterval(batchSize, 1, 1000);
    if (maxRetainedPublications < maxPendingPublications ||
        transportTimeout < const Duration(seconds: 1) ||
        transportTimeout > const Duration(seconds: 30) ||
        lease <= transportTimeout ||
        lease > const Duration(hours: 1) ||
        retryBase < const Duration(seconds: 1) ||
        retryBase > const Duration(hours: 1) ||
        expiry < const Duration(seconds: 1) ||
        expiry > const Duration(days: 30) ||
        retention < const Duration(seconds: 1) ||
        retention > const Duration(days: 365)) {
      throw ArgumentError('Invalid scheduling limits');
    }
  }
  final int maxRecipients,
      maxPayloadBytes,
      maxPendingPublications,
      maxRetainedPublications,
      maxScopeDeliveries,
      maxAttempts,
      batchSize;
  final Duration lease, transportTimeout, retryBase, expiry, retention;
}

final class CalendarSchedulingRuntime {
  CalendarSchedulingRuntime({
    required this.host,
    required this.transport,
    CalendarSchedulingOptions? options,
  }) : options = options ?? CalendarSchedulingOptions();
  final CalendarSchedulingHost host;
  final CalendarSchedulingTransport transport;
  final CalendarSchedulingOptions options;
}
