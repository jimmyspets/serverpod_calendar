@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';

import 'invitation_occurrence_values_test.dart' show basis, calendar, snapshot;
import 'invitation_range_cancellation_values_test.dart' show point, versions;

IcalendarSchedulingMessage request({
  bool date = false,
  String? zone,
  String? original,
  String? start,
  List<String>? ending,
  int? sequence = 9,
  String summary = 'Master',
  List<String> extra = const [],
}) => parseIcalendarSchedulingMessage(
  utf8.encode(
    calendar(
      [
        date
            ? 'RECURRENCE-ID;VALUE=DATE;RANGE=THISANDFUTURE:${original ?? '20300102'}'
            : 'RECURRENCE-ID;RANGE=THISANDFUTURE${zone == null ? '' : ';TZID=$zone'}:${original ?? (zone == null ? '20300102T090000Z' : '20300102T090000')}',
        start ??
            (date
                ? 'DTSTART;VALUE=DATE:20300102'
                : zone == null
                ? 'DTSTART:20300102T090000Z'
                : 'DTSTART;TZID=$zone:20300102T090000'),
        ...ending ?? (date ? <String>[] : ['DURATION:PT1H']),
        if (sequence != null) 'SEQUENCE:$sequence',
        'SUMMARY:${encodeIcalendarText(summary)}',
        ...extra,
      ],
      method: 'REQUEST',
      zone: zone,
    ),
  ),
);

IcalendarSchedulingMessage changed(
  IcalendarSchedulingMessage m,
  String a,
  String b,
) => parseIcalendarSchedulingMessage(
  utf8.encode(
    utf8.decode(serializeIcalendarSchedulingMessage(m)).replaceFirst(a, b),
  ),
);

CalendarInvitationRangeRestorationProjection restore(
  EventStorageProposal b,
  IcalendarSchedulingMessage m, {
  CalendarEventTimingOverrides? edits,
  CalendarEventProtocolState? state,
  CalendarEventContent? content,
  CalendarEventProtocolVersion? cancellation,
  String? uid,
  String recipient = 'mailto:alice@example.invalid',
  int work = eventMaxCandidateWork,
}) => projectInvitationRangeRestoration(
  protocolUid: uid ?? b.protocolUid,
  content: content ?? b.content,
  timingOverrides:
      edits ??
      CalendarEventTimingOverrides(
        singles: [],
        future: [],
        cancelledFrom: CalendarEventTiming(
          kind: b.content.timing.kind,
          zoneId: b.content.timing.zoneId,
          start: b.content.timing.start.copyWith(day: 2),
        ),
      ),
  protocolState: state ?? b.protocolState,
  cancellationVersion:
      cancellation ??
      CalendarEventProtocolVersion(
        sequence: 8,
        stamp: DateTime.utc(2026),
      ),
  message: m,
  recipientAddress: recipient,
  maxCandidateWork: work,
);

