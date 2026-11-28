import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import 'calendar_authorization.dart';
import 'scheduling_runtime.dart';

/// Host-resolved delivery metadata and decoded REFRESH calendar bytes.
final class CalendarRefreshDelivery {
  CalendarRefreshDelivery({
    required this.scopeKey,
    required this.eventId,
    required this.namespace,
    required this.deliveryKey,
    required this.originReference,
    required Uint8List bytes,
  }) : bytes = _copy(bytes);

  static Uint8List _copy(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > 32768) {
      throw ArgumentError('Invalid REFRESH size');
    }
    return Uint8List.fromList(bytes).asUnmodifiableView();
  }

  final UuidValue eventId;
  final String scopeKey, namespace, deliveryKey, originReference;
  final Uint8List bytes;
}

/// The host independently verifies the origin and the exact claimed attendee.
abstract interface class CalendarRefreshHost {
  CalendarAuthorizationGuarantee get guarantee;

  Future<CalendarAuthorizationVerdict> authorizeReceipt(
    Session session,
    CalendarRefreshDelivery delivery,
    CalendarEventPolicySnapshot event,
    String attendeeAddress,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );

  /// Check current organizer/source disclosure and the approved requester route.
  /// At dispatch the actor is absent and the stored route needs fresh approval.
  Future<CalendarAuthorizationVerdict> authorizeResend(
    Session session,
    CalendarSchedulingPolicyContext context,
    String originReference,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}
