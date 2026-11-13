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

import 'calendar_incoming_publication_kind.dart' as _ing1vpo7;
import 'calendar_incoming_publication_outcome.dart' as _ireg3hht;

@_isc.immutable
abstract class CalendarIncomingPublicationSourceView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarIncomingPublicationSourceView._({
    required this.id,
    required this.entryId,
    this.basisSourceId,
    required this.kind,
    this.sequence,
    required this.stamp,
    required this.digest,
    required this.normalizedSource,
    required this.outcome,
    required this.isCurrent,
    required this.receivedAt,
  });

  const factory CalendarIncomingPublicationSourceView({
    required _isc.UuidValue id,
    required _isc.UuidValue entryId,
    _isc.UuidValue? basisSourceId,
    required _ing1vpo7.CalendarIncomingPublicationKind kind,
    int? sequence,
    required DateTime stamp,
    required String digest,
    required String normalizedSource,
    required _ireg3hht.CalendarIncomingPublicationOutcome outcome,
    required bool isCurrent,
    required DateTime receivedAt,
  }) = _CalendarIncomingPublicationSourceViewImpl;

  factory CalendarIncomingPublicationSourceView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationSourceView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entryId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      basisSourceId: jsonSerialization['basisSourceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['basisSourceId'],
            ),
      kind: _ing1vpo7.CalendarIncomingPublicationKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      digest: jsonSerialization['digest'] as String,
      normalizedSource: jsonSerialization['normalizedSource'] as String,
      outcome: _ireg3hht.CalendarIncomingPublicationOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      isCurrent: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isCurrent'],
      ),
      receivedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  final _isc.UuidValue id;

  final _isc.UuidValue entryId;

  final _isc.UuidValue? basisSourceId;

  final _ing1vpo7.CalendarIncomingPublicationKind kind;

  final int? sequence;

  final DateTime stamp;

  final String digest;

  final String normalizedSource;

  final _ireg3hht.CalendarIncomingPublicationOutcome outcome;

  final bool isCurrent;

  final DateTime receivedAt;

  /// Returns a shallow copy of this [CalendarIncomingPublicationSourceView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarIncomingPublicationSourceView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? entryId,
    _isc.UuidValue? basisSourceId = const _isc.$UndefinedUuidValue(),
    _ing1vpo7.CalendarIncomingPublicationKind? kind,
    int? sequence,
    DateTime? stamp,
    String? digest,
    String? normalizedSource,
    _ireg3hht.CalendarIncomingPublicationOutcome? outcome,
    bool? isCurrent,
    DateTime? receivedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationSourceView &&
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
                  other.basisSourceId,
                  basisSourceId,
                ) ||
                other.basisSourceId == basisSourceId) &&
            (identical(
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
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
                  other.digest,
                  digest,
                ) ||
                other.digest == digest) &&
            (identical(
                  other.normalizedSource,
                  normalizedSource,
                ) ||
                other.normalizedSource == normalizedSource) &&
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
                other.receivedAt == receivedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      entryId,
      basisSourceId,
      kind,
      sequence,
      stamp,
      digest,
      normalizedSource,
      outcome,
      isCurrent,
      receivedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationSourceView',
      'id': id.toJson(),
      'entryId': entryId.toJson(),
      if (basisSourceId != null) 'basisSourceId': basisSourceId?.toJson(),
      'kind': kind.toJson(),
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      'digest': digest,
      'normalizedSource': normalizedSource,
      'outcome': outcome.toJson(),
      'isCurrent': isCurrent,
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationSourceView',
      'id': id.toJson(),
      'entryId': entryId.toJson(),
      if (basisSourceId != null) 'basisSourceId': basisSourceId?.toJson(),
      'kind': kind.toJson(),
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      'digest': digest,
      'normalizedSource': normalizedSource,
      'outcome': outcome.toJson(),
      'isCurrent': isCurrent,
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarIncomingPublicationSourceViewImpl
    extends CalendarIncomingPublicationSourceView {
  const _CalendarIncomingPublicationSourceViewImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue entryId,
    _isc.UuidValue? basisSourceId,
    required _ing1vpo7.CalendarIncomingPublicationKind kind,
    int? sequence,
    required DateTime stamp,
    required String digest,
    required String normalizedSource,
    required _ireg3hht.CalendarIncomingPublicationOutcome outcome,
    required bool isCurrent,
    required DateTime receivedAt,
  }) : super._(
         id: id,
         entryId: entryId,
         basisSourceId: basisSourceId,
         kind: kind,
         sequence: sequence,
         stamp: stamp,
         digest: digest,
         normalizedSource: normalizedSource,
         outcome: outcome,
         isCurrent: isCurrent,
         receivedAt: receivedAt,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationSourceView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarIncomingPublicationSourceView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? entryId,
    _isc.UuidValue? basisSourceId = const _isc.$UndefinedUuidValue(),
    _ing1vpo7.CalendarIncomingPublicationKind? kind,
    Object? sequence = _Undefined,
    DateTime? stamp,
    String? digest,
    String? normalizedSource,
    _ireg3hht.CalendarIncomingPublicationOutcome? outcome,
    bool? isCurrent,
    DateTime? receivedAt,
  }) {
    return CalendarIncomingPublicationSourceView(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      basisSourceId: basisSourceId is _isc.UndefinedSentinel
          ? this.basisSourceId
          : basisSourceId,
      kind: kind ?? this.kind,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      digest: digest ?? this.digest,
      normalizedSource: normalizedSource ?? this.normalizedSource,
      outcome: outcome ?? this.outcome,
      isCurrent: isCurrent ?? this.isCurrent,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}
