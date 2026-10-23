import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'icalendar_task_calendar_test.dart' show load, rejects;
import 'icalendar_task_series_test.dart' show series, master, original;
import 'support/icalendar_fixtures.dart' show explicitZone;

List<String> alarm({
  String trigger = 'TRIGGER:-PT5M',
  List<String> extra = const [],
}) => [
  'BEGIN:VALARM',
  'ACTION:DISPLAY',
  'DESCRIPTION:Reminder',
  trigger,
  ...extra,
  'END:VALARM',
];
const start = ['DTSTART:20261022T120000Z'];

void main() {
  test('relative trigger and optional source identity acknowledgement annotations survive', () {
    final properties = alarm(
      extra: [
        'UID:alarm@example.invalid',
        'ACKNOWLEDGED:20261020T123456Z',
        'REPEAT:2',
        'DURATION:PT5M',
      ],
    );
    properties[2] = r'DESCRIPTION;LANGUAGE=sv;ALTREP="cid:reminder@example.invalid":Påminnelse\nNu';
    final c = load([...start, ...properties]), a = c.tasks.single.alarms.single;
    expect(a.trigger.relativeDuration!.sign, -1);
    expect(a.trigger.relativeDuration!.minutes, 5);
    expect(a.trigger.related, isNull);
    expect(a.trigger.effectiveRelated, 'START');
    expect(a.trigger.absoluteUtc, isNull);
    expect(a.uid, 'alarm@example.invalid');
    expect(a.acknowledged, DateTime.utc(2026, 10, 20, 12, 34, 56));
    expect(a.repeat, 2);
    expect(a.repeatInterval!.minutes, 5);
    expect(a.description.value, 'Påminnelse\nNu');
    expect(a.description.language, 'sv');
    final bytes = serializeIcalendarTaskCalendar(c),
        again = parseIcalendarTaskCalendar(bytes);
    expect(serializeIcalendarTaskCalendar(again), bytes);
    expect(again.tasks.single.alarms.single.uid, a.uid);
    expect(c.tasks.single.status, isNull);
    expect(c.tasks.single.completed, isNull);
  });
  test('sparse absolute alarm works on undated task without inventing recipient or repeat', () {
    final a = load(alarm(trigger: 'TRIGGER;VALUE=DATE-TIME:20261023T120000Z'))
        .tasks
        .single
        .alarms
        .single;
    expect(a.trigger.absoluteUtc, DateTime.utc(2026, 10, 23, 12));
    expect(a.trigger.relativeDuration, isNull);
    expect(a.trigger.effectiveRelated, isNull);
    expect(a.uid, isNull);
    expect(a.acknowledged, isNull);
    expect(a.repeat, isNull);
    expect(a.repeatInterval, isNull);
  });
  test('relative START END and due-only anchors validate presence across typed tasks', () {
    for (final properties in <List<String>>[
      ['DTSTART;VALUE=DATE:20261022', ...alarm()],
      [
        'DUE;VALUE=DATE:20261023',
        ...alarm(trigger: 'TRIGGER;RELATED=END:PT0S'),
      ],
      [
        ...start,
        'DURATION:P1D',
        ...alarm(trigger: 'TRIGGER;VALUE=DURATION;RELATED=END:+PT1H'),
      ],
      ['DUE:20261023T120000Z', ...alarm(trigger: 'TRIGGER;RELATED=END:-P1D')],
    ]) {
      expect(load(properties).tasks.single.alarms.length, 1);
    }
    final c = load(
      [
        'DTSTART;TZID=Europe/Stockholm:20260328T090000',
        ...alarm(trigger: 'TRIGGER:-P1D'),
      ],
      zones: [explicitZone('Europe/Stockholm')],
    );
    expect(c.tasks.single.alarms.single.trigger.relativeDuration!.days, 1);
    for (final properties in <List<String>>[
      alarm(),
      [...start, ...alarm(trigger: 'TRIGGER;RELATED=END:PT0S')],
      ['DUE:20261023T120000Z', ...alarm()],
    ]) {
      expect(() => load(properties), rejects(IcalendarComponentError.missing));
    }
  });
  test('zero trigger and explicit zero repeats preserve source rather than normalize', () {
    final a = load([
      ...start,
      ...alarm(trigger: 'TRIGGER:-PT0S', extra: ['REPEAT:0', 'DURATION:PT1S']),
    ]).tasks.single.alarms.single;
    expect(a.trigger.relativeDuration!.isZero, isTrue);
    expect(a.trigger.relativeDuration!.sign, -1);
    expect(a.repeat, 0);
    expect(
      load([...start, ...alarm(trigger: 'TRIGGER:PT0S')])
          .tasks
          .single
          .alarms
          .single
          .trigger
          .relativeDuration!
          .sign,
      1,
    );
  });
  test('progress occurrence inherits timing and alarms while raw list stays absent', () {
    final c = series([
      [...master, ...alarm()],
      [original, 'STATUS:COMPLETED'],
    ]);
    final o = c.series.single.overrides.single;
    expect(o.component.alarms, isEmpty);
    expect(o.alarms.length, 1);
    expect(o.component.status, IcalendarTaskStatus.completed);
    expect(
      parseIcalendarTaskCalendar(serializeIcalendarTaskCalendar(c))
          .series
          .single
          .overrides
          .single
          .component
          .alarms,
      isEmpty,
    );
    final explicit = series([
      [...master, ...alarm()],
      [
        original,
        ...alarm(trigger: 'TRIGGER;VALUE=DURATION;RELATED=START:-PT5M'),
      ],
    ]);
    expect(explicit.series.single.overrides.single.component.alarms.length, 1);
  });
  test(
    'explicit occurrence alarm timing state or content differences reject',
    () {
      for (final properties in [
        alarm(trigger: 'TRIGGER:-PT6M'),
        alarm(extra: ['UID:added']),
        alarm(extra: ['ACKNOWLEDGED:20261022T120000Z']),
        alarm(extra: ['REPEAT:0', 'DURATION:PT1S']),
      ]) {
        expect(
          () => series([
            [...master, ...alarm()],
            [original, ...properties],
          ]),
          rejects(IcalendarComponentError.unsupportedProperty),
        );
      }
      expect(
        () => series([
          master,
          [original, ...alarm()],
        ]),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    },
  );
  test(
    'repeat duration pairing count and interval constraints reject whole file',
    () {
      for (final extra in <List<String>>[
        ['REPEAT:2'],
        ['DURATION:PT5M'],
        ['REPEAT:-1', 'DURATION:PT5M'],
        ['REPEAT:2', 'DURATION:PT0S'],
        ['REPEAT:2', 'DURATION:-PT5M'],
        ['REPEAT:101', 'DURATION:PT1S'],
        ['REPEAT:2', 'DURATION:P366D'],
      ]) {
        expect(
          () => load([...start, ...alarm(extra: extra)]),
          throwsA(isA<IcalendarComponentException>()),
        );
      }
    },
  );
  test(
    'required properties singleton duplicates and duplicate alarm UIDs reject',
    () {
      for (final name in [
        'ACTION:DISPLAY',
        'DESCRIPTION:Reminder',
        'TRIGGER:-PT5M',
      ]) {
        expect(
          () => load([...start, ...alarm().where((p) => p != name)]),
          rejects(IcalendarComponentError.missing),
        );
        expect(
          () => load([
            ...start,
            ...alarm(extra: [name]),
          ]),
          rejects(IcalendarComponentError.duplicate),
        );
      }
      expect(
        () => load([
          ...start,
          ...alarm(extra: ['UID:a']),
          ...alarm(extra: ['UID:a']),
        ]),
        rejects(IcalendarComponentError.duplicate),
      );
      expect(
        load([...start, ...alarm(), ...alarm()]).tasks.single.alarms.length,
        2,
      );
    },
  );
  test('strict whole-second UTC trigger acknowledgement and ordinary profile boundaries', () {
    for (final trigger in [
      'TRIGGER;VALUE=DATE-TIME:20261022T120000',
      'TRIGGER;VALUE=DATE-TIME;RELATED=START:20261022T120000Z',
      'TRIGGER;VALUE=DATE-TIME;TZID=UTC:20261022T120000Z',
      'TRIGGER;VALUE=DATE:20261022',
      'TRIGGER;RELATED=OTHER:-PT5M',
      'TRIGGER;VALUE=DATE-TIME:21000101T000000Z',
      'TRIGGER;VALUE=DATE-TIME:20261022T120000.0Z',
      'TRIGGER:PT0.5S',
    ]) {
      expect(
        () => load([...start, ...alarm(trigger: trigger)]),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    for (final value in [
      '20261022T120000',
      '21000101T000000Z',
      '19691231T235959Z',
    ]) {
      expect(
        () => load([
          ...start,
          ...alarm(extra: ['ACKNOWLEDGED:$value']),
        ]),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    expect(
      load(alarm(trigger: 'TRIGGER;VALUE=DATE-TIME:19700101T000000Z'))
          .tasks
          .single
          .alarms
          .single
          .trigger
          .absoluteUtc,
      DateTime.utc(1970),
    );
  });
  test('unsupported actions incomplete snooze proximity nested components and recipients reject', () {
    for (final extra in <List<String>>[
      ['RELATED-TO;RELTYPE=SNOOZE:parent'],
      ['PROXIMITY:ARRIVE'],
      ['ATTENDEE:mailto:a@example.invalid'],
      ['ATTACH:urn:file:1'],
      ['X-PRIVATE:value'],
      ['BEGIN:VLOCATION', 'UID:a', 'END:VLOCATION'],
    ]) {
      expect(
        () => load([...start, ...alarm(extra: extra)]),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    for (final action in ['AUDIO', 'EMAIL', 'X-CUSTOM']) {
      expect(
        () => load([
          ...start,
          ...alarm().map((p) => p == 'ACTION:DISPLAY' ? 'ACTION:$action' : p),
        ]),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
  });
  test('exact bounded magnitude and repeat span use portable arithmetic', () {
    expect(
      load([
        ...start,
        ...alarm(
          trigger: 'TRIGGER:-P366D',
          extra: ['REPEAT:2', 'DURATION:P183D'],
        ),
      ]).tasks.single.alarms.length,
      1,
    );
    for (final trigger in [
      'TRIGGER:P367D',
      'TRIGGER:PT9007199254740991H',
      'TRIGGER:P9007199254740991W',
    ]) {
      expect(
        () => load([...start, ...alarm(trigger: trigger)]),
        rejects(IcalendarComponentError.limitExceeded),
      );
    }
    expect(
      () => load([
        ...start,
        ...alarm(trigger: 'TRIGGER:P2D'),
      ], limits: const IcalendarComponentLimits(maxAlarmDurationDays: 1)),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
  test(
    'component file-wide count and text budgets reject without partial alarms',
    () {
      expect(
        () => load([
          ...start,
          ...alarm(),
          ...alarm(),
        ], limits: const IcalendarComponentLimits(maxAlarmsPerTask: 1)),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => series([
          [...master, ...alarm()],
          [original, ...alarm()],
        ], limits: const IcalendarComponentLimits(maxCalendarAlarms: 1)),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => load(
          [
            ...start,
            ...alarm(extra: ['UID:${'a' * 100}']),
          ],
          limits: const IcalendarComponentLimits(maxTaskMetadataCodePoints: 60),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => load([
          ...start,
          ...alarm(extra: ['REPEAT:2', 'DURATION:PT1S']),
        ], limits: const IcalendarComponentLimits(maxAlarmRepeat: 1)),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => load(
          [],
          limits: const IcalendarComponentLimits(maxCalendarAlarms: 0),
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'alarm lists source properties and nested parameter values are immutable',
    () {
      final a = load([...start, ...alarm()]).tasks.single;
      expect(() => a.alarms.clear(), throwsUnsupportedError);
      expect(
        () => a.alarms.single.source.entries.clear(),
        throwsUnsupportedError,
      );
      expect(
        () => a.alarms.single.trigger.source.parameters.clear(),
        throwsUnsupportedError,
      );
    },
  );
}
