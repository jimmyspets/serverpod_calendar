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
abstract class CalendarTaskSourceRelationship
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskSourceRelationship._({
    required this.targetUid,
    this.relationType,
  });

  const factory CalendarTaskSourceRelationship({
    required String targetUid,
    String? relationType,
  }) = _CalendarTaskSourceRelationshipImpl;

  factory CalendarTaskSourceRelationship.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskSourceRelationship(
      targetUid: jsonSerialization['targetUid'] as String,
      relationType: jsonSerialization['relationType'] as String?,
    );
  }

  final String targetUid;

  final String? relationType;

  /// Returns a shallow copy of this [CalendarTaskSourceRelationship]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskSourceRelationship copyWith({
    String? targetUid,
    String? relationType,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskSourceRelationship &&
            (identical(
                  other.targetUid,
                  targetUid,
                ) ||
                other.targetUid == targetUid) &&
            (identical(
                  other.relationType,
                  relationType,
                ) ||
                other.relationType == relationType);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      targetUid,
      relationType,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskSourceRelationship',
      'targetUid': targetUid,
      if (relationType != null) 'relationType': relationType,
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

class _CalendarTaskSourceRelationshipImpl
    extends CalendarTaskSourceRelationship {
  const _CalendarTaskSourceRelationshipImpl({
    required String targetUid,
    String? relationType,
  }) : super._(
         targetUid: targetUid,
         relationType: relationType,
       );

  /// Returns a shallow copy of this [CalendarTaskSourceRelationship]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskSourceRelationship copyWith({
    String? targetUid,
    Object? relationType = _Undefined,
  }) {
    return CalendarTaskSourceRelationship(
      targetUid: targetUid ?? this.targetUid,
      relationType: relationType is String? ? relationType : this.relationType,
    );
  }
}
