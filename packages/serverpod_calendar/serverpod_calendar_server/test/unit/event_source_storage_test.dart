@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart'
    show RecurrenceLimitException;
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';

EventStorageProposal source({
  String timing = 'DTSTART:20261022T120000Z',
  List<String> extra = const [],
  List<String> overrides = const [],
  List<String> zones = const [],
}) {
  final lines = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Synthetic//EN',
    ...zones,
    'BEGIN:VEVENT',
    'UID:not-a-uuid@example.invalid',
    'DTSTAMP:20261022T100000Z',
    timing,
    ...extra,
    'END:VEVENT',
    ...overrides,
    'END:VCALENDAR',
    '',
  ];
  return eventStorageProposal(
    parseIcalendarEventCalendar(utf8.encode(lines.join('\r\n'))).series.single,
  );
}

CalendarEventTiming anchor(int day) => CalendarEventTiming(
  kind: CalendarEventTimeKind.utc,
  start: CalendarEventCivil(year: 2026, month: 10, day: day, hour: 12),
);
void main() {
  test('source omissions annotations PERIOD and bounded private baseline', () {
    final p = source(
      extra: [
        'SUMMARY;LANGUAGE=sv;ALTREP="cid:synthetic@example.invalid":Hej',
        'RDATE;VALUE=PERIOD:20261024T120000Z/PT2H',
      ],
    );
    expect(p.protocolUid, 'not-a-uuid@example.invalid');
    expect(p.content.status, CalendarEventStatus.confirmed);
    expect(p.protocolState.statusPresent, isFalse);
    expect(p.protocolState.transparencyPresent, isFalse);
    expect(p.protocolState.version.sequence, isNull);
    expect(p.protocolState.version.created, isNull);
    expect(p.content.textParameters!.summary!.language, 'sv');
    expect(
      p.content.textParameters!.summary!.alternativeUri,
      'cid:synthetic@example.invalid',
    );
    expect(p.content.periods!.single.duration!.hours, 2);
    validateEventImportBaseline(p.importBaseline, p.protocolUid);
    expect(
      () => validateEventImportBaseline(
        p.importBaseline.copyWith(profile: 'unknown'),
        p.protocolUid,
      ),
      throwsStateError,
    );
    expect(() => p.content.periods!.clear(), throwsUnsupportedError);
    final page = previewEventOccurrences(
      p.content,
      CalendarEventOccurrenceQuery(
        eventId: UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
        expectedRevision: 1,
        fromUtc: DateTime.utc(2026, 10, 22),
        untilUtc: DateTime.utc(2026, 10, 25),
      ),
    );
    expect(page.occurrences.length, 2);
    expect(
      page.occurrences.last.endUtc!
          .difference(page.occurrences.last.startUtc!)
          .inHours,
      2,
    );
  });
  test('DATE duration explicit empty text and version omissions', () {
    final p = source(
      timing: 'DTSTART;VALUE=DATE:20261022',
      extra: [
        'DURATION:P2D',
        'SUMMARY:',
        'SEQUENCE:7',
        'CREATED:20261001T000000Z',
      ],
    );
    expect(p.content.timing.duration!.days, 2);
    expect(p.content.summary, '');
    expect(p.protocolState.version.sequence, 7);
    expect(p.protocolState.version.created, DateTime.utc(2026, 10));
    expect(p.importBaseline.canonicalValue, contains('"summary":""'));
    expect(
      source().importBaseline.canonicalValue,
      isNot(p.importBaseline.canonicalValue),
    );
  });
  test('independent occurrence versions retain cancellation geometry', () {
    final p = source(
      extra: ['RRULE:FREQ=DAILY;COUNT=3', 'SUMMARY:Same', 'SEQUENCE:3'],
      overrides: [
        'BEGIN:VEVENT',
        'UID:not-a-uuid@example.invalid',
        'DTSTAMP:20261023T100000Z',
        'RECURRENCE-ID:20261023T120000Z',
        'DTSTART:20261023T150000Z',
        'DURATION:PT2H',
        'STATUS:CANCELLED',
        'SEQUENCE:8',
        'END:VEVENT',
      ],
    );
    expect(p.edits!.singles.single.replacement!.start.hour, 15);
    expect(p.edits!.singles.single.replacement!.duration!.hours, 2);
    final changed = advanceEventProtocol(
      p.protocolState,
      p.content,
      p.edits,
      p.content.copyWith(summary: 'New'),
      p.edits,
      DateTime.utc(2026, 10, 20),
    );
    expect(changed.version.sequence, 4);
    expect(changed.version.stamp, p.protocolState.version.stamp);
    expect(changed.overrides.single.version.sequence, 8);
    expect(changed.overrides.single.version.created, isNull);
    final restored = p.edits!.copyWith(
      singles: [p.edits!.singles.single.copyWith(cancelled: false)],
    );
    final result = advanceEventProtocol(
      changed,
      p.content.copyWith(summary: 'New'),
      p.edits,
      p.content.copyWith(summary: 'New'),
      restored,
      DateTime.utc(2026, 10, 24),
    );
    expect(result.version.sequence, 4);
    expect(result.overrides.single.version.sequence, 9);
    expect(result.overrides.single.statusPresent, isFalse);
  });
  test(
    'explicit repeated text tracks master while inherited text does not',
    () {
      final p = source(
        extra: ['RRULE:FREQ=DAILY;COUNT=2', 'SUMMARY:Same'],
        overrides: [
          'BEGIN:VEVENT',
          'UID:not-a-uuid@example.invalid',
          'DTSTAMP:20261022T100000Z',
          'RECURRENCE-ID:20261023T120000Z',
          'DTSTART:20261023T150000Z',
          'SUMMARY:Same',
          'END:VEVENT',
        ],
      );
      final s = advanceEventProtocol(
        p.protocolState,
        p.content,
        p.edits,
        p.content.copyWith(summary: 'Changed'),
        p.edits,
        DateTime.utc(2026, 10, 24),
      );
      expect(s.version.sequence, 1);
      expect(s.overrides.single.version.sequence, 1);
      expect(s.overrides.single.summaryPresent, isTrue);
      expect(
        advanceEventProtocol(
          s,
          p.content,
          p.edits,
          p.content,
          p.edits,
          DateTime.utc(2026, 10, 25),
        ).version.toJson(),
        s.version.toJson(),
      );
    },
  );
  test('sequence ceiling allows no-op and rejects significant changes', () {
    final p = source(extra: ['SEQUENCE:2147483647']);
    expect(
      advanceEventProtocol(
        p.protocolState,
        p.content,
        null,
        p.content,
        null,
        DateTime.utc(2026, 10, 24),
      ).version.sequence,
      2147483647,
    );
    expect(
      () => advanceEventProtocol(
        p.protocolState,
        p.content,
        null,
        p.content.copyWith(summary: 'new'),
        null,
        DateTime.utc(2026, 10, 24),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    'PERIOD conflict profile and shared input budget reject without loss',
    () {
      final c = source(extra: ['RDATE;VALUE=PERIOD:20261024T120000Z/PT2H'])
          .content;
      expect(
        () => validateEventContent(
          c.copyWith(
            periods: [
              c.periods!.single,
              c.periods!.single.copyWith(
                duration: CalendarEventDuration(hours: 3),
              ),
            ],
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateEventContent(
          c.copyWith(periods: List.filled(257, c.periods!.single)),
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
      expect(
        () => validateEventContent(c.copyWith(periods: [anchor(24)])),
        throwsArgumentError,
      );
      expect(
        () => validateEventContent(
          c.copyWith(
            periods: [
              c.periods!.single.copyWith(
                kind: CalendarEventTimeKind.zoned,
                zoneId: 'UTC',
              ),
            ],
          ),
        ),
        throwsArgumentError,
      );
    },
  );
  test('legacy initialization omits unknown occurrence creation', () {
    final p = source(extra: ['RRULE:FREQ=DAILY;COUNT=2']);
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(originalStart: anchor(23), cancelled: true),
      ],
      future: [],
    );
    final state = eventProtocolBaseline(
      p.content,
      edits,
      DateTime.utc(2026, 1, 1, 0, 0, 0, 500),
      DateTime.utc(2026, 2, 1, 0, 0, 0, 500),
      legacy: true,
    );
    expect(state.version.created, DateTime.utc(2026));
    expect(state.version.lastModified, DateTime.utc(2026, 2));
    expect(state.overrides.single.version.created, isNull);
    expect(() => state.overrides.clear(), throwsUnsupportedError);
  });
  test('named-zone and THISANDFUTURE source geometry stay typed', () {
    final p = source(
      timing: 'DTSTART;TZID=UTC:20261022T120000',
      extra: ['RRULE:FREQ=DAILY;COUNT=3', 'DURATION:P1D'],
      zones: [
        'BEGIN:VTIMEZONE',
        'TZID:UTC',
        'BEGIN:STANDARD',
        'DTSTART:19000101T000000',
        'TZOFFSETFROM:+0000',
        'TZOFFSETTO:+0000',
        'END:STANDARD',
        'END:VTIMEZONE',
      ],
      overrides: [
        'BEGIN:VEVENT',
        'UID:not-a-uuid@example.invalid',
        'DTSTAMP:20261022T100000Z',
        'RECURRENCE-ID;TZID=UTC;RANGE=THISANDFUTURE:20261023T120000',
        'DTSTART;TZID=UTC:20261023T130000',
        'DURATION:PT2H',
        'SEQUENCE:5',
        'END:VEVENT',
      ],
    );
    expect(p.content.timing.kind, CalendarEventTimeKind.zoned);
    expect(p.content.timing.zoneId, 'UTC');
    expect(p.content.timing.duration!.days, 1);
    expect(p.content.recurrence!.rule!.count, 3);
    expect(p.edits!.future.single.originalStart.start.hour, 12);
    expect(p.edits!.future.single.replacement.start.hour, 13);
    expect(p.edits!.future.single.replacement.duration!.hours, 2);
    expect(p.protocolState.overrides.single.isThisAndFuture, isTrue);
    expect(p.protocolState.overrides.single.version.sequence, 5);
  });
  test('DATE and subdaily filters retain WKST UNTIL and clock selections', () {
    final d = source(
      timing: 'DTSTART;VALUE=DATE:20261022',
      extra: ['RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU;BYDAY=TH;UNTIL=20261231'],
    ).content.recurrence!.rule!;
    expect(d.frequency, CalendarEventFrequency.weekly);
    expect(d.interval, 2);
    expect(d.weekStart, 7);
    expect(d.byDay.single.weekday, 4);
    expect(d.untilDate!.month, 12);
    final t = source(
      extra: [
        'RRULE:FREQ=MINUTELY;INTERVAL=2;BYHOUR=12;BYMINUTE=0,2,4;COUNT=3',
      ],
    ).content.recurrence!.rule!;
    expect(t.frequency, CalendarEventFrequency.minutely);
    expect(t.byHour, [12]);
    expect(t.byMinute, [0, 2, 4]);
    expect(t.count, 3);
  });
  test('malformed ALTREP rejects as a native validation error', () {
    final c = source(extra: ['SUMMARY:Text']).content;
    expect(
      () => validateEventContent(
        c.copyWith(
          textParameters: CalendarEventTextParameters(
            summary: CalendarTextParameters(alternativeUri: 'http://[broken'),
          ),
        ),
      ),
      throwsArgumentError,
    );
  });
  test('UID digest is only an aid; exact text decides conflict', () {
    expect(eventUidConflicts('A', ['a', 'other']), isFalse);
    expect(eventUidConflicts('A', ['A']), isTrue);
    expect(eventUidDigest('A'), isNot(eventUidDigest('a')));
    validateEventUid('😀' * 4096);
    expect(() => validateEventUid('😀' * 4097), throwsArgumentError);
  });
}
