import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../calendar_module.dart';
import '../generated/protocol.dart';

class CalendarEventEndpoint extends Endpoint {
  Future<CalendarEventOccurrencePage> listOccurrences(
    Session session,
    CalendarEventOccurrenceListQuery query,
  ) => CalendarModule.service(session).listEventOccurrences(query);
  Future<CalendarEventReceipt?> updateTextMetadata(
    Session session,
    CalendarEventTextMetadataRequest request,
  ) => CalendarModule.service(session).updateEventTextMetadata(request);

  Future<CalendarEventReceipt?> updateDescriptiveMetadata(
    Session session,
    CalendarEventDescriptiveRequest request,
  ) => CalendarModule.service(session).updateEventDescriptiveMetadata(request);

  Future<CalendarSchedulingInstanceResponsesView> schedulingInstanceResponses(
    Session session,
    UuidValue eventId,
    CalendarEventTiming originalStart,
  ) =>
      CalendarModule.service(session)
          .schedulingInstanceResponses(eventId, originalStart);

  Future<CalendarSchedulingResponsesView> schedulingResponses(
    Session session,
    UuidValue eventId,
  ) => CalendarModule.service(session).schedulingResponses(eventId);

  Future<List<CalendarSchedulingReplySourceView>> schedulingReplySources(
    Session session,
    UuidValue eventId,
  ) => CalendarModule.service(session).schedulingReplySources(eventId);

  Future<CalendarSchedulingReplyDocument> schedulingReplySource(
    Session session,
    UuidValue eventId,
    UuidValue sourceId,
  ) => CalendarModule.service(session).schedulingReplySource(eventId, sourceId);
  Future<CalendarSchedulingReceipt> reopenPublishedAndNotify(
    Session session,
    CalendarSchedulingReopenRequest request,
  ) => CalendarModule.service(session).reopenPublishedAndNotify(request);
  Future<CalendarSchedulingReceipt> restoreOccurrenceAndNotify(
    Session session,
    CalendarSchedulingOccurrenceRestoreRequest request,
  ) => CalendarModule.service(session).restoreOccurrenceAndNotify(request);
  Future<CalendarSchedulingReceipt> cancelOccurrenceAndNotify(
    Session session,
    CalendarSchedulingOccurrenceCancelRequest request,
  ) => CalendarModule.service(session).cancelOccurrenceAndNotify(request);
  @override
  bool get requireLogin => true;
  Future<CalendarSchedulingReceipt> saveAndNotify(
    Session session,
    CalendarSchedulingSaveRequest request,
  ) => CalendarModule.service(session).saveAndNotify(request);
  Future<CalendarSchedulingReceipt> cancelAndNotify(
    Session session,
    CalendarSchedulingCancelRequest request,
  ) => CalendarModule.service(session).cancelAndNotify(request);
  Future<CalendarSchedulingView> schedulingStatus(
    Session session,
    UuidValue eventId,
  ) => CalendarModule.service(session).schedulingStatus(eventId);
  Future<CalendarEventReplaceResult> replaceFromImport(
    Session session,
    CalendarEventReplaceRequest request,
  ) => CalendarModule.service(session).replaceEventsFromImport(request);
  Future<ByteData> exportEvents(
    Session session,
    CalendarEventExportRequest request,
  ) => CalendarModule.service(session).exportEvents(request);
  Future<CalendarEventImportResult> importEvents(
    Session session,
    CalendarEventImportRequest request,
  ) => CalendarModule.service(session).importEvents(request);
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
    CalendarCategoryFilter? categoryFilter,
  }) => CalendarModule.service(session).listEvents(
    calendarId,
    pageSize: pageSize,
    fieldGroups: fieldGroups,
    cursor: cursor,
    categoryFilter: categoryFilter,
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
  Future<CalendarEventReceipt?> changeOccurrenceContent(
    Session session,
    CalendarEventOccurrenceContentRequest request,
  ) => CalendarModule.service(session).changeOccurrenceContent(request);
  Future<CalendarEventReceipt?> deleteEvent(
    Session session,
    UuidValue eventId,
    int expectedRevision,
  ) => CalendarModule.service(session).deleteEvent(eventId, expectedRevision);
}
