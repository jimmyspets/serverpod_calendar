/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

@_is.immutable
abstract class CalendarAlarmDuration
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAlarmDuration._({
    int? sign,
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) : sign = sign ?? 1,
       weeks = weeks ?? 0,
       days = days ?? 0,
       hours = hours ?? 0,
       minutes = minutes ?? 0,
       seconds = seconds ?? 0;

  const factory CalendarAlarmDuration({
    int? sign,
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) = _CalendarAlarmDurationImpl;

  factory CalendarAlarmDuration.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmDuration(
      sign: jsonSerialization['sign'] as int?,
      weeks: jsonSerialization['weeks'] as int?,
      days: jsonSerialization['days'] as int?,
      hours: jsonSerialization['hours'] as int?,
      minutes: jsonSerialization['minutes'] as int?,
      seconds: jsonSerialization['seconds'] as int?,
    );
  }

  final int sign;

  final int weeks;

  final int days;

  final int hours;

  final int minutes;

  final int seconds;

  /// Returns a shallow copy of this [CalendarAlarmDuration]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAlarmDuration copyWith({
    int? sign,
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAlarmDuration &&
            (identical(
                  other.sign,
                  sign,
                ) ||
                other.sign == sign) &&
            (identical(
                  other.weeks,
                  weeks,
                ) ||
                other.weeks == weeks) &&
            (identical(
                  other.days,
                  days,
                ) ||
                other.days == days) &&
            (identical(
                  other.hours,
                  hours,
                ) ||
                other.hours == hours) &&
            (identical(
                  other.minutes,
                  minutes,
                ) ||
                other.minutes == minutes) &&
            (identical(
                  other.seconds,
                  seconds,
                ) ||
                other.seconds == seconds);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      sign,
      weeks,
      days,
      hours,
      minutes,
      seconds,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmDuration',
      'sign': sign,
      'weeks': weeks,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmDuration',
      'sign': sign,
      'weeks': weeks,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAlarmDurationImpl extends CalendarAlarmDuration {
  const _CalendarAlarmDurationImpl({
    int? sign,
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) : super._(
         sign: sign,
         weeks: weeks,
         days: days,
         hours: hours,
         minutes: minutes,
         seconds: seconds,
       );

  /// Returns a shallow copy of this [CalendarAlarmDuration]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAlarmDuration copyWith({
    int? sign,
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) {
    return CalendarAlarmDuration(
      sign: sign ?? this.sign,
      weeks: weeks ?? this.weeks,
      days: days ?? this.days,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
    );
  }
}
