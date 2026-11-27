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
import 'calendar_availability_slot.dart' as _i45h4t8f;
import 'calendar_availability_target.dart' as _iwbqbnec;
import 'calendar_free_busy_coverage.dart' as _ia3n9q23;
import 'calendar_free_busy_period.dart' as _i82zcrxb;

@_is.immutable
abstract class CalendarSubjectAvailability
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarSubjectAvailability._({
    required this.target,
    required this.coverage,
    required this.periods,
    required this.freeSlots,
  });

  const factory CalendarSubjectAvailability({
    required _iwbqbnec.CalendarAvailabilityTarget target,
    required _ia3n9q23.CalendarFreeBusyCoverage coverage,
    required List<_i82zcrxb.CalendarFreeBusyPeriod> periods,
    required List<_i45h4t8f.CalendarAvailabilitySlot> freeSlots,
  }) = _CalendarSubjectAvailabilityImpl;

  factory CalendarSubjectAvailability.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSubjectAvailability(
      target: _ix00hwbf.Protocol()
          .deserialize<_iwbqbnec.CalendarAvailabilityTarget>(
            jsonSerialization['target'],
          ),
      coverage: _ia3n9q23.CalendarFreeBusyCoverage.fromJson(
        (jsonSerialization['coverage'] as String),
      ),
      periods: _ix00hwbf.Protocol()
          .deserialize<List<_i82zcrxb.CalendarFreeBusyPeriod>>(
            jsonSerialization['periods'],
          ),
      freeSlots: _ix00hwbf.Protocol()
          .deserialize<List<_i45h4t8f.CalendarAvailabilitySlot>>(
            jsonSerialization['freeSlots'],
          ),
    );
  }

  final _iwbqbnec.CalendarAvailabilityTarget target;

  final _ia3n9q23.CalendarFreeBusyCoverage coverage;

  final List<_i82zcrxb.CalendarFreeBusyPeriod> periods;

  final List<_i45h4t8f.CalendarAvailabilitySlot> freeSlots;

  /// Returns a shallow copy of this [CalendarSubjectAvailability]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSubjectAvailability copyWith({
    _iwbqbnec.CalendarAvailabilityTarget? target,
    _ia3n9q23.CalendarFreeBusyCoverage? coverage,
    List<_i82zcrxb.CalendarFreeBusyPeriod>? periods,
    List<_i45h4t8f.CalendarAvailabilitySlot>? freeSlots,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSubjectAvailability &&
            (identical(
                  other.target,
                  target,
                ) ||
                other.target == target) &&
            (identical(
                  other.coverage,
                  coverage,
                ) ||
                other.coverage == coverage) &&
            const _iss.DeepCollectionEquality().equals(
              other.periods,
              periods,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.freeSlots,
              freeSlots,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      target,
      coverage,
      const _iss.DeepCollectionEquality().hash(periods),
      const _iss.DeepCollectionEquality().hash(freeSlots),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSubjectAvailability',
      'target': target.toJson(),
      'coverage': coverage.toJson(),
      'periods': periods.toJson(valueToJson: (v) => v.toJson()),
      'freeSlots': freeSlots.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSubjectAvailability',
      'target': target.toJsonForProtocol(),
      'coverage': coverage.toJson(),
      'periods': periods.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'freeSlots': freeSlots.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarSubjectAvailabilityImpl extends CalendarSubjectAvailability {
  const _CalendarSubjectAvailabilityImpl({
    required _iwbqbnec.CalendarAvailabilityTarget target,
    required _ia3n9q23.CalendarFreeBusyCoverage coverage,
    required List<_i82zcrxb.CalendarFreeBusyPeriod> periods,
    required List<_i45h4t8f.CalendarAvailabilitySlot> freeSlots,
  }) : super._(
         target: target,
         coverage: coverage,
         periods: periods,
         freeSlots: freeSlots,
       );

  /// Returns a shallow copy of this [CalendarSubjectAvailability]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSubjectAvailability copyWith({
    _iwbqbnec.CalendarAvailabilityTarget? target,
    _ia3n9q23.CalendarFreeBusyCoverage? coverage,
    List<_i82zcrxb.CalendarFreeBusyPeriod>? periods,
    List<_i45h4t8f.CalendarAvailabilitySlot>? freeSlots,
  }) {
    return CalendarSubjectAvailability(
      target: target ?? this.target.copyWith(),
      coverage: coverage ?? this.coverage,
      periods: periods ?? this.periods.map((e0) => e0.copyWith()).toList(),
      freeSlots:
          freeSlots ?? this.freeSlots.map((e0) => e0.copyWith()).toList(),
    );
  }
}
