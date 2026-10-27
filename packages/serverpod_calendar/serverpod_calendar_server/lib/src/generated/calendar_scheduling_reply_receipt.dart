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
import 'calendar_scheduling_reply_outcome.dart' as _ikqvfn4d;

@_is.immutable
abstract class CalendarSchedulingReplyReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarSchedulingReplyReceipt._({
    required this.receiptId,
    required this.sourceId,
    required this.outcome,
    required this.invitationSequence,
    this.sourceSequence,
    required this.sourceStamp,
    required this.unchanged,
  });

  const factory CalendarSchedulingReplyReceipt({
    required _is.UuidValue receiptId,
    required _is.UuidValue sourceId,
    required _ikqvfn4d.CalendarSchedulingReplyOutcome outcome,
    required int invitationSequence,
    int? sourceSequence,
    required DateTime sourceStamp,
    required bool unchanged,
  }) = _CalendarSchedulingReplyReceiptImpl;

  factory CalendarSchedulingReplyReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingReplyReceipt(
      receiptId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['receiptId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      outcome: _ikqvfn4d.CalendarSchedulingReplyOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      invitationSequence: jsonSerialization['invitationSequence'] as int,
      sourceSequence: jsonSerialization['sourceSequence'] as int?,
      sourceStamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['sourceStamp'],
      ),
      unchanged: _is.BoolJsonExtension.fromJson(jsonSerialization['unchanged']),
    );
  }

  final _is.UuidValue receiptId;

  final _is.UuidValue sourceId;

  final _ikqvfn4d.CalendarSchedulingReplyOutcome outcome;

  final int invitationSequence;

  final int? sourceSequence;

  final DateTime sourceStamp;

  final bool unchanged;

  /// Returns a shallow copy of this [CalendarSchedulingReplyReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingReplyReceipt copyWith({
    _is.UuidValue? receiptId,
    _is.UuidValue? sourceId,
    _ikqvfn4d.CalendarSchedulingReplyOutcome? outcome,
    int? invitationSequence,
    int? sourceSequence,
    DateTime? sourceStamp,
    bool? unchanged,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingReplyReceipt &&
            (identical(
                  other.receiptId,
                  receiptId,
                ) ||
                other.receiptId == receiptId) &&
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
                  other.sourceStamp,
                  sourceStamp,
                ) ||
                other.sourceStamp == sourceStamp) &&
            (identical(
                  other.unchanged,
                  unchanged,
                ) ||
                other.unchanged == unchanged);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      receiptId,
      sourceId,
      outcome,
      invitationSequence,
      sourceSequence,
      sourceStamp,
      unchanged,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingReplyReceipt',
      'receiptId': receiptId.toJson(),
      'sourceId': sourceId.toJson(),
      'outcome': outcome.toJson(),
      'invitationSequence': invitationSequence,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      'sourceStamp': sourceStamp.toJson(),
      'unchanged': unchanged,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingReplyReceipt',
      'receiptId': receiptId.toJson(),
      'sourceId': sourceId.toJson(),
      'outcome': outcome.toJson(),
      'invitationSequence': invitationSequence,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      'sourceStamp': sourceStamp.toJson(),
      'unchanged': unchanged,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingReplyReceiptImpl
    extends CalendarSchedulingReplyReceipt {
  const _CalendarSchedulingReplyReceiptImpl({
    required _is.UuidValue receiptId,
    required _is.UuidValue sourceId,
    required _ikqvfn4d.CalendarSchedulingReplyOutcome outcome,
    required int invitationSequence,
    int? sourceSequence,
    required DateTime sourceStamp,
    required bool unchanged,
  }) : super._(
         receiptId: receiptId,
         sourceId: sourceId,
         outcome: outcome,
         invitationSequence: invitationSequence,
         sourceSequence: sourceSequence,
         sourceStamp: sourceStamp,
         unchanged: unchanged,
       );

  /// Returns a shallow copy of this [CalendarSchedulingReplyReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingReplyReceipt copyWith({
    _is.UuidValue? receiptId,
    _is.UuidValue? sourceId,
    _ikqvfn4d.CalendarSchedulingReplyOutcome? outcome,
    int? invitationSequence,
    Object? sourceSequence = _Undefined,
    DateTime? sourceStamp,
    bool? unchanged,
  }) {
    return CalendarSchedulingReplyReceipt(
      receiptId: receiptId ?? this.receiptId,
      sourceId: sourceId ?? this.sourceId,
      outcome: outcome ?? this.outcome,
      invitationSequence: invitationSequence ?? this.invitationSequence,
      sourceSequence: sourceSequence is int?
          ? sourceSequence
          : this.sourceSequence,
      sourceStamp: sourceStamp ?? this.sourceStamp,
      unchanged: unchanged ?? this.unchanged,
    );
  }
}
