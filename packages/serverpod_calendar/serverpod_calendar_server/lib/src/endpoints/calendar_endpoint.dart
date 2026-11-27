import 'package:serverpod/serverpod.dart';

import '../calendar_module.dart';
import '../generated/protocol.dart';

/// Native calendar operations. Authorization also lives in the service layer.
class CalendarEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<CalendarMutationReceipt?> create(
    Session session,
    CalendarCreateRequest request,
  ) => CalendarModule.service(session).create(request);
  Future<CalendarView> getCalendar(
    Session session,
    UuidValue calendarId,
    List<CalendarFieldGroup> fieldGroups,
  ) => CalendarModule.service(session).get(calendarId, fieldGroups);
  Future<CalendarPage> list(
    Session session, {
    required int pageSize,
    required List<CalendarFieldGroup> fieldGroups,
    String? cursor,
  }) =>
      CalendarModule.service(session)
          .list(pageSize: pageSize, fieldGroups: fieldGroups, cursor: cursor);
  Future<CalendarMutationReceipt?> updateMetadata(
    Session session,
    CalendarMetadataUpdateRequest request,
  ) => CalendarModule.service(session).updateMetadata(request);
  Future<CalendarMutationReceipt?> updatePresentation(
    Session session,
    CalendarPresentationUpdateRequest request,
  ) => CalendarModule.service(session).updatePresentation(request);
  Future<CalendarMutationReceipt?> updateProtocolMetadata(
    Session session,
    CalendarProtocolMetadataUpdateRequest request,
  ) => CalendarModule.service(session).updateProtocolMetadata(request);
  Future<CalendarMutationReceipt?> updateSettings(
    Session session,
    CalendarSettingsUpdateRequest request,
  ) => CalendarModule.service(session).updateSettings(request);
  Future<List<CalendarSubjectView>> subjects(
    Session session,
    UuidValue calendarId,
  ) => CalendarModule.service(session).subjects(calendarId);
  Future<CalendarMutationReceipt?> changeSubject(
    Session session,
    CalendarSubjectChangeRequest request,
  ) => CalendarModule.service(session).changeSubject(request);
  Future<CalendarMutationReceipt?> delete(
    Session session,
    UuidValue calendarId,
    int expectedRevision,
  ) => CalendarModule.service(session).delete(calendarId, expectedRevision);
}
