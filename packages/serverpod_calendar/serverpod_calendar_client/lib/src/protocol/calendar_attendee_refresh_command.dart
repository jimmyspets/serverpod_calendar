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

abstract class CalendarAttendeeRefreshCommand
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarAttendeeRefreshCommand._({
    required this.invitationId,
    required this.expectedInvitationRevision,
    required this.commandId,
  });

  factory CalendarAttendeeRefreshCommand({
    required _isc.UuidValue invitationId,
    required int expectedInvitationRevision,
    required _isc.UuidValue commandId,
  }) = _CalendarAttendeeRefreshCommandImpl;

  factory CalendarAttendeeRefreshCommand.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAttendeeRefreshCommand(
      invitationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      expectedInvitationRevision:
          jsonSerialization['expectedInvitationRevision'] as int,
      commandId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
    );
  }

  _isc.UuidValue invitationId;

  int expectedInvitationRevision;

  _isc.UuidValue commandId;

  /// Returns a shallow copy of this [CalendarAttendeeRefreshCommand]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAttendeeRefreshCommand copyWith({
    _isc.UuidValue? invitationId,
    int? expectedInvitationRevision,
    _isc.UuidValue? commandId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAttendeeRefreshCommand',
      'invitationId': invitationId.toJson(),
      'expectedInvitationRevision': expectedInvitationRevision,
      'commandId': commandId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAttendeeRefreshCommand',
      'invitationId': invitationId.toJson(),
      'expectedInvitationRevision': expectedInvitationRevision,
      'commandId': commandId.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAttendeeRefreshCommandImpl
    extends CalendarAttendeeRefreshCommand {
  _CalendarAttendeeRefreshCommandImpl({
    required _isc.UuidValue invitationId,
    required int expectedInvitationRevision,
    required _isc.UuidValue commandId,
  }) : super._(
         invitationId: invitationId,
         expectedInvitationRevision: expectedInvitationRevision,
         commandId: commandId,
       );

  /// Returns a shallow copy of this [CalendarAttendeeRefreshCommand]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAttendeeRefreshCommand copyWith({
    _isc.UuidValue? invitationId,
    int? expectedInvitationRevision,
    _isc.UuidValue? commandId,
  }) {
    return CalendarAttendeeRefreshCommand(
      invitationId: invitationId ?? this.invitationId,
      expectedInvitationRevision:
          expectedInvitationRevision ?? this.expectedInvitationRevision,
      commandId: commandId ?? this.commandId,
    );
  }
}
