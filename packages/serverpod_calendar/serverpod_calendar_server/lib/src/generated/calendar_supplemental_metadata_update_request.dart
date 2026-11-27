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
import 'calendar_supplemental_metadata.dart' as _ixppc388;

abstract class CalendarSupplementalMetadataUpdateRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarSupplementalMetadataUpdateRequest._({
    required this.calendarId,
    required this.expectedRevision,
    required this.metadata,
  });

  factory CalendarSupplementalMetadataUpdateRequest({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required _ixppc388.CalendarSupplementalMetadata metadata,
  }) = _CalendarSupplementalMetadataUpdateRequestImpl;

  factory CalendarSupplementalMetadataUpdateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSupplementalMetadataUpdateRequest(
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      metadata: _ix00hwbf.Protocol()
          .deserialize<_ixppc388.CalendarSupplementalMetadata>(
            jsonSerialization['metadata'],
          ),
    );
  }

  _is.UuidValue calendarId;

  int expectedRevision;

  _ixppc388.CalendarSupplementalMetadata metadata;

  /// Returns a shallow copy of this [CalendarSupplementalMetadataUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSupplementalMetadataUpdateRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    _ixppc388.CalendarSupplementalMetadata? metadata,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarSupplementalMetadataUpdateRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'metadata': metadata.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarSupplementalMetadataUpdateRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'metadata': metadata.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarSupplementalMetadataUpdateRequestImpl
    extends CalendarSupplementalMetadataUpdateRequest {
  _CalendarSupplementalMetadataUpdateRequestImpl({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required _ixppc388.CalendarSupplementalMetadata metadata,
  }) : super._(
         calendarId: calendarId,
         expectedRevision: expectedRevision,
         metadata: metadata,
       );

  /// Returns a shallow copy of this [CalendarSupplementalMetadataUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSupplementalMetadataUpdateRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    _ixppc388.CalendarSupplementalMetadata? metadata,
  }) {
    return CalendarSupplementalMetadataUpdateRequest(
      calendarId: calendarId ?? this.calendarId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      metadata: metadata ?? this.metadata.copyWith(),
    );
  }
}
