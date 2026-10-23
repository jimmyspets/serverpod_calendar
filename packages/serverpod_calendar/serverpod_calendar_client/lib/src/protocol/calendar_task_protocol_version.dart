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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

@_isc.immutable
abstract class CalendarTaskProtocolVersion
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskProtocolVersion._({
    this.sequence,
    required this.stamp,
    this.created,
    this.lastModified,
  });

  const factory CalendarTaskProtocolVersion({
    int? sequence,
    required DateTime stamp,
    DateTime? created,
    DateTime? lastModified,
  }) = _CalendarTaskProtocolVersionImpl;

  factory CalendarTaskProtocolVersion.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskProtocolVersion(
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      created: jsonSerialization['created'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
      lastModified: jsonSerialization['lastModified'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastModified'],
            ),
    );
  }

  final int? sequence;

  final DateTime stamp;

  final DateTime? created;

  final DateTime? lastModified;

  /// Returns a shallow copy of this [CalendarTaskProtocolVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskProtocolVersion copyWith({
    int? sequence,
    DateTime? stamp,
    DateTime? created,
    DateTime? lastModified,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskProtocolVersion &&
            (identical(
                  other.sequence,
                  sequence,
                ) ||
                other.sequence == sequence) &&
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
                other.lastModified == lastModified);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      sequence,
      stamp,
      created,
      lastModified,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskProtocolVersion',
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      if (created != null) 'created': created?.toJson(),
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskProtocolVersion',
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      if (created != null) 'created': created?.toJson(),
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskProtocolVersionImpl extends CalendarTaskProtocolVersion {
  const _CalendarTaskProtocolVersionImpl({
    int? sequence,
    required DateTime stamp,
    DateTime? created,
    DateTime? lastModified,
  }) : super._(
         sequence: sequence,
         stamp: stamp,
         created: created,
         lastModified: lastModified,
       );

  /// Returns a shallow copy of this [CalendarTaskProtocolVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskProtocolVersion copyWith({
    Object? sequence = _Undefined,
    DateTime? stamp,
    Object? created = _Undefined,
    Object? lastModified = _Undefined,
  }) {
    return CalendarTaskProtocolVersion(
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      created: created is DateTime? ? created : this.created,
      lastModified: lastModified is DateTime?
          ? lastModified
          : this.lastModified,
    );
  }
}
