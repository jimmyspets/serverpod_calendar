import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  for (final year in [1, 1600, 2255, 9999]) {
    test('short UTC window at year $year has exact relative microseconds', () {
      final start = DateTime.utc(year, 1, 1, 12, 30, 0, 123, 457);
      final end = DateTime.utc(year, 1, 1, 12, 30, 0, 123, 458);
      final window = UtcWindow(start: start, end: end);
      expect(window.elapsedMicroseconds, BigInt.one);
      expect(window.duration, const Duration(microseconds: 1));
    });
  }
  test(
    'negative-epoch floor/remainder produces exact positive window length',
    () {
      final window = UtcWindow(
        start: DateTime.utc(1969, 12, 31, 23, 59, 59, 999, 999),
        end: DateTime.utc(1970, 1, 1, 0, 0, 0, 0, 1),
      );
      expect(window.elapsedMicroseconds, BigInt.from(2));
      expect(window.duration, const Duration(microseconds: 2));
    },
  );
  test(
    'Duration accepts the portable exact limit and rejects longer values',
    () {
      final start = DateTime.utc(1970);
      final end = CalendarDuration(
        seconds: 9007199254,
        microsecond: 740991,
      ).addToUtc(start);
      final window = UtcWindow(start: start, end: end);
      expect(window.elapsedMicroseconds, BigInt.parse('9007199254740991'));
      expect(window.duration.inMicroseconds, 9007199254740991);
      final longer = UtcWindow(
        start: start,
        end: CalendarDuration(microsecond: 2).addToUtc(end),
      );
      expect(longer.elapsedMicroseconds, BigInt.parse('9007199254740993'));
      expect(() => longer.duration, throwsRangeError);
    },
  );
  test(
    'full instant range remains queryable without an overflowing Duration',
    () {
      final min = DateTime.fromMillisecondsSinceEpoch(
        -8640000000000000,
        isUtc: true,
      );
      final max = DateTime.fromMillisecondsSinceEpoch(
        8640000000000000,
        isUtc: true,
      );
      final window = UtcWindow(start: min, end: max);
      expect(window.elapsedMicroseconds, BigInt.parse('17280000000000000000'));
      expect(() => window.duration, throwsRangeError);
      expect(window.contains(DateTime.utc(2026)), isTrue);
      expect(
        window.intersection(
          UtcWindow(start: DateTime.utc(2026), end: DateTime.utc(2027)),
        ),
        UtcWindow(start: DateTime.utc(2026), end: DateTime.utc(2027)),
      );
    },
  );
}
