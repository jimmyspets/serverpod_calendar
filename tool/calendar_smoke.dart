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
      await eb.deleteEvent(id, 1);
    }
    for (final id in parents) {
      await b.delete(id, 1);
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
