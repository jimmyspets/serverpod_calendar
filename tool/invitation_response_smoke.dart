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
  await instanceInvitationResponseSmoke(clients);
}

Future<void> instanceInvitationResponseSmoke(List<Client> clients) async {
  final a = clients.first.modules.serverpod_calendar.calendarInvitation;
  final b = clients.last.modules.serverpod_calendar.calendarInvitation;
  final id = const cal.Uuid().v4obj();
  final master = await clients.first.invitationDemo.simulateRecurring(
    id,
    const cal.Uuid().v4obj(),
    20,
    'Instance response',
  );
  final incoming = await clients.first.invitationDemo.simulateOccurrence(
    id,
    const cal.Uuid().v4obj(),
    2,
    false,
  );
  try {
    final original = (await b.getInvitation(incoming.entryId)).originalStart!;
    final selection = await b.recurringOccurrenceResponse(
      incoming.entryId,
      original,
    );
    final view = selection.response;
    if (!selection.canSend || view.originalStart?.start.day != 5) {
      throw StateError('Wrong response original');
    }
    final request = cal.CalendarInvitationResponseRequest(
      invitationId: selection.masterInvitationId,
      sourceId: selection.membershipSourceId!,
      expectedInvitationRevision: selection.masterInvitationRevision,
      expectedResponseRevision: 0,
      commandId: const cal.Uuid().v4obj(),
      choice: cal.CalendarInvitationResponseChoice.declined,
    );
    final selectedRequest =
        cal.CalendarInvitationRecurringOccurrenceResponseRequest(
          request: request,
          openedInvitationId: incoming.entryId,
          originalStart: original,
          selectionHeadId: selection.selectionHeadId,
          expectedSelectionRevision: selection.selectionRevision,
          selectionEvidenceId: selection.selectionEvidenceId!,
          selectionDigest: selection.selectionDigest!,
        );
    final results = await Future.wait([
      a.sendRecurringOccurrenceResponse(selectedRequest),
      b.sendRecurringOccurrenceResponse(selectedRequest),
    ]);
    if (results.first.id != results.last.id ||
        (await a.response(master.entryId)).revision != 0 ||
        await a.link(master.entryId) != null) {
      throw StateError(
        'Instance response duplicated or changed master/calendar state',
      );
    }
    await clients.last.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      21,
      'Independent master update',
    );
    if ((await b.response(incoming.entryId)).appliesToCurrentSource ||
        (await a.sendRecurringOccurrenceResponse(selectedRequest)).id !=
            results.first.id) {
      throw StateError('Combined proof changed a retained instance receipt');
    }
    await clients.last.invitationDemo.simulateOccurrence(
      id,
      const cal.Uuid().v4obj(),
      3,
      false,
    );
    if ((await a.response(incoming.entryId)).appliesToCurrentSource ||
        (await b.sendRecurringOccurrenceResponse(selectedRequest)).id !=
            results.first.id) {
      throw StateError('Instance historical retry changed intent');
    }
    await clients.last.invitationDemo.simulateOccurrence(
      id,
      const cal.Uuid().v4obj(),
      4,
      true,
    );
    if ((await a.response(incoming.entryId)).canSend ||
        (await a.responseActivity(incoming.entryId)).length != 1) {
      throw StateError(
        'Cancellation admitted a new response or lost retained history',
      );
    }
  } finally {
    for (final entry in [master.entryId, incoming.entryId]) {
      final current = await b.getInvitation(entry);
      if (current.dismissedAt == null) {
        await b.dismiss(current.id, current.revision);
      }
    }
  }
}
