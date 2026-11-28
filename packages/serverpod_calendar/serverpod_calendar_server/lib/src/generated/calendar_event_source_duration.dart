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
abstract class CalendarEventSourceDuration
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventSourceDuration._({
    required this.sign,
    required this.weeks,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  const factory CalendarEventSourceDuration({
    required int sign,
    required int weeks,
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) = _CalendarEventSourceDurationImpl;

  factory CalendarEventSourceDuration.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventSourceDuration(
      sign: jsonSerialization['sign'] as int,
      weeks: jsonSerialization['weeks'] as int,
      days: jsonSerialization['days'] as int,
      hours: jsonSerialization['hours'] as int,
      minutes: jsonSerialization['minutes'] as int,
      seconds: jsonSerialization['seconds'] as int,
    );
  }

  final int sign;

  final int weeks;

  final int days;

  final int hours;

  final int minutes;

  final int seconds;

  /// Returns a shallow copy of this [CalendarEventSourceDuration]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventSourceDuration copyWith({
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
            other is CalendarEventSourceDuration &&
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
      '__className__': 'serverpod_calendar.CalendarEventSourceDuration',
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
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarEventSourceDurationImpl extends CalendarEventSourceDuration {
  const _CalendarEventSourceDurationImpl({
    required int sign,
    required int weeks,
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
  }) : super._(
         sign: sign,
         weeks: weeks,
         days: days,
         hours: hours,
         minutes: minutes,
         seconds: seconds,
       );

  /// Returns a shallow copy of this [CalendarEventSourceDuration]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventSourceDuration copyWith({
    int? sign,
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) {
    return CalendarEventSourceDuration(
      sign: sign ?? this.sign,
      weeks: weeks ?? this.weeks,
      days: days ?? this.days,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
    );
  }
}
