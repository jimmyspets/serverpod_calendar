import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'support/icalendar_fixtures.dart' as f;
import 'support/availability_fixtures.dart' as availability;
import 'icalendar_event_override_test.dart' show timed, single, rejects;

List<String> alarm({
  String trigger = 'TRIGGER:-PT5M',
  List<String> extra = const [],
}) => [
  'BEGIN:VALARM',
  'ACTION:DISPLAY',
  'DESCRIPTION:Source reminder',
  trigger,
  ...extra,
  'END:VALARM',
];
List<String> snoozes() => [
  ...alarm(extra: ['UID:original', 'ACKNOWLEDGED:20261020T120000Z']),
  ...alarm(
    trigger: 'TRIGGER;VALUE=DATE-TIME:20261023T100000Z',
    extra: ['UID:snooze', 'RELATED-TO;RELTYPE=SNOOZE:original'],
  ),
];
IcalendarEventCalendar load(
  List<String> extra, {
  String timing = 'DTSTART:20261022T120000Z',
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
  List<String> zones = const [],
}) => f.load(
  f.file(
    events: [f.event(timing: timing, extra: extra)],
    zones: zones,
  ),
  limits: limits,
);
void main() {
  test('event DISPLAY source state signed units annotations repeats and immutable lists round trip unarmed', () {
    final lines = alarm(
      extra: [
        'UID:source-alarm',
        'ACKNOWLEDGED:20261020T120000Z',
        'REPEAT:2',
        'DURATION:PT5M',
      ],
    );
    lines[2] =
        'DESCRIPTION;LANGUAGE=sv;ALTREP="cid:note@example.invalid":Påminnelse';
    final c = load(lines), a = c.events.single.alarms.single;
    expect(a.trigger.relativeDuration!.sign, -1);
    expect(a.trigger.relativeDuration!.minutes, 5);
    expect(a.trigger.related, isNull);
    expect(a.trigger.effectiveRelated, 'START');
    expect(a.description.language, 'sv');
    expect(a.repeat, 2);
    expect(a.acknowledged, DateTime.utc(2026, 10, 20, 12));
    expect(() => c.events.single.alarms.clear(), throwsUnsupportedError);
    final bytes = serializeIcalendarEventCalendar(c);
    expect(
      serializeIcalendarEventCalendar(parseIcalendarEventCalendar(bytes)),
      bytes,
    );
  });
  test('absolute UTC alarms preserve sparse state across DATE UTC and named event profiles', () {
    for (final timing in [
      'DTSTART;VALUE=DATE:20261022',
      'DTSTART:20261022T120000Z',
      'DTSTART;TZID=Europe/Stockholm:20261022T120000',
    ]) {
      final c = load(
        alarm(trigger: 'TRIGGER;VALUE=DATE-TIME:20261023T120000Z'),
        timing: timing,
        zones: timing.contains('TZID')
            ? [f.explicitZone('Europe/Stockholm')]
            : [],
      );
      final a = c.events.single.alarms.single;
      expect(a.trigger.absoluteUtc, DateTime.utc(2026, 10, 23, 12));
      expect(a.trigger.relativeDuration, isNull);
      expect(a.uid, isNull);
      expect(a.repeat, isNull);
    }
  });
  test(
    'END alarms require explicit end or duration including all-day events',
    () {
      for (final timing in [
        'DTSTART:20261022T120000Z',
        'DTSTART;VALUE=DATE:20261022',
      ]) {
        expect(
          () =>
              load(alarm(trigger: 'TRIGGER;RELATED=END:PT0S'), timing: timing),
          rejects(IcalendarComponentError.missing),
        );
        expect(
          load([
            'DURATION:P1D',
            ...alarm(trigger: 'TRIGGER;RELATED=END:PT0S'),
          ], timing: timing).events.single.alarms.length,
          1,
        );
      }
      expect(
        load([
          'DTEND:20261022T130000Z',
          ...alarm(trigger: 'TRIGGER;RELATED=END:-PT5M'),
        ]).events.single.alarms.length,
        1,
      );
    },
  );
  test('own alarm omissions inherit without modifying source and matching lists retain presence at ranges', () {
    final defs = snoozes();
    final c = timed([
      single(':20261023T120000Z', 'DTSTART:20261023T140000Z'),
      single(
        ';RANGE=THISANDFUTURE:20261024T120000Z',
        'DTSTART:20261024T150000Z',
        extra: defs,
      ),
    ], extra: defs);
    final s = c.series.single;
    expect(s.overrides.first.alarms, isEmpty);
    expect(s.alarmsFor(s.overrides.first).length, 2);
    expect(s.overrides.last.alarms.last.snoozeTargetUid, 'original');
    expect(s.alarmsFor(s.master).length, 2);
    expect(() => s.alarmsFor(load([]).events.single), throwsArgumentError);
    expect(
      parseIcalendarEventCalendar(serializeIcalendarEventCalendar(c))
          .series
          .single
          .overrides
          .first
          .alarms,
      isEmpty,
    );
  });
  test('different own alarms and inherited END alarms with point replacements reject', () {
    expect(
      () => timed([
        single(
          ':20261023T120000Z',
          'DTSTART:20261023T140000Z',
          extra: alarm(trigger: 'TRIGGER:-PT10M'),
        ),
      ], extra: alarm()),
      rejects(IcalendarComponentError.unsupportedProperty),
    );
    expect(
      () => timed(
        [single(':20261023T120000Z', 'DTSTART:20261023T140000Z')],
        extra: [
          'DURATION:PT1H',
          ...alarm(trigger: 'TRIGGER;RELATED=END:PT0S'),
        ],
      ),
      rejects(IcalendarComponentError.missing),
    );
  });
  test('snooze links require acknowledged original siblings without chains repeats or detached targets', () {
    expect(load(snoozes()).events.single.alarms.last.isSnooze, isTrue);
    for (final lines in [
      snoozes().where((v) => !v.startsWith('ACKNOWLEDGED:')).toList(),
      snoozes()
          .map(
            (v) => v.replaceFirst(
              'RELTYPE=SNOOZE:original',
              'RELTYPE=SNOOZE:missing',
            ),
          )
          .toList(),
      [
        ...alarm(
          trigger: 'TRIGGER;VALUE=DATE-TIME:20261023T100000Z',
          extra: [
            'UID:s',
            'RELATED-TO;RELTYPE=SNOOZE:s',
            'ACKNOWLEDGED:20261020T120000Z',
          ],
        ),
      ],
    ]) {
      expect(() => load(lines), throwsA(isA<IcalendarComponentException>()));
    }
  });
  test('event alarm limits share file counters and event metadata budgets', () {
    expect(
      () => load([
        ...alarm(),
        ...alarm(),
      ], limits: const IcalendarComponentLimits(maxAlarmsPerEvent: 1)),
      rejects(IcalendarComponentError.limitExceeded),
    );
    final text = f.file(
      events: [
        f.event(uid: 'a', extra: alarm()),
        f.event(uid: 'b', extra: alarm()),
      ],
    );
    expect(
      () => f.load(
        text,
        limits: const IcalendarComponentLimits(maxCalendarAlarms: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => f.load(
        text,
        limits: const IcalendarComponentLimits(maxEventMetadataCodePoints: 20),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    for (final extra in [
      ['REPEAT:101', 'DURATION:PT1S'],
      ['REPEAT:2'],
      ['DURATION:PT1S'],
      ['REPEAT:1', 'DURATION:-PT1S'],
    ]) {
      expect(
        () => load(alarm(extra: extra)),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
  });
  test('unsupported actions nested children and malformed trigger fractions reject', () {
    for (final lines in [
      alarm()
          .map((v) => v.replaceFirst('ACTION:DISPLAY', 'ACTION:EMAIL'))
          .toList(),
      alarm(trigger: 'TRIGGER:PT1.1S'),
      alarm(trigger: 'TRIGGER;VALUE=DATE-TIME:20261023T120000'),
      alarm(extra: ['BEGIN:VALARM', 'END:VALARM']),
    ]) {
      expect(() => load(lines), throwsA(isA<IcalendarComponentException>()));
    }
  });
  test('AVAILABLE and VAVAILABILITY still reject alarm children despite shared event timing helpers', () {
    expect(
      () => availability.read([
        availability.definition(
          openings: [
            availability.opening(extra: ['DURATION:PT1H', ...alarm()]),
          ],
        ),
      ]),
      rejects(IcalendarComponentError.unsupportedComponent),
    );
    expect(
      () => availability.read([
        availability.definition(openings: [alarm().join('\r\n')]),
      ]),
      rejects(IcalendarComponentError.unsupportedComponent),
    );
  });
  test(
    'default START and explicit START matching preserve source presence',
    () {
      final c = timed([
        single(
          ':20261023T120000Z',
          'DTSTART:20261023T140000Z',
          extra: alarm(trigger: 'TRIGGER;RELATED=START:-PT5M'),
        ),
      ], extra: alarm());
      expect(c.events.single.alarms.single.trigger.related, isNull);
      expect(
        c.series.single.overrides.single.alarms.single.trigger.related,
        'START',
      );
      expect(
        utf8.decode(serializeIcalendarEventCalendar(c)),
        contains('RELATED=START'),
      );
    },
  );
}
