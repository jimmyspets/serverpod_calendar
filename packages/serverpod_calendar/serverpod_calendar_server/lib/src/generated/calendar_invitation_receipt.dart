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
abstract class CalendarInvitationReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarInvitationReceipt._({
    required this.id,
    required this.entryId,
    required this.sourceId,
    required this.outcome,
    required this.entryRevision,
    required this.receivedAt,
  });

  const factory CalendarInvitationReceipt({
    required _is.UuidValue id,
    required _is.UuidValue entryId,
    required _is.UuidValue sourceId,
    required _i98zwsq8.CalendarInvitationOutcome outcome,
    required int entryRevision,
    required DateTime receivedAt,
  }) = _CalendarInvitationReceiptImpl;

  factory CalendarInvitationReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationReceipt(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      outcome: _i98zwsq8.CalendarInvitationOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      entryRevision: jsonSerialization['entryRevision'] as int,
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  final _is.UuidValue id;

  final _is.UuidValue entryId;

  final _is.UuidValue sourceId;

  final _i98zwsq8.CalendarInvitationOutcome outcome;

  final int entryRevision;

  final DateTime receivedAt;

  /// Returns a shallow copy of this [CalendarInvitationReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? entryId,
    _is.UuidValue? sourceId,
    _i98zwsq8.CalendarInvitationOutcome? outcome,
    int? entryRevision,
    DateTime? receivedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationReceipt &&
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
                  other.sourceId,
                  sourceId,
                ) ||
                other.sourceId == sourceId) &&
            (identical(
                  other.outcome,
                  outcome,
                ) ||
                other.outcome == outcome) &&
            (identical(
                  other.entryRevision,
                  entryRevision,
                ) ||
                other.entryRevision == entryRevision) &&
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
      sourceId,
      outcome,
      entryRevision,
      receivedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationReceipt',
      'id': id.toJson(),
      'entryId': entryId.toJson(),
      'sourceId': sourceId.toJson(),
      'outcome': outcome.toJson(),
      'entryRevision': entryRevision,
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationReceipt',
      'id': id.toJson(),
      'entryId': entryId.toJson(),
      'sourceId': sourceId.toJson(),
      'outcome': outcome.toJson(),
      'entryRevision': entryRevision,
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationReceiptImpl extends CalendarInvitationReceipt {
  const _CalendarInvitationReceiptImpl({
    required _is.UuidValue id,
    required _is.UuidValue entryId,
    required _is.UuidValue sourceId,
    required _i98zwsq8.CalendarInvitationOutcome outcome,
    required int entryRevision,
    required DateTime receivedAt,
  }) : super._(
         id: id,
         entryId: entryId,
         sourceId: sourceId,
         outcome: outcome,
         entryRevision: entryRevision,
         receivedAt: receivedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? entryId,
    _is.UuidValue? sourceId,
    _i98zwsq8.CalendarInvitationOutcome? outcome,
    int? entryRevision,
    DateTime? receivedAt,
  }) {
    return CalendarInvitationReceipt(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      sourceId: sourceId ?? this.sourceId,
      outcome: outcome ?? this.outcome,
      entryRevision: entryRevision ?? this.entryRevision,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}
