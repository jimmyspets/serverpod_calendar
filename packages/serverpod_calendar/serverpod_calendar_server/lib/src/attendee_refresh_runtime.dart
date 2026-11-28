import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_authorization.dart';
import 'generated/protocol.dart';
import 'invitation_response_runtime.dart';
import 'invitation_runtime.dart';

enum CalendarAttendeeRefreshOperation { read, send, dispatch }

final class CalendarAttendeeRefreshContext {
  const CalendarAttendeeRefreshContext({
    required this.operation,
    required this.recipient,
    required this.invitation,
    this.actor,
    this.sourceId,
    this.sourceRevision,
    this.sourceDigest,
    this.sourceMessage,
    this.outgoingMessage,
    this.payloadDigest,
    this.authority,
    this.isRetry = false,
  });

  final CalendarAttendeeRefreshOperation operation;
  final CalendarInvitationRecipient recipient;
  final CalendarInvitationView invitation;
  final CalendarHostContext? actor;
  final UuidValue? sourceId;
  final int? sourceRevision;
  final String? sourceDigest, payloadDigest;
  final IcalendarSchedulingMessage? sourceMessage, outgoingMessage;
  final CalendarInvitationResponseAuthority? authority;
  final bool isRetry;
}

abstract interface class CalendarAttendeeRefreshHost {
  CalendarAuthorizationGuarantee get guarantee;

  Future<CalendarInvitationResponseAuthority> resolve(
    Session session,
    CalendarAttendeeRefreshContext context,
    Transaction transaction,
  );

  /// On actor-free dispatch, verify current private source disclosure, the
  /// attendee identity and the exact retained organizer route independently.
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarAttendeeRefreshContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  );
}

final class CalendarAttendeeRefreshRuntime {
  const CalendarAttendeeRefreshRuntime({
    required this.host,
    required this.transport,
  });

  final CalendarAttendeeRefreshHost host;
  final CalendarInvitationResponseTransport transport;
}
