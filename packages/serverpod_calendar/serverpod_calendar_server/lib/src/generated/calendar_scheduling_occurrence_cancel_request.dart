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

@_is.immutable
abstract class CalendarSchedulingOccurrenceCancelRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarSchedulingOccurrenceCancelRequest._({
    required this.eventId,
    required this.expectedRevision,
    required this.commandId,
    required this.originalStart,
  });

  const factory CalendarSchedulingOccurrenceCancelRequest({
    required _is.UuidValue eventId,
    required int expectedRevision,
    required _is.UuidValue commandId,
    required _ieswiaty.CalendarEventTiming originalStart,
  }) = _CalendarSchedulingOccurrenceCancelRequestImpl;

  factory CalendarSchedulingOccurrenceCancelRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingOccurrenceCancelRequest(
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
    );
  }

  final _is.UuidValue eventId;

  final int expectedRevision;

  final _is.UuidValue commandId;

  final _ieswiaty.CalendarEventTiming originalStart;

  /// Returns a shallow copy of this [CalendarSchedulingOccurrenceCancelRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingOccurrenceCancelRequest copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
    _is.UuidValue? commandId,
    _ieswiaty.CalendarEventTiming? originalStart,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingOccurrenceCancelRequest &&
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
          'serverpod_calendar.CalendarSchedulingOccurrenceCancelRequest',
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
          'serverpod_calendar.CalendarSchedulingOccurrenceCancelRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'commandId': commandId.toJson(),
      'originalStart': originalStart.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarSchedulingOccurrenceCancelRequestImpl
    extends CalendarSchedulingOccurrenceCancelRequest {
  const _CalendarSchedulingOccurrenceCancelRequestImpl({
    required _is.UuidValue eventId,
    required int expectedRevision,
    required _is.UuidValue commandId,
    required _ieswiaty.CalendarEventTiming originalStart,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         commandId: commandId,
         originalStart: originalStart,
       );

  /// Returns a shallow copy of this [CalendarSchedulingOccurrenceCancelRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingOccurrenceCancelRequest copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
    _is.UuidValue? commandId,
    _ieswiaty.CalendarEventTiming? originalStart,
  }) {
    return CalendarSchedulingOccurrenceCancelRequest(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      commandId: commandId ?? this.commandId,
      originalStart: originalStart ?? this.originalStart.copyWith(),
    );
  }
}
