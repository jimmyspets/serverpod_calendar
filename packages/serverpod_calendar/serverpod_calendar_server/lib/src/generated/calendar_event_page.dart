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
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;
import 'calendar_event_view.dart' as _iqr733fy;

abstract class CalendarEventPage
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarEventPage._({
    required this.events,
    this.nextCursor,
  });

  factory CalendarEventPage({
    required List<_iqr733fy.CalendarEventView> events,
    String? nextCursor,
  }) = _CalendarEventPageImpl;

  factory CalendarEventPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarEventPage(
      events: _ix00hwbf.Protocol()
          .deserialize<List<_iqr733fy.CalendarEventView>>(
            jsonSerialization['events'],
          ),
      nextCursor: jsonSerialization['nextCursor'] as String?,
    );
  }

  List<_iqr733fy.CalendarEventView> events;

  String? nextCursor;

  /// Returns a shallow copy of this [CalendarEventPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventPage copyWith({
    List<_iqr733fy.CalendarEventView>? events,
    String? nextCursor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventPage',
      'events': events.toJson(valueToJson: (v) => v.toJson()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventPage',
      'events': events.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventPageImpl extends CalendarEventPage {
  _CalendarEventPageImpl({
    required List<_iqr733fy.CalendarEventView> events,
    String? nextCursor,
  }) : super._(
         events: events,
         nextCursor: nextCursor,
       );

  /// Returns a shallow copy of this [CalendarEventPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventPage copyWith({
    List<_iqr733fy.CalendarEventView>? events,
    Object? nextCursor = _Undefined,
  }) {
    return CalendarEventPage(
      events: events ?? this.events.map((e0) => e0.copyWith()).toList(),
      nextCursor: nextCursor is String? ? nextCursor : this.nextCursor,
    );
  }
}
