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
abstract class CalendarEventByDay
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventByDay._({
    required this.weekday,
    this.ordinal,
  });

  const factory CalendarEventByDay({
    required int weekday,
    int? ordinal,
  }) = _CalendarEventByDayImpl;

  factory CalendarEventByDay.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarEventByDay(
      weekday: jsonSerialization['weekday'] as int,
      ordinal: jsonSerialization['ordinal'] as int?,
    );
  }

  final int weekday;

  final int? ordinal;

  /// Returns a shallow copy of this [CalendarEventByDay]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventByDay copyWith({
    int? weekday,
    int? ordinal,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventByDay &&
            (identical(
                  other.weekday,
                  weekday,
                ) ||
                other.weekday == weekday) &&
            (identical(
                  other.ordinal,
                  ordinal,
                ) ||
                other.ordinal == ordinal);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      weekday,
      ordinal,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventByDay',
      'weekday': weekday,
      if (ordinal != null) 'ordinal': ordinal,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventByDay',
      'weekday': weekday,
      if (ordinal != null) 'ordinal': ordinal,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventByDayImpl extends CalendarEventByDay {
  const _CalendarEventByDayImpl({
    required int weekday,
    int? ordinal,
  }) : super._(
         weekday: weekday,
         ordinal: ordinal,
       );

  /// Returns a shallow copy of this [CalendarEventByDay]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventByDay copyWith({
    int? weekday,
    Object? ordinal = _Undefined,
  }) {
    return CalendarEventByDay(
      weekday: weekday ?? this.weekday,
      ordinal: ordinal is int? ? ordinal : this.ordinal,
    );
  }
}
