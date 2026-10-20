import 'calendar_date.dart';

/// Gregorian wall-clock fields, with whole-second precision and no zone.
///
/// This is a building block for named-zone values, not an accepted floating
/// event time or a UTC instant. Zone resolution and DST policy belong elsewhere.
final class CivilDateTime implements Comparable<CivilDateTime> {
  /// Creates validated wall-clock fields without normalizing or resolving them.
  ///
  /// [microsecond] is the fractional second, zero under the whole-second profile, rather than
  /// Dart's microsecond-within-a-millisecond field. Leap second 60 is rejected.
  /// Throws [RangeError] for an invalid time field.
  CivilDateTime({
    required this.date,
    required this.hour,
    required this.minute,
    this.second = 0,
    this.microsecond = 0,
  }) {
    if (date.isExclusiveEnd && (hour != 0 || minute != 0 || second != 0)) {
      throw RangeError('The exclusive boundary must be exactly midnight');
    }
    RangeError.checkValueInInterval(hour, 0, 23, 'hour');
    RangeError.checkValueInInterval(minute, 0, 59, 'minute');
    RangeError.checkValueInInterval(second, 0, 59, 'second');
    RangeError.checkValueInInterval(microsecond, 0, 0, 'microsecond');
  }

  final CalendarDate date;
  final int hour;
  final int minute;
  final int second;

  /// Fractional second in microseconds, zero under the whole-second profile.
  final int microsecond;

  /// Wall-clock field ordering only, not instant ordering across zones or folds.
  @override
  int compareTo(CivilDateTime other) {
    final dates = date.compareTo(other.date);
    if (dates != 0) return dates;
    final hours = hour.compareTo(other.hour);
    if (hours != 0) return hours;
    final minutes = minute.compareTo(other.minute);
    if (minutes != 0) return minutes;
    final seconds = second.compareTo(other.second);
    return seconds != 0 ? seconds : microsecond.compareTo(other.microsecond);
  }

  @override
  bool operator ==(Object other) =>
      other is CivilDateTime &&
      date == other.date &&
      hour == other.hour &&
      minute == other.minute &&
      second == other.second &&
      microsecond == other.microsecond;

  @override
  int get hashCode => Object.hash(date, hour, minute, second, microsecond);

  /// Diagnostic text; no UTC suffix, zone or iCalendar serialization is implied.
  @override
  String toString() {
    final time =
        '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}';
    final fraction = microsecond == 0
        ? ''
        : '.${microsecond.toString().padLeft(6, '0')}';
    return '${date}T$time$fraction';
  }
}
