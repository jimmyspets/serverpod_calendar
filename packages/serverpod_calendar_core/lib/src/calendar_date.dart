/// A Gregorian calendar date without a time, timezone or UTC instant.
///
/// The selected native/interchange profile accepts years 1970 through 2099.
/// Invalid fields are rejected, never normalized into another date.
final class CalendarDate implements Comparable<CalendarDate> {
  /// Creates a valid Gregorian date in the selected year range.
  ///
  /// Throws [RangeError] for an unsupported year, month or day.
  CalendarDate({required this.year, required this.month, required this.day}) {
    RangeError.checkValueInInterval(year, 1970, 2099, 'year');
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    RangeError.checkValueInInterval(day, 1, daysInMonth, 'day');
  }

  /// The sole date outside the ordinary profile, for exclusive endpoints only.
  const CalendarDate.exclusiveEnd() : year = 2100, month = 1, day = 1;

  bool get isExclusiveEnd => year == 2100;

  void requireOrdinary([String name = 'date']) {
    if (isExclusiveEnd) throw RangeError('$name must precede 2100-01-01');
  }

  final int year;
  final int month;
  final int day;

  /// Whether this date's year has February 29 under Gregorian rules.
  bool get isLeapYear => _isLeapYear(year);

  /// Number of days in this date's month, independent of timezone or DST.
  int get daysInMonth => switch (month) {
    2 => isLeapYear ? 29 : 28,
    4 || 6 || 9 || 11 => 30,
    _ => 31,
  };

  /// Monday is 1 and Sunday is 7, independent of timezone or week start.
  int get weekday => _dayNumber % 7 + 1;

  /// Signed calendar days from this date to [other].
  ///
  /// This is not an elapsed-time duration and does not resolve either date.
  int daysUntil(CalendarDate other) => other._dayNumber - _dayNumber;

  /// Moves forward or backward by calendar days, without timestamp conversion.
  ///
  /// Throws [RangeError] if the result would leave years 1970 through 2099.
  CalendarDate addDays(int days) {
    final current = _dayNumber;
    // Validate before addition to avoid overflow for very large input values.
    RangeError.checkValueInInterval(
      days,
      _firstDayNumber - current,
      _endDayNumber - current,
      'days',
    );
    final target = current + days;
    if (target == _endDayNumber) return const CalendarDate.exclusiveEnd();
    var lower = 1970;
    var upper = 2100;
    while (lower + 1 < upper) {
      final middle = (lower + upper) ~/ 2;
      if (_daysBeforeYear(middle) <= target) {
        lower = middle;
      } else {
        upper = middle;
      }
    }
    final dayOfYear = target - _daysBeforeYear(lower);
    final leap = _isLeapYear(lower);
    var resultMonth = 1;
    while (resultMonth < 12 &&
        _daysBeforeMonth[resultMonth] + (leap && resultMonth >= 2 ? 1 : 0) <=
            dayOfYear) {
      resultMonth++;
    }
    final beforeMonth =
        _daysBeforeMonth[resultMonth - 1] + (leap && resultMonth > 2 ? 1 : 0);
    return CalendarDate(
      year: lower,
      month: resultMonth,
      day: dayOfYear - beforeMonth + 1,
    );
  }

  // Zero-based Gregorian day numbers; 0001-01-01 is Monday.
  static const _firstDayNumber = 719162;
  static const _endDayNumber = 766644;
  static const _daysBeforeMonth = [
    0,
    31,
    59,
    90,
    120,
    151,
    181,
    212,
    243,
    273,
    304,
    334,
  ];

  static bool _isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  static int _daysBeforeYear(int year) {
    final previous = year - 1;
    return previous * 365 + previous ~/ 4 - previous ~/ 100 + previous ~/ 400;
  }

  int get _dayNumber =>
      _daysBeforeYear(year) +
      _daysBeforeMonth[month - 1] +
      (isLeapYear && month > 2 ? 1 : 0) +
      day -
      1;

  /// Chronological date ordering, without resolving a date to an instant.
  @override
  int compareTo(CalendarDate other) {
    final years = year.compareTo(other.year);
    if (years != 0) return years;
    final months = month.compareTo(other.month);
    return months != 0 ? months : day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// A diagnostic YYYY-MM-DD representation, not an iCalendar serializer.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
