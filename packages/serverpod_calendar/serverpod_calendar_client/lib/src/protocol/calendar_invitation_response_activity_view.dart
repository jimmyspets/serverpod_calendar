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
import 'calendar_invitation_response_delivery_state.dart' as _iw51ozry;

abstract class CalendarInvitationResponseActivityView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarInvitationResponseActivityView._({
    required this.id,
    required this.stateRevision,
    required this.choice,
    required this.sourceId,
    required this.sourceRevision,
    this.sourceSequence,
    required this.sourceStamp,
    required this.stamp,
    required this.deliveryState,
    required this.attemptCount,
    required this.queuedAt,
    required this.expiresAt,
    this.terminalAt,
    this.resultCode,
  });

  factory CalendarInvitationResponseActivityView({
    required _isc.UuidValue id,
    required int stateRevision,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
    required _isc.UuidValue sourceId,
    required int sourceRevision,
    int? sourceSequence,
    required DateTime sourceStamp,
    required DateTime stamp,
    required _iw51ozry.CalendarInvitationResponseDeliveryState deliveryState,
    required int attemptCount,
    required DateTime queuedAt,
    required DateTime expiresAt,
    DateTime? terminalAt,
    String? resultCode,
  }) = _CalendarInvitationResponseActivityViewImpl;

  factory CalendarInvitationResponseActivityView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseActivityView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      stateRevision: jsonSerialization['stateRevision'] as int,
      choice: _il64jj9v.CalendarInvitationResponseChoice.fromJson(
        (jsonSerialization['choice'] as String),
      ),
      sourceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      sourceRevision: jsonSerialization['sourceRevision'] as int,
      sourceSequence: jsonSerialization['sourceSequence'] as int?,
      sourceStamp: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['sourceStamp'],
      ),
      stamp: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      deliveryState: _iw51ozry.CalendarInvitationResponseDeliveryState.fromJson(
        (jsonSerialization['deliveryState'] as String),
      ),
      attemptCount: jsonSerialization['attemptCount'] as int,
      queuedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['queuedAt'],
      ),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      terminalAt: jsonSerialization['terminalAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['terminalAt'],
            ),
      resultCode: jsonSerialization['resultCode'] as String?,
    );
  }

  _isc.UuidValue id;

  int stateRevision;

  _il64jj9v.CalendarInvitationResponseChoice choice;

  _isc.UuidValue sourceId;

  int sourceRevision;

  int? sourceSequence;

  DateTime sourceStamp;

  DateTime stamp;

  _iw51ozry.CalendarInvitationResponseDeliveryState deliveryState;

  int attemptCount;

  DateTime queuedAt;

  DateTime expiresAt;

  DateTime? terminalAt;

  String? resultCode;

  /// Returns a shallow copy of this [CalendarInvitationResponseActivityView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationResponseActivityView copyWith({
    _isc.UuidValue? id,
    int? stateRevision,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    _isc.UuidValue? sourceId,
    int? sourceRevision,
    int? sourceSequence,
    DateTime? sourceStamp,
    DateTime? stamp,
    _iw51ozry.CalendarInvitationResponseDeliveryState? deliveryState,
    int? attemptCount,
    DateTime? queuedAt,
    DateTime? expiresAt,
    DateTime? terminalAt,
    String? resultCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationResponseActivityView',
      'id': id.toJson(),
      'stateRevision': stateRevision,
      'choice': choice.toJson(),
      'sourceId': sourceId.toJson(),
      'sourceRevision': sourceRevision,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      'sourceStamp': sourceStamp.toJson(),
      'stamp': stamp.toJson(),
      'deliveryState': deliveryState.toJson(),
      'attemptCount': attemptCount,
      'queuedAt': queuedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
      if (resultCode != null) 'resultCode': resultCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationResponseActivityView',
      'id': id.toJson(),
      'stateRevision': stateRevision,
      'choice': choice.toJson(),
      'sourceId': sourceId.toJson(),
      'sourceRevision': sourceRevision,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      'sourceStamp': sourceStamp.toJson(),
      'stamp': stamp.toJson(),
      'deliveryState': deliveryState.toJson(),
      'attemptCount': attemptCount,
      'queuedAt': queuedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
      if (resultCode != null) 'resultCode': resultCode,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationResponseActivityViewImpl
    extends CalendarInvitationResponseActivityView {
  _CalendarInvitationResponseActivityViewImpl({
    required _isc.UuidValue id,
    required int stateRevision,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
    required _isc.UuidValue sourceId,
    required int sourceRevision,
    int? sourceSequence,
    required DateTime sourceStamp,
    required DateTime stamp,
    required _iw51ozry.CalendarInvitationResponseDeliveryState deliveryState,
    required int attemptCount,
    required DateTime queuedAt,
    required DateTime expiresAt,
    DateTime? terminalAt,
    String? resultCode,
  }) : super._(
         id: id,
         stateRevision: stateRevision,
         choice: choice,
         sourceId: sourceId,
         sourceRevision: sourceRevision,
         sourceSequence: sourceSequence,
         sourceStamp: sourceStamp,
         stamp: stamp,
         deliveryState: deliveryState,
         attemptCount: attemptCount,
         queuedAt: queuedAt,
         expiresAt: expiresAt,
         terminalAt: terminalAt,
         resultCode: resultCode,
       );

  /// Returns a shallow copy of this [CalendarInvitationResponseActivityView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationResponseActivityView copyWith({
    _isc.UuidValue? id,
    int? stateRevision,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    _isc.UuidValue? sourceId,
    int? sourceRevision,
    Object? sourceSequence = _Undefined,
    DateTime? sourceStamp,
    DateTime? stamp,
    _iw51ozry.CalendarInvitationResponseDeliveryState? deliveryState,
    int? attemptCount,
    DateTime? queuedAt,
    DateTime? expiresAt,
    Object? terminalAt = _Undefined,
    Object? resultCode = _Undefined,
  }) {
    return CalendarInvitationResponseActivityView(
      id: id ?? this.id,
      stateRevision: stateRevision ?? this.stateRevision,
      choice: choice ?? this.choice,
      sourceId: sourceId ?? this.sourceId,
      sourceRevision: sourceRevision ?? this.sourceRevision,
      sourceSequence: sourceSequence is int?
          ? sourceSequence
          : this.sourceSequence,
      sourceStamp: sourceStamp ?? this.sourceStamp,
      stamp: stamp ?? this.stamp,
      deliveryState: deliveryState ?? this.deliveryState,
      attemptCount: attemptCount ?? this.attemptCount,
      queuedAt: queuedAt ?? this.queuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      terminalAt: terminalAt is DateTime? ? terminalAt : this.terminalAt,
      resultCode: resultCode is String? ? resultCode : this.resultCode,
    );
  }
}
