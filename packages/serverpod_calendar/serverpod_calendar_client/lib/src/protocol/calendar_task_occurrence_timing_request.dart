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
import 'package:serverpod_calendar_client/src/protocol/protocol.dart'
    as _ie4a1wrz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_task_timing.dart' as _i9h8y8lg;

@_isc.immutable
abstract class CalendarTaskOccurrenceTimingRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskOccurrenceTimingRequest._({
    required this.taskId,
    required this.expectedRevision,
    required this.originalStart,
    this.replacement,
  });

  const factory CalendarTaskOccurrenceTimingRequest({
    required _isc.UuidValue taskId,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    _i9h8y8lg.CalendarTaskTiming? replacement,
  }) = _CalendarTaskOccurrenceTimingRequestImpl;

  factory CalendarTaskOccurrenceTimingRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskOccurrenceTimingRequest(
      taskId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      replacement: jsonSerialization['replacement'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i9h8y8lg.CalendarTaskTiming>(
              jsonSerialization['replacement'],
            ),
    );
  }

  final _isc.UuidValue taskId;

  final int expectedRevision;

  final _ieswiaty.CalendarEventTiming originalStart;

  final _i9h8y8lg.CalendarTaskTiming? replacement;

  /// Returns a shallow copy of this [CalendarTaskOccurrenceTimingRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskOccurrenceTimingRequest copyWith({
    _isc.UuidValue? taskId,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    _i9h8y8lg.CalendarTaskTiming? replacement,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskOccurrenceTimingRequest &&
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
                  other.replacement,
                  replacement,
                ) ||
                other.replacement == replacement);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      taskId,
      expectedRevision,
      originalStart,
      replacement,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrenceTimingRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJson(),
      if (replacement != null) 'replacement': replacement?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrenceTimingRequest',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJsonForProtocol(),
      if (replacement != null) 'replacement': replacement?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskOccurrenceTimingRequestImpl
    extends CalendarTaskOccurrenceTimingRequest {
  const _CalendarTaskOccurrenceTimingRequestImpl({
    required _isc.UuidValue taskId,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    _i9h8y8lg.CalendarTaskTiming? replacement,
  }) : super._(
         taskId: taskId,
         expectedRevision: expectedRevision,
         originalStart: originalStart,
         replacement: replacement,
       );

  /// Returns a shallow copy of this [CalendarTaskOccurrenceTimingRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskOccurrenceTimingRequest copyWith({
    _isc.UuidValue? taskId,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    Object? replacement = _Undefined,
  }) {
    return CalendarTaskOccurrenceTimingRequest(
      taskId: taskId ?? this.taskId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      replacement: replacement is _i9h8y8lg.CalendarTaskTiming?
          ? replacement
          : this.replacement?.copyWith(),
    );
  }
}
