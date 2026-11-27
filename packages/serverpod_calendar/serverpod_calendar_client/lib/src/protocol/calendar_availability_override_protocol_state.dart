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
import 'calendar_availability_source_metadata.dart' as _i15w6qdl;
import 'calendar_event_timing.dart' as _ieswiaty;

@_isc.immutable
abstract class CalendarAvailabilityOverrideProtocolState
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityOverrideProtocolState._({
    required this.originalStart,
    bool? isThisAndFuture,
    required this.stamp,
    this.created,
    this.lastModified,
    this.metadata,
  }) : isThisAndFuture = isThisAndFuture ?? false;

  const factory CalendarAvailabilityOverrideProtocolState({
    required _ieswiaty.CalendarEventTiming originalStart,
    bool? isThisAndFuture,
    required DateTime stamp,
    DateTime? created,
    DateTime? lastModified,
    _i15w6qdl.CalendarAvailabilitySourceMetadata? metadata,
  }) = _CalendarAvailabilityOverrideProtocolStateImpl;

  factory CalendarAvailabilityOverrideProtocolState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOverrideProtocolState(
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      isThisAndFuture: jsonSerialization['isThisAndFuture'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['isThisAndFuture'],
            ),
      stamp: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      created: jsonSerialization['created'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
      lastModified: jsonSerialization['lastModified'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastModified'],
            ),
      metadata: jsonSerialization['metadata'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_i15w6qdl.CalendarAvailabilitySourceMetadata>(
                  jsonSerialization['metadata'],
                ),
    );
  }

  final _ieswiaty.CalendarEventTiming originalStart;

  final bool isThisAndFuture;

  final DateTime stamp;

  final DateTime? created;

  final DateTime? lastModified;

  final _i15w6qdl.CalendarAvailabilitySourceMetadata? metadata;

  /// Returns a shallow copy of this [CalendarAvailabilityOverrideProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityOverrideProtocolState copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    bool? isThisAndFuture,
    DateTime? stamp,
    DateTime? created,
    DateTime? lastModified,
    _i15w6qdl.CalendarAvailabilitySourceMetadata? metadata,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityOverrideProtocolState &&
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
                  other.stamp,
                  stamp,
                ) ||
                other.stamp == stamp) &&
            (identical(
                  other.created,
                  created,
                ) ||
                other.created == created) &&
            (identical(
                  other.lastModified,
                  lastModified,
                ) ||
                other.lastModified == lastModified) &&
            (identical(
                  other.metadata,
                  metadata,
                ) ||
                other.metadata == metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      originalStart,
      isThisAndFuture,
      stamp,
      created,
      lastModified,
      metadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAvailabilityOverrideProtocolState',
      'originalStart': originalStart.toJson(),
      'isThisAndFuture': isThisAndFuture,
      'stamp': stamp.toJson(),
      if (created != null) 'created': created?.toJson(),
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAvailabilityOverrideProtocolState',
      'originalStart': originalStart.toJsonForProtocol(),
      'isThisAndFuture': isThisAndFuture,
      'stamp': stamp.toJson(),
      if (created != null) 'created': created?.toJson(),
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
      if (metadata != null) 'metadata': metadata?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityOverrideProtocolStateImpl
    extends CalendarAvailabilityOverrideProtocolState {
  const _CalendarAvailabilityOverrideProtocolStateImpl({
    required _ieswiaty.CalendarEventTiming originalStart,
    bool? isThisAndFuture,
    required DateTime stamp,
    DateTime? created,
    DateTime? lastModified,
    _i15w6qdl.CalendarAvailabilitySourceMetadata? metadata,
  }) : super._(
         originalStart: originalStart,
         isThisAndFuture: isThisAndFuture,
         stamp: stamp,
         created: created,
         lastModified: lastModified,
         metadata: metadata,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOverrideProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityOverrideProtocolState copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    bool? isThisAndFuture,
    DateTime? stamp,
    Object? created = _Undefined,
    Object? lastModified = _Undefined,
    Object? metadata = _Undefined,
  }) {
    return CalendarAvailabilityOverrideProtocolState(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      isThisAndFuture: isThisAndFuture ?? this.isThisAndFuture,
      stamp: stamp ?? this.stamp,
      created: created is DateTime? ? created : this.created,
      lastModified: lastModified is DateTime?
          ? lastModified
          : this.lastModified,
      metadata: metadata is _i15w6qdl.CalendarAvailabilitySourceMetadata?
          ? metadata
          : this.metadata?.copyWith(),
    );
  }
}
