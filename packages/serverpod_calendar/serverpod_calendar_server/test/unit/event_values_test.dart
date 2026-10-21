@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart'
    show RecurrenceLimitException;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';

CalendarEventCivil civil(int month, int day, {int hour = 0, int minute = 0}) =>
    CalendarEventCivil(
      year: 2026,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
    );
CalendarEventRule rule(CalendarEventFrequency frequency, {int? count}) =>
    CalendarEventRule(
      frequency: frequency,
      count: count,
      byDay: [],
      byMonthDay: [],
      byYearDay: [],
      byWeekNo: [],
      byMonth: [],
      byHour: [],
      byMinute: [],
      bySetPosition: [],
    );
void main() {
  CalendarEventTiming date(int day) => CalendarEventTiming(
    kind: CalendarEventTimeKind.date,
    start: civil(1, day),
  );
  CalendarEventContent content(
    CalendarEventTiming timing,
    CalendarEventRecurrence recurrence,
  ) => CalendarEventContent(timing: timing, recurrence: recurrence);
  CalendarEventOccurrenceQuery query({
    CalendarEventCivil? from,
    CalendarEventCivil? until,
    DateTime? start,
    DateTime? end,
  }) => CalendarEventOccurrenceQuery(
    eventId: UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
    expectedRevision: 1,
    fromDate: from,
    untilDate: until,
    fromUtc: start,
    untilUtc: end,
  );
  test('recurrence DATE additions precede DTSTART; exclusions win without replenishing count', () {
    final c = validateEventContent(
      content(
        date(3),
        CalendarEventRecurrence(
          rule: rule(CalendarEventFrequency.daily, count: 3),
          inclusions: [date(1), date(3), date(1)],
          exclusions: [date(4), date(1)],
        ),
      ),
    );
    expect(c.recurrence!.inclusions.length, 2);
    final p = previewEventOccurrences(
      c,
      query(from: civil(1, 1), until: civil(1, 10)),
    );
    expect(p.occurrences.map((v) => v.start.day), [3, 5]);
    expect(p.occurrences.first.endDate!.day, 4);
    expect(p.occurrences.first.startUtc, isNull);
  });
  test('rule filters canonicalize and DTSTART must match including week selections', () {
    final r = rule(CalendarEventFrequency.yearly).copyWith(byMonth: [3, 1, 3]);
    final value = validateEventContent(
      content(
        date(1),
        CalendarEventRecurrence(rule: r, inclusions: [], exclusions: []),
      ),
    );
    expect(value.recurrence!.rule!.byMonth, [1, 3]);
    expect(
      () => validateEventContent(
        content(
          date(1),
          CalendarEventRecurrence(
            rule: rule(CalendarEventFrequency.weekly)
                .copyWith(byDay: [CalendarEventByDay(weekday: 1)]),
            inclusions: [],
            exclusions: [],
          ),
        ),
      ),
      throwsArgumentError,
    );
  });
  test('named zone recurrence skips generated gaps and keeps COUNT plus nominal days', () {
    final t = CalendarEventTiming(
      kind: CalendarEventTimeKind.zoned,
      zoneId: 'Europe/Stockholm',
      start: civil(3, 28, hour: 2, minute: 30),
      duration: CalendarEventDuration(days: 1),
    );
    final c = validateEventContent(
      content(
        t,
        CalendarEventRecurrence(
          rule: rule(CalendarEventFrequency.daily, count: 3),
          inclusions: [],
          exclusions: [],
        ),
      ),
    );
    final p = previewEventOccurrences(
      c,
      query(start: DateTime.utc(2026, 3, 28), end: DateTime.utc(2026, 4, 2)),
    );
    expect(p.occurrences.map((v) => v.originalStart.day), [28, 30, 31]);
    expect(
      p.occurrences.first.endUtc!.difference(p.occurrences.first.startUtc!),
      const Duration(days: 1),
    );
    expect(p.zoneId, 'Europe/Stockholm');
  });
  test(
    'preview overlaps include earlier long starts and timed point membership',
    () {
      final c = CalendarEventContent(
        timing: date(1).copyWith(duration: CalendarEventDuration(days: 3)),
      );
      expect(
        previewEventOccurrences(
          c,
          query(from: civil(1, 3), until: civil(1, 4)),
        ).occurrences.single.start.day,
        1,
      );
      final t = CalendarEventContent(
        timing: CalendarEventTiming(
          kind: CalendarEventTimeKind.utc,
          start: civil(1, 1, hour: 12),
        ),
      );
      final p = previewEventOccurrences(
        t,
        query(
          start: DateTime.utc(2026, 1, 1, 12),
          end: DateTime.utc(2026, 1, 2),
        ),
      );
      expect(p.occurrences.single.startUtc, p.occurrences.single.endUtc);
      expect(
        previewEventOccurrences(
          t,
          query(
            start: DateTime.utc(2026, 1, 1),
            end: DateTime.utc(2026, 1, 1, 12),
          ),
        ).occurrences,
        isEmpty,
      );
    },
  );
  test('explicit recurrence values reject mixed profiles spans fractions and raw input excess', () {
    for (final v in [
      date(1).copyWith(kind: CalendarEventTimeKind.utc),
      date(1).copyWith(end: civil(1, 2)),
      date(1).copyWith(start: civil(1, 1).copyWith(microsecond: 1)),
    ]) {
      expect(
        () => validateEventContent(
          content(
            date(1),
            CalendarEventRecurrence(inclusions: [v], exclusions: []),
          ),
        ),
        throwsArgumentError,
      );
    }
    expect(
      () => validateEventContent(
        content(
          date(1),
          CalendarEventRecurrence(
            inclusions: List.filled(257, date(1)),
            exclusions: [],
          ),
        ),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('preview fails atomically on result work window or boundary limits', () {
    final c = validateEventContent(
      content(
        CalendarEventTiming(
          kind: CalendarEventTimeKind.utc,
          start: civil(1, 1),
        ),
        CalendarEventRecurrence(
          rule: rule(CalendarEventFrequency.minutely),
          inclusions: [],
          exclusions: [],
        ),
      ),
    );
    expect(
      () => previewEventOccurrences(
        c,
        query(start: DateTime.utc(2026, 1, 1), end: DateTime.utc(2026, 1, 2)),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => previewEventOccurrences(
        CalendarEventContent(timing: date(1)),
        query(
          from: civil(1, 1),
          until: CalendarEventCivil(year: 2028, month: 1, day: 1),
        ),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => previewEventOccurrences(
        CalendarEventContent(timing: date(1)),
        query(start: DateTime.utc(2026), end: DateTime.utc(2026, 2)),
      ),
      throwsArgumentError,
    );
    final last = CalendarEventContent(
      timing: CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: CalendarEventCivil(year: 2099, month: 12, day: 31),
      ),
    );
    expect(
      previewEventOccurrences(
        last,
        query(
          from: CalendarEventCivil(year: 2099, month: 12, day: 31),
          until: CalendarEventCivil(year: 2100, month: 1, day: 1),
        ),
      ).occurrences.single.endDate!.year,
      2100,
    );
  });

  test(
    'native event DATE retains omitted end and explicit endpoint semantics',
    () {
      final v = CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: civil(1, 1),
      );
      final (date, time) = validateEventTiming(v);
      expect(time, isNull);
      expect(date!.dayCount, 1);
      expect(date.end, isNull);
      expect(date.duration, isNull);
      final last = validateEventTiming(
        v.copyWith(
          start: CalendarEventCivil(year: 2099, month: 12, day: 31),
          end: CalendarEventCivil(year: 2100, month: 1, day: 1),
        ),
      ).$1!;
      expect(last.endExclusive.isExclusiveEnd, isTrue);
    },
  );
  test(
    'native event UTC omitted end is a point rather than a one-day event',
    () {
      final value = validateEventTiming(
        CalendarEventTiming(
          kind: CalendarEventTimeKind.utc,
          start: civil(1, 1, hour: 12),
        ),
      ).$2!;
      expect(value.isPoint, isTrue);
      expect(value.start.instant, DateTime.utc(2026, 1, 1, 12));
    },
  );
  test(
    'native event nominal day and elapsed 24 hours stay distinct across DST',
    () {
      final input = CalendarEventTiming(
        kind: CalendarEventTimeKind.zoned,
        start: civil(3, 28, hour: 12),
        zoneId: 'Europe/Stockholm',
        duration: CalendarEventDuration(days: 1),
      );
      expect(
        validateEventTiming(input).$2!.endExclusive,
        DateTime.utc(2026, 3, 29, 10),
      );
      expect(
        validateEventTiming(
          input.copyWith(duration: CalendarEventDuration(hours: 24)),
        ).$2!.endExclusive,
        DateTime.utc(2026, 3, 29, 11),
      );
      expect(input.duration!.days, 1);
    },
  );
  test('native event explicit gap and fold use selected RFC rules', () {
    CalendarEventTiming input(CalendarEventCivil start) => CalendarEventTiming(
      kind: CalendarEventTimeKind.zoned,
      start: start,
      zoneId: 'Europe/Stockholm',
    );
    expect(
      validateEventTiming(input(civil(3, 29, hour: 2, minute: 30)))
          .$2!
          .start
          .instant,
      DateTime.utc(2026, 3, 29, 1, 30),
    );
    expect(
      validateEventTiming(input(civil(10, 25, hour: 2, minute: 30)))
          .$2!
          .start
          .instant,
      DateTime.utc(2026, 10, 25, 0, 30),
    );
    final alias = validateEventTiming(
      CalendarEventTiming(
        kind: CalendarEventTimeKind.zoned,
        start: civil(1, 1),
        zoneId: 'US/Eastern',
      ),
    ).$2!;
    expect(alias.start.zoneId, 'US/Eastern');
  });
  test(
    'native event rejects fractions leap seconds floating and mixed forms',
    () {
      final basic = CalendarEventTiming(
        kind: CalendarEventTimeKind.utc,
        start: civil(1, 1),
      );
      for (final bad in [
        basic.copyWith(start: basic.start.copyWith(microsecond: 1)),
        basic.copyWith(start: basic.start.copyWith(second: 60)),
        basic.copyWith(kind: CalendarEventTimeKind.floating),
        basic.copyWith(zoneId: 'Europe/Stockholm'),
        basic.copyWith(
          end: civil(1, 2),
          duration: CalendarEventDuration(days: 1),
        ),
        basic.copyWith(duration: CalendarEventDuration()),
        basic.copyWith(
          duration: CalendarEventDuration(seconds: 1, microsecond: 1),
        ),
        basic.copyWith(start: CalendarEventCivil(year: 2100, month: 1, day: 1)),
        basic.copyWith(start: civil(2, 30)),
        basic.copyWith(
          kind: CalendarEventTimeKind.zoned,
          zoneId: 'europe/stockholm',
        ),
        basic.copyWith(
          kind: CalendarEventTimeKind.date,
          start: civil(1, 1, hour: 1),
        ),
      ]) {
        expect(() => validateEventTiming(bad), throwsArgumentError);
      }
    },
  );
  test(
    'native event optional plain text is preserved and recurrence rejects',
    () {
      final value = CalendarEventContent(
        summary: '',
        description: '  notes\n',
        timing: CalendarEventTiming(
          kind: CalendarEventTimeKind.date,
          start: civil(1, 1),
        ),
      );
      expect(validateEventContent(value).summary, '');
      expect(validateEventContent(value).description, '  notes\n');
      expect(
        () => validateEventContent(
          value.copyWith(
            recurrence: CalendarEventRecurrence(
              rule: rule(CalendarEventFrequency.hourly),
              inclusions: [],
              exclusions: [],
            ),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateEventContent(value.copyWith(summary: 'a' * 4097)),
        throwsArgumentError,
      );
      expect(
        () => validateEventContent(value.copyWith(location: '\u0000')),
        throwsArgumentError,
      );
    },
  );
}
