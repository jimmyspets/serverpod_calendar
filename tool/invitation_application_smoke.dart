import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> invitationApplicationSmoke(List<Client> clients) async {
  final a = clients.first,
      b = clients.last,
      api = a.modules.serverpod_calendar,
      other = b.modules.serverpod_calendar;
  final id = const cal.Uuid().v4obj();
  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic explicit updates',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  final source = await a.invitationDemo.simulate(
    id,
    const cal.Uuid().v4obj(),
    null,
    'Original update example',
  );
  final creation = cal.CalendarInvitationAdoptionRequest(
    invitationId: source.entryId,
    sourceId: source.sourceId,
    expectedRevision: 1,
    calendarId: calendar,
    expectedCalendarRevision: 1,
  );
  final link = await api.calendarInvitation.adopt(creation);
  cal.CalendarInvitationApplyRequest body(
    cal.CalendarInvitationApplicationView v,
  ) => cal.CalendarInvitationApplyRequest(
    invitationId: v.invitationId,
    sourceId: v.incomingSourceId!,
    expectedInvitationRevision: v.invitationRevision!,
    linkId: v.linkId,
    expectedEventRevision: v.eventRevision,
    expectedCalendarRevision: v.calendarRevision,
    expectedApplicationRevision: v.applicationRevision,
  );
  void require(bool value, String message) {
    if (!value) {
      throw StateError(message);
    }
  }

  Future<String> outcome(Future<Object?> Function() action) async {
    try {
      await action();
      return 'saved';
    } on cal.CalendarException catch (e) {
      return e.code.name;
    }
  }

  try {
    await b.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      1,
      'First source update',
    );
    final first = body(
      await api.calendarInvitation.application(source.entryId),
    );
    final raced = await Future.wait(
      clients.map(
        (c) =>
            c.modules.serverpod_calendar.calendarInvitation.applyUpdate(first),
      ),
    );
    require(
      raced.first.id == raced.last.id && raced.first.eventRevision == 2,
      'Concurrent update did not preserve stable latest receipt',
    );
    require(
      (await other.calendarInvitation.adopt(creation)).id == link.id,
      'Update changed creation receipt',
    );
    await a.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      2,
      'Second source update',
    );
    var view = await other.calendarInvitation.application(source.entryId);
    var latest = body(view);
    cal.CalendarInvitationApplyReceipt? result;
    final race = await Future.wait([
      outcome(() async {
        result = await api.calendarInvitation.applyUpdate(latest);
        return result;
      }),
      outcome(
        () => other.calendarEvent.update(
          cal.CalendarEventUpdateRequest(
            eventId: link.eventId,
            expectedRevision: view.eventRevision,
            content: view.currentContent,
          ),
        ),
      ),
    ]);
    require(
      race.where((v) => v == 'saved').length == 1 &&
          race.contains('staleRevision'),
      'Local-save/update race did not reject one stale writer',
    );
    if (result == null) {
      latest = body(await other.calendarInvitation.application(source.entryId));
      result = await api.calendarInvitation.applyUpdate(latest);
    }
    require(
      await outcome(() => other.calendarInvitation.applyUpdate(first)) ==
          'staleRevision',
      'Superseded command replayed an earlier update',
    );
    await b.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      3,
      'Pending source after local changes',
    );
    view = await api.calendarInvitation.application(source.entryId);
    await other.calendarEvent.update(
      cal.CalendarEventUpdateRequest(
        eventId: link.eventId,
        expectedRevision: view.eventRevision,
        content: view.currentContent.copyWith(summary: 'Local update draft'),
      ),
    );
    final conflict = await other.calendarInvitation.application(source.entryId);
    require(
      conflict.hasLocalChanges && !conflict.canApply,
      'Local source conflict was reported clean',
    );
    require(
      await outcome(() => api.calendarInvitation.applyUpdate(body(conflict))) ==
          'dependencyConflict',
      'Source erased local changes',
    );
    final latestResult = result;
    if (latestResult == null) {
      throw StateError('Missing accepted update result');
    }
    require(
      (await other.calendarInvitation.applyUpdate(latest)).id ==
          latestResult.id,
      'Latest retry changed result after local edits',
    );
    require(
      (await api.calendarInvitation.getInvitation(source.entryId))
              .dismissedAt ==
          null,
      'Latest retry dismissed newer review',
    );
    require(
      (await api.calendarInvitation.adopt(creation)).id == link.id,
      'Creation retry failed after updates/local edits',
    );

    final cancelCommand = const cal.Uuid().v4obj();
    final cancellations = await Future.wait([
      a.invitationDemo.simulateCancellation(id, cancelCommand, 4),
      b.invitationDemo.simulateCancellation(id, cancelCommand, 4),
    ]);
    require(
      cancellations.first.id == cancellations.last.id,
      'Cancellation duplicate receipts differ',
    );
    final cancelled = await other.calendarInvitation.application(
      source.entryId,
    );
    require(
      cancelled.incomingKind ==
              cal.CalendarInvitationSourceKind.meetingCancellation &&
          !cancelled.canApply &&
          cancelled.incomingContent == null &&
          cancelled.currentContent.summary == conflict.currentContent.summary &&
          cancelled.eventRevision == conflict.eventRevision &&
          cancelled.applicationRevision == conflict.applicationRevision,
      'Cancellation receipt mutated event/checkpoint or implied application',
    );
    require(
      (await api.calendarInvitation.applyUpdate(latest)).id ==
              latestResult.id &&
          (await other.calendarInvitation.adopt(creation)).id == link.id &&
          (await api.calendarInvitation.getInvitation(source.entryId))
                  .dismissedAt ==
              null,
      'Retained REQUEST retries changed cancellation review',
    );
    final history = await other.calendarInvitation.sources(source.entryId);
    require(
      history.any((s) => s.kind == cal.CalendarInvitationSourceKind.request) &&
          history.any(
            (s) =>
                s.kind == cal.CalendarInvitationSourceKind.meetingCancellation,
          ),
      'Historical source kinds were flattened',
    );
    stdout.writeln(
      'PASS: two-host cancellation review, stable ingress and retained REQUEST retries, unchanged local drafts/checkpoint and independent source kinds.',
    );
    stdout.writeln(
      'PASS: two-host explicit source updates, stable latest results, native-save races, superseded retries and local-edit protection with unchanged creation identity.',
    );
  } finally {
    final entry = await api.calendarInvitation.getInvitation(source.entryId);
    if (entry.dismissedAt == null) {
      await api.calendarInvitation.dismiss(entry.id, entry.revision);
    }
    final event = await api.calendarEvent.getEvent(link.eventId, []);
    await api.calendarEvent.deleteEvent(link.eventId, event.revision);
    await api.calendar.delete(calendar, 1);
  }
}
