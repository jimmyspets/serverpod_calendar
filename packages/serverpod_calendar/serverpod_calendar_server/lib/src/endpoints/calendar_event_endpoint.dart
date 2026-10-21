import 'package:serverpod/serverpod.dart';

import '../calendar_module.dart';
import '../generated/protocol.dart';

class CalendarEventEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<CalendarEventReceipt?> create(
    Session session,
    CalendarEventCreateRequest request,
  ) => CalendarModule.service(session).createEvent(request);
  Future<CalendarEventView> getEvent(
    Session session,
    UuidValue eventId,
    List<CalendarEventFieldGroup> groups,
  ) => CalendarModule.service(session).getEvent(eventId, groups);
  Future<CalendarEventPage> list(
    Session session,
    UuidValue calendarId, {
    required int pageSize,
    required List<CalendarEventFieldGroup> fieldGroups,
    String? cursor,
  }) => CalendarModule.service(session).listEvents(
    calendarId,
    pageSize: pageSize,
    fieldGroups: fieldGroups,
    cursor: cursor,
  );
  Future<CalendarEventOccurrencePreview> preview(
    Session session,
    CalendarEventOccurrenceQuery query,
  ) => CalendarModule.service(session).previewOccurrences(query);
  Future<CalendarEventReceipt?> update(
    Session session,
    CalendarEventUpdateRequest request,
  ) => CalendarModule.service(session).updateEvent(request);
  Future<CalendarEventReceipt?> changeStatus(
    Session session,
    CalendarEventStatusRequest request,
  ) => CalendarModule.service(session).changeEventStatus(request);
  Future<CalendarEventReceipt?> changeOccurrence(
    Session session,
    CalendarEventOccurrenceChange request,
  ) => CalendarModule.service(session).changeOccurrence(request);
  Future<CalendarEventReceipt?> deleteEvent(
    Session session,
    UuidValue eventId,
    int expectedRevision,
  ) => CalendarModule.service(session).deleteEvent(eventId, expectedRevision);
}
