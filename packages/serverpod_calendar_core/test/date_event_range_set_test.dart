import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int day) => CalendarDate(year: 2026, month: 1, day: day);
CalendarDate terminal(int day) => CalendarDate(year: 9999, month: 12, day: day);
void main() {
  DateEventExceptionSet base({
    int count = 10,
    int length = 1,
    CalendarDate? start,
    List<CalendarDate> inclusions = const [],
    List<CalendarDate> exclusions = const [],
    List<DateEventException> singles = const [],
  }) {
    final origin = start ?? d(1);
    final series = DateEventSeries(
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
    return DateEventExceptionSet(
      series: series,
      exceptions: singles,
      maxExceptions: 100,
      maxValidationCandidateDays: 1000,
      maxValidationRuleOccurrences: 100,
      maxValidationResults: 100,
    );
  }

  DateEventRangeChange change(int original, int actual, {int length = 1}) =>
      DateEventRangeChange(
        originalStart: d(original),
        replacement: DateEventSpan(
          start: d(actual),
          duration: CalendarDuration(days: length),
        ),
      );
  DateEventException cancel(int n) =>
      DateEventException.cancel(originalStart: d(n));
  DateEventException single(int original, int actual, {int length = 1}) =>
      DateEventException.replace(
        originalStart: d(original),
        replacement: DateEventSpan(
          start: d(actual),
          duration: CalendarDuration(days: length),
        ),
      );
  DateEventRangeSet apply(
    DateEventExceptionSet base,
    List<DateEventRangeChange> changes, {
    int cap = 100,
    int work = 1000,
    int raw = 100,
    int validated = 100,
  }) => DateEventRangeSet(
    base: base,
    changes: changes,
    maxRangeChanges: cap,
    maxValidationCandidateDays: work,
    maxValidationRuleOccurrences: raw,
    maxValidationResults: validated,
  );
  List<DateEventOccurrence> query(
    DateEventRangeSet value, {
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

  test('empty range list preserves the single-exception engine', () {
    final original = base(
      count: 4,
      length: 3,
      singles: [cancel(2), single(3, 20)],
    );
    final value = apply(original, [], cap: 0);
    expect(
      query(value),
      original.expandOverlapping(
        from: d(1),
        until: d(31),
        maxCandidateDays: 1000,
        maxRuleOccurrences: 100,
        maxBaseOccurrences: 100,
        maxResults: 100,
      ),
    );
  });
  test(
    'positive shift applies at original anchor and subsequent original dates',
    () {
      final values = query(apply(base(count: 5), [change(3, 8, length: 2)]));
      expect(values.map((v) => v.originalStart), [
        d(1),
        d(2),
        d(3),
        d(4),
        d(5),
      ]);
      expect(values.map((v) => v.span.start), [d(1), d(2), d(8), d(9), d(10)]);
      expect(values.map((v) => v.span.dayCount), [1, 1, 2, 2, 2]);
    },
  );
  test(
    'negative shifts can reorder actual dates without changing identity',
    () {
      final values = query(apply(base(count: 5), [change(4, 1)]));
      expect(values.map((v) => v.originalStart), [
        d(1),
        d(4),
        d(2),
        d(5),
        d(3),
      ]);
      expect(values.map((v) => v.span.start), [d(1), d(1), d(2), d(2), d(3)]);
    },
  );
  test(
    'later anchors use absolute original-relative shifts, not accumulation',
    () {
      final values = query(
        apply(base(count: 7), [
          change(3, 8, length: 2),
          change(6, 4, length: 3),
        ]),
      );
      expect(
        values.map(
          (v) => (v.originalStart.day, v.span.start.day, v.span.dayCount),
        ),
        [
          (1, 1, 1),
          (2, 2, 1),
          (6, 4, 3),
          (7, 5, 3),
          (3, 8, 2),
          (4, 9, 2),
          (5, 10, 2),
        ],
      );
    },
  );
  test(
    'range order follows original dates regardless of supplied list order',
    () {
      final values = query(apply(base(count: 7), [change(6, 4), change(3, 8)]));
      expect(values.map((v) => v.originalStart), [
        d(1),
        d(2),
        d(6),
        d(7),
        d(3),
        d(4),
        d(5),
      ]);
    },
  );
  test('separate single replacements and cancellations retain precedence', () {
    final original = base(
      count: 7,
      singles: [single(2, 20), single(4, 1, length: 5), cancel(5)],
    );
    final values = query(apply(original, [change(3, 8)]));
    expect(values.map((v) => v.originalStart), [
      d(1),
      d(4),
      d(3),
      d(6),
      d(7),
      d(2),
    ]);
    expect(values.firstWhere((v) => v.originalStart == d(4)).span.dayCount, 5);
    expect(values.last.span.start, d(20));
  });
  test(
    'single instance moved across anchor is not selected by actual order',
    () {
      final value = apply(
        base(count: 5, singles: [single(1, 20), single(5, 1)]),
        [change(3, 8)],
      );
      expect(
        query(value, from: d(20), until: d(21)).single.originalStart,
        d(1),
      );
      expect(query(value, from: d(1), until: d(2)).single.originalStart, d(5));
    },
  );
  test('lengthening is found beyond the original template lookback', () {
    final value = apply(base(count: 3), [change(2, 2, length: 10)]);
    expect(
      query(value, from: d(10), until: d(11)).map((v) => v.originalStart),
      [d(2), d(3)],
    );
  });
  test('shortening and moved-out spans disappear from old query locations', () {
    final value = apply(base(count: 3, length: 10), [change(2, 20)]);
    expect(query(value, from: d(8), until: d(9)).single.originalStart, d(1));
    expect(query(value, from: d(22), until: d(23)), isEmpty);
  });
  test('half-open touching boundaries exclude shifted spans', () {
    final value = apply(base(count: 2), [change(1, 8, length: 2)]);
    expect(query(value, from: d(7), until: d(8)), isEmpty);
    expect(query(value, from: d(11), until: d(12)), isEmpty);
    expect(query(value, from: d(10), until: d(11)).single.originalStart, d(2));
  });
  test(
    'complete spans are not clipped and equal actual starts remain distinct',
    () {
      final values = query(
        apply(base(count: 4, singles: [single(2, 4, length: 7)]), [
          change(3, 4, length: 5),
        ]),
        from: d(5),
        until: d(6),
      );
      expect(values.map((v) => v.originalStart), [d(2), d(3), d(4)]);
      expect(values.map((v) => v.span.endExclusive), [d(11), d(9), d(10)]);
      expect(values.toSet().length, 3);
    },
  );
  test('range template retains explicit end/duration/default form', () {
    final templates = [
      DateEventSpan(start: d(8)),
      DateEventSpan(start: d(8), end: d(10)),
      DateEventSpan(start: d(8), duration: CalendarDuration(weeks: 1)),
    ];
    for (final template in templates) {
      final value = apply(base(count: 3), [
        DateEventRangeChange(originalStart: d(2), replacement: template),
      ]);
      final spans = query(value, from: d(8)).map((v) => v.span).toList();
      expect(spans.length, 2);
      expect(spans.every((s) => s.dayCount == template.dayCount), isTrue);
      expect(
        spans.every((s) => (s.end == null) == (template.end == null)),
        isTrue,
      );
      expect(spans.every((s) => s.duration == template.duration), isTrue);
    }
  });
  test('original EXDATE remains excluded after a range shift', () {
    final value = apply(base(count: 5, exclusions: [d(4)]), [change(3, 8)]);
    expect(query(value).map((v) => v.originalStart), [d(1), d(2), d(3), d(5)]);
  });
  test(
    'COUNT and UNTIL still constrain original starts, not shifted dates',
    () {
      final origin = d(1);
      final series = DateEventSeries(
        span: DateEventSpan(start: origin),
        recurrence: DateRecurrenceSet(
          start: origin,
          rule: DateRecurrenceRule(
            frequency: DateRecurrenceFrequency.daily,
            until: d(3),
          ),
          maxExplicitDates: 0,
        ),
      );
      final original = DateEventExceptionSet(
        series: series,
        exceptions: [],
        maxExceptions: 0,
        maxValidationCandidateDays: 1000,
        maxValidationRuleOccurrences: 100,
        maxValidationResults: 100,
      );
      expect(query(apply(original, [change(2, 20)])).map((v) => v.span.start), [
        d(1),
        d(20),
        d(21),
      ]);
      expect(
        query(apply(base(count: 3), [change(2, 20)])).map((v) => v.span.start),
        [d(1), d(20), d(21)],
      );
    },
  );
  test('earlier RDATE anchor can shift DTSTART without rebasing the rule', () {
    final value = apply(base(start: d(10), count: 2, inclusions: [d(2)]), [
      change(2, 3),
    ]);
    expect(query(value).map((v) => (v.originalStart.day, v.span.start.day)), [
      (2, 3),
      (10, 11),
      (11, 12),
    ]);
    expect(value.base.series.recurrence.start, d(10));
  });
  test('monthly invalid-date skipping is not rewritten after the shift', () {
    final january = CalendarDate(year: 2026, month: 1, day: 31);
    final series = DateEventSeries(
      span: DateEventSpan(start: january),
      recurrence: DateRecurrenceSet(
        start: january,
        rule: DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.monthly,
          count: 2,
        ),
        maxExplicitDates: 0,
      ),
    );
    final original = DateEventExceptionSet(
      series: series,
      exceptions: [],
      maxExceptions: 0,
      maxValidationCandidateDays: 1000,
      maxValidationRuleOccurrences: 100,
      maxValidationResults: 100,
    );
    final value = apply(original, [
      DateEventRangeChange(
        originalStart: january,
        replacement: DateEventSpan(
          start: CalendarDate(year: 2026, month: 2, day: 1),
        ),
      ),
    ]);
    final values = query(
      value,
      from: january,
      until: CalendarDate(year: 2026, month: 4, day: 2),
    );
    expect(values.map((v) => v.span.start), [
      CalendarDate(year: 2026, month: 2, day: 1),
      CalendarDate(year: 2026, month: 4, day: 1),
    ]);
  });
  test('duplicate and excluded/orphan anchors are rejected', () {
    expect(
      () => apply(base(), [change(3, 8), change(3, 9)]),
      throwsArgumentError,
    );
    expect(() => apply(base(count: 2), [change(3, 8)]), throwsArgumentError);
    expect(
      () => apply(base(count: 4, exclusions: [d(3)]), [change(3, 8)]),
      throwsArgumentError,
    );
    expect(
      () => apply(base(start: d(10), count: 1), [change(3, 8)]),
      throwsArgumentError,
    );
  });
  test('same original anchor cannot have both range and single semantics', () {
    expect(
      () => apply(base(singles: [cancel(3)]), [change(3, 8)]),
      throwsArgumentError,
    );
    expect(
      () => apply(base(singles: [single(3, 8)]), [change(3, 8)]),
      throwsArgumentError,
    );
  });
  test('raw range cap is checked before copying and duplicate handling', () {
    expect(
      () => apply(base(), [change(3, 8), change(3, 8)], cap: 1),
      limit('maxRangeChanges'),
    );
    expect(
      () => apply(base(), [change(3, 8)], cap: 0),
      limit('maxRangeChanges'),
    );
  });
  test(
    'range anchor validation shares one bounded original recurrence scan',
    () {
      final original = base(count: 7);
      final changes = [change(3, 8), change(7, 10)];
      expect(
        () => apply(original, changes, work: 6),
        limit('maxValidationCandidateDays'),
      );
      expect(
        () => apply(original, changes, raw: 4),
        limit('maxValidationRuleOccurrences'),
      );
      expect(
        () => apply(original, changes, validated: 4),
        limit('maxValidationResults'),
      );
      expect(
        apply(original, changes, work: 7, raw: 5, validated: 5).changes.length,
        2,
      );
    },
  );
  test(
    'one envelope counts intervening starts before segment overlap filtering',
    () {
      final value = apply(base(count: 20), [change(5, 1), change(15, 5)]);
      expect(
        () => query(value, from: d(6), until: d(7), raw: 6),
        limit('maxRuleOccurrences'),
      );
      expect(
        () => query(value, from: d(6), until: d(7), baseCap: 6),
        limit('maxBaseOccurrences'),
      );
      expect(
        () => query(value, from: d(6), until: d(7), work: 10),
        limit('maxCandidateDays'),
      );
      final values = query(
        value,
        from: d(6),
        until: d(7),
        raw: 7,
        baseCap: 7,
        results: 2,
      );
      expect(values.map((v) => v.originalStart), [d(10), d(16)]);
      expect(
        () => query(value, from: d(6), until: d(7), results: 1),
        limit('maxResults'),
      );
    },
  );
  test('separate moved-in replacements count toward final result limit', () {
    final value = apply(
      base(count: 4, singles: [single(1, 20), single(4, 20)]),
      [change(2, 8)],
    );
    expect(
      () => query(value, from: d(20), until: d(21), results: 1),
      limit('maxResults'),
    );
    expect(
      query(
        value,
        from: d(20),
        until: d(21),
        results: 2,
      ).map((v) => v.originalStart),
      [d(1), d(4)],
    );
  });
  test('no inverse segment overlap still finds independent replacements', () {
    final value = apply(base(count: 4, singles: [single(1, 8)]), [
      change(2, 20),
    ]);
    expect(query(value, from: d(8), until: d(9)).single.originalStart, d(1));
    expect(query(value, from: d(10), until: d(11)), isEmpty);
  });
  test(
    'all invalid scalar budgets and query bounds reject empty inputs/results',
    () {
      for (final bad in [-1, DateRecurrenceRule.maxScalar + 1]) {
        expect(() => apply(base(), [], cap: bad), throwsRangeError);
      }
      final value = apply(base(count: 1), []);
      for (final bad in [0, -1, DateRecurrenceRule.maxScalar + 1]) {
        expect(() => apply(base(), [], work: bad), throwsRangeError);
        expect(() => apply(base(), [], raw: bad), throwsRangeError);
        expect(() => apply(base(), [], validated: bad), throwsRangeError);
        expect(() => query(value, work: bad), throwsRangeError);
        expect(() => query(value, raw: bad), throwsRangeError);
        expect(() => query(value, baseCap: bad), throwsRangeError);
        expect(() => query(value, results: bad), throwsRangeError);
      }
      expect(() => query(value, from: d(8), until: d(8)), throwsArgumentError);
      expect(() => query(value, from: d(8), until: d(7)), throwsArgumentError);
    },
  );
  test(
    'selected shifted endpoint overflow fails while cancellation can remove it',
    () {
      final original = base(start: terminal(28), count: 3);
      final change = DateEventRangeChange(
        originalStart: terminal(28),
        replacement: DateEventSpan(
          start: terminal(29),
          duration: CalendarDuration(days: 2),
        ),
      );
      expect(
        () => query(
          apply(original, [change]),
          from: terminal(30),
          until: terminal(31),
        ),
        throwsRangeError,
      );
      final cancelled = base(
        start: terminal(28),
        count: 3,
        singles: [DateEventException.cancel(originalStart: terminal(29))],
      );
      expect(
        query(
          apply(cancelled, [change]),
          from: terminal(30),
          until: terminal(31),
        ).single.originalStart,
        terminal(28),
      );
    },
  );
  test('terminal original date can anchor a valid negative shift', () {
    final original = base(
      start: terminal(28),
      count: 1,
      inclusions: [terminal(31)],
    );
    final change = DateEventRangeChange(
      originalStart: terminal(31),
      replacement: DateEventSpan(start: terminal(28)),
    );
    expect(
      query(
        apply(original, [change]),
        from: terminal(28),
        until: terminal(29),
      ).map((v) => v.originalStart),
      [terminal(28), terminal(31)],
    );
  });
  test('first-profile-date anchor has no earlier segment to materialize', () {
    final first = CalendarDate(year: 1, month: 1, day: 1);
    final value = apply(base(start: first, count: 2), [
      DateEventRangeChange(
        originalStart: first,
        replacement: DateEventSpan(
          start: first.addDays(1),
          duration: CalendarDuration(days: 2),
        ),
      ),
    ]);
    final values = query(
      value,
      from: first.addDays(1),
      until: first.addDays(2),
    );
    expect(values.single.originalStart, first);
    expect(values.single.span.endExclusive, first.addDays(3));
  });
  test(
    'huge shifts stay exact and unrelated future overflow is not materialized',
    () {
      final first = CalendarDate(year: 1, month: 1, day: 1);
      final original = base(start: first, count: 2);
      final change = DateEventRangeChange(
        originalStart: first,
        replacement: DateEventSpan(start: terminal(30)),
      );
      final value = apply(original, [change]);
      expect(
        query(
          value,
          from: terminal(30),
          until: terminal(31),
        ).single.originalStart,
        first,
      );
    },
  );
  test('canonical snapshots and results are immutable with budget-independent equality', () {
    final input = [change(6, 4), change(3, 8)];
    final value = apply(base(count: 7), input);
    input.clear();
    expect(value.changes.map((v) => v.originalStart), [d(3), d(6)]);
    expect(() => value.changes.clear(), throwsUnsupportedError);
    expect(() => query(value).clear(), throwsUnsupportedError);
    final same = apply(
      base(count: 7),
      [change(3, 8), change(6, 4)],
      cap: 10,
      work: 100,
    );
    expect(value, same);
    expect(value.hashCode, same.hashCode);
    expect(value, isNot(apply(base(count: 8), [change(3, 8), change(6, 4)])));
    expect(value, isNot(apply(base(count: 7), [change(3, 8)])));
    expect(value, isNot(apply(base(count: 7), [change(3, 9), change(6, 4)])));
    expect(value, isNot(value.base));
  });
  test('finite oracle checks original-order ranges, singles, spans and actual ordering', () {
    for (var length = 1; length <= 3; length++) {
      final value = apply(
        base(
          count: 9,
          length: length,
          singles: [cancel(4), single(5, 18, length: 4)],
        ),
        [change(3, 8, length: 2), change(6, 2, length: 3)],
      );
      final effective = [
        for (var n = 1; n <= 9; n++)
          if (n != 4)
            (
              n,
              n == 5
                  ? 18
                  : n >= 6
                  ? n - 4
                  : n >= 3
                  ? n + 5
                  : n,
              n == 5
                  ? 4
                  : n >= 6
                  ? 3
                  : n >= 3
                  ? 2
                  : length,
            ),
      ];
      for (var from = 1; from <= 20; from++) {
        for (var until = from + 1; until <= 22; until++) {
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
          final actual = query(value, from: d(from), until: d(until));
          expect(
            actual.map((v) => v.originalStart),
            expected.map((v) => d(v.$1)),
          );
          expect(actual.map((v) => v.span.start), expected.map((v) => d(v.$2)));
          expect(actual.map((v) => v.span.dayCount), expected.map((v) => v.$3));
        }
      }
    }
  });
}
