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
import 'calendar_event_civil.dart' as _i1bb5k1r;
import 'calendar_event_duration.dart' as _idn2i48l;
import 'calendar_task_time_kind.dart' as _ijhc2xsq;

@_isc.immutable
abstract class CalendarTaskTiming
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskTiming._({
    required this.kind,
    this.start,
    this.due,
    this.duration,
    this.zoneId,
  });

  const factory CalendarTaskTiming({
    required _ijhc2xsq.CalendarTaskTimeKind kind,
    _i1bb5k1r.CalendarEventCivil? start,
    _i1bb5k1r.CalendarEventCivil? due,
    _idn2i48l.CalendarEventDuration? duration,
    String? zoneId,
  }) = _CalendarTaskTimingImpl;

  factory CalendarTaskTiming.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarTaskTiming(
      kind: _ijhc2xsq.CalendarTaskTimeKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      start: jsonSerialization['start'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['start'],
            ),
      due: jsonSerialization['due'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['due'],
            ),
      duration: jsonSerialization['duration'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_idn2i48l.CalendarEventDuration>(
              jsonSerialization['duration'],
            ),
      zoneId: jsonSerialization['zoneId'] as String?,
    );
  }

  final _ijhc2xsq.CalendarTaskTimeKind kind;

  final _i1bb5k1r.CalendarEventCivil? start;

  final _i1bb5k1r.CalendarEventCivil? due;

  final _idn2i48l.CalendarEventDuration? duration;

  final String? zoneId;

  /// Returns a shallow copy of this [CalendarTaskTiming]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskTiming copyWith({
    _ijhc2xsq.CalendarTaskTimeKind? kind,
    _i1bb5k1r.CalendarEventCivil? start,
    _i1bb5k1r.CalendarEventCivil? due,
    _idn2i48l.CalendarEventDuration? duration,
    String? zoneId,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskTiming &&
            (identical(
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
            (identical(
                  other.start,
                  start,
                ) ||
                other.start == start) &&
            (identical(
                  other.due,
                  due,
                ) ||
                other.due == due) &&
            (identical(
                  other.duration,
                  duration,
                ) ||
                other.duration == duration) &&
            (identical(
                  other.zoneId,
                  zoneId,
                ) ||
                other.zoneId == zoneId);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      kind,
      start,
      due,
      duration,
      zoneId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskTiming',
      'kind': kind.toJson(),
      if (start != null) 'start': start?.toJson(),
      if (due != null) 'due': due?.toJson(),
      if (duration != null) 'duration': duration?.toJson(),
      if (zoneId != null) 'zoneId': zoneId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskTiming',
      'kind': kind.toJson(),
      if (start != null) 'start': start?.toJsonForProtocol(),
      if (due != null) 'due': due?.toJsonForProtocol(),
      if (duration != null) 'duration': duration?.toJsonForProtocol(),
      if (zoneId != null) 'zoneId': zoneId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskTimingImpl extends CalendarTaskTiming {
  const _CalendarTaskTimingImpl({
    required _ijhc2xsq.CalendarTaskTimeKind kind,
    _i1bb5k1r.CalendarEventCivil? start,
    _i1bb5k1r.CalendarEventCivil? due,
    _idn2i48l.CalendarEventDuration? duration,
    String? zoneId,
  }) : super._(
         kind: kind,
         start: start,
         due: due,
         duration: duration,
         zoneId: zoneId,
       );

  /// Returns a shallow copy of this [CalendarTaskTiming]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskTiming copyWith({
    _ijhc2xsq.CalendarTaskTimeKind? kind,
    Object? start = _Undefined,
    Object? due = _Undefined,
    Object? duration = _Undefined,
    Object? zoneId = _Undefined,
  }) {
    return CalendarTaskTiming(
      kind: kind ?? this.kind,
      start: start is _i1bb5k1r.CalendarEventCivil?
          ? start
          : this.start?.copyWith(),
      due: due is _i1bb5k1r.CalendarEventCivil? ? due : this.due?.copyWith(),
      duration: duration is _idn2i48l.CalendarEventDuration?
          ? duration
          : this.duration?.copyWith(),
      zoneId: zoneId is String? ? zoneId : this.zoneId,
    );
  }
}
