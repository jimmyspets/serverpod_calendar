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

abstract class CalendarSubjectView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarSubjectView._({
    required this.namespace,
    required this.kind,
    required this.externalId,
    required this.contributesAvailability,
  });

  factory CalendarSubjectView({
    required String namespace,
    required String kind,
    required String externalId,
    required bool contributesAvailability,
  }) = _CalendarSubjectViewImpl;

  factory CalendarSubjectView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarSubjectView(
      namespace: jsonSerialization['namespace'] as String,
      kind: jsonSerialization['kind'] as String,
      externalId: jsonSerialization['externalId'] as String,
      contributesAvailability: _is.BoolJsonExtension.fromJson(
        jsonSerialization['contributesAvailability'],
      ),
    );
  }

  String namespace;

  String kind;

  String externalId;

  bool contributesAvailability;

  /// Returns a shallow copy of this [CalendarSubjectView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSubjectView copyWith({
    String? namespace,
    String? kind,
    String? externalId,
    bool? contributesAvailability,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSubjectView',
      'namespace': namespace,
      'kind': kind,
      'externalId': externalId,
      'contributesAvailability': contributesAvailability,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSubjectView',
      'namespace': namespace,
      'kind': kind,
      'externalId': externalId,
      'contributesAvailability': contributesAvailability,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarSubjectViewImpl extends CalendarSubjectView {
  _CalendarSubjectViewImpl({
    required String namespace,
    required String kind,
    required String externalId,
    required bool contributesAvailability,
  }) : super._(
         namespace: namespace,
         kind: kind,
         externalId: externalId,
         contributesAvailability: contributesAvailability,
       );

  /// Returns a shallow copy of this [CalendarSubjectView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSubjectView copyWith({
    String? namespace,
    String? kind,
    String? externalId,
    bool? contributesAvailability,
  }) {
    return CalendarSubjectView(
      namespace: namespace ?? this.namespace,
      kind: kind ?? this.kind,
      externalId: externalId ?? this.externalId,
      contributesAvailability:
          contributesAvailability ?? this.contributesAvailability,
    );
  }
}
