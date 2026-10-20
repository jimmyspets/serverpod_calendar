import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

DateTime t(int seconds) =>
    DateTime.utc(2026, 1, 1).add(Duration(seconds: seconds));
void main() {
  test('omitted end and duration retain a point event without occupancy', () {
    final span = UtcEventSpan(start: t(3));
    expect(span.start, t(3));
    expect(span.end, isNull);
    expect(span.duration, isNull);
    expect(span.endExclusive, t(3));
    expect(span.isPoint, isTrue);
    expect(span.elapsedMicroseconds, BigInt.zero);
    expect(span.occupiedWindow, isNull);
  });
  test('explicit end retains input and positive interval geometry', () {
    final span = UtcEventSpan(start: t(1), end: t(4));
    expect(span.end, t(4));
    expect(span.duration, isNull);
    expect(span.endExclusive, t(4));
    expect(span.isPoint, isFalse);
    expect(span.elapsedMicroseconds, BigInt.from(3000000));
    expect(span.occupiedWindow, UtcWindow(start: t(1), end: t(4)));
  });
  test('positive duration preserves units and original value', () {
    final duration = CalendarDuration(
      days: 1,
      hours: 2,
      minutes: 3,
      seconds: 4,
      microsecond: 567891,
    );
    final span = UtcEventSpan(start: t(1), duration: duration);
    expect(identical(span.duration, duration), isTrue);
    expect(span.end, isNull);
    expect(span.endExclusive, DateTime.utc(2026, 1, 2, 2, 3, 5, 567, 891));
    expect(span.elapsedMicroseconds, BigInt.from(93784567891));
  });
  test('UTC weeks and clock durations remain distinct canonical forms', () {
    final weeks = UtcEventSpan(
      start: t(1),
      duration: CalendarDuration(weeks: 1),
    );
    final days = UtcEventSpan(start: t(1), duration: CalendarDuration(days: 7));
    final hours = UtcEventSpan(
      start: t(1),
      duration: CalendarDuration(hours: 168),
    );
    expect(weeks.endExclusive, days.endExclusive);
    expect(days.endExclusive, hours.endExclusive);
    expect({weeks, days, hours}.length, 3);
  });
  test('equal actual bounds retain explicit-end versus duration intent', () {
    final a = UtcEventSpan(start: t(1), end: t(4));
    final b = UtcEventSpan(start: t(1), duration: CalendarDuration(seconds: 3));
    expect(a.occupiedWindow, b.occupiedWindow);
    expect(a, isNot(b));
  });
  test('conflicting fields reject even when their effective ends agree', () {
    expect(
      () => UtcEventSpan(
        start: t(1),
        end: t(4),
        duration: CalendarDuration(seconds: 3),
      ),
      throwsArgumentError,
    );
  });
  test('explicit equal/reversed ends cannot encode the default point', () {
    for (final end in [t(1), t(0)]) {
      expect(() => UtcEventSpan(start: t(1), end: end), throwsArgumentError);
    }
  });
  test('local values reject for start/end rather than being converted', () {
    expect(() => UtcEventSpan(start: DateTime(2026)), throwsArgumentError);
    expect(
      () => UtcEventSpan(
        start: DateTime(2026),
        duration: CalendarDuration(seconds: 1),
      ),
      throwsArgumentError,
    );
    expect(
      () => UtcEventSpan(start: t(1), end: DateTime(2026, 1, 2)),
      throwsArgumentError,
    );
  });
  for (final duration in [
    CalendarDuration(),
    CalendarDuration(sign: -1),
    CalendarDuration(sign: -1, seconds: 1),
    CalendarDuration(sign: -1, microsecond: 1),
    CalendarDuration(sign: -1, weeks: 1),
  ]) {
    test(
      'nonpositive event duration rejects ${duration.sign}/${duration.seconds}/${duration.microsecond}/${duration.weeks}',
      () {
        expect(
          () => UtcEventSpan(start: t(1), duration: duration),
          throwsArgumentError,
        );
      },
    );
  }
  test(
    'interval queries include overlap and exclude both touching boundaries',
    () {
      final span = UtcEventSpan(start: t(3), end: t(7));
      for (final window in [
        UtcWindow(start: t(0), end: t(3)),
        UtcWindow(start: t(7), end: t(8)),
        UtcWindow(start: t(8), end: t(9)),
      ]) {
        expect(span.occursIn(window), isFalse);
      }
      for (final window in [
        UtcWindow(start: t(3), end: t(7)),
        UtcWindow(start: t(4), end: t(5)),
        UtcWindow(start: t(1), end: t(9)),
        UtcWindow(start: t(1), end: t(4)),
        UtcWindow(start: t(6), end: t(8)),
      ]) {
        expect(span.occursIn(window), isTrue);
      }
    },
  );
  test(
    'point query membership includes lower bound but excludes upper bound',
    () {
      final window = UtcWindow(start: t(3), end: t(7));
      expect(UtcEventSpan(start: t(2)).occursIn(window), isFalse);
      expect(UtcEventSpan(start: t(3)).occursIn(window), isTrue);
      expect(UtcEventSpan(start: t(5)).occursIn(window), isTrue);
      expect(UtcEventSpan(start: t(7)).occursIn(window), isFalse);
      expect(UtcEventSpan(start: t(8)).occursIn(window), isFalse);
      expect(UtcEventSpan(start: t(5)).occupiedWindow, isNull);
    },
  );
  test(
    'one-microsecond interval and adjacent point queries remain distinct',
    () {
      final start = DateTime.utc(2026, 1, 1, 0, 0, 0, 123, 457);
      final end = DateTime.utc(2026, 1, 1, 0, 0, 0, 123, 458);
      final span = UtcEventSpan(
        start: start,
        duration: CalendarDuration(microsecond: 1),
      );
      final window = UtcWindow(start: start, end: end);
      expect(span.occursIn(window), isTrue);
      expect(span.elapsedMicroseconds, BigInt.one);
      expect(UtcEventSpan(start: start).occursIn(window), isTrue);
      expect(UtcEventSpan(start: end).occursIn(window), isFalse);
    },
  );
  for (final year in [1, 1600, 2255, 9999]) {
    test(
      'year $year exact fraction and query behavior on distant UTC instants',
      () {
        final start = DateTime.utc(year, 1, 1, 12, 30, 0, 123, 457);
        final end = DateTime.utc(year, 1, 1, 12, 30, 0, 123, 458);
        final after = DateTime.utc(year, 1, 1, 12, 30, 0, 123, 459);
        final span = UtcEventSpan(
          start: start,
          duration: CalendarDuration(microsecond: 1),
        );
        expect(span.endExclusive, end);
        expect(span.elapsedMicroseconds, BigInt.one);
        expect(span.occursIn(UtcWindow(start: end, end: after)), isFalse);
        expect(
          UtcEventSpan(start: end).occursIn(UtcWindow(start: end, end: after)),
          isTrue,
        );
      },
    );
  }
  test(
    'full DateTime span has exact BigInt elapsed length beyond int Duration',
    () {
      final min = DateTime.fromMillisecondsSinceEpoch(
        -8640000000000000,
        isUtc: true,
      );
      final max = DateTime.fromMillisecondsSinceEpoch(
        8640000000000000,
        isUtc: true,
      );
      final explicit = UtcEventSpan(start: min, end: max);
      final duration = UtcEventSpan(
        start: min,
        duration: CalendarDuration(days: 200000000),
      );
      expect(
        explicit.elapsedMicroseconds,
        BigInt.parse('17280000000000000000'),
      );
      expect(duration.endExclusive, max);
      expect(duration.elapsedMicroseconds, explicit.elapsedMicroseconds);
      expect(explicit.occursIn(UtcWindow(start: t(1), end: t(2))), isTrue);
    },
  );
  test('terminal point is representable but outside a window ending there', () {
    final max = DateTime.fromMillisecondsSinceEpoch(
      8640000000000000,
      isUtc: true,
    );
    final justBefore = CalendarDuration(sign: -1, microsecond: 1).addToUtc(max);
    final span = UtcEventSpan(start: max);
    expect(span.isPoint, isTrue);
    expect(span.occursIn(UtcWindow(start: justBefore, end: max)), isFalse);
    expect(
      () =>
          UtcEventSpan(start: max, duration: CalendarDuration(microsecond: 1)),
      throwsRangeError,
    );
    expect(
      UtcEventSpan(
        start: justBefore,
        duration: CalendarDuration(microsecond: 1),
      ).endExclusive,
      max,
    );
  });
  test('huge positive event durations fail rather than wrapping', () {
    expect(
      () => UtcEventSpan(
        start: t(1),
        duration: CalendarDuration(days: CalendarDuration.maxComponent),
      ),
      throwsRangeError,
    );
    expect(
      () => UtcEventSpan(
        start: t(1),
        duration: CalendarDuration(weeks: CalendarDuration.maxComponent),
      ),
      throwsRangeError,
    );
  });
  test('query geometry agrees with finite occupied-tick and point sets', () {
    for (var start = 0; start <= 6; start++) {
      for (var end = start; end <= 8; end++) {
        final span = start == end
            ? UtcEventSpan(start: t(start))
            : UtcEventSpan(start: t(start), end: t(end));
        final ticks = start == end
            ? {start}
            : {for (var tick = start; tick < end; tick++) tick};
        for (var from = 0; from <= 6; from++) {
          for (var until = from + 1; until <= 8; until++) {
            final queryTicks = {
              for (var tick = from; tick < until; tick++) tick,
            };
            expect(
              span.occursIn(UtcWindow(start: t(from), end: t(until))),
              ticks.intersection(queryTicks).isNotEmpty,
            );
          }
        }
      }
    }
  });
  test('equality/hash include start and original end/duration form', () {
    final point = UtcEventSpan(start: t(1));
    final samePoint = UtcEventSpan(start: t(1));
    expect(point, samePoint);
    expect(point.hashCode, samePoint.hashCode);
    final explicit = UtcEventSpan(start: t(1), end: t(4));
    final same = UtcEventSpan(start: t(1), end: t(4));
    expect(explicit, same);
    expect(explicit.hashCode, same.hashCode);
    expect(explicit, isNot(UtcEventSpan(start: t(2), end: t(4))));
    expect(explicit, isNot(UtcEventSpan(start: t(1), end: t(5))));
    final duration = UtcEventSpan(
      start: t(1),
      duration: CalendarDuration(seconds: 3),
    );
    final sameDuration = UtcEventSpan(
      start: t(1),
      duration: CalendarDuration(seconds: 3),
    );
    expect(duration, sameDuration);
    expect(duration.hashCode, sameDuration.hashCode);
    expect(duration, isNot(explicit));
    expect(point, isNot(t(1)));
  });
}
