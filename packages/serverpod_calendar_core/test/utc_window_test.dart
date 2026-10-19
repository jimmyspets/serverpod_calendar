import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  final start = DateTime.utc(2024, 2, 29, 23, 59, 59, 999, 998);
  final middle = start.add(const Duration(microseconds: 1));
  final end = start.add(const Duration(microseconds: 2));
  UtcWindow window(DateTime from, DateTime to) =>
      UtcWindow(start: from, end: to);

  group('validation', () {
    test(
      'retains explicit UTC bounds and elapsed precision across leap day',
      () {
        final value = window(start, end);
        expect(value.start, start);
        expect(value.end, DateTime.utc(2024, 3));
        expect(value.duration, const Duration(microseconds: 2));
      },
    );

    test('rejects local start even when local offset happens to be zero', () {
      expect(() => window(DateTime(2024, 2, 29), end), throwsArgumentError);
    });

    test('rejects local end', () {
      expect(() => window(start, DateTime(2024, 3)), throwsArgumentError);
    });

    test('rejects an empty window', () {
      expect(() => window(start, start), throwsArgumentError);
    });

    test('rejects reversed bounds', () {
      expect(() => window(end, start), throwsArgumentError);
    });
  });

  group('half-open membership', () {
    final value = window(start, end);
    test('includes start and interior but excludes end', () {
      expect(value.contains(start), isTrue);
      expect(value.contains(middle), isTrue);
      expect(value.contains(end), isFalse);
    });

    test('excludes instants outside both bounds', () {
      expect(
        value.contains(start.subtract(const Duration(microseconds: 1))),
        isFalse,
      );
      expect(value.contains(end.add(const Duration(microseconds: 1))), isFalse);
    });

    test('rejects local instants', () {
      expect(() => value.contains(DateTime(2024, 3)), throwsArgumentError);
    });
  });

  group('intersection', () {
    final a = window(start, end);
    test('adjacent windows in either order do not overlap', () {
      final b = window(end, end.add(const Duration(seconds: 1)));
      expect(a.overlaps(b), isFalse);
      expect(b.overlaps(a), isFalse);
      expect(a.intersection(b), isNull);
      expect(b.intersection(a), isNull);
    });

    test('separated windows do not overlap', () {
      final b = window(
        end.add(const Duration(seconds: 1)),
        end.add(const Duration(seconds: 2)),
      );
      expect(a.overlaps(b), isFalse);
      expect(a.intersection(b), isNull);
    });

    test('partial overlap clips bounds and is symmetric', () {
      final b = window(middle, end.add(const Duration(microseconds: 1)));
      final expected = window(middle, end);
      expect(a.overlaps(b), isTrue);
      expect(a.intersection(b), expected);
      expect(b.intersection(a), expected);
    });

    test('a contained window is preserved in both directions', () {
      final outer = window(
        start.subtract(const Duration(days: 1)),
        end.add(const Duration(days: 1)),
      );
      expect(a.intersection(outer), a);
      expect(outer.intersection(a), a);
    });

    test('identical windows preserve the whole interval', () {
      expect(a.overlaps(a), isTrue);
      expect(a.intersection(a), a);
    });
  });

  test('value equality and hashing distinguish both bounds', () {
    final a = window(start, end);
    final equal = window(
      DateTime.fromMicrosecondsSinceEpoch(
        start.microsecondsSinceEpoch,
        isUtc: true,
      ),
      end,
    );
    expect(a, equal);
    expect(a.hashCode, equal.hashCode);
    expect({
      a,
      equal,
      window(start, middle),
      window(middle, end),
    }, hasLength(3));
    expect(a == Object(), isFalse);
  });
}
