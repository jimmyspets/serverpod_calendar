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

@_isc.immutable
abstract class CalendarInvitationReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationReceipt._({
    required this.id,
    required this.entryId,
    required this.sourceId,
    required this.outcome,
    required this.entryRevision,
    required this.receivedAt,
  });

  const factory CalendarInvitationReceipt({
    required _isc.UuidValue id,
    required _isc.UuidValue entryId,
    required _isc.UuidValue sourceId,
    required _i98zwsq8.CalendarInvitationOutcome outcome,
    required int entryRevision,
    required DateTime receivedAt,
  }) = _CalendarInvitationReceiptImpl;

  factory CalendarInvitationReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationReceipt(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entryId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      sourceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      outcome: _i98zwsq8.CalendarInvitationOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      entryRevision: jsonSerialization['entryRevision'] as int,
      receivedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  final _isc.UuidValue id;

  final _isc.UuidValue entryId;

  final _isc.UuidValue sourceId;

  final _i98zwsq8.CalendarInvitationOutcome outcome;

  final int entryRevision;

  final DateTime receivedAt;

  /// Returns a shallow copy of this [CalendarInvitationReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationReceipt copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? entryId,
    _isc.UuidValue? sourceId,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarInvitationReceiptImpl extends CalendarInvitationReceipt {
  const _CalendarInvitationReceiptImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue entryId,
    required _isc.UuidValue sourceId,
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
  @_isc.useResult
  @override
  CalendarInvitationReceipt copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? entryId,
    _isc.UuidValue? sourceId,
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
