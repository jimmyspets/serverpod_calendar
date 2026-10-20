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

abstract class CalendarCreateRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarCreateRequest._({
    required this.displayName,
    required this.availabilityZoneId,
    required this.noRuleFallback,
  });

  factory CalendarCreateRequest({
    required String displayName,
    required String availabilityZoneId,
    required _itts4qyp.CalendarNoRuleFallback noRuleFallback,
  }) = _CalendarCreateRequestImpl;

  factory CalendarCreateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarCreateRequest(
      displayName: jsonSerialization['displayName'] as String,
      availabilityZoneId: jsonSerialization['availabilityZoneId'] as String,
      noRuleFallback: _itts4qyp.CalendarNoRuleFallback.fromJson(
        (jsonSerialization['noRuleFallback'] as String),
      ),
    );
  }

  String displayName;

  String availabilityZoneId;

  _itts4qyp.CalendarNoRuleFallback noRuleFallback;

  /// Returns a shallow copy of this [CalendarCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarCreateRequest copyWith({
    String? displayName,
    String? availabilityZoneId,
    _itts4qyp.CalendarNoRuleFallback? noRuleFallback,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarCreateRequest',
      'displayName': displayName,
      'availabilityZoneId': availabilityZoneId,
      'noRuleFallback': noRuleFallback.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarCreateRequest',
      'displayName': displayName,
      'availabilityZoneId': availabilityZoneId,
      'noRuleFallback': noRuleFallback.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarCreateRequestImpl extends CalendarCreateRequest {
  _CalendarCreateRequestImpl({
    required String displayName,
    required String availabilityZoneId,
    required _itts4qyp.CalendarNoRuleFallback noRuleFallback,
  }) : super._(
         displayName: displayName,
         availabilityZoneId: availabilityZoneId,
         noRuleFallback: noRuleFallback,
       );

  /// Returns a shallow copy of this [CalendarCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarCreateRequest copyWith({
    String? displayName,
    String? availabilityZoneId,
    _itts4qyp.CalendarNoRuleFallback? noRuleFallback,
  }) {
    return CalendarCreateRequest(
      displayName: displayName ?? this.displayName,
      availabilityZoneId: availabilityZoneId ?? this.availabilityZoneId,
      noRuleFallback: noRuleFallback ?? this.noRuleFallback,
    );
  }
}
