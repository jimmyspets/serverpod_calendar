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
import 'calendar_event_content.dart' as _id4cvk34;

@_is.immutable
abstract class CalendarEventCreateRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventCreateRequest._({
    required this.calendarId,
    required this.content,
  });

  const factory CalendarEventCreateRequest({
    required _is.UuidValue calendarId,
    required _id4cvk34.CalendarEventContent content,
  }) = _CalendarEventCreateRequestImpl;

  factory CalendarEventCreateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventCreateRequest(
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      content: _ix00hwbf.Protocol().deserialize<_id4cvk34.CalendarEventContent>(
        jsonSerialization['content'],
      ),
    );
  }

  final _is.UuidValue calendarId;

  final _id4cvk34.CalendarEventContent content;

  /// Returns a shallow copy of this [CalendarEventCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventCreateRequest copyWith({
    _is.UuidValue? calendarId,
    _id4cvk34.CalendarEventContent? content,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventCreateRequest &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.content,
                  content,
                ) ||
                other.content == content);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      calendarId,
      content,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventCreateRequest',
      'calendarId': calendarId.toJson(),
      'content': content.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventCreateRequest',
      'calendarId': calendarId.toJson(),
      'content': content.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarEventCreateRequestImpl extends CalendarEventCreateRequest {
  const _CalendarEventCreateRequestImpl({
    required _is.UuidValue calendarId,
    required _id4cvk34.CalendarEventContent content,
  }) : super._(
         calendarId: calendarId,
         content: content,
       );

  /// Returns a shallow copy of this [CalendarEventCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventCreateRequest copyWith({
    _is.UuidValue? calendarId,
    _id4cvk34.CalendarEventContent? content,
  }) {
    return CalendarEventCreateRequest(
      calendarId: calendarId ?? this.calendarId,
      content: content ?? this.content.copyWith(),
    );
  }
}
