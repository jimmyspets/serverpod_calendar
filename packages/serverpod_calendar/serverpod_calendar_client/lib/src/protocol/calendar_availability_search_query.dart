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
import 'calendar_availability_target.dart' as _iwbqbnec;

@_isc.immutable
abstract class CalendarAvailabilitySearchQuery
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilitySearchQuery._({
    required this.targets,
    required this.fromUtc,
    required this.untilUtc,
    required this.mode,
    int? minimumSeconds,
  }) : minimumSeconds = minimumSeconds ?? 1;

  const factory CalendarAvailabilitySearchQuery({
    required List<_iwbqbnec.CalendarAvailabilityTarget> targets,
    required DateTime fromUtc,
    required DateTime untilUtc,
    required _iam4llos.CalendarAvailabilitySearchMode mode,
    int? minimumSeconds,
  }) = _CalendarAvailabilitySearchQueryImpl;

  factory CalendarAvailabilitySearchQuery.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilitySearchQuery(
      targets: _ie4a1wrz.Protocol()
          .deserialize<List<_iwbqbnec.CalendarAvailabilityTarget>>(
            jsonSerialization['targets'],
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
      minimumSeconds: jsonSerialization['minimumSeconds'] as int?,
    );
  }

  final List<_iwbqbnec.CalendarAvailabilityTarget> targets;

  final DateTime fromUtc;

  final DateTime untilUtc;

  final _iam4llos.CalendarAvailabilitySearchMode mode;

  final int minimumSeconds;

  /// Returns a shallow copy of this [CalendarAvailabilitySearchQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilitySearchQuery copyWith({
    List<_iwbqbnec.CalendarAvailabilityTarget>? targets,
    DateTime? fromUtc,
    DateTime? untilUtc,
    _iam4llos.CalendarAvailabilitySearchMode? mode,
    int? minimumSeconds,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilitySearchQuery &&
            const _iss.DeepCollectionEquality().equals(
              other.targets,
              targets,
            ) &&
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
                other.minimumSeconds == minimumSeconds);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(targets),
      fromUtc,
      untilUtc,
      mode,
      minimumSeconds,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilitySearchQuery',
      'targets': targets.toJson(valueToJson: (v) => v.toJson()),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'mode': mode.toJson(),
      'minimumSeconds': minimumSeconds,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilitySearchQuery',
      'targets': targets.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'mode': mode.toJson(),
      'minimumSeconds': minimumSeconds,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilitySearchQueryImpl
    extends CalendarAvailabilitySearchQuery {
  const _CalendarAvailabilitySearchQueryImpl({
    required List<_iwbqbnec.CalendarAvailabilityTarget> targets,
    required DateTime fromUtc,
    required DateTime untilUtc,
    required _iam4llos.CalendarAvailabilitySearchMode mode,
    int? minimumSeconds,
  }) : super._(
         targets: targets,
         fromUtc: fromUtc,
         untilUtc: untilUtc,
         mode: mode,
         minimumSeconds: minimumSeconds,
       );

  /// Returns a shallow copy of this [CalendarAvailabilitySearchQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilitySearchQuery copyWith({
    List<_iwbqbnec.CalendarAvailabilityTarget>? targets,
    DateTime? fromUtc,
    DateTime? untilUtc,
    _iam4llos.CalendarAvailabilitySearchMode? mode,
    int? minimumSeconds,
  }) {
    return CalendarAvailabilitySearchQuery(
      targets: targets ?? this.targets.map((e0) => e0.copyWith()).toList(),
      fromUtc: fromUtc ?? this.fromUtc,
      untilUtc: untilUtc ?? this.untilUtc,
      mode: mode ?? this.mode,
      minimumSeconds: minimumSeconds ?? this.minimumSeconds,
    );
  }
}
