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
abstract class CalendarTaskAssignee
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskAssignee._({
    required this.namespace,
    required this.kind,
    required this.externalId,
  });

  const factory CalendarTaskAssignee({
    required String namespace,
    required String kind,
    required String externalId,
  }) = _CalendarTaskAssigneeImpl;

  factory CalendarTaskAssignee.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskAssignee(
      namespace: jsonSerialization['namespace'] as String,
      kind: jsonSerialization['kind'] as String,
      externalId: jsonSerialization['externalId'] as String,
    );
  }

  final String namespace;

  final String kind;

  final String externalId;

  /// Returns a shallow copy of this [CalendarTaskAssignee]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskAssignee copyWith({
    String? namespace,
    String? kind,
    String? externalId,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskAssignee &&
            (identical(
                  other.namespace,
                  namespace,
                ) ||
                other.namespace == namespace) &&
            (identical(
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
            (identical(
                  other.externalId,
                  externalId,
                ) ||
                other.externalId == externalId);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      namespace,
      kind,
      externalId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskAssignee',
      'namespace': namespace,
      'kind': kind,
      'externalId': externalId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskAssignee',
      'namespace': namespace,
      'kind': kind,
      'externalId': externalId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarTaskAssigneeImpl extends CalendarTaskAssignee {
  const _CalendarTaskAssigneeImpl({
    required String namespace,
    required String kind,
    required String externalId,
  }) : super._(
         namespace: namespace,
         kind: kind,
         externalId: externalId,
       );

  /// Returns a shallow copy of this [CalendarTaskAssignee]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskAssignee copyWith({
    String? namespace,
    String? kind,
    String? externalId,
  }) {
    return CalendarTaskAssignee(
      namespace: namespace ?? this.namespace,
      kind: kind ?? this.kind,
      externalId: externalId ?? this.externalId,
    );
  }
}
