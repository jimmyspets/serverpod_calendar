import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

/// Synthetic transport only. Production hosts replace origin verification.
final class DemoInvitationHost implements CalendarInvitationHost {
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  CalendarInvitationRecipient _recipient(Session session) {
    final user = session.authenticated?.userIdentifier;
    if (user == null) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Invitation access denied',
      );
    }
    return CalendarInvitationRecipient(
      scopeKey: 'demo:user:$user',
      key: user,
      calendarAddress: 'mailto:demo-$user@example.invalid',
    );
  }

  @override
  Future<CalendarInvitationRecipient> resolveDelivery(
    Session session,
    CalendarInvitationDelivery delivery,
    IcalendarSchedulingMessage message,
  ) async {
    final recipient = _recipient(session);
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        delivery.namespace != 'example.invitation' ||
        delivery.originReference != 'synthetic:${recipient.key}' ||
        message.events.single.participants.organizer?.address !=
            'mailto:organizer@example.invalid' ||
        !message.uid.startsWith('synthetic-invitation:${recipient.key}:')) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Invitation access denied',
      );
    }
    return recipient;
  }

  @override
  Future<CalendarInvitationRecipient> resolveCurrent(
    Session session,
    CalendarHostContext actor,
    Transaction tx,
  ) async => _recipient(session);
  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarInvitationPolicyContext context,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    final recipient = _recipient(session);
    final user = await AuthUser.db.findById(
      session,
      UuidValue.fromString(recipient.key),
      transaction: tx,
    );
    if (user == null || user.blocked || !recipient.same(context.recipient)) {
      return CalendarAuthorizationVerdict.deny;
    }
    if ({
      CalendarInvitationOperation.receive,
      CalendarInvitationOperation.receiveCancellation,
      CalendarInvitationOperation.receiveOccurrence,
    }.contains(context.operation)) {
      final resolved = await resolveDelivery(
        session,
        context.delivery!,
        context.message!,
      );
      if (!resolved.same(context.recipient)) {
        return CalendarAuthorizationVerdict.deny;
      }
    } else if (context.actor?.principalId != recipient.key ||
        context.actor?.scopeKey != recipient.scopeKey) {
      return CalendarAuthorizationVerdict.deny;
    }
    if (context.operation == CalendarInvitationOperation.adopt ||
        {
          CalendarInvitationOperation.readLink,
          CalendarInvitationOperation.apply,
          CalendarInvitationOperation.applyCancellation,
          CalendarInvitationOperation.readApplication,
        }.contains(context.operation)) {
      final message = context.message;
      if (message != null &&
          (message.events.single.participants.organizer?.address !=
                  'mailto:organizer@example.invalid' ||
              !message.uid.startsWith(
                'synthetic-invitation:${recipient.key}:',
              ) ||
              !message.events.single.participants.attendees.any(
                (a) => a.address == recipient.calendarAddress,
              ))) {
        return CalendarAuthorizationVerdict.deny;
      }
      if (context.historicalSourceUnavailable == true &&
          (context.linkSource?.uid != context.currentEvent?.protocolUid ||
              context.linkSource?.organizer !=
                  'mailto:organizer@example.invalid' ||
              context.currentEvent?.protocolUid.startsWith(
                    'synthetic-invitation:${recipient.key}:',
                  ) !=
                  true ||
              context
                      .currentEvent
                      ?.protocolState
                      ?.sourceMetadata
                      ?.organizer
                      ?.address !=
                  'mailto:organizer@example.invalid')) {
        return CalendarAuthorizationVerdict.deny;
      }
    }
    return CalendarAuthorizationVerdict.allow;
  }
}
