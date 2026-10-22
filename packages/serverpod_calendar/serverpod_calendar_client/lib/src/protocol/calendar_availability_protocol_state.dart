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
import 'calendar_availability_opening_protocol_state.dart' as _ix3hb3ib;

@_isc.immutable
abstract class CalendarAvailabilityProtocolState
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityProtocolState._({
    this.sequence,
    this.created,
    required this.stamp,
    this.lastModified,
    required this.openings,
  });

  const factory CalendarAvailabilityProtocolState({
    int? sequence,
    DateTime? created,
    required DateTime stamp,
    DateTime? lastModified,
    required List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState> openings,
  }) = _CalendarAvailabilityProtocolStateImpl;

  factory CalendarAvailabilityProtocolState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityProtocolState(
      sequence: jsonSerialization['sequence'] as int?,
      created: jsonSerialization['created'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
      stamp: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      lastModified: jsonSerialization['lastModified'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastModified'],
            ),
      openings: _ie4a1wrz.Protocol()
          .deserialize<
            List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState>
          >(jsonSerialization['openings']),
    );
  }

  final int? sequence;

  final DateTime? created;

  final DateTime stamp;

  final DateTime? lastModified;

  final List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState> openings;

  /// Returns a shallow copy of this [CalendarAvailabilityProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityProtocolState copyWith({
    int? sequence,
    DateTime? created,
    DateTime? stamp,
    DateTime? lastModified,
    List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState>? openings,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityProtocolState &&
            (identical(
                  other.sequence,
                  sequence,
                ) ||
                other.sequence == sequence) &&
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
              other.openings,
              openings,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      sequence,
      created,
      stamp,
      lastModified,
      const _iss.DeepCollectionEquality().hash(openings),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityProtocolState',
      if (sequence != null) 'sequence': sequence,
      if (created != null) 'created': created?.toJson(),
      'stamp': stamp.toJson(),
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
      'openings': openings.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityProtocolState',
      if (sequence != null) 'sequence': sequence,
      if (created != null) 'created': created?.toJson(),
      'stamp': stamp.toJson(),
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
      'openings': openings.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityProtocolStateImpl
    extends CalendarAvailabilityProtocolState {
  const _CalendarAvailabilityProtocolStateImpl({
    int? sequence,
    DateTime? created,
    required DateTime stamp,
    DateTime? lastModified,
    required List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState> openings,
  }) : super._(
         sequence: sequence,
         created: created,
         stamp: stamp,
         lastModified: lastModified,
         openings: openings,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityProtocolState copyWith({
    Object? sequence = _Undefined,
    Object? created = _Undefined,
    DateTime? stamp,
    Object? lastModified = _Undefined,
    List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState>? openings,
  }) {
    return CalendarAvailabilityProtocolState(
      sequence: sequence is int? ? sequence : this.sequence,
      created: created is DateTime? ? created : this.created,
      stamp: stamp ?? this.stamp,
      lastModified: lastModified is DateTime?
          ? lastModified
          : this.lastModified,
      openings: openings ?? this.openings.map((e0) => e0.copyWith()).toList(),
    );
  }
}
