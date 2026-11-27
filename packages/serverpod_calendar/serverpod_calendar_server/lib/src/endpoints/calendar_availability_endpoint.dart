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
    UuidValue calendarId,
  ) => CalendarModule.service(session).listAvailability(calendarId);
  Future<CalendarAvailabilityReceipt?> update(
    Session session,
    CalendarAvailabilityUpdateRequest request,
  ) => CalendarModule.service(session).updateAvailability(request);
  Future<CalendarAvailabilityReceipt?> deleteRule(
    Session session,
    UuidValue availabilityId,
    int expectedRevision,
  ) =>
      CalendarModule.service(session)
          .deleteAvailability(availabilityId, expectedRevision);
}
