import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'icalendar_display_alarm_test.dart' show alarm, start;
import 'icalendar_task_calendar_test.dart' show load, task, rejects;
import 'icalendar_task_series_test.dart' show series, master, original;
import 'support/icalendar_fixtures.dart' show file;

List<String> base({String uid = 'base', bool acknowledged = true}) => alarm(
  extra: ['UID:$uid', if (acknowledged) 'ACKNOWLEDGED:20261022T120000Z'],
);
List<String> snooze({
  String target = 'base',
  String? uid = 'snooze',
  String trigger = 'TRIGGER;VALUE=DATE-TIME:20261022T120500Z',
  List<String> extra = const [],
}) => alarm(
  trigger: trigger,
  extra: [
    if (uid != null) 'UID:$uid',
    'RELATED-TO;RELTYPE=SNOOZE:$target',
    ...extra,
  ],
);

void main() {
  test(
    'sibling snooze retains source state without creating acknowledgements',
    () {
      final c = load([...start, ...base(), ...snooze()]),
          a = c.tasks.single.alarms;
      expect(a.first.isSnooze, isFalse);
      expect(a.first.snoozeTargetUid, isNull);
      expect(a.last.isSnooze, isTrue);
      expect(a.last.snoozeTargetUid, 'base');
      expect(a.last.uid, 'snooze');
      expect(a.last.trigger.absoluteUtc, DateTime.utc(2026, 10, 22, 12, 5));
      expect(a.last.acknowledged, isNull);
      expect(a.last.repeat, isNull);
      expect(c.tasks.single.completed, isNull);
      final bytes = serializeIcalendarTaskCalendar(c);
      expect(
        serializeIcalendarTaskCalendar(parseIcalendarTaskCalendar(bytes)),
        bytes,
      );
    },
  );
  test(
    'forward sibling reference and exact decoded Unicode UID are supported',
    () {
      final c = load([
        ...start,
        ...snooze(target: r'base\, é'),
        ...base(uid: r'base\, é'),
      ]);
      expect(c.tasks.single.alarms.first.snoozeTargetUid, 'base, é');
      expect(c.tasks.single.alarms.last.uid, 'base, é');
      expect(
        parseIcalendarTaskCalendar(serializeIcalendarTaskCalendar(c))
            .tasks
            .single
            .alarms
            .first
            .isSnooze,
        isTrue,
      );
      expect(
        () => load([...start, ...base(uid: 'Base'), ...snooze()]),
        rejects(IcalendarComponentError.missing),
      );
    },
  );
  test('undated task absolute original and later acknowledgement remain source data', () {
    final p = alarm(
      trigger: 'TRIGGER;VALUE=DATE-TIME:20261022T110000Z',
      extra: ['UID:base', 'ACKNOWLEDGED:20261022T130000Z'],
    );
    final c = load([...p, ...snooze()]);
    expect(c.tasks.single.isUndated, isTrue);
    expect(
      c.tasks.single.alarms.first.acknowledged!.isAfter(
        c.tasks.single.alarms.last.trigger.absoluteUtc!,
      ),
      isTrue,
    );
    expect(c.tasks.single.alarms.last.acknowledged, isNull);
  });
  test('missing own UID target or original source acknowledgement rejects', () {
    expect(
      () => load([...start, ...base(), ...snooze(uid: null)]),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => load([...start, ...snooze()]),
      rejects(IcalendarComponentError.missing),
    );
    expect(
      () => load([...start, ...base(acknowledged: false), ...snooze()]),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => load([...start, ...base(), ...snooze(target: '')]),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test(
    'cross-task and raw override borrowing cannot resolve a snooze target',
    () {
      expect(
        () => parseIcalendarTaskCalendar(
          utf8.encode(
            file(
              events: [
                task(uid: 'a', properties: [...start, ...base()]),
                task(uid: 'b', properties: [...start, ...snooze()]),
              ],
            ),
          ),
        ),
        rejects(IcalendarComponentError.missing),
      );
      expect(
        () => series([
          [...master, ...base(), ...snooze()],
          [original, ...snooze()],
        ]),
        rejects(IcalendarComponentError.missing),
      );
    },
  );
  test('self links chains and cycles reject even with acknowledged nodes', () {
    expect(
      () => load([
        ...start,
        ...snooze(target: 'snooze', extra: ['ACKNOWLEDGED:20261022T120000Z']),
      ]),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => load([
        ...start,
        ...base(),
        ...snooze(extra: ['ACKNOWLEDGED:20261022T120000Z']),
        ...snooze(target: 'snooze', uid: 'second'),
      ]),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => load([
        ...snooze(
          target: 'b',
          uid: 'a',
          extra: ['ACKNOWLEDGED:20261022T120000Z'],
        ),
        ...snooze(
          target: 'a',
          uid: 'b',
          extra: ['ACKNOWLEDGED:20261022T120000Z'],
        ),
      ]),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test(
    'relative and repeating snoozes including explicit zero repeat reject',
    () {
      expect(
        () => load([...start, ...base(), ...snooze(trigger: 'TRIGGER:PT5M')]),
        rejects(IcalendarComponentError.invalidValue),
      );
      for (final count in [0, 1]) {
        expect(
          () => load([
            ...start,
            ...base(),
            ...snooze(extra: ['REPEAT:$count', 'DURATION:PT1M']),
          ]),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
      expect(
        load([
          ...start,
          ...base(),
          ...snooze(extra: ['ACKNOWLEDGED:20261022T120600Z']),
        ]).tasks.single.alarms.last.acknowledged,
        DateTime.utc(2026, 10, 22, 12, 6),
      );
    },
  );
  test(
    'one explicit SNOOZE relation required with strict supported parameters',
    () {
      expect(
        () => load([
          ...start,
          ...base(),
          ...snooze(extra: ['RELATED-TO;RELTYPE=SNOOZE:base']),
        ]),
        rejects(IcalendarComponentError.duplicate),
      );
      for (final relation in [
        'RELATED-TO:base',
        'RELATED-TO;RELTYPE=PARENT:base',
        'RELATED-TO;RELTYPE=SNOOZE;VALUE=TEXT:base',
        'RELATED-TO;RELTYPE=SNOOZE;RELTYPE=SNOOZE:base',
      ]) {
        final properties = snooze().map(
          (p) => p.startsWith('RELATED-TO') ? relation : p,
        );
        expect(
          () => load([...start, ...base(), ...properties]),
          throwsA(isA<IcalendarComponentException>()),
        );
      }
      final c = load([
        ...start,
        ...base(),
        ...snooze().map(
          (p) => p.replaceAll('RELTYPE=SNOOZE', 'RELTYPE=snooze'),
        ),
      ]);
      expect(c.tasks.single.alarms.last.snoozeTargetUid, 'base');
    },
  );
  test(
    'occurrence omission and complete source repetition preserve snooze graph',
    () {
      final alarms = [...base(), ...snooze()];
      final c = series([
        [...master, ...alarms],
        [original, 'PERCENT-COMPLETE:15'],
      ]);
      final o = c.series.single.overrides.single;
      expect(o.component.alarms, isEmpty);
      expect(o.alarms.last.snoozeTargetUid, 'base');
      expect(
        series([
          [...master, ...alarms],
          [original, ...alarms],
        ]).series.single.overrides.single.component.alarms.last.isSnooze,
        isTrue,
      );
      final two = [...base(), ...base(uid: 'other')];
      expect(
        () => series([
          [...master, ...two, ...snooze()],
          [original, ...two, ...snooze(target: 'other')],
        ]),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    },
  );
  test('source target text and sibling components share existing budgets', () {
    final longUid = 'a' * 30;
    const limits = IcalendarComponentLimits(maxTaskMetadataCodePoints: 90);
    expect(
      load([...start, ...base(uid: longUid)], limits: limits).tasks.length,
      1,
    );
    expect(
      () => load([
        ...start,
        ...base(uid: longUid),
        ...snooze(target: longUid),
      ], limits: limits),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load([
        ...start,
        ...base(),
        ...snooze(),
      ], limits: const IcalendarComponentLimits(maxAlarmsPerTask: 1)),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load([
        ...start,
        ...base(),
        ...snooze(),
      ], limits: const IcalendarComponentLimits(maxCalendarAlarms: 1)),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
  test('source list immutability and multiple inert snooze definitions retain order', () {
    final c = load([
      ...start,
      ...base(),
      ...snooze(),
      ...snooze(uid: 'another'),
    ]);
    expect(c.tasks.single.alarms.map((a) => a.uid), [
      'base',
      'snooze',
      'another',
    ]);
    expect(() => c.tasks.single.alarms.clear(), throwsUnsupportedError);
    final relation = c.tasks.single.alarms[1].source.entries
        .whereType<IcalendarSyntaxProperty>()
        .firstWhere((p) => p.canonicalName == 'RELATED-TO');
    expect(
      () => relation.parameters.single.values.clear(),
      throwsUnsupportedError,
    );
  });
}
