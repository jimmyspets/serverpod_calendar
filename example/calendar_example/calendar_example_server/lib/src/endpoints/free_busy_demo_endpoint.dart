import 'package:crypto/crypto.dart';

import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

import '../calendar_policy.dart';
import '../free_busy_mime.dart';
import '../free_busy_runtime.dart';

/// Synthetic fixtures only. Callers cannot supply sender proof or raw mail.
class FreeBusyDemoEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<CalendarFreeBusyIngressReceipt> simulate(
    Session session,
    UuidValue calendarId,
    UuidValue commandId,
    DateTime fromUtc,
    DateTime untilUtc, {
    bool publish = false,
  }) async {
    _development(session);
    final host = DemoFreeBusyHost();
    final actor = await DemoCalendarPolicy().resolveContext(session);
    final mailbox = await session.db.transaction(
      (tx) => host.resolveMailbox(
        session,
        actor,
        calendarId,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      ),
    );
    try {
      final window = UtcWindow(start: fromUtc, end: untilUtc);
      final sender = publish
          ? 'mailto:publisher@example.invalid'
          : 'mailto:requester@example.invalid';
      final message = buildCalendarFreeBusyExchange(
        method: publish
            ? IcalendarFreeBusyMethod.publish
            : IcalendarFreeBusyMethod.request,
        uid:
            'synthetic-freebusy:${sha256.convert(utf8.encode('synthetic-source:$commandId')).toString()}',
        stamp: DateTime.utc(2026),
        window: window,
        organizer: sender,
        attendees: publish ? [] : [mailbox.address],
        partition: publish
            ? [
                AvailabilityInterval(
                  window: window,
                  kind: AvailabilityKind.busy,
                ),
              ]
            : null,
      );
      final payload = utf8.decode(calendarFreeBusyExchangeBytes(message));
      final mime = composeSyntheticFreeBusyMime(
        CalendarSchedulingSubmission(
          deliveryKey: commandId,
          publicationId: commandId,
          scopeKey: actor.scopeKey,
          organizerAddress: sender,
          recipient: CalendarSchedulingRoute(mailbox.address, mailbox.address),
          payload: payload,
        ),
      );
      return await receiveHostFreeBusyMime(
        session,
        raw: ascii.encode(mime),
        outerProtection: ImipProtection.none,
        mailbox: mailbox,
        namespace: 'example.freebusy',
        deliveryKey: commandId.toString(),
        originRef: 'synthetic-freebusy:${actor.principalId}',
      );
    } on CalendarException {
      rethrow;
    } catch (_) {
      throw CalendarException(
        code: CalendarFailureCode.validation,
        message: 'Invalid synthetic busy message',
      );
    }
  }

  Future<CalendarFreeBusyIngressReceipt> simulateReply(
    Session session,
    UuidValue outgoingId,
    UuidValue commandId,
  ) async {
    _development(session);
    final host = DemoFreeBusyHost();
    final actor = await DemoCalendarPolicy().resolveContext(session);
    final command = await CalendarFreeBusyCommandRecord.db.findById(
      session,
      outgoingId,
    );
    if (command == null ||
        command.scopeKey != actor.scopeKey ||
        command.ownerKey != actor.principalId ||
        command.method != 'request' ||
        command.payload == null ||
        command.calendarId == null ||
        command.scrubbedAt != null) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Busy exchange denied',
      );
    }
    await CalendarModule.service(session).freeBusyDeliveryActivity(outgoingId);
    final mailbox = await session.db.transaction(
      (tx) => host.resolveMailbox(
        session,
        actor,
        command.calendarId!,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      ),
    );
    final request = parseIcalendarFreeBusyMessage(utf8.encode(command.payload!))
        .components
        .single;
    const respondent = 'mailto:respondent@example.invalid';
    if (!request.attendees.contains(respondent)) {
      throw CalendarException(
        code: CalendarFailureCode.validation,
        message: 'Choose the synthetic respondent route first',
      );
    }
    final message = buildCalendarFreeBusyExchange(
      method: IcalendarFreeBusyMethod.reply,
      uid: request.uid,
      stamp: DateTime.utc(2026),
      window: request.window,
      organizer: mailbox.address,
      attendees: [respondent],
      partition: [
        AvailabilityInterval(
          window: request.window,
          kind: AvailabilityKind.tentative,
        ),
      ],
    );
    final mime = composeSyntheticFreeBusyMime(
      CalendarSchedulingSubmission(
        deliveryKey: commandId,
        publicationId: commandId,
        scopeKey: actor.scopeKey,
        organizerAddress: respondent,
        recipient: CalendarSchedulingRoute(mailbox.address, mailbox.address),
        payload: utf8.decode(calendarFreeBusyExchangeBytes(message)),
      ),
    );
    return await receiveHostFreeBusyMime(
      session,
      raw: ascii.encode(mime),
      outerProtection: ImipProtection.none,
      mailbox: mailbox,
      namespace: 'example.freebusy',
      deliveryKey: commandId.toString(),
      originRef: 'synthetic-freebusy:${actor.principalId}',
    );
  }

  void _development(Session session) {
    if (!{'development', 'test'}.contains(session.serverpod.runMode)) {
      throw CalendarException(
        code: CalendarFailureCode.accessDenied,
        message: 'Synthetic fixtures are disabled',
      );
    }
  }
}
