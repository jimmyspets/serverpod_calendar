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

AlarmTiming alarmTiming(CalendarAlarmDefinition value) {
  final relative = value.relativeDuration;
  final interval = value.repeatInterval == null
      ? null
      : alarmDuration(value.repeatInterval!);
  if ((relative == null) == (value.absoluteUtc == null)) {
    throw ArgumentError('Exactly one alarm trigger is required');
  }
  if (relative == null) {
    if (value.anchor != null || value.dateZoneId != null) {
      throw ArgumentError('Absolute trigger has no relative anchor or zone');
    }
    return AlarmTiming.absolute(
      utc: value.absoluteUtc!,
      repeat: value.repeat,
      repeatInterval: interval,
    );
  }
  if (value.anchor == null) throw ArgumentError('Relative anchor required');
  return AlarmTiming.relative(
    offset: alarmDuration(relative),
    anchor: value.anchor == CalendarAlarmAnchor.start
        ? AlarmAnchor.start
        : AlarmAnchor.end,
    dateZoneId: value.dateZoneId,
    repeat: value.repeat,
    repeatInterval: interval,
  );
}

CalendarAlarmDefinition validateAlarmDefinition(CalendarAlarmDefinition value) {
  alarmTiming(value);
  return value;
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

/// Conservative inverse trigger bounds. Unit/day arithmetic may change offsets;
/// two days cover the difference between supported offsets smaller than a day.
UtcWindow alarmAnchorWindow(
  AlarmTiming timing,
  UtcWindow target, {
  Duration endLookback = Duration.zero,
}) {
  int seconds(CalendarDuration? d) => d == null
      ? 0
      : d.sign *
            (d.weeks * 604800 +
                d.days * 86400 +
                d.hours * 3600 +
                d.minutes * 60 +
                d.seconds);
  final offset = seconds(timing.offset);
  final repeats = seconds(timing.repeatInterval) * (timing.repeat ?? 0);
  final calendarUnits = [
    timing.offset,
    timing.repeatInterval,
  ].any((d) => d != null && (d.weeks != 0 || d.days != 0));
  final padding = calendarUnits
      ? const Duration(days: 2)
      : const Duration(seconds: 1);
  var from = target.start
      .subtract(Duration(seconds: offset + repeats))
      .subtract(padding)
      .subtract(endLookback);
  var until = target.end.subtract(Duration(seconds: offset)).add(padding);
  final first = DateTime.utc(1970), last = DateTime.utc(2100);
  if (from.isBefore(first)) from = first;
  if (until.isAfter(last)) until = last;
  if (!from.isBefore(until)) {
    throw ArgumentError('Alarm anchors outside supported profile');
  }
  return UtcWindow(start: from, end: until);
}
