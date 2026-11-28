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
import 'calendar_alarm_definition.dart' as _irif99jb;
import 'calendar_alarm_parent.dart' as _iiyuulin;
import 'calendar_alarm_plan_status.dart' as _irtomk7p;

@_is.immutable
abstract class CalendarAlarmView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAlarmView._({
    required this.id,
    required this.parent,
    required this.revision,
    bool? armed,
    this.planningStatus,
    this.planningWindowEnd,
    required this.definition,
    required this.anchorCompatible,
    required this.createdAt,
    required this.updatedAt,
  }) : armed = armed ?? false;

  const factory CalendarAlarmView({
    required _is.UuidValue id,
    required _iiyuulin.CalendarAlarmParent parent,
    required int revision,
    bool? armed,
    _irtomk7p.CalendarAlarmPlanStatus? planningStatus,
    DateTime? planningWindowEnd,
    required _irif99jb.CalendarAlarmDefinition definition,
    required bool anchorCompatible,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarAlarmViewImpl;

  factory CalendarAlarmView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarAlarmView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      parent: _ix00hwbf.Protocol().deserialize<_iiyuulin.CalendarAlarmParent>(
        jsonSerialization['parent'],
      ),
      revision: jsonSerialization['revision'] as int,
      armed: jsonSerialization['armed'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['armed']),
      planningStatus: jsonSerialization['planningStatus'] == null
          ? null
          : _irtomk7p.CalendarAlarmPlanStatus.fromJson(
              (jsonSerialization['planningStatus'] as String),
            ),
      planningWindowEnd: jsonSerialization['planningWindowEnd'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['planningWindowEnd'],
            ),
      definition: _ix00hwbf.Protocol()
          .deserialize<_irif99jb.CalendarAlarmDefinition>(
            jsonSerialization['definition'],
          ),
      anchorCompatible: _is.BoolJsonExtension.fromJson(
        jsonSerialization['anchorCompatible'],
      ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  final _is.UuidValue id;

  final _iiyuulin.CalendarAlarmParent parent;

  final int revision;

  final bool armed;

  final _irtomk7p.CalendarAlarmPlanStatus? planningStatus;

  final DateTime? planningWindowEnd;

  final _irif99jb.CalendarAlarmDefinition definition;

  final bool anchorCompatible;

  final DateTime createdAt;

  final DateTime updatedAt;

  /// Returns a shallow copy of this [CalendarAlarmView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAlarmView copyWith({
    _is.UuidValue? id,
    _iiyuulin.CalendarAlarmParent? parent,
    int? revision,
    bool? armed,
    _irtomk7p.CalendarAlarmPlanStatus? planningStatus,
    DateTime? planningWindowEnd,
    _irif99jb.CalendarAlarmDefinition? definition,
    bool? anchorCompatible,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAlarmView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.parent,
                  parent,
                ) ||
                other.parent == parent) &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            (identical(
                  other.armed,
                  armed,
                ) ||
                other.armed == armed) &&
            (identical(
                  other.planningStatus,
                  planningStatus,
                ) ||
                other.planningStatus == planningStatus) &&
            (identical(
                  other.planningWindowEnd,
                  planningWindowEnd,
                ) ||
                other.planningWindowEnd == planningWindowEnd) &&
            (identical(
                  other.definition,
                  definition,
                ) ||
                other.definition == definition) &&
            (identical(
                  other.anchorCompatible,
                  anchorCompatible,
                ) ||
                other.anchorCompatible == anchorCompatible) &&
            (identical(
                  other.createdAt,
                  createdAt,
                ) ||
                other.createdAt == createdAt) &&
            (identical(
                  other.updatedAt,
                  updatedAt,
                ) ||
                other.updatedAt == updatedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      parent,
      revision,
      armed,
      planningStatus,
      planningWindowEnd,
      definition,
      anchorCompatible,
      createdAt,
      updatedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmView',
      'id': id.toJson(),
      'parent': parent.toJson(),
      'revision': revision,
      'armed': armed,
      if (planningStatus != null) 'planningStatus': planningStatus?.toJson(),
      if (planningWindowEnd != null)
        'planningWindowEnd': planningWindowEnd?.toJson(),
      'definition': definition.toJson(),
      'anchorCompatible': anchorCompatible,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmView',
      'id': id.toJson(),
      'parent': parent.toJsonForProtocol(),
      'revision': revision,
      'armed': armed,
      if (planningStatus != null) 'planningStatus': planningStatus?.toJson(),
      if (planningWindowEnd != null)
        'planningWindowEnd': planningWindowEnd?.toJson(),
      'definition': definition.toJsonForProtocol(),
      'anchorCompatible': anchorCompatible,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAlarmViewImpl extends CalendarAlarmView {
  const _CalendarAlarmViewImpl({
    required _is.UuidValue id,
    required _iiyuulin.CalendarAlarmParent parent,
    required int revision,
    bool? armed,
    _irtomk7p.CalendarAlarmPlanStatus? planningStatus,
    DateTime? planningWindowEnd,
    required _irif99jb.CalendarAlarmDefinition definition,
    required bool anchorCompatible,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         parent: parent,
         revision: revision,
         armed: armed,
         planningStatus: planningStatus,
         planningWindowEnd: planningWindowEnd,
         definition: definition,
         anchorCompatible: anchorCompatible,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarAlarmView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAlarmView copyWith({
    _is.UuidValue? id,
    _iiyuulin.CalendarAlarmParent? parent,
    int? revision,
    bool? armed,
    Object? planningStatus = _Undefined,
    Object? planningWindowEnd = _Undefined,
    _irif99jb.CalendarAlarmDefinition? definition,
    bool? anchorCompatible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarAlarmView(
      id: id ?? this.id,
      parent: parent ?? this.parent.copyWith(),
      revision: revision ?? this.revision,
      armed: armed ?? this.armed,
      planningStatus: planningStatus is _irtomk7p.CalendarAlarmPlanStatus?
          ? planningStatus
          : this.planningStatus,
      planningWindowEnd: planningWindowEnd is DateTime?
          ? planningWindowEnd
          : this.planningWindowEnd,
      definition: definition ?? this.definition.copyWith(),
      anchorCompatible: anchorCompatible ?? this.anchorCompatible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
