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
    final responseCommand = cal.CalendarInvitationResponseRequest(
      invitationId: received.entryId,
      sourceId: received.sourceId,
      expectedInvitationRevision: received.entryRevision,
      expectedResponseRevision: 0,
      commandId: const cal.Uuid().v4obj(),
      choice: cal.CalendarInvitationResponseChoice.declined,
    );
    final responses = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation
            .sendBundleResponse(responseCommand),
      ),
    );
    require(
      responses.first.id == responses.last.id &&
          (await api.calendarInvitation.bundleResponseActivity(
                received.entryId,
              )).single.sourceSequence ==
              null &&
          await api.calendarInvitation.link(received.entryId) == null,
      'Bundle master response changed source omission, retry identity or adoption',
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
      (await api.calendarInvitation.bundleResponse(received.entryId))
          .appliesToCurrentSource,
      'Calendar adoption withdrew the unchanged master response',
    );
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
    require(
      !(await api.calendarInvitation.bundleResponse(received.entryId))
              .appliesToCurrentSource &&
          (await api.calendarInvitation.sendBundleResponse(responseCommand))
                  .id ==
              responses.first.id &&
          (await api.calendarInvitation.bundleResponseActivity(
                received.entryId,
              )).length ==
              1,
      'Child-only update reactivated or rebased a master response',
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
    var latestCommand = secondUpdate;
    var latestResult = second;
    for (final sequence in [13, 15]) {
      final cancelKey = const cal.Uuid().v4obj();
      final notices = await Future.wait(
        clients.map(
          (c) =>
              c.invitationDemo.simulateCancellation(uid, cancelKey, sequence),
        ),
      );
      require(
        notices.first.id == notices.last.id,
        'Cancellation ingress race changed receipt',
      );
      final cancellation = await api.calendarInvitation.bundleApplication(
        received.entryId,
      );
      require(
        cancellation.canApplyCancellation &&
            cancellation.incomingComponents!.length == 1,
        'Cancellation review confused actual and retained vectors',
      );
      final cancelCommand = updateCommand(cancellation);
      final cancelled = await Future.wait(
        clients.map(
          (c) => c.modules.serverpod_calendar.calendarInvitation
              .applyBundleCancellation(cancelCommand),
        ),
      );
      require(
        cancelled.first.id == cancelled.last.id,
        'Cancellation race changed latest result',
      );
      final status = await b.modules.serverpod_calendar.calendarInvitation
          .bundleApplication(received.entryId);
      require(
        status.currentContent.status == cal.CalendarEventStatus.cancelled &&
            !status.hasLocalChanges &&
            status.acceptedCancellationVersion!.sequence == sequence &&
            status.acceptedComponents.length == 3,
        'Cancelled native state lost distinct source proof',
      );
      await b.invitationDemo.simulateBundleUpdate(
        uid,
        const cal.Uuid().v4obj(),
        2,
        sequence + 1,
        'Synthetic updated invitation',
      );
      final reopening = await api.calendarInvitation.bundleApplication(
        received.entryId,
      );
      require(
        reopening.canReopen,
        'Complete newer REQUEST did not allow explicit reopening',
      );
      latestCommand = updateCommand(reopening);
      final restored = await Future.wait(
        clients.map(
          (c) => c.modules.serverpod_calendar.calendarInvitation
              .applyBundleReopening(latestCommand),
        ),
      );
      latestResult = restored.first;
      require(
        restored.first.id == restored.last.id,
        'Reopening race changed latest result',
      );
    }

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
      16,
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
      (await b.modules.serverpod_calendar.calendarInvitation
                  .applyBundleReopening(latestCommand))
              .id ==
          latestResult.id,
      'Retained update retry rewrote a private draft',
    );
    stdout.writeln(
      'PASS: two JWT hosts, complete MIME bundles, one-event adoption/application races, child-only/mixed updates, whole cancellation/reopening cycles, independent versions and draft-preserving latest retries.',
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
