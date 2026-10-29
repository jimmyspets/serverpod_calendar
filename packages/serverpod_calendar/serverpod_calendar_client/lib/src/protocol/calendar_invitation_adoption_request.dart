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

@_isc.immutable
abstract class CalendarInvitationAdoptionRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationAdoptionRequest._({
    required this.invitationId,
    required this.expectedRevision,
    required this.sourceId,
    required this.calendarId,
    required this.expectedCalendarRevision,
  });

  const factory CalendarInvitationAdoptionRequest({
    required _isc.UuidValue invitationId,
    required int expectedRevision,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue calendarId,
    required int expectedCalendarRevision,
  }) = _CalendarInvitationAdoptionRequestImpl;

  factory CalendarInvitationAdoptionRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationAdoptionRequest(
      invitationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      sourceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedCalendarRevision:
          jsonSerialization['expectedCalendarRevision'] as int,
    );
  }

  final _isc.UuidValue invitationId;

  final int expectedRevision;

  final _isc.UuidValue sourceId;

  final _isc.UuidValue calendarId;

  final int expectedCalendarRevision;

  /// Returns a shallow copy of this [CalendarInvitationAdoptionRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationAdoptionRequest copyWith({
    _isc.UuidValue? invitationId,
    int? expectedRevision,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? calendarId,
    int? expectedCalendarRevision,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationAdoptionRequest &&
            (identical(
                  other.invitationId,
                  invitationId,
                ) ||
                other.invitationId == invitationId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
            (identical(
                  other.sourceId,
                  sourceId,
                ) ||
                other.sourceId == sourceId) &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.expectedCalendarRevision,
                  expectedCalendarRevision,
                ) ||
                other.expectedCalendarRevision == expectedCalendarRevision);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      invitationId,
      expectedRevision,
      sourceId,
      calendarId,
      expectedCalendarRevision,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationAdoptionRequest',
      'invitationId': invitationId.toJson(),
      'expectedRevision': expectedRevision,
      'sourceId': sourceId.toJson(),
      'calendarId': calendarId.toJson(),
      'expectedCalendarRevision': expectedCalendarRevision,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationAdoptionRequest',
      'invitationId': invitationId.toJson(),
      'expectedRevision': expectedRevision,
      'sourceId': sourceId.toJson(),
      'calendarId': calendarId.toJson(),
      'expectedCalendarRevision': expectedCalendarRevision,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarInvitationAdoptionRequestImpl
    extends CalendarInvitationAdoptionRequest {
  const _CalendarInvitationAdoptionRequestImpl({
    required _isc.UuidValue invitationId,
    required int expectedRevision,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue calendarId,
    required int expectedCalendarRevision,
  }) : super._(
         invitationId: invitationId,
         expectedRevision: expectedRevision,
         sourceId: sourceId,
         calendarId: calendarId,
         expectedCalendarRevision: expectedCalendarRevision,
       );

  /// Returns a shallow copy of this [CalendarInvitationAdoptionRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationAdoptionRequest copyWith({
    _isc.UuidValue? invitationId,
    int? expectedRevision,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? calendarId,
    int? expectedCalendarRevision,
  }) {
    return CalendarInvitationAdoptionRequest(
      invitationId: invitationId ?? this.invitationId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      sourceId: sourceId ?? this.sourceId,
      calendarId: calendarId ?? this.calendarId,
      expectedCalendarRevision:
          expectedCalendarRevision ?? this.expectedCalendarRevision,
    );
  }
}
