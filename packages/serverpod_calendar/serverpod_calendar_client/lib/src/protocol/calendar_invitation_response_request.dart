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
import 'calendar_invitation_response_choice.dart' as _il64jj9v;

abstract class CalendarInvitationResponseRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarInvitationResponseRequest._({
    required this.invitationId,
    required this.expectedInvitationRevision,
    required this.sourceId,
    required this.expectedResponseRevision,
    required this.commandId,
    required this.choice,
  });

  factory CalendarInvitationResponseRequest({
    required _isc.UuidValue invitationId,
    required int expectedInvitationRevision,
    required _isc.UuidValue sourceId,
    required int expectedResponseRevision,
    required _isc.UuidValue commandId,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
  }) = _CalendarInvitationResponseRequestImpl;

  factory CalendarInvitationResponseRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseRequest(
      invitationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      expectedInvitationRevision:
          jsonSerialization['expectedInvitationRevision'] as int,
      sourceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      expectedResponseRevision:
          jsonSerialization['expectedResponseRevision'] as int,
      commandId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      choice: _il64jj9v.CalendarInvitationResponseChoice.fromJson(
        (jsonSerialization['choice'] as String),
      ),
    );
  }

  _isc.UuidValue invitationId;

  int expectedInvitationRevision;

  _isc.UuidValue sourceId;

  int expectedResponseRevision;

  _isc.UuidValue commandId;

  _il64jj9v.CalendarInvitationResponseChoice choice;

  /// Returns a shallow copy of this [CalendarInvitationResponseRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationResponseRequest copyWith({
    _isc.UuidValue? invitationId,
    int? expectedInvitationRevision,
    _isc.UuidValue? sourceId,
    int? expectedResponseRevision,
    _isc.UuidValue? commandId,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationResponseRequest',
      'invitationId': invitationId.toJson(),
      'expectedInvitationRevision': expectedInvitationRevision,
      'sourceId': sourceId.toJson(),
      'expectedResponseRevision': expectedResponseRevision,
      'commandId': commandId.toJson(),
      'choice': choice.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationResponseRequest',
      'invitationId': invitationId.toJson(),
      'expectedInvitationRevision': expectedInvitationRevision,
      'sourceId': sourceId.toJson(),
      'expectedResponseRevision': expectedResponseRevision,
      'commandId': commandId.toJson(),
      'choice': choice.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarInvitationResponseRequestImpl
    extends CalendarInvitationResponseRequest {
  _CalendarInvitationResponseRequestImpl({
    required _isc.UuidValue invitationId,
    required int expectedInvitationRevision,
    required _isc.UuidValue sourceId,
    required int expectedResponseRevision,
    required _isc.UuidValue commandId,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
  }) : super._(
         invitationId: invitationId,
         expectedInvitationRevision: expectedInvitationRevision,
         sourceId: sourceId,
         expectedResponseRevision: expectedResponseRevision,
         commandId: commandId,
         choice: choice,
       );

  /// Returns a shallow copy of this [CalendarInvitationResponseRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationResponseRequest copyWith({
    _isc.UuidValue? invitationId,
    int? expectedInvitationRevision,
    _isc.UuidValue? sourceId,
    int? expectedResponseRevision,
    _isc.UuidValue? commandId,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
  }) {
    return CalendarInvitationResponseRequest(
      invitationId: invitationId ?? this.invitationId,
      expectedInvitationRevision:
          expectedInvitationRevision ?? this.expectedInvitationRevision,
      sourceId: sourceId ?? this.sourceId,
      expectedResponseRevision:
          expectedResponseRevision ?? this.expectedResponseRevision,
      commandId: commandId ?? this.commandId,
      choice: choice ?? this.choice,
    );
  }
}
