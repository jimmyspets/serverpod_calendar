import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> schedulingReplySmoke(List<Client> clients) async {
  await _replySmoke(clients, false);
  await _replySmoke(clients, true);
}

Future<void> _replySmoke(List<Client> clients, bool recurring) async {
  final a = clients.first, b = clients.last;
  final api = a.modules.serverpod_calendar;
  final parent = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic reply races',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  cal.CalendarEventContent content(String title) => cal.CalendarEventContent(
    summary: title,
    recurrence: recurring
        ? cal.CalendarEventRecurrence(
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
          )
        : null,
    timing: cal.CalendarEventTiming(
      kind: cal.CalendarEventTimeKind.utc,
      start: cal.CalendarEventCivil(year: 2026, month: 11, day: 2, hour: 9),
    ),
  );
  final event = (await api.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: parent.calendarId,
      content: content('Draft'),
    ),
  ))!;
  await api.calendarEvent.saveAndNotify(
    cal.CalendarSchedulingSaveRequest(
      eventId: event.eventId,
      expectedRevision: 1,
      content: content('Published'),
      recipients: ['mailto:bob@example.invalid'],
      commandId: const Uuid().v4obj(),
    ),
  );
  final published = await api.calendarEvent.schedulingResponses(event.eventId);
  if (published.recurring != recurring) {
    throw StateError('Wrong reply target scope');
  }
  final command = const Uuid().v4obj();
  final stamp = DateTime.utc(2026, 10, 27, 12);
  Future<cal.CalendarSchedulingReplyReceipt> submit(
    Client client,
    UuidValue key, {
    int? sequence,
    DateTime? time,
  }) => client.schedulingDemo.simulateReply(
    event.eventId,
    key,
    'mailto:bob@example.invalid',
    cal.CalendarSchedulingParticipation.accepted,
    sequence ?? published.publishedSequence,
    time ?? stamp,
    'Synthetic private reply',
  );
  final receipts = await Future.wait([
    for (final client in [a, b]) submit(client, command),
  ]);
  if (receipts.first.receiptId != receipts.last.receiptId ||
      receipts.where((r) => !r.unchanged).length != 1) {
    throw StateError('Generated-client reply race was not idempotent');
  }
  var response =
      (await b.modules.serverpod_calendar.calendarEvent.schedulingResponses(
        event.eventId,
      )).responses.single;
  if (!response.isCurrent ||
      response.effectiveParticipation !=
          cal.CalendarSchedulingParticipation.accepted) {
    throw StateError('Cross-host attendee response missing');
  }
  // A publication/reply race can serialize in either order. It must never carry
  // acceptance across the new invitation version or change native drafts.
  final race = await Future.wait<Object>([
    api.calendarEvent.saveAndNotify(
      cal.CalendarSchedulingSaveRequest(
        eventId: event.eventId,
        expectedRevision: 2,
        content: content('New invitation'),
        recipients: ['mailto:bob@example.invalid'],
        commandId: const Uuid().v4obj(),
      ),
    ),
    submit(
      b,
      const Uuid().v4obj(),
      time: stamp.add(const Duration(seconds: 1)),
    ),
  ]);
  if (race.length != 2) throw StateError('Publication/reply race incomplete');
  response =
      (await b.modules.serverpod_calendar.calendarEvent.schedulingResponses(
        event.eventId,
      )).responses.single;
  if (response.isCurrent) {
    throw StateError('Prior response carried across invitation');
  }
  final current = await api.calendarEvent.schedulingResponses(event.eventId);
  await submit(
    b,
    const Uuid().v4obj(),
    sequence: current.publishedSequence,
    time: stamp.add(const Duration(seconds: 2)),
  );
  final document = await api.calendarEvent.schedulingReplySource(
    event.eventId,
    receipts.first.sourceId,
  );
  if (!document.normalizedSource.contains('COMMENT:Synthetic private reply')) {
    throw StateError('Source review lost private comments');
  }
  final saved = await api.calendarEvent.getEvent(
    event.eventId,
    cal.CalendarEventFieldGroup.values,
  );
  if (saved.revision != 3 || saved.summary != 'New invitation') {
    throw StateError('Reply changed native event state');
  }
}
