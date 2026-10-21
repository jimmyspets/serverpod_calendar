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
import 'calendar_event_content.dart' as _id4cvk34;

@_isc.immutable
abstract class CalendarEventUpdateRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventUpdateRequest._({
    required this.eventId,
    required this.expectedRevision,
    required this.content,
  });

  const factory CalendarEventUpdateRequest({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    required _id4cvk34.CalendarEventContent content,
  }) = _CalendarEventUpdateRequestImpl;

  factory CalendarEventUpdateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventUpdateRequest(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      content: _ie4a1wrz.Protocol().deserialize<_id4cvk34.CalendarEventContent>(
        jsonSerialization['content'],
      ),
    );
  }

  final _isc.UuidValue eventId;

  final int expectedRevision;

  final _id4cvk34.CalendarEventContent content;

  /// Returns a shallow copy of this [CalendarEventUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventUpdateRequest copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _id4cvk34.CalendarEventContent? content,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventUpdateRequest &&
            (identical(
                  other.eventId,
                  eventId,
                ) ||
                other.eventId == eventId) &&
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
      eventId,
      expectedRevision,
      content,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventUpdateRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'content': content.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventUpdateRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'content': content.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarEventUpdateRequestImpl extends CalendarEventUpdateRequest {
  const _CalendarEventUpdateRequestImpl({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    required _id4cvk34.CalendarEventContent content,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         content: content,
       );

  /// Returns a shallow copy of this [CalendarEventUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventUpdateRequest copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _id4cvk34.CalendarEventContent? content,
  }) {
    return CalendarEventUpdateRequest(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      content: content ?? this.content.copyWith(),
    );
  }
}
