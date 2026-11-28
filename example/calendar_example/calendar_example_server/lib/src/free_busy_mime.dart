import 'dart:convert';

import 'package:enough_mail/mime.dart';
import 'package:serverpod/serverpod.dart' hide TransferEncoding;
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

import 'imip_mime_input.dart';
import 'scheduling_mime.dart';

/// Synthetic composition only. A MIME From field never supplies host authority.
String composeSyntheticFreeBusyMime(CalendarSchedulingSubmission submission) {
  try {
    if (submission.payload.length > 262144 ||
        utf8.encode(submission.payload).length > 262144 ||
        !isSyntheticSchedulingMailbox(submission.organizerAddress) ||
        !isSyntheticSchedulingMailbox(submission.recipient.address)) {
      throw const HostImipMimeException(HostImipMimeError.profile);
    }
    final message = parseIcalendarFreeBusyMessage(
      utf8.encode(submission.payload),
    );
    if (message.components.length != 1) {
      throw const HostImipMimeException(HostImipMimeError.profile);
    }
    final component = message.components.single;
    final sender = message.method == IcalendarFreeBusyMethod.reply
        ? component.attendees.single
        : component.organizer.address;
    if (sender != submission.organizerAddress ||
        !isSyntheticSchedulingMailbox(component.organizer.address) ||
        component.attendees.any((a) => !isSyntheticSchedulingMailbox(a)) ||
        message.method == IcalendarFreeBusyMethod.request &&
            !component.attendees.contains(submission.recipient.address) ||
        message.method == IcalendarFreeBusyMethod.reply &&
            component.organizer.address != submission.recipient.address) {
      throw const HostImipMimeException(HostImipMimeError.profile);
    }
    final builder =
        MessageBuilder(
            text: submission.payload,
            transferEncoding: TransferEncoding.base64,
            characterSet: CharacterSet.utf8,
          )
          ..from = [MailAddress(null, sender.substring(7))]
          ..to = [MailAddress(null, submission.recipient.address.substring(7))]
          ..subject = 'Busy-time message'
          ..date = component.stamp
          ..messageId = '<freebusy-${submission.deliveryKey}@example.invalid>';
    builder.setContentType(
      MediaType.fromText('text/calendar'),
      characterSet: CharacterSet.utf8,
      parameters: {
        'method': message.method.name.toUpperCase(),
        'component': 'VFREEBUSY',
      },
    );
    final rendered = builder.buildMimeMessage().renderMessage();
    if (rendered.length > 1048576 || rendered.codeUnits.any((c) => c > 127)) {
      throw const HostImipMimeException(HostImipMimeError.limitExceeded);
    }
    // Assert the existing bounded raw adapter retains the exact authorized
    // calendar bytes; no reserialization may change a queued retry payload.
    final decoded = parseHostImipMime(
      ascii.encode(rendered),
      outerProtection: ImipProtection.none,
    );
    if (decoded.freeBusyMessage == null ||
        utf8.decode(decoded.source.body) != submission.payload) {
      throw const HostImipMimeException(HostImipMimeError.profile);
    }
    return rendered;
  } on HostImipMimeException {
    rethrow;
  } catch (_) {
    throw const HostImipMimeException(HostImipMimeError.unavailable);
  }
}

/// The caller supplies a trusted mailbox/origin, independently of MIME headers.
Future<CalendarFreeBusyIngressReceipt> receiveHostFreeBusyMime(
  Session session, {
  required List<int> raw,
  required ImipProtection outerProtection,
  required CalendarFreeBusyMailbox mailbox,
  required String namespace,
  required String deliveryKey,
  required String originRef,
}) {
  final part = parseHostImipMime(raw, outerProtection: outerProtection);
  if (part.freeBusyMessage == null || part.source.body.length > 262144) {
    throw const HostImipMimeException(HostImipMimeError.profile);
  }
  return CalendarModule.receiveFreeBusy(
    session,
    CalendarFreeBusyIngress(
      mailbox: mailbox,
      namespace: namespace,
      deliveryKey: deliveryKey,
      originRef: originRef,
      payload: utf8.decode(part.source.body),
    ),
  );
}
