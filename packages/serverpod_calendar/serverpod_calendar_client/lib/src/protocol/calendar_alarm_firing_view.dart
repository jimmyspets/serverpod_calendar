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
import 'calendar_alarm_action_view.dart' as _ixqjnkie;
import 'calendar_alarm_firing_kind.dart' as _i8okwxwj;
import 'calendar_alarm_firing_state.dart' as _ihos0r46;

@_isc.immutable
abstract class CalendarAlarmFiringView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAlarmFiringView._({
    required this.id,
    required this.alarmId,
    required this.originalKey,
    required this.kind,
    required this.dueAt,
    required this.expiresAt,
    required this.state,
    this.acceptedAt,
    this.action,
  });

  const factory CalendarAlarmFiringView({
    required _isc.UuidValue id,
    required _isc.UuidValue alarmId,
    required String originalKey,
    required _i8okwxwj.CalendarAlarmFiringKind kind,
    required DateTime dueAt,
    required DateTime expiresAt,
    required _ihos0r46.CalendarAlarmFiringState state,
    DateTime? acceptedAt,
    _ixqjnkie.CalendarAlarmActionView? action,
  }) = _CalendarAlarmFiringViewImpl;

  factory CalendarAlarmFiringView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmFiringView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      alarmId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['alarmId'],
      ),
      originalKey: jsonSerialization['originalKey'] as String,
      kind: _i8okwxwj.CalendarAlarmFiringKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      dueAt: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      state: _ihos0r46.CalendarAlarmFiringState.fromJson(
        (jsonSerialization['state'] as String),
      ),
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['acceptedAt'],
            ),
      action: jsonSerialization['action'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ixqjnkie.CalendarAlarmActionView>(
              jsonSerialization['action'],
            ),
    );
  }

  final _isc.UuidValue id;

  final _isc.UuidValue alarmId;

  final String originalKey;

  final _i8okwxwj.CalendarAlarmFiringKind kind;

  final DateTime dueAt;

  final DateTime expiresAt;

  final _ihos0r46.CalendarAlarmFiringState state;

  final DateTime? acceptedAt;

  final _ixqjnkie.CalendarAlarmActionView? action;

  /// Returns a shallow copy of this [CalendarAlarmFiringView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAlarmFiringView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? alarmId,
    String? originalKey,
    _i8okwxwj.CalendarAlarmFiringKind? kind,
    DateTime? dueAt,
    DateTime? expiresAt,
    _ihos0r46.CalendarAlarmFiringState? state,
    DateTime? acceptedAt,
    _ixqjnkie.CalendarAlarmActionView? action,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAlarmFiringView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.alarmId,
                  alarmId,
                ) ||
                other.alarmId == alarmId) &&
            (identical(
                  other.originalKey,
                  originalKey,
                ) ||
                other.originalKey == originalKey) &&
            (identical(
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
            (identical(
                  other.dueAt,
                  dueAt,
                ) ||
                other.dueAt == dueAt) &&
            (identical(
                  other.expiresAt,
                  expiresAt,
                ) ||
                other.expiresAt == expiresAt) &&
            (identical(
                  other.state,
                  state,
                ) ||
                other.state == state) &&
            (identical(
                  other.acceptedAt,
                  acceptedAt,
                ) ||
                other.acceptedAt == acceptedAt) &&
            (identical(
                  other.action,
                  action,
                ) ||
                other.action == action);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      alarmId,
      originalKey,
      kind,
      dueAt,
      expiresAt,
      state,
      acceptedAt,
      action,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmFiringView',
      'id': id.toJson(),
      'alarmId': alarmId.toJson(),
      'originalKey': originalKey,
      'kind': kind.toJson(),
      'dueAt': dueAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'state': state.toJson(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (action != null) 'action': action?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmFiringView',
      'id': id.toJson(),
      'alarmId': alarmId.toJson(),
      'originalKey': originalKey,
      'kind': kind.toJson(),
      'dueAt': dueAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'state': state.toJson(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (action != null) 'action': action?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAlarmFiringViewImpl extends CalendarAlarmFiringView {
  const _CalendarAlarmFiringViewImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue alarmId,
    required String originalKey,
    required _i8okwxwj.CalendarAlarmFiringKind kind,
    required DateTime dueAt,
    required DateTime expiresAt,
    required _ihos0r46.CalendarAlarmFiringState state,
    DateTime? acceptedAt,
    _ixqjnkie.CalendarAlarmActionView? action,
  }) : super._(
         id: id,
         alarmId: alarmId,
         originalKey: originalKey,
         kind: kind,
         dueAt: dueAt,
         expiresAt: expiresAt,
         state: state,
         acceptedAt: acceptedAt,
         action: action,
       );

  /// Returns a shallow copy of this [CalendarAlarmFiringView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAlarmFiringView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? alarmId,
    String? originalKey,
    _i8okwxwj.CalendarAlarmFiringKind? kind,
    DateTime? dueAt,
    DateTime? expiresAt,
    _ihos0r46.CalendarAlarmFiringState? state,
    Object? acceptedAt = _Undefined,
    Object? action = _Undefined,
  }) {
    return CalendarAlarmFiringView(
      id: id ?? this.id,
      alarmId: alarmId ?? this.alarmId,
      originalKey: originalKey ?? this.originalKey,
      kind: kind ?? this.kind,
      dueAt: dueAt ?? this.dueAt,
      expiresAt: expiresAt ?? this.expiresAt,
      state: state ?? this.state,
      acceptedAt: acceptedAt is DateTime? ? acceptedAt : this.acceptedAt,
      action: action is _ixqjnkie.CalendarAlarmActionView?
          ? action
          : this.action?.copyWith(),
    );
  }
}
