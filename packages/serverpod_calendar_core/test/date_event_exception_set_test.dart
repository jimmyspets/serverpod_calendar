import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int day) => CalendarDate(year: 2026, month: 1, day: day);
CalendarDate last(int day) => CalendarDate(year: 2099, month: 12, day: day);

void main() {
  DateEventSeries base({
    int length = 1,
    int count = 10,
    CalendarDate? start,
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
        rule: DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.daily,
          count: count,
        ),
        inclusions: inclusions,
        exclusions: exclusions,
        maxExplicitDates: 100,
      ),
    );
  }

  DateEventException cancel(int n) =>
      DateEventException.cancel(originalStart: d(n));
  DateEventException move(int original, int actual, {int length = 1}) =>
      DateEventException.replace(
        originalStart: d(original),
        replacement: DateEventSpan(
          start: d(actual),
          duration: CalendarDuration(days: length),
        ),
      );
  DateEventExceptionSet apply(
    DateEventSeries series,
    List<DateEventException> exceptions, {
    int cap = 100,
    int work = 1000,
    int raw = 100,
    int validated = 100,
  }) => DateEventExceptionSet(
    series: series,
    exceptions: exceptions,
    maxExceptions: cap,
    maxValidationCandidateDays: work,
    maxValidationRuleOccurrences: raw,
    maxValidationResults: validated,
  );
  List<DateEventOccurrence> query(
    DateEventExceptionSet value, {
    CalendarDate? from,
    CalendarDate? until,
    int work = 1000,
    int raw = 100,
    int baseCap = 100,
    int results = 100,
  }) => value.expandOverlapping(
    from: from ?? d(1),
    until: until ?? d(31),
    maxCandidateDays: work,
    maxRuleOccurrences: raw,
    maxBaseOccurrences: baseCap,
    maxResults: results,
  );
  Matcher limit(String name) => throwsA(
    isA<RecurrenceLimitException>().having((e) => e.limit, 'limit', name),
  );

  test('empty exception set preserves ordinary spans and original dates', () {
    final series = base(count: 3, length: 2);
    final set = apply(series, [], cap: 0);
    final values = query(set);
    expect(values.map((v) => v.originalStart), [d(1), d(2), d(3)]);
    expect(
      values.map((v) => v.span),
      series.expandOverlapping(
        from: d(1),
        until: d(31),
        maxCandidateDays: 1000,
        maxRuleOccurrences: 100,
        maxResults: 100,
      ),
    );
  });
  test('cancels a single occurrence without replenishing COUNT', () {
    final set = apply(base(count: 3), [cancel(2)]);
    expect(query(set).map((v) => v.originalStart), [d(1), d(3)]);
    expect(query(set, from: d(4)), isEmpty);
  });
  test('moved-in span is found even when original is outside base range', () {
    final set = apply(base(count: 3), [move(1, 20, length: 3)]);
    final value = query(set, from: d(21), until: d(22)).single;
    expect(value.originalStart, d(1));
    expect(value.span.start, d(20));
    expect(value.span.endExclusive, d(23));
    expect(query(set, from: d(1), until: d(2)), isEmpty);
  });
  test('replacement moved before DTSTART is included by actual span', () {
    final series = base(start: d(10), count: 2);
    final set = apply(series, [
      DateEventException.replace(
        originalStart: d(11),
        replacement: DateEventSpan(start: d(2)),
      ),
    ]);
    expect(query(set, from: d(2), until: d(3)).single.originalStart, d(11));
    expect(query(set, from: d(11), until: d(12)), isEmpty);
  });
  test('lengthened unchanged-start replacement bypasses template lookback', () {
    final set = apply(base(count: 2), [move(1, 1, length: 10)]);
    expect(query(set, from: d(9), until: d(10)).single.originalStart, d(1));
  });
  test('shortening removes overlap at the new exclusive end', () {
    final set = apply(base(count: 1, length: 10), [move(1, 1, length: 2)]);
    expect(query(set, from: d(3), until: d(4)), isEmpty);
  });
  test('replacement touching query boundaries is excluded', () {
    final set = apply(base(count: 2), [move(1, 5, length: 2), move(2, 9)]);
    expect(query(set, from: d(7), until: d(9)), isEmpty);
  });
  test(
    'same actual start retains each original identity in deterministic order',
    () {
      final set = apply(base(count: 4), [move(3, 4), move(2, 4)]);
      final values = query(set, from: d(4), until: d(5));
      expect(values.map((v) => v.originalStart), [d(2), d(3), d(4)]);
      expect(values.map((v) => v.span.start), [d(4), d(4), d(4)]);
      expect(values.toSet().length, 3);
    },
  );
  test('sorts by actual start before original date', () {
    final set = apply(base(count: 3), [move(1, 9), move(3, 1)]);
    expect(query(set).map((v) => v.originalStart), [d(3), d(2), d(1)]);
  });
  test('preserves complete replacement end/duration/default forms', () {
    final replacements = [
      DateEventSpan(start: d(10)),
      DateEventSpan(start: d(11), end: d(13)),
      DateEventSpan(start: d(12), duration: CalendarDuration(weeks: 1)),
    ];
    final set = apply(base(count: 3), [
      for (var i = 0; i < 3; i++)
        DateEventException.replace(
          originalStart: d(i + 1),
          replacement: replacements[i],
        ),
    ]);
    final values = query(set);
    for (var i = 0; i < 3; i++) {
      expect(identical(values[i].span, replacements[i]), isTrue);
    }
  });
  test(
    'snapshots and canonicalizes input; returned collections are immutable',
    () {
      final input = [cancel(3), move(1, 8)];
      final set = apply(base(count: 3), input);
      input.clear();
      expect(set.exceptions.map((v) => v.originalStart), [d(1), d(3)]);
      expect(() => set.exceptions.clear(), throwsUnsupportedError);
      expect(() => query(set).clear(), throwsUnsupportedError);
    },
  );
  test(
    'duplicate targets reject identical or conflicting exception values',
    () {
      for (final pair in [
        [cancel(2), cancel(2)],
        [cancel(2), move(2, 8)],
        [move(2, 8), move(2, 9)],
      ]) {
        expect(() => apply(base(), pair), throwsArgumentError);
      }
    },
  );
  test('raw exception cap runs before copying or duplicate handling', () {
    expect(
      () => apply(base(), [cancel(2), cancel(2)], cap: 1),
      limit('maxExceptions'),
    );
    expect(() => apply(base(), [cancel(2)], cap: 0), limit('maxExceptions'));
  });
  test('rejects targets before DTSTART or beyond COUNT', () {
    expect(
      () => apply(base(start: d(3), count: 2), [cancel(2)]),
      throwsArgumentError,
    );
    expect(() => apply(base(count: 2), [move(3, 8)]), throwsArgumentError);
  });
  test('EXDATE cannot be revived or targeted even with RDATE duplicate', () {
    final series = base(count: 3, inclusions: [d(2)], exclusions: [d(2)]);
    expect(() => apply(series, [cancel(2)]), throwsArgumentError);
    expect(() => apply(series, [move(2, 8)]), throwsArgumentError);
  });
  test('earlier RDATE is a valid original target', () {
    final set = apply(base(start: d(10), count: 1, inclusions: [d(2)]), [
      move(2, 4),
    ]);
    expect(query(set, from: d(4), until: d(5)).single.originalStart, d(2));
    expect(set.series.recurrence.start, d(10));
  });
  test('UNTIL constrains target membership but not replacement start', () {
    final origin = d(1);
    final series = DateEventSeries(
      span: DateEventSpan(start: origin),
      recurrence: DateRecurrenceSet(
        start: origin,
        rule: DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.daily,
          until: d(2),
        ),
        maxExplicitDates: 0,
      ),
    );
    expect(() => apply(series, [cancel(3)]), throwsArgumentError);
    final set = apply(series, [move(2, 20)]);
    expect(query(set, from: d(20), until: d(21)).single.originalStart, d(2));
  });
  test(
    'membership validation uses shared work rather than per-target resets',
    () {
      final series = base(count: 4);
      expect(
        () => apply(series, [cancel(2), cancel(4)], work: 3),
        limit('maxValidationCandidateDays'),
      );
      expect(
        apply(series, [cancel(2), cancel(4)], work: 4).exceptions.length,
        2,
      );
    },
  );
  test('membership raw/result caps include intervening recurrence starts', () {
    final series = base(count: 4);
    expect(
      () => apply(series, [cancel(1), cancel(4)], raw: 3),
      limit('maxValidationRuleOccurrences'),
    );
    expect(
      () => apply(series, [cancel(1), cancel(4)], validated: 3),
      limit('maxValidationResults'),
    );
    expect(
      apply(
        series,
        [cancel(1), cancel(4)],
        raw: 4,
        validated: 4,
      ).exceptions.length,
      2,
    );
  });
  test('validates all exception targets even outside an eventual query', () {
    expect(
      () => apply(base(count: 3), [move(1, 8), cancel(9)]),
      throwsArgumentError,
    );
  });
  test('invalid constructor budgets reject even empty inputs', () {
    for (final bad in [-1, DateRecurrenceRule.maxScalar + 1]) {
      expect(() => apply(base(), [], cap: bad), throwsRangeError);
    }
    for (final bad in [0, -1, DateRecurrenceRule.maxScalar + 1]) {
      expect(() => apply(base(), [], work: bad), throwsRangeError);
      expect(() => apply(base(), [], raw: bad), throwsRangeError);
      expect(() => apply(base(), [], validated: bad), throwsRangeError);
    }
  });
  test('query candidate/raw/base caps cannot be bypassed by cancellation', () {
    final set = apply(base(count: 4), [
      cancel(1),
      cancel(2),
      cancel(3),
      cancel(4),
    ]);
    expect(() => query(set, work: 3), limit('maxCandidateDays'));
    expect(() => query(set, raw: 3), limit('maxRuleOccurrences'));
    expect(() => query(set, baseCap: 3), limit('maxBaseOccurrences'));
    expect(query(set, work: 4, raw: 4, baseCap: 4, results: 1), isEmpty);
  });
  test(
    'final cap applies after cancellations and includes moved-in results',
    () {
      final cancelled = apply(base(count: 4), [
        cancel(1),
        cancel(2),
        cancel(3),
      ]);
      expect(query(cancelled, results: 1).single.originalStart, d(4));
      final moved = apply(base(count: 2), [move(1, 20), move(2, 20)]);
      expect(
        () => query(moved, from: d(20), until: d(21), results: 1),
        limit('maxResults'),
      );
      expect(query(moved, from: d(20), until: d(21), results: 2).length, 2);
    },
  );
  test('invalid query bounds/budgets reject even empty results', () {
    final set = apply(base(count: 1), []);
    expect(() => query(set, from: d(9), until: d(9)), throwsArgumentError);
    expect(() => query(set, from: d(9), until: d(8)), throwsArgumentError);
    for (final bad in [0, -1, DateRecurrenceRule.maxScalar + 1]) {
      expect(() => query(set, from: d(20), work: bad), throwsRangeError);
      expect(() => query(set, from: d(20), raw: bad), throwsRangeError);
      expect(() => query(set, from: d(20), baseCap: bad), throwsRangeError);
      expect(() => query(set, from: d(20), results: bad), throwsRangeError);
    }
  });
  test(
    'cancellation/replacement suppress base before terminal endpoint overflow',
    () {
      final series = base(
        start: last(27),
        count: 1,
        length: 3,
        inclusions: [last(30)],
      );
      final cancelled = apply(series, [
        DateEventException.cancel(originalStart: last(30)),
      ]);
      expect(
        query(cancelled, from: last(27), until: last(31)).single.originalStart,
        last(27),
      );
      final replaced = apply(series, [
        DateEventException.replace(
          originalStart: last(30),
          replacement: DateEventSpan(start: last(30)),
        ),
      ]);
      expect(
        query(replaced, from: last(30), until: last(31)).single.originalStart,
        last(30),
      );
      expect(
        () => query(apply(series, []), from: last(27), until: last(31)),
        throwsRangeError,
      );
    },
  );
  test('terminal original date can move to a representable span', () {
    final series = base(start: last(28), count: 1, inclusions: [last(31)]);
    final set = apply(series, [
      DateEventException.replace(
        originalStart: last(31),
        replacement: DateEventSpan(start: last(29)),
      ),
    ]);
    expect(
      query(set, from: last(29), until: last(30)).single.originalStart,
      last(31),
    );
  });
  test('first-profile-date replacement needs no out-of-range lookback', () {
    final first = CalendarDate(year: 1970, month: 1, day: 1);
    final series = base(start: first, count: 2, length: 10);
    final set = apply(series, [
      DateEventException.replace(
        originalStart: first.addDays(1),
        replacement: DateEventSpan(start: first),
      ),
    ]);
    final values = query(set, from: first, until: first.addDays(1));
    expect(values.map((v) => v.originalStart), [first, first.addDays(1)]);
  });
  test('WKST membership and ISO labels remain independent after moving', () {
    final sunday = CalendarDate(year: 2021, month: 1, day: 3);
    final series = DateEventSeries(
      span: DateEventSpan(start: sunday),
      recurrence: DateRecurrenceSet(
        start: sunday,
        rule: DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          weekStart: Weekday.sunday,
          byWeekNo: [1],
          count: 1,
        ),
        maxExplicitDates: 0,
      ),
    );
    final replacement = DateEventSpan(start: sunday.addDays(1));
    final set = apply(series, [
      DateEventException.replace(
        originalStart: sunday,
        replacement: replacement,
      ),
    ]);
    final value = query(
      set,
      from: replacement.start,
      until: replacement.endExclusive,
    ).single;
    expect(IsoWeekDate.fromDate(value.originalStart).toString(), '2020-W53-7');
    expect(IsoWeekDate.fromDate(value.span.start).toString(), '2021-W01-1');
    expect(series.recurrence.rule!.weekStart, Weekday.sunday);
  });
  test(
    'overlap/identity agrees with an independent finite occupied-date oracle',
    () {
      for (var length = 1; length <= 4; length++) {
        final set = apply(base(count: 8, length: length), [
          cancel(2),
          move(3, 13, length: 3),
          move(5, 1),
          move(7, 7, length: 5),
        ]);
        final effective = [
          for (var n = 1; n <= 8; n++)
            if (n != 2)
              (
                n,
                n == 3
                    ? 13
                    : n == 5
                    ? 1
                    : n,
                n == 3
                    ? 3
                    : n == 5
                    ? 1
                    : n == 7
                    ? 5
                    : length,
              ),
        ];
        for (var from = 1; from <= 16; from++) {
          for (var until = from + 1; until <= 18; until++) {
            final days = {for (var n = from; n < until; n++) n};
            final expected =
                effective
                    .where(
                      (v) =>
                          {for (var n = v.$2; n < v.$2 + v.$3; n++) n}
                              .intersection(days)
                              .isNotEmpty,
                    )
                    .toList()
                  ..sort(
                    (a, b) => a.$2 == b.$2
                        ? a.$1.compareTo(b.$1)
                        : a.$2.compareTo(b.$2),
                  );
            final actual = query(set, from: d(from), until: d(until));
            expect(
              actual.map((v) => v.originalStart),
              expected.map((v) => d(v.$1)),
            );
            expect(
              actual.map((v) => v.span.start),
              expected.map((v) => d(v.$2)),
            );
            expect(
              actual.map((v) => v.span.dayCount),
              expected.map((v) => v.$3),
            );
          }
        }
      }
    },
  );
  test(
    'equality excludes budgets and includes canonical exceptions/series',
    () {
      final a = apply(base(count: 3), [cancel(3), move(1, 8)]);
      final b = apply(
        base(count: 3),
        [move(1, 8), cancel(3)],
        cap: 4,
        work: 50,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(apply(base(count: 3), [cancel(3), move(1, 9)])));
      expect(a, isNot(apply(base(count: 4), [cancel(3), move(1, 8)])));
      expect(a, isNot(apply(base(count: 3), [cancel(3)])));
      expect(a, isNot(a.series));
    },
  );
}
