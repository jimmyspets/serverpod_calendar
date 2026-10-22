import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart';
import 'support/availability_fixtures.dart';

Matcher rejects(IcalendarComponentError kind) => throwsA(
  isA<IcalendarComponentException>().having((e) => e.kind, 'kind', kind),
);
void main() {
  test('unbounded closure defaults, immutable source and protocol metadata round trip', () {
    final c = read([
      definition(
        extra: [
          'SEQUENCE:+2',
          'CREATED:20261001T000000Z',
          'LAST-MODIFIED:20261021T000000Z',
          'SUMMARY;LANGUAGE=en:Closed',
          'DESCRIPTION:Details',
          'LOCATION:Room',
        ],
      ),
    ]);
    final d = c.definitions.single;
    expect(d.start, isNull);
    expect(d.endExclusive, isNull);
    expect(d.duration, isNull);
    expect(d.priority, 0);
    expect(d.closedKind, AvailabilityKind.unavailable);
    expect(d.sequence, 2);
    expect(d.created, DateTime.utc(2026, 10));
    expect(d.summary!.language, 'en');
    expect(d.openings, isEmpty);
    expect(compose(c).single.kind, AvailabilityKind.unavailable);
    final bytes = serializeIcalendarAvailabilityCalendar(c);
    expect(
      serializeIcalendarAvailabilityCalendar(
        parseIcalendarAvailabilityCalendar(bytes),
      ),
      bytes,
    );
    expect(() => c.definitions.clear(), throwsUnsupportedError);
    expect(() => d.openings.clear(), throwsUnsupportedError);
  });
  test(
    'optional independent envelope bounds keep exact UTC and named forms',
    () {
      final c = read(
        [
          definition(
            extra: [
              'DTSTART:20261022T100000Z',
              'DTEND;TZID=UTC:20261022T140000',
            ],
          ),
          definition(uid: 'end-only', extra: ['DTEND:20261022T110000Z']),
          definition(uid: 'start-only', extra: ['DTSTART:20261022T160000Z']),
        ],
        zones: [fixedZone()],
      );
      expect(c.definitions.first.start!.zoneId, isNull);
      expect(c.definitions.first.end!.zoneId, 'UTC');
      expect(c.definitions[1].start, isNull);
      expect(c.definitions[2].endExclusive, isNull);
      expect(expand(c).first.end, DateTime.utc(2026, 10, 22, 14));
    },
  );
  test('envelope nominal days differ from elapsed hours through DST', () {
    IcalendarAvailabilityDefinition d(String duration) => read(
      [
        definition(
          extra: [
            'DTSTART;TZID=America/New_York:20260307T120000',
            'DURATION:$duration',
          ],
        ),
      ],
      zones: [newYorkZone()],
    ).definitions.single;
    expect(d('P1D').endExclusive, DateTime.utc(2026, 3, 8, 16));
    expect(d('PT24H').endExclusive, DateTime.utc(2026, 3, 8, 17));
    expect(d('P1D').duration!.days, 1);
  });
  test('opening profile requires positive timed end or duration and protocol fields', () {
    for (final o in [
      opening(),
      opening(extra: ['DURATION:PT0S']),
      opening(extra: ['DURATION:-PT1H']),
      opening(extra: ['DTEND:20261022T090000Z']),
      opening(timing: 'DTSTART;VALUE=DATE:20261022', extra: ['DURATION:P1D']),
      opening(timing: 'DTSTART:20261022T090000', extra: ['DURATION:PT1H']),
      opening(extra: ['DURATION:PT1H'])
          .replaceFirst('DTSTAMP:20261022T000000Z\r\n', ''),
    ]) {
      expect(
        () => read([
          definition(openings: [o]),
        ]),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    expect(
      read([
        definition(
          openings: [
            opening(extra: ['DURATION:PT1H']),
          ],
        ),
      ]).definitions.single.openings.single.master.span.duration,
      CalendarDuration(hours: 1),
    );
  });
  test(
    'recurrence, PERIOD and exclusions reuse canonical original identities',
    () {
      final c = read([
        definition(
          openings: [
            opening(
              extra: [
                'DURATION:PT1H',
                'RRULE:COUNT=2;FREQ=DAILY',
                'RDATE;VALUE=PERIOD:20261021T090000Z/PT3H',
                'EXDATE:20261022T090000Z',
              ],
            ),
          ],
        ),
      ]);
      final range = UtcWindow(
        start: DateTime.utc(2026, 10, 21),
        end: DateTime.utc(2026, 10, 24),
      );
      final values = expand(c, period: range).single.openings;
      expect(values.map((o) => o.start.day), [21, 23]);
      expect(values.first.end, DateTime.utc(2026, 10, 21, 12));
      expect(
        utf8.decode(serializeIcalendarAvailabilityCalendar(c)),
        contains('RRULE:FREQ=DAILY;COUNT=2'),
      );
      expect(
        c.definitions.single.openings.single.master.source.entries
            .whereType<IcalendarSyntaxProperty>()
            .singleWhere((p) => p.canonicalName == 'RRULE')
            .value,
        'COUNT=2;FREQ=DAILY',
      );
    },
  );
  test(
    'opening timing singles and future ranges preserve independent overrides',
    () {
      final c = read([
        definition(
          openings: [
            opening(
              uid: 'hours',
              extra: [
                'DURATION:PT1H',
                'RRULE:FREQ=DAILY;COUNT=3',
                'SUMMARY:Hours',
              ],
            ),
            opening(
              uid: 'hours',
              timing: 'DTSTART:20261023T100000Z',
              extra: [
                'RECURRENCE-ID;RANGE=THISANDFUTURE:20261023T090000Z',
                'DURATION:PT2H',
              ],
            ),
            opening(
              uid: 'hours',
              timing: 'DTSTART:20261021T110000Z',
              extra: [
                'RECURRENCE-ID:20261024T090000Z',
                'DURATION:PT3H',
                'SUMMARY:Hours',
              ],
            ),
          ],
        ),
      ]);
      final group = c.definitions.single.openings.single;
      expect(group.overrides.length, 2);
      expect(group.master.summary!.value, 'Hours');
      expect(group.overrides.first.summary, isNull);
      final values = expand(
        c,
        period: UtcWindow(
          start: DateTime.utc(2026, 10, 21),
          end: DateTime.utc(2026, 10, 25),
        ),
      ).single.openings;
      expect(values.map((o) => o.start), [
        DateTime.utc(2026, 10, 21, 11),
        DateTime.utc(2026, 10, 22, 9),
        DateTime.utc(2026, 10, 23, 10),
      ]);
      expect(values.last.end, DateTime.utc(2026, 10, 23, 12));
    },
  );
  test('priority and equal-priority openings use existing RFC composition', () {
    final c = read([
      definition(
        uid: 'low',
        extra: ['BUSYTYPE:BUSY'],
        openings: [
          opening(uid: 'low-hours', extra: ['DTEND:20261022T170000Z']),
        ],
      ),
      definition(
        uid: 'high',
        extra: [
          'PRIORITY:1',
          'DTSTART:20261022T120000Z',
          'DTEND:20261022T150000Z',
          'BUSYTYPE:BUSY-TENTATIVE',
        ],
        openings: [
          opening(
            uid: 'high-hours',
            timing: 'DTSTART:20261022T130000Z',
            extra: ['DURATION:PT1H'],
          ),
        ],
      ),
    ]);
    final result = compose(c);
    expect(result.map((i) => i.kind), [
      AvailabilityKind.busy,
      AvailabilityKind.free,
      AvailabilityKind.tentative,
      AvailabilityKind.free,
      AvailabilityKind.tentative,
      AvailabilityKind.free,
      AvailabilityKind.busy,
    ]);
    expect(result.map((i) => i.window.start.hour), [0, 9, 12, 13, 14, 15, 17]);
    final equal = read([
      definition(
        extra: ['BUSYTYPE:BUSY'],
        openings: [
          opening(extra: ['DURATION:PT1H']),
        ],
      ),
      definition(
        uid: 'same-priority',
        openings: [
          opening(
            uid: 'other',
            timing: 'DTSTART:20261022T100000Z',
            extra: ['DURATION:PT1H'],
          ),
        ],
      ),
    ]);
    expect(compose(equal).map((i) => i.kind), [
      AvailabilityKind.busy,
      AvailabilityKind.free,
      AvailabilityKind.busy,
    ]);
    expect(compose(equal)[1].window.end.hour, 11);
  });
  test('envelope clipping and closure never become missing-rule fallback', () {
    final c = read([
      definition(
        extra: ['DTSTART:20261022T100000Z', 'DTEND:20261022T120000Z'],
        openings: [
          opening(extra: ['DURATION:PT8H']),
        ],
      ),
    ]);
    final d = expand(c).single;
    expect(d.openings.single.start, DateTime.utc(2026, 10, 22, 10));
    expect(d.openings.single.end, DateTime.utc(2026, 10, 22, 12));
    expect(compose(c, fallback: true).map((i) => i.kind), [
      AvailabilityKind.unavailable,
      AvailabilityKind.free,
      AvailabilityKind.unavailable,
    ]);
    final outside = read([
      definition(
        extra: ['DTSTART:20261024T000000Z'],
        openings: [
          opening(extra: ['DURATION:PT1H']),
        ],
      ),
    ]);
    expect(expand(outside).single.openings, isEmpty);
    expect(compose(outside).single.kind, AvailabilityKind.free);
  });
  test(
    'named recurring hours retain DST and require matched timezone definitions',
    () {
      final c = read(
        [
          definition(
            openings: [
              opening(
                timing: 'DTSTART;TZID=America/New_York:20260307T090000',
                extra: ['DURATION:PT1H', 'RRULE:FREQ=DAILY;COUNT=2'],
              ),
            ],
          ),
        ],
        zones: [newYorkZone()],
      );
      expect(
        expand(
          c,
          period: UtcWindow(
            start: DateTime.utc(2026, 3, 7),
            end: DateTime.utc(2026, 3, 9),
          ),
        ).single.openings.map((o) => o.start.hour),
        [14, 13],
      );
      expect(
        () => read([
          definition(
            openings: [
              opening(
                timing: 'DTSTART;TZID=UTC:20261022T090000',
                extra: ['DURATION:PT1H'],
              ),
            ],
          ),
        ]),
        rejects(IcalendarComponentError.missing),
      );
      expect(
        () => read([definition()], zones: [fixedZone(offset: '+0100')]),
        rejects(IcalendarComponentError.zoneMismatch),
      );
    },
  );
  test(
    'global query work and raw occurrence caps do not multiply per opening',
    () {
      final c = read([
        definition(
          openings: [
            opening(extra: ['DURATION:PT1H', 'RRULE:FREQ=DAILY;COUNT=2']),
            opening(
              uid: 'other',
              extra: ['DURATION:PT1H', 'RRULE:FREQ=DAILY;COUNT=2'],
            ),
          ],
        ),
      ]);
      final period = UtcWindow(
        start: DateTime.utc(2026, 10, 22),
        end: DateTime.utc(2026, 10, 24),
      );
      expect(
        expand(c, period: period, work: 8, count: 4).single.openings.length,
        4,
      );
      expect(
        () => expand(c, period: period, work: 7),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => expand(c, period: period, count: 3),
        rejects(IcalendarComponentError.limitExceeded),
      );
    },
  );
  test('query validation rejects invalid limits and ordinary endpoints', () {
    final c = read([definition()]);
    expect(
      () => expand(c, work: 0),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => expand(c, count: 0),
      rejects(IcalendarComponentError.invalidValue),
    );
    for (final period in [
      UtcWindow(
        start: DateTime.utc(1969, 12, 31),
        end: DateTime.utc(1970, 1, 2),
      ),
      UtcWindow(
        start: DateTime.utc(2099, 12, 31),
        end: DateTime.utc(2100, 1, 1, 0, 0, 1),
      ),
    ]) {
      expect(
        () => expand(c, period: period),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
  });
  test('envelope bound/duration grammar and exact integer bounds reject', () {
    for (final props in [
      ['DURATION:PT1H'],
      ['DTSTART:20261022T090000Z', 'DTEND:20261022T100000Z', 'DURATION:PT1H'],
      ['DTSTART:20261022T090000Z', 'DURATION:PT0S'],
      ['DTSTART:20261022T090000Z', 'DTEND:20261022T080000Z'],
      ['DTSTART;VALUE=DATE:20261022'],
      ['DTEND:20261022T090000'],
      ['PRIORITY:10'],
      ['PRIORITY:-1'],
      ['PRIORITY:1.0'],
      ['SEQUENCE:2147483648'],
      ['BUSYTYPE:FREE'],
      ['BUSYTYPE:X-CUSTOM'],
      ['BUSYTYPE:BUſY'],
    ]) {
      expect(
        () => read([definition(extra: props)]),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    expect(
      read([
        definition(extra: ['PRIORITY:+09', 'SEQUENCE:2147483647']),
      ]).definitions.single.priority,
      9,
    );
  });
  test(
    'strict component/property contexts keep unsupported metadata explicit',
    () {
      for (final property in [
        'X-PRIVATE:Value',
        'RRULE:FREQ=DAILY',
        'STATUS:CANCELLED',
        'RECURRENCE-ID:20261022T090000Z',
      ]) {
        expect(
          () => read([
            definition(extra: [property]),
          ]),
          rejects(IcalendarComponentError.unsupportedProperty),
        );
      }
      for (final property in [
        'SEQUENCE:1',
        'PRIORITY:1',
        'BUSYTYPE:BUSY',
        'STATUS:CANCELLED',
        'TRANSP:TRANSPARENT',
        'ORGANIZER:mailto:synthetic@example.invalid',
      ]) {
        expect(
          () => read([
            definition(
              openings: [
                opening(extra: ['DURATION:PT1H', property]),
              ],
            ),
          ]),
          rejects(IcalendarComponentError.unsupportedProperty),
        );
      }
      expect(
        () => read([
          definition(openings: [event()]),
        ]),
        rejects(IcalendarComponentError.unsupportedComponent),
      );
      expect(
        () => read([event()]),
        rejects(IcalendarComponentError.unsupportedComponent),
      );
    },
  );
  test(
    'metadata parameters, cardinality and required timestamps are strict',
    () {
      final c = read([
        definition(
          extra: [
            'SUMMARY;LANGUAGE=en;ALTREP="https://example.invalid/info":Office',
          ],
        ),
      ]);
      expect(
        c.definitions.single.summary!.alternativeUri,
        'https://example.invalid/info',
      );
      for (final props in [
        ['UID:duplicate'],
        ['DTSTAMP:20261022T000000Z'],
        ['SUMMARY;LANGUAGE=en;LANGUAGE=sv:Office'],
        ['SUMMARY;X-UNKNOWN=x:Office'],
        ['DTSTAMP:20261022T000000.000Z'],
      ]) {
        expect(
          () => read([definition(extra: props)]),
          throwsA(isA<IcalendarComponentException>()),
        );
      }
      expect(
        () => read([
          definition().replaceFirst('DTSTAMP:20261022T000000Z\r\n', ''),
        ]),
        rejects(IcalendarComponentError.missing),
      );
    },
  );
  test('qualified opening grouping rejects detached, duplicate and excluded anchors', () {
    final o = opening(
      uid: 'hours',
      extra: [
        'DURATION:PT1H',
        'RRULE:FREQ=DAILY;COUNT=2',
        'EXDATE:20261023T090000Z',
      ],
    );
    final change = opening(
      uid: 'hours',
      timing: 'DTSTART:20261023T100000Z',
      extra: ['DURATION:PT1H', 'RECURRENCE-ID:20261023T090000Z'],
    );
    expect(
      () => read([
        definition(openings: [change]),
      ]),
      rejects(IcalendarComponentError.missing),
    );
    expect(
      () => read([
        definition(openings: [o, change]),
      ]),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => read([
        definition(openings: [o, o]),
      ]),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => read([
        definition(openings: [o]),
        definition(uid: 'other', openings: [o]),
      ]),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => read([definition(), definition()]),
      rejects(IcalendarComponentError.duplicate),
    );
  });
  test(
    'opening content changes reject and profiles cannot silently change',
    () {
      final master = opening(
        uid: 'hours',
        extra: ['DURATION:PT1H', 'RRULE:FREQ=DAILY;COUNT=2', 'SUMMARY:Hours'],
      );
      final change = opening(
        uid: 'hours',
        timing: 'DTSTART:20261023T100000Z',
        extra: [
          'DURATION:PT1H',
          'RECURRENCE-ID:20261023T090000Z',
          'SUMMARY:Changed',
        ],
      );
      expect(
        () => read([
          definition(openings: [master, change]),
        ]),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
      final other = opening(
        uid: 'hours',
        timing: 'DTSTART;TZID=UTC:20261023T100000',
        extra: ['DURATION:PT1H', 'RECURRENCE-ID:20261023T090000Z'],
      );
      expect(
        () => read(
          [
            definition(openings: [master, other]),
          ],
          zones: [fixedZone()],
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test(
    'raw definition/opening/override and shared parse budgets fail atomically',
    () {
      expect(
        () => read(
          [definition(), definition(uid: 'other')],
          limits: const IcalendarComponentLimits(maxAvailabilityDefinitions: 1),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      final o = opening(extra: ['DURATION:PT1H', 'RRULE:FREQ=DAILY;COUNT=3']);
      expect(
        () => read([
          definition(
            openings: [
              o,
              opening(uid: 'other', extra: ['DURATION:PT1H']),
            ],
          ),
        ], limits: const IcalendarComponentLimits(maxAvailableComponents: 1)),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => read([
          definition(
            openings: [
              o,
              opening(
                extra: ['DURATION:PT1H', 'RECURRENCE-ID:20261023T090000Z'],
              ),
              opening(
                extra: ['DURATION:PT1H', 'RECURRENCE-ID:20261024T090000Z'],
              ),
            ],
          ),
        ], limits: const IcalendarComponentLimits(maxAvailableOverrides: 1)),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => read([
          definition(
            openings: [
              o,
              opening(
                uid: 'other',
                extra: ['DURATION:PT1H', 'RRULE:FREQ=DAILY;COUNT=3'],
              ),
            ],
          ),
        ], limits: const IcalendarComponentLimits(maxCandidates: 3)),
        rejects(IcalendarComponentError.limitExceeded),
      );
    },
  );
  test(
    'whole seconds and exclusive 2100 endpoints are not ordinary starts',
    () {
      final c = read([
        definition(
          extra: ['DTEND:21000101T000000Z'],
          openings: [
            opening(
              timing: 'DTSTART:20991231T235959Z',
              extra: ['DURATION:PT1S'],
            ),
          ],
        ),
      ]);
      expect(c.definitions.single.end!.civil.date.isExclusiveEnd, isTrue);
      expect(
        expand(
          c,
          period: UtcWindow(
            start: DateTime.utc(2099, 12, 31),
            end: DateTime.utc(2100),
          ),
        ).single.openings.single.end,
        DateTime.utc(2100),
      );
      for (final props in [
        ['DTSTART:21000101T000000Z'],
        ['DTEND:21000101T000001Z'],
        ['DTSTART:20261022T090000.000Z'],
        ['DTEND:20261022T090060Z'],
      ]) {
        expect(
          () => read([definition(extra: props)]),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
    },
  );
  test(
    'strict envelopes and manually constructed unsupported trees reject',
    () {
      expect(() => read([]), rejects(IcalendarComponentError.missing));
      for (final entry in [
        'METHOD:PUBLISH',
        'CALSCALE:OTHER',
        'SUMMARY:Calendar title',
      ]) {
        expect(
          () => parseIcalendarAvailabilityCalendar(
            utf8.encode(file(events: [definition()], envelope: [entry])),
          ),
          throwsA(isA<IcalendarComponentException>()),
        );
      }
      expect(
        () => validateIcalendarAvailabilityCalendar(
          IcalendarSyntaxDocument([
            IcalendarSyntaxComponent('VAVAILABILITY', []),
          ]),
        ),
        rejects(IcalendarComponentError.unsupportedComponent),
      );
    },
  );
  test('late failure exposes no partial source calendar or private values', () {
    IcalendarAvailabilityCalendar? result;
    try {
      result = read([
        definition(),
        definition(
          uid: 'private@example.invalid',
          extra: ['X-PRIVATE:private@example.invalid'],
        ),
      ]);
      fail('Expected rejection');
    } on IcalendarComponentException catch (e) {
      expect(e.toString(), 'IcalendarComponentException(unsupportedProperty)');
    }
    expect(result, isNull);
  });
}
