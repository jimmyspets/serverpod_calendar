@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart'
    show RecurrenceLimitException;
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';
import 'package:serverpod_calendar_server/src/event_wire_output.dart';

String event({
  String uid = 'source@example.invalid',
  String timing = 'DTSTART:20261022T120000Z',
  List<String> extra = const [],
}) => [
  'BEGIN:VEVENT',
  'UID:$uid',
  'DTSTAMP:20400101T000000Z',
  timing,
  ...extra,
  'END:VEVENT',
].join('\r\n');
IcalendarEventCalendar load(List<String> entries) =>
    parseIcalendarEventCalendar(
      utf8.encode(
        [
          'BEGIN:VCALENDAR',
          'VERSION:2.0',
          'PRODID:-//Synthetic original envelope//EN',
          ...entries,
          'END:VCALENDAR',
          '',
        ].join('\r\n'),
      ),
    );
CalendarEventPolicySnapshot snapshot(EventStorageProposal p) =>
    CalendarEventPolicySnapshot(
      UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
      UuidValue.fromString('22222222-2222-4222-8222-222222222222'),
      1,
      p.content,
      p.protocolUid,
      DateTime.utc(2026),
      timingOverrides: p.edits,
      protocolState: p.protocolState,
    );
void main() {
  test(
    'emits complete decoded source meaning and versions without old envelope',
    () {
      final proposal = eventStorageProposal(
        load([
          event(
            extra: [
              'SUMMARY;LANGUAGE=sv;ALTREP="cid:synthetic@example.invalid":Hej',
              'DURATION:PT1H',
              'RRULE:FREQ=DAILY;COUNT=3',
              'RDATE;VALUE=PERIOD:20261026T120000Z/PT2H',
              'SEQUENCE:7',
            ],
          ),
          event(
            timing: 'DTSTART:20261023T150000Z',
            extra: [
              'RECURRENCE-ID:20261023T120000Z',
              'DURATION:PT3H',
              'STATUS:CANCELLED',
              'SEQUENCE:8',
            ],
          ),
        ]).series.single,
      );
      final bytes = eventExportBytes([snapshot(proposal)]),
          text = utf8.decode(eventExportBytes([snapshot(proposal)]));
      expect(utf8.decode(bytes), text);
      expect(text, isNot(contains('Synthetic original envelope')));
      expect(text, isNot(contains('importBaseline')));
      final parsed = parseIcalendarEventCalendar(bytes).series.single;
      expect(parsed.master.sequence, 7);
      expect(parsed.overrides.single.sequence, 8);
      expect(parsed.master.status, isNull);
      expect(parsed.master.created, isNull);
      expect(parsed.master.summary!.language, 'sv');
      expect(
        parsed.master.summary!.alternativeUri,
        'cid:synthetic@example.invalid',
      );
      expect(
        parsed
            .master
            .recurrence!
            .timedSet!
            .periods
            .values
            .single
            .duration!
            .hours,
        2,
      );
      expect(parsed.overrides.single.timedSpan!.start.civil.hour, 15);
    },
  );
  test('DATE values explicit exclusive endpoints and UNTIL stay DATE', () {
    final p = eventStorageProposal(
      load([
        event(
          timing: 'DTSTART;VALUE=DATE:20261022',
          extra: [
            'DTEND;VALUE=DATE:20261024',
            'RRULE:FREQ=WEEKLY;UNTIL=20261231;WKST=SU;BYDAY=TH',
          ],
        ),
      ]).series.single,
    );
    final text = utf8.decode(eventExportBytes([snapshot(p)]));
    expect(text, contains('DTSTART;VALUE=DATE:20261022'));
    expect(text, contains('DTEND;VALUE=DATE:20261024'));
    expect(text, contains('UNTIL=20261231'));
    expect(text, contains('WKST=SU'));
    final endpoint = eventStorageProposal(
      load([
        event(
          timing: 'DTSTART;VALUE=DATE:20991231',
          extra: ['DTEND;VALUE=DATE:21000101'],
        ),
      ]).series.single,
    );
    expect(
      utf8.decode(eventExportBytes([snapshot(endpoint)])),
      contains('DTEND;VALUE=DATE:21000101'),
    );
  });
  test(
    'named zone rules regenerate and retain nominal duration and future timing',
    () {
      final zone = utf8
          .decode(
            serializeIcalendarSyntax(
              IcalendarSyntaxDocument([
                createIcalendarTimeZone('America/New_York'),
              ]),
            ),
          )
          .trimRight();
      final p = eventStorageProposal(
        load([
          zone,
          event(
            timing: 'DTSTART;TZID=America/New_York:20260307T120000',
            extra: ['DURATION:P1D', 'RRULE:FREQ=DAILY;COUNT=3'],
          ),
          event(
            timing: 'DTSTART;TZID=America/New_York:20260308T140000',
            extra: [
              'RECURRENCE-ID;TZID=America/New_York;RANGE=THISANDFUTURE:20260308T120000',
              'DURATION:PT2H',
            ],
          ),
        ]).series.single,
      );
      final output = eventExportBytes([snapshot(p)]),
          parsed = parseIcalendarEventCalendar(output).series.single;
      expect(utf8.decode(output), contains('BEGIN:VTIMEZONE'));
      expect(parsed.master.timedSpan!.start.zoneId, 'America/New_York');
      expect(parsed.master.timedSpan!.duration!.days, 1);
      expect(parsed.overrides.single.isThisAndFuture, isTrue);
      expect(parsed.overrides.single.timedSpan!.start.civil.hour, 14);
    },
  );
  test(
    'rejects cancellation-only restoration state without invented timing',
    () {
      final p = eventStorageProposal(
        load([
          event(extra: ['RRULE:FREQ=DAILY;COUNT=2']),
        ]).series.single,
      );
      final s = snapshot(p),
          edits = CalendarEventTimingOverrides(
            singles: [
              CalendarEventSingleOverride(
                originalStart: CalendarEventTiming(
                  kind: CalendarEventTimeKind.utc,
                  start: CalendarEventCivil(
                    year: 2026,
                    month: 10,
                    day: 23,
                    hour: 12,
                  ),
                ),
                cancelled: true,
              ),
            ],
            future: [],
          );
      final state = eventProtocolBaseline(
        p.content,
        edits,
        DateTime.utc(2026),
        DateTime.utc(2026),
      );
      final changed = CalendarEventPolicySnapshot(
        s.eventId,
        s.calendarId,
        1,
        s.content,
        s.protocolUid,
        s.updatedAt,
        timingOverrides: edits,
        protocolState: state,
      );
      expect(() => eventExportBytes([changed]), throwsArgumentError);
    },
  );
  test(
    'rejects status projection that would change independent cancellation',
    () {
      final p = eventStorageProposal(
        load([
          event(extra: ['STATUS:CONFIRMED', 'RRULE:FREQ=DAILY;COUNT=2']),
          event(
            timing: 'DTSTART:20261023T150000Z',
            extra: ['RECURRENCE-ID:20261023T120000Z', 'STATUS:CONFIRMED'],
          ),
        ]).series.single,
      );
      final changed = p.content.copyWith(status: CalendarEventStatus.cancelled);
      final state = advanceEventProtocol(
        p.protocolState,
        p.content,
        p.edits,
        changed,
        p.edits,
        DateTime.utc(2026),
      );
      final old = snapshot(p);
      expect(
        () => eventExportBytes([
          CalendarEventPolicySnapshot(
            old.eventId,
            old.calendarId,
            2,
            changed,
            old.protocolUid,
            old.updatedAt,
            timingOverrides: p.edits,
            protocolState: state,
          ),
        ]),
        throwsArgumentError,
      );
    },
  );
  test('raw budget includes occurrence components across selected series', () {
    String stamp(int day) {
      final d = DateTime.utc(2026, 1, 1).add(Duration(days: day));
      return '2026${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T120000Z';
    }

    final selected = [
      for (final uid in ['a', 'b'])
        snapshot(
          eventStorageProposal(
            load([
              event(
                uid: uid,
                timing: 'DTSTART:${stamp(0)}',
                extra: ['RRULE:FREQ=DAILY;COUNT=65'],
              ),
              for (var i = 1; i <= 64; i++)
                event(
                  uid: uid,
                  timing: 'DTSTART:${stamp(i)}',
                  extra: ['RECURRENCE-ID:${stamp(i)}'],
                ),
            ]).series.single,
          ),
        ),
    ];
    expect(
      () => eventExportBytes(selected),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    'rejects incomplete checkpoints duplicate UID and raw component excess',
    () {
      final p = eventStorageProposal(load([event()]).series.single),
          s = snapshot(p);
      expect(() => eventExportBytes([]), throwsArgumentError);
      expect(() => eventExportBytes([s, s]), throwsArgumentError);
      expect(
        () => eventExportBytes([
          CalendarEventPolicySnapshot(
            s.eventId,
            s.calendarId,
            1,
            s.content,
            s.protocolUid,
            s.updatedAt,
          ),
        ]),
        throwsArgumentError,
      );
      expect(() => eventExportBytes(List.filled(129, s)), throwsArgumentError);
    },
  );
}
