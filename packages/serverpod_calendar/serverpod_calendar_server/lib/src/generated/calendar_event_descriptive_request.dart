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
import 'calendar_event_descriptive_metadata.dart' as _i0bvx67a;

@_is.immutable
abstract class CalendarEventDescriptiveRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventDescriptiveRequest._({
    required this.eventId,
    required this.expectedRevision,
    required this.metadata,
  });

  const factory CalendarEventDescriptiveRequest({
    required _is.UuidValue eventId,
    required int expectedRevision,
    required _i0bvx67a.CalendarEventDescriptiveMetadata metadata,
  }) = _CalendarEventDescriptiveRequestImpl;

  factory CalendarEventDescriptiveRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventDescriptiveRequest(
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      metadata: _ix00hwbf.Protocol()
          .deserialize<_i0bvx67a.CalendarEventDescriptiveMetadata>(
            jsonSerialization['metadata'],
          ),
    );
  }

  final _is.UuidValue eventId;

  final int expectedRevision;

  final _i0bvx67a.CalendarEventDescriptiveMetadata metadata;

  /// Returns a shallow copy of this [CalendarEventDescriptiveRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventDescriptiveRequest copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
    _i0bvx67a.CalendarEventDescriptiveMetadata? metadata,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventDescriptiveRequest &&
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
                  other.metadata,
                  metadata,
                ) ||
                other.metadata == metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      expectedRevision,
      metadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventDescriptiveRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'metadata': metadata.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventDescriptiveRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'metadata': metadata.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarEventDescriptiveRequestImpl
    extends CalendarEventDescriptiveRequest {
  const _CalendarEventDescriptiveRequestImpl({
    required _is.UuidValue eventId,
    required int expectedRevision,
    required _i0bvx67a.CalendarEventDescriptiveMetadata metadata,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         metadata: metadata,
       );

  /// Returns a shallow copy of this [CalendarEventDescriptiveRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventDescriptiveRequest copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
    _i0bvx67a.CalendarEventDescriptiveMetadata? metadata,
  }) {
    return CalendarEventDescriptiveRequest(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      metadata: metadata ?? this.metadata.copyWith(),
    );
  }
}
