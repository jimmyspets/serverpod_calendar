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
import 'calendar_availability_search_mode.dart' as _iam4llos;
import 'calendar_availability_slot.dart' as _i45h4t8f;
import 'calendar_free_busy_coverage.dart' as _ia3n9q23;
import 'calendar_subject_availability.dart' as _imo3vsmf;

@_isc.immutable
abstract class CalendarAvailabilitySearchView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilitySearchView._({
    required this.snapshotId,
    required this.calculatedAtUtc,
    required this.fromUtc,
    required this.untilUtc,
    required this.mode,
    required this.minimumSeconds,
    required this.results,
    this.commonCoverage,
    required this.commonSlots,
  });

  const factory CalendarAvailabilitySearchView({
    required _isc.UuidValue snapshotId,
    required DateTime calculatedAtUtc,
    required DateTime fromUtc,
    required DateTime untilUtc,
    required _iam4llos.CalendarAvailabilitySearchMode mode,
    required int minimumSeconds,
    required List<_imo3vsmf.CalendarSubjectAvailability> results,
    _ia3n9q23.CalendarFreeBusyCoverage? commonCoverage,
    required List<_i45h4t8f.CalendarAvailabilitySlot> commonSlots,
  }) = _CalendarAvailabilitySearchViewImpl;

  factory CalendarAvailabilitySearchView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilitySearchView(
      snapshotId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['snapshotId'],
      ),
      calculatedAtUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['calculatedAtUtc'],
      ),
      fromUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['fromUtc'],
      ),
      untilUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['untilUtc'],
      ),
      mode: _iam4llos.CalendarAvailabilitySearchMode.fromJson(
        (jsonSerialization['mode'] as String),
      ),
      minimumSeconds: jsonSerialization['minimumSeconds'] as int,
      results: _ie4a1wrz.Protocol()
          .deserialize<List<_imo3vsmf.CalendarSubjectAvailability>>(
            jsonSerialization['results'],
          ),
      commonCoverage: jsonSerialization['commonCoverage'] == null
          ? null
          : _ia3n9q23.CalendarFreeBusyCoverage.fromJson(
              (jsonSerialization['commonCoverage'] as String),
            ),
      commonSlots: _ie4a1wrz.Protocol()
          .deserialize<List<_i45h4t8f.CalendarAvailabilitySlot>>(
            jsonSerialization['commonSlots'],
          ),
    );
  }

  final _isc.UuidValue snapshotId;

  final DateTime calculatedAtUtc;

  final DateTime fromUtc;

  final DateTime untilUtc;

  final _iam4llos.CalendarAvailabilitySearchMode mode;

  final int minimumSeconds;

  final List<_imo3vsmf.CalendarSubjectAvailability> results;

  final _ia3n9q23.CalendarFreeBusyCoverage? commonCoverage;

  final List<_i45h4t8f.CalendarAvailabilitySlot> commonSlots;

  /// Returns a shallow copy of this [CalendarAvailabilitySearchView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilitySearchView copyWith({
    _isc.UuidValue? snapshotId,
    DateTime? calculatedAtUtc,
    DateTime? fromUtc,
    DateTime? untilUtc,
    _iam4llos.CalendarAvailabilitySearchMode? mode,
    int? minimumSeconds,
    List<_imo3vsmf.CalendarSubjectAvailability>? results,
    _ia3n9q23.CalendarFreeBusyCoverage? commonCoverage,
    List<_i45h4t8f.CalendarAvailabilitySlot>? commonSlots,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilitySearchView &&
            (identical(
                  other.snapshotId,
                  snapshotId,
                ) ||
                other.snapshotId == snapshotId) &&
            (identical(
                  other.calculatedAtUtc,
                  calculatedAtUtc,
                ) ||
                other.calculatedAtUtc == calculatedAtUtc) &&
            (identical(
                  other.fromUtc,
                  fromUtc,
                ) ||
                other.fromUtc == fromUtc) &&
            (identical(
                  other.untilUtc,
                  untilUtc,
                ) ||
                other.untilUtc == untilUtc) &&
            (identical(
                  other.mode,
                  mode,
                ) ||
                other.mode == mode) &&
            (identical(
                  other.minimumSeconds,
                  minimumSeconds,
                ) ||
                other.minimumSeconds == minimumSeconds) &&
            const _iss.DeepCollectionEquality().equals(
              other.results,
              results,
            ) &&
            (identical(
                  other.commonCoverage,
                  commonCoverage,
                ) ||
                other.commonCoverage == commonCoverage) &&
            const _iss.DeepCollectionEquality().equals(
              other.commonSlots,
              commonSlots,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      snapshotId,
      calculatedAtUtc,
      fromUtc,
      untilUtc,
      mode,
      minimumSeconds,
      const _iss.DeepCollectionEquality().hash(results),
      commonCoverage,
      const _iss.DeepCollectionEquality().hash(commonSlots),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilitySearchView',
      'snapshotId': snapshotId.toJson(),
      'calculatedAtUtc': calculatedAtUtc.toJson(),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'mode': mode.toJson(),
      'minimumSeconds': minimumSeconds,
      'results': results.toJson(valueToJson: (v) => v.toJson()),
      if (commonCoverage != null) 'commonCoverage': commonCoverage?.toJson(),
      'commonSlots': commonSlots.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilitySearchView',
      'snapshotId': snapshotId.toJson(),
      'calculatedAtUtc': calculatedAtUtc.toJson(),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'mode': mode.toJson(),
      'minimumSeconds': minimumSeconds,
      'results': results.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (commonCoverage != null) 'commonCoverage': commonCoverage?.toJson(),
      'commonSlots': commonSlots.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilitySearchViewImpl
    extends CalendarAvailabilitySearchView {
  const _CalendarAvailabilitySearchViewImpl({
    required _isc.UuidValue snapshotId,
    required DateTime calculatedAtUtc,
    required DateTime fromUtc,
    required DateTime untilUtc,
    required _iam4llos.CalendarAvailabilitySearchMode mode,
    required int minimumSeconds,
    required List<_imo3vsmf.CalendarSubjectAvailability> results,
    _ia3n9q23.CalendarFreeBusyCoverage? commonCoverage,
    required List<_i45h4t8f.CalendarAvailabilitySlot> commonSlots,
  }) : super._(
         snapshotId: snapshotId,
         calculatedAtUtc: calculatedAtUtc,
         fromUtc: fromUtc,
         untilUtc: untilUtc,
         mode: mode,
         minimumSeconds: minimumSeconds,
         results: results,
         commonCoverage: commonCoverage,
         commonSlots: commonSlots,
       );

  /// Returns a shallow copy of this [CalendarAvailabilitySearchView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilitySearchView copyWith({
    _isc.UuidValue? snapshotId,
    DateTime? calculatedAtUtc,
    DateTime? fromUtc,
    DateTime? untilUtc,
    _iam4llos.CalendarAvailabilitySearchMode? mode,
    int? minimumSeconds,
    List<_imo3vsmf.CalendarSubjectAvailability>? results,
    Object? commonCoverage = _Undefined,
    List<_i45h4t8f.CalendarAvailabilitySlot>? commonSlots,
  }) {
    return CalendarAvailabilitySearchView(
      snapshotId: snapshotId ?? this.snapshotId,
      calculatedAtUtc: calculatedAtUtc ?? this.calculatedAtUtc,
      fromUtc: fromUtc ?? this.fromUtc,
      untilUtc: untilUtc ?? this.untilUtc,
      mode: mode ?? this.mode,
      minimumSeconds: minimumSeconds ?? this.minimumSeconds,
      results: results ?? this.results.map((e0) => e0.copyWith()).toList(),
      commonCoverage: commonCoverage is _ia3n9q23.CalendarFreeBusyCoverage?
          ? commonCoverage
          : this.commonCoverage,
      commonSlots:
          commonSlots ?? this.commonSlots.map((e0) => e0.copyWith()).toList(),
    );
  }
}
