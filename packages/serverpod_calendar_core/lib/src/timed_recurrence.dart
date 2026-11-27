import 'calendar_date.dart';
import 'civil_date_time.dart';
import 'date_recurrence_generator.dart';
import 'date_recurrence_rule.dart';
import 'named_zone_resolver.dart';
import 'recurrence_date_selection.dart';
import 'timed_value.dart';
import 'utc_arithmetic.dart';
import 'utc_window.dart';

/// SECONDLY and BYSECOND are deliberately outside the selected initial profile.
enum TimedRecurrenceFrequency {
  minutely,
  hourly,
  daily,
  weekly,
  monthly,
  yearly,
}

/// Canonical timed rule. UNTIL is inclusive UTC, including for zoned DTSTART.
final class TimedRecurrenceRule {
  TimedRecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.count,
    this.until,
    Weekday weekStart = Weekday.monday,
    List<ByDayValue> byDay = const [],
    List<int> byMonthDay = const [],
    List<int> byYearDay = const [],
    List<int> byWeekNo = const [],
    List<int> byMonth = const [],
    List<int> byHour = const [],
    List<int> byMinute = const [],
    List<int> bySetPosition = const [],
  }) : byHour = _numbers(byHour, 0, 23, 'byHour'),
       byMinute = _numbers(byMinute, 0, 59, 'byMinute'),
       bySetPosition = _numbers(bySetPosition, -366, 366, 'bySetPosition'),
       dateSelection = DateRecurrenceRule(
         frequency: switch (frequency) {
           TimedRecurrenceFrequency.minutely ||
           TimedRecurrenceFrequency.hourly => DateRecurrenceFrequency.yearly,
           TimedRecurrenceFrequency.daily => DateRecurrenceFrequency.daily,
           TimedRecurrenceFrequency.weekly => DateRecurrenceFrequency.weekly,
           TimedRecurrenceFrequency.monthly => DateRecurrenceFrequency.monthly,
           TimedRecurrenceFrequency.yearly => DateRecurrenceFrequency.yearly,
         },
         weekStart: weekStart,
         byDay: byDay,
         byMonthDay: byMonthDay,
         byYearDay: byYearDay,
         byWeekNo: byWeekNo,
         byMonth: byMonth,
       ) {
    RangeError.checkValueInInterval(
      interval,
      1,
      DateRecurrenceRule.maxScalar,
      'interval',
    );
    if (count != null) {
      RangeError.checkValueInInterval(
        count!,
        1,
        DateRecurrenceRule.maxScalar,
        'count',
      );
    }
    if (until != null) utcMicroseconds(until!);
    if (count != null && until != null) {
      throw ArgumentError('COUNT and UNTIL are exclusive');
    }
    if (frequency != TimedRecurrenceFrequency.yearly && byWeekNo.isNotEmpty) {
      throw ArgumentError('BYWEEKNO requires YEARLY');
    }
    if (frequency.index < TimedRecurrenceFrequency.monthly.index &&
        byDay.any((d) => d.ordinal != null)) {
      throw ArgumentError('Ordinal BYDAY requires MONTHLY or YEARLY');
    }
    if (this.bySetPosition.contains(0)) {
      throw ArgumentError('BYSETPOS must be nonzero');
    }
    if (this.bySetPosition.isNotEmpty &&
        byHour.isEmpty &&
        byMinute.isEmpty &&
        byDay.isEmpty &&
        byMonthDay.isEmpty &&
        byYearDay.isEmpty &&
        byWeekNo.isEmpty &&
        byMonth.isEmpty) {
      throw ArgumentError('BYSETPOS requires another BY part');
    }
  }
  final TimedRecurrenceFrequency frequency;
  final int interval;
  final int? count;
  final DateTime? until;
  final DateRecurrenceRule dateSelection;
  final List<int> byHour, byMinute, bySetPosition;
  static List<int> _numbers(List<int> values, int min, int max, String name) {
    for (final value in values) {
      RangeError.checkValueInInterval(value, min, max, name);
    }
    return List.unmodifiable(values.toSet().toList()..sort());
  }

  @override
  bool operator ==(Object other) =>
      other is TimedRecurrenceRule &&
      frequency == other.frequency &&
      interval == other.interval &&
      count == other.count &&
      until == other.until &&
      dateSelection == other.dateSelection &&
      _same(byHour, other.byHour) &&
      _same(byMinute, other.byMinute) &&
      _same(bySetPosition, other.bySetPosition);
  static bool _same(List<int> a, List<int> b) =>
      a.length == b.length &&
      Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);
  @override
  int get hashCode => Object.hash(
    frequency,
    interval,
    count,
    until,
    dateSelection,
    Object.hashAll(byHour),
    Object.hashAll(byMinute),
    Object.hashAll(bySetPosition),
  );
}

