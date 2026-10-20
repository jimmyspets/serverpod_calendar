import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

TimedValue local(
  String zone,
  int year,
  int month,
  int day,
  int hour, [
  int minute = 0,
]) => TimedValue.zoned(
  CivilDateTime(
    date: CalendarDate(year: year, month: month, day: day),
    hour: hour,
    minute: minute,
  ),
  zoneId: zone,
);
List<TimedValue> expand(
  TimedValue start,
  TimedRecurrenceRule rule,
  UtcWindow window,
) => TimedRecurrenceGenerator().expand(
  start: start,
  rule: rule,
  window: window,
  maxCandidateWork: 100000,
  maxResults: 1000,
);
void main() {
  test('all-day explicit projection preserves 23/25-hour Stockholm days', () {
    for (final v in [(3, 29, 23), (10, 25, 25)]) {
      final span = DateEventSpan(
        start: CalendarDate(year: 2026, month: v.$1, day: v.$2),
      );
      expect(
        span.occupiedWindowIn(zoneId: 'Europe/Stockholm')!.duration,
        Duration(hours: v.$3),
      );
      expect(span.dayCount, 1);
    }
  });
  test(
    'half-hour DST and a wholly skipped date do not become 24-hour days',
    () {
      expect(
        DateEventSpan(start: CalendarDate(year: 2026, month: 10, day: 4))
            .occupiedWindowIn(zoneId: 'Australia/Lord_Howe')!
            .duration,
        const Duration(hours: 23, minutes: 30),
      );
      expect(
        DateEventSpan(start: CalendarDate(year: 2011, month: 12, day: 30))
            .occupiedWindowIn(zoneId: 'Pacific/Apia'),
        isNull,
      );
      expect(
        () =>
            DateEventSpan(start: CalendarDate(year: 2038, month: 1, day: 1))
                .occupiedWindowIn(zoneId: 'UTC'),
        throwsRangeError,
      );
    },
  );
  test(
    'Lord Howe half-hour generated gap skipped; clock units remain elapsed',
    () {
      final start = local('Australia/Lord_Howe', 2026, 10, 3, 2, 15);
      final values = expand(
        start,
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          count: 3,
        ),
        UtcWindow(
          start: DateTime.utc(2026, 10, 1),
          end: DateTime.utc(2026, 10, 10),
        ),
      );
      expect(values.map((v) => v.civil.date.day), [3, 5, 6]);
      expect(
        start.add(CalendarDuration(days: 1)),
        DateTime.utc(2026, 10, 3, 15, 45),
      );
      expect(
        start.add(CalendarDuration(hours: 24)),
        DateTime.utc(2026, 10, 3, 15, 45),
      );
    },
  );
  test('Apia whole-date gap skipped without consuming count', () {
    final start = local('Pacific/Apia', 2011, 12, 29, 9);
    final values = expand(
      start,
      TimedRecurrenceRule(frequency: TimedRecurrenceFrequency.daily, count: 3),
      UtcWindow(
        start: DateTime.utc(2011, 12, 28),
        end: DateTime.utc(2012, 1, 3),
      ),
    );
    expect(values.map((v) => (v.civil.date.month, v.civil.date.day)), [
      (12, 29),
      (12, 31),
      (1, 1),
    ]);
  });
  test(
    'hourly gap DTSTART can precede generated civil values with earlier UTC',
    () {
      final start = local('Europe/Stockholm', 2026, 3, 29, 2, 30);
      final values = expand(
        start,
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.minutely,
          interval: 30,
          count: 3,
        ),
        UtcWindow(
          start: DateTime.utc(2026, 3, 29, 1),
          end: DateTime.utc(2026, 3, 29, 2),
        ),
      );
      expect(values.map((v) => (v.civil.hour, v.civil.minute)), [
        (3, 0),
        (2, 30),
        (3, 30),
      ]);
      final set = TimedRecurrenceSet(
        start: start,
        rule: TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.minutely,
          interval: 30,
          count: 3,
        ),
        maxExplicitDates: 0,
      );
      final series = TimedEventSeries(
        recurrence: set,
        span: TimedEventSpan(start: start),
        maxChanges: 0,
        maxValidationCandidateWork: 100,
        maxValidationOccurrences: 10,
      );
      final occurrences = series.expandOverlapping(
        window: UtcWindow(
          start: DateTime.utc(2026, 3, 29, 1),
          end: DateTime.utc(2026, 3, 29, 2),
        ),
        maxCandidateWork: 100,
        maxRuleOccurrences: 10,
        maxBaseOccurrences: 10,
        maxResults: 10,
      );
      expect(occurrences.map((v) => v.originalStart), values);
    },
  );
  test(
    'zoned backward range shift includes original future dates across DST',
    () {
      final start = local('Europe/Stockholm', 2026, 3, 27, 9);
      final anchor = local('Europe/Stockholm', 2026, 3, 29, 9);
      final actual = local('Europe/Stockholm', 2026, 3, 28, 9);
      final series = TimedEventSeries(
        recurrence: TimedRecurrenceSet(
          start: start,
          rule: TimedRecurrenceRule(
            frequency: TimedRecurrenceFrequency.daily,
            count: 5,
          ),
          maxExplicitDates: 0,
        ),
        span: TimedEventSpan(start: start, duration: CalendarDuration(days: 1)),
        changes: [
          TimedEventRangeChange(
            originalStart: anchor,
            replacement: TimedEventSpan(
              start: actual,
              duration: CalendarDuration(days: 1),
            ),
          ),
        ],
        maxChanges: 1,
        maxValidationCandidateWork: 100,
        maxValidationOccurrences: 10,
      );
      final values = series.expandOverlapping(
        window: UtcWindow(
          start: DateTime.utc(2026, 3, 28, 8),
          end: DateTime.utc(2026, 3, 28, 9),
        ),
        maxCandidateWork: 100,
        maxRuleOccurrences: 10,
        maxBaseOccurrences: 10,
        maxResults: 10,
      );
      expect(values.map((v) => v.originalStart.civil.date.day), [28, 29]);
      expect(
        values.every(
          (v) => v.span.endExclusive == DateTime.utc(2026, 3, 29, 7),
        ),
        isTrue,
      );
    },
  );
  test('distant UTC recurrence preserves odd microseconds on web', () {
    for (final year in [1, 1600, 9999]) {
      final start = TimedValue.utc(DateTime.utc(year, 1, 1, 9, 0, 7, 123, 457));
      final values = expand(
        start,
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          count: 2,
        ),
        UtcWindow(start: DateTime.utc(year), end: DateTime.utc(year, 1, 3)),
      );
      expect(values.length, 2);
      expect(
        values.every(
          (v) => v.civil.microsecond == 123457 && v.instant.microsecond == 457,
        ),
        isTrue,
      );
    }
  });
  test('week-number and ordinal date filters compose with time expansion', () {
    final start = TimedValue.utc(DateTime.utc(2026, 1, 1, 9));
    final values = expand(
      start,
      TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.yearly,
        count: 4,
        byWeekNo: [1],
        byHour: [9, 10],
        byDay: [ByDayValue(weekday: Weekday.thursday)],
      ),
      UtcWindow(start: DateTime.utc(2026), end: DateTime.utc(2030)),
    );
    expect(values.map((v) => (v.civil.date.year, v.civil.hour)), [
      (2026, 9),
      (2026, 10),
      (2027, 9),
      (2027, 10),
    ]);
    final monthly = expand(
      TimedValue.utc(DateTime.utc(2026, 1, 30, 9)),
      TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.monthly,
        count: 2,
        byDay: [ByDayValue(weekday: Weekday.friday, ordinal: -1)],
      ),
      UtcWindow(start: DateTime.utc(2026), end: DateTime.utc(2027)),
    );
    expect(monthly.map((v) => v.civil.date.day), [30, 27]);
  });
}
