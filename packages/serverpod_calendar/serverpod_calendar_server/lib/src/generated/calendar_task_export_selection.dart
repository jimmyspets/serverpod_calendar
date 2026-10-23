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
abstract class CalendarTaskExportSelection
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskExportSelection._({
    required this.taskId,
    required this.expectedRevision,
  });

  const factory CalendarTaskExportSelection({
    required _is.UuidValue taskId,
    required int expectedRevision,
  }) = _CalendarTaskExportSelectionImpl;

  factory CalendarTaskExportSelection.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskExportSelection(
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
    );
  }

  final _is.UuidValue taskId;

  final int expectedRevision;

  /// Returns a shallow copy of this [CalendarTaskExportSelection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskExportSelection copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskExportSelection &&
            (identical(
                  other.taskId,
                  taskId,
                ) ||
                other.taskId == taskId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      taskId,
      expectedRevision,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskExportSelection',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskExportSelection',
      'taskId': taskId.toJson(),
      'expectedRevision': expectedRevision,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarTaskExportSelectionImpl extends CalendarTaskExportSelection {
  const _CalendarTaskExportSelectionImpl({
    required _is.UuidValue taskId,
    required int expectedRevision,
  }) : super._(
         taskId: taskId,
         expectedRevision: expectedRevision,
       );

  /// Returns a shallow copy of this [CalendarTaskExportSelection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskExportSelection copyWith({
    _is.UuidValue? taskId,
    int? expectedRevision,
  }) {
    return CalendarTaskExportSelection(
      taskId: taskId ?? this.taskId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
    );
  }
}
