import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

final class _Storage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async {
    value = data;
  }
}

/// Real JWT clients on independent hosts; all source mail remains synthetic.
Future<void> incomingPublicationSmoke(
  List<Client> clients,
  String bobPassword, {
  bool bundled = false,
}) async {
  if (clients.length != 2) throw StateError('Two hosts required');
  final a = clients[0].modules.serverpod_calendar,
      b = clients[1].modules.serverpod_calendar;
  final bob = Client(clients[1].host)
    ..authSessionManager = ClientAuthSessionManager(storage: _Storage());
  final anonymous = Client(clients[0].host);
  final apis = [a.calendarIncomingPublication, b.calendarIncomingPublication];
  Future<cal.CalendarIncomingPublicationCommandReceipt> add(
    int host,
    cal.CalendarIncomingPublicationAddRequest request,
  ) => bundled
      ? apis[host].addBundleToCalendar(request)
      : apis[host].addToCalendar(request);
  Future<cal.CalendarIncomingPublicationCommandReceipt> apply(
    int host,
    cal.CalendarIncomingPublicationApplyRequest request,
  ) => bundled
      ? apis[host].applyBundleSource(request)
      : apis[host].applySource(request);
  Future<cal.CalendarIncomingPublicationSourceView> source(
    int host,
    cal.UuidValue entry,
    cal.UuidValue id,
  ) async => bundled
      ? (await apis[host].getBundleSource(entry, id)).source
      : await apis[host].getSource(entry, id);
  Future<cal.CalendarIncomingPublicationLinkView?> link(
    int host,
    cal.UuidValue entry,
  ) async => bundled
      ? (await apis[host].getBundleLink(entry))?.link
      : await apis[host].getLink(entry);

  void require(bool ok, String reason) {
    if (!ok) throw StateError(reason);
  }

  Future<void> denied(Future<Object?> Function() action) async {
    try {
      await action();
    } on cal.CalendarException catch (e) {
      if (e.code == cal.CalendarFailureCode.accessDenied) return;
      rethrow;
    }
    throw StateError('Private publication boundary allowed access');
  }

  try {
    final auth = await bob.emailIdp.login(
      email: 'bob@example.invalid',
      password: bobPassword,
    );
    await bob.auth.updateSignedInUser(auth);
    var rejected = false;
    try {
      await anonymous.modules.serverpod_calendar.calendarIncomingPublication
          .list(cal.CalendarIncomingPublicationQuery());
    } on ServerpodClientUnauthorized {
      rejected = true;
    }
    require(rejected, 'Anonymous inbox access allowed');
    final fixture = cal.Uuid().v4obj(), ingress = cal.Uuid().v4obj();
    final received = await clients[0].publicationDemo.simulate(
      fixture,
      ingress,
      0,
      false,
      true,
      'Synthetic published event',
      bundled: bundled,
    );
    final repeated = await clients[1].publicationDemo.simulate(
      fixture,
      ingress,
      0,
      false,
      true,
      'Synthetic published event',
      bundled: bundled,
    );
    require(repeated.id == received.id, 'Cross-host ingress receipt changed');
    final view = await b.calendarIncomingPublication.getEntry(received.entryId);
    require(
      view.recurring &&
          view.bundledPublication == bundled &&
          view.summary == 'Synthetic published event',
      'Review projection changed',
    );
    await denied(
      () => bob.modules.serverpod_calendar.calendarIncomingPublication.getEntry(
        received.entryId,
      ),
    );
    await denied(
      () => bob.modules.serverpod_calendar.calendarIncomingPublication
          .getSource(received.entryId, received.sourceId),
    );
    final calendar = (await a.calendar.create(
      cal.CalendarCreateRequest(
        displayName: 'Incoming publication probe',
        availabilityZoneId: 'Europe/Stockholm',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!.calendarId;
    final input = cal.CalendarIncomingPublicationAddRequest(
      entryId: view.id,
      sourceId: view.sourceId,
      expectedRevision: view.revision,
      calendarId: calendar,
      expectedCalendarRevision: 1,
      commandId: cal.Uuid().v4obj(),
    );
    final created = await add(0, input);
    final retry = await add(1, input);
    require(
      retry.unchanged && retry.eventId == created.eventId,
      'Cross-host Add receipt changed',
    );
    final pending = await clients[1].publicationDemo.simulate(
      fixture,
      cal.Uuid().v4obj(),
      1,
      false,
      true,
      'Synthetic published event',
      bundled: bundled,
    );
    require(
      pending.outcome == cal.CalendarIncomingPublicationOutcome.selected,
      'Update not selected',
    );
    final cancelled = await clients[0].publicationDemo.simulate(
      fixture,
      cal.Uuid().v4obj(),
      2,
      true,
      true,
      'Synthetic published event',
      bundled: bundled,
    );
    final cancellationSource = await source(
      1,
      cancelled.entryId,
      cancelled.sourceId,
    );
    require(
      cancellationSource.basisSourceId == pending.sourceId,
      'Cancellation lost newer unapplied source basis',
    );
    final cancelInput = cal.CalendarIncomingPublicationApplyRequest(
      entryId: cancelled.entryId,
      sourceId: cancelled.sourceId,
      expectedRevision: cancelled.entryRevision,
      expectedEventRevision: 1,
      commandId: cal.Uuid().v4obj(),
    );
    final results = await Future.wait([
      apply(0, cancelInput),
      apply(1, cancelInput),
    ]);
    require(
      results.every(
        (r) => r.eventId == created.eventId && r.eventRevision == 2,
      ),
      'Competing Apply committed twice',
    );
    require(
      (await b.calendarEvent.getEvent(
            created.eventId,
            cal.CalendarEventFieldGroup.values,
          )).status ==
          cal.CalendarEventStatus.cancelled,
      'Cancellation not visible across hosts',
    );
    final reopen = await clients[1].publicationDemo.simulate(
      fixture,
      cal.Uuid().v4obj(),
      3,
      false,
      true,
      'Synthetic published event',
      bundled: bundled,
    );
    final reopenInput = cal.CalendarIncomingPublicationApplyRequest(
      entryId: reopen.entryId,
      sourceId: reopen.sourceId,
      expectedRevision: reopen.entryRevision,
      expectedEventRevision: 2,
      commandId: cal.Uuid().v4obj(),
    );
    await apply(0, reopenInput);
    final restored = await b.calendarEvent.getEvent(
      created.eventId,
      cal.CalendarEventFieldGroup.values,
    );
    require(
      restored.status == cal.CalendarEventStatus.confirmed &&
          restored.revision == 3,
      'Explicit reopening failed',
    );
    await b.calendarEvent.deleteEvent(created.eventId, 3);
    final historical = await add(0, input);
    require(
      historical.unchanged && historical.eventId == created.eventId,
      'Deleted creation retry recreated event',
    );
    require((await link(1, view.id))!.deleted, 'Deletion link marker absent');
    print(
      'PASS: incoming ${bundled ? "bundle" : "master"} publication MIME/JWT cross-host review, private source, separate basis, competing application, reopening and deletion retry.',
    );
  } finally {
    bob.close();
    anonymous.close();
  }
}
