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
import 'calendar_alarm_definition.dart' as _irif99jb;

@_isc.immutable
abstract class CalendarAlarmSourceTimings
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAlarmSourceTimings._({
    required this.parentRevision,
    required this.definitions,
  });

  const factory CalendarAlarmSourceTimings({
    required int parentRevision,
    required List<_irif99jb.CalendarAlarmDefinition> definitions,
  }) = _CalendarAlarmSourceTimingsImpl;

  factory CalendarAlarmSourceTimings.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmSourceTimings(
      parentRevision: jsonSerialization['parentRevision'] as int,
      definitions: _ie4a1wrz.Protocol()
          .deserialize<List<_irif99jb.CalendarAlarmDefinition>>(
            jsonSerialization['definitions'],
          ),
    );
  }

  final int parentRevision;

  final List<_irif99jb.CalendarAlarmDefinition> definitions;

  /// Returns a shallow copy of this [CalendarAlarmSourceTimings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAlarmSourceTimings copyWith({
    int? parentRevision,
    List<_irif99jb.CalendarAlarmDefinition>? definitions,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAlarmSourceTimings &&
            (identical(
                  other.parentRevision,
                  parentRevision,
                ) ||
                other.parentRevision == parentRevision) &&
            const _iss.DeepCollectionEquality().equals(
              other.definitions,
              definitions,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      parentRevision,
      const _iss.DeepCollectionEquality().hash(definitions),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmSourceTimings',
      'parentRevision': parentRevision,
      'definitions': definitions.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmSourceTimings',
      'parentRevision': parentRevision,
      'definitions': definitions.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAlarmSourceTimingsImpl extends CalendarAlarmSourceTimings {
  const _CalendarAlarmSourceTimingsImpl({
    required int parentRevision,
    required List<_irif99jb.CalendarAlarmDefinition> definitions,
  }) : super._(
         parentRevision: parentRevision,
         definitions: definitions,
       );

  /// Returns a shallow copy of this [CalendarAlarmSourceTimings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAlarmSourceTimings copyWith({
    int? parentRevision,
    List<_irif99jb.CalendarAlarmDefinition>? definitions,
  }) {
    return CalendarAlarmSourceTimings(
      parentRevision: parentRevision ?? this.parentRevision,
      definitions:
          definitions ?? this.definitions.map((e0) => e0.copyWith()).toList(),
    );
  }
}