/// Shared civil-period engine for UTC and named-zone recurrence.
final class TimedRecurrenceGenerator {
  /// Half-open instant query, with COUNT evaluated from original DTSTART.
  /// Full cadence periods are selected before BYSETPOS, COUNT and query filters.
  /// Invalid generated gaps do not consume COUNT; explicit gap DTSTART does.
  /// Optional [sharedWorkBudget] also charges each unit of candidate work to a
  /// trusted aggregate ceiling, without replacing the per-call work limit.
  List<TimedValue> expand({
    required TimedValue start,
    required TimedRecurrenceRule rule,
    required UtcWindow window,
    required int maxCandidateWork,
    required int maxResults,
    RecurrenceWorkBudget? sharedWorkBudget,
  }) {
    start.civil.date.requireOrdinary('DTSTART');
    for (final entry in {
      'maxCandidateWork': maxCandidateWork,
      'maxResults': maxResults,
    }.entries) {
      RangeError.checkValueInInterval(
        entry.value,
        1,
        DateRecurrenceRule.maxScalar,
        entry.key,
      );
    }
    if (rule.until != null && rule.until!.isBefore(start.instant)) {
      throw ArgumentError('UNTIL excludes DTSTART');
    }
    final resolver = NamedZoneResolver();
    var upper = window.end;
    if (rule.until != null && rule.until!.isBefore(upper)) upper = rule.until!;
    if (start.zoneId != null) {
      // UTC query geometry may include boundary padding. Every generated civil
      // value is still clipped to the ordinary profile and guarded on resolve.
      upper = upper.add(resolver.maximumOffset(zoneId: start.zoneId!));
    }
    final first = CalendarDate(year: 1970, month: 1, day: 1);
    final last = first.daysUntil(CalendarDate(year: 2099, month: 12, day: 31));
    final maxMinute = (last + 1) * 1440;
    int minute(CivilDateTime c) =>
        first.daysUntil(c.date) * 1440 + c.hour * 60 + c.minute;
    final startMinute = minute(start.civil);
    final upperMinute = upper.year < 1970
        ? -1
        : upper.year >= 2100
        ? maxMinute - 1
        : minute(civilFields(upper));
    var work = 0;
    void charge() {
      if (++work > maxCandidateWork) {
        throw const RecurrenceLimitException('maxCandidateWork');
      }
      sharedWorkBudget?.charge();
    }

    List<TimedValue> select(_TimedPeriod period) {
      if (rule.bySetPosition.isNotEmpty &&
          (period.begin < 0 || period.end > maxMinute)) {
        throw RangeError(
          'BYSETPOS requires a complete supported cadence period',
        );
      }
      final candidates = <TimedValue>[];
      final beginDay = period.begin < 0 ? 0 : period.begin ~/ 1440;
      final endDay = ((period.end + 1439) ~/ 1440).clamp(0, last + 1);
      for (var day = beginDay; day < endDay; day++) {
        charge();
        final date = first.addDays(day);
        if (!matchesRecurrenceDate(
          date,
          start.civil.date,
          rule.dateSelection,
          defaultsFrequency: rule.frequency.index < 2
              ? DateRecurrenceFrequency.daily
              : null,
        )) {
          continue;
        }
        final hours = rule.frequency.index < 2
            ? [(period.begin % 1440) ~/ 60]
            : rule.byHour.isEmpty
            ? [start.civil.hour]
            : rule.byHour;
        for (final hour in hours) {
          if (rule.byHour.isNotEmpty && !rule.byHour.contains(hour)) continue;
          final minutes = rule.frequency == TimedRecurrenceFrequency.minutely
              ? [period.begin % 60]
              : rule.byMinute.isEmpty
              ? [start.civil.minute]
              : rule.byMinute;
          for (final m in minutes) {
            charge();
            final tick = day * 1440 + hour * 60 + m;
            if (tick < period.begin ||
                tick >= period.end ||
                (rule.byMinute.isNotEmpty && !rule.byMinute.contains(m))) {
              continue;
            }
            final civil = CivilDateTime(
              date: date,
              hour: hour,
              minute: m,
              second: start.civil.second,
              microsecond: start.civil.microsecond,
            );
            if (civil == start.civil) {
              candidates.add(start);
              continue;
            }
            if (start.zoneId != null &&
                resolver.resolveRecurrenceCandidate(
                      civil,
                      zoneId: start.zoneId!,
                    ) ==
                    null) {
              continue;
            }
            candidates.add(start.at(civil));
          }
        }
      }
      if (rule.bySetPosition.isEmpty) return candidates;
      final indices = <int>{};
      for (final p in rule.bySetPosition) {
        final i = p > 0 ? p - 1 : candidates.length + p;
        if (i >= 0 && i < candidates.length) indices.add(i);
      }
      return [for (final i in indices.toList()..sort()) candidates[i]];
    }

    var period = _TimedPeriod.initial(start.civil, rule, startMinute);
    var candidates = select(period);
    if (!candidates.contains(start)) {
      throw ArgumentError('DTSTART does not match recurrence rule');
    }
    var count = 0;
    final result = <TimedValue>[];
    while (true) {
      for (final candidate in candidates) {
        if (candidate.compareTo(start) < 0) continue;
        // Do not end on one out-of-window instant: gap DTSTART can reorder UTC.
        if (rule.until != null && candidate.instant.isAfter(rule.until!)) {
          continue;
        }
        count++;
        if (window.contains(candidate.instant)) {
          if (result.length >= maxResults) {
            throw const RecurrenceLimitException('maxResults');
          }
          result.add(candidate);
        }
        if (count == rule.count) return _sorted(result);
      }
      final next = period.next(rule, first, maxMinute);
      if (next == null || next.begin > upperMinute) return _sorted(result);
      period = next;
      candidates = select(period);
    }
  }

