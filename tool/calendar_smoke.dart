import 'dart:convert';
import 'dart:typed_data';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

Future<void> rejects(
  Future<dynamic> Function() call,
  cal.CalendarFailureCode code,
) async {
  try {
    await call();
  } on cal.CalendarException catch (e) {
    if (e.code == code) return;
    rethrow;
  }
  throw StateError('Expected calendar rejection: $code');
}

Future<void> calendarSmoke(List<Client> clients, String bobPassword) async {
  final a = clients.first.modules.serverpod_calendar.calendar;
  final b = clients.last.modules.serverpod_calendar.calendar;
  final principal = await clients.first.smoke.whoAmI();
  const groups = cal.CalendarFieldGroup.values;
  final ids = <UuidValue>[];
  Future<cal.CalendarMutationReceipt> create() async {
    final receipt = (await a.create(
      cal.CalendarCreateRequest(
        displayName: '  Demo  ',
        availabilityZoneId: 'Europe/Stockholm',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!;
    ids.add(receipt.calendarId);
    return receipt;
  }

  try {
    final first = await create();
    final second = await create();
    check(
      first.calendarId != second.calendarId,
      'Duplicate names must have separate identities',
    );
    check(
      (await b.getCalendar(first.calendarId, groups)).displayName == 'Demo',
      'Cross-host create visibility',
    );
    final firstIdentity = (await a.getCalendar(
      first.calendarId,
      groups,
    )).protocolIdentity!;
    final secondIdentity = (await b.getCalendar(
      second.calendarId,
      groups,
    )).protocolIdentity!;
    final remoteIdentity = (await b.getCalendar(first.calendarId, [
      cal.CalendarFieldGroup.protocolIdentity,
    ])).protocolIdentity!;
    check(
      firstIdentity.uid == remoteIdentity.uid &&
          firstIdentity.lastModified == remoteIdentity.lastModified &&
          firstIdentity.uid != secondIdentity.uid &&
          firstIdentity.uid != first.calendarId.toString() &&
          firstIdentity.lastModified.isUtc &&
          firstIdentity.lastModified.millisecond == 0 &&
          firstIdentity.lastModified.microsecond == 0,
      'Distinct stable protocol identities and whole-second UTC time across hosts',
    );
    await a.updatePresentation(
      cal.CalendarPresentationUpdateRequest(
        calendarId: second.calendarId,
        expectedRevision: 1,
        displayName: 'Native metadata',
        description: '  Native\nnotes  ',
        color: '#a0b1c2',
      ),
    );
    await b.updateProtocolMetadata(
      cal.CalendarProtocolMetadataUpdateRequest(
        calendarId: second.calendarId,
        expectedRevision: 2,
        metadata: cal.CalendarProtocolMetadata(
          names: [
            cal.CalendarTextVariant(value: 'Swedish name', language: 'SV'),
            cal.CalendarTextVariant(value: 'English name', language: 'en'),
          ],
          descriptions: [cal.CalendarTextVariant(value: 'Protocol notes')],
          color: 'Turquoise',
        ),
      ),
    );
    final protocolView = await a.getCalendar(second.calendarId, [
      cal.CalendarFieldGroup.protocolMetadata,
    ]);
    check(
      protocolView.displayName == null &&
          protocolView.description == null &&
          protocolView.color == null,
      'Protocol disclosure leaked native presentation',
    );
    check(
      protocolView.protocolMetadata!.names.first.language == 'SV' &&
          protocolView.protocolMetadata!.color == 'Turquoise',
      'Cross-host protocol metadata round trip',
    );
    final nativeView = await a.getCalendar(second.calendarId, [
      cal.CalendarFieldGroup.metadata,
    ]);
    check(
      nativeView.protocolMetadata == null &&
          nativeView.protocolIdentity == null &&
          nativeView.description == '  Native\nnotes  ' &&
          nativeView.color == '#A0B1C2',
      'Native disclosure leaked protocol metadata',
    );
    await a.updateMetadata(
      cal.CalendarMetadataUpdateRequest(
        calendarId: second.calendarId,
        expectedRevision: 3,
        displayName: 'Only native name changed',
      ),
    );
    final retained = await b.getCalendar(second.calendarId, groups);
    check(
      retained.protocolIdentity!.uid == secondIdentity.uid &&
          !retained.protocolIdentity!.lastModified.isBefore(
            secondIdentity.lastModified,
          ),
      'Calendar edits changed protocol UID or moved revision time backwards',
    );
    check(
      retained.description == '  Native\nnotes  ' &&
          retained.protocolMetadata!.names.length == 2,
      'Name-only edit discarded metadata',
    );
    await rejects(
      () => a.updateProtocolMetadata(
        cal.CalendarProtocolMetadataUpdateRequest(
          calendarId: second.calendarId,
          expectedRevision: 4,
          metadata: cal.CalendarProtocolMetadata(
            names: [],
            descriptions: [],
            color: '#aabbcc',
          ),
        ),
      ),
      cal.CalendarFailureCode.validation,
    );
    await b.updatePresentation(
      cal.CalendarPresentationUpdateRequest(
        calendarId: second.calendarId,
        expectedRevision: 4,
        displayName: 'Native cleared',
      ),
    );
    final cleared = await a.getCalendar(second.calendarId, groups);
    check(
      cleared.description == null &&
          cleared.color == null &&
          cleared.protocolMetadata!.names.length == 2,
      'Clearing native fields changed protocol metadata',
    );
    await a.updateSupplementalMetadata(
      cal.CalendarSupplementalMetadataUpdateRequest(
        calendarId: second.calendarId,
        expectedRevision: cleared.revision,
        metadata: cal.CalendarSupplementalMetadata(
          url: 'https://example.invalid/calendar',
          categories: [cal.CalendarCategory(value: 'Work', language: 'SV')],
          images: [
            cal.CalendarImageLink(
              uri: 'https://example.invalid/image.png',
              display: ['BADGE', 'X-PRIVATE'],
              mediaType: 'image/png',
            ),
          ],
          refreshHint: cal.CalendarRefreshHint(hours: 24),
        ),
      ),
    );
    final extra = await create();
    await b.updateSupplementalMetadata(
      cal.CalendarSupplementalMetadataUpdateRequest(
        calendarId: extra.calendarId,
        expectedRevision: 1,
        metadata: cal.CalendarSupplementalMetadata(
          categories: [cal.CalendarCategory(value: 'Work', language: 'en')],
          images: [],
        ),
      ),
    );
    final category = cal.CalendarCategoryFilter(value: 'Work');
    final categoryPage = await a.list(
      pageSize: 1,
      fieldGroups: [cal.CalendarFieldGroup.metadata],
      categoryFilter: category,
    );
    check(
      categoryPage.nextCursor != null &&
          categoryPage.calendars.single.supplementalMetadata == null,
      'Category filtering exposed unrequested link data or missed continuation',
    );
    final categoryNext = await b.list(
      pageSize: 1,
      fieldGroups: [cal.CalendarFieldGroup.metadata],
      categoryFilter: category,
      cursor: categoryPage.nextCursor,
    );
    check(
      categoryNext.calendars.single.id != categoryPage.calendars.single.id,
      'Cross-host category continuation',
    );
    await rejects(
      () => b.list(
        pageSize: 1,
        fieldGroups: [cal.CalendarFieldGroup.metadata],
        categoryFilter: cal.CalendarCategoryFilter(value: 'work'),
        cursor: categoryPage.nextCursor,
      ),
      cal.CalendarFailureCode.invalidCursor,
    );
    final exact = await b.list(
      pageSize: 10,
      fieldGroups: groups,
      categoryFilter: cal.CalendarCategoryFilter(value: 'Work', language: 'sv'),
    );
    check(
      exact.calendars.single.id == second.calendarId &&
          exact.calendars.single.supplementalMetadata!.refreshHint!.hours == 24,
      'Exact/language category match or refresh unit retention',
    );
    check(
      exact
              .calendars
              .single
              .supplementalMetadata!
              .images
              .single
              .display!
              .last ==
          'X-PRIVATE',
      'Image hints lost',
    );
    final page = await a.list(pageSize: 1, fieldGroups: groups);
    check(
      page.nextCursor != null && page.calendars.length == 1,
      'Missing protected continuation',
    );
    final next = await b.list(
      pageSize: 1,
      fieldGroups: groups,
      cursor: page.nextCursor,
    );
    check(
      next.calendars.single.id != page.calendars.single.id,
      'Cross-host cursor replay',
    );
    await a.updateMetadata(
      cal.CalendarMetadataUpdateRequest(
        calendarId: first.calendarId,
        expectedRevision: 1,
        displayName: 'Renamed',
      ),
    );
    await rejects(
      () => b.updateMetadata(
        cal.CalendarMetadataUpdateRequest(
          calendarId: first.calendarId,
          expectedRevision: 1,
          displayName: 'Stale',
        ),
      ),
      cal.CalendarFailureCode.staleRevision,
    );
    await rejects(
      () => b.list(pageSize: 1, fieldGroups: groups, cursor: page.nextCursor),
      cal.CalendarFailureCode.invalidCursor,
    );
    final metadata = await b.getCalendar(first.calendarId, [
      cal.CalendarFieldGroup.metadata,
    ]);
    check(
      metadata.availabilityZoneId == null && metadata.displayName == 'Renamed',
      'Disclosure projection',
    );
    await b.updateSettings(
      cal.CalendarSettingsUpdateRequest(
        calendarId: first.calendarId,
        expectedRevision: 2,
        availabilityZoneId: 'UTC',
        noRuleFallback: cal.CalendarNoRuleFallback.unavailable,
      ),
    );
    cal.CalendarSubjectChangeRequest subject(
      cal.CalendarSubjectAction action,
      int revision, {
      String? externalId,
    }) => cal.CalendarSubjectChangeRequest(
      calendarId: first.calendarId,
      expectedRevision: revision,
      action: action,
      namespace: 'demo',
      kind: 'user',
      externalId: externalId ?? principal,
      contributesAvailability: true,
    );
    await rejects(
      () => a.changeSubject(
        subject(cal.CalendarSubjectAction.attach, 3, externalId: 'forged'),
      ),
      cal.CalendarFailureCode.accessDenied,
    );
    // Competing independent hosts must not leave a link attached to a marker.
    final outcomes = await Future.wait([
      a
          .delete(first.calendarId, 3)
          .then<Object?>((r) => r, onError: (Object e) => e),
      b
          .changeSubject(subject(cal.CalendarSubjectAction.attach, 3))
          .then<Object?>((r) => r, onError: (Object e) => e),
    ]);
    check(
      outcomes.whereType<cal.CalendarMutationReceipt>().length == 1,
      'Delete/attach race had multiple winners',
    );
    final winner = outcomes.whereType<cal.CalendarMutationReceipt>().single;
    if (!winner.deleted) {
      await rejects(
        () => a.delete(first.calendarId, 4),
        cal.CalendarFailureCode.dependencyConflict,
      );
      check(
        (await a.subjects(first.calendarId)).single.externalId == principal,
        'Cross-host association visibility',
      );
      await a.changeSubject(
        subject(cal.CalendarSubjectAction.setContribution, 4)
          ..contributesAvailability = false,
      );
      await b.changeSubject(subject(cal.CalendarSubjectAction.detach, 5));
      await a.delete(first.calendarId, 6);
    }
    await rejects(
      () => b.getCalendar(first.calendarId, groups),
      cal.CalendarFailureCode.accessDenied,
    );
    ids.remove(first.calendarId);
    final bob = Client(clients.last.host)
      ..authSessionManager = ClientAuthSessionManager(storage: _Storage());
    try {
      await bob.auth.updateSignedInUser(
        await bob.emailIdp.login(
          email: 'bob@example.invalid',
          password: bobPassword,
        ),
      );
      await rejects(
        () => bob.modules.serverpod_calendar.calendar.getCalendar(
          second.calendarId,
          groups,
        ),
        cal.CalendarFailureCode.accessDenied,
      );
      check(
        (await bob.modules.serverpod_calendar.calendar.list(
          pageSize: 100,
          fieldGroups: groups,
        )).calendars.every((v) => !ids.contains(v.id)),
        'Private scope leakage',
      );
      await bob.auth.signOutDevice();
    } finally {
      bob.close();
    }
    await eventImportSmoke(clients);
    await eventReplacementSmoke(clients);
    await eventContentSmoke(clients);
    await eventMetadataSmoke(clients);
    await personalAlarmSmoke(clients);
    await taskSmoke(clients);
    final ea = clients.first.modules.serverpod_calendar.calendarEvent;
    final eb = clients.last.modules.serverpod_calendar.calendarEvent;
    final eventIds = <UuidValue>[];
    try {
      for (final kind in [
        cal.CalendarEventTimeKind.date,
        cal.CalendarEventTimeKind.utc,
        cal.CalendarEventTimeKind.zoned,
      ]) {
        final receipt = (await ea.create(
          cal.CalendarEventCreateRequest(
            calendarId: second.calendarId,
            content: cal.CalendarEventContent(
              recurrence: cal.CalendarEventRecurrence(
                rule: cal.CalendarEventRule(
                  frequency: cal.CalendarEventFrequency.daily,
                  count: 3,
                  byDay: [],
                  byMonthDay: [],
                  byYearDay: [],
                  byWeekNo: [],
                  byMonth: [],
                  byHour: [],
                  byMinute: [],
                  bySetPosition: [],
                ),
                inclusions: [],
                exclusions: [],
              ),
              timing: cal.CalendarEventTiming(
                kind: kind,
                start: cal.CalendarEventCivil(
                  year: 2026,
                  month: 3,
                  day: 28,
                  hour: kind == cal.CalendarEventTimeKind.date ? 0 : 12,
                ),
                zoneId: kind == cal.CalendarEventTimeKind.zoned
                    ? 'Europe/Stockholm'
                    : null,
                duration: cal.CalendarEventDuration(days: 1),
              ),
            ),
          ),
        ))!;
        eventIds.add(receipt.eventId);
        final view = await eb.getEvent(
          receipt.eventId,
          cal.CalendarEventFieldGroup.values,
        );
        check(
          view.timing!.kind == kind &&
              view.timing!.duration!.days == 1 &&
              view.summary == null,
          'Event temporal meaning or omitted summary changed',
        );
        final query = cal.CalendarEventOccurrenceQuery(
          eventId: receipt.eventId,
          expectedRevision: 1,
          fromDate: kind == cal.CalendarEventTimeKind.date
              ? cal.CalendarEventCivil(year: 2026, month: 3, day: 27)
              : null,
          untilDate: kind == cal.CalendarEventTimeKind.date
              ? cal.CalendarEventCivil(year: 2026, month: 4, day: 1)
              : null,
          fromUtc: kind != cal.CalendarEventTimeKind.date
              ? DateTime.utc(2026, 3, 27)
              : null,
          untilUtc: kind != cal.CalendarEventTimeKind.date
              ? DateTime.utc(2026, 4, 1)
              : null,
        );
        final local = await ea.preview(query);
        final remote = await eb.preview(query);
        check(
          jsonEncode(local.toJson()) == jsonEncode(remote.toJson()) &&
              remote.occurrences.length == 3,
          'Cross-host recurrence projection differs',
        );
        if (kind == cal.CalendarEventTimeKind.zoned) {
          check(
            remote.occurrences.first.endUtc!.difference(
                  remote.occurrences.first.startUtc!,
                ) ==
                const Duration(hours: 23),
            'Recurring nominal day lost DST semantics',
          );
        }
      }
      // Independent hosts retain exceptional spans/annotations across native edits.
      final sourceFields = (await ea.create(
        cal.CalendarEventCreateRequest(
          calendarId: second.calendarId,
          content: cal.CalendarEventContent(
            summary: 'Synthetic source fields',
            timing: cal.CalendarEventTiming(
              kind: cal.CalendarEventTimeKind.utc,
              start: cal.CalendarEventCivil(
                year: 2026,
                month: 4,
                day: 2,
                hour: 12,
              ),
            ),
            periods: [
              cal.CalendarEventTiming(
                kind: cal.CalendarEventTimeKind.utc,
                start: cal.CalendarEventCivil(
                  year: 2026,
                  month: 4,
                  day: 3,
                  hour: 12,
                ),
                duration: cal.CalendarEventDuration(hours: 2),
              ),
            ],
            textParameters: cal.CalendarEventTextParameters(
              summary: cal.CalendarTextParameters(
                language: 'sv',
                alternativeUri: 'cid:synthetic@example.invalid',
              ),
            ),
          ),
        ),
      ))!;
      eventIds.add(sourceFields.eventId);
      final sourceRead = await eb.getEvent(
        sourceFields.eventId,
        cal.CalendarEventFieldGroup.values,
      );
      await eb.update(
        cal.CalendarEventUpdateRequest(
          eventId: sourceRead.id,
          expectedRevision: sourceRead.revision,
          content: cal.CalendarEventContent(
            summary: 'Changed',
            timing: sourceRead.timing!,
          ),
        ),
      );
      final retained = await ea.getEvent(
        sourceRead.id,
        cal.CalendarEventFieldGroup.values,
      );
      check(
        retained.periods!.single.duration!.hours == 2 &&
            retained.textParameters!.summary!.language == 'sv' &&
            retained.protocolVersion!.sequence == 1,
        'Cross-host source-field retention failed',
      );
      final projection = await ea.preview(
        cal.CalendarEventOccurrenceQuery(
          eventId: sourceRead.id,
          expectedRevision: 2,
          fromUtc: DateTime.utc(2026, 4, 2),
          untilUtc: DateTime.utc(2026, 4, 4),
        ),
      );
      check(
        projection.occurrences.length == 2 &&
            projection.occurrences.last.endUtc!
                    .difference(projection.occurrences.last.startUtc!)
                    .inHours ==
                2,
        'Stored PERIOD missing from cross-host calculations',
      );
      final patternId = eventIds[eventIds.length - 2];
      final patternOriginal = await eb.getEvent(
        patternId,
        cal.CalendarEventFieldGroup.values,
      );
      final patternOutcomes = await Future.wait([
        for (final api in [ea, eb])
          api
              .update(
                cal.CalendarEventUpdateRequest(
                  eventId: patternId,
                  expectedRevision: 1,
                  content: cal.CalendarEventContent(
                    timing: patternOriginal.timing!,
                    recurrence: patternOriginal.recurrence!.copyWith(
                      rule: patternOriginal.recurrence!.rule!.copyWith(
                        count: 4,
                      ),
                    ),
                  ),
                ),
              )
              .then<Object?>((r) => r, onError: (Object e) => e),
      ]);
      check(
        patternOutcomes.whereType<cal.CalendarEventReceipt>().length == 1 &&
            patternOutcomes.whereType<cal.CalendarException>().single.code ==
                cal.CalendarFailureCode.staleRevision,
        'Recurrence pattern race did not reject a stale write',
      );
      await rejects(
        () => ea.preview(
          cal.CalendarEventOccurrenceQuery(
            eventId: patternId,
            expectedRevision: 1,
            fromUtc: DateTime.utc(2026, 3, 27),
            untilUtc: DateTime.utc(2026, 4, 1),
          ),
        ),
        cal.CalendarFailureCode.staleRevision,
      );
      cal.CalendarEventTiming anchorTiming(int day, {int? replacementDay}) =>
          cal.CalendarEventTiming(
            kind: patternOriginal.timing!.kind,
            zoneId: patternOriginal.timing!.zoneId,
            start: patternOriginal.timing!.start.copyWith(
              day: replacementDay ?? day,
            ),
            duration: replacementDay == null
                ? null
                : cal.CalendarEventDuration(days: 1),
          );
      Future<void> applyOccurrence(
        cal.EndpointCalendarEvent api,
        int revision,
        cal.CalendarEventOccurrenceAction action,
        int day, {
        int? moved,
      }) async {
        await api.changeOccurrence(
          cal.CalendarEventOccurrenceChange(
            eventId: patternId,
            expectedRevision: revision,
            originalStart: anchorTiming(day),
            action: action,
            replacement: moved == null
                ? null
                : anchorTiming(day, replacementDay: moved),
          ),
        );
      }

      await applyOccurrence(
        ea,
        2,
        cal.CalendarEventOccurrenceAction.replaceFutureTiming,
        29,
        moved: 30,
      );
      await applyOccurrence(
        eb,
        3,
        cal.CalendarEventOccurrenceAction.replaceSingleTiming,
        30,
        moved: 27,
      );
      final occurrenceQuery = cal.CalendarEventOccurrenceQuery(
        eventId: patternId,
        expectedRevision: 4,
        fromUtc: DateTime.utc(2026, 3, 26),
        untilUtc: DateTime.utc(2026, 4, 4),
      );
      final movedPreview = await ea.preview(occurrenceQuery);
      check(
        movedPreview.occurrences
                    .singleWhere((o) => o.originalStart.day == 30)
                    .start
                    .day ==
                27 &&
            movedPreview.occurrences
                    .singleWhere((o) => o.originalStart.day == 29)
                    .start
                    .day ==
                30,
        'Cross-host occurrence edits lost original identity or separate single precedence',
      );
      await applyOccurrence(
        ea,
        4,
        cal.CalendarEventOccurrenceAction.cancelSingle,
        30,
      );
      check(
        (await eb.preview(occurrenceQuery.copyWith(expectedRevision: 5)))
                .occurrences
                .length ==
            3,
        'Single cancellation leaked into preview',
      );
      await applyOccurrence(
        eb,
        5,
        cal.CalendarEventOccurrenceAction.restoreSingle,
        30,
      );
      check(
        (await ea.preview(occurrenceQuery.copyWith(expectedRevision: 6)))
                .occurrences
                .singleWhere((o) => o.originalStart.day == 30)
                .start
                .day ==
            27,
        'Restoring single occurrence discarded its timing',
      );
      final occurrenceOutcomes = await Future.wait([
        for (final api in [ea, eb])
          api
              .changeOccurrence(
                cal.CalendarEventOccurrenceChange(
                  eventId: patternId,
                  expectedRevision: 6,
                  originalStart: anchorTiming(31),
                  action: cal.CalendarEventOccurrenceAction.replaceSingleTiming,
                  replacement: anchorTiming(31, replacementDay: 28),
                ),
              )
              .then<Object?>((r) => r, onError: (Object e) => e),
      ]);
      check(
        occurrenceOutcomes.whereType<cal.CalendarEventReceipt>().length == 1 &&
            occurrenceOutcomes.whereType<cal.CalendarException>().single.code ==
                cal.CalendarFailureCode.staleRevision,
        'Competing occurrence timing writes did not reject one stale revision',
      );
      final edited = await eb.getEvent(
        patternId,
        cal.CalendarEventFieldGroup.values,
      );
      check(
        edited.timing!.start.day == 28 &&
            edited.protocolUid == patternOriginal.protocolUid &&
            edited.timingOverrides!.singles.length == 2,
        'Occurrence editing rewrote master content/identity',
      );
      final privateBooking = (await ea.create(
        cal.CalendarEventCreateRequest(
          calendarId: second.calendarId,
          content: cal.CalendarEventContent(
            summary: 'Synthetic private title',
            status: cal.CalendarEventStatus.tentative,
            timing: cal.CalendarEventTiming(
              kind: cal.CalendarEventTimeKind.utc,
              start: cal.CalendarEventCivil(
                year: 2026,
                month: 4,
                day: 4,
                hour: 9,
              ),
              duration: cal.CalendarEventDuration(hours: 1),
            ),
          ),
        ),
      ))!;
      eventIds.add(privateBooking.eventId);
      final busyQuery = cal.CalendarFreeBusyQuery(
        calendarId: second.calendarId,
        fromUtc: DateTime.utc(2026, 4, 4),
        untilUtc: DateTime.utc(2026, 4, 5),
      );
      String busyWire(ByteData bytes) => utf8.decode(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      List<String> occupied(String text) => text
          .split('\r\n')
          .where((line) => line.startsWith('FREEBUSY;'))
          .toList();
      final localFile = busyWire(await a.exportFreeBusy(busyQuery));
      final remoteFile = busyWire(await b.exportFreeBusy(busyQuery));
      check(
        jsonEncode(occupied(localFile)) == jsonEncode(occupied(remoteFile)) &&
            remoteFile.contains('FBTYPE=BUSY-TENTATIVE:') &&
            !remoteFile.contains('Synthetic private title') &&
            !remoteFile.contains(privateBooking.eventId.toString()) &&
            !remoteFile.contains(second.calendarId.toString()),
        'Cross-host VFREEBUSY lost classification or disclosed identities/details',
      );
      final localBusy = await a.freeBusy(busyQuery);
      final remoteBusy = await b.freeBusy(busyQuery);
      check(
        jsonEncode(localBusy.toJson()) == jsonEncode(remoteBusy.toJson()) &&
            remoteBusy.coverage == cal.CalendarFreeBusyCoverage.complete &&
            remoteBusy.periods[1].kind == cal.CalendarFreeBusyKind.tentative,
        'Cross-host free/busy differs or lost tentative classification',
      );
      check(
        !jsonEncode(remoteBusy.toJson())
                .contains(privateBooking.eventId.toString()) &&
            !jsonEncode(remoteBusy.toJson())
                .contains('Synthetic private title'),
        'Free/busy exposed private event identity/content',
      );
      await ea.changeStatus(
        cal.CalendarEventStatusRequest(
          eventId: privateBooking.eventId,
          expectedRevision: 1,
          status: cal.CalendarEventStatus.confirmed,
        ),
      );
      check(
        (await b.freeBusy(busyQuery)).periods[1].kind ==
            cal.CalendarFreeBusyKind.busy,
        'Remote free/busy did not see committed lifecycle change',
      );
      final changedFile = busyWire(await b.exportFreeBusy(busyQuery));
      check(
        changedFile.contains('FREEBUSY;FBTYPE=BUSY:') &&
            !changedFile.contains('FBTYPE=BUSY-TENTATIVE:'),
        'Remote VFREEBUSY ignored committed lifecycle change',
      );
      final storedPrivate = await eb.getEvent(
        privateBooking.eventId,
        cal.CalendarEventFieldGroup.values,
      );
      await ea.update(
        cal.CalendarEventUpdateRequest(
          eventId: privateBooking.eventId,
          expectedRevision: 2,
          content: cal.CalendarEventContent(
            timing: storedPrivate.timing!,
            transparency: cal.CalendarEventTransparency.transparent,
          ),
        ),
      );
      check(
        (await b.freeBusy(busyQuery)).periods.single.kind ==
            cal.CalendarFreeBusyKind.free,
        'Transparent event continued blocking remote free/busy',
      );
      check(
        occupied(busyWire(await b.exportFreeBusy(busyQuery))).isEmpty,
        'Remote VFREEBUSY kept a newly transparent booking',
      );
      final aa = clients.first.modules.serverpod_calendar.calendarAvailability;
      final ab = clients.last.modules.serverpod_calendar.calendarAvailability;
      final opening = cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.utc,
        start: cal.CalendarEventCivil(year: 2026, month: 4, day: 4, hour: 8),
        end: cal.CalendarEventCivil(year: 2026, month: 4, day: 4, hour: 18),
      );
      final working = (await aa.create(
        cal.CalendarAvailabilityCreateRequest(
          calendarId: second.calendarId,
          content: cal.CalendarAvailabilityContent(
            summary: 'Private rule',
            categoryGroups: [
              cal.CalendarAvailabilityCategoryGroup(
                values: ['One', 'One'],
                language: 'en',
              ),
              cal.CalendarAvailabilityCategoryGroup(
                values: ['Två'],
                language: 'sv',
              ),
            ],
            openings: [
              cal.CalendarAvailabilityOpening(
                timing: opening,
                periods: [
                  opening.copyWith(
                    start: cal.CalendarEventCivil(
                      year: 2026,
                      month: 4,
                      day: 5,
                      hour: 9,
                    ),
                    end: null,
                    duration: cal.CalendarEventDuration(hours: 2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ))!;
      final remoteRule = await ab.getRule(working.availabilityId);
      check(
        remoteRule.content.openings.single.uid != null,
        'Opening identity was not persisted across hosts',
      );
      check(
        remoteRule.content.categoryGroups!.first.values.length == 2 &&
            remoteRule.content.categoryGroups!.last.language == 'sv' &&
            remoteRule.content.openings.single.protocolUid != null &&
            remoteRule
                    .content
                    .openings
                    .single
                    .periods!
                    .single
                    .duration!
                    .hours ==
                2,
        'Remote source-preserving groups, opening protocol UID or PERIOD lost',
      );
      final sourcePreview = await ab.preview(
        cal.CalendarAvailabilityOccurrenceQuery(
          availabilityId: remoteRule.id,
          openingUid: remoteRule.content.openings.single.uid!,
          expectedRevision: 1,
          fromUtc: DateTime.utc(2026, 4, 5),
          untilUtc: DateTime.utc(2026, 4, 6),
        ),
      );
      check(
        sourcePreview.occurrences.single.endUtc!
                .difference(sourcePreview.occurrences.single.startUtc!)
                .inHours ==
            2,
        'Remote PERIOD projection flattened its exceptional duration',
      );
      final withHours = await b.freeBusy(busyQuery);
      check(
        withHours.periods.length == 3 &&
            withHours.periods[0].kind == cal.CalendarFreeBusyKind.unavailable &&
            withHours.periods[1].startUtc.hour == 8 &&
            withHours.periods[1].kind == cal.CalendarFreeBusyKind.free &&
            !withHours.toJson().toString().contains('Private rule'),
        'Remote query ignored working hours or disclosed their label',
      );
      final detailParent = await create();
      final detailReceipt = (await aa.create(
        cal.CalendarAvailabilityCreateRequest(
          calendarId: detailParent.calendarId,
          content: cal.CalendarAvailabilityContent(
            openings: [cal.CalendarAvailabilityOpening(timing: opening)],
          ),
        ),
      ))!;
      var detail = await ab.getRule(detailReceipt.availabilityId);
      check(
        detail.protocolState.sequence == 0 &&
            detail.protocolState.openings.single.created != null,
        'New opening protocol state missing',
      );
      final protocolCreated = detail.protocolState.created;
      final openingStamp = detail.protocolState.openings.single.stamp;

      await rejects(
        () => aa.updateMetadata(
          cal.CalendarAvailabilityUpdateRequest(
            availabilityId: detail.id,
            expectedRevision: detail.revision,
            content: detail.content.copyWith(
              organizer: cal.CalendarAvailabilityOrganizer(
                address: 'urn:calendar-example:user:someone-else',
              ),
            ),
          ),
        ),
        cal.CalendarFailureCode.accessDenied,
      );
      await rejects(
        () => aa.updateMetadata(
          cal.CalendarAvailabilityUpdateRequest(
            availabilityId: detail.id,
            expectedRevision: detail.revision,
            content: detail.content.copyWith(
              extensions: [
                cal.CalendarAvailabilityExtension(
                  name: 'X-NOT-REGISTERED',
                  value: 'No',
                ),
              ],
            ),
          ),
        ),
        cal.CalendarFailureCode.validation,
      );

      await aa.updateMetadata(
        cal.CalendarAvailabilityUpdateRequest(
          availabilityId: detail.id,
          expectedRevision: 1,
          content: detail.content.copyWith(
            description: 'Synthetic notes',
            organizer: cal.CalendarAvailabilityOrganizer(
              address: 'urn:calendar-example:user:$principal',
              commonName: 'Synthetic organizer',
              language: 'en',
            ),
            textParameters: cal.CalendarAvailabilityTextParameters(
              description: cal.CalendarTextParameters(
                language: 'SV',
                alternativeUri: 'cid:synthetic@example.invalid',
              ),
            ),
            extensions: [
              cal.CalendarAvailabilityExtension(
                name: 'X-CALENDAR-EXAMPLE-LABEL',
                value: 'Synthetic label',
              ),
            ],
            categories: ['Work'],
            comments: ['Note'],
            classification: cal.CalendarAvailabilityClass.private,
          ),
        ),
      );
      detail = await ab.getRule(detail.id);
      check(
        detail.protocolState.sequence == 1 &&
            detail.protocolState.created == protocolCreated &&
            detail.protocolState.openings.single.stamp == openingStamp &&
            detail.content.description == 'Synthetic notes' &&
            detail.content.organizer?.commonName == 'Synthetic organizer' &&
            detail.content.textParameters?.description?.language == 'SV' &&
            detail.content.extensions?.single.value == 'Synthetic label' &&
            (await ab.list(detailParent.calendarId, category: 'Work')).length ==
                1,
        'Remote availability metadata/category round trip failed',
      );
      cal.CalendarAvailabilityOccurrenceChange skip() =>
          cal.CalendarAvailabilityOccurrenceChange(
            availabilityId: detail.id,
            openingUid: detail.content.openings.single.uid!,
            expectedRevision: 2,
            originalStart: opening.copyWith(end: null),
            action: cal.CalendarEventOccurrenceAction.cancelSingle,
          );
      final skips = await Future.wait([
        for (final endpoint in [aa, ab])
          () async {
            try {
              await endpoint.changeOccurrence(skip());
              return true;
            } on cal.CalendarException catch (e) {
              if (e.code == cal.CalendarFailureCode.staleRevision) return false;
              rethrow;
            }
          }(),
      ]);
      check(
        skips.where((v) => v).length == 1,
        'Competing opening changes had multiple winners',
      );
      final detailQuery = cal.CalendarFreeBusyQuery(
        calendarId: detailParent.calendarId,
        fromUtc: busyQuery.fromUtc,
        untilUtc: busyQuery.untilUtc,
      );
      check(
        (await b.freeBusy(detailQuery)).periods.single.kind ==
            cal.CalendarFreeBusyKind.unavailable,
        'Remote query ignored skipped opening',
      );
      await ab.changeOccurrence(
        skip().copyWith(
          expectedRevision: 3,
          action: cal.CalendarEventOccurrenceAction.restoreSingle,
        ),
      );
      await aa.changeOccurrence(
        skip().copyWith(
          expectedRevision: 4,
          action: cal.CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: opening.copyWith(
            start: opening.start.copyWith(hour: 9),
            end: opening.end!.copyWith(hour: 19),
          ),
        ),
      );
      final detailPreview = await ab.preview(
        cal.CalendarAvailabilityOccurrenceQuery(
          availabilityId: detail.id,
          openingUid: detail.content.openings.single.uid!,
          expectedRevision: 5,
          fromUtc: busyQuery.fromUtc,
          untilUtc: busyQuery.untilUtc,
        ),
      );
      check(
        detailPreview.occurrences.single.start.hour == 9 &&
            (await b.freeBusy(detailQuery)).periods[1].startUtc.hour == 9,
        'Remote future opening timing was not projected',
      );
      final protocolFinal = await ab.getRule(detail.id);
      check(
        protocolFinal.protocolState.sequence == 4 &&
            protocolFinal.protocolState.created == protocolCreated,
        'Cross-host occurrence protocol versions diverged',
      );
      await ab.deleteRule(detail.id, 5);
      final envelopeReceipt = (await aa.create(
        cal.CalendarAvailabilityCreateRequest(
          calendarId: detailParent.calendarId,
          content: cal.CalendarAvailabilityContent(
            openings: [],
            validFrom: opening.copyWith(end: null),
            validDuration: cal.CalendarEventDuration(hours: 1),
          ),
        ),
      ))!;
      final envelope = await ab.getRule(envelopeReceipt.availabilityId);
      check(
        envelope.content.validDuration?.hours == 1 &&
            envelope.content.validUntil == null,
        'Remote envelope duration was flattened',
      );
      await aa.update(
        cal.CalendarAvailabilityUpdateRequest(
          availabilityId: envelope.id,
          expectedRevision: 1,
          content: envelope.content,
        ),
      );
      final unchanged = await ab.getRule(envelope.id);
      check(
        unchanged.revision == 2 &&
            unchanged.protocolState.sequence == 0 &&
            unchanged.protocolState.stamp == envelope.protocolState.stamp,
        'Identical cross-host write advanced protocol state',
      );
      await ab.deleteRule(envelope.id, 2);

      final edits = await Future.wait([
        for (final endpoint in [aa, ab])
          () async {
            try {
              await endpoint.update(
                cal.CalendarAvailabilityUpdateRequest(
                  availabilityId: working.availabilityId,
                  expectedRevision: 1,
                  content: remoteRule.content.copyWith(openings: []),
                ),
              );
              return true;
            } on cal.CalendarException catch (e) {
              if (e.code == cal.CalendarFailureCode.staleRevision) return false;
              rethrow;
            }
          }(),
      ]);
      check(
        edits.where((v) => v).length == 1,
        'Competing rule writes had multiple winners',
      );
      check(
        (await a.freeBusy(busyQuery)).periods.single.kind ==
            cal.CalendarFreeBusyKind.unavailable,
        'Committed closure was not visible from another host',
      );
      await ab.deleteRule(working.availabilityId, 2);
      check(
        (await a.freeBusy(busyQuery)).periods.single.kind ==
            cal.CalendarFreeBusyKind.free,
        'Deleted rule continued restricting another host',
      );

      final importParent = await create();
      final importOther = await create();
      cal.CalendarAvailabilityImportRequest importInput(
        UuidValue parent,
        String uid,
      ) {
        final bytes = Uint8List.fromList(
          utf8.encode(
            [
              'BEGIN:VCALENDAR',
              'VERSION:2.0',
              'PRODID:-//Synthetic//EN',
              'BEGIN:VAVAILABILITY',
              'UID:$uid',
              'DTSTAMP:20400101T000000Z',
              'CONTACT:Source desk',
              'CATEGORIES;LANGUAGE=sv:Öppet,Öppet',
              'BEGIN:AVAILABLE',
              'UID:opening@example.invalid',
              'DTSTAMP:20390101T000000Z',
              'DTSTART:20261022T090000Z',
              'DURATION:PT1H',
              'RDATE;VALUE=PERIOD:20261023T090000Z/PT2H',
              'END:AVAILABLE',
              'END:VAVAILABILITY',
              'END:VCALENDAR',
              '',
            ].join('\r\n'),
          ),
        );
        return cal.CalendarAvailabilityImportRequest(
          calendarId: parent,
          expectedRevision: 1,
          bytes: ByteData.sublistView(bytes),
        );
      }

      Future<Object?> importOutcome(
        cal.EndpointCalendarAvailability api,
        cal.CalendarAvailabilityImportRequest input,
      ) => api
          .importCalendar(input)
          .then<Object?>((v) => v, onError: (Object e) => e);
      final importRace = await Future.wait([
        importOutcome(
          aa,
          importInput(importParent.calendarId, '來源@example.invalid'),
        ),
        importOutcome(
          ab,
          importInput(importParent.calendarId, '來源@example.invalid'),
        ),
      ]);
      check(
        importRace.whereType<cal.CalendarAvailabilityImportResult>().length ==
                1 &&
            importRace.whereType<cal.CalendarException>().single.code ==
                cal.CalendarFailureCode.dependencyConflict,
        'Same-destination import race must have exactly one winner',
      );
      final imported = importRace
          .whereType<cal.CalendarAvailabilityImportResult>()
          .single
          .receipts
          .single;
      final copied = (await aa.importCalendar(
        importInput(importOther.calendarId, '來源@example.invalid'),
      )).receipts.single;
      final remoteImport = await ab.getRule(imported.availabilityId);
      final copy = await ab.getRule(copied.availabilityId);
      check(
        remoteImport.protocolUid == copy.protocolUid &&
            remoteImport.id != copy.id &&
            remoteImport.content.openings.single.uid !=
                copy.content.openings.single.uid,
        'Cross-calendar imports must retain protocol UID with distinct native identities',
      );
      check(
        remoteImport.protocolState.sequence == null &&
            remoteImport.protocolState.stamp == DateTime.utc(2040) &&
            remoteImport.content.contacts!.single.value == 'Source desk' &&
            remoteImport.content.categoryGroups!.single.values.length == 2 &&
            remoteImport
                    .content
                    .openings
                    .single
                    .periods!
                    .single
                    .duration!
                    .hours ==
                2,
        'Cross-host import lost source protocol or metadata state',
      );

      final exportRequest = cal.CalendarAvailabilityExportRequest(
        calendarId: importParent.calendarId,
        expectedRevision: 1,
        selection: [
          cal.CalendarAvailabilityExportSelection(
            availabilityId: remoteImport.id,
            expectedRevision: remoteImport.revision,
          ),
        ],
      );
      final exportA = await aa.exportCalendar(exportRequest);
      final exportB = await ab.exportCalendar(exportRequest);
      final bytesA = exportA.buffer.asUint8List(
        exportA.offsetInBytes,
        exportA.lengthInBytes,
      );
      final bytesB = exportB.buffer.asUint8List(
        exportB.offsetInBytes,
        exportB.lengthInBytes,
      );
      check(
        utf8.decode(bytesA) == utf8.decode(bytesB),
        'Hosts produced different availability exports',
      );
      final exportedParent = await create();
      final reimported = (await ab.importCalendar(
        cal.CalendarAvailabilityImportRequest(
          calendarId: exportedParent.calendarId,
          expectedRevision: 1,
          bytes: exportA,
        ),
      )).receipts.single;
      final restored = await aa.getRule(reimported.availabilityId);
      check(
        restored.protocolUid == remoteImport.protocolUid &&
            restored.id != remoteImport.id &&
            restored.protocolState.stamp == remoteImport.protocolState.stamp &&
            restored.content.contacts!.single.value == 'Source desk' &&
            restored.content.categoryGroups!.single.values.length == 2 &&
            restored.content.openings.single.periods!.single.duration!.hours ==
                2,
        'Authenticated cross-host export/import did not preserve source state',
      );

      cal.CalendarAvailabilityReplaceRequest replacement(
        cal.CalendarAvailabilityView rule,
        String label,
      ) => cal.CalendarAvailabilityReplaceRequest(
        calendarId: rule.calendarId,
        expectedRevision: 1,
        selection: [
          cal.CalendarAvailabilityExportSelection(
            availabilityId: rule.id,
            expectedRevision: rule.revision,
          ),
        ],
        bytes: ByteData.sublistView(
          Uint8List.fromList(
            utf8.encode(
              utf8
                  .decode(bytesA)
                  .replaceAll('CONTACT:Source desk', 'CONTACT:$label'),
            ),
          ),
        ),
      );
      Future<Object?> replaceOutcome(
        cal.EndpointCalendarAvailability api,
        cal.CalendarAvailabilityReplaceRequest request,
      ) => api
          .replaceFromImport(request)
          .then<Object?>((v) => v, onError: (Object e) => e);
      final replacementRace = await Future.wait([
        replaceOutcome(aa, replacement(restored, 'First source update')),
        replaceOutcome(ab, replacement(restored, 'Second source update')),
      ]);
      check(
        replacementRace
                    .whereType<cal.CalendarAvailabilityReplaceResult>()
                    .length ==
                1 &&
            replacementRace.whereType<cal.CalendarException>().single.code ==
                cal.CalendarFailureCode.staleRevision,
        'Competing replacements must have one revision winner',
      );
      var winner = await ab.getRule(restored.id);
      check(
        winner.revision == 2 &&
            winner.content.openings.single.uid ==
                restored.content.openings.single.uid,
        'Cross-host replacement lost revision or opening identity',
      );
      final contact = winner.content.contacts!.single.value;
      final noop = await aa.replaceFromImport(replacement(winner, contact));
      check(
        !noop.receipts.single.changed &&
            noop.receipts.single.receipt.revision == 2,
        'Cross-host replay was not a no-op',
      );
      final nativeRace = await Future.wait<Object?>([
        aa
            .updateMetadata(
              cal.CalendarAvailabilityUpdateRequest(
                availabilityId: winner.id,
                expectedRevision: 2,
                content: winner.content.copyWith(summary: 'Native race edit'),
              ),
            )
            .then<Object?>((v) => v, onError: (Object e) => e),
        replaceOutcome(ab, replacement(winner, 'Third source update')),
      ]);
      check(
        nativeRace.whereType<cal.CalendarException>().length == 1 &&
            nativeRace.whereType<cal.CalendarException>().single.code ==
                cal.CalendarFailureCode.staleRevision,
        'Native edit/replacement race had an invalid outcome',
      );
      winner = await aa.getRule(restored.id);
      check(
        winner.revision == 3,
        'Native edit/replacement winner was not visible remotely',
      );
      await ab.deleteRule(winner.id, winner.revision);
      await rejects(
        () => aa.replaceFromImport(replacement(winner, 'After deletion')),
        cal.CalendarFailureCode.accessDenied,
      );

      await ab.deleteRule(imported.availabilityId, 1);
      await aa.deleteRule(copied.availabilityId, 1);
      final importDeleteParent = await create();
      final importDeleteRace = await Future.wait<Object?>([
        a
            .delete(importDeleteParent.calendarId, 1)
            .then<Object?>((v) => v, onError: (Object e) => e),
        importOutcome(
          ab,
          importInput(importDeleteParent.calendarId, 'delete-race'),
        ),
      ]);
      if (importDeleteRace.last is cal.CalendarAvailabilityImportResult) {
        check(
          importDeleteRace.first is cal.CalendarException &&
              (importDeleteRace.first as cal.CalendarException).code ==
                  cal.CalendarFailureCode.dependencyConflict,
          'Calendar deletion ignored imported dependencies',
        );
        await aa.deleteRule(
          (importDeleteRace.last as cal.CalendarAvailabilityImportResult)
              .receipts
              .single
              .availabilityId,
          1,
        );
      } else {
        check(
          importDeleteRace.first is cal.CalendarMutationReceipt &&
              importDeleteRace.last is cal.CalendarException &&
              (importDeleteRace.last as cal.CalendarException).code ==
                  cal.CalendarFailureCode.accessDenied,
          'Import attached definitions to deleted calendar',
        );
        ids.remove(importDeleteParent.calendarId);
      }

      final ruleParent = await create();
      final parentRace = await Future.wait<Object?>([
        a
            .delete(ruleParent.calendarId, 1)
            .then<Object?>((v) => v, onError: (Object e) => e),
        ab
            .create(
              cal.CalendarAvailabilityCreateRequest(
                calendarId: ruleParent.calendarId,
                content: cal.CalendarAvailabilityContent(openings: []),
              ),
            )
            .then<Object?>((v) => v, onError: (Object e) => e),
      ]);
      final createdRules = parentRace
          .whereType<cal.CalendarAvailabilityReceipt>();
      if (createdRules.isNotEmpty) {
        check(
          parentRace.first is cal.CalendarException &&
              (parentRace.first as cal.CalendarException).code ==
                  cal.CalendarFailureCode.dependencyConflict,
          'Parent deletion ignored committed rule dependency',
        );
        await aa.deleteRule(createdRules.single.availabilityId, 1);
      } else {
        ids.remove(ruleParent.calendarId);
        check(
          parentRace.first is cal.CalendarMutationReceipt &&
              parentRace.last is cal.CalendarException &&
              (parentRace.last as cal.CalendarException).code ==
                  cal.CalendarFailureCode.accessDenied,
          'Rule was attached to a deleted parent',
        );
      }
      final sa =
          clients.first.modules.serverpod_calendar.calendarAvailabilitySearch;
      final sb =
          clients.last.modules.serverpod_calendar.calendarAvailabilitySearch;
      final association = (await a.getCalendar(
        second.calendarId,
        groups,
      )).revision;
      await a.changeSubject(
        cal.CalendarSubjectChangeRequest(
          calendarId: second.calendarId,
          expectedRevision: association,
          action: cal.CalendarSubjectAction.attach,
          namespace: 'demo',
          kind: 'user',
          externalId: principal,
          contributesAvailability: true,
        ),
      );
      final searchInput = cal.CalendarAvailabilitySearchQuery(
        targets: [
          cal.CalendarAvailabilityTarget(
            namespace: 'demo',
            kind: 'user',
            externalId: principal,
          ),
        ],
        fromUtc: busyQuery.fromUtc,
        untilUtc: busyQuery.untilUtc,
        mode: cal.CalendarAvailabilitySearchMode.commonFree,
      );
      final localSubject = await sa.search(searchInput);
      final remoteSubject = await sb.search(searchInput);
      check(
        localSubject.commonCoverage == cal.CalendarFreeBusyCoverage.complete &&
            jsonEncode(
                  localSubject.commonSlots.map((s) => s.toJson()).toList(),
                ) ==
                jsonEncode(
                  remoteSubject.commonSlots.map((s) => s.toJson()).toList(),
                ),
        'Cross-host subject resolution or common slots differ',
      );
      check(
        !remoteSubject.toJson().toString().contains(
          second.calendarId.toString(),
        ),
        'Subject summary disclosed a contributing calendar ID',
      );
      final another = (await aa.create(
        cal.CalendarAvailabilityCreateRequest(
          calendarId: second.calendarId,
          content: cal.CalendarAvailabilityContent(openings: []),
        ),
      ))!;
      check(
        (await sb.search(searchInput)).commonSlots.isEmpty,
        'Remote subject query ignored committed closure',
      );
      await ab.deleteRule(another.availabilityId, 1);
      final unlinkRevision = (await b.getCalendar(
        second.calendarId,
        groups,
      )).revision;
      await b.changeSubject(
        cal.CalendarSubjectChangeRequest(
          calendarId: second.calendarId,
          expectedRevision: unlinkRevision,
          action: cal.CalendarSubjectAction.detach,
          namespace: 'demo',
          kind: 'user',
          externalId: principal,
          contributesAvailability: true,
        ),
      );
      check(
        (await sa.search(searchInput)).commonCoverage ==
            cal.CalendarFreeBusyCoverage.unknown,
        'Remote contributor removal was interpreted as free',
      );
      final firstPage = await ea.list(
        second.calendarId,
        pageSize: 1,
        fieldGroups: cal.CalendarEventFieldGroup.values,
      );
      final remotePage = await eb.list(
        second.calendarId,
        pageSize: 1,
        fieldGroups: cal.CalendarEventFieldGroup.values,
        cursor: firstPage.nextCursor,
      );
      check(
        firstPage.events.single.id != remotePage.events.single.id,
        'Cross-host event cursor repeated an item',
      );
      final id = eventIds.first;
      final original = await ea.getEvent(
        id,
        cal.CalendarEventFieldGroup.values,
      );
      final updates = await Future.wait([
        for (final endpoint in [ea, eb])
          () async {
            try {
              await endpoint.changeStatus(
                cal.CalendarEventStatusRequest(
                  eventId: id,
                  expectedRevision: 1,
                  status: cal.CalendarEventStatus.cancelled,
                ),
              );
              return true;
            } on cal.CalendarException catch (e) {
              if (e.code == cal.CalendarFailureCode.staleRevision) return false;
              rethrow;
            }
          }(),
      ]);
      check(
        updates.where((v) => v).length == 1,
        'Competing event writes did not reject one stale revision',
      );
      final cancelled = await eb.getEvent(
        id,
        cal.CalendarEventFieldGroup.values,
      );
      check(
        cancelled.protocolUid == original.protocolUid &&
            cancelled.status == cal.CalendarEventStatus.cancelled,
        'Cancellation lost identity or removed event',
      );
      final parent = await b.getCalendar(second.calendarId, groups);
      await rejects(
        () => a.delete(second.calendarId, parent.revision),
        cal.CalendarFailureCode.dependencyConflict,
      );
      await rejects(
        () => ea.list(
          second.calendarId,
          pageSize: 1,
          fieldGroups: cal.CalendarEventFieldGroup.values,
          cursor: firstPage.nextCursor,
        ),
        cal.CalendarFailureCode.invalidCursor,
      );
    } finally {
      for (final id in eventIds) {
        final view = await eb.getEvent(id, cal.CalendarEventFieldGroup.values);
        await eb.deleteEvent(id, view.revision);
      }
    }
    final raceParent = (await a.create(
      cal.CalendarCreateRequest(
        displayName: 'Event parent race',
        availabilityZoneId: 'UTC',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!;
    UuidValue? raceEvent;
    final parentRace = await Future.wait([
      () async {
        try {
          await a.delete(raceParent.calendarId, 1);
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.dependencyConflict) {
            return false;
          }
          rethrow;
        }
      }(),
      () async {
        try {
          raceEvent = (await eb.create(
            cal.CalendarEventCreateRequest(
              calendarId: raceParent.calendarId,
              content: cal.CalendarEventContent(
                timing: cal.CalendarEventTiming(
                  kind: cal.CalendarEventTimeKind.date,
                  start: cal.CalendarEventCivil(year: 2026, month: 1, day: 1),
                ),
              ),
            ),
          ))!.eventId;
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.accessDenied) return false;
          rethrow;
        }
      }(),
    ]);
    check(
      parentRace.where((v) => v).length == 1,
      'Parent deletion and event creation did not serialize across hosts',
    );
    if (raceEvent != null) {
      await ea.deleteEvent(raceEvent!, 1);
      await b.delete(raceParent.calendarId, 1);
    }
    print(
      'PASS: subject/common-free resolution across hosts and remote source/association changes, working-hours CRUD/composition and cross-host rule writes/parent races, per-calendar free/busy and native events/recurrence/occurrence timing, temporal forms, lifecycle/cursors and cross-host stale-write race, stable calendar protocol UID/time, links/categories/image/refresh metadata, cross-host filtered cursors, native/protocol metadata isolation, multilingual round trips and generated calendar CRUD, scope isolation, cursors, stale writes and cross-host delete/attach race.',
    );
  } finally {
    for (final id in ids) {
      final v = await b.getCalendar(id, groups);
      await b.delete(id, v.revision);
    }
  }
}

Future<void> eventMetadataSmoke(List<Client> clients) async {
  final calendars = clients.first.modules.serverpod_calendar.calendar;
  final a = clients.first.modules.serverpod_calendar.calendarEvent,
      b = clients.last.modules.serverpod_calendar.calendarEvent;
  final parent = (await calendars.create(
    cal.CalendarCreateRequest(
      displayName: 'Event metadata smoke',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  UuidValue? id;
  final properties = [
    'CLASS:PRIVATE',
    'URL:https://example.invalid/event',
    'CATEGORIES;LANGUAGE=en:Work,Work',
    'COMMENT;LANGUAGE=sv:Source note',
    'CONTACT;ALTREP="cid:desk@example.invalid":Cross-host source desk',
    'RELATED-TO:metadata@example.invalid',
    'ATTACH;VALUE=URI;FMTTYPE=application/pdf:urn:source:file',
    'ORGANIZER;CN=Inert organizer:mailto:source-organizer@example.invalid',
    'ATTENDEE;PARTSTAT=DECLINED:mailto:source-attendee@example.invalid',
    'BEGIN:VALARM',
    'ACTION:DISPLAY',
    'DESCRIPTION:Private cross-host source alarm',
    'TRIGGER:-PT5M',
    'UID:source-alarm',
    'ACKNOWLEDGED:20261023T100000Z',
    'END:VALARM',
    'BEGIN:VALARM',
    'ACTION:DISPLAY',
    'DESCRIPTION:Source snooze',
    'TRIGGER;VALUE=DATE-TIME:20261026T080000Z',
    'UID:source-snooze',
    'RELATED-TO;RELTYPE=SNOOZE:source-alarm',
    'END:VALARM',
  ];
  final source = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:Synthetic',
    'BEGIN:VEVENT',
    'UID:metadata@example.invalid',
    'DTSTAMP:20261023T120000Z',
    'DTSTART:20261026T090000Z',
    'RRULE:FREQ=DAILY;COUNT=3',
    ...properties,
    'END:VEVENT',
    'BEGIN:VEVENT',
    'UID:metadata@example.invalid',
    'DTSTAMP:20261023T120000Z',
    'RECURRENCE-ID:20261027T090000Z',
    'DTSTART:20261027T110000Z',
    ...properties,
    'END:VEVENT',
    'END:VCALENDAR',
    '',
  ].join('\r\n');
  final original = cal.CalendarEventTiming(
    kind: cal.CalendarEventTimeKind.utc,
    start: cal.CalendarEventCivil(year: 2026, month: 10, day: 27, hour: 9),
  );
  cal.CalendarEventExportRequest selection(int revision) =>
      cal.CalendarEventExportRequest(
        calendarId: parent,
        expectedRevision: 1,
        selection: [
          cal.CalendarEventExportSelection(
            eventId: id!,
            expectedRevision: revision,
          ),
        ],
      );
  String decode(ByteData data) => utf8.decode(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  try {
    id = (await a.importEvents(
      cal.CalendarEventImportRequest(
        calendarId: parent,
        expectedRevision: 1,
        bytes: ByteData.sublistView(Uint8List.fromList(utf8.encode(source))),
      ),
    )).receipts.single.eventId;
    final text = decode(await b.exportEvents(selection(1)));
    check(
      'Cross-host source desk'.allMatches(text).length == 2 &&
          text.contains('CATEGORIES;LANGUAGE=en:Work,Work') &&
          'source-attendee@example.invalid'.allMatches(text).length == 2 &&
          'urn:source:file'.allMatches(text).length == 2 &&
          'BEGIN:VALARM'.allMatches(text).length == 4,
      'Cross-host metadata export preserves grouped own and master source',
    );
    check(
      !jsonEncode(
        (await b.getEvent(id, cal.CalendarEventFieldGroup.values)).toJson(),
      ).contains('Cross-host source desk'),
      'Ordinary event views exclude source metadata',
    );
    await b.changeOccurrence(
      cal.CalendarEventOccurrenceChange(
        eventId: id,
        expectedRevision: 1,
        originalStart: original,
        action: cal.CalendarEventOccurrenceAction.clearSingleTiming,
      ),
    );
    final hidden = await a.getEvent(id, cal.CalendarEventFieldGroup.values);
    check(
      hidden.timingOverrides == null &&
          hidden.occurrenceProtocolVersions!.isEmpty,
      'Metadata-only original is hidden from ordinary event projections',
    );
    await rejects(
      () => a.exportEvents(selection(2)),
      cal.CalendarFailureCode.validation,
    );
    await b.changeOccurrence(
      cal.CalendarEventOccurrenceChange(
        eventId: id,
        expectedRevision: 2,
        originalStart: original,
        action: cal.CalendarEventOccurrenceAction.replaceFutureTiming,
        replacement: original.copyWith(
          start: original.start.copyWith(hour: 10),
        ),
      ),
    );
    final ranged = decode(await a.exportEvents(selection(3)));
    check(
      'Cross-host source desk'.allMatches(ranged).length == 2 &&
          ranged.contains('RANGE=THISANDFUTURE'),
      'Timing scope transfer preserves source metadata across hosts',
    );
    print(
      'PASS: event source metadata cross-host storage/export, ordinary projection privacy, inherited timing and range-transfer preservation.',
    );
  } finally {
    if (id != null) {
      final current = await a.getEvent(id, []);
      await a.deleteEvent(id, current.revision);
    }
    await calendars.delete(parent, 1);
  }
}

Future<void> eventContentSmoke(List<Client> clients) async {
  final calendars = clients.first.modules.serverpod_calendar.calendar;
  final a = clients.first.modules.serverpod_calendar.calendarEvent,
      b = clients.last.modules.serverpod_calendar.calendarEvent;
  final parent = (await calendars.create(
    cal.CalendarCreateRequest(
      displayName: 'Event content smoke',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  UuidValue? id;
  cal.CalendarEventTiming timing(int d) => cal.CalendarEventTiming(
    kind: cal.CalendarEventTimeKind.date,
    start: cal.CalendarEventCivil(year: 2026, month: 10, day: d),
  );
  try {
    id = (await a.create(
      cal.CalendarEventCreateRequest(
        calendarId: parent,
        content: cal.CalendarEventContent(
          summary: 'Master',
          timing: timing(22),
          recurrence: cal.CalendarEventRecurrence(
            rule: cal.CalendarEventRule(
              frequency: cal.CalendarEventFrequency.daily,
              count: 3,
              byDay: [],
              byMonthDay: [],
              byYearDay: [],
              byWeekNo: [],
              byMonth: [],
              byHour: [],
              byMinute: [],
              bySetPosition: [],
            ),
            inclusions: [],
            exclusions: [],
          ),
        ),
      ),
    ))!.eventId;
    cal.CalendarEventOccurrenceContentRequest request(String text, int rev) =>
        cal.CalendarEventOccurrenceContentRequest(
          eventId: id!,
          expectedRevision: rev,
          originalStart: timing(23),
          changes: [
            cal.CalendarEventOccurrenceContentChange(
              field: cal.CalendarEventContentField.summary,
              action: cal.CalendarEventContentAction.setValue,
              text: text,
            ),
          ],
        );
    final results = await Future.wait([
      a
          .changeOccurrenceContent(request('A', 1))
          .then<Object?>((v) => v)
          .catchError((Object e) => e),
      b
          .changeOccurrenceContent(request('B', 1))
          .then<Object?>((v) => v)
          .catchError((Object e) => e),
    ]);
    check(
      results.whereType<cal.CalendarException>().length == 1 &&
          results.whereType<cal.CalendarException>().single.code ==
              cal.CalendarFailureCode.staleRevision,
      'Cross-host content race admits one writer',
    );
    await b.changeOccurrenceContent(request('Reviewed', 2));
    final preview = await a.preview(
      cal.CalendarEventOccurrenceQuery(
        eventId: id,
        expectedRevision: 3,
        fromDate: timing(22).start,
        untilDate: timing(25).start,
        fieldGroups: [cal.CalendarEventFieldGroup.summary],
      ),
    );
    check(
      preview.occurrences[1].content!.summary == 'Reviewed' &&
          preview.occurrences[2].content!.summary == 'Master',
      'Remote content stays local to original',
    );
    check(
      preview.occurrences[1].start.day == 23,
      'Content edit preserves timing inheritance',
    );
    await rejects(
      () => a.exportEvents(
        cal.CalendarEventExportRequest(
          calendarId: parent,
          expectedRevision: 1,
          selection: [
            cal.CalendarEventExportSelection(eventId: id!, expectedRevision: 3),
          ],
        ),
      ),
      cal.CalendarFailureCode.validation,
    );
    print(
      'PASS: event content cross-host stale race, original-local disclosure, unchanged timing and lossy export rejection.',
    );
  } finally {
    if (id != null) {
      final current = await a.getEvent(id, []);
      await a.deleteEvent(id, current.revision);
    }
    await calendars.delete(parent, 1);
  }
}

Future<void> eventReplacementSmoke(List<Client> clients) async {
  final calendars = clients.first.modules.serverpod_calendar.calendar;
  final a = clients.first.modules.serverpod_calendar.calendarEvent;
  final b = clients.last.modules.serverpod_calendar.calendarEvent;
  final parent = (await calendars.create(
    cal.CalendarCreateRequest(
      displayName: 'Event replacement smoke',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  UuidValue? id;
  ByteData source(String summary) => ByteData.sublistView(
    Uint8List.fromList(
      utf8.encode(
        [
          'BEGIN:VCALENDAR',
          'VERSION:2.0',
          'PRODID:Synthetic',
          'BEGIN:VEVENT',
          'UID:event-replacement@example.invalid',
          'DTSTAMP:20261023T120000Z',
          'DTSTART:20261026T090000Z',
          'SUMMARY:$summary',
          'END:VEVENT',
          'END:VCALENDAR',
          '',
        ].join('\r\n'),
      ),
    ),
  );
  try {
    id = (await a.importEvents(
      cal.CalendarEventImportRequest(
        calendarId: parent,
        expectedRevision: 1,
        bytes: source('Before'),
      ),
    )).receipts.single.eventId;
    cal.CalendarEventReplaceRequest replace(int revision, String summary) =>
        cal.CalendarEventReplaceRequest(
          calendarId: parent,
          expectedRevision: 1,
          selection: [
            cal.CalendarEventExportSelection(
              eventId: id!,
              expectedRevision: revision,
            ),
          ],
          bytes: source(summary),
        );
    final results = await Future.wait([
      a
          .replaceFromImport(replace(1, 'Source A'))
          .then<Object>((v) => v)
          .catchError((Object e) => e),
      b
          .replaceFromImport(replace(1, 'Source B'))
          .then<Object>((v) => v)
          .catchError((Object e) => e),
    ]);
    check(
      results.whereType<cal.CalendarException>().length == 1 &&
          results.whereType<cal.CalendarException>().single.code ==
              cal.CalendarFailureCode.staleRevision,
      'Cross-host event replacement race admits one writer',
    );
    await b.replaceFromImport(replace(2, 'Reviewed retry'));
    final noOp = await a.replaceFromImport(replace(3, 'Reviewed retry'));
    check(
      !noOp.receipts.single.changed &&
          noOp.receipts.single.receipt.revision == 3,
      'Cross-host source retry baseline supports identical no-op',
    );
    final current = await a.getEvent(id, cal.CalendarEventFieldGroup.values);
    await b.update(
      cal.CalendarEventUpdateRequest(
        eventId: id,
        expectedRevision: 3,
        content: cal.CalendarEventContent(
          summary: 'Local edit',
          timing: current.timing!,
          status: current.status!,
          transparency: current.transparency!,
        ),
      ),
    );
    await rejects(
      () => a.replaceFromImport(replace(4, 'Source after local edit')),
      cal.CalendarFailureCode.dependencyConflict,
    );
    check(
      (await a.getEvent(id, cal.CalendarEventFieldGroup.values)).summary ==
          'Local edit',
      'Remote native edit prevents source overwrite',
    );
    print(
      'PASS: event replacement cross-host stale race, explicit retry, true no-op and local-edit protection.',
    );
  } finally {
    if (id != null) {
      final current = await a.getEvent(id, []);
      await a.deleteEvent(id, current.revision);
    }
    await calendars.delete(parent, 1);
  }
}

Future<void> eventImportSmoke(List<Client> clients) async {
  final a = clients.first.modules.serverpod_calendar.calendar;
  final b = clients.last.modules.serverpod_calendar.calendar;
  final ea = clients.first.modules.serverpod_calendar.calendarEvent;
  final eb = clients.last.modules.serverpod_calendar.calendarEvent;
  final parents = <UuidValue>{};
  final objects = <UuidValue>{};
  Future<UuidValue> parent() async {
    final r = (await a.create(
      cal.CalendarCreateRequest(
        displayName: 'Synthetic event import',
        availabilityZoneId: 'UTC',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!;
    parents.add(r.calendarId);
    return r.calendarId;
  }

  String source(String uid) => [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Synthetic cross-host events//EN',
    'BEGIN:VEVENT',
    'UID:$uid',
    'DTSTAMP:20400101T000000Z',
    'SEQUENCE:7',
    'DTSTART:20261026T090000Z',
    'DURATION:PT1H',
    'SUMMARY;LANGUAGE=sv:Imported event',
    'RRULE:FREQ=DAILY;COUNT=3',
    'RDATE;VALUE=PERIOD:20261030T090000Z/PT2H',
    'END:VEVENT',
    'BEGIN:VEVENT',
    'UID:$uid',
    'DTSTAMP:20390101T000000Z',
    'RECURRENCE-ID:20261027T090000Z',
    'DTSTART:20261027T110000Z',
    'STATUS:CANCELLED',
    'END:VEVENT',
    'END:VCALENDAR',
    '',
  ].join('\r\n');
  cal.CalendarEventImportRequest request(UuidValue id, String uid) =>
      cal.CalendarEventImportRequest(
        calendarId: id,
        expectedRevision: 1,
        bytes: ByteData.sublistView(
          Uint8List.fromList(utf8.encode(source(uid))),
        ),
      );
  try {
    final first = await parent(), second = await parent();
    final outcomes = await Future.wait([
      for (final api in [ea, eb])
        () async {
          try {
            final result = await api.importEvents(
              request(first, 'same-source@example.invalid'),
            );
            objects.addAll(result.receipts.map((v) => v.eventId));
            return true;
          } on cal.CalendarException catch (e) {
            if (e.code == cal.CalendarFailureCode.dependencyConflict) {
              return false;
            }
            rethrow;
          }
        }(),
    ]);
    check(
      outcomes.where((v) => v).length == 1,
      'Competing event imports did not serialize',
    );
    final id = objects.single;
    final view = await eb.getEvent(id, cal.CalendarEventFieldGroup.values);
    check(
      view.protocolUid == 'same-source@example.invalid' &&
          view.protocolVersion!.sequence == 7 &&
          view.protocolVersion!.created == null &&
          view.occurrenceProtocolVersions!.single.version.stamp ==
              DateTime.utc(2039) &&
          view.textParameters!.summary!.language == 'sv',
      'Imported source state differed across hosts',
    );
    cal.CalendarEventExportRequest exportRequest(int revision) =>
        cal.CalendarEventExportRequest(
          calendarId: first,
          expectedRevision: 1,
          selection: [
            cal.CalendarEventExportSelection(
              eventId: id,
              expectedRevision: revision,
            ),
          ],
        );
    String text(ByteData data) => utf8.decode(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    final exportedA = text(await ea.exportEvents(exportRequest(1))),
        exportedB = text(await eb.exportEvents(exportRequest(1)));
    check(
      exportedA == exportedB &&
          !exportedA.contains(id.toString()) &&
          !exportedA.contains('importBaseline'),
      'Cross-host event export differs or leaked private storage',
    );
    await eb.update(
      cal.CalendarEventUpdateRequest(
        eventId: id,
        expectedRevision: 1,
        content: cal.CalendarEventContent(
          summary: 'Current exported event',
          timing: view.timing!,
          recurrence: view.recurrence,
          status: view.status!,
          transparency: view.transparency!,
        ),
      ),
    );
    await rejects(
      () => ea.exportEvents(exportRequest(1)),
      cal.CalendarFailureCode.staleRevision,
    );
    final current = text(await ea.exportEvents(exportRequest(2)));
    check(
      current.contains('Current exported event') &&
          current.contains('SEQUENCE:8'),
      'Export returned an old source snapshot',
    );
    final copy = await eb.importEvents(
      request(second, 'same-source@example.invalid'),
    );
    objects.add(copy.receipts.single.eventId);
    check(
      copy.receipts.single.eventId != id,
      'Independent copies reused native identity',
    );
    final busy = await b.freeBusy(
      cal.CalendarFreeBusyQuery(
        calendarId: first,
        fromUtc: DateTime.utc(2026, 10, 30, 9),
        untilUtc: DateTime.utc(2026, 10, 30, 11),
      ),
    );
    check(
      busy.coverage == cal.CalendarFreeBusyCoverage.complete &&
          busy.periods.single.kind == cal.CalendarFreeBusyKind.busy,
      'Imported PERIOD missing from cross-host occupancy',
    );
    final race = await parent();
    final raceOutcomes = await Future.wait([
      () async {
        try {
          final imported = await ea.importEvents(request(race, 'race-source'));
          objects.addAll(imported.receipts.map((v) => v.eventId));
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.accessDenied) return false;
          rethrow;
        }
      }(),
      () async {
        try {
          await b.delete(race, 1);
          parents.remove(race);
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.dependencyConflict) {
            return false;
          }
          rethrow;
        }
      }(),
    ]);
    check(
      raceOutcomes.where((v) => v).length == 1,
      'Parent delete and event import failed to serialize',
    );
    print(
      'PASS: create-only event import source retention, independent copies, cross-host occupied time, competing UID and parent deletion races.',
    );
  } finally {
    for (final id in objects) {
      final current = await eb.getEvent(id, cal.CalendarEventFieldGroup.values);
      await eb.deleteEvent(id, current.revision);
    }
    for (final id in parents) {
      await b.delete(id, 1);
    }
  }
}

Future<void> taskSmoke(List<Client> clients) async {
  await taskReplacementSmoke(clients);
  await taskImportSmoke(clients);
  final calendars = clients.first.modules.serverpod_calendar.calendar;
  final tasks = clients.first.modules.serverpod_calendar.calendarTask;
  final remote = clients.last.modules.serverpod_calendar.calendarTask;
  final parents = <UuidValue>[];
  final ids = <UuidValue>[];
  Future<UuidValue> parent() async {
    final result = (await calendars.create(
      cal.CalendarCreateRequest(
        displayName: 'Task test',
        availabilityZoneId: 'Europe/Stockholm',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!.calendarId;
    parents.add(result);
    return result;
  }

  cal.CalendarTaskContent content([String? title]) => cal.CalendarTaskContent(
    summary: title,
    timing: cal.CalendarTaskTiming(kind: cal.CalendarTaskTimeKind.undated),
  );
  Future<cal.CalendarTaskReceipt> create(UuidValue calendar) async {
    final task = (await tasks.create(
      cal.CalendarTaskCreateRequest(
        calendarId: calendar,
        content: content('Shared task'),
        assignees: [],
      ),
    ))!;
    ids.add(task.taskId);
    return task;
  }

  Future<cal.CalendarTaskView> read(UuidValue id) =>
      remote.getTask(id, cal.CalendarTaskFieldGroup.values);
  try {
    final calendar = await parent(),
        task = await create(calendar),
        second = await create(calendar);
    final first = await read(task.taskId);
    check(
      first.progress!.percentComplete == 0 &&
          first.protocolVersion!.sequence == 0,
      'Native task initial progress/version',
    );
    final cursor = (await tasks.list(
      calendar,
      pageSize: 1,
      fieldGroups: cal.CalendarTaskFieldGroup.values,
    )).nextCursor!;
    check(
      (await remote.list(
            calendar,
            pageSize: 1,
            fieldGroups: cal.CalendarTaskFieldGroup.values,
            cursor: cursor,
          )).tasks.length ==
          1,
      'Task continuation across independent hosts',
    );
    await rejects(
      () => calendars.list(
        pageSize: 1,
        fieldGroups: cal.CalendarFieldGroup.values,
        cursor: cursor,
      ),
      cal.CalendarFailureCode.invalidCursor,
    );
    final actor = await clients.first.smoke.whoAmI();
    await remote.changeAssignments(
      cal.CalendarTaskAssignmentsRequest(
        taskId: task.taskId,
        expectedRevision: 1,
        assignees: [
          cal.CalendarTaskAssignee(
            namespace: 'demo',
            kind: 'user',
            externalId: actor,
          ),
        ],
      ),
    );
    check(
      (await tasks.getTask(
            task.taskId,
            cal.CalendarTaskFieldGroup.values,
          )).protocolVersion ==
          first.protocolVersion,
      'Assignment-only edits preserve protocol version across hosts',
    );
    await rejects(
      () => tasks.changeAssignments(
        cal.CalendarTaskAssignmentsRequest(
          taskId: task.taskId,
          expectedRevision: 2,
          assignees: [
            cal.CalendarTaskAssignee(
              namespace: 'demo',
              kind: 'user',
              externalId: 'untrusted',
            ),
          ],
        ),
      ),
      cal.CalendarFailureCode.accessDenied,
    );
    await tasks.changeProgress(
      cal.CalendarTaskProgressRequest(
        taskId: task.taskId,
        expectedRevision: 2,
        action: cal.CalendarTaskProgressAction.setPercentage,
        percentComplete: 65,
      ),
    );
    await remote.changeProgress(
      cal.CalendarTaskProgressRequest(
        taskId: task.taskId,
        expectedRevision: 3,
        action: cal.CalendarTaskProgressAction.complete,
      ),
    );
    var current = await read(task.taskId);
    check(
      current.progress!.percentComplete == 100 &&
          current.progress!.completedAt!.isUtc &&
          current.progress!.completedAt!.millisecond == 0,
      'Completion server-recorded whole-second UTC',
    );
    await tasks.changeProgress(
      cal.CalendarTaskProgressRequest(
        taskId: task.taskId,
        expectedRevision: 4,
        action: cal.CalendarTaskProgressAction.cancel,
      ),
    );
    current = await read(task.taskId);
    check(
      current.progress!.percentComplete == 100 &&
          current.progress!.completedAt == null,
      'Cancellation keeps percentage and clears completion',
    );
    await remote.changeProgress(
      cal.CalendarTaskProgressRequest(
        taskId: task.taskId,
        expectedRevision: 5,
        action: cal.CalendarTaskProgressAction.reopen,
      ),
    );
    check(
      (await read(task.taskId)).progress!.percentComplete == 0,
      'Reopening resets percentage',
    );
    final outcomes = await Future.wait(
      [tasks, remote].map((api) async {
        try {
          await api.update(
            cal.CalendarTaskUpdateRequest(
              taskId: task.taskId,
              expectedRevision: 6,
              content: content('Competing edit'),
            ),
          );
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.staleRevision) return false;
          rethrow;
        }
      }),
    );
    check(
      outcomes.where((v) => v).length == 1,
      'Cross-host task revision race must have one winner',
    );
    await rejects(
      () => calendars.delete(calendar, 1),
      cal.CalendarFailureCode.dependencyConflict,
    );
    await rejects(
      () => remote.list(
        calendar,
        pageSize: 1,
        fieldGroups: cal.CalendarTaskFieldGroup.values,
        cursor: cursor,
      ),
      cal.CalendarFailureCode.invalidCursor,
    );
    check(
      (await read(task.taskId)).protocolUid == first.protocolUid,
      'Task protocol UID is stable',
    );
    final busy = await calendars.freeBusy(
      cal.CalendarFreeBusyQuery(
        calendarId: calendar,
        fromUtc: DateTime.utc(2026, 3, 29),
        untilUtc: DateTime.utc(2026, 3, 30),
      ),
    );
    check(
      busy.periods.every((p) => p.kind == cal.CalendarFreeBusyKind.free),
      'Tasks do not book time',
    );
    await remote.deleteTask(second.taskId, 1);
    ids.remove(second.taskId);
    final series = (await tasks.create(
      cal.CalendarTaskCreateRequest(
        calendarId: calendar,
        content: cal.CalendarTaskContent(
          summary: 'Recurring host task',
          timing: cal.CalendarTaskTiming(
            kind: cal.CalendarTaskTimeKind.zoned,
            zoneId: 'Europe/Stockholm',
            start: cal.CalendarEventCivil(
              year: 2026,
              month: 3,
              day: 28,
              hour: 9,
            ),
            duration: cal.CalendarEventDuration(days: 1),
          ),
          recurrence: cal.CalendarEventRecurrence(
            rule: cal.CalendarEventRule(
              frequency: cal.CalendarEventFrequency.daily,
              count: 3,
              byDay: [],
              byMonthDay: [],
              byYearDay: [],
              byWeekNo: [],
              byMonth: [],
              byHour: [],
              byMinute: [],
              bySetPosition: [],
            ),
            inclusions: [],
            exclusions: [],
          ),
        ),
        assignees: [],
      ),
    ))!;
    ids.add(series.taskId);
    cal.CalendarTaskOccurrenceQuery preview(int revision) =>
        cal.CalendarTaskOccurrenceQuery(
          taskId: series.taskId,
          expectedRevision: revision,
          fromUtc: DateTime.utc(2026, 3, 27),
          untilUtc: DateTime.utc(2026, 3, 31),
        );
    final projected = await remote.previewOccurrences(preview(1)),
        original = projected.occurrences.first.originalStart;
    check(
      projected.occurrences.first.dueUtc!
              .difference(projected.occurrences.first.startUtc!)
              .inHours ==
          23,
      'Task nominal day through DST across hosts',
    );
    final seriesVersion = (await read(series.taskId)).protocolVersion;
    await tasks.changeOccurrenceProgress(
      cal.CalendarTaskOccurrenceProgressRequest(
        taskId: series.taskId,
        expectedRevision: 1,
        originalStart: original,
        action: cal.CalendarTaskProgressAction.complete,
      ),
    );
    check(
      (await read(series.taskId)).protocolVersion == seriesVersion,
      'Occurrence progress leaves master protocol version unchanged across hosts',
    );

    final observed = await remote.previewOccurrences(preview(2));
    check(
      observed.occurrences.first.progress.status ==
              cal.CalendarTaskStatus.completed &&
          observed.occurrences[1].progress.status ==
              cal.CalendarTaskStatus.needsAction,
      'Per-occurrence progress is independent across hosts',
    );
    final competing = await Future.wait(
      [tasks, remote].map((api) async {
        try {
          await api.changeOccurrenceProgress(
            cal.CalendarTaskOccurrenceProgressRequest(
              taskId: series.taskId,
              expectedRevision: 2,
              originalStart: original,
              action: cal.CalendarTaskProgressAction.reopen,
            ),
          );
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.staleRevision) return false;
          rethrow;
        }
      }),
    );
    check(
      competing.where((v) => v).length == 1,
      'Competing occurrence progress has exactly one winner',
    );
    final historyQuery = cal.CalendarTaskHistoryQuery(
      taskId: series.taskId,
      expectedRevision: 3,
      originalStart: original,
      pageSize: 1,
    );
    final history = await tasks.occurrenceHistory(historyQuery);
    check(
      history.entries.single.action ==
              cal.CalendarTaskProgressAction.complete &&
          history.nextCursor != null,
      'Durable task history initial authorized page',
    );
    check(
      (await remote.occurrenceHistory(
            historyQuery.copyWith(cursor: history.nextCursor),
          )).entries.single.action ==
          cal.CalendarTaskProgressAction.reopen,
      'Task history continuation across hosts',
    );
    final currentSeries = await read(series.taskId);
    await rejects(
      () => tasks.update(
        cal.CalendarTaskUpdateRequest(
          taskId: series.taskId,
          expectedRevision: 3,
          content: cal.CalendarTaskContent(
            timing: currentSeries.timing!,
            recurrence: currentSeries.recurrence!.copyWith(
              exclusions: [original],
            ),
          ),
        ),
      ),
      cal.CalendarFailureCode.validation,
    );
    print(
      'PASS: recurring task DST projections, independent progress, preserved history, cross-host cursors and competing occurrence writes.',
    );

    final raceParent = await parent();
    final race = await Future.wait([
      () async {
        try {
          await create(raceParent);
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.accessDenied) return false;
          rethrow;
        }
      }(),
      () async {
        try {
          await clients.last.modules.serverpod_calendar.calendar.delete(
            raceParent,
            1,
          );
          parents.remove(raceParent);
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.dependencyConflict) {
            return false;
          }
          rethrow;
        }
      }(),
    ]);
    check(
      race.where((v) => v).length == 1,
      'Task creation and parent deletion serialize across hosts',
    );
    print(
      'PASS: native tasks across two hosts, assignments, progress, cancellation, revision/parent races and opaque continuations.',
    );
  } finally {
    for (final id in ids) {
      final current = await read(id);
      await remote.deleteTask(id, current.revision);
    }
    for (final id in parents) {
      await calendars.delete(id, 1);
    }
  }
}

Future<void> taskReplacementSmoke(List<Client> clients) async {
  final calendar = clients.first.modules.serverpod_calendar.calendar;
  final a = clients.first.modules.serverpod_calendar.calendarTask;
  final b = clients.last.modules.serverpod_calendar.calendarTask;
  final principal = await clients.first.smoke.whoAmI();
  final parent = (await calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Task replacement smoke',
      availabilityZoneId: 'UTC',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  UuidValue? id;
  ByteData source(String summary) => ByteData.sublistView(
    Uint8List.fromList(
      utf8.encode(
        [
          'BEGIN:VCALENDAR',
          'VERSION:2.0',
          'PRODID:Synthetic',
          'BEGIN:VTODO',
          'UID:replacement@example.invalid',
          'DTSTAMP:20260301T000000Z',
          'SUMMARY:$summary',
          'END:VTODO',
          'END:VCALENDAR',
          '',
        ].join('\r\n'),
      ),
    ),
  );
  try {
    id = (await a.importTasks(
      cal.CalendarTaskImportRequest(
        calendarId: parent,
        expectedRevision: 1,
        bytes: source('Before'),
      ),
    )).receipts.single.taskId;
    cal.CalendarTaskReplaceRequest replace(int revision) =>
        cal.CalendarTaskReplaceRequest(
          calendarId: parent,
          expectedRevision: 1,
          bytes: source('After'),
          selection: [
            cal.CalendarTaskExportSelection(
              taskId: id!,
              expectedRevision: revision,
            ),
          ],
        );
    final results = await Future.wait([
      a
          .replaceFromImport(replace(1))
          .then<Object>((v) => v)
          .catchError((Object e) => e),
      b
          .changeAssignments(
            cal.CalendarTaskAssignmentsRequest(
              taskId: id,
              expectedRevision: 1,
              assignees: [
                cal.CalendarTaskAssignee(
                  namespace: 'demo',
                  kind: 'user',
                  externalId: principal,
                ),
              ],
            ),
          )
          .then<Object>((v) => v!)
          .catchError((Object e) => e),
    ]);
    check(
      results.whereType<cal.CalendarException>().length == 1 &&
          results.whereType<cal.CalendarException>().single.code ==
              cal.CalendarFailureCode.staleRevision,
      'Cross-host task replacement/assignment race has one stale writer',
    );
    final current = await b.getTask(id, cal.CalendarTaskFieldGroup.values);
    if (current.summary == 'Before') {
      await a.replaceFromImport(replace(current.revision));
    } else {
      await b.changeAssignments(
        cal.CalendarTaskAssignmentsRequest(
          taskId: id,
          expectedRevision: current.revision,
          assignees: [
            cal.CalendarTaskAssignee(
              namespace: 'demo',
              kind: 'user',
              externalId: principal,
            ),
          ],
        ),
      );
    }
    final finalView = await b.getTask(id, cal.CalendarTaskFieldGroup.values);
    check(
      finalView.summary == 'After' &&
          finalView.assignees!.single.externalId == principal &&
          finalView.revision == 3,
      'Explicit retry preserves assignments and replacement source across hosts',
    );
    final noOp = await b.replaceFromImport(replace(3));
    check(
      !noOp.receipts.single.changed &&
          noOp.receipts.single.receipt.revision == 3,
      'Cross-host identical replacement remains a true no-op',
    );
  } finally {
    if (id != null) {
      final current = await a.getTask(id, []);
      await a.deleteTask(id, current.revision);
    }
    await calendar.delete(parent, 1);
  }
}

Future<void> taskImportSmoke(List<Client> clients) async {
  final ca = clients.first.modules.serverpod_calendar.calendar,
      cb = clients.last.modules.serverpod_calendar.calendar;
  final a = clients.first.modules.serverpod_calendar.calendarTask,
      b = clients.last.modules.serverpod_calendar.calendarTask;
  final parents = <UuidValue>[], ids = <UuidValue>[];
  Future<UuidValue> parent() async {
    final p = (await ca.create(
      cal.CalendarCreateRequest(
        displayName: 'Task import smoke',
        availabilityZoneId: 'UTC',
        noRuleFallback: cal.CalendarNoRuleFallback.free,
      ),
    ))!.calendarId;
    parents.add(p);
    return p;
  }

  cal.CalendarTaskImportRequest request(UuidValue p, String uid) =>
      cal.CalendarTaskImportRequest(
        calendarId: p,
        expectedRevision: 1,
        bytes: ByteData.sublistView(
          Uint8List.fromList(
            utf8.encode(
              [
                'BEGIN:VCALENDAR',
                'VERSION:2.0',
                'PRODID:Synthetic two-host task import',
                'BEGIN:VTODO',
                'UID:$uid',
                'DTSTAMP:20260301T000000Z',
                'DTSTART;VALUE=DATE:20260328',
                'RRULE:FREQ=DAILY;COUNT=3',
                'SUMMARY:Imported two-host task',
                'PERCENT-COMPLETE:37',
                'ORGANIZER:mailto:source@example.invalid',
                'ATTENDEE:mailto:guest@example.invalid',
                'BEGIN:VALARM',
                'ACTION:DISPLAY',
                'DESCRIPTION:Unarmed source alarm',
                'TRIGGER:-PT5M',
                'END:VALARM',
                'END:VTODO',
                'BEGIN:VTODO',
                'UID:$uid',
                'DTSTAMP:20260302T000000Z',
                'RECURRENCE-ID;VALUE=DATE:20260329',
                'PERCENT-COMPLETE:12',
                'END:VTODO',
                'END:VCALENDAR',
                '',
              ].join('\r\n'),
            ),
          ),
        ),
      );
  try {
    final p = await parent(), other = await parent();
    final first = (await a.importTasks(request(p, 'two-host-task')))
        .receipts
        .single;
    ids.add(first.taskId);
    final view = await b.getTask(
      first.taskId,
      cal.CalendarTaskFieldGroup.values,
    );
    check(
      view.progress!.status == null &&
          view.progress!.percentComplete == 37 &&
          view.assignees!.isEmpty &&
          view.protocolVersion!.sequence == null,
      'Imported task preserves source progress/versions and assigns nobody across hosts',
    );
    final preview = await b.previewOccurrences(
      cal.CalendarTaskOccurrenceQuery(
        taskId: first.taskId,
        expectedRevision: 1,
        fromDate: cal.CalendarEventCivil(year: 2026, month: 3, day: 27),
        untilDate: cal.CalendarEventCivil(year: 2026, month: 3, day: 31),
      ),
    );
    check(
      preview.occurrences[0].progress.percentComplete == 37 &&
          preview.occurrences[1].progress.percentComplete == 12 &&
          preview.occurrences[1].progress.status == null,
      'Imported raw sparse progress survives cross-host preview',
    );
    final history = await b.occurrenceHistory(
      cal.CalendarTaskHistoryQuery(
        taskId: first.taskId,
        expectedRevision: 1,
        originalStart: preview.occurrences[1].originalStart,
        pageSize: 10,
      ),
    );
    check(history.entries.isEmpty, 'Import invents no history');
    cal.CalendarTaskExportRequest exportRequest(int revision) =>
        cal.CalendarTaskExportRequest(
          calendarId: p,
          expectedRevision: 1,
          selection: [
            cal.CalendarTaskExportSelection(
              taskId: first.taskId,
              expectedRevision: revision,
            ),
          ],
        );
    final wire = await b.exportTasks(exportRequest(1));
    final wireText = utf8.decode(
      wire.buffer.asUint8List(wire.offsetInBytes, wire.lengthInBytes),
    );
    check(
      wireText.contains('BEGIN:VALARM') &&
          wireText.contains('PERCENT-COMPLETE:12') &&
          !wireText.contains('STATUS:') &&
          !wireText.contains(first.taskId.toString()),
      'Cross-host task export retains sparse progress and inert rich source metadata',
    );
    final exportCopy = (await a.importTasks(
      cal.CalendarTaskImportRequest(
        calendarId: other,
        expectedRevision: 1,
        bytes: wire,
      ),
    )).receipts.single;
    ids.add(exportCopy.taskId);
    final copied = await b.getTask(
      exportCopy.taskId,
      cal.CalendarTaskFieldGroup.values,
    );
    check(
      copied.progress!.percentComplete == 37 && copied.assignees!.isEmpty,
      'Exported task reimports without invented assignments or progress',
    );
    await a.deleteTask(exportCopy.taskId, 1);
    ids.remove(exportCopy.taskId);
    await b.changeAssignments(
      cal.CalendarTaskAssignmentsRequest(
        taskId: first.taskId,
        expectedRevision: 1,
        assignees: [],
      ),
    );
    await rejects(
      () => a.exportTasks(exportRequest(1)),
      cal.CalendarFailureCode.staleRevision,
    );
    final changed = await a.exportTasks(exportRequest(2));
    check(
      utf8
          .decode(
            changed.buffer.asUint8List(
              changed.offsetInBytes,
              changed.lengthInBytes,
            ),
          )
          .contains('PERCENT-COMPLETE:37'),
      'Task export checks the latest committed revision across independent hosts',
    );
    final original = preview.occurrences[1].originalStart;
    cal.CalendarTaskOccurrenceTimingRequest timingRequest(
      int revision, {
      bool clear = false,
    }) => cal.CalendarTaskOccurrenceTimingRequest(
      taskId: first.taskId,
      expectedRevision: revision,
      originalStart: original,
      replacement: clear
          ? null
          : cal.CalendarTaskTiming(
              kind: cal.CalendarTaskTimeKind.date,
              start: cal.CalendarEventCivil(year: 2026, month: 3, day: 31),
              duration: cal.CalendarEventDuration(days: 1),
            ),
    );
    cal.CalendarTaskOccurrenceProgressRequest progressRequest(int revision) =>
        cal.CalendarTaskOccurrenceProgressRequest(
          taskId: first.taskId,
          expectedRevision: revision,
          originalStart: original,
          action: cal.CalendarTaskProgressAction.complete,
        );
    Future<bool> compete(Future<dynamic> Function() f) async {
      try {
        await f();
        return true;
      } on cal.CalendarException catch (e) {
        if (e.code == cal.CalendarFailureCode.staleRevision) return false;
        rethrow;
      }
    }

    final winners = await Future.wait([
      compete(() => a.changeOccurrenceTiming(timingRequest(2))),
      compete(() => b.changeOccurrenceProgress(progressRequest(2))),
    ]);
    check(
      winners.where((v) => v).length == 1,
      'Exactly one competing timing/progress write wins across hosts',
    );
    if (winners.first) {
      await b.changeOccurrenceProgress(progressRequest(3));
    } else {
      await a.changeOccurrenceTiming(timingRequest(3));
    }
    final moved = (await b.previewOccurrences(
      cal.CalendarTaskOccurrenceQuery(
        taskId: first.taskId,
        expectedRevision: 4,
        fromDate: cal.CalendarEventCivil(year: 2026, month: 3, day: 31),
        untilDate: cal.CalendarEventCivil(year: 2026, month: 4, day: 1),
      ),
    )).occurrences.single;
    check(
      moved.originalStart == original &&
          moved.progress.percentComplete == 100 &&
          moved.replacementTiming != null,
      'Explicit retry preserves original timing and completed progress from both hosts',
    );
    final evidence = await a.occurrenceHistory(
      cal.CalendarTaskHistoryQuery(
        taskId: first.taskId,
        expectedRevision: 4,
        originalStart: original,
        pageSize: 10,
      ),
    );
    check(
      evidence.entries.length == 1,
      'Timing writes invent no progress history',
    );
    await a.changeOccurrenceTiming(timingRequest(4, clear: true));
    final retained = await b.occurrenceHistory(
      cal.CalendarTaskHistoryQuery(
        taskId: first.taskId,
        expectedRevision: 5,
        originalStart: original,
        pageSize: 10,
      ),
    );
    check(
      retained.entries.length == 1,
      'Clearing timing retains completion history across hosts',
    );

    final anchor = preview.occurrences.first.originalStart;
    cal.CalendarTaskOccurrenceTimingRequest futureRequest(
      int revision, {
      bool clear = false,
    }) => timingRequest(revision, clear: clear).copyWith(
      originalStart: anchor,
      thisAndFuture: true,
      replacement: clear
          ? null
          : cal.CalendarTaskTiming(
              kind: cal.CalendarTaskTimeKind.date,
              start: cal.CalendarEventCivil(year: 2026, month: 3, day: 29),
              duration: cal.CalendarEventDuration(days: 1),
            ),
    );
    final futureWinners = await Future.wait([
      compete(() => a.changeOccurrenceTiming(futureRequest(5))),
      compete(
        () => b.changeOccurrenceProgress(
          progressRequest(5).copyWith(originalStart: anchor),
        ),
      ),
    ]);
    check(
      futureWinners.where((v) => v).length == 1,
      'Exactly one competing future timing/progress write wins across hosts',
    );
    if (futureWinners.first) {
      await b.changeOccurrenceProgress(
        progressRequest(6).copyWith(originalStart: anchor),
      );
    } else {
      await a.changeOccurrenceTiming(futureRequest(6));
    }
    final ranged = (await b.previewOccurrences(
      cal.CalendarTaskOccurrenceQuery(
        taskId: first.taskId,
        expectedRevision: 7,
        fromDate: cal.CalendarEventCivil(year: 2026, month: 3, day: 28),
        untilDate: cal.CalendarEventCivil(year: 2026, month: 4, day: 1),
      ),
    )).occurrences;
    check(
      ranged.map((o) => o.actualStart!.start.day).join(',') == '29,30,31' &&
          ranged.map((o) => o.progress.percentComplete).join(',') ==
              '100,100,37',
      'Future timing propagates without propagating anchor progress across hosts',
    );
    final futureBytes = await a.exportTasks(
      cal.CalendarTaskExportRequest(
        calendarId: p,
        expectedRevision: 1,
        selection: [
          cal.CalendarTaskExportSelection(
            taskId: first.taskId,
            expectedRevision: 7,
          ),
        ],
      ),
    );
    final rangeCopy = (await b.importTasks(
      cal.CalendarTaskImportRequest(
        calendarId: other,
        expectedRevision: 1,
        bytes: futureBytes,
      ),
    )).receipts.single;
    ids.add(rangeCopy.taskId);
    final copiedRanges = (await b.previewOccurrences(
      cal.CalendarTaskOccurrenceQuery(
        taskId: rangeCopy.taskId,
        expectedRevision: 1,
        fromDate: cal.CalendarEventCivil(year: 2026, month: 3, day: 28),
        untilDate: cal.CalendarEventCivil(year: 2026, month: 4, day: 1),
      ),
    )).occurrences;
    check(
      copiedRanges.first.futureTiming != null &&
          copiedRanges.last.progress.percentComplete == 37,
      'Active RANGE source round trips across independent hosts',
    );
    await b.deleteTask(rangeCopy.taskId, 1);
    ids.remove(rangeCopy.taskId);
    await a.changeOccurrenceTiming(futureRequest(7, clear: true));
    final anchorHistory = await b.occurrenceHistory(
      cal.CalendarTaskHistoryQuery(
        taskId: first.taskId,
        expectedRevision: 8,
        originalStart: anchor,
        pageSize: 10,
      ),
    );
    check(
      anchorHistory.entries.length == 1,
      'Setting and clearing future timing invents no progress history across hosts',
    );

    cal.CalendarTaskOccurrenceContentRequest contentRequest(
      int revision, {
      bool inherit = false,
    }) => cal.CalendarTaskOccurrenceContentRequest(
      taskId: first.taskId,
      expectedRevision: revision,
      originalStart: anchor,
      changes: [
        cal.CalendarTaskOccurrenceContentChange(
          field: cal.CalendarTaskContentField.summary,
          action: inherit
              ? cal.CalendarTaskContentAction.inheritSeries
              : cal.CalendarTaskContentAction.setValue,
          text: inherit ? null : 'Own content',
        ),
      ],
    );
    cal.CalendarTaskOccurrenceProgressRequest reopenRequest(int revision) =>
        progressRequest(revision).copyWith(
          originalStart: anchor,
          action: cal.CalendarTaskProgressAction.reopen,
        );
    final contentWinners = await Future.wait([
      compete(() => a.changeOccurrenceContent(contentRequest(8))),
      compete(() => b.changeOccurrenceProgress(reopenRequest(8))),
    ]);
    check(
      contentWinners.where((v) => v).length == 1,
      'Exactly one competing content/progress write wins across hosts',
    );
    if (contentWinners.first) {
      await b.changeOccurrenceProgress(reopenRequest(9));
    } else {
      await a.changeOccurrenceContent(contentRequest(9));
    }
    cal.CalendarTaskOccurrenceQuery contentQuery(UuidValue id, int revision) =>
        cal.CalendarTaskOccurrenceQuery(
          taskId: id,
          expectedRevision: revision,
          fromDate: cal.CalendarEventCivil(year: 2026, month: 3, day: 27),
          untilDate: cal.CalendarEventCivil(year: 2026, month: 4, day: 1),
          fieldGroups: [cal.CalendarTaskFieldGroup.summary],
        );
    final contentValues = (await b.previewOccurrences(
      contentQuery(first.taskId, 10),
    )).occurrences;
    check(
      contentValues.first.content!.summary == 'Own content' &&
          contentValues.first.progress.percentComplete == 0 &&
          contentValues.last.contentOverrides == null,
      'Content retry preserves independent progress and per-field inheritance across hosts',
    );
    final beforeContentNoop = await a.exportTasks(exportRequest(10));
    await a.changeOccurrenceContent(contentRequest(10));
    final afterContentNoop = await b.exportTasks(exportRequest(11));
    check(
      base64Encode(
            beforeContentNoop.buffer.asUint8List(
              beforeContentNoop.offsetInBytes,
              beforeContentNoop.lengthInBytes,
            ),
          ) ==
          base64Encode(
            afterContentNoop.buffer.asUint8List(
              afterContentNoop.offsetInBytes,
              afterContentNoop.lengthInBytes,
            ),
          ),
      'Identical content save leaves exported protocol state stable across hosts',
    );
    final contentCopy = (await b.importTasks(
      cal.CalendarTaskImportRequest(
        calendarId: other,
        expectedRevision: 1,
        bytes: afterContentNoop,
      ),
    )).receipts.single;
    ids.add(contentCopy.taskId);
    final copiedContent = (await b.previewOccurrences(
      contentQuery(contentCopy.taskId, 1),
    )).occurrences;
    check(
      copiedContent.first.contentOverrides!.summary == 'Own content' &&
          copiedContent.last.contentOverrides == null,
      'Selected content overrides round trip across hosts without becoming series defaults',
    );
    await b.deleteTask(contentCopy.taskId, 1);
    ids.remove(contentCopy.taskId);
    await a.changeOccurrenceContent(contentRequest(11, inherit: true));
    final contentHistory = await b.occurrenceHistory(
      cal.CalendarTaskHistoryQuery(
        taskId: first.taskId,
        expectedRevision: 12,
        originalStart: anchor,
        pageSize: 10,
      ),
    );
    check(
      contentHistory.entries.length == 2,
      'Content set/no-op/inherit adds no completion history across hosts',
    );

    await rejects(
      () => b.importTasks(request(p, 'two-host-task')),
      cal.CalendarFailureCode.dependencyConflict,
    );
    final copy = (await b.importTasks(request(other, 'two-host-task')))
        .receipts
        .single;
    ids.add(copy.taskId);
    check(
      copy.taskId != first.taskId,
      'Independent destination copy gets a new native UUID',
    );
    final race = await Future.wait(
      [a, b].map((api) async {
        try {
          final result = await api.importTasks(request(p, 'race-task'));
          ids.add(result.receipts.single.taskId);
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.dependencyConflict) {
            return false;
          }
          rethrow;
        }
      }),
    );
    check(
      race.where((v) => v).length == 1,
      'Exactly one competing task UID import wins across hosts',
    );
    final raceParent = await parent();
    final parentRace = await Future.wait([
      () async {
        try {
          final r = await a.importTasks(request(raceParent, 'parent-race'));
          ids.add(r.receipts.single.taskId);
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.accessDenied) return false;
          rethrow;
        }
      }(),
      () async {
        try {
          await cb.delete(raceParent, 1);
          parents.remove(raceParent);
          return true;
        } on cal.CalendarException catch (e) {
          if (e.code == cal.CalendarFailureCode.dependencyConflict) {
            return false;
          }
          rethrow;
        }
      }(),
    ]);
    check(
      parentRace.where((v) => v).length == 1,
      'Task import and parent deletion serialize across hosts',
    );
    print(
      'PASS: create-only task import source progress, no assignments/history, independent copies and cross-host UID/parent races.',
    );
  } finally {
    for (final id in ids) {
      final current = await b.getTask(id, cal.CalendarTaskFieldGroup.values);
      await b.deleteTask(id, current.revision);
    }
    for (final id in parents) {
      await ca.delete(id, 1);
    }
  }
}

final class _Storage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async {
    value = data;
  }
}

Future<void> personalAlarmSmoke(List<Client> clients) async {
  final a = clients.first.modules.serverpod_calendar;
  final b = clients.last.modules.serverpod_calendar;
  final calendar = (await a.calendar.create(
    cal.CalendarCreateRequest(
      displayName: 'Private alarm two-host fixture',
      availabilityZoneId: 'Europe/Stockholm',
      noRuleFallback: cal.CalendarNoRuleFallback.free,
    ),
  ))!.calendarId;
  final event = (await a.calendarEvent.create(
    cal.CalendarEventCreateRequest(
      calendarId: calendar,
      content: cal.CalendarEventContent(
        timing: cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: cal.CalendarEventCivil(year: 2026, month: 3, day: 29),
        ),
      ),
    ),
  ))!;
  final parent = cal.CalendarAlarmParent(
    kind: cal.CalendarAlarmParentKind.event,
    id: event.eventId,
  );
  cal.CalendarAlarmDefinition definition(int minute) =>
      cal.CalendarAlarmDefinition(
        absoluteUtc: DateTime.utc(2026, 3, 29, 12, minute),
      );
  for (var i = 0; i < 15; i++) {
    await a.calendarAlarm.create(
      cal.CalendarAlarmCreateRequest(parent: parent, definition: definition(i)),
    );
  }
  Future<Object> create(dynamic api) async {
    try {
      return await api.create(
        cal.CalendarAlarmCreateRequest(
          parent: parent,
          definition: definition(16),
        ),
      ) as Object;
    } on cal.CalendarException catch (e) {
      return e;
    }
  }

  final results = await Future.wait([
    create(a.calendarAlarm),
    create(b.calendarAlarm),
  ]);
  check(
    results.whereType<cal.CalendarAlarmView>().length == 1 &&
        results.whereType<cal.CalendarException>().single.code ==
            cal.CalendarFailureCode.limitExceeded,
    'Cross-host personal alarm cap race failed',
  );
  final rows = await b.calendarAlarm.list(parent);
  check(rows.length == 16, 'Cross-host private alarm persistence failed');
  Future<Object> update(dynamic api) async {
    try {
      return await api.update(
        cal.CalendarAlarmUpdateRequest(
          parent: parent,
          alarmId: rows.first.id,
          expectedRevision: 1,
          definition: definition(30),
        ),
      ) as Object;
    } on cal.CalendarException catch (e) {
      return e;
    }
  }

  final writes = await Future.wait([
    update(a.calendarAlarm),
    update(b.calendarAlarm),
  ]);
  check(
    writes.whereType<cal.CalendarAlarmView>().length == 1 &&
        writes.whereType<cal.CalendarException>().single.code ==
            cal.CalendarFailureCode.staleRevision,
    'Cross-host personal alarm revision race failed',
  );
  check(
    (await b.calendarEvent.getEvent(
          event.eventId,
          cal.CalendarEventFieldGroup.values,
        )).revision ==
        1,
    'Private alarm writes changed shared event revision',
  );
  final beforeArm = (await b.calendarAlarm.list(parent))
      .firstWhere((r) => r.id == rows.first.id);
  final armed = (await a.calendarAlarm.setArmed(
    parent,
    beforeArm.id,
    beforeArm.revision,
    true,
  ))!;
  check(armed.armed, 'Explicit arming failed across hosts');
  cal.CalendarAlarmView? planned;
  final deadline = DateTime.now().add(const Duration(seconds: 45));
  while (DateTime.now().isBefore(deadline)) {
    planned = (await b.calendarAlarm.list(parent))
        .firstWhere((r) => r.id == armed.id);
    if (planned.planningStatus == cal.CalendarAlarmPlanStatus.ready) break;
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  check(
    planned?.planningStatus == cal.CalendarAlarmPlanStatus.ready &&
        planned?.planningWindowEnd != null,
    'Independent host maintenance did not complete the rolling alarm plan',
  );
  check(
    planned!.revision == armed.revision,
    'Background planning changed the private API revision',
  );
  final disarmed = (await b.calendarAlarm.setArmed(
    parent,
    armed.id,
    armed.revision,
    false,
  ))!;
  check(
    !disarmed.armed &&
        !(await a.calendarAlarm.list(parent))
            .firstWhere((r) => r.id == armed.id)
            .armed,
    'Cross-host disarming failed',
  );
  await b.calendarEvent.deleteEvent(event.eventId, 1);
  await rejects(
    () => a.calendarAlarm.list(parent),
    cal.CalendarFailureCode.accessDenied,
  );
  final task = (await a.calendarTask.create(
    cal.CalendarTaskCreateRequest(
      calendarId: calendar,
      content: cal.CalendarTaskContent(
        timing: cal.CalendarTaskTiming(kind: cal.CalendarTaskTimeKind.undated),
      ),
      assignees: [],
    ),
  ))!;
  final taskParent = cal.CalendarAlarmParent(
    kind: cal.CalendarAlarmParentKind.task,
    id: task.taskId,
  );
  await a.calendarAlarm.create(
    cal.CalendarAlarmCreateRequest(
      parent: taskParent,
      definition: definition(1),
    ),
  );
  check(
    (await b.calendarAlarm.list(taskParent)).length == 1,
    'Undated task absolute alarm missing across hosts',
  );
  await b.calendarTask.deleteTask(task.taskId, 1);
  await rejects(
    () => a.calendarAlarm.list(taskParent),
    cal.CalendarFailureCode.accessDenied,
  );
  await a.calendar.delete(calendar, 1);
  print(
    'PASS: private personal alarm definitions across two hosts, competing cap/revision writes, unchanged item versions, explicit arming/rolling planning/disarming and parent deletion. Notification delivery remains unconnected.',
  );
}
