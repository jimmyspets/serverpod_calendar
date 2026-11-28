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
abstract class CalendarFreeBusyReplyRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarFreeBusyReplyRequest._({
    required this.commandId,
    required this.sourceId,
    required this.expectedSourceRevision,
    required this.expectedReplyRevision,
  });

  const factory CalendarFreeBusyReplyRequest({
    required _is.UuidValue commandId,
    required _is.UuidValue sourceId,
    required int expectedSourceRevision,
    required int expectedReplyRevision,
  }) = _CalendarFreeBusyReplyRequestImpl;

  factory CalendarFreeBusyReplyRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyReplyRequest(
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      expectedSourceRevision:
          jsonSerialization['expectedSourceRevision'] as int,
      expectedReplyRevision: jsonSerialization['expectedReplyRevision'] as int,
    );
  }

  final _is.UuidValue commandId;

  final _is.UuidValue sourceId;

  final int expectedSourceRevision;

  final int expectedReplyRevision;

  /// Returns a shallow copy of this [CalendarFreeBusyReplyRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyReplyRequest copyWith({
    _is.UuidValue? commandId,
    _is.UuidValue? sourceId,
    int? expectedSourceRevision,
    int? expectedReplyRevision,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFreeBusyReplyRequest &&
            (identical(
                  other.commandId,
                  commandId,
                ) ||
                other.commandId == commandId) &&
            (identical(
                  other.sourceId,
                  sourceId,
                ) ||
                other.sourceId == sourceId) &&
            (identical(
                  other.expectedSourceRevision,
                  expectedSourceRevision,
                ) ||
                other.expectedSourceRevision == expectedSourceRevision) &&
            (identical(
                  other.expectedReplyRevision,
                  expectedReplyRevision,
                ) ||
                other.expectedReplyRevision == expectedReplyRevision);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      commandId,
      sourceId,
      expectedSourceRevision,
      expectedReplyRevision,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyReplyRequest',
      'commandId': commandId.toJson(),
      'sourceId': sourceId.toJson(),
      'expectedSourceRevision': expectedSourceRevision,
      'expectedReplyRevision': expectedReplyRevision,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyReplyRequest',
      'commandId': commandId.toJson(),
      'sourceId': sourceId.toJson(),
      'expectedSourceRevision': expectedSourceRevision,
      'expectedReplyRevision': expectedReplyRevision,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyReplyRequestImpl extends CalendarFreeBusyReplyRequest {
  const _CalendarFreeBusyReplyRequestImpl({
    required _is.UuidValue commandId,
    required _is.UuidValue sourceId,
    required int expectedSourceRevision,
    required int expectedReplyRevision,
  }) : super._(
         commandId: commandId,
         sourceId: sourceId,
         expectedSourceRevision: expectedSourceRevision,
         expectedReplyRevision: expectedReplyRevision,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyReplyRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyReplyRequest copyWith({
    _is.UuidValue? commandId,
    _is.UuidValue? sourceId,
    int? expectedSourceRevision,
    int? expectedReplyRevision,
  }) {
    return CalendarFreeBusyReplyRequest(
      commandId: commandId ?? this.commandId,
      sourceId: sourceId ?? this.sourceId,
      expectedSourceRevision:
          expectedSourceRevision ?? this.expectedSourceRevision,
      expectedReplyRevision:
          expectedReplyRevision ?? this.expectedReplyRevision,
    );
  }
}
