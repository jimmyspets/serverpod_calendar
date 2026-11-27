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
import 'calendar_event_occurrence_action.dart' as _icnciyzp;
import 'calendar_event_timing.dart' as _ieswiaty;

@_isc.immutable
abstract class CalendarAvailabilityOccurrenceChange
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityOccurrenceChange._({
    required this.availabilityId,
    required this.openingUid,
    required this.expectedRevision,
    required this.originalStart,
    required this.action,
    this.replacement,
  });

  const factory CalendarAvailabilityOccurrenceChange({
    required _isc.UuidValue availabilityId,
    required _isc.UuidValue openingUid,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _icnciyzp.CalendarEventOccurrenceAction action,
    _ieswiaty.CalendarEventTiming? replacement,
  }) = _CalendarAvailabilityOccurrenceChangeImpl;

  factory CalendarAvailabilityOccurrenceChange.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOccurrenceChange(
      availabilityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['availabilityId'],
      ),
      openingUid: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['openingUid'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      action: _icnciyzp.CalendarEventOccurrenceAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      replacement: jsonSerialization['replacement'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['replacement'],
            ),
    );
  }

  final _isc.UuidValue availabilityId;

  final _isc.UuidValue openingUid;

  final int expectedRevision;

  final _ieswiaty.CalendarEventTiming originalStart;

  final _icnciyzp.CalendarEventOccurrenceAction action;

  final _ieswiaty.CalendarEventTiming? replacement;

  /// Returns a shallow copy of this [CalendarAvailabilityOccurrenceChange]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityOccurrenceChange copyWith({
    _isc.UuidValue? availabilityId,
    _isc.UuidValue? openingUid,
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
            other is CalendarAvailabilityOccurrenceChange &&
            (identical(
                  other.availabilityId,
                  availabilityId,
                ) ||
                other.availabilityId == availabilityId) &&
            (identical(
                  other.openingUid,
                  openingUid,
                ) ||
                other.openingUid == openingUid) &&
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
      availabilityId,
      openingUid,
      expectedRevision,
      originalStart,
      action,
      replacement,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAvailabilityOccurrenceChange',
      'availabilityId': availabilityId.toJson(),
      'openingUid': openingUid.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJson(),
      'action': action.toJson(),
      if (replacement != null) 'replacement': replacement?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAvailabilityOccurrenceChange',
      'availabilityId': availabilityId.toJson(),
      'openingUid': openingUid.toJson(),
      'expectedRevision': expectedRevision,
      'originalStart': originalStart.toJsonForProtocol(),
      'action': action.toJson(),
      if (replacement != null) 'replacement': replacement?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityOccurrenceChangeImpl
    extends CalendarAvailabilityOccurrenceChange {
  const _CalendarAvailabilityOccurrenceChangeImpl({
    required _isc.UuidValue availabilityId,
    required _isc.UuidValue openingUid,
    required int expectedRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _icnciyzp.CalendarEventOccurrenceAction action,
    _ieswiaty.CalendarEventTiming? replacement,
  }) : super._(
         availabilityId: availabilityId,
         openingUid: openingUid,
         expectedRevision: expectedRevision,
         originalStart: originalStart,
         action: action,
         replacement: replacement,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOccurrenceChange]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityOccurrenceChange copyWith({
    _isc.UuidValue? availabilityId,
    _isc.UuidValue? openingUid,
    int? expectedRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    _icnciyzp.CalendarEventOccurrenceAction? action,
    Object? replacement = _Undefined,
  }) {
    return CalendarAvailabilityOccurrenceChange(
      availabilityId: availabilityId ?? this.availabilityId,
      openingUid: openingUid ?? this.openingUid,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      action: action ?? this.action,
      replacement: replacement is _ieswiaty.CalendarEventTiming?
          ? replacement
          : this.replacement?.copyWith(),
    );
  }
}
