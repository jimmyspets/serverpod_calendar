import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as notify;

import '../notification_runtime.dart';

/// Transient authorized hints only. Recovery reads the durable generic module.
class NotificationStreamEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Stream<notify.NotificationHint> watch(Session session) async* {
    final service = notify.NotificationModule.service(session);
    final actor = await service.authorizeSubscription();
    final controller = StreamController<notify.NotificationHint>();
    var pending = false, closed = false;
    void wake(notify.NotificationHint hint) {
      if (!closed && !pending) {
        pending = true;
        controller.add(hint);
      }
    }

    final subscription = session.messages
        .createStream<notify.NotificationHint>(
          demoNotificationChannel(actor.scopeKey, actor.recipient),
        )
        .listen(
          wake,
          onError: (Object error, StackTrace stack) {
            if (!closed) controller.addError(error, stack);
          },
        );
    final heartbeat = Timer.periodic(
      const Duration(seconds: 5),
      (_) => wake(notify.NotificationHint()),
    );
    final lifetime = Timer(const Duration(seconds: 60), () {
      closed = true;
      unawaited(controller.close());
    });
    try {
      // Subscribe before the ready hint closes the initial recovery race.
      yield notify.NotificationHint();
      await for (final hint in controller.stream) {
        pending = false;
        if (!actor.same(await service.authorizeSubscription())) {
          throw StateError('Recipient context changed');
        }
        yield hint;
      }
    } finally {
      closed = true;
      heartbeat.cancel();
      lifetime.cancel();
      await subscription.cancel();
      if (!controller.isClosed) unawaited(controller.close());
    }
  }
}
