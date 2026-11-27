import 'utc_window.dart';

/// Native precedence; RFC 7953 rule composition is a separate calculation.
enum AvailabilityKind { free, tentative, busy, unavailable }

final class AvailabilityInterval {
  const AvailabilityInterval({required this.window, required this.kind});
  final UtcWindow window;
  final AvailabilityKind kind;
}

final class AvailabilityLimitException implements Exception {
  const AvailabilityLimitException(this.limit);
  final String limit;
  @override
  String toString() => 'AvailabilityLimitException: $limit exceeded';
}

final class _Boundary {
  const _Boundary(this.instant, this.kind, this.delta);
  final DateTime instant;
  final AvailabilityKind kind;
  final int delta;
}

/// Partition a complete query into clipped, merged native classifications.
/// Inputs are booking intervals, never incomplete/unknown coverage or rules.
List<AvailabilityInterval> partitionFreeBusy({
  required UtcWindow window,
  required List<AvailabilityInterval> bookings,
  required bool fallbackUnavailable,
  required int maxInputIntervals,
  required int maxOutputIntervals,
}) {
  RangeError.checkValueInInterval(
    maxInputIntervals,
    1,
    9007199254740991,
    'maxInputIntervals',
  );
  RangeError.checkValueInInterval(
    maxOutputIntervals,
    1,
    9007199254740991,
    'maxOutputIntervals',
  );
  if (bookings.length > maxInputIntervals) {
    throw const AvailabilityLimitException('maxInputIntervals');
  }
  final boundaries = [
    _Boundary(window.start, AvailabilityKind.free, 0),
    _Boundary(window.end, AvailabilityKind.free, 0),
  ];
  for (final input in bookings) {
    if (input.kind == AvailabilityKind.free) {
      throw ArgumentError('Free input cannot erase bookings');
    }
    final clipped = window.intersection(input.window);
    if (clipped == null) continue;
    boundaries.add(_Boundary(clipped.start, input.kind, 1));
    boundaries.add(_Boundary(clipped.end, input.kind, -1));
  }
  boundaries.sort((a, b) => a.instant.compareTo(b.instant));
  final counts = List.filled(AvailabilityKind.values.length, 0);
  if (fallbackUnavailable) counts[AvailabilityKind.unavailable.index] = 1;
  final result = <AvailabilityInterval>[];
  var index = 0;
  while (index < boundaries.length) {
    final time = boundaries[index].instant;
    while (index < boundaries.length && boundaries[index].instant == time) {
      final b = boundaries[index++];
      counts[b.kind.index] += b.delta;
    }
    if (index == boundaries.length) break;
    final next = boundaries[index].instant;
    var kind = AvailabilityKind.free;
    for (final candidate in AvailabilityKind.values.reversed) {
      if (counts[candidate.index] > 0) {
        kind = candidate;
        break;
      }
    }
    if (result.isNotEmpty &&
        result.last.kind == kind &&
        result.last.window.end == time) {
      final previous = result.removeLast();
      result.add(
        AvailabilityInterval(
          window: UtcWindow(start: previous.window.start, end: next),
          kind: kind,
        ),
      );
    } else {
      if (result.length >= maxOutputIntervals) {
        throw const AvailabilityLimitException('maxOutputIntervals');
      }
      result.add(
        AvailabilityInterval(
          window: UtcWindow(start: time, end: next),
          kind: kind,
        ),
      );
    }
  }
  return List.unmodifiable(result);
}
