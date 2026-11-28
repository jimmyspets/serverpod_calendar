@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_wire_output.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

CalendarEventPolicySnapshot source(
  int id, {
  bool related = false,
  bool dateOnly = false,
  bool zoned = false,
}) {
  final bytes = utf8.encode(
    [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic//EN',
      'BEGIN:VEVENT',
      'UID:copied-source@example.invalid',
      'DTSTAMP:20261025T120000Z',
      'DTSTART:20261026T120000Z',
      'DURATION:PT1H',
      'RRULE:FREQ=DAILY;COUNT=3',
      'SUMMARY:Published text',
      if (related) 'RELATED-TO:source-reference@example.invalid',
      'BEGIN:VALARM',
      'ACTION:DISPLAY',
      'TRIGGER:-PT5M',
      'DESCRIPTION:Private source reminder',
      'END:VALARM',
      'END:VEVENT',
      'BEGIN:VEVENT',
      'UID:copied-source@example.invalid',
      'DTSTAMP:20261025T120000Z',
      'RECURRENCE-ID:20261027T120000Z',
      'DTSTART:20261027T140000Z',
      'DURATION:PT1H',
      'END:VEVENT',
      'END:VCALENDAR',
      '',
    ].join('\r\n'),
  );
  var wire = utf8.decode(bytes);
  if (dateOnly) {
    wire = wire
        .replaceAllMapped(
          RegExp(r'(DTSTART|RECURRENCE-ID):(\d{8})T\d{6}Z'),
          (m) => '${m[1]};VALUE=DATE:${m[2]}',
        )
        .replaceAll('DURATION:PT1H', 'DURATION:P1D');
  } else if (zoned) {
    wire = wire.replaceAllMapped(
      RegExp(r'(DTSTART|RECURRENCE-ID):(\d{8}T\d{6})Z'),
      (m) => '${m[1]};TZID=Europe/Stockholm:${m[2]}',
    );
  }
  var document = parseIcalendarSyntax(utf8.encode(wire));
  if (zoned) {
    document = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [
        ...document.components.single.entries
            .whereType<IcalendarSyntaxProperty>(),
        createIcalendarTimeZone('Europe/Stockholm'),
        ...document.components.single.entries
            .whereType<IcalendarSyntaxComponent>(),
      ]),
    ]);
  }
  final proposal = eventStorageProposal(
    validateIcalendarEventCalendar(document).series.single,
  );
  return CalendarEventPolicySnapshot(
    UuidValue.fromString(
      '00000000-0000-4000-8000-${id.toString().padLeft(12, '0')}',
    ),
    UuidValue.fromString(
      '10000000-0000-4000-8000-${id.toString().padLeft(12, '0')}',
    ),
    1,
    proposal.content,
    proposal.protocolUid,
    DateTime.utc(2026, 10, 25),
    timingOverrides: proposal.edits,
    protocolState: proposal.protocolState,
  );
}

void main() {
  test('named-zone copies share one full-horizon generated zone without changing local identity', () {
    final bytes = eventPublicationBytes([
      source(1, zoned: true),
      source(2, zoned: true),
    ]);
    final root = parseIcalendarSyntax(bytes).components.single;
    expect(
      root.entries.whereType<IcalendarSyntaxComponent>().where(
        (c) => c.canonicalName == 'VTIMEZONE',
      ),
      hasLength(1),
    );
    expect(parseIcalendarEventCalendar(bytes).series, hasLength(2));
    expect(
      utf8.decode(bytes),
      contains('RECURRENCE-ID;TZID=Europe/Stockholm:20261027T120000'),
    );
  });
  test('date-only publication keeps dates and duration units', () {
    final bytes = eventPublicationBytes([source(1, dateOnly: true)]);
    expect(parseIcalendarEventCalendar(bytes).series, hasLength(1));
    final text = utf8.decode(bytes);
    expect(text, contains('DTSTART;VALUE=DATE:20261026'));
    expect(text, contains('RECURRENCE-ID;VALUE=DATE:20261027'));
    expect(text, contains('DURATION:P1D'));
  });
  test('copies get distinct stable publication UIDs on every component', () {
    final a = source(1), b = source(2);
    final bytes = eventPublicationBytes([b, a]);
    final parsed = parseIcalendarEventCalendar(bytes);
    expect(parsed.series, hasLength(2));
    expect(parsed.series.map((s) => s.master.uid).toSet(), {
      'urn:uuid:${a.eventId}',
      'urn:uuid:${b.eventId}',
    });
    expect(
      utf8.decode(bytes),
      isNot(contains('copied-source@example.invalid')),
    );
    expect(eventPublicationBytes([a, b]), orderedEquals(bytes));
    expect(
      eventPublicationBytes([a]),
      orderedEquals(eventPublicationBytes([a])),
    );
  });
  test(
    'publication excludes alarms without modifying authenticated export',
    () {
      final a = source(1);
      final canonical = eventExportBytes([a]);
      final published = utf8.decode(eventPublicationBytes([a]));
      expect(published, isNot(contains('VALARM')));
      expect(published, isNot(contains('Private source reminder')));
      expect(published, contains('SUMMARY:Published text'));
      expect(published, contains('RRULE:'));
      expect(published, contains('RECURRENCE-ID:'));
      expect(utf8.decode(canonical), contains('VALARM'));
      expect(eventExportBytes([a]), orderedEquals(canonical));
    },
  );
  test('unmapped source references reject instead of retargeting copies', () {
    expect(
      () => eventPublicationBytes([source(1, related: true)]),
      throwsArgumentError,
    );
  });
  test('empty selection emits an empty feed; duplicate identity rejects', () {
    final document = parseIcalendarSyntax(eventPublicationBytes([]));
    expect(document.components.single.canonicalName, 'VCALENDAR');
    expect(
      document.components.single.entries.whereType<IcalendarSyntaxComponent>(),
      isEmpty,
    );
    final a = source(1);
    expect(() => eventPublicationBytes([a, a]), throwsArgumentError);
  });
}
