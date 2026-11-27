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
import 'calendar_event_recurrence.dart' as _iqxs44bf;
import 'calendar_event_timing.dart' as _ieswiaty;

@_is.immutable
abstract class CalendarAvailabilityOpening
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityOpening._({
    this.uid,
    required this.timing,
    this.recurrence,
  });

  const factory CalendarAvailabilityOpening({
    _is.UuidValue? uid,
    required _ieswiaty.CalendarEventTiming timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
  }) = _CalendarAvailabilityOpeningImpl;

  factory CalendarAvailabilityOpening.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOpening(
      uid: jsonSerialization['uid'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['uid']),
      timing: _ix00hwbf.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
        jsonSerialization['timing'],
      ),
      recurrence: jsonSerialization['recurrence'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_iqxs44bf.CalendarEventRecurrence>(
              jsonSerialization['recurrence'],
            ),
    );
  }

  final _is.UuidValue? uid;

  final _ieswiaty.CalendarEventTiming timing;

  final _iqxs44bf.CalendarEventRecurrence? recurrence;

  /// Returns a shallow copy of this [CalendarAvailabilityOpening]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityOpening copyWith({
    _is.UuidValue? uid,
    _ieswiaty.CalendarEventTiming? timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityOpening &&
            (identical(
                  other.uid,
                  uid,
                ) ||
                other.uid == uid) &&
            (identical(
                  other.timing,
                  timing,
                ) ||
                other.timing == timing) &&
            (identical(
                  other.recurrence,
                  recurrence,
                ) ||
                other.recurrence == recurrence);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      uid,
      timing,
      recurrence,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOpening',
      if (uid != null) 'uid': uid?.toJson(),
      'timing': timing.toJson(),
      if (recurrence != null) 'recurrence': recurrence?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOpening',
      if (uid != null) 'uid': uid?.toJson(),
      'timing': timing.toJsonForProtocol(),
      if (recurrence != null) 'recurrence': recurrence?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityOpeningImpl extends CalendarAvailabilityOpening {
  const _CalendarAvailabilityOpeningImpl({
    _is.UuidValue? uid,
    required _ieswiaty.CalendarEventTiming timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
  }) : super._(
         uid: uid,
         timing: timing,
         recurrence: recurrence,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOpening]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityOpening copyWith({
    Object? uid = _Undefined,
    _ieswiaty.CalendarEventTiming? timing,
    Object? recurrence = _Undefined,
  }) {
    return CalendarAvailabilityOpening(
      uid: uid is _is.UuidValue? ? uid : this.uid,
      timing: timing ?? this.timing.copyWith(),
      recurrence: recurrence is _iqxs44bf.CalendarEventRecurrence?
          ? recurrence
          : this.recurrence?.copyWith(),
    );
  }
}
