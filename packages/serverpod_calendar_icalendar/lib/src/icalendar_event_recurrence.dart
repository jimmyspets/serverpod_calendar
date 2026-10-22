import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'icalendar_component_support.dart';
import 'icalendar_syntax.dart';
import 'icalendar_temporal_values.dart';

/// Immutable core recurrence sets; null when no recurrence properties exist.
/// Source spelling/order remains on the containing event's syntax component.
final class IcalendarEventRecurrence {
  IcalendarEventRecurrence._(this.dateSet, this.timedSet);
  final DateRecurrenceSet? dateSet;
  final TimedRecurrenceSet? timedSet;
}

IcalendarEventRecurrence? componentEventRecurrence(
  Object start,
  Map<String, List<IcalendarSyntaxProperty>> properties,
  ComponentBudget budget,
  Object Function(IcalendarSyntaxProperty, bool exclusiveEnd) parseTemporal,
) {
  if (!['RRULE', 'RDATE', 'EXDATE'].any(properties.containsKey)) return null;
  final additions = <Object>[], exclusions = <Object>[];
  final periods = <TimedEventSpan>[];
  var explicitCount = 0;
  for (final name in ['RDATE', 'EXDATE']) {
    for (final p in properties[name] ?? <IcalendarSyntaxProperty>[]) {
      final parameters = componentParameters(p, {'VALUE', 'TZID'});
      final period =
          parameters['VALUE'] != null &&
          componentToken(parameters['VALUE']!) == 'PERIOD';
      if (period && (name != 'RDATE' || start is! TimedValue)) {
        componentFail(IcalendarComponentError.invalidValue);
      }
      for (final value in p.value.split(',')) {
        if (++explicitCount > budget.limits.maxExplicitDates) {
          componentFail(IcalendarComponentError.limitExceeded);
        }
        budget.explicitDate();
        if (period) {
          final span = _period(p, value, parseTemporal);
          if (!(start as TimedValue).sameProfile(span.start)) {
            componentFail(IcalendarComponentError.invalidValue);
          }
          periods.add(span);
          continue;
        }
        final parsed = parseTemporal(
          IcalendarSyntaxProperty(p.name, value, parameters: p.parameters),
          false,
        );
        if ((start is CalendarDate && parsed is! CalendarDate) ||
            (start is TimedValue &&
                (parsed is! TimedValue || !start.sameProfile(parsed)))) {
          componentFail(IcalendarComponentError.invalidValue);
        }
        (name == 'RDATE' ? additions : exclusions).add(parsed);
      }
    }
  }
  final property = properties['RRULE']?.single;
  final parts = property == null ? null : _parts(property, budget);
  if (start is CalendarDate) {
    final rule = parts == null ? null : _dateRule(parts);
    if (rule != null) {
      DateRecurrenceGenerator().expand(
        start: start,
        rule: rule,
        from: start,
        through: start,
        maxCandidateDays: budget.limits.maxCandidates,
        maxResults: 1,
        sharedWorkBudget: budget.sharedWork,
      );
    }
    return IcalendarEventRecurrence._(
      DateRecurrenceSet(
        start: start,
        rule: rule,
        inclusions: additions.cast<CalendarDate>(),
        exclusions: exclusions.cast<CalendarDate>(),
        maxExplicitDates: budget.limits.maxExplicitDates,
      ),
      null,
    );
  }
  final timed = start as TimedValue;
  final rule = parts == null ? null : _timedRule(parts);
  if (rule != null) {
    TimedRecurrenceGenerator().expand(
      start: timed,
      rule: rule,
      window: UtcWindow(
        start: timed.instant,
        end: timed.instant.add(const Duration(seconds: 1)),
      ),
      maxCandidateWork: budget.limits.maxCandidates,
      maxResults: 1,
      sharedWorkBudget: budget.sharedWork,
    );
  }
  return IcalendarEventRecurrence._(
    null,
    TimedRecurrenceSet(
      start: timed,
      rule: rule,
      inclusions: additions.cast<TimedValue>(),
      exclusions: exclusions.cast<TimedValue>(),
      periods: periods,
      maxExplicitDates: budget.limits.maxExplicitDates,
    ),
  );
}

