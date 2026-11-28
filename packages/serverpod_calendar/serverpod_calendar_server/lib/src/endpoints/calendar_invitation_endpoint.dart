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
  Future<CalendarInvitationApplicationView> application(
    Session session,
    UuidValue id,
  ) => CalendarModule.service(session).invitationApplication(id);
  Future<CalendarInvitationApplyReceipt> applyUpdate(
    Session session,
    CalendarInvitationApplyRequest request,
  ) => CalendarModule.service(session).applyInvitationUpdate(request);
  Future<CalendarInvitationApplyReceipt> applyCancellation(
    Session session,
    CalendarInvitationApplyRequest request,
  ) => CalendarModule.service(session).applyInvitationCancellation(request);
  Future<CalendarInvitationOccurrenceApplicationView> occurrenceApplication(
    Session session,
    UuidValue id,
  ) => CalendarModule.service(session).invitationOccurrenceApplication(id);
  Future<CalendarInvitationOccurrenceApplyReceipt> applyOccurrenceUpdate(
    Session session,
    CalendarInvitationOccurrenceApplyRequest request,
  ) => CalendarModule.service(session).applyInvitationOccurrenceUpdate(request);
  Future<CalendarInvitationOccurrenceApplyReceipt> applyOccurrenceCancellation(
    Session session,
    CalendarInvitationOccurrenceApplyRequest request,
  ) =>
      CalendarModule.service(session)
          .applyInvitationOccurrenceCancellation(request);
  Future<CalendarInvitationResponseView> response(
    Session session,
    UuidValue id,
  ) => CalendarModule.service(session).invitationResponse(id);
  Future<List<CalendarInvitationResponseActivityView>> responseActivity(
    Session session,
    UuidValue id,
  ) => CalendarModule.service(session).invitationResponseActivity(id);
  Future<CalendarInvitationResponseReceipt> sendResponse(
    Session session,
    CalendarInvitationResponseRequest request,
  ) => CalendarModule.service(session).sendInvitationResponse(request);
}
