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
abstract class CalendarEventSourceRelationship
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventSourceRelationship._({
    required this.targetUid,
    this.relationType,
  });

  const factory CalendarEventSourceRelationship({
    required String targetUid,
    String? relationType,
  }) = _CalendarEventSourceRelationshipImpl;

  factory CalendarEventSourceRelationship.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventSourceRelationship(
      targetUid: jsonSerialization['targetUid'] as String,
      relationType: jsonSerialization['relationType'] as String?,
    );
  }

  final String targetUid;

  final String? relationType;

  /// Returns a shallow copy of this [CalendarEventSourceRelationship]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventSourceRelationship copyWith({
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
            other is CalendarEventSourceRelationship &&
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
      '__className__': 'serverpod_calendar.CalendarEventSourceRelationship',
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

class _CalendarEventSourceRelationshipImpl
    extends CalendarEventSourceRelationship {
  const _CalendarEventSourceRelationshipImpl({
    required String targetUid,
    String? relationType,
  }) : super._(
         targetUid: targetUid,
         relationType: relationType,
       );

  /// Returns a shallow copy of this [CalendarEventSourceRelationship]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventSourceRelationship copyWith({
    String? targetUid,
    Object? relationType = _Undefined,
  }) {
    return CalendarEventSourceRelationship(
      targetUid: targetUid ?? this.targetUid,
      relationType: relationType is String? ? relationType : this.relationType,
    );
  }
}
