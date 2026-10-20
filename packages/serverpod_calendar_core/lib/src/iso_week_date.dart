import 'calendar_date.dart';

/// ISO 8601 week fields derived from a validated Gregorian date.
///
/// Weeks start Monday and week 1 contains January 4. These native labels are
/// independent of recurrence WKST, device locale and timezone resolution.
final class IsoWeekDate {
  /// Projects [date] without attaching a time or timezone.
  factory IsoWeekDate.fromDate(CalendarDate date) {
    final weekday = date.weekday;
    // A week's Thursday determines its ISO year. For the supported profile,
    // even the first and last weeks have their Thursday within years 1–9999.
    final thursday = date.addDays(4 - weekday);
    final januaryFirst = CalendarDate(year: thursday.year, month: 1, day: 1);
    final week = januaryFirst.daysUntil(thursday) ~/ 7 + 1;
    return IsoWeekDate._(thursday.year, week, weekday);
  }

  const IsoWeekDate._(this.weekYear, this.week, this.weekday);

  /// The ISO week-year, which can differ from the Gregorian year near New Year.
  final int weekYear;

  /// Week number from 1 through 52 or 53 in [weekYear].
  final int week;

  /// Monday is 1 and Sunday is 7.
  final int weekday;

  @override
  bool operator ==(Object other) =>
      other is IsoWeekDate &&
      weekYear == other.weekYear &&
      week == other.week &&
      weekday == other.weekday;

  @override
  int get hashCode => Object.hash(weekYear, week, weekday);

  /// Diagnostic YYYY-Www-D text, not an iCalendar serializer or localized label.
  @override
  String toString() =>
      '${weekYear.toString().padLeft(4, '0')}-'
      'W${week.toString().padLeft(2, '0')}-$weekday';
}
