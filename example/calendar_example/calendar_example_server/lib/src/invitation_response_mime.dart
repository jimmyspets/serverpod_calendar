import 'dart:convert';

import 'package:enough_mail/mime.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'scheduling_mime.dart';

/// Attendee sender, organizer destination. No role/route is inferred from headers.
String composeSyntheticInvitationResponseMime(
  CalendarInvitationResponseSubmission submission, {
  required bool requireProtection,
}) {
  if (requireProtection) {
    throw const SyntheticSchedulingMimeException(
      SyntheticSchedulingMimeError.protection,
    );
  }
  try {
    if (!isSyntheticSchedulingMailbox(submission.attendeeAddress) ||
        !isSyntheticSchedulingMailbox(submission.organizer.address)) {
      throw const SyntheticSchedulingMimeException(
        SyntheticSchedulingMimeError.profile,
      );
    }
    if (submission.payload.length > 32768) {
      throw const SyntheticSchedulingMimeException(
        SyntheticSchedulingMimeError.limitExceeded,
      );
    }
    final bytes = utf8.encode(submission.payload);
    if (bytes.length > 32768) {
      throw const SyntheticSchedulingMimeException(
        SyntheticSchedulingMimeError.limitExceeded,
      );
    }
    final parsed = parseImipCalendarPart(
      ImipDecodedPart(
        mediaType: 'text/calendar',
        parameters: const [
          ImipParameter('method', 'REPLY'),
          ImipParameter('charset', 'UTF-8'),
          ImipParameter('component', 'VEVENT'),
        ],
        body: bytes,
        protection: ImipProtection.none,
        limits: const ImipPartLimits(maxDecodedBytes: 32768),
      ),
      limits: const ImipPartLimits(maxDecodedBytes: 32768),
    );
    final message = parsed.eventMessage;
    if (message == null ||
        message.method != IcalendarSchedulingMethod.reply ||
        message.events.length != 1) {
      throw const SyntheticSchedulingMimeException(
        SyntheticSchedulingMimeError.profile,
      );
    }
    final event = message.events.single;
    if (event.participants.organizer?.address != submission.organizer.address ||
        event.participants.attendees.length != 1 ||
        event.participants.attendees.single.address !=
            submission.attendeeAddress ||
        !{
          'ACCEPTED',
          'TENTATIVE',
          'DECLINED',
        }.contains(event.participants.attendees.single.participationStatus)) {
      throw const SyntheticSchedulingMimeException(
        SyntheticSchedulingMimeError.profile,
      );
    }
    final calendar = message.source.components.single;
    for (final entry in calendar.entries) {
      if (entry is IcalendarSyntaxProperty) {
        if (!{'VERSION', 'PRODID', 'METHOD'}.contains(entry.canonicalName) ||
            entry.parameters.isNotEmpty) {
          throw const SyntheticSchedulingMimeException(
            SyntheticSchedulingMimeError.profile,
          );
        }
      } else if (entry is IcalendarSyntaxComponent) {
        if (entry.canonicalName != 'VEVENT') {
          throw const SyntheticSchedulingMimeException(
            SyntheticSchedulingMimeError.profile,
          );
        }
        for (final field in entry.entries) {
          if (field is! IcalendarSyntaxProperty ||
              !{
                'UID',
                'DTSTAMP',
                'SEQUENCE',
                'ORGANIZER',
                'ATTENDEE',
              }.contains(field.canonicalName) ||
              field.parameters.any(
                (p) =>
                    field.canonicalName != 'ATTENDEE' ||
                    p.name.toUpperCase() != 'PARTSTAT',
              )) {
            throw const SyntheticSchedulingMimeException(
              SyntheticSchedulingMimeError.profile,
            );
          }
        }
      }
    }
    final builder =
        MessageBuilder(
            text: submission.payload,
            transferEncoding: TransferEncoding.base64,
            characterSet: CharacterSet.utf8,
          )
          ..from = [MailAddress(null, submission.attendeeAddress.substring(7))]
          ..to = [MailAddress(null, submission.organizer.address.substring(7))]
          ..subject = 'Calendar response'
          ..date = event.stamp
          ..messageId =
              '<calendar-reply-${submission.deliveryKey}@example.invalid>';
    builder.setContentType(
      MediaType.fromText('text/calendar'),
      characterSet: CharacterSet.utf8,
      parameters: {'method': 'REPLY', 'component': 'VEVENT'},
    );
    final output = builder.buildMimeMessage().renderMessage();
    if (output.length > 1048576) {
      throw const SyntheticSchedulingMimeException(
        SyntheticSchedulingMimeError.limitExceeded,
      );
    }
    if (output.codeUnits.any((c) => c > 127)) {
      throw const SyntheticSchedulingMimeException(
        SyntheticSchedulingMimeError.unavailable,
      );
    }
    return output;
  } on SyntheticSchedulingMimeException {
    rethrow;
  } on ImipPartException catch (e) {
    throw SyntheticSchedulingMimeException(
      e.kind == ImipPartError.limitExceeded
          ? SyntheticSchedulingMimeError.limitExceeded
          : SyntheticSchedulingMimeError.profile,
    );
  } catch (_) {
    throw const SyntheticSchedulingMimeException(
      SyntheticSchedulingMimeError.unavailable,
    );
  }
}
