import 'dart:convert';
import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

final class _Storage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async {
    value = data;
  }
}

Future<void> freeBusyExchangeSmoke(
  List<Client> clients,
  String bobPassword,
) async {
  if (clients.length != 2) throw StateError('Two hosts required');
  final a = clients.first.modules.serverpod_calendar;
  final b = clients.last.modules.serverpod_calendar;
  final bob = Client(clients.last.host)
    ..authSessionManager = ClientAuthSessionManager(storage: _Storage());
  final anonymous = Client(clients.first.host);
  cal.UuidValue? calendar, event;
  void require(bool ok, String message) {
    if (!ok) throw StateError(message);
  }

  Future<void> denied(Future<Object?> Function() action) async {
    try {
      await action();
    } on cal.CalendarException catch (e) {
      if (e.code == cal.CalendarFailureCode.accessDenied) return;
      rethrow;
    }
    throw StateError('Private exchange boundary did not deny access');
  }

  try {
    var unauthorized = false;
    try {
      await anonymous.modules.serverpod_calendar.calendarFreeBusyExchange
          .listFreeBusyInbox(pageSize: 20);
    } on ServerpodClientUnauthorized {
      unauthorized = true;
    }
    require(unauthorized, 'Anonymous exchange endpoint allowed access');
    final auth = await bob.emailIdp.login(
      email: 'bob@example.invalid',
      password: bobPassword,
    );
    await bob.auth.updateSignedInUser(auth);
    calendar = (await a.calendar.create(
      cal.CalendarCreateRequest(
        displayName: 'Generated-client busy messages',
        availabilityZoneId: 'Europe/Stockholm',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!.calendarId;
    event = (await a.calendarEvent.create(
      cal.CalendarEventCreateRequest(
        calendarId: calendar,
        content: cal.CalendarEventContent(
          summary: 'Synthetic private booking',
          timing: cal.CalendarEventTiming(
            kind: cal.CalendarEventTimeKind.utc,
            start: cal.CalendarEventCivil(
              year: 2030,
              month: 11,
              day: 6,
              hour: 9,
            ),
            duration: cal.CalendarEventDuration(hours: 1),
          ),
        ),
      ),
    ))!.eventId;
    final query = cal.CalendarFreeBusyQuery(
      calendarId: calendar,
      fromUtc: DateTime.utc(2030, 11, 6),
      untilUtc: DateTime.utc(2030, 11, 7),
    );
    final before = (await a.calendar.freeBusy(query)).toJson();
    final request = cal.CalendarFreeBusyPublishRequest(
      commandId: cal.Uuid().v4obj(),
      calendarId: calendar,
      fromUtc: query.fromUtc,
      untilUtc: query.untilUtc,
      recipients: ['mailto:respondent@example.invalid'],
    );
    final published = await a.calendarFreeBusyExchange.publishFreeBusy(request);
    final retried = await b.calendarFreeBusyExchange.publishFreeBusy(request);
    require(
      jsonEncode(published.toJson()) == jsonEncode(retried.toJson()),
      'Cross-host receipt changed',
    );
    await denied(
      () => bob.modules.serverpod_calendar.calendarFreeBusyExchange
          .publishFreeBusy(request),
    );
    await denied(
      () => bob.modules.serverpod_calendar.calendarFreeBusyExchange
          .freeBusyDeliveryActivity(published.id, pageSize: 20),
    );
    final requested = await b.calendarFreeBusyExchange.requestFreeBusy(
      request.copyWith(commandId: cal.Uuid().v4obj()),
    );
    final reply = await clients.first.freeBusyDemo.simulateReply(
      requested.id,
      cal.Uuid().v4obj(),
    );
    final header = await b.calendarFreeBusyExchange.getFreeBusyMessage(
      reply.sourceId,
    );
    require(
      header.method == 'reply' && !header.header.contains('FREEBUSY:'),
      'Header disclosed source periods',
    );
    await denied(
      () => bob.modules.serverpod_calendar.calendarFreeBusyExchange
          .getFreeBusyMessage(reply.sourceId),
    );
    await denied(
      () => bob.modules.serverpod_calendar.calendarFreeBusyExchange
          .getFreeBusySource(reply.sourceId),
    );
    final incoming = await clients.last.freeBusyDemo.simulate(
      calendar,
      cal.Uuid().v4obj(),
      query.fromUtc,
      query.untilUtc,
      publish: false,
    );
    final current = await a.calendarFreeBusyExchange.getFreeBusyMessage(
      incoming.sourceId,
    );
    final refusalRequest = cal.CalendarFreeBusyReplyRequest(
      commandId: cal.Uuid().v4obj(),
      sourceId: incoming.sourceId,
      expectedSourceRevision: current.sourceRevision!,
      expectedReplyRevision: current.replyRevision!,
    );
    final refused = await a.calendarFreeBusyExchange.refuseFreeBusy(
      refusalRequest,
    );
    require(
      jsonEncode(
            (await b.calendarFreeBusyExchange.refuseFreeBusy(refusalRequest))
                .toJson(),
          ) ==
          jsonEncode(refused.toJson()),
      'Refusal retry changed',
    );
    await b.calendarFreeBusyExchange.dismissFreeBusyMessage(incoming.sourceId);
    require(
      (await a.calendar.freeBusy(query)).toJson().toString() ==
          before.toString(),
      'Receiving/replying changed native availability',
    );
    final bytes = await b.calendarFreeBusyExchange.getFreeBusySource(
      incoming.sourceId,
    );
    final text = utf8.decode(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    require(
      text.contains('BEGIN:VFREEBUSY') &&
          !text.contains(calendar.toString()) &&
          !text.contains(event.toString()),
      'Source fixture leaked native lookup IDs',
    );
    await b.calendarFreeBusyExchange.withdrawFreeBusyCommand(requested.id);
    final page = await a.calendarFreeBusyExchange.listFreeBusyOutgoing(
      pageSize: 50,
    );
    require(
      page.items.any((v) => v.id == published.id),
      'Shared outgoing state missing',
    );
    await b.calendarEvent.deleteEvent(event, 1);
    event = null;
    require(
      jsonEncode(
            (await a.calendarFreeBusyExchange.publishFreeBusy(request))
                .toJson(),
          ) ==
          jsonEncode(published.toJson()),
      'Scrubbed retry did not retain opaque receipt',
    );
    require(
      !(await b.calendarFreeBusyExchange.listFreeBusyOutgoing(pageSize: 50))
          .items
          .any((v) => v.id == published.id),
      'Scrubbed marker remained discoverable',
    );
    await a.calendar.delete(calendar, 1);
    calendar = null;
    require(
      jsonEncode(
            (await b.calendarFreeBusyExchange.publishFreeBusy(request))
                .toJson(),
          ) ==
          jsonEncode(published.toJson()),
      'Deleted-calendar retry reactivated or lost identity',
    );
    stdout.writeln(
      'PASS: JWT/generated VFREEBUSY clients, two-host state/receipts, independent private ownership, informational MIME intake and deletion-marker retries.',
    );
  } finally {
    if (event != null) await a.calendarEvent.deleteEvent(event, 1);
    if (calendar != null) await a.calendar.delete(calendar, 1);
    bob.close();
    anonymous.close();
  }
}
