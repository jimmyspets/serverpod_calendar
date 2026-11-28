import 'dart:convert';
import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:serverpod_calendar_feed_client/serverpod_calendar_feed_client.dart'
    as feed;

Future<void> invitationCancellationApplicationSmoke(
  List<Client> clients,
) async {
  final a = clients.first, b = clients.last;
  final api = a.modules.serverpod_calendar,
      other = b.modules.serverpod_calendar;
  void require(bool value, String message) {
    if (!value) throw StateError(message);
  }

  Future<String> outcome(Future<Object?> Function() action) async {
    try {
      await action();
      return 'saved';
    } on cal.CalendarException catch (e) {
      return e.code.name;
    }
  }

  cal.CalendarInvitationApplyRequest body(
    cal.CalendarInvitationApplicationView view,
  ) => cal.CalendarInvitationApplyRequest(
    invitationId: view.invitationId,
    sourceId: view.incomingSourceId!,
    expectedInvitationRevision: view.invitationRevision!,
    linkId: view.linkId,
    expectedEventRevision: view.eventRevision,
    expectedCalendarRevision: view.calendarRevision,
    expectedApplicationRevision: view.applicationRevision,
  );
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
      final text = await utf8.decoder.bind(response).join();
      return (
        response.statusCode,
        response.headers.value(HttpHeaders.etagHeader),
        text,
      );
    } catch (_) {
      throw StateError('Synthetic cancellation subscription check failed');
    } finally {
      http.close(force: true);
    }
  }

  final calendar = (await api.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Synthetic cancellation application',
      availabilityZoneId: 'Etc/UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!;
  final id = const cal.Uuid().v4obj();
  final source = await a.invitationDemo.simulate(
    id,
    const cal.Uuid().v4obj(),
    null,
    'Retained meeting',
  );
  final creation = cal.CalendarInvitationAdoptionRequest(
    invitationId: source.entryId,
    sourceId: source.sourceId,
    expectedRevision: 1,
    calendarId: calendar.calendarId,
    expectedCalendarRevision: 1,
  );
  final link = await api.calendarInvitation.adopt(creation);
  feed.CalendarFeedView? subscription;
  try {
    subscription = await a.modules.serverpod_calendar_feed.calendarFeed.create(
      feed.CalendarFeedSettings(
        displayName: 'Synthetic cancellation feed',
        calendarIds: [calendar.calendarId],
      ),
    );
    final credential = await a.modules.serverpod_calendar_feed.calendarFeed
        .createCredential(
          subscription.id,
          subscription.revision,
          'Synthetic URL',
        );
    final url = Uri.parse(credential.url).replace(port: 18282);
    final before = await fetch(url);
    require(
      before.$1 == 200 && before.$2 != null,
      'Initial subscription failed',
    );
    await a.invitationDemo.simulateCancellation(
      id,
      const cal.Uuid().v4obj(),
      1,
    );
    require(
      (await fetch(url, before.$2)).$1 == 304,
      'Receipt changed native feed representation',
    );
    var view = await other.calendarInvitation.application(source.entryId);
    require(
      view.canApplyCancellation &&
          view.currentContent.status == cal.CalendarEventStatus.confirmed,
      'Cancellation was applied on receipt or not eligible',
    );
    var input = body(view);
    cal.CalendarInvitationApplyReceipt? accepted;
    final race = await Future.wait([
      outcome(() async {
        accepted = await api.calendarInvitation.applyCancellation(input);
        return accepted;
      }),
      outcome(
        () => other.calendarEvent.update(
          cal.CalendarEventUpdateRequest(
            eventId: link.eventId,
            expectedRevision: view.eventRevision,
            content: view.currentContent,
          ),
        ),
      ),
    ]);
    require(
      race.where((v) => v == 'saved').length == 1 &&
          race.contains('staleRevision'),
      'Cancellation/native save race was not fenced',
    );
    if (accepted == null) {
      input = body(await other.calendarInvitation.application(source.entryId));
      accepted = await api.calendarInvitation.applyCancellation(input);
    }
    final result = accepted;
    if (result == null) throw StateError('Missing cancellation result');
    require(
      result.kind == cal.CalendarInvitationSourceKind.meetingCancellation &&
          (await other.calendarInvitation.applyCancellation(input)).id ==
              result.id,
      'Cancellation retry lost stable kind/result',
    );
    require(
      await outcome(() => other.calendarInvitation.applyUpdate(input)) ==
          'staleRevision',
      'Cross-action retry aliased cancellation',
    );
    final cancelledFeed = await fetch(url, before.$2);
    require(
      cancelledFeed.$1 == 200 &&
          cancelledFeed.$2 != before.$2 &&
          cancelledFeed.$3.contains('STATUS:CANCELLED'),
      'Applied cancellation did not invalidate feed',
    );
    await b.invitationDemo.simulate(
      id,
      const cal.Uuid().v4obj(),
      2,
      'Explicitly reopened meeting',
    );
    view = await api.calendarInvitation.application(source.entryId);
    require(
      view.currentContent.status == cal.CalendarEventStatus.cancelled &&
          view.canApply,
      'New REQUEST reopened automatically or lacked clean projection baseline',
    );
    await other.calendarInvitation.applyUpdate(body(view));
    view = await api.calendarInvitation.application(source.entryId);
    require(
      view.currentContent.status == cal.CalendarEventStatus.confirmed &&
          view.currentContent.summary == 'Explicitly reopened meeting' &&
          view.acceptedKind == cal.CalendarInvitationSourceKind.request,
      'Explicit reopening did not accept complete REQUEST',
    );
    require(
      await outcome(() => api.calendarInvitation.applyCancellation(input)) ==
          'staleRevision',
      'Superseded cancellation replayed',
    );
    final reopenedFeed = await fetch(url, cancelledFeed.$2);
    require(
      reopenedFeed.$1 == 200 &&
          reopenedFeed.$2 != cancelledFeed.$2 &&
          !reopenedFeed.$3.contains('STATUS:CANCELLED'),
      'Explicit reopening did not invalidate feed',
    );
    await a.invitationDemo.simulateCancellation(
      id,
      const cal.Uuid().v4obj(),
      3,
    );
    view = await api.calendarInvitation.application(source.entryId);
    final third = body(view);
    final contested = await Future.wait([
      outcome(() => api.calendarInvitation.applyCancellation(third)),
      outcome(
        () => other.calendarEvent.update(
          cal.CalendarEventUpdateRequest(
            eventId: link.eventId,
            expectedRevision: view.eventRevision,
            content: view.currentContent.copyWith(
              summary: 'Private racing draft',
            ),
          ),
        ),
      ),
    ]);
    require(
      contested.where((v) => v == 'saved').length == 1 &&
          contested.contains('staleRevision'),
      'Draft/cancellation race was not fenced',
    );
    final current = await other.calendarInvitation.application(source.entryId);
    if (current.currentContent.status != cal.CalendarEventStatus.cancelled) {
      require(
        current.currentContent.summary == 'Private racing draft' &&
            current.hasLocalChanges &&
            !current.canApplyCancellation,
        'Cancellation erased a winning local draft',
      );
      require(
        await outcome(
              () => api.calendarInvitation.applyCancellation(body(current)),
            ) ==
            'dependencyConflict',
        'Refreshed cancellation bypassed dirty baseline',
      );
    }
    require(
      (await other.calendarInvitation.adopt(creation)).id == link.id,
      'Lifecycle changed immutable creation receipt',
    );
    stdout.writeln(
      'PASS: two-host explicit cancellation/reopening, stable action retries, native-save/draft races and source-receipt versus applied feed ETags.',
    );
  } finally {
    if (subscription != null) {
      final current = await a.modules.serverpod_calendar_feed.calendarFeed.read(
        subscription.id,
      );
      await a.modules.serverpod_calendar_feed.calendarFeed.delete(
        current.id,
        current.revision,
      );
    }
    final entry = await api.calendarInvitation.getInvitation(source.entryId);
    if (entry.dismissedAt == null) {
      await api.calendarInvitation.dismiss(entry.id, entry.revision);
    }
    final event = await api.calendarEvent.getEvent(link.eventId, []);
    await api.calendarEvent.deleteEvent(link.eventId, event.revision);
    await api.calendar.delete(calendar.calendarId, 1);
  }
}
