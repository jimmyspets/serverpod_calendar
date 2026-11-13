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
abstract class CalendarIncomingPublicationApplyRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarIncomingPublicationApplyRequest._({
    required this.entryId,
    required this.sourceId,
    required this.expectedRevision,
    required this.expectedEventRevision,
    required this.commandId,
  });

  const factory CalendarIncomingPublicationApplyRequest({
    required _is.UuidValue entryId,
    required _is.UuidValue sourceId,
    required int expectedRevision,
    required int expectedEventRevision,
    required _is.UuidValue commandId,
  }) = _CalendarIncomingPublicationApplyRequestImpl;

  factory CalendarIncomingPublicationApplyRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationApplyRequest(
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      expectedEventRevision: jsonSerialization['expectedEventRevision'] as int,
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
    );
  }

  final _is.UuidValue entryId;

  final _is.UuidValue sourceId;

  final int expectedRevision;

  final int expectedEventRevision;

  final _is.UuidValue commandId;

  /// Returns a shallow copy of this [CalendarIncomingPublicationApplyRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIncomingPublicationApplyRequest copyWith({
    _is.UuidValue? entryId,
    _is.UuidValue? sourceId,
    int? expectedRevision,
    int? expectedEventRevision,
    _is.UuidValue? commandId,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationApplyRequest &&
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
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
            (identical(
                  other.expectedEventRevision,
                  expectedEventRevision,
                ) ||
                other.expectedEventRevision == expectedEventRevision) &&
            (identical(
                  other.commandId,
                  commandId,
                ) ||
                other.commandId == commandId);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      entryId,
      sourceId,
      expectedRevision,
      expectedEventRevision,
      commandId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationApplyRequest',
      'entryId': entryId.toJson(),
      'sourceId': sourceId.toJson(),
      'expectedRevision': expectedRevision,
      'expectedEventRevision': expectedEventRevision,
      'commandId': commandId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationApplyRequest',
      'entryId': entryId.toJson(),
      'sourceId': sourceId.toJson(),
      'expectedRevision': expectedRevision,
      'expectedEventRevision': expectedEventRevision,
      'commandId': commandId.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarIncomingPublicationApplyRequestImpl
    extends CalendarIncomingPublicationApplyRequest {
  const _CalendarIncomingPublicationApplyRequestImpl({
    required _is.UuidValue entryId,
    required _is.UuidValue sourceId,
    required int expectedRevision,
    required int expectedEventRevision,
    required _is.UuidValue commandId,
  }) : super._(
         entryId: entryId,
         sourceId: sourceId,
         expectedRevision: expectedRevision,
         expectedEventRevision: expectedEventRevision,
         commandId: commandId,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationApplyRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarIncomingPublicationApplyRequest copyWith({
    _is.UuidValue? entryId,
    _is.UuidValue? sourceId,
    int? expectedRevision,
    int? expectedEventRevision,
    _is.UuidValue? commandId,
  }) {
    return CalendarIncomingPublicationApplyRequest(
      entryId: entryId ?? this.entryId,
      sourceId: sourceId ?? this.sourceId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      expectedEventRevision:
          expectedEventRevision ?? this.expectedEventRevision,
      commandId: commandId ?? this.commandId,
    );
  }
}
