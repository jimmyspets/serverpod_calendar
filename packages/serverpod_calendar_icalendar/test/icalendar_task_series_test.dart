import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'icalendar_task_calendar_test.dart' show task, rejects;
import 'support/icalendar_fixtures.dart' show file, explicitZone, fixedZone;

const master = [
  'DTSTART;VALUE=DATE:20261022',
  'DUE;VALUE=DATE:20261023',
  'RRULE:FREQ=DAILY;COUNT=4',
  'SUMMARY;LANGUAGE=sv:Arbete',
  'PRIORITY:3',
];
IcalendarTaskCalendar series(
  List<List<String>> components, {
  List<String> zones = const [],
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => parseIcalendarTaskCalendar(
  utf8.encode(
    file(
      events: [for (final p in components) task(properties: p)],
      zones: zones,
    ),
  ),
  limits: limits,
);
const original = 'RECURRENCE-ID;VALUE=DATE:20261023';

void main() {
  test('explicit DATE and UTC starts move complete timing and round-trip no deadline', () {
    final c = series([
      master,
      [original, 'DTSTART;VALUE=DATE:20261026'],
    ]);
    final again = parseIcalendarTaskCalendar(serializeIcalendarTaskCalendar(c))
        .series
        .single
        .overrides
        .single;
    expect(again.dateTiming!.start!.day, 26);
    expect(again.dateTiming!.effectiveDue, isNull);
    expect(again.component.recurrenceDate!.day, 23);
    final utc = series([
      ['DTSTART:20261022T120000Z', 'DURATION:PT2H', 'RRULE:FREQ=DAILY;COUNT=3'],
      [
        'RECURRENCE-ID:20261023T120000Z',
        'DTSTART:20261024T090000Z',
        'DUE:20261024T100000Z',
      ],
    ]).series.single.overrides.single;
    expect(utc.timedProjection!.start.instant, DateTime.utc(2026, 10, 24, 9));
    expect(utc.timedProjection!.dueInstant, DateTime.utc(2026, 10, 24, 10));
  });
  test(
    'clearing deadline rejects inherited END alarms without dropping them',
    () {
      expect(
        () => series([
          [
            ...master,
            'BEGIN:VALARM',
            'ACTION:DISPLAY',
            'DESCRIPTION:Due',
            'TRIGGER;RELATED=END:-PT5M',
            'END:VALARM',
          ],
          [original, 'DTSTART;VALUE=DATE:20261023'],
        ]),
        rejects(IcalendarComponentError.missing),
      );
    },
  );
  test(
    'RANGE propagates timing while source progress describes only its anchor',
    () {
      final c = series([
        master,
        [
          original.replaceFirst('VALUE=DATE', 'VALUE=DATE;RANGE=THISANDFUTURE'),
          'DTSTART;VALUE=DATE:20261025',
          'STATUS:COMPLETED',
          'PERCENT-COMPLETE:100',
        ],
        ['RECURRENCE-ID;VALUE=DATE:20261024', 'PERCENT-COMPLETE:12'],
      ]);
      final range = c.series.single.overrides.first,
          later = c.series.single.overrides.last;
      expect(range.component.thisAndFuture, isTrue);
      expect(range.component.status, IcalendarTaskStatus.completed);
      expect(later.dateTiming!.start!.day, 26);
      expect(later.dateTiming!.effectiveDue, isNull);
      expect(later.component.status, isNull);
      expect(later.component.percentComplete, 12);
      final again = parseIcalendarTaskCalendar(
        serializeIcalendarTaskCalendar(c),
      ).series.single;
      expect(again.overrides.first.component.thisAndFuture, isTrue);
      expect(again.overrides.last.dateTiming!.start!.day, 26);
    },
  );
  test(
    'RANGE requires complete same-profile timing and rejects THISANDPRIOR',
    () {
      expect(
        () => series([
          master,
          [
            'RECURRENCE-ID;VALUE=DATE;RANGE=THISANDPRIOR:20261023',
            'DTSTART;VALUE=DATE:20261024',
          ],
        ]),
        rejects(IcalendarComponentError.unsupportedParameter),
      );
      expect(
        () => series([
          master,
          [
            'RECURRENCE-ID;VALUE=DATE;RANGE=THISANDFUTURE:20261023',
            'DTSTART:20261024T000000Z',
          ],
        ]),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test('raw omissions survive while timing text and priority inherit', () {
    final c = series([
      master,
      [original, 'STATUS:COMPLETED'],
    ]);
    final linked = c.series.single.overrides.single, raw = linked.component;
    expect(c.tasks.length, 1);
    expect(raw.isOverride, isTrue);
    expect(raw.isUndated, isFalse);
    expect(raw.dateTiming, isNull);
    expect(raw.summary, isNull);
    expect(raw.priority, isNull);
    expect(raw.percentComplete, isNull);
    expect(raw.completed, isNull);
    expect(raw.status, IcalendarTaskStatus.completed);
    expect(linked.dateTiming!.start!.day, 23);
    expect(linked.dateTiming!.effectiveDue!.day, 24);
    expect(linked.summary!.value, 'Arbete');
    expect(linked.priority, 3);
    final again = parseIcalendarTaskCalendar(serializeIcalendarTaskCalendar(c));
    expect(again.series.single.overrides.single.component.dateTiming, isNull);
    expect(() => c.series.clear(), throwsUnsupportedError);
    expect(() => c.series.single.overrides.clear(), throwsUnsupportedError);
  });
  test(
    'independent source progress and version fields do not acquire defaults',
    () {
      for (final status in <String?>[
        null,
        'NEEDS-ACTION',
        'IN-PROCESS',
        'COMPLETED',
        'CANCELLED',
      ]) {
        for (final percent in <int?>[null, 0, 37, 100]) {
          for (final completed in [false, true]) {
            final c = series([
              master,
              [
                original,
                if (status != null) 'STATUS:$status',
                if (percent != null) 'PERCENT-COMPLETE:$percent',
                if (completed) 'COMPLETED:20261020T123456Z',
                'SEQUENCE:2',
                'LAST-MODIFIED:20261019T010203Z',
              ],
            ]);
            final raw = parseIcalendarTaskCalendar(
              serializeIcalendarTaskCalendar(c),
            ).series.single.overrides.single.component;
            expect(raw.status == null, status == null);
            expect(raw.percentComplete, percent);
            expect(
              raw.completed,
              completed ? DateTime.utc(2026, 10, 20, 12, 34, 56) : null,
            );
            expect(raw.created, isNull);
            expect(raw.sequence, 2);
            expect(raw.lastModified, DateTime.utc(2026, 10, 19, 1, 2, 3));
            expect(c.tasks.single.status, isNull);
          }
        }
      }
    },
  );
  test(
    'override before master retains source ordering and master collection',
    () {
      final bytes = utf8.encode(
        file(
          events: [
            task(properties: [original]),
            task(uid: 'other'),
            task(properties: master),
          ],
        ),
      );
      final c = parseIcalendarTaskCalendar(bytes);
      expect(c.tasks.map((v) => v.uid), ['other', 'task@example.invalid']);
      expect(c.series.last.overrides.length, 1);
      expect(serializeIcalendarTaskCalendar(c), bytes);
    },
  );
  test(
    'explicit matching content annotations and alternate deadline form survive',
    () {
      final c = series([
        master,
        [
          original,
          'DTSTART;VALUE=DATE:20261023',
          'DURATION:P1D',
          'SUMMARY;LANGUAGE=sv:Arbete',
          'PRIORITY:3',
        ],
      ]);
      final o = c.series.single.overrides.single;
      expect(o.component.dateTiming!.duration, isNotNull);
      expect(o.component.dateTiming!.due, isNull);
      expect(o.dateTiming!.effectiveDue!.day, 24);
      expect(
        parseIcalendarTaskCalendar(serializeIcalendarTaskCalendar(c))
            .series
            .single
            .overrides
            .single
            .component
            .dateTiming!
            .duration,
        isNotNull,
      );
      expect(
        series([
          [...master.where((p) => !p.startsWith('PRIORITY:'))],
          [original, 'PRIORITY:0'],
        ]).series.single.overrides.single.component.priority,
        0,
      );
    },
  );
  test('due-only inherits; explicit start supplies complete timing', () {
    for (final p in [
      'DTSTART;VALUE=DATE:20261023',
      'DUE;VALUE=DATE:20261024',
    ]) {
      final o = series([
        master,
        [original, p],
      ]).series.single.overrides.single;
      expect(o.dateTiming!.start!.day, 23);
      expect(
        o.dateTiming!.effectiveDue?.day,
        p.startsWith('DTSTART') ? null : 24,
      );
    }
  });
  test('UTC projected deadlines validate explicit repetitions', () {
    final c = series([
      [
        'DTSTART:20261022T120000Z',
        'DUE:20261022T140000Z',
        'RRULE:FREQ=DAILY;COUNT=3',
      ],
      ['RECURRENCE-ID:20261023T120000Z', 'DUE:20261023T140000Z'],
    ]);
    final o = c.series.single.overrides.single;
    expect(o.timedProjection!.dueInstant, DateTime.utc(2026, 10, 23, 14));
    expect(o.component.timedTiming!.start, isNull);
  });
  test('named-zone nominal duration retains DST projection', () {
    final c = series(
      [
        [
          'DTSTART;TZID=Europe/Stockholm:20260327T090000',
          'DURATION:P1D',
          'RRULE:FREQ=DAILY;COUNT=4',
        ],
        [
          'RECURRENCE-ID;TZID=Europe/Stockholm:20260328T090000',
          'DUE;TZID=Europe/Stockholm:20260329T090000',
        ],
      ],
      zones: [explicitZone('Europe/Stockholm')],
    );
    final p = c.series.single.overrides.single.timedProjection!;
    expect(p.dueInstant!.difference(p.start.instant).inHours, 23);
  });
  test(
    'elapsed deadline at later fold does not accept first-fold local DUE',
    () {
      final m = [
        'DTSTART;TZID=Europe/Stockholm:20261024T013000',
        'DURATION:PT2H',
        'RRULE:FREQ=DAILY;COUNT=3',
      ];
      final id = 'RECURRENCE-ID;TZID=Europe/Stockholm:20261025T013000';
      final zones = [explicitZone('Europe/Stockholm')];
      final o = series([
        m,
        [id],
      ], zones: zones).series.single.overrides.single;
      expect(o.timedProjection!.dueInstant, DateTime.utc(2026, 10, 25, 1, 30));
      expect(
        () => series([
          m,
          [id, 'DUE;TZID=Europe/Stockholm:20261025T023000'],
        ], zones: zones),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    },
  );
  test('earlier inclusion is a valid original but exclusions and absent dates reject', () {
    expect(
      series([
        [...master, 'RDATE;VALUE=DATE:20261021'],
        ['RECURRENCE-ID;VALUE=DATE:20261021'],
      ]).series.single.overrides.length,
      1,
    );
    for (final m in [
      master,
      [...master, 'EXDATE;VALUE=DATE:20261023'],
    ]) {
      expect(
        () => series([
          m,
          [m == master ? 'RECURRENCE-ID;VALUE=DATE:20261030' : original],
        ]),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
  });
  test('missing master wrong UID and nonrecurring master reject', () {
    expect(
      () => series([
        [original],
      ]),
      rejects(IcalendarComponentError.missing),
    );
    expect(
      () => parseIcalendarTaskCalendar(
        utf8.encode(
          file(
            events: [
              task(properties: master),
              task(uid: 'other', properties: [original]),
            ],
          ),
        ),
      ),
      rejects(IcalendarComponentError.missing),
    );
    expect(
      () => series([
        [...master.where((p) => !p.startsWith('RRULE:'))],
        [original],
      ]),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test('duplicate originals reject regardless of sequence', () {
    expect(
      () => series([
        master,
        [original],
        [original, 'SEQUENCE:9'],
      ]),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => series([master, master]),
      rejects(IcalendarComponentError.duplicate),
    );
  });
  test('original value type and exact named-zone profile must match', () {
    expect(
      () => series([
        master,
        ['RECURRENCE-ID:20261023T000000Z'],
      ]),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => series(
        [
          ['DTSTART:20261022T120000Z', 'RRULE:FREQ=DAILY;COUNT=3'],
          ['RECURRENCE-ID;TZID=UTC:20261023T120000'],
        ],
        zones: [fixedZone()],
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test('recurrence generators on overrides and RANGE reject explicitly', () {
    for (final p in [
      'RRULE:FREQ=DAILY',
      'RDATE;VALUE=DATE:20261024',
      'EXDATE;VALUE=DATE:20261024',
    ]) {
      expect(
        () => series([
          master,
          [original, p],
        ]),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
    expect(
      () => series([
        master,
        ['RECURRENCE-ID;VALUE=DATE;RANGE=THISANDFUTURE:20261023'],
      ]),
      rejects(IcalendarComponentError.missing),
    );
  });
  test(
    'content differences and clear values stay local even on RANGE anchors',
    () {
      final c = series([
        master,
        [
          original.replaceFirst('VALUE=DATE', 'VALUE=DATE;RANGE=THISANDFUTURE'),
          'DTSTART;VALUE=DATE:20261025',
          'SUMMARY;LANGUAGE=en:Other',
          'DESCRIPTION:',
          'LOCATION:Room',
          'PRIORITY:0',
        ],
        ['RECURRENCE-ID;VALUE=DATE:20261024'],
      ]);
      final anchor = c.series.single.overrides.first,
          later = c.series.single.overrides.last;
      expect(anchor.summary!.value, 'Other');
      expect(anchor.summary!.language, 'en');
      expect(anchor.description!.value, '');
      expect(anchor.location!.value, 'Room');
      expect(anchor.priority, 0);
      expect(later.summary!.value, 'Arbete');
      expect(later.description, isNull);
      expect(later.priority, 3);
      expect(later.dateTiming!.start!.day, 26);
      final again = parseIcalendarTaskCalendar(
        serializeIcalendarTaskCalendar(c),
      ).series.single;
      expect(again.overrides.first.description!.value, '');
      expect(again.overrides.last.component.summary, isNull);
    },
  );
  test('partial changed deadlines still reject', () {
    for (final p in ['DUE;VALUE=DATE:20261025']) {
      expect(
        () => series([
          master,
          [original, p],
        ]),
        rejects(IcalendarComponentError.unsupportedProperty),
        reason: p,
      );
    }
    expect(
      () => series([
        master,
        [original, 'DURATION:P1D'],
      ]),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test(
    'generated gap originals are absent even though explicit values resolve',
    () {
      expect(
        () => series(
          [
            [
              'DTSTART;TZID=Europe/Stockholm:20260328T023000',
              'RRULE:FREQ=DAILY;COUNT=3',
            ],
            ['RECURRENCE-ID;TZID=Europe/Stockholm:20260329T023000'],
          ],
          zones: [explicitZone('Europe/Stockholm')],
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test('file-wide candidate budget is shared across masters', () {
    const limits = IcalendarComponentLimits(maxCandidates: 5);
    final one = series([
      master,
      [original],
    ], limits: limits);
    expect(one.series.single.overrides.length, 1);
    expect(
      () => parseIcalendarTaskCalendar(
        utf8.encode(
          file(
            events: [
              task(properties: master),
              task(properties: [original]),
              task(uid: 'second', properties: master),
              task(uid: 'second', properties: [original]),
              task(uid: 'third', properties: master),
              task(uid: 'third', properties: [original]),
            ],
          ),
        ),
        limits: limits,
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
  test('projected task deadlines cannot reach exclusive event boundary', () {
    expect(
      () => series([
        [
          'DTSTART;VALUE=DATE:20991230',
          'DURATION:P1D',
          'RRULE:FREQ=DAILY;COUNT=2',
        ],
        ['RECURRENCE-ID;VALUE=DATE:20991231'],
      ]),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test(
    'override total metadata and aggregate validation limits fail atomically',
    () {
      final components = [
        master,
        [original],
        ['RECURRENCE-ID;VALUE=DATE:20261024'],
      ];
      expect(
        () => series(
          components,
          limits: const IcalendarComponentLimits(maxOverridesPerTask: 1),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => series(
          components,
          limits: const IcalendarComponentLimits(maxTasks: 2),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => series(
          components,
          limits: const IcalendarComponentLimits(maxValidationOccurrences: 1),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => series(
          components,
          limits: const IcalendarComponentLimits(maxCandidates: 1),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => series(
          components,
          limits: const IcalendarComponentLimits(maxTaskMetadataCodePoints: 20),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => series(
          components,
          limits: const IcalendarComponentLimits(maxOverridesPerTask: 0),
        ),
        throwsArgumentError,
      );
    },
  );
}
