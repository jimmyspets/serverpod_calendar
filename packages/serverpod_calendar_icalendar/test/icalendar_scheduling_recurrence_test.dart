import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart' show explicitZone, fixedZone;
import 'support/scheduling_fixtures.dart';

String component(List<String> fields) =>
    ['BEGIN:VEVENT', ...fields, 'END:VEVENT'].join('\r\n');
String multiple(
  String method,
  List<List<String>> events, {
  List<String> zones = const [],
}) => message(
  method,
  events.first,
  zones: zones,
  components: events.skip(1).map(component).toList(),
);
List<String> instance(String method, String identity, {bool future = false}) =>
    [
      ...minimal(method),
      'RECURRENCE-ID${future ? ';RANGE=THISANDFUTURE' : ''}:$identity',
    ];

void main() {
  test('iTIP observance exclusivity follows verified erratum without narrowing ordinary source', () {
    final fields = minimal('REQUEST')
        .map((p) => p == start ? 'DTSTART;TZID=UTC:20261022T120000' : p)
        .toList();
    final zone = fixedZone(
      extra: [
        'RRULE:FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1',
        'RDATE:19010101T000000',
      ],
    );
    final source = message('REQUEST', fields, zones: [zone]);
    expect(() => load(source), rejects(IcalendarComponentError.invalidValue));
    final ordinary = parseIcalendarEventCalendar(
      utf8.encode(source.replaceFirst('METHOD:REQUEST\r\n', '')),
    );
    expect(ordinary.timeZones.keys, ['UTC']);
    final ruleOnly = message(
      'REQUEST',
      fields,
      zones: [
        fixedZone(extra: ['RRULE:FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1']),
      ],
    );
    expect(load(ruleOnly).timeZones.keys, ['UTC']);
  });
  for (final method in ['PUBLISH', 'REQUEST', 'REPLY', 'CANCEL']) {
    test('$method accepts an untrusted detached instance without a master', () {
      final fields = instance(method, '20261023T120000Z');
      final source = message(method, fields), value = load(source);
      expect(value.events, hasLength(1));
      final own = value.events.single;
      expect(own.isOverride, isTrue);
      expect(own.originalTime!.instant, DateTime.utc(2026, 10, 23, 12));
      expect(own.isThisAndFuture, isFalse);
      expect(own.recurrence, isNull);
      expect(own.startTime == null, method == 'REPLY' || method == 'CANCEL');
      expect(utf8.decode(serializeIcalendarSchedulingMessage(value)), source);
    });
    test(
      '$method preserves multiple detached originals and per-component versions',
      () {
        final fields = [
          instance(method, '20261023T120000Z'),
          instance(method, '20261024T120000Z')
              .map(
                (p) => p == stamp
                    ? 'DTSTAMP:20261024T100000Z'
                    : p == 'SEQUENCE:2'
                    ? 'SEQUENCE:3'
                    : p,
              )
              .toList(),
        ];
        final source = multiple(method, fields), value = load(source);
        expect(value.events.map((e) => e.originalTime!.instant), [
          DateTime.utc(2026, 10, 23, 12),
          DateTime.utc(2026, 10, 24, 12),
        ]);
        expect(value.events[0].stamp, DateTime.utc(2026, 10, 22, 10));
        expect(value.events[1].stamp, DateTime.utc(2026, 10, 24, 10));
        expect(() => value.events.clear(), throwsUnsupportedError);
        expect(utf8.decode(serializeIcalendarSchedulingMessage(value)), source);
      },
    );
  }
  test('DATE recurrence preserves WKST, earlier inclusions, repeated lists and exclusions', () {
    final fields =
        minimal('REQUEST')
            .map((p) => p == start ? 'DTSTART;VALUE=DATE:20261019' : p)
            .toList()
          ..addAll([
            'RRULE:FREQ=WEEKLY;COUNT=4;BYDAY=MO;WKST=SU',
            'RDATE;VALUE=DATE:20261018',
            'RDATE;VALUE=DATE:20261021',
            'EXDATE;VALUE=DATE:20261026',
            'EXDATE;VALUE=DATE:20261102',
          ]);
    final source = message('REQUEST', fields), value = load(source);
    final set = value.events.single.recurrence!.dateSet!;
    expect(set.rule!.weekStart, Weekday.sunday);
    expect(set.rule!.count, 4);
    expect(set.inclusions, [
      CalendarDate(year: 2026, month: 10, day: 18),
      CalendarDate(year: 2026, month: 10, day: 21),
    ]);
    expect(set.exclusions, hasLength(2));
    expect(utf8.decode(serializeIcalendarSchedulingMessage(value)), source);
  });
  test(
    'UTC recurrence preserves PERIOD end/duration and source FREQ-first output',
    () {
      final fields = [
        ...minimal('REQUEST'),
        'RRULE:COUNT=3;FREQ=DAILY',
        'RDATE;VALUE=PERIOD:20261025T120000Z/PT2H,20261026T120000Z/20261026T150000Z',
        'EXDATE:20261023T120000Z',
      ];
      final source = message('REQUEST', fields), value = load(source);
      final set = value.events.single.recurrence!.timedSet!;
      expect(set.periods.values.first.duration!.hours, 2);
      expect(
        set.periods.values.last.end!.instant,
        DateTime.utc(2026, 10, 26, 15),
      );
      final output = utf8.decode(serializeIcalendarSchedulingMessage(value));
      expect(output, contains('RRULE:FREQ=DAILY;COUNT=3'));
      expect(
        (value.events.single.source.entries
                .whereType<IcalendarSyntaxProperty>()
                .singleWhere((p) => p.canonicalName == 'RRULE'))
            .value,
        'COUNT=3;FREQ=DAILY',
      );
      expect(
        load(output).events.single.recurrence!.timedSet!.periods,
        hasLength(2),
      );
    },
  );
  test('named-zone master and detached fold identity preserve civil meaning and RANGE', () {
    final fields =
        minimal('REQUEST')
            .map(
              (p) => p == start
                  ? 'DTSTART;TZID=America/New_York:20261101T013000'
                  : p,
            )
            .toList()
          ..addAll(['DURATION:PT1H', 'RRULE:FREQ=DAILY;COUNT=3']);
    final own =
        minimal('REQUEST')
            .map(
              (p) => p == start
                  ? 'DTSTART;TZID=America/New_York:20261102T020000'
                  : p,
            )
            .toList()
          ..add(
            'RECURRENCE-ID;TZID=America/New_York;RANGE=THISANDFUTURE:20261101T013000',
          );
    final source = multiple(
      'REQUEST',
      [fields, own],
      zones: [explicitZone('America/New_York')],
    );
    final value = load(source);
    expect(
      value.events[0].recurrence!.timedSet!.start.zoneId,
      'America/New_York',
    );
    expect(
      value.events[1].originalTime!.instant,
      DateTime.utc(2026, 11, 1, 5, 30),
    );
    expect(value.events[1].isThisAndFuture, isTrue);
    expect(
      load(utf8.decode(serializeIcalendarSchedulingMessage(value)))
          .events[1]
          .originalTime,
      value.events[1].originalTime,
    );
    final detached = message(
      'CANCEL',
      [
        ...minimal('CANCEL'),
        'RECURRENCE-ID;TZID=America/New_York:20261101T013000',
      ],
      zones: [explicitZone('America/New_York')],
    );
    expect(load(detached).events.single.startTime, isNull);
    expect(
      load(detached).events.single.originalTime!.zoneId,
      'America/New_York',
    );
  });
  test(
    'DATE detached cancellation and future source state do not invent timing',
    () {
      final source = message('CANCEL', [
        ...minimal('CANCEL'),
        'RECURRENCE-ID;VALUE=DATE;RANGE=THISANDFUTURE:20261023',
      ]);
      final value = load(source), own = value.events.single;
      expect(own.originalDate, CalendarDate(year: 2026, month: 10, day: 23));
      expect(own.isThisAndFuture, isTrue);
      expect(own.startDate, isNull);
      expect(own.dateSpan, isNull);
      expect(utf8.decode(serializeIcalendarSchedulingMessage(value)), source);
    },
  );
  test(
    'source components do not inherit text, timing, versions or reply results',
    () {
      final source = multiple('REPLY', [
        [
          ...minimal('REPLY'),
          'SUMMARY:Master',
          'SEQUENCE:7',
          'REQUEST-STATUS:2.0;Success',
        ],
        instance('REPLY', '20261023T120000Z'),
      ]);
      final value = load(source), own = value.events[1];
      expect(own.summary, isNull);
      expect(own.startTime, isNull);
      expect(own.sequence, isNull);
      expect(own.requestStatuses, isEmpty);
      expect(value.events[0].sequence, 7);
      expect(utf8.decode(serializeIcalendarSchedulingMessage(value)), source);
    },
  );
  test('parsing does not assert incoming originals belong to an incoming master rule', () {
    final source = multiple('REQUEST', [
      [...minimal('REQUEST'), 'RRULE:FREQ=DAILY;COUNT=2'],
      instance('REQUEST', '20261029T120000Z'),
    ]);
    final value = load(source);
    expect(
      value.events[1].originalTime!.instant,
      DateTime.utc(2026, 10, 29, 12),
    );
    // Reconciliation needs trusted prior state; ordinary file import stays strict.
    expect(
      () => parseIcalendarEventCalendar(
        utf8.encode(source.replaceFirst('METHOD:REQUEST\r\n', '')),
      ),
      rejects(),
    );
  });
  test(
    'one source UID, one master and unique original/range keys are enforced',
    () {
      for (final method in ['PUBLISH', 'REQUEST', 'REPLY', 'CANCEL']) {
        expect(
          () => load(multiple(method, [minimal(method), minimal(method)])),
          rejects(IcalendarComponentError.duplicate),
        );
        final own = instance(method, '20261023T120000Z');
        expect(
          () => load(multiple(method, [own, own])),
          rejects(IcalendarComponentError.duplicate),
        );
        expect(
          () => load(
            multiple(method, [
              minimal(method),
              own
                  .map((p) => p == uid ? 'UID:other@example.invalid' : p)
                  .toList(),
            ]),
          ),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
      final value = load(
        multiple('CANCEL', [
          instance('CANCEL', '20261023T120000Z'),
          instance('CANCEL', '20261023T120000Z', future: true),
        ]),
      );
      expect(value.events, hasLength(2));
      expect(value.events.map((e) => e.isThisAndFuture), [false, true]);
    },
  );
  test('unresolved timing profiles, identities and unsupported RANGE values reject', () {
    for (final identity in [
      'RECURRENCE-ID:20261023T120000',
      'RECURRENCE-ID:21000101T000000Z',
      'RECURRENCE-ID:20261023T120000.001Z',
      'RECURRENCE-ID;RANGE=THISANDPRIOR:20261023T120000Z',
      'RECURRENCE-ID;TZID=UTC:20261023T120000',
    ]) {
      expect(
        () => load(message('CANCEL', [...minimal('CANCEL'), identity])),
        rejects(),
      );
    }
    expect(
      () => load(
        message('REQUEST', [
          ...minimal('REQUEST'),
          'RECURRENCE-ID;VALUE=DATE:20261023',
        ]),
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
    final master = minimal('REQUEST')
        .map((p) => p == start ? 'DTSTART;VALUE=DATE:20261022' : p)
        .toList();
    expect(
      () => load(
        multiple('REQUEST', [master, instance('REQUEST', '20261023T120000Z')]),
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => load(
        message(
          'CANCEL',
          [
            ...minimal('CANCEL'),
            'RECURRENCE-ID;TZID=US/Eastern:20261101T013000',
          ],
          zones: [explicitZone('America/New_York')],
        ),
      ),
      rejects(IcalendarComponentError.missing),
    );
  });
  test('pattern constraints stay distinct from detached identity', () {
    for (final property in [
      'RRULE:FREQ=DAILY',
      'RDATE:20261024T120000Z',
      'EXDATE:20261024T120000Z',
    ]) {
      expect(
        () => load(message('CANCEL', [...minimal('CANCEL'), property])),
        rejects(IcalendarComponentError.missing),
      );
      expect(
        () => load(
          message('REQUEST', [
            ...instance('REQUEST', '20261023T120000Z'),
            property,
          ]),
        ),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
    expect(
      () => load(
        message('REQUEST', [
          ...minimal('REQUEST'),
          'RRULE:FREQ=DAILY;COUNT=2;UNTIL=20261024T120000Z',
        ]),
      ),
      rejects(),
    );
    expect(
      () => load(
        message('REQUEST', [
          ...minimal('REQUEST'),
          'RDATE;VALUE=DATE:20261024',
        ]),
      ),
      rejects(),
    );
  });
  test('message/component/override/explicit/work/metadata/output budgets fail atomically', () {
    final rows = [
      instance('CANCEL', '20261023T120000Z'),
      instance('CANCEL', '20261024T120000Z'),
    ];
    expect(
      () => load(
        multiple('CANCEL', rows),
        limits: const IcalendarComponentLimits(maxEvents: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        multiple('CANCEL', rows),
        limits: const IcalendarComponentLimits(maxOverridesPerEvent: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        message('REQUEST', [
          ...minimal('REQUEST'),
          'RDATE:20261024T120000Z',
          'RDATE:20261025T120000Z',
        ]),
        limits: const IcalendarComponentLimits(maxCalendarExplicitDates: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        message('REQUEST', [
          ...minimal('REQUEST'),
          'RRULE:FREQ=YEARLY;BYMONTH=10;BYMONTHDAY=22',
        ]),
        limits: const IcalendarComponentLimits(maxCandidates: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        multiple('CANCEL', [
          for (final row in rows) [...row, 'DESCRIPTION:${'x' * 100}'],
        ]),
        limits: const IcalendarComponentLimits(maxEventMetadataCodePoints: 200),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    final value = load(multiple('CANCEL', rows));
    expect(
      () => serializeIcalendarSchedulingMessage(
        value,
        syntaxLimits: const IcalendarSyntaxLimits(maxBytes: 40),
      ),
      throwsA(isA<IcalendarSyntaxException>()),
    );
  });
}
