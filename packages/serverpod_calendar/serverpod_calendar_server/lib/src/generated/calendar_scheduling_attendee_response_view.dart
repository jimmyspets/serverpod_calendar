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
import 'calendar_scheduling_participation.dart' as _iot0xi24;

@_is.immutable
abstract class CalendarSchedulingAttendeeResponseView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarSchedulingAttendeeResponseView._({
    required this.attendeeAddress,
    this.sourceId,
    this.revision,
    this.invitationSequence,
    this.sourceSequence,
    this.stamp,
    this.sourceParticipation,
    this.effectiveParticipation,
    this.receivedAt,
    required this.isCurrent,
  });

  const factory CalendarSchedulingAttendeeResponseView({
    required String attendeeAddress,
    _is.UuidValue? sourceId,
    int? revision,
    int? invitationSequence,
    int? sourceSequence,
    DateTime? stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    _iot0xi24.CalendarSchedulingParticipation? effectiveParticipation,
    DateTime? receivedAt,
    required bool isCurrent,
  }) = _CalendarSchedulingAttendeeResponseViewImpl;

  factory CalendarSchedulingAttendeeResponseView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingAttendeeResponseView(
      attendeeAddress: jsonSerialization['attendeeAddress'] as String,
      sourceId: jsonSerialization['sourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['sourceId']),
      revision: jsonSerialization['revision'] as int?,
      invitationSequence: jsonSerialization['invitationSequence'] as int?,
      sourceSequence: jsonSerialization['sourceSequence'] as int?,
      stamp: jsonSerialization['stamp'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      sourceParticipation: jsonSerialization['sourceParticipation'] == null
          ? null
          : _iot0xi24.CalendarSchedulingParticipation.fromJson(
              (jsonSerialization['sourceParticipation'] as String),
            ),
      effectiveParticipation:
          jsonSerialization['effectiveParticipation'] == null
          ? null
          : _iot0xi24.CalendarSchedulingParticipation.fromJson(
              (jsonSerialization['effectiveParticipation'] as String),
            ),
      receivedAt: jsonSerialization['receivedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['receivedAt']),
      isCurrent: _is.BoolJsonExtension.fromJson(jsonSerialization['isCurrent']),
    );
  }

  final String attendeeAddress;

  final _is.UuidValue? sourceId;

  final int? revision;

  final int? invitationSequence;

  final int? sourceSequence;

  final DateTime? stamp;

  final _iot0xi24.CalendarSchedulingParticipation? sourceParticipation;

  final _iot0xi24.CalendarSchedulingParticipation? effectiveParticipation;

  final DateTime? receivedAt;

  final bool isCurrent;

  /// Returns a shallow copy of this [CalendarSchedulingAttendeeResponseView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingAttendeeResponseView copyWith({
    String? attendeeAddress,
    _is.UuidValue? sourceId,
    int? revision,
    int? invitationSequence,
    int? sourceSequence,
    DateTime? stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    _iot0xi24.CalendarSchedulingParticipation? effectiveParticipation,
    DateTime? receivedAt,
    bool? isCurrent,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingAttendeeResponseView &&
            (identical(
                  other.attendeeAddress,
                  attendeeAddress,
                ) ||
                other.attendeeAddress == attendeeAddress) &&
            (identical(
                  other.sourceId,
                  sourceId,
                ) ||
                other.sourceId == sourceId) &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            (identical(
                  other.invitationSequence,
                  invitationSequence,
                ) ||
                other.invitationSequence == invitationSequence) &&
            (identical(
                  other.sourceSequence,
                  sourceSequence,
                ) ||
                other.sourceSequence == sourceSequence) &&
            (identical(
                  other.stamp,
                  stamp,
                ) ||
                other.stamp == stamp) &&
            (identical(
                  other.sourceParticipation,
                  sourceParticipation,
                ) ||
                other.sourceParticipation == sourceParticipation) &&
            (identical(
                  other.effectiveParticipation,
                  effectiveParticipation,
                ) ||
                other.effectiveParticipation == effectiveParticipation) &&
            (identical(
                  other.receivedAt,
                  receivedAt,
                ) ||
                other.receivedAt == receivedAt) &&
            (identical(
                  other.isCurrent,
                  isCurrent,
                ) ||
                other.isCurrent == isCurrent);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      attendeeAddress,
      sourceId,
      revision,
      invitationSequence,
      sourceSequence,
      stamp,
      sourceParticipation,
      effectiveParticipation,
      receivedAt,
      isCurrent,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarSchedulingAttendeeResponseView',
      'attendeeAddress': attendeeAddress,
      if (sourceId != null) 'sourceId': sourceId?.toJson(),
      if (revision != null) 'revision': revision,
      if (invitationSequence != null) 'invitationSequence': invitationSequence,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      if (stamp != null) 'stamp': stamp?.toJson(),
      if (sourceParticipation != null)
        'sourceParticipation': sourceParticipation?.toJson(),
      if (effectiveParticipation != null)
        'effectiveParticipation': effectiveParticipation?.toJson(),
      if (receivedAt != null) 'receivedAt': receivedAt?.toJson(),
      'isCurrent': isCurrent,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarSchedulingAttendeeResponseView',
      'attendeeAddress': attendeeAddress,
      if (sourceId != null) 'sourceId': sourceId?.toJson(),
      if (revision != null) 'revision': revision,
      if (invitationSequence != null) 'invitationSequence': invitationSequence,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      if (stamp != null) 'stamp': stamp?.toJson(),
      if (sourceParticipation != null)
        'sourceParticipation': sourceParticipation?.toJson(),
      if (effectiveParticipation != null)
        'effectiveParticipation': effectiveParticipation?.toJson(),
      if (receivedAt != null) 'receivedAt': receivedAt?.toJson(),
      'isCurrent': isCurrent,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingAttendeeResponseViewImpl
    extends CalendarSchedulingAttendeeResponseView {
  const _CalendarSchedulingAttendeeResponseViewImpl({
    required String attendeeAddress,
    _is.UuidValue? sourceId,
    int? revision,
    int? invitationSequence,
    int? sourceSequence,
    DateTime? stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    _iot0xi24.CalendarSchedulingParticipation? effectiveParticipation,
    DateTime? receivedAt,
    required bool isCurrent,
  }) : super._(
         attendeeAddress: attendeeAddress,
         sourceId: sourceId,
         revision: revision,
         invitationSequence: invitationSequence,
         sourceSequence: sourceSequence,
         stamp: stamp,
         sourceParticipation: sourceParticipation,
         effectiveParticipation: effectiveParticipation,
         receivedAt: receivedAt,
         isCurrent: isCurrent,
       );

  /// Returns a shallow copy of this [CalendarSchedulingAttendeeResponseView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingAttendeeResponseView copyWith({
    String? attendeeAddress,
    Object? sourceId = _Undefined,
    Object? revision = _Undefined,
    Object? invitationSequence = _Undefined,
    Object? sourceSequence = _Undefined,
    Object? stamp = _Undefined,
    Object? sourceParticipation = _Undefined,
    Object? effectiveParticipation = _Undefined,
    Object? receivedAt = _Undefined,
    bool? isCurrent,
  }) {
    return CalendarSchedulingAttendeeResponseView(
      attendeeAddress: attendeeAddress ?? this.attendeeAddress,
      sourceId: sourceId is _is.UuidValue? ? sourceId : this.sourceId,
      revision: revision is int? ? revision : this.revision,
      invitationSequence: invitationSequence is int?
          ? invitationSequence
          : this.invitationSequence,
      sourceSequence: sourceSequence is int?
          ? sourceSequence
          : this.sourceSequence,
      stamp: stamp is DateTime? ? stamp : this.stamp,
      sourceParticipation:
          sourceParticipation is _iot0xi24.CalendarSchedulingParticipation?
          ? sourceParticipation
          : this.sourceParticipation,
      effectiveParticipation:
          effectiveParticipation is _iot0xi24.CalendarSchedulingParticipation?
          ? effectiveParticipation
          : this.effectiveParticipation,
      receivedAt: receivedAt is DateTime? ? receivedAt : this.receivedAt,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}
