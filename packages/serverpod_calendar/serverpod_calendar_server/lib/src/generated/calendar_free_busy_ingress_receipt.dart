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

@_is.immutable
abstract class CalendarFreeBusyIngressReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarFreeBusyIngressReceipt._({
    required this.id,
    required this.sourceId,
    this.headId,
    required this.outcome,
    this.sourceRevision,
    required this.receivedAt,
  });

  const factory CalendarFreeBusyIngressReceipt({
    required _is.UuidValue id,
    required _is.UuidValue sourceId,
    _is.UuidValue? headId,
    required String outcome,
    int? sourceRevision,
    required DateTime receivedAt,
  }) = _CalendarFreeBusyIngressReceiptImpl;

  factory CalendarFreeBusyIngressReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyIngressReceipt(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      headId: jsonSerialization['headId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['headId']),
      outcome: jsonSerialization['outcome'] as String,
      sourceRevision: jsonSerialization['sourceRevision'] as int?,
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  final _is.UuidValue id;

  final _is.UuidValue sourceId;

  final _is.UuidValue? headId;

  final String outcome;

  final int? sourceRevision;

  final DateTime receivedAt;

  /// Returns a shallow copy of this [CalendarFreeBusyIngressReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyIngressReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? sourceId,
    _is.UuidValue? headId = const _is.$UndefinedUuidValue(),
    String? outcome,
    int? sourceRevision,
    DateTime? receivedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFreeBusyIngressReceipt &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.sourceId,
                  sourceId,
                ) ||
                other.sourceId == sourceId) &&
            (identical(
                  other.headId,
                  headId,
                ) ||
                other.headId == headId) &&
            (identical(
                  other.outcome,
                  outcome,
                ) ||
                other.outcome == outcome) &&
            (identical(
                  other.sourceRevision,
                  sourceRevision,
                ) ||
                other.sourceRevision == sourceRevision) &&
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
      sourceId,
      headId,
      outcome,
      sourceRevision,
      receivedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyIngressReceipt',
      'id': id.toJson(),
      'sourceId': sourceId.toJson(),
      if (headId != null) 'headId': headId?.toJson(),
      'outcome': outcome,
      if (sourceRevision != null) 'sourceRevision': sourceRevision,
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyIngressReceipt',
      'id': id.toJson(),
      'sourceId': sourceId.toJson(),
      if (headId != null) 'headId': headId?.toJson(),
      'outcome': outcome,
      if (sourceRevision != null) 'sourceRevision': sourceRevision,
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFreeBusyIngressReceiptImpl
    extends CalendarFreeBusyIngressReceipt {
  const _CalendarFreeBusyIngressReceiptImpl({
    required _is.UuidValue id,
    required _is.UuidValue sourceId,
    _is.UuidValue? headId,
    required String outcome,
    int? sourceRevision,
    required DateTime receivedAt,
  }) : super._(
         id: id,
         sourceId: sourceId,
         headId: headId,
         outcome: outcome,
         sourceRevision: sourceRevision,
         receivedAt: receivedAt,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyIngressReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyIngressReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? sourceId,
    _is.UuidValue? headId = const _is.$UndefinedUuidValue(),
    String? outcome,
    Object? sourceRevision = _Undefined,
    DateTime? receivedAt,
  }) {
    return CalendarFreeBusyIngressReceipt(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      headId: headId is _is.UndefinedSentinel ? this.headId : headId,
      outcome: outcome ?? this.outcome,
      sourceRevision: sourceRevision is int?
          ? sourceRevision
          : this.sourceRevision,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}
