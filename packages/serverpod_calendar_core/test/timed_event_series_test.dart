import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

TimedValue u(int day, [int hour = 9]) =>
    TimedValue.utc(DateTime.utc(2026, 1, day, hour));
TimedValue z(int month, int day, int hour, [int minute = 0]) =>
    TimedValue.zoned(
      CivilDateTime(
        date: CalendarDate(year: 2026, month: month, day: day),
        hour: hour,
        minute: minute,
      ),
      zoneId: 'Europe/Stockholm',
    );
TimedEventSpan span(TimedValue s, [int hours = 1]) => TimedEventSpan(
  start: s,
  duration: CalendarDuration(hours: hours),
);
TimedRecurrenceSet set({
  TimedValue? start,
  int count = 5,
  List<TimedValue> inclusions = const [],
  List<TimedValue> exclusions = const [],
  List<TimedEventSpan> periods = const [],
}) => TimedRecurrenceSet(
  start: start ?? u(1),
  rule: TimedRecurrenceRule(
    frequency: TimedRecurrenceFrequency.daily,
    count: count,
  ),
  inclusions: inclusions,
  exclusions: exclusions,
  periods: periods,
  maxExplicitDates: 100,
);
TimedEventSeries series({
  TimedRecurrenceSet? recurrence,
  TimedEventSpan? master,
  List<TimedEventException> exceptions = const [],
  List<TimedEventRangeChange> changes = const [],
}) => TimedEventSeries(
  recurrence: recurrence ?? set(),
  span: master ?? span(u(1)),
  exceptions: exceptions,
  changes: changes,
  maxChanges: 100,
  maxValidationCandidateWork: 100000,
  maxValidationOccurrences: 1000,
);
List<TimedEventOccurrence> query(
  TimedEventSeries s,
  int from,
  int until, {
  int work = 100000,
  int raw = 1000,
  int base = 1000,
  int results = 1000,
}) => s.expandOverlapping(
  window: UtcWindow(start: u(from, 0).instant, end: u(until, 0).instant),
  maxCandidateWork: work,
  maxRuleOccurrences: raw,
  maxBaseOccurrences: base,
  maxResults: results,
);
void main() {
  test(
    'zoned duration differs from explicit exact-end propagation across DST',
    () {
      final start = z(3, 28, 9);
      final nominal = TimedEventSpan(
        start: start,
        duration: CalendarDuration(days: 1),
      );
      final exact = TimedEventSpan(start: start, end: z(3, 29, 9));
      expect(
        nominal.elapsedMicroseconds,
        BigInt.from(23) * BigInt.from(3600000000),
      );
      expect(exact.elapsedMicroseconds, nominal.elapsedMicroseconds);
      final next = z(3, 29, 9);
      expect(
        nominal.projectAt(next).endExclusive,
        DateTime.utc(2026, 3, 30, 7),
      );
      expect(exact.projectAt(next).endExclusive, DateTime.utc(2026, 3, 30, 6));
    },
  );
  test('span strict validation, points and fold endpoints', () {
    expect(TimedEventSpan(start: u(1)).isPoint, isTrue);
    expect(() => TimedEventSpan(start: u(1), end: u(1)), throwsArgumentError);
    expect(
      () => TimedEventSpan(start: u(1), duration: CalendarDuration()),
      throwsArgumentError,
    );
    expect(
      () => TimedEventSpan(
        start: u(1),
        duration: CalendarDuration(sign: -1, hours: 1),
      ),
      throwsArgumentError,
    );
    expect(
      () => TimedEventSpan(
        start: u(1),
        end: u(2),
        duration: CalendarDuration(days: 1),
      ),
      throwsArgumentError,
    );
    expect(
      () => TimedEventSpan(start: u(1), end: z(1, 2, 9)),
      throwsArgumentError,
    );
    final fold = TimedEventSpan(
      start: z(10, 25, 2, 30),
      duration: CalendarDuration(hours: 1),
    );
    expect(fold.endExclusive, DateTime.utc(2026, 10, 25, 1, 30));
    expect(fold.projectAt(fold.start).endExclusive, fold.endExclusive);
    expect(span(u(1)), span(u(1)));
    expect(span(u(1)).hashCode, span(u(1)).hashCode);
  });
  test(
    'earlier additions, exclusions and period precedence preserve COUNT',
    () {
      final earlier = TimedValue.utc(DateTime.utc(2025, 12, 31, 9));
      final r = set(
        count: 2,
        inclusions: [earlier, u(2), u(3)],
        exclusions: [u(1), u(3)],
        periods: [span(u(2), 5)],
      );
      final values = r.expand(
        window: UtcWindow(start: earlier.instant, end: u(4).instant),
        maxCandidateWork: 100,
        maxRuleOccurrences: 10,
        maxResults: 10,
      );
      expect(values, [earlier, u(2)]);
      final found = query(series(recurrence: r), 1, 4);
      expect(found.map((v) => v.originalStart), [u(2)]);
      expect(found.single.span.endExclusive, u(2, 14).instant);
    },
  );
  test('raw input cap, conflicting periods and mixed profiles rejected', () {
    expect(
      () => TimedRecurrenceSet(
        start: u(1),
        inclusions: [u(2), u(2)],
        maxExplicitDates: 1,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(() => set(inclusions: [z(1, 2, 9)]), throwsArgumentError);
    expect(
      () => set(periods: [span(u(2)), span(u(2), 2)]),
      throwsArgumentError,
    );
    expect(
      () => set(periods: [TimedEventSpan(start: u(2))]),
      throwsArgumentError,
    );
    final r = set(inclusions: [u(2), u(2)]);
    expect(r.inclusions, [u(2)]);
    expect(() => r.inclusions.add(u(3)), throwsUnsupportedError);
  });
  test(
    'overlap includes long spans starting before query, with point boundaries',
    () {
      final values = query(
        series(
          master: TimedEventSpan(
            start: u(1),
            duration: CalendarDuration(days: 3),
          ),
        ),
        4,
        5,
      );
      expect(values.map((v) => v.originalStart), [u(1), u(2), u(3), u(4)]);
      final point = series(master: TimedEventSpan(start: u(1)));
      expect(query(point, 2, 3).map((v) => v.originalStart), [u(2)]);
    },
  );
  test('moved-in/out and cancellation retain identities and tie ordering', () {
    final s = series(
      exceptions: [
        TimedEventException.cancel(u(2)),
        TimedEventException.replace(u(3), span(u(10))),
        TimedEventException.replace(u(5), span(u(1))),
      ],
    );
    expect(query(s, 1, 3).map((v) => v.originalStart), [u(1), u(5)]);
    expect(query(s, 10, 11).single.originalStart, u(3));
  });
  test('orphan, excluded, duplicate and collision anchors reject', () {
    expect(
      () => series(exceptions: [TimedEventException.cancel(u(6))]),
      throwsArgumentError,
    );
    expect(
      () => series(
        recurrence: set(exclusions: [u(2)]),
        exceptions: [TimedEventException.cancel(u(2))],
      ),
      throwsArgumentError,
    );
    expect(
      () => series(
        exceptions: [
          TimedEventException.cancel(u(2)),
          TimedEventException.cancel(u(2)),
        ],
      ),
      throwsArgumentError,
    );
    expect(
      () => series(
        exceptions: [TimedEventException.cancel(u(2))],
        changes: [
          TimedEventRangeChange(originalStart: u(2), replacement: span(u(3))),
        ],
      ),
      throwsArgumentError,
    );
  });
  test('ranges use original ordering and absolute shifts; singles win', () {
    final s = series(
      changes: [
        TimedEventRangeChange(originalStart: u(2), replacement: span(u(5), 2)),
        TimedEventRangeChange(originalStart: u(4), replacement: span(u(2), 3)),
      ],
      exceptions: [TimedEventException.replace(u(3), span(u(1)))],
    );
    final found = query(s, 1, 8);
    expect(
      found.map(
        (v) => (
          v.originalStart.civil.date.day,
          v.span.start.day,
          v.span.elapsedMicroseconds,
        ),
      ),
      [
        (1, 1, BigInt.from(3600000000)),
        (3, 1, BigInt.from(3600000000)),
        (4, 2, BigInt.from(10800000000)),
        (5, 3, BigInt.from(10800000000)),
        (2, 5, BigInt.from(7200000000)),
      ],
    );
  });
  test('inverse range bound finds original future starts moved backwards', () {
    final s = series(
      recurrence: set(count: 20),
      changes: [
        TimedEventRangeChange(originalStart: u(10), replacement: span(u(2))),
      ],
    );
    expect(query(s, 2, 3).map((v) => v.originalStart), [u(2), u(10)]);
  });
  test('shared query and validation caps fail without partial output', () {
    final s = series();
    for (final action in <void Function()>[
      () => query(s, 1, 7, work: 1),
      () => query(s, 1, 7, raw: 2),
      () => query(s, 1, 7, base: 2),
      () => query(s, 1, 7, results: 2),
      () => TimedEventSeries(
        recurrence: set(),
        span: span(u(1)),
        exceptions: [TimedEventException.cancel(u(5))],
        maxChanges: 1,
        maxValidationCandidateWork: 1,
        maxValidationOccurrences: 10,
      ),
      () => TimedEventSeries(
        recurrence: set(),
        span: span(u(1)),
        exceptions: [TimedEventException.cancel(u(5))],
        maxChanges: 0,
        maxValidationCandidateWork: 100,
        maxValidationOccurrences: 10,
      ),
    ]) {
      expect(action, throwsA(isA<RecurrenceLimitException>()));
    }
  });
  test(
    'unused budgets still validate and base limit has its own diagnostic',
    () {
      expect(
        () => TimedEventSeries(
          recurrence: set(),
          span: span(u(1)),
          maxChanges: 0,
          maxValidationCandidateWork: 0,
          maxValidationOccurrences: 1,
        ),
        throwsRangeError,
      );
      expect(
        () => TimedRecurrenceSet(start: u(1), maxExplicitDates: 0).expand(
          window: UtcWindow(start: u(1).instant, end: u(2).instant),
          maxCandidateWork: 1,
          maxRuleOccurrences: 0,
          maxResults: 1,
        ),
        throwsRangeError,
      );
      expect(
        () => query(series(), 1, 7, base: 2),
        throwsA(
          isA<RecurrenceLimitException>().having(
            (e) => e.limit,
            'limit',
            'maxBaseOccurrences',
          ),
        ),
      );
    },
  );
  test('excluded DTSTART still validates rule alignment', () {
    final r = TimedRecurrenceSet(
      start: u(1),
      rule: TimedRecurrenceRule(
        frequency: TimedRecurrenceFrequency.daily,
        byHour: [10],
      ),
      exclusions: [u(1)],
      maxExplicitDates: 1,
    );
    expect(() => query(series(recurrence: r), 1, 2), throwsArgumentError);
  });
  test('date-time profile overflow rejects instead of extending UTC years', () {
    final last = TimedValue.utc(DateTime.utc(2099, 12, 31, 23));
    expect(
      () => TimedEventSpan(start: last, duration: CalendarDuration(hours: 2)),
      throwsRangeError,
    );
  });
  test(
    'finite identity/interval oracle for mixed ranges and single overrides',
    () {
      final s = series(
        recurrence: set(count: 8),
        changes: [
          TimedEventRangeChange(
            originalStart: u(3),
            replacement: span(u(5), 4),
          ),
          TimedEventRangeChange(
            originalStart: u(6),
            replacement: span(u(2), 2),
          ),
        ],
        exceptions: [
          TimedEventException.cancel(u(4)),
          TimedEventException.replace(u(7), span(u(10), 3)),
        ],
      );
      final expected = [
        (1, 1, 1),
        (2, 2, 1),
        (3, 5, 4),
        (5, 7, 4),
        (6, 2, 2),
        (7, 10, 3),
        (8, 4, 2),
      ];
      for (var from = 1; from <= 11; from++) {
        final window = UtcWindow(
          start: u(from, 0).instant,
          end: u(from + 1, 0).instant,
        );
        final want =
            expected
                .where(
                  (v) =>
                      DateTime.utc(2026, 1, v.$2, 9).isBefore(window.end) &&
                      DateTime.utc(
                        2026,
                        1,
                        v.$2,
                        9 + v.$3,
                      ).isAfter(window.start),
                )
                .toList()
              ..sort(
                (a, b) =>
                    a.$2 == b.$2 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2),
              );
        expect(
          query(s, from, from + 1).map((v) => v.originalStart.civil.date.day),
          want.map((v) => v.$1),
          reason: 'day $from',
        );
      }
    },
  );
}
