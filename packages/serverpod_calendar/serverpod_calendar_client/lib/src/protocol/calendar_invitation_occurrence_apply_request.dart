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
abstract class CalendarInvitationOccurrenceApplyRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationOccurrenceApplyRequest._({
    required this.invitationId,
    required this.sourceId,
    required this.linkId,
    required this.expectedInvitationRevision,
    required this.expectedEventRevision,
    required this.expectedCalendarRevision,
    required this.expectedApplicationRevision,
    required this.expectedOccurrenceRevision,
  });

  const factory CalendarInvitationOccurrenceApplyRequest({
    required _isc.UuidValue invitationId,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue linkId,
    required int expectedInvitationRevision,
    required int expectedEventRevision,
    required int expectedCalendarRevision,
    required int expectedApplicationRevision,
    required int expectedOccurrenceRevision,
  }) = _CalendarInvitationOccurrenceApplyRequestImpl;

  factory CalendarInvitationOccurrenceApplyRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationOccurrenceApplyRequest(
      invitationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      sourceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      linkId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['linkId']),
      expectedInvitationRevision:
          jsonSerialization['expectedInvitationRevision'] as int,
      expectedEventRevision: jsonSerialization['expectedEventRevision'] as int,
      expectedCalendarRevision:
          jsonSerialization['expectedCalendarRevision'] as int,
      expectedApplicationRevision:
          jsonSerialization['expectedApplicationRevision'] as int,
      expectedOccurrenceRevision:
          jsonSerialization['expectedOccurrenceRevision'] as int,
    );
  }

  final _isc.UuidValue invitationId;

  final _isc.UuidValue sourceId;

  final _isc.UuidValue linkId;

  final int expectedInvitationRevision;

  final int expectedEventRevision;

  final int expectedCalendarRevision;

  final int expectedApplicationRevision;

  final int expectedOccurrenceRevision;

  /// Returns a shallow copy of this [CalendarInvitationOccurrenceApplyRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationOccurrenceApplyRequest copyWith({
    _isc.UuidValue? invitationId,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? linkId,
    int? expectedInvitationRevision,
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
            other is CalendarInvitationOccurrenceApplyRequest &&
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
                  other.linkId,
                  linkId,
                ) ||
                other.linkId == linkId) &&
            (identical(
                  other.expectedInvitationRevision,
                  expectedInvitationRevision,
                ) ||
                other.expectedInvitationRevision ==
                    expectedInvitationRevision) &&
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
      linkId,
      expectedInvitationRevision,
      expectedEventRevision,
      expectedCalendarRevision,
      expectedApplicationRevision,
      expectedOccurrenceRevision,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationOccurrenceApplyRequest',
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'linkId': linkId.toJson(),
      'expectedInvitationRevision': expectedInvitationRevision,
      'expectedEventRevision': expectedEventRevision,
      'expectedCalendarRevision': expectedCalendarRevision,
      'expectedApplicationRevision': expectedApplicationRevision,
      'expectedOccurrenceRevision': expectedOccurrenceRevision,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationOccurrenceApplyRequest',
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'linkId': linkId.toJson(),
      'expectedInvitationRevision': expectedInvitationRevision,
      'expectedEventRevision': expectedEventRevision,
      'expectedCalendarRevision': expectedCalendarRevision,
      'expectedApplicationRevision': expectedApplicationRevision,
      'expectedOccurrenceRevision': expectedOccurrenceRevision,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarInvitationOccurrenceApplyRequestImpl
    extends CalendarInvitationOccurrenceApplyRequest {
  const _CalendarInvitationOccurrenceApplyRequestImpl({
    required _isc.UuidValue invitationId,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue linkId,
    required int expectedInvitationRevision,
    required int expectedEventRevision,
    required int expectedCalendarRevision,
    required int expectedApplicationRevision,
    required int expectedOccurrenceRevision,
  }) : super._(
         invitationId: invitationId,
         sourceId: sourceId,
         linkId: linkId,
         expectedInvitationRevision: expectedInvitationRevision,
         expectedEventRevision: expectedEventRevision,
         expectedCalendarRevision: expectedCalendarRevision,
         expectedApplicationRevision: expectedApplicationRevision,
         expectedOccurrenceRevision: expectedOccurrenceRevision,
       );

  /// Returns a shallow copy of this [CalendarInvitationOccurrenceApplyRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationOccurrenceApplyRequest copyWith({
    _isc.UuidValue? invitationId,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? linkId,
    int? expectedInvitationRevision,
    int? expectedEventRevision,
    int? expectedCalendarRevision,
    int? expectedApplicationRevision,
    int? expectedOccurrenceRevision,
  }) {
    return CalendarInvitationOccurrenceApplyRequest(
      invitationId: invitationId ?? this.invitationId,
      sourceId: sourceId ?? this.sourceId,
      linkId: linkId ?? this.linkId,
      expectedInvitationRevision:
          expectedInvitationRevision ?? this.expectedInvitationRevision,
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
