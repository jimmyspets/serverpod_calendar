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
abstract class CalendarEventSingleOverride
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventSingleOverride._({
    required this.originalStart,
    this.replacement,
    bool? cancelled,
  }) : cancelled = cancelled ?? false;

  const factory CalendarEventSingleOverride({
    required _ieswiaty.CalendarEventTiming originalStart,
    _ieswiaty.CalendarEventTiming? replacement,
    bool? cancelled,
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
    );
  }

  final _ieswiaty.CalendarEventTiming originalStart;

  final _ieswiaty.CalendarEventTiming? replacement;

  final bool cancelled;

  /// Returns a shallow copy of this [CalendarEventSingleOverride]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventSingleOverride copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    _ieswiaty.CalendarEventTiming? replacement,
    bool? cancelled,
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
                other.cancelled == cancelled);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      originalStart,
      replacement,
      cancelled,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventSingleOverride',
      'originalStart': originalStart.toJson(),
      if (replacement != null) 'replacement': replacement?.toJson(),
      'cancelled': cancelled,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventSingleOverride',
      'originalStart': originalStart.toJsonForProtocol(),
      if (replacement != null) 'replacement': replacement?.toJsonForProtocol(),
      'cancelled': cancelled,
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
  }) : super._(
         originalStart: originalStart,
         replacement: replacement,
         cancelled: cancelled,
       );

  /// Returns a shallow copy of this [CalendarEventSingleOverride]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventSingleOverride copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    Object? replacement = _Undefined,
    bool? cancelled,
  }) {
    return CalendarEventSingleOverride(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      replacement: replacement is _ieswiaty.CalendarEventTiming?
          ? replacement
          : this.replacement?.copyWith(),
      cancelled: cancelled ?? this.cancelled,
    );
  }
}
