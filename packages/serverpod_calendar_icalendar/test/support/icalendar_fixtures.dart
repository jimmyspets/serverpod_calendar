import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

String event({
  String uid = 'synthetic@example.invalid',
  String timing = 'DTSTART:20261022T120000Z',
  List<String> extra = const [],
}) => [
  'BEGIN:VEVENT',
  'UID:$uid',
  'DTSTAMP:20261022T100000Z',
  timing,
  ...extra,
  'END:VEVENT',
].join('\r\n');
String file({
  List<String>? events,
  List<String> zones = const [],
  List<String> envelope = const [],
}) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:-//Synthetic calendar tests//EN',
  ...envelope,
  ...zones,
  ...(events ?? [event()]),
  'END:VCALENDAR',
  '',
].join('\r\n');
IcalendarEventCalendar load(
  String text, {
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => parseIcalendarEventCalendar(utf8.encode(text), limits: limits);

String fixedZone({
  String id = 'UTC',
  String offset = '+0000',
  String seed = '19000101T000000',
  List<String> extra = const [],
}) => [
  'BEGIN:VTIMEZONE',
  'TZID:$id',
  'BEGIN:STANDARD',
  'DTSTART:$seed',
  'TZOFFSETFROM:$offset',
  'TZOFFSETTO:$offset',
  ...extra,
  'END:STANDARD',
  'END:VTIMEZONE',
].join('\r\n');
String _stamp(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}${_two(value.month)}${_two(value.day)}T${_two(value.hour)}${_two(value.minute)}${_two(value.second)}';
String _two(int value) => value.toString().padLeft(2, '0');
String _offset(Duration value) {
  final n = value.inSeconds.abs();
  return '${value.isNegative ? '-' : '+'}${_two(n ~/ 3600)}${_two(n ~/ 60 % 60)}${_two(n % 60)}';
}

// Synthetic explicit transition definition from an independent core snapshot.
// The separate New York historical/yearly fixture below tests wire expansion.
String explicitZone(String id) {
  final snapshot = NamedZoneResolver().calendarProfileSnapshot(
    zoneId: id,
    maxTransitions: 8192,
  );
  final rows = <String>[
    'BEGIN:VTIMEZONE',
    'TZID:$id',
    'BEGIN:STANDARD',
    'DTSTART:${_stamp(snapshot.horizon.start.subtract(const Duration(seconds: 1)).add(snapshot.initialOffset))}',
    'TZOFFSETFROM:${_offset(snapshot.initialOffset)}',
    'TZOFFSETTO:${_offset(snapshot.initialOffset)}',
    'END:STANDARD',
  ];
  var before = snapshot.initialOffset;
  final groups = <(Duration, Duration), List<DateTime>>{};
  for (final change in snapshot.changes) {
    groups
        .putIfAbsent((before, change.offset), () => [])
        .add(change.instant.add(before));
    before = change.offset;
  }
  for (final group in groups.entries) {
    rows.addAll([
      'BEGIN:STANDARD',
      'DTSTART:${_stamp(group.value.first)}',
      'TZOFFSETFROM:${_offset(group.key.$1)}',
      'TZOFFSETTO:${_offset(group.key.$2)}',
    ]);
    if (group.value.length > 1) {
      rows.add('RDATE:${group.value.skip(1).map(_stamp).join(',')}');
    }
    rows.add('END:STANDARD');
  }
  return [...rows, 'END:VTIMEZONE'].join('\r\n');
}

// Historical regimes and emergency 1974/75 onsets, independently described
// from RFC 5545 section 3.6.5 rather than derived from the pinned transitions.
String newYorkZone() {
  String obs(String seed, bool daylight, [String? rule]) => [
    'BEGIN:${daylight ? 'DAYLIGHT' : 'STANDARD'}',
    'DTSTART:$seed',
    'TZOFFSETFROM:${daylight ? '-0500' : '-0400'}',
    'TZOFFSETTO:${daylight ? '-0400' : '-0500'}',
    if (rule != null) 'RRULE:$rule',
    'END:${daylight ? 'DAYLIGHT' : 'STANDARD'}',
  ].join('\r\n');
  return [
    'BEGIN:VTIMEZONE',
    'TZID:America/New_York',
    obs(
      '19670430T020000',
      true,
      'FREQ=YEARLY;BYMONTH=4;BYDAY=-1SU;UNTIL=19730429T070000Z',
    ),
    obs('19740106T020000', true),
    obs('19750223T020000', true),
    obs(
      '19760425T020000',
      true,
      'FREQ=YEARLY;BYMONTH=4;BYDAY=-1SU;UNTIL=19860427T070000Z',
    ),
    obs(
      '19870405T020000',
      true,
      'FREQ=YEARLY;BYMONTH=4;BYDAY=1SU;UNTIL=20060402T070000Z',
    ),
    obs('20070311T020000', true, 'FREQ=YEARLY;BYMONTH=3;BYDAY=2SU'),
    obs(
      '19671029T020000',
      false,
      'FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU;UNTIL=20061029T060000Z',
    ),
    obs('20071104T020000', false, 'FREQ=YEARLY;BYMONTH=11;BYDAY=1SU'),
    'END:VTIMEZONE',
  ].join('\r\n');
}
