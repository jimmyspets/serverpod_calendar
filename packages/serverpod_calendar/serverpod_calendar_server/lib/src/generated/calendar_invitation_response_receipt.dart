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

abstract class CalendarInvitationResponseReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarInvitationResponseReceipt._({
    required this.id,
    required this.invitationId,
    required this.sourceId,
    required this.stateRevision,
    required this.choice,
    required this.stamp,
    required this.queuedAt,
  });

  factory CalendarInvitationResponseReceipt({
    required _is.UuidValue id,
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required int stateRevision,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
    required DateTime stamp,
    required DateTime queuedAt,
  }) = _CalendarInvitationResponseReceiptImpl;

  factory CalendarInvitationResponseReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseReceipt(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      invitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      stateRevision: jsonSerialization['stateRevision'] as int,
      choice: _il64jj9v.CalendarInvitationResponseChoice.fromJson(
        (jsonSerialization['choice'] as String),
      ),
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      queuedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['queuedAt'],
      ),
    );
  }

  _is.UuidValue id;

  _is.UuidValue invitationId;

  _is.UuidValue sourceId;

  int stateRevision;

  _il64jj9v.CalendarInvitationResponseChoice choice;

  DateTime stamp;

  DateTime queuedAt;

  /// Returns a shallow copy of this [CalendarInvitationResponseReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationResponseReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    int? stateRevision,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    DateTime? stamp,
    DateTime? queuedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationResponseReceipt',
      'id': id.toJson(),
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'stateRevision': stateRevision,
      'choice': choice.toJson(),
      'stamp': stamp.toJson(),
      'queuedAt': queuedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationResponseReceipt',
      'id': id.toJson(),
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'stateRevision': stateRevision,
      'choice': choice.toJson(),
      'stamp': stamp.toJson(),
      'queuedAt': queuedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationResponseReceiptImpl
    extends CalendarInvitationResponseReceipt {
  _CalendarInvitationResponseReceiptImpl({
    required _is.UuidValue id,
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required int stateRevision,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
    required DateTime stamp,
    required DateTime queuedAt,
  }) : super._(
         id: id,
         invitationId: invitationId,
         sourceId: sourceId,
         stateRevision: stateRevision,
         choice: choice,
         stamp: stamp,
         queuedAt: queuedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationResponseReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationResponseReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    int? stateRevision,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    DateTime? stamp,
    DateTime? queuedAt,
  }) {
    return CalendarInvitationResponseReceipt(
      id: id ?? this.id,
      invitationId: invitationId ?? this.invitationId,
      sourceId: sourceId ?? this.sourceId,
      stateRevision: stateRevision ?? this.stateRevision,
      choice: choice ?? this.choice,
      stamp: stamp ?? this.stamp,
      queuedAt: queuedAt ?? this.queuedAt,
    );
  }
}
