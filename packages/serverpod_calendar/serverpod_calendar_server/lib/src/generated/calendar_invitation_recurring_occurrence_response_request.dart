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
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;

import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_invitation_response_request.dart' as _iw3qnr12;

@_is.immutable
abstract class CalendarInvitationRecurringOccurrenceResponseRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarInvitationRecurringOccurrenceResponseRequest._({
    required this.request,
    required this.openedInvitationId,
    required this.originalStart,
    required this.selectionHeadId,
    required this.expectedSelectionRevision,
    required this.selectionEvidenceId,
    required this.selectionDigest,
  });

  const factory CalendarInvitationRecurringOccurrenceResponseRequest({
    required _iw3qnr12.CalendarInvitationResponseRequest request,
    required _is.UuidValue openedInvitationId,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _is.UuidValue selectionHeadId,
    required int expectedSelectionRevision,
    required _is.UuidValue selectionEvidenceId,
    required String selectionDigest,
  }) = _CalendarInvitationRecurringOccurrenceResponseRequestImpl;

  factory CalendarInvitationRecurringOccurrenceResponseRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationRecurringOccurrenceResponseRequest(
      request: _ix00hwbf.Protocol()
          .deserialize<_iw3qnr12.CalendarInvitationResponseRequest>(
            jsonSerialization['request'],
          ),
      openedInvitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['openedInvitationId'],
      ),
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      selectionHeadId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['selectionHeadId'],
      ),
      expectedSelectionRevision:
          jsonSerialization['expectedSelectionRevision'] as int,
      selectionEvidenceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['selectionEvidenceId'],
      ),
      selectionDigest: jsonSerialization['selectionDigest'] as String,
    );
  }

  final _iw3qnr12.CalendarInvitationResponseRequest request;

  final _is.UuidValue openedInvitationId;

  final _ieswiaty.CalendarEventTiming originalStart;

  final _is.UuidValue selectionHeadId;

  final int expectedSelectionRevision;

  final _is.UuidValue selectionEvidenceId;

  final String selectionDigest;

  /// Returns a shallow copy of this [CalendarInvitationRecurringOccurrenceResponseRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationRecurringOccurrenceResponseRequest copyWith({
    _iw3qnr12.CalendarInvitationResponseRequest? request,
    _is.UuidValue? openedInvitationId,
    _ieswiaty.CalendarEventTiming? originalStart,
    _is.UuidValue? selectionHeadId,
    int? expectedSelectionRevision,
    _is.UuidValue? selectionEvidenceId,
    String? selectionDigest,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationRecurringOccurrenceResponseRequest &&
            (identical(
                  other.request,
                  request,
                ) ||
                other.request == request) &&
            (identical(
                  other.openedInvitationId,
                  openedInvitationId,
                ) ||
                other.openedInvitationId == openedInvitationId) &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.selectionHeadId,
                  selectionHeadId,
                ) ||
                other.selectionHeadId == selectionHeadId) &&
            (identical(
                  other.expectedSelectionRevision,
                  expectedSelectionRevision,
                ) ||
                other.expectedSelectionRevision == expectedSelectionRevision) &&
            (identical(
                  other.selectionEvidenceId,
                  selectionEvidenceId,
                ) ||
                other.selectionEvidenceId == selectionEvidenceId) &&
            (identical(
                  other.selectionDigest,
                  selectionDigest,
                ) ||
                other.selectionDigest == selectionDigest);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      request,
      openedInvitationId,
      originalStart,
      selectionHeadId,
      expectedSelectionRevision,
      selectionEvidenceId,
      selectionDigest,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationRecurringOccurrenceResponseRequest',
      'request': request.toJson(),
      'openedInvitationId': openedInvitationId.toJson(),
      'originalStart': originalStart.toJson(),
      'selectionHeadId': selectionHeadId.toJson(),
      'expectedSelectionRevision': expectedSelectionRevision,
      'selectionEvidenceId': selectionEvidenceId.toJson(),
      'selectionDigest': selectionDigest,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationRecurringOccurrenceResponseRequest',
      'request': request.toJsonForProtocol(),
      'openedInvitationId': openedInvitationId.toJson(),
      'originalStart': originalStart.toJsonForProtocol(),
      'selectionHeadId': selectionHeadId.toJson(),
      'expectedSelectionRevision': expectedSelectionRevision,
      'selectionEvidenceId': selectionEvidenceId.toJson(),
      'selectionDigest': selectionDigest,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationRecurringOccurrenceResponseRequestImpl
    extends CalendarInvitationRecurringOccurrenceResponseRequest {
  const _CalendarInvitationRecurringOccurrenceResponseRequestImpl({
    required _iw3qnr12.CalendarInvitationResponseRequest request,
    required _is.UuidValue openedInvitationId,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _is.UuidValue selectionHeadId,
    required int expectedSelectionRevision,
    required _is.UuidValue selectionEvidenceId,
    required String selectionDigest,
  }) : super._(
         request: request,
         openedInvitationId: openedInvitationId,
         originalStart: originalStart,
         selectionHeadId: selectionHeadId,
         expectedSelectionRevision: expectedSelectionRevision,
         selectionEvidenceId: selectionEvidenceId,
         selectionDigest: selectionDigest,
       );

  /// Returns a shallow copy of this [CalendarInvitationRecurringOccurrenceResponseRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationRecurringOccurrenceResponseRequest copyWith({
    _iw3qnr12.CalendarInvitationResponseRequest? request,
    _is.UuidValue? openedInvitationId,
    _ieswiaty.CalendarEventTiming? originalStart,
    _is.UuidValue? selectionHeadId,
    int? expectedSelectionRevision,
    _is.UuidValue? selectionEvidenceId,
    String? selectionDigest,
  }) {
    return CalendarInvitationRecurringOccurrenceResponseRequest(
      request: request ?? this.request.copyWith(),
      openedInvitationId: openedInvitationId ?? this.openedInvitationId,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      selectionHeadId: selectionHeadId ?? this.selectionHeadId,
      expectedSelectionRevision:
          expectedSelectionRevision ?? this.expectedSelectionRevision,
      selectionEvidenceId: selectionEvidenceId ?? this.selectionEvidenceId,
      selectionDigest: selectionDigest ?? this.selectionDigest,
    );
  }
}
