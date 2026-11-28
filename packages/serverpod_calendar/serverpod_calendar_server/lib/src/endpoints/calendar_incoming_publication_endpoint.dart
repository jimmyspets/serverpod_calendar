import 'package:serverpod/serverpod.dart';

import '../calendar_module.dart';
import '../generated/protocol.dart';

class CalendarIncomingPublicationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  Future<CalendarIncomingPublicationPage> list(
    Session session,
    CalendarIncomingPublicationQuery query,
  ) => CalendarModule.service(session).incomingPublicationList(query);
  Future<CalendarIncomingPublicationView> getEntry(
    Session session,
    UuidValue id,
  ) => CalendarModule.service(session).incomingPublicationGet(id);
  Future<CalendarIncomingPublicationSourceView> getSource(
    Session session,
    UuidValue id,
    UuidValue sourceId,
  ) => CalendarModule.service(session).incomingPublicationSource(id, sourceId);
  Future<void> dismiss(Session session, UuidValue id, int expectedRevision) =>
      CalendarModule.service(session)
          .incomingPublicationDismiss(id, expectedRevision);
  Future<CalendarIncomingPublicationLinkView?> getLink(
    Session session,
    UuidValue id,
  ) => CalendarModule.service(session).incomingPublicationLink(id);
  Future<CalendarIncomingPublicationCommandReceipt> addToCalendar(
    Session session,
    CalendarIncomingPublicationAddRequest input,
  ) => CalendarModule.service(session).incomingPublicationAdd(input);
  Future<CalendarIncomingPublicationCommandReceipt> applySource(
    Session session,
    CalendarIncomingPublicationApplyRequest input,
  ) => CalendarModule.service(session).incomingPublicationApply(input);
}
