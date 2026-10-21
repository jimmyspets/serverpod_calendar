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
import 'calendar_event_civil.dart' as _i1bb5k1r;
import 'calendar_event_duration.dart' as _idn2i48l;
import 'calendar_event_time_kind.dart' as _idbnuf6y;

@_is.immutable
abstract class CalendarEventTiming
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventTiming._({
    required this.kind,
    required this.start,
    this.end,
    this.duration,
    this.zoneId,
  });

  const factory CalendarEventTiming({
    required _idbnuf6y.CalendarEventTimeKind kind,
    required _i1bb5k1r.CalendarEventCivil start,
    _i1bb5k1r.CalendarEventCivil? end,
    _idn2i48l.CalendarEventDuration? duration,
    String? zoneId,
  }) = _CalendarEventTimingImpl;

  factory CalendarEventTiming.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarEventTiming(
      kind: _idbnuf6y.CalendarEventTimeKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      start: _ix00hwbf.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
        jsonSerialization['start'],
      ),
      end: jsonSerialization['end'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['end'],
            ),
      duration: jsonSerialization['duration'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_idn2i48l.CalendarEventDuration>(
              jsonSerialization['duration'],
            ),
      zoneId: jsonSerialization['zoneId'] as String?,
    );
  }

  final _idbnuf6y.CalendarEventTimeKind kind;

  final _i1bb5k1r.CalendarEventCivil start;

  final _i1bb5k1r.CalendarEventCivil? end;

  final _idn2i48l.CalendarEventDuration? duration;

  final String? zoneId;

  /// Returns a shallow copy of this [CalendarEventTiming]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventTiming copyWith({
    _idbnuf6y.CalendarEventTimeKind? kind,
    _i1bb5k1r.CalendarEventCivil? start,
    _i1bb5k1r.CalendarEventCivil? end,
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
            other is CalendarEventTiming &&
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
                  other.end,
                  end,
                ) ||
                other.end == end) &&
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
      end,
      duration,
      zoneId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventTiming',
      'kind': kind.toJson(),
      'start': start.toJson(),
      if (end != null) 'end': end?.toJson(),
      if (duration != null) 'duration': duration?.toJson(),
      if (zoneId != null) 'zoneId': zoneId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventTiming',
      'kind': kind.toJson(),
      'start': start.toJsonForProtocol(),
      if (end != null) 'end': end?.toJsonForProtocol(),
      if (duration != null) 'duration': duration?.toJsonForProtocol(),
      if (zoneId != null) 'zoneId': zoneId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventTimingImpl extends CalendarEventTiming {
  const _CalendarEventTimingImpl({
    required _idbnuf6y.CalendarEventTimeKind kind,
    required _i1bb5k1r.CalendarEventCivil start,
    _i1bb5k1r.CalendarEventCivil? end,
    _idn2i48l.CalendarEventDuration? duration,
    String? zoneId,
  }) : super._(
         kind: kind,
         start: start,
         end: end,
         duration: duration,
         zoneId: zoneId,
       );

  /// Returns a shallow copy of this [CalendarEventTiming]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventTiming copyWith({
    _idbnuf6y.CalendarEventTimeKind? kind,
    _i1bb5k1r.CalendarEventCivil? start,
    Object? end = _Undefined,
    Object? duration = _Undefined,
    Object? zoneId = _Undefined,
  }) {
    return CalendarEventTiming(
      kind: kind ?? this.kind,
      start: start ?? this.start.copyWith(),
      end: end is _i1bb5k1r.CalendarEventCivil? ? end : this.end?.copyWith(),
      duration: duration is _idn2i48l.CalendarEventDuration?
          ? duration
          : this.duration?.copyWith(),
      zoneId: zoneId is String? ? zoneId : this.zoneId,
    );
  }
}
