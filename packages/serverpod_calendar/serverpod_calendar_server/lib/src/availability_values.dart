import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_values.dart';
import 'generated/protocol.dart';

const availabilityMaxDefinitions = 64;
const availabilityMaxOpenings = 16;

/// A bound is a start-only UTC or named-zone civil value. The special 2100
/// midnight is permitted only for the exclusive upper bound.
DateTime? availabilityBound(CalendarEventTiming? value, {bool end = false}) {
  if (value == null) return null;
  if (value.kind != CalendarEventTimeKind.utc &&
      value.kind != CalendarEventTimeKind.zoned) {
    throw ArgumentError('Availability requires UTC or named-zone DATE-TIME');
  }
  if (value.end != null || value.duration != null) {
    throw ArgumentError('Validity bounds must be individual values');
  }
  if (!end || value.start.year != 2100) {
    return validateEventTiming(value).$2!.start.instant;
  }
  final span = validateEventTiming(
    CalendarEventTiming(
      kind: value.kind,
      zoneId: value.zoneId,
      start: CalendarEventCivil(year: 1970, month: 1, day: 1),
      end: value.start,
    ),
  ).$2!;
  return span.resolved.endExclusive;
}

CalendarAvailabilityContent validateAvailabilityContent(
  CalendarAvailabilityContent input,
) {
  if (input.summary != null) {
    validateCalendarPlainText(input.summary!, maxCodePoints: 4096);
  }
  RangeError.checkValueInInterval(input.priority, 0, 9, 'priority');
  if (input.closedKind == CalendarFreeBusyKind.free) {
    throw ArgumentError('Closed-time type cannot be free');
  }
  if (input.openings.length > availabilityMaxOpenings) {
    throw const AvailabilityLimitException('maxOpeningsPerDefinition');
  }
  final start = availabilityBound(input.validFrom);
  final end = availabilityBound(input.validUntil, end: true);
  if (start != null && end != null && !start.isBefore(end)) {
    throw ArgumentError('Validity end must follow start');
  }
  final uids = <Object>{};
  final openings = <CalendarAvailabilityOpening>[];
  for (final opening in input.openings) {
    if (opening.uid != null && !uids.add(opening.uid!)) {
      throw ArgumentError('Duplicate opening identity');
    }
    final t = opening.timing;
    if (t.kind != CalendarEventTimeKind.utc &&
        t.kind != CalendarEventTimeKind.zoned) {
      throw ArgumentError('Openings require UTC or named-zone DATE-TIME');
    }
    final span = validateEventTiming(t).$2!;
    if (span.isPoint) {
      throw ArgumentError('An opening must have positive duration');
    }
    openings.add(
      opening.copyWith(
        recurrence: validateEventRecurrence(t, opening.recurrence),
      ),
    );
  }
  return input.copyWith(openings: List.unmodifiable(openings));
}

/// Bounded native adapter. Event transport types are shared timing structures;
/// status, transparency, attendees and event authorization never enter rules.
AvailabilityDefinition evaluateAvailability(
  CalendarAvailabilityContent input,
  UtcWindow window,
) {
  final start = availabilityBound(input.validFrom);
  final end = availabilityBound(input.validUntil, end: true);
  final from = start != null && start.isAfter(window.start)
      ? start
      : window.start;
  final until = end != null && end.isBefore(window.end) ? end : window.end;
  final openings = <UtcWindow>[];
  if (from.isBefore(until)) {
    final clipped = UtcWindow(start: from, end: until);
    for (final opening in input.openings) {
      openings.addAll(
        eventOccupiedWindows(
          CalendarEventContent(
            timing: opening.timing,
            recurrence: opening.recurrence,
          ),
          null,
          clipped,
          dateZone: 'UTC',
        ),
      );
      if (openings.length > 5000) {
        throw const AvailabilityLimitException('maxProjectedOpenings');
      }
    }
  }
  return AvailabilityDefinition(
    start: start,
    end: end,
    priority: input.priority,
    closedKind: AvailabilityKind.values.byName(input.closedKind.name),
    openings: openings,
  );
}
