@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_output.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_source_storage_test.dart' as f;
import 'event_wire_output_test.dart' show snapshot;
import 'event_source_metadata_test.dart' show metadata, component;

void main() {
  test('older metadata-only v2 source snapshots omit new participant keys and remain valid', () {
    final p = f.source(extra: ['CLASS:PRIVATE', 'CATEGORIES:Old source group']);
    final payload = p.protocolState.sourceMetadata!.toJson();
    expect(payload.containsKey('organizer'), isFalse);
    expect(payload.containsKey('attendees'), isFalse);
    expect(p.importBaseline.profile, eventBaselineProfile);
    expect(p.importBaseline.canonicalValue, isNot(contains('attendees')));
    validateEventImportBaseline(p.importBaseline, p.protocolUid);
  });

  test('event participant source validates master organizer context and parameter roles', () {
    CalendarEventSourceMetadata value(
      String name,
      Map<String, List<String>> parameters,
    ) => CalendarEventSourceMetadata(
      categoryGroups: [],
      comments: [],
      contacts: [],
      attendees: [
        CalendarEventSourceParticipant(address: name, parameters: parameters),
      ],
    );
    for (final parameters in [
      <String, List<String>>{
        'PARTSTAT': ['COMPLETED'],
      },
      {
        'PARTSTAT': ['IN-PROCESS'],
      },
      {
        'RSVP': ['YES'],
      },
      {
        'LANGUAGE': ['en'],
      },
      {
        'UNKNOWN': ['value'],
      },
      {
        'MEMBER': ['relative'],
      },
      {
        'CN': ['x', 'y'],
      },
    ]) {
      expect(
        () => validateEventSourceMetadata(
          value('mailto:a@example.invalid', parameters),
        ),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    final p = f.source();
    expect(
      () => validateEventProtocolState(
        p.protocolState.copyWith(
          sourceMetadata: value('mailto:a@example.invalid', {}),
        ),
        p.content,
        p.edits,
      ),
      throwsArgumentError,
    );
  });
  test('event participant comparison respects token case but rejects changed claims and ordering', () {
    final p = f.source(
      extra: ['RRULE:FREQ=DAILY;COUNT=2', ...metadata],
      overrides: component(metadata),
    );
    final m = p.protocolState.sourceMetadata!,
        own = p.edits!.singles.single.sourceMetadata!;
    final a = own.attendees!.single;
    validateEventMetadataInheritance(
      m,
      own.copyWith(
        attendees: [
          a.copyWith(
            parameters: {
              ...a.parameters,
              'PARTSTAT': ['accepted'],
            },
          ),
        ],
      ),
    );
    expect(
      () => validateEventMetadataInheritance(
        m,
        own.copyWith(
          attendees: [
            a.copyWith(
              parameters: {
                ...a.parameters,
                'RSVP': ['FALSE'],
              },
            ),
          ],
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateEventMetadataInheritance(
        m,
        own.copyWith(
          organizer: own.organizer!.copyWith(
            address: 'mailto:other@example.invalid',
          ),
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateEventSourceMetadata(
        m.copyWith(attendees: List.filled(65, a)),
      ),
      throwsA(isA<Exception>()),
    );
  });
  test('event participant state preserves decoded source baselines and stays outside protocol views', () {
    final p = f.source(
      extra: ['RRULE:FREQ=DAILY;COUNT=2', ...metadata],
      overrides: component(metadata),
    );
    final bytes = eventExportBytes([snapshot(p)]);
    final c = parseIcalendarEventCalendar(bytes);
    expect(
      c.events.single.participants.attendees.single.participationStatus,
      'ACCEPTED',
    );
    expect(
      c.series.single.overrides.single.participants.organizer!.commonName,
      'Source organizer',
    );
    expect(
      c.events.single.participants.attendees.single.address,
      'mailto:source-attendee@example.invalid',
    );
    expect(
      jsonEncode(p.edits!.toJsonForProtocol()),
      isNot(contains('source-attendee@example.invalid')),
    );
    expect(
      p.importBaseline.canonicalValue,
      contains('source-attendee@example.invalid'),
    );
  });
}
