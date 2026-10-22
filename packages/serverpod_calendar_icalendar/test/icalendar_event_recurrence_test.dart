import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart';

Matcher rejects(IcalendarComponentError kind) => throwsA(
  isA<IcalendarComponentException>().having((e) => e.kind, 'kind', kind),
);
IcalendarEvent dateEvent(
  List<String> properties, {
  String start = '20261022',
}) => load(
  file(
    events: [event(timing: 'DTSTART;VALUE=DATE:$start', extra: properties)],
  ),
).events.single;
List<CalendarDate> dates(
  IcalendarEvent e, {
  String from = '20261001',
  String through = '20261231',
}) => e.recurrence!.dateSet!.expand(
  from: parseIcalendarDate(from),
  through: parseIcalendarDate(through),
  maxCandidateDays: 200000,
  maxRuleOccurrences: 10000,
  maxResults: 500,
);
List<TimedValue> times(IcalendarEvent e, DateTime from, DateTime through) =>
    e.recurrence!.timedSet!.expand(
      window: UtcWindow(start: from, end: through),
      maxCandidateWork: 200000,
      maxRuleOccurrences: 10000,
      maxResults: 500,
    );

void main() {
  test(
    'ASCII protocol tokens reject Unicode lookalikes while text stays Unicode',
    () {
      for (final rule in [
        'FREQ=daıly',
        'FREQ=DAILY;ınterval=1',
        'FREQ=DAILY;UNTıL=20261024',
      ]) {
        expect(
          () => dateEvent(['RRULE:$rule']),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
      expect(
        () => load(file(envelope: ['CALSCALE:GREGORıAN'])),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => load(
          file(
            events: [
              event(extra: ['STATUS:CONFıRMED']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => load(
          file(
            events: [event(timing: 'DTSTART;VALUE=DATE-TıME:20261022T120000Z')],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => load(
          file(
            zones: [
              fixedZone(extra: ['RRULE:FREQ=YEARLY;ınterval=1']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        load(
          file(
            events: [
              event(extra: ['SUMMARY:İstanbul — 日本語']),
            ],
          ),
        ).events.single.summary!.value,
        'İstanbul — 日本語',
      );
    },
  );
  test('absence remains distinct from finite explicit-date recurrence', () {
    expect(load(file()).events.single.recurrence, isNull);
    final e = dateEvent([
      'RDATE;VALUE=DATE:20261020,20261024',
      'EXDATE;VALUE=DATE:20261022',
    ]);
    expect(e.recurrence!.dateSet!.rule, isNull);
    expect(dates(e).map(serializeIcalendarDate), ['20261020', '20261024']);
    expect(e.recurrence!.dateSet!.start, parseIcalendarDate('20261022'));
  });
  test(
    'COUNT constrains only rule; earlier RDATE and EXDATE precedence survive',
    () {
      final e = dateEvent([
        'RRULE:FREQ=DAILY;COUNT=3',
        'RDATE;VALUE=DATE:20261020,20261023',
        'RDATE;VALUE=DATE:20261025,20261025',
        'EXDATE;VALUE=DATE:20261023',
      ]);
      expect(dates(e).map(serializeIcalendarDate), [
        '20261020',
        '20261022',
        '20261024',
        '20261025',
      ]);
      expect(e.recurrence!.dateSet!.inclusions.length, 3);
      expect(
        () => e.recurrence!.dateSet!.inclusions.clear(),
        throwsUnsupportedError,
      );
    },
  );
  test(
    'DATE UNTIL is inclusive and ordinary rather than an exclusive endpoint',
    () {
      final e = dateEvent(['RRULE:FREQ=DAILY;UNTIL=20261024']);
      expect(dates(e).map(serializeIcalendarDate), [
        '20261022',
        '20261023',
        '20261024',
      ]);
      for (final until in [
        '20261024T120000Z',
        '21000101',
        '19691231',
        '20261021',
      ]) {
        expect(
          () => dateEvent(['RRULE:FREQ=DAILY;UNTIL=$until']),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
    },
  );
  test(
    'filter normalization does not erase source spelling or raw budgets',
    () {
      final e = dateEvent([
        'RRULE:COUNT=3;freq=monthly;BYMONTHDAY=22,22;BYMONTH=12,10,11,10',
      ]);
      final rule = e.recurrence!.dateSet!.rule!;
      expect(rule.byMonth, [10, 11, 12]);
      expect(rule.byMonthDay, [22]);
      expect(dates(e).map(serializeIcalendarDate), [
        '20261022',
        '20261122',
        '20261222',
      ]);
      expect(
        e.source.entries.whereType<IcalendarSyntaxProperty>().last.value,
        startsWith('COUNT=3;freq=monthly'),
      );
      expect(() => rule.byMonth.add(1), throwsUnsupportedError);
    },
  );
  test('source serialization moves only FREQ first and is deterministic', () {
    final value = load(
      file(
        events: [
          event(extra: ['RRULE:COUNT=3;freq=daily;INTERVAL=1']),
        ],
      ),
    );
    final output = serializeIcalendarEventCalendar(value);
    expect(
      utf8.decode(output),
      contains('RRULE:freq=daily;COUNT=3;INTERVAL=1'),
    );
    final again = parseIcalendarEventCalendar(output);
    expect(
      again.events.single.recurrence!.timedSet!.rule,
      value.events.single.recurrence!.timedSet!.rule,
    );
    expect(serializeIcalendarEventCalendar(again), output);
    expect(
      value.events.single.source.entries
          .whereType<IcalendarSyntaxProperty>()
          .last
          .value,
      'COUNT=3;freq=daily;INTERVAL=1',
    );
  });
  test(
    'weekly and monthly/date yearly filters use existing core semantics',
    () {
      final weekly = dateEvent([
        'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TH;COUNT=2',
      ]);
      expect(dates(weekly).map(serializeIcalendarDate), [
        '20261022',
        '20261105',
      ]);
      final monthly = dateEvent([
        'RRULE:FREQ=MONTHLY;BYDAY=-1FR;COUNT=2',
      ], start: '20261030');
      expect(dates(monthly).map(serializeIcalendarDate), [
        '20261030',
        '20261127',
      ]);
      final leap = dateEvent([
        'RRULE:FREQ=YEARLY;BYMONTH=2;BYMONTHDAY=29;COUNT=2',
      ], start: '20240229');
      expect(
        dates(
          leap,
          from: '20240101',
          through: '20281231',
        ).map(serializeIcalendarDate),
        ['20240229', '20280229'],
      );
      final yearDay = dateEvent([
        'RRULE:FREQ=YEARLY;BYYEARDAY=-1;COUNT=2',
      ], start: '20251231');
      expect(dates(yearDay, from: '20250101').map(serializeIcalendarDate), [
        '20251231',
        '20261231',
      ]);
    },
  );
  test(
    'explicit WKST controls BYWEEKNO without changing ISO display convention',
    () {
      final e = dateEvent([
        'RRULE:FREQ=YEARLY;BYWEEKNO=1;BYDAY=SU;WKST=SU;COUNT=2',
      ], start: '20210103');
      expect(e.recurrence!.dateSet!.rule!.weekStart, Weekday.sunday);
      expect(
        dates(
          e,
          from: '20210101',
          through: '20221231',
        ).map(serializeIcalendarDate),
        ['20210103', '20220102'],
      );
      expect(
        () => dateEvent([
          'RRULE:FREQ=YEARLY;BYWEEKNO=1;BYDAY=SU;COUNT=2',
        ], start: '20210103'),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        dateEvent(['RRULE:FREQ=DAILY;COUNT=1'])
            .recurrence!
            .dateSet!
            .rule!
            .weekStart,
        Weekday.monday,
      );
    },
  );
  test(
    'start alignment includes BYSETPOS and cannot be bypassed by EXDATE',
    () {
      final e = dateEvent([
        'RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1;COUNT=2',
      ], start: '20261030');
      expect(dates(e).map(serializeIcalendarDate), ['20261030', '20261130']);
      expect(
        () => dateEvent([
          'RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1',
          'EXDATE;VALUE=DATE:20261022',
        ]),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test('UTC clock rules retain seconds and form typed recurrence sets', () {
    final e = load(
      file(
        events: [
          event(
            timing: 'DTSTART:20261022T120005Z',
            extra: [
              'RRULE:FREQ=HOURLY;COUNT=3;BYMINUTE=0,30',
              'RDATE:20261022T100005Z',
              'EXDATE:20261022T123005Z',
            ],
          ),
        ],
      ),
    ).events.single;
    expect(
      times(
        e,
        DateTime.utc(2026, 10, 22),
        DateTime.utc(2026, 10, 23),
      ).map(serializeIcalendarDateTime),
      ['20261022T100005Z', '20261022T120005Z', '20261022T130005Z'],
    );
    final minute = load(
      file(
        events: [
          event(extra: ['RRULE:FREQ=MINUTELY;COUNT=2']),
        ],
      ),
    ).events.single;
    expect(
      times(
        minute,
        DateTime.utc(2026, 10, 22),
        DateTime.utc(2026, 10, 23),
      ).map(serializeIcalendarDateTime),
      ['20261022T120000Z', '20261022T120100Z'],
    );
  });
  test(
    'UTC UNTIL required for UTC and named masters; floating and DATE reject',
    () {
      for (final until in [
        '20261022',
        '20261022T140000',
        '21000101T000000Z',
        '20261022T140000.000Z',
      ]) {
        expect(
          () => load(
            file(
              events: [
                event(extra: ['RRULE:FREQ=HOURLY;UNTIL=$until']),
              ],
            ),
          ),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
      final e = load(
        file(
          events: [
            event(extra: ['RRULE:FREQ=HOURLY;UNTIL=20261022T140000Z']),
          ],
        ),
      ).events.single;
      expect(
        times(e, DateTime.utc(2026, 10, 22), DateTime.utc(2026, 10, 23)).length,
        3,
      );
    },
  );
  test('named recurrence skips generated DST gaps without consuming COUNT', () {
    final e = load(
      file(
        zones: [newYorkZone()],
        events: [
          event(
            timing: 'DTSTART;TZID=America/New_York:20260307T023000',
            extra: [
              'RRULE:FREQ=DAILY;COUNT=3',
              'RDATE;TZID=America/New_York:20260306T023000',
            ],
          ),
        ],
      ),
    ).events.single;
    final values = times(
      e,
      DateTime.utc(2026, 3, 6),
      DateTime.utc(2026, 3, 12),
    );
    expect(values.map((v) => v.civil.date.day), [6, 7, 9, 10]);
    expect(values.every((v) => v.zoneId == 'America/New_York'), isTrue);
    final again = parseIcalendarEventCalendar(
      serializeIcalendarEventCalendar(
        load(
          file(
            zones: [newYorkZone()],
            events: [
              event(
                timing: 'DTSTART;TZID=America/New_York:20260307T023000',
                extra: ['RRULE:FREQ=DAILY;COUNT=3'],
              ),
            ],
          ),
        ),
      ),
    );
    expect(again.events.single.recurrence!.timedSet!.rule!.count, 3);
  });
  test(
    'named DATE-TIME UNTIL uses UTC and nominal event duration stays nominal',
    () {
      final e = load(
        file(
          zones: [newYorkZone()],
          events: [
            event(
              timing: 'DTSTART;TZID=America/New_York:20260307T120000',
              extra: [
                'DURATION:P1D',
                'RRULE:FREQ=DAILY;UNTIL=20260309T160000Z',
              ],
            ),
          ],
        ),
      ).events.single;
      final values = times(
        e,
        DateTime.utc(2026, 3, 7),
        DateTime.utc(2026, 3, 11),
      );
      expect(values.length, 3);
      expect(
        e.timedSpan!
            .projectAt(values.first)
            .endExclusive
            .difference(values.first.instant),
        const Duration(hours: 23),
      );
      expect(
        () => load(
          file(
            zones: [newYorkZone()],
            events: [
              event(
                timing: 'DTSTART;TZID=America/New_York:20260307T120000',
                extra: ['RRULE:FREQ=DAILY;UNTIL=20260309T120000'],
              ),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test('explicit recurrence dates require exact master kind and zone', () {
    for (final property in [
      'RDATE:20261023T120000Z',
      'EXDATE:20261023T120000Z',
      'RDATE;VALUE=DATE:21000101',
      'RDATE;VALUE=DATE:19691231',
    ]) {
      expect(
        () => dateEvent([property]),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
    for (final property in [
      'RDATE:20261023T120000',
      'EXDATE;VALUE=DATE:20261023',
      'RDATE;TZID=UTC:20261023T120000',
    ]) {
      expect(
        () => load(
          file(
            zones: [fixedZone()],
            events: [
              event(extra: [property]),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
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
              extra: ['RDATE;TZID=Etc/UTC:20261023T120000'],
            ),
          ],
        ),
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test(
    'PERIOD, override components, SECONDLY and BYSECOND remain rejected',
    () {
      expect(
        () => load(
          file(
            events: [
              event(extra: ['RDATE;VALUE=PERIOD:20261023T120000Z/PT1H']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => dateEvent(['RRULE:FREQ=SECONDLY']),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => load(
          file(
            events: [
              event(extra: ['RRULE:FREQ=SECONDLY']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => dateEvent(['RRULE:FREQ=DAILY;BYSECOND=0']),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
      expect(
        () => load(
          file(
            events: [
              event(extra: ['RECURRENCE-ID:20261022T120000Z']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    },
  );
  test('duplicate/malformed rule parts and unsupported parameters reject', () {
    for (final rule in [
      '',
      'COUNT=2',
      'FREQ=DAILY;',
      'FREQ=DAILY;FREQ=DAILY',
      'FREQ=DAILY;COUNT=2;count=3',
      'FREQ=DAILY;COUNT=2;UNTIL=20261024',
      'FREQ=DAILY;WKST=XX',
      'FREQ=DAILY;INTERVAL=+1',
      'FREQ=DAILY;COUNT=-1',
      'FREQ=DAILY;COUNT=0',
      'FREQ=DAILY;COUNT=9007199254740992',
      'FREQ=YEARLY;BYMONTH=+10',
      'FREQ=YEARLY;BYMONTH=010',
      'FREQ=MONTHLY;BYMONTHDAY=022',
      'FREQ=YEARLY;BYYEARDAY=0001',
      'FREQ=MONTHLY;BYDAY=0TH',
      'FREQ=MONTHLY;BYDAY=54TH',
    ]) {
      expect(
        () => dateEvent(['RRULE:$rule']),
        throwsA(isA<IcalendarComponentException>()),
        reason: rule,
      );
    }
    expect(
      () => dateEvent(['RRULE:FREQ=DAILY', 'RRULE:FREQ=WEEKLY']),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => dateEvent(['RRULE;VALUE=RECUR:FREQ=DAILY']),
      rejects(IcalendarComponentError.unsupportedParameter),
    );
    expect(
      () => dateEvent(['RDATE;VALUE=DATE;VALUE=DATE:20261023']),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => dateEvent(['RDATE;VALUE=DATE:']),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test(
    'RFC combination restrictions remain enforced rather than normalized',
    () {
      for (final rule in [
        'FREQ=WEEKLY;BYMONTHDAY=22',
        'FREQ=DAILY;BYYEARDAY=295',
        'FREQ=MONTHLY;BYYEARDAY=295',
        'FREQ=DAILY;BYWEEKNO=43',
        'FREQ=WEEKLY;BYDAY=1TH',
        'FREQ=YEARLY;BYWEEKNO=43;BYDAY=1TH',
        'FREQ=DAILY;BYHOUR=12',
        'FREQ=DAILY;BYMINUTE=0',
        'FREQ=MINUTELY',
        'FREQ=HOURLY',
        'FREQ=MONTHLY;BYSETPOS=1',
      ]) {
        expect(
          () => dateEvent(['RRULE:$rule']),
          rejects(IcalendarComponentError.invalidValue),
          reason: rule,
        );
      }
    },
  );
  test(
    'exact scalar boundary and leading zero grammar map without web rounding',
    () {
      final e = dateEvent([
        'RRULE:FREQ=DAILY;COUNT=9007199254740991;INTERVAL=0001',
      ]);
      expect(e.recurrence!.dateSet!.rule!.count, DateRecurrenceRule.maxScalar);
      expect(e.recurrence!.dateSet!.rule!.interval, 1);
    },
  );
  test(
    'raw values and dates count before deduplication across the calendar',
    () {
      expect(
        () => load(
          file(
            events: [
              event(
                timing: 'DTSTART;VALUE=DATE:20261022',
                extra: ['RDATE;VALUE=DATE:20261022,20261022'],
              ),
            ],
          ),
          limits: const IcalendarComponentLimits(maxExplicitDates: 1),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => load(
          file(
            events: [
              event(extra: ['RRULE:FREQ=DAILY;BYHOUR=12,12']),
            ],
          ),
          limits: const IcalendarComponentLimits(maxRuleValues: 1),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      for (final mode in ['dates', 'rules']) {
        final props = mode == 'dates'
            ? ['RDATE:20261022T120000Z']
            : ['RRULE:FREQ=DAILY;BYHOUR=12'];
        expect(
          () => load(
            file(
              events: [
                event(extra: props),
                event(uid: 'second', extra: props),
              ],
            ),
            limits: mode == 'dates'
                ? const IcalendarComponentLimits(maxCalendarExplicitDates: 1)
                : const IcalendarComponentLimits(maxCalendarRuleValues: 1),
          ),
          rejects(IcalendarComponentError.limitExceeded),
        );
      }
    },
  );
  test(
    'candidate work is shared across separate events and zone validation',
    () {
      final first = event(
        timing: 'DTSTART;VALUE=DATE:20261022',
        extra: ['RRULE:FREQ=DAILY;COUNT=1'],
      );
      final second = event(
        uid: 'second',
        timing: 'DTSTART;VALUE=DATE:20261022',
        extra: ['RRULE:FREQ=DAILY;COUNT=1'],
      );
      expect(
        load(
          file(events: [first]),
          limits: const IcalendarComponentLimits(maxCandidates: 1),
        ).events.length,
        1,
      );
      expect(
        () => load(
          file(events: [first, second]),
          limits: const IcalendarComponentLimits(maxCandidates: 1),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      final zone = fixedZone(extra: ['RRULE:FREQ=YEARLY']);
      expect(
        load(
          file(zones: [zone]),
          limits: const IcalendarComponentLimits(maxCandidates: 6231),
        ).events.length,
        1,
      );
      expect(
        () => load(
          file(zones: [zone], events: [first]),
          limits: const IcalendarComponentLimits(maxCandidates: 6231),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
    },
  );
  test('late invalid recurrence returns no partial event calendar or source errors', () {
    expect(
      () => load(
        file(
          events: [
            event(),
            event(
              uid: 'private-uid',
              extra: ['RRULE:FREQ=DAILY;PRIVATE-SECRET=value'],
            ),
          ],
        ),
      ),
      rejects(IcalendarComponentError.unsupportedProperty),
    );
    try {
      dateEvent(['RRULE:FREQ=DAILY;PRIVATE-SECRET=value']);
      fail('Expected rejection');
    } on IcalendarComponentException catch (e) {
      expect(e.toString(), 'IcalendarComponentException(unsupportedProperty)');
    }
  });
}
