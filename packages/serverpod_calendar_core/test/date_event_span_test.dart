import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate date(int year, int month, int day) =>
    CalendarDate(year: year, month: month, day: day);
CalendarDate d(int day) => date(2026, 1, day);

void main() {
  test('omitted end and duration retain an implicit one-day event', () {
    final span = DateEventSpan(start: d(1));
    expect(span.start, d(1));
    expect(span.end, isNull);
    expect(span.duration, isNull);
    expect(span.endExclusive, d(2));
    expect(span.dayCount, 1);
  });
  test('explicit exclusive end retains the supplied form', () {
    final span = DateEventSpan(start: d(1), end: d(4));
    expect(span.end, d(4));
    expect(span.duration, isNull);
    expect(span.endExclusive, d(4));
    expect(span.dayCount, 3);
  });
  for (final duration in [
    CalendarDuration(days: 7),
    CalendarDuration(weeks: 1),
  ]) {
    test(
      'positive duration retains original units: ${duration.weeks} weeks',
      () {
        final span = DateEventSpan(start: d(1), duration: duration);
        expect(identical(span.duration, duration), isTrue);
        expect(span.end, isNull);
        expect(span.endExclusive, d(8));
        expect(span.dayCount, 7);
      },
    );
  }
  test('end and duration are rejected even when their results agree', () {
    expect(
      () => DateEventSpan(
        start: d(1),
        end: d(2),
        duration: CalendarDuration(days: 1),
      ),
      throwsArgumentError,
    );
  });
  for (final end in [d(1), date(2025, 12, 31)]) {
    test('explicit end must strictly follow start: $end', () {
      expect(() => DateEventSpan(start: d(1), end: end), throwsArgumentError);
    });
  }
  for (final (index, duration) in [
    CalendarDuration(),
    CalendarDuration(sign: -1),
    CalendarDuration(sign: -1, days: 1),
    CalendarDuration(sign: -1, weeks: 1),
    CalendarDuration(hours: 24),
    CalendarDuration(days: 1, hours: 1),
    CalendarDuration(days: 1, minutes: 1),
    CalendarDuration(days: 1, seconds: 1),
    CalendarDuration(days: 1, microsecond: 1),
  ].indexed) {
    test('rejects invalid event duration #$index', () {
      expect(
        () => DateEventSpan(start: d(1), duration: duration),
        throwsArgumentError,
      );
    });
  }
  for (final year in [1900, 2000, 2024, 2100]) {
    test('default/duration spans cross Gregorian February in $year', () {
      final leap = year == 2000 || year == 2024;
      final span = DateEventSpan(start: date(year, 2, 28));
      expect(span.endExclusive, leap ? date(year, 2, 29) : date(year, 3, 1));
      final twoDays = DateEventSpan(
        start: date(year, 2, 28),
        duration: CalendarDuration(days: 2),
      );
      expect(twoDays.endExclusive, leap ? date(year, 3, 1) : date(year, 3, 2));
      expect(twoDays.dayCount, 2);
    });
  }
  test('weeks cross year boundaries using calendar dates', () {
    final span = DateEventSpan(
      start: date(2023, 12, 25),
      duration: CalendarDuration(weeks: 2),
    );
    expect(span.endExclusive, date(2024, 1, 8));
    expect(span.dayCount, 14);
  });
  test('date membership is half-open across all bounds', () {
    final span = DateEventSpan(start: d(2), end: d(5));
    expect(span.contains(d(1)), isFalse);
    expect(span.contains(d(2)), isTrue);
    expect(span.contains(d(3)), isTrue);
    expect(span.contains(d(4)), isTrue);
    expect(span.contains(d(5)), isFalse);
    expect(span.contains(d(6)), isFalse);
  });
  test('overlap is symmetric and touching spans are disjoint', () {
    final span = DateEventSpan(start: d(3), end: d(7));
    for (final other in [
      DateEventSpan(start: d(1), end: d(3)),
      DateEventSpan(start: d(7)),
      DateEventSpan(start: d(9)),
    ]) {
      expect(span.overlaps(other), isFalse);
      expect(other.overlaps(span), isFalse);
    }
    for (final other in [
      span,
      DateEventSpan(start: d(4)),
      DateEventSpan(start: d(1), end: d(5)),
      DateEventSpan(start: d(6), end: d(8)),
      DateEventSpan(start: d(1), end: d(9)),
    ]) {
      expect(span.overlaps(other), isTrue);
      expect(other.overlaps(span), isTrue);
    }
  });
  test('all short span pairs agree with independent occupied-date sets', () {
    for (var a = 1; a <= 6; a++) {
      for (var aEnd = a + 1; aEnd <= 8; aEnd++) {
        final left = DateEventSpan(start: d(a), end: d(aEnd));
        final occupied = {for (var n = a; n < aEnd; n++) n};
        for (var b = 1; b <= 6; b++) {
          for (var bEnd = b + 1; bEnd <= 8; bEnd++) {
            final right = DateEventSpan(start: d(b), end: d(bEnd));
            final expected = {for (var n = b; n < bEnd; n++) n}
                .intersection(occupied)
                .isNotEmpty;
            expect(left.overlaps(right), expected);
          }
        }
      }
    }
  });
  test(
    'equal occupied dates preserve distinct end/duration/default intent',
    () {
      final implicit = DateEventSpan(start: d(1));
      final explicit = DateEventSpan(start: d(1), end: d(2));
      final duration = DateEventSpan(
        start: d(1),
        duration: CalendarDuration(days: 1),
      );
      expect(implicit.endExclusive, explicit.endExclusive);
      expect(explicit.endExclusive, duration.endExclusive);
      expect({implicit, explicit, duration}.length, 3);
      final days = DateEventSpan(
        start: d(1),
        duration: CalendarDuration(days: 7),
      );
      final weeks = DateEventSpan(
        start: d(1),
        duration: CalendarDuration(weeks: 1),
      );
      expect(days.endExclusive, weeks.endExclusive);
      expect(days, isNot(weeks));
    },
  );
  test('structurally equal spans have equal hashes', () {
    for (final pair in [
      (DateEventSpan(start: d(1)), DateEventSpan(start: d(1))),
      (
        DateEventSpan(start: d(1), end: d(4)),
        DateEventSpan(start: d(1), end: d(4)),
      ),
      (
        DateEventSpan(start: d(1), duration: CalendarDuration(days: 3)),
        DateEventSpan(start: d(1), duration: CalendarDuration(days: 3)),
      ),
    ]) {
      expect(pair.$1, pair.$2);
      expect(pair.$1.hashCode, pair.$2.hashCode);
    }
    expect(DateEventSpan(start: d(1)), isNot(DateEventSpan(start: d(2))));
    expect(DateEventSpan(start: d(1)), isNot(d(1)));
  });
  test('full-profile explicit bounds are dates rather than instants', () {
    final span = DateEventSpan(start: date(1, 1, 1), end: date(9999, 12, 31));
    expect(span.dayCount, 3652058);
    expect(span.contains(date(9999, 12, 30)), isTrue);
    expect(span.contains(date(9999, 12, 31)), isFalse);
    expect(DateEventSpan(start: date(1, 1, 1)).endExclusive, date(1, 1, 2));
  });
  test('effective end can reach the maximum date exactly', () {
    final span = DateEventSpan(start: date(9999, 12, 30));
    expect(span.endExclusive, date(9999, 12, 31));
    final week = DateEventSpan(
      start: date(9999, 12, 24),
      duration: CalendarDuration(weeks: 1),
    );
    expect(week.endExclusive, date(9999, 12, 31));
  });
  test(
    'last-profile-day event fails rather than clipping its exclusive end',
    () {
      expect(() => DateEventSpan(start: date(9999, 12, 31)), throwsRangeError);
      expect(
        () => DateEventSpan(
          start: date(9999, 12, 31),
          duration: CalendarDuration(days: 1),
        ),
        throwsRangeError,
      );
      expect(
        () => DateEventSpan(
          start: date(9999, 12, 25),
          duration: CalendarDuration(weeks: 1),
        ),
        throwsRangeError,
      );
    },
  );
  for (final duration in [
    CalendarDuration(days: CalendarDuration.maxComponent),
    CalendarDuration(weeks: CalendarDuration.maxComponent),
  ]) {
    test(
      'huge duration rejects before unsafe aggregation: ${duration.weeks} weeks',
      () {
        expect(
          () => DateEventSpan(start: d(1), duration: duration),
          throwsRangeError,
        );
      },
    );
  }
  test('all-day calendar spans do not resolve DST or extend zone coverage', () {
    final spring = DateEventSpan(start: date(2026, 3, 29));
    final autumn = DateEventSpan(start: date(2026, 10, 25));
    expect(spring.dayCount, 1);
    expect(autumn.dayCount, 1);
    expect(DateEventSpan(start: date(2038, 1, 1)).dayCount, 1);
    expect(
      () => NamedZoneResolver().resolve(
        CivilDateTime(date: date(2038, 1, 1), hour: 0, minute: 0),
        zoneId: 'Europe/Stockholm',
      ),
      throwsA(isA<RangeError>()),
    );
  });
}
