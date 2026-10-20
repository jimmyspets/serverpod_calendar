/// A signed duration retaining nominal calendar units and clock units.
///
/// This is not an elapsed [Duration]. Applying it to a date or zoned time,
/// property-specific validity and iCalendar conversion are separate contracts.
final class CalendarDuration {
  /// Creates a duration without carrying or normalizing its components.
  ///
  /// [sign] must be 1 or -1. Magnitudes are nonnegative; nonzero [weeks]
  /// cannot be combined with other nonzero components. [microsecond] is the
  /// complete fractional-second magnitude, from 0 through 999999.
  /// Zero is allowed here, including a retained negative sign; consumers must
  /// enforce their own positive/nonzero or date-only constraints.
  CalendarDuration({
    this.sign = 1,
    this.weeks = 0,
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    this.microsecond = 0,
  }) {
    if (sign != 1 && sign != -1) {
      throw ArgumentError.value(sign, 'sign', 'Must be 1 or -1');
    }
    RangeError.checkValueInInterval(weeks, 0, maxComponent, 'weeks');
    RangeError.checkValueInInterval(days, 0, maxComponent, 'days');
    RangeError.checkValueInInterval(hours, 0, maxComponent, 'hours');
    RangeError.checkValueInInterval(minutes, 0, maxComponent, 'minutes');
    RangeError.checkValueInInterval(seconds, 0, maxComponent, 'seconds');
    RangeError.checkValueInInterval(microsecond, 0, 999999, 'microsecond');
    if (weeks != 0 &&
        (days != 0 ||
            hours != 0 ||
            minutes != 0 ||
            seconds != 0 ||
            microsecond != 0)) {
      throw ArgumentError('Weeks cannot be combined with other duration units');
    }
  }

  /// Largest exact portable integer magnitude in the Dart VM/web profile.
  ///
  /// This is a representation bound, not a permitted scheduling horizon.
  /// Future operations must check aggregate arithmetic and result bounds.
  static const int maxComponent = 9007199254740991;

  final int sign;
  final int weeks;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final int microsecond;

  /// Whether every magnitude is zero, independently of the retained sign.
  bool get isZero =>
      weeks == 0 &&
      days == 0 &&
      hours == 0 &&
      minutes == 0 &&
      seconds == 0 &&
      microsecond == 0;

  /// Structural equality preserves units; one day is not rewritten as 24 hours.
  @override
  bool operator ==(Object other) =>
      other is CalendarDuration &&
      sign == other.sign &&
      weeks == other.weeks &&
      days == other.days &&
      hours == other.hours &&
      minutes == other.minutes &&
      seconds == other.seconds &&
      microsecond == other.microsecond;

  @override
  int get hashCode =>
      Object.hash(sign, weeks, days, hours, minutes, seconds, microsecond);
}
