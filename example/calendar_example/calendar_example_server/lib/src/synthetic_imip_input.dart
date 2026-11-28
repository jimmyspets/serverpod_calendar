import 'dart:convert';

import 'package:enough_mail/mime.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'imip_mime_input.dart';

/// Untrusted synthetic fixture composition only. Fixed transport headers are
/// deliberately unrelated to source participants and never prove authority.
/// The receiving wrapper must validate the complete MIME and calendar data.
List<int> composeSyntheticIngressMime(
  List<int> calendar, {
  required IcalendarSchedulingMethod method,
}) {
  if (calendar.length > 524288) {
    throw const HostImipMimeException(HostImipMimeError.limitExceeded);
  }
  try {
    if (calendar.any((b) => b < 0 || b > 255)) {
      throw const HostImipMimeException(HostImipMimeError.profile);
    }
    // Dart's UTF-8 decoder removes a leading BOM. Reject it instead of repairing
    // bytes before the strict calendar gate can inspect them.
    if (calendar.length >= 3 &&
        calendar[0] == 239 &&
        calendar[1] == 187 &&
        calendar[2] == 191) {
      throw const HostImipMimeException(HostImipMimeError.profile);
    }
    final builder =
        MessageBuilder(
            text: utf8.decode(calendar, allowMalformed: false),
            transferEncoding: TransferEncoding.base64,
            characterSet: CharacterSet.utf8,
          )
          ..from = [MailAddress(null, 'transport@example.invalid')]
          ..to = [MailAddress(null, 'fixture@example.invalid')]
          ..subject = 'Synthetic calendar input'
          ..date = DateTime.utc(2026)
          ..messageId = '<synthetic-input@example.invalid>';
    builder.setContentType(
      MediaType.fromText('text/calendar'),
      characterSet: CharacterSet.utf8,
      parameters: {'method': method.name.toUpperCase(), 'component': 'VEVENT'},
    );
    final result = builder.buildMimeMessage().renderMessage();
    if (result.length > 1048576) {
      throw const HostImipMimeException(HostImipMimeError.limitExceeded);
    }
    if (result.codeUnits.any((c) => c > 127)) {
      throw const HostImipMimeException(HostImipMimeError.unavailable);
    }
    return ascii.encode(result);
  } on HostImipMimeException {
    rethrow;
  } on FormatException {
    throw const HostImipMimeException(HostImipMimeError.profile);
  } catch (_) {
    throw const HostImipMimeException(HostImipMimeError.unavailable);
  }
}
