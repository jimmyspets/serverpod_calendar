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
import 'calendar_availability_override_protocol_state.dart' as _i33h9mr5;

@_is.immutable
abstract class CalendarAvailabilityOpeningProtocolState
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityOpeningProtocolState._({
    required this.openingUid,
    this.created,
    required this.stamp,
    this.lastModified,
    this.overrides,
  });

  const factory CalendarAvailabilityOpeningProtocolState({
    required _is.UuidValue openingUid,
    DateTime? created,
    required DateTime stamp,
    DateTime? lastModified,
    List<_i33h9mr5.CalendarAvailabilityOverrideProtocolState>? overrides,
  }) = _CalendarAvailabilityOpeningProtocolStateImpl;

  factory CalendarAvailabilityOpeningProtocolState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOpeningProtocolState(
      openingUid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['openingUid'],
      ),
      created: jsonSerialization['created'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      lastModified: jsonSerialization['lastModified'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastModified'],
            ),
      overrides: jsonSerialization['overrides'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<
              List<_i33h9mr5.CalendarAvailabilityOverrideProtocolState>
            >(jsonSerialization['overrides']),
    );
  }

  final _is.UuidValue openingUid;

  final DateTime? created;

  final DateTime stamp;

  final DateTime? lastModified;

  final List<_i33h9mr5.CalendarAvailabilityOverrideProtocolState>? overrides;

  /// Returns a shallow copy of this [CalendarAvailabilityOpeningProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityOpeningProtocolState copyWith({
    _is.UuidValue? openingUid,
    DateTime? created,
    DateTime? stamp,
    DateTime? lastModified,
    List<_i33h9mr5.CalendarAvailabilityOverrideProtocolState>? overrides,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityOpeningProtocolState &&
            (identical(
                  other.openingUid,
                  openingUid,
                ) ||
                other.openingUid == openingUid) &&
            (identical(
                  other.created,
                  created,
                ) ||
                other.created == created) &&
            (identical(
                  other.stamp,
                  stamp,
                ) ||
                other.stamp == stamp) &&
            (identical(
                  other.lastModified,
                  lastModified,
                ) ||
                other.lastModified == lastModified) &&
            const _iss.DeepCollectionEquality().equals(
              other.overrides,
              overrides,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      openingUid,
      created,
      stamp,
      lastModified,
      const _iss.DeepCollectionEquality().hash(overrides),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAvailabilityOpeningProtocolState',
      'openingUid': openingUid.toJson(),
      if (created != null) 'created': created?.toJson(),
      'stamp': stamp.toJson(),
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
      if (overrides != null)
        'overrides': overrides?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAvailabilityOpeningProtocolState',
      'openingUid': openingUid.toJson(),
      if (created != null) 'created': created?.toJson(),
      'stamp': stamp.toJson(),
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
      if (overrides != null)
        'overrides': overrides?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityOpeningProtocolStateImpl
    extends CalendarAvailabilityOpeningProtocolState {
  const _CalendarAvailabilityOpeningProtocolStateImpl({
    required _is.UuidValue openingUid,
    DateTime? created,
    required DateTime stamp,
    DateTime? lastModified,
    List<_i33h9mr5.CalendarAvailabilityOverrideProtocolState>? overrides,
  }) : super._(
         openingUid: openingUid,
         created: created,
         stamp: stamp,
         lastModified: lastModified,
         overrides: overrides,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOpeningProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityOpeningProtocolState copyWith({
    _is.UuidValue? openingUid,
    Object? created = _Undefined,
    DateTime? stamp,
    Object? lastModified = _Undefined,
    Object? overrides = _Undefined,
  }) {
    return CalendarAvailabilityOpeningProtocolState(
      openingUid: openingUid ?? this.openingUid,
      created: created is DateTime? ? created : this.created,
      stamp: stamp ?? this.stamp,
      lastModified: lastModified is DateTime?
          ? lastModified
          : this.lastModified,
      overrides:
          overrides
              is List<_i33h9mr5.CalendarAvailabilityOverrideProtocolState>?
          ? overrides
          : this.overrides?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