void main() {
  for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
    final date = profile == 'date',
        zone = profile == 'Europe/Stockholm' ? profile : null;
    test(
      '$profile clears only cutoff and retains source/native distinctions',
      () {
        final b = basis(date: date, zone: zone), before = snapshot(b);
        final m = request(
          date: date,
          zone: zone,
          extra: [
            'CREATED:20200101T000000Z',
            'LAST-MODIFIED:20210101T000000Z',
          ],
        );
        final r = restore(b, m);
        expect(r.timingOverrides, isNull);
        expect(r.content.toJson(), b.content.toJson());
        expect(r.protocolState.toJson(), b.protocolState.toJson());
        expect(r.requiredAfterSequence, 8);
        expect(r.cancellationVersion.sequence, 8);
        expect(r.restorationVersion.sequence, 9);
        expect(r.restorationVersion.created, DateTime.utc(2020));
        expect(r.restorationVersion.lastModified, DateTime.utc(2021));
        expect(identical(r.sourceMessage, m), isTrue);
        expect(m.events.single.status, isNull);
        expect(snapshot(b), before);
        expect(() => r.protocolState.overrides.clear(), throwsUnsupportedError);
      },
    );
    test('$profile explicit end remains explicit, alternate form rejects', () {
      final b0 = basis(date: date, zone: zone);
      final end = b0.content.timing.start.copyWith(
        day: date ? 2 : 1,
        hour: date ? 0 : 10,
      );
      final b = b0.content.copyWith(
        timing: b0.content.timing.copyWith(duration: null, end: end),
      );
      final endLine = date
          ? 'DTEND;VALUE=DATE:20300103'
          : zone == null
          ? 'DTEND:20300102T100000Z'
          : 'DTEND;TZID=$zone:20300102T100000';
      expect(
        restore(
          b0,
          request(date: date, zone: zone, ending: [endLine]),
          content: b,
        ).timingOverrides,
        isNull,
      );
      expect(
        () => restore(
          b0,
          request(
            date: date,
            zone: zone,
            ending: ['DURATION:${date ? 'P1D' : 'PT1H'}'],
          ),
          content: b,
        ),
        throwsArgumentError,
      );
      expect(
        () => restore(
          b0,
          request(date: date, zone: zone, ending: []),
          content: b,
        ),
        throwsArgumentError,
      );
    });
    test('$profile other original and changed start reject', () {
      final b = basis(date: date, zone: zone);
      final m = request(date: date, zone: zone);
      expect(
        () => restore(
          b,
          changed(
            m,
            date
                ? ':20300102\r\n'
                : ':20300102T090000${zone == null ? 'Z' : ''}\r\n',
            date
                ? ':20300103\r\n'
                : ':20300103T090000${zone == null ? 'Z' : ''}\r\n',
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => restore(
          b,
          request(
            date: date,
            zone: zone,
            start: date
                ? 'DTSTART;VALUE=DATE:20300103'
                : zone == null
                ? 'DTSTART:20300102T100000Z'
                : 'DTSTART;TZID=$zone:20300102T100000',
          ),
        ),
        throwsArgumentError,
      );
    });
  }
  test(
    'anchor single, surrounding range and individual cancellations all survive',
    () {
      final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=8');
      final edits = CalendarEventTimingOverrides(
        cancelledFrom: point(2),
        singles: [
          CalendarEventSingleOverride(
            originalStart: point(2),
            replacement: point(
              2,
              hour: 11,
            ).copyWith(duration: CalendarEventDuration(hours: 2)),
            cancelled: true,
            contentOverrides: CalendarEventOccurrenceContent(summary: 'Own'),
          ),
          CalendarEventSingleOverride(originalStart: point(4), cancelled: true),
        ],
        future: [
          CalendarEventFutureOverride(
            originalStart: point(1),
            replacement: point(
              1,
              hour: 10,
            ).copyWith(duration: CalendarEventDuration(hours: 1)),
          ),
        ],
      );
      final state = versions(b, edits, own: {'S:2': 3, 'S:4': 4, 'R:1': 6});
      final before = jsonEncode(edits.toJson());
      final r = restore(
        b,
        request(
          start: 'DTSTART:20300102T110000Z',
          ending: ['DURATION:PT2H'],
          summary: 'Own',
        ),
        edits: edits,
        state: state,
      );
      expect(r.timingOverrides!.cancelledFrom, isNull);
      expect(
        r.timingOverrides!.singles.map((v) => v.cancelled),
        everyElement(isTrue),
      );
      expect(
        r.timingOverrides!.singles.map((v) => v.toJson()),
        edits.singles.map((v) => v.toJson()),
      );
      expect(
        r.timingOverrides!.future.single.toJson(),
        edits.future.single.toJson(),
      );
      expect(r.protocolState.toJson(), state.toJson());
      expect(jsonEncode(edits.toJson()), before);
      expect(() => r.timingOverrides!.singles.clear(), throwsUnsupportedError);
      expect(() => r.timingOverrides!.future.clear(), throwsUnsupportedError);
    },
  );
  for (final type in [
    'master',
    'underlying range',
    'later single',
    'later range',
  ]) {
    test('$type floor is checked independently of cancellation version', () {
      final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=8');
      final edits = CalendarEventTimingOverrides(
        cancelledFrom: point(2),
        singles: [
          CalendarEventSingleOverride(
            originalStart: point(type == 'later single' ? 4 : 2),
            cancelled: true,
          ),
        ],
        future: [
          if (type.contains('range'))
            CalendarEventFutureOverride(
              originalStart: point(type == 'later range' ? 3 : 1),
              replacement: point(type == 'later range' ? 3 : 1)
                  .copyWith(duration: CalendarEventDuration(hours: 1)),
            ),
        ],
      );
      final state = versions(
        b,
        edits,
        master: type == 'master' ? 20 : 2,
        own: {'S:2': 1, 'S:4': 20, 'R:1': 20, 'R:3': 20},
      );
      expect(
        () => restore(b, request(sequence: 20), edits: edits, state: state),
        throwsArgumentError,
      );
      expect(
        restore(
          b,
          request(sequence: 21),
          edits: edits,
          state: state,
        ).requiredAfterSequence,
        20,
      );
    });
  }
  for (final seq in [null, 0, 7, 8]) {
    test(
      'missing/equal/lower restoration sequence $seq rejects despite later stamp',
      () {
        final m = changed(
          request(sequence: seq),
          'DTSTAMP:20260101T000000Z',
          'DTSTAMP:20350101T000000Z',
        );
        expect(() => restore(basis(), m), throwsArgumentError);
      },
    );
  }
  test(
    'omitted native sequence stays absent; source dates can go backwards',
    () {
      final b = basis();
      final m = changed(
        request(),
        'DTSTAMP:20260101T000000Z',
        'DTSTAMP:20200101T000000Z',
      );
      final r = restore(
        b,
        m,
        state: b.protocolState.copyWith(
          version: b.protocolState.version.copyWith(sequence: null),
        ),
      );
      expect(r.protocolState.version.sequence, isNull);
      expect(r.restorationVersion.stamp, DateTime.utc(2020));
      expect(r.restorationVersion.created, isNull);
      expect(r.restorationVersion.lastModified, isNull);
    },
  );
  for (final seq in [null, -1, eventMaxSequence, eventMaxSequence + 1]) {
    test('missing/invalid/exhausted cancellation version $seq rejects', () {
      expect(
        () => restore(
          basis(),
          request(),
          cancellation: CalendarEventProtocolVersion(
            sequence: seq,
            stamp: DateTime.utc(2026),
          ),
        ),
        throwsArgumentError,
      );
    });
  }
  test('fractional cancellation source timestamps reject without rounding', () {
    expect(
      () => restore(
        basis(),
        request(),
        cancellation: CalendarEventProtocolVersion(
          sequence: 8,
          stamp: DateTime.utc(2026, 1, 1, 0, 0, 0, 1),
        ),
      ),
      throwsArgumentError,
    );
  });
  test('maximum restoration sequence is retained without overflow', () {
    expect(
      restore(
        basis(),
        request(sequence: eventMaxSequence),
      ).restorationVersion.sequence,
      eventMaxSequence,
    );
  });
  for (final line in [
    'DESCRIPTION:Different',
    'DESCRIPTION;LANGUAGE=en:Beskrivning',
    'LOCATION:Elsewhere',
    'TRANSP:TRANSPARENT',
    'STATUS:TENTATIVE',
    'CLASS:PRIVATE',
    'URL:https://example.invalid',
    'CATEGORIES:Hidden',
    'PRIORITY:1',
  ]) {
    test('different supplied property rejects: $line', () {
      expect(
        () => restore(basis(), request(extra: [line])),
        throwsArgumentError,
      );
    });
  }
  test('matching annotations and explicit confirmed are accepted without applying defaults', () {
    final r = restore(
      basis(),
      request(
        extra: [
          'DESCRIPTION;LANGUAGE=sv:Beskrivning',
          'LOCATION:Room',
          'STATUS:CONFIRMED',
          'TRANSP:OPAQUE',
        ],
      ),
    );
    expect(r.protocolState.version.sequence, 7);
  });
  test('tentative status comparison uses meaning rather than enum ordinal', () {
    final b = basis(extra: ['STATUS:TENTATIVE']);
    expect(
      restore(b, request(extra: ['STATUS:TENTATIVE'])).content.status,
      CalendarEventStatus.tentative,
    );
    expect(
      () => restore(b, request(extra: ['STATUS:CONFIRMED'])),
      throwsArgumentError,
    );
  });
  for (final line in ['DURATION:PT60M', 'DTEND:20300102T100000Z']) {
    test('equal elapsed span cannot change retained form/units: $line', () {
      expect(
        () => restore(basis(), request(ending: [line])),
        throwsArgumentError,
      );
    });
  }
  test('omitted timing end cannot replace retained positive duration', () {
    expect(() => restore(basis(), request(ending: [])), throwsArgumentError);
  });
  test('native cutoff is required and inactive masters reject', () {
    final b = basis();
    expect(
      () => restore(
        b,
        request(),
        edits: CalendarEventTimingOverrides(singles: [], future: []),
      ),
      throwsArgumentError,
    );
    expect(
      () => restore(
        b,
        request(),
        content: b.content.copyWith(status: CalendarEventStatus.cancelled),
        state: b.protocolState.copyWith(statusPresent: true),
      ),
      throwsArgumentError,
    );
  });
  test(
    'exact zone key and civil profile are required even for equal instants',
    () {
      final b = basis(zone: 'Europe/Stockholm');
      expect(
        () => restore(
          b,
          request(
            original: '20300102T080000Z',
            start: 'DTSTART:20300102T080000Z',
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => restore(b, request(zone: 'Europe/Paris')),
        throwsArgumentError,
      );
    },
  );
  test('inert claims must match retained organizer and recipient', () {
    for (final pair in [
      ('mailto:organizer@example.invalid', 'mailto:other@example.invalid'),
      ('ATTENDEE:mailto:alice@example.invalid\r\n', ''),
      ('ORGANIZER:', 'ORGANIZER;SENT-BY="mailto:other@example.invalid":'),
      ('ATTENDEE:', 'ATTENDEE;SENT-BY="mailto:other@example.invalid":'),
    ]) {
      expect(
        () => restore(basis(), changed(request(), pair.$1, pair.$2)),
        throwsArgumentError,
      );
    }
    expect(
      () => restore(
        basis(),
        request(),
        recipient: 'mailto:other@example.invalid',
      ),
      throwsArgumentError,
    );
    expect(
      () => restore(basis(), request(), uid: 'other@example.invalid'),
      throwsArgumentError,
    );
  });
  test('exhausted shared work does not prove restoration membership/floor', () {
    expect(
      () => restore(basis(), request(), work: 1),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(() => restore(basis(), request(), work: 0), throwsArgumentError);
  });
  test(
    'anchor future remains an unchanged future, never a new replacement',
    () {
      final b = basis();
      final edits = CalendarEventTimingOverrides(
        cancelledFrom: point(2),
        singles: [],
        future: [
          CalendarEventFutureOverride(
            originalStart: point(2),
            replacement: point(
              2,
              hour: 11,
            ).copyWith(duration: CalendarEventDuration(hours: 2)),
            contentOverrides: CalendarEventOccurrenceContent(
              summary: 'Range anchor',
            ),
          ),
        ],
      );
      final state = versions(b, edits, own: {'R:2': 6});
      final r = restore(
        b,
        request(
          start: 'DTSTART:20300102T110000Z',
          ending: ['DURATION:PT2H'],
          summary: 'Range anchor',
        ),
        edits: edits,
        state: state,
      );
      expect(
        r.timingOverrides!.future.single.toJson(),
        edits.future.single.toJson(),
      );
      expect(r.protocolState.toJson(), state.toJson());
      expect(
        () => restore(b, request(), edits: edits, state: state),
        throwsArgumentError,
      );
    },
  );
  test('DATE duration retains nominal weeks instead of equivalent days', () {
    final b = basis(date: true);
    final content = b.content.copyWith(
      timing: b.content.timing.copyWith(
        duration: CalendarEventDuration(weeks: 1),
      ),
    );
    expect(
      restore(
        b,
        request(date: true, ending: ['DURATION:P1W']),
        content: content,
      ).content.timing.duration!.weeks,
      1,
    );
    expect(
      () => restore(
        b,
        request(date: true, ending: ['DURATION:P7D']),
        content: content,
      ),
      throwsArgumentError,
    );
  });
  for (final (date, extra, original, start, ending) in [
    (
      true,
      'RDATE;VALUE=DATE:20291230',
      '20291230',
      'DTSTART;VALUE=DATE:20291230',
      <String>[],
    ),
    (
      false,
      'RDATE;VALUE=PERIOD:20291230T090000Z/PT2H',
      '20291230T090000Z',
      'DTSTART:20291230T090000Z',
      ['DURATION:PT2H'],
    ),
  ]) {
    test(
      'earlier ${date ? 'DATE inclusion' : 'PERIOD'} restores exact original',
      () {
        final b = basis(date: date, extra: [extra]);
        final anchor = CalendarEventTiming(
          kind: b.content.timing.kind,
          start: CalendarEventCivil(
            year: 2029,
            month: 12,
            day: 30,
            hour: date ? 0 : 9,
          ),
        );
        final r = restore(
          b,
          request(date: date, original: original, start: start, ending: ending),
          edits: CalendarEventTimingOverrides(
            singles: [],
            future: [],
            cancelledFrom: anchor,
          ),
        );
        expect(r.originalStart.toJson(), anchor.toJson());
        expect(r.content.toJson(), b.content.toJson());
      },
    );
  }
  for (final (month, day, hours) in [(3, 30, 23), (10, 26, 25)]) {
    test('nominal day across DST remains a $hours-hour interval', () {
      const zone = 'Europe/Stockholm';
      final text =
          '2030${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}T090000';
      final b = basis(zone: zone, start: 'DTSTART;TZID=$zone:$text');
      final content = b.content.copyWith(
        timing: b.content.timing.copyWith(
          duration: CalendarEventDuration(days: 1),
        ),
      );
      final anchor = CalendarEventTiming(
        kind: CalendarEventTimeKind.zoned,
        zoneId: zone,
        start: content.timing.start,
      );
      final r = restore(
        b,
        request(
          zone: zone,
          original: text,
          start: 'DTSTART;TZID=$zone:$text',
          ending: ['DURATION:P1D'],
        ),
        content: content,
        edits: CalendarEventTimingOverrides(
          singles: [],
          future: [],
          cancelledFrom: anchor,
        ),
      );
      final span = validateEventTiming(r.content.timing).$2!;
      expect(span.start.instant.difference(span.endExclusive).inHours, -hours);
      expect(
        () => restore(
          b,
          request(
            zone: zone,
            original: text,
            start: 'DTSTART;TZID=$zone:$text',
            ending: ['DURATION:PT${hours}H'],
          ),
          content: content,
          edits: CalendarEventTimingOverrides(
            singles: [],
            future: [],
            cancelledFrom: anchor,
          ),
        ),
        throwsArgumentError,
      );
    });
  }
  for (final text in ['20300331T023000', '20301027T023000']) {
    test('explicit gap/fold inclusion retains wall fields: $text', () {
      const zone = 'Europe/Stockholm';
      final start = text.substring(0, 8) == '20300331'
          ? '20300330T023000'
          : '20301026T023000';
      final b = basis(
        zone: zone,
        start: 'DTSTART;TZID=$zone:$start',
        extra: ['RDATE;TZID=$zone:$text'],
      );
      final c = parseIcalendarDateTime(text, zoneId: zone);
      final anchor = CalendarEventTiming(
        kind: CalendarEventTimeKind.zoned,
        zoneId: zone,
        start: eventCivil(c.civil),
      );
      final r = restore(
        b,
        request(zone: zone, original: text, start: 'DTSTART;TZID=$zone:$text'),
        edits: CalendarEventTimingOverrides(
          singles: [],
          future: [],
          cancelledFrom: anchor,
        ),
      );
      expect(r.originalStart.toJson(), anchor.toJson());
    });
  }
  test(
    'excluded, orphaned and duplicate single/future anchors remain invalid',
    () {
      final excluded = basis(extra: ['EXDATE:20300102T090000Z']);
      expect(() => restore(excluded, request()), throwsArgumentError);
      expect(
        () => restore(
          basis(),
          request(original: '20300109T090000Z'),
          edits: CalendarEventTimingOverrides(
            singles: [],
            future: [],
            cancelledFrom: point(9),
          ),
        ),
        throwsArgumentError,
      );
      final b = basis();
      final edits = CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(originalStart: point(2), cancelled: true),
        ],
        future: [
          CalendarEventFutureOverride(
            originalStart: point(2),
            replacement: point(2)
                .copyWith(duration: CalendarEventDuration(hours: 1)),
          ),
        ],
        cancelledFrom: point(2),
      );
      expect(() => restore(b, request(), edits: edits), throwsArgumentError);
    },
  );
  test('unarmed source alarms survive but incoming alarms still reject', () {
    const alarm = [
      'BEGIN:VALARM',
      'ACTION:DISPLAY',
      'TRIGGER:-PT15M',
      'DESCRIPTION:Reminder',
      'END:VALARM',
    ];
    final b = basis(extra: alarm);
    final r = restore(b, request());
    expect(r.protocolState.toJson(), b.protocolState.toJson());
    expect(r.protocolState.sourceMetadata!.alarms!.length, 1);
    expect(
      () => restore(b, request(extra: alarm)),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
  test('sanitized diagnostics never echo private identity', () {
    try {
      restore(basis(), request(), uid: 'PRIVATE-RESTORATION-UID');
      fail('Expected rejection');
    } on ArgumentError catch (e) {
      expect(e.toString(), isNot(contains('PRIVATE-RESTORATION-UID')));
    }
  });
  test('raw source ceilings still apply to an already parsed message', () {
    final dates = List.filled(5000, '19800101T000000').join(',');
    final m = request(zone: 'Etc/UTC');
    final text = utf8
        .decode(serializeIcalendarSchedulingMessage(m))
        .replaceFirst('END:STANDARD', 'RDATE:$dates\r\nEND:STANDARD');
    final large = parseIcalendarSchedulingMessage(
      utf8.encode(text),
      syntaxLimits: const IcalendarSyntaxLimits(
        maxPhysicalLineBytes: 200000,
        maxUnfoldedLineBytes: 200000,
      ),
    );
    expect(
      () => restore(basis(zone: 'Etc/UTC'), large),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    '127 native exceptions survive without imposing the smaller wire cap',
    () {
      final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=130');
      final singles = [
        for (var i = 0; i < 127; i++)
          CalendarEventSingleOverride(
            originalStart: CalendarEventTiming(
              kind: CalendarEventTimeKind.utc,
              start: eventCivil(
                CivilDateTime(
                  date: CalendarDate(year: 2030, month: 1, day: 1).addDays(i),
                  hour: 9,
                  minute: 0,
                ),
              ),
            ),
            cancelled: true,
          ),
      ];
      final edits = CalendarEventTimingOverrides(
        singles: singles,
        future: [],
        cancelledFrom: point(2),
      );
      final state = versions(b, edits);
      final r = restore(b, request(), edits: edits, state: state);
      expect(r.timingOverrides!.singles.length, 127);
      expect(r.timingOverrides!.singles.every((v) => v.cancelled), isTrue);
      singles.clear();
      state.overrides.clear();
      expect(r.timingOverrides!.singles.length, 127);
      expect(r.protocolState.overrides.length, 127);
    },
  );
  for (final date in [true, false]) {
    test(
      '${date ? 'DATE' : 'UTC'} exclusive 2100 endpoint stays an end only',
      () {
        final b = basis(
          date: date,
          start: date
              ? 'DTSTART;VALUE=DATE:20991230'
              : 'DTSTART:20991230T090000Z',
          rule: 'RRULE:FREQ=DAILY;COUNT=2',
        );
        final anchor = CalendarEventTiming(
          kind: b.content.timing.kind,
          start: b.content.timing.start.copyWith(day: 31),
        );
        final content = b.content.copyWith(
          timing: b.content.timing.copyWith(
            duration: null,
            end: CalendarEventCivil(year: 2099, month: 12, day: 31),
          ),
        );
        final m = request(
          date: date,
          original: date ? '20991231' : '20991231T090000Z',
          start: date
              ? 'DTSTART;VALUE=DATE:20991231'
              : 'DTSTART:20991231T090000Z',
          ending: [
            date ? 'DTEND;VALUE=DATE:21000101' : 'DTEND:21000101T000000Z',
          ],
        );
        final r = restore(
          b,
          m,
          content: content,
          edits: CalendarEventTimingOverrides(
            singles: [],
            future: [],
            cancelledFrom: anchor,
          ),
        );
        expect(r.originalStart.start.year, 2099);
        expect(r.content.timing.toJson(), content.timing.toJson());
      },
    );
  }
  test('1970 first ordinary day remains a valid original', () {
    final b = basis(date: true, start: 'DTSTART;VALUE=DATE:19700101');
    final anchor = b.content.timing;
    final r = restore(
      b,
      request(
        date: true,
        original: '19700101',
        start: 'DTSTART;VALUE=DATE:19700101',
      ),
      edits: CalendarEventTimingOverrides(
        singles: [],
        future: [],
        cancelledFrom: anchor,
      ),
    );
    expect(r.originalStart.start.year, 1970);
  });
}
