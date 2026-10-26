import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

/// Local demo authority only. Synthetic addresses never establish a real mailbox.
final class DemoSchedulingHost implements CalendarSchedulingHost {
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;
  bool _synthetic(String address) =>
      RegExp(r'^mailto:[A-Za-z0-9._+\-]+@example\.invalid$').hasMatch(address);
  String _organizer(String id) => 'mailto:calendar-$id@example.invalid';

  Future<bool> _active(
    Session session,
    String scope,
    String ref,
    Transaction tx,
  ) async {
    if (scope != ref || !scope.startsWith('demo:user:')) return false;
    final id = scope.substring('demo:user:'.length);
    final user = await AuthUser.db.findById(
      session,
      UuidValue.fromString(id),
      transaction: tx,
    );
    return user != null && !user.blocked;
  }

  @override
  Future<CalendarSchedulingAuthority> resolve(
    Session session,
    CalendarHostContext actor,
    CalendarEventPolicySnapshot current,
    List<String> recipientProposals,
    Transaction transaction,
  ) async {
    if (actor.scopeKey != 'demo:user:${actor.principalId}' ||
        !await _active(session, actor.scopeKey, actor.scopeKey, transaction) ||
        recipientProposals.any((r) => !_synthetic(r))) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Scheduling denied',
      );
    }
    return CalendarSchedulingAuthority(
      organizerAddress: _organizer(actor.principalId),
      authorityRef: actor.scopeKey,
      routes: recipientProposals.map((r) => CalendarSchedulingRoute(r, r)),
    );
  }

  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarSchedulingPolicyContext context,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    if (!await _active(
          session,
          context.scopeKey,
          context.authority.authorityRef,
          transaction,
        ) ||
        context.actor != null && context.actor!.scopeKey != context.scopeKey ||
        context.authority.organizerAddress !=
            _organizer(context.scopeKey.substring('demo:user:'.length)) ||
        context.authority.routes.any(
          (r) => !_synthetic(r.address) || r.routeRef != r.address,
        ) ||
        !{'REQUEST', 'CANCEL'}.contains(context.intent.method) ||
        context.intent.organizerAddress != context.authority.organizerAddress ||
        context.currentEvent.eventId != context.proposedEvent.eventId ||
        context.currentEvent.calendarId != context.proposedEvent.calendarId ||
        context.currentEvent.eventId != context.outgoingEvent.eventId ||
        context.currentEvent.calendarId != context.outgoingEvent.calendarId) {
      return CalendarAuthorizationVerdict.deny;
    }
    // Private-user demo grants all event detail/source/publication operations
    // while the owner is active. Production hosts replace this complete check.
    return CalendarAuthorizationVerdict.allow;
  }
}

/// Recording only: no SMTP/MIME/mobile provider and no body in application logs.
final class DemoSchedulingTransport implements CalendarSchedulingTransport {
  @override
  Future<CalendarSchedulingTransportResult> submit(
    Session session,
    CalendarSchedulingSubmission submission,
  ) async {
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        !submission.recipient.address.endsWith('@example.invalid')) {
      return const CalendarSchedulingTransportResult(
        CalendarSchedulingTransportOutcome.permanentFailure,
      );
    }
    final file = File(
      '../../../.local/scheduling-mail/${submission.deliveryKey}-${Uuid().v4obj()}.json',
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'deliveryKey': submission.deliveryKey.toString(),
        'publicationId': submission.publicationId.toString(),
        'scope': submission.scopeKey,
        'organizer': submission.organizerAddress,
        'recipient': submission.recipient.address,
        'payload': submission.payload,
      }),
      flush: true,
    );
    return CalendarSchedulingTransportResult(
      CalendarSchedulingTransportOutcome.accepted,
      receipt: 'synthetic:${submission.deliveryKey}',
    );
  }
}
