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
import 'calendar_invitation_outcome.dart' as _i98zwsq8;

@_is.immutable
abstract class CalendarInvitationSourceView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarInvitationSourceView._({
    required this.id,
    required this.entryId,
    this.sequence,
    required this.stamp,
    required this.outcome,
    required this.isCurrent,
    required this.receivedAt,
    this.inactiveAt,
  });

  const factory CalendarInvitationSourceView({
    required _is.UuidValue id,
    required _is.UuidValue entryId,
    int? sequence,
    required DateTime stamp,
    required _i98zwsq8.CalendarInvitationOutcome outcome,
    required bool isCurrent,
    required DateTime receivedAt,
    DateTime? inactiveAt,
  }) = _CalendarInvitationSourceViewImpl;

  factory CalendarInvitationSourceView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationSourceView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      outcome: _i98zwsq8.CalendarInvitationOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      isCurrent: _is.BoolJsonExtension.fromJson(jsonSerialization['isCurrent']),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      inactiveAt: jsonSerialization['inactiveAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['inactiveAt']),
    );
  }

  final _is.UuidValue id;

  final _is.UuidValue entryId;

  final int? sequence;

  final DateTime stamp;

  final _i98zwsq8.CalendarInvitationOutcome outcome;

  final bool isCurrent;

  final DateTime receivedAt;

  final DateTime? inactiveAt;

  /// Returns a shallow copy of this [CalendarInvitationSourceView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationSourceView copyWith({
    _is.UuidValue? id,
    _is.UuidValue? entryId,
    int? sequence,
    DateTime? stamp,
    _i98zwsq8.CalendarInvitationOutcome? outcome,
    bool? isCurrent,
    DateTime? receivedAt,
    DateTime? inactiveAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationSourceView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.entryId,
                  entryId,
                ) ||
                other.entryId == entryId) &&
            (identical(
                  other.sequence,
                  sequence,
                ) ||
                other.sequence == sequence) &&
            (identical(
                  other.stamp,
                  stamp,
                ) ||
                other.stamp == stamp) &&
            (identical(
                  other.outcome,
                  outcome,
                ) ||
                other.outcome == outcome) &&
            (identical(
                  other.isCurrent,
                  isCurrent,
                ) ||
                other.isCurrent == isCurrent) &&
            (identical(
                  other.receivedAt,
                  receivedAt,
                ) ||
                other.receivedAt == receivedAt) &&
            (identical(
                  other.inactiveAt,
                  inactiveAt,
                ) ||
                other.inactiveAt == inactiveAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      entryId,
      sequence,
      stamp,
      outcome,
      isCurrent,
      receivedAt,
      inactiveAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationSourceView',
      'id': id.toJson(),
      'entryId': entryId.toJson(),
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      'outcome': outcome.toJson(),
      'isCurrent': isCurrent,
      'receivedAt': receivedAt.toJson(),
      if (inactiveAt != null) 'inactiveAt': inactiveAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationSourceView',
      'id': id.toJson(),
      'entryId': entryId.toJson(),
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      'outcome': outcome.toJson(),
      'isCurrent': isCurrent,
      'receivedAt': receivedAt.toJson(),
      if (inactiveAt != null) 'inactiveAt': inactiveAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationSourceViewImpl extends CalendarInvitationSourceView {
  const _CalendarInvitationSourceViewImpl({
    required _is.UuidValue id,
    required _is.UuidValue entryId,
    int? sequence,
    required DateTime stamp,
    required _i98zwsq8.CalendarInvitationOutcome outcome,
    required bool isCurrent,
    required DateTime receivedAt,
    DateTime? inactiveAt,
  }) : super._(
         id: id,
         entryId: entryId,
         sequence: sequence,
         stamp: stamp,
         outcome: outcome,
         isCurrent: isCurrent,
         receivedAt: receivedAt,
         inactiveAt: inactiveAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationSourceView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationSourceView copyWith({
    _is.UuidValue? id,
    _is.UuidValue? entryId,
    Object? sequence = _Undefined,
    DateTime? stamp,
    _i98zwsq8.CalendarInvitationOutcome? outcome,
    bool? isCurrent,
    DateTime? receivedAt,
    Object? inactiveAt = _Undefined,
  }) {
    return CalendarInvitationSourceView(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      outcome: outcome ?? this.outcome,
      isCurrent: isCurrent ?? this.isCurrent,
      receivedAt: receivedAt ?? this.receivedAt,
      inactiveAt: inactiveAt is DateTime? ? inactiveAt : this.inactiveAt,
    );
  }
}
