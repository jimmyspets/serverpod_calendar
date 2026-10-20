import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

TimedValue u(int day, [int h = 9, int m = 0]) =>
    TimedValue.utc(DateTime.utc(2026, 1, day, h, m));
TimedValue z(int month, int day, int hour, [int minute = 30]) =>
    TimedValue.zoned(
      CivilDateTime(
        date: CalendarDate(year: 2026, month: month, day: day),
        hour: hour,
        minute: minute,
      ),
      zoneId: 'Europe/Stockholm',
    );
List<TimedValue> run(
  TimedValue start,
  TimedRecurrenceRule rule, {
  UtcWindow? window,
  int work = 100000,
  int results = 1000,
}) => TimedRecurrenceGenerator().expand(
  start: start,
  rule: rule,
  window:
      window ?? UtcWindow(start: DateTime.utc(2026), end: DateTime.utc(2030)),
  maxCandidateWork: work,
  maxResults: results,
);
void main() {
  test('profile identity and guarded factories', () {
    expect(z(1, 1, 9, 0).instant, DateTime.utc(2026, 1, 1, 8));
    expect(z(1, 1, 9).zoneDataVersion, NamedZoneResolver.dataVersion);
    expect(u(1).zoneDataVersion, isNull);
    expect(() => u(1).compareTo(z(1, 1, 9)), throwsArgumentError);
    expect(() => TimedValue.utc(DateTime(2026)), throwsArgumentError);
    expect(() => TimedValue.utc(DateTime.utc(0)), throwsRangeError);
  });
  for (final f in TimedRecurrenceFrequency.values) {
    test('$f count and safe enormous interval', () {
      final values = run(u(1), TimedRecurrenceRule(frequency: f, count: 3));
      expect(values.length, 3);
      expect(values.first, u(1));
      expect(
        run(
          u(1),
          TimedRecurrenceRule(
            frequency: f,
            interval: DateRecurrenceRule.maxScalar,
          ),
        ),
        [u(1)],
      );
    });
  }
  test('canonical immutable lists and structural equality', () {
    final hours = [9, 8, 9];
    final a = TimedRecurrenceRule(
      frequency: TimedRecurrenceFrequency.daily,
      byHour: hours,
      byMinute: [30, 0, 30],
    );
    hours.clear();
    expect(a.byHour, [8, 9]);
    expect(a.byMinute, [0, 30]);
    expect(() => a.byHour.add(10), throwsUnsupportedError);
    final b = TimedRecurrenceRule(
      frequency: TimedRecurrenceFrequency.daily,
      byHour: [8, 9],
      byMinute: [0, 30],
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
  test('invalid fields and illegal rule combinations rejected', () {
    for (final action in <void Function()>[
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        interval: 0,
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        count: 0,
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        byHour: [24],
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        byMinute: [60],
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        bySetPosition: [367],
      ),
    ]) {
      expect(action, throwsRangeError);
    }
    for (final action in <void Function()>[
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        count: 1,
        until: DateTime.utc(2026),
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        until: DateTime(2026),
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        bySetPosition: [0],
        byHour: [9],
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        bySetPosition: [1],
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.hourly,
        byWeekNo: [1],
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.minutely,
        byDay: [ByDayValue(weekday: Weekday.monday, ordinal: 1)],
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.weekly,
        byMonthDay: [1],
      ),
      () => TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        byYearDay: [1],
      ),
    ]) {
      expect(action, throwsArgumentError);
    }
  });
  test('daily time expansion preserves ordinary seconds', () {
    final start = TimedValue.utc(DateTime.utc(2026, 1, 1, 8, 15, 7));
    final values = run(
      start,
      TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        count: 5,
        byHour: [8, 10],
        byMinute: [15, 45],
      ),
    );
    expect(
      values.map((v) => (v.civil.date.day, v.civil.hour, v.civil.minute)),
      [(1, 8, 15), (1, 8, 45), (1, 10, 15), (1, 10, 45), (2, 8, 15)],
    );
    expect(
      values.every((v) => v.civil.second == 7 && v.civil.microsecond == 0),
      isTrue,
    );
  });
  test('minutely clock limits with interval', () {
    expect(
      run(
        u(1, 9, 5),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.minutely,
          interval: 5,
          count: 3,
          byHour: [9],
          byMinute: [5, 15, 25],
        ),
      ).map((v) => v.civil.minute),
      [5, 15, 25],
    );
  });
  test('hourly expansion with date filter', () {
    expect(
      run(
        u(1, 9, 15),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.hourly,
          interval: 2,
          count: 5,
          byHour: [9, 11],
          byMinute: [15, 45],
          byYearDay: [1, 2],
        ),
      ).map((v) => (v.civil.date.day, v.civil.hour, v.civil.minute)),
      [(1, 9, 15), (1, 9, 45), (1, 11, 15), (1, 11, 45), (2, 9, 15)],
    );
  });
  test('monthly invalid dates do not consume count', () {
    expect(
      run(
        u(31),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.monthly,
          count: 3,
        ),
      ).map((v) => v.civil.date.month),
      [1, 3, 5],
    );
  });
  test('set positions after full time expansion and start alignment', () {
    expect(
      run(
        u(1, 10, 45),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          count: 2,
          byHour: [8, 10],
          byMinute: [15, 45],
          bySetPosition: [-1],
        ),
      ),
      [u(1, 10, 45), u(2, 10, 45)],
    );
    expect(
      () => run(
        u(1),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          byHour: [9, 10],
          bySetPosition: [-1],
        ),
      ),
      throwsArgumentError,
    );
  });
  test('half-open queries preserve historical COUNT', () {
    final rule = TimedRecurrenceRule(
      frequency: TimedRecurrenceFrequency.daily,
      count: 3,
    );
    expect(
      run(
        u(1),
        rule,
        window: UtcWindow(start: u(2).instant, end: u(3).instant),
      ),
      [u(2)],
    );
    expect(
      run(
        u(1),
        rule,
        window: UtcWindow(start: u(4).instant, end: u(5).instant),
      ),
      isEmpty,
    );
  });
  test('inclusive UTC UNTIL; mismatched DTSTART rejected', () {
    expect(
      run(
        u(1),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          until: u(2).instant,
        ),
      ),
      [u(1), u(2)],
    );
    expect(
      () => run(
        u(1),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          until: DateTime.utc(2025),
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => run(
        u(1),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          byHour: [10],
        ),
      ),
      throwsArgumentError,
    );
  });
  test('WKST changes interval grouping', () {
    final days = [
      ByDayValue(weekday: Weekday.thursday),
      ByDayValue(weekday: Weekday.sunday),
    ];
    expect(
      run(
        u(1),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.weekly,
          interval: 2,
          count: 4,
          byDay: days,
        ),
      ).map((v) => v.civil.date.day),
      [1, 4, 15, 18],
    );
    expect(
      run(
        u(1),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.weekly,
          interval: 2,
          count: 4,
          weekStart: Weekday.sunday,
          byDay: days,
        ),
      ).map((v) => v.civil.date.day),
      [1, 11, 15, 25],
    );
  });
  test('DST gap skips without count; fold resolves first', () {
    final window = UtcWindow(
      start: DateTime.utc(2026),
      end: DateTime.utc(2027),
    );
    expect(
      run(
        z(3, 28, 2),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          count: 3,
        ),
        window: window,
      ).map((v) => v.civil.date.day),
      [28, 30, 31],
    );
    final fall = run(
      z(10, 24, 2),
      TimedRecurrenceRule(frequency: TimedRecurrenceFrequency.daily, count: 3),
      window: window,
    );
    expect(fall[1].instant, DateTime.utc(2026, 10, 25, 0, 30));
    expect(fall[2].instant, DateTime.utc(2026, 10, 26, 1, 30));
  });
  test('explicit gap DTSTART retained with original civil identity', () {
    final start = z(3, 29, 2);
    final values = run(
      start,
      TimedRecurrenceRule(frequency: TimedRecurrenceFrequency.hourly, count: 3),
      window: UtcWindow(start: DateTime.utc(2026), end: DateTime.utc(2027)),
    );
    expect(start.instant, DateTime.utc(2026, 3, 29, 1, 30));
    expect(values.map((v) => v.civil.hour), [2, 3, 4]);
  });
  test('zoned until is UTC and positions follow gap removal', () {
    final window = UtcWindow(
      start: DateTime.utc(2026),
      end: DateTime.utc(2027),
    );
    expect(
      run(
        z(3, 28, 9, 0),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          until: DateTime.utc(2026, 3, 29, 7),
        ),
        window: window,
      ).length,
      2,
    );
    expect(
      run(
        z(3, 28, 3),
        TimedRecurrenceRule(
          frequency: TimedRecurrenceFrequency.daily,
          count: 2,
          byHour: [2, 3],
          bySetPosition: [-1],
        ),
        window: window,
      ).map((v) => v.civil.hour),
      [3, 3],
    );
  });
  test('work, raw-result and history limits fail explicitly', () {
    final rule = TimedRecurrenceRule(
      frequency: TimedRecurrenceFrequency.daily,
      count: 3,
    );
    expect(
      () => run(u(1), rule, work: 1),
      throwsA(
        isA<RecurrenceLimitException>().having(
          (e) => e.limit,
          'limit',
          'maxCandidateWork',
        ),
      ),
    );
    expect(
      () => run(u(1), rule, results: 2),
      throwsA(
        isA<RecurrenceLimitException>().having(
          (e) => e.limit,
          'limit',
          'maxResults',
        ),
      ),
    );
    expect(() => run(u(1), rule, work: 0), throwsRangeError);
    expect(
      () => run(
        u(1),
        TimedRecurrenceRule(frequency: TimedRecurrenceFrequency.hourly),
        work: 5,
        window: UtcWindow(start: u(20).instant, end: u(21).instant),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('zone coverage is never inferred from recurrence', () {
    expect(
      () => run(
        z(1, 1, 9),
        TimedRecurrenceRule(frequency: TimedRecurrenceFrequency.daily),
        window: UtcWindow(start: DateTime.utc(2100), end: DateTime.utc(2101)),
      ),
      throwsRangeError,
    );
  });
  test('finite independent minute oracle', () {
    for (final step in [1, 2, 5, 17]) {
      final end = DateTime.utc(2026, 1, 1, 11);
      final expected = <DateTime>[];
      for (
        var d = u(1).instant;
        d.isBefore(end);
        d = d.add(Duration(minutes: step))
      ) {
        if ([9, 10].contains(d.hour) &&
            [0, 5, 10, 15, 30, 45].contains(d.minute)) {
          expected.add(d);
        }
      }
      expect(
        run(
          u(1),
          TimedRecurrenceRule(
            frequency: TimedRecurrenceFrequency.minutely,
            interval: step,
            byHour: [9, 10],
            byMinute: [0, 5, 10, 15, 30, 45],
          ),
          window: UtcWindow(start: u(1).instant, end: end),
        ).map((v) => v.instant),
        expected,
      );
    }
  });
}
