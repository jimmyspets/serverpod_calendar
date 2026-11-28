import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_authorization.dart';
import 'generated/protocol.dart';
import 'invitation_runtime.dart';
import 'scheduling_runtime.dart';

enum CalendarInvitationResponseOperation { read, send, dispatch }

final class CalendarInvitationResponseAuthority {
  const CalendarInvitationResponseAuthority({
    required this.attendeeAddress,
    required this.authorityRef,
    required this.organizer,
  });
  final String attendeeAddress, authorityRef;
  final CalendarSchedulingRoute organizer;
}

/// Immutable actual invitation/source and independent personal response state.
/// Background dispatch has no actor; the host must revalidate the real recipient.
final class CalendarInvitationResponsePolicyContext {
  const CalendarInvitationResponsePolicyContext({
    required this.operation,
    required this.recipient,
    required this.invitation,
    required this.currentState,
    this.actor,
    this.sourceId,
    this.sourceRevision,
    this.sourceDigest,
    this.sourceMessage,
    this.proposedState,
    this.request,
    this.receipt,
    this.outgoingMessage,
    this.payloadDigest,
    this.authority,
    this.isRetry = false,
  });
  final CalendarInvitationResponseOperation operation;
  final CalendarInvitationRecipient recipient;
  final CalendarHostContext? actor;
  final CalendarInvitationView invitation;
  final CalendarInvitationResponseView currentState;
  final UuidValue? sourceId;
  final int? sourceRevision;
  final String? sourceDigest;
  final IcalendarSchedulingMessage? sourceMessage, outgoingMessage;
  final CalendarInvitationResponseView? proposedState;
  final CalendarInvitationResponseRequest? request;
  final CalendarInvitationResponseReceipt? receipt;
  final String? payloadDigest;
  final CalendarInvitationResponseAuthority? authority;
  final bool isRetry;
}

abstract interface class CalendarInvitationResponseHost {
  CalendarAuthorizationGuarantee get guarantee;

  /// Resolve a verified attendee and approved organizer route, independently of
  /// source claims. Called only for a new explicit command, never to retarget work.
  Future<CalendarInvitationResponseAuthority> resolve(
    Session session,
    CalendarInvitationResponsePolicyContext context,
    Transaction transaction,
  );

  /// Includes current raw-source/read/send rights, identity and route on dispatch.
  /// The worker supplies no fabricated login or actor. Denial withdraws work;
  /// unavailable policy remains bounded retryable work.
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarInvitationResponsePolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}

final class CalendarInvitationResponseSubmission {
  const CalendarInvitationResponseSubmission({
    required this.deliveryKey,
    required this.scopeKey,
    required this.attendeeAddress,
    required this.organizer,
    required this.payload,
  });
  final UuidValue deliveryKey;
  final String scopeKey, attendeeAddress, payload;
  final CalendarSchedulingRoute organizer;
}

abstract interface class CalendarInvitationResponseTransport {
  Future<CalendarSchedulingTransportResult> submit(
    Session session,
    CalendarInvitationResponseSubmission submission,
  );
}

final class CalendarInvitationResponseOptions {
  CalendarInvitationResponseOptions({
    this.maxStatesPerRecipient = 128,
    this.maxStatesPerScope = 4096,
    this.maxResponsesPerState = 32,
    this.maxResponsesPerRecipient = 512,
    this.maxResponsesPerScope = 4096,
    this.maxPendingPerRecipient = 16,
    this.maxPayloadBytes = 32768,
    this.maxRecipientPayloadBytes = 8388608,
    this.maxScopePayloadBytes = 67108864,
    this.maxAttempts = 8,
    this.batchSize = 100,
    this.lease = const Duration(seconds: 120),
    this.transportTimeout = const Duration(seconds: 30),
    this.retryBase = const Duration(seconds: 30),
    this.expiry = const Duration(days: 7),
    this.retention = const Duration(days: 30),
  }) {
    for (final (value, cap) in [
      (maxStatesPerRecipient, 128),
      (maxStatesPerScope, 4096),
      (maxResponsesPerState, 32),
      (maxResponsesPerRecipient, 512),
      (maxResponsesPerScope, 4096),
      (maxPendingPerRecipient, 16),
      (maxPayloadBytes, 32768),
      (maxRecipientPayloadBytes, 8388608),
      (maxScopePayloadBytes, 67108864),
      (maxAttempts, 32),
      (batchSize, 100),
    ]) {
      if (value < 1 || value > cap) {
        throw ArgumentError('Invalid response limit');
      }
    }
    if (transportTimeout < const Duration(seconds: 1) ||
        transportTimeout > const Duration(seconds: 30) ||
        lease <= transportTimeout ||
        lease > const Duration(hours: 1) ||
        retryBase < const Duration(seconds: 1) ||
        retryBase > const Duration(hours: 1) ||
        expiry < const Duration(seconds: 1) ||
        expiry > const Duration(days: 30) ||
        retention <= Duration.zero ||
        retention > const Duration(days: 365)) {
      throw ArgumentError('Invalid response worker configuration');
    }
  }
  final int maxStatesPerRecipient,
      maxStatesPerScope,
      maxResponsesPerState,
      maxResponsesPerRecipient,
      maxResponsesPerScope,
      maxPendingPerRecipient,
      maxPayloadBytes,
      maxRecipientPayloadBytes,
      maxScopePayloadBytes,
      maxAttempts,
      batchSize;
  final Duration lease, transportTimeout, retryBase, expiry, retention;
}

final class CalendarInvitationResponseRuntime {
  CalendarInvitationResponseRuntime({
    required this.host,
    required this.transport,
    CalendarInvitationResponseOptions? options,
  }) : options = options ?? CalendarInvitationResponseOptions();
  final CalendarInvitationResponseHost host;
  final CalendarInvitationResponseTransport transport;
  final CalendarInvitationResponseOptions options;
}
