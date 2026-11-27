import 'free_busy.dart';
import 'utc_window.dart';

/// One fully evaluated RFC 7953 envelope. Bounds are optional; openings have
/// already undergone bounded recurrence expansion. No unknown coverage allowed.
final class AvailabilityDefinition {
  AvailabilityDefinition({
    this.start,
    this.end,
    this.priority = 0,
    this.closedKind = AvailabilityKind.unavailable,
    required Iterable<UtcWindow> openings,
  }) : openings = List.unmodifiable(openings) {
    RangeError.checkValueInInterval(priority, 0, 9, 'priority');
    for (final bound in [start, end]) {
      if (bound != null && !bound.isUtc) {
        throw ArgumentError('Availability bounds must be UTC');
      }
    }
    if (start != null && end != null && !start!.isBefore(end!)) {
      throw ArgumentError('Availability end must follow start');
    }
    if (closedKind == AvailabilityKind.free) {
      throw ArgumentError('BUSYTYPE cannot be free');
    }
  }
  final DateTime? start, end;
  final int priority;
  final AvailabilityKind closedKind;
  final List<UtcWindow> openings;
}

/// RFC 7953 sections 4–5, evaluated per elementary interval. Highest effective
/// priority wins (1 through 9, then 0). Equal-priority openings form a union;
/// closed-time precedence is BUSY > BUSY-UNAVAILABLE > BUSY-TENTATIVE.
/// The host's fallback applies only where no definition is effective.
List<AvailabilityInterval> composeAvailability({
  required UtcWindow window,
  required List<AvailabilityDefinition> definitions,
  required bool fallbackUnavailable,
  required int maxDefinitions,
  required int maxOpenings,
  required int maxOutputIntervals,
}) {
  for (final limit in [maxDefinitions, maxOpenings, maxOutputIntervals]) {
    RangeError.checkValueInInterval(limit, 1, 9007199254740991, 'limit');
  }
  if (definitions.length > maxDefinitions) {
    throw const AvailabilityLimitException('maxDefinitions');
  }
  var openingCount = 0;
  final points = <DateTime>{window.start, window.end};
  final effective = <(AvailabilityDefinition, UtcWindow, List<UtcWindow>)>[];
  for (final d in definitions) {
    openingCount += d.openings.length;
    if (openingCount > maxOpenings) {
      throw const AvailabilityLimitException('maxOpenings');
    }
    final start = d.start == null || d.start!.isBefore(window.start)
        ? window.start
        : d.start!;
    final end = d.end == null || d.end!.isAfter(window.end)
        ? window.end
        : d.end!;
    if (!start.isBefore(end)) continue;
    final range = UtcWindow(start: start, end: end);
    final openings = <UtcWindow>[];
    points.addAll([start, end]);
    for (final opening in d.openings) {
      final clipped = range.intersection(opening);
      if (clipped == null) continue;
      openings.add(clipped);
      points.addAll([clipped.start, clipped.end]);
    }
    openings.sort((a, b) => a.start.compareTo(b.start));
    final merged = <UtcWindow>[];
    for (final opening in openings) {
      if (merged.isNotEmpty && !opening.start.isAfter(merged.last.end)) {
        final last = merged.removeLast();
        merged.add(
          UtcWindow(
            start: last.start,
            end: opening.end.isAfter(last.end) ? opening.end : last.end,
          ),
        );
      } else {
        merged.add(opening);
      }
    }
    effective.add((d, range, merged));
  }
  final ordered = points.toList()..sort();
  final result = <AvailabilityInterval>[];
  for (var i = 0; i < ordered.length - 1; i++) {
    final time = ordered[i];
    var priority = 11;
    var kind = fallbackUnavailable
        ? AvailabilityKind.unavailable
        : AvailabilityKind.free;
    var open = false;
    var closedRank = -1;
    for (final (d, range, openings) in effective) {
      if (!range.contains(time)) continue;
      final rank = d.priority == 0 ? 10 : d.priority;
      if (rank > priority) continue;
      if (rank < priority) {
        priority = rank;
        open = false;
        closedRank = -1;
      }
      var low = 0;
      var high = openings.length;
      while (low < high) {
        final middle = (low + high) ~/ 2;
        if (!openings[middle].start.isAfter(time)) {
          low = middle + 1;
        } else {
          high = middle;
        }
      }
      if (low > 0 && time.isBefore(openings[low - 1].end)) open = true;
      final busyRank = switch (d.closedKind) {
        AvailabilityKind.busy => 3,
        AvailabilityKind.unavailable => 2,
        AvailabilityKind.tentative => 1,
        AvailabilityKind.free => throw StateError('Invalid BUSYTYPE'),
      };
      if (busyRank > closedRank) {
        closedRank = busyRank;
        kind = d.closedKind;
      }
    }
    if (open) kind = AvailabilityKind.free;
    final next = ordered[i + 1];
    if (result.isNotEmpty && result.last.kind == kind) {
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
