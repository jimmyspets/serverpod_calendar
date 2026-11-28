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
import 'calendar_task_content.dart' as _if7nbvl8;

@_is.immutable
abstract class CalendarTaskUpdateRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskUpdateRequest._({
    required this.taskId,
    required this.expectedRevision,
    required this.content,
  });

  const factory CalendarTaskUpdateRequest({
    required _is.UuidValue taskId,
    required int expectedRevision,
    required _if7nbvl8.CalendarTaskContent content,
  }) = _CalendarTaskUpdateRequestImpl;

  factory CalendarTaskUpdateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskUpdateRequest(
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      content: _ix00hwbf.Protocol().deserialize<_if7nbvl8.CalendarTaskContent>(
        jsonSerialization['content'],
      ),
    );
  }

  final _is.UuidValue taskId;

  final int expectedRevision;

  final _if7nbvl8.CalendarTaskContent content;

  /// Returns a shallow copy of this [CalendarTaskUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskUpdateRequest copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
    _if7nbvl8.CalendarTaskContent? content,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskUpdateRequest &&
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
                  other.content,
                  content,
                ) ||
                other.content == content);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      taskId,
      expectedRevision,
      content,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskUpdateRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'content': content.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskUpdateRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'content': content.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarTaskUpdateRequestImpl extends CalendarTaskUpdateRequest {
  const _CalendarTaskUpdateRequestImpl({
    required _is.UuidValue taskId,
    required int expectedRevision,
    required _if7nbvl8.CalendarTaskContent content,
  }) : super._(
         taskId: taskId,
         expectedRevision: expectedRevision,
         content: content,
       );

  /// Returns a shallow copy of this [CalendarTaskUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskUpdateRequest copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
    _if7nbvl8.CalendarTaskContent? content,
  }) {
    return CalendarTaskUpdateRequest(
      taskId: taskId ?? this.taskId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      content: content ?? this.content.copyWith(),
    );
  }
}
