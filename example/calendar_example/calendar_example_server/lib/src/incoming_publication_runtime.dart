import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

/// Development/test provider fixture only; not production mailbox verification.
final class DemoIncomingPublicationHost
    implements CalendarIncomingPublicationHost {
  bool _supportedClaims(IcalendarSchedulingMessage message) =>
      message.events.isNotEmpty &&
      message.events.length <= 65 &&
      message.events.every(
        (event) =>
            event.participants.organizer?.address ==
                'mailto:publisher@example.invalid' &&
            event.participants.organizer?.sentBy == null &&
            event.participants.attendees.isEmpty,
      );
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  CalendarIncomingPublicationRecipient _recipient(Session session) {
    final id = session.authenticated?.userIdentifier;
    if (id == null) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Publication access denied',
      );
    }
    return CalendarIncomingPublicationRecipient(
      scopeKey: 'demo:user:$id',
      key: id,
      calendarAddress: 'mailto:demo-$id@example.invalid',
    );
  }

  @override
  Future<CalendarIncomingPublicationRecipient> resolveDelivery(
    Session session,
    CalendarIncomingPublicationDelivery delivery,
    IcalendarSchedulingMessage message,
  ) async {
    final recipient = _recipient(session);
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        delivery.namespace != 'example.publication' ||
        delivery.originReference != 'synthetic:${recipient.key}' ||
        !message.uid.startsWith('synthetic-publication:${recipient.key}:') ||
        !_supportedClaims(message)) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Publication access denied',
      );
    }
    return recipient;
  }

  @override
  Future<CalendarIncomingPublicationRecipient> resolveRecipient(
    Session session,
    CalendarHostContext actor,
  ) async {
    final recipient = _recipient(session);
    if (actor.principalId != recipient.key ||
        actor.scopeKey != recipient.scopeKey) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Publication access denied',
      );
    }
    return recipient;
  }

  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarIncomingPublicationPolicyContext context,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    final recipient = _recipient(session);
    final user = await AuthUser.db.findById(
      session,
      UuidValue.fromString(recipient.key),
      transaction: tx,
    );
    if (user == null ||
        user.blocked ||
        !recipient.same(context.recipient) ||
        context.actor != null &&
            (context.actor!.principalId != recipient.key ||
                context.actor!.scopeKey != recipient.scopeKey)) {
      return CalendarAuthorizationVerdict.deny;
    }
    if (context.delivery != null) {
      final actual = await resolveDelivery(
        session,
        context.delivery!,
        context.source!,
      );
      if (!actual.same(recipient)) return CalendarAuthorizationVerdict.deny;
    }
    for (final message in [
      context.source,
      context.sourceBasis,
      context.acceptedBasis,
    ]) {
      if (message != null &&
          (!message.uid.startsWith('synthetic-publication:${recipient.key}:') ||
              !_supportedClaims(message))) {
        return CalendarAuthorizationVerdict.deny;
      }
    }
    if (context.calendar != null) {
      final identity = await CalendarIdentityRecord.db.findById(
        session,
        context.calendar!.calendarId,
        transaction: tx,
      );
      if (identity == null || identity.scopeKey != recipient.scopeKey) {
        return CalendarAuthorizationVerdict.deny;
      }
    }
    return CalendarAuthorizationVerdict.allow;
  }
}
