import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  final day = CalendarDate(year: 2026, month: 10, day: 22);
  test('shared work accumulates across date and timed expansions', () {
    final budget = RecurrenceWorkBudget(maxWork: 3);
    DateRecurrenceGenerator().expand(
      start: day,
      rule: DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.daily,
        count: 1,
      ),
      from: day,
      through: day,
      maxCandidateDays: 10,
      maxResults: 1,
      sharedWorkBudget: budget,
    );
    expect(budget.used, 1);
    TimedRecurrenceGenerator().expand(
      start: TimedValue.utc(DateTime.utc(2026, 10, 22, 12)),
      rule: TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        count: 1,
      ),
      window: UtcWindow(
        start: DateTime.utc(2026, 10, 22),
        end: DateTime.utc(2026, 10, 23),
      ),
      maxCandidateWork: 10,
      maxResults: 1,
      sharedWorkBudget: budget,
    );
    expect(budget.used, 3);
    expect(budget.remaining, 0);
    expect(budget.charge, throwsA(isA<RecurrenceLimitException>()));
    expect(budget.used, 3);
  });
  test('failed alignment retains work and local caps still apply', () {
    final budget = RecurrenceWorkBudget(maxWork: 3);
    expect(
      () => DateRecurrenceGenerator().expand(
        start: day,
        rule: DateRecurrenceRule(
          frequency: DateRecurrenceFrequency.daily,
          byMonth: [1],
        ),
        from: day,
        through: day,
        maxCandidateDays: 10,
        maxResults: 1,
        sharedWorkBudget: budget,
      ),
      throwsArgumentError,
    );
    expect(budget.used, 1);
    expect(
      () => DateRecurrenceGenerator().expand(
        start: day,
        rule: DateRecurrenceRule(frequency: DateRecurrenceFrequency.monthly),
        from: day,
        through: day,
        maxCandidateDays: 1,
        maxResults: 1,
        sharedWorkBudget: budget,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(budget.used, 2);
  });
  test(
    'shared work configuration and portable ceiling reject invalid values',
    () {
      expect(() => RecurrenceWorkBudget(maxWork: 0), throwsRangeError);
      expect(() => RecurrenceWorkBudget(maxWork: -1), throwsRangeError);
      expect(
        () => RecurrenceWorkBudget(maxWork: 9007199254740992),
        throwsRangeError,
      );
      final budget = RecurrenceWorkBudget(
        maxWork: DateRecurrenceRule.maxScalar,
      );
      budget.charge();
      expect(budget.remaining, 9007199254740990);
    },
  );
}
