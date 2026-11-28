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
import 'calendar_event_occurrence_content.dart' as _io4uvjqi;
import 'calendar_event_timing.dart' as _ieswiaty;

@_isc.immutable
abstract class CalendarEventFutureOverride
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventFutureOverride._({
    required this.originalStart,
    required this.replacement,
    this.contentOverrides,
  });

  const factory CalendarEventFutureOverride({
    required _ieswiaty.CalendarEventTiming originalStart,
    required _ieswiaty.CalendarEventTiming replacement,
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides,
  }) = _CalendarEventFutureOverrideImpl;

  factory CalendarEventFutureOverride.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventFutureOverride(
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      replacement: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['replacement'],
          ),
      contentOverrides: jsonSerialization['contentOverrides'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_io4uvjqi.CalendarEventOccurrenceContent>(
                  jsonSerialization['contentOverrides'],
                ),
    );
  }

  final _ieswiaty.CalendarEventTiming originalStart;

  final _ieswiaty.CalendarEventTiming replacement;

  final _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides;

  /// Returns a shallow copy of this [CalendarEventFutureOverride]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventFutureOverride copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    _ieswiaty.CalendarEventTiming? replacement,
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventFutureOverride &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.replacement,
                  replacement,
                ) ||
                other.replacement == replacement) &&
            (identical(
                  other.contentOverrides,
                  contentOverrides,
                ) ||
                other.contentOverrides == contentOverrides);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      originalStart,
      replacement,
      contentOverrides,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventFutureOverride',
      'originalStart': originalStart.toJson(),
      'replacement': replacement.toJson(),
      if (contentOverrides != null)
        'contentOverrides': contentOverrides?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventFutureOverride',
      'originalStart': originalStart.toJsonForProtocol(),
      'replacement': replacement.toJsonForProtocol(),
      if (contentOverrides != null)
        'contentOverrides': contentOverrides?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventFutureOverrideImpl extends CalendarEventFutureOverride {
  const _CalendarEventFutureOverrideImpl({
    required _ieswiaty.CalendarEventTiming originalStart,
    required _ieswiaty.CalendarEventTiming replacement,
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides,
  }) : super._(
         originalStart: originalStart,
         replacement: replacement,
         contentOverrides: contentOverrides,
       );

  /// Returns a shallow copy of this [CalendarEventFutureOverride]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventFutureOverride copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    _ieswiaty.CalendarEventTiming? replacement,
    Object? contentOverrides = _Undefined,
  }) {
    return CalendarEventFutureOverride(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      replacement: replacement ?? this.replacement.copyWith(),
      contentOverrides:
          contentOverrides is _io4uvjqi.CalendarEventOccurrenceContent?
          ? contentOverrides
          : this.contentOverrides?.copyWith(),
    );
  }
}
