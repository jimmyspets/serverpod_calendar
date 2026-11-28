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
import 'calendar_invitation_outcome.dart' as _i98zwsq8;
import 'calendar_invitation_source_kind.dart' as _ilccsff7;

@_isc.immutable
abstract class CalendarInvitationSourceView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationSourceView._({
    required this.id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required this.entryId,
    this.sequence,
    required this.stamp,
    required this.outcome,
    required this.isCurrent,
    required this.receivedAt,
    this.inactiveAt,
  }) : kind = kind ?? _ilccsff7.CalendarInvitationSourceKind.request;

  const factory CalendarInvitationSourceView({
    required _isc.UuidValue id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required _isc.UuidValue entryId,
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
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      kind: jsonSerialization['kind'] == null
          ? null
          : _ilccsff7.CalendarInvitationSourceKind.fromJson(
              (jsonSerialization['kind'] as String),
            ),
      entryId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      outcome: _i98zwsq8.CalendarInvitationOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      isCurrent: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isCurrent'],
      ),
      receivedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      inactiveAt: jsonSerialization['inactiveAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['inactiveAt'],
            ),
    );
  }

  final _ilccsff7.CalendarInvitationSourceKind kind;

  final _isc.UuidValue id;

  final _isc.UuidValue entryId;

  final int? sequence;

  final DateTime stamp;

  final _i98zwsq8.CalendarInvitationOutcome outcome;

  final bool isCurrent;

  final DateTime receivedAt;

  final DateTime? inactiveAt;

  /// Returns a shallow copy of this [CalendarInvitationSourceView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationSourceView copyWith({
    _isc.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    _isc.UuidValue? entryId,
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
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
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
      kind,
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
      'kind': kind.toJson(),
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
      'kind': kind.toJson(),
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationSourceViewImpl extends CalendarInvitationSourceView {
  const _CalendarInvitationSourceViewImpl({
    required _isc.UuidValue id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required _isc.UuidValue entryId,
    int? sequence,
    required DateTime stamp,
    required _i98zwsq8.CalendarInvitationOutcome outcome,
    required bool isCurrent,
    required DateTime receivedAt,
    DateTime? inactiveAt,
  }) : super._(
         id: id,
         kind: kind,
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
  @_isc.useResult
  @override
  CalendarInvitationSourceView copyWith({
    _isc.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    _isc.UuidValue? entryId,
    Object? sequence = _Undefined,
    DateTime? stamp,
    _i98zwsq8.CalendarInvitationOutcome? outcome,
    bool? isCurrent,
    DateTime? receivedAt,
    Object? inactiveAt = _Undefined,
  }) {
    return CalendarInvitationSourceView(
      id: id ?? this.id,
      kind: kind ?? this.kind,
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
