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
import 'calendar_item_text_metadata_patch.dart' as _ikwi9ryb;

@_isc.immutable
abstract class CalendarEventTextMetadataRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventTextMetadataRequest._({
    required this.eventId,
    required this.expectedRevision,
    required this.patch,
  });

  const factory CalendarEventTextMetadataRequest({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    required _ikwi9ryb.CalendarItemTextMetadataPatch patch,
  }) = _CalendarEventTextMetadataRequestImpl;

  factory CalendarEventTextMetadataRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventTextMetadataRequest(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      patch: _ie4a1wrz.Protocol()
          .deserialize<_ikwi9ryb.CalendarItemTextMetadataPatch>(
            jsonSerialization['patch'],
          ),
    );
  }

  final _isc.UuidValue eventId;

  final int expectedRevision;

  final _ikwi9ryb.CalendarItemTextMetadataPatch patch;

  /// Returns a shallow copy of this [CalendarEventTextMetadataRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventTextMetadataRequest copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _ikwi9ryb.CalendarItemTextMetadataPatch? patch,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventTextMetadataRequest &&
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
                  other.patch,
                  patch,
                ) ||
                other.patch == patch);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      expectedRevision,
      patch,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventTextMetadataRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'patch': patch.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventTextMetadataRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'patch': patch.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarEventTextMetadataRequestImpl
    extends CalendarEventTextMetadataRequest {
  const _CalendarEventTextMetadataRequestImpl({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    required _ikwi9ryb.CalendarItemTextMetadataPatch patch,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         patch: patch,
       );

  /// Returns a shallow copy of this [CalendarEventTextMetadataRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventTextMetadataRequest copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _ikwi9ryb.CalendarItemTextMetadataPatch? patch,
  }) {
    return CalendarEventTextMetadataRequest(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      patch: patch ?? this.patch.copyWith(),
    );
  }
}
