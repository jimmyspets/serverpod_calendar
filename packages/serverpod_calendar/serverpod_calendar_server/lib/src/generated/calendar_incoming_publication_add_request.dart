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
abstract class CalendarIncomingPublicationAddRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarIncomingPublicationAddRequest._({
    required this.entryId,
    required this.sourceId,
    required this.expectedRevision,
    required this.calendarId,
    required this.expectedCalendarRevision,
    required this.commandId,
  });

  const factory CalendarIncomingPublicationAddRequest({
    required _is.UuidValue entryId,
    required _is.UuidValue sourceId,
    required int expectedRevision,
    required _is.UuidValue calendarId,
    required int expectedCalendarRevision,
    required _is.UuidValue commandId,
  }) = _CalendarIncomingPublicationAddRequestImpl;

  factory CalendarIncomingPublicationAddRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationAddRequest(
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      expectedCalendarRevision:
          jsonSerialization['expectedCalendarRevision'] as int,
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
    );
  }

  final _is.UuidValue entryId;

  final _is.UuidValue sourceId;

  final int expectedRevision;

  final _is.UuidValue calendarId;

  final int expectedCalendarRevision;

  final _is.UuidValue commandId;

  /// Returns a shallow copy of this [CalendarIncomingPublicationAddRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIncomingPublicationAddRequest copyWith({
    _is.UuidValue? entryId,
    _is.UuidValue? sourceId,
    int? expectedRevision,
    _is.UuidValue? calendarId,
    int? expectedCalendarRevision,
    _is.UuidValue? commandId,
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
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarIncomingPublicationAddRequestImpl
    extends CalendarIncomingPublicationAddRequest {
  const _CalendarIncomingPublicationAddRequestImpl({
    required _is.UuidValue entryId,
    required _is.UuidValue sourceId,
    required int expectedRevision,
    required _is.UuidValue calendarId,
    required int expectedCalendarRevision,
    required _is.UuidValue commandId,
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
  @_is.useResult
  @override
  CalendarIncomingPublicationAddRequest copyWith({
    _is.UuidValue? entryId,
    _is.UuidValue? sourceId,
    int? expectedRevision,
    _is.UuidValue? calendarId,
    int? expectedCalendarRevision,
    _is.UuidValue? commandId,
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
