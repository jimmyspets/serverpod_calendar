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
import 'calendar_invitation_response_delivery_state.dart' as _iw51ozry;

abstract class CalendarInvitationResponseView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarInvitationResponseView._({
    required this.invitationId,
    required this.revision,
    this.responseId,
    this.choice,
    this.stamp,
    this.sourceId,
    this.sourceRevision,
    this.sourceSequence,
    this.sourceStamp,
    required this.appliesToCurrentSource,
    this.deliveryState,
  });

  factory CalendarInvitationResponseView({
    required _is.UuidValue invitationId,
    required int revision,
    _is.UuidValue? responseId,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    DateTime? stamp,
    _is.UuidValue? sourceId,
    int? sourceRevision,
    int? sourceSequence,
    DateTime? sourceStamp,
    required bool appliesToCurrentSource,
    _iw51ozry.CalendarInvitationResponseDeliveryState? deliveryState,
  }) = _CalendarInvitationResponseViewImpl;

  factory CalendarInvitationResponseView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseView(
      invitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      revision: jsonSerialization['revision'] as int,
      responseId: jsonSerialization['responseId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['responseId'],
            ),
      choice: jsonSerialization['choice'] == null
          ? null
          : _il64jj9v.CalendarInvitationResponseChoice.fromJson(
              (jsonSerialization['choice'] as String),
            ),
      stamp: jsonSerialization['stamp'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      sourceId: jsonSerialization['sourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['sourceId']),
      sourceRevision: jsonSerialization['sourceRevision'] as int?,
      sourceSequence: jsonSerialization['sourceSequence'] as int?,
      sourceStamp: jsonSerialization['sourceStamp'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['sourceStamp'],
            ),
      appliesToCurrentSource: _is.BoolJsonExtension.fromJson(
        jsonSerialization['appliesToCurrentSource'],
      ),
      deliveryState: jsonSerialization['deliveryState'] == null
          ? null
          : _iw51ozry.CalendarInvitationResponseDeliveryState.fromJson(
              (jsonSerialization['deliveryState'] as String),
            ),
    );
  }

  _is.UuidValue invitationId;

  int revision;

  _is.UuidValue? responseId;

  _il64jj9v.CalendarInvitationResponseChoice? choice;

  DateTime? stamp;

  _is.UuidValue? sourceId;

  int? sourceRevision;

  int? sourceSequence;

  DateTime? sourceStamp;

  bool appliesToCurrentSource;

  _iw51ozry.CalendarInvitationResponseDeliveryState? deliveryState;

  /// Returns a shallow copy of this [CalendarInvitationResponseView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationResponseView copyWith({
    _is.UuidValue? invitationId,
    int? revision,
    _is.UuidValue? responseId,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    DateTime? stamp,
    _is.UuidValue? sourceId,
    int? sourceRevision,
    int? sourceSequence,
    DateTime? sourceStamp,
    bool? appliesToCurrentSource,
    _iw51ozry.CalendarInvitationResponseDeliveryState? deliveryState,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationResponseView',
      'invitationId': invitationId.toJson(),
      'revision': revision,
      if (responseId != null) 'responseId': responseId?.toJson(),
      if (choice != null) 'choice': choice?.toJson(),
      if (stamp != null) 'stamp': stamp?.toJson(),
      if (sourceId != null) 'sourceId': sourceId?.toJson(),
      if (sourceRevision != null) 'sourceRevision': sourceRevision,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      if (sourceStamp != null) 'sourceStamp': sourceStamp?.toJson(),
      'appliesToCurrentSource': appliesToCurrentSource,
      if (deliveryState != null) 'deliveryState': deliveryState?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationResponseView',
      'invitationId': invitationId.toJson(),
      'revision': revision,
      if (responseId != null) 'responseId': responseId?.toJson(),
      if (choice != null) 'choice': choice?.toJson(),
      if (stamp != null) 'stamp': stamp?.toJson(),
      if (sourceId != null) 'sourceId': sourceId?.toJson(),
      if (sourceRevision != null) 'sourceRevision': sourceRevision,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      if (sourceStamp != null) 'sourceStamp': sourceStamp?.toJson(),
      'appliesToCurrentSource': appliesToCurrentSource,
      if (deliveryState != null) 'deliveryState': deliveryState?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationResponseViewImpl
    extends CalendarInvitationResponseView {
  _CalendarInvitationResponseViewImpl({
    required _is.UuidValue invitationId,
    required int revision,
    _is.UuidValue? responseId,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    DateTime? stamp,
    _is.UuidValue? sourceId,
    int? sourceRevision,
    int? sourceSequence,
    DateTime? sourceStamp,
    required bool appliesToCurrentSource,
    _iw51ozry.CalendarInvitationResponseDeliveryState? deliveryState,
  }) : super._(
         invitationId: invitationId,
         revision: revision,
         responseId: responseId,
         choice: choice,
         stamp: stamp,
         sourceId: sourceId,
         sourceRevision: sourceRevision,
         sourceSequence: sourceSequence,
         sourceStamp: sourceStamp,
         appliesToCurrentSource: appliesToCurrentSource,
         deliveryState: deliveryState,
       );

  /// Returns a shallow copy of this [CalendarInvitationResponseView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationResponseView copyWith({
    _is.UuidValue? invitationId,
    int? revision,
    Object? responseId = _Undefined,
    Object? choice = _Undefined,
    Object? stamp = _Undefined,
    Object? sourceId = _Undefined,
    Object? sourceRevision = _Undefined,
    Object? sourceSequence = _Undefined,
    Object? sourceStamp = _Undefined,
    bool? appliesToCurrentSource,
    Object? deliveryState = _Undefined,
  }) {
    return CalendarInvitationResponseView(
      invitationId: invitationId ?? this.invitationId,
      revision: revision ?? this.revision,
      responseId: responseId is _is.UuidValue? ? responseId : this.responseId,
      choice: choice is _il64jj9v.CalendarInvitationResponseChoice?
          ? choice
          : this.choice,
      stamp: stamp is DateTime? ? stamp : this.stamp,
      sourceId: sourceId is _is.UuidValue? ? sourceId : this.sourceId,
      sourceRevision: sourceRevision is int?
          ? sourceRevision
          : this.sourceRevision,
      sourceSequence: sourceSequence is int?
          ? sourceSequence
          : this.sourceSequence,
      sourceStamp: sourceStamp is DateTime? ? sourceStamp : this.sourceStamp,
      appliesToCurrentSource:
          appliesToCurrentSource ?? this.appliesToCurrentSource,
      deliveryState:
          deliveryState is _iw51ozry.CalendarInvitationResponseDeliveryState?
          ? deliveryState
          : this.deliveryState,
    );
  }
}
