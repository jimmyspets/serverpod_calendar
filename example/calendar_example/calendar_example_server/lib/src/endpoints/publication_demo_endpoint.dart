import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import '../imip_ingress.dart';
import '../synthetic_imip_input.dart';

/// Only fixed synthetic source data; callers cannot submit a trusted origin.
class PublicationDemoEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<CalendarIncomingPublicationIngressReceipt> simulate(
    Session session,
    UuidValue publicationId,
    UuidValue commandId,
    int sequence,
    bool cancel,
    bool recurring,
    String summary,
  ) async {
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        sequence < 0 ||
        sequence > 2147483647 ||
        summary.runes.length > 256) {
      throw CalendarException(
        code: CalendarFailureCode.validation,
        message: 'Invalid simulation',
      );
    }
    final user = session.authenticated!.userIdentifier;
    final method = cancel
        ? IcalendarSchedulingMethod.cancel
        : IcalendarSchedulingMethod.publish;
    final text = encodeIcalendarText(summary);
    final source = [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic publication//EN',
      'METHOD:${cancel ? 'CANCEL' : 'PUBLISH'}',
      'BEGIN:VEVENT',
      'UID:synthetic-publication:$user:$publicationId',
      'ORGANIZER:mailto:publisher@example.invalid',
      'DTSTAMP:20261113T070000Z',
      'SEQUENCE:$sequence',
      'DTSTART:20330103T090000Z',
      'DURATION:PT1H',
      'SUMMARY:$text',
      if (recurring) 'RRULE:FREQ=DAILY;COUNT=3',
      if (cancel) 'STATUS:CANCELLED',
      'END:VEVENT',
      'END:VCALENDAR',
      '',
    ].join('\r\n');
    return receiveHostImipPublication(
      session,
      raw: composeSyntheticIngressMime(utf8.encode(source), method: method),
      outerProtection: ImipProtection.none,
      namespace: 'example.publication',
      deliveryKey: commandId.toString(),
      originReference: 'synthetic:$user',
    );
  }
}
