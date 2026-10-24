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
import 'calendar_event_occurrence_content_change.dart' as _iikl1ga8;
import 'calendar_event_timing.dart' as _ieswiaty;

@_is.immutable
abstract class CalendarEventOccurrenceContentRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventOccurrenceContentRequest._({
    required this.eventId,
    required this.expectedRevision,
    required this.originalStart,
    required this.changes,
  });

  const factory CalendarEventOccurrenceContentRequest({
    required _is.UuidValue eventId,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required List<_iikl1ga8.CalendarEventOccurrenceContentChange> changes,
  }) = _CalendarEventOccurrenceContentRequestImpl;

  factory CalendarEventOccurrenceContentRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrenceContentRequest(
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      changes: _ix00hwbf.Protocol()
          .deserialize<List<_iikl1ga8.CalendarEventOccurrenceContentChange>>(
            jsonSerialization['changes'],
          ),
    );
  }

  final _is.UuidValue eventId;

  final int expectedRevision;

  final _ieswiaty.CalendarEventTiming originalStart;

  final List<_iikl1ga8.CalendarEventOccurrenceContentChange> changes;

  /// Returns a shallow copy of this [CalendarEventOccurrenceContentRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventOccurrenceContentRequest copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    List<_iikl1ga8.CalendarEventOccurrenceContentChange>? changes,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOccurrenceContentRequest &&
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
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            const _iss.DeepCollectionEquality().equals(
              other.changes,
              changes,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      expectedRevision,
      originalStart,
      const _iss.DeepCollectionEquality().hash(changes),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarEventOccurrenceContentRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJson(),
      'changes': changes.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarEventOccurrenceContentRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJsonForProtocol(),
      'changes': changes.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarEventOccurrenceContentRequestImpl
    extends CalendarEventOccurrenceContentRequest {
  const _CalendarEventOccurrenceContentRequestImpl({
    required _is.UuidValue eventId,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required List<_iikl1ga8.CalendarEventOccurrenceContentChange> changes,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         originalStart: originalStart,
         changes: changes,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrenceContentRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventOccurrenceContentRequest copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    List<_iikl1ga8.CalendarEventOccurrenceContentChange>? changes,
  }) {
    return CalendarEventOccurrenceContentRequest(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      changes: changes ?? this.changes.map((e0) => e0.copyWith()).toList(),
    );
  }
}
