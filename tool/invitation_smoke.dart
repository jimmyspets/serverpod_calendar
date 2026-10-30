import 'invitation_cancellation_application_smoke.dart';
import 'invitation_application_smoke.dart';
import 'invitation_adoption_smoke.dart';
import 'invitation_response_smoke.dart';

import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> invitationSmoke(List<Client> clients) async {
  if (clients.length != 2) throw StateError('Invitation probe needs two hosts');
  final a = clients.first,
      b = clients.last,
      id = const cal.Uuid().v4obj(),
      command = const cal.Uuid().v4obj();
  final before = (await a.modules.serverpod_calendar.calendar.list(
    pageSize: 100,
    fieldGroups: [],
  )).calendars.map((v) => v.id).toSet();
  cal.CalendarInvitationReceipt? first;
  try {
    final raced = await Future.wait(
      [a, b].map(
        (c) => c.invitationDemo.simulate(
          id,
          command,
          null,
          'Synthetic invitation review',
        ),
      ),
    );
    first = raced.first;
    if (first.id != raced.last.id || first.sourceId != raced.last.sourceId) {
      throw StateError('Duplicate invitation race changed receipt identity');
    }
    final duplicate = await b.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      null,
      'Synthetic invitation review',
    );
    if (duplicate.outcome != cal.CalendarInvitationOutcome.duplicate ||
        duplicate.sourceId != first.sourceId) {
      throw StateError('Cross-key duplicate changed source');
    }
    var conflict = false;
    try {
      await b.invitationDemo.simulate(id, command, null, 'Conflicting key');
    } on cal.CalendarException catch (e) {
      conflict = e.code == cal.CalendarFailureCode.validation;
    }
    if (!conflict) {
      throw StateError('Conflicting invitation delivery key was accepted');
    }
    final view = await b.modules.serverpod_calendar.calendarInvitation
        .getInvitation(first.entryId);
    if (view.sequence != null ||
        view.summary != 'Synthetic invitation review') {
      throw StateError('Source omission or summary was changed');
    }
    final source = await b.modules.serverpod_calendar.calendarInvitation.source(
      first.entryId,
      first.sourceId,
    );
    if (!source.text.contains('METHOD:REQUEST') ||
        source.text.contains('SEQUENCE:')) {
      throw StateError('Invitation source version was normalized lossily');
    }
    final outcomes = await Future.wait(
      [a, b].map((c) async {
        try {
          await c.modules.serverpod_calendar.calendarInvitation.dismiss(
            first!.entryId,
            1,
          );
          return 'saved';
        } on cal.CalendarException catch (e) {
          return e.code.name;
        }
      }),
    );
    if (outcomes.where((v) => v == 'saved').length != 1 ||
        outcomes.where((v) => v == 'staleRevision').length != 1) {
      throw StateError('Dismissal race did not reject stale revision');
    }
    final retained = await a.invitationDemo.simulate(
      id,
      command,
      null,
      'Synthetic invitation review',
    );
    if (retained.id != first.id ||
        (await b.modules.serverpod_calendar.calendarInvitation.list()).any(
          (v) => v.id == first!.entryId,
        )) {
      throw StateError('Retained retry reopened dismissal');
    }
    final newer = await b.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      1,
      'Updated invitation review',
    );
    if (newer.entryId != first.entryId ||
        newer.entryRevision != 3 ||
        !(await a.modules.serverpod_calendar.calendarInvitation.list()).any(
          (v) => v.id == first!.entryId,
        )) {
      throw StateError('Newer version did not reopen only review');
    }
    final after = (await b.modules.serverpod_calendar.calendar.list(
      pageSize: 100,
      fieldGroups: [],
    )).calendars.map((v) => v.id).toSet();
    if (before.length != after.length || !before.containsAll(after)) {
      throw StateError('Invitation receipt changed calendar collections');
    }
    stdout.writeln(
      'PASS: two-host trusted invitation receipt/key/dismissal races, source omissions, private review and no calendar creation.',
    );
  } finally {
    if (first != null) {
      final current = await b.modules.serverpod_calendar.calendarInvitation
          .getInvitation(first.entryId);
      if (current.dismissedAt == null) {
        await b.modules.serverpod_calendar.calendarInvitation.dismiss(
          current.id,
          current.revision,
        );
      }
    }
  }
  await invitationAdoptionSmoke(clients);
  await invitationApplicationSmoke(clients);
  await invitationCancellationApplicationSmoke(clients);
  await invitationResponseSmoke(clients);
}
