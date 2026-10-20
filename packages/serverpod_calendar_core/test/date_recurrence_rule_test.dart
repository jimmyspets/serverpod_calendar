import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  final monday = ByDayValue(weekday: Weekday.monday);
  final firstMonday = ByDayValue(weekday: Weekday.monday, ordinal: 1);
  final lastFriday = ByDayValue(weekday: Weekday.friday, ordinal: -1);
  test('DATE cadence defaults preserve an open rule and Monday week start', () {
    for (final frequency in DateRecurrenceFrequency.values) {
      final rule = DateRecurrenceRule(frequency: frequency);
      expect(rule.frequency, frequency);
      expect(rule.interval, 1);
      expect(rule.count, isNull);
      expect(rule.until, isNull);
      expect(rule.weekStart, Weekday.monday);
      expect(rule.byDay, isEmpty);
    }
  });
  test('every week start maps to the CalendarDate weekday numbering', () {
    for (final day in Weekday.values) {
      expect(day.isoNumber, day.index + 1);
      expect(
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.weekly,
          interval: 2,
          weekStart: day,
          byDay: [monday],
        ).weekStart,
        day,
      );
    }
  });
  for (final value in [-1, 0, DateRecurrenceRule.maxScalar + 1]) {
    test('rejects unsupported interval $value', () {
      expect(
        () => DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.daily,
          interval: value,
        ),
        throwsRangeError,
      );
    });
    test('rejects unsupported count $value', () {
      expect(
        () => DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.daily,
          count: value,
        ),
        throwsRangeError,
      );
    });
  }
  test(
    'positive scalar representation bounds do not imply expansion permission',
    () {
      final rule = DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        interval: DateRecurrenceRule.maxScalar,
        count: DateRecurrenceRule.maxScalar,
      );
      expect(rule.interval, DateRecurrenceRule.maxScalar);
      expect(rule.count, DateRecurrenceRule.maxScalar);
    },
  );
  test('UNTIL retains a date at either selected profile boundary', () {
    for (final date in [
      CalendarDate(year: 1, month: 1, day: 1),
      CalendarDate(year: 9999, month: 12, day: 31),
    ]) {
      expect(
        DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.daily,
          until: date,
        ).until,
        date,
      );
    }
  });
  test('COUNT and UNTIL cannot coexist', () {
    expect(
      () => DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.daily,
        count: 1,
        until: CalendarDate(year: 2026, month: 1, day: 1),
      ),
      throwsArgumentError,
    );
  });
  for (final ordinal in [-54, 0, 54]) {
    test('BYDAY rejects ordinal $ordinal', () {
      expect(
        () => ByDayValue(weekday: Weekday.monday, ordinal: ordinal),
        throwsRangeError,
      );
    });
  }
  test('BYDAY accepts unnumbered and signed ordinal boundaries', () {
    expect(monday.ordinal, isNull);
    expect(ByDayValue(weekday: Weekday.sunday, ordinal: -53).ordinal, -53);
    expect(ByDayValue(weekday: Weekday.sunday, ordinal: 53).ordinal, 53);
  });
  test('BYDAY equality retains weekday and ordinal independently', () {
    final equal = ByDayValue(weekday: Weekday.monday, ordinal: 1);
    expect(firstMonday, equal);
    expect(firstMonday.hashCode, equal.hashCode);
    expect(monday, isNot(firstMonday));
    expect(
      ByDayValue(weekday: Weekday.tuesday, ordinal: 1),
      isNot(firstMonday),
    );
  });

  final filters = <String, (int, DateRecurrenceRule Function(List<int>))>{
    'byMonthDay': (
      31,
      (v) => DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        byMonthDay: v,
      ),
    ),
    'byYearDay': (
      366,
      (v) => DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        byYearDay: v,
      ),
    ),
    'byWeekNo': (
      53,
      (v) => DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        byWeekNo: v,
      ),
    ),
    'bySetPosition': (
      366,
      (v) => DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        byMonth: [1],
        bySetPosition: v,
      ),
    ),
  };
  for (final entry in filters.entries) {
    final (maximum, create) = entry.value;
    for (final invalid in [-maximum - 1, 0, maximum + 1]) {
      test('${entry.key} rejects $invalid', () {
        expect(() => create([invalid]), throwsRangeError);
      });
    }
    test('${entry.key} accepts signed boundaries', () {
      expect(() => create([-maximum, -1, 1, maximum]), returnsNormally);
    });
  }
  for (final month in [-1, 0, 13]) {
    test('BYMONTH rejects $month', () {
      expect(
        () => DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          byMonth: [month],
        ),
        throwsRangeError,
      );
    });
  }
  test('BYMONTH accepts both boundaries and normalizes duplicates/order', () {
    final rule = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.yearly,
      byMonth: [12, 1, 12],
    );
    expect(rule.byMonth, [1, 12]);
  });
  test('all signed lists are sorted and exact duplicates removed', () {
    final rule = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.yearly,
      byMonthDay: [2, -1, 2],
      byYearDay: [3, -2, 3],
      byWeekNo: [4, -3, 4],
      bySetPosition: [5, -4, 5],
    );
    expect(rule.byMonthDay, [-1, 2]);
    expect(rule.byYearDay, [-2, 3]);
    expect(rule.byWeekNo, [-3, 4]);
    expect(rule.bySetPosition, [-4, 5]);
  });
  test(
    'BYDAY canonical order retains distinct unnumbered and numbered selections',
    () {
      final rule = DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.monthly,
        byDay: [lastFriday, firstMonday, monday, firstMonday],
      );
      expect(rule.byDay, [monday, firstMonday, lastFriday]);
    },
  );
  test('rule snapshots all caller lists and exposes no mutable lists', () {
    final numbers = [1, 2];
    final days = [monday];
    final rule = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.yearly,
      byDay: days,
      byMonthDay: numbers,
      byYearDay: numbers,
      byWeekNo: numbers,
      byMonth: numbers,
      bySetPosition: numbers,
    );
    numbers.clear();
    days.clear();
    expect(rule.byDay, [monday]);
    expect(() => rule.byDay.clear(), throwsUnsupportedError);
    for (final values in [
      rule.byMonthDay,
      rule.byYearDay,
      rule.byWeekNo,
      rule.byMonth,
      rule.bySetPosition,
    ]) {
      expect(values, [1, 2]);
      expect(() => values.clear(), throwsUnsupportedError);
    }
  });
  test('weekly rules reject BYMONTHDAY', () {
    expect(
      () => DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.weekly,
        byMonthDay: [1],
      ),
      throwsArgumentError,
    );
  });
  for (final frequency in [
    DateRecurrenceFrequency.daily,
    DateRecurrenceFrequency.weekly,
    DateRecurrenceFrequency.monthly,
  ]) {
    test('$frequency rejects BYYEARDAY and BYWEEKNO', () {
      expect(
        () => DateRecurrenceRule(frequency: frequency, byYearDay: [1]),
        throwsArgumentError,
      );
      expect(
        () => DateRecurrenceRule(frequency: frequency, byWeekNo: [1]),
        throwsArgumentError,
      );
    });
  }
  for (final frequency in [
    DateRecurrenceFrequency.daily,
    DateRecurrenceFrequency.weekly,
  ]) {
    test('$frequency rejects ordinal BYDAY', () {
      expect(
        () => DateRecurrenceRule(frequency: frequency, byDay: [firstMonday]),
        throwsArgumentError,
      );
      expect(
        () => DateRecurrenceRule(frequency: frequency, byDay: [lastFriday]),
        throwsArgumentError,
      );
    });
  }
  test(
    'yearly BYWEEKNO rejects ordinal BYDAY but accepts unnumbered weekdays',
    () {
      expect(
        () => DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          byWeekNo: [1],
          byDay: [firstMonday],
        ),
        throwsArgumentError,
      );
      expect(
        () => DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.yearly,
          byWeekNo: [1],
          byDay: [monday],
        ),
        returnsNormally,
      );
    },
  );
  test('monthly/yearly ordinal BYDAY accepts full legal ordinal grammar', () {
    for (final frequency in [
      DateRecurrenceFrequency.monthly,
      DateRecurrenceFrequency.yearly,
    ]) {
      expect(
        () => DateRecurrenceRule(
          frequency: frequency,
          byDay: [ByDayValue(weekday: Weekday.monday, ordinal: 53)],
          byMonth: [2],
        ),
        returnsNormally,
      );
    }
  });
  test('BYSETPOS requires another BY part; WKST and INTERVAL do not count', () {
    expect(
      () => DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.monthly,
        interval: 2,
        weekStart: Weekday.sunday,
        bySetPosition: [-1],
      ),
      throwsArgumentError,
    );
    expect(
      () => DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.monthly,
        byDay: [monday],
        bySetPosition: [-1],
      ),
      returnsNormally,
    );
  });
  test('structurally legal filters may yield no dates and are not clamped', () {
    final rule = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.yearly,
      byMonth: [2],
      byMonthDay: [30, 31],
      byYearDay: [366],
    );
    expect(rule.byMonthDay, [30, 31]);
    expect(rule.byYearDay, [366]);
  });
  test('canonical equivalent rule values have equal hashes', () {
    final a = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.yearly,
      byMonth: [3, 1, 3],
      byDay: [monday, monday],
    );
    final b = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.yearly,
      byMonth: [1, 3],
      byDay: [ByDayValue(weekday: Weekday.monday)],
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect({a, b}, hasLength(1));
  });
  test('equality distinguishes every rule field', () {
    final base = DateRecurrenceRule(
      frequency: DateRecurrenceFrequency.yearly,
      byMonth: [1],
    );
    final alternatives = [
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.monthly,
        byMonth: [1],
      ),
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        interval: 2,
        byMonth: [1],
      ),
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        count: 1,
        byMonth: [1],
      ),
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        until: CalendarDate(year: 2026, month: 1, day: 1),
        byMonth: [1],
      ),
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        weekStart: Weekday.sunday,
        byMonth: [1],
      ),
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        byDay: [monday],
        byMonth: [1],
      ),
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        byMonthDay: [1],
        byMonth: [1],
      ),
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        byYearDay: [1],
        byMonth: [1],
      ),
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        byWeekNo: [1],
        byMonth: [1],
      ),
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        byMonth: [2],
      ),
      DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.yearly,
        bySetPosition: [1],
        byMonth: [1],
      ),
    ];
    expect(alternatives, everyElement(isNot(base)));
    expect({base, ...alternatives}, hasLength(12));
  });
}
