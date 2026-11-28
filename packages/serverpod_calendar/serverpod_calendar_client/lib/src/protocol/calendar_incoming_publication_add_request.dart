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
abstract class CalendarIncomingPublicationAddRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarIncomingPublicationAddRequest._({
    required this.entryId,
    required this.sourceId,
    required this.expectedRevision,
    required this.calendarId,
    required this.expectedCalendarRevision,
    required this.commandId,
  });

  const factory CalendarIncomingPublicationAddRequest({
    required _isc.UuidValue entryId,
    required _isc.UuidValue sourceId,
    required int expectedRevision,
    required _isc.UuidValue calendarId,
    required int expectedCalendarRevision,
    required _isc.UuidValue commandId,
  }) = _CalendarIncomingPublicationAddRequestImpl;

  factory CalendarIncomingPublicationAddRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationAddRequest(
      entryId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      sourceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedCalendarRevision:
          jsonSerialization['expectedCalendarRevision'] as int,
      commandId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
    );
  }

  final _isc.UuidValue entryId;

  final _isc.UuidValue sourceId;

  final int expectedRevision;

  final _isc.UuidValue calendarId;

  final int expectedCalendarRevision;

  final _isc.UuidValue commandId;

  /// Returns a shallow copy of this [CalendarIncomingPublicationAddRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarIncomingPublicationAddRequest copyWith({
    _isc.UuidValue? entryId,
    _isc.UuidValue? sourceId,
    int? expectedRevision,
    _isc.UuidValue? calendarId,
    int? expectedCalendarRevision,
    _isc.UuidValue? commandId,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationAddRequest &&
            (identical(
                  other.entryId,
                  entryId,
                ) ||
                other.entryId == entryId) &&
            (identical(
                  other.sourceId,
                  sourceId,
                ) ||
                other.sourceId == sourceId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.expectedCalendarRevision,
                  expectedCalendarRevision,
                ) ||
                other.expectedCalendarRevision == expectedCalendarRevision) &&
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
      entryId,
      sourceId,
      expectedRevision,
      calendarId,
      expectedCalendarRevision,
      commandId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationAddRequest',
      'entryId': entryId.toJson(),
      'sourceId': sourceId.toJson(),
      'expectedRevision': expectedRevision,
      'calendarId': calendarId.toJson(),
      'expectedCalendarRevision': expectedCalendarRevision,
      'commandId': commandId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationAddRequest',
      'entryId': entryId.toJson(),
      'sourceId': sourceId.toJson(),
      'expectedRevision': expectedRevision,
      'calendarId': calendarId.toJson(),
      'expectedCalendarRevision': expectedCalendarRevision,
      'commandId': commandId.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarIncomingPublicationAddRequestImpl
    extends CalendarIncomingPublicationAddRequest {
  const _CalendarIncomingPublicationAddRequestImpl({
    required _isc.UuidValue entryId,
    required _isc.UuidValue sourceId,
    required int expectedRevision,
    required _isc.UuidValue calendarId,
    required int expectedCalendarRevision,
    required _isc.UuidValue commandId,
  }) : super._(
         entryId: entryId,
         sourceId: sourceId,
         expectedRevision: expectedRevision,
         calendarId: calendarId,
         expectedCalendarRevision: expectedCalendarRevision,
         commandId: commandId,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationAddRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarIncomingPublicationAddRequest copyWith({
    _isc.UuidValue? entryId,
    _isc.UuidValue? sourceId,
    int? expectedRevision,
    _isc.UuidValue? calendarId,
    int? expectedCalendarRevision,
    _isc.UuidValue? commandId,
  }) {
    return CalendarIncomingPublicationAddRequest(
      entryId: entryId ?? this.entryId,
      sourceId: sourceId ?? this.sourceId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      calendarId: calendarId ?? this.calendarId,
      expectedCalendarRevision:
          expectedCalendarRevision ?? this.expectedCalendarRevision,
      commandId: commandId ?? this.commandId,
    );
  }
}
