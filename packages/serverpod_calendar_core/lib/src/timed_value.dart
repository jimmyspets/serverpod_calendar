import 'calendar_date.dart';
import 'calendar_duration.dart';
import 'civil_date_time.dart';
import 'named_zone_resolver.dart';

/// Explicit UTC or named-zone time. No floating-time factory is provided.
/// Zoned identity preserves supplied civil fields and the exact zone key.
final class TimedValue implements Comparable<TimedValue> {
  TimedValue._(this.civil, this.instant, this.zoneId);

  factory TimedValue.utc(DateTime instant) {
    if (!instant.isUtc) {
      throw ArgumentError('An explicit UTC value is required');
    }
    return TimedValue._(civilFields(instant), instant, null);
  }

  factory TimedValue.zoned(CivilDateTime civil, {required String zoneId}) =>
      TimedValue._(
        civil,
        NamedZoneResolver().resolve(civil, zoneId: zoneId).instant,
        zoneId,
      );

  final CivilDateTime civil;
  final DateTime instant;
  final String? zoneId;
  String? get zoneDataVersion =>
      zoneId == null ? null : NamedZoneResolver.dataVersion;

  bool sameProfile(TimedValue other) => zoneId == other.zoneId;

  /// Applies explicit native duration rules and returns the resulting instant.
  /// Returning an instant preserves later-fold identity after elapsed arithmetic.
  DateTime add(CalendarDuration duration) => zoneId == null
      ? duration.addToUtc(instant)
      : duration.addToZoned(
          civil,
          zoneId: zoneId!,
          resolver: NamedZoneResolver(),
        );

  /// Creates a value in this profile; generated gaps are handled by the engine.
  TimedValue at(CivilDateTime fields) => zoneId == null
      ? TimedValue.utc(civilEncoding(fields))
      : TimedValue.zoned(fields, zoneId: zoneId!);

  @override
  int compareTo(TimedValue other) {
    if (!sameProfile(other)) throw ArgumentError('Different temporal profiles');
    return civil.compareTo(other.civil);
  }

  @override
  bool operator ==(Object other) =>
      other is TimedValue && zoneId == other.zoneId && civil == other.civil;
  @override
  int get hashCode => Object.hash(civil, zoneId);
}

/// Internal numeric wall-field encoding; does not resolve an unspecified zone.
DateTime civilEncoding(CivilDateTime value) => DateTime.utc(
  value.date.year,
  value.date.month,
  value.date.day,
  value.hour,
  value.minute,
  value.second,
  value.microsecond ~/ 1000,
  value.microsecond % 1000,
);

CivilDateTime civilFields(DateTime value) => CivilDateTime(
  date: CalendarDate(year: value.year, month: value.month, day: value.day),
  hour: value.hour,
  minute: value.minute,
  second: value.second,
  microsecond: value.millisecond * 1000 + value.microsecond,
);

void validateZonedInstant(DateTime instant, String zoneId) {
  NamedZoneResolver().localAt(instant, zoneId: zoneId);
}
