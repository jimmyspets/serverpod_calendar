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
import 'calendar_task_export_selection.dart' as _i71mi7ri;

@_is.immutable
abstract class CalendarTaskExportRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskExportRequest._({
    required this.calendarId,
    required this.expectedRevision,
    required this.selection,
  });

  const factory CalendarTaskExportRequest({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required List<_i71mi7ri.CalendarTaskExportSelection> selection,
  }) = _CalendarTaskExportRequestImpl;

  factory CalendarTaskExportRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskExportRequest(
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      selection: _ix00hwbf.Protocol()
          .deserialize<List<_i71mi7ri.CalendarTaskExportSelection>>(
            jsonSerialization['selection'],
          ),
    );
  }

  final _is.UuidValue calendarId;

  final int expectedRevision;

  final List<_i71mi7ri.CalendarTaskExportSelection> selection;

  /// Returns a shallow copy of this [CalendarTaskExportRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskExportRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    List<_i71mi7ri.CalendarTaskExportSelection>? selection,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskExportRequest &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
            const _iss.DeepCollectionEquality().equals(
              other.selection,
              selection,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      calendarId,
      expectedRevision,
      const _iss.DeepCollectionEquality().hash(selection),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskExportRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'selection': selection.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskExportRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'selection': selection.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarTaskExportRequestImpl extends CalendarTaskExportRequest {
  const _CalendarTaskExportRequestImpl({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required List<_i71mi7ri.CalendarTaskExportSelection> selection,
  }) : super._(
         calendarId: calendarId,
         expectedRevision: expectedRevision,
         selection: selection,
       );

  /// Returns a shallow copy of this [CalendarTaskExportRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskExportRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    List<_i71mi7ri.CalendarTaskExportSelection>? selection,
  }) {
    return CalendarTaskExportRequest(
      calendarId: calendarId ?? this.calendarId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      selection:
          selection ?? this.selection.map((e0) => e0.copyWith()).toList(),
    );
  }
}
