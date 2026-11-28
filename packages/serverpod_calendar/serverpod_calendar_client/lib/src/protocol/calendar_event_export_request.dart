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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_event_export_selection.dart' as _ijug927r;

@_isc.immutable
abstract class CalendarEventExportRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventExportRequest._({
    required this.calendarId,
    required this.expectedRevision,
    required this.selection,
  });

  const factory CalendarEventExportRequest({
    required _isc.UuidValue calendarId,
    required int expectedRevision,
    required List<_ijug927r.CalendarEventExportSelection> selection,
  }) = _CalendarEventExportRequestImpl;

  factory CalendarEventExportRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventExportRequest(
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      selection: _ie4a1wrz.Protocol()
          .deserialize<List<_ijug927r.CalendarEventExportSelection>>(
            jsonSerialization['selection'],
          ),
    );
  }

  final _isc.UuidValue calendarId;

  final int expectedRevision;

  final List<_ijug927r.CalendarEventExportSelection> selection;

  /// Returns a shallow copy of this [CalendarEventExportRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventExportRequest copyWith({
    _isc.UuidValue? calendarId,
    int? expectedRevision,
    List<_ijug927r.CalendarEventExportSelection>? selection,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventExportRequest &&
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
      '__className__': 'serverpod_calendar.CalendarEventExportRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'selection': selection.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventExportRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'selection': selection.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarEventExportRequestImpl extends CalendarEventExportRequest {
  const _CalendarEventExportRequestImpl({
    required _isc.UuidValue calendarId,
    required int expectedRevision,
    required List<_ijug927r.CalendarEventExportSelection> selection,
  }) : super._(
         calendarId: calendarId,
         expectedRevision: expectedRevision,
         selection: selection,
       );

  /// Returns a shallow copy of this [CalendarEventExportRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventExportRequest copyWith({
    _isc.UuidValue? calendarId,
    int? expectedRevision,
    List<_ijug927r.CalendarEventExportSelection>? selection,
  }) {
    return CalendarEventExportRequest(
      calendarId: calendarId ?? this.calendarId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      selection:
          selection ?? this.selection.map((e0) => e0.copyWith()).toList(),
    );
  }
}
