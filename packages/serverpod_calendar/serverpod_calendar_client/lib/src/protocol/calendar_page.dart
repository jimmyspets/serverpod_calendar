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
import 'package:serverpod_calendar_client/src/protocol/protocol.dart'
    as _ie4a1wrz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'calendar_view.dart' as _ivspd2q7;

abstract class CalendarPage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarPage._({
    required this.calendars,
    this.nextCursor,
  });

  factory CalendarPage({
    required List<_ivspd2q7.CalendarView> calendars,
    String? nextCursor,
  }) = _CalendarPageImpl;

  factory CalendarPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarPage(
      calendars: _ie4a1wrz.Protocol().deserialize<List<_ivspd2q7.CalendarView>>(
        jsonSerialization['calendars'],
      ),
      nextCursor: jsonSerialization['nextCursor'] as String?,
    );
  }

  List<_ivspd2q7.CalendarView> calendars;

  String? nextCursor;

  /// Returns a shallow copy of this [CalendarPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarPage copyWith({
    List<_ivspd2q7.CalendarView>? calendars,
    String? nextCursor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarPage',
      'calendars': calendars.toJson(valueToJson: (v) => v.toJson()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarPage',
      'calendars': calendars.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarPageImpl extends CalendarPage {
  _CalendarPageImpl({
    required List<_ivspd2q7.CalendarView> calendars,
    String? nextCursor,
  }) : super._(
         calendars: calendars,
         nextCursor: nextCursor,
       );

  /// Returns a shallow copy of this [CalendarPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarPage copyWith({
    List<_ivspd2q7.CalendarView>? calendars,
    Object? nextCursor = _Undefined,
  }) {
    return CalendarPage(
      calendars:
          calendars ?? this.calendars.map((e0) => e0.copyWith()).toList(),
      nextCursor: nextCursor is String? ? nextCursor : this.nextCursor,
    );
  }
}
