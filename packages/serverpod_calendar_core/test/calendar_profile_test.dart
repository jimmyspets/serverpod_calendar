import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

import 'fixtures/timezone_profile_reference.dart';

void main() {
  test(
    'all zones and supported years agree with independent Python TZif reader',
    () {
      final resolver = NamedZoneResolver();
      expect(resolver.zoneIds.length, referenceZoneCount);
      var digest = 0;
      for (final id in resolver.zoneIds) {
        for (final second in referenceInstants) {
          final instant = DateTime.fromMillisecondsSinceEpoch(
            second * 1000,
            isUtc: true,
          );
          String offset;
          try {
            final local = resolver.localAt(instant, zoneId: id);
            offset = DateTime.utc(
              local.date.year,
              local.date.month,
              local.date.day,
              local.hour,
              local.minute,
              local.second,
            ).difference(instant).inSeconds.toString();
          } on ZoneCoverageException {
            offset = 'unknown';
          }
          for (final char in '$id:$second:$offset;'.codeUnits) {
            digest = (digest * 65599 + char) % 2147483647;
          }
        }
      }
      expect(digest, referenceDigest);
    },
  );

  test('exclusive boundary cannot become a start, recurrence date or due', () {
    const boundary = CalendarDate.exclusiveEnd();
    final civil = CivilDateTime(date: boundary, hour: 0, minute: 0);
    final end = TimedValue.zonedEnd(civil, zoneId: 'Europe/Stockholm');
    final first = TimedValue.utc(DateTime.utc(2099, 12, 31));
    expect(() => TimedValue.utc(DateTime.utc(2100)), throwsRangeError);
    expect(
      () => TimedValue.zoned(civil, zoneId: 'Europe/Stockholm'),
      throwsRangeError,
    );
    expect(() => TimedEventSpan(start: end), throwsRangeError);
    expect(
      () => TimedRecurrenceSet(start: end, maxExplicitDates: 0),
      throwsRangeError,
    );
    expect(
      () => TimedRecurrenceSet(
        start: first,
        inclusions: [end],
        maxExplicitDates: 1,
      ),
      throwsRangeError,
    );
    expect(
      () => DateRecurrenceSet(start: boundary, maxExplicitDates: 0),
      throwsRangeError,
    );
    expect(
      () => DateRecurrenceSet(
        start: first.civil.date,
        inclusions: [boundary],
        maxExplicitDates: 1,
      ),
      throwsRangeError,
    );
    expect(() => DateTaskTiming(start: boundary), throwsRangeError);
    expect(() => DateTaskTiming(due: boundary), throwsRangeError);
    expect(() => TimedTaskTiming(due: end), throwsRangeError);
    final ordinary = TimedValue.zoned(
      CivilDateTime(date: first.civil.date, hour: 0, minute: 0),
      zoneId: 'Europe/Stockholm',
    );
    expect(
      () => TimedEventSpan(start: ordinary).projectAt(end),
      throwsRangeError,
    );
    expect(() => TimedTaskTiming(start: ordinary).at(end), throwsRangeError);
    final span = TimedEventSpan(start: ordinary);
    final dateSpan = DateEventSpan(start: first.civil.date);
    expect(() => TimedEventException.cancel(end), throwsRangeError);
    expect(() => TimedEventException.replace(end, span), throwsRangeError);
    expect(
      () => TimedEventRangeChange(originalStart: end, replacement: span),
      throwsRangeError,
    );
    expect(
      () => DateEventException.cancel(originalStart: boundary),
      throwsRangeError,
    );
    expect(
      () => DateEventException.replace(
        originalStart: boundary,
        replacement: dateSpan,
      ),
      throwsRangeError,
    );
    expect(
      () =>
          DateEventRangeChange(originalStart: boundary, replacement: dateSpan),
      throwsRangeError,
    );
  });

  test(
    'last all-day event and zoned event resolve their exclusive endpoints',
    () {
      final last = CalendarDate(year: 2099, month: 12, day: 31);
      final allDay = DateEventSpan(start: last);
      expect(allDay.endExclusive, const CalendarDate.exclusiveEnd());
      expect(
        allDay.occupiedWindowIn(zoneId: 'Europe/Stockholm')!.end,
        DateTime.utc(2099, 12, 31, 23),
      );
      expect(
        allDay.occupiedWindowIn(zoneId: 'America/New_York')!.end,
        DateTime.utc(2100, 1, 1, 5),
      );
      final start = TimedValue.zoned(
        CivilDateTime(date: last, hour: 23, minute: 59, second: 59),
        zoneId: 'America/New_York',
      );
      expect(
        TimedEventSpan(
          start: start,
          duration: CalendarDuration(seconds: 1),
        ).endExclusive,
        DateTime.utc(2100, 1, 1, 5),
      );
    },
  );

  test('no recurrence starts are generated in excluded year 2100', () {
    final last = CalendarDate(year: 2099, month: 12, day: 31);
    final values = DateRecurrenceGenerator().expand(
      start: last,
      rule: DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.daily,
        count: 5,
      ),
      from: last,
      through: last,
      maxCandidateDays: 10,
      maxResults: 10,
    );
    expect(values, [last]);
    final timed = TimedRecurrenceGenerator().expand(
      start: TimedValue.utc(DateTime.utc(2099, 12, 31, 23, 59, 59)),
      rule: TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.minutely,
        count: 5,
      ),
      window: UtcWindow(
        start: DateTime.utc(2099, 12, 31),
        end: DateTime.utc(2100),
      ),
      maxCandidateWork: 10,
      maxResults: 10,
    );
    expect(timed.length, 1);
  });
}
