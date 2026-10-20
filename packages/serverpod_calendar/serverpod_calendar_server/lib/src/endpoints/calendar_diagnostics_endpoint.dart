import 'package:serverpod/serverpod.dart';

/// Authenticated module wiring check; no calendar/notification domain behavior.
class CalendarDiagnosticsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String> check(Session session) async {
    return 'calendar:ready:${session.authenticated!.userIdentifier}';
  }
}
