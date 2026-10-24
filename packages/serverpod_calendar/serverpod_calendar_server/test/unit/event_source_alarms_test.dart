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
import 'event_source_metadata_test.dart' show metadata, component, sourceAlarms;
import 'event_wire_output_test.dart' show snapshot;

const endAlarm = [
  'BEGIN:VALARM',
  'ACTION:DISPLAY',
  'DESCRIPTION:END reminder',
  'TRIGGER;RELATED=END:-PT5M',
  'END:VALARM',
];
void main() {
  test('event source alarms preserve raw definitions privately through canonical export with children last', () {
    final p = f.source(
      extra: ['RRULE:FREQ=DAILY;COUNT=2', ...metadata],
      overrides: component(metadata),
    );
    final alarms = p.protocolState.sourceMetadata!.alarms!;
    expect(alarms.first.relativeDuration!.sign, -1);
    expect(alarms.first.repeat, 2);
    expect(alarms.last.snoozeTargetUid, 'source-alarm');
    expect(() => alarms.clear(), throwsUnsupportedError);
    expect(
      jsonEncode(p.edits!.toJsonForProtocol()),
      isNot(contains('Private source reminder')),
    );
    final bytes = eventExportBytes([snapshot(p)]),
        c = parseIcalendarEventCalendar(bytes);
    expect(c.events.single.alarms.length, 2);
    expect(c.series.single.overrides.single.alarms.last.isSnooze, isTrue);
    for (final event in [c.events.single, ...c.series.single.overrides]) {
      var child = false;
      for (final entry in event.source.entries) {
        if (entry is IcalendarSyntaxComponent) {
          child = true;
        } else {
          expect(child, isFalse);
        }
      }
    }
    validateEventImportBaseline(p.importBaseline, p.protocolUid);
  });
  test('retained END alarms reject point master or occurrence timing and permit explicit durations', () {
    final p = f.source(
      extra: ['RRULE:FREQ=DAILY;COUNT=2', 'DURATION:PT1H', ...endAlarm],
    );
    expect(
      () => validateEventProtocolState(
        p.protocolState,
        p.content.copyWith(timing: f.anchor(22)),
        p.edits,
      ),
      throwsArgumentError,
    );
    final edits = validateEventOverrides(
      p.content,
      CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: f.anchor(23),
            replacement: f.anchor(23),
          ),
        ],
        future: [],
      ),
    );
    expect(
      () => advanceEventProtocol(
        p.protocolState,
        p.content,
        p.edits,
        p.content,
        edits,
        DateTime.utc(2026, 10, 24),
      ),
      throwsArgumentError,
    );
    validateEventProtocolState(p.protocolState, p.content, p.edits);
  });
  test('native source alarm validation rejects conflicting triggers repeat state fractions and total caps', () {
    final p = f.source(extra: sourceAlarms),
        m = p.protocolState.sourceMetadata!,
        a = m.alarms!.first;
    expect(
      () => validateEventSourceMetadata(
        m.copyWith(
          alarms: [a.copyWith(absoluteUtc: DateTime.utc(2026, 10, 24))],
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateEventSourceMetadata(
        m.copyWith(alarms: [a.copyWith(repeat: 101)]),
      ),
      throwsA(isA<IcalendarComponentException>()),
    );
    expect(
      () => validateEventSourceMetadata(
        m.copyWith(
          alarms: [
            a.copyWith(acknowledged: DateTime.utc(2026, 10, 24, 0, 0, 0, 1)),
          ],
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateEventSourceMetadata(m.copyWith(alarms: List.filled(17, a))),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => validateEventSourceMetadata(
        m,
        budget: EventMetadataBudget()..alarms = 255,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    'own default START matches explicit START but changed source state rejects',
    () {
      final p = f.source(extra: sourceAlarms),
          m = p.protocolState.sourceMetadata!,
          a = m.alarms!.first;
      validateEventMetadataInheritance(
        m,
        m.copyWith(
          alarms: [
            a.copyWith(related: 'START'),
            m.alarms!.last,
          ],
        ),
      );
      expect(
        () => validateEventMetadataInheritance(
          m,
          m.copyWith(
            alarms: [
              a.copyWith(acknowledged: DateTime.utc(2026, 10, 21)),
              m.alarms!.last,
            ],
          ),
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'older reference-only v2 snapshots omit source alarm keys and remain valid',
    () {
      final p = f.source(extra: ['RELATED-TO:unresolved', 'ATTACH:urn:file:1']);
      expect(
        p.protocolState.sourceMetadata!.toJson().containsKey('alarms'),
        isFalse,
      );
      validateEventImportBaseline(p.importBaseline, p.protocolUid);
    },
  );
}
