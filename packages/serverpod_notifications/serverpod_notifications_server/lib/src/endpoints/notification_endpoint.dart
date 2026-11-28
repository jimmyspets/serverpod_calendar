import 'package:serverpod/serverpod.dart';

import '../notification_module.dart';
import '../generated/protocol.dart';

class NotificationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<NotificationPage> recover(
    Session session,
    int pageSize,
    String? cursor,
  ) =>
      NotificationModule.service(session)
          .recover(pageSize: pageSize, cursor: cursor);
}
