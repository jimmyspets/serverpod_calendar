import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'invitation_response_mime.dart';
import 'scheduling_mime.dart';

/// Current synthetic recipient proof only; production hosts replace this policy.
final class DemoInvitationResponseHost
    implements CalendarInvitationResponseHost {
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  Future<bool> _allowed(
    Session session,
    CalendarInvitationResponsePolicyContext c,
    Transaction tx,
  ) async {
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        c.recipient.scopeKey != 'demo:user:${c.recipient.key}' ||
        c.recipient.calendarAddress !=
            'mailto:demo-${c.recipient.key}@example.invalid' ||
        c.invitation.organizer != 'mailto:organizer@example.invalid' ||
        !c.invitation.uid.startsWith(
          'synthetic-invitation:${c.recipient.key}:',
        )) {
      return false;
    }
    UuidValue id;
    try {
      id = UuidValue.fromString(c.recipient.key);
    } catch (_) {
      return false;
    }
    final user = await AuthUser.db.findById(session, id, transaction: tx);
    if (user == null || user.blocked) return false;
    if (c.actor != null &&
        (c.actor!.principalId != c.recipient.key ||
            c.actor!.scopeKey != c.recipient.scopeKey)) {
      return false;
    }
    if (c.actor == null &&
        c.operation != CalendarInvitationResponseOperation.dispatch) {
      return false;
    }
    if (c.operation != CalendarInvitationResponseOperation.read) {
      final source = c.sourceMessage,
          outgoing = c.outgoingMessage,
          authority = c.authority;
      if (source == null ||
          outgoing == null ||
          authority == null ||
          source.method != IcalendarSchedulingMethod.request ||
          !source.events.single.participants.attendees.any(
            (a) => a.address == c.recipient.calendarAddress,
          ) ||
          outgoing.method != IcalendarSchedulingMethod.reply ||
          outgoing.uid != c.invitation.uid ||
          outgoing.events.single.participants.attendees.single.address !=
              c.recipient.calendarAddress ||
          outgoing.events.single.participants.organizer?.address !=
              c.invitation.organizer ||
          authority.attendeeAddress != c.recipient.calendarAddress ||
          authority.authorityRef != 'demo-recipient:${c.recipient.key}' ||
          authority.organizer.address != c.invitation.organizer ||
          authority.organizer.routeRef != 'demo-organizer:${c.recipient.key}' ||
          sha256
                  .convert(serializeIcalendarSyntax(outgoing.source))
                  .toString() !=
              c.payloadDigest) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<CalendarInvitationResponseAuthority> resolve(
    Session session,
    CalendarInvitationResponsePolicyContext context,
    Transaction transaction,
  ) async {
    if (!await _allowed(session, context, transaction)) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Response access denied.',
      );
    }
    return CalendarInvitationResponseAuthority(
      attendeeAddress: context.recipient.calendarAddress,
      authorityRef: 'demo-recipient:${context.recipient.key}',
      organizer: CalendarSchedulingRoute(
        context.invitation.organizer,
        'demo-organizer:${context.recipient.key}',
      ),
    );
  }

  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarInvitationResponsePolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async => await _allowed(session, context, transaction)
      ? CalendarAuthorizationVerdict.allow
      : CalendarAuthorizationVerdict.deny;
}

/// Synthetic attempt recording only. Stable reply identity survives retries;
/// provider acceptance is not remote receipt or application.
final class DemoInvitationResponseTransport
    implements CalendarInvitationResponseTransport {
  @override
  Future<CalendarSchedulingTransportResult> submit(
    Session session,
    CalendarInvitationResponseSubmission submission,
  ) async {
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        !isSyntheticSchedulingMailbox(submission.attendeeAddress) ||
        !isSyntheticSchedulingMailbox(submission.organizer.address)) {
      return const CalendarSchedulingTransportResult(
        CalendarSchedulingTransportOutcome.permanentFailure,
      );
    }
    String mime;
    try {
      mime = composeSyntheticInvitationResponseMime(
        submission,
        requireProtection: false,
      );
    } on SyntheticSchedulingMimeException catch (e) {
      return CalendarSchedulingTransportResult(
        e.kind == SyntheticSchedulingMimeError.unavailable
            ? CalendarSchedulingTransportOutcome.transientFailure
            : CalendarSchedulingTransportOutcome.permanentFailure,
      );
    }
    final file = File(
      '../../../.local/attendee-response-mail/${submission.deliveryKey}-${const Uuid().v4obj()}.json',
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'deliveryKey': submission.deliveryKey.toString(),
        'scope': submission.scopeKey,
        'attendee': submission.attendeeAddress,
        'organizer': submission.organizer.address,
        'payload': submission.payload,
        'payloadDigest': sha256
            .convert(utf8.encode(submission.payload))
            .toString(),
        'mime': mime,
      }),
      flush: true,
    );
    return CalendarSchedulingTransportResult(
      CalendarSchedulingTransportOutcome.accepted,
      receipt: 'synthetic-reply:${submission.deliveryKey}',
    );
  }
}
