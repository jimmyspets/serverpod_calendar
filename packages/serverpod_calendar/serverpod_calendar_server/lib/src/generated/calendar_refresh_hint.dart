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

abstract class CalendarRefreshHint
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarRefreshHint._({
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) : weeks = weeks ?? 0,
       days = days ?? 0,
       hours = hours ?? 0,
       minutes = minutes ?? 0,
       seconds = seconds ?? 0;

  factory CalendarRefreshHint({
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) = _CalendarRefreshHintImpl;

  factory CalendarRefreshHint.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarRefreshHint(
      weeks: jsonSerialization['weeks'] as int?,
      days: jsonSerialization['days'] as int?,
      hours: jsonSerialization['hours'] as int?,
      minutes: jsonSerialization['minutes'] as int?,
      seconds: jsonSerialization['seconds'] as int?,
    );
  }

  int weeks;

  int days;

  int hours;

  int minutes;

  int seconds;

  /// Returns a shallow copy of this [CalendarRefreshHint]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarRefreshHint copyWith({
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshHint',
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
      '__className__': 'serverpod_calendar.CalendarRefreshHint',
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

class _CalendarRefreshHintImpl extends CalendarRefreshHint {
  _CalendarRefreshHintImpl({
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) : super._(
         weeks: weeks,
         days: days,
         hours: hours,
         minutes: minutes,
         seconds: seconds,
       );

  /// Returns a shallow copy of this [CalendarRefreshHint]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarRefreshHint copyWith({
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) {
    return CalendarRefreshHint(
      weeks: weeks ?? this.weeks,
      days: days ?? this.days,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
    );
  }
}
