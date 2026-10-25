import 'package:serverpod/serverpod.dart';

import '../feed_module.dart';
import '../generated/protocol.dart';

class CalendarFeedEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<CalendarFeedView>> list(Session session) =>
      CalendarFeedModule.service(session).list();
  Future<CalendarFeedView> read(Session session, UuidValue id) =>
      CalendarFeedModule.service(session).read(id);
  Future<CalendarFeedView> create(
    Session session,
    CalendarFeedSettings settings,
  ) => CalendarFeedModule.service(session).create(settings);
  Future<CalendarFeedView> update(
    Session session,
    UuidValue id,
    int expectedRevision,
    CalendarFeedSettings settings,
  ) =>
      CalendarFeedModule.service(session)
          .update(id, expectedRevision, settings);
  Future<void> delete(Session session, UuidValue id, int expectedRevision) =>
      CalendarFeedModule.service(session).delete(id, expectedRevision);
  Future<List<CalendarFeedCredentialView>> credentials(
    Session session,
    UuidValue feedId,
  ) => CalendarFeedModule.service(session).credentials(feedId);
  Future<CalendarFeedCreatedCredential> createCredential(
    Session session,
    UuidValue feedId,
    int expectedFeedRevision,
    String? label,
  ) =>
      CalendarFeedModule.service(session)
          .createCredential(feedId, expectedFeedRevision, label);
  Future<void> revokeCredential(
    Session session,
    UuidValue feedId,
    int expectedFeedRevision,
    UuidValue credentialId,
    int expectedRevision,
  ) => CalendarFeedModule.service(session).revokeCredential(
    feedId,
    expectedFeedRevision,
    credentialId,
    expectedRevision,
  );
}
