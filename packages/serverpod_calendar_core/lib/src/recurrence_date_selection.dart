import 'calendar_date.dart';
import 'date_recurrence_rule.dart';

bool matchesRecurrenceDate(
  CalendarDate date,
  CalendarDate start,
  DateRecurrenceRule rule, {
  DateRecurrenceFrequency? defaultsFrequency,
}) {
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
  switch (defaultsFrequency ?? rule.frequency) {
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
      return expandsDay || rule.byMonth.isNotEmpty || date.month == start.month;
  }
}

bool _weekMatches(CalendarDate date, int yearDay, DateRecurrenceRule rule) {
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
int _weekOne(int year, Weekday weekStart) {
  final january4 = _daysBeforeYear(year) + 3;
  return january4 - (january4 - (weekStart.isoNumber - 1)) % 7;
}

int _daysBeforeYear(int year) {
  // Avoid truncating negative integer division at the virtual year-zero edge.
  if (year == 0) return -366;
  final previous = year - 1;
  return previous * 365 + previous ~/ 4 - previous ~/ 100 + previous ~/ 400;
}

bool _signed(List<int> values, int day, int length) =>
    values.contains(day) || values.contains(day - length - 1);
