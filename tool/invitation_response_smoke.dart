import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> invitationResponseSmoke(List<Client> clients) async {
  final a = clients.first.modules.serverpod_calendar.calendarInvitation;
  final b = clients.last.modules.serverpod_calendar.calendarInvitation;
  final id = const cal.Uuid().v4obj();
  final incoming = await clients.first.invitationDemo.simulate(
    id,
    const cal.Uuid().v4obj(),
    null,
    'Cross-host explicit response',
  );
  try {
    final request = cal.CalendarInvitationResponseRequest(
      invitationId: incoming.entryId,
      expectedInvitationRevision: incoming.entryRevision,
      sourceId: incoming.sourceId,
      expectedResponseRevision: 0,
      commandId: const cal.Uuid().v4obj(),
      choice: cal.CalendarInvitationResponseChoice.declined,
    );
    final results = await Future.wait([
      a.sendResponse(request),
      b.sendResponse(request),
    ]);
    if (results.first.id != results.last.id ||
        results.first.stamp != results.last.stamp) {
      throw StateError('Cross-host response retry lost stable receipt');
    }
    final view = await b.response(incoming.entryId);
    if (view.revision != 1 ||
        view.choice != cal.CalendarInvitationResponseChoice.declined ||
        !view.appliesToCurrentSource ||
        await a.link(incoming.entryId) != null) {
      throw StateError('Response changed adoption or private state');
    }
    await clients.last.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      1,
      'New source is not accepted implicitly',
    );
    if ((await a.response(incoming.entryId)).appliesToCurrentSource ||
        (await b.sendResponse(request)).id != results.first.id ||
        (await b.responseActivity(incoming.entryId)).length != 1) {
      throw StateError(
        'Historical response was rebased or retried as a new send',
      );
    }
  } finally {
    final current = await b.getInvitation(incoming.entryId);
    await b.dismiss(current.id, current.revision);
  }
}
