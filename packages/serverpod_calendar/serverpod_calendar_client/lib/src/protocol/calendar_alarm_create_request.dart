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
import 'calendar_alarm_definition.dart' as _irif99jb;
import 'calendar_alarm_parent.dart' as _iiyuulin;

@_isc.immutable
abstract class CalendarAlarmCreateRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAlarmCreateRequest._({
    required this.parent,
    required this.definition,
  });

  const factory CalendarAlarmCreateRequest({
    required _iiyuulin.CalendarAlarmParent parent,
    required _irif99jb.CalendarAlarmDefinition definition,
  }) = _CalendarAlarmCreateRequestImpl;

  factory CalendarAlarmCreateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmCreateRequest(
      parent: _ie4a1wrz.Protocol().deserialize<_iiyuulin.CalendarAlarmParent>(
        jsonSerialization['parent'],
      ),
      definition: _ie4a1wrz.Protocol()
          .deserialize<_irif99jb.CalendarAlarmDefinition>(
            jsonSerialization['definition'],
          ),
    );
  }

  final _iiyuulin.CalendarAlarmParent parent;

  final _irif99jb.CalendarAlarmDefinition definition;

  /// Returns a shallow copy of this [CalendarAlarmCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAlarmCreateRequest copyWith({
    _iiyuulin.CalendarAlarmParent? parent,
    _irif99jb.CalendarAlarmDefinition? definition,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAlarmCreateRequest &&
            (identical(
                  other.parent,
                  parent,
                ) ||
                other.parent == parent) &&
            (identical(
                  other.definition,
                  definition,
                ) ||
                other.definition == definition);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      parent,
      definition,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmCreateRequest',
      'parent': parent.toJson(),
      'definition': definition.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmCreateRequest',
      'parent': parent.toJsonForProtocol(),
      'definition': definition.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAlarmCreateRequestImpl extends CalendarAlarmCreateRequest {
  const _CalendarAlarmCreateRequestImpl({
    required _iiyuulin.CalendarAlarmParent parent,
    required _irif99jb.CalendarAlarmDefinition definition,
  }) : super._(
         parent: parent,
         definition: definition,
       );

  /// Returns a shallow copy of this [CalendarAlarmCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAlarmCreateRequest copyWith({
    _iiyuulin.CalendarAlarmParent? parent,
    _irif99jb.CalendarAlarmDefinition? definition,
  }) {
    return CalendarAlarmCreateRequest(
      parent: parent ?? this.parent.copyWith(),
      definition: definition ?? this.definition.copyWith(),
    );
  }
}
