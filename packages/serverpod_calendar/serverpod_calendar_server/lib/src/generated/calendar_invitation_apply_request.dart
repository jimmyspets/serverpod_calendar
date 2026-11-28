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
abstract class CalendarInvitationApplyRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarInvitationApplyRequest._({
    required this.invitationId,
    required this.sourceId,
    required this.expectedInvitationRevision,
    required this.linkId,
    required this.expectedEventRevision,
    required this.expectedCalendarRevision,
    required this.expectedApplicationRevision,
    int? expectedOccurrenceRevision,
  }) : expectedOccurrenceRevision = expectedOccurrenceRevision ?? 0;

  const factory CalendarInvitationApplyRequest({
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required int expectedInvitationRevision,
    required _is.UuidValue linkId,
    required int expectedEventRevision,
    required int expectedCalendarRevision,
    required int expectedApplicationRevision,
    int? expectedOccurrenceRevision,
  }) = _CalendarInvitationApplyRequestImpl;

  factory CalendarInvitationApplyRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationApplyRequest(
      invitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      expectedInvitationRevision:
          jsonSerialization['expectedInvitationRevision'] as int,
      linkId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['linkId']),
      expectedEventRevision: jsonSerialization['expectedEventRevision'] as int,
      expectedCalendarRevision:
          jsonSerialization['expectedCalendarRevision'] as int,
      expectedApplicationRevision:
          jsonSerialization['expectedApplicationRevision'] as int,
      expectedOccurrenceRevision:
          jsonSerialization['expectedOccurrenceRevision'] as int?,
    );
  }

  final _is.UuidValue invitationId;

  final _is.UuidValue sourceId;

  final int expectedInvitationRevision;

  final _is.UuidValue linkId;

  final int expectedEventRevision;

  final int expectedCalendarRevision;

  final int expectedApplicationRevision;

  final int expectedOccurrenceRevision;

  /// Returns a shallow copy of this [CalendarInvitationApplyRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationApplyRequest copyWith({
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    int? expectedInvitationRevision,
    _is.UuidValue? linkId,
    int? expectedEventRevision,
    int? expectedCalendarRevision,
    int? expectedApplicationRevision,
    int? expectedOccurrenceRevision,
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
                    expectedApplicationRevision) &&
            (identical(
                  other.expectedOccurrenceRevision,
                  expectedOccurrenceRevision,
                ) ||
                other.expectedOccurrenceRevision == expectedOccurrenceRevision);
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
      expectedOccurrenceRevision,
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
      'expectedOccurrenceRevision': expectedOccurrenceRevision,
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
      'expectedOccurrenceRevision': expectedOccurrenceRevision,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationApplyRequestImpl
    extends CalendarInvitationApplyRequest {
  const _CalendarInvitationApplyRequestImpl({
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required int expectedInvitationRevision,
    required _is.UuidValue linkId,
    required int expectedEventRevision,
    required int expectedCalendarRevision,
    required int expectedApplicationRevision,
    int? expectedOccurrenceRevision,
  }) : super._(
         invitationId: invitationId,
         sourceId: sourceId,
         expectedInvitationRevision: expectedInvitationRevision,
         linkId: linkId,
         expectedEventRevision: expectedEventRevision,
         expectedCalendarRevision: expectedCalendarRevision,
         expectedApplicationRevision: expectedApplicationRevision,
         expectedOccurrenceRevision: expectedOccurrenceRevision,
       );

  /// Returns a shallow copy of this [CalendarInvitationApplyRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationApplyRequest copyWith({
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    int? expectedInvitationRevision,
    _is.UuidValue? linkId,
    int? expectedEventRevision,
    int? expectedCalendarRevision,
    int? expectedApplicationRevision,
    int? expectedOccurrenceRevision,
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
      expectedOccurrenceRevision:
          expectedOccurrenceRevision ?? this.expectedOccurrenceRevision,
    );
  }
}
