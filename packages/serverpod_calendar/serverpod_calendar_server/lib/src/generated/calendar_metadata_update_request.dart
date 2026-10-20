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

abstract class CalendarMetadataUpdateRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarMetadataUpdateRequest._({
    required this.calendarId,
    required this.expectedRevision,
    required this.displayName,
  });

  factory CalendarMetadataUpdateRequest({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required String displayName,
  }) = _CalendarMetadataUpdateRequestImpl;

  factory CalendarMetadataUpdateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarMetadataUpdateRequest(
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      displayName: jsonSerialization['displayName'] as String,
    );
  }

  _is.UuidValue calendarId;

  int expectedRevision;

  String displayName;

  /// Returns a shallow copy of this [CalendarMetadataUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarMetadataUpdateRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    String? displayName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarMetadataUpdateRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'displayName': displayName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarMetadataUpdateRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'displayName': displayName,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarMetadataUpdateRequestImpl extends CalendarMetadataUpdateRequest {
  _CalendarMetadataUpdateRequestImpl({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required String displayName,
  }) : super._(
         calendarId: calendarId,
         expectedRevision: expectedRevision,
         displayName: displayName,
       );

  /// Returns a shallow copy of this [CalendarMetadataUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarMetadataUpdateRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    String? displayName,
  }) {
    return CalendarMetadataUpdateRequest(
      calendarId: calendarId ?? this.calendarId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      displayName: displayName ?? this.displayName,
    );
  }
}
