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
import 'calendar_event_status.dart' as _ivzxk9bc;

@_isc.immutable
abstract class CalendarEventStatusRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventStatusRequest._({
    required this.eventId,
    required this.expectedRevision,
    required this.status,
  });

  const factory CalendarEventStatusRequest({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    required _ivzxk9bc.CalendarEventStatus status,
  }) = _CalendarEventStatusRequestImpl;

  factory CalendarEventStatusRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventStatusRequest(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      status: _ivzxk9bc.CalendarEventStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
    );
  }

  final _isc.UuidValue eventId;

  final int expectedRevision;

  final _ivzxk9bc.CalendarEventStatus status;

  /// Returns a shallow copy of this [CalendarEventStatusRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventStatusRequest copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _ivzxk9bc.CalendarEventStatus? status,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventStatusRequest &&
            (identical(
                  other.eventId,
                  eventId,
                ) ||
                other.eventId == eventId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
            (identical(
                  other.status,
                  status,
                ) ||
                other.status == status);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      expectedRevision,
      status,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventStatusRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'status': status.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventStatusRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'status': status.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarEventStatusRequestImpl extends CalendarEventStatusRequest {
  const _CalendarEventStatusRequestImpl({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    required _ivzxk9bc.CalendarEventStatus status,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         status: status,
       );

  /// Returns a shallow copy of this [CalendarEventStatusRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventStatusRequest copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _ivzxk9bc.CalendarEventStatus? status,
  }) {
    return CalendarEventStatusRequest(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      status: status ?? this.status,
    );
  }
}
