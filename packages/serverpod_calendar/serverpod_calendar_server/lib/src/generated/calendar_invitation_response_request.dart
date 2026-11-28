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
import 'calendar_invitation_response_choice.dart' as _il64jj9v;

abstract class CalendarInvitationResponseRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarInvitationResponseRequest._({
    required this.invitationId,
    required this.expectedInvitationRevision,
    required this.sourceId,
    required this.expectedResponseRevision,
    required this.commandId,
    required this.choice,
  });

  factory CalendarInvitationResponseRequest({
    required _is.UuidValue invitationId,
    required int expectedInvitationRevision,
    required _is.UuidValue sourceId,
    required int expectedResponseRevision,
    required _is.UuidValue commandId,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
  }) = _CalendarInvitationResponseRequestImpl;

  factory CalendarInvitationResponseRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseRequest(
      invitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      expectedInvitationRevision:
          jsonSerialization['expectedInvitationRevision'] as int,
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      expectedResponseRevision:
          jsonSerialization['expectedResponseRevision'] as int,
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      choice: _il64jj9v.CalendarInvitationResponseChoice.fromJson(
        (jsonSerialization['choice'] as String),
      ),
    );
  }

  _is.UuidValue invitationId;

  int expectedInvitationRevision;

  _is.UuidValue sourceId;

  int expectedResponseRevision;

  _is.UuidValue commandId;

  _il64jj9v.CalendarInvitationResponseChoice choice;

  /// Returns a shallow copy of this [CalendarInvitationResponseRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationResponseRequest copyWith({
    _is.UuidValue? invitationId,
    int? expectedInvitationRevision,
    _is.UuidValue? sourceId,
    int? expectedResponseRevision,
    _is.UuidValue? commandId,
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
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationResponseRequestImpl
    extends CalendarInvitationResponseRequest {
  _CalendarInvitationResponseRequestImpl({
    required _is.UuidValue invitationId,
    required int expectedInvitationRevision,
    required _is.UuidValue sourceId,
    required int expectedResponseRevision,
    required _is.UuidValue commandId,
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
  @_is.useResult
  @override
  CalendarInvitationResponseRequest copyWith({
    _is.UuidValue? invitationId,
    int? expectedInvitationRevision,
    _is.UuidValue? sourceId,
    int? expectedResponseRevision,
    _is.UuidValue? commandId,
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
