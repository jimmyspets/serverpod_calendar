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
  Future<CalendarInvitationReceipt> simulate(
    Session session,
    UuidValue invitationId,
    UuidValue commandId,
    int? sequence,
    String summary,
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
