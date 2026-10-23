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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'calendar_task_status.dart' as _iiahrdev;

@_isc.immutable
abstract class CalendarTaskProgress
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskProgress._({
    _iiahrdev.CalendarTaskStatus? status,
    int? percentComplete,
    this.completedAt,
  }) : status = status ?? _iiahrdev.CalendarTaskStatus.needsAction,
       percentComplete = percentComplete ?? 0;

  const factory CalendarTaskProgress({
    _iiahrdev.CalendarTaskStatus? status,
    int? percentComplete,
    DateTime? completedAt,
  }) = _CalendarTaskProgressImpl;

  factory CalendarTaskProgress.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskProgress(
      status: jsonSerialization['status'] == null
          ? null
          : _iiahrdev.CalendarTaskStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      percentComplete: jsonSerialization['percentComplete'] as int?,
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
    );
  }

  final _iiahrdev.CalendarTaskStatus status;

  final int percentComplete;

  final DateTime? completedAt;

  /// Returns a shallow copy of this [CalendarTaskProgress]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskProgress copyWith({
    _iiahrdev.CalendarTaskStatus? status,
    int? percentComplete,
    DateTime? completedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskProgress &&
            (identical(
                  other.status,
                  status,
                ) ||
                other.status == status) &&
            (identical(
                  other.percentComplete,
                  percentComplete,
                ) ||
                other.percentComplete == percentComplete) &&
            (identical(
                  other.completedAt,
                  completedAt,
                ) ||
                other.completedAt == completedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      status,
      percentComplete,
      completedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskProgress',
      'status': status.toJson(),
      'percentComplete': percentComplete,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskProgress',
      'status': status.toJson(),
      'percentComplete': percentComplete,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskProgressImpl extends CalendarTaskProgress {
  const _CalendarTaskProgressImpl({
    _iiahrdev.CalendarTaskStatus? status,
    int? percentComplete,
    DateTime? completedAt,
  }) : super._(
         status: status,
         percentComplete: percentComplete,
         completedAt: completedAt,
       );

  /// Returns a shallow copy of this [CalendarTaskProgress]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskProgress copyWith({
    _iiahrdev.CalendarTaskStatus? status,
    int? percentComplete,
    Object? completedAt = _Undefined,
  }) {
    return CalendarTaskProgress(
      status: status ?? this.status,
      percentComplete: percentComplete ?? this.percentComplete,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
    );
  }
}
