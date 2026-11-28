import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

/// Show source civil fields without device-zone conversion or invented ends.
String invitationTimingLabel(cal.CalendarEventTiming value) {
  final date = value.kind == cal.CalendarEventTimeKind.date;
  String two(int n) => n.toString().padLeft(2, '0');
  String civil(cal.CalendarEventCivil c) =>
      '${c.year.toString().padLeft(4, '0')}-${two(c.month)}-${two(c.day)}${date ? '' : ' ${two(c.hour)}:${two(c.minute)}:${two(c.second)}'}';
  final profile = date
      ? 'DATE'
      : value.kind == cal.CalendarEventTimeKind.utc
      ? 'UTC'
      : value.zoneId!;
  final d = value.duration;
  final end = value.end != null
      ? 'DTEND${date ? ' (exclusive)' : ''}: ${civil(value.end!)}'
      : d != null
      ? 'DURATION: ${d.weeks}w ${d.days}d ${d.hours}h ${d.minutes}m ${d.seconds}s'
      : 'DTEND/DURATION omitted';
  return '${civil(value.start)} [$profile]; $end';
}
