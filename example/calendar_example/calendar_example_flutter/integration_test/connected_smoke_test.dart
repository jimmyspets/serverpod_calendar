import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:calendar_example_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('real host sign-in, generated module calls and sign-out', (
    tester,
  ) async {
    final label = 'Flutter ${DateTime.now().microsecondsSinceEpoch}';
    final renamedLabel = '$label renamed';
    const password = String.fromEnvironment('DEMO_PASSWORD');
    expect(
      password,
      isNotEmpty,
      reason: 'Pass --dart-define-from-file=.local/test_defines.json',
    );
    final client = Client(
      const String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost:18180/',
      ),
    )..authSessionManager = FlutterAuthSessionManager();
    addTearDown(client.close);
    await tester.pumpWidget(CalendarExampleApp(client: client));
    await tester.enterText(
      find.byKey(const Key('email')),
      const String.fromEnvironment('DEMO_EMAIL'),
    );
    await tester.enterText(find.byKey(const Key('password')), password);
    await tester.tap(find.byKey(const Key('sign-in')));
    await _waitFor(tester, find.byKey(const Key('check')));
    await tester.tap(find.byKey(const Key('check')));
    await _waitFor(tester, find.byKey(const Key('result')));
    expect(
      find.textContaining('Connected: host, calendar and notifications'),
      findsOneWidget,
    );
    await _tap(tester, 'open-calendars');
    await _tap(tester, 'calendar-create');
    await tester.enterText(
      find.byKey(const Key('calendar-name')),
      label,
    );
    await tester.enterText(
      find.byKey(const Key('calendar-description')),
      '  Native notes\n',
    );
    await tester.enterText(find.byKey(const Key('calendar-color')), '#a0b1c2');
    await _tap(tester, 'calendar-submit-create');
    await _waitFor(tester, find.text(label));
    await tester.tap(find.text(label));
    await _idle(tester);
    final initialProtocolLabel = tester
        .widget<SelectableText>(
          find.byKey(const Key('calendar-protocol-uid')),
        )
        .data!;
    expect(find.byKey(const Key('calendar-protocol-modified')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('calendar-name')),
      renamedLabel,
    );
    await _tap(tester, 'calendar-save-name');
    await tester.enterText(find.byKey(const Key('calendar-zone')), 'UTC');
    await _tap(tester, 'calendar-save-settings');
    expect(find.text('UTC'), findsOneWidget);
    expect(find.text('#A0B1C2'), findsOneWidget);
    await _tap(tester, 'protocol-name-add');
    await tester.enterText(
      find.byKey(const Key('protocol-name-language-0')),
      'sv',
    );
    await tester.enterText(
      find.byKey(const Key('protocol-name-value-0')),
      'Protocol Swedish',
    );
    await _tap(tester, 'protocol-copy-name');
    await _tap(tester, 'protocol-copy-description');
    await tester.enterText(find.byKey(const Key('protocol-color')), 'red');
    await _tap(tester, 'protocol-save');
    final saved = await client.modules.serverpod_calendar.calendar.list(
      pageSize: 25,
      fieldGroups: cal.CalendarFieldGroup.values,
    );
    final calendar = saved.calendars.singleWhere(
      (v) => v.displayName == renamedLabel,
    );
    expect(
      'Protocol UID: ${calendar.protocolIdentity!.uid}',
      initialProtocolLabel,
    );
    expect(calendar.protocolIdentity!.uid, isNot(calendar.id.toString()));
    expect(calendar.protocolIdentity!.lastModified.isUtc, isTrue);
    expect(calendar.protocolIdentity!.lastModified.millisecond, 0);
    expect(calendar.protocolIdentity!.lastModified.microsecond, 0);
    expect(calendar.protocolMetadata!.names.length, 2);
    expect(calendar.protocolMetadata!.names.first.value, renamedLabel);
    expect(calendar.protocolMetadata!.names.last.value, 'Protocol Swedish');
    expect(calendar.protocolMetadata!.names.last.language, 'sv');
    expect(
      calendar.protocolMetadata!.descriptions.single.value,
      '  Native notes\n',
    );
    expect(calendar.protocolMetadata!.color, 'red');
    expect(calendar.color, '#A0B1C2');
    // Another native edit must retain saved protocol text and color.
    await tester.enterText(
      find.byKey(const Key('calendar-description')),
      'Changed native description',
    );
    await _tap(tester, 'calendar-save-name');
    final retained = await client.modules.serverpod_calendar.calendar
        .getCalendar(calendar.id, cal.CalendarFieldGroup.values);
    expect(retained.description, 'Changed native description');
    expect(
      retained.protocolMetadata!.descriptions.single.value,
      '  Native notes\n',
    );
    await client.modules.serverpod_calendar.calendar.updateProtocolMetadata(
      cal.CalendarProtocolMetadataUpdateRequest(
        calendarId: calendar.id,
        expectedRevision: retained.revision,
        metadata: cal.CalendarProtocolMetadata(
          names: retained.protocolMetadata!.names,
          descriptions: [cal.CalendarTextVariant(value: 'External change')],
          color: 'blue',
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('calendar-description')),
      'Stale draft',
    );
    await _tap(tester, 'calendar-save-name');
    expect(find.byKey(const Key('calendar-error')), findsOneWidget);
    final afterConflict = await client.modules.serverpod_calendar.calendar
        .getCalendar(calendar.id, cal.CalendarFieldGroup.values);
    expect(afterConflict.description, 'Changed native description');
    expect(
      afterConflict.protocolMetadata!.descriptions.single.value,
      'External change',
    );
    await _tap(tester, 'calendar-reload');
    expect(find.text('External change'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('metadata-url')),
      'https://example.invalid/calendar',
    );
    await _tap(tester, 'metadata-category-add');
    await tester.enterText(
      find.byKey(const Key('metadata-category-value-0')),
      'Work',
    );
    await tester.enterText(
      find.byKey(const Key('metadata-category-language-0')),
      'sv',
    );
    await _tap(tester, 'metadata-image-add');
    await tester.enterText(
      find.byKey(const Key('metadata-image-uri-0')),
      'https://example.invalid/image.png',
    );
    await tester.enterText(
      find.byKey(const Key('metadata-image-display-0')),
      'BADGE,X-PRIVATE',
    );
    await tester.enterText(
      find.byKey(const Key('metadata-image-type-0')),
      'image/png',
    );
    await _tap(tester, 'metadata-refresh-enabled');
    await tester.enterText(
      find.byKey(const Key('metadata-refresh-hours')),
      '24',
    );
    await _tap(tester, 'metadata-save');
    final links = await client.modules.serverpod_calendar.calendar.getCalendar(
      calendar.id,
      cal.CalendarFieldGroup.values,
    );
    expect(links.supplementalMetadata!.url, 'https://example.invalid/calendar');
    expect(links.supplementalMetadata!.refreshHint!.days, 0);
    expect(links.supplementalMetadata!.refreshHint!.hours, 24);
    expect(links.supplementalMetadata!.images.single.display, [
      'BADGE',
      'X-PRIVATE',
    ]);
    expect(
      links.protocolMetadata!.descriptions.single.value,
      'External change',
    );
    await tester.pageBack();
    await _idle(tester);
    await tester.enterText(
      find.byKey(const Key('calendar-category-search')),
      'Work',
    );
    await tester.enterText(
      find.byKey(const Key('calendar-category-language')),
      'SV',
    );
    await _tap(tester, 'calendar-category-apply');
    expect(find.text(renamedLabel), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('calendar-category-search')),
      'work',
    );
    await _tap(tester, 'calendar-category-apply');
    expect(find.text(renamedLabel), findsNothing);
    await tester.enterText(
      find.byKey(const Key('calendar-category-search')),
      '',
    );
    await tester.enterText(
      find.byKey(const Key('calendar-category-language')),
      '',
    );
    await _tap(tester, 'calendar-category-apply');
    // Unfiltered results may span pages or lie outside the visible list.
    // Reopen through the already-verified exact filter instead of assuming
    // this UUID sorts into the first unfiltered page.
    await tester.enterText(
      find.byKey(const Key('calendar-category-search')),
      'Work',
    );
    await tester.enterText(
      find.byKey(const Key('calendar-category-language')),
      'SV',
    );
    await _tap(tester, 'calendar-category-apply');
    await tester.ensureVisible(find.text(renamedLabel));
    await tester.tap(find.text(renamedLabel));
    await _idle(tester);
    await _tap(tester, 'calendar-events');
    await _tap(tester, 'event-create');
    await _tap(tester, 'event-end-form-omitted');
    await tester.tap(find.text('duration').last);
    await _idle(tester);
    await tester.enterText(
      find.byKey(const Key('event-duration-2')),
      'invalid',
    );
    await _tap(tester, 'event-end-form-duration');
    await tester.tap(find.text('omitted').last);
    await _idle(tester);
    await _tap(tester, 'event-save');
    await _waitFor(tester, find.text('Untitled event'));
    final events = client.modules.serverpod_calendar.calendarEvent;
    final event = (await events.list(
      calendar.id,
      pageSize: 10,
      fieldGroups: cal.CalendarEventFieldGroup.values,
    )).events.single;
    expect(event.summary, isNull);
    await tester.tap(find.text('Untitled event'));
    await _idle(tester);
    await tester.enterText(
      find.byKey(const Key('event-summary')),
      'Local draft',
    );
    await events.update(
      cal.CalendarEventUpdateRequest(
        eventId: event.id,
        expectedRevision: 1,
        replaceTextParameters: true,
        content: cal.CalendarEventContent(
          summary: 'External event',
          textParameters: cal.CalendarEventTextParameters(
            summary: cal.CalendarTextParameters(
              language: 'sv',
              alternativeUri: 'cid:synthetic@example.invalid',
            ),
          ),
          timing: event.timing!,
        ),
      ),
    );
    await _tap(tester, 'event-save');
    expect(find.byKey(const Key('event-error')), findsOneWidget);
    expect(
      (await events.getEvent(
        event.id,
        cal.CalendarEventFieldGroup.values,
      )).summary,
      'External event',
    );
    await _tap(tester, 'event-reload');
    final summaryField = find.byKey(const Key('event-summary'));
    await _enabledField(tester, summaryField);
    expect(
      tester.widget<TextField>(summaryField).controller!.text,
      'External event',
    );
    final eventLabel = '$renamedLabel event';
    await tester.ensureVisible(summaryField);
    await tester.tap(summaryField);
    await _idle(tester);
    await tester.enterText(summaryField, eventLabel);
    await tester.pump();
    expect(tester.widget<TextField>(summaryField).controller!.text, eventLabel);
    await _tap(tester, 'event-save');
    await _enabledField(tester, summaryField);
    expect(
      (await events.getEvent(
        event.id,
        cal.CalendarEventFieldGroup.values,
      )).summary,
      eventLabel,
    );
    final annotated = await events.getEvent(
      event.id,
      cal.CalendarEventFieldGroup.values,
    );
    expect(annotated.textParameters!.summary!.language, 'sv');
    expect(annotated.protocolVersion!.sequence, 2);
    expect(find.textContaining('annotations are retained'), findsOneWidget);
    await _tap(tester, 'event-clear-parameters');
    await _tap(tester, 'event-save');
    await _enabledField(tester, summaryField);
    expect(
      (await events.getEvent(
        event.id,
        cal.CalendarEventFieldGroup.values,
      )).textParameters?.summary,
      isNull,
    );
    // Persist recurrence through Flutter and preview through the real endpoint.
    await tester.enterText(find.byKey(const Key('event-start')), '2026-03-29');
    await _tap(tester, 'event-frequency-none');
    await tester.tap(find.text('daily').last);
    await _idle(tester);
    await tester.ensureVisible(find.byKey(const Key('event-rule-count')));
    await tester.enterText(find.byKey(const Key('event-rule-count')), '3');
    await tester.ensureVisible(find.byKey(const Key('event-inclusions')));
    await tester.enterText(
      find.byKey(const Key('event-inclusions')),
      '2026-03-27',
    );
    await tester.ensureVisible(find.byKey(const Key('event-exclusions')));
    await tester.enterText(
      find.byKey(const Key('event-exclusions')),
      '2026-03-30',
    );
    await _tap(tester, 'event-save');
    await _tap(tester, 'event-preview');
    await tester.enterText(find.byKey(const Key('preview-from')), '2026-03-01');
    await tester.enterText(
      find.byKey(const Key('preview-until')),
      '2026-04-01',
    );
    await _tap(tester, 'preview-load');
    await _waitFor(tester, find.text('3 occurrences'));
    expect(find.text('2026-03-27'), findsOneWidget);
    expect(find.text('2026-03-29'), findsOneWidget);
    expect(find.text('2026-03-31'), findsOneWidget);
    final untilField = find.byKey(const Key('preview-until'));
    await _enabledField(tester, untilField);
    await tester.tap(untilField);
    await _idle(tester);
    await tester.enterText(untilField, '2026-04-05');
    expect(tester.widget<TextField>(untilField).controller!.text, '2026-04-05');
    await _tap(tester, 'preview-load');
    await _tap(tester, 'occurrence-edit-2026-03-29T00:00:00');
    await tester.enterText(
      find.byKey(const Key('occurrence-start')),
      '2026-03-28',
    );
    final savedForRace = await events.getEvent(
      event.id,
      cal.CalendarEventFieldGroup.values,
    );
    await events.update(
      cal.CalendarEventUpdateRequest(
        eventId: event.id,
        expectedRevision: savedForRace.revision,
        content: cal.CalendarEventContent(
          summary: savedForRace.summary,
          timing: savedForRace.timing!,
          recurrence: savedForRace.recurrence,
        ),
      ),
    );
    await _tap(tester, 'occurrence-save');
    expect(find.byKey(const Key('occurrence-edit-error')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('occurrence-start')))
          .controller!
          .text,
      '2026-03-28',
    );
    expect(
      (await events.getEvent(
        event.id,
        cal.CalendarEventFieldGroup.values,
      )).timingOverrides,
      isNull,
    );
    await tester.pageBack();
    await _idle(tester);
    await _tap(tester, 'preview-reload-series');
    await _tap(tester, 'occurrence-edit-2026-03-29T00:00:00');
    await tester.enterText(
      find.byKey(const Key('occurrence-start')),
      '2026-03-28',
    );
    await _tap(tester, 'occurrence-save');
    await _waitFor(tester, find.text('2026-03-28'));
    await _tap(tester, 'occurrence-future-2026-03-31T00:00:00');
    await tester.enterText(
      find.byKey(const Key('occurrence-start')),
      '2026-04-02',
    );
    await _tap(tester, 'occurrence-save');
    await _showOccurrence(tester, find.text('2026-04-02'));
    expect(find.text('2026-04-02'), findsOneWidget);
    await _tap(tester, 'occurrence-cancel-2026-03-29T00:00:00');
    await _showOccurrence(tester, find.text('2 occurrences'));
    expect(find.text('2 occurrences'), findsOneWidget);
    await _tap(tester, 'occurrence-restore-2026-03-29T00:00:00');
    await _showOccurrence(tester, find.text('3 occurrences'));
    expect(find.text('2026-03-28'), findsOneWidget);
    await _tap(tester, 'occurrence-clear-future-2026-03-31T00:00:00');
    await _tap(tester, 'occurrence-clear-single-2026-03-29T00:00:00');
    expect(
      (await events.getEvent(
        event.id,
        cal.CalendarEventFieldGroup.values,
      )).timingOverrides,
      isNull,
    );
    expect(find.text('2026-03-29'), findsOneWidget);
    expect(find.text('2026-03-31'), findsOneWidget);
    await tester.pageBack();
    await _idle(tester);
    await _tap(tester, 'event-status-cancelled');
    expect(find.text('Status: cancelled'), findsOneWidget);
    await tester.pageBack();
    await _idle(tester);
    await tester.pageBack();
    await _idle(tester);
    final busyExample = (await events.create(
      cal.CalendarEventCreateRequest(
        calendarId: calendar.id,
        content: cal.CalendarEventContent(
          summary: 'Never show private busy title',
          status: cal.CalendarEventStatus.tentative,
          timing: cal.CalendarEventTiming(
            kind: cal.CalendarEventTimeKind.utc,
            start: cal.CalendarEventCivil(
              year: 2026,
              month: 3,
              day: 29,
              hour: 9,
            ),
            duration: cal.CalendarEventDuration(hours: 1),
          ),
        ),
      ),
    ))!;
    await _tap(tester, 'calendar-free-busy');
    await tester.enterText(
      find.byKey(const Key('busy-from')),
      '2026-03-29T00:00:00Z',
    );
    await tester.enterText(
      find.byKey(const Key('busy-until')),
      '2026-03-30T00:00:00Z',
    );
    await _tap(tester, 'busy-load');
    await _waitFor(tester, find.byKey(const Key('busy-complete')));
    expect(find.text('tentative'), findsOneWidget);
    expect(find.text('Never show private busy title'), findsNothing);
    await _tap(tester, 'busy-export');
    await _waitFor(tester, find.byKey(const Key('busy-export-source')));
    final freeBusyFile = tester
        .widget<SelectableText>(find.byKey(const Key('busy-export-source')))
        .data!;
    expect(freeBusyFile, contains('BEGIN:VFREEBUSY\r\n'));
    expect(freeBusyFile, contains('FREEBUSY;FBTYPE=BUSY-TENTATIVE:'));
    expect(freeBusyFile, isNot(contains('Never show private busy title')));
    expect(freeBusyFile, isNot(contains(busyExample.eventId.toString())));
    expect(freeBusyFile, isNot(contains(calendar.id.toString())));

    await tester.pageBack();
    await _idle(tester);
    await events.deleteEvent(busyExample.eventId, 1);
    await _tap(tester, 'calendar-availability');
    await _tap(tester, 'availability-create');
    await tester.enterText(
      find.byKey(const Key('availability-summary')),
      'Example working hours',
    );
    await tester.enterText(
      find.byKey(const Key('availability-zone')),
      'Europe/Stockholm',
    );
    await tester.enterText(
      find.byKey(const Key('availability-start')),
      '2026-03-30T09:00:00',
    );
    await tester.enterText(
      find.byKey(const Key('availability-end')),
      '2026-03-30T17:00:00',
    );
    await tester.enterText(
      find.byKey(const Key('availability-from')),
      '2026-03-30T00:00:00',
    );
    await _tap(tester, 'availability-duration-envelope');
    await tester.enterText(
      find.byKey(const Key('availability-duration-1')),
      '7',
    );
    await _tap(tester, 'availability-save');
    await _waitFor(tester, find.text('Example working hours'));
    final rulesApi = client.modules.serverpod_calendar.calendarAvailability;
    var rules = await rulesApi.list(calendar.id);
    expect(rules, hasLength(1));
    expect(rules.single.content.validDuration!.days, 7);
    expect(rules.single.content.validUntil, isNull);
    expect(rules.single.protocolState.sequence, 0);
    final protocolCreated = rules.single.protocolState.created;

    final hoursQuery = await client.modules.serverpod_calendar.calendar
        .freeBusy(
          cal.CalendarFreeBusyQuery(
            calendarId: calendar.id,
            fromUtc: DateTime.utc(2026, 3, 30),
            untilUtc: DateTime.utc(2026, 3, 31),
          ),
        );
    expect(hoursQuery.coverage, cal.CalendarFreeBusyCoverage.complete);
    expect(hoursQuery.periods[1].kind, cal.CalendarFreeBusyKind.free);
    expect(hoursQuery.periods[1].startUtc, DateTime.utc(2026, 3, 30, 7));
    await _tap(tester, 'availability-metadata-${rules.single.id}');
    await tester.enterText(
      find.byKey(const Key('availability-meta-description')),
      'Opening notes',
    );
    await tester.enterText(
      find.byKey(const Key('availability-meta-categories')),
      'Work',
    );
    await _tap(tester, 'availability-comment-add');
    await tester.enterText(
      find.byKey(const Key('availability-comment-0')),
      'Synthetic comment',
    );
    await _tap(tester, 'availability-text-parameters');
    await tester.enterText(
      find.byKey(const Key('availability-description-language')),
      'SV',
    );
    await tester.enterText(
      find.byKey(const Key('availability-description-altrep')),
      'cid:notes@example.invalid',
    );
    await tester.ensureVisible(find.text('Organizer publication label'));
    await tester.tap(find.text('Organizer publication label'));
    await tester.pumpAndSettle();
    await _tap(tester, 'availability-organizer-self');
    await _idle(tester);
    await tester.enterText(
      find.byKey(const Key('availability-organizer-name')),
      'Demo organizer',
    );
    await tester.ensureVisible(find.text('Private host extensions'));
    await tester.tap(find.text('Private host extensions'));
    await tester.pumpAndSettle();
    await _tap(tester, 'availability-extension-add');
    await tester.enterText(
      find.byKey(const Key('availability-extension-0-value')),
      'Demo label',
    );
    await _tap(tester, 'availability-metadata-save');
    await _waitFor(tester, find.text('Example working hours'));
    final openingUid = rules.single.content.openings.single.uid!;
    await _tap(tester, 'opening-preview-$openingUid');
    await _enabledField(tester, find.byKey(const Key('opening-from')));
    await tester.enterText(
      find.byKey(const Key('opening-from')),
      '2026-03-30T00:00:00Z',
    );
    await tester.enterText(
      find.byKey(const Key('opening-until')),
      '2026-03-31T00:00:00Z',
    );
    await _tap(tester, 'opening-load');
    await _waitFor(tester, find.byKey(const Key('opening-preview-complete')));
    await _tap(tester, 'opening-single-2026-03-30T09:00:00');
    await tester.enterText(
      find.byKey(const Key('occurrence-start')),
      '2026-03-30T10:00:00',
    );
    await tester.enterText(
      find.byKey(const Key('occurrence-end')),
      '2026-03-30T18:00:00',
    );
    await _tap(tester, 'occurrence-save');
    await _tap(tester, 'opening-load');
    await _waitFor(tester, find.byKey(const Key('opening-preview-complete')));
    await _tap(tester, 'opening-skip-2026-03-30T09:00:00');
    await _tap(tester, 'opening-restore-2026-03-30T09:00:00');
    await _tap(tester, 'opening-clear-single-2026-03-30T09:00:00');
    await tester.pageBack();
    await _idle(tester);
    rules = await rulesApi.list(calendar.id);
    expect(rules.single.content.description, 'Opening notes');
    expect(rules.single.content.textParameters!.description!.language, 'SV');
    expect(
      rules.single.content.textParameters!.description!.alternativeUri,
      'cid:notes@example.invalid',
    );
    expect(rules.single.content.organizer!.commonName, 'Demo organizer');
    expect(rules.single.content.extensions!.single.value, 'Demo label');
    expect(rules.single.protocolState.sequence, 5);
    expect(rules.single.protocolState.created, protocolCreated);
    expect(rules.single.content.validDuration!.days, 7);

    expect(rules.single.content.categories, ['Work']);
    expect(rules.single.timingOverrides, isNull);
    await _tap(tester, 'availability-edit-${rules.single.id}');
    await tester.enterText(
      find.byKey(const Key('availability-summary')),
      'Unsaved hours draft',
    );
    await rulesApi.update(
      cal.CalendarAvailabilityUpdateRequest(
        availabilityId: rules.single.id,
        expectedRevision: rules.single.revision,
        content: rules.single.content.copyWith(summary: 'Changed elsewhere'),
      ),
    );
    await _tap(tester, 'availability-save');
    await _waitFor(tester, find.byKey(const Key('availability-editor-error')));
    expect(find.text('Unsaved hours draft'), findsOneWidget);
    expect(
      (tester.widget<ElevatedButton>(
        find.byKey(const Key('availability-save')),
      )).onPressed,
      isNull,
    );
    await tester.pageBack();
    await _waitFor(tester, find.text('Changed elsewhere'));
    await _tap(tester, 'availability-delete-${rules.single.id}');
    await _idle(tester);
    expect(await rulesApi.list(calendar.id), isEmpty);

    await _tap(tester, 'availability-import');
    await _tap(tester, 'availability-import-example');
    await _tap(tester, 'availability-import-submit');
    await _waitFor(tester, find.text('Imported example hours'));
    final importedHours = (await rulesApi.list(calendar.id)).single;
    expect(importedHours.protocolUid, 'example-hours@example.invalid');
    expect(
      importedHours.content.contacts!.single.value,
      'Example contact only',
    );
    expect(importedHours.protocolState.sequence, isNull);
    await _tap(tester, 'availability-import');
    await _tap(tester, 'availability-import-example');
    await _tap(tester, 'availability-import-submit');
    await _waitFor(tester, find.byKey(const Key('availability-import-error')));
    expect((await rulesApi.list(calendar.id)).length, 1);
    await tester.pageBack();
    await _idle(tester);

    await _tap(tester, 'availability-export-${importedHours.id}');
    await _waitFor(tester, find.byKey(const Key('availability-export-source')));
    final exportedText = tester
        .widget<SelectableText>(
          find.byKey(const Key('availability-export-source')),
        )
        .data!;
    expect(exportedText, contains('BEGIN:VCALENDAR\r\n'));
    expect(exportedText, contains('UID:example-hours@example.invalid\r\n'));
    expect(exportedText, contains('CONTACT:Example contact only\r\n'));
    expect(exportedText, isNot(contains(importedHours.id.toString())));
    await tester.pageBack();
    await _idle(tester);

    await _tap(tester, 'availability-replace-${importedHours.id}');
    await _tap(tester, 'availability-import-example');
    await _tap(tester, 'availability-import-submit');
    await _waitFor(tester, find.text('Imported example hours'));
    expect((await rulesApi.getRule(importedHours.id)).revision, 1);
    await _tap(tester, 'availability-replace-${importedHours.id}');
    await tester.enterText(
      find.byKey(const Key('availability-import-source')),
      exportedText.replaceAll(
        'Imported example hours',
        'Replaced example hours',
      ),
    );
    await _tap(tester, 'availability-import-submit');
    await _waitFor(tester, find.text('Replaced example hours'));
    final replacedHours = await rulesApi.getRule(importedHours.id);
    expect(replacedHours.revision, 2);
    expect(
      replacedHours.content.openings.single.uid,
      importedHours.content.openings.single.uid,
    );
    await rulesApi.updateMetadata(
      cal.CalendarAvailabilityUpdateRequest(
        availabilityId: replacedHours.id,
        expectedRevision: 2,
        content: replacedHours.content.copyWith(summary: 'Local hours edit'),
      ),
    );
    await _tap(tester, 'availability-reload');
    await _waitFor(tester, find.text('Local hours edit'));
    await _tap(tester, 'availability-replace-${importedHours.id}');
    await _tap(tester, 'availability-import-example');
    await _tap(tester, 'availability-import-submit');
    await _waitFor(tester, find.byKey(const Key('availability-import-error')));
    expect(
      (await rulesApi.getRule(importedHours.id)).content.summary,
      'Local hours edit',
    );
    await tester.pageBack();
    await _idle(tester);

    await _tap(tester, 'availability-delete-${importedHours.id}');
    await _idle(tester);
    expect(await rulesApi.list(calendar.id), isEmpty);

    await tester.pageBack();
    await _idle(tester);

    await _tap(tester, 'calendar-delete');
    await _tap(tester, 'calendar-confirm-delete');
    expect(find.byKey(const Key('calendar-error')), findsOneWidget);
    await _tap(tester, 'calendar-events');
    await _waitFor(tester, find.text(eventLabel));
    await tester.tap(find.text(eventLabel));
    await _idle(tester);
    await _tap(tester, 'event-status-confirmed');
    await _tap(tester, 'event-delete');
    await _tap(tester, 'event-confirm-delete');
    expect(find.text(eventLabel), findsNothing);
    await _tap(tester, 'event-import');
    await _tap(tester, 'event-import-example');
    await _tap(tester, 'event-import-submit');
    await _waitFor(tester, find.text('Imported example event'));
    final imported = (await events.list(
      calendar.id,
      pageSize: 10,
      fieldGroups: cal.CalendarEventFieldGroup.values,
    )).events.single;
    expect(imported.protocolUid, 'example-event@example.invalid');
    expect(imported.periods!.single.duration!.hours, 2);
    expect(imported.protocolVersion!.sequence, isNull);
    expect(imported.textParameters!.summary!.language, 'en');
    await _tap(tester, 'event-import');
    await _tap(tester, 'event-import-example');
    await _tap(tester, 'event-import-submit');
    await _waitFor(tester, find.byKey(const Key('event-import-error')));
    expect(
      (await events.list(
        calendar.id,
        pageSize: 10,
        fieldGroups: cal.CalendarEventFieldGroup.values,
      )).events,
      hasLength(1),
    );
    final source = find.byKey(const Key('event-import-source'));
    await tester.ensureVisible(source);
    await tester.enterText(
      source,
      'BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Synthetic//EN\nBEGIN:VTODO\nUID:unsupported\nEND:VTODO\nEND:VCALENDAR\n',
    );
    await _tap(tester, 'event-import-submit');
    await _waitFor(tester, find.byKey(const Key('event-import-error')));
    await tester.pageBack();
    await _idle(tester);
    await events.deleteEvent(imported.id, 1);
    await tester.pageBack();
    await _idle(tester);
    await _tap(tester, 'calendar-attach-self');
    await _tap(tester, 'calendar-subject-search');
    await _enabledField(tester, find.byKey(const Key('search-from')));
    await tester.enterText(
      find.byKey(const Key('search-from')),
      '2026-03-29T00:00:00Z',
    );
    await tester.enterText(
      find.byKey(const Key('search-until')),
      '2026-03-30T00:00:00Z',
    );
    await _tap(tester, 'search-load');
    await _waitFor(tester, find.byKey(const Key('search-common-complete')));
    expect(find.byKey(const Key('search-target-complete-0')), findsOneWidget);
    await _tap(tester, 'search-add');
    expect(find.byKey(const Key('search-common-complete')), findsNothing);
    await tester.enterText(
      find.byKey(const Key('search-reference-1')),
      'not-a-demo-user',
    );
    await _tap(tester, 'search-load');
    await _waitFor(tester, find.byKey(const Key('search-common-unknown')));
    expect(find.byKey(const Key('search-target-complete-0')), findsOneWidget);
    expect(find.byKey(const Key('search-target-unknown-1')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('search-mode')));
    await tester.tap(find.byKey(const Key('search-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Per person/resource').last);
    await tester.pumpAndSettle();
    await _tap(tester, 'search-load');
    await _waitFor(tester, find.byKey(const Key('search-per-target')));
    expect(find.byKey(const Key('search-common-unknown')), findsNothing);
    await tester.pageBack();
    await _idle(tester);

    await _tap(tester, 'calendar-delete');
    await _tap(tester, 'calendar-confirm-delete');
    expect(find.byKey(const Key('calendar-error')), findsOneWidget);
    await _tap(tester, 'calendar-detach');
    await _tap(tester, 'calendar-delete');
    await _tap(tester, 'calendar-confirm-delete');
    expect(find.text(renamedLabel), findsNothing);
    await tester.pageBack();
    await _idle(tester);
    await tester.tap(find.byKey(const Key('sign-out')));
    await _waitFor(tester, find.byKey(const Key('sign-in')));
    expect(find.byKey(const Key('result')), findsNothing);
  });
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 120; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
  }
  fail('Timed out waiting for $finder');
}

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  if (key.startsWith('occurrence-') || key.startsWith('preview-')) {
    await _showOccurrence(tester, finder);
  } else {
    await _waitFor(tester, finder);
  }
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await _idle(tester, step: key);
}

Future<void> _idle(WidgetTester tester, {String step = 'calendar'}) async {
  await tester.pump(const Duration(milliseconds: 300));
  for (var i = 0; i < 120; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(AlertDialog).evaluate().isNotEmpty ||
        find.byType(LinearProgressIndicator).evaluate().isEmpty) {
      return;
    }
  }
  fail('Calendar request did not become idle: $step');
}

Future<void> _enabledField(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 120; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty &&
        tester.widget<TextField>(finder).enabled == true) {
      return;
    }
  }
  fail('Event editor did not become editable');
}

// Preview rows are lazily built by ListView. Scroll the real list to find
// offscreen actions/results instead of treating an unbuilt row as absent data.
Future<void> _showOccurrence(WidgetTester tester, Finder finder) async {
  final list = find.byType(ListView).last;
  final scrollable = find
      .descendant(of: list, matching: find.byType(Scrollable))
      .first;
  await tester.drag(scrollable, const Offset(0, 10000));
  await tester.pump(const Duration(milliseconds: 200));
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: scrollable,
    maxScrolls: 30,
  );
  await tester.pump();
}
