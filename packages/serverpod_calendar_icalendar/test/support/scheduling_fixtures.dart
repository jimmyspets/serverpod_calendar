import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

const organizer = 'ORGANIZER:mailto:organizer@example.invalid';
const attendee = 'ATTENDEE;PARTSTAT=ACCEPTED:mailto:guest@example.invalid';
const start = 'DTSTART:20261022T120000Z';
const stamp = 'DTSTAMP:20261022T100000Z';
const uid = 'UID:synthetic-scheduling@example.invalid';

String message(
  String method,
  List<String> fields, {
  List<String> zones = const [],
  List<String> envelope = const [],
  List<String> components = const [],
}) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:-//Synthetic scheduling//EN',
  'METHOD:$method',
  ...envelope,
  ...zones,
  'BEGIN:VEVENT',
  ...fields,
  'END:VEVENT',
  ...components,
  'END:VCALENDAR',
  '',
].join('\r\n');
List<String> minimal(String method) => [
  uid,
  stamp,
  organizer,
  if (method == 'PUBLISH' || method == 'REQUEST') ...[start, 'SUMMARY:'],
  if (method == 'REQUEST' || method == 'REPLY') attendee,
  if (method == 'CANCEL') ...['SEQUENCE:2', 'STATUS:CANCELLED'],
];
IcalendarSchedulingMessage load(
  String source, {
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
}) => parseIcalendarSchedulingMessage(utf8.encode(source), limits: limits);
Matcher rejects([IcalendarComponentError? kind]) => throwsA(
  isA<IcalendarComponentException>().having(
    (e) => kind == null || e.kind == kind,
    'expected error',
    true,
  ),
);
