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
import 'calendar_event_occurrence_action.dart' as _icnciyzp;
import 'calendar_event_timing.dart' as _ieswiaty;

@_is.immutable
abstract class CalendarEventOccurrenceChange
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventOccurrenceChange._({
    required this.eventId,
    required this.expectedRevision,
    required this.originalStart,
    required this.action,
    this.replacement,
  });

  const factory CalendarEventOccurrenceChange({
    required _is.UuidValue eventId,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _icnciyzp.CalendarEventOccurrenceAction action,
    _ieswiaty.CalendarEventTiming? replacement,
  }) = _CalendarEventOccurrenceChangeImpl;

  factory CalendarEventOccurrenceChange.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrenceChange(
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      action: _icnciyzp.CalendarEventOccurrenceAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      replacement: jsonSerialization['replacement'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['replacement'],
            ),
    );
  }

  final _is.UuidValue eventId;

  final int expectedRevision;

  final _ieswiaty.CalendarEventTiming originalStart;

  final _icnciyzp.CalendarEventOccurrenceAction action;

  final _ieswiaty.CalendarEventTiming? replacement;

  /// Returns a shallow copy of this [CalendarEventOccurrenceChange]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventOccurrenceChange copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    _icnciyzp.CalendarEventOccurrenceAction? action,
    _ieswiaty.CalendarEventTiming? replacement,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOccurrenceChange &&
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
            (identical(
                  other.action,
                  action,
                ) ||
                other.action == action) &&
            (identical(
                  other.replacement,
                  replacement,
                ) ||
                other.replacement == replacement);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      expectedRevision,
      originalStart,
      action,
      replacement,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceChange',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJson(),
      'action': action.toJson(),
      if (replacement != null) 'replacement': replacement?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceChange',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJsonForProtocol(),
      'action': action.toJson(),
      if (replacement != null) 'replacement': replacement?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventOccurrenceChangeImpl extends CalendarEventOccurrenceChange {
  const _CalendarEventOccurrenceChangeImpl({
    required _is.UuidValue eventId,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _icnciyzp.CalendarEventOccurrenceAction action,
    _ieswiaty.CalendarEventTiming? replacement,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         originalStart: originalStart,
         action: action,
         replacement: replacement,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrenceChange]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventOccurrenceChange copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    _icnciyzp.CalendarEventOccurrenceAction? action,
    Object? replacement = _Undefined,
  }) {
    return CalendarEventOccurrenceChange(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      action: action ?? this.action,
      replacement: replacement is _ieswiaty.CalendarEventTiming?
          ? replacement
          : this.replacement?.copyWith(),
    );
  }
}
