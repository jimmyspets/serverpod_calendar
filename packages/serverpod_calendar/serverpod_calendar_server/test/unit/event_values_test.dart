@TestOn('vm')
library;

import 'package:test/test.dart';
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
void main() {
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
        () => validateEventContent(value.copyWith(recurring: true)),
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
