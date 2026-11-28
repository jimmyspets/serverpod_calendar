import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> invitationBundleSmoke(List<Client> clients) async {
  final a = clients.first, b = clients.last;
  final api = a.modules.serverpod_calendar;
  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic bundled invitation',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  final uid = const cal.Uuid().v4obj(), key = const cal.Uuid().v4obj();
  cal.CalendarInvitationReceipt? received;
  cal.UuidValue? event;
  void require(bool value, String message) {
    if (!value) throw StateError(message);
  }

  try {
    final intake = await Future.wait(
      clients.map(
        (c) => c.invitationDemo.simulateBundle(
          uid,
          key,
          null,
          'Synthetic complete invitation',
        ),
      ),
    );
    received = intake.first;
    require(
      received.id == intake.last.id,
      'Bundle ingress race changed receipt',
    );
    final view = await b.modules.serverpod_calendar.calendarInvitation
        .getInvitation(received.entryId);
    require(
      view.kind == cal.CalendarInvitationSourceKind.requestBundle &&
          view.recurring,
      'Bundle source profile lost',
    );
    final source = await api.calendarInvitation.source(
      received.entryId,
      received.sourceId,
    );
    require(
      source.text.contains('RANGE=THISANDFUTURE'),
      'Source review lost future component',
    );
    final request = cal.CalendarInvitationAdoptionRequest(
      invitationId: received.entryId,
      expectedRevision: 1,
      sourceId: received.sourceId,
      calendarId: calendar,
      expectedCalendarRevision: 1,
    );
    final added = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation.adopt(request),
      ),
    );
    event = added.first.eventId;
    require(
      added.first.id == added.last.id && added.first.bundledRequest,
      'Bundle adoption race lost identity/profile',
    );
    final preview = await b.modules.serverpod_calendar.calendarEvent.preview(
      cal.CalendarEventOccurrenceQuery(
        eventId: event,
        expectedRevision: 1,
        fromUtc: DateTime.utc(2030),
        untilUtc: DateTime.utc(2030, 1, 9),
        fieldGroups: [cal.CalendarEventFieldGroup.summary],
      ),
    );
    require(
      preview.occurrences.length == 3,
      'Whole-series preview lost an original',
    );
    final retry = await b.modules.serverpod_calendar.calendarInvitation.adopt(
      request,
    );
    require(
      retry.toJson().toString() == added.first.toJson().toString(),
      'Retained bundle adoption changed result',
    );
    cal.CalendarInvitationApplyRequest updateCommand(
      cal.CalendarInvitationBundleApplicationView view,
    ) => cal.CalendarInvitationApplyRequest(
      invitationId: view.invitationId,
      sourceId: view.incomingSourceId!,
      expectedInvitationRevision: view.invitationRevision!,
      linkId: view.linkId,
      expectedEventRevision: view.eventRevision,
      expectedCalendarRevision: view.calendarRevision,
      expectedApplicationRevision: view.applicationRevision,
    );
    await a.invitationDemo.simulateBundleUpdate(
      uid,
      const cal.Uuid().v4obj(),
      1,
      null,
      'Synthetic complete invitation',
    );
    final firstView = await b.modules.serverpod_calendar.calendarInvitation
        .bundleApplication(received.entryId);
    final firstUpdate = updateCommand(firstView);
    final applied = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation
            .applyBundleUpdate(firstUpdate),
      ),
    );
    require(
      applied.first.id == applied.last.id && applied.first.eventRevision == 2,
      'Child-only bundle application lost atomic retry identity',
    );
    require(
      (await api.calendarInvitation.bundleApplication(received.entryId))
              .acceptedComponents
              .singleWhere((v) => v.originalStart == null)
              .sequence ==
          null,
      'Child-only update invented a master version',
    );
    await b.invitationDemo.simulateBundleUpdate(
      uid,
      const cal.Uuid().v4obj(),
      2,
      1,
      'Synthetic updated invitation',
    );
    final secondView = await api.calendarInvitation.bundleApplication(
      received.entryId,
    );
    final secondUpdate = updateCommand(secondView);
    final second = await b.modules.serverpod_calendar.calendarInvitation
        .applyBundleUpdate(secondUpdate);
    require(
      second.eventRevision == 3 && second.applicationRevision == 2,
      'Complete bundle update did not advance once',
    );
    var rejected = false;
    try {
      await b.invitationDemo.simulateBundleUpdate(
        uid,
        const cal.Uuid().v4obj(),
        1,
        2,
        'Synthetic updated invitation',
      );
    } on cal.CalendarException catch (e) {
      rejected = e.code == cal.CalendarFailureCode.validation;
    }
    require(rejected, 'Regressing bundle entered scalar reconciliation');
    final current = await api.calendarEvent.getEvent(
      event,
      cal.CalendarEventFieldGroup.values,
    );
    await api.calendarEvent.update(
      cal.CalendarEventUpdateRequest(
        eventId: event,
        expectedRevision: current.revision,
        content: cal.CalendarEventContent(
          timing: current.timing!,
          summary: 'Private draft',
          description: current.description,
          location: current.location,
          status: current.status!,
          transparency: current.transparency!,
          recurrence: current.recurrence,
          periods: current.periods,
          textParameters: current.textParameters,
        ),
      ),
    );
    await a.invitationDemo.simulateBundleUpdate(
      uid,
      const cal.Uuid().v4obj(),
      3,
      1,
      'Synthetic updated invitation',
    );
    final dirty = await api.calendarInvitation.bundleApplication(
      received.entryId,
    );
    require(
      dirty.hasLocalChanges && !dirty.canApply,
      'Local bundle edit did not block application',
    );
    require(
      (await b.modules.serverpod_calendar.calendarInvitation.applyBundleUpdate(
            secondUpdate,
          )).id ==
          second.id,
      'Retained update retry rewrote a private draft',
    );
    stdout.writeln(
      'PASS: two JWT hosts, complete MIME bundles, one-event adoption/application races, child-only and mixed versions, rejected regressions and draft-preserving latest retries.',
    );
  } finally {
    if (received != null) {
      final current = await api.calendarInvitation.getInvitation(
        received.entryId,
      );
      if (current.dismissedAt == null) {
        await api.calendarInvitation.dismiss(current.id, current.revision);
      }
    }
    if (event != null) {
      final current = await api.calendarEvent.getEvent(event, []);
      await api.calendarEvent.deleteEvent(event, current.revision);
    }
    await api.calendar.delete(calendar, 1);
  }
}
