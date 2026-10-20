import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

DateTime t(int s) => DateTime.utc(2026).add(Duration(seconds: s));
UtcWindow w(int a, int b) => UtcWindow(start: t(a), end: t(b));
void main() {
  test('half-open membership, adjacency, intersection and equality', () {
    expect(w(1, 3).contains(t(1)), isTrue);
    expect(w(1, 3).contains(t(3)), isFalse);
    expect(w(1, 3).overlaps(w(3, 4)), isFalse);
    expect(w(1, 3).intersection(w(3, 4)), isNull);
    expect(w(1, 3).intersection(w(2, 4)), w(2, 3));
    expect(w(1, 3), w(1, 3));
    expect(w(1, 3).hashCode, w(1, 3).hashCode);
    expect(w(1, 3).duration, const Duration(seconds: 2));
  });
  test('finite occupied-second oracle checks every short window pair', () {
    for (var a = 0; a < 6; a++) {
      for (var b = a + 1; b <= 6; b++) {
        for (var c = 0; c < 6; c++) {
          for (var d = c + 1; d <= 6; d++) {
            final left = {for (var i = a; i < b; i++) i},
                right = {for (var i = c; i < d; i++) i};
            expect(
              w(a, b).overlaps(w(c, d)),
              left.intersection(right).isNotEmpty,
            );
          }
        }
      }
    }
  });
  test('rejects local, equal, reversed and fractional bounds', () {
    expect(
      () => UtcWindow(start: DateTime(2026), end: t(1)),
      throwsArgumentError,
    );
    expect(() => w(1, 1), throwsArgumentError);
    expect(() => w(2, 1), throwsArgumentError);
    expect(
      () => UtcWindow(
        start: t(0).add(const Duration(milliseconds: 1)),
        end: t(1),
      ),
      throwsArgumentError,
    );
  });
}
