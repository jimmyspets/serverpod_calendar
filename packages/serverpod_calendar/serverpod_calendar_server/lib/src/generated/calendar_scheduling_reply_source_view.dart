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
import 'calendar_scheduling_reply_outcome.dart' as _ikqvfn4d;

@_is.immutable
abstract class CalendarSchedulingReplySourceView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarSchedulingReplySourceView._({
    required this.id,
    required this.attendeeAddress,
    this.sourceSequence,
    required this.stamp,
    this.sourceParticipation,
    required this.effectiveParticipation,
    required this.outcome,
    required this.publishedSequence,
    required this.publishedCancelled,
    required this.receivedAt,
    required this.isCurrent,
  });

  const factory CalendarSchedulingReplySourceView({
    required _is.UuidValue id,
    required String attendeeAddress,
    int? sourceSequence,
    required DateTime stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    required _iot0xi24.CalendarSchedulingParticipation effectiveParticipation,
    required _ikqvfn4d.CalendarSchedulingReplyOutcome outcome,
    required int publishedSequence,
    required bool publishedCancelled,
    required DateTime receivedAt,
    required bool isCurrent,
  }) = _CalendarSchedulingReplySourceViewImpl;

  factory CalendarSchedulingReplySourceView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingReplySourceView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      attendeeAddress: jsonSerialization['attendeeAddress'] as String,
      sourceSequence: jsonSerialization['sourceSequence'] as int?,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      sourceParticipation: jsonSerialization['sourceParticipation'] == null
          ? null
          : _iot0xi24.CalendarSchedulingParticipation.fromJson(
              (jsonSerialization['sourceParticipation'] as String),
            ),
      effectiveParticipation:
          _iot0xi24.CalendarSchedulingParticipation.fromJson(
            (jsonSerialization['effectiveParticipation'] as String),
          ),
      outcome: _ikqvfn4d.CalendarSchedulingReplyOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      publishedSequence: jsonSerialization['publishedSequence'] as int,
      publishedCancelled: _is.BoolJsonExtension.fromJson(
        jsonSerialization['publishedCancelled'],
      ),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      isCurrent: _is.BoolJsonExtension.fromJson(jsonSerialization['isCurrent']),
    );
  }

  final _is.UuidValue id;

  final String attendeeAddress;

  final int? sourceSequence;

  final DateTime stamp;

  final _iot0xi24.CalendarSchedulingParticipation? sourceParticipation;

  final _iot0xi24.CalendarSchedulingParticipation effectiveParticipation;

  final _ikqvfn4d.CalendarSchedulingReplyOutcome outcome;

  final int publishedSequence;

  final bool publishedCancelled;

  final DateTime receivedAt;

  final bool isCurrent;

  /// Returns a shallow copy of this [CalendarSchedulingReplySourceView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingReplySourceView copyWith({
    _is.UuidValue? id,
    String? attendeeAddress,
    int? sourceSequence,
    DateTime? stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    _iot0xi24.CalendarSchedulingParticipation? effectiveParticipation,
    _ikqvfn4d.CalendarSchedulingReplyOutcome? outcome,
    int? publishedSequence,
    bool? publishedCancelled,
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
            other is CalendarSchedulingReplySourceView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.attendeeAddress,
                  attendeeAddress,
                ) ||
                other.attendeeAddress == attendeeAddress) &&
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
                  other.outcome,
                  outcome,
                ) ||
                other.outcome == outcome) &&
            (identical(
                  other.publishedSequence,
                  publishedSequence,
                ) ||
                other.publishedSequence == publishedSequence) &&
            (identical(
                  other.publishedCancelled,
                  publishedCancelled,
                ) ||
                other.publishedCancelled == publishedCancelled) &&
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
      id,
      attendeeAddress,
      sourceSequence,
      stamp,
      sourceParticipation,
      effectiveParticipation,
      outcome,
      publishedSequence,
      publishedCancelled,
      receivedAt,
      isCurrent,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingReplySourceView',
      'id': id.toJson(),
      'attendeeAddress': attendeeAddress,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      'stamp': stamp.toJson(),
      if (sourceParticipation != null)
        'sourceParticipation': sourceParticipation?.toJson(),
      'effectiveParticipation': effectiveParticipation.toJson(),
      'outcome': outcome.toJson(),
      'publishedSequence': publishedSequence,
      'publishedCancelled': publishedCancelled,
      'receivedAt': receivedAt.toJson(),
      'isCurrent': isCurrent,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingReplySourceView',
      'id': id.toJson(),
      'attendeeAddress': attendeeAddress,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      'stamp': stamp.toJson(),
      if (sourceParticipation != null)
        'sourceParticipation': sourceParticipation?.toJson(),
      'effectiveParticipation': effectiveParticipation.toJson(),
      'outcome': outcome.toJson(),
      'publishedSequence': publishedSequence,
      'publishedCancelled': publishedCancelled,
      'receivedAt': receivedAt.toJson(),
      'isCurrent': isCurrent,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingReplySourceViewImpl
    extends CalendarSchedulingReplySourceView {
  const _CalendarSchedulingReplySourceViewImpl({
    required _is.UuidValue id,
    required String attendeeAddress,
    int? sourceSequence,
    required DateTime stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    required _iot0xi24.CalendarSchedulingParticipation effectiveParticipation,
    required _ikqvfn4d.CalendarSchedulingReplyOutcome outcome,
    required int publishedSequence,
    required bool publishedCancelled,
    required DateTime receivedAt,
    required bool isCurrent,
  }) : super._(
         id: id,
         attendeeAddress: attendeeAddress,
         sourceSequence: sourceSequence,
         stamp: stamp,
         sourceParticipation: sourceParticipation,
         effectiveParticipation: effectiveParticipation,
         outcome: outcome,
         publishedSequence: publishedSequence,
         publishedCancelled: publishedCancelled,
         receivedAt: receivedAt,
         isCurrent: isCurrent,
       );

  /// Returns a shallow copy of this [CalendarSchedulingReplySourceView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingReplySourceView copyWith({
    _is.UuidValue? id,
    String? attendeeAddress,
    Object? sourceSequence = _Undefined,
    DateTime? stamp,
    Object? sourceParticipation = _Undefined,
    _iot0xi24.CalendarSchedulingParticipation? effectiveParticipation,
    _ikqvfn4d.CalendarSchedulingReplyOutcome? outcome,
    int? publishedSequence,
    bool? publishedCancelled,
    DateTime? receivedAt,
    bool? isCurrent,
  }) {
    return CalendarSchedulingReplySourceView(
      id: id ?? this.id,
      attendeeAddress: attendeeAddress ?? this.attendeeAddress,
      sourceSequence: sourceSequence is int?
          ? sourceSequence
          : this.sourceSequence,
      stamp: stamp ?? this.stamp,
      sourceParticipation:
          sourceParticipation is _iot0xi24.CalendarSchedulingParticipation?
          ? sourceParticipation
          : this.sourceParticipation,
      effectiveParticipation:
          effectiveParticipation ?? this.effectiveParticipation,
      outcome: outcome ?? this.outcome,
      publishedSequence: publishedSequence ?? this.publishedSequence,
      publishedCancelled: publishedCancelled ?? this.publishedCancelled,
      receivedAt: receivedAt ?? this.receivedAt,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}
