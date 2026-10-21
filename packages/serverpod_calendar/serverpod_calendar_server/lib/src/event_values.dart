import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'generated/protocol.dart';

/// Native DTO conversion only; temporal rules remain in the independent core.
(DateEventSpan?, TimedEventSpan?) validateEventTiming(CalendarEventTiming v) {
  CivilDateTime civil(CalendarEventCivil c, {bool end = false}) {
    final date = end && c.year == 2100 && c.month == 1 && c.day == 1
        ? const CalendarDate.exclusiveEnd()
        : CalendarDate(year: c.year, month: c.month, day: c.day);
    return CivilDateTime(
      date: date,
      hour: c.hour,
      minute: c.minute,
      second: c.second,
      microsecond: c.microsecond,
    );
  }

  final start = civil(v.start);
  final end = v.end == null ? null : civil(v.end!, end: true);
  final d = v.duration;
  final duration = d == null
      ? null
      : CalendarDuration(
          weeks: d.weeks,
          days: d.days,
          hours: d.hours,
          minutes: d.minutes,
          seconds: d.seconds,
          microsecond: d.microsecond,
        );
  if (v.kind != CalendarEventTimeKind.zoned && v.zoneId != null) {
    throw ArgumentError('Only named-zone timing accepts a zone');
  }
  if (v.kind == CalendarEventTimeKind.date) {
    for (final c in [start, ?end]) {
      if (c.hour != 0 || c.minute != 0 || c.second != 0) {
        throw ArgumentError('DATE has no clock time');
      }
    }
    return (
      DateEventSpan(start: start.date, end: end?.date, duration: duration),
      null,
    );
  }
  if (v.kind == CalendarEventTimeKind.floating) {
    throw ArgumentError('Floating timing is unsupported');
  }
  TimedValue timed(CivilDateTime c, {bool finish = false}) {
    if (v.kind == CalendarEventTimeKind.utc) {
      final utc = DateTime.utc(
        c.date.year,
        c.date.month,
        c.date.day,
        c.hour,
        c.minute,
        c.second,
      );
      return finish ? TimedValue.utcEnd(utc) : TimedValue.utc(utc);
    }
    final zone = v.zoneId;
    if (zone == null || zone.isEmpty || zone.length > 255) {
      throw ArgumentError('Named zone required');
    }
    return finish
        ? TimedValue.zonedEnd(c, zoneId: zone)
        : TimedValue.zoned(c, zoneId: zone);
  }

  return (
    null,
    TimedEventSpan(
      start: timed(start),
      end: end == null ? null : timed(end, finish: true),
      duration: duration,
    ),
  );
}

CalendarEventContent validateEventContent(CalendarEventContent value) {
  if (value.recurring) {
    throw ArgumentError('Recurring event storage is not implemented');
  }
  if (value.summary != null) {
    validateCalendarPlainText(value.summary!, maxCodePoints: 4096);
  }
  if (value.description != null) {
    validateCalendarPlainText(value.description!, maxCodePoints: 16384);
  }
  if (value.location != null) {
    validateCalendarPlainText(value.location!, maxCodePoints: 4096);
  }
  validateEventTiming(value.timing);
  return value;
}
