import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:serverpod_calendar_feed_client/serverpod_calendar_feed_client.dart'
    as feed;

final class _Fetched {
  const _Fetched(this.code, this.headers, this.bytes);
  final int code;
  final Map<String, String> headers;
  final List<int> bytes;
  String? get etag => headers['etag'];
}

Future<_Fetched> _fetch(
  Uri uri, {
  String method = 'GET',
  Map<String, String> headers = const {},
}) async {
  final client = HttpClient()
    ..autoUncompress = false
    ..connectionTimeout = const Duration(seconds: 5);
  try {
    final request = await client.openUrl(method, uri);
    headers.forEach(request.headers.set);
    final response = await request.close().timeout(const Duration(seconds: 30));
    final bytes = await response
        .fold<List<int>>([], (a, b) => a..addAll(b))
        .timeout(const Duration(seconds: 10));
    final values = <String, String>{};
    response.headers.forEach(
      (name, valuesList) => values[name] = valuesList.join(','),
    );
    return _Fetched(response.statusCode, values, bytes);
  } catch (_) {
    throw StateError('Synthetic subscription HTTP request failed');
  } finally {
    client.close(force: true);
  }
}

void _require(bool value, String message) {
  if (!value) throw StateError(message);
}

/// Real HTTP and generated management clients against independent hosts.
Future<void> feedSmoke(
  List<Client> clients, {
  Future<void> Function(bool)? setPublisherBlocked,
}) async {
  if (clients.length != 2) {
    throw ArgumentError('The feed probe requires two hosts');
  }
  final a = clients.first.modules.serverpod_calendar;
  final b = clients.last.modules.serverpod_calendar;
  final managerA = clients.first.modules.serverpod_calendar_feed.calendarFeed;
  final managerB = clients.last.modules.serverpod_calendar_feed.calendarFeed;
  final calendars = <cal.CalendarMutationReceipt>[];
  final events = <cal.CalendarEventReceipt>[];
  final feeds = <feed.CalendarFeedView>[];
  final tokens = <String>[];
  try {
    for (var i = 0; i < 2; i++) {
      final calendar = (await a.calendar.create(
        cal.CalendarCreateRequest(
          displayName: 'Synthetic subscription source $i',
          availabilityZoneId: 'Etc/UTC',
          noRuleFallback: cal.CalendarNoRuleFallback.free,
        ),
      ))!;
      calendars.add(calendar);
      final bytes = ByteData.sublistView(
        Uint8List.fromList(
          utf8.encode(
            [
              'BEGIN:VCALENDAR',
              'VERSION:2.0',
              'PRODID:Synthetic',
              'BEGIN:VEVENT',
              'UID:copied-subscription@example.invalid',
              'DTSTAMP:20261025T000000Z',
              'DTSTART:20300101T120000Z',
              'DURATION:PT1H',
              'RRULE:FREQ=DAILY;COUNT=3',
              'SUMMARY:Subscribed synthetic event',
              'BEGIN:VALARM',
              'ACTION:DISPLAY',
              'TRIGGER:-PT5M',
              'DESCRIPTION:Never publish source alarm text',
              'END:VALARM',
              'END:VEVENT',
              'END:VCALENDAR',
              '',
            ].join('\r\n'),
          ),
        ),
      );
      events.add(
        (await a.calendarEvent.importEvents(
          cal.CalendarEventImportRequest(
            calendarId: calendar.calendarId,
            expectedRevision: 1,
            bytes: bytes,
          ),
        )).receipts.single,
      );
    }
    final settings = feed.CalendarFeedSettings(
      displayName: 'Synthetic combined feed',
      calendarIds: calendars.map((c) => c.calendarId).toList(),
      protocolMetadata: cal.CalendarProtocolMetadata(
        names: [
          cal.CalendarTextVariant(
            value: 'Explicit subscription title',
            language: 'en',
          ),
        ],
        descriptions: [],
      ),
    );
    final combined = await managerA.create(settings);
    feeds.add(combined);
    final first = await managerA.createCredential(
      combined.id,
      combined.revision,
      'First URL',
    );
    final second = await managerB.createCredential(
      combined.id,
      2,
      'Second URL',
    );
    final url = Uri.parse(first.url), otherUrl = Uri.parse(second.url);
    tokens.addAll([
      url.pathSegments.last.replaceFirst('.ics', ''),
      otherUrl.pathSegments.last.replaceFirst('.ics', ''),
    ]);
    final survivorUrl = url.replace(port: 18282);
    final get = await _fetch(
      url,
      headers: {'Accept-Encoding': 'gzip', 'Host': 'ignored.example.invalid'},
    );
    _require(get.code == 200 && get.etag != null, 'Subscription GET failed');
    final text = utf8.decode(get.bytes);
    _require(
      text.contains('NAME;LANGUAGE=en:Explicit subscription title'),
      'Feed presentation was not serialized',
    );
    _require(
      !text.contains('VALARM') &&
          !text.contains('Never publish source alarm text'),
      'Alarm leaked into subscription',
    );
    _require(
      !text.contains('copied-subscription@example.invalid') &&
          events.every((e) => text.contains('UID:urn:uuid:${e.eventId}')),
      'Copies lost distinct publication identities',
    );
    _require(
      get.headers['content-encoding'] == null && text.contains('RRULE:'),
      'Encoding/recurrence profile changed',
    );
    final remote = await _fetch(survivorUrl);
    _require(
      remote.etag == get.etag &&
          base64Encode(remote.bytes) == base64Encode(get.bytes),
      'Hosts produced different snapshots',
    );
    final secondGet = await _fetch(otherUrl);
    _require(
      secondGet.etag == get.etag,
      'Independent credentials changed publication bytes',
    );
    final head = await _fetch(url, method: 'HEAD');
    _require(
      head.code == 200 &&
          head.bytes.isEmpty &&
          head.etag == get.etag &&
          head.headers['content-length'] == '${get.bytes.length}',
      'HEAD differs from GET',
    );
    final unchanged = await _fetch(
      survivorUrl,
      headers: {'If-None-Match': '"unmatched", W/${get.etag}'},
    );
    _require(
      unchanged.code == 304 &&
          unchanged.bytes.isEmpty &&
          unchanged.etag == get.etag,
      'Weak conditional subscription failed',
    );
    _require(
      unchanged.headers['content-length'] == null ||
          unchanged.headers['content-length'] == '${get.bytes.length}',
      '304 reported an incorrect representation length',
    );
    final precondition = await _fetch(
      url,
      headers: {'If-Match': 'W/${get.etag}', 'If-None-Match': get.etag!},
    );
    _require(
      precondition.code == 412 &&
          precondition.headers['cache-control'] == 'no-store',
      'Precondition precedence changed',
    );
    final malformed = await _fetch(
      url,
      headers: {'If-None-Match': '"unterminated'},
    );
    _require(
      malformed.code == 400 && malformed.headers['cache-control'] == 'no-store',
      'Malformed condition was cached',
    );
    final range = await _fetch(
      url,
      headers: {
        'Range': 'bytes=0-9',
        'If-Modified-Since': 'Wed, 01 Jan 2098 00:00:00 GMT',
      },
    );
    _require(
      range.code == 200 &&
          range.headers['content-range'] == null &&
          range.etag == get.etag,
      'Deferred date/range profile changed',
    );
    await managerB.revokeCredential(
      combined.id,
      3,
      first.credential.id,
      first.credential.revision,
    );
    for (final target in [url, survivorUrl]) {
      final revoked = await _fetch(
        target,
        headers: {'If-None-Match': get.etag!},
      );
      _require(
        revoked.code == 404 &&
            revoked.etag == null &&
            revoked.headers['cache-control'] == 'no-store',
        'Committed revocation failed before conditional handling',
      );
    }
    _require(
      (await _fetch(otherUrl)).etag == get.etag,
      'Revocation changed another credential representation',
    );
    final metadata = cal.CalendarEventDescriptiveMetadata(
      priority: 0,
      geographicPosition: cal.CalendarEventGeographicPosition(
        latitudeText: '+090.000000000000000000',
        longitudeText: '-000.000',
      ),
      resourceGroups: [
        cal.CalendarEventResourceGroup(
          values: ['Room', '', 'Room'],
          language: 'en',
          alternativeUri: 'cid:labels@example.invalid',
        ),
      ],
    );
    final results = await Future.wait([
      for (final api in [a, b])
        () async {
          try {
            await api.calendarEvent.updateDescriptiveMetadata(
              cal.CalendarEventDescriptiveRequest(
                eventId: events.first.eventId,
                expectedRevision: 1,
                metadata: metadata,
              ),
            );
            return true;
          } on cal.CalendarException catch (e) {
            if (e.code != cal.CalendarFailureCode.staleRevision) rethrow;
            return false;
          }
        }(),
    ]);
    _require(
      results.where((v) => v).length == 1,
      'Descriptive metadata race did not fence one stale write',
    );
    final descriptive = await _fetch(
      otherUrl.replace(port: 18282),
      headers: {'If-None-Match': get.etag!},
    );
    final descriptiveText = utf8.decode(descriptive.bytes);
    _require(
      descriptive.code == 200 &&
          descriptive.etag != get.etag &&
          descriptiveText.contains('GEO:+090.000000000000000000;-000.000') &&
          descriptiveText.contains('PRIORITY:0') &&
          descriptiveText.contains(
            'RESOURCES;LANGUAGE=en;ALTREP="cid:labels@example.invalid":Room,,Room',
          ),
      'Cross-host descriptive feed projection or ETag failed',
    );
    _require(
      (await _fetch(
            otherUrl,
            headers: {'If-None-Match': descriptive.etag!},
          )).code ==
          304,
      'Stable descriptive feed did not return 304',
    );
    await b.calendarEvent.changeStatus(
      cal.CalendarEventStatusRequest(
        eventId: events.first.eventId,
        expectedRevision: 2,
        status: cal.CalendarEventStatus.cancelled,
      ),
    );
    events[0] = events[0].copyWith(revision: 3);
    final changed = await _fetch(
      otherUrl.replace(port: 18282),
      headers: {'If-None-Match': get.etag!},
    );
    _require(
      changed.code == 200 &&
          changed.etag != get.etag &&
          utf8.decode(changed.bytes).contains('STATUS:CANCELLED'),
      'Cross-host event change retained stale publication',
    );
    final canonical = await a.calendarEvent.exportEvents(
      cal.CalendarEventExportRequest(
        calendarId: calendars.last.calendarId,
        expectedRevision: 1,
        selection: [
          cal.CalendarEventExportSelection(
            eventId: events.last.eventId,
            expectedRevision: 1,
          ),
        ],
      ),
    );
    final sourceText = utf8.decode(
      canonical.buffer.asUint8List(
        canonical.offsetInBytes,
        canonical.lengthInBytes,
      ),
    );
    _require(
      sourceText.contains('UID:copied-subscription@example.invalid') &&
          sourceText.contains('VALARM'),
      'Subscription projection modified canonical export',
    );
    // The generic invalid-token response must precede malformed conditional parsing.
    final invalidUrl = url.replace(path: '/calendar-feed/${'A' * 43}.ics');
    final denied = await _fetch(
      invalidUrl,
      headers: {'If-None-Match': '"unterminated'},
    );
    _require(
      denied.code == 404 && denied.headers['cache-control'] == 'no-store',
      'Invalid token leaked conditional state',
    );
    if (setPublisherBlocked != null) {
      try {
        await setPublisherBlocked(true);
        for (final target in [otherUrl, otherUrl.replace(port: 18282)]) {
          final blocked = await _fetch(
            target,
            headers: {'If-None-Match': changed.etag!},
          );
          _require(
            blocked.code == 404 && blocked.etag == null,
            'Publisher withdrawal retained access',
          );
        }
      } finally {
        await setPublisherBlocked(false);
      }
      _require(
        (await _fetch(otherUrl)).etag == changed.etag,
        'Restored publication changed unchanged bytes',
      );
    }
    var transportFailure = false;
    try {
      final fault = await _fetch(
        otherUrl.replace(
          port: 18282,
          path: '/calendar-feed-transport-probe/${otherUrl.pathSegments.last}',
        ),
      );
      transportFailure = fault.code >= 500;
    } on StateError {
      transportFailure = true;
    }
    _require(
      transportFailure,
      'The opt-in post-handler transport fault was not exercised',
    );
    _require(
      (await _fetch(otherUrl.replace(port: 18282))).code == 200,
      'Transport failure stopped the host',
    );
    var redacted = false;
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (!redacted && DateTime.now().isBefore(deadline)) {
      redacted = (await File(
        '.local/host-smoke-b.log',
      ).readAsString()).contains('[calendar feed request redacted]');
      if (!redacted) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    _require(redacted, 'Framework transport diagnostics were not redacted');
    Future<Object?> attempt(Future<Object?> request) async {
      try {
        return await request;
      } on feed.CalendarFeedException catch (e) {
        return e;
      } on cal.CalendarException catch (e) {
        return e;
      }
    }

    // Race the last active slot at the same expected aggregate revision.
    var current = await managerA.read(combined.id);
    for (var i = 0; i < 14; i++) {
      final issued = await managerA.createCredential(
        combined.id,
        current.revision,
        'Capacity fixture',
      );
      tokens.add(
        Uri.parse(issued.url).pathSegments.last.replaceFirst('.ics', ''),
      );
      current = await managerA.read(combined.id);
    }
    final raced = await Future.wait([
      attempt(
        managerA.createCredential(combined.id, current.revision, 'Race A'),
      ),
      attempt(
        managerB.createCredential(combined.id, current.revision, 'Race B'),
      ),
    ]);
    _require(
      raced.whereType<feed.CalendarFeedCreatedCredential>().length == 1 &&
          raced.whereType<feed.CalendarFeedException>().single.code ==
              feed.CalendarFeedFailureCode.staleRevision,
      'Competing credential writes did not preserve capacity/revisions',
    );
    tokens.add(
      Uri.parse(
        raced.whereType<feed.CalendarFeedCreatedCredential>().single.url,
      ).pathSegments.last.replaceFirst('.ics', ''),
    );
    current = await managerA.read(combined.id);
    _require(
      (await managerB.credentials(combined.id))
              .where((c) => c.revokedAt == null)
              .length ==
          16,
      'Competing writes exceeded the active credential cap',
    );
    final capped = await attempt(
      managerB.createCredential(combined.id, current.revision, 'Over capacity'),
    );
    _require(
      capped is feed.CalendarFeedException &&
          capped.code == feed.CalendarFeedFailureCode.limitExceeded,
      'Active credential cap was not enforced',
    );
    final revisions = await Future.wait([
      attempt(
        managerA.update(
          combined.id,
          current.revision,
          settings.copyWith(displayName: 'Race A label'),
        ),
      ),
      attempt(
        managerB.update(
          combined.id,
          current.revision,
          settings.copyWith(displayName: 'Race B label'),
        ),
      ),
    ]);
    _require(
      revisions.whereType<feed.CalendarFeedView>().length == 1 &&
          revisions.whereType<feed.CalendarFeedException>().single.code ==
              feed.CalendarFeedFailureCode.staleRevision,
      'Competing feed edits did not reject a stale writer',
    );
    _require(
      (await _fetch(
            otherUrl,
            headers: {'If-None-Match': changed.etag!},
          )).code ==
          304,
      'Private labels or credential changes altered publication bytes',
    );
    final target = (await a.calendar.create(
      cal.CalendarCreateRequest(
        displayName: 'Synthetic selection/delete race',
        availabilityZoneId: 'Etc/UTC',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!;
    calendars.add(target);
    final selectionRace = await Future.wait([
      attempt(
        managerA.create(
          feed.CalendarFeedSettings(
            displayName: 'Selection race',
            calendarIds: [target.calendarId],
          ),
        ),
      ),
      attempt(b.calendar.delete(target.calendarId, target.revision)),
    ]);
    final selected = selectionRace.whereType<feed.CalendarFeedView>().toList();
    final removed = selectionRace
        .whereType<cal.CalendarMutationReceipt>()
        .toList();
    feeds.addAll(selected);
    if (removed.isNotEmpty) {
      calendars.removeWhere((c) => c.calendarId == target.calendarId);
    }
    _require(
      selected.length + removed.length == 1,
      'Calendar deletion and feed selection both committed or both failed',
    );
    _require(
      selected.isEmpty
          ? selectionRace.whereType<feed.CalendarFeedException>().single.code ==
                feed.CalendarFeedFailureCode.accessDenied
          : selectionRace.whereType<cal.CalendarException>().single.code ==
                cal.CalendarFailureCode.dependencyConflict,
      'Selection/delete race returned an unexpected boundary result',
    );
    for (final path in ['.local/host-smoke-a.log', '.local/host-smoke-b.log']) {
      final log = File(path);
      if (await log.exists()) {
        final contents = await log.readAsString();
        _require(
          tokens.every((t) => !contents.contains(t)),
          'Bearer credential appeared in application logs',
        );
      }
    }
    print(
      'PASS: two-host event subscriptions, stable UIDs/no alarms, HEAD/ETags, revocation/withdrawal, transport redaction, competing credential/settings/deletion writes and canonical export separation.',
    );
  } finally {
    for (final value in feeds.reversed) {
      final current = await managerB.read(value.id);
      await managerB.delete(value.id, current.revision);
    }
    for (final event in events.reversed) {
      await b.calendarEvent.deleteEvent(event.eventId, event.revision);
    }
    for (final calendar in calendars.reversed) {
      await b.calendar.delete(calendar.calendarId, calendar.revision);
    }
  }
}
