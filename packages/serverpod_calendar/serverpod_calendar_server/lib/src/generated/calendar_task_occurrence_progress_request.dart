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
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_task_progress_action.dart' as _i6s7yrua;

@_is.immutable
abstract class CalendarTaskOccurrenceProgressRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskOccurrenceProgressRequest._({
    required this.taskId,
    required this.expectedRevision,
    required this.originalStart,
    required this.action,
    this.percentComplete,
  });

  const factory CalendarTaskOccurrenceProgressRequest({
    required _is.UuidValue taskId,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _i6s7yrua.CalendarTaskProgressAction action,
    int? percentComplete,
  }) = _CalendarTaskOccurrenceProgressRequestImpl;

  factory CalendarTaskOccurrenceProgressRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskOccurrenceProgressRequest(
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      action: _i6s7yrua.CalendarTaskProgressAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      percentComplete: jsonSerialization['percentComplete'] as int?,
    );
  }

  final _is.UuidValue taskId;

  final int expectedRevision;

  final _ieswiaty.CalendarEventTiming originalStart;

  final _i6s7yrua.CalendarTaskProgressAction action;

  final int? percentComplete;

  /// Returns a shallow copy of this [CalendarTaskOccurrenceProgressRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskOccurrenceProgressRequest copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
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
            other is CalendarTaskOccurrenceProgressRequest &&
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
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
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
      originalStart,
      action,
      percentComplete,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarTaskOccurrenceProgressRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJson(),
      'action': action.toJson(),
      if (percentComplete != null) 'percentComplete': percentComplete,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarTaskOccurrenceProgressRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJsonForProtocol(),
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

class _CalendarTaskOccurrenceProgressRequestImpl
    extends CalendarTaskOccurrenceProgressRequest {
  const _CalendarTaskOccurrenceProgressRequestImpl({
    required _is.UuidValue taskId,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _i6s7yrua.CalendarTaskProgressAction action,
    int? percentComplete,
  }) : super._(
         taskId: taskId,
         expectedRevision: expectedRevision,
         originalStart: originalStart,
         action: action,
         percentComplete: percentComplete,
       );

  /// Returns a shallow copy of this [CalendarTaskOccurrenceProgressRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskOccurrenceProgressRequest copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    _i6s7yrua.CalendarTaskProgressAction? action,
    Object? percentComplete = _Undefined,
  }) {
    return CalendarTaskOccurrenceProgressRequest(
      taskId: taskId ?? this.taskId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      action: action ?? this.action,
      percentComplete: percentComplete is int?
          ? percentComplete
          : this.percentComplete,
    );
  }
}
