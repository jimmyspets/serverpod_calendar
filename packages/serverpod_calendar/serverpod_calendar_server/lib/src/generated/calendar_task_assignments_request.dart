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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_task_assignee.dart' as _ih5e3u6u;

@_is.immutable
abstract class CalendarTaskAssignmentsRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskAssignmentsRequest._({
    required this.taskId,
    required this.expectedRevision,
    required this.assignees,
  });

  const factory CalendarTaskAssignmentsRequest({
    required _is.UuidValue taskId,
    required int expectedRevision,
    required List<_ih5e3u6u.CalendarTaskAssignee> assignees,
  }) = _CalendarTaskAssignmentsRequestImpl;

  factory CalendarTaskAssignmentsRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskAssignmentsRequest(
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      assignees: _ix00hwbf.Protocol()
          .deserialize<List<_ih5e3u6u.CalendarTaskAssignee>>(
            jsonSerialization['assignees'],
          ),
    );
  }

  final _is.UuidValue taskId;

  final int expectedRevision;

  final List<_ih5e3u6u.CalendarTaskAssignee> assignees;

  /// Returns a shallow copy of this [CalendarTaskAssignmentsRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskAssignmentsRequest copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
    List<_ih5e3u6u.CalendarTaskAssignee>? assignees,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskAssignmentsRequest &&
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
            const _iss.DeepCollectionEquality().equals(
              other.assignees,
              assignees,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      taskId,
      expectedRevision,
      const _iss.DeepCollectionEquality().hash(assignees),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskAssignmentsRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'assignees': assignees.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskAssignmentsRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'assignees': assignees.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarTaskAssignmentsRequestImpl
    extends CalendarTaskAssignmentsRequest {
  const _CalendarTaskAssignmentsRequestImpl({
    required _is.UuidValue taskId,
    required int expectedRevision,
    required List<_ih5e3u6u.CalendarTaskAssignee> assignees,
  }) : super._(
         taskId: taskId,
         expectedRevision: expectedRevision,
         assignees: assignees,
       );

  /// Returns a shallow copy of this [CalendarTaskAssignmentsRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskAssignmentsRequest copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
    List<_ih5e3u6u.CalendarTaskAssignee>? assignees,
  }) {
    return CalendarTaskAssignmentsRequest(
      taskId: taskId ?? this.taskId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      assignees:
          assignees ?? this.assignees.map((e0) => e0.copyWith()).toList(),
    );
  }
}
