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
abstract class CalendarAvailabilityUpdateRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityUpdateRequest._({
    required this.availabilityId,
    required this.expectedRevision,
    required this.content,
  });

  const factory CalendarAvailabilityUpdateRequest({
    required _is.UuidValue availabilityId,
    required int expectedRevision,
    required _ifxxil5c.CalendarAvailabilityContent content,
  }) = _CalendarAvailabilityUpdateRequestImpl;

  factory CalendarAvailabilityUpdateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityUpdateRequest(
      availabilityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['availabilityId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      content: _ix00hwbf.Protocol()
          .deserialize<_ifxxil5c.CalendarAvailabilityContent>(
            jsonSerialization['content'],
          ),
    );
  }

  final _is.UuidValue availabilityId;

  final int expectedRevision;

  final _ifxxil5c.CalendarAvailabilityContent content;

  /// Returns a shallow copy of this [CalendarAvailabilityUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityUpdateRequest copyWith({
    _is.UuidValue? availabilityId,
    int? expectedRevision,
    _ifxxil5c.CalendarAvailabilityContent? content,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityUpdateRequest &&
            (identical(
                  other.availabilityId,
                  availabilityId,
                ) ||
                other.availabilityId == availabilityId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
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
      availabilityId,
      expectedRevision,
      content,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityUpdateRequest',
      'availabilityId': availabilityId.toJson(),
      'expectedRevision': expectedRevision,
      'content': content.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityUpdateRequest',
      'availabilityId': availabilityId.toJson(),
      'expectedRevision': expectedRevision,
      'content': content.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityUpdateRequestImpl
    extends CalendarAvailabilityUpdateRequest {
  const _CalendarAvailabilityUpdateRequestImpl({
    required _is.UuidValue availabilityId,
    required int expectedRevision,
    required _ifxxil5c.CalendarAvailabilityContent content,
  }) : super._(
         availabilityId: availabilityId,
         expectedRevision: expectedRevision,
         content: content,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityUpdateRequest copyWith({
    _is.UuidValue? availabilityId,
    int? expectedRevision,
    _ifxxil5c.CalendarAvailabilityContent? content,
  }) {
    return CalendarAvailabilityUpdateRequest(
      availabilityId: availabilityId ?? this.availabilityId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      content: content ?? this.content.copyWith(),
    );
  }
}
