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
import 'calendar_event_override_protocol_state.dart' as _iml0c566;
import 'calendar_event_protocol_version.dart' as _iblfo3t0;

@_is.immutable
abstract class CalendarEventProtocolState
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventProtocolState._({
    required this.version,
    bool? statusPresent,
    bool? transparencyPresent,
    required this.overrides,
  }) : statusPresent = statusPresent ?? true,
       transparencyPresent = transparencyPresent ?? true;

  const factory CalendarEventProtocolState({
    required _iblfo3t0.CalendarEventProtocolVersion version,
    bool? statusPresent,
    bool? transparencyPresent,
    required List<_iml0c566.CalendarEventOverrideProtocolState> overrides,
  }) = _CalendarEventProtocolStateImpl;

  factory CalendarEventProtocolState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventProtocolState(
      version: _ix00hwbf.Protocol()
          .deserialize<_iblfo3t0.CalendarEventProtocolVersion>(
            jsonSerialization['version'],
          ),
      statusPresent: jsonSerialization['statusPresent'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['statusPresent']),
      transparencyPresent: jsonSerialization['transparencyPresent'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['transparencyPresent'],
            ),
      overrides: _ix00hwbf.Protocol()
          .deserialize<List<_iml0c566.CalendarEventOverrideProtocolState>>(
            jsonSerialization['overrides'],
          ),
    );
  }

  final _iblfo3t0.CalendarEventProtocolVersion version;

  final bool statusPresent;

  final bool transparencyPresent;

  final List<_iml0c566.CalendarEventOverrideProtocolState> overrides;

  /// Returns a shallow copy of this [CalendarEventProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventProtocolState copyWith({
    _iblfo3t0.CalendarEventProtocolVersion? version,
    bool? statusPresent,
    bool? transparencyPresent,
    List<_iml0c566.CalendarEventOverrideProtocolState>? overrides,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventProtocolState &&
            (identical(
                  other.version,
                  version,
                ) ||
                other.version == version) &&
            (identical(
                  other.statusPresent,
                  statusPresent,
                ) ||
                other.statusPresent == statusPresent) &&
            (identical(
                  other.transparencyPresent,
                  transparencyPresent,
                ) ||
                other.transparencyPresent == transparencyPresent) &&
            const _iss.DeepCollectionEquality().equals(
              other.overrides,
              overrides,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      version,
      statusPresent,
      transparencyPresent,
      const _iss.DeepCollectionEquality().hash(overrides),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventProtocolState',
      'version': version.toJson(),
      'statusPresent': statusPresent,
      'transparencyPresent': transparencyPresent,
      'overrides': overrides.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarEventProtocolStateImpl extends CalendarEventProtocolState {
  const _CalendarEventProtocolStateImpl({
    required _iblfo3t0.CalendarEventProtocolVersion version,
    bool? statusPresent,
    bool? transparencyPresent,
    required List<_iml0c566.CalendarEventOverrideProtocolState> overrides,
  }) : super._(
         version: version,
         statusPresent: statusPresent,
         transparencyPresent: transparencyPresent,
         overrides: overrides,
       );

  /// Returns a shallow copy of this [CalendarEventProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventProtocolState copyWith({
    _iblfo3t0.CalendarEventProtocolVersion? version,
    bool? statusPresent,
    bool? transparencyPresent,
    List<_iml0c566.CalendarEventOverrideProtocolState>? overrides,
  }) {
    return CalendarEventProtocolState(
      version: version ?? this.version.copyWith(),
      statusPresent: statusPresent ?? this.statusPresent,
      transparencyPresent: transparencyPresent ?? this.transparencyPresent,
      overrides:
          overrides ?? this.overrides.map((e0) => e0.copyWith()).toList(),
    );
  }
}
