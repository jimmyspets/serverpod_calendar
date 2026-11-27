import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'icalendar_component_support.dart';
import 'icalendar_syntax.dart';
import 'calendar_text_metadata.dart';

/// Fully matched finite offset evidence, retaining the accepted source syntax.
final class IcalendarValidatedTimeZone {
  IcalendarValidatedTimeZone._(this.source, this.snapshot);
  final IcalendarSyntaxComponent source;
  final ZoneRulesSnapshot snapshot;
  String get zoneId => snapshot.zoneId;
  String get dataVersion => snapshot.dataVersion!;
}

/// Internal component adapter entry; the enclosing calendar validates syntax.
IcalendarValidatedTimeZone validateComponentTimeZone(
  IcalendarSyntaxComponent source,
  ComponentBudget budget,
) {
  if (source.canonicalName != 'VTIMEZONE') {
    componentFail(IcalendarComponentError.unsupportedComponent);
  }
  final properties = componentProperties(source, {
    'TZID',
    'LAST-MODIFIED',
    'TZURL',
  });
  final id = componentText(
    requiredProperty(properties, 'TZID'),
    maxPoints: 255,
  );
  if (id.isEmpty) componentFail(IcalendarComponentError.invalidValue);
  final modified = properties['LAST-MODIFIED'];
  if (modified != null) componentUtc(modified.single);
  final url = properties['TZURL'];
  if (url != null) {
    componentParameters(url.single, {});
    componentUri(url.single.value);
  }
  final expected = NamedZoneResolver().calendarProfileSnapshot(
    zoneId: id,
    maxTransitions: budget.limits.maxOnsets,
  );
  final onsets = <_Onset>[];
  for (final observance
      in source.entries.whereType<IcalendarSyntaxComponent>()) {
    budget.observance();
    if (!{'STANDARD', 'DAYLIGHT'}.contains(observance.canonicalName)) {
      componentFail(IcalendarComponentError.unsupportedComponent);
    }
    if (observance.entries.any((e) => e is IcalendarSyntaxComponent)) {
      componentFail(IcalendarComponentError.unsupportedComponent);
    }
    final p = componentProperties(
      observance,
      {
        'DTSTART',
        'TZOFFSETFROM',
        'TZOFFSETTO',
        'RRULE',
        'RDATE',
        'TZNAME',
        'COMMENT',
      },
      repeated: {'RDATE', 'TZNAME', 'COMMENT'},
    );
    final startProperty = requiredProperty(p, 'DTSTART');
    componentParameters(startProperty, {});
    final start = _wall(startProperty.value);
    final from = _offset(requiredProperty(p, 'TZOFFSETFROM'));
    final to = _offset(requiredProperty(p, 'TZOFFSETTO'));
    void add(DateTime wall) {
      budget.onset();
      final instant = wall.subtract(from);
      // Later onsets cannot affect this half-open validation horizon. Their
      // syntax is still validated and the immutable source is retained.
      if (instant.isBefore(expected.horizon.end)) {
        onsets.add(_Onset(instant, from, to));
      }
    }

    add(start);
    for (final name in ['TZNAME', 'COMMENT']) {
      for (final text in p[name] ?? <IcalendarSyntaxProperty>[]) {
        final allowed = name == 'TZNAME'
            ? {'LANGUAGE'}
            : {'LANGUAGE', 'ALTREP'};
        final parameters = componentParameters(text, allowed);
        componentText(text, parameters: allowed);
        if (parameters['LANGUAGE'] != null) {
          validateCalendarLanguageTag(parameters['LANGUAGE']!);
        }
        if (parameters['ALTREP'] != null) componentUri(parameters['ALTREP']!);
      }
    }
    for (final rdate in p['RDATE'] ?? <IcalendarSyntaxProperty>[]) {
      final parameters = componentParameters(rdate, {'VALUE'});
      if (parameters['VALUE'] != null &&
          parameters['VALUE']!.toUpperCase() != 'DATE-TIME') {
        componentFail(IcalendarComponentError.invalidValue);
      }
      for (final text in rdate.value.split(',')) {
        add(_wall(text));
      }
    }
    if (p['RRULE'] != null) {
      final rule = p['RRULE']!.single;
      componentParameters(rule, {});
      _expandYearly(rule.value, start, from, budget, add);
    }
  }
  if (onsets.isEmpty) componentFail(IcalendarComponentError.zoneCoverage);
  onsets.sort((a, b) => a.instant.compareTo(b.instant));
  final distinct = <_Onset>[];
  for (final onset in onsets) {
    if (distinct.isNotEmpty && distinct.last.instant == onset.instant) {
      if (distinct.last.from != onset.from || distinct.last.to != onset.to) {
        componentFail(IcalendarComponentError.zoneMismatch);
      }
      continue;
    }
    if (distinct.isNotEmpty && distinct.last.to != onset.from) {
      componentFail(IcalendarComponentError.zoneMismatch);
    }
    distinct.add(onset);
  }
  // Do not invent indefinite prehistory from a future onset's TZOFFSETFROM.
  if (distinct.first.instant.isAfter(expected.horizon.start)) {
    componentFail(IcalendarComponentError.zoneCoverage);
  }
  var initial = distinct.first.to;
  final changes = <ZoneOffsetChange>[];
  for (final onset in distinct) {
    if (!onset.instant.isAfter(expected.horizon.start)) {
      initial = onset.to;
    } else {
      changes.add(ZoneOffsetChange(instant: onset.instant, offset: onset.to));
    }
  }
  final actual = ZoneRulesSnapshot(
    zoneId: id,
    horizon: expected.horizon,
    initialOffset: initial,
    changes: changes,
    maxTransitions: budget.limits.maxOnsets,
    dataVersion: expected.dataVersion,
  );
  if (!expected.matchesOffsets(actual)) {
    componentFail(IcalendarComponentError.zoneMismatch);
  }
  return IcalendarValidatedTimeZone._(source, actual);
}

