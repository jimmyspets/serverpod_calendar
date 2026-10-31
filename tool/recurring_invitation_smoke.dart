import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> recurringInvitationSmoke(List<Client> clients) async {
  final a = clients.first, b = clients.last;
  final api = a.modules.serverpod_calendar,
      other = b.modules.serverpod_calendar;
  final id = const cal.Uuid().v4obj(), key = const cal.Uuid().v4obj();
  cal.CalendarInvitationReceipt? incoming;
  cal.UuidValue? calendar, event;
  void require(bool value, String message) {
    if (!value) throw StateError(message);
  }

  Future<cal.CalendarInvitationApplyRequest> request() async {
    final view = await other.calendarInvitation.application(incoming!.entryId);
    return cal.CalendarInvitationApplyRequest(
      invitationId: incoming!.entryId,
      sourceId: view.incomingSourceId!,
      expectedInvitationRevision: view.invitationRevision!,
      linkId: view.linkId,
      expectedEventRevision: view.eventRevision,
      expectedCalendarRevision: view.calendarRevision,
      expectedApplicationRevision: view.applicationRevision,
    );
  }

  try {
    final received = await Future.wait(
      clients.map(
        (c) => c.invitationDemo.simulateRecurring(
          id,
          key,
          null,
          'Recurring recipient race',
        ),
      ),
    );
    incoming = received.first;
    require(
      received.first.id == received.last.id,
      'Recurring ingress duplicated receipt',
    );
    require(
      (await other.calendarInvitation.getInvitation(incoming.entryId))
          .recurring,
      'Recurring mode missing from generated response',
    );
    final response = cal.CalendarInvitationResponseRequest(
      invitationId: incoming.entryId,
      sourceId: incoming.sourceId,
      expectedInvitationRevision: incoming.entryRevision,
      expectedResponseRevision: 0,
      commandId: const cal.Uuid().v4obj(),
      choice: cal.CalendarInvitationResponseChoice.declined,
    );
    final replies = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation.sendResponse(
          response,
        ),
      ),
    );
    require(
      replies.first.id == replies.last.id,
      'Master response retry duplicated intent',
    );
    require(
      await other.calendarInvitation.link(incoming.entryId) == null,
      'Declining implicitly adopted recurring event',
    );
    calendar = (await api.calendar.create(
      cal.CalendarCreateRequest(
        displayName: 'Recurring recipient smoke',
        availabilityZoneId: 'Etc/UTC',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!.calendarId;
    final adoption = cal.CalendarInvitationAdoptionRequest(
      invitationId: incoming.entryId,
      sourceId: incoming.sourceId,
      expectedRevision: incoming.entryRevision,
      calendarId: calendar,
      expectedCalendarRevision: 1,
    );
    final links = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation.adopt(adoption),
      ),
    );
    event = links.first.eventId;
    require(
      event == links.last.eventId,
      'Recurring adoption race duplicated series',
    );
    final occurrences = await other.calendarEvent.listOccurrences(
      cal.CalendarEventOccurrenceListQuery(
        calendarId: calendar,
        fromUtc: DateTime.utc(2030, 1, 1),
        untilUtc: DateTime.utc(2030, 1, 7),
        pageSize: 10,
        fieldGroups: [],
      ),
    );
    require(
      occurrences.occurrences.length == 3 &&
          occurrences.occurrences.last.occurrence.endUtc!.hour == 11,
      'Recurring adoption lost exclusion or PERIOD length',
    );
    await b.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      1,
      'Reviewed recurring update',
    );
    final apply = await request();
    final updates = await Future.wait(
      clients.map(
        (c) =>
            c.modules.serverpod_calendar.calendarInvitation.applyUpdate(apply),
      ),
    );
    require(
      updates.first.id == updates.last.id,
      'Recurring update race changed retry identity',
    );
    await a.invitationDemo.simulateCancellation(
      id,
      const cal.Uuid().v4obj(),
      2,
    );
    require(
      (await other.calendarInvitation.getInvitation(incoming.entryId))
          .recurring,
      'Minimal cancellation erased known mode',
    );
    final cancel = await request();
    await other.calendarInvitation.applyCancellation(cancel);
    require(
      (await api.calendarEvent.getEvent(event, [
            cal.CalendarEventFieldGroup.state,
          ])).status ==
          cal.CalendarEventStatus.cancelled,
      'Whole-series cancellation was not applied',
    );
    await b.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      3,
      'Explicit recurring reopen',
    );
    await api.calendarInvitation.applyUpdate(await request());
    require(
      (await other.calendarEvent.getEvent(event, [
            cal.CalendarEventFieldGroup.state,
          ])).status ==
          cal.CalendarEventStatus.confirmed,
      'Explicit recurring REQUEST did not reopen',
    );
    var rejected = false;
    try {
      await b.invitationDemo.simulate(
        id,
        const cal.Uuid().v4obj(),
        9,
        'Forbidden mode conversion',
      );
    } on cal.CalendarException catch (e) {
      rejected = e.code == cal.CalendarFailureCode.validation;
    }
    require(rejected, 'Higher source sequence converted recurring mode');
    stdout.writeln(
      'PASS: two-host recurring-master ingress/adoption/update/response races, no-adoption decline, preserved PERIOD/exclusions, explicit whole-series cancellation/reopening and mode-conversion rejection.',
    );
  } finally {
    if (incoming != null) {
      final view = await other.calendarInvitation.getInvitation(
        incoming.entryId,
      );
      if (view.dismissedAt == null) {
        await other.calendarInvitation.dismiss(view.id, view.revision);
      }
    }
    if (event != null) {
      final view = await other.calendarEvent.getEvent(event, []);
      await other.calendarEvent.deleteEvent(event, view.revision);
    }
    if (calendar != null) await other.calendar.delete(calendar, 1);
  }
}
