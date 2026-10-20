import 'calendar_date.dart';
import 'date_recurrence_rule.dart';

/// Expansion stopped without returning a partial occurrence list.
final class RecurrenceLimitException implements Exception {
  const RecurrenceLimitException(this.limit);
  final String limit;
  @override
  String toString() => 'RecurrenceLimitException: $limit exceeded';
}

/// Bounded DATE-only start-date generation, without event spans or exceptions.
///
/// Yearly week-number filters honor WKST and adjacent week-years. Timed recurrence,
/// RDATE/EXDATE and overrides require separate implementations.
final class DateRecurrenceGenerator {
  /// Returns sorted dates in the inclusive [from] through [through] range.
  ///
  /// [start] must match the rule, including first-period BYSETPOS. COUNT is
  /// counted from start, including occurrences before the requested range.
  /// UNTIL is inclusive. Each valid date examined in a cadence period consumes
  /// work, including dates outside the output range needed for BYSETPOS.
  /// Both budgets must be positive portable integers. Limit failure throws
  /// [RecurrenceLimitException]; no partial result escapes.
  List<CalendarDate> expand({
    required CalendarDate start,
    required DateRecurrenceRule rule,
    required CalendarDate from,
    required CalendarDate through,
    required int maxCandidateDays,
    required int maxResults,
  }) {
    RangeError.checkValueInInterval(
      maxCandidateDays,
      1,
      DateRecurrenceRule.maxScalar,
      'maxCandidateDays',
    );
    RangeError.checkValueInInterval(
      maxResults,
      1,
      DateRecurrenceRule.maxScalar,
      'maxResults',
    );
    if (from.compareTo(through) > 0) {
      throw ArgumentError('from must not follow through');
    }
    if (rule.until != null && rule.until!.compareTo(start) < 0) {
      throw ArgumentError('UNTIL must not exclude DTSTART');
    }
    final first = CalendarDate(year: 1, month: 1, day: 1);
    final last = first.daysUntil(CalendarDate(year: 9999, month: 12, day: 31));
    final startDay = first.daysUntil(start);
    final lower = first.daysUntil(from);
    var upper = first.daysUntil(through);
    if (rule.until != null) {
      final until = first.daysUntil(rule.until!);
      if (until < upper) upper = until;
    }
    var work = 0;
    List<int> candidates(_DatePeriod period) {
      if (rule.bySetPosition.isNotEmpty &&
          (period.begin < 0 || period.end > last + 1)) {
        throw RangeError(
          'BYSETPOS requires a full cadence period inside the date profile',
        );
      }
      final dates = <int>[];
      final begin = period.begin < 0 ? 0 : period.begin;
      final end = period.end > last + 1 ? last + 1 : period.end;
      for (var day = begin; day < end; day++) {
        if (work >= maxCandidateDays) {
          throw const RecurrenceLimitException('maxCandidateDays');
        }
        work++;
        final date = first.addDays(day);
        if (_matches(date, start, rule)) dates.add(day);
      }
      if (rule.bySetPosition.isEmpty) return dates;
      final selected = <int>{};
      for (final position in rule.bySetPosition) {
        final index = position > 0 ? position - 1 : dates.length + position;
        if (index >= 0 && index < dates.length) selected.add(dates[index]);
      }
      return selected.toList()..sort();
    }

    var period = _DatePeriod.initial(start, rule, first, last);
    var selected = candidates(period);
    if (!selected.contains(startDay)) {
      throw ArgumentError('DTSTART does not match the recurrence rule');
    }
    final result = <CalendarDate>[];
    var occurrences = 0;
    while (true) {
      for (final day in selected) {
        if (day < startDay) continue;
        if (day > upper) return List.unmodifiable(result);
        occurrences++;
        if (day >= lower) {
          if (result.length >= maxResults) {
            throw const RecurrenceLimitException('maxResults');
          }
          result.add(first.addDays(day));
        }
        if (occurrences == rule.count) return List.unmodifiable(result);
      }
      final next = period.next(rule, first, last);
      if (next == null || next.begin > upper) return List.unmodifiable(result);
      period = next;
      selected = candidates(period);
    }
  }

