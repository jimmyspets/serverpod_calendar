import 'package:serverpod/serverpod.dart';

import '../calendar_module.dart';
import '../generated/protocol.dart';

class CalendarAvailabilityEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<CalendarAvailabilityReceipt?> create(
    Session session,
    CalendarAvailabilityCreateRequest request,
  ) => CalendarModule.service(session).createAvailability(request);
  Future<CalendarAvailabilityView> getRule(
    Session session,
    UuidValue availabilityId,
  ) => CalendarModule.service(session).getAvailability(availabilityId);
  Future<List<CalendarAvailabilityView>> list(
    Session session,
    UuidValue calendarId, {
    String? category,
  }) =>
      CalendarModule.service(session)
          .listAvailability(calendarId, category: category);
  Future<CalendarAvailabilityReceipt?> update(
    Session session,
    CalendarAvailabilityUpdateRequest request,
  ) => CalendarModule.service(session).updateAvailability(request);
  Future<CalendarAvailabilityReceipt?> updateMetadata(
    Session session,
    CalendarAvailabilityUpdateRequest request,
  ) => CalendarModule.service(session).updateAvailabilityMetadata(request);
  Future<CalendarAvailabilityReceipt?> changeOccurrence(
    Session session,
    CalendarAvailabilityOccurrenceChange request,
  ) => CalendarModule.service(session).changeAvailabilityOccurrence(request);
  Future<CalendarAvailabilityOccurrencePreview> preview(
    Session session,
    CalendarAvailabilityOccurrenceQuery query,
  ) => CalendarModule.service(session).previewAvailabilityOccurrences(query);
  Future<CalendarAvailabilityReceipt?> deleteRule(
    Session session,
    UuidValue availabilityId,
    int expectedRevision,
  ) =>
      CalendarModule.service(session)
          .deleteAvailability(availabilityId, expectedRevision);
}
