import 'calendar_date.dart';
import 'civil_date_time.dart';
import 'named_zone_resolver.dart';
import 'utc_arithmetic.dart';

/// A signed duration retaining nominal calendar units and clock units.
///
/// This is not an elapsed [Duration]. Explicit date/zoned application preserves
/// calendar meaning; property-specific validity and interchange remain separate.
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

  /// Applies signed days or weeks to a date without timestamp conversion.
  ///
  /// Nonzero clock units throw [ArgumentError]. Result overflow throws
  /// [RangeError], with weeks checked before multiplication.
  CalendarDate addToDate(CalendarDate start) {
    if (hours != 0 || minutes != 0 || seconds != 0 || microsecond != 0) {
      throw ArgumentError('Date-only application requires days or weeks only');
    }
    final available = sign == 1
        ? start.daysUntil(CalendarDate(year: 9999, month: 12, day: 31))
        : CalendarDate(year: 1, month: 1, day: 1).daysUntil(start);
    RangeError.checkValueInInterval(weeks, 0, available ~/ 7, 'weeks');
    RangeError.checkValueInInterval(days, 0, available, 'days');
    return start.addDays(sign * (weeks == 0 ? days : weeks * 7));
  }

  /// Applies signed units to an explicit UTC instant without lossy aggregation.
  ///
  /// In UTC, a day is 24 hours and a week is seven days; no zone/DST or leap
  /// second is applied. Zero still validates UTC input. Unsupported DateTime
  /// results throw [RangeError] before narrowing; fractions remain exact on web.
  DateTime addToUtc(DateTime start) {
    final origin = utcMicroseconds(start);
    final dayUnits = BigInt.from(weeks) * BigInt.from(7) + BigInt.from(days);
    final secondsTotal =
        dayUnits * BigInt.from(86400) +
        BigInt.from(hours) * BigInt.from(3600) +
        BigInt.from(minutes) * BigInt.from(60) +
        BigInt.from(seconds);
    final delta =
        secondsTotal * BigInt.from(1000000) + BigInt.from(microsecond);
    return utcFromMicroseconds(origin + BigInt.from(sign) * delta);
  }

  /// Applies calendar units to requested wall fields, then elapsed clock units.
  ///
  /// Explicit start and intermediate fields use the resolver's RFC gap/fold
  /// policy. Even zero durations validate the start. The final UTC instant is
  /// checked by inverse projection, preserving later-fold instant identity.
  /// Unsupported years/coverage throw rather than returning a partial result.
  DateTime addToZoned(
    CivilDateTime start, {
    required String zoneId,
    required NamedZoneResolver resolver,
  }) {
    final origin = resolver.resolve(start, zoneId: zoneId);
    var base = origin.instant;
    if (weeks != 0 || days != 0) {
      final date = CalendarDuration(
        sign: sign,
        weeks: weeks,
        days: days,
      ).addToDate(start.date);
      final intermediate = CivilDateTime(
        date: date,
        hour: start.hour,
        minute: start.minute,
        second: start.second,
        microsecond: start.microsecond,
      );
      base = resolver.resolve(intermediate, zoneId: zoneId).instant;
    }
    // Aggregate with arbitrary precision before narrowing to a supported
    // instant. Large accepted component values must never overflow or round.
    final clock =
        BigInt.from(hours) * BigInt.from(3600000000) +
        BigInt.from(minutes) * BigInt.from(60000000) +
        BigInt.from(seconds) * BigInt.from(1000000) +
        BigInt.from(microsecond);
    final result =
        BigInt.from(base.microsecondsSinceEpoch) + BigInt.from(sign) * clock;
    // Loose UTC bounds allow offset spillover at the civil envelope edges.
    // localAt enforces the actual local-year and per-zone coverage limits.
    if (result < BigInt.from(DateTime.utc(1899).microsecondsSinceEpoch) ||
        result >= BigInt.from(DateTime.utc(2039).microsecondsSinceEpoch)) {
      throw RangeError(
        'Zoned duration result exceeds the supported time envelope',
      );
    }
    final instant = DateTime.fromMicrosecondsSinceEpoch(
      result.toInt(),
      isUtc: true,
    );
    resolver.localAt(instant, zoneId: zoneId);
    return instant;
  }

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
