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
import 'calendar_availability_opening_protocol_state.dart' as _ix3hb3ib;

@_is.immutable
abstract class CalendarAvailabilityProtocolState
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityProtocolState._({
    required this.sequence,
    required this.created,
    required this.stamp,
    required this.lastModified,
    required this.openings,
  });

  const factory CalendarAvailabilityProtocolState({
    required int sequence,
    required DateTime created,
    required DateTime stamp,
    required DateTime lastModified,
    required List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState> openings,
  }) = _CalendarAvailabilityProtocolStateImpl;

  factory CalendarAvailabilityProtocolState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityProtocolState(
      sequence: jsonSerialization['sequence'] as int,
      created: _is.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      lastModified: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastModified'],
      ),
      openings: _ix00hwbf.Protocol()
          .deserialize<
            List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState>
          >(jsonSerialization['openings']),
    );
  }

  final int sequence;

  final DateTime created;

  final DateTime stamp;

  final DateTime lastModified;

  final List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState> openings;

  /// Returns a shallow copy of this [CalendarAvailabilityProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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
      'sequence': sequence,
      'created': created.toJson(),
      'stamp': stamp.toJson(),
      'lastModified': lastModified.toJson(),
      'openings': openings.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityProtocolState',
      'sequence': sequence,
      'created': created.toJson(),
      'stamp': stamp.toJson(),
      'lastModified': lastModified.toJson(),
      'openings': openings.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityProtocolStateImpl
    extends CalendarAvailabilityProtocolState {
  const _CalendarAvailabilityProtocolStateImpl({
    required int sequence,
    required DateTime created,
    required DateTime stamp,
    required DateTime lastModified,
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
  @_is.useResult
  @override
  CalendarAvailabilityProtocolState copyWith({
    int? sequence,
    DateTime? created,
    DateTime? stamp,
    DateTime? lastModified,
    List<_ix3hb3ib.CalendarAvailabilityOpeningProtocolState>? openings,
  }) {
    return CalendarAvailabilityProtocolState(
      sequence: sequence ?? this.sequence,
      created: created ?? this.created,
      stamp: stamp ?? this.stamp,
      lastModified: lastModified ?? this.lastModified,
      openings: openings ?? this.openings.map((e0) => e0.copyWith()).toList(),
    );
  }
}
