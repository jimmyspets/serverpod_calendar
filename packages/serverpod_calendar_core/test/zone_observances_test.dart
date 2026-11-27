import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  final resolver = NamedZoneResolver();
  test('publication evidence preserves daylight flags and offset chain', () {
    final values = resolver.calendarProfileObservances(
      zoneId: 'Europe/Stockholm',
      maxObservances: 8192,
    );
    expect(values.first.instant, DateTime.utc(1969, 12, 31));
    expect(values.first.offsetFrom, values.first.offsetTo);
    expect(values.last.instant.year, 2099);
    expect(values.any((v) => v.isDaylight), isTrue);
    for (var i = 1; i < values.length; i++) {
      expect(values[i].instant.isAfter(values[i - 1].instant), isTrue);
      expect(values[i].offsetFrom, values[i - 1].offsetTo);
    }
    expect(() => values.clear(), throwsUnsupportedError);
  });
  test(
    'fixed zones have one seed; insufficient budgets and unknown zones fail',
    () {
      expect(
        resolver
            .calendarProfileObservances(zoneId: 'Etc/UTC', maxObservances: 1)
            .single
            .offsetTo,
        Duration.zero,
      );
      expect(
        () => resolver.calendarProfileObservances(
          zoneId: 'Europe/Stockholm',
          maxObservances: 1,
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
      expect(
        () => resolver.calendarProfileObservances(
          zoneId: 'Invalid/Zone',
          maxObservances: 8192,
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'negative daylight saving is a label, not an inferred offset increase',
    () {
      final values = resolver.calendarProfileObservances(
        zoneId: 'Europe/Dublin',
        maxObservances: 8192,
      );
      expect(
        values.any(
          (v) =>
              v.instant.year == 2026 &&
              v.isDaylight &&
              v.offsetTo == Duration.zero,
        ),
        isTrue,
      );
      expect(
        values.any(
          (v) =>
              v.instant.year == 2026 &&
              !v.isDaylight &&
              v.offsetTo == const Duration(hours: 1),
        ),
        isTrue,
      );
    },
  );
}