final class _Onset {
  _Onset(this.instant, this.from, this.to);
  final DateTime instant;
  final Duration from, to;
}

Duration _offset(IcalendarSyntaxProperty p) {
  componentParameters(p, {});
  final value = p.value;
  if (!_full(RegExp(r'[+-][0-9]{4}(?:[0-9]{2})?'), value)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final h = int.parse(value.substring(1, 3));
  final m = int.parse(value.substring(3, 5));
  final s = value.length == 7 ? int.parse(value.substring(5)) : 0;
  if (h > 23 || m > 59 || s > 59 || (value[0] == '-' && h + m + s == 0)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  return Duration(
    seconds: (value[0] == '-' ? -1 : 1) * (h * 3600 + m * 60 + s),
  );
}

bool _full(RegExp pattern, String value) {
  final m = pattern.firstMatch(value);
  return m != null && m.start == 0 && m.end == value.length;
}

// Numeric wall-field encoding, never a UTC event or an ordinary CalendarDate.
// Earlier seeds and 2100 calculation edges cannot escape through native values.
DateTime _wall(String value, {bool utc = false}) {
  if (value.length != (utc ? 16 : 15) ||
      !_full(
        RegExp(utc ? r'[0-9]{8}T[0-9]{6}Z' : r'[0-9]{8}T[0-9]{6}'),
        value,
      )) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final y = int.parse(value.substring(0, 4));
  final m = int.parse(value.substring(4, 6));
  final d = int.parse(value.substring(6, 8));
  final h = int.parse(value.substring(9, 11));
  final minute = int.parse(value.substring(11, 13));
  final s = int.parse(value.substring(13, 15));
  if (y < 1 ||
      y > 2100 ||
      m < 1 ||
      m > 12 ||
      d < 1 ||
      d > _days(y, m) ||
      h > 23 ||
      minute > 59 ||
      s > 59) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  return DateTime.utc(y, m, d, h, minute, s);
}

int _days(int y, int m) => switch (m) {
  2 => y % 4 == 0 && (y % 100 != 0 || y % 400 == 0) ? 29 : 28,
  4 || 6 || 9 || 11 => 30,
  _ => 31,
};

void _expandYearly(
  String value,
  DateTime seed,
  Duration from,
  ComponentBudget budget,
  void Function(DateTime) add,
) {
  if (value.length > 4096) componentFail(IcalendarComponentError.limitExceeded);
  final parts = <String, String>{};
  for (final item in value.split(';')) {
    final pair = item.split('=');
    if (pair.length != 2 || pair[1].isEmpty) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final key = pair[0].toUpperCase();
    if (!{
      'FREQ',
      'INTERVAL',
      'UNTIL',
      'BYMONTH',
      'BYMONTHDAY',
      'BYDAY',
    }.contains(key)) {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
    if (parts.containsKey(key)) {
      componentFail(IcalendarComponentError.duplicate);
    }
    parts[key] = pair[1];
  }
  if (parts['FREQ']?.toUpperCase() != 'YEARLY') {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final interval = parts['INTERVAL'] == null
      ? 1
      : _integer(parts['INTERVAL']!, 1, 10000, signed: false);
  final until = parts['UNTIL'] == null
      ? null
      : _wall(parts['UNTIL']!, utc: true);
  if (until != null && until.isBefore(seed.subtract(from))) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  List<int> numbers(String key, int low, int high) {
    final raw = parts[key]!.split(',');
    if (raw.length > 64) componentFail(IcalendarComponentError.limitExceeded);
    final pattern = RegExp(
      key == 'BYMONTH' ? r'[0-9]{1,2}' : r'[+-]?[0-9]{1,2}',
    );
    if (raw.any((v) => !_full(pattern, v))) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    return raw.map((v) => _integer(v, low, high)).toSet().toList()..sort();
  }

  final months = parts['BYMONTH'] == null
      ? [seed.month]
      : numbers('BYMONTH', 1, 12);
  final days = parts['BYMONTHDAY'] == null
      ? null
      : numbers('BYMONTHDAY', -31, 31);
  if (days?.contains(0) ?? false) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final weekdays = <(int?, int)>[];
  if (parts['BYDAY'] != null) {
    final raw = parts['BYDAY']!.toUpperCase().split(',');
    if (raw.length > 64) componentFail(IcalendarComponentError.limitExceeded);
    for (final text in raw) {
      final match = RegExp(r'([+-]?[1-5])?(MO|TU|WE|TH|FR|SA|SU)')
          .firstMatch(text);
      if (match == null || match.start != 0 || match.end != text.length) {
        componentFail(IcalendarComponentError.invalidValue);
      }
      weekdays.add((
        match.group(1) == null ? null : int.parse(match.group(1)!),
        ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'].indexOf(match.group(2)!) + 1,
      ));
    }
  }
  if (parts['BYMONTH'] == null && (days != null || weekdays.isNotEmpty)) {
    // This bounded month-based profile does not reinterpret year-relative BYDAY.
    componentFail(IcalendarComponentError.invalidValue);
  }
  bool selected(DateTime day) {
    final length = _days(day.year, day.month);
    if (!months.contains(day.month)) return false;
    if (days != null &&
        !days.any((v) => day.day == (v > 0 ? v : length + v + 1))) {
      return false;
    }
    if (weekdays.isNotEmpty &&
        !weekdays.any(
          (v) =>
              day.weekday == v.$2 &&
              (v.$1 == null ||
                  (v.$1! > 0
                      ? (day.day - 1) ~/ 7 + 1 == v.$1
                      : -((length - day.day) ~/ 7 + 1) == v.$1)),
        )) {
      return false;
    }
    return days != null || weekdays.isNotEmpty || day.day == seed.day;
  }

  if (!selected(seed)) componentFail(IcalendarComponentError.invalidValue);
  DateTime? last;
  for (var year = seed.year; year <= 2100; year += interval) {
    if (until != null && year > until.year + 1) break;
    for (final month in months) {
      for (var d = 1; d <= _days(year, month); d++) {
        budget.candidate();
        final wall = DateTime.utc(
          year,
          month,
          d,
          seed.hour,
          seed.minute,
          seed.second,
        );
        if (wall.isBefore(seed) || !selected(wall)) continue;
        final instant = wall.subtract(from);
        if (until != null && instant.isAfter(until)) continue;
        last = instant;
        add(wall);
      }
    }
  }
  if (until != null && last != until) {
    componentFail(IcalendarComponentError.invalidValue);
  }
}

int _integer(String value, int low, int high, {bool signed = true}) {
  if (value.length > 8 ||
      !_full(RegExp(signed ? r'[+-]?[0-9]+' : r'[0-9]+'), value)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final result = int.parse(value);
  if (result < low || result > high) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  return result;
}
