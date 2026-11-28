import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'generated/protocol.dart';

CalendarDuration alarmDuration(CalendarAlarmDuration value) => CalendarDuration(
  sign: value.sign,
  weeks: value.weeks,
  days: value.days,
  hours: value.hours,
  minutes: value.minutes,
  seconds: value.seconds,
);

CalendarAlarmDefinition validateAlarmDefinition(CalendarAlarmDefinition value) {
  final relative = value.relativeDuration;
  if ((relative == null) == (value.absoluteUtc == null)) {
    throw ArgumentError('Exactly one alarm trigger is required');
  }
  if (relative == null) {
    TimedValue.utc(value.absoluteUtc!);
    if (value.anchor != null || value.dateZoneId != null) {
      throw ArgumentError('Absolute trigger has no relative anchor or zone');
    }
  } else {
    _boundedAlarmDuration(relative);
    if (value.anchor == null) throw ArgumentError('Relative anchor required');
    final zone = value.dateZoneId;
    if (zone != null &&
        (zone.length > 255 || !NamedZoneResolver().zoneIds.contains(zone))) {
      throw ArgumentError('Exact named zone required');
    }
  }
  if ((value.repeat == null) != (value.repeatInterval == null)) {
    throw ArgumentError('Repeat count and interval must be paired');
  }
  if (value.repeat != null) {
    RangeError.checkValueInInterval(value.repeat!, 0, 100, 'repeat');
    final d = alarmDuration(value.repeatInterval!);
    if (d.sign < 0 || d.isZero) {
      throw ArgumentError('Positive repeat interval required');
    }
    _boundedAlarmDuration(value.repeatInterval!, multiplier: value.repeat!);
  }
  return value;
}

void _boundedAlarmDuration(CalendarAlarmDuration value, {int multiplier = 1}) {
  alarmDuration(value);
  // Check the weighted aggregate exactly before any narrowing or multiplication.
  final seconds =
      BigInt.from(value.weeks) * BigInt.from(604800) +
      BigInt.from(value.days) * BigInt.from(86400) +
      BigInt.from(value.hours) * BigInt.from(3600) +
      BigInt.from(value.minutes) * BigInt.from(60) +
      BigInt.from(value.seconds);
  final bound = BigInt.from(366 * 86400);
  if (seconds > bound || seconds * BigInt.from(multiplier) > bound) {
    throw ArgumentError('Alarm duration exceeds supported bound');
  }
}

/// Compatibility of the current master anchor, not readiness for delivery.
/// Planning must validate every effective occurrence and the calculated instant.
bool alarmEventAnchorCompatible(
  CalendarAlarmDefinition definition,
  CalendarEventTiming timing,
) {
  if (definition.absoluteUtc != null) return true;
  if (timing.kind == CalendarEventTimeKind.date &&
      definition.dateZoneId == null) {
    return false;
  }
  return definition.anchor == CalendarAlarmAnchor.start ||
      timing.end != null ||
      timing.duration != null;
}

bool alarmTaskAnchorCompatible(
  CalendarAlarmDefinition definition,
  CalendarTaskTiming timing,
) {
  if (definition.absoluteUtc != null) return true;
  if (timing.kind == CalendarTaskTimeKind.undated) return false;
  if (timing.kind == CalendarTaskTimeKind.date &&
      definition.dateZoneId == null) {
    return false;
  }
  return definition.anchor == CalendarAlarmAnchor.start
      ? timing.start != null
      : timing.due != null || timing.duration != null;
}
