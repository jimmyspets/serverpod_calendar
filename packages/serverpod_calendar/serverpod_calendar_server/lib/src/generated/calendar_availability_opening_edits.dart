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
import 'calendar_event_timing_overrides.dart' as _ijijze99;

@_is.immutable
abstract class CalendarAvailabilityOpeningEdits
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityOpeningEdits._({
    required this.openingUid,
    required this.overrides,
  });

  const factory CalendarAvailabilityOpeningEdits({
    required _is.UuidValue openingUid,
    required _ijijze99.CalendarEventTimingOverrides overrides,
  }) = _CalendarAvailabilityOpeningEditsImpl;

  factory CalendarAvailabilityOpeningEdits.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOpeningEdits(
      openingUid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['openingUid'],
      ),
      overrides: _ix00hwbf.Protocol()
          .deserialize<_ijijze99.CalendarEventTimingOverrides>(
            jsonSerialization['overrides'],
          ),
    );
  }

  final _is.UuidValue openingUid;

  final _ijijze99.CalendarEventTimingOverrides overrides;

  /// Returns a shallow copy of this [CalendarAvailabilityOpeningEdits]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityOpeningEdits copyWith({
    _is.UuidValue? openingUid,
    _ijijze99.CalendarEventTimingOverrides? overrides,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityOpeningEdits &&
            (identical(
                  other.openingUid,
                  openingUid,
                ) ||
                other.openingUid == openingUid) &&
            (identical(
                  other.overrides,
                  overrides,
                ) ||
                other.overrides == overrides);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      openingUid,
      overrides,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOpeningEdits',
      'openingUid': openingUid.toJson(),
      'overrides': overrides.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOpeningEdits',
      'openingUid': openingUid.toJson(),
      'overrides': overrides.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityOpeningEditsImpl
    extends CalendarAvailabilityOpeningEdits {
  const _CalendarAvailabilityOpeningEditsImpl({
    required _is.UuidValue openingUid,
    required _ijijze99.CalendarEventTimingOverrides overrides,
  }) : super._(
         openingUid: openingUid,
         overrides: overrides,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOpeningEdits]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityOpeningEdits copyWith({
    _is.UuidValue? openingUid,
    _ijijze99.CalendarEventTimingOverrides? overrides,
  }) {
    return CalendarAvailabilityOpeningEdits(
      openingUid: openingUid ?? this.openingUid,
      overrides: overrides ?? this.overrides.copyWith(),
    );
  }
}
