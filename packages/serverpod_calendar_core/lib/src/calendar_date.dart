/// A Gregorian calendar date without a time, timezone or UTC instant.
///
/// The selected native/interchange profile accepts years 1 through 9999.
/// Invalid fields are rejected, never normalized into another date.
final class CalendarDate implements Comparable<CalendarDate> {
  /// Creates a valid Gregorian date in the selected year range.
  ///
  /// Throws [RangeError] for an unsupported year, month or day.
  CalendarDate({required this.year, required this.month, required this.day}) {
    RangeError.checkValueInInterval(year, 1, 9999, 'year');
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    RangeError.checkValueInInterval(day, 1, daysInMonth, 'day');
  }

  final int year;
  final int month;
  final int day;

  /// Whether this date's year has February 29 under Gregorian rules.
  bool get isLeapYear => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Number of days in this date's month, independent of timezone or DST.
  int get daysInMonth => switch (month) {
    2 => isLeapYear ? 29 : 28,
    4 || 6 || 9 || 11 => 30,
    _ => 31,
  };

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
