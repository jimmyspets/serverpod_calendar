import 'package:serverpod/serverpod.dart';

/// Authenticated module wiring check; no calendar/notification domain behavior.
class NotificationDiagnosticsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String> check(Session session) async {
    return 'notifications:ready:${session.authenticated!.userIdentifier}';
  }
}