  static bool _matches(
    CalendarDate date,
    CalendarDate start,
    DateRecurrenceRule rule,
  ) {
    if (rule.byMonth.isNotEmpty && !rule.byMonth.contains(date.month)) {
      return false;
    }
    if (rule.byMonthDay.isNotEmpty &&
        !_signed(rule.byMonthDay, date.day, date.daysInMonth)) {
      return false;
    }
    final yearStart = CalendarDate(year: date.year, month: 1, day: 1);
    final yearDay = yearStart.daysUntil(date) + 1;
    final yearLength = date.isLeapYear ? 366 : 365;
    if (rule.byWeekNo.isNotEmpty && !_weekMatches(date, yearDay, rule)) {
      return false;
    }
    if (rule.byYearDay.isNotEmpty &&
        !_signed(rule.byYearDay, yearDay, yearLength)) {
      return false;
    }
    if (rule.byDay.isNotEmpty) {
      final monthOrdinal =
          rule.frequency == DateRecurrenceFrequency.monthly ||
          rule.byMonth.isNotEmpty;
      final ordinalDay = monthOrdinal ? date.day : yearDay;
      final ordinalLength = monthOrdinal ? date.daysInMonth : yearLength;
      if (!rule.byDay.any(
        (value) =>
            value.weekday.isoNumber == date.weekday &&
            (value.ordinal == null ||
                value.ordinal == (ordinalDay - 1) ~/ 7 + 1 ||
                value.ordinal == -((ordinalLength - ordinalDay) ~/ 7 + 1)),
      )) {
        return false;
      }
    }
    switch (rule.frequency) {
      case DateRecurrenceFrequency.daily:
        return true;
      case DateRecurrenceFrequency.weekly:
        return rule.byDay.isNotEmpty || date.weekday == start.weekday;
      case DateRecurrenceFrequency.monthly:
        return rule.byDay.isNotEmpty ||
            rule.byMonthDay.isNotEmpty ||
            date.day == start.day;
      case DateRecurrenceFrequency.yearly:
        final expandsDay =
            rule.byDay.isNotEmpty ||
            rule.byMonthDay.isNotEmpty ||
            rule.byYearDay.isNotEmpty ||
            rule.byWeekNo.isNotEmpty;
        if (!expandsDay && date.day != start.day) return false;
        return expandsDay ||
            rule.byMonth.isNotEmpty ||
            date.month == start.month;
    }
  }

  static bool _weekMatches(
    CalendarDate date,
    int yearDay,
    DateRecurrenceRule rule,
  ) {
    var year = date.year;
    final ordinal = _daysBeforeYear(year) + yearDay - 1;
    var begin = _weekOne(year, rule.weekStart);
    if (ordinal < begin) {
      begin = _weekOne(--year, rule.weekStart);
    } else {
      final next = _weekOne(year + 1, rule.weekStart);
      if (ordinal >= next) {
        year++;
        begin = next;
      }
    }
    final number = (ordinal - begin) ~/ 7 + 1;
    final total = (_weekOne(year + 1, rule.weekStart) - begin) ~/ 7;
    return _signed(rule.byWeekNo, number, total);
  }

  // Week one contains January 4 for every week start under the four-day rule.
  // Adjacent week-year labels 0/10000 are integer boundaries only, not dates.
  static int _weekOne(int year, Weekday weekStart) {
    final january4 = _daysBeforeYear(year) + 3;
    return january4 - (january4 - (weekStart.isoNumber - 1)) % 7;
  }

  static int _daysBeforeYear(int year) {
    // Avoid truncating negative integer division at the virtual year-zero edge.
    if (year == 0) return -366;
    final previous = year - 1;
    return previous * 365 + previous ~/ 4 - previous ~/ 100 + previous ~/ 400;
  }

  static bool _signed(List<int> values, int day, int length) =>
      values.contains(day) || values.contains(day - length - 1);
}

final class _DatePeriod {
  const _DatePeriod(this.begin, this.end, this.year, this.month);
  final int begin;
  final int end;
  final int year;
  final int month;

  factory _DatePeriod.initial(
    CalendarDate start,
    DateRecurrenceRule rule,
    CalendarDate first,
    int last,
  ) {
    final day = first.daysUntil(start);
    switch (rule.frequency) {
      case DateRecurrenceFrequency.daily:
        return _DatePeriod(day, day + 1, start.year, start.month);
      case DateRecurrenceFrequency.weekly:
        final begin = day - (start.weekday - rule.weekStart.isoNumber + 7) % 7;
        return _DatePeriod(begin, begin + 7, start.year, start.month);
      case DateRecurrenceFrequency.monthly:
        return _calendar(start.year, start.month, false, first, last);
      case DateRecurrenceFrequency.yearly:
        return _calendar(start.year, 1, true, first, last);
    }
  }

  static _DatePeriod _calendar(
    int year,
    int month,
    bool yearly,
    CalendarDate first,
    int last,
  ) {
    final date = CalendarDate(year: year, month: month, day: 1);
    final begin = first.daysUntil(date);
    final end = yearly
        ? begin + (date.isLeapYear ? 366 : 365)
        : begin + date.daysInMonth;
    return _DatePeriod(begin, end, year, month);
  }

  _DatePeriod? next(DateRecurrenceRule rule, CalendarDate first, int last) {
    switch (rule.frequency) {
      case DateRecurrenceFrequency.daily:
      case DateRecurrenceFrequency.weekly:
        final scale = rule.frequency == DateRecurrenceFrequency.weekly ? 7 : 1;
        if (rule.interval > (last - begin) ~/ scale) return null;
        final next = begin + rule.interval * scale;
        return _DatePeriod(next, next + scale, year, month);
      case DateRecurrenceFrequency.monthly:
        final index = (year - 1) * 12 + month - 1;
        if (rule.interval > 119987 - index) return null;
        final next = index + rule.interval;
        return _calendar(next ~/ 12 + 1, next % 12 + 1, false, first, last);
      case DateRecurrenceFrequency.yearly:
        if (rule.interval > 9999 - year) return null;
        return _calendar(year + rule.interval, 1, true, first, last);
    }
  }
}
