import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import '../imip_ingress.dart';
import '../synthetic_imip_input.dart';

/// Development/test simulator. No untrusted sender proof or bytes are accepted.
class InvitationDemoEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Fixed synthetic original from the recurring demo; no sender proof input.
  Future<CalendarInvitationReceipt> simulateOccurrence(
    Session session,
    UuidValue invitationId,
    UuidValue commandId,
    int sequence,
    bool cancel,
  ) async {
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        sequence < 1 ||
        sequence > 2147483647) {
      throw CalendarException(
        code: CalendarFailureCode.validation,
        message: 'Invalid simulation',
      );
    }
    final user = session.authenticated!.userIdentifier;
    final method = cancel
        ? IcalendarSchedulingMethod.cancel
        : IcalendarSchedulingMethod.request;
    final source = [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic invitation//EN',
      'METHOD:${cancel ? 'CANCEL' : 'REQUEST'}',
      'BEGIN:VEVENT',
      'UID:synthetic-invitation:$user:$invitationId',
      'DTSTAMP:20260101T000000Z',
      'SEQUENCE:$sequence',
      'RECURRENCE-ID:20300103T090000Z',
      if (cancel)
        'STATUS:CANCELLED'
      else ...[
        'DTSTART:20300103T110000Z',
        'DTEND:20300103T120000Z',
        'SUMMARY:Synthetic occurrence update',
      ],
      'ORGANIZER:mailto:organizer@example.invalid',
      'ATTENDEE:mailto:demo-$user@example.invalid',
      'END:VEVENT',
      'END:VCALENDAR',
      '',
    ].join('\r\n');
    return receiveHostImipInvitation(
      session,
      namespace: 'example.invitation',
      deliveryKey: commandId.toString(),
      originReference: 'synthetic:$user',
      outerProtection: ImipProtection.none,
      raw: composeSyntheticIngressMime(utf8.encode(source), method: method),
    );
  }

  Future<CalendarInvitationReceipt> simulate(
    Session session,
    UuidValue invitationId,
    UuidValue commandId,
    int? sequence,
    String summary,
  ) => _simulate(session, invitationId, commandId, sequence, summary, false);

  Future<CalendarInvitationReceipt> simulateRecurring(
    Session session,
    UuidValue invitationId,
    UuidValue commandId,
    int? sequence,
    String summary,
  ) => _simulate(session, invitationId, commandId, sequence, summary, true);

  Future<CalendarInvitationReceipt> _simulate(
    Session session,
    UuidValue invitationId,
    UuidValue commandId,
    int? sequence,
    String summary,
    bool recurring,
  ) async {
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        summary.runes.length > 256 ||
        sequence != null && (sequence < 0 || sequence > 2147483647)) {
      throw CalendarException(
        code: CalendarFailureCode.validation,
        message: 'Invalid simulation',
      );
    }
    final user = session.authenticated!.userIdentifier;
    final source = [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic invitation//EN',
      'METHOD:REQUEST',
      'BEGIN:VEVENT',
      'UID:synthetic-invitation:$user:$invitationId',
      'DTSTAMP:20260101T000000Z',
      if (sequence != null) 'SEQUENCE:$sequence',
      'DTSTART:20300101T090000Z',
      if (recurring) ...[
        'DTEND:20300101T100000Z',
        'RRULE:FREQ=DAILY;COUNT=3',
        'EXDATE:20300102T090000Z',
        'RDATE;VALUE=PERIOD:20300105T090000Z/PT2H',
      ],
      'SUMMARY:${encodeIcalendarText(summary)}',
      'ORGANIZER:mailto:organizer@example.invalid',
      'ATTENDEE:mailto:demo-$user@example.invalid',
      'END:VEVENT',
      'END:VCALENDAR',
      '',
    ].join('\r\n');
    return receiveHostImipInvitation(
      session,
      namespace: 'example.invitation',
      deliveryKey: commandId.toString(),
      originReference: 'synthetic:$user',
      outerProtection: ImipProtection.none,
      raw: composeSyntheticIngressMime(
        utf8.encode(source),
        method: IcalendarSchedulingMethod.request,
      ),
    );
  }

  Future<CalendarInvitationReceipt> simulateCancellation(
    Session session,
    UuidValue invitationId,
    UuidValue commandId,
    int sequence,
  ) async {
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        sequence < 1 ||
        sequence > 2147483647) {
      throw CalendarException(
        code: CalendarFailureCode.validation,
        message: 'Invalid simulation',
      );
    }
    final user = session.authenticated!.userIdentifier;
    final source = [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic invitation//EN',
      'METHOD:CANCEL',
      'BEGIN:VEVENT',
      'UID:synthetic-invitation:$user:$invitationId',
      'DTSTAMP:20260101T000000Z',
      'SEQUENCE:$sequence',
      'STATUS:CANCELLED',
      'ORGANIZER:mailto:organizer@example.invalid',
      'ATTENDEE:mailto:demo-$user@example.invalid',
      'END:VEVENT',
      'END:VCALENDAR',
      '',
    ].join('\r\n');
    return receiveHostImipInvitation(
      session,
      namespace: 'example.invitation',
      deliveryKey: commandId.toString(),
      originReference: 'synthetic:$user',
      outerProtection: ImipProtection.none,
      raw: composeSyntheticIngressMime(
        utf8.encode(source),
        method: IcalendarSchedulingMethod.cancel,
      ),
    );
  }
}
