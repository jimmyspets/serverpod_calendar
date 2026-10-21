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
import 'calendar_availability_opening.dart' as _i8tf9h36;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_free_busy_kind.dart' as _izms466b;

@_isc.immutable
abstract class CalendarAvailabilityContent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityContent._({
    this.summary,
    this.validFrom,
    this.validUntil,
    int? priority,
    _izms466b.CalendarFreeBusyKind? closedKind,
    required this.openings,
  }) : priority = priority ?? 0,
       closedKind = closedKind ?? _izms466b.CalendarFreeBusyKind.unavailable;

  const factory CalendarAvailabilityContent({
    String? summary,
    _ieswiaty.CalendarEventTiming? validFrom,
    _ieswiaty.CalendarEventTiming? validUntil,
    int? priority,
    _izms466b.CalendarFreeBusyKind? closedKind,
    required List<_i8tf9h36.CalendarAvailabilityOpening> openings,
  }) = _CalendarAvailabilityContentImpl;

  factory CalendarAvailabilityContent.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityContent(
      summary: jsonSerialization['summary'] as String?,
      validFrom: jsonSerialization['validFrom'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['validFrom'],
            ),
      validUntil: jsonSerialization['validUntil'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['validUntil'],
            ),
      priority: jsonSerialization['priority'] as int?,
      closedKind: jsonSerialization['closedKind'] == null
          ? null
          : _izms466b.CalendarFreeBusyKind.fromJson(
              (jsonSerialization['closedKind'] as String),
            ),
      openings: _ie4a1wrz.Protocol()
          .deserialize<List<_i8tf9h36.CalendarAvailabilityOpening>>(
            jsonSerialization['openings'],
          ),
    );
  }

  final String? summary;

  final _ieswiaty.CalendarEventTiming? validFrom;

  final _ieswiaty.CalendarEventTiming? validUntil;

  final int priority;

  final _izms466b.CalendarFreeBusyKind closedKind;

  final List<_i8tf9h36.CalendarAvailabilityOpening> openings;

  /// Returns a shallow copy of this [CalendarAvailabilityContent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityContent copyWith({
    String? summary,
    _ieswiaty.CalendarEventTiming? validFrom,
    _ieswiaty.CalendarEventTiming? validUntil,
    int? priority,
    _izms466b.CalendarFreeBusyKind? closedKind,
    List<_i8tf9h36.CalendarAvailabilityOpening>? openings,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityContent &&
            (identical(
                  other.summary,
                  summary,
                ) ||
                other.summary == summary) &&
            (identical(
                  other.validFrom,
                  validFrom,
                ) ||
                other.validFrom == validFrom) &&
            (identical(
                  other.validUntil,
                  validUntil,
                ) ||
                other.validUntil == validUntil) &&
            (identical(
                  other.priority,
                  priority,
                ) ||
                other.priority == priority) &&
            (identical(
                  other.closedKind,
                  closedKind,
                ) ||
                other.closedKind == closedKind) &&
            const _iss.DeepCollectionEquality().equals(
              other.openings,
              openings,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      summary,
      validFrom,
      validUntil,
      priority,
      closedKind,
      const _iss.DeepCollectionEquality().hash(openings),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityContent',
      if (summary != null) 'summary': summary,
      if (validFrom != null) 'validFrom': validFrom?.toJson(),
      if (validUntil != null) 'validUntil': validUntil?.toJson(),
      'priority': priority,
      'closedKind': closedKind.toJson(),
      'openings': openings.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityContent',
      if (summary != null) 'summary': summary,
      if (validFrom != null) 'validFrom': validFrom?.toJsonForProtocol(),
      if (validUntil != null) 'validUntil': validUntil?.toJsonForProtocol(),
      'priority': priority,
      'closedKind': closedKind.toJson(),
      'openings': openings.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityContentImpl extends CalendarAvailabilityContent {
  const _CalendarAvailabilityContentImpl({
    String? summary,
    _ieswiaty.CalendarEventTiming? validFrom,
    _ieswiaty.CalendarEventTiming? validUntil,
    int? priority,
    _izms466b.CalendarFreeBusyKind? closedKind,
    required List<_i8tf9h36.CalendarAvailabilityOpening> openings,
  }) : super._(
         summary: summary,
         validFrom: validFrom,
         validUntil: validUntil,
         priority: priority,
         closedKind: closedKind,
         openings: openings,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityContent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityContent copyWith({
    Object? summary = _Undefined,
    Object? validFrom = _Undefined,
    Object? validUntil = _Undefined,
    int? priority,
    _izms466b.CalendarFreeBusyKind? closedKind,
    List<_i8tf9h36.CalendarAvailabilityOpening>? openings,
  }) {
    return CalendarAvailabilityContent(
      summary: summary is String? ? summary : this.summary,
      validFrom: validFrom is _ieswiaty.CalendarEventTiming?
          ? validFrom
          : this.validFrom?.copyWith(),
      validUntil: validUntil is _ieswiaty.CalendarEventTiming?
          ? validUntil
          : this.validUntil?.copyWith(),
      priority: priority ?? this.priority,
      closedKind: closedKind ?? this.closedKind,
      openings: openings ?? this.openings.map((e0) => e0.copyWith()).toList(),
    );
  }
}
