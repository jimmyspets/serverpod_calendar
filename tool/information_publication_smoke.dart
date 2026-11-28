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

Future<void> informationPublicationSmoke(
  List<Client> clients,
  String bobPassword,
) async {
  if (clients.length != 2) throw StateError('Two independent hosts required');
  final a = clients.first.modules.serverpod_calendar,
      b = clients.last.modules.serverpod_calendar;
  final bob = Client(clients.last.host)
    ..authSessionManager = ClientAuthSessionManager(storage: _Storage());
  final anonymous = Client(clients.first.host);
  void require(bool value, String reason) {
    if (!value) throw StateError(reason);
  }

  Future<void> denied(Future<Object?> Function() action) async {
    try {
      await action();
    } on cal.CalendarException catch (e) {
      if (e.code == cal.CalendarFailureCode.accessDenied) return;
      rethrow;
    }
    throw StateError('Private/purpose boundary allowed access');
  }

  try {
    final auth = await bob.emailIdp.login(
      email: 'bob@example.invalid',
      password: bobPassword,
    );
    await bob.auth.updateSignedInUser(auth);
    final calendar = (await a.calendar.create(
      cal.CalendarCreateRequest(
        displayName: 'Synthetic information publication',
        availabilityZoneId: 'Europe/Stockholm',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!.calendarId;
    final content = cal.CalendarEventContent(
      summary: 'Published information',
      timing: cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.zoned,
        start: cal.CalendarEventCivil(year: 2027, month: 3, day: 28, hour: 9),
        zoneId: 'Europe/Stockholm',
        duration: cal.CalendarEventDuration(hours: 1),
      ),
    );
    final id = (await a.calendarEvent.create(
      cal.CalendarEventCreateRequest(calendarId: calendar, content: content),
    ))!.eventId;
    var unauthorized = false;
    try {
      await anonymous.modules.serverpod_calendar.calendarEvent
          .informationPublicationStatus(id);
    } on ServerpodClientUnauthorized {
      unauthorized = true;
    }
    require(unauthorized, 'Anonymous publication status allowed');
    await denied(
      () => bob.modules.serverpod_calendar.calendarEvent
          .informationPublicationStatus(id),
    );
    final input = cal.CalendarSchedulingSaveRequest(
      eventId: id,
      expectedRevision: 1,
      commandId: cal.Uuid().v4obj(),
      content: content,
      recipients: ['mailto:bob@example.invalid'],
    );
    final first = await a.calendarEvent.saveAndPublishInformation(input);
    final retry = await b.calendarEvent.saveAndPublishInformation(input);
    require(
      retry.unchanged && retry.publicationId == first.publicationId,
      'Cross-host receipt changed',
    );
    final status = await b.calendarEvent.informationPublicationStatus(id);
    require(
      status.purpose ==
              cal.CalendarSchedulingBindingPurpose.informationPublication &&
          status.method == 'PUBLISH',
      'Trusted purpose missing',
    );
    await denied(() => b.calendarEvent.schedulingStatus(id));
    final second = await b.calendarEvent.saveAndPublishInformation(
      input.copyWith(
        expectedRevision: 2,
        commandId: cal.Uuid().v4obj(),
        content: content.copyWith(summary: 'Published update'),
      ),
    );
    require(second.eventRevision == 3, 'Update revision mismatch');
    await a.calendarEvent.update(
      cal.CalendarEventUpdateRequest(
        eventId: id,
        expectedRevision: 3,
        content: content.copyWith(summary: 'Private newer draft'),
      ),
    );
    final cancellation = cal.CalendarSchedulingCancelRequest(
      eventId: id,
      expectedRevision: 4,
      commandId: cal.Uuid().v4obj(),
    );
    final cancelled = await b.calendarEvent.cancelPublishedInformation(
      cancellation,
    );
    final reopened = await a.calendarEvent.reopenPublishedInformation(
      cal.CalendarSchedulingReopenRequest(
        eventId: id,
        expectedRevision: 5,
        commandId: cal.Uuid().v4obj(),
      ),
    );
    require(reopened.eventRevision == 6, 'Lifecycle revision mismatch');
    require(
      (await b.calendarEvent.cancelPublishedInformation(cancellation))
              .publicationId ==
          cancelled.publicationId,
      'Historical cancellation receipt changed',
    );
    final current = await b.calendarEvent.getEvent(
      id,
      cal.CalendarEventFieldGroup.values,
    );
    require(
      current.summary == 'Private newer draft' &&
          current.status == cal.CalendarEventStatus.confirmed,
      'Lifecycle replaced native draft',
    );
    require(
      (await b.calendarEvent.informationPublicationStatus(id)).hasLocalChanges,
      'Private draft not distinguished',
    );
    // A second series exercises outgoing components and retained resets through
    // actual generated clients on both hosts, independently of ordinary export.
    final recurring = content.copyWith(
      recurrence: cal.CalendarEventRecurrence(
        rule: cal.CalendarEventRule(
          frequency: cal.CalendarEventFrequency.daily,
          count: 5,
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
    );
    final series = (await a.calendarEvent.create(
      cal.CalendarEventCreateRequest(calendarId: calendar, content: recurring),
    ))!.eventId;
    Future<cal.CalendarEventView> seriesView() =>
        b.calendarEvent.getEvent(series, cal.CalendarEventFieldGroup.values);
    cal.CalendarEventTiming point(int day) => cal.CalendarEventTiming(
      kind: cal.CalendarEventTimeKind.zoned,
      start: cal.CalendarEventCivil(year: 2027, month: 3, day: day, hour: 9),
      zoneId: 'Europe/Stockholm',
    );
    for (final future in [false, true]) {
      await a.calendarEvent.changeOccurrence(
        cal.CalendarEventOccurrenceChange(
          eventId: series,
          expectedRevision: (await seriesView()).revision,
          originalStart: point(future ? 30 : 29),
          action: future
              ? cal.CalendarEventOccurrenceAction.replaceFutureTiming
              : cal.CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: point(31),
        ),
      );
    }
    Future<cal.CalendarSchedulingReceipt> publishSeries() async =>
        a.calendarEvent.saveAndPublishInformation(
          cal.CalendarSchedulingSaveRequest(
            eventId: series,
            expectedRevision: (await seriesView()).revision,
            commandId: cal.Uuid().v4obj(),
            content: recurring,
            recipients: ['mailto:bob@example.invalid'],
          ),
        );
    await publishSeries();
    require(
      !(await b.calendarEvent.informationPublicationStatus(series))
          .hasLocalChanges,
      'Published exceptions were incorrectly marked dirty',
    );
    for (final future in [false, true]) {
      await b.calendarEvent.changeOccurrence(
        cal.CalendarEventOccurrenceChange(
          eventId: series,
          expectedRevision: (await seriesView()).revision,
          originalStart: point(future ? 30 : 29),
          action: future
              ? cal.CalendarEventOccurrenceAction.clearFutureTiming
              : cal.CalendarEventOccurrenceAction.clearSingleTiming,
        ),
      );
    }
    await publishSeries();
    final resetView = await seriesView();
    require(
      (resetView.timingOverrides?.singles.isEmpty ?? true) &&
          (resetView.timingOverrides?.future.isEmpty ?? true),
      'Publication pinned reset native timings',
    );
    await b.calendarEvent.cancelPublishedInformation(
      cal.CalendarSchedulingCancelRequest(
        eventId: series,
        expectedRevision: resetView.revision,
        commandId: cal.Uuid().v4obj(),
      ),
    );
    await a.calendarEvent.reopenPublishedInformation(
      cal.CalendarSchedulingReopenRequest(
        eventId: series,
        expectedRevision: (await seriesView()).revision,
        commandId: cal.Uuid().v4obj(),
      ),
    );
    require(
      !(await b.calendarEvent.informationPublicationStatus(series))
          .hasLocalChanges,
      'Reopened reset packet lost canonical inheritance',
    );
    // Active outbox bindings intentionally prevent deletion; disposable test storage owns cleanup.
    print(
      'PASS: two JWT hosts information PUBLISH/update/cancel/reopen, exact historical receipts, native draft preservation and private/purpose guards plus single/future component publication and retained resets; synthetic-only binding retained.',
    );
  } finally {
    bob.close();
    anonymous.close();
  }
}
