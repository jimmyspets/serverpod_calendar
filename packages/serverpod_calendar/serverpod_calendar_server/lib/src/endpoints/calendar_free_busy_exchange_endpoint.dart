import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../calendar_module.dart';
import '../generated/protocol.dart';

/// Private, explicit scheduling exchange. Raw trusted ingress is host-only.
class CalendarFreeBusyExchangeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<CalendarFreeBusyMessagePage> listFreeBusyInbox(
    Session session, {
    int pageSize = 20,
    String? cursor,
  }) =>
      CalendarModule.service(session)
          .listFreeBusyInbox(pageSize: pageSize, cursor: cursor);
  Future<CalendarFreeBusyMessageView> getFreeBusyMessage(
    Session session,
    UuidValue sourceId,
  ) => CalendarModule.service(session).getFreeBusyMessage(sourceId);
  Future<ByteData> getFreeBusySource(Session session, UuidValue sourceId) =>
      CalendarModule.service(session).getFreeBusySource(sourceId);
  Future<CalendarFreeBusyMessageView> dismissFreeBusyMessage(
    Session session,
    UuidValue sourceId,
  ) => CalendarModule.service(session).dismissFreeBusyMessage(sourceId);
  Future<CalendarFreeBusyOutgoingPage> listFreeBusyOutgoing(
    Session session, {
    int pageSize = 20,
    String? cursor,
  }) =>
      CalendarModule.service(session)
          .listFreeBusyOutgoing(pageSize: pageSize, cursor: cursor);
  Future<CalendarFreeBusyDeliveryPage> freeBusyDeliveryActivity(
    Session session,
    UuidValue commandId, {
    int pageSize = 20,
    String? cursor,
  }) => CalendarModule.service(session)
      .freeBusyDeliveryActivity(commandId, pageSize: pageSize, cursor: cursor);
  Future<CalendarFreeBusyCommandReceipt> publishFreeBusy(
    Session session,
    CalendarFreeBusyPublishRequest request,
  ) => CalendarModule.service(session).publishFreeBusy(request);
  Future<CalendarFreeBusyCommandReceipt> requestFreeBusy(
    Session session,
    CalendarFreeBusyPublishRequest request,
  ) => CalendarModule.service(session).requestFreeBusy(request);
  Future<CalendarFreeBusyCommandReceipt> replyFreeBusy(
    Session session,
    CalendarFreeBusyReplyRequest request,
  ) => CalendarModule.service(session).replyFreeBusy(request);
  Future<CalendarFreeBusyCommandReceipt> refuseFreeBusy(
    Session session,
    CalendarFreeBusyReplyRequest request,
  ) => CalendarModule.service(session).refuseFreeBusy(request);
  Future<CalendarFreeBusyCommandReceipt> withdrawFreeBusyCommand(
    Session session,
    UuidValue commandId,
  ) => CalendarModule.service(session).withdrawFreeBusyCommand(commandId);
}
