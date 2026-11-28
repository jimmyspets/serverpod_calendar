@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/task_source_values.dart';

CalendarTaskSourceState state(
  List<String> timing, {
  List<String> properties = const [],
  List<String> overrides = const [],
}) => taskStorageProposal(
  parseIcalendarTaskCalendar(
    utf8.encode(
      [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:Synthetic',
        'BEGIN:VTODO',
        'UID:source',
        'DTSTAMP:20261023T100000Z',
        ...timing,
        ...properties,
        'END:VTODO',
        ...overrides,
        'END:VCALENDAR',
        '',
      ].join('\r\n'),
    ),
  ).series.single,
).state;
void main() {
  for (final timing in <List<String>>[
    [],
    ['DUE;VALUE=DATE:20261025'],
    ['DTSTART;VALUE=DATE:20261023', 'DURATION:P2D'],
    ['DUE:20261025T090000Z'],
    ['DTSTART:20261023T090000Z', 'DUE:20261023T100000Z'],
  ]) {
    test('task output preserves optional timing shape $timing', () {
      final original = state(
        timing,
        properties: ['PERCENT-COMPLETE:17', 'COMPLETED:20261022T090000Z'],
      );
      final bytes = taskExportBytes([(uid: 'source', state: original)]);
      final copy = taskStorageProposal(
        parseIcalendarTaskCalendar(bytes).series.single,
      ).state;
      expect(copy, original);
      expect(utf8.decode(bytes), isNot(contains('STATUS:')));
      expect(taskExportBytes([(uid: 'source', state: original)]), bytes);
    });
  }
  test('task output regenerates matching full-horizon zones and preserves due duration shape', () {
    final utc = state(['DTSTART:20261023T090000Z', 'DURATION:PT1H']);
    final zoned = utc.copyWith(
      master: utc.master.copyWith(
        content: utc.master.content.copyWith(
          timing: CalendarTaskTiming(
            kind: CalendarTaskTimeKind.zoned,
            zoneId: 'Europe/Stockholm',
            start: CalendarEventCivil(year: 2026, month: 10, day: 23, hour: 9),
            duration: CalendarEventDuration(hours: 1),
          ),
        ),
      ),
    );
    final bytes = taskExportBytes([(uid: 'source', state: zoned)]);
    final parsed = parseIcalendarTaskCalendar(bytes);
    expect(parsed.timeZones, hasLength(1));
    expect(taskStorageProposal(parsed.series.single).state, zoned);
    expect(
      utf8.decode(bytes),
      contains('DTSTART;TZID=Europe/Stockholm:20261023T090000'),
    );
  });
  test('task output rejects duplicate UID and empty selections', () {
    final s = state([]);
    expect(() => taskExportBytes([]), throwsArgumentError);
    expect(
      () => taskExportBytes([(uid: 'same', state: s), (uid: 'same', state: s)]),
      throwsArgumentError,
    );
  });
  test('task output enforces aggregate raw-component cap across individually valid series', () {
    String date(DateTime d) =>
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    final s = state(
      ['DTSTART;VALUE=DATE:20261023'],
      properties: ['RRULE:FREQ=DAILY;COUNT=65'],
      overrides: [
        for (var i = 1; i <= 64; i++) ...[
          'BEGIN:VTODO',
          'UID:source',
          'DTSTAMP:20261023T100000Z',
          'RECURRENCE-ID;VALUE=DATE:${date(DateTime.utc(2026, 10, 23 + i))}',
          'PERCENT-COMPLETE:1',
          'END:VTODO',
        ],
      ],
    );
    expect(validateTaskSourceState('source', s), s);
    expect(
      () => taskExportBytes([(uid: 'one', state: s), (uid: 'two', state: s)]),
      throwsA(
        isA<IcalendarComponentException>().having(
          (e) => e.kind,
          'kind',
          IcalendarComponentError.limitExceeded,
        ),
      ),
    );
  });
}
