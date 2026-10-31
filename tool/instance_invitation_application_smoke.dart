import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> instanceInvitationApplicationSmoke(List<Client> clients) async {
  final a = clients.first, b = clients.last, api = b.modules.serverpod_calendar;
  final id = const cal.Uuid().v4obj();
  final master = await a.invitationDemo.simulateRecurring(
    id,
    const cal.Uuid().v4obj(),
    1,
    'Occurrence application client',
  );
  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Occurrence application client',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  cal.CalendarInvitationAdoptionReceipt? link;
  cal.UuidValue? entry;
  void require(bool value, String message) {
    if (!value) {
      throw StateError(message);
    }
  }

  cal.CalendarInvitationOccurrenceApplyRequest command(
    cal.CalendarInvitationOccurrenceApplicationView v,
  ) => cal.CalendarInvitationOccurrenceApplyRequest(
    invitationId: v.invitationId,
    sourceId: v.incomingSourceId!,
    linkId: v.linkId,
    expectedInvitationRevision: v.invitationRevision,
    expectedEventRevision: v.eventRevision,
    expectedCalendarRevision: v.calendarRevision,
    expectedApplicationRevision: v.applicationRevision,
    expectedOccurrenceRevision: v.occurrenceRevision,
  );
  try {
    link = await api.calendarInvitation.adopt(
      cal.CalendarInvitationAdoptionRequest(
        invitationId: master.entryId,
        sourceId: master.sourceId,
        expectedRevision: 1,
        calendarId: calendar,
        expectedCalendarRevision: 1,
      ),
    );
    final incoming = await a.invitationDemo.simulateOccurrence(
      id,
      const cal.Uuid().v4obj(),
      2,
      false,
    );
    entry = incoming.entryId;
    final view = await api.calendarInvitation.occurrenceApplication(entry);
    require(
      view.canApply && view.originalStart.start.day == 3,
      'Generated occurrence preview lost original',
    );
    final input = command(view);
    final race = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation
            .applyOccurrenceUpdate(input),
      ),
    );
    require(
      race.first.id == race.last.id && race.first.eventRevision == 2,
      'Cross-host occurrence apply duplicated effect',
    );
    await a.invitationDemo.simulateOccurrence(
      id,
      const cal.Uuid().v4obj(),
      3,
      true,
    );
    final cancellation = await api.calendarInvitation.occurrenceApplication(
      entry,
    );
    require(
      cancellation.canApply &&
          cancellation.incomingSourceText?.contains('DTSTART:') == false,
      'Cancellation invented timing or cannot apply',
    );
    final result = await api.calendarInvitation.applyOccurrenceCancellation(
      command(cancellation),
    );
    require(
      result.kind == cal.CalendarInvitationSourceKind.instanceCancellation &&
          result.eventRevision == 3,
      'Wrong occurrence cancellation result',
    );
    await a.invitationDemo.simulateOccurrence(
      id,
      const cal.Uuid().v4obj(),
      4,
      false,
    );
    final reopened = await api.calendarInvitation.applyOccurrenceUpdate(
      command(await api.calendarInvitation.occurrenceApplication(entry)),
    );
    require(reopened.eventRevision == 4, 'Explicit occurrence reopen failed');
    await a.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      5,
      'Composed master',
    );
    final masterView = await api.calendarInvitation.application(master.entryId);
    require(
      masterView.canApply &&
          masterView.occurrenceRevision == 3 &&
          !masterView.occurrenceCompositionBlocked,
      'Master composition unavailable',
    );
    final masterRequest = cal.CalendarInvitationApplyRequest(
      invitationId: masterView.invitationId,
      sourceId: masterView.incomingSourceId!,
      linkId: masterView.linkId,
      expectedInvitationRevision: masterView.invitationRevision!,
      expectedEventRevision: masterView.eventRevision,
      expectedCalendarRevision: masterView.calendarRevision,
      expectedApplicationRevision: masterView.applicationRevision,
      expectedOccurrenceRevision: masterView.occurrenceRevision,
    );
    final composed = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation.applyUpdate(
          masterRequest,
        ),
      ),
    );
    require(
      composed.first.id == composed.last.id &&
          composed.first.eventRevision == 5,
      'Master race duplicated composition',
    );
    final retained = await api.calendarInvitation.occurrenceApplication(entry);
    require(
      retained.occurrenceRevision == 4 &&
          retained.acceptedVersion.sequence == 4 &&
          retained.currentOccurrence!.summary == 'Synthetic occurrence update',
      'Master erased accepted occurrence',
    );
    stdout.writeln(
      'PASS: generated-client two-host occurrence preview/update race, minimal cancellation, explicit reopening, master composition race and independent occurrence preservation.',
    );
  } finally {
    if (link != null) {
      final event = await api.calendarEvent.getEvent(link.eventId, []);
      await api.calendarEvent.deleteEvent(link.eventId, event.revision);
    }
    await api.calendar.delete(calendar, 1);
    for (final e in [master.entryId, ?entry]) {
      final v = await api.calendarInvitation.getInvitation(e);
      if (v.dismissedAt == null) {
        await api.calendarInvitation.dismiss(e, v.revision);
      }
    }
  }
}
