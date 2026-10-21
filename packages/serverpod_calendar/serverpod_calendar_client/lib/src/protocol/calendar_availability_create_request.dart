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
import 'calendar_availability_content.dart' as _ifxxil5c;

@_isc.immutable
abstract class CalendarAvailabilityCreateRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityCreateRequest._({
    required this.calendarId,
    required this.content,
  });

  const factory CalendarAvailabilityCreateRequest({
    required _isc.UuidValue calendarId,
    required _ifxxil5c.CalendarAvailabilityContent content,
  }) = _CalendarAvailabilityCreateRequestImpl;

  factory CalendarAvailabilityCreateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityCreateRequest(
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      content: _ie4a1wrz.Protocol()
          .deserialize<_ifxxil5c.CalendarAvailabilityContent>(
            jsonSerialization['content'],
          ),
    );
  }

  final _isc.UuidValue calendarId;

  final _ifxxil5c.CalendarAvailabilityContent content;

  /// Returns a shallow copy of this [CalendarAvailabilityCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityCreateRequest copyWith({
    _isc.UuidValue? calendarId,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityCreateRequestImpl
    extends CalendarAvailabilityCreateRequest {
  const _CalendarAvailabilityCreateRequestImpl({
    required _isc.UuidValue calendarId,
    required _ifxxil5c.CalendarAvailabilityContent content,
  }) : super._(
         calendarId: calendarId,
         content: content,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityCreateRequest copyWith({
    _isc.UuidValue? calendarId,
    _ifxxil5c.CalendarAvailabilityContent? content,
  }) {
    return CalendarAvailabilityCreateRequest(
      calendarId: calendarId ?? this.calendarId,
      content: content ?? this.content.copyWith(),
    );
  }
}
