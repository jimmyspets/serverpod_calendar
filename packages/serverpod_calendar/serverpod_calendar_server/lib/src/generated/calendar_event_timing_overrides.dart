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
import 'calendar_event_future_override.dart' as _imbjv41e;
import 'calendar_event_single_override.dart' as _iq1kxi25;

@_is.immutable
abstract class CalendarEventTimingOverrides
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventTimingOverrides._({
    required this.singles,
    required this.future,
  });

  const factory CalendarEventTimingOverrides({
    required List<_iq1kxi25.CalendarEventSingleOverride> singles,
    required List<_imbjv41e.CalendarEventFutureOverride> future,
  }) = _CalendarEventTimingOverridesImpl;

  factory CalendarEventTimingOverrides.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventTimingOverrides(
      singles: _ix00hwbf.Protocol()
          .deserialize<List<_iq1kxi25.CalendarEventSingleOverride>>(
            jsonSerialization['singles'],
          ),
      future: _ix00hwbf.Protocol()
          .deserialize<List<_imbjv41e.CalendarEventFutureOverride>>(
            jsonSerialization['future'],
          ),
    );
  }

  final List<_iq1kxi25.CalendarEventSingleOverride> singles;

  final List<_imbjv41e.CalendarEventFutureOverride> future;

  /// Returns a shallow copy of this [CalendarEventTimingOverrides]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventTimingOverrides copyWith({
    List<_iq1kxi25.CalendarEventSingleOverride>? singles,
    List<_imbjv41e.CalendarEventFutureOverride>? future,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventTimingOverrides &&
            const _iss.DeepCollectionEquality().equals(
              other.singles,
              singles,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.future,
              future,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(singles),
      const _iss.DeepCollectionEquality().hash(future),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventTimingOverrides',
      'singles': singles.toJson(valueToJson: (v) => v.toJson()),
      'future': future.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventTimingOverrides',
      'singles': singles.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'future': future.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarEventTimingOverridesImpl extends CalendarEventTimingOverrides {
  const _CalendarEventTimingOverridesImpl({
    required List<_iq1kxi25.CalendarEventSingleOverride> singles,
    required List<_imbjv41e.CalendarEventFutureOverride> future,
  }) : super._(
         singles: singles,
         future: future,
       );

  /// Returns a shallow copy of this [CalendarEventTimingOverrides]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventTimingOverrides copyWith({
    List<_iq1kxi25.CalendarEventSingleOverride>? singles,
    List<_imbjv41e.CalendarEventFutureOverride>? future,
  }) {
    return CalendarEventTimingOverrides(
      singles: singles ?? this.singles.map((e0) => e0.copyWith()).toList(),
      future: future ?? this.future.map((e0) => e0.copyWith()).toList(),
    );
  }
}
