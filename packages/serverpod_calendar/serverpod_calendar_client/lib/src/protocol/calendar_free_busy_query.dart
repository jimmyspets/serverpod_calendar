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
abstract class CalendarFreeBusyQuery
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarFreeBusyQuery._({
    required this.calendarId,
    required this.fromUtc,
    required this.untilUtc,
  });

  const factory CalendarFreeBusyQuery({
    required _isc.UuidValue calendarId,
    required DateTime fromUtc,
    required DateTime untilUtc,
  }) = _CalendarFreeBusyQueryImpl;

  factory CalendarFreeBusyQuery.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyQuery(
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      fromUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['fromUtc'],
      ),
      untilUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['untilUtc'],
      ),
    );
  }

  final _isc.UuidValue calendarId;

  final DateTime fromUtc;

  final DateTime untilUtc;

  /// Returns a shallow copy of this [CalendarFreeBusyQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarFreeBusyQuery copyWith({
    _isc.UuidValue? calendarId,
    DateTime? fromUtc,
    DateTime? untilUtc,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFreeBusyQuery &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.fromUtc,
                  fromUtc,
                ) ||
                other.fromUtc == fromUtc) &&
            (identical(
                  other.untilUtc,
                  untilUtc,
                ) ||
                other.untilUtc == untilUtc);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      calendarId,
      fromUtc,
      untilUtc,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyQuery',
      'calendarId': calendarId.toJson(),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyQuery',
      'calendarId': calendarId.toJson(),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyQueryImpl extends CalendarFreeBusyQuery {
  const _CalendarFreeBusyQueryImpl({
    required _isc.UuidValue calendarId,
    required DateTime fromUtc,
    required DateTime untilUtc,
  }) : super._(
         calendarId: calendarId,
         fromUtc: fromUtc,
         untilUtc: untilUtc,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarFreeBusyQuery copyWith({
    _isc.UuidValue? calendarId,
    DateTime? fromUtc,
    DateTime? untilUtc,
  }) {
    return CalendarFreeBusyQuery(
      calendarId: calendarId ?? this.calendarId,
      fromUtc: fromUtc ?? this.fromUtc,
      untilUtc: untilUtc ?? this.untilUtc,
    );
  }
}
