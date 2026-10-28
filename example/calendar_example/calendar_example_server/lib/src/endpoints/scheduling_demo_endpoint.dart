import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

/// Synthetic private-owner test ingress, deliberately unavailable in production.
class SchedulingDemoEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<CalendarSchedulingReplyReceipt> simulateReply(
    Session session,
    UuidValue eventId,
    UuidValue commandId,
    String attendeeAddress,
    CalendarSchedulingParticipation participation,
    int? sequence,
    DateTime sourceStamp,
    String? comment,
    CalendarEventTiming? originalStart,
  ) async {
    if (!{'development', 'test'}.contains(session.serverpod.runMode) ||
        !RegExp(r'^mailto:[A-Za-z0-9._+\-]+@example\.invalid$')
            .hasMatch(attendeeAddress) ||
        !sourceStamp.isUtc ||
        sourceStamp.microsecond != 0 ||
        sourceStamp.millisecond != 0 ||
        sourceStamp.year < 1970 ||
        sourceStamp.year >= 2100 ||
        (comment?.runes.length ?? 0) > 4096) {
      throw CalendarException(
        code: CalendarFailureCode.validation,
        message: 'Invalid simulation',
      );
    }
    final service = CalendarModule.service(session);
    // Actual object/parent rights checked before constructing trusted test evidence.
    if (originalStart == null) {
      await service.schedulingResponses(eventId);
    } else {
      await service.schedulingInstanceResponses(eventId, originalStart);
    }
    final event = await service.getEvent(
      eventId,
      CalendarEventFieldGroup.values,
    );
    final status = await service.schedulingStatus(eventId);
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp =
        '${sourceStamp.year}${two(sourceStamp.month)}${two(sourceStamp.day)}T'
        '${two(sourceStamp.hour)}${two(sourceStamp.minute)}${two(sourceStamp.second)}Z';
    final state = switch (participation) {
      CalendarSchedulingParticipation.needsAction => 'NEEDS-ACTION',
      CalendarSchedulingParticipation.accepted => 'ACCEPTED',
      CalendarSchedulingParticipation.declined => 'DECLINED',
      CalendarSchedulingParticipation.tentative => 'TENTATIVE',
    };
    final c = originalStart?.start;
    final date = c == null ? null : '${c.year}${two(c.month)}${two(c.day)}';
    final original = c == null
        ? null
        : IcalendarSyntaxProperty(
            'RECURRENCE-ID',
            originalStart!.kind == CalendarEventTimeKind.date
                ? date!
                : '$date'
                      'T${two(c.hour)}${two(c.minute)}${two(c.second)}${originalStart.kind == CalendarEventTimeKind.utc ? 'Z' : ''}',
            parameters: [
              if (originalStart.kind == CalendarEventTimeKind.date)
                IcalendarSyntaxParameter('VALUE', ['DATE']),
              if (originalStart.zoneId != null)
                IcalendarSyntaxParameter('TZID', [originalStart.zoneId!]),
            ],
          );
    final bytes = serializeIcalendarSyntax(
      IcalendarSyntaxDocument([
        IcalendarSyntaxComponent('VCALENDAR', [
          IcalendarSyntaxProperty('VERSION', '2.0'),
          IcalendarSyntaxProperty(
            'PRODID',
            '-//Synthetic reply simulation//EN',
          ),
          IcalendarSyntaxProperty('METHOD', 'REPLY'),
          if (originalStart?.zoneId != null)
            createIcalendarTimeZone(originalStart!.zoneId!),
          IcalendarSyntaxComponent('VEVENT', [
            IcalendarSyntaxProperty(
              'UID',
              encodeIcalendarText(event.protocolUid!),
            ),
            IcalendarSyntaxProperty('DTSTAMP', stamp),
            ?original,
            if (sequence != null)
              IcalendarSyntaxProperty('SEQUENCE', '$sequence'),
            IcalendarSyntaxProperty('ORGANIZER', status.organizerAddress!),
            IcalendarSyntaxProperty(
              'ATTENDEE',
              attendeeAddress,
              parameters: [
                IcalendarSyntaxParameter('PARTSTAT', [state]),
              ],
            ),
            if (comment != null)
              IcalendarSyntaxProperty('COMMENT', encodeIcalendarText(comment)),
          ]),
        ]),
      ]),
    );
    final id = session.authenticated!.userIdentifier;
    return CalendarModule.receiveSchedulingReply(
      session,
      CalendarSchedulingReplyDelivery(
        scopeKey: 'demo:user:$id',
        eventId: eventId,
        namespace: 'demo-synthetic-reply',
        deliveryKey: commandId.toString(),
        originReference: 'demo-owner:$id',
        bytes: bytes,
      ),
    );
  }
}
