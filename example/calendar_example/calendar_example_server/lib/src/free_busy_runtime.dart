import 'package:crypto/crypto.dart';

import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

import 'free_busy_mime.dart';
import 'scheduling_mime.dart';

/// Private-user synthetic example. Production hosts replace mailbox and origin
/// verification; a calendar-specific address never claims person-wide coverage.
final class DemoFreeBusyHost implements CalendarFreeBusyExchangeHost {
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;

  String address(UuidValue calendar) =>
      'mailto:busy-${sha256.convert(utf8.encode('example-freebusy-mailbox:$calendar')).toString().substring(0, 32)}@example.invalid';
  Future<bool> _active(
    Session session,
    String scope,
    String owner,
    Transaction tx,
  ) async {
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        scope != 'demo:user:$owner') {
      return false;
    }
    try {
      final user = await AuthUser.db.findById(
        session,
        UuidValue.fromString(owner),
        transaction: tx,
      );
      return user != null && !user.blocked;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> resolveOwner(
    Session session,
    CalendarHostContext actor,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (!await _active(session, actor.scopeKey, actor.principalId, tx)) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Busy exchange denied',
      );
    }
    return actor.principalId;
  }

  @override
  Future<CalendarFreeBusyMailbox> resolveMailbox(
    Session session,
    CalendarHostContext actor,
    UuidValue calendarId,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    final owner = await resolveOwner(session, actor, tx, phase);
    final identity = await CalendarIdentityRecord.db.findById(
      session,
      calendarId,
      transaction: tx,
    );
    if (identity == null ||
        identity.deletedAt != null ||
        identity.scopeKey != actor.scopeKey) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Busy exchange denied',
      );
    }
    return CalendarFreeBusyMailbox(
      scopeKey: actor.scopeKey,
      ownerKey: owner,
      calendarId: calendarId,
      address: address(calendarId),
      bindingRef: 'calendar:$calendarId',
    );
  }

  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarFreeBusyExchangePolicyContext c,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (!await _active(session, c.scopeKey, c.ownerKey, tx) ||
        c.actor != null &&
            (c.actor!.scopeKey != c.scopeKey ||
                c.actor!.principalId != c.ownerKey)) {
      return CalendarAuthorizationVerdict.deny;
    }
    final mailbox = c.mailbox;
    if (mailbox != null) {
      final identity = await CalendarIdentityRecord.db.findById(
        session,
        mailbox.calendarId,
        transaction: tx,
      );
      if (mailbox.scopeKey != c.scopeKey ||
          mailbox.ownerKey != c.ownerKey ||
          mailbox.address != address(mailbox.calendarId) ||
          mailbox.bindingRef != 'calendar:${mailbox.calendarId}' ||
          identity == null ||
          identity.scopeKey != c.scopeKey) {
        return CalendarAuthorizationVerdict.deny;
      }
      if (identity.deletedAt != null &&
          !c.isRetry &&
          !{
            CalendarFreeBusyExchangeOperation.readHeader,
            CalendarFreeBusyExchangeOperation.readSource,
            CalendarFreeBusyExchangeOperation.dismiss,
          }.contains(c.operation)) {
        return CalendarAuthorizationVerdict.deny;
      }
    }
    final incoming = {
      CalendarFreeBusyExchangeOperation.receivePublish,
      CalendarFreeBusyExchangeOperation.receiveRequest,
      CalendarFreeBusyExchangeOperation.receiveReply,
    }.contains(c.operation);
    if (incoming) {
      if (mailbox == null ||
          c.message == null ||
          c.namespace != 'example.freebusy' ||
          c.originRef != 'synthetic-freebusy:${c.ownerKey}') {
        return CalendarAuthorizationVerdict.deny;
      }
      if (c.operation == CalendarFreeBusyExchangeOperation.receiveReply &&
          phase == CalendarAuthorizationPhase.finalWrite &&
          !c.isRetry &&
          (c.requestMessage == null ||
              c.route == null ||
              c.route!.address !=
                  c.message!.components.single.attendees.single)) {
        return CalendarAuthorizationVerdict.deny;
      }
      for (final part in c.message!.components) {
        final origin = c.message!.method == IcalendarFreeBusyMethod.reply
            ? part.attendees.single
            : part.organizer.address;
        final expected = switch (c.message!.method) {
          IcalendarFreeBusyMethod.publish => 'mailto:publisher@example.invalid',
          IcalendarFreeBusyMethod.request => 'mailto:requester@example.invalid',
          IcalendarFreeBusyMethod.reply => 'mailto:respondent@example.invalid',
        };
        if (origin != expected ||
            !isSyntheticSchedulingMailbox(part.organizer.address) ||
            part.attendees.any((a) => !isSyntheticSchedulingMailbox(a)) ||
            c.message!.method == IcalendarFreeBusyMethod.request &&
                !part.attendees.contains(mailbox.address) ||
            c.message!.method == IcalendarFreeBusyMethod.reply &&
                part.organizer.address != mailbox.address) {
          return CalendarAuthorizationVerdict.deny;
        }
      }
    }
    if (c.route != null &&
        (!isSyntheticSchedulingMailbox(c.route!.address) ||
            c.route!.routeRef != c.route!.address)) {
      return CalendarAuthorizationVerdict.deny;
    }
    if (c.message != null &&
        !incoming &&
        {
          CalendarFreeBusyExchangeOperation.publish,
          CalendarFreeBusyExchangeOperation.request,
          CalendarFreeBusyExchangeOperation.share,
          CalendarFreeBusyExchangeOperation.refuse,
          CalendarFreeBusyExchangeOperation.dispatch,
        }.contains(c.operation)) {
      if (mailbox == null || c.message!.components.length != 1) {
        return CalendarAuthorizationVerdict.deny;
      }
      final part = c.message!.components.single;
      final sender = c.message!.method == IcalendarFreeBusyMethod.reply
          ? part.attendees.single
          : part.organizer.address;
      if (sender != mailbox.address ||
          !isSyntheticSchedulingMailbox(part.organizer.address) ||
          part.attendees.any((a) => !isSyntheticSchedulingMailbox(a))) {
        return CalendarAuthorizationVerdict.deny;
      }
    }
    return CalendarAuthorizationVerdict.allow;
  }

  @override
  Future<CalendarAuthorizationVerdict> authorizeSources(
    Session session,
    CalendarFreeBusyExchangePolicyContext c,
    List<CalendarAuthorizationRequest> requests,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (c.actor != null ||
        c.mailbox == null ||
        c.calendar == null ||
        await authorize(session, c, tx, phase) !=
            CalendarAuthorizationVerdict.allow) {
      return CalendarAuthorizationVerdict.deny;
    }
    for (final request in requests) {
      if (request.calendarId != c.mailbox!.calendarId ||
          request.current?.calendarId != c.mailbox!.calendarId ||
          !{
            CalendarPermission.readFreeBusy,
            CalendarPermission.exportFreeBusy,
            CalendarPermission.projectEventBusy,
            CalendarPermission.projectAvailability,
          }.contains(request.operation) ||
          request.currentEvent != null &&
              request.currentEvent!.calendarId != c.mailbox!.calendarId ||
          request.currentAvailability != null &&
              request.currentAvailability!.calendarId !=
                  c.mailbox!.calendarId) {
        return CalendarAuthorizationVerdict.deny;
      }
    }
    return CalendarAuthorizationVerdict.allow;
  }

  @override
  Future<List<CalendarSchedulingRoute>> resolveRoutes(
    Session session,
    CalendarFreeBusyExchangePolicyContext c,
    List<String> addresses,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (!await _active(session, c.scopeKey, c.ownerKey, tx) ||
        addresses.any((a) => !isSyntheticSchedulingMailbox(a))) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Busy exchange denied',
      );
    }
    return [for (final a in addresses) CalendarSchedulingRoute(a, a)];
  }
}

/// Records acceptance locally. No SMTP, provider credentials or real mail.
final class DemoFreeBusyTransport implements CalendarSchedulingTransport {
  @override
  Future<CalendarSchedulingTransportResult> submit(
    Session session,
    CalendarSchedulingSubmission submission,
  ) async {
    if (!{'development', 'test'}.contains(session.serverpod.runMode)) {
      return const CalendarSchedulingTransportResult(
        CalendarSchedulingTransportOutcome.permanentFailure,
      );
    }
    final mime = composeSyntheticFreeBusyMime(submission);
    final file = File(
      '../../../.local/freebusy-mail/${submission.deliveryKey}-${const Uuid().v4()}.json',
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'deliveryKey': submission.deliveryKey.toString(),
        'commandId': submission.publicationId.toString(),
        'scope': submission.scopeKey,
        'sender': submission.organizerAddress,
        'recipient': submission.recipient.address,
        'payload': submission.payload,
        'mime': mime,
      }),
      flush: true,
    );
    return CalendarSchedulingTransportResult(
      CalendarSchedulingTransportOutcome.accepted,
      receipt: 'synthetic:${submission.deliveryKey}',
      mimeDigest: sha256.convert(ascii.encode(mime)).toString(),
    );
  }
}
