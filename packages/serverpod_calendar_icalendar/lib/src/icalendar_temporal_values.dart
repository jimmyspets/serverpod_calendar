import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

/// Diagnostics omit source text, zone identifiers and nested exception payloads.
enum IcalendarValueError {
  invalidSyntax,
  invalidValue,
  outsideProfile,
  invalidContext,
  floatingTime,
  unsupportedZone,
  zoneCoverage,
  limitExceeded,
}

final class IcalendarValueException implements Exception {
  const IcalendarValueException(this.kind);
  final IcalendarValueError kind;
  @override
  String toString() => 'IcalendarValueException(${kind.name})';
}

Never _fail(IcalendarValueError kind) => throw IcalendarValueException(kind);

bool _matches(RegExp pattern, String value) {
  final match = pattern.firstMatch(value);
  return match != null && match.start == 0 && match.end == value.length;
}

final _datePattern = RegExp(r'[0-9]{8}');
final _timePattern = RegExp(r'[0-9]{8}T[0-9]{6}Z?');
final _durationPattern = RegExp(
  r'([+-]?)P(?:(\d+)W|(\d+)D(?:T(?:(\d+)H(?:(\d+)M(?:(\d+)S)?)?|(\d+)M(?:(\d+)S)?|(\d+)S))?|T(?:(\d+)H(?:(\d+)M(?:(\d+)S)?)?|(\d+)M(?:(\d+)S)?|(\d+)S))',
);

/// Parses one basic-format DATE, without trimming, TEXT escapes or list syntax.
///
/// [exclusiveEnd] permits only the additional 2100-01-01 boundary. A component
/// adapter must enable it only for a property with exclusive-end semantics.
CalendarDate parseIcalendarDate(String value, {bool exclusiveEnd = false}) {
  if (value.length != 8 || !_matches(_datePattern, value)) {
    _fail(IcalendarValueError.invalidSyntax);
  }
  if (value == '21000101' && exclusiveEnd) {
    return const CalendarDate.exclusiveEnd();
  }
  final year = int.parse(value.substring(0, 4));
  if (year < 1970 || year >= 2100) {
    _fail(IcalendarValueError.outsideProfile);
  }
  try {
    return CalendarDate(
      year: year,
      month: int.parse(value.substring(4, 6)),
      day: int.parse(value.substring(6, 8)),
    );
  } on ArgumentError {
    _fail(IcalendarValueError.invalidValue);
  }
}

String serializeIcalendarDate(CalendarDate value, {bool exclusiveEnd = false}) {
  if (value.isExclusiveEnd && !exclusiveEnd) {
    _fail(IcalendarValueError.outsideProfile);
  }
  return '${value.year.toString().padLeft(4, '0')}'
      '${_two(value.month)}${_two(value.day)}';
}

/// Parses one whole-second UTC or explicitly named-zone DATE-TIME.
///
/// A trailing Z forbids [zoneId]; local fields require one. Exact pinned IANA
/// identifiers and explicit-time gap/fold rules come from the core resolver.
/// This does not validate VTIMEZONE or authorize import: component adapters
/// must independently validate the supplied zone definition/context.
TimedValue parseIcalendarDateTime(
  String value, {
  String? zoneId,
  bool exclusiveEnd = false,
}) {
  if ((value.length != 15 && value.length != 16) ||
      !_matches(_timePattern, value)) {
    _fail(IcalendarValueError.invalidSyntax);
  }
  final utc = value.endsWith('Z');
  if (utc && zoneId != null) _fail(IcalendarValueError.invalidContext);
  if (!utc && zoneId == null) _fail(IcalendarValueError.floatingTime);
  if (zoneId != null && zoneId.length > 255) {
    _fail(IcalendarValueError.limitExceeded);
  }
  final date = parseIcalendarDate(
    value.substring(0, 8),
    exclusiveEnd: exclusiveEnd,
  );
  late final CivilDateTime civil;
  try {
    civil = CivilDateTime(
      date: date,
      hour: int.parse(value.substring(9, 11)),
      minute: int.parse(value.substring(11, 13)),
      second: int.parse(value.substring(13, 15)),
    );
  } on ArgumentError {
    _fail(IcalendarValueError.invalidValue);
  }
  if (utc) {
    final instant = DateTime.utc(
      date.year,
      date.month,
      date.day,
      civil.hour,
      civil.minute,
      civil.second,
    );
    return exclusiveEnd ? TimedValue.utcEnd(instant) : TimedValue.utc(instant);
  }
  try {
    return exclusiveEnd
        ? TimedValue.zonedEnd(civil, zoneId: zoneId!)
        : TimedValue.zoned(civil, zoneId: zoneId!);
  } on ZoneCoverageException {
    _fail(IcalendarValueError.zoneCoverage);
  } on ArgumentError {
    _fail(IcalendarValueError.unsupportedZone);
  }
}

