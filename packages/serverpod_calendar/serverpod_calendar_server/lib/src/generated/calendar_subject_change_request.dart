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
import 'calendar_subject_action.dart' as _i41idnki;

abstract class CalendarSubjectChangeRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarSubjectChangeRequest._({
    required this.calendarId,
    required this.expectedRevision,
    required this.action,
    required this.namespace,
    required this.kind,
    required this.externalId,
    required this.contributesAvailability,
  });

  factory CalendarSubjectChangeRequest({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required _i41idnki.CalendarSubjectAction action,
    required String namespace,
    required String kind,
    required String externalId,
    required bool contributesAvailability,
  }) = _CalendarSubjectChangeRequestImpl;

  factory CalendarSubjectChangeRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSubjectChangeRequest(
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      action: _i41idnki.CalendarSubjectAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      namespace: jsonSerialization['namespace'] as String,
      kind: jsonSerialization['kind'] as String,
      externalId: jsonSerialization['externalId'] as String,
      contributesAvailability: _is.BoolJsonExtension.fromJson(
        jsonSerialization['contributesAvailability'],
      ),
    );
  }

  _is.UuidValue calendarId;

  int expectedRevision;

  _i41idnki.CalendarSubjectAction action;

  String namespace;

  String kind;

  String externalId;

  bool contributesAvailability;

  /// Returns a shallow copy of this [CalendarSubjectChangeRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSubjectChangeRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    _i41idnki.CalendarSubjectAction? action,
    String? namespace,
    String? kind,
    String? externalId,
    bool? contributesAvailability,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSubjectChangeRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'action': action.toJson(),
      'namespace': namespace,
      'kind': kind,
      'externalId': externalId,
      'contributesAvailability': contributesAvailability,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSubjectChangeRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'action': action.toJson(),
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

class _CalendarSubjectChangeRequestImpl extends CalendarSubjectChangeRequest {
  _CalendarSubjectChangeRequestImpl({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required _i41idnki.CalendarSubjectAction action,
    required String namespace,
    required String kind,
    required String externalId,
    required bool contributesAvailability,
  }) : super._(
         calendarId: calendarId,
         expectedRevision: expectedRevision,
         action: action,
         namespace: namespace,
         kind: kind,
         externalId: externalId,
         contributesAvailability: contributesAvailability,
       );

  /// Returns a shallow copy of this [CalendarSubjectChangeRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSubjectChangeRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    _i41idnki.CalendarSubjectAction? action,
    String? namespace,
    String? kind,
    String? externalId,
    bool? contributesAvailability,
  }) {
    return CalendarSubjectChangeRequest(
      calendarId: calendarId ?? this.calendarId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      action: action ?? this.action,
      namespace: namespace ?? this.namespace,
      kind: kind ?? this.kind,
      externalId: externalId ?? this.externalId,
      contributesAvailability:
          contributesAvailability ?? this.contributesAvailability,
    );
  }
}
