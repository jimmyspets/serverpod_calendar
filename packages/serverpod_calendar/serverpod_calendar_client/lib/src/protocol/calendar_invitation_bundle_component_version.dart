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

import 'calendar_event_timing.dart' as _ieswiaty;

@_isc.immutable
abstract class CalendarInvitationBundleComponentVersion
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationBundleComponentVersion._({
    this.originalStart,
    bool? isThisAndFuture,
    this.sequence,
    required this.stamp,
  }) : isThisAndFuture = isThisAndFuture ?? false;

  const factory CalendarInvitationBundleComponentVersion({
    _ieswiaty.CalendarEventTiming? originalStart,
    bool? isThisAndFuture,
    int? sequence,
    required DateTime stamp,
  }) = _CalendarInvitationBundleComponentVersionImpl;

  factory CalendarInvitationBundleComponentVersion.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationBundleComponentVersion(
      originalStart: jsonSerialization['originalStart'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['originalStart'],
            ),
      isThisAndFuture: jsonSerialization['isThisAndFuture'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['isThisAndFuture'],
            ),
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
    );
  }

  final _ieswiaty.CalendarEventTiming? originalStart;

  final bool isThisAndFuture;

  final int? sequence;

  final DateTime stamp;

  /// Returns a shallow copy of this [CalendarInvitationBundleComponentVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationBundleComponentVersion copyWith({
    _ieswiaty.CalendarEventTiming? originalStart =
        const _UndefinedCalendarInvitationBundleComponentVersion$originalStart(),
    bool? isThisAndFuture,
    int? sequence,
    DateTime? stamp,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationBundleComponentVersion &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.isThisAndFuture,
                  isThisAndFuture,
                ) ||
                other.isThisAndFuture == isThisAndFuture) &&
            (identical(
                  other.sequence,
                  sequence,
                ) ||
                other.sequence == sequence) &&
            (identical(
                  other.stamp,
                  stamp,
                ) ||
                other.stamp == stamp);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      originalStart,
      isThisAndFuture,
      sequence,
      stamp,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationBundleComponentVersion',
      if (originalStart != null) 'originalStart': originalStart?.toJson(),
      'isThisAndFuture': isThisAndFuture,
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationBundleComponentVersion',
      if (originalStart != null)
        'originalStart': originalStart?.toJsonForProtocol(),
      'isThisAndFuture': isThisAndFuture,
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedCalendarInvitationBundleComponentVersion$originalStart
    extends _isc.UndefinedSentinel
    implements _ieswiaty.CalendarEventTiming {
  const _UndefinedCalendarInvitationBundleComponentVersion$originalStart();
}

class _CalendarInvitationBundleComponentVersionImpl
    extends CalendarInvitationBundleComponentVersion {
  const _CalendarInvitationBundleComponentVersionImpl({
    _ieswiaty.CalendarEventTiming? originalStart,
    bool? isThisAndFuture,
    int? sequence,
    required DateTime stamp,
  }) : super._(
         originalStart: originalStart,
         isThisAndFuture: isThisAndFuture,
         sequence: sequence,
         stamp: stamp,
       );

  /// Returns a shallow copy of this [CalendarInvitationBundleComponentVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationBundleComponentVersion copyWith({
    _ieswiaty.CalendarEventTiming? originalStart =
        const _UndefinedCalendarInvitationBundleComponentVersion$originalStart(),
    bool? isThisAndFuture,
    Object? sequence = _Undefined,
    DateTime? stamp,
  }) {
    return CalendarInvitationBundleComponentVersion(
      originalStart: originalStart is _isc.UndefinedSentinel
          ? this.originalStart?.copyWith()
          : originalStart,
      isThisAndFuture: isThisAndFuture ?? this.isThisAndFuture,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
    );
  }
}
