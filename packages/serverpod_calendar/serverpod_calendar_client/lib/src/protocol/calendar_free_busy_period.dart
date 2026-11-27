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
import 'calendar_free_busy_kind.dart' as _izms466b;

abstract class CalendarFreeBusyPeriod
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarFreeBusyPeriod._({
    required this.startUtc,
    required this.endUtc,
    required this.kind,
  });

  factory CalendarFreeBusyPeriod({
    required DateTime startUtc,
    required DateTime endUtc,
    required _izms466b.CalendarFreeBusyKind kind,
  }) = _CalendarFreeBusyPeriodImpl;

  factory CalendarFreeBusyPeriod.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyPeriod(
      startUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startUtc'],
      ),
      endUtc: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endUtc']),
      kind: _izms466b.CalendarFreeBusyKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
    );
  }

  DateTime startUtc;

  DateTime endUtc;

  _izms466b.CalendarFreeBusyKind kind;

  /// Returns a shallow copy of this [CalendarFreeBusyPeriod]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarFreeBusyPeriod copyWith({
    DateTime? startUtc,
    DateTime? endUtc,
    _izms466b.CalendarFreeBusyKind? kind,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyPeriod',
      'startUtc': startUtc.toJson(),
      'endUtc': endUtc.toJson(),
      'kind': kind.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyPeriod',
      'startUtc': startUtc.toJson(),
      'endUtc': endUtc.toJson(),
      'kind': kind.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyPeriodImpl extends CalendarFreeBusyPeriod {
  _CalendarFreeBusyPeriodImpl({
    required DateTime startUtc,
    required DateTime endUtc,
    required _izms466b.CalendarFreeBusyKind kind,
  }) : super._(
         startUtc: startUtc,
         endUtc: endUtc,
         kind: kind,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyPeriod]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarFreeBusyPeriod copyWith({
    DateTime? startUtc,
    DateTime? endUtc,
    _izms466b.CalendarFreeBusyKind? kind,
  }) {
    return CalendarFreeBusyPeriod(
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      kind: kind ?? this.kind,
    );
  }
}
