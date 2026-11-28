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

@_is.immutable
abstract class CalendarInvitationAdoptionRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarInvitationAdoptionRequest._({
    required this.invitationId,
    required this.expectedRevision,
    required this.sourceId,
    required this.calendarId,
    required this.expectedCalendarRevision,
  });

  const factory CalendarInvitationAdoptionRequest({
    required _is.UuidValue invitationId,
    required int expectedRevision,
    required _is.UuidValue sourceId,
    required _is.UuidValue calendarId,
    required int expectedCalendarRevision,
  }) = _CalendarInvitationAdoptionRequestImpl;

  factory CalendarInvitationAdoptionRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationAdoptionRequest(
      invitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedCalendarRevision:
          jsonSerialization['expectedCalendarRevision'] as int,
    );
  }

  final _is.UuidValue invitationId;

  final int expectedRevision;

  final _is.UuidValue sourceId;

  final _is.UuidValue calendarId;

  final int expectedCalendarRevision;

  /// Returns a shallow copy of this [CalendarInvitationAdoptionRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationAdoptionRequest copyWith({
    _is.UuidValue? invitationId,
    int? expectedRevision,
    _is.UuidValue? sourceId,
    _is.UuidValue? calendarId,
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
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationAdoptionRequestImpl
    extends CalendarInvitationAdoptionRequest {
  const _CalendarInvitationAdoptionRequestImpl({
    required _is.UuidValue invitationId,
    required int expectedRevision,
    required _is.UuidValue sourceId,
    required _is.UuidValue calendarId,
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
  @_is.useResult
  @override
  CalendarInvitationAdoptionRequest copyWith({
    _is.UuidValue? invitationId,
    int? expectedRevision,
    _is.UuidValue? sourceId,
    _is.UuidValue? calendarId,
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
