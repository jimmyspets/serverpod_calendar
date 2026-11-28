import 'dart:async';
import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

/// Real generated-client writes race across independent example host processes.
Future<void> schedulingSmoke(List<Client> clients) async {
  final a = clients.first.modules.serverpod_calendar;
  final b = clients.last.modules.serverpod_calendar;
  final calendar = (await a.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic organizer publication',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  cal.CalendarEventContent content(String title) => cal.CalendarEventContent(
    summary: title,
    recurrence: cal.CalendarEventRecurrence(
      rule: cal.CalendarEventRule(
        frequency: cal.CalendarEventFrequency.daily,
        count: 4,
        byDay: [],
        byMonthDay: [],
        byYearDay: [],
        byWeekNo: [],
        byMonth: [],
        byHour: [],
        byMinute: [],
        bySetPosition: [],
      ),
      inclusions: [],
      exclusions: [],
    ),
    timing: cal.CalendarEventTiming(
      kind: cal.CalendarEventTimeKind.utc,
      start: cal.CalendarEventCivil(year: 2026, month: 11, day: 1, hour: 9),
    ),
  );
  final event = (await a.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: calendar.calendarId,
      content: content('Local draft'),
    ),
  ))!;
  await b.calendarEvent.changeOccurrence(
    cal.CalendarEventOccurrenceChange(
      eventId: event.eventId,
      expectedRevision: 1,
      originalStart: cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.utc,
        start: cal.CalendarEventCivil(year: 2026, month: 11, day: 2, hour: 9),
      ),
      action: cal.CalendarEventOccurrenceAction.replaceSingleTiming,
      replacement: cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.utc,
        start: cal.CalendarEventCivil(year: 2026, month: 11, day: 2, hour: 10),
      ),
    ),
  );
  final command = cal.CalendarSchedulingSaveRequest(
    eventId: event.eventId,
    expectedRevision: 2,
    content: content('Explicit invitation'),
    recipients: ['mailto:bob@example.invalid'],
    commandId: cal.Uuid().v4obj(),
  );
  final receipts = await Future.wait([
    a.calendarEvent.saveAndNotify(command),
    b.calendarEvent.saveAndNotify(command),
  ]);
  if (receipts[0].publicationId != receipts[1].publicationId ||
      receipts.where((r) => !r.unchanged).length != 1) {
    throw StateError('Concurrent idempotent publication was not atomic');
  }
  final status = await b.calendarEvent.schedulingStatus(event.eventId);
  if (status.eventRevision != 3 ||
      status.hasLocalChanges ||
      status.origin != cal.CalendarEventOrigin.native) {
    throw StateError('Cross-host publication checkpoint differs');
  }
  final writes = await Future.wait([
    for (final api in [a, b])
      () async {
        try {
          await api.calendarEvent.saveAndNotify(
            command.copyWith(
              expectedRevision: 3,
              commandId: cal.Uuid().v4obj(),
              content: content('Concurrent update ${api == a ? 'A' : 'B'}'),
            ),
          );
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code != cal.CalendarFailureCode.staleRevision) rethrow;
          return false;
        }
      }(),
  ]);
  if (writes.where((v) => v).length != 1) {
    throw StateError('Expected revision race accepted both publications');
  }
  var before = await a.calendarEvent.schedulingStatus(event.eventId);
  await b.calendarEvent.changeOccurrence(
    cal.CalendarEventOccurrenceChange(
      eventId: event.eventId,
      expectedRevision: before.eventRevision,
      originalStart: cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.utc,
        start: cal.CalendarEventCivil(year: 2026, month: 11, day: 2, hour: 9),
      ),
      action: cal.CalendarEventOccurrenceAction.clearSingleTiming,
    ),
  );
  final reset = command.copyWith(
    expectedRevision: before.eventRevision + 1,
    commandId: cal.Uuid().v4obj(),
    content: content('Reset across hosts'),
  );
  final resetReceipts = await Future.wait([
    a.calendarEvent.saveAndNotify(reset),
    b.calendarEvent.saveAndNotify(reset),
  ]);
  if (resetReceipts[0].publicationId != resetReceipts[1].publicationId ||
      resetReceipts.where((r) => !r.unchanged).length != 1 ||
      (await a.calendarEvent.getEvent(
            event.eventId,
            cal.CalendarEventFieldGroup.values,
          )).timingOverrides !=
          null) {
    throw StateError(
      'Cross-host reset changed native inheritance or lost idempotency',
    );
  }
  before = await a.calendarEvent.schedulingStatus(event.eventId);
  await a.calendarEvent.update(
    cal.CalendarEventUpdateRequest(
      eventId: event.eventId,
      expectedRevision: before.eventRevision,
      content: content('Unpublished local edit'),
    ),
  );
  if (!(await b.calendarEvent.schedulingStatus(event.eventId))
      .hasLocalChanges) {
    throw StateError('Local edit was silently published');
  }
  // Recurring host maintenance claims shared work; acceptance is synthetic only.
  var accepted = false;
  for (var i = 0; i < 100; i++) {
    final current = await b.calendarEvent.schedulingStatus(event.eventId);
    if (current.deliveries.every(
      (d) => d.state == cal.CalendarSchedulingDeliveryState.accepted,
    )) {
      accepted = true;
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  if (!accepted) {
    throw StateError('Independent hosts did not dispatch synthetic intent');
  }
  final ready = await a.calendarEvent.schedulingStatus(event.eventId);
  final cancel = cal.CalendarSchedulingCancelRequest(
    eventId: event.eventId,
    expectedRevision: ready.eventRevision,
    commandId: cal.Uuid().v4obj(),
  );
  final cancellations = await Future.wait([
    a.calendarEvent.cancelAndNotify(cancel),
    b.calendarEvent.cancelAndNotify(cancel),
  ]);
  if (cancellations[0].publicationId != cancellations[1].publicationId ||
      cancellations.where((r) => !r.unchanged).length != 1) {
    throw StateError('Cross-host cancellation retry queued duplicate intent');
  }
  final cancelled = await b.calendarEvent.schedulingStatus(event.eventId);
  if (cancelled.method != 'CANCEL' ||
      cancelled.eventRevision != ready.eventRevision + 1 ||
      !(await a.calendarEvent.getEvent(
        event.eventId,
        cal.CalendarEventFieldGroup.values,
      )).summary!.contains('Unpublished')) {
    throw StateError('Cancellation lost native drafts or method identity');
  }
  await b.calendarEvent.saveAndNotify(
    command.copyWith(
      expectedRevision: cancelled.eventRevision,
      commandId: cal.Uuid().v4obj(),
      content: content('Reopened explicitly'),
    ),
  );
  if ((await a.calendarEvent.schedulingStatus(event.eventId)).method !=
      'REQUEST') {
    throw StateError('Explicit reopening did not publish REQUEST');
  }

  Future<void> terminal() async {
    for (var i = 0; i < 100; i++) {
      final status = await b.calendarEvent.schedulingStatus(event.eventId);
      if (status.deliveries.every(
        (d) => d.state == cal.CalendarSchedulingDeliveryState.accepted,
      )) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    throw StateError('Prior scheduling deliveries did not terminate');
  }

  await terminal();
  var state = await a.calendarEvent.schedulingStatus(event.eventId);
  final oldPoint = cal.CalendarEventTiming(
    kind: cal.CalendarEventTimeKind.utc,
    start: cal.CalendarEventCivil(year: 2026, month: 11, day: 2, hour: 9),
  );
  final currentPoint = oldPoint.copyWith(
    start: cal.CalendarEventCivil(year: 2026, month: 11, day: 3, hour: 9),
  );
  final privateContent = content('Private historical cancellation draft');
  await a.calendarEvent.update(
    cal.CalendarEventUpdateRequest(
      eventId: event.eventId,
      expectedRevision: state.eventRevision,
      content: privateContent.copyWith(
        recurrence: privateContent.recurrence!.copyWith(exclusions: [oldPoint]),
      ),
    ),
  );
  state = await b.calendarEvent.schedulingStatus(event.eventId);
  final instance = cal.CalendarSchedulingOccurrenceCancelRequest(
    eventId: event.eventId,
    expectedRevision: state.eventRevision,
    commandId: cal.Uuid().v4obj(),
    originalStart: currentPoint,
  );
  final both = await Future.wait([
    a.calendarEvent.cancelOccurrenceAndNotify(instance),
    b.calendarEvent.cancelOccurrenceAndNotify(instance),
  ]);
  if (both[0].publicationId != both[1].publicationId ||
      both.where((r) => !r.unchanged).length != 1) {
    throw StateError(
      'Cross-host instance cancellation lost command idempotency',
    );
  }
  await terminal();
  state = await b.calendarEvent.schedulingStatus(event.eventId);
  final historical = instance.copyWith(
    expectedRevision: state.eventRevision,
    originalStart: oldPoint,
  );
  final raced = await Future.wait([
    for (final api in [a, b])
      () async {
        try {
          await api.calendarEvent.cancelOccurrenceAndNotify(
            historical.copyWith(commandId: cal.Uuid().v4obj()),
          );
          return true;
        } on cal.CalendarException catch (e) {
          if (![
            cal.CalendarFailureCode.staleRevision,
            cal.CalendarFailureCode.dependencyConflict,
          ].contains(e.code)) {
            rethrow;
          }
          return false;
        }
      }(),
  ]);
  if (raced.where((v) => v).length != 1) {
    throw StateError(
      'Concurrent historical cancellations both changed the revision',
    );
  }
  final saved = await b.calendarEvent.getEvent(
    event.eventId,
    cal.CalendarEventFieldGroup.values,
  );
  final current = await a.calendarEvent.schedulingStatus(event.eventId);
  if (saved.summary != 'Private historical cancellation draft' ||
      saved.timingOverrides!.singles.length != 1 ||
      saved.timingOverrides!.singles.single.originalStart.start.day != 3 ||
      current.publicationKind !=
          cal.CalendarSchedulingPublicationKind.occurrenceCancel ||
      current.originalStart!.start.day != 2 ||
      !current.hasLocalChanges ||
      !current.hasOccurrenceCancellations) {
    throw StateError(
      'Historical cancellation changed native drafts or confused status',
    );
  }
  final oldRetry = await a.calendarEvent.cancelOccurrenceAndNotify(instance);
  if (!oldRetry.unchanged ||
      oldRetry.publicationId != both.first.publicationId) {
    throw StateError('Retained cross-host retry changed bytes');
  }
  try {
    await b.calendarEvent.saveAndNotify(
      command.copyWith(
        expectedRevision: current.eventRevision,
        commandId: cal.Uuid().v4obj(),
      ),
    );
    throw StateError('REQUEST silently reopened cancelled originals');
  } on cal.CalendarException catch (e) {
    if (e.code != cal.CalendarFailureCode.dependencyConflict) rethrow;
  }
  await a.calendarEvent.cancelAndNotify(
    cal.CalendarSchedulingCancelRequest(
      eventId: event.eventId,
      expectedRevision: current.eventRevision,
      commandId: cal.Uuid().v4obj(),
    ),
  );
  stdout.writeln(
    'PASS: two-host recurring occurrence-bundle publication and retained resets, idempotency/revision races, local draft isolation, cancellation/reopening, v4 current/historical instance cancellation races and synthetic acceptance.',
  );
  // Bindings deliberately reject deletion in the first profile. Isolated test
  // storage is reset by the root harness; no public cleanup backdoor is added.
}
