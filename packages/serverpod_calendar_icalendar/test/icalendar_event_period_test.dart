import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart';

Matcher rejects(IcalendarComponentError kind) => throwsA(
  isA<IcalendarComponentException>().having((e) => e.kind, 'kind', kind),
);
IcalendarEventCalendar periods(
  List<String> properties, {
  String start = 'DTSTART:20261022T120000Z',
  List<String> zones = const [],
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => load(
  file(
    events: [event(timing: start, extra: properties)],
    zones: zones,
  ),
  limits: limits,
);
List<TimedEventOccurrence> occurrences(
  IcalendarEventCalendar calendar,
  DateTime from,
  DateTime end,
) {
  final e = calendar.events.single;
  return TimedEventSeries(
    recurrence: e.recurrence!.timedSet!,
    span: e.timedSpan!,
    maxChanges: 0,
    maxValidationCandidateWork: 200000,
    maxValidationOccurrences: 10000,
  ).expandOverlapping(
    window: UtcWindow(start: from, end: end),
    maxCandidateWork: 200000,
    maxRuleOccurrences: 10000,
    maxBaseOccurrences: 10000,
    maxResults: 500,
  );
}

void main() {
  test('RFC UTC end/duration forms and repeated source round trip', () {
    final c = periods([
      'rdate;value=period:19960403T020000Z/19960403T040000Z,19960404T010000Z/PT3H',
      'RDATE;VALUE=PERIOD:19960405T010000Z/+PT1H',
    ]);
    final spans = c.events.single.recurrence!.timedSet!.periods.values.toList();
    expect(spans.length, 3);
    expect(spans[0].end!.instant, DateTime.utc(1996, 4, 3, 4));
    expect(spans[0].duration, isNull);
    expect(spans[1].end, isNull);
    expect(spans[1].duration, CalendarDuration(hours: 3));
    final bytes = serializeIcalendarEventCalendar(c);
    final output = utf8.decode(bytes).replaceAll('\r\n ', '');
    expect(output, contains('rdate;value=period:19960403T020000Z/'));
    expect(output, contains('19960405T010000Z/+PT1H'));
    final copy = parseIcalendarEventCalendar(bytes);
    expect(
      copy.events.single.recurrence!.timedSet!.periods,
      equals(c.events.single.recurrence!.timedSet!.periods),
    );
    expect(serializeIcalendarEventCalendar(copy), bytes);
    expect(
      () => c.events.single.recurrence!.timedSet!.periods.clear(),
      throwsUnsupportedError,
    );
  });

  test(
    'earlier additions, period precedence and EXDATE preserve rule COUNT',
    () {
      final c = periods([
        'DURATION:PT1H',
        'RRULE:FREQ=DAILY;COUNT=2',
        'RDATE:20261023T120000Z,20261024T120000Z',
        'RDATE;VALUE=PERIOD:20261021T120000Z/PT2H,20261023T120000Z/PT4H,20261024T120000Z/PT8H',
        'EXDATE:20261022T120000Z,20261024T120000Z',
      ]);
      final found = occurrences(
        c,
        DateTime.utc(2026, 10, 20),
        DateTime.utc(2026, 10, 26),
      );
      expect(found.map((e) => e.originalStart.instant), [
        DateTime.utc(2026, 10, 21, 12),
        DateTime.utc(2026, 10, 23, 12),
      ]);
      expect(found.map((e) => e.span.endExclusive), [
        DateTime.utc(2026, 10, 21, 14),
        DateTime.utc(2026, 10, 23, 16),
      ]);
      expect(c.events.single.recurrence!.timedSet!.rule!.count, 2);
      expect(c.events.single.timedSpan!.duration, CalendarDuration(hours: 1));
    },
  );

  test(
    'a period at DTSTART replaces its point span without adding identity',
    () {
      final c = periods(['RDATE;VALUE=PERIOD:20261022T120000Z/PT2H']);
      final found = occurrences(
        c,
        DateTime.utc(2026, 10, 22),
        DateTime.utc(2026, 10, 23),
      );
      expect(found.length, 1);
      expect(found.single.span.endExclusive, DateTime.utc(2026, 10, 22, 14));
    },
  );

  test('overlapping query includes an earlier long period', () {
    final c = periods(['RDATE;VALUE=PERIOD:20261020T120000Z/P3D']);
    final found = occurrences(
      c,
      DateTime.utc(2026, 10, 21),
      DateTime.utc(2026, 10, 22),
    );
    expect(found.single.originalStart.instant, DateTime.utc(2026, 10, 20, 12));
    expect(found.single.span.endExclusive, DateTime.utc(2026, 10, 23, 12));
  });

  test('duplicate identical forms coalesce while retaining raw syntax', () {
    final c = periods([
      'RDATE;VALUE=PERIOD:20261023T120000Z/PT1H,20261023T120000Z/PT1H',
      'RDATE;VALUE=PERIOD:20261023T120000Z/+PT1H',
    ]);
    expect(c.events.single.recurrence!.timedSet!.periods.length, 1);
    expect(utf8.decode(serializeIcalendarEventCalendar(c)), contains('/+PT1H'));
  });

  test('conflicting spans/forms reject even when excluded', () {
    for (final pair in [
      '20261023T120000Z/PT1H,20261023T120000Z/PT2H',
      '20261023T120000Z/PT1H,20261023T120000Z/20261023T130000Z',
      '20261023T120000Z/P1D,20261023T120000Z/PT24H',
    ]) {
      expect(
        () => periods(['RDATE;VALUE=PERIOD:$pair', 'EXDATE:20261023T120000Z']),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
  });

  test('named-zone duration keeps nominal days across DST', () {
    final zone = newYorkZone();
    IcalendarEventCalendar nominal(String duration) => periods(
      ['RDATE;VALUE=PERIOD;TZID=America/New_York:20260307T120000/$duration'],
      start: 'DTSTART;TZID=America/New_York:20260301T120000',
      zones: [zone],
    );
    final day = nominal('P1D')
        .events
        .single
        .recurrence!
        .timedSet!
        .periods
        .values
        .single;
    final hours = nominal('PT24H')
        .events
        .single
        .recurrence!
        .timedSet!
        .periods
        .values
        .single;
    expect(day.endExclusive, DateTime.utc(2026, 3, 8, 16));
    expect(hours.endExclusive, DateTime.utc(2026, 3, 8, 17));
    expect(day.duration!.days, 1);
    expect(hours.duration!.hours, 24);
  });

  test(
    'explicit gap/fold endpoints use RFC resolution and positive instants',
    () {
      final c = periods(
        [
          'RDATE;VALUE=PERIOD;TZID=America/New_York:20260308T023000/PT1H,20261101T013000/20261101T023000',
        ],
        start: 'DTSTART;TZID=America/New_York:20260301T120000',
        zones: [newYorkZone()],
      );
      final spans = c.events.single.recurrence!.timedSet!.periods.values
          .toList();
      expect(spans[0].start.instant, DateTime.utc(2026, 3, 8, 7, 30));
      expect(spans[0].endExclusive, DateTime.utc(2026, 3, 8, 8, 30));
      expect(spans[1].start.instant, DateTime.utc(2026, 11, 1, 5, 30));
      expect(spans[1].endExclusive, DateTime.utc(2026, 11, 1, 7, 30));
      expect(
        () => periods(
          [
            'RDATE;VALUE=PERIOD;TZID=America/New_York:20260308T023000/20260308T030000',
          ],
          start: 'DTSTART;TZID=America/New_York:20260301T120000',
          zones: [newYorkZone()],
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );

  test('exact UTC/named/alias profiles cannot be mixed or inherited', () {
    final utcZone = fixedZone();
    final aliasZone = fixedZone(id: 'Etc/UTC');
    for (final line in [
      'RDATE;VALUE=PERIOD:20261023T120000Z/PT1H',
      'RDATE;VALUE=PERIOD:20261023T120000/PT1H',
      'RDATE;VALUE=PERIOD;TZID=Etc/UTC:20261023T120000/PT1H',
      'RDATE;VALUE=PERIOD;TZID=UTC:20261023T120000Z/PT1H',
      'RDATE;VALUE=PERIOD;TZID=UTC:20261023T120000/20261023T130000Z',
    ]) {
      expect(
        () => periods(
          [line],
          start: 'DTSTART;TZID=UTC:20261022T120000',
          zones: [utcZone, aliasZone],
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
    expect(
      () => periods(
        ['RDATE;VALUE=PERIOD;TZID=UTC:20261023T120000/PT1H'],
        zones: [utcZone],
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
  });

  test('exclusive 2100 endpoint is allowed but never an ordinary start', () {
    for (final end in ['21000101T000000Z', 'PT1S']) {
      final span = periods(['RDATE;VALUE=PERIOD:20991231T235959Z/$end'])
          .events
          .single
          .recurrence!
          .timedSet!
          .periods
          .values
          .single;
      expect(span.endExclusive, DateTime.utc(2100));
    }
    final named = periods(
      ['RDATE;VALUE=PERIOD;TZID=UTC:20991231T235959/21000101T000000'],
      start: 'DTSTART;TZID=UTC:20261022T120000',
      zones: [fixedZone()],
    );
    expect(
      named
          .events
          .single
          .recurrence!
          .timedSet!
          .periods
          .values
          .single
          .end!
          .civil
          .date
          .isExclusiveEnd,
      isTrue,
    );
    for (final raw in [
      '21000101T000000Z/PT1S',
      '20991231T235959Z/PT2S',
      '20991231T235959Z/21000101T000001Z',
      '19691231T235959Z/PT2S',
    ]) {
      expect(
        () => periods(['RDATE;VALUE=PERIOD:$raw']),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
    expect(
      periods(['RDATE;VALUE=PERIOD:19700101T000000Z/PT1S'])
          .events
          .single
          .recurrence!
          .timedSet!
          .periods
          .length,
      1,
    );
  });

  test('strict PERIOD grammar, positive length and whole seconds', () {
    for (final raw in [
      '',
      '/PT1H',
      '20261023T120000Z/',
      '20261023T120000Z/PT1H/PT2H',
      '20261023T120000Z',
      '20261023/PT1H',
      '20261023T120000Z/20261023T120000Z',
      '20261023T120000Z/20261023T110000Z',
      '20261023T120000Z/P0D',
      '20261023T120000Z/-PT1H',
      '20261023T120000Z/P1DT0.000S',
      '20261023T120000.000Z/PT1H',
      '20261023T120000Z/20261023T130000.000Z',
      '20261023T120060Z/PT1H',
      '20261023T120000Z/20261023T130060Z',
      '20261023T120000Z/pt1h',
      '20261023T120000Z/PT1H,',
      '20261023T120000Z/PT1H\\,20261024T120000Z/PT1H',
      '20261023T120000Z/ PT1H',
      '20261023T120000Z/PT999999999999999999999999999999999999H',
    ]) {
      expect(
        () => periods(['RDATE;VALUE=PERIOD:$raw']),
        rejects(IcalendarComponentError.invalidValue),
        reason: raw,
      );
    }
  });

  test('PERIOD context and parameters reject without implicit coercion', () {
    for (final line in [
      'EXDATE;VALUE=PERIOD:20261023T120000Z/PT1H',
      'RDATE:20261023T120000Z/PT1H',
      'RDATE;VALUE=DATE-TIME:20261023T120000Z/PT1H',
      'RDATE;VALUE=PERIOD:20261023T120000Z/PT1H,20261024T120000Z',
      'RDATE;VALUE=PERIOD;VALUE=PERIOD:20261023T120000Z/PT1H',
      'RDATE;VALUE=PERIOD,DATE-TIME:20261023T120000Z/PT1H',
      'RDATE;VALUE=PERıOD:20261023T120000Z/PT1H',
    ]) {
      expect(
        () => periods([line]),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    expect(
      () => periods([
        'RDATE;VALUE=PERIOD:20261023T120000Z/PT1H',
      ], start: 'DTSTART;VALUE=DATE:20261022'),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => periods(['RDATE;VALUE=PERIOD;X-PRIVATE=1:20261023T120000Z/PT1H']),
      rejects(IcalendarComponentError.unsupportedParameter),
    );
    expect(
      () => periods(['RDATE;VALUE=PERIOD;TZID=UTC:20261023T120000/PT1H']),
      rejects(IcalendarComponentError.missing),
    );
  });

  test(
    'a period-only zone reference still requires full-horizon agreement',
    () {
      expect(
        () => periods(
          ['RDATE;VALUE=PERIOD;TZID=UTC:20261023T120000/PT1H'],
          zones: [fixedZone(offset: '+0100')],
        ),
        rejects(IcalendarComponentError.zoneMismatch),
      );
    },
  );

  test('raw period duplicates share start/exclusion and calendar budgets', () {
    final line =
        'RDATE;VALUE=PERIOD:20261023T120000Z/PT1H,20261023T120000Z/PT1H';
    expect(
      () => periods([
        line,
      ], limits: const IcalendarComponentLimits(maxExplicitDates: 1)),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => periods([
        line,
        'EXDATE:20261023T120000Z',
      ], limits: const IcalendarComponentLimits(maxExplicitDates: 2)),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        file(
          events: [
            event(extra: [line]),
            event(uid: 'second@example.invalid', extra: [line]),
          ],
        ),
        limits: const IcalendarComponentLimits(maxCalendarExplicitDates: 3),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      periods(
        [line],
        limits: const IcalendarComponentLimits(
          maxExplicitDates: 2,
          maxCalendarExplicitDates: 2,
        ),
      ).events.single.recurrence!.timedSet!.periods.length,
      1,
    );
  });

  test(
    'late conflicting event fails atomically with private-free diagnostics',
    () {
      IcalendarEventCalendar? result;
      try {
        result = load(
          file(
            events: [
              event(),
              event(
                uid: 'private-secret@example.invalid',
                extra: [
                  'SUMMARY:Private synthetic title',
                  'RDATE;VALUE=PERIOD:20261023T120000Z/PT1H,20261023T120000Z/PT2H',
                ],
              ),
            ],
          ),
        );
        fail('Expected whole-calendar rejection');
      } on IcalendarComponentException catch (e) {
        expect(e.kind, IcalendarComponentError.invalidValue);
        expect(e.toString(), 'IcalendarComponentException(invalidValue)');
      }
      expect(result, isNull);
    },
  );
}
