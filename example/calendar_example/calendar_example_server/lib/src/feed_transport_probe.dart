import 'dart:async';

import 'package:serverpod/serverpod.dart';

/// Test-mode opt-in only. Exercises framework errors after a handler returns;
/// never reads module storage or treats its suffix as a credential.
class FeedTransportProbe extends Route {
  FeedTransportProbe() : super(path: '/**');
  @override
  Future<Result> call(Request req) async => Response.ok(
    body: Body.fromDataStream(const Stream.empty(), contentLength: 1),
  );
  @override
  FutureOr<Result> handleCall(Session session, Request request) =>
      Response.notFound();
}
