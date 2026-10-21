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
abstract class CalendarEventDuration
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventDuration._({
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
    int? microsecond,
  }) : weeks = weeks ?? 0,
       days = days ?? 0,
       hours = hours ?? 0,
       minutes = minutes ?? 0,
       seconds = seconds ?? 0,
       microsecond = microsecond ?? 0;

  const factory CalendarEventDuration({
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
    int? microsecond,
  }) = _CalendarEventDurationImpl;

  factory CalendarEventDuration.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventDuration(
      weeks: jsonSerialization['weeks'] as int?,
      days: jsonSerialization['days'] as int?,
      hours: jsonSerialization['hours'] as int?,
      minutes: jsonSerialization['minutes'] as int?,
      seconds: jsonSerialization['seconds'] as int?,
      microsecond: jsonSerialization['microsecond'] as int?,
    );
  }

  final int weeks;

  final int days;

  final int hours;

  final int minutes;

  final int seconds;

  final int microsecond;

  /// Returns a shallow copy of this [CalendarEventDuration]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventDuration copyWith({
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
    int? microsecond,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventDuration &&
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
                other.seconds == seconds) &&
            (identical(
                  other.microsecond,
                  microsecond,
                ) ||
                other.microsecond == microsecond);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      weeks,
      days,
      hours,
      minutes,
      seconds,
      microsecond,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventDuration',
      'weeks': weeks,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'microsecond': microsecond,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventDuration',
      'weeks': weeks,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'microsecond': microsecond,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarEventDurationImpl extends CalendarEventDuration {
  const _CalendarEventDurationImpl({
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
    int? microsecond,
  }) : super._(
         weeks: weeks,
         days: days,
         hours: hours,
         minutes: minutes,
         seconds: seconds,
         microsecond: microsecond,
       );

  /// Returns a shallow copy of this [CalendarEventDuration]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventDuration copyWith({
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
    int? microsecond,
  }) {
    return CalendarEventDuration(
      weeks: weeks ?? this.weeks,
      days: days ?? this.days,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      microsecond: microsecond ?? this.microsecond,
    );
  }
}
