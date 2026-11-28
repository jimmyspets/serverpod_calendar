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
import 'calendar_task_progress_action.dart' as _i6s7yrua;

@_is.immutable
abstract class CalendarTaskProgressRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskProgressRequest._({
    required this.taskId,
    required this.expectedRevision,
    required this.action,
    this.percentComplete,
  });

  const factory CalendarTaskProgressRequest({
    required _is.UuidValue taskId,
    required int expectedRevision,
    required _i6s7yrua.CalendarTaskProgressAction action,
    int? percentComplete,
  }) = _CalendarTaskProgressRequestImpl;

  factory CalendarTaskProgressRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskProgressRequest(
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      action: _i6s7yrua.CalendarTaskProgressAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      percentComplete: jsonSerialization['percentComplete'] as int?,
    );
  }

  final _is.UuidValue taskId;

  final int expectedRevision;

  final _i6s7yrua.CalendarTaskProgressAction action;

  final int? percentComplete;

  /// Returns a shallow copy of this [CalendarTaskProgressRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskProgressRequest copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
    _i6s7yrua.CalendarTaskProgressAction? action,
    int? percentComplete,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskProgressRequest &&
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
                  other.action,
                  action,
                ) ||
                other.action == action) &&
            (identical(
                  other.percentComplete,
                  percentComplete,
                ) ||
                other.percentComplete == percentComplete);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      taskId,
      expectedRevision,
      action,
      percentComplete,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskProgressRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'action': action.toJson(),
      if (percentComplete != null) 'percentComplete': percentComplete,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskProgressRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'action': action.toJson(),
      if (percentComplete != null) 'percentComplete': percentComplete,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskProgressRequestImpl extends CalendarTaskProgressRequest {
  const _CalendarTaskProgressRequestImpl({
    required _is.UuidValue taskId,
    required int expectedRevision,
    required _i6s7yrua.CalendarTaskProgressAction action,
    int? percentComplete,
  }) : super._(
         taskId: taskId,
         expectedRevision: expectedRevision,
         action: action,
         percentComplete: percentComplete,
       );

  /// Returns a shallow copy of this [CalendarTaskProgressRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskProgressRequest copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
    _i6s7yrua.CalendarTaskProgressAction? action,
    Object? percentComplete = _Undefined,
  }) {
    return CalendarTaskProgressRequest(
      taskId: taskId ?? this.taskId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      action: action ?? this.action,
      percentComplete: percentComplete is int?
          ? percentComplete
          : this.percentComplete,
    );
  }
}
