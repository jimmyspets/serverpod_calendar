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
import 'calendar_no_rule_fallback.dart' as _itts4qyp;

abstract class CalendarSettingsUpdateRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarSettingsUpdateRequest._({
    required this.calendarId,
    required this.expectedRevision,
    required this.availabilityZoneId,
    required this.noRuleFallback,
  });

  factory CalendarSettingsUpdateRequest({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required String availabilityZoneId,
    required _itts4qyp.CalendarNoRuleFallback noRuleFallback,
  }) = _CalendarSettingsUpdateRequestImpl;

  factory CalendarSettingsUpdateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSettingsUpdateRequest(
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      availabilityZoneId: jsonSerialization['availabilityZoneId'] as String,
      noRuleFallback: _itts4qyp.CalendarNoRuleFallback.fromJson(
        (jsonSerialization['noRuleFallback'] as String),
      ),
    );
  }

  _is.UuidValue calendarId;

  int expectedRevision;

  String availabilityZoneId;

  _itts4qyp.CalendarNoRuleFallback noRuleFallback;

  /// Returns a shallow copy of this [CalendarSettingsUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSettingsUpdateRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    String? availabilityZoneId,
    _itts4qyp.CalendarNoRuleFallback? noRuleFallback,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSettingsUpdateRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'availabilityZoneId': availabilityZoneId,
      'noRuleFallback': noRuleFallback.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSettingsUpdateRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'availabilityZoneId': availabilityZoneId,
      'noRuleFallback': noRuleFallback.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarSettingsUpdateRequestImpl extends CalendarSettingsUpdateRequest {
  _CalendarSettingsUpdateRequestImpl({
    required _is.UuidValue calendarId,
    required int expectedRevision,
    required String availabilityZoneId,
    required _itts4qyp.CalendarNoRuleFallback noRuleFallback,
  }) : super._(
         calendarId: calendarId,
         expectedRevision: expectedRevision,
         availabilityZoneId: availabilityZoneId,
         noRuleFallback: noRuleFallback,
       );

  /// Returns a shallow copy of this [CalendarSettingsUpdateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSettingsUpdateRequest copyWith({
    _is.UuidValue? calendarId,
    int? expectedRevision,
    String? availabilityZoneId,
    _itts4qyp.CalendarNoRuleFallback? noRuleFallback,
  }) {
    return CalendarSettingsUpdateRequest(
      calendarId: calendarId ?? this.calendarId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      availabilityZoneId: availabilityZoneId ?? this.availabilityZoneId,
      noRuleFallback: noRuleFallback ?? this.noRuleFallback,
    );
  }
}
