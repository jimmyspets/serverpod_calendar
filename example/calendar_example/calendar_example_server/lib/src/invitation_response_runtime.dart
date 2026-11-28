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
  String _original(IcalendarSchedulingEvent event) {
    final date = event.originalDate, time = event.originalTime;
    return jsonEncode(
      date != null
          ? ['date', date.year, date.month, date.day]
          : time == null
          ? null
          : [
              'time',
              time.zoneId,
              time.civil.date.year,
              time.civil.date.month,
              time.civil.date.day,
              time.civil.hour,
              time.civil.minute,
              time.civil.second,
            ],
    );
  }

  bool _matchesTarget(
    CalendarInvitationResponsePolicyContext context,
    IcalendarSchedulingMessage source,
    IcalendarSchedulingMessage outgoing,
  ) {
    final event = outgoing.events.single,
        original = context.responseOriginalStart;
    if (event.isThisAndFuture) return false;
    if (original != null) {
      final component = context.responseComponentVersion;
      if (component == null ||
          !event.isOverride ||
          component.sequence != event.sequence) {
        return false;
      }
      final c = original.start;
      final key = jsonEncode(
        original.kind == CalendarEventTimeKind.date
            ? ['date', c.year, c.month, c.day]
            : [
                'time',
                original.zoneId,
                c.year,
                c.month,
                c.day,
                c.hour,
                c.minute,
                c.second,
              ],
      );
      return _original(event) == key;
    }
    final basis = source.events.singleWhere(
      (event) => !event.isOverride || source.events.length == 1,
    );
    return basis.isOverride == event.isOverride &&
        _original(basis) == _original(event) &&
        basis.sequence == event.sequence;
  }

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
        !{
          CalendarInvitationResponseOperation.dispatch,
          CalendarInvitationResponseOperation.dispatchOccurrence,
          CalendarInvitationResponseOperation.dispatchBundleMaster,
          CalendarInvitationResponseOperation.dispatchBundleOccurrence,
          CalendarInvitationResponseOperation.dispatchRecurringOccurrence,
          CalendarInvitationResponseOperation.maintainRecurringResponseEvidence,
        }.contains(c.operation)) {
      return false;
    }
    if (!{
      CalendarInvitationResponseOperation.read,
      CalendarInvitationResponseOperation.readBundleMaster,
      CalendarInvitationResponseOperation.readBundleOccurrence,
      CalendarInvitationResponseOperation.readRecurringOccurrence,
      CalendarInvitationResponseOperation.maintainRecurringResponseEvidence,
    }.contains(c.operation)) {
      final source = c.sourceMessage,
          outgoing = c.outgoingMessage,
          authority = c.authority;
      if (source == null ||
          outgoing == null ||
          authority == null ||
          source.method != IcalendarSchedulingMethod.request ||
          !source.events
              .singleWhere(
                (event) => !event.isOverride || source.events.length == 1,
              )
              .participants
              .attendees
              .any(
                (a) => a.address == c.recipient.calendarAddress,
              ) ||
          outgoing.method != IcalendarSchedulingMethod.reply ||
          outgoing.uid != c.invitation.uid ||
          !_matchesTarget(c, source, outgoing) ||
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

final class DemoAttendeeRefreshHost implements CalendarAttendeeRefreshHost {
  @override
  CalendarAuthorizationGuarantee get guarantee =>
      CalendarAuthorizationGuarantee.freshCheck;

  CalendarInvitationResponseAuthority _route(
    CalendarAttendeeRefreshContext c,
  ) => CalendarInvitationResponseAuthority(
    attendeeAddress: c.recipient.calendarAddress,
    authorityRef: 'demo-refresh-recipient:${c.recipient.key}',
    organizer: CalendarSchedulingRoute(
      c.invitation.organizer,
      'demo-refresh-organizer:${c.recipient.key}',
    ),
  );

  Future<bool> _recipientAllowed(
    Session session,
    CalendarAttendeeRefreshContext c,
    Transaction transaction,
  ) async {
    final key = c.recipient.key;
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        c.recipient.scopeKey != 'demo:user:$key' ||
        c.recipient.calendarAddress != 'mailto:demo-$key@example.invalid' ||
        c.invitation.organizer != 'mailto:organizer@example.invalid' ||
        !c.invitation.uid.startsWith('synthetic-invitation:$key:') ||
        (c.actor == null) !=
            (c.operation == CalendarAttendeeRefreshOperation.dispatch) ||
        c.actor != null &&
            (c.actor!.principalId != key ||
                c.actor!.scopeKey != c.recipient.scopeKey)) {
      return false;
    }
    final user = await AuthUser.db.findById(
      session,
      UuidValue.fromString(key),
      transaction: transaction,
    );
    return user != null && !user.blocked;
  }

  bool _sourceAllowed(CalendarAttendeeRefreshContext c) {
    final source = c.sourceMessage;
    return c.sourceId != null &&
        source != null &&
        source.method == IcalendarSchedulingMethod.request &&
        source.uid == c.invitation.uid &&
        source.events.single.participants.organizer?.address ==
            c.invitation.organizer &&
        source.events.single.participants.attendees.any(
          (a) => a.address == c.recipient.calendarAddress,
        );
  }

  @override
  Future<CalendarInvitationResponseAuthority> resolve(
    Session session,
    CalendarAttendeeRefreshContext context,
    Transaction transaction,
  ) async {
    if (!await _recipientAllowed(session, context, transaction) ||
        !_sourceAllowed(context)) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Invitation request access denied.',
      );
    }
    return _route(context);
  }

  @override
  Future<CalendarAuthorizationVerdict> authorize(
    Session session,
    CalendarAttendeeRefreshContext c,
    Transaction transaction,
    CalendarAuthorizationPhase phase,
  ) async {
    if (!await _recipientAllowed(session, c, transaction)) {
      return CalendarAuthorizationVerdict.deny;
    }
    if (c.operation == CalendarAttendeeRefreshOperation.read) {
      return CalendarAuthorizationVerdict.allow;
    }
    final outgoing = c.outgoingMessage;
    final route = _route(c);
    final approved = c.authority;
    return _sourceAllowed(c) &&
            outgoing != null &&
            outgoing.method == IcalendarSchedulingMethod.refresh &&
            outgoing.uid == c.invitation.uid &&
            outgoing.events.single.participants.organizer?.address ==
                route.organizer.address &&
            outgoing.events.single.participants.attendees.single.address ==
                route.attendeeAddress &&
            approved?.attendeeAddress == route.attendeeAddress &&
            approved?.authorityRef == route.authorityRef &&
            approved?.organizer.address == route.organizer.address &&
            approved?.organizer.routeRef == route.organizer.routeRef &&
            sha256
                    .convert(serializeIcalendarSyntax(outgoing.source))
                    .toString() ==
                c.payloadDigest
        ? CalendarAuthorizationVerdict.allow
        : CalendarAuthorizationVerdict.deny;
  }
}

/// Synthetic attempt recording only. Stable delivery identity survives retries;
/// provider acceptance is not remote receipt or application.
final class DemoInvitationResponseTransport
    implements CalendarInvitationResponseTransport {
  DemoInvitationResponseTransport({this.refresh = false});

  final bool refresh;

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
        refresh: refresh,
      );
    } on SyntheticSchedulingMimeException catch (e) {
      return CalendarSchedulingTransportResult(
        e.kind == SyntheticSchedulingMimeError.unavailable
            ? CalendarSchedulingTransportOutcome.transientFailure
            : CalendarSchedulingTransportOutcome.permanentFailure,
      );
    }
    final file = File(
      '../../../.local/attendee-${refresh ? 'refresh' : 'response'}-mail/${submission.deliveryKey}-${const Uuid().v4obj()}.json',
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
      receipt:
          'synthetic-${refresh ? 'refresh' : 'reply'}:${submission.deliveryKey}',
    );
  }
}
