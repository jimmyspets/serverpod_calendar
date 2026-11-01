import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate date(int day) => CalendarDate(year: 2026, month: 1, day: day);
DateEventSpan days(int day) => DateEventSpan(start: date(day));
DateEventExceptionSet dateBase({
  CalendarDate? start,
  int count = 5,
  List<DateEventException> singles = const [],
  List<CalendarDate> inclusions = const [],
  List<CalendarDate> exclusions = const [],
}) => DateEventExceptionSet(
  series: DateEventSeries(
    span: DateEventSpan(start: start ?? date(1)),
    recurrence: DateRecurrenceSet(
      start: start ?? date(1),
      rule: DateRecurrenceRule(
        frequency: DateRecurrenceFrequency.daily,
        count: count,
      ),
      inclusions: inclusions,
      exclusions: exclusions,
      maxExplicitDates: 20,
    ),
  ),
  exceptions: singles,
  maxExceptions: 20,
  maxValidationCandidateDays: 1000,
  maxValidationRuleOccurrences: 100,
  maxValidationResults: 100,
);
DateEventRangeSet dates({
  DateEventExceptionSet? base,
  CalendarDate? cutoff,
  List<DateEventRangeChange> changes = const [],
  int cap = 20,
  int work = 1000,
  int raw = 100,
  int validated = 100,
  RecurrenceWorkBudget? shared,
}) => DateEventRangeSet(
  base: base ?? dateBase(),
  changes: changes,
  cancelledFrom: cutoff,
  maxRangeChanges: cap,
  maxValidationCandidateDays: work,
  maxValidationRuleOccurrences: raw,
  maxValidationResults: validated,
  sharedWorkBudget: shared,
);
List<DateEventOccurrence> dateQuery(
  DateEventRangeSet value, {
  int from = 1,
  int until = 31,
  int work = 1000,
  int raw = 100,
  int base = 100,
  int results = 100,
  RecurrenceWorkBudget? shared,
}) => value.expandOverlapping(
  from: date(from),
  until: date(until),
  maxCandidateDays: work,
  maxRuleOccurrences: raw,
  maxBaseOccurrences: base,
  maxResults: results,
  sharedWorkBudget: shared,
);
TimedValue time(int day, {String? zone, int month = 1, int hour = 9}) =>
    zone == null
    ? TimedValue.utc(DateTime.utc(2026, month, day, hour))
    : TimedValue.zoned(
        CivilDateTime(
          date: CalendarDate(year: 2026, month: month, day: day),
          hour: hour,
          minute: 0,
        ),
        zoneId: zone,
      );
TimedEventSpan hour(TimedValue start) =>
    TimedEventSpan(start: start, duration: CalendarDuration(hours: 1));
TimedEventSeries timed({
  String? zone,
  TimedValue? start,
  TimedValue? cutoff,
  List<TimedEventException> singles = const [],
  List<TimedEventRangeChange> changes = const [],
  List<TimedValue> inclusions = const [],
  List<TimedValue> exclusions = const [],
  List<TimedEventSpan> periods = const [],
  int cap = 20,
  int work = 10000,
  int raw = 100,
  int count = 5,
  RecurrenceWorkBudget? shared,
}) {
  final origin = start ?? time(1, zone: zone);
  return TimedEventSeries(
    span: hour(origin),
    recurrence: TimedRecurrenceSet(
      start: origin,
      rule: TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        count: count,
      ),
      inclusions: inclusions,
      exclusions: exclusions,
      periods: periods,
      maxExplicitDates: 20,
    ),
    exceptions: singles,
    changes: changes,
    cancelledFrom: cutoff,
    maxChanges: cap,
    maxValidationCandidateWork: work,
    maxValidationOccurrences: raw,
    sharedWorkBudget: shared,
  );
}

List<TimedEventOccurrence> timeQuery(
  TimedEventSeries value, {
  DateTime? from,
  DateTime? until,
  int work = 10000,
  int raw = 100,
  int base = 100,
  int results = 100,
  RecurrenceWorkBudget? shared,
}) => value.expandOverlapping(
  window: UtcWindow(
    start: from ?? DateTime.utc(2025, 12, 1),
    end: until ?? DateTime.utc(2026, 2, 1),
  ),
  maxCandidateWork: work,
  maxRuleOccurrences: raw,
  maxBaseOccurrences: base,
  maxResults: results,
  sharedWorkBudget: shared,
);
final limited = isA<RecurrenceLimitException>();

