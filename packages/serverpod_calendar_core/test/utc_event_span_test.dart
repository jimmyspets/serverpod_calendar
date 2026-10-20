import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

DateTime t(int s) => DateTime.utc(2026).add(Duration(seconds: s));
void main() {
  test('omitted end is a point without occupied duration', () {
    final p = UtcEventSpan(start: t(1));
    expect(p.isPoint, isTrue);
    expect(p.occupiedWindow, isNull);
    expect(p.occursIn(UtcWindow(start: t(1), end: t(2))), isTrue);
    expect(p.occursIn(UtcWindow(start: t(0), end: t(1))), isFalse);
  });
  test(
    'explicit end/duration forms preserve meaning and differ structurally',
    () {
      final e = UtcEventSpan(start: t(1), end: t(3));
      final d = UtcEventSpan(
        start: t(1),
        duration: CalendarDuration(seconds: 2),
      );
      expect(e.endExclusive, d.endExclusive);
      expect(e, isNot(d));
      expect(e.occupiedWindow, UtcWindow(start: t(1), end: t(3)));
      expect(e, UtcEventSpan(start: t(1), end: t(3)));
      expect(e.hashCode, UtcEventSpan(start: t(1), end: t(3)).hashCode);
    },
  );
  test('invalid cardinality, positivity, precision and profile reject', () {
    for (final action in <void Function()>[
      () => UtcEventSpan(start: t(1), end: t(1)),
      () => UtcEventSpan(start: t(1), end: t(0)),
      () => UtcEventSpan(
        start: t(1),
        end: t(2),
        duration: CalendarDuration(seconds: 1),
      ),
      () => UtcEventSpan(start: t(1), duration: CalendarDuration()),
      () => UtcEventSpan(
        start: t(1),
        duration: CalendarDuration(sign: -1, seconds: 1),
      ),
      () => UtcEventSpan(start: t(1).add(const Duration(milliseconds: 1))),
    ]) {
      expect(action, throwsArgumentError);
    }
    expect(() => UtcEventSpan(start: DateTime.utc(1969)), throwsRangeError);
    expect(() => UtcEventSpan(start: DateTime.utc(2100)), throwsRangeError);
  });
  test('last supported second may end at the explicit exclusive boundary', () {
    final s = UtcEventSpan(
      start: DateTime.utc(2099, 12, 31, 23, 59, 59),
      duration: CalendarDuration(seconds: 1),
    );
    expect(s.endExclusive, DateTime.utc(2100));
    expect(
      () =>
          UtcEventSpan(start: s.start, duration: CalendarDuration(seconds: 2)),
      throwsRangeError,
    );
  });
  test('finite point/interval oracle checks half-open overlap', () {
    for (var a = 0; a < 5; a++) {
      for (var b = a; b <= 5; b++) {
        for (var c = 0; c < 5; c++) {
          for (var d = c + 1; d <= 5; d++) {
            final span = b == a
                ? UtcEventSpan(start: t(a))
                : UtcEventSpan(start: t(a), end: t(b));
            final wanted = a == b ? a >= c && a < d : a < d && b > c;
            expect(span.occursIn(UtcWindow(start: t(c), end: t(d))), wanted);
          }
        }
      }
    }
  });
}
