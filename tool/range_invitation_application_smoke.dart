import 'dart:io';
import 'dart:convert';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:serverpod_calendar_feed_client/serverpod_calendar_feed_client.dart'
    as feed;

Future<void> rangeInvitationApplicationSmoke(List<Client> clients) async {
  final a = clients.first, b = clients.last, api = b.modules.serverpod_calendar;
  final manager = a.modules.serverpod_calendar_feed.calendarFeed;
  final id = const cal.Uuid().v4obj();
  void require(bool value, String message) {
    if (!value) {
      throw StateError(message);
    }
  }

  Future<(int, String?, String)> fetch(Uri uri, [String? etag]) async {
    final http = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final request = await http.getUrl(uri);
      request.followRedirects = false;
      if (etag != null) {
        request.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
      }
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      final text = await response.transform(utf8.decoder).join();
      return (
        response.statusCode,
        response.headers.value(HttpHeaders.etagHeader),
        text,
      );
    } finally {
      http.close(force: true);
    }
  }

  cal.CalendarInvitationOccurrenceApplyRequest command(
    cal.CalendarInvitationOccurrenceApplicationView v,
  ) => cal.CalendarInvitationOccurrenceApplyRequest(
    invitationId: v.invitationId,
    sourceId: v.incomingSourceId!,
    linkId: v.linkId,
    expectedInvitationRevision: v.invitationRevision,
    expectedEventRevision: v.eventRevision,
    expectedCalendarRevision: v.calendarRevision,
    expectedApplicationRevision: v.applicationRevision,
    expectedOccurrenceRevision: v.occurrenceRevision,
  );
  final master = await a.invitationDemo.simulateRecurring(
    id,
    const cal.Uuid().v4obj(),
    1,
    'Range application client',
  );
  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Range application client',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  cal.CalendarInvitationAdoptionReceipt? link;
  cal.UuidValue? entry;
  feed.CalendarFeedView? subscription;
  try {
    link = await api.calendarInvitation.adopt(
      cal.CalendarInvitationAdoptionRequest(
        invitationId: master.entryId,
        sourceId: master.sourceId,
        expectedRevision: 1,
        calendarId: calendar,
        expectedCalendarRevision: 1,
      ),
    );
    subscription = await manager.create(
      feed.CalendarFeedSettings(
        displayName: 'Synthetic range feed',
        calendarIds: [calendar],
      ),
    );
    final credential = await manager.createCredential(
      subscription.id,
      subscription.revision,
      'Synthetic range URL',
    );
    final url = Uri.parse(credential.url).replace(port: 18282);
    final before = await fetch(url);
    require(
      before.$1 == 200 && before.$2 != null,
      'Initial range feed unavailable',
    );
    final incoming = await a.invitationDemo.simulateRange(
      id,
      const cal.Uuid().v4obj(),
      2,
      false,
    );
    entry = incoming.entryId;
    final view = await api.calendarInvitation.rangeApplication(entry);
    require(
      view.canApply &&
          view.isThisAndFuture &&
          view.originalStart.start.day == 3,
      'Range preview lost typed source',
    );
    require(
      (await fetch(url, before.$2)).$1 == 304,
      'Review-only range receipt changed publication',
    );
    final input = command(view);
    final race = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation.applyRangeUpdate(
          input,
        ),
      ),
    );
    require(
      race.first.id == race.last.id && race.first.eventRevision == 2,
      'Range race duplicated effect',
    );
    final published = await fetch(url, before.$2);
    require(
      published.$1 == 200 &&
          published.$2 != before.$2 &&
          published.$3.contains('RANGE=THISANDFUTURE'),
      'Applied range did not change ETag/canonical range output',
    );
    await a.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      3,
      'Master after range',
    );
    final v = await api.calendarInvitation.application(master.entryId);
    require(
      v.canApply && !v.occurrenceCompositionBlocked,
      'Range blocked valid master composition',
    );
    final masterInput = cal.CalendarInvitationApplyRequest(
      invitationId: v.invitationId,
      sourceId: v.incomingSourceId!,
      linkId: v.linkId,
      expectedInvitationRevision: v.invitationRevision!,
      expectedEventRevision: v.eventRevision,
      expectedCalendarRevision: v.calendarRevision,
      expectedApplicationRevision: v.applicationRevision,
      expectedOccurrenceRevision: v.occurrenceRevision,
    );
    final composed = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation.applyUpdate(
          masterInput,
        ),
      ),
    );
    require(
      composed.first.id == composed.last.id &&
          composed.first.eventRevision == 3,
      'Composed master raced twice',
    );
    final retained = await api.calendarInvitation.rangeApplication(entry);
    require(
      retained.isThisAndFuture &&
          retained.acceptedVersion.sequence == 2 &&
          retained.currentOccurrence!.summary ==
              'Synthetic occurrence update' &&
          retained.occurrenceRevision == 2,
      'Master composition changed accepted range values/version',
    );
    require(
      (await api.calendarInvitation.applyRangeUpdate(input)).id ==
          race.first.id,
      'Master lost retained range receipt',
    );
    final currentFeed = await fetch(url);
    await a.invitationDemo.simulateRange(id, const cal.Uuid().v4obj(), 4, true);
    final cancelled = await api.calendarInvitation.rangeApplication(entry);
    require(
      cancelled.canApply &&
          cancelled.incomingKind ==
              cal.CalendarInvitationSourceKind.rangeCancellation,
      'Range CANCEL preview did not enable explicit application',
    );
    require(
      (await fetch(url, currentFeed.$2)).$1 == 304,
      'Unapplied range CANCEL changed publication',
    );
    require(
      (await api.calendarInvitation.applyRangeUpdate(input)).id ==
              race.first.id &&
          (await api.calendarInvitation.getInvitation(entry)).dismissedAt ==
              null,
      'Retained range retry dismissed a newer notice',
    );
    final cancelInput = command(cancelled);
    final cancelledRace = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation
            .applyRangeCancellation(cancelInput),
      ),
    );
    require(
      cancelledRace.first.id == cancelledRace.last.id,
      'Range cancellation duplicated effects',
    );
    final masked = await api.calendarInvitation.rangeApplication(entry);
    require(
      masked.hasAcceptedRangeCancellation &&
          !masked.hasLocalChanges &&
          masked.currentOccurrence!.status == cal.CalendarEventStatus.cancelled,
      'Accepted cancellation projection/clean-state lost',
    );
    require(
      (await fetch(url, currentFeed.$2)).$1 != 304 &&
          (await fetch(url)).$1 != 200,
      'Masked unrepresentable series leaked stale 304 or a lossy feed',
    );
    require(
      (await api.calendarInvitation.applyRangeCancellation(cancelInput)).id ==
          cancelledRace.first.id,
      'Cancellation exact retry changed receipt',
    );
    stdout.writeln(
      'PASS: generated-client two-host range preview/apply and master races, preserved source versions/retries, receipt-only versus applied feed ETags and explicit range cancellation, masked-feed rejection and stable retries.',
    );
  } finally {
    if (subscription != null) {
      final current = await manager.read(subscription.id);
      await manager.delete(current.id, current.revision);
    }
    if (link != null) {
      final event = await api.calendarEvent.getEvent(link.eventId, []);
      await api.calendarEvent.deleteEvent(link.eventId, event.revision);
    }
    await api.calendar.delete(calendar, 1);
    for (final e in [master.entryId, ?entry]) {
      final current = await api.calendarInvitation.getInvitation(e);
      if (current.dismissedAt == null) {
        await api.calendarInvitation.dismiss(e, current.revision);
      }
    }
  }
}