void main() {
  group('DATE future cancellation', () {
    test('inclusive original cutoff retains singles and later ranges', () {
      final singles = [
        DateEventException.replace(
          originalStart: date(2),
          replacement: days(9),
        ),
        DateEventException.replace(
          originalStart: date(4),
          replacement: days(1),
        ),
      ];
      final changes = [
        DateEventRangeChange(originalStart: date(3), replacement: days(6)),
        DateEventRangeChange(originalStart: date(5), replacement: days(10)),
      ];
      final value = dates(
        base: dateBase(singles: singles),
        changes: changes,
        cutoff: date(3),
      );
      // Independently enumerated originals/actual starts: only 1 and 2 survive.
      expect(
        dateQuery(value).map((v) => (v.originalStart.day, v.span.start.day)),
        [(1, 1), (2, 9)],
      );
      expect(value.base.exceptions, singles);
      expect(value.changes, changes);
      expect(
        dateQuery(dates(base: value.base, changes: value.changes))
            .map((v) => (v.originalStart.day, v.span.start.day)),
        [(1, 1), (4, 1), (3, 6), (2, 9), (5, 10)],
      );
      expect(() => value.changes.clear(), throwsUnsupportedError);
      expect(() => dateQuery(value).clear(), throwsUnsupportedError);
    });
    test('moved-in single is suppressed outside original query range', () {
      final value = dates(
        base: dateBase(
          singles: [
            DateEventException.replace(
              originalStart: date(5),
              replacement: days(1),
            ),
          ],
        ),
        cutoff: date(3),
      );
      expect(dateQuery(value, until: 2).map((v) => v.originalStart), [date(1)]);
    });
    test(
      'single cancellation can anchor cutoff and survives reconstruction',
      () {
        final base = dateBase(
          singles: [DateEventException.cancel(originalStart: date(3))],
        );
        expect(dateQuery(dates(base: base, cutoff: date(3))).length, 2);
        expect(dateQuery(dates(base: base)).map((v) => v.originalStart.day), [
          1,
          2,
          4,
          5,
        ]);
      },
    );
    test('earlier RDATE is a valid inclusive cutoff', () {
      final earlier = CalendarDate(year: 2025, month: 12, day: 31);
      expect(
        dateQuery(
          dates(
            base: dateBase(inclusions: [earlier]),
            cutoff: earlier,
          ),
        ),
        isEmpty,
      );
    });
    test('orphan excluded and exclusive-end cutoffs reject', () {
      expect(() => dates(cutoff: date(6)), throwsArgumentError);
      expect(
        () => dates(
          base: dateBase(exclusions: [date(3)]),
          cutoff: date(3),
        ),
        throwsArgumentError,
      );
      expect(
        () => dates(cutoff: const CalendarDate.exclusiveEnd()),
        throwsArgumentError,
      );
    });
    test('same-anchor cancellation costs a separate change slot', () {
      final change = DateEventRangeChange(
        originalStart: date(3),
        replacement: days(4),
      );
      expect(
        () => dates(cutoff: date(3), changes: [change], cap: 1),
        throwsA(limited),
      );
      expect(
        dates(cutoff: date(3), changes: [change], cap: 2).cancelledFrom,
        date(3),
      );
      expect(() => dates(cutoff: date(1), cap: 0), throwsA(limited));
      expect(dates(cap: 0).cancelledFrom, isNull);
      expect(
        () => dates(cutoff: date(3), changes: [change, change]),
        throwsArgumentError,
      );
    });
    test('cutoff participates in value equality and hashing', () {
      final a = dates(cutoff: date(3)), b = dates(cutoff: date(3));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(dates()));
      expect(a, isNot(dates(cutoff: date(4))));
    });
    test('suppressed candidates still consume raw base and work budgets', () {
      final value = dates(cutoff: date(1));
      expect(dateQuery(value, results: 1), isEmpty);
      expect(() => dateQuery(value, base: 1), throwsA(limited));
      expect(() => dateQuery(value, raw: 1), throwsA(limited));
      expect(() => dateQuery(value, work: 1), throwsA(limited));
      expect(() => dateQuery(value, results: 0), throwsRangeError);
      expect(() => dates(cutoff: date(5), work: 1), throwsA(limited));
      final changes = [
        DateEventRangeChange(originalStart: date(5), replacement: days(6)),
      ];
      expect(
        () => dates(cutoff: date(1), changes: changes, raw: 1),
        throwsA(limited),
      );
      expect(
        () => dates(cutoff: date(1), changes: changes, validated: 1),
        throwsA(limited),
      );
    });
    test('shared validation and expansion work is not refunded', () {
      final budget = RecurrenceWorkBudget(maxWork: 1000);
      final value = dates(cutoff: date(1), shared: budget);
      final used = budget.used;
      expect(used, greaterThan(0));
      expect(dateQuery(value, shared: budget), isEmpty);
      expect(budget.used, greaterThan(used));
      final exhausted = RecurrenceWorkBudget(maxWork: 1)..charge();
      expect(() => dates(cutoff: date(1), shared: exhausted), throwsA(limited));
      expect(exhausted.used, 1);
    });
  });

  test('DATE cutoff avoids materializing cancelled horizon overflow', () {
    final first = CalendarDate(year: 2099, month: 12, day: 29);
    final last = first.addDays(1);
    final base = dateBase(start: first, count: 3);
    final changes = [
      DateEventRangeChange(
        originalStart: first,
        replacement: DateEventSpan(
          start: last,
          duration: CalendarDuration(days: 2),
        ),
      ),
    ];
    List<DateEventOccurrence> query(DateEventRangeSet value) =>
        value.expandOverlapping(
          from: first,
          until: const CalendarDate.exclusiveEnd(),
          maxCandidateDays: 100,
          maxRuleOccurrences: 100,
          maxBaseOccurrences: 100,
          maxResults: 100,
        );
    final value = dates(base: base, changes: changes, cutoff: last);
    expect(query(value).map((v) => v.span.start), [last]);
    expect(() => query(dates(base: base, changes: changes)), throwsRangeError);
    expect(
      dates(
        base: dateBase(start: CalendarDate(year: 1970, month: 1, day: 1)),
        cutoff: CalendarDate(year: 1970, month: 1, day: 1),
      ).cancelledFrom,
      CalendarDate(year: 1970, month: 1, day: 1),
    );
  });

  test('finite DATE oracle covers every cutoff and narrow actual window', () {
    final base = dateBase(
      singles: [
        DateEventException.replace(
          originalStart: date(2),
          replacement: days(9),
        ),
        DateEventException.replace(
          originalStart: date(4),
          replacement: days(1),
        ),
      ],
    );
    final changes = [
      DateEventRangeChange(originalStart: date(3), replacement: days(6)),
    ];
    // Independently enumerated original -> actual day; single 4 ignores shift.
    const expected = [(1, 1), (2, 9), (3, 6), (4, 1), (5, 8)];
    for (var cutoff = 1; cutoff <= 5; cutoff++) {
      final value = dates(base: base, changes: changes, cutoff: date(cutoff));
      for (var from = 1; from <= 10; from++) {
        final oracle =
            expected.where((v) => v.$1 < cutoff && v.$2 == from).toList()
              ..sort((a, b) => a.$1.compareTo(b.$1));
        expect(
          dateQuery(
            value,
            from: from,
            until: from + 1,
          ).map((v) => (v.originalStart.day, v.span.start.day)),
          oracle,
        );
      }
    }
  });

  test('named-zone cutoff compares civil identity even for equal instants', () {
    const zone = 'Europe/Stockholm';
    final gap = time(29, month: 3, hour: 2, zone: zone);
    final afterGap = time(29, month: 3, hour: 3, zone: zone);
    expect(gap.instant, afterGap.instant);
    final value = timed(start: gap, inclusions: [afterGap], cutoff: afterGap);
    expect(
      timeQuery(
        value,
        from: DateTime.utc(2026, 3, 28),
        until: DateTime.utc(2026, 4, 5),
      ).map((v) => v.originalStart),
      [gap],
    );
  });

  for (final (month, startDay, beforeUtcHour, afterUtcHour) in [
    (3, 28, 8, 7),
    (10, 24, 7, 8),
  ]) {
    test(
      'named-zone cutoff preserves active DST projection in month $month',
      () {
        const zone = 'Europe/Stockholm';
        final start = time(startDay, month: month, zone: zone);
        final cutoff = time(startDay + 2, month: month, zone: zone);
        final value = timed(start: start, cutoff: cutoff);
        final result = timeQuery(
          value,
          from: DateTime.utc(2026, month, startDay),
          until: DateTime.utc(2026, month + 1, 1),
        );
        expect(result.map((v) => v.span.start), [
          DateTime.utc(2026, month, startDay, beforeUtcHour),
          DateTime.utc(2026, month, startDay + 1, afterUtcHour),
        ]);
      },
    );
  }

  for (final zone in <String?>[null, 'Europe/Stockholm']) {
    group('${zone ?? 'UTC'} future cancellation', () {
      TimedValue t(int day) => time(day, zone: zone);
      test(
        'finite oracle covers cutoffs against narrow actual UTC windows',
        () {
          final singles = [
            TimedEventException.replace(t(2), hour(t(9))),
            TimedEventException.replace(t(4), hour(t(1))),
          ];
          final changes = [
            TimedEventRangeChange(originalStart: t(3), replacement: hour(t(6))),
          ];
          const expected = [(1, 1), (2, 9), (3, 6), (4, 1), (5, 8)];
          for (var cutoff = 1; cutoff <= 5; cutoff++) {
            final value = timed(
              zone: zone,
              singles: singles,
              changes: changes,
              cutoff: t(cutoff),
            );
            for (var from = 1; from <= 10; from++) {
              final oracle =
                  expected.where((v) => v.$1 < cutoff && v.$2 == from).toList()
                    ..sort((a, b) => a.$1.compareTo(b.$1));
              expect(
                timeQuery(
                  value,
                  from: t(from).instant,
                  until: t(from + 1).instant,
                ).map(
                  (v) => (
                    v.originalStart.civil.date.day,
                    v.actualStart.civil.date.day,
                  ),
                ),
                oracle,
              );
            }
          }
        },
      );
      test('cancelled horizon overflow is not materialized', () {
        TimedValue at(CalendarDate day) => zone == null
            ? TimedValue.utc(DateTime.utc(day.year, day.month, day.day, 9))
            : TimedValue.zoned(
                CivilDateTime(date: day, hour: 9, minute: 0),
                zoneId: zone,
              );
        final first = at(CalendarDate(year: 2099, month: 12, day: 30));
        final last = at(CalendarDate(year: 2099, month: 12, day: 31));
        final changes = [
          TimedEventRangeChange(originalStart: first, replacement: hour(last)),
        ];
        final value = timed(
          start: first,
          count: 2,
          changes: changes,
          cutoff: last,
        );
        List<TimedEventOccurrence> query(TimedEventSeries v) => timeQuery(
          v,
          from: DateTime.utc(2099, 12, 29),
          until: DateTime.utc(2100),
        );
        expect(query(value).map((v) => v.actualStart), [last]);
        expect(
          () => query(timed(start: first, count: 2, changes: changes)),
          throwsArgumentError,
        );
        final lower = at(CalendarDate(year: 1970, month: 1, day: 1));
        expect(
          timeQuery(
            timed(start: lower, cutoff: lower),
            from: DateTime.utc(1969, 12, 31),
            until: DateTime.utc(1970, 1, 8),
          ),
          isEmpty,
        );
      });
      test('original order suppresses singles and later timing ranges', () {
        final singles = [
          TimedEventException.replace(t(2), hour(t(9))),
          TimedEventException.replace(t(4), hour(t(1))),
        ];
        final changes = [
          TimedEventRangeChange(originalStart: t(3), replacement: hour(t(6))),
          TimedEventRangeChange(originalStart: t(5), replacement: hour(t(10))),
        ];
        final value = timed(
          zone: zone,
          cutoff: t(3),
          singles: singles,
          changes: changes,
        );
        expect(
          timeQuery(value).map(
            (v) =>
                (v.originalStart.civil.date.day, v.actualStart.civil.date.day),
          ),
          [(1, 1), (2, 9)],
        );
        expect(value.exceptions.values, singles);
        expect(value.changes, changes);
        final restored = timed(
          zone: zone,
          singles: value.exceptions.values.toList(),
          changes: value.changes,
        );
        expect(
          timeQuery(restored).map(
            (v) =>
                (v.originalStart.civil.date.day, v.actualStart.civil.date.day),
          ),
          [(1, 1), (4, 1), (3, 6), (2, 9), (5, 10)],
        );
        expect(() => value.exceptions.clear(), throwsUnsupportedError);
        expect(() => value.changes.clear(), throwsUnsupportedError);
        expect(() => timeQuery(value).clear(), throwsUnsupportedError);
      });
      test('moved-in single is suppressed without original query overlap', () {
        final value = timed(
          zone: zone,
          cutoff: t(3),
          singles: [TimedEventException.replace(t(5), hour(t(1)))],
        );
        expect(
          timeQuery(
            value,
            from: t(1).instant,
            until: t(2).instant,
          ).map((v) => v.originalStart),
          [t(1)],
        );
      });
      test('single-cancelled anchor remains valid and is retained', () {
        final singles = [TimedEventException.cancel(t(3))];
        expect(
          timeQuery(timed(zone: zone, singles: singles, cutoff: t(3))).length,
          2,
        );
        expect(
          timeQuery(timed(zone: zone, singles: singles))
              .map((v) => v.originalStart),
          [t(1), t(2), t(4), t(5)],
        );
      });
      test('earlier RDATE and PERIOD can each anchor a cutoff', () {
        final earlier = t(1).at(
          CivilDateTime(
            date: CalendarDate(year: 2025, month: 12, day: 31),
            hour: 9,
            minute: 0,
          ),
        );
        expect(
          timeQuery(timed(zone: zone, inclusions: [earlier], cutoff: earlier)),
          isEmpty,
        );
        final period = hour(t(8));
        final value = timed(zone: zone, periods: [period], cutoff: t(8));
        expect(timeQuery(value).map((v) => v.originalStart), [
          t(1),
          t(2),
          t(3),
          t(4),
          t(5),
        ]);
        expect(value.recurrence.periods[t(8)], period);
      });
      test('orphan excluded foreign-profile and endpoint cutoff reject', () {
        expect(() => timed(zone: zone, cutoff: t(6)), throwsArgumentError);
        expect(
          () => timed(zone: zone, exclusions: [t(3)], cutoff: t(3)),
          throwsArgumentError,
        );
        expect(
          () => timed(
            zone: zone,
            cutoff: time(3, zone: zone == null ? 'Europe/Stockholm' : null),
          ),
          throwsArgumentError,
        );
        expect(
          () =>
              timed(zone: zone, cutoff: TimedValue.utcEnd(DateTime.utc(2100))),
          throwsArgumentError,
        );
      });
      test(
        'same-anchor cutoff costs capacity and does not permit collisions',
        () {
          final change = TimedEventRangeChange(
            originalStart: t(3),
            replacement: hour(t(4)),
          );
          expect(
            () => timed(zone: zone, cutoff: t(3), changes: [change], cap: 1),
            throwsA(limited),
          );
          expect(
            timed(
              zone: zone,
              cutoff: t(3),
              changes: [change],
              cap: 2,
            ).cancelledFrom,
            t(3),
          );
          expect(
            () => timed(zone: zone, cutoff: t(1), cap: 0),
            throwsA(limited),
          );
          expect(
            () => timed(zone: zone, cutoff: t(1), changes: [change, change]),
            throwsArgumentError,
          );
          expect(
            () => timed(
              zone: zone,
              cutoff: t(3),
              changes: [change],
              singles: [TimedEventException.cancel(t(3))],
            ),
            throwsArgumentError,
          );
        },
      );
      test(
        'suppression cannot bypass candidate raw base or invalid budgets',
        () {
          final value = timed(zone: zone, cutoff: t(1));
          expect(timeQuery(value, results: 1), isEmpty);
          expect(() => timeQuery(value, work: 1), throwsA(limited));
          expect(() => timeQuery(value, raw: 1), throwsA(limited));
          expect(() => timeQuery(value, base: 1), throwsA(limited));
          expect(() => timeQuery(value, results: 0), throwsRangeError);
          expect(
            () => timed(zone: zone, cutoff: t(5), work: 1),
            throwsA(limited),
          );
          expect(
            () => timed(
              zone: zone,
              cutoff: t(1),
              changes: [
                TimedEventRangeChange(
                  originalStart: t(5),
                  replacement: hour(t(6)),
                ),
              ],
              raw: 1,
            ),
            throwsA(limited),
          );
        },
      );
      test('shared work consumed by validation and suppressed expansion', () {
        final budget = RecurrenceWorkBudget(maxWork: 10000);
        final value = timed(zone: zone, cutoff: t(1), shared: budget);
        final used = budget.used;
        expect(used, greaterThan(0));
        expect(timeQuery(value, shared: budget), isEmpty);
        expect(budget.used, greaterThan(used));
        final exhausted = RecurrenceWorkBudget(maxWork: 1)..charge();
        expect(
          () => timed(zone: zone, cutoff: t(1), shared: exhausted),
          throwsA(limited),
        );
        expect(exhausted.used, 1);
      });
    });
  }
}
