@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_output.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart'
    show RecurrenceLimitException;
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_source_storage_test.dart' as f;
import 'event_overrides_test.dart' as g;
import 'event_wire_output_test.dart' show snapshot;

const metadata = [
  'ORGANIZER;CN=Source organizer:mailto:source-organizer@example.invalid',
  'ATTENDEE;PARTSTAT=ACCEPTED;MEMBER="urn:group:source":mailto:source-attendee@example.invalid',
  'URL:https://example.invalid/event',
  'CLASS:PRIVATE',
  'CATEGORIES;LANGUAGE=en:Work,Work',
  'COMMENT;LANGUAGE=sv:Note',
  'CONTACT;ALTREP="cid:desk@example.invalid":Desk',
];
List<String> component(List<String> extra) => [
  'BEGIN:VEVENT',
  'UID:not-a-uuid@example.invalid',
  'DTSTAMP:20261022T100000Z',
  'RECURRENCE-ID:20261023T120000Z',
  'DTSTART:20261023T150000Z',
  'SEQUENCE:3',
  'CREATED:20261020T000000Z',
  ...extra,
  'END:VEVENT',
];
void main() {
  test('event source metadata charges master and occurrence against the same native budget', () {
    final p = f.source(extra: ['RRULE:FREQ=DAILY;COUNT=2']);
    final metadata = CalendarEventSourceMetadata(
      categoryGroups: [],
      comments: [
        for (var i = 0; i < 10; i++)
          CalendarEventSourceText(value: List.filled(4000, 'x').join()),
      ],
      contacts: [],
    );
    final edits = validateEventOverrides(
      p.content,
      CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: f.anchor(23),
            replacement: f.anchor(23),
            sourceMetadata: metadata,
          ),
        ],
        future: [],
      ),
    );
    expect(
      () => validateEventProtocolState(
        p.protocolState.copyWith(
          sourceMetadata: metadata,
          overrides: [
            CalendarEventOverrideProtocolState(
              originalStart: f.anchor(23),
              version: p.protocolState.version,
            ),
          ],
        ),
        p.content,
        edits,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('event source metadata is immutable server-only JSON and round trips decoded groups', () {
    final p = f.source(
      extra: ['RRULE:FREQ=DAILY;COUNT=2', ...metadata],
      overrides: component(metadata),
    );
    final own = p.edits!.singles.single;
    expect(
      p.protocolState.sourceMetadata!.organizer!.address,
      'mailto:source-organizer@example.invalid',
    );
    expect(own.sourceMetadata!.attendees!.single.parameters['MEMBER'], [
      'urn:group:source',
    ]);
    expect(
      () => own.sourceMetadata!.attendees!.single.parameters['MEMBER']!.clear(),
      throwsUnsupportedError,
    );
    expect(p.protocolState.sourceMetadata!.categoryGroups.single.values, [
      'Work',
      'Work',
    ]);
    expect(
      own.sourceMetadata!.contacts.single.parameters!.alternativeUri,
      'cid:desk@example.invalid',
    );
    expect(
      () => own.sourceMetadata!.categoryGroups.single.values.clear(),
      throwsUnsupportedError,
    );
    expect(jsonEncode(own.toJson()), contains('sourceMetadata'));
    expect(
      jsonEncode(own.toJsonForProtocol()),
      isNot(contains('sourceMetadata')),
    );
    expect(jsonEncode(p.edits!.toJsonForProtocol()), isNot(contains('Desk')));
    final round = eventStorageProposal(
      parseIcalendarEventCalendar(eventExportBytes([snapshot(p)]))
          .series
          .single,
    );
    expect(
      round.importBaseline.canonicalValue,
      p.importBaseline.canonicalValue,
    );
  });
  test('event source metadata-only nodes survive clear content and timing without disclosure or lossy export', () {
    final p = f.source(
      extra: ['RRULE:FREQ=DAILY;COUNT=2', ...metadata],
      overrides: component(metadata),
    );
    var edits = changeEventOverrides(
      p.content,
      p.edits,
      CalendarEventOccurrenceChange(
        eventId: g.id,
        expectedRevision: 1,
        originalStart: f.anchor(23),
        action: CalendarEventOccurrenceAction.clearSingleTiming,
      ),
    );
    expect(edits!.singles.single.replacement, isNull);
    expect(
      edits.singles.single.sourceMetadata,
      p.edits!.singles.single.sourceMetadata,
    );
    edits = changeEventContentOverrides(
      p.content,
      edits,
      CalendarEventOccurrenceContentRequest(
        eventId: g.id,
        expectedRevision: 2,
        originalStart: f.anchor(23),
        changes: [
          CalendarEventOccurrenceContentChange(
            field: CalendarEventContentField.summary,
            action: CalendarEventContentAction.inheritSeries,
          ),
        ],
      ),
    );
    expect(edits!.singles.single.sourceMetadata, isNotNull);
    expect(
      eventDisclosedOverrides(edits, CalendarEventFieldGroup.values.toSet()),
      isNull,
    );
    final state = advanceEventProtocol(
      p.protocolState,
      p.content,
      p.edits,
      p.content,
      edits,
      DateTime.utc(2026, 10, 24),
    );
    expect(state.overrides.single.version.sequence, 4);
    expect(
      state.overrides.single.version.created,
      p.protocolState.overrides.single.version.created,
    );
    expect(
      () => eventExportBytes([
        CalendarEventPolicySnapshot(
          g.id,
          g.id,
          1,
          p.content,
          p.protocolUid,
          DateTime.utc(2026, 10, 24),
          timingOverrides: edits,
          protocolState: state,
        ),
      ]),
      throwsArgumentError,
    );
  });
  test(
    'event source metadata has explicit item and shared codepoint ceilings',
    () {
      final m = CalendarEventSourceMetadata(
        categoryGroups: [],
        comments: [
          for (var i = 0; i < 17; i++)
            CalendarEventSourceText(value: List.filled(4096, 'x').join()),
        ],
        contacts: [],
      );
      expect(
        () => validateEventSourceMetadata(m),
        throwsA(isA<RecurrenceLimitException>()),
      );
      expect(
        () => validateEventSourceMetadata(
          m.copyWith(
            comments: [],
            categoryGroups: [
              CalendarEventSourceCategoryGroup(values: List.filled(65, 'Work')),
            ],
          ),
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
      expect(
        () => validateEventSourceMetadata(
          m.copyWith(comments: [], classification: 'X-PRIVATE'),
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'event source inheritance default CLASS and exact grouping remain bounded',
    () {
      final public = CalendarEventSourceMetadata(
        classification: 'PUBLIC',
        categoryGroups: [],
        comments: [],
        contacts: [],
      );
      validateEventMetadataInheritance(null, public);
      expect(
        () => validateEventMetadataInheritance(
          null,
          public.copyWith(classification: 'PRIVATE'),
        ),
        throwsArgumentError,
      );
      final master = public.copyWith(
        categoryGroups: [
          CalendarEventSourceCategoryGroup(values: ['A', 'B']),
        ],
      );
      expect(
        () => validateEventMetadataInheritance(
          master,
          master.copyWith(
            categoryGroups: [
              CalendarEventSourceCategoryGroup(values: ['A']),
              CalendarEventSourceCategoryGroup(values: ['B']),
            ],
          ),
        ),
        throwsArgumentError,
      );
    },
  );
  test('event source master metadata stays stable during native text edits and baseline detects differences', () {
    final p = f.source(extra: metadata);
    final changed = advanceEventProtocol(
      p.protocolState,
      p.content,
      p.edits,
      p.content.copyWith(summary: 'Native'),
      p.edits,
      DateTime.utc(2026, 10, 24),
    );
    expect(changed.sourceMetadata, p.protocolState.sourceMetadata);
    expect(changed.version.sequence, 1);
    final baseline = eventImportBaseline(
      p.protocolUid,
      p.content,
      p.edits,
      p.protocolState,
    );
    validateEventImportBaseline(baseline, p.protocolUid);
    final other = eventImportBaseline(
      p.protocolUid,
      p.content,
      p.edits,
      p.protocolState.copyWith(
        sourceMetadata: p.protocolState.sourceMetadata!.copyWith(contacts: []),
      ),
    );
    expect(other.canonicalValue, isNot(baseline.canonicalValue));
  });
}
