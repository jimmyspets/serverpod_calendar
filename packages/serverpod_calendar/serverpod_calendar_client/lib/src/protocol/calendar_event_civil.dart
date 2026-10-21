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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

@_isc.immutable
abstract class CalendarEventCivil
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventCivil._({
    required this.year,
    required this.month,
    required this.day,
    int? hour,
    int? minute,
    int? second,
    int? microsecond,
  }) : hour = hour ?? 0,
       minute = minute ?? 0,
       second = second ?? 0,
       microsecond = microsecond ?? 0;

  const factory CalendarEventCivil({
    required int year,
    required int month,
    required int day,
    int? hour,
    int? minute,
    int? second,
    int? microsecond,
  }) = _CalendarEventCivilImpl;

  factory CalendarEventCivil.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarEventCivil(
      year: jsonSerialization['year'] as int,
      month: jsonSerialization['month'] as int,
      day: jsonSerialization['day'] as int,
      hour: jsonSerialization['hour'] as int?,
      minute: jsonSerialization['minute'] as int?,
      second: jsonSerialization['second'] as int?,
      microsecond: jsonSerialization['microsecond'] as int?,
    );
  }

  final int year;

  final int month;

  final int day;

  final int hour;

  final int minute;

  final int second;

  final int microsecond;

  /// Returns a shallow copy of this [CalendarEventCivil]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventCivil copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? microsecond,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventCivil &&
            (identical(
                  other.year,
                  year,
                ) ||
                other.year == year) &&
            (identical(
                  other.month,
                  month,
                ) ||
                other.month == month) &&
            (identical(
                  other.day,
                  day,
                ) ||
                other.day == day) &&
            (identical(
                  other.hour,
                  hour,
                ) ||
                other.hour == hour) &&
            (identical(
                  other.minute,
                  minute,
                ) ||
                other.minute == minute) &&
            (identical(
                  other.second,
                  second,
                ) ||
                other.second == second) &&
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
      year,
      month,
      day,
      hour,
      minute,
      second,
      microsecond,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventCivil',
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'second': second,
      'microsecond': microsecond,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventCivil',
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'second': second,
      'microsecond': microsecond,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarEventCivilImpl extends CalendarEventCivil {
  const _CalendarEventCivilImpl({
    required int year,
    required int month,
    required int day,
    int? hour,
    int? minute,
    int? second,
    int? microsecond,
  }) : super._(
         year: year,
         month: month,
         day: day,
         hour: hour,
         minute: minute,
         second: second,
         microsecond: microsecond,
       );

  /// Returns a shallow copy of this [CalendarEventCivil]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventCivil copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? microsecond,
  }) {
    return CalendarEventCivil(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      microsecond: microsecond ?? this.microsecond,
    );
  }
}
