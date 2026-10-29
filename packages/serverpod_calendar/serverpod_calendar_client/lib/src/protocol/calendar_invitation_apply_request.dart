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
abstract class CalendarInvitationApplyRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationApplyRequest._({
    required this.invitationId,
    required this.sourceId,
    required this.expectedInvitationRevision,
    required this.linkId,
    required this.expectedEventRevision,
    required this.expectedCalendarRevision,
    required this.expectedApplicationRevision,
  });

  const factory CalendarInvitationApplyRequest({
    required _isc.UuidValue invitationId,
    required _isc.UuidValue sourceId,
    required int expectedInvitationRevision,
    required _isc.UuidValue linkId,
    required int expectedEventRevision,
    required int expectedCalendarRevision,
    required int expectedApplicationRevision,
  }) = _CalendarInvitationApplyRequestImpl;

  factory CalendarInvitationApplyRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationApplyRequest(
      invitationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      sourceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      expectedInvitationRevision:
          jsonSerialization['expectedInvitationRevision'] as int,
      linkId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['linkId']),
      expectedEventRevision: jsonSerialization['expectedEventRevision'] as int,
      expectedCalendarRevision:
          jsonSerialization['expectedCalendarRevision'] as int,
      expectedApplicationRevision:
          jsonSerialization['expectedApplicationRevision'] as int,
    );
  }

  final _isc.UuidValue invitationId;

  final _isc.UuidValue sourceId;

  final int expectedInvitationRevision;

  final _isc.UuidValue linkId;

  final int expectedEventRevision;

  final int expectedCalendarRevision;

  final int expectedApplicationRevision;

  /// Returns a shallow copy of this [CalendarInvitationApplyRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationApplyRequest copyWith({
    _isc.UuidValue? invitationId,
    _isc.UuidValue? sourceId,
    int? expectedInvitationRevision,
    _isc.UuidValue? linkId,
    int? expectedEventRevision,
    int? expectedCalendarRevision,
    int? expectedApplicationRevision,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationApplyRequest &&
            (identical(
                  other.invitationId,
                  invitationId,
                ) ||
                other.invitationId == invitationId) &&
            (identical(
                  other.sourceId,
                  sourceId,
                ) ||
                other.sourceId == sourceId) &&
            (identical(
                  other.expectedInvitationRevision,
                  expectedInvitationRevision,
                ) ||
                other.expectedInvitationRevision ==
                    expectedInvitationRevision) &&
            (identical(
                  other.linkId,
                  linkId,
                ) ||
                other.linkId == linkId) &&
            (identical(
                  other.expectedEventRevision,
                  expectedEventRevision,
                ) ||
                other.expectedEventRevision == expectedEventRevision) &&
            (identical(
                  other.expectedCalendarRevision,
                  expectedCalendarRevision,
                ) ||
                other.expectedCalendarRevision == expectedCalendarRevision) &&
            (identical(
                  other.expectedApplicationRevision,
                  expectedApplicationRevision,
                ) ||
                other.expectedApplicationRevision ==
                    expectedApplicationRevision);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      invitationId,
      sourceId,
      expectedInvitationRevision,
      linkId,
      expectedEventRevision,
      expectedCalendarRevision,
      expectedApplicationRevision,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationApplyRequest',
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'expectedInvitationRevision': expectedInvitationRevision,
      'linkId': linkId.toJson(),
      'expectedEventRevision': expectedEventRevision,
      'expectedCalendarRevision': expectedCalendarRevision,
      'expectedApplicationRevision': expectedApplicationRevision,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationApplyRequest',
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'expectedInvitationRevision': expectedInvitationRevision,
      'linkId': linkId.toJson(),
      'expectedEventRevision': expectedEventRevision,
      'expectedCalendarRevision': expectedCalendarRevision,
      'expectedApplicationRevision': expectedApplicationRevision,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarInvitationApplyRequestImpl
    extends CalendarInvitationApplyRequest {
  const _CalendarInvitationApplyRequestImpl({
    required _isc.UuidValue invitationId,
    required _isc.UuidValue sourceId,
    required int expectedInvitationRevision,
    required _isc.UuidValue linkId,
    required int expectedEventRevision,
    required int expectedCalendarRevision,
    required int expectedApplicationRevision,
  }) : super._(
         invitationId: invitationId,
         sourceId: sourceId,
         expectedInvitationRevision: expectedInvitationRevision,
         linkId: linkId,
         expectedEventRevision: expectedEventRevision,
         expectedCalendarRevision: expectedCalendarRevision,
         expectedApplicationRevision: expectedApplicationRevision,
       );

  /// Returns a shallow copy of this [CalendarInvitationApplyRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationApplyRequest copyWith({
    _isc.UuidValue? invitationId,
    _isc.UuidValue? sourceId,
    int? expectedInvitationRevision,
    _isc.UuidValue? linkId,
    int? expectedEventRevision,
    int? expectedCalendarRevision,
    int? expectedApplicationRevision,
  }) {
    return CalendarInvitationApplyRequest(
      invitationId: invitationId ?? this.invitationId,
      sourceId: sourceId ?? this.sourceId,
      expectedInvitationRevision:
          expectedInvitationRevision ?? this.expectedInvitationRevision,
      linkId: linkId ?? this.linkId,
      expectedEventRevision:
          expectedEventRevision ?? this.expectedEventRevision,
      expectedCalendarRevision:
          expectedCalendarRevision ?? this.expectedCalendarRevision,
      expectedApplicationRevision:
          expectedApplicationRevision ?? this.expectedApplicationRevision,
    );
  }
}
