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
import 'calendar_task_source_duration.dart' as _im8khkr9;
import 'calendar_task_source_text.dart' as _i9mnuab5;

@_is.immutable
abstract class CalendarTaskSourceAlarm
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskSourceAlarm._({
    required this.description,
    this.relativeDuration,
    this.absoluteUtc,
    this.related,
    this.uid,
    this.acknowledged,
    this.repeat,
    this.repeatInterval,
    this.snoozeTargetUid,
  });

  const factory CalendarTaskSourceAlarm({
    required _i9mnuab5.CalendarTaskSourceText description,
    _im8khkr9.CalendarTaskSourceDuration? relativeDuration,
    DateTime? absoluteUtc,
    String? related,
    String? uid,
    DateTime? acknowledged,
    int? repeat,
    _im8khkr9.CalendarTaskSourceDuration? repeatInterval,
    String? snoozeTargetUid,
  }) = _CalendarTaskSourceAlarmImpl;

  factory CalendarTaskSourceAlarm.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskSourceAlarm(
      description: _ix00hwbf.Protocol()
          .deserialize<_i9mnuab5.CalendarTaskSourceText>(
            jsonSerialization['description'],
          ),
      relativeDuration: jsonSerialization['relativeDuration'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_im8khkr9.CalendarTaskSourceDuration>(
                  jsonSerialization['relativeDuration'],
                ),
      absoluteUtc: jsonSerialization['absoluteUtc'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['absoluteUtc'],
            ),
      related: jsonSerialization['related'] as String?,
      uid: jsonSerialization['uid'] as String?,
      acknowledged: jsonSerialization['acknowledged'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['acknowledged'],
            ),
      repeat: jsonSerialization['repeat'] as int?,
      repeatInterval: jsonSerialization['repeatInterval'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_im8khkr9.CalendarTaskSourceDuration>(
                  jsonSerialization['repeatInterval'],
                ),
      snoozeTargetUid: jsonSerialization['snoozeTargetUid'] as String?,
    );
  }

  final _i9mnuab5.CalendarTaskSourceText description;

  final _im8khkr9.CalendarTaskSourceDuration? relativeDuration;

  final DateTime? absoluteUtc;

  final String? related;

  final String? uid;

  final DateTime? acknowledged;

  final int? repeat;

  final _im8khkr9.CalendarTaskSourceDuration? repeatInterval;

  final String? snoozeTargetUid;

  /// Returns a shallow copy of this [CalendarTaskSourceAlarm]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskSourceAlarm copyWith({
    _i9mnuab5.CalendarTaskSourceText? description,
    _im8khkr9.CalendarTaskSourceDuration? relativeDuration,
    DateTime? absoluteUtc,
    String? related,
    String? uid,
    DateTime? acknowledged,
    int? repeat,
    _im8khkr9.CalendarTaskSourceDuration? repeatInterval,
    String? snoozeTargetUid,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskSourceAlarm &&
            (identical(
                  other.description,
                  description,
                ) ||
                other.description == description) &&
            (identical(
                  other.relativeDuration,
                  relativeDuration,
                ) ||
                other.relativeDuration == relativeDuration) &&
            (identical(
                  other.absoluteUtc,
                  absoluteUtc,
                ) ||
                other.absoluteUtc == absoluteUtc) &&
            (identical(
                  other.related,
                  related,
                ) ||
                other.related == related) &&
            (identical(
                  other.uid,
                  uid,
                ) ||
                other.uid == uid) &&
            (identical(
                  other.acknowledged,
                  acknowledged,
                ) ||
                other.acknowledged == acknowledged) &&
            (identical(
                  other.repeat,
                  repeat,
                ) ||
                other.repeat == repeat) &&
            (identical(
                  other.repeatInterval,
                  repeatInterval,
                ) ||
                other.repeatInterval == repeatInterval) &&
            (identical(
                  other.snoozeTargetUid,
                  snoozeTargetUid,
                ) ||
                other.snoozeTargetUid == snoozeTargetUid);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      description,
      relativeDuration,
      absoluteUtc,
      related,
      uid,
      acknowledged,
      repeat,
      repeatInterval,
      snoozeTargetUid,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskSourceAlarm',
      'description': description.toJson(),
      if (relativeDuration != null)
        'relativeDuration': relativeDuration?.toJson(),
      if (absoluteUtc != null) 'absoluteUtc': absoluteUtc?.toJson(),
      if (related != null) 'related': related,
      if (uid != null) 'uid': uid,
      if (acknowledged != null) 'acknowledged': acknowledged?.toJson(),
      if (repeat != null) 'repeat': repeat,
      if (repeatInterval != null) 'repeatInterval': repeatInterval?.toJson(),
      if (snoozeTargetUid != null) 'snoozeTargetUid': snoozeTargetUid,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskSourceAlarmImpl extends CalendarTaskSourceAlarm {
  const _CalendarTaskSourceAlarmImpl({
    required _i9mnuab5.CalendarTaskSourceText description,
    _im8khkr9.CalendarTaskSourceDuration? relativeDuration,
    DateTime? absoluteUtc,
    String? related,
    String? uid,
    DateTime? acknowledged,
    int? repeat,
    _im8khkr9.CalendarTaskSourceDuration? repeatInterval,
    String? snoozeTargetUid,
  }) : super._(
         description: description,
         relativeDuration: relativeDuration,
         absoluteUtc: absoluteUtc,
         related: related,
         uid: uid,
         acknowledged: acknowledged,
         repeat: repeat,
         repeatInterval: repeatInterval,
         snoozeTargetUid: snoozeTargetUid,
       );

  /// Returns a shallow copy of this [CalendarTaskSourceAlarm]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskSourceAlarm copyWith({
    _i9mnuab5.CalendarTaskSourceText? description,
    Object? relativeDuration = _Undefined,
    Object? absoluteUtc = _Undefined,
    Object? related = _Undefined,
    Object? uid = _Undefined,
    Object? acknowledged = _Undefined,
    Object? repeat = _Undefined,
    Object? repeatInterval = _Undefined,
    Object? snoozeTargetUid = _Undefined,
  }) {
    return CalendarTaskSourceAlarm(
      description: description ?? this.description.copyWith(),
      relativeDuration:
          relativeDuration is _im8khkr9.CalendarTaskSourceDuration?
          ? relativeDuration
          : this.relativeDuration?.copyWith(),
      absoluteUtc: absoluteUtc is DateTime? ? absoluteUtc : this.absoluteUtc,
      related: related is String? ? related : this.related,
      uid: uid is String? ? uid : this.uid,
      acknowledged: acknowledged is DateTime?
          ? acknowledged
          : this.acknowledged,
      repeat: repeat is int? ? repeat : this.repeat,
      repeatInterval: repeatInterval is _im8khkr9.CalendarTaskSourceDuration?
          ? repeatInterval
          : this.repeatInterval?.copyWith(),
      snoozeTargetUid: snoozeTargetUid is String?
          ? snoozeTargetUid
          : this.snoozeTargetUid,
    );
  }
}
