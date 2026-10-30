import 'dart:convert';

import 'package:enough_mail/mime.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

enum SyntheticSchedulingMimeError {
  profile,
  protection,
  limitExceeded,
  unavailable,
}

/// No source text or third-party diagnostic is exposed to callers/logs.
final class SyntheticSchedulingMimeException implements Exception {
  const SyntheticSchedulingMimeException(this.kind);
  final SyntheticSchedulingMimeError kind;
  @override
  String toString() => 'SyntheticSchedulingMimeException(${kind.name})';
}

Never _fail(SyntheticSchedulingMimeError kind) =>
    throw SyntheticSchedulingMimeException(kind);

// This example's stricter subset is contained in the accepted mailto profile.
// Real mailbox resolution/authority remains the replacing host's responsibility.
final _synthetic = RegExp(
  r'^mailto:[A-Za-z0-9_+\-]+(?:\.[A-Za-z0-9_+\-]+)*@example\.invalid$',
);

bool isSyntheticSchedulingMailbox(String value) =>
    value.length <= 2048 &&
    !value.codeUnits.any((c) => c <= 32 || c >= 127) &&
    _synthetic.hasMatch(value);

/// Host-local composition only, not sender verification or a network transport.
/// All native worker/complete-message/route checks must precede submission.
String composeSyntheticSchedulingMime(
  CalendarSchedulingSubmission submission, {
  required bool requireProtection,
}) {
  if (requireProtection) _fail(SyntheticSchedulingMimeError.protection);
  try {
    if (!isSyntheticSchedulingMailbox(submission.organizerAddress) ||
        !isSyntheticSchedulingMailbox(submission.recipient.address)) {
      _fail(SyntheticSchedulingMimeError.profile);
    }
    // Reject oversized strings before UTF-8 allocation; bytes are rechecked by
    // the carrier. Do not regenerate/normalize the already authorized payload.
    if (submission.payload.length > 524288) {
      _fail(SyntheticSchedulingMimeError.limitExceeded);
    }
    final bytes = utf8.encode(submission.payload);
    if (bytes.length > 524288) {
      _fail(SyntheticSchedulingMimeError.limitExceeded);
    }
    final syntax = parseIcalendarSyntax(bytes);
    if (syntax.components.length != 1 ||
        syntax.components.single.canonicalName != 'VCALENDAR') {
      _fail(SyntheticSchedulingMimeError.profile);
    }
    final methods = syntax.components.single.entries
        .whereType<IcalendarSyntaxProperty>()
        .where((p) => p.canonicalName == 'METHOD')
        .toList();
    if (methods.length != 1) _fail(SyntheticSchedulingMimeError.profile);
    final part = ImipDecodedPart(
      mediaType: 'text/calendar',
      parameters: [
        const ImipParameter('charset', 'UTF-8'),
        ImipParameter('method', methods.single.value),
        const ImipParameter('component', 'VEVENT'),
      ],
      body: bytes,
      protection: ImipProtection.none,
      limits: const ImipPartLimits(maxDecodedBytes: 524288),
    );
    final message = parseImipCalendarPart(
      part,
      limits: const ImipPartLimits(maxDecodedBytes: 524288),
    ).eventMessage!;
    if (!const {
      IcalendarSchedulingMethod.request,
      IcalendarSchedulingMethod.cancel,
    }.contains(message.method)) {
      _fail(SyntheticSchedulingMimeError.profile);
    }
    for (final event in message.events) {
      if (event.participants.organizer?.address !=
          submission.organizerAddress) {
        _fail(SyntheticSchedulingMimeError.profile);
      }
      for (final participant in <IcalendarEventParticipant>[
        event.participants.organizer!,
        ...event.participants.attendees,
      ]) {
        if (!isSyntheticSchedulingMailbox(participant.address)) {
          _fail(SyntheticSchedulingMimeError.profile);
        }
        for (final name in ['SENT-BY', 'DELEGATED-TO', 'DELEGATED-FROM']) {
          if ((participant.parameters[name] ?? const <String>[]).any(
            (address) => !isSyntheticSchedulingMailbox(address),
          )) {
            _fail(SyntheticSchedulingMimeError.profile);
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
          ..from = [MailAddress(null, submission.organizerAddress.substring(7))]
          ..to = [MailAddress(null, submission.recipient.address.substring(7))]
          ..subject = 'Calendar update'
          ..date = message.events.first.stamp
          ..messageId = '<calendar-${submission.deliveryKey}@example.invalid>';
    builder.setContentType(
      MediaType.fromText('text/calendar'),
      characterSet: CharacterSet.utf8,
      parameters: {
        'method': message.method.name.toUpperCase(),
        'component': 'VEVENT',
      },
    );
    final rendered = builder.buildMimeMessage().renderMessage();
    if (rendered.length > 1048576) {
      _fail(SyntheticSchedulingMimeError.limitExceeded);
    }
    if (rendered.codeUnits.any((c) => c > 127)) {
      _fail(SyntheticSchedulingMimeError.unavailable);
    }
    return rendered;
  } on SyntheticSchedulingMimeException {
    rethrow;
  } on ImipPartException catch (e) {
    _fail(
      e.kind == ImipPartError.limitExceeded
          ? SyntheticSchedulingMimeError.limitExceeded
          : SyntheticSchedulingMimeError.profile,
    );
  } on IcalendarComponentException catch (e) {
    _fail(
      e.kind == IcalendarComponentError.limitExceeded
          ? SyntheticSchedulingMimeError.limitExceeded
          : SyntheticSchedulingMimeError.profile,
    );
  } on IcalendarSyntaxException catch (e) {
    _fail(
      e.kind == IcalendarSyntaxError.limitExceeded
          ? SyntheticSchedulingMimeError.limitExceeded
          : SyntheticSchedulingMimeError.profile,
    );
  } catch (_) {
    _fail(SyntheticSchedulingMimeError.unavailable);
  }
}
