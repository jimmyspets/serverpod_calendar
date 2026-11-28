@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_output.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart'
    show RecurrenceLimitException;
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_source_storage_test.dart' as f;
import 'event_source_metadata_test.dart' show metadata, component;
import 'event_wire_output_test.dart' show snapshot;

CalendarEventSourceMetadata refs({
  List<CalendarEventSourceRelationship>? relationships,
  List<CalendarEventSourceAttachment>? attachments,
}) => CalendarEventSourceMetadata(
  categoryGroups: [],
  comments: [],
  contacts: [],
  relationships: relationships,
  attachments: attachments,
);
void main() {
  test('parameter-free own participant snapshots restore only required empty parameter maps', () {
    final values = [
      'ORGANIZER:mailto:o@example.invalid',
      'ATTENDEE:mailto:a@example.invalid',
    ];
    final p = f.source(
      extra: ['RRULE:FREQ=DAILY;COUNT=2', ...values],
      overrides: component(values),
    );
    expect(p.importBaseline.canonicalValue, isNot(contains('parameters')));
    validateEventImportBaseline(p.importBaseline, p.protocolUid);
    final broken = p.importBaseline.copyWith(
      canonicalValue: p.importBaseline.canonicalValue.replaceAll(
        '"organizer":{"address":"mailto:o@example.invalid"}',
        '"organizer":{}',
      ),
    );
    expect(
      () => validateEventImportBaseline(broken, p.protocolUid),
      throwsStateError,
    );
  });

  test('event source reference DTOs retain presence through canonical export without native resolution', () {
    final p = f.source(
      extra: ['RRULE:FREQ=DAILY;COUNT=2', ...metadata],
      overrides: component(metadata),
    );
    final m = p.protocolState.sourceMetadata!,
        own = p.edits!.singles.single.sourceMetadata!;
    expect(m.relationships!.single.targetUid, p.protocolUid);
    expect(m.relationships!.single.relationType, isNull);
    expect(own.attachments!.single.explicitUri, isTrue);
    expect(() => own.relationships!.clear(), throwsUnsupportedError);
    expect(() => own.attachments!.clear(), throwsUnsupportedError);
    final c = parseIcalendarEventCalendar(eventExportBytes([snapshot(p)]));
    expect(
      c.events.single.references.relationships.single.targetUid,
      p.protocolUid,
    );
    expect(
      c.series.single.overrides.single.references.attachments.single.uri,
      'urn:source:file',
    );
    expect(
      jsonEncode(p.edits!.toJsonForProtocol()),
      isNot(contains('urn:source:file')),
    );
    validateEventImportBaseline(p.importBaseline, p.protocolUid);
  });
  test('event source references match semantic defaults and media case while preserving own presence', () {
    final m = validateEventSourceMetadata(
      refs(
        relationships: [CalendarEventSourceRelationship(targetUid: 'target')],
        attachments: [
          CalendarEventSourceAttachment(
            uri: 'urn:file:1',
            mediaType: 'application/pdf',
            explicitUri: false,
          ),
        ],
      ),
    )!;
    final own = validateEventSourceMetadata(
      m.copyWith(
        relationships: [
          m.relationships!.single.copyWith(relationType: 'parent'),
        ],
        attachments: [
          m.attachments!.single.copyWith(
            mediaType: 'APPLICATION/PDF',
            explicitUri: true,
          ),
        ],
      ),
    )!;
    validateEventMetadataInheritance(m, own);
    expect(own.relationships!.single.relationType, 'PARENT');
    expect(own.attachments!.single.explicitUri, isTrue);
    expect(
      () => validateEventMetadataInheritance(
        m,
        own.copyWith(
          relationships: [
            own.relationships!.single.copyWith(targetUid: 'Target'),
          ],
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateEventMetadataInheritance(
        m,
        own.copyWith(
          attachments: [
            own.attachments!.single.copyWith(mediaType: 'text/plain'),
          ],
        ),
      ),
      throwsArgumentError,
    );
  });
  test('native source validation rejects malformed inline and extended references with shared budgets', () {
    for (final a in [
      CalendarEventSourceAttachment(
        uri: 'data:text/plain,hello',
        explicitUri: false,
      ),
      CalendarEventSourceAttachment(uri: 'relative', explicitUri: false),
      CalendarEventSourceAttachment(
        uri: 'urn:file:1',
        mediaType: '*/*',
        explicitUri: true,
      ),
    ]) {
      expect(
        () => validateEventSourceMetadata(refs(attachments: [a])),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    for (final r in [
      CalendarEventSourceRelationship(targetUid: ''),
      CalendarEventSourceRelationship(
        targetUid: 'target',
        relationType: 'DEPENDS-ON',
      ),
    ]) {
      expect(
        () => validateEventSourceMetadata(refs(relationships: [r])),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    expect(
      () => validateEventSourceMetadata(
        refs(
          relationships: List.filled(
            65,
            CalendarEventSourceRelationship(targetUid: 'target'),
          ),
        ),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => validateEventSourceMetadata(
        refs(
          attachments: [
            CalendarEventSourceAttachment(
              uri: 'urn:file:1',
              explicitUri: false,
            ),
          ],
        ),
        budget: EventMetadataBudget()..used = 65530,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('older participant v2 source snapshots omit reference keys and remain valid', () {
    final p = f.source(
      extra: [
        'ORGANIZER:mailto:o@example.invalid',
        'ATTENDEE:mailto:a@example.invalid',
      ],
    );
    final value = p.protocolState.sourceMetadata!.toJson();
    expect(value.containsKey('relationships'), isFalse);
    expect(value.containsKey('attachments'), isFalse);
    expect(p.importBaseline.canonicalValue, isNot(contains('relationships')));
    validateEventImportBaseline(p.importBaseline, p.protocolUid);
  });
}
