import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart';

Matcher rejects(IcalendarComponentError kind) => throwsA(
  isA<IcalendarComponentException>().having((e) => e.kind, 'kind', kind),
);
String single(
  String identity,
  String timing, {
  List<String> extra = const [],
  String uid = 'synthetic@example.invalid',
}) => event(
  uid: uid,
  timing: timing,
  extra: ['RECURRENCE-ID$identity', ...extra],
);
IcalendarEventCalendar timed(
  List<String> overrides, {
  List<String> extra = const [],
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => load(
  file(
    events: [
      event(extra: ['RRULE:FREQ=DAILY;COUNT=5', ...extra]),
      ...overrides,
    ],
  ),
  limits: limits,
);
IcalendarEventCalendar date(
  List<String> overrides, {
  List<String> extra = const [],
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => load(
  file(
    events: [
      event(
        timing: 'DTSTART;VALUE=DATE:20261022',
        extra: ['RRULE:FREQ=DAILY;COUNT=5', ...extra],
      ),
      ...overrides,
    ],
  ),
  limits: limits,
);
List<TimedEventOccurrence> times(
  IcalendarEventCalendar c, {
  DateTime? from,
  DateTime? until,
}) => c.series.single.timedSeries!.expandOverlapping(
  window: UtcWindow(
    start: from ?? DateTime.utc(2026, 10, 19),
    end: until ?? DateTime.utc(2026, 11),
  ),
  maxCandidateWork: 200000,
  maxRuleOccurrences: 10000,
  maxBaseOccurrences: 10000,
  maxResults: 1000,
);
List<DateEventOccurrence> dates(
  IcalendarEventCalendar c, {
  String from = '20261019',
  String until = '20261101',
}) => c.series.single.dateSeries!.expandOverlapping(
  from: parseIcalendarDate(from),
  until: parseIcalendarDate(until),
  maxCandidateDays: 200000,
  maxRuleOccurrences: 10000,
  maxBaseOccurrences: 10000,
  maxResults: 1000,
);

void main() {
  test(
    'groups exact UIDs regardless of source order, retains all components',
    () {
      final c = load(
        file(
          events: [
            single(':20261023T120000Z', 'DTSTART:20261023T150000Z'),
            event(uid: 'other@example.invalid'),
            event(extra: ['RRULE:FREQ=DAILY;COUNT=2']),
          ],
        ),
      );
      expect(c.events.map((e) => e.uid), [
        'other@example.invalid',
        'synthetic@example.invalid',
      ]);
      expect(c.series[0].overrides, isEmpty);
      expect(
        c.series[1].overrides.single.originalStart,
        parseIcalendarDateTime('20261023T120000Z'),
      );
      final output = serializeIcalendarEventCalendar(c);
      expect('BEGIN:VEVENT'.allMatches(utf8.decode(output)).length, 3);
      expect(
        serializeIcalendarEventCalendar(parseIcalendarEventCalendar(output)),
        output,
      );
      expect(() => c.series.clear(), throwsUnsupportedError);
      expect(() => c.series[1].overrides.clear(), throwsUnsupportedError);
    },
  );
  test('DATE move resize cancellation and original identity survive overlap queries', () {
    final c = date([
      single(
        ';VALUE=DATE:20261023',
        'DTSTART;VALUE=DATE:20261020',
        extra: ['DURATION:P2D'],
      ),
      single(
        ';VALUE=DATE:20261024',
        'DTSTART;VALUE=DATE:20261024',
        extra: ['STATUS:CANCELLED'],
      ),
      single(
        ';VALUE=DATE:20261025',
        'DTSTART;VALUE=DATE:20261025',
        extra: ['DTEND;VALUE=DATE:20261028'],
      ),
    ]);
    final moved = dates(c, from: '20261020', until: '20261021').single;
    expect(moved.originalStart, parseIcalendarDate('20261023'));
    expect(moved.span.endExclusive, parseIcalendarDate('20261022'));
    expect(
      dates(c).any((o) => o.originalStart == parseIcalendarDate('20261024')),
      isFalse,
    );
    final overlap = dates(c, from: '20261027', until: '20261028').single;
    expect(overlap.originalStart, parseIcalendarDate('20261025'));
    expect(overlap.span.end, parseIcalendarDate('20261028'));
  });
  test('DATE ranges use original ordering, absolute shifts and independent singles', () {
    final c = date([
      single(
        ';VALUE=DATE;RANGE=THISANDFUTURE:20261023',
        'DTSTART;VALUE=DATE:20261025',
        extra: ['DURATION:P2D'],
      ),
      single(';VALUE=DATE:20261024', 'DTSTART;VALUE=DATE:20261020'),
      single(
        ';VALUE=DATE:20261025',
        'DTSTART;VALUE=DATE:20261025',
        extra: ['STATUS:CANCELLED'],
      ),
      single(
        ';VALUE=DATE;RANGE=THISANDFUTURE:20261026',
        'DTSTART;VALUE=DATE:20261027',
      ),
    ]);
    final found = dates(c);
    expect(found.map((o) => serializeIcalendarDate(o.originalStart)), [
      '20261024',
      '20261022',
      '20261023',
      '20261026',
    ]);
    expect(found.map((o) => serializeIcalendarDate(o.span.start)), [
      '20261020',
      '20261022',
      '20261025',
      '20261027',
    ]);
    expect(found[2].span.dayCount, 2);
    expect(found[3].span.dayCount, 1);
  });
  test(
    'UTC moved-in, moved-out, resized and cancelled occurrences are complete',
    () {
      final c = timed(
        [
          single(
            ':20261023T120000Z',
            'DTSTART:20261020T120000Z',
            extra: ['DURATION:PT2H'],
          ),
          single(':20261024T120000Z', 'DTSTART:20261101T120000Z'),
          single(
            ':20261025T120000Z',
            'DTSTART:20261025T120000Z',
            extra: ['STATUS:CANCELLED'],
          ),
        ],
        extra: ['DURATION:PT1H'],
      );
      final found = times(
        c,
        from: DateTime.utc(2026, 10, 20, 13),
        until: DateTime.utc(2026, 10, 20, 14),
      );
      expect(
        found.single.originalStart.instant,
        DateTime.utc(2026, 10, 23, 12),
      );
      expect(found.single.span.endExclusive, DateTime.utc(2026, 10, 20, 14));
      expect(times(c).map((o) => o.originalStart.instant), [
        DateTime.utc(2026, 10, 23, 12),
        DateTime.utc(2026, 10, 22, 12),
        DateTime.utc(2026, 10, 26, 12),
      ]);
    },
  );
  test('UTC future ranges resize and do not compound later shifts', () {
    final c = timed([
      single(
        ';RANGE=THISANDFUTURE:20261023T120000Z',
        'DTSTART:20261023T140000Z',
        extra: ['DURATION:PT3H'],
      ),
      single(
        ':20261024T120000Z',
        'DTSTART:20261024T160000Z',
        extra: ['DURATION:PT1H'],
      ),
      single(
        ';RANGE=THISANDFUTURE:20261025T120000Z',
        'DTSTART:20261025T110000Z',
        extra: ['DTEND:20261025T130000Z'],
      ),
    ]);
    final found = times(c);
    expect(found.map((o) => o.actualStart.instant.hour), [12, 14, 16, 11, 11]);
    expect(found.map((o) => o.span.endExclusive.hour), [12, 17, 17, 13, 13]);
  });
  test('named future timing retains civil shift and nominal DST duration', () {
    final c = load(
      file(
        zones: [newYorkZone()],
        events: [
          event(
            timing: 'DTSTART;TZID=America/New_York:20260306T090000',
            extra: ['RRULE:FREQ=DAILY;COUNT=4', 'DURATION:PT1H'],
          ),
          single(
            ';TZID=America/New_York;RANGE=THISANDFUTURE:20260307T090000',
            'DTSTART;TZID=America/New_York:20260307T100000',
            extra: ['DURATION:P1D'],
          ),
          single(
            ';TZID=America/New_York:20260308T090000',
            'DTSTART;TZID=America/New_York:20260308T110000',
            extra: ['DURATION:PT2H'],
          ),
        ],
      ),
    );
    final found = times(
      c,
      from: DateTime.utc(2026, 3, 6),
      until: DateTime.utc(2026, 3, 11),
    );
    expect(found.map((o) => o.actualStart.instant), [
      DateTime.utc(2026, 3, 6, 14),
      DateTime.utc(2026, 3, 7, 15),
      DateTime.utc(2026, 3, 8, 15),
      DateTime.utc(2026, 3, 9, 14),
    ]);
    expect(found[1].span.endExclusive, DateTime.utc(2026, 3, 8, 14));
    expect(found[2].span.endExclusive, DateTime.utc(2026, 3, 8, 17));
    expect(
      c.series.single.overrides.first.timedSpan!.duration,
      CalendarDuration(days: 1),
    );
  });
  test('PERIOD and earlier RDATE anchors retain precedence under timing components', () {
    final c = timed(
      [
        single(
          ':20261021T120000Z',
          'DTSTART:20261020T120000Z',
          extra: ['DURATION:PT3H'],
        ),
        single(
          ';RANGE=THISANDFUTURE:20261023T120000Z',
          'DTSTART:20261023T140000Z',
          extra: ['DURATION:PT2H'],
        ),
        single(
          ':20261024T120000Z',
          'DTSTART:20261024T120000Z',
          extra: ['STATUS:CANCELLED'],
        ),
      ],
      extra: ['RDATE;VALUE=PERIOD:20261021T120000Z/PT4H,20261023T120000Z/PT8H'],
    );
    final found = times(c);
    expect(found.first.originalStart.instant, DateTime.utc(2026, 10, 21, 12));
    expect(found.first.span.endExclusive, DateTime.utc(2026, 10, 20, 15));
    expect(
      found
          .singleWhere((o) => o.originalStart.instant.day == 23)
          .span
          .endExclusive,
      DateTime.utc(2026, 10, 23, 16),
    );
    expect(found.any((o) => o.originalStart.instant.day == 24), isFalse);
  });
  test(
    'cancellation preserves its parsed timing and source protocol versions',
    () {
      final c = timed(
        [
          single(
            ':20261023T120000Z',
            'DTSTART:20261023T170000Z',
            extra: [
              'DURATION:PT3H',
              'STATUS:CANCELLED',
              'SEQUENCE:7',
              'CREATED:20261001T000000Z',
              'LAST-MODIFIED:20261022T110000Z',
            ],
          ),
        ],
        extra: ['SEQUENCE:2'],
      );
      final o = c.series.single.overrides.single;
      expect(o.timedSpan!.endExclusive, DateTime.utc(2026, 10, 23, 20));
      expect(o.sequence, 7);
      expect(c.events.single.sequence, 2);
      expect(times(c).any((o) => o.originalStart.instant.day == 23), isFalse);
      expect(
        utf8.decode(serializeIcalendarEventCalendar(c)),
        contains('SEQUENCE:7'),
      );
    },
  );
  test(
    'omitted content inherits, explicit text and annotations remain local',
    () {
      final content = [
        'SUMMARY;LANGUAGE=en;ALTREP="https://example.invalid/text":Meeting',
        'DESCRIPTION:Details',
        'LOCATION:Room',
        'STATUS:TENTATIVE',
        'TRANSP:TRANSPARENT',
      ];
      final c = timed([
        single(':20261023T120000Z', 'DTSTART:20261023T150000Z'),
        single(':20261024T120000Z', 'DTSTART:20261024T160000Z', extra: content),
      ], extra: content);
      expect(c.series.single.overrides.first.summary, isNull);
      expect(c.series.single.master.summary!.value, 'Meeting');
      expect(c.series.single.overrides.last.summary!.language, 'en');
      expect(
        c.series.single.overrides.last.status,
        IcalendarEventStatus.tentative,
      );
    },
  );
  test('status/transparency differences still reject', () {
    for (final value in ['STATUS:TENTATIVE', 'TRANSP:TRANSPARENT']) {
      expect(
        () => timed(
          [
            single(
              ':20261023T120000Z',
              'DTSTART:20261023T130000Z',
              extra: [value],
            ),
          ],
          extra: [
            'SUMMARY:Master',
            'DESCRIPTION:Details',
            'LOCATION:Room',
            'STATUS:CONFIRMED',
          ],
        ),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
    final c = timed(
      [
        single(
          ':20261023T120000Z',
          'DTSTART:20261023T130000Z',
          extra: ['SUMMARY;LANGUAGE=sv:Same', 'DESCRIPTION:', 'LOCATION:Other'],
        ),
        single(
          ';RANGE=THISANDFUTURE:20261024T120000Z',
          'DTSTART:20261024T140000Z',
          extra: ['SUMMARY;ALTREP="https://example.invalid/other":Anchor'],
        ),
      ],
      extra: ['SUMMARY;LANGUAGE=en:Same', 'DESCRIPTION:Master'],
    );
    final own = c.series.single.overrides;
    expect(own.first.summary!.language, 'sv');
    expect(own.first.description!.value, '');
    expect(own.first.location!.value, 'Other');
    expect(own.last.summary!.value, 'Anchor');
    expect(c.series.single.master.summary!.value, 'Same');
    final round = parseIcalendarEventCalendar(
      serializeIcalendarEventCalendar(c),
    );
    expect(round.series.single.overrides.first.description!.value, '');
    expect(
      timed([
        single(
          ':20261023T120000Z',
          'DTSTART:20261023T130000Z',
          extra: ['TRANSP:OPAQUE'],
        ),
      ]).series.length,
      1,
    );
  });
  test(
    'omitted end uses standalone point/day default, not master duration',
    () {
      final t = timed(
        [single(':20261023T120000Z', 'DTSTART:20261023T140000Z')],
        extra: ['DURATION:PT3H'],
      );
      expect(
        times(t)
            .singleWhere((o) => o.originalStart.instant.day == 23)
            .span
            .isPoint,
        isTrue,
      );
      final d = date(
        [single(';VALUE=DATE:20261023', 'DTSTART;VALUE=DATE:20261024')],
        extra: ['DURATION:P3D'],
      );
      expect(
        dates(d)
            .singleWhere(
              (o) => o.originalStart == parseIcalendarDate('20261023'),
            )
            .span
            .dayCount,
        1,
      );
    },
  );
  test('detached, missing recurrence and duplicate masters reject', () {
    expect(
      () => load(
        file(events: [single(':20261023T120000Z', 'DTSTART:20261023T140000Z')]),
      ),
      rejects(IcalendarComponentError.missing),
    );
    expect(
      () => load(
        file(
          events: [
            event(),
            single(':20261022T120000Z', 'DTSTART:20261022T140000Z'),
          ],
        ),
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => load(file(events: [event(), event()])),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => timed([
        single(
          ':20261023T120000Z',
          'DTSTART:20261023T140000Z',
          uid: 'Synthetic@example.invalid',
        ),
      ]),
      rejects(IcalendarComponentError.missing),
    );
  });
  test(
    'orphan, excluded and moved actual identities cannot retarget an override',
    () {
      for (final id in ['20261027T120000Z', '20261023T140000Z']) {
        expect(
          () => timed([single(':$id', 'DTSTART:20261023T150000Z')]),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
      expect(
        () => timed(
          [single(':20261023T120000Z', 'DTSTART:20261023T150000Z')],
          extra: ['EXDATE:20261023T120000Z'],
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => date(
          [single(';VALUE=DATE:20261023', 'DTSTART;VALUE=DATE:20261024')],
          extra: ['EXDATE;VALUE=DATE:20261023'],
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test(
    'duplicate anchors reject regardless of version, cancellation or range',
    () {
      final a = single(':20261023T120000Z', 'DTSTART:20261023T140000Z');
      for (final b in [
        a,
        single(
          ':20261023T120000Z',
          'DTSTART:20261023T120000Z',
          extra: ['STATUS:CANCELLED', 'SEQUENCE:9'],
        ),
        single(
          ';RANGE=THISANDFUTURE:20261023T120000Z',
          'DTSTART:20261023T140000Z',
        ),
      ]) {
        expect(
          () => timed([a, b]),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
      expect(
        () => date([
          single(';VALUE=DATE:20261023', 'DTSTART;VALUE=DATE:20261024'),
          single(
            ';VALUE=DATE;RANGE=THISANDFUTURE:20261023',
            'DTSTART;VALUE=DATE:20261025',
          ),
        ]),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test('recurrence identity and replacement require exact master profile', () {
    for (final o in [
      single(';VALUE=DATE:20261023', 'DTSTART;VALUE=DATE:20261024'),
      single(':20261023T120000', 'DTSTART:20261023T140000Z'),
      single(';TZID=UTC:20261023T120000', 'DTSTART;TZID=UTC:20261023T140000'),
      single(':20261023T120000Z', 'DTSTART;VALUE=DATE:20261023'),
    ]) {
      expect(
        () => load(
          file(
            zones: [fixedZone()],
            events: [
              event(extra: ['RRULE:FREQ=DAILY;COUNT=5']),
              o,
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
    expect(
      () => date([single(':20261023T120000Z', 'DTSTART:20261023T140000Z')]),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => load(
        file(
          zones: [
            fixedZone(),
            fixedZone(id: 'Etc/UTC'),
          ],
          events: [
            event(
              timing: 'DTSTART;TZID=UTC:20261022T120000',
              extra: ['RRULE:FREQ=DAILY;COUNT=5'],
            ),
            single(
              ';TZID=Etc/UTC:20261023T120000',
              'DTSTART;TZID=UTC:20261023T140000',
            ),
          ],
        ),
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test(
    'strict RANGE/context/cardinality rejects unsupported component behavior',
    () {
      for (final suffix in [
        ';RANGE=THISANDPRIOR:20261023T120000Z',
        ';RANGE=THıSANDFUTURE:20261023T120000Z',
        ';RANGE=THISANDFUTURE;RANGE=THISANDFUTURE:20261023T120000Z',
        ';VALUE=PERIOD:20261023T120000Z/PT1H',
      ]) {
        expect(
          () => timed([single(suffix, 'DTSTART:20261023T140000Z')]),
          throwsA(isA<IcalendarComponentException>()),
        );
      }
      for (final property in [
        'RRULE:FREQ=DAILY',
        'RDATE:20261024T120000Z',
        'EXDATE:20261024T120000Z',
      ]) {
        expect(
          () => timed([
            single(
              ':20261023T120000Z',
              'DTSTART:20261023T140000Z',
              extra: [property],
            ),
          ]),
          rejects(IcalendarComponentError.unsupportedProperty),
        );
      }
      expect(
        () => timed([
          single(
            ';RANGE=THISANDFUTURE:20261023T120000Z',
            'DTSTART:20261023T140000Z',
            extra: ['STATUS:CANCELLED'],
          ),
        ]),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
      expect(
        () => timed([
          single(
            ':20261023T120000Z',
            'DTSTART:20261023T140000Z',
            extra: ['RECURRENCE-ID:20261024T120000Z'],
          ),
        ]),
        rejects(IcalendarComponentError.duplicate),
      );
    },
  );
  test('ordinary identity guards and exclusive replacement endpoints remain strict', () {
    for (final id in [
      '21000101T000000Z',
      '20261023T120000.000Z',
      '20261023T120060Z',
      '19691231T235959Z',
    ]) {
      expect(
        () => timed([single(':$id', 'DTSTART:20261023T140000Z')]),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
    final c = load(
      file(
        events: [
          event(
            timing: 'DTSTART:20991230T120000Z',
            extra: ['RRULE:FREQ=DAILY;COUNT=2'],
          ),
          single(
            ':20991231T120000Z',
            'DTSTART:20991231T235959Z',
            extra: ['DTEND:21000101T000000Z'],
          ),
        ],
      ),
    );
    expect(
      c.series.single.overrides.single.timedSpan!.endExclusive,
      DateTime.utc(2100),
    );
    expect(
      () => timed([single(':20261023T120000Z', 'DTSTART:21000101T000000Z')]),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test('override and raw membership result caps fail without truncation', () {
    final o = [
      single(':20261023T120000Z', 'DTSTART:20261023T140000Z'),
      single(':20261025T120000Z', 'DTSTART:20261025T140000Z'),
    ];
    expect(
      () => timed(
        o,
        limits: const IcalendarComponentLimits(maxOverridesPerEvent: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => timed(o, limits: const IcalendarComponentLimits(maxEvents: 2)),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => timed(
        o,
        limits: const IcalendarComponentLimits(maxValidationOccurrences: 2),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => date([
        single(';VALUE=DATE:20261023', 'DTSTART;VALUE=DATE:20261024'),
        single(';VALUE=DATE:20261025', 'DTSTART;VALUE=DATE:20261026'),
      ], limits: const IcalendarComponentLimits(maxValidationOccurrences: 2)),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
  test(
    'alignment and independent series memberships share the global work cap',
    () {
      final master = event(extra: ['RRULE:FREQ=DAILY;COUNT=2']);
      final o = single(':20261023T120000Z', 'DTSTART:20261023T140000Z');
      expect(
        load(
          file(events: [master, o]),
          limits: const IcalendarComponentLimits(maxCandidates: 6),
        ).series.length,
        1,
      );
      expect(
        () => load(
          file(
            events: [
              master,
              o,
              event(uid: 'other', extra: ['RRULE:FREQ=DAILY;COUNT=2']),
              single(
                ':20261023T120000Z',
                'DTSTART:20261023T140000Z',
                uid: 'other',
              ),
            ],
          ),
          limits: const IcalendarComponentLimits(maxCandidates: 11),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
    },
  );
  test('late override failure returns no partial grouped calendar or private error', () {
    IcalendarEventCalendar? result;
    try {
      result = timed([
        single(
          ':20261023T120000Z',
          'DTSTART:20261023T140000Z',
          extra: ['SUMMARY:Private synthetic override', 'TRANSP:TRANSPARENT'],
        ),
      ]);
      fail('Expected rejection');
    } on IcalendarComponentException catch (e) {
      expect(e.toString(), 'IcalendarComponentException(unsupportedProperty)');
    }
    expect(result, isNull);
  });
}
