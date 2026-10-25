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
import 'calendar_alarm_action_kind.dart' as _ihv8htej;
import 'calendar_alarm_parent.dart' as _iiyuulin;

@_isc.immutable
abstract class CalendarAlarmActionRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAlarmActionRequest._({
    required this.parent,
    required this.alarmId,
    required this.expectedAlarmRevision,
    required this.expectedActionRevision,
    required this.kind,
    this.firingId,
    this.actionId,
    this.snoozeAt,
  });

  const factory CalendarAlarmActionRequest({
    required _iiyuulin.CalendarAlarmParent parent,
    required _isc.UuidValue alarmId,
    required int expectedAlarmRevision,
    required int expectedActionRevision,
    required _ihv8htej.CalendarAlarmActionKind kind,
    _isc.UuidValue? firingId,
    _isc.UuidValue? actionId,
    DateTime? snoozeAt,
  }) = _CalendarAlarmActionRequestImpl;

  factory CalendarAlarmActionRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmActionRequest(
      parent: _ie4a1wrz.Protocol().deserialize<_iiyuulin.CalendarAlarmParent>(
        jsonSerialization['parent'],
      ),
      alarmId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['alarmId'],
      ),
      expectedAlarmRevision: jsonSerialization['expectedAlarmRevision'] as int,
      expectedActionRevision:
          jsonSerialization['expectedActionRevision'] as int,
      kind: _ihv8htej.CalendarAlarmActionKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      firingId: jsonSerialization['firingId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['firingId']),
      actionId: jsonSerialization['actionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['actionId']),
      snoozeAt: jsonSerialization['snoozeAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['snoozeAt']),
    );
  }

  final _iiyuulin.CalendarAlarmParent parent;

  final _isc.UuidValue alarmId;

  final int expectedAlarmRevision;

  final int expectedActionRevision;

  final _ihv8htej.CalendarAlarmActionKind kind;

  final _isc.UuidValue? firingId;

  final _isc.UuidValue? actionId;

  final DateTime? snoozeAt;

  /// Returns a shallow copy of this [CalendarAlarmActionRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAlarmActionRequest copyWith({
    _iiyuulin.CalendarAlarmParent? parent,
    _isc.UuidValue? alarmId,
    int? expectedAlarmRevision,
    int? expectedActionRevision,
    _ihv8htej.CalendarAlarmActionKind? kind,
    _isc.UuidValue? firingId,
    _isc.UuidValue? actionId,
    DateTime? snoozeAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAlarmActionRequest &&
            (identical(
                  other.parent,
                  parent,
                ) ||
                other.parent == parent) &&
            (identical(
                  other.alarmId,
                  alarmId,
                ) ||
                other.alarmId == alarmId) &&
            (identical(
                  other.expectedAlarmRevision,
                  expectedAlarmRevision,
                ) ||
                other.expectedAlarmRevision == expectedAlarmRevision) &&
            (identical(
                  other.expectedActionRevision,
                  expectedActionRevision,
                ) ||
                other.expectedActionRevision == expectedActionRevision) &&
            (identical(
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
            (identical(
                  other.firingId,
                  firingId,
                ) ||
                other.firingId == firingId) &&
            (identical(
                  other.actionId,
                  actionId,
                ) ||
                other.actionId == actionId) &&
            (identical(
                  other.snoozeAt,
                  snoozeAt,
                ) ||
                other.snoozeAt == snoozeAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      parent,
      alarmId,
      expectedAlarmRevision,
      expectedActionRevision,
      kind,
      firingId,
      actionId,
      snoozeAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmActionRequest',
      'parent': parent.toJson(),
      'alarmId': alarmId.toJson(),
      'expectedAlarmRevision': expectedAlarmRevision,
      'expectedActionRevision': expectedActionRevision,
      'kind': kind.toJson(),
      if (firingId != null) 'firingId': firingId?.toJson(),
      if (actionId != null) 'actionId': actionId?.toJson(),
      if (snoozeAt != null) 'snoozeAt': snoozeAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmActionRequest',
      'parent': parent.toJsonForProtocol(),
      'alarmId': alarmId.toJson(),
      'expectedAlarmRevision': expectedAlarmRevision,
      'expectedActionRevision': expectedActionRevision,
      'kind': kind.toJson(),
      if (firingId != null) 'firingId': firingId?.toJson(),
      if (actionId != null) 'actionId': actionId?.toJson(),
      if (snoozeAt != null) 'snoozeAt': snoozeAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAlarmActionRequestImpl extends CalendarAlarmActionRequest {
  const _CalendarAlarmActionRequestImpl({
    required _iiyuulin.CalendarAlarmParent parent,
    required _isc.UuidValue alarmId,
    required int expectedAlarmRevision,
    required int expectedActionRevision,
    required _ihv8htej.CalendarAlarmActionKind kind,
    _isc.UuidValue? firingId,
    _isc.UuidValue? actionId,
    DateTime? snoozeAt,
  }) : super._(
         parent: parent,
         alarmId: alarmId,
         expectedAlarmRevision: expectedAlarmRevision,
         expectedActionRevision: expectedActionRevision,
         kind: kind,
         firingId: firingId,
         actionId: actionId,
         snoozeAt: snoozeAt,
       );

  /// Returns a shallow copy of this [CalendarAlarmActionRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAlarmActionRequest copyWith({
    _iiyuulin.CalendarAlarmParent? parent,
    _isc.UuidValue? alarmId,
    int? expectedAlarmRevision,
    int? expectedActionRevision,
    _ihv8htej.CalendarAlarmActionKind? kind,
    Object? firingId = _Undefined,
    Object? actionId = _Undefined,
    Object? snoozeAt = _Undefined,
  }) {
    return CalendarAlarmActionRequest(
      parent: parent ?? this.parent.copyWith(),
      alarmId: alarmId ?? this.alarmId,
      expectedAlarmRevision:
          expectedAlarmRevision ?? this.expectedAlarmRevision,
      expectedActionRevision:
          expectedActionRevision ?? this.expectedActionRevision,
      kind: kind ?? this.kind,
      firingId: firingId is _isc.UuidValue? ? firingId : this.firingId,
      actionId: actionId is _isc.UuidValue? ? actionId : this.actionId,
      snoozeAt: snoozeAt is DateTime? ? snoozeAt : this.snoozeAt,
    );
  }
}
