@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart'
    show eventMaxSequence;
import 'package:serverpod_calendar_server/src/event_values.dart'
    show eventMaxCandidateWork;
import 'package:serverpod_calendar_server/src/published_finite_suffix_projection.dart'
    show composePublishedCutoffReopening;
import 'package:test/test.dart';

import 'published_range_cancellation_values_test.dart' as fixture;

void main() {
  test(
    'reopening versions retained components and deduplicates wire masks',
    () {
      final basis = parseIcalendarSyntax(
        utf8.encode(
          fixture.raw(
            date: true,
            rule: 'FREQ=DAILY;COUNT=7',
            extra: ['EXDATE;VALUE=DATE:20300106'],
            own: [(2, 3, false, 8), (3, 2, false, 9), (5, 1, false, 10)],
          ),
        ),
      );
      final stamp = DateTime.utc(2030, 1, 1, 12);
      final (message, suffix) = composePublishedCutoffReopening(
        basis: basis,
        cutoff: fixture.point(4, date: true),
        individualMasks: [
          fixture.point(3, date: true),
          fixture.point(5, date: true),
        ],
        sequenceFloor: 20,
        stamp: stamp,
        maxBytes: 65536,
        work: RecurrenceWorkBudget(maxWork: eventMaxCandidateWork),
      );
      expect(suffix.exclusions.map((point) => point.start.day), [4, 5, 7]);
      expect(message.events.map((event) => event.sequence), [21, 22]);
      expect(message.events.map((event) => event.stamp), everyElement(stamp));
      expect(message.events.last.originalDate!.day, 2);
      final wire = utf8.decode(serializeIcalendarSchedulingMessage(message));
      for (final day in [3, 4, 5, 6, 7]) {
        expect(
          RegExp('EXDATE;VALUE=DATE:2030010$day').allMatches(wire),
          hasLength(1),
        );
      }
    },
  );

  test(
    'reopening rejects source exclusions as individual proof and overflow',
    () {
      final basis = parseIcalendarSyntax(
        utf8.encode(
          fixture.raw(
            date: true,
            rule: 'FREQ=DAILY;COUNT=5',
            extra: ['EXDATE;VALUE=DATE:20300104'],
          ),
        ),
      );
      Object project(List<CalendarEventTiming> masks, int floor) =>
          composePublishedCutoffReopening(
            basis: basis,
            cutoff: fixture.point(3, date: true),
            individualMasks: masks,
            sequenceFloor: floor,
            stamp: DateTime.utc(2030, 1, 1),
            maxBytes: 65536,
            work: RecurrenceWorkBudget(maxWork: eventMaxCandidateWork),
          );
      expect(
        () => project([fixture.point(4, date: true)], 20),
        throwsArgumentError,
      );
      expect(
        () => project([], eventMaxSequence),
        throwsA(isA<RecurrenceLimitException>()),
      );
    },
  );

  test('masks finite originals and removes only suffix components', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          date: true,
          rule: 'FREQ=DAILY;COUNT=5',
          own: [(2, 4, false, 2), (4, 3, false, 2)],
        ),
      ),
    );
    final before = serializeIcalendarSyntax(basis);
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    expect(result.exclusions.length, 3);
    expect(result.suppressedComponents.length, 1);
    final parsed = validateIcalendarSchedulingMessage(result.candidate);
    expect(parsed.events.where((v) => v.isOverride).length, 1);
    final recurrence = parsed.events
        .singleWhere((v) => !v.isOverride)
        .recurrence!
        .dateSet!;
    final retained = recurrence.expand(
      from: CalendarDate(year: 2030, month: 1, day: 1),
      through: CalendarDate(year: 2030, month: 1, day: 5),
      maxCandidateDays: 100,
      maxRuleOccurrences: 100,
      maxResults: 100,
    );
    expect(retained.map((v) => v.day), [1, 2]);
    expect(serializeIcalendarSyntax(basis), before);
  });

  test('preserves source exclusions and earlier additions', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          date: true,
          rule: 'FREQ=DAILY;COUNT=5',
          extra: ['EXDATE;VALUE=DATE:20300104', 'RDATE;VALUE=DATE:20291231'],
        ),
      ),
    );
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    expect(result.exclusions.map((v) => v.start.day), [3, 5]);
    final wire = utf8.decode(serializeIcalendarSyntax(result.candidate));
    expect(wire, contains('EXDATE;VALUE=DATE:20300104'));
    expect(wire, contains('RDATE;VALUE=DATE:20291231'));
  });

  test('supports a finite UTC suffix', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(fixture.raw(rule: 'FREQ=DAILY;COUNT=4')),
    );
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(3),
    );
    expect(result.exclusions.map((v) => v.start.day), [3, 4]);
  });

  test('skips a nonexistent generated local time', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          zone: 'Europe/Stockholm',
          prefix: '202603',
          time: '023000',
          startDay: 28,
          rule: 'FREQ=DAILY;COUNT=4',
        ),
      ),
    );
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(
        28,
        zone: 'Europe/Stockholm',
        year: 2026,
        month: 3,
        hour: 2,
        minute: 30,
      ),
    );
    expect(result.exclusions.map((v) => v.start.day), [28, 30, 31, 1]);
  });

  test('keeps original civil identities across an autumn fold', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          zone: 'Europe/Stockholm',
          prefix: '202610',
          time: '023000',
          startDay: 24,
          rule: 'FREQ=DAILY;COUNT=3',
        ),
      ),
    );
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(
        24,
        zone: 'Europe/Stockholm',
        year: 2026,
        month: 10,
        hour: 2,
        minute: 30,
      ),
    );
    expect(result.exclusions.map((v) => v.start.day), [24, 25, 26]);
    expect(result.exclusions.map((v) => v.start.hour), [2, 2, 2]);
  });

  test('fails closed when shared work is exhausted', () {
    final basis = parseIcalendarSyntax(utf8.encode(fixture.raw(date: true)));
    expect(
      () => projectPublishedFiniteSuffix(
        basis: basis,
        originalStart: fixture.point(3, date: true),
        sharedWorkBudget: RecurrenceWorkBudget(maxWork: 1),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });

  test('includes a later PERIOD original and keeps its source form', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          rule: 'FREQ=DAILY;COUNT=3',
          extra: ['RDATE;VALUE=PERIOD:20300105T090000Z/PT2H'],
        ),
      ),
    );
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(2),
    );
    expect(result.exclusions.map((v) => v.start.day), [2, 3, 5]);
    expect(
      utf8.decode(serializeIcalendarSyntax(result.candidate)),
      contains('RDATE;VALUE=PERIOD:20300105T090000Z/PT2H'),
    );
  });

  test('does not expose mutable original identities', () {
    final basis = parseIcalendarSyntax(utf8.encode(fixture.raw(date: true)));
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    expect(
      identical(result.exclusions.first, result.exclusions.first),
      isFalse,
    );
    expect(result.exclusions.first.start.day, 3);
    expect(() => result.exclusions.clear(), throwsUnsupportedError);
  });

  test('rejects an unbounded rule', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(fixture.raw(date: true, rule: 'FREQ=DAILY')),
    );
    expect(
      () => projectPublishedFiniteSuffix(
        basis: basis,
        originalStart: fixture.point(3, date: true),
      ),
      throwsArgumentError,
    );
  });

  test('rejects a cancellation message as an active REQUEST basis', () {
    final raw = fixture
        .raw(date: true)
        .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL');
    final basis = parseIcalendarSyntax(utf8.encode(raw));
    expect(
      () => projectPublishedFiniteSuffix(
        basis: basis,
        originalStart: fixture.point(3, date: true),
      ),
      throwsArgumentError,
    );
  });

  test('rejects a cutoff excluded by the source', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          date: true,
          extra: ['EXDATE;VALUE=DATE:20300103'],
        ),
      ),
    );
    expect(
      () => projectPublishedFiniteSuffix(
        basis: basis,
        originalStart: fixture.point(3, date: true),
      ),
      throwsArgumentError,
    );
  });

  test('handles the final original without inventing more dates', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          date: true,
          rule: 'FREQ=DAILY;COUNT=3',
        ),
      ),
    );
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    expect(result.exclusions.map((v) => v.start.day), [3]);
  });

  test('can suppress a complete series beginning at DTSTART', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          date: true,
          rule: 'FREQ=DAILY;COUNT=3',
        ),
      ),
    );
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(1, date: true),
    );
    expect(result.exclusions.map((v) => v.start.day), [1, 2, 3]);
    expect(
      utf8.decode(serializeIcalendarSyntax(result.candidate)),
      contains('DTSTART;VALUE=DATE:20300101'),
    );
  });

  test('preserves the exact named-zone alias', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          zone: 'US/Eastern',
          rule: 'FREQ=DAILY;COUNT=3',
        ),
      ),
    );
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(2, zone: 'US/Eastern'),
    );
    expect(result.exclusions.map((v) => v.zoneId), [
      'US/Eastern',
      'US/Eastern',
    ]);
  });

  test('preserves source versions for a finite UNTIL rule', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          date: true,
          rule: 'FREQ=DAILY;UNTIL=20300104',
          sequence: 7,
          own: [(2, 4, false, 5)],
        ),
      ),
    );
    final result = projectPublishedFiniteSuffix(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    final events = validateIcalendarSchedulingMessage(result.candidate).events;
    expect(events.singleWhere((event) => !event.isOverride).sequence, 7);
    expect(events.singleWhere((event) => event.isOverride).sequence, 5);
    expect(result.exclusions.map((v) => v.start.day), [3, 4]);
  });

  test('rejects a cutoff that is not a recurrence original', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          date: true,
          rule: 'FREQ=DAILY;COUNT=3',
        ),
      ),
    );
    expect(
      () => projectPublishedFiniteSuffix(
        basis: basis,
        originalStart: fixture.point(4, date: true),
      ),
      throwsArgumentError,
    );
  });

  test('rejects a cutoff with a different exact zone identifier', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          zone: 'US/Eastern',
          rule: 'FREQ=DAILY;COUNT=3',
        ),
      ),
    );
    expect(
      () => projectPublishedFiniteSuffix(
        basis: basis,
        originalStart: fixture.point(2, zone: 'America/New_York'),
      ),
      throwsArgumentError,
    );
  });

  test('rejects conflicting single and range identities', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          date: true,
          own: [(3, 4, false, 2), (3, 5, true, 2)],
        ),
      ),
    );
    expect(
      () => projectPublishedFiniteSuffix(
        basis: basis,
        originalStart: fixture.point(3, date: true),
      ),
      throwsA(anyOf(isA<ArgumentError>(), isA<IcalendarComponentException>())),
    );
  });

  test('rejects a COUNT whose end cannot be proved within the horizon', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          date: true,
          prefix: '209912',
          startDay: 30,
          rule: 'FREQ=DAILY;COUNT=4',
        ),
      ),
    );
    expect(
      () => projectPublishedFiniteSuffix(
        basis: basis,
        originalStart: fixture.point(30, date: true, year: 2099, month: 12),
      ),
      throwsArgumentError,
    );
  });

  test('rejects an oversized syntax document', () {
    final source = parseIcalendarSyntax(utf8.encode(fixture.raw(date: true)));
    final root = source.components.single;
    final basis = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(root.name, [
        ...root.entries,
        IcalendarSyntaxProperty('X-OVERSIZED', 'x' * 525000),
      ]),
    ]);
    expect(
      () => projectPublishedFiniteSuffix(
        basis: basis,
        originalStart: fixture.point(3, date: true),
      ),
      throwsA(isA<IcalendarSyntaxException>()),
    );
  });

  test('rejects a suffix beyond existing bounded capacity', () {
    final basis = parseIcalendarSyntax(
      utf8.encode(
        fixture.raw(
          date: true,
          rule: 'FREQ=DAILY;COUNT=300',
        ),
      ),
    );
    expect(
      () => projectPublishedFiniteSuffix(
        basis: basis,
        originalStart: fixture.point(1, date: true),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
}
