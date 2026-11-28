@TestOn('vm')
library;

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:test/test.dart';

import 'event_overrides_test.dart' as fixture;

void main() {
  test('COUNT beyond 2099 cannot be mistaken for an exhausted series', () {
    CalendarEventTiming point(int day) => CalendarEventTiming(
      kind: CalendarEventTimeKind.date,
      start: CalendarEventCivil(year: 2099, month: 12, day: day),
    );
    final series = fixture.content().copyWith(timing: point(30));
    expect(
      () => eventSchedulingDateIsProvablyLast(series, point(31)),
      throwsArgumentError,
    );
  });
  test('COUNT exhaustion skips a spring DST gap rather than counting it', () {
    const kind = CalendarEventTimeKind.zoned;
    final series = fixture.content(kind: kind, hour: 2);
    expect(
      eventSchedulingTimedIsProvablyLast(
        series,
        fixture.timing(31, kind: kind, hour: 2),
      ),
      false,
    );
    final last = CalendarEventTiming(
      kind: kind,
      zoneId: 'Europe/Stockholm',
      start: CalendarEventCivil(year: 2026, month: 4, day: 2, hour: 2),
    );
    expect(eventSchedulingTimedIsProvablyLast(series, last), true);
  });
  test('returns the next original after exclusions, not a moved start', () {
    final base = fixture.content();
    final content = base.copyWith(
      recurrence: base.recurrence!.copyWith(
        exclusions: [fixture.timing(29)],
        inclusions: [fixture.timing(27)],
      ),
    );
    final next = eventSchedulingNextDateInWindow(
      content,
      fixture.timing(28),
      CalendarDate(year: 2026, month: 3, day: 31),
    );
    expect(next!.start.day, 30);
    expect(next.end, isNull);
    expect(next.duration, isNull);
  });

  test('an empty window does not assert the series has ended', () {
    final content = fixture.content();
    expect(
      eventSchedulingNextDateInWindow(
        content,
        fixture.timing(28),
        CalendarDate(year: 2026, month: 3, day: 29),
      )!.start.day,
      29,
    );
    final recurrence = content.recurrence!;
    final excluded = content.copyWith(
      recurrence: recurrence.copyWith(exclusions: [fixture.timing(29)]),
    );
    expect(
      eventSchedulingNextDateInWindow(
        excluded,
        fixture.timing(28),
        CalendarDate(year: 2026, month: 3, day: 29),
      ),
      isNull,
    );
    expect(
      eventSchedulingNextDateInWindow(
        excluded,
        fixture.timing(28),
        CalendarDate(year: 2026, month: 3, day: 30),
      )!.start.day,
      30,
    );
  });

  test('rejects an excluded anchor and a non-DATE profile', () {
    final base = fixture.content();
    final excluded = base.copyWith(
      recurrence: base.recurrence!.copyWith(exclusions: [fixture.timing(29)]),
    );
    final through = CalendarDate(year: 2026, month: 3, day: 31);
    expect(
      () => eventSchedulingNextDateInWindow(
        excluded,
        fixture.timing(29),
        through,
      ),
      throwsArgumentError,
    );
    expect(
      () => eventSchedulingNextDateInWindow(
        fixture.content(kind: CalendarEventTimeKind.utc),
        fixture.timing(28, kind: CalendarEventTimeKind.utc),
        through,
      ),
      throwsArgumentError,
    );
  });

  test('shared work exhaustion throws rather than reporting no next date', () {
    expect(
      () => eventSchedulingNextDateInWindow(
        fixture.content(),
        fixture.timing(28),
        CalendarDate(year: 2026, month: 3, day: 31),
        sharedWorkBudget: RecurrenceWorkBudget(maxWork: 1),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });

  test('timed search uses civil originals and skips a generated DST gap', () {
    const kind = CalendarEventTimeKind.zoned;
    final content = fixture.content(kind: kind, hour: 2);
    final next = eventSchedulingNextTimedInWindow(
      content,
      fixture.timing(28, kind: kind, hour: 2),
      fixture.timing(31, kind: kind, hour: 2),
    );
    expect(next!.start.day, 30);
    expect(next.start.hour, 2);
    expect(next.zoneId, 'Europe/Stockholm');
  });

  test(
    'UTC search returns the next included original and validates profile',
    () {
      const kind = CalendarEventTimeKind.utc;
      final base = fixture.content(kind: kind, hour: 2);
      final content = base.copyWith(
        recurrence: base.recurrence!.copyWith(
          exclusions: [fixture.timing(29, kind: kind, hour: 2)],
        ),
      );
      expect(
        eventSchedulingNextTimedInWindow(
          content,
          fixture.timing(28, kind: kind, hour: 2),
          fixture.timing(31, kind: kind, hour: 2),
        )!.start.day,
        30,
      );
      expect(
        () => eventSchedulingNextTimedInWindow(
          content,
          fixture.timing(28, kind: kind, hour: 2),
          fixture.timing(31, kind: CalendarEventTimeKind.zoned, hour: 2),
        ),
        throwsArgumentError,
      );
    },
  );
  test('last timed proof respects UTC UNTIL and explicit additions', () {
    const kind = CalendarEventTimeKind.utc;
    final base = fixture.content(kind: kind, hour: 9);
    final finite = base.copyWith(
      recurrence: CalendarEventRecurrence(
        rule: CalendarEventRule(
          frequency: CalendarEventFrequency.daily,
          untilUtc: DateTime.utc(2026, 3, 29, 9),
          byDay: [],
          byMonthDay: [],
          byYearDay: [],
          byWeekNo: [],
          byMonth: [],
          byHour: [],
          byMinute: [],
          bySetPosition: [],
        ),
        inclusions: [fixture.timing(31, kind: kind, hour: 9)],
        exclusions: [],
      ),
    );
    expect(
      eventSchedulingTimedIsProvablyLast(
        finite,
        fixture.timing(29, kind: kind, hour: 9),
      ),
      false,
    );
    expect(
      eventSchedulingTimedIsProvablyLast(
        finite,
        fixture.timing(31, kind: kind, hour: 9),
      ),
      true,
    );
    expect(
      eventSchedulingTimedIsProvablyLast(
        base,
        fixture.timing(29, kind: kind, hour: 9),
      ),
      false,
    );
  });

  test('last zoned proof accounts for UTC UNTIL across a DST change', () {
    const kind = CalendarEventTimeKind.zoned;
    final base = fixture.content(kind: kind, hour: 9);
    final finite = base.copyWith(
      recurrence: CalendarEventRecurrence(
        rule: CalendarEventRule(
          frequency: CalendarEventFrequency.daily,
          untilUtc: DateTime.utc(2026, 3, 29, 7),
          byDay: [],
          byMonthDay: [],
          byYearDay: [],
          byWeekNo: [],
          byMonth: [],
          byHour: [],
          byMinute: [],
          bySetPosition: [],
        ),
        inclusions: [],
        exclusions: [],
      ),
    );
    expect(
      eventSchedulingTimedIsProvablyLast(
        finite,
        fixture.timing(28, kind: kind, hour: 9),
      ),
      false,
    );
    expect(
      eventSchedulingTimedIsProvablyLast(
        finite,
        fixture.timing(29, kind: kind, hour: 9),
      ),
      true,
    );
  });

  test('last-date proof includes additions and rejects unbounded rules', () {
    final base = fixture.content();
    CalendarEventRule rule({CalendarEventCivil? until}) => CalendarEventRule(
      frequency: CalendarEventFrequency.daily,
      untilDate: until,
      byDay: [],
      byMonthDay: [],
      byYearDay: [],
      byWeekNo: [],
      byMonth: [],
      byHour: [],
      byMinute: [],
      bySetPosition: [],
    );
    final finite = base.copyWith(
      recurrence: CalendarEventRecurrence(
        rule: rule(until: CalendarEventCivil(year: 2026, month: 3, day: 29)),
        inclusions: [fixture.timing(31)],
        exclusions: [],
      ),
    );
    expect(
      eventSchedulingDateIsProvablyLast(finite, fixture.timing(29)),
      false,
    );
    expect(eventSchedulingDateIsProvablyLast(finite, fixture.timing(31)), true);
    final unbounded = base.copyWith(
      recurrence: CalendarEventRecurrence(
        rule: rule(),
        inclusions: [],
        exclusions: [],
      ),
    );
    expect(
      () => eventSchedulingDateIsProvablyLast(unbounded, fixture.timing(29)),
      throwsArgumentError,
    );
  });
}