  List<TimedValue> _sorted(List<TimedValue> values) => List.unmodifiable(
    values..sort((a, b) {
      final order = a.instant.compareTo(b.instant);
      return order == 0 ? a.compareTo(b) : order;
    }),
  );
}

final class _TimedPeriod {
  const _TimedPeriod(this.begin, this.end, this.year, this.month);
  final int begin, end, year, month;
  factory _TimedPeriod.initial(
    CivilDateTime start,
    TimedRecurrenceRule rule,
    int minute,
  ) {
    final day = minute ~/ 1440 * 1440;
    return switch (rule.frequency) {
      TimedRecurrenceFrequency.minutely => _TimedPeriod(
        minute,
        minute + 1,
        start.date.year,
        start.date.month,
      ),
      TimedRecurrenceFrequency.hourly => _TimedPeriod(
        minute ~/ 60 * 60,
        minute ~/ 60 * 60 + 60,
        start.date.year,
        start.date.month,
      ),
      TimedRecurrenceFrequency.daily => _TimedPeriod(
        day,
        day + 1440,
        start.date.year,
        start.date.month,
      ),
      TimedRecurrenceFrequency.weekly => _TimedPeriod(
        day -
            (start.date.weekday - rule.dateSelection.weekStart.isoNumber + 7) %
                7 *
                1440,
        day -
            (start.date.weekday - rule.dateSelection.weekStart.isoNumber + 7) %
                7 *
                1440 +
            10080,
        start.date.year,
        start.date.month,
      ),
      TimedRecurrenceFrequency.monthly => _calendar(
        start.date.year,
        start.date.month,
        false,
      ),
      TimedRecurrenceFrequency.yearly => _calendar(start.date.year, 1, true),
    };
  }
  static _TimedPeriod _calendar(int year, int month, bool yearly) {
    final date = CalendarDate(year: year, month: month, day: 1);
    final begin =
        CalendarDate(year: 1970, month: 1, day: 1).daysUntil(date) * 1440;
    return _TimedPeriod(
      begin,
      begin +
          (yearly
                  ? date.isLeapYear
                        ? 366
                        : 365
                  : date.daysInMonth) *
              1440,
      year,
      month,
    );
  }

  _TimedPeriod? next(
    TimedRecurrenceRule rule,
    CalendarDate first,
    int maxMinute,
  ) {
    if (rule.frequency.index <= TimedRecurrenceFrequency.weekly.index) {
      final scale = [1, 60, 1440, 10080][rule.frequency.index];
      if (rule.interval > (maxMinute - 1 - begin) ~/ scale) return null;
      final next = begin + rule.interval * scale;
      return _TimedPeriod(next, next + scale, year, month);
    }
    if (rule.frequency == TimedRecurrenceFrequency.monthly) {
      final index = (year - 1) * 12 + month - 1;
      if (rule.interval > 25199 - index) return null;
      final next = index + rule.interval;
      return _calendar(next ~/ 12 + 1, next % 12 + 1, false);
    }
    return rule.interval > 2099 - year
        ? null
        : _calendar(year + rule.interval, 1, true);
  }
}
