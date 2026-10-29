import 'package:serverpod/serverpod.dart';

import '../calendar_module.dart';
import '../generated/protocol.dart';

class CalendarInvitationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<List<CalendarInvitationView>> list(Session session) =>
      CalendarModule.service(session).listInvitations();
  Future<CalendarInvitationView> getInvitation(Session session, UuidValue id) =>
      CalendarModule.service(session).getInvitation(id);
  Future<List<CalendarInvitationSourceView>> sources(
    Session session,
    UuidValue id,
  ) => CalendarModule.service(session).invitationSources(id);
  Future<CalendarInvitationDocument> source(
    Session session,
    UuidValue id,
    UuidValue sourceId,
  ) => CalendarModule.service(session).invitationSource(id, sourceId);
  Future<void> dismiss(Session session, UuidValue id, int expectedRevision) =>
      CalendarModule.service(session).dismissInvitation(id, expectedRevision);
  Future<CalendarInvitationAdoptionReceipt?> link(
    Session session,
    UuidValue id,
  ) => CalendarModule.service(session).invitationLink(id);
  Future<CalendarInvitationAdoptionReceipt> adopt(
    Session session,
    CalendarInvitationAdoptionRequest request,
  ) => CalendarModule.service(session).adoptInvitation(request);
}
