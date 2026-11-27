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
import 'calendar_availability_content.dart' as _ifxxil5c;

@_is.immutable
abstract class CalendarAvailabilityCreateRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityCreateRequest._({
    required this.calendarId,
    required this.content,
  });

  const factory CalendarAvailabilityCreateRequest({
    required _is.UuidValue calendarId,
    required _ifxxil5c.CalendarAvailabilityContent content,
  }) = _CalendarAvailabilityCreateRequestImpl;

  factory CalendarAvailabilityCreateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityCreateRequest(
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      content: _ix00hwbf.Protocol()
          .deserialize<_ifxxil5c.CalendarAvailabilityContent>(
            jsonSerialization['content'],
          ),
    );
  }

  final _is.UuidValue calendarId;

  final _ifxxil5c.CalendarAvailabilityContent content;

  /// Returns a shallow copy of this [CalendarAvailabilityCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityCreateRequest copyWith({
    _is.UuidValue? calendarId,
    _ifxxil5c.CalendarAvailabilityContent? content,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityCreateRequest &&
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
      '__className__': 'serverpod_calendar.CalendarAvailabilityCreateRequest',
      'calendarId': calendarId.toJson(),
      'content': content.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityCreateRequest',
      'calendarId': calendarId.toJson(),
      'content': content.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityCreateRequestImpl
    extends CalendarAvailabilityCreateRequest {
  const _CalendarAvailabilityCreateRequestImpl({
    required _is.UuidValue calendarId,
    required _ifxxil5c.CalendarAvailabilityContent content,
  }) : super._(
         calendarId: calendarId,
         content: content,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityCreateRequest copyWith({
    _is.UuidValue? calendarId,
    _ifxxil5c.CalendarAvailabilityContent? content,
  }) {
    return CalendarAvailabilityCreateRequest(
      calendarId: calendarId ?? this.calendarId,
      content: content ?? this.content.copyWith(),
    );
  }
}
