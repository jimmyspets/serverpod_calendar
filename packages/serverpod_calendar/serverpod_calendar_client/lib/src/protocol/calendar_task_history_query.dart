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

@_isc.immutable
abstract class CalendarTaskHistoryQuery
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskHistoryQuery._({
    required this.taskId,
    required this.expectedRevision,
    required this.originalStart,
    required this.pageSize,
    this.cursor,
  });

  const factory CalendarTaskHistoryQuery({
    required _isc.UuidValue taskId,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required int pageSize,
    String? cursor,
  }) = _CalendarTaskHistoryQueryImpl;

  factory CalendarTaskHistoryQuery.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskHistoryQuery(
      taskId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      pageSize: jsonSerialization['pageSize'] as int,
      cursor: jsonSerialization['cursor'] as String?,
    );
  }

  final _isc.UuidValue taskId;

  final int expectedRevision;

  final _ieswiaty.CalendarEventTiming originalStart;

  final int pageSize;

  final String? cursor;

  /// Returns a shallow copy of this [CalendarTaskHistoryQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskHistoryQuery copyWith({
    _isc.UuidValue? taskId,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    int? pageSize,
    String? cursor,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskHistoryQuery &&
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
                  other.pageSize,
                  pageSize,
                ) ||
                other.pageSize == pageSize) &&
            (identical(
                  other.cursor,
                  cursor,
                ) ||
                other.cursor == cursor);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      taskId,
      expectedRevision,
      originalStart,
      pageSize,
      cursor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskHistoryQuery',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJson(),
      'pageSize': pageSize,
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskHistoryQuery',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJsonForProtocol(),
      'pageSize': pageSize,
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskHistoryQueryImpl extends CalendarTaskHistoryQuery {
  const _CalendarTaskHistoryQueryImpl({
    required _isc.UuidValue taskId,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required int pageSize,
    String? cursor,
  }) : super._(
         taskId: taskId,
         expectedRevision: expectedRevision,
         originalStart: originalStart,
         pageSize: pageSize,
         cursor: cursor,
       );

  /// Returns a shallow copy of this [CalendarTaskHistoryQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskHistoryQuery copyWith({
    _isc.UuidValue? taskId,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    int? pageSize,
    Object? cursor = _Undefined,
  }) {
    return CalendarTaskHistoryQuery(
      taskId: taskId ?? this.taskId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      pageSize: pageSize ?? this.pageSize,
      cursor: cursor is String? ? cursor : this.cursor,
    );
  }
}
