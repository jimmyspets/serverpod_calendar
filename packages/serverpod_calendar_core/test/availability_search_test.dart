import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

DateTime t(int n) => DateTime.utc(2026, 3, 30, n);
UtcWindow w(int a, int b) => UtcWindow(start: t(a), end: t(b));
List<AvailabilityInterval> p(int a, int b) => partitionFreeBusy(
  window: w(0, 24),
  bookings: [
    AvailabilityInterval(window: w(a, b), kind: AvailabilityKind.busy),
  ],
  fallbackUnavailable: false,
  maxInputIntervals: 20,
  maxOutputIntervals: 20,
);
List<AvailabilityInterval> combine(List<List<AvailabilityInterval>> sources) =>
    combineCompleteAvailability(
      window: w(0, 24),
      sources: sources,
      maxSources: 8,
      maxInputIntervals: 100,
      maxOutputIntervals: 100,
    );
void main() {
  test('free time intersects all independently evaluated contributors', () {
    final v = combine([p(9, 10), p(10, 11)]);
    expect(v.map((x) => (x.window, x.kind)), [
      (w(0, 9), AvailabilityKind.free),
      (w(9, 11), AvailabilityKind.busy),
      (w(11, 24), AvailabilityKind.free),
    ]);
    expect(freeAvailabilityWindows(v, minimumSeconds: 3600), [
      w(0, 9),
      w(11, 24),
    ]);
  });
  test(
    'independent calendars cannot override each other with rule priority',
    () {
      List<AvailabilityInterval> hours(int priority, int from, int until) =>
          composeAvailability(
            window: w(0, 24),
            definitions: [
              AvailabilityDefinition(
                priority: priority,
                openings: [w(from, until)],
              ),
            ],
            fallbackUnavailable: false,
            maxDefinitions: 8,
            maxOpenings: 8,
            maxOutputIntervals: 20,
          );
      expect(
        freeAvailabilityWindows(
          combine([hours(0, 9, 17), hours(1, 10, 18)]),
          minimumSeconds: 1,
        ),
        [w(10, 17)],
      );
    },
  );
  test('minimum is elapsed time applied after maximal intervals merge', () {
    final v = combine([p(0, 9), p(17, 24)]);
    expect(freeAvailabilityWindows(v, minimumSeconds: 8 * 3600), [w(9, 17)]);
    expect(freeAvailabilityWindows(v, minimumSeconds: 8 * 3600 + 1), isEmpty);
    expect(
      () => freeAvailabilityWindows(v, minimumSeconds: 0),
      throwsRangeError,
    );
    expect(
      () => freeAvailabilityWindows(v, minimumSeconds: 2678401),
      throwsRangeError,
    );
  });
  test('empty incomplete overlapping and out-of-window inputs reject', () {
    for (final inputs in <List<List<AvailabilityInterval>>>[
      [],
      [[]],
      [
        [AvailabilityInterval(window: w(1, 24), kind: AvailabilityKind.free)],
      ],
      [
        [
          AvailabilityInterval(window: w(0, 10), kind: AvailabilityKind.free),
          AvailabilityInterval(window: w(9, 24), kind: AvailabilityKind.free),
        ],
      ],
      [
        [
          AvailabilityInterval(
            window: UtcWindow(start: t(0), end: t(25)),
            kind: AvailabilityKind.free,
          ),
        ],
      ],
    ]) {
      expect(() => combine(inputs), throwsArgumentError);
    }
  });
  test('combined caps count raw inputs before canonicalization', () {
    expect(
      () => combineCompleteAvailability(
        window: w(0, 24),
        sources: [p(9, 10), p(9, 10)],
        maxSources: 1,
        maxInputIntervals: 100,
        maxOutputIntervals: 100,
      ),
      throwsA(isA<AvailabilityLimitException>()),
    );
    expect(
      () => combineCompleteAvailability(
        window: w(0, 24),
        sources: [p(9, 10), p(9, 10)],
        maxSources: 2,
        maxInputIntervals: 5,
        maxOutputIntervals: 100,
      ),
      throwsA(isA<AvailabilityLimitException>()),
    );
  });
  test('classification and free intersection agree with an independent hourly oracle', () {
    final inputs = [p(9, 13), p(10, 14), p(15, 17)];
    final v = combine(inputs);
    for (var n = 0; n < 24; n++) {
      final expected = inputs
          .map((s) => s.singleWhere((p) => p.window.contains(t(n))).kind.index)
          .reduce((a, b) => a > b ? a : b);
      expect(
        v.singleWhere((p) => p.window.contains(t(n))).kind.index,
        expected,
      );
    }
    expect(
      combine(inputs.reversed.toList()).map((x) => (x.window, x.kind)),
      v.map((x) => (x.window, x.kind)),
    );
  });
}
