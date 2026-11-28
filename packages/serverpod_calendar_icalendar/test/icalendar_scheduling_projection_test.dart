import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart' show fixedZone;
import 'support/scheduling_fixtures.dart';

IcalendarEventCalendar source(
  List<List<String>> events, {
  List<String> zones = const [],
}) => parseIcalendarEventCalendar(
  utf8.encode(
    multiple(
      'REQUEST',
      events,
      zones: zones,
    ).replaceFirst('METHOD:REQUEST\r\n', ''),
  ),
);

List<String> master({String? summary = 'SUMMARY:Series'}) => [
  uid,
  stamp,
  start,
  organizer,
  attendee,
  ?summary,
  'RRULE:FREQ=DAILY;COUNT=3',
];
List<String> override({bool future = false, List<String> extra = const []}) => [
  uid,
  'DTSTAMP:20261023T110000Z',
  'SEQUENCE:7',
  'RECURRENCE-ID${future ? ';RANGE=THISANDFUTURE' : ''}:20261023T120000Z',
  'DTSTART:20261023T130000Z',
  ...extra,
];

void main() {
  test(
    'projects missing required fields without changing source or versions',
    () {
      final value = source([master(), override()]);
      final before = serializeIcalendarSyntax(value.source);
      final projected = projectIcalendarRequestFields(value);
      final own = projected.events.last;
      expect(own.summary!.value, 'Series');
      expect(own.sequence, 7);
      expect(own.stamp, DateTime.utc(2026, 10, 23, 11));
      expect(own.originalTime!.instant, DateTime.utc(2026, 10, 23, 12));
      expect(own.startTime!.instant, DateTime.utc(2026, 10, 23, 13));
      expect(own.participants.attendees, hasLength(1));
      expect(serializeIcalendarSyntax(value.source), before);
      expect(value.series.single.overrides.single.summary, isNull);
      expect(
        serializeIcalendarSchedulingMessage(
          projectIcalendarRequestFields(value),
        ),
        serializeIcalendarSchedulingMessage(projected),
      );
    },
  );

  test(
    'copies annotated escaped summary and preserves explicit empty summary',
    () {
      final value = source([
        master(
          summary: 'SUMMARY;LANGUAGE=sv;ALTREP="https://example.invalid/text":Möte\\, här',
        ),
        override(),
      ]);
      final projected = projectIcalendarRequestFields(value);
      final own = projected.events.last.summary!;
      expect(own.value, 'Möte, här');
      expect(own.language, 'sv');
      expect(own.alternativeUri, 'https://example.invalid/text');
      final explicit = projectIcalendarRequestFields(
        source([
          master(),
          override(extra: ['SUMMARY:', organizer, attendee]),
        ]),
      ).events.last;
      expect(explicit.summary!.value, '');
      expect(explicit.participants.attendees, hasLength(1));
    },
  );

  test('absent master summary becomes empty, never a UI placeholder', () {
    final projected = projectIcalendarRequestFields(
      source([master(summary: null), override()]),
    );
    expect(projected.events.map((e) => e.summary!.value), ['', '']);
  });

  test('preserves source component order and future anchor', () {
    final projected = projectIcalendarRequestFields(
      source([override(future: true), master()]),
    );
    expect(projected.events.first.isThisAndFuture, isTrue);
    expect(projected.events.first.sequence, 7);
    expect(projected.events.last.isOverride, isFalse);
    expect(projected.events.last.sequence, isNull);
  });

  test('DATE and named-zone masters retain their exact profiles', () {
    for (final date in [true, false]) {
      final fields = master()
          .map(
            (p) => p == start
                ? date
                      ? 'DTSTART;VALUE=DATE:20261022'
                      : 'DTSTART;TZID=UTC:20261022T120000'
                : p,
          )
          .toList();
      final projected = projectIcalendarRequestFields(
        source([fields], zones: date ? [] : [fixedZone()]),
      );
      expect(projected.events.single.startDate != null, date);
      expect(projected.timeZones.keys, date ? isEmpty : ['UTC']);
    }
  });

  test('never invents participants or mixes different series', () {
    for (final missing in ['ORGANIZER', 'ATTENDEE']) {
      final fields = master().where((p) => !p.startsWith(missing)).toList();
      expect(
        () => projectIcalendarRequestFields(source([fields])),
        rejects(IcalendarComponentError.missing),
      );
    }
    expect(
      () => projectIcalendarRequestFields(
        source([
          master(),
          master()
              .map((p) => p == uid ? 'UID:other@example.invalid' : p)
              .toList(),
        ]),
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
  });

  test('retains PERIOD additions, exclusions and participant parameters', () {
    final value = source([
      [
        ...master().where((p) => p != attendee),
        'ATTENDEE;CN="Guest ^\'One^\'";PARTSTAT=ACCEPTED:mailto:guest@example.invalid',
        'RDATE;VALUE=PERIOD:20261025T120000Z/PT2H',
        'EXDATE:20261024T120000Z',
      ],
      override(),
    ]);
    final output = utf8.decode(
      serializeIcalendarSchedulingMessage(projectIcalendarRequestFields(value)),
    );
    expect(output, contains('RDATE;VALUE=PERIOD:20261025T120000Z/PT2H'));
    expect(output, contains('EXDATE:20261024T120000Z'));
    final own = projectIcalendarRequestFields(value).events.last.source;
    final inherited = own.entries
        .whereType<IcalendarSyntaxProperty>()
        .singleWhere((p) => p.canonicalName == 'ATTENDEE');
    final original = value.series.single.master.source.entries
        .whereType<IcalendarSyntaxProperty>()
        .singleWhere((p) => p.canonicalName == 'ATTENDEE');
    expect(identical(inherited, original), isTrue);
  });

  test('a later master edit changes only its new projection', () {
    final first = projectIcalendarRequestFields(source([master(), override()]));
    final second = projectIcalendarRequestFields(
      source([master(summary: 'SUMMARY:Updated'), override()]),
    );
    expect(first.events.last.summary!.value, 'Series');
    expect(second.events.last.summary!.value, 'Updated');
    expect(second.events.last.sequence, first.events.last.sequence);
  });

  test('does not discard cancellation or source alarms to force a REQUEST', () {
    final cancelled = source([
      master(),
      override(extra: ['STATUS:CANCELLED']),
    ]);
    expect(() => projectIcalendarRequestFields(cancelled), rejects());
    final alarm = source([
      [
        ...master(),
        'BEGIN:VALARM',
        'ACTION:DISPLAY',
        'DESCRIPTION:Reminder',
        'TRIGGER:-PT5M',
        'END:VALARM',
      ],
    ]);
    expect(() => projectIcalendarRequestFields(alarm), rejects());
  });

  test(
    'output enforces iTIP zone rules independently of standalone validation',
    () {
      final fields = master()
          .map((p) => p == start ? 'DTSTART;TZID=UTC:20261022T120000' : p)
          .toList();
      final value = source(
        [fields],
        zones: [
          fixedZone(
            extra: [
              'RRULE:FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1',
              'RDATE:19010101T000000',
            ],
          ),
        ],
      );
      expect(() => projectIcalendarRequestFields(value), rejects());
    },
  );

  test('bounds copied fields, output lines/bytes and component counts', () {
    final value = source([master(), override()]);
    expect(
      () => projectIcalendarRequestFields(
        value,
        limits: const IcalendarComponentLimits(maxEvents: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    final bytes = serializeIcalendarSyntax(value.source);
    for (final limits in [
      IcalendarSyntaxLimits(maxBytes: bytes.length),
      IcalendarSyntaxLimits(maxLines: bytes.where((b) => b == 10).length),
    ]) {
      expect(
        () => projectIcalendarRequestFields(value, syntaxLimits: limits),
        throwsA(isA<IcalendarSyntaxException>()),
      );
    }
  });
}
