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
abstract class CalendarSchedulingOccurrenceRestoreRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarSchedulingOccurrenceRestoreRequest._({
    required this.eventId,
    required this.expectedRevision,
    required this.commandId,
    required this.originalStart,
  });

  const factory CalendarSchedulingOccurrenceRestoreRequest({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    required _isc.UuidValue commandId,
    required _ieswiaty.CalendarEventTiming originalStart,
  }) = _CalendarSchedulingOccurrenceRestoreRequestImpl;

  factory CalendarSchedulingOccurrenceRestoreRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingOccurrenceRestoreRequest(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      commandId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
    );
  }

  final _isc.UuidValue eventId;

  final int expectedRevision;

  final _isc.UuidValue commandId;

  final _ieswiaty.CalendarEventTiming originalStart;

  /// Returns a shallow copy of this [CalendarSchedulingOccurrenceRestoreRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarSchedulingOccurrenceRestoreRequest copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _isc.UuidValue? commandId,
    _ieswiaty.CalendarEventTiming? originalStart,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingOccurrenceRestoreRequest &&
            (identical(
                  other.eventId,
                  eventId,
                ) ||
                other.eventId == eventId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
            (identical(
                  other.commandId,
                  commandId,
                ) ||
                other.commandId == commandId) &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      expectedRevision,
      commandId,
      originalStart,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarSchedulingOccurrenceRestoreRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'commandId': commandId.toJson(),
      'originalStart': originalStart.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarSchedulingOccurrenceRestoreRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'commandId': commandId.toJson(),
      'originalStart': originalStart.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarSchedulingOccurrenceRestoreRequestImpl
    extends CalendarSchedulingOccurrenceRestoreRequest {
  const _CalendarSchedulingOccurrenceRestoreRequestImpl({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    required _isc.UuidValue commandId,
    required _ieswiaty.CalendarEventTiming originalStart,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         commandId: commandId,
         originalStart: originalStart,
       );

  /// Returns a shallow copy of this [CalendarSchedulingOccurrenceRestoreRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarSchedulingOccurrenceRestoreRequest copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _isc.UuidValue? commandId,
    _ieswiaty.CalendarEventTiming? originalStart,
  }) {
    return CalendarSchedulingOccurrenceRestoreRequest(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      commandId: commandId ?? this.commandId,
      originalStart: originalStart ?? this.originalStart.copyWith(),
    );
  }
}
