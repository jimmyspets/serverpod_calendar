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

@_is.immutable
abstract class CalendarEventProtocolVersion
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventProtocolVersion._({
    this.sequence,
    required this.stamp,
    this.created,
    this.lastModified,
  });

  const factory CalendarEventProtocolVersion({
    int? sequence,
    required DateTime stamp,
    DateTime? created,
    DateTime? lastModified,
  }) = _CalendarEventProtocolVersionImpl;

  factory CalendarEventProtocolVersion.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventProtocolVersion(
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      created: jsonSerialization['created'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
      lastModified: jsonSerialization['lastModified'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastModified'],
            ),
    );
  }

  final int? sequence;

  final DateTime stamp;

  final DateTime? created;

  final DateTime? lastModified;

  /// Returns a shallow copy of this [CalendarEventProtocolVersion]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventProtocolVersion copyWith({
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
            other is CalendarEventProtocolVersion &&
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
      '__className__': 'serverpod_calendar.CalendarEventProtocolVersion',
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      if (created != null) 'created': created?.toJson(),
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventProtocolVersion',
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      if (created != null) 'created': created?.toJson(),
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventProtocolVersionImpl extends CalendarEventProtocolVersion {
  const _CalendarEventProtocolVersionImpl({
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

  /// Returns a shallow copy of this [CalendarEventProtocolVersion]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventProtocolVersion copyWith({
    Object? sequence = _Undefined,
    DateTime? stamp,
    Object? created = _Undefined,
    Object? lastModified = _Undefined,
  }) {
    return CalendarEventProtocolVersion(
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      created: created is DateTime? ? created : this.created,
      lastModified: lastModified is DateTime?
          ? lastModified
          : this.lastModified,
    );
  }
}
