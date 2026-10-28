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
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;
import 'calendar_item_text_metadata_patch.dart' as _ikwi9ryb;

@_is.immutable
abstract class CalendarTaskTextMetadataRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskTextMetadataRequest._({
    required this.taskId,
    required this.expectedRevision,
    required this.patch,
  });

  const factory CalendarTaskTextMetadataRequest({
    required _is.UuidValue taskId,
    required int expectedRevision,
    required _ikwi9ryb.CalendarItemTextMetadataPatch patch,
  }) = _CalendarTaskTextMetadataRequestImpl;

  factory CalendarTaskTextMetadataRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskTextMetadataRequest(
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      patch: _ix00hwbf.Protocol()
          .deserialize<_ikwi9ryb.CalendarItemTextMetadataPatch>(
            jsonSerialization['patch'],
          ),
    );
  }

  final _is.UuidValue taskId;

  final int expectedRevision;

  final _ikwi9ryb.CalendarItemTextMetadataPatch patch;

  /// Returns a shallow copy of this [CalendarTaskTextMetadataRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskTextMetadataRequest copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
    _ikwi9ryb.CalendarItemTextMetadataPatch? patch,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskTextMetadataRequest &&
            (identical(
                  other.taskId,
                  taskId,
                ) ||
                other.taskId == taskId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
            (identical(
                  other.patch,
                  patch,
                ) ||
                other.patch == patch);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      taskId,
      expectedRevision,
      patch,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskTextMetadataRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'patch': patch.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskTextMetadataRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'patch': patch.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarTaskTextMetadataRequestImpl
    extends CalendarTaskTextMetadataRequest {
  const _CalendarTaskTextMetadataRequestImpl({
    required _is.UuidValue taskId,
    required int expectedRevision,
    required _ikwi9ryb.CalendarItemTextMetadataPatch patch,
  }) : super._(
         taskId: taskId,
         expectedRevision: expectedRevision,
         patch: patch,
       );

  /// Returns a shallow copy of this [CalendarTaskTextMetadataRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskTextMetadataRequest copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
    _ikwi9ryb.CalendarItemTextMetadataPatch? patch,
  }) {
    return CalendarTaskTextMetadataRequest(
      taskId: taskId ?? this.taskId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      patch: patch ?? this.patch.copyWith(),
    );
  }
}
