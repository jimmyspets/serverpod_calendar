import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate date(int year, int month, int day) =>
    CalendarDate(year: year, month: month, day: day);
CalendarDate d(int day) => date(2026, 1, day);

void main() {
  DateEventSeries series({
    CalendarDate? start,
    int length = 1,
    DateRecurrenceRule? rule,
    List<CalendarDate> inclusions = const [],
    List<CalendarDate> exclusions = const [],
  }) {
    final origin = start ?? d(1);
    return DateEventSeries(
      span: DateEventSpan(
        start: origin,
        duration: CalendarDuration(days: length),
      ),
      recurrence: DateRecurrenceSet(
        start: origin,
        rule: rule,
        inclusions: inclusions,
        exclusions: exclusions,
        maxExplicitDates: 100,
      ),
    );
  }

  List<DateEventSpan> expand(
    DateEventSeries value, {
    CalendarDate? from,
    CalendarDate? until,
    int work = 1000,
    int raw = 100,
    int results = 100,
  }) => value.expandOverlapping(
    from: from ?? d(1),
    until: until ?? d(31),
    maxCandidateDays: work,
    maxRuleOccurrences: raw,
    maxResults: results,
  );
  DateRecurrenceRule daily(int count) => DateRecurrenceRule(
    frequency: DateRecurrenceFrequency.daily,
    count: count,
  );
  Matcher limit(String name) => throwsA(
    isA<RecurrenceLimitException>().having((e) => e.limit, 'limit', name),
  );

  test('rejects inconsistent recurrence and template starts', () {
    expect(
      () => DateEventSeries(
        recurrence: DateRecurrenceSet(start: d(1), maxExplicitDates: 0),
        span: DateEventSpan(start: d(2)),
      ),
      throwsArgumentError,
    );
  });
  test('includes earlier starts but excludes both touching boundaries', () {
    final value = series(length: 3, rule: daily(6));
    final spans = expand(value, from: d(5), until: d(6));
    expect(spans.map((s) => s.start), [d(3), d(4), d(5)]);
    expect(spans.map((s) => s.endExclusive), [d(6), d(7), d(8)]);
  });
  test('does not clip returned spans to query bounds', () {
    final spans = expand(series(length: 10), from: d(5), until: d(6));
    expect(spans.single.start, d(1));
    expect(spans.single.endExclusive, d(11));
    expect(spans.single.dayCount, 10);
  });
  test('one-day defaults do not look back into an adjacent day', () {
    final origin = d(1);
    final value = DateEventSeries(
      recurrence: DateRecurrenceSet(
        start: origin,
        rule: daily(3),
        maxExplicitDates: 0,
      ),
      span: DateEventSpan(start: origin),
    );
    final spans = expand(value, from: d(2), until: d(3));
    expect(spans.single.start, d(2));
    expect(spans.single.end, isNull);
    expect(spans.single.duration, isNull);
    expect(spans.single.endExclusive, d(3));
  });
  test('explicit-end templates shift the same calendar-day length', () {
    final origin = date(2024, 2, 28);
    final value = DateEventSeries(
      recurrence: DateRecurrenceSet(
        start: origin,
        rule: daily(3),
        maxExplicitDates: 0,
      ),
      span: DateEventSpan(start: origin, end: date(2024, 3, 1)),
    );
    final spans = expand(value, from: origin, until: date(2024, 3, 3));
    expect(spans.map((s) => s.start), [
      origin,
      date(2024, 2, 29),
      date(2024, 3, 1),
    ]);
    expect(spans.map((s) => s.end), [
      date(2024, 3, 1),
      date(2024, 3, 2),
      date(2024, 3, 3),
    ]);
    expect(spans.every((s) => s.duration == null && s.dayCount == 2), isTrue);
    expect(value.span.end, date(2024, 3, 1));
  });
  test('week-duration templates preserve units and original object', () {
    final duration = CalendarDuration(weeks: 1);
    final value = DateEventSeries(
      recurrence: DateRecurrenceSet(
        start: d(1),
        rule: daily(2),
        maxExplicitDates: 0,
      ),
      span: DateEventSpan(start: d(1), duration: duration),
    );
    final spans = expand(value, from: d(7), until: d(9));
    expect(spans.map((s) => s.start), [d(1), d(2)]);
    expect(
      spans.every(
        (s) =>
            identical(s.duration, duration) && s.end == null && s.dayCount == 7,
      ),
      isTrue,
    );
  });
  test('COUNT remains historical when earlier spans overlap the query', () {
    final spans = expand(
      series(length: 5, rule: daily(3)),
      from: d(6),
      until: d(8),
    );
    expect(spans.map((s) => s.start), [d(2), d(3)]);
    expect(
      expand(
        series(length: 5, rule: daily(3)),
        from: d(8),
        until: d(9),
      ),
      isEmpty,
    );
  });
  test('UNTIL limits starts rather than their exclusive ends', () {
    final value = series(
      length: 5,
      rule: DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.daily,
        until: d(2),
      ),
    );
    expect(expand(value, from: d(6), until: d(7)).map((s) => s.start), [d(2)]);
  });
  test('earlier inclusions keep the same span without rebasing DTSTART', () {
    final value = series(
      start: d(10),
      length: 4,
      rule: daily(2),
      inclusions: [d(2), d(20)],
    );
    expect(expand(value, from: d(4), until: d(5)).single.start, d(2));
    expect(value.recurrence.start, d(10));
    expect(value.recurrence.rule!.count, 2);
    expect(expand(value, from: d(22), until: d(23)).single.start, d(20));
  });
  test('exclusions remove whole spans and never replenish COUNT', () {
    final value = series(
      length: 3,
      rule: daily(3),
      inclusions: [d(1), d(2)],
      exclusions: [d(1), d(2)],
    );
    expect(expand(value, from: d(3), until: d(6)).map((s) => s.start), [d(3)]);
    expect(value.recurrence.start, d(1));
  });
  test('sorted unique starts remain distinct when their spans overlap', () {
    final value = series(
      length: 5,
      rule: daily(3),
      inclusions: [d(3), d(2), d(6), d(6)],
    );
    final spans = expand(value);
    expect(spans.map((s) => s.start), [d(1), d(2), d(3), d(6)]);
    expect(spans[0].overlaps(spans[1]), isTrue);
    expect(() => spans.clear(), throwsUnsupportedError);
  });
  test('result limits include starts before the requested lower bound', () {
    final value = series(length: 5, rule: daily(5));
    expect(
      () => expand(value, from: d(5), until: d(6), results: 4),
      limit('maxResults'),
    );
    expect(expand(value, from: d(5), until: d(6), results: 5).length, 5);
  });
  test('raw rule limits use the widened range before exclusions', () {
    final value = series(
      length: 5,
      rule: daily(5),
      exclusions: [d(1), d(2), d(3), d(4)],
    );
    expect(
      () => expand(value, from: d(5), until: d(6), raw: 4),
      limit('maxRuleOccurrences'),
    );
    expect(
      expand(value, from: d(5), until: d(6), raw: 5, results: 1).single.start,
      d(5),
    );
  });
  test('candidate work includes pre-query recurrence history', () {
    final value = series(rule: daily(20));
    expect(
      () => expand(value, from: d(20), until: d(21), work: 19),
      limit('maxCandidateDays'),
    );
    expect(
      expand(value, from: d(20), until: d(21), work: 20).single.start,
      d(20),
    );
  });
  test('inclusion-only results still obey the final cap', () {
    expect(
      () => expand(
        series(length: 5, inclusions: [d(2), d(3)]),
        from: d(4),
        until: d(5),
        results: 2,
      ),
      limit('maxResults'),
    );
  });
  test('invalid query bounds reject empty and reversed windows', () {
    for (final until in [d(5), d(4)]) {
      expect(
        () => expand(series(), from: d(5), until: until),
        throwsArgumentError,
      );
    }
  });
  test('invalid budgets reject even a no-match no-rule query', () {
    for (final bad in [0, -1, DateRecurrenceRule.maxScalar + 1]) {
      expect(() => expand(series(), from: d(20), work: bad), throwsRangeError);
      expect(() => expand(series(), from: d(20), raw: bad), throwsRangeError);
      expect(
        () => expand(series(), from: d(20), results: bad),
        throwsRangeError,
      );
    }
  });
  test('excluded mismatched DTSTART still fails rule validation', () {
    final value = series(
      rule: DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.weekly,
        byDay: [ByDayValue(weekday: Weekday.monday)],
      ),
      exclusions: [d(1)],
    );
    expect(() => expand(value, from: d(20)), throwsArgumentError);
  });
  test('lookback clamps safely at the first supported date', () {
    final first = date(1970, 1, 1);
    final value = series(start: first, length: 30, rule: daily(2));
    expect(
      expand(value, from: first, until: first.addDays(1)).single.start,
      first,
    );
    expect(
      expand(value, from: first.addDays(1), until: first.addDays(2)).length,
      2,
    );
  });
  test('full-profile length can overlap a query near its far end', () {
    final first = date(1970, 1, 1);
    final last = date(2099, 12, 31);
    final value = DateEventSeries(
      recurrence: DateRecurrenceSet(start: first, maxExplicitDates: 0),
      span: DateEventSpan(start: first, end: last),
    );
    final result = expand(value, from: last.addDays(-1), until: last);
    expect(result.single.start, first);
    expect(result.single.endExclusive, last);
  });
  test('query upper bound excludes an otherwise invalid terminal start', () {
    final origin = date(2099, 12, 30);
    final value = series(start: origin, rule: daily(2));
    expect(
      expand(
        value,
        from: origin,
        until: date(2099, 12, 31),
      ).single.endExclusive,
      date(2099, 12, 31),
    );
  });
  test('overflow in any overlapping occurrence fails the whole query', () {
    final origin = date(2099, 12, 28);
    final value = series(
      start: origin,
      length: 3,
      inclusions: [date(2099, 12, 30)],
    );
    expect(
      () => expand(value, from: origin, until: date(2099, 12, 31)),
      throwsRangeError,
    );
    final excluded = series(
      start: origin,
      length: 3,
      inclusions: [date(2099, 12, 30)],
      exclusions: [date(2099, 12, 30)],
    );
    expect(
      expand(excluded, from: origin, until: date(2099, 12, 31)).single.start,
      origin,
    );
  });
  test('explicit-end overflow fails instead of clipping a returned span', () {
    final origin = date(2099, 12, 28);
    final value = DateEventSeries(
      recurrence: DateRecurrenceSet(
        start: origin,
        inclusions: [date(2099, 12, 30)],
        maxExplicitDates: 1,
      ),
      span: DateEventSpan(start: origin, end: date(2099, 12, 31)),
    );
    expect(
      () => expand(value, from: origin, until: date(2099, 12, 31)),
      throwsRangeError,
    );
  });
  test(
    'Sunday WKST remains independent of ISO labels and overlap lookback',
    () {
      final sunday = date(2021, 1, 3);
      final value = series(
        start: sunday,
        length: 3,
        rule: DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          weekStart: Weekday.sunday,
          byWeekNo: [1],
          count: 1,
        ),
      );
      final result = expand(
        value,
        from: date(2021, 1, 5),
        until: date(2021, 1, 6),
      );
      expect(result.single.start, sunday);
      expect(
        IsoWeekDate.fromDate(result.single.start).toString(),
        '2020-W53-7',
      );
      expect(value.recurrence.rule!.weekStart, Weekday.sunday);
    },
  );
  test('overlap results agree with an independent occupied-date oracle', () {
    final starts = [1, 3, 4, 8, 12];
    for (var length = 1; length <= 7; length++) {
      final value = series(
        length: length,
        inclusions: [for (final n in starts) d(n)],
        exclusions: [d(4)],
      );
      for (var from = 1; from <= 16; from++) {
        for (var until = from + 1; until <= 18; until++) {
          final query = {for (var n = from; n < until; n++) n};
          final expected = [
            for (final start in starts)
              if (start != 4 &&
                  {for (var n = start; n < start + length; n++) n}
                      .intersection(query)
                      .isNotEmpty)
                d(start),
          ];
          expect(
            expand(value, from: d(from), until: d(until)).map((s) => s.start),
            expected,
          );
        }
      }
    }
  });
  test('equality/hash retain recurrence and span forms', () {
    final a = series(length: 3, rule: daily(2));
    final b = series(length: 3, rule: daily(2));
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(series(length: 4, rule: daily(2))));
    expect(a, isNot(series(length: 3, rule: daily(3))));
    expect(a, isNot(a.span));
    final implicit = DateEventSeries(
      recurrence: a.recurrence,
      span: DateEventSpan(start: d(1)),
    );
    expect(implicit, isNot(series(rule: daily(2))));
  });
}
