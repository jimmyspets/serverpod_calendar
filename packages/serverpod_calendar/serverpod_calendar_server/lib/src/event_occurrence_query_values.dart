part of 'event_values.dart';

/// Query-local pure calculation cache; never caches permission decisions.
final class EventOccurrenceQueryWork {
  EventOccurrenceQueryWork({required int maxWork, required this.maxResults})
    : recurrence = RecurrenceWorkBudget(maxWork: maxWork) {
    if (maxResults < 1 || maxResults > 10000) {
      throw ArgumentError('Invalid occurrence materialization limit');
    }
  }
  final RecurrenceWorkBudget recurrence;
  final int maxResults;
  int _materialized = 0;
  final _dateCoverage = <(String, UtcWindow)>{};
  void materialize() {
    if (++_materialized > maxResults) {
      throw const RecurrenceLimitException('aggregateOccurrences');
    }
  }

  void proveDateWindow(String zone, UtcWindow span) {
    if (_dateCoverage.contains((zone, span))) return;
    NamedZoneResolver().snapshot(
      zoneId: zone,
      horizon: span,
      maxTransitions: recurrence.maxWork,
      sharedWorkBudget: recurrence,
    );
    _dateCoverage.add((zone, span));
  }
}

final class EventOccurrenceWindowProjection {
  const EventOccurrenceWindowProjection(
    this.occurrence,
    this.orderStart,
    this.originalKey,
    this.cancelled,
  );
  final CalendarEventOccurrence occurrence;
  final DateTime orderStart;
  final String originalKey;
  final bool cancelled;
}

String eventOccurrenceQueryKey(CalendarEventTiming original) => jsonEncode([
  original.kind.name,
  original.zoneId,
  _anchorKey(original),
]);

/// Complete read projection from already validated native state. Retained
/// cancellations are materialized only for this detail view, without editing
/// canonical state or producing scheduling/export components.
List<EventOccurrenceWindowProjection> eventOccurrenceWindow(
  CalendarEventContent content,
  CalendarEventTimingOverrides? overrides,
  UtcWindow window, {
  required String dateZone,
  required Set<CalendarEventFieldGroup> groups,
  required EventOccurrenceQueryWork work,
}) {
  final cancelled = {
    for (final own in overrides?.singles ?? <CalendarEventSingleOverride>[])
      if (own.cancelled) _anchorKey(own.originalStart),
  };
  final projection = overrides?.copyWith(
    singles: List.unmodifiable([
      for (final own in overrides.singles) own.copyWith(cancelled: false),
    ]),
  );
  final result = <EventOccurrenceWindowProjection>[];
  bool overlaps(DateTime start, DateTime end) => start == end
      ? !start.isBefore(window.start) && start.isBefore(window.end)
      : start.isBefore(window.end) && end.isAfter(window.start);
  void add(CalendarEventOccurrence row, DateTime start) {
    work.materialize();
    final original = CalendarEventTiming(
      kind: content.timing.kind,
      zoneId: content.timing.zoneId,
      start: row.originalStart,
    );
    final own = eventOriginalContent(overrides, original);
    result.add(
      EventOccurrenceWindowProjection(
        row.copyWith(
          content: eventDisclosedOccurrenceContent(
            eventEffectiveOccurrenceContent(content, own),
            groups,
          ),
          contentOverrides: eventDisclosedOccurrenceContent(own, groups),
        ),
        start,
        eventOccurrenceQueryKey(original),
        content.status == CalendarEventStatus.cancelled ||
            cancelled.contains(_anchorKey(original)),
      ),
    );
  }

  if (content.timing.kind == CalendarEventTimeKind.date) {
    final resolver = NamedZoneResolver();
    final high = resolver.maximumOffset(zoneId: dateZone);
    final low = high - resolver.offsetRange(zoneId: dateZone);
    final rawFirst = window.start.add(low);
    final rawLast = window.end.subtract(const Duration(seconds: 1)).add(high);
    final first = DateTime.utc(rawFirst.year, rawFirst.month, rawFirst.day);
    final last = DateTime.utc(
      rawLast.year,
      rawLast.month,
      rawLast.day,
    ).add(const Duration(days: 1));
    final minimum = DateTime.utc(1970), maximum = DateTime.utc(2100);
    final begin = first.isBefore(minimum) ? minimum : first;
    final end = last.isAfter(maximum) ? maximum : last;
    if (!begin.isBefore(end)) return const [];
    final from = CalendarDate(
      year: begin.year,
      month: begin.month,
      day: begin.day,
    );
    final until = end == maximum
        ? const CalendarDate.exclusiveEnd()
        : CalendarDate(year: end.year, month: end.month, day: end.day);
    for (final value
        in _dateOverrides(
          content,
          projection,
          sharedWorkBudget: work.recurrence,
        ).expandOverlapping(
          from: from,
          until: until,
          maxCandidateDays: 100000,
          maxRuleOccurrences: 100000,
          maxBaseOccurrences: 100000,
          maxResults: 10001,
          sharedWorkBudget: work.recurrence,
        )) {
      work.recurrence.charge();
      final span = value.span.occupiedWindowIn(zoneId: dateZone);
      if (span == null || !overlaps(span.start, span.end)) continue;
      work.proveDateWindow(dateZone, span);
      add(
        CalendarEventOccurrence(
          originalStart: eventDate(value.originalStart),
          start: eventDate(value.span.start),
          endDate: eventDate(value.span.endExclusive),
        ),
        span.start,
      );
    }
  } else {
    for (final value
        in _timedOverrides(
          content,
          projection,
          sharedWorkBudget: work.recurrence,
        ).expandOverlapping(
          window: window,
          maxCandidateWork: 100000,
          maxRuleOccurrences: 100000,
          maxBaseOccurrences: 100000,
          maxResults: 10001,
          sharedWorkBudget: work.recurrence,
        )) {
      work.recurrence.charge();
      if (!overlaps(value.span.start, value.span.endExclusive)) continue;
      add(
        CalendarEventOccurrence(
          originalStart: eventCivil(value.originalStart.civil),
          start: eventCivil(value.actualStart.civil),
          startUtc: value.span.start,
          endUtc: value.span.endExclusive,
        ),
        value.span.start,
      );
    }
  }
  return List.unmodifiable(result);
}
