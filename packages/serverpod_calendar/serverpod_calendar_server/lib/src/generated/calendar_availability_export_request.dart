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
import 'calendar_availability_export_selection.dart' as _incs3y0d;

@_is.immutable
abstract class CalendarAvailabilityExportRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityExportRequest._({
    required this.calendarId,
    required this.expectedRevision,
    required this.selection,
  });

  const factory CalendarAvailabilityExportRequest({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required List<_incs3y0d.CalendarAvailabilityExportSelection> selection,
  }) = _CalendarAvailabilityExportRequestImpl;

  factory CalendarAvailabilityExportRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityExportRequest(
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      selection: _ix00hwbf.Protocol()
          .deserialize<List<_incs3y0d.CalendarAvailabilityExportSelection>>(
            jsonSerialization['selection'],
          ),
    );
  }

  final _is.UuidValue calendarId;

  final int expectedRevision;

  final List<_incs3y0d.CalendarAvailabilityExportSelection> selection;

  /// Returns a shallow copy of this [CalendarAvailabilityExportRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityExportRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    List<_incs3y0d.CalendarAvailabilityExportSelection>? selection,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityExportRequest &&
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
      '__className__': 'serverpod_calendar.CalendarAvailabilityExportRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'selection': selection.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityExportRequest',
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

class _CalendarAvailabilityExportRequestImpl
    extends CalendarAvailabilityExportRequest {
  const _CalendarAvailabilityExportRequestImpl({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required List<_incs3y0d.CalendarAvailabilityExportSelection> selection,
  }) : super._(
         calendarId: calendarId,
         expectedRevision: expectedRevision,
         selection: selection,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityExportRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityExportRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    List<_incs3y0d.CalendarAvailabilityExportSelection>? selection,
  }) {
    return CalendarAvailabilityExportRequest(
      calendarId: calendarId ?? this.calendarId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      selection:
          selection ?? this.selection.map((e0) => e0.copyWith()).toList(),
    );
  }
}