TimedEventSpan _period(
  IcalendarSyntaxProperty property,
  String value,
  Object Function(IcalendarSyntaxProperty, bool exclusiveEnd) parseTemporal,
) {
  final parts = value.split('/');
  if (parts.length != 2 || parts.any((p) => p.isEmpty)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  // VALUE=PERIOD describes the pair. Each endpoint is a DATE-TIME, with the
  // property's exact TZID independently checked by the existing value adapter.
  Object endpoint(String raw, bool exclusiveEnd) => parseTemporal(
    IcalendarSyntaxProperty(
      property.name,
      raw,
      parameters: property.parameters.where((p) => p.canonicalName != 'VALUE'),
    ),
    exclusiveEnd,
  );
  final start = endpoint(parts[0], false);
  if (start is! TimedValue) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final tail = parts[1];
  if (tail.startsWith('P') || tail.startsWith('+P') || tail.startsWith('-P')) {
    return TimedEventSpan(start: start, duration: parseIcalendarDuration(tail));
  }
  final end = endpoint(tail, true);
  if (end is! TimedValue) componentFail(IcalendarComponentError.invalidValue);
  return TimedEventSpan(start: start, end: end);
}

final class _Parts {
  _Parts(this.scalars, this.numbers, this.days);
  final Map<String, String> scalars;
  final Map<String, List<int>> numbers;
  final List<ByDayValue> days;
  List<int> list(String key) => numbers[key] ?? const [];
  int scalar(String key, int fallback) =>
      scalars[key] == null ? fallback : _positive(scalars[key]!);
  int? get count =>
      scalars['COUNT'] == null ? null : _positive(scalars['COUNT']!);
  Weekday get weekStart =>
      scalars['WKST'] == null ? Weekday.monday : _weekday(scalars['WKST']!);
}

_Parts _parts(IcalendarSyntaxProperty property, ComponentBudget budget) {
  componentParameters(property, {});
  if (property.value.length > 4096) {
    componentFail(IcalendarComponentError.limitExceeded);
  }
  componentToken(property.value);
  final scalars = <String, String>{};
  const allowed = {
    'FREQ',
    'INTERVAL',
    'COUNT',
    'UNTIL',
    'WKST',
    'BYDAY',
    'BYMONTHDAY',
    'BYYEARDAY',
    'BYWEEKNO',
    'BYMONTH',
    'BYHOUR',
    'BYMINUTE',
    'BYSETPOS',
  };
  for (final item in property.value.split(';')) {
    final pair = item.split('=');
    if (pair.length != 2 || pair[1].isEmpty) {
      componentFail(IcalendarComponentError.invalidValue);
    }
    final key = pair[0].toUpperCase();
    if (!allowed.contains(key)) {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
    if (scalars.containsKey(key)) {
      componentFail(IcalendarComponentError.duplicate);
    }
    scalars[key] = pair[1];
  }
  if (!scalars.containsKey('FREQ')) {
    componentFail(IcalendarComponentError.missing);
  }
  if (scalars['COUNT'] != null && scalars['UNTIL'] != null) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final numbers = <String, List<int>>{};
  final days = <ByDayValue>[];
  var size = 0;
  for (final key in scalars.keys.where((key) => key.startsWith('BY'))) {
    final values = scalars[key]!.split(',');
    for (final value in values) {
      if (++size > budget.limits.maxRuleValues) {
        componentFail(IcalendarComponentError.limitExceeded);
      }
      budget.ruleValue();
      if (key == 'BYDAY') {
        final match = RegExp(r'([+-]?[0-9]{1,2})?(MO|TU|WE|TH|FR|SA|SU)')
            .firstMatch(value.toUpperCase());
        if (match == null || match.start != 0 || match.end != value.length) {
          componentFail(IcalendarComponentError.invalidValue);
        }
        days.add(
          ByDayValue(
            weekday: _weekday(match.group(2)!),
            ordinal: match.group(1) == null ? null : int.parse(match.group(1)!),
          ),
        );
      } else {
        final signed = {
          'BYMONTHDAY',
          'BYYEARDAY',
          'BYWEEKNO',
          'BYSETPOS',
        }.contains(key);
        final width = {'BYYEARDAY', 'BYSETPOS'}.contains(key) ? 3 : 2;
        final pattern = RegExp('${signed ? r'[+-]?' : ''}[0-9]{1,$width}');
        if (!_full(pattern, value)) {
          componentFail(IcalendarComponentError.invalidValue);
        }
        numbers.putIfAbsent(key, () => []).add(int.parse(value));
      }
    }
  }
  return _Parts(scalars, numbers, days);
}

DateRecurrenceRule _dateRule(_Parts p) {
  if (p.scalars.containsKey('BYHOUR') || p.scalars.containsKey('BYMINUTE')) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final frequency = switch (p.scalars['FREQ']!.toUpperCase()) {
    'DAILY' => DateRecurrenceFrequency.daily,
    'WEEKLY' => DateRecurrenceFrequency.weekly,
    'MONTHLY' => DateRecurrenceFrequency.monthly,
    'YEARLY' => DateRecurrenceFrequency.yearly,
    _ => componentFail(IcalendarComponentError.invalidValue),
  };
  return DateRecurrenceRule(
    frequency: frequency,
    interval: p.scalar('INTERVAL', 1),
    count: p.count,
    until: p.scalars['UNTIL'] == null
        ? null
        : parseIcalendarDate(p.scalars['UNTIL']!),
    weekStart: p.weekStart,
    byDay: p.days,
    byMonthDay: p.list('BYMONTHDAY'),
    byYearDay: p.list('BYYEARDAY'),
    byWeekNo: p.list('BYWEEKNO'),
    byMonth: p.list('BYMONTH'),
    bySetPosition: p.list('BYSETPOS'),
  );
}

TimedRecurrenceRule _timedRule(_Parts p) {
  final frequency = switch (p.scalars['FREQ']!.toUpperCase()) {
    'MINUTELY' => TimedRecurrenceFrequency.minutely,
    'HOURLY' => TimedRecurrenceFrequency.hourly,
    'DAILY' => TimedRecurrenceFrequency.daily,
    'WEEKLY' => TimedRecurrenceFrequency.weekly,
    'MONTHLY' => TimedRecurrenceFrequency.monthly,
    'YEARLY' => TimedRecurrenceFrequency.yearly,
    _ => componentFail(IcalendarComponentError.invalidValue),
  };
  final until = p.scalars['UNTIL'];
  if (until != null && !until.endsWith('Z')) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  return TimedRecurrenceRule(
    frequency: frequency,
    interval: p.scalar('INTERVAL', 1),
    count: p.count,
    until: until == null ? null : parseIcalendarDateTime(until).instant,
    weekStart: p.weekStart,
    byDay: p.days,
    byMonthDay: p.list('BYMONTHDAY'),
    byYearDay: p.list('BYYEARDAY'),
    byWeekNo: p.list('BYWEEKNO'),
    byMonth: p.list('BYMONTH'),
    byHour: p.list('BYHOUR'),
    byMinute: p.list('BYMINUTE'),
    bySetPosition: p.list('BYSETPOS'),
  );
}

bool _full(RegExp pattern, String value) {
  final m = pattern.firstMatch(value);
  return m != null && m.start == 0 && m.end == value.length;
}

int _positive(String value) {
  if (value.length > 32 || !_full(RegExp(r'[0-9]+'), value)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  final number = BigInt.parse(value);
  if (number < BigInt.one ||
      number > BigInt.from(DateRecurrenceRule.maxScalar)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  return number.toInt();
}

Weekday _weekday(String value) {
  final index = [
    'MO',
    'TU',
    'WE',
    'TH',
    'FR',
    'SA',
    'SU',
  ].indexOf(value.toUpperCase());
  if (index < 0) componentFail(IcalendarComponentError.invalidValue);
  return Weekday.values[index];
}
