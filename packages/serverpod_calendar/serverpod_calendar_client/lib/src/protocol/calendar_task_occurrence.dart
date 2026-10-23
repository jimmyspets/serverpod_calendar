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
import 'calendar_event_civil.dart' as _i1bb5k1r;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_task_progress.dart' as _ikcsq95s;

@_isc.immutable
abstract class CalendarTaskOccurrence
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskOccurrence._({
    required this.originalStart,
    this.startUtc,
    this.dueDate,
    this.dueUtc,
    required this.progress,
  });

  const factory CalendarTaskOccurrence({
    required _ieswiaty.CalendarEventTiming originalStart,
    DateTime? startUtc,
    _i1bb5k1r.CalendarEventCivil? dueDate,
    DateTime? dueUtc,
    required _ikcsq95s.CalendarTaskProgress progress,
  }) = _CalendarTaskOccurrenceImpl;

  factory CalendarTaskOccurrence.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskOccurrence(
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      startUtc: jsonSerialization['startUtc'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['startUtc']),
      dueDate: jsonSerialization['dueDate'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['dueDate'],
            ),
      dueUtc: jsonSerialization['dueUtc'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['dueUtc']),
      progress: _ie4a1wrz.Protocol()
          .deserialize<_ikcsq95s.CalendarTaskProgress>(
            jsonSerialization['progress'],
          ),
    );
  }

  final _ieswiaty.CalendarEventTiming originalStart;

  final DateTime? startUtc;

  final _i1bb5k1r.CalendarEventCivil? dueDate;

  final DateTime? dueUtc;

  final _ikcsq95s.CalendarTaskProgress progress;

  /// Returns a shallow copy of this [CalendarTaskOccurrence]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskOccurrence copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    DateTime? startUtc,
    _i1bb5k1r.CalendarEventCivil? dueDate,
    DateTime? dueUtc,
    _ikcsq95s.CalendarTaskProgress? progress,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskOccurrence &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.startUtc,
                  startUtc,
                ) ||
                other.startUtc == startUtc) &&
            (identical(
                  other.dueDate,
                  dueDate,
                ) ||
                other.dueDate == dueDate) &&
            (identical(
                  other.dueUtc,
                  dueUtc,
                ) ||
                other.dueUtc == dueUtc) &&
            (identical(
                  other.progress,
                  progress,
                ) ||
                other.progress == progress);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      originalStart,
      startUtc,
      dueDate,
      dueUtc,
      progress,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrence',
      'originalStart': originalStart.toJson(),
      if (startUtc != null) 'startUtc': startUtc?.toJson(),
      if (dueDate != null) 'dueDate': dueDate?.toJson(),
      if (dueUtc != null) 'dueUtc': dueUtc?.toJson(),
      'progress': progress.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrence',
      'originalStart': originalStart.toJsonForProtocol(),
      if (startUtc != null) 'startUtc': startUtc?.toJson(),
      if (dueDate != null) 'dueDate': dueDate?.toJsonForProtocol(),
      if (dueUtc != null) 'dueUtc': dueUtc?.toJson(),
      'progress': progress.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskOccurrenceImpl extends CalendarTaskOccurrence {
  const _CalendarTaskOccurrenceImpl({
    required _ieswiaty.CalendarEventTiming originalStart,
    DateTime? startUtc,
    _i1bb5k1r.CalendarEventCivil? dueDate,
    DateTime? dueUtc,
    required _ikcsq95s.CalendarTaskProgress progress,
  }) : super._(
         originalStart: originalStart,
         startUtc: startUtc,
         dueDate: dueDate,
         dueUtc: dueUtc,
         progress: progress,
       );

  /// Returns a shallow copy of this [CalendarTaskOccurrence]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskOccurrence copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    Object? startUtc = _Undefined,
    Object? dueDate = _Undefined,
    Object? dueUtc = _Undefined,
    _ikcsq95s.CalendarTaskProgress? progress,
  }) {
    return CalendarTaskOccurrence(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      startUtc: startUtc is DateTime? ? startUtc : this.startUtc,
      dueDate: dueDate is _i1bb5k1r.CalendarEventCivil?
          ? dueDate
          : this.dueDate?.copyWith(),
      dueUtc: dueUtc is DateTime? ? dueUtc : this.dueUtc,
      progress: progress ?? this.progress.copyWith(),
    );
  }
}
