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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class CalendarPresentationUpdateRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarPresentationUpdateRequest._({
    required this.calendarId,
    required this.expectedRevision,
    required this.displayName,
    this.description,
    this.color,
  });

  factory CalendarPresentationUpdateRequest({
    required _isc.UuidValue calendarId,
    required int expectedRevision,
    required String displayName,
    String? description,
    String? color,
  }) = _CalendarPresentationUpdateRequestImpl;

  factory CalendarPresentationUpdateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarPresentationUpdateRequest(
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      displayName: jsonSerialization['displayName'] as String,
      description: jsonSerialization['description'] as String?,
      color: jsonSerialization['color'] as String?,
    );
  }

  _isc.UuidValue calendarId;

  int expectedRevision;

  String displayName;

  String? description;

  String? color;

  /// Returns a shallow copy of this [CalendarPresentationUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarPresentationUpdateRequest copyWith({
    _isc.UuidValue? calendarId,
    int? expectedRevision,
    String? displayName,
    String? description,
    String? color,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarPresentationUpdateRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'displayName': displayName,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarPresentationUpdateRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'displayName': displayName,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarPresentationUpdateRequestImpl
    extends CalendarPresentationUpdateRequest {
  _CalendarPresentationUpdateRequestImpl({
    required _isc.UuidValue calendarId,
    required int expectedRevision,
    required String displayName,
    String? description,
    String? color,
  }) : super._(
         calendarId: calendarId,
         expectedRevision: expectedRevision,
         displayName: displayName,
         description: description,
         color: color,
       );

  /// Returns a shallow copy of this [CalendarPresentationUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarPresentationUpdateRequest copyWith({
    _isc.UuidValue? calendarId,
    int? expectedRevision,
    String? displayName,
    Object? description = _Undefined,
    Object? color = _Undefined,
  }) {
    return CalendarPresentationUpdateRequest(
      calendarId: calendarId ?? this.calendarId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      displayName: displayName ?? this.displayName,
      description: description is String? ? description : this.description,
      color: color is String? ? color : this.color,
    );
  }
}
