@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';

import 'invitation_occurrence_values_test.dart' show zoneSource;

typedef Own = (int, int, bool, int?);

String raw({
  bool date = false,
  String? zone,
  List<Own> own = const [],
  List<String> extra = const [],
  int? sequence = 2,
  String? rule = 'FREQ=DAILY;COUNT=8',
  String prefix = '203001',
  String time = '090000',
  int startDay = 1,
  bool ownClaims = true,
}) {
  String value(int day) =>
      '$prefix${day.toString().padLeft(2, '0')}${date ? '' : 'T$time${zone == null ? 'Z' : ''}'}';
  String prop(String name, int day, {bool future = false}) =>
      '$name${date
          ? ';VALUE=DATE'
          : zone == null
          ? ''
          : ';TZID=$zone'}${future ? ';RANGE=THISANDFUTURE' : ''}:${value(day)}';
  List<String> claims() => [
    'ORGANIZER;CN=Organizer:mailto:organizer@example.invalid',
    'ATTENDEE;CN=Alice;ROLE=REQ-PARTICIPANT:mailto:alice@example.invalid',
  ];
  return [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Synthetic published bundle//EN',
    'METHOD:REQUEST',
    if (zone != null) zoneSource(zone),
    'BEGIN:VEVENT',
    'UID:published@example.invalid',
    'DTSTAMP:20260101T000000Z',
    if (sequence != null) 'SEQUENCE:$sequence',
    prop('DTSTART', startDay),
    if (rule != null) 'RRULE:$rule',
    'SUMMARY:Master',
    'DESCRIPTION:Private retained text',
    ...claims(),
    ...extra,
    'END:VEVENT',
    for (final o in own) ...[
      'BEGIN:VEVENT',
      'UID:published@example.invalid',
      'DTSTAMP:20260101T000000Z',
      if (o.$4 != null) 'SEQUENCE:${o.$4}',
      prop('RECURRENCE-ID', o.$1, future: o.$3),
      prop('DTSTART', o.$2),
      'SUMMARY:Own ${o.$1}',
      if (ownClaims) ...claims(),
      'END:VEVENT',
    ],
    'END:VCALENDAR',
    '',
  ].join('\r\n');
}

IcalendarSchedulingMessage parse(String text) =>
    parseIcalendarSchedulingMessage(
      utf8.encode(text),
      limits: const IcalendarComponentLimits(maxOverridesPerEvent: 128),
    );
CalendarEventTiming point(
  int day, {
  bool date = false,
  String? zone,
  int year = 2030,
  int month = 1,
  int hour = 9,
  int minute = 0,
}) => CalendarEventTiming(
  kind: date
      ? CalendarEventTimeKind.date
      : zone == null
      ? CalendarEventTimeKind.utc
      : CalendarEventTimeKind.zoned,
  zoneId: zone,
  start: CalendarEventCivil(
    year: year,
    month: month,
    day: day,
    hour: date ? 0 : hour,
    minute: date ? 0 : minute,
  ),
);
CalendarPublishedRangeCancellation cancel(
  IcalendarSchedulingMessage basis, {
  CalendarEventTiming? original,
  int sequence = 20,
  DateTime? stamp,
  int minimumSequence = 0,
  DateTime? minimumStamp,
  int maxTargets = 64,
  int maxBytes = 524288,
  int maxWork = 200000,
  RecurrenceWorkBudget? work,
}) => projectPublishedRangeCancellation(
  basis: basis.source,
  originalStart: original ?? point(3),
  sequence: sequence,
  stamp: stamp ?? DateTime.utc(2026, 2),
  minimumSequence: minimumSequence,
  minimumStamp: minimumStamp,
  maxTargets: maxTargets,
  maxBytes: maxBytes,
  maxCandidateWork: maxWork,
  sharedWorkBudget: work,
);

