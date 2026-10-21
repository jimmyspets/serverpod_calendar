import 'free_busy.dart';
import 'utc_window.dart';

/// Combine complete partitions. Free time is the intersection, blocking native
/// classifications retain their precedence. Empty/incomplete sources reject.
List<AvailabilityInterval> combineCompleteAvailability({
  required UtcWindow window,
  required List<List<AvailabilityInterval>> sources,
  required int maxSources,
  required int maxInputIntervals,
  required int maxOutputIntervals,
}) {
  RangeError.checkValueInInterval(
    maxSources,
    1,
    9007199254740991,
    'maxSources',
  );
  if (sources.isEmpty) {
    throw ArgumentError('No sources cannot establish free time');
  }
  if (sources.length > maxSources) {
    throw const AvailabilityLimitException('maxSources');
  }
  var count = 0;
  final blocking = <AvailabilityInterval>[];
  for (final source in sources) {
    count += source.length;
    if (count > maxInputIntervals) {
      throw const AvailabilityLimitException('maxInputIntervals');
    }
    var expected = window.start;
    for (final period in source) {
      if (period.window.start != expected ||
          period.window.end.isAfter(window.end)) {
        throw ArgumentError(
          'Sources must partition the whole query without gaps/overlaps',
        );
      }
      expected = period.window.end;
      if (period.kind != AvailabilityKind.free) blocking.add(period);
    }
    if (expected != window.end) {
      throw ArgumentError('Incomplete source coverage');
    }
  }
  return partitionFreeBusy(
    window: window,
    bookings: blocking,
    fallbackUnavailable: false,
    maxInputIntervals: maxInputIntervals,
    maxOutputIntervals: maxOutputIntervals,
  );
}

/// Filter maximal free intervals using exact elapsed seconds, after merging.
List<UtcWindow> freeAvailabilityWindows(
  List<AvailabilityInterval> partition, {
  required int minimumSeconds,
}) {
  RangeError.checkValueInInterval(minimumSeconds, 1, 2678400, 'minimumSeconds');
  return List.unmodifiable([
    for (final period in partition)
      if (period.kind == AvailabilityKind.free &&
          period.window.elapsedMicroseconds >=
              BigInt.from(minimumSeconds) * BigInt.from(1000000))
        period.window,
  ]);
}
