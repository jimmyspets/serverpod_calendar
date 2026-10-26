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
abstract class CalendarSchedulingCancelRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarSchedulingCancelRequest._({
    required this.eventId,
    required this.expectedRevision,
    required this.commandId,
  });

  const factory CalendarSchedulingCancelRequest({
    required _is.UuidValue eventId,
    required int expectedRevision,
    required _is.UuidValue commandId,
  }) = _CalendarSchedulingCancelRequestImpl;

  factory CalendarSchedulingCancelRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingCancelRequest(
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
    );
  }

  final _is.UuidValue eventId;

  final int expectedRevision;

  final _is.UuidValue commandId;

  /// Returns a shallow copy of this [CalendarSchedulingCancelRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingCancelRequest copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
    _is.UuidValue? commandId,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingCancelRequest &&
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
                  other.commandId,
                  commandId,
                ) ||
                other.commandId == commandId);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      expectedRevision,
      commandId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingCancelRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'commandId': commandId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingCancelRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'commandId': commandId.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarSchedulingCancelRequestImpl
    extends CalendarSchedulingCancelRequest {
  const _CalendarSchedulingCancelRequestImpl({
    required _is.UuidValue eventId,
    required int expectedRevision,
    required _is.UuidValue commandId,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         commandId: commandId,
       );

  /// Returns a shallow copy of this [CalendarSchedulingCancelRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingCancelRequest copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
    _is.UuidValue? commandId,
  }) {
    return CalendarSchedulingCancelRequest(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      commandId: commandId ?? this.commandId,
    );
  }
}
