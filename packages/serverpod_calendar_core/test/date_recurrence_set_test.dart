import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int day) => CalendarDate(year: 2026, month: 1, day: day);
void main() {
  DateRecurrenceSet set({
    CalendarDate? start,
    DateRecurrenceRule? rule,
    List<CalendarDate> inclusions = const [],
    List<CalendarDate> exclusions = const [],
    int input = 100,
  }) => DateRecurrenceSet(
    start: start ?? d(1),
    rule: rule,
    inclusions: inclusions,
    exclusions: exclusions,
    maxExplicitDates: input,
  );
  List<CalendarDate> expand(
    DateRecurrenceSet value, {
    CalendarDate? from,
    CalendarDate? through,
    int work = 1000,
    int raw = 100,
    int results = 100,
  }) => value.expand(
    from: from ?? d(1),
    through: through ?? d(31),
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

  test('no rule includes DTSTART once with no explicit input budget', () {
    final value = set(input: 0);
    expect(expand(value), [d(1)]);
    expect(expand(value, from: d(2)), isEmpty);
    expect(expand(value, through: d(1), results: 1), [d(1)]);
  });
  test('canonical explicit dates are immutable snapshots', () {
    final included = [d(5), d(2), d(5)];
    final excluded = [d(3), d(3), d(1)];
    final value = set(inclusions: included, exclusions: excluded, input: 6);
    included.clear();
    excluded.clear();
    expect(value.inclusions, [d(2), d(5)]);
    expect(value.exclusions, [d(1), d(3)]);
    expect(() => value.inclusions.clear(), throwsUnsupportedError);
    expect(() => value.exclusions.clear(), throwsUnsupportedError);
  });
  test('raw duplicate explicit dates consume the shared input budget', () {
    expect(
      () => set(inclusions: [d(2), d(2)], input: 1),
      limit('maxExplicitDates'),
    );
    expect(
      () => set(inclusions: [d(2)], exclusions: [d(2)], input: 1),
      limit('maxExplicitDates'),
    );
    expect(() => set(exclusions: [d(2)], input: 0), limit('maxExplicitDates'));
  });
  for (final input in [-1, DateRecurrenceRule.maxScalar + 1]) {
    test('rejects unsupported explicit input budget $input', () {
      expect(() => set(input: input), throwsRangeError);
    });
  }
  test('earlier inclusions are preserved without changing DTSTART', () {
    final value = set(start: d(10), rule: daily(2), inclusions: [d(2), d(20)]);
    expect(expand(value), [d(2), d(10), d(11), d(20)]);
    expect(value.start, d(10));
    expect(value.rule!.count, 2);
  });
  test('union deduplicates DTSTART, rule occurrences and inclusions', () {
    expect(expand(set(rule: daily(3), inclusions: [d(1), d(3), d(7), d(7)])), [
      d(1),
      d(2),
      d(3),
      d(7),
    ]);
  });
  test('exclusions win over both rule output and explicit inclusions', () {
    expect(
      expand(
        set(rule: daily(3), inclusions: [d(2), d(7)], exclusions: [d(2), d(7)]),
      ),
      [d(1), d(3)],
    );
  });
  test('excluded DTSTART stays stored and is not replaced', () {
    final value = set(rule: daily(2), inclusions: [d(1)], exclusions: [d(1)]);
    expect(expand(value), [d(2)]);
    expect(value.start, d(1));
    expect(expand(set(exclusions: [d(1)])), isEmpty);
  });
  test('EXDATE does not replenish COUNT', () {
    expect(expand(set(rule: daily(3), exclusions: [d(1), d(2)])), [d(3)]);
  });
  test('COUNT history is evaluated before query and exclusions', () {
    expect(
      expand(
        set(rule: daily(3), exclusions: [d(2)]),
        from: d(3),
      ),
      [d(3)],
    );
    expect(expand(set(rule: daily(3)), from: d(4)), isEmpty);
  });
  test('RDATE extends beyond rule UNTIL without moving that bound', () {
    final rule = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.daily,
      until: d(2),
    );
    final value = set(rule: rule, inclusions: [d(5)]);
    expect(expand(value), [d(1), d(2), d(5)]);
    expect(value.rule!.until, d(2));
  });
  test('query bounds apply to all sources including earlier RDATE', () {
    expect(
      expand(
        set(start: d(10), inclusions: [d(1), d(5), d(20)]),
        from: d(5),
        through: d(10),
      ),
      [d(5), d(10)],
    );
    expect(
      expand(
        set(start: d(10), inclusions: [d(1), d(20)]),
        from: d(20),
        through: d(20),
      ),
      [d(20)],
    );
  });
  test('off-rule RDATE dates do not need to match rule filters', () {
    final rule = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.weekly,
      count: 2,
      byDay: [ByDayValue(weekday: Weekday.thursday)],
    );
    expect(expand(set(rule: rule, inclusions: [d(2)])), [d(1), d(2), d(8)]);
  });
  test('excluded mismatched DTSTART still fails rule validation', () {
    final value = set(
      rule: DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.daily,
        byMonth: [2],
      ),
      inclusions: [d(2)],
      exclusions: [d(1)],
    );
    expect(() => expand(value), throwsArgumentError);
  });
  test('raw rule limit cannot be bypassed by excluding most occurrences', () {
    final value = set(rule: daily(4), exclusions: [d(1), d(2), d(3)]);
    expect(
      () => expand(value, raw: 2, results: 1),
      limit('maxRuleOccurrences'),
    );
    expect(expand(value, raw: 4, results: 1), [d(4)]);
  });
  test(
    'work exhaustion is preserved even when every output would be excluded',
    () {
      expect(
        () => expand(
          set(rule: daily(3), exclusions: [d(1), d(2), d(3)]),
          work: 2,
        ),
        limit('maxCandidateDays'),
      );
    },
  );
  test('final result budget applies after union and subtraction', () {
    final value = set(
      rule: daily(3),
      inclusions: [d(1), d(7)],
      exclusions: [d(2), d(3)],
    );
    expect(expand(value, raw: 3, results: 2), [d(1), d(7)]);
    expect(() => expand(value, raw: 3, results: 1), limit('maxResults'));
  });
  test('inclusion-only results have the same final cap', () {
    expect(
      () => expand(set(inclusions: [d(2), d(3)]), results: 2),
      limit('maxResults'),
    );
    expect(
      expand(
        set(inclusions: [d(2), d(3)], exclusions: [d(1), d(2)]),
        results: 1,
      ),
      [d(3)],
    );
  });
  test('raw rule cap counts in-query output rather than pre-query history', () {
    expect(
      expand(
        set(rule: daily(31)),
        from: d(31),
        through: d(31),
        work: 31,
        raw: 1,
        results: 1,
      ),
      [d(31)],
    );
  });
  test('explicit non-Monday WKST is preserved by set evaluation', () {
    final start = CalendarDate(year: 2021, month: 1, day: 3);
    final value = set(
      start: start,
      rule: DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        weekStart: Weekday.sunday,
        byWeekNo: [1],
        count: 1,
      ),
      inclusions: [start],
      exclusions: [start],
    );
    expect(expand(value, from: start, through: start), isEmpty);
    expect(value.rule!.weekStart, Weekday.sunday);
  });
  test('date-profile edges remain distinct date-only values', () {
    final first = CalendarDate(year: 1970, month: 1, day: 1);
    final last = CalendarDate(year: 2099, month: 12, day: 31);
    final value = set(start: first, inclusions: [last]);
    expect(expand(value, from: first, through: last), [first, last]);
  });
  test('output is immutable after successful complete evaluation', () {
    final values = expand(set(inclusions: [d(2)]));
    expect(() => values.add(d(3)), throwsUnsupportedError);
  });
  test(
    'equal canonical sets retain hashes independently of construction budget',
    () {
      final a = set(
        rule: daily(2),
        inclusions: [d(3), d(2), d(3)],
        exclusions: [d(1)],
        input: 4,
      );
      final b = set(
        rule: daily(2),
        inclusions: [d(2), d(3)],
        exclusions: [d(1)],
        input: 10,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect({a, b}, hasLength(1));
    },
  );
  test('equality includes start, rule, inclusions and exclusions', () {
    final value = set(rule: daily(2), inclusions: [d(3)], exclusions: [d(1)]);
    final different = [
      set(start: d(2), rule: daily(2), inclusions: [d(3)], exclusions: [d(1)]),
      set(rule: daily(3), inclusions: [d(3)], exclusions: [d(1)]),
      set(rule: daily(2), inclusions: [d(4)], exclusions: [d(1)]),
      set(rule: daily(2), inclusions: [d(3)], exclusions: [d(2)]),
    ];
    expect(different, everyElement(isNot(value)));
    expect({value, ...different}, hasLength(5));
  });
  test('invalid query and budgets fail even without a rule', () {
    expect(() => expand(set(), from: d(5), through: d(4)), throwsArgumentError);
    expect(() => expand(set(), work: 0), throwsRangeError);
    expect(() => expand(set(), raw: 0), throwsRangeError);
    expect(() => expand(set(), results: 0), throwsRangeError);
    expect(
      () => expand(set(), raw: DateRecurrenceRule.maxScalar + 1),
      throwsRangeError,
    );
  });
}
