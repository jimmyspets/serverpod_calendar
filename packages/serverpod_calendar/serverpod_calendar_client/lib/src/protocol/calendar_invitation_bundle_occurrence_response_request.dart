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
import 'package:serverpod_calendar_client/src/protocol/protocol.dart'
    as _ie4a1wrz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_invitation_response_request.dart' as _iw3qnr12;

@_isc.immutable
abstract class CalendarInvitationBundleOccurrenceResponseRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationBundleOccurrenceResponseRequest._({
    required this.request,
    required this.originalStart,
  });

  const factory CalendarInvitationBundleOccurrenceResponseRequest({
    required _iw3qnr12.CalendarInvitationResponseRequest request,
    required _ieswiaty.CalendarEventTiming originalStart,
  }) = _CalendarInvitationBundleOccurrenceResponseRequestImpl;

  factory CalendarInvitationBundleOccurrenceResponseRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationBundleOccurrenceResponseRequest(
      request: _ie4a1wrz.Protocol()
          .deserialize<_iw3qnr12.CalendarInvitationResponseRequest>(
            jsonSerialization['request'],
          ),
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
    );
  }

  final _iw3qnr12.CalendarInvitationResponseRequest request;

  final _ieswiaty.CalendarEventTiming originalStart;

  /// Returns a shallow copy of this [CalendarInvitationBundleOccurrenceResponseRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationBundleOccurrenceResponseRequest copyWith({
    _iw3qnr12.CalendarInvitationResponseRequest? request,
    _ieswiaty.CalendarEventTiming? originalStart,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationBundleOccurrenceResponseRequest &&
            (identical(
                  other.request,
                  request,
                ) ||
                other.request == request) &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      request,
      originalStart,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationBundleOccurrenceResponseRequest',
      'request': request.toJson(),
      'originalStart': originalStart.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationBundleOccurrenceResponseRequest',
      'request': request.toJsonForProtocol(),
      'originalStart': originalStart.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarInvitationBundleOccurrenceResponseRequestImpl
    extends CalendarInvitationBundleOccurrenceResponseRequest {
  const _CalendarInvitationBundleOccurrenceResponseRequestImpl({
    required _iw3qnr12.CalendarInvitationResponseRequest request,
    required _ieswiaty.CalendarEventTiming originalStart,
  }) : super._(
         request: request,
         originalStart: originalStart,
       );

  /// Returns a shallow copy of this [CalendarInvitationBundleOccurrenceResponseRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationBundleOccurrenceResponseRequest copyWith({
    _iw3qnr12.CalendarInvitationResponseRequest? request,
    _ieswiaty.CalendarEventTiming? originalStart,
  }) {
    return CalendarInvitationBundleOccurrenceResponseRequest(
      request: request ?? this.request.copyWith(),
      originalStart: originalStart ?? this.originalStart.copyWith(),
    );
  }
}
