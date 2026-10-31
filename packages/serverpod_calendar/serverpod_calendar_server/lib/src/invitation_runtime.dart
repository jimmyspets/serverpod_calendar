import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_authorization.dart';
import 'invitation_response_runtime.dart';
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
  receiveCancellation,
  receiveOccurrence,
  list,
  readSummary,
  readSource,
  dismiss,
  adopt,
  readLink,
  apply,
  applyCancellation,
  readApplication,
}

/// Original link source evidence, retained independently of a prunable body.
/// This is a trusted descriptor, never a reconstructed source document.
final class CalendarInvitationLinkSource {
  const CalendarInvitationLinkSource({
    required this.invitationId,
    required this.sourceId,
    required this.uid,
    required this.organizer,
    required this.digest,
    required this.sequence,
    required this.stamp,
  });
  final UuidValue invitationId, sourceId;
  final String uid, organizer, digest;
  final int? sequence;
  final DateTime stamp;
}

/// Current accepted source, distinct from the immutable creation descriptor.
final class CalendarInvitationApplicationState {
  const CalendarInvitationApplicationState({
    this.kind = CalendarInvitationSourceKind.request,
    required this.linkId,
    required this.revision,
    required this.invitationId,
    required this.sourceId,
    required this.digest,
    required this.sequence,
    required this.stamp,
    required this.baselineDigest,
    required this.eventRevision,
    required this.invitationRevision,
    required this.appliedAt,
    this.latestResult,
  });
  final CalendarInvitationSourceKind kind;
  final UuidValue linkId, invitationId, sourceId;
  final int revision, eventRevision, invitationRevision;
  final String digest, baselineDigest;
  final int? sequence;
  final DateTime stamp, appliedAt;
  final CalendarInvitationApplyReceipt? latestResult;
}

enum CalendarInvitationOccurrenceBasisKind { retainedMaster, acceptedBaseline }

/// Actual trusted admission evidence, never reconstructed source bytes.
final class CalendarInvitationOccurrenceBasis {
  const CalendarInvitationOccurrenceBasis({
    required this.kind,
    required this.originalStart,
    required this.content,
    required this.sequence,
    required this.stamp,
    this.master,
    this.message,
    this.sourceId,
    this.link,
    this.accepted,
    this.baseline,
  });
  final CalendarInvitationOccurrenceBasisKind kind;
  final CalendarEventTiming originalStart;
  final CalendarEventContent content;
  final int? sequence;
  final DateTime stamp;
  final CalendarInvitationView? master;
  final IcalendarSchedulingMessage? message;
  final UuidValue? sourceId;
  final CalendarInvitationAdoptionReceipt? link;
  final CalendarInvitationApplicationState? accepted;
  final CalendarEventImportBaseline? baseline;
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
    this.adoptionRequest,
    this.link,
    this.linkSource,
    this.calendar,
    this.currentEvent,
    this.proposedEvent,
    this.historicalSourceUnavailable,
    this.applyRequest,
    this.currentApplication,
    this.proposedApplication,
    this.applicationReceipt,
    this.proposedBaseline,
    this.localChanges,
    this.linkedEventUnavailable,
    this.occurrenceBasis,
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
  final CalendarInvitationAdoptionRequest? adoptionRequest;
  final CalendarInvitationAdoptionReceipt? link;
  final CalendarInvitationLinkSource? linkSource;
  final CalendarPolicySnapshot? calendar;
  final CalendarEventPolicySnapshot? currentEvent, proposedEvent;

  /// True only when the original retained body is actually unavailable.
  final bool? historicalSourceUnavailable;
  final CalendarInvitationApplyRequest? applyRequest;
  final CalendarInvitationApplicationState? currentApplication,
      proposedApplication;
  final CalendarInvitationApplyReceipt? applicationReceipt;
  final CalendarEventImportBaseline? proposedBaseline;
  final bool? localChanges;
  final bool? linkedEventUnavailable;
  final CalendarInvitationOccurrenceBasis? occurrenceBasis;

  CalendarInvitationPolicyContext forOperation(
    CalendarInvitationOperation value,
  ) => CalendarInvitationPolicyContext(
    operation: value,
    recipient: recipient,
    actor: actor,
    delivery: delivery,
    message: message,
    normalizedSource: normalizedSource,
    sourceDigest: sourceDigest,
    current: current,
    proposedOutcome: proposedOutcome,
    proposedRevision: proposedRevision,
    proposedDismissed: proposedDismissed,
    entryId: entryId,
    sourceId: sourceId,
    receiptId: receiptId,
    isRetry: isRetry,
    receipt: receipt,
    adoptionRequest: adoptionRequest,
    link: link,
    linkSource: linkSource,
    calendar: calendar,
    currentEvent: currentEvent,
    proposedEvent: proposedEvent,
    historicalSourceUnavailable: historicalSourceUnavailable,
    applyRequest: applyRequest,
    currentApplication: currentApplication,
    proposedApplication: proposedApplication,
    applicationReceipt: applicationReceipt,
    proposedBaseline: proposedBaseline,
    localChanges: localChanges,
    linkedEventUnavailable: linkedEventUnavailable,
    occurrenceBasis: occurrenceBasis,
  );
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
    this.maxLinks = 1024,
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
      (maxLinks, 1024),
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
      maxReceipts,
      maxLinks;
  final Duration terminalRetention;
}

final class CalendarInvitationRuntime {
  CalendarInvitationRuntime({
    required this.host,
    this.responses,
    CalendarInvitationOptions? options,
  }) : options = options ?? CalendarInvitationOptions();
  final CalendarInvitationHost host;
  final CalendarInvitationResponseRuntime? responses;
  final CalendarInvitationOptions options;
}
