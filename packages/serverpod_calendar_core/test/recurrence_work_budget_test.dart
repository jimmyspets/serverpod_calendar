import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  final day = CalendarDate(year: 2026, month: 10, day: 22);
  test(
    'timed overlap queries share aggregate candidate work without refund',
    () {
      final start = TimedValue.utc(DateTime.utc(2026, 10, 22, 12));
      final series = TimedEventSeries(
        recurrence: TimedRecurrenceSet(
          start: start,
          rule: TimedRecurrenceRule(
            frequency: TimedRecurrenceFrequency.daily,
            count: 2,
          ),
          maxExplicitDates: 0,
        ),
        span: TimedEventSpan(
          start: start,
          duration: CalendarDuration(hours: 1),
        ),
        maxChanges: 0,
        maxValidationCandidateWork: 20,
        maxValidationOccurrences: 10,
      );
      final budget = RecurrenceWorkBudget(maxWork: 7);
      List<TimedEventOccurrence> query() => series.expandOverlapping(
        window: UtcWindow(
          start: DateTime.utc(2026, 10, 22),
          end: DateTime.utc(2026, 10, 24),
        ),
        maxCandidateWork: 20,
        maxRuleOccurrences: 10,
        maxBaseOccurrences: 10,
        maxResults: 10,
        sharedWorkBudget: budget,
      );
      expect(query().length, 2);
      expect(budget.used, 4);
      expect(query, throwsA(isA<RecurrenceLimitException>()));
      expect(budget.used, 7);
    },
  );
  test(
    'DATE single/range membership shares retained work across validations',
    () {
      final budget = RecurrenceWorkBudget(maxWork: 4);
      final series = DateEventSeries(
        recurrence: DateRecurrenceSet(
          start: day,
          rule: DateRecurrenceRule(frequency: DateRecurrenceFrequency.daily),
          maxExplicitDates: 0,
        ),
        span: DateEventSpan(start: day),
      );
      final singles = DateEventExceptionSet(
        series: series,
        exceptions: [DateEventException.cancel(originalStart: day.addDays(1))],
        maxExceptions: 1,
        maxValidationCandidateDays: 20,
        maxValidationRuleOccurrences: 10,
        maxValidationResults: 10,
        sharedWorkBudget: budget,
      );
      expect(budget.used, 2);
      expect(
        () => DateEventRangeSet(
          base: singles,
          changes: [
            DateEventRangeChange(
              originalStart: day.addDays(2),
              replacement: DateEventSpan(start: day.addDays(3)),
            ),
          ],
          maxRangeChanges: 1,
          maxValidationCandidateDays: 20,
          maxValidationRuleOccurrences: 10,
          maxValidationResults: 10,
          sharedWorkBudget: budget,
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
      expect(budget.used, 4);
    },
  );
  test('timed membership shares a budget across independent series', () {
    final budget = RecurrenceWorkBudget(maxWork: 7);
    final start = TimedValue.utc(DateTime.utc(2026, 10, 22, 12));
    final recurrence = TimedRecurrenceSet(
      start: start,
      rule: TimedRecurrenceRule(frequency: TimedRecurrenceFrequency.daily),
      maxExplicitDates: 0,
    );
    TimedEventSeries build() => TimedEventSeries(
      recurrence: recurrence,
      span: TimedEventSpan(start: start),
      exceptions: [
        TimedEventException.cancel(
          TimedValue.utc(DateTime.utc(2026, 10, 23, 12)),
        ),
      ],
      maxChanges: 1,
      maxValidationCandidateWork: 20,
      maxValidationOccurrences: 10,
      sharedWorkBudget: budget,
    );
    expect(build().exceptions.length, 1);
    expect(budget.used, 4);
    expect(build, throwsA(isA<RecurrenceLimitException>()));
    expect(budget.used, 7);
  });
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