void main() {
  for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
    final date = profile == 'date',
        zone = profile == 'date' || profile == 'utc' ? null : profile;
    test(
      '$profile suffix bundle follows originals across moved singles and ranges',
      () {
        final basis = parse(
          raw(
            date: date,
            zone: zone,
            own: [
              (2, 7, false, 15),
              (3, 4, false, 3),
              (4, 1, false, 4),
              (5, 6, true, 5),
            ],
          ),
        );
        final before = serializeIcalendarSchedulingMessage(basis);
        final result = cancel(
          basis,
          original: point(3, date: date, zone: zone),
        );
        expect(
          result.requiredAfterSequence,
          15,
        ); // includes the earlier high version
        expect(result.targets.map((t) => t.originalStart.start.day), [3, 4, 5]);
        expect(result.targets.map((t) => t.isThisAndFuture), [
          true,
          false,
          true,
        ]);
        expect(result.message.method, IcalendarSchedulingMethod.cancel);
        expect(
          result.message.events.every(
            (e) =>
                e.sequence == 20 && e.status == IcalendarEventStatus.cancelled,
          ),
          isTrue,
        );
        expect(
          result.message.events.every(
            (e) =>
                e.startDate == null &&
                e.startTime == null &&
                e.summary == null &&
                e.duration == null,
          ),
          isTrue,
        );
        expect(
          result.message.events.every(
            (e) =>
                e.participants.organizer!.commonName == 'Organizer' &&
                e.participants.attendees.single.commonName == 'Alice',
          ),
          isTrue,
        );
        expect(result.message.timeZones.keys, zone == null ? isEmpty : [zone]);
        final bytes = serializeIcalendarSchedulingMessage(result.message);
        final again = parseIcalendarSchedulingMessage(bytes);
        expect(again.events.map((e) => e.isThisAndFuture), [true, false, true]);
        expect(
          bytes,
          serializeIcalendarSchedulingMessage(
            cancel(
              basis,
              original: point(3, date: date, zone: zone),
            ).message,
          ),
        );
        expect(serializeIcalendarSchedulingMessage(basis), before);
        expect(
          identical(
            result.targets.first.originalStart,
            result.targets.first.originalStart,
          ),
          isFalse,
        );
        expect(() => result.targets.clear(), throwsUnsupportedError);
        expect(() => result.message.events.clear(), throwsUnsupportedError);
      },
    );
  }
  for (final future in [false, true]) {
    test(
      'anchor ${future ? 'range' : 'single'} is represented exactly once',
      () {
        final result = cancel(parse(raw(own: [(3, 4, future, 3)])));
        expect(result.targets, hasLength(1));
        expect(result.message.events.single.isThisAndFuture, isTrue);
      },
    );
  }
  test('unsorted source exceptions produce sorted target manifest', () {
    expect(
      cancel(parse(raw(own: [(6, 1, false, 6), (4, 8, true, 4)]))).targets
          .map((t) => t.originalStart.start.day),
      [3, 4, 6],
    );
  });
  test('omitted inherited claims use the validated master claims', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(raw(own: [(4, 5, false, 3)], ownClaims: false)),
    );
    final before = serializeIcalendarSyntax(basis);
    final result = projectPublishedRangeCancellation(
      basis: basis,
      originalStart: point(3),
      sequence: 20,
      stamp: DateTime.utc(2026, 2),
    );
    expect(
      result.message.events.last.participants.attendees.single.address,
      'mailto:alice@example.invalid',
    );
    expect(serializeIcalendarSyntax(basis), before);
  });
  for (final sequence in [0, 2, 19, 20, 2147483647]) {
    test('optional floor rejects sequence $sequence at or below it', () {
      expect(
        () =>
            cancel(parse(raw()), sequence: sequence, minimumSequence: sequence),
        throwsArgumentError,
      );
    });
  }
  test('explicit zero basis versions remain zero and require advancement', () {
    final basis = parse(raw(sequence: 0));
    expect(cancel(basis, sequence: 1).requiredAfterSequence, 0);
    expect(basis.events.single.sequence, 0);
  });
  test('highest portable version can be emitted without wrapping', () {
    expect(
      cancel(
        parse(raw()),
        sequence: eventMaxSequence,
      ).message.events.single.sequence,
      eventMaxSequence,
    );
  });
  for (final floor in [-1, 2147483648]) {
    test('invalid historical floor $floor rejects', () {
      expect(
        () => cancel(parse(raw()), minimumSequence: floor),
        throwsArgumentError,
      );
    });
  }
  test('source and optional stamp bounds are independent of sequence', () {
    final basis = parse(
      raw().replaceFirst(
        'DTSTAMP:20260101T000000Z',
        'DTSTAMP:20260301T000000Z',
      ),
    );
    expect(() => cancel(basis), throwsArgumentError);
    final stamp = DateTime.utc(2026, 4);
    expect(
      cancel(basis, stamp: stamp, minimumStamp: stamp).minimumStamp,
      stamp,
    );
    expect(
      () => cancel(basis, stamp: DateTime.utc(2026, 3), minimumStamp: stamp),
      throwsArgumentError,
    );
  });
  for (final stamp in [
    DateTime.utc(2026, 2, 1, 0, 0, 0, 1),
    DateTime.utc(2100),
    DateTime.utc(1969, 12, 31),
    DateTime(2026, 2),
  ]) {
    test(
      'invalid or non-UTC candidate stamp ${stamp.toIso8601String()} rejects',
      () {
        expect(() => cancel(parse(raw()), stamp: stamp), throwsArgumentError);
      },
    );
  }
  for (final mode in ['master', 'own']) {
    test('missing $mode SEQUENCE is never invented', () {
      expect(
        () => cancel(
          parse(
            raw(
              sequence: mode == 'master' ? null : 2,
              own: mode == 'own' ? [(4, 5, false, null)] : [],
            ),
          ),
        ),
        throwsArgumentError,
      );
    });
  }
  test(
    'a changed explicit participant claim rejects without roster rewriting',
    () {
      final text = raw(own: [(4, 5, false, 3)]);
      final index = text.lastIndexOf('CN=Alice');
      final changed = text.replaceRange(
        index,
        index + 'CN=Alice'.length,
        'CN=Different',
      );
      expect(() => cancel(parse(changed)), throwsArgumentError);
    },
  );
  test('a different explicit organizer rejects', () {
    final text = raw(own: [(4, 5, false, 3)]);
    final index = text.lastIndexOf('mailto:organizer@example.invalid');
    expect(
      () => cancel(
        parse(
          text.replaceRange(
            index,
            index + 'mailto:organizer@example.invalid'.length,
            'mailto:other@example.invalid',
          ),
        ),
      ),
      throwsArgumentError,
    );
  });
  test('nonrecurring and inactive bases reject', () {
    expect(() => cancel(parse(raw(rule: null))), throwsArgumentError);
    expect(
      () => projectPublishedRangeCancellation(
        basis: parseIcalendarSyntax(
          utf8.encode(raw(extra: ['STATUS:CANCELLED'])),
        ),
        originalStart: point(3),
        sequence: 20,
        stamp: DateTime.utc(2026, 2),
      ),
      throwsArgumentError,
    );
  });
  test('a CANCEL basis is not converted into REQUEST', () {
    final text = raw(extra: ['STATUS:CANCELLED'])
        .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL');
    expect(() => cancel(parse(text)), throwsArgumentError);
  });
  test('detached REQUEST basis rejects', () {
    final source = parse(raw(own: [(4, 5, false, 3)])).source.components.single;
    var skipped = false;
    final doc = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(source.name, [
        for (final e in source.entries)
          if (e is IcalendarSyntaxComponent &&
              e.canonicalName == 'VEVENT' &&
              !skipped)
            ...(() {
              skipped = true;
              return <IcalendarSyntaxEntry>[];
            })()
          else
            e,
      ]),
    ]);
    expect(
      () => cancel(validateIcalendarSchedulingMessage(doc)),
      throwsArgumentError,
    );
  });
  test(
    'single and future components at one original are outside the profile',
    () {
      expect(
        () => cancel(parse(raw(own: [(4, 5, false, 3), (4, 6, true, 4)]))),
        throwsArgumentError,
      );
    },
  );
  test('exact zone identifier is required despite equivalent offsets', () {
    expect(
      () => cancel(
        parse(raw(zone: 'US/Eastern')),
        original: point(3, zone: 'America/New_York'),
      ),
      throwsArgumentError,
    );
  });
  test('DATE and UTC originals cannot be interchanged', () {
    expect(
      () => cancel(parse(raw(date: true)), original: point(3)),
      throwsArgumentError,
    );
  });
  test('original is a point, never a span or a fractional clock', () {
    final basis = parse(raw());
    expect(
      () => cancel(
        basis,
        original: point(3).copyWith(duration: CalendarEventDuration(hours: 1)),
      ),
      throwsArgumentError,
    );
    expect(
      () => cancel(
        basis,
        original: point(3)
            .copyWith(start: point(3).start.copyWith(microsecond: 1)),
      ),
      throwsArgumentError,
    );
  });
  test('excluded or absent originals reject', () {
    expect(
      () => cancel(parse(raw(extra: ['EXDATE:20300103T090000Z']))),
      throwsArgumentError,
    );
    expect(
      () => cancel(parse(raw()), original: point(15)),
      throwsArgumentError,
    );
  });
  test('earlier inclusion is a valid original without changing DTSTART', () {
    final basis = parse(raw(startDay: 3, extra: ['RDATE:20300101T090000Z']));
    expect(
      cancel(basis, original: point(1)).targets.single.originalStart.start.day,
      1,
    );
    expect(basis.events.single.startTime!.civil.date.day, 3);
  });
  test(
    'PERIOD addition uses its start identity and does not change its form',
    () {
      final basis = parse(
        raw(extra: ['RDATE;VALUE=PERIOD:20300110T090000Z/PT2H']),
      );
      final before = serializeIcalendarSchedulingMessage(basis);
      expect(
        cancel(
          basis,
          original: point(10),
        ).targets.single.originalStart.start.day,
        10,
      );
      expect(serializeIcalendarSchedulingMessage(basis), before);
    },
  );
  for (final day in [31, 27]) {
    test(
      'explicit named-zone ${day == 31 ? 'gap' : 'fold'} original preserves civil identity',
      () {
        final gap = day == 31, month = gap ? 3 : 10;
        final basis = parse(
          raw(
            zone: 'Europe/Stockholm',
            prefix: gap ? '203003' : '203010',
            startDay: day - 1,
            time: '023000',
            rule: 'FREQ=DAILY;COUNT=3',
            extra: [
              'RDATE;TZID=Europe/Stockholm:2030${month.toString().padLeft(2, '0')}${day}T023000',
            ],
          ),
        );
        final result = cancel(
          basis,
          original: point(
            day,
            month: month,
            hour: 2,
            minute: 30,
            zone: 'Europe/Stockholm',
          ),
        );
        expect(result.message.events.single.originalTime!.civil.hour, 2);
        expect(result.message.events.single.originalTime!.civil.minute, 30);
      },
    );
  }
  test('a generated nonexistent local original is absent unless explicitly included', () {
    final basis = parse(
      raw(
        zone: 'Europe/Stockholm',
        prefix: '203003',
        startDay: 30,
        time: '023000',
        rule: 'FREQ=DAILY;COUNT=3',
      ),
    );
    expect(
      () => cancel(
        basis,
        original: point(
          31,
          month: 3,
          hour: 2,
          minute: 30,
          zone: 'Europe/Stockholm',
        ),
      ),
      throwsArgumentError,
    );
  });
  test(
    'ordinary last DATE supports an exclusive 2100 end but not 2100 identity',
    () {
      final basis = parse(
        raw(
          date: true,
          prefix: '209912',
          startDay: 30,
          rule: 'FREQ=DAILY;COUNT=2',
          extra: ['DTEND;VALUE=DATE:20991231'],
        ),
      );
      expect(
        cancel(
          basis,
          original: point(31, date: true, year: 2099, month: 12),
        ).targets,
        hasLength(1),
      );
      expect(
        () => cancel(basis, original: point(1, date: true, year: 2100)),
        throwsArgumentError,
      );
    },
  );
  test('generated anchor counts toward target capacity without dropping exceptions', () {
    final basis = parse(raw(own: [(4, 5, false, 3), (5, 6, true, 4)]));
    expect(
      () => cancel(basis, maxTargets: 2),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(cancel(basis, maxTargets: 3).targets, hasLength(3));
  });
  test('64 source exceptions plus a new earlier anchor cannot become 65 targets', () {
    final text = raw(rule: 'FREQ=DAILY;COUNT=100');
    final ending = text.indexOf('END:VCALENDAR');
    final events = <String>[];
    for (var i = 1; i <= 64; i++) {
      final d = DateTime.utc(2030, 1, 1).add(Duration(days: i));
      final v =
          '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T090000Z';
      events.add(
        'BEGIN:VEVENT\r\nUID:published@example.invalid\r\nDTSTAMP:20260101T000000Z\r\nSEQUENCE:3\r\nRECURRENCE-ID:$v\r\nDTSTART:$v\r\nSUMMARY:Own\r\nORGANIZER;CN=Organizer:mailto:organizer@example.invalid\r\nATTENDEE;CN=Alice;ROLE=REQ-PARTICIPANT:mailto:alice@example.invalid\r\nEND:VEVENT\r\n',
      );
    }
    final basis = parse(text.replaceRange(ending, ending, events.join()));
    expect(
      () => cancel(basis, original: point(1)),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('caller-parsed large input is bounded again before projection', () {
    final basis = parse(raw(extra: ['COMMENT:${'x' * 4000}']));
    expect(
      () => cancel(basis, maxBytes: 1000),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('shared work is cumulative and cannot weaken selected limits', () {
    final basis = parse(raw()),
        measured = RecurrenceWorkBudget(maxWork: 200000);
    cancel(basis, work: measured);
    final used = measured.used;
    expect(used, greaterThan(0));
    cancel(basis, work: measured);
    expect(measured.used, greaterThan(used));
    final bounded = RecurrenceWorkBudget(maxWork: used);
    cancel(basis, work: bounded);
    expect(
      () => cancel(basis, work: bounded),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => cancel(basis, maxWork: 10, work: RecurrenceWorkBudget(maxWork: 11)),
      throwsArgumentError,
    );
  });
  test('tiny aggregate work never produces a partial bundle', () {
    expect(
      () => cancel(parse(raw(own: [(4, 5, false, 3)])), maxWork: 1),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    'lower target limit does not discard or reject earlier source components',
    () {
      final basis = parse(raw(own: [(1, 7, false, 4), (2, 8, true, 5)]));
      expect(cancel(basis, maxTargets: 1).targets, hasLength(1));
    },
  );
  for (final field in [
    'METHOD;X-PARAM=bad:REQUEST',
    'METHOD:REPLY',
    'METHOD:requeſt',
  ]) {
    test(
      'unsupported scheduling envelope $field is never stripped into validity',
      () {
        final doc = parseIcalendarSyntax(
          utf8.encode(raw().replaceFirst('METHOD:REQUEST', field)),
        );
        expect(
          () => projectPublishedRangeCancellation(
            basis: doc,
            originalStart: point(3),
            sequence: 20,
            stamp: DateTime.utc(2026, 2),
          ),
          throwsArgumentError,
        );
      },
    );
  }
  test(
    'unknown properties and source alarms are rejected rather than stripped',
    () {
      for (final extra in [
        ['X-UNPROFILED:secret'],
        [
          'BEGIN:VALARM',
          'ACTION:DISPLAY',
          'DESCRIPTION:Reminder',
          'TRIGGER:-PT1H',
          'END:VALARM',
        ],
      ]) {
        final doc = parseIcalendarSyntax(utf8.encode(raw(extra: extra)));
        expect(
          () => projectPublishedRangeCancellation(
            basis: doc,
            originalStart: point(3),
            sequence: 20,
            stamp: DateTime.utc(2026, 2),
          ),
          throwsArgumentError,
        );
      }
    },
  );
  test('raw source cannot widen the hard 512 KiB ceiling', () {
    final doc = parseIcalendarSyntax(
      utf8.encode(raw(extra: List.filled(140, 'COMMENT:${'x' * 4000}'))),
    );
    expect(
      () => projectPublishedRangeCancellation(
        basis: doc,
        originalStart: point(3),
        sequence: 20,
        stamp: DateTime.utc(2026, 2),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    'inherited roster expansion must fit the same complete byte ceiling',
    () {
      final doc = parseIcalendarSyntax(
        utf8.encode(
          raw(
            own: [(4, 5, false, 3), (5, 6, true, 4)],
            ownClaims: false,
          ).replaceFirst('CN=Alice', 'CN=${'A' * 800}'),
        ),
      );
      final size = serializeIcalendarSyntax(doc).length;
      expect(
        () => projectPublishedRangeCancellation(
          basis: doc,
          originalStart: point(3),
          sequence: 20,
          stamp: DateTime.utc(2026, 2),
          maxBytes: size + 100,
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
    },
  );
  test(
    'unused zones are still bounded before filtering output definitions',
    () {
      final text = raw(zone: 'Europe/Stockholm').replaceFirst(
        'BEGIN:VEVENT',
        '${zoneSource('US/Eastern')}\r\nBEGIN:VEVENT',
      );
      expect(
        () => projectPublishedRangeCancellation(
          basis: parseIcalendarSyntax(utf8.encode(text)),
          originalStart: point(3, zone: 'Europe/Stockholm'),
          sequence: 20,
          stamp: DateTime.utc(2026, 2),
          maxZones: 1,
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
    },
  );
  test('a high earlier component timestamp still bounds the whole bundle', () {
    final text = raw(own: [(2, 7, false, 3)]);
    final last = text.lastIndexOf('DTSTAMP:20260101T000000Z');
    final basis = parse(
      text.replaceRange(
        last,
        last + 'DTSTAMP:20260101T000000Z'.length,
        'DTSTAMP:20260301T000000Z',
      ),
    );
    expect(() => cancel(basis), throwsArgumentError);
    expect(
      cancel(basis, stamp: DateTime.utc(2026, 3)).minimumStamp,
      DateTime.utc(2026, 3),
    );
  });
  for (final bound in [
    DateTime(2026),
    DateTime.utc(2026, 1, 1, 0, 0, 0, 1),
    DateTime.utc(2100),
  ]) {
    test(
      'invalid optional stamp lower bound ${bound.toIso8601String()} rejects',
      () {
        expect(
          () => cancel(parse(raw()), minimumStamp: bound),
          throwsArgumentError,
        );
      },
    );
  }
  test('non-echo diagnostics omit participant and source text', () {
    expect(
      () => cancel(parse(raw()), minimumSequence: -1),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.toString(),
          'sanitized diagnostic',
          allOf(
            isNot(contains('published@example.invalid')),
            isNot(contains('Private retained text')),
          ),
        ),
      ),
    );
  });
  for (final bound in [0, 65]) {
    test('invalid target limit $bound rejects', () {
      expect(
        () => cancel(parse(raw()), maxTargets: bound),
        throwsArgumentError,
      );
    });
  }
  test('duplicate and over-limit publication recipients reject', () {
    for (final extra in [
      ['ATTENDEE;CN=Alice;ROLE=REQ-PARTICIPANT:mailto:alice@example.invalid'],
      [for (var i = 0; i < 64; i++) 'ATTENDEE:mailto:extra$i@example.invalid'],
    ]) {
      final basis = parseIcalendarSyntax(utf8.encode(raw(extra: extra)));
      expect(
        () => projectPublishedRangeCancellation(
          basis: basis,
          originalStart: point(3),
          sequence: 20,
          stamp: DateTime.utc(2026, 2),
        ),
        extra.length == 1
            ? throwsArgumentError
            : throwsA(isA<RecurrenceLimitException>()),
      );
    }
  });
  test(
    'equivalent participant tokens do not rewrite preserved source spelling',
    () {
      final text = raw(own: [(4, 5, false, 3)]);
      final index = text.lastIndexOf('ROLE=REQ-PARTICIPANT');
      final basis = parse(
        text.replaceRange(
          index,
          index + 'ROLE=REQ-PARTICIPANT'.length,
          'ROLE=req-participant',
        ),
      );
      expect(
        cancel(basis).message.events.last.participants.attendees.single.role,
        'REQ-PARTICIPANT',
      );
      expect(
        basis.events.last.participants.attendees.single.role,
        'req-participant',
      );
    },
  );
}
