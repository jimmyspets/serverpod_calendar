import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  final start = CalendarDate(year: 2026, month: 1, day: 1);
  final until = start.addDays(3);
  final series = DateEventSeries(
    span: DateEventSpan(start: start),
    recurrence: DateRecurrenceSet(
      start: start,
      rule: DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.daily,
        count: 3,
      ),
      maxExplicitDates: 0,
    ),
  );
  final singles = DateEventExceptionSet(
    series: series,
    exceptions: [],
    maxExceptions: 0,
    maxValidationCandidateDays: 100,
    maxValidationRuleOccurrences: 100,
    maxValidationResults: 100,
  );
  final ranges = DateEventRangeSet(
    base: singles,
    changes: [],
    maxRangeChanges: 0,
    maxValidationCandidateDays: 100,
    maxValidationRuleOccurrences: 100,
    maxValidationResults: 100,
  );
  for (final kind in ['series', 'singles', 'ranges']) {
    test('$kind expansion enforces the supplied aggregate work ceiling', () {
      List<Object> expand(RecurrenceWorkBudget? budget) => switch (kind) {
        'series' => series.expandOverlapping(
          from: start,
          until: until,
          maxCandidateDays: 100,
          maxRuleOccurrences: 100,
          maxResults: 100,
          sharedWorkBudget: budget,
        ),
        'singles' => singles.expandOverlapping(
          from: start,
          until: until,
          maxCandidateDays: 100,
          maxRuleOccurrences: 100,
          maxBaseOccurrences: 100,
          maxResults: 100,
          sharedWorkBudget: budget,
        ),
        _ => ranges.expandOverlapping(
          from: start,
          until: until,
          maxCandidateDays: 100,
          maxRuleOccurrences: 100,
          maxBaseOccurrences: 100,
          maxResults: 100,
          sharedWorkBudget: budget,
        ),
      };
      expect(expand(null), hasLength(3));
      final work = RecurrenceWorkBudget(maxWork: 1);
      expect(() => expand(work), throwsA(isA<RecurrenceLimitException>()));
      expect(work.remaining, 0);
      expect(() => expand(work), throwsA(isA<RecurrenceLimitException>()));
    });
  }
  test('zone snapshot charges raw transitions outside its output horizon', () {
    final resolver = NamedZoneResolver();
    final horizon = UtcWindow(
      start: DateTime.utc(2026, 1, 1),
      end: DateTime.utc(2026, 1, 2),
    );
    expect(
      resolver
          .snapshot(
            zoneId: 'Europe/Stockholm',
            horizon: horizon,
            maxTransitions: 0,
          )
          .changes,
      isEmpty,
    );
    expect(
      () => resolver.snapshot(
        zoneId: 'Europe/Stockholm',
        horizon: horizon,
        maxTransitions: 0,
        sharedWorkBudget: RecurrenceWorkBudget(maxWork: 1),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
}
