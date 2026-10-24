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
import 'calendar_event_occurrence_content.dart' as _io4uvjqi;
import 'calendar_event_source_metadata.dart' as _ic57ts5d;
import 'calendar_event_timing.dart' as _ieswiaty;

@_is.immutable
abstract class CalendarEventSingleOverride
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventSingleOverride._({
    required this.originalStart,
    this.replacement,
    bool? cancelled,
    this.contentOverrides,
    this.sourceMetadata,
  }) : cancelled = cancelled ?? false;

  const factory CalendarEventSingleOverride({
    required _ieswiaty.CalendarEventTiming originalStart,
    _ieswiaty.CalendarEventTiming? replacement,
    bool? cancelled,
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides,
    _ic57ts5d.CalendarEventSourceMetadata? sourceMetadata,
  }) = _CalendarEventSingleOverrideImpl;

  factory CalendarEventSingleOverride.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventSingleOverride(
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      replacement: jsonSerialization['replacement'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['replacement'],
            ),
      cancelled: jsonSerialization['cancelled'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['cancelled']),
      contentOverrides: jsonSerialization['contentOverrides'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_io4uvjqi.CalendarEventOccurrenceContent>(
                  jsonSerialization['contentOverrides'],
                ),
      sourceMetadata: jsonSerialization['sourceMetadata'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_ic57ts5d.CalendarEventSourceMetadata>(
                  jsonSerialization['sourceMetadata'],
                ),
    );
  }

  final _ieswiaty.CalendarEventTiming originalStart;

  final _ieswiaty.CalendarEventTiming? replacement;

  final bool cancelled;

  final _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides;

  final _ic57ts5d.CalendarEventSourceMetadata? sourceMetadata;

  /// Returns a shallow copy of this [CalendarEventSingleOverride]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventSingleOverride copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    _ieswiaty.CalendarEventTiming? replacement,
    bool? cancelled,
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides,
    _ic57ts5d.CalendarEventSourceMetadata? sourceMetadata,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventSingleOverride &&
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
                  other.cancelled,
                  cancelled,
                ) ||
                other.cancelled == cancelled) &&
            (identical(
                  other.contentOverrides,
                  contentOverrides,
                ) ||
                other.contentOverrides == contentOverrides) &&
            (identical(
                  other.sourceMetadata,
                  sourceMetadata,
                ) ||
                other.sourceMetadata == sourceMetadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      originalStart,
      replacement,
      cancelled,
      contentOverrides,
      sourceMetadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventSingleOverride',
      'originalStart': originalStart.toJson(),
      if (replacement != null) 'replacement': replacement?.toJson(),
      'cancelled': cancelled,
      if (contentOverrides != null)
        'contentOverrides': contentOverrides?.toJson(),
      if (sourceMetadata != null) 'sourceMetadata': sourceMetadata?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventSingleOverride',
      'originalStart': originalStart.toJsonForProtocol(),
      if (replacement != null) 'replacement': replacement?.toJsonForProtocol(),
      'cancelled': cancelled,
      if (contentOverrides != null)
        'contentOverrides': contentOverrides?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventSingleOverrideImpl extends CalendarEventSingleOverride {
  const _CalendarEventSingleOverrideImpl({
    required _ieswiaty.CalendarEventTiming originalStart,
    _ieswiaty.CalendarEventTiming? replacement,
    bool? cancelled,
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides,
    _ic57ts5d.CalendarEventSourceMetadata? sourceMetadata,
  }) : super._(
         originalStart: originalStart,
         replacement: replacement,
         cancelled: cancelled,
         contentOverrides: contentOverrides,
         sourceMetadata: sourceMetadata,
       );

  /// Returns a shallow copy of this [CalendarEventSingleOverride]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventSingleOverride copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    Object? replacement = _Undefined,
    bool? cancelled,
    Object? contentOverrides = _Undefined,
    Object? sourceMetadata = _Undefined,
  }) {
    return CalendarEventSingleOverride(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      replacement: replacement is _ieswiaty.CalendarEventTiming?
          ? replacement
          : this.replacement?.copyWith(),
      cancelled: cancelled ?? this.cancelled,
      contentOverrides:
          contentOverrides is _io4uvjqi.CalendarEventOccurrenceContent?
          ? contentOverrides
          : this.contentOverrides?.copyWith(),
      sourceMetadata: sourceMetadata is _ic57ts5d.CalendarEventSourceMetadata?
          ? sourceMetadata
          : this.sourceMetadata?.copyWith(),
    );
  }
}
