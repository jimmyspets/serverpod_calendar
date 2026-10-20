import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  test(
    'entire calendar horizon has exact elapsed seconds and microsecond units',
    () {
      final w = UtcWindow(start: DateTime.utc(1970), end: DateTime.utc(2100));
      expect(w.duration.inSeconds, 4102444800);
      expect(
        w.elapsedMicroseconds,
        BigInt.from(4102444800) * BigInt.from(1000000),
      );
    },
  );
  test(
    'zero fraction encodings are accepted; every nonzero fraction rejects',
    () {
      final zero = DateTime.parse('2026-01-01T00:00:00.000000Z');
      expect(
        UtcWindow(
          start: zero,
          end: DateTime.utc(2026, 1, 1, 0, 0, 1),
        ).duration.inSeconds,
        1,
      );
      for (final text in [
        '2026-01-01T00:00:00.001Z',
        '2026-01-01T00:00:00.000001Z',
      ]) {
        expect(
          () => UtcWindow(
            start: DateTime.parse(text),
            end: DateTime.utc(2026, 1, 1, 0, 0, 1),
          ),
          throwsArgumentError,
        );
      }
    },
  );
  test(
    'boundary projection padding does not imply ordinary calendar dates',
    () {
      expect(
        UtcWindow(
          start: DateTime.utc(1969, 12, 31),
          end: DateTime.utc(1970),
        ).duration.inDays,
        1,
      );
      expect(
        () => TimedValue.utc(DateTime.utc(1969, 12, 31)),
        throwsRangeError,
      );
      expect(() => TimedValue.utc(DateTime.utc(2100)), throwsRangeError);
    },
  );
}
