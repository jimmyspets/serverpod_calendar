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
import 'calendar_protocol_metadata.dart' as _itchuj1l;

abstract class CalendarProtocolMetadataUpdateRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarProtocolMetadataUpdateRequest._({
    required this.calendarId,
    required this.expectedRevision,
    required this.metadata,
  });

  factory CalendarProtocolMetadataUpdateRequest({
    required _isc.UuidValue calendarId,
    required int expectedRevision,
    required _itchuj1l.CalendarProtocolMetadata metadata,
  }) = _CalendarProtocolMetadataUpdateRequestImpl;

  factory CalendarProtocolMetadataUpdateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarProtocolMetadataUpdateRequest(
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      metadata: _ie4a1wrz.Protocol()
          .deserialize<_itchuj1l.CalendarProtocolMetadata>(
            jsonSerialization['metadata'],
          ),
    );
  }

  _isc.UuidValue calendarId;

  int expectedRevision;

  _itchuj1l.CalendarProtocolMetadata metadata;

  /// Returns a shallow copy of this [CalendarProtocolMetadataUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarProtocolMetadataUpdateRequest copyWith({
    _isc.UuidValue? calendarId,
    int? expectedRevision,
    _itchuj1l.CalendarProtocolMetadata? metadata,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarProtocolMetadataUpdateRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'metadata': metadata.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarProtocolMetadataUpdateRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'metadata': metadata.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarProtocolMetadataUpdateRequestImpl
    extends CalendarProtocolMetadataUpdateRequest {
  _CalendarProtocolMetadataUpdateRequestImpl({
    required _isc.UuidValue calendarId,
    required int expectedRevision,
    required _itchuj1l.CalendarProtocolMetadata metadata,
  }) : super._(
         calendarId: calendarId,
         expectedRevision: expectedRevision,
         metadata: metadata,
       );

  /// Returns a shallow copy of this [CalendarProtocolMetadataUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarProtocolMetadataUpdateRequest copyWith({
    _isc.UuidValue? calendarId,
    int? expectedRevision,
    _itchuj1l.CalendarProtocolMetadata? metadata,
  }) {
    return CalendarProtocolMetadataUpdateRequest(
      calendarId: calendarId ?? this.calendarId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      metadata: metadata ?? this.metadata.copyWith(),
    );
  }
}