/// Emits requested wall fields; named-zone values require a separate exact TZID.
///
/// The caller must provide the approved zone definition/context. This is not a
/// complete property serializer or authorization/publication projection.
String serializeIcalendarDateTime(
  TimedValue value, {
  bool exclusiveEnd = false,
}) {
  final civil = value.civil;
  return '${serializeIcalendarDate(civil.date, exclusiveEnd: exclusiveEnd)}'
      'T${_two(civil.hour)}${_two(civil.minute)}${_two(civil.second)}'
      '${value.zoneId == null ? 'Z' : ''}';
}

/// Parses RFC 5545 duration grammar into unit-preserving core magnitudes.
///
/// Positive, negative and signed zero values are supported at the value layer.
/// Property positivity, date-only units and application bounds remain separate.
/// ISO year/month, fractional, week/day mixture and list forms are rejected.
CalendarDuration parseIcalendarDuration(String value) {
  // Enough for all five 16-digit core magnitudes plus designators/sign.
  if (value.length > 128) _fail(IcalendarValueError.limitExceeded);
  final match = _durationPattern.firstMatch(value);
  if (match == null || match.start != 0 || match.end != value.length) {
    _fail(IcalendarValueError.invalidSyntax);
  }
  int magnitude(List<int> groups) {
    for (final group in groups) {
      final text = match.group(group);
      if (text == null) continue;
      // Avoid browser rounding before the exact portable integer bound check.
      final number = BigInt.parse(text);
      if (number > BigInt.from(CalendarDuration.maxComponent)) {
        _fail(IcalendarValueError.outsideProfile);
      }
      return number.toInt();
    }
    return 0;
  }

  return CalendarDuration(
    sign: match.group(1) == '-' ? -1 : 1,
    weeks: magnitude([2]),
    days: magnitude([3]),
    hours: magnitude([4, 10]),
    minutes: magnitude([5, 7, 11, 13]),
    seconds: magnitude([6, 8, 9, 12, 14, 15]),
  );
}

/// Emits uppercase grammar without converting nominal days into elapsed hours.
///
/// Leading plus/zeroes and explicit zero-unit spelling are not retained.
/// Negative zero remains negative; zero magnitudes serialize as PT0S.
String serializeIcalendarDuration(CalendarDuration value) {
  final sign = value.sign < 0 ? '-' : '';
  if (value.isZero) return '${sign}PT0S';
  if (value.weeks != 0) return '${sign}P${value.weeks}W';
  final result = StringBuffer('${sign}P');
  if (value.days != 0) result.write('${value.days}D');
  if (value.hours != 0 || value.minutes != 0 || value.seconds != 0) {
    result.write('T');
    if (value.hours != 0) result.write('${value.hours}H');
    // RFC grammar requires M between H and S, including zero minutes.
    if (value.minutes != 0 || (value.hours != 0 && value.seconds != 0)) {
      result.write('${value.minutes}M');
    }
    if (value.seconds != 0) result.write('${value.seconds}S');
  }
  return result.toString();
}

String _two(int value) => value.toString().padLeft(2, '0');
