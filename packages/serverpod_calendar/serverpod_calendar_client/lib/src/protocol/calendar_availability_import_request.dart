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
import 'dart:typed_data' as _idt;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

@_isc.immutable
abstract class CalendarAvailabilityImportRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityImportRequest._({
    required this.calendarId,
    required this.expectedRevision,
    required this.bytes,
  });

  const factory CalendarAvailabilityImportRequest({
    required _isc.UuidValue calendarId,
    required int expectedRevision,
    required _idt.ByteData bytes,
  }) = _CalendarAvailabilityImportRequestImpl;

  factory CalendarAvailabilityImportRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityImportRequest(
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      bytes: _isc.ByteDataJsonExtension.fromJson(jsonSerialization['bytes']),
    );
  }

  final _isc.UuidValue calendarId;

  final int expectedRevision;

  final _idt.ByteData bytes;

  /// Returns a shallow copy of this [CalendarAvailabilityImportRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityImportRequest copyWith({
    _isc.UuidValue? calendarId,
    int? expectedRevision,
    _idt.ByteData? bytes,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityImportRequest &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
            (identical(
                  other.bytes,
                  bytes,
                ) ||
                other.bytes == bytes);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      calendarId,
      expectedRevision,
      bytes,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityImportRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'bytes': bytes.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityImportRequest',
      'calendarId': calendarId.toJson(),
      'expectedRevision': expectedRevision,
      'bytes': bytes.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityImportRequestImpl
    extends CalendarAvailabilityImportRequest {
  const _CalendarAvailabilityImportRequestImpl({
    required _isc.UuidValue calendarId,
    required int expectedRevision,
    required _idt.ByteData bytes,
  }) : super._(
         calendarId: calendarId,
         expectedRevision: expectedRevision,
         bytes: bytes,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityImportRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityImportRequest copyWith({
    _isc.UuidValue? calendarId,
    int? expectedRevision,
    _idt.ByteData? bytes,
  }) {
    return CalendarAvailabilityImportRequest(
      calendarId: calendarId ?? this.calendarId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      bytes: bytes ?? this.bytes.clone(),
    );
  }
}
