import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

UtcWindow w(int a, int b) => UtcWindow(
  start: DateTime.utc(2026, 1, 1, 0, a),
  end: DateTime.utc(2026, 1, 1, 0, b),
);
AvailabilityInterval b(int a, int z, AvailabilityKind k) =>
    AvailabilityInterval(window: w(a, z), kind: k);
List<AvailabilityInterval> partition(
  List<AvailabilityInterval> input, {
  bool unavailable = false,
  int output = 100,
}) => partitionFreeBusy(
  window: w(0, 12),
  bookings: input,
  fallbackUnavailable: unavailable,
  maxInputIntervals: 100,
  maxOutputIntervals: output,
);
void main() {
  test('empty complete input partitions as free or unavailable fallback', () {
    expect(partition([]).single.kind, AvailabilityKind.free);
    expect(
      partition([], unavailable: true).single.kind,
      AvailabilityKind.unavailable,
    );
    expect(partition([]).single.window, w(0, 12));
  });
  test(
    'clip merge adjacent and overlapping bookings without source boundaries',
    () {
      final p = partition([
        b(-2, 3, AvailabilityKind.busy),
        b(2, 5, AvailabilityKind.busy),
        b(5, 7, AvailabilityKind.busy),
        b(10, 15, AvailabilityKind.busy),
      ]);
      expect(p.map((v) => v.window), [w(0, 7), w(7, 10), w(10, 12)]);
      expect(p.map((v) => v.kind), [
        AvailabilityKind.busy,
        AvailabilityKind.free,
        AvailabilityKind.busy,
      ]);
    },
  );
  test(
    'native precedence retains tentative outside stronger busy and unavailable',
    () {
      final p = partition([
        b(1, 11, AvailabilityKind.tentative),
        b(3, 9, AvailabilityKind.busy),
        b(5, 7, AvailabilityKind.unavailable),
      ]);
      expect(p.map((v) => v.kind), [
        AvailabilityKind.free,
        AvailabilityKind.tentative,
        AvailabilityKind.busy,
        AvailabilityKind.unavailable,
        AvailabilityKind.busy,
        AvailabilityKind.tentative,
        AvailabilityKind.free,
      ]);
      expect(
        partition([
          b(2, 8, AvailabilityKind.busy),
        ], unavailable: true).single.kind,
        AvailabilityKind.unavailable,
      );
    },
  );
  test('finite tick oracle verifies complete disjoint coverage classifications and input-order invariance', () {
    final inputs = [
      b(0, 4, AvailabilityKind.tentative),
      b(2, 7, AvailabilityKind.busy),
      b(4, 6, AvailabilityKind.unavailable),
      b(8, 12, AvailabilityKind.tentative),
    ];
    for (final unavailable in [false, true]) {
      final p = partition(inputs, unavailable: unavailable);
      final reverse = partition(
        inputs.reversed.toList(),
        unavailable: unavailable,
      );
      expect(
        p.map((v) => (v.window, v.kind)),
        reverse.map((v) => (v.window, v.kind)),
      );
      for (var tick = 0; tick < 12; tick++) {
        final instant = DateTime.utc(2026, 1, 1, 0, tick);
        final expected = unavailable
            ? AvailabilityKind.unavailable
            : inputs
                  .where((v) => v.window.contains(instant))
                  .fold(
                    AvailabilityKind.free,
                    (a, v) => a.index > v.kind.index ? a : v.kind,
                  );
        expect(
          p.where((v) => v.window.contains(instant)).single.kind,
          expected,
        );
      }
      expect(p.first.window.start, w(0, 12).start);
      expect(p.last.window.end, w(0, 12).end);
      for (var i = 1; i < p.length; i++) {
        expect(p[i - 1].window.end, p[i].window.start);
      }
    }
  });
  test('caps reject atomically and free input cannot erase bookings', () {
    expect(
      () => partition([b(1, 2, AvailabilityKind.busy)], output: 2),
      throwsA(isA<AvailabilityLimitException>()),
    );
    expect(
      () => partitionFreeBusy(
        window: w(0, 12),
        bookings: [
          b(1, 2, AvailabilityKind.busy),
          b(3, 4, AvailabilityKind.busy),
        ],
        fallbackUnavailable: false,
        maxInputIntervals: 1,
        maxOutputIntervals: 100,
      ),
      throwsA(isA<AvailabilityLimitException>()),
    );
    expect(
      () => partition([b(1, 2, AvailabilityKind.free)]),
      throwsArgumentError,
    );
    expect(() => partition([]).clear(), throwsUnsupportedError);
  });
}
