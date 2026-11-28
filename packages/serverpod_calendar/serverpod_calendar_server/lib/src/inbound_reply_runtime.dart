import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_authorization.dart';
import 'generated/protocol.dart';

/// A server-only invocation, not a generated RPC or proof of sender identity.
/// The installed host must verify originReference for this actual binding and
/// exact attendee. Evidence and delivery keys are never copied into source data.
final class CalendarSchedulingReplyDelivery {
  CalendarSchedulingReplyDelivery({
    required this.scopeKey,
    required this.eventId,
    required this.namespace,
    required this.deliveryKey,
    required this.originReference,
    required Uint8List bytes,
  }) : bytes = _copy(bytes);
  static Uint8List _copy(Uint8List input) {
    if (input.length > 524288) {
      throw ArgumentError('Reply source exceeds limit');
    }
    return Uint8List.fromList(input).asUnmodifiableView();
  }

  final String scopeKey, namespace, deliveryKey, originReference;
  final UuidValue eventId;
  final Uint8List bytes;
}

/// Complete immutable context; sender claims are data until the host approves.
final class CalendarSchedulingReplyPolicyContext {
  const CalendarSchedulingReplyPolicyContext({
    required this.delivery,
    required this.calendar,
    required this.currentEvent,
    required this.publishedEvent,
    required this.publishedSequence,
    required this.publishedCancelled,
    required this.message,
    required this.normalizedSource,
    required this.sourceDigest,
    this.currentResponse,
    this.proposedOutcome,
    this.sourceId,
    this.receiptId,
    this.isRetry = false,
  });
  final CalendarSchedulingReplyDelivery delivery;
  final CalendarPolicySnapshot calendar;
  final CalendarEventPolicySnapshot currentEvent, publishedEvent;
  final int publishedSequence;
  final bool publishedCancelled;
  final IcalendarSchedulingMessage message;
  final String normalizedSource, sourceDigest;

  /// Absent only before origin approval/history lookup; later checks carry an
  /// actual current or unknown descriptor, including retained receipt retries.
  final CalendarSchedulingAttendeeResponseView? currentResponse;
  final CalendarSchedulingReplyOutcome? proposedOutcome;
  final UuidValue? sourceId, receiptId;
  final bool isRetry;
}

abstract interface class CalendarSchedulingReplyHost {
  CalendarAuthorizationGuarantee get guarantee;

  /// Verify actual origin/role for the exact stored roster address. The source
  /// ATTENDEE, SMTP headers or an authenticated display address are insufficient.
  /// A final check occurs inside the transaction after proposed writes, so a
  /// denial or unavailable result rolls back source, receipt and response.
  Future<CalendarAuthorizationVerdict> authorizeReply(
    Session session,
    CalendarSchedulingReplyPolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}

final class CalendarSchedulingReplyOptions {
  CalendarSchedulingReplyOptions({
    this.maxSourceBytes = 524288,
    this.maxSourcesPerBinding = 256,
    this.maxReceiptsPerBinding = 1024,
    this.maxSourcesPerScope = 4096,
    this.maxReceiptsPerScope = 8192,
    this.cleanupBatch = 100,
    this.retention = const Duration(days: 30),
  }) {
    RangeError.checkValueInInterval(maxSourceBytes, 1024, 524288);
    // Public metadata lists remain bounded without a new cursor contract.
    RangeError.checkValueInInterval(maxSourcesPerBinding, 1, 256);
    RangeError.checkValueInInterval(maxReceiptsPerBinding, 1, 1024);
    RangeError.checkValueInInterval(
      maxSourcesPerScope,
      maxSourcesPerBinding,
      100000,
    );
    RangeError.checkValueInInterval(
      maxReceiptsPerScope,
      maxReceiptsPerBinding,
      100000,
    );
    RangeError.checkValueInInterval(cleanupBatch, 1, 1000);
    if (retention < const Duration(seconds: 1) ||
        retention > const Duration(days: 365)) {
      throw ArgumentError('Invalid reply retention');
    }
  }
  final int maxSourceBytes,
      maxSourcesPerBinding,
      maxReceiptsPerBinding,
      maxSourcesPerScope,
      maxReceiptsPerScope,
      cleanupBatch;
  final Duration retention;
}

final class CalendarSchedulingReplyRuntime {
  CalendarSchedulingReplyRuntime({
    required this.host,
    CalendarSchedulingReplyOptions? options,
  }) : options = options ?? CalendarSchedulingReplyOptions();
  final CalendarSchedulingReplyHost host;
  final CalendarSchedulingReplyOptions options;
}
