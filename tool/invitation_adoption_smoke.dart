import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

Future<void> invitationAdoptionSmoke(List<Client> clients) async {
  final a = clients.first, b = clients.last;
  final calendars = <cal.UuidValue>[];
  final entries = <cal.UuidValue>[];
  Future<cal.UuidValue> calendar() async {
    final created = (await a.modules.serverpod_calendar.calendar.create(
      cal.CalendarCreateRequest(
        displayName: 'Synthetic invitation adoption',
        availabilityZoneId: 'UTC',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!.calendarId;
    calendars.add(created);
    return created;
  }

  Future<cal.CalendarInvitationReceipt> source(cal.UuidValue id) async {
    final receipt = await a.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      null,
      'Synthetic calendar addition',
    );
    entries.add(receipt.entryId);
    return receipt;
  }

  Future<String> outcome(Future<Object?> Function() action) async {
    try {
      await action();
      return 'saved';
    } on cal.CalendarException catch (e) {
      return e.code.name;
    }
  }

  void require(bool value, String message) {
    if (!value) {
      throw StateError(message);
    }
  }

  try {
    final parent = await calendar(),
        id = const cal.Uuid().v4obj(),
        received = await source(id);
    final request = cal.CalendarInvitationAdoptionRequest(
      invitationId: received.entryId,
      expectedRevision: 1,
      sourceId: received.sourceId,
      calendarId: parent,
      expectedCalendarRevision: 1,
    );
    final raced = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation.adopt(request),
      ),
    );
    require(
      raced.first.id == raced.last.id &&
          raced.first.eventId == raced.last.eventId,
      'Concurrent calendar adoption created multiple events',
    );
    final added = raced.first;
    var event = await b.modules.serverpod_calendar.calendarEvent.getEvent(
      added.eventId,
      cal.CalendarEventFieldGroup.values,
    );
    await b.modules.serverpod_calendar.calendarEvent.update(
      cal.CalendarEventUpdateRequest(
        eventId: added.eventId,
        expectedRevision: event.revision,
        content: cal.CalendarEventContent(
          timing: event.timing!,
          summary: 'Local adoption draft',
          status: event.status!,
          transparency: event.transparency!,
        ),
      ),
    );
    await a.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      1,
      'New review source',
    );
    final retained = await b.modules.serverpod_calendar.calendarInvitation
        .adopt(request);
    event = await a.modules.serverpod_calendar.calendarEvent.getEvent(
      added.eventId,
      cal.CalendarEventFieldGroup.values,
    );
    require(
      retained.id == added.id &&
          event.summary == 'Local adoption draft' &&
          (await a.modules.serverpod_calendar.calendarInvitation.getInvitation(
                received.entryId,
              )).dismissedAt ==
              null,
      'Retained adoption replayed source content or dismissed a newer source',
    );
    require(
      (await b.modules.serverpod_calendar.calendarInvitation.link(
            received.entryId,
          ))!.eventId ==
          added.eventId,
      'Other host could not resolve stable link',
    );
    final other = await calendar();
    require(
      await outcome(
            () => a.modules.serverpod_calendar.calendarInvitation.adopt(
              request.copyWith(calendarId: other),
            ),
          ) ==
          'dependencyConflict',
      'Different destination retargeted existing link',
    );

    // Race ordinary import and explicit adoption for the same source UID.
    final uidParent = await calendar(),
        uidSource = await source(const cal.Uuid().v4obj());
    final document = await b.modules.serverpod_calendar.calendarInvitation
        .source(uidSource.entryId, uidSource.sourceId);
    final file = Uint8List.fromList(
      utf8.encode(document.text.replaceFirst('METHOD:REQUEST\r\n', '')),
    );
    final uidRace = await Future.wait([
      outcome(
        () => a.modules.serverpod_calendar.calendarInvitation.adopt(
          cal.CalendarInvitationAdoptionRequest(
            invitationId: uidSource.entryId,
            expectedRevision: 1,
            sourceId: uidSource.sourceId,
            calendarId: uidParent,
            expectedCalendarRevision: 1,
          ),
        ),
      ),
      outcome(
        () => b.modules.serverpod_calendar.calendarEvent.importEvents(
          cal.CalendarEventImportRequest(
            calendarId: uidParent,
            expectedRevision: 1,
            bytes: ByteData.sublistView(file),
          ),
        ),
      ),
    ]);
    require(
      uidRace.where((v) => v == 'saved').length == 1 &&
          uidRace.contains('dependencyConflict'),
      'UID conflict race did not preserve one active copy',
    );
    // Race parent deletion against adoption: one committed outcome wins.
    final deleteParent = await calendar(),
        deleteSource = await source(const cal.Uuid().v4obj());
    final parentRace = await Future.wait([
      outcome(
        () => a.modules.serverpod_calendar.calendarInvitation.adopt(
          cal.CalendarInvitationAdoptionRequest(
            invitationId: deleteSource.entryId,
            expectedRevision: 1,
            sourceId: deleteSource.sourceId,
            calendarId: deleteParent,
            expectedCalendarRevision: 1,
          ),
        ),
      ),
      outcome(
        () => b.modules.serverpod_calendar.calendar.delete(deleteParent, 1),
      ),
    ]);
    require(
      parentRace.where((v) => v == 'saved').length == 1,
      'Parent deletion/adoption both committed',
    );
    stdout.writeln(
      'PASS: two-host stable invitation adoption, retained retry/local draft protection, source review, competing UID import and parent deletion races.',
    );
  } finally {
    for (final entry in entries) {
      final current = await b.modules.serverpod_calendar.calendarInvitation
          .getInvitation(entry);
      if (current.dismissedAt == null) {
        await b.modules.serverpod_calendar.calendarInvitation.dismiss(
          entry,
          current.revision,
        );
      }
    }
    for (final parent in calendars) {
      try {
        final events = await b.modules.serverpod_calendar.calendarEvent.list(
          parent,
          pageSize: 100,
          fieldGroups: [],
        );
        for (final event in events.events) {
          await b.modules.serverpod_calendar.calendarEvent.deleteEvent(
            event.id,
            event.revision,
          );
        }
        await b.modules.serverpod_calendar.calendar.delete(parent, 1);
      } on cal.CalendarException catch (e) {
        if (e.code != cal.CalendarFailureCode.accessDenied) {
          rethrow;
        }
      }
    }
  }
}
