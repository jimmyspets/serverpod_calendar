import 'package:serverpod/serverpod.dart';

import '../calendar_module.dart';
import '../generated/protocol.dart';

class CalendarAvailabilitySearchEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<CalendarAvailabilitySearchView> search(
    Session session,
    CalendarAvailabilitySearchQuery query,
  ) => CalendarModule.service(session).searchAvailability(query);
}
