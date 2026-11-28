import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart' show file, fixedZone, explicitZone;

String task({
  String uid = 'task@example.invalid',
  List<String> properties = const [],
}) => [
  'BEGIN:VTODO',
  'UID:$uid',
  'DTSTAMP:20261022T100000Z',
  ...properties,
  'END:VTODO',
].join('\r\n');
IcalendarTaskCalendar load(
  List<String> properties, {
  List<String> zones = const [],
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => parseIcalendarTaskCalendar(
  utf8.encode(
    file(
      events: [task(properties: properties)],
      zones: zones,
    ),
  ),
  limits: limits,
);
Matcher rejects(IcalendarComponentError kind) => throwsA(
  isA<IcalendarComponentException>().having((e) => e.kind, 'kind', kind),
);

void main() {
  test(
    'undated task preserves every absent source progress and checkpoint field',
    () {
      final calendar = load([]), value = calendar.tasks.single;
      expect(value.isUndated, isTrue);
      expect(value.dateTiming, isNull);
      expect(value.timedTiming, isNull);
      expect(value.status, isNull);
      expect(value.percentComplete, isNull);
      expect(value.completed, isNull);
      expect(value.priority, isNull);
      expect(value.sequence, isNull);
      expect(value.created, isNull);
      expect(value.lastModified, isNull);
      expect(value.stamp, DateTime.utc(2026, 10, 22, 10));
      expect(() => calendar.tasks.clear(), throwsUnsupportedError);
      expect(() => calendar.timeZones.clear(), throwsUnsupportedError);
      expect(() => value.source.entries.clear(), throwsUnsupportedError);
    },
  );
  for (final status in <String?>[
    null,
    'NEEDS-ACTION',
    'IN-PROCESS',
    'COMPLETED',
    'CANCELLED',
  ]) {
    test(
      'source ${status ?? 'absent'} progress fields remain independently optional',
      () {
        for (final percentage in <int?>[null, 0, 39, 100]) {
          for (final completed in [false, true]) {
            final properties = <String>[
              if (status != null) 'STATUS:$status',
              if (percentage != null) 'PERCENT-COMPLETE:$percentage',
              if (completed) 'COMPLETED:20261021T123456Z',
            ];
            final value = load(properties), parsed = value.tasks.single;
            expect(parsed.status?.name, switch (status) {
              null => null,
              'NEEDS-ACTION' => 'needsAction',
              'IN-PROCESS' => 'inProcess',
              'COMPLETED' => 'completed',
              _ => 'cancelled',
            });
            expect(parsed.percentComplete, percentage);
            expect(
              parsed.completed,
              completed ? DateTime.utc(2026, 10, 21, 12, 34, 56) : null,
            );
            final again = parseIcalendarTaskCalendar(
              serializeIcalendarTaskCalendar(value),
            ).tasks.single;
            expect(again.percentComplete, percentage);
            expect(again.status, parsed.status);
            expect(again.completed, parsed.completed);
          }
        }
      },
    );
  }
  test('DATE and timed due-only start-only and explicit due-duration forms stay distinct', () {
    final due = load(['DUE;VALUE=DATE:20261023']).tasks.single;
    expect(due.dateTiming!.start, isNull);
    expect(due.dateTiming!.due, CalendarDate(year: 2026, month: 10, day: 23));
    final start = load(['DTSTART:20261022T120000Z']).tasks.single;
    expect(start.timedTiming!.due, isNull);
    expect(start.timedTiming!.effectiveDue, isNull);
    final explicit = load(['DTSTART:20261022T120000Z', 'DUE:20261023T120000Z'])
        .tasks
        .single;
    final duration = load(['DTSTART:20261022T120000Z', 'DURATION:P1D'])
        .tasks
        .single;
    expect(explicit.timedTiming!.duration, isNull);
    expect(duration.timedTiming!.due, isNull);
    expect(
      explicit.timedTiming!.effectiveDue,
      duration.timedTiming!.effectiveDue,
    );
    expect(
      load(['DUE:20261022T120000Z']).tasks.single.timedTiming!.start,
      isNull,
    );
  });
  test('annotated Unicode text and source versions survive deterministic reserialization', () {
    final value = load([
      'SUMMARY;LANGUAGE=sv;ALTREP="https://example.invalid/task":Möte\\, arbete',
      'DESCRIPTION:First\\nSecond',
      'LOCATION:Room',
      'PRIORITY:+0',
      'SEQUENCE:7',
      'CREATED:20261020T100000Z',
      'LAST-MODIFIED:20261019T100000Z',
    ]);
    final t = value.tasks.single;
    expect(t.summary!.value, 'Möte, arbete');
    expect(t.summary!.language, 'sv');
    expect(t.summary!.alternativeUri, 'https://example.invalid/task');
    expect(t.description!.value, 'First\nSecond');
    expect(t.priority, 0);
    expect(t.sequence, 7);
    expect(t.lastModified, DateTime.utc(2026, 10, 19, 10));
    final bytes = serializeIcalendarTaskCalendar(value),
        again = parseIcalendarTaskCalendar(bytes);
    expect(serializeIcalendarTaskCalendar(again), bytes);
    expect(
      again.tasks.single.source.entries.map((e) => e.runtimeType).toList(),
      t.source.entries.map((e) => e.runtimeType).toList(),
    );
  });
  test('recurring DATE master preserves earlier additions exclusions COUNT and WKST', () {
    final value = load([
      'DTSTART;VALUE=DATE:20261022',
      'DUE;VALUE=DATE:20261023',
      'RRULE:COUNT=3;FREQ=DAILY;WKST=SU',
      'RDATE;VALUE=DATE:20261021',
      'EXDATE;VALUE=DATE:20261023',
    ]);
    final t = value.tasks.single, set = t.recurrence!.dateSet!;
    expect(set.rule!.weekStart, Weekday.sunday);
    final projected = t.dateTiming!.expandStarts(
      set,
      from: CalendarDate(year: 2026, month: 10, day: 20),
      through: CalendarDate(year: 2026, month: 10, day: 25),
      maxCandidateDays: 100,
      maxRuleOccurrences: 100,
      maxResults: 10,
    );
    expect(projected.map((v) => v.originalStart.day), [21, 22, 24]);
    expect(projected.last.timing.effectiveDue!.day, 25);
    expect(
      utf8.decode(serializeIcalendarTaskCalendar(value)),
      contains('RRULE:FREQ=DAILY;COUNT=3;WKST=SU'),
    );
    expect(
      t.source.entries
          .whereType<IcalendarSyntaxProperty>()
          .firstWhere((p) => p.canonicalName == 'RRULE')
          .value,
      'COUNT=3;FREQ=DAILY;WKST=SU',
    );
  });
  test('named-zone recurrence retains nominal duration through DST with full-horizon zones', () {
    final t = load(
      [
        'DTSTART;TZID=Europe/Stockholm:20260328T090000',
        'DURATION:P1D',
        'RRULE:FREQ=DAILY;COUNT=3',
      ],
      zones: [explicitZone('Europe/Stockholm')],
    ).tasks.single;
    final values = t.timedTiming!.expandStarts(
      t.recurrence!.timedSet!,
      window: UtcWindow(
        start: DateTime.utc(2026, 3, 27),
        end: DateTime.utc(2026, 3, 31),
      ),
      maxCandidateWork: 1000,
      maxRuleOccurrences: 100,
      maxResults: 10,
    );
    expect(
      values.first.timing.dueInstant!
          .difference(values.first.originalStart.instant)
          .inHours,
      23,
    );
    expect(
      values[1].timing.dueInstant!
          .difference(values[1].originalStart.instant)
          .inHours,
      24,
    );
    expect(values.every((v) => v.originalStart.civil.hour == 9), isTrue);
  });
  test('required zone evidence is exact even if an event-local definition would suffice elsewhere', () {
    expect(
      () => load(['DTSTART;TZID=UTC:20261022T120000']),
      rejects(IcalendarComponentError.missing),
    );
    expect(
      load(
        ['DTSTART;TZID=UTC:20261022T120000'],
        zones: [fixedZone()],
      ).tasks.single.timedTiming!.start!.zoneId,
      'UTC',
    );
    expect(
      () => load(
        ['DTSTART;TZID=UTC:20261022T120000'],
        zones: [fixedZone(offset: '+0100')],
      ),
      rejects(IcalendarComponentError.zoneMismatch),
    );
    expect(
      () => load(
        ['DTSTART;TZID=utc:20261022T120000'],
        zones: [fixedZone(id: 'utc')],
      ),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
  test('milestone and due-duration validation rejects invalid chronology profiles and fractions', () {
    for (final properties in <List<String>>[
      ['DURATION:P1D'],
      ['DTSTART;VALUE=DATE:20261022', 'DURATION:PT1H'],
      ['DTSTART:20261022T120000Z', 'DURATION:PT0S'],
      ['DTSTART;VALUE=DATE:20261022', 'DUE;VALUE=DATE:20261022'],
      ['DTSTART:20261022T120000Z', 'DUE;VALUE=DATE:20261023'],
      ['DTSTART:20261022T120000Z', 'DUE:20261023T120000Z', 'DURATION:P1D'],
      ['DUE:20261022T120000'],
      ['DUE:20261022T120000.0Z'],
      ['DUE;VALUE=DATE:21000101'],
      ['DTSTART;VALUE=DATE:20991231', 'DURATION:P1D'],
      ['COMPLETED:20261022T120000'],
      ['COMPLETED;VALUE=DATE:20261022'],
      ['PRIORITY:10'],
      ['PERCENT-COMPLETE:101'],
      ['PERCENT-COMPLETE:-1'],
      ['STATUS:CONFIRMED'],
      ['SEQUENCE:-1'],
    ]) {
      expect(
        () => load(properties),
        throwsA(isA<IcalendarComponentException>()),
        reason: properties.first.split(':').first,
      );
    }
  });
  test(
    'recurrence rejects missing start profile mismatch and nonmatching DTSTART',
    () {
      expect(
        () => load(['DUE;VALUE=DATE:20261022', 'RRULE:FREQ=DAILY']),
        rejects(IcalendarComponentError.missing),
      );
      expect(
        () =>
            load(['DTSTART;VALUE=DATE:20261022', 'RRULE:FREQ=WEEKLY;BYDAY=MO']),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => load(['DTSTART;VALUE=DATE:20261022', 'RDATE:20261023T120000Z']),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test(
    'unsupported task data and occurrence components reject the whole file',
    () {
      for (final property in [
        'RECURRENCE-ID:20261022T120000Z',
        'ATTENDEE:mailto:a@example.invalid',
        'ORGANIZER:mailto:a@example.invalid',
        'CATEGORIES:Work',
        'URL:https://example.invalid',
        'CLASS:PRIVATE',
        'X-PRIVATE:data',
        'RDATE;VALUE=PERIOD:20261023T120000Z/PT1H',
      ]) {
        expect(
          () => load(['DTSTART:20261022T120000Z', property]),
          rejects(IcalendarComponentError.unsupportedProperty),
        );
      }
      expect(
        () => load([
          'BEGIN:VALARM',
          'ACTION:DISPLAY',
          'TRIGGER:-PT5M',
          'END:VALARM',
        ]),
        rejects(IcalendarComponentError.unsupportedComponent),
      );
      final scheduling = file(events: [task()], envelope: ['METHOD:PUBLISH']);
      expect(
        () => parseIcalendarTaskCalendar(utf8.encode(scheduling)),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
      final mixed = file(
        events: [
          task(),
          task(uid: 'other', properties: ['URL:https://example.invalid']),
        ],
      );
      expect(
        () => parseIcalendarTaskCalendar(utf8.encode(mixed)),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    },
  );
  test('duplicate UID properties parameter values and envelope components fail explicitly', () {
    expect(
      () => load(['UID:second']),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => load(['STATUS:COMPLETED', 'STATUS:CANCELLED']),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => load(['SUMMARY;LANGUAGE=en;LANGUAGE=sv:value']),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => load(['PERCENT-COMPLETE;X-OTHER=yes:25']),
      rejects(IcalendarComponentError.unsupportedParameter),
    );
    expect(
      () => parseIcalendarTaskCalendar(
        utf8.encode(file(events: [task(), task()])),
      ),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => parseIcalendarTaskCalendar(utf8.encode(file(events: []))),
      rejects(IcalendarComponentError.missing),
    );
    expect(
      () => parseIcalendarTaskCalendar(utf8.encode(file())),
      rejects(IcalendarComponentError.unsupportedComponent),
    );
  });
  test('strict syntax and manually constructed trees share the same validation boundary', () {
    final source = file(events: [task()]);
    expect(
      () => parseIcalendarTaskCalendar(
        utf8.encode(source.replaceAll('\r\n', '\n')),
      ),
      throwsA(isA<IcalendarSyntaxException>()),
    );
    expect(
      () => parseIcalendarTaskCalendar([
        0xef,
        0xbb,
        0xbf,
        ...utf8.encode(source),
      ]),
      throwsA(isA<IcalendarSyntaxException>()),
    );
    final tree = parseIcalendarSyntax(utf8.encode(source));
    expect(
      validateIcalendarTaskCalendar(tree).tasks.single.uid,
      'task@example.invalid',
    );
    expect(
      () => parseIcalendarTaskCalendar([0xff, ...utf8.encode(source)]),
      throwsA(isA<IcalendarSyntaxException>()),
    );
  });
  test('task count metadata explicit dates and rule aggregate budgets fail without partial output', () {
    final two = file(
      events: [
        task(uid: 'a'),
        task(uid: 'b'),
      ],
    );
    expect(
      () => parseIcalendarTaskCalendar(
        utf8.encode(two),
        limits: const IcalendarComponentLimits(maxTasks: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load([
        'SUMMARY:Too much text',
      ], limits: const IcalendarComponentLimits(maxTaskMetadataCodePoints: 2)),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load([
        'DTSTART;VALUE=DATE:20261022',
        'RDATE;VALUE=DATE:20261023,20261024',
      ], limits: const IcalendarComponentLimits(maxExplicitDates: 1)),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load([
        'DTSTART;VALUE=DATE:20261022',
        'RRULE:FREQ=DAILY;BYMONTH=1,2,3',
      ], limits: const IcalendarComponentLimits(maxRuleValues: 2)),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load([], limits: const IcalendarComponentLimits(maxTasks: 0)),
      throwsArgumentError,
    );
  });
}
