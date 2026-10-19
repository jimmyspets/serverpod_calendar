import 'package:serverpod/serverpod.dart';

/// Host-side authenticated identity check, separate from calendar storage.
class SmokeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String> whoAmI(Session session) async =>
      session.authenticated!.userIdentifier;
}
