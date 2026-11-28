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
    await a.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      5,
      'Master preserving cutoff',
    );
    final maskedMaster = await api.calendarInvitation.application(
      master.entryId,
    );
    require(
      maskedMaster.hasAcceptedRangeCancellation &&
          maskedMaster.canApply &&
          !maskedMaster.occurrenceCompositionBlocked &&
          !maskedMaster.hasLocalChanges,
      'Eligible masked master remained blocked',
    );
    final maskedMasterInput = cal.CalendarInvitationApplyRequest(
      invitationId: maskedMaster.invitationId,
      sourceId: maskedMaster.incomingSourceId!,
      linkId: maskedMaster.linkId,
      expectedInvitationRevision: maskedMaster.invitationRevision!,
      expectedEventRevision: maskedMaster.eventRevision,
      expectedCalendarRevision: maskedMaster.calendarRevision,
      expectedApplicationRevision: maskedMaster.applicationRevision,
      expectedOccurrenceRevision: maskedMaster.occurrenceRevision,
    );
    final maskedMasterRace = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation.applyUpdate(
          maskedMasterInput,
        ),
      ),
    );
    require(
      maskedMasterRace.first.id == maskedMasterRace.last.id &&
          maskedMasterRace.first.eventRevision == 5,
      'Masked master race duplicated effect',
    );
    final stillCancelled = await api.calendarInvitation.rangeApplication(entry);
    require(
      stillCancelled.hasAcceptedRangeCancellation &&
          !stillCancelled.hasLocalChanges &&
          stillCancelled.acceptedVersion.sequence == 4 &&
          stillCancelled.currentOccurrence!.status ==
              cal.CalendarEventStatus.cancelled,
      'Master update reopened or changed source cancellation',
    );
    require(
      (await api.calendarInvitation.applyRangeCancellation(cancelInput)).id ==
          cancelledRace.first.id,
      'Master composition superseded original cancellation receipt',
    );
    require(
      (await fetch(url, currentFeed.$2)).$1 != 304 &&
          (await fetch(url)).$1 != 200,
      'Master composition published a lossy masked feed or stale 304',
    );
    await a.invitationDemo.simulateCancellation(
      id,
      const cal.Uuid().v4obj(),
      6,
    );
    final whole = await api.calendarInvitation.application(master.entryId);
    require(
      whole.canApplyCancellation && whole.hasAcceptedRangeCancellation,
      'Masked whole cancellation remained blocked',
    );
    cal.CalendarInvitationApplyRequest masterCommand(
      cal.CalendarInvitationApplicationView v,
    ) => cal.CalendarInvitationApplyRequest(
      invitationId: v.invitationId,
      sourceId: v.incomingSourceId!,
      linkId: v.linkId,
      expectedInvitationRevision: v.invitationRevision!,
      expectedEventRevision: v.eventRevision,
      expectedCalendarRevision: v.calendarRevision,
      expectedApplicationRevision: v.applicationRevision,
      expectedOccurrenceRevision: v.occurrenceRevision,
    );
    final wholeInput = masterCommand(whole);
    final wholeRace = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation
            .applyCancellation(wholeInput),
      ),
    );
    require(
      wholeRace.first.id == wholeRace.last.id &&
          wholeRace.first.eventRevision == 6,
      'Whole cancellation race duplicated effect',
    );
    final wholeState = await api.calendarInvitation.application(master.entryId);
    require(
      wholeState.currentContent.status == cal.CalendarEventStatus.cancelled &&
          !wholeState.hasLocalChanges &&
          wholeState.hasAcceptedRangeCancellation,
      'Whole cancellation lost protected mask or clean state',
    );
    require(
      (await fetch(url, currentFeed.$2)).$1 != 304 &&
          (await fetch(url)).$1 != 200,
      'Whole cancellation erased mask for a lossy feed',
    );
    await a.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      7,
      'Reopened master keeps cancelled suffix',
    );
    final reopen = await api.calendarInvitation.application(master.entryId);
    require(
      reopen.canApply && reopen.hasAcceptedRangeCancellation,
      'Explicit reopening remained blocked',
    );
    final reopenInput = masterCommand(reopen);
    final reopenedRace = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation.applyUpdate(
          reopenInput,
        ),
      ),
    );
    require(
      reopenedRace.first.id == reopenedRace.last.id &&
          reopenedRace.first.eventRevision == 7,
      'Reopening race duplicated effect',
    );
    final reopened = await api.calendarInvitation.application(master.entryId),
        stillMasked = await api.calendarInvitation.rangeApplication(entry);
    require(
      reopened.currentContent.status == cal.CalendarEventStatus.confirmed &&
          !reopened.hasLocalChanges &&
          stillMasked.currentOccurrence!.status ==
              cal.CalendarEventStatus.cancelled &&
          stillMasked.acceptedVersion.sequence == 4,
      'Reopening restored the cancelled suffix or changed its version',
    );
    require(
      (await api.calendarInvitation.applyRangeCancellation(cancelInput)).id ==
          cancelledRace.first.id,
      'Lifecycle transitions superseded original range cancellation receipt',
    );
    await a.invitationDemo.simulateRange(
      id,
      const cal.Uuid().v4obj(),
      8,
      false,
    );
    final restoreView = await api.calendarInvitation
        .rangeRestorationApplication(entry);
    require(
      restoreView.canApply && !restoreView.hasLocalChanges,
      'Restoration preview blocked',
    );
    final restoreInput = command(restoreView);
    final restoredRace = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation
            .applyRangeRestoration(restoreInput),
      ),
    );
    require(
      restoredRace.first.id == restoredRace.last.id &&
          restoredRace.first.eventRevision == 8,
      'Restoration race duplicated effects',
    );
    final restored = await api.calendarInvitation.rangeRestorationApplication(
      entry,
    );
    require(
      restored.hasAcceptedRangeRestoration &&
          restored.hasAcceptedRangeCancellation &&
          !restored.hasLocalChanges &&
          restored.currentOccurrence!.status ==
              cal.CalendarEventStatus.confirmed &&
          restored.acceptedKind == cal.CalendarInvitationSourceKind.request &&
          restored.acceptedVersion.sequence == 8,
      'Restored history/version/native state incorrect',
    );
    final restoredFeed = await fetch(url, currentFeed.$2);
    require(
      restoredFeed.$1 == 200 &&
          restoredFeed.$2 != null &&
          restoredFeed.$2 != currentFeed.$2,
      'Restored feed did not become representable with fresh ETag',
    );
    require(
      (await fetch(url, restoredFeed.$2)).$1 == 304,
      'Restored feed validator failed',
    );
    require(
      (await api.calendarInvitation.applyRangeRestoration(restoreInput)).id ==
          restoredRace.first.id,
      'Restoration retry changed receipt',
    );
    await a.invitationDemo.simulateRecurring(
      id,
      const cal.Uuid().v4obj(),
      9,
      'Master after restoration',
    );
    final nextMaster = await api.calendarInvitation.application(master.entryId);
    require(
      nextMaster.canApply &&
          !nextMaster.occurrenceCompositionBlocked &&
          nextMaster.hasAcceptedRangeRestoration,
      'Restored master preview blocked',
    );
    final restoredMasterInput = masterCommand(nextMaster);
    final masterRace = await Future.wait(
      clients.map(
        (c) => c.modules.serverpod_calendar.calendarInvitation.applyUpdate(
          restoredMasterInput,
        ),
      ),
    );
    require(
      masterRace.first.id == masterRace.last.id &&
          masterRace.first.eventRevision == 9,
      'Restored master duplicated effect',
    );
    final kept = await api.calendarInvitation.rangeRestorationApplication(
      entry,
    );
    require(
      kept.hasAcceptedRangeRestoration &&
          !kept.hasLocalChanges &&
          kept.acceptedVersion.sequence == 8 &&
          kept.currentOccurrence!.status == cal.CalendarEventStatus.confirmed,
      'Master altered accepted restoration',
    );
    require(
      (await api.calendarInvitation.applyRangeRestoration(restoreInput)).id ==
          restoredRace.first.id,
      'Master superseded restoration retry',
    );
    final composedFeed = await fetch(url, restoredFeed.$2);
    require(
      composedFeed.$1 == 200 &&
          composedFeed.$2 != restoredFeed.$2 &&
          composedFeed.$3.contains('Master after restoration'),
      'Restored master feed did not update',
    );
    var lifecycleFeed = composedFeed;
    for (final cancelled in [true, false]) {
      if (cancelled) {
        await a.invitationDemo.simulateCancellation(
          id,
          const cal.Uuid().v4obj(),
          10,
        );
      } else {
        await a.invitationDemo.simulateRecurring(
          id,
          const cal.Uuid().v4obj(),
          11,
          'Reopened restored meeting',
        );
      }
      final view = await api.calendarInvitation.application(master.entryId);
      require(
        view.hasAcceptedRangeRestoration &&
            (cancelled ? view.canApplyCancellation : view.canApply),
        'Restored lifecycle preview blocked',
      );
      final request = masterCommand(view);
      final results = await Future.wait(
        clients.map(
          (c) => cancelled
              ? c.modules.serverpod_calendar.calendarInvitation
                    .applyCancellation(request)
              : c.modules.serverpod_calendar.calendarInvitation.applyUpdate(
                  request,
                ),
        ),
      );
      require(
        results.first.id == results.last.id,
        'Restored lifecycle duplicated transition',
      );
      final current = await api.calendarInvitation.application(master.entryId);
      require(
        current.currentContent.status ==
                (cancelled
                    ? cal.CalendarEventStatus.cancelled
                    : cal.CalendarEventStatus.confirmed) &&
            !current.hasLocalChanges &&
            current.hasAcceptedRangeRestoration,
        'Restored lifecycle lost native/history state',
      );
      final nextFeed = await fetch(url, lifecycleFeed.$2);
      require(
        nextFeed.$1 == 200 && nextFeed.$2 != lifecycleFeed.$2,
        'Restored lifecycle stale feed validator',
      );
      require(
        (await fetch(url, nextFeed.$2)).$1 == 304,
        'Restored lifecycle validator failed',
      );
      lifecycleFeed = nextFeed;
      require(
        (await api.calendarInvitation.applyRangeRestoration(restoreInput)).id ==
            restoredRace.first.id,
        'Restored lifecycle superseded original receipt',
      );
    }
    stdout.writeln(
      'PASS: generated-client two-host range preview/apply and master races, preserved source versions/retries, receipt-only versus applied feed ETags and explicit range cancellation, masked-feed rejection, v5/v6 master composition/cancellation/reopening and stable independent retries, explicit v7 restoration and restored feed validators.',
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
