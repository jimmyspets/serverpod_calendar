import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

import 'imip_mime_input.dart';

List<int> _calendar(
  List<int> raw,
  ImipProtection protection,
  Set<IcalendarSchedulingMethod> methods,
  int maximum,
) {
  final part = parseHostImipMime(raw, outerProtection: protection);
  if (part.eventMessage == null ||
      !methods.contains(part.eventMessage!.method)) {
    throw const HostImipMimeException(HostImipMimeError.profile);
  }
  if (part.source.body.length > maximum) {
    throw const HostImipMimeException(HostImipMimeError.limitExceeded);
  }
  return part.source.body;
}

/// Host-only bridge. Metadata must come from trusted integration context and
/// remains subject to the installed invitation host's origin/recipient checks.
/// MIME headers never resolve an actor, recipient, calendar or delivery key.
Future<CalendarInvitationReceipt> receiveHostImipInvitation(
  Session session, {
  required List<int> raw,
  required ImipProtection outerProtection,
  required String namespace,
  required String deliveryKey,
  required String originReference,
}) async {
  final bytes = _calendar(raw, outerProtection, const {
    IcalendarSchedulingMethod.request,
    IcalendarSchedulingMethod.cancel,
  }, 262144);
  return CalendarModule.receiveSchedulingInvitation(
    session,
    CalendarInvitationDelivery(
      namespace: namespace,
      deliveryKey: deliveryKey,
      originReference: originReference,
      bytes: Uint8List.fromList(bytes),
    ),
  );
}

/// The caller supplies an explicitly host-resolved target. Existing module
/// validation and preliminary/final host authorization remain authoritative;
/// this wrapper neither discovers a target nor verifies a production sender.
Future<CalendarSchedulingReplyReceipt> receiveHostImipReply(
  Session session, {
  required List<int> raw,
  required ImipProtection outerProtection,
  required String scopeKey,
  required UuidValue eventId,
  required String namespace,
  required String deliveryKey,
  required String originReference,
}) async {
  final bytes = _calendar(raw, outerProtection, const {
    IcalendarSchedulingMethod.reply,
  }, 524288);
  return CalendarModule.receiveSchedulingReply(
    session,
    CalendarSchedulingReplyDelivery(
      scopeKey: scopeKey,
      eventId: eventId,
      namespace: namespace,
      deliveryKey: deliveryKey,
      originReference: originReference,
      bytes: Uint8List.fromList(bytes),
    ),
  );
}
