import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'icalendar_fixtures.dart';

String opening({
  String uid = 'opening',
  String timing = 'DTSTART:20261022T090000Z',
  List<String> extra = const [],
}) => [
  'BEGIN:AVAILABLE',
  'UID:$uid',
  'DTSTAMP:20261022T000000Z',
  timing,
  ...extra,
  'END:AVAILABLE',
].join('\r\n');
String definition({
  String uid = 'definition',
  List<String> extra = const [],
  List<String> openings = const [],
}) => [
  'BEGIN:VAVAILABILITY',
  'UID:$uid',
  'DTSTAMP:20261022T000000Z',
  ...extra,
  ...openings,
  'END:VAVAILABILITY',
].join('\r\n');
IcalendarAvailabilityCalendar read(
  List<String> definitions, {
  List<String> zones = const [],
  IcalendarComponentLimits limits = const IcalendarComponentLimits(),
  IcalendarAvailabilityExtensionRegistry? extensions,
}) => parseIcalendarAvailabilityCalendar(
  utf8.encode(file(events: definitions, zones: zones)),
  limits: limits,
  extensions: extensions,
);
UtcWindow get window => UtcWindow(
  start: DateTime.utc(2026, 10, 22),
  end: DateTime.utc(2026, 10, 23),
);
List<AvailabilityDefinition> expand(
  IcalendarAvailabilityCalendar c, {
  UtcWindow? period,
  int work = 200000,
  int count = 1000,
}) => c.expand(
  window: period ?? window,
  maxCandidateWork: work,
  maxRuleOccurrences: 10000,
  maxBaseOccurrences: 10000,
  maxOccurrences: count,
);
List<AvailabilityInterval> compose(
  IcalendarAvailabilityCalendar c, {
  bool fallback = false,
}) => composeAvailability(
  window: window,
  definitions: expand(c),
  fallbackUnavailable: fallback,
  maxDefinitions: 64,
  maxOpenings: 1000,
  maxOutputIntervals: 1000,
);
