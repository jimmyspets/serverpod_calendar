import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

DateTime t(int hour) => DateTime.utc(2026, 3, 30, hour);
UtcWindow w(int from, int until) => UtcWindow(start: t(from), end: t(until));
List<AvailabilityInterval> calculate(
  List<AvailabilityDefinition> definitions, {
  bool fallback = false,
  int maxOutput = 100,
}) => composeAvailability(
  window: w(0, 24),
  definitions: definitions,
  fallbackUnavailable: fallback,
  maxDefinitions: 64,
  maxOpenings: 5000,
  maxOutputIntervals: maxOutput,
);
AvailabilityKind at(List<AvailabilityInterval> values, int hour) =>
    values.singleWhere((p) => p.window.contains(t(hour))).kind;

void main() {
  test(
    'optional bounds, clipping and fallback only outside applicable envelopes',
    () {
      final p = calculate([
        AvailabilityDefinition(
          start: t(4),
          end: t(20),
          openings: [w(0, 9), w(17, 24)],
        ),
      ]);
      expect(p.map((v) => (v.window, v.kind)), [
        (w(0, 9), AvailabilityKind.free),
        (w(9, 17), AvailabilityKind.unavailable),
        (w(17, 24), AvailabilityKind.free),
      ]);
      final closed = calculate([
        AvailabilityDefinition(start: t(4), end: t(20), openings: []),
      ]);
      expect(at(closed, 10), AvailabilityKind.unavailable);
      expect(at(closed, 3), AvailabilityKind.free);
      expect(
        at(calculate([], fallback: true), 10),
        AvailabilityKind.unavailable,
      );
      expect(
        at(calculate([AvailabilityDefinition(end: t(5), openings: [])]), 4),
        AvailabilityKind.unavailable,
      );
    },
  );
  test('holiday and temporary hours replace lower priorities over their entire range', () {
    final base = AvailabilityDefinition(openings: [w(9, 17)]);
    final holiday = AvailabilityDefinition(
      start: t(12),
      end: t(20),
      priority: 5,
      openings: [],
    );
    final urgent = AvailabilityDefinition(
      start: t(14),
      end: t(16),
      priority: 1,
      openings: [w(14, 15)],
    );
    final values = calculate([base, holiday, urgent]);
    expect(at(values, 10), AvailabilityKind.free);
    expect(at(values, 13), AvailabilityKind.unavailable);
    expect(at(values, 14), AvailabilityKind.free);
    expect(at(values, 15), AvailabilityKind.unavailable);
    expect(at(values, 16), AvailabilityKind.unavailable);
    expect(
      at(
        calculate([base, AvailabilityDefinition(priority: 9, openings: [])]),
        10,
      ),
      AvailabilityKind.unavailable,
    );
  });
  test('equal priorities union openings; closed BUSY wins over UNAVAILABLE and TENTATIVE', () {
    final values = calculate([
      AvailabilityDefinition(
        priority: 3,
        openings: [w(9, 12)],
        closedKind: AvailabilityKind.tentative,
      ),
      AvailabilityDefinition(
        priority: 3,
        openings: [w(13, 17)],
        closedKind: AvailabilityKind.unavailable,
      ),
      AvailabilityDefinition(
        priority: 3,
        openings: [],
        closedKind: AvailabilityKind.busy,
      ),
    ]);
    expect(at(values, 10), AvailabilityKind.free);
    expect(at(values, 14), AvailabilityKind.free);
    expect(at(values, 12), AvailabilityKind.busy);
  });
  test(
    'deterministic against an independent hourly oracle and input order',
    () {
      final definitions = [
        for (var n = 0; n < 10; n++)
          AvailabilityDefinition(
            start: t(n),
            end: t(n + 13),
            priority: n % 4,
            closedKind: AvailabilityKind.values[1 + n % 3],
            openings: [w(n + 1, n + 4), w(n + 3, n + 6)],
          ),
      ];
      for (final fallback in [false, true]) {
        final values = calculate(definitions, fallback: fallback);
        expect(
          calculate(
            definitions.reversed.toList(),
            fallback: fallback,
          ).map((v) => (v.window, v.kind)),
          values.map((v) => (v.window, v.kind)),
        );
        for (var h = 0; h < 24; h++) {
          final active = definitions
              .where(
                (d) =>
                    (d.start == null || !t(h).isBefore(d.start!)) &&
                    (d.end == null || t(h).isBefore(d.end!)),
              )
              .toList();
          AvailabilityKind expected;
          if (active.isEmpty) {
            expected = fallback
                ? AvailabilityKind.unavailable
                : AvailabilityKind.free;
          } else {
            active.sort(
              (a, b) => (a.priority == 0 ? 10 : a.priority).compareTo(
                b.priority == 0 ? 10 : b.priority,
              ),
            );
            final winners = active.where(
              (d) => d.priority == active.first.priority,
            );
            if (winners.any((d) => d.openings.any((o) => o.contains(t(h))))) {
              expected = AvailabilityKind.free;
            } else {
              expected = [
                AvailabilityKind.busy,
                AvailabilityKind.unavailable,
                AvailabilityKind.tentative,
              ].firstWhere((k) => winners.any((d) => d.closedKind == k));
            }
          }
          expect(at(values, h), expected, reason: 'hour $h');
        }
      }
    },
  );
  test('limits fail atomically and invalid rule values are rejected', () {
    expect(
      () => calculate([
        AvailabilityDefinition(openings: [w(9, 17)]),
      ], maxOutput: 2),
      throwsA(isA<AvailabilityLimitException>()),
    );
    expect(
      () => AvailabilityDefinition(priority: 10, openings: []),
      throwsRangeError,
    );
    expect(
      () => AvailabilityDefinition(
        closedKind: AvailabilityKind.free,
        openings: [],
      ),
      throwsArgumentError,
    );
    expect(
      () => AvailabilityDefinition(start: t(9), end: t(9), openings: []),
      throwsArgumentError,
    );
    expect(
      () => composeAvailability(
        window: w(0, 24),
        definitions: [
          AvailabilityDefinition(openings: [w(9, 10), w(11, 12)]),
        ],
        fallbackUnavailable: false,
        maxDefinitions: 1,
        maxOpenings: 1,
        maxOutputIntervals: 10,
      ),
      throwsA(isA<AvailabilityLimitException>()),
    );
  });
}
