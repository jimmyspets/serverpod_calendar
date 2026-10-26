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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_event_content.dart' as _id4cvk34;

@_isc.immutable
abstract class CalendarSchedulingSaveRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarSchedulingSaveRequest._({
    required this.eventId,
    required this.expectedRevision,
    required this.content,
    required this.recipients,
    required this.commandId,
  });

  const factory CalendarSchedulingSaveRequest({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    required _id4cvk34.CalendarEventContent content,
    required List<String> recipients,
    required _isc.UuidValue commandId,
  }) = _CalendarSchedulingSaveRequestImpl;

  factory CalendarSchedulingSaveRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingSaveRequest(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      content: _ie4a1wrz.Protocol().deserialize<_id4cvk34.CalendarEventContent>(
        jsonSerialization['content'],
      ),
      recipients: _ie4a1wrz.Protocol().deserialize<List<String>>(
        jsonSerialization['recipients'],
      ),
      commandId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
    );
  }

  final _isc.UuidValue eventId;

  final int expectedRevision;

  final _id4cvk34.CalendarEventContent content;

  final List<String> recipients;

  final _isc.UuidValue commandId;

  /// Returns a shallow copy of this [CalendarSchedulingSaveRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarSchedulingSaveRequest copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _id4cvk34.CalendarEventContent? content,
    List<String>? recipients,
    _isc.UuidValue? commandId,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingSaveRequest &&
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
                  other.content,
                  content,
                ) ||
                other.content == content) &&
            const _iss.DeepCollectionEquality().equals(
              other.recipients,
              recipients,
            ) &&
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
      content,
      const _iss.DeepCollectionEquality().hash(recipients),
      commandId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingSaveRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'content': content.toJson(),
      'recipients': recipients.toJson(),
      'commandId': commandId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingSaveRequest',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      'content': content.toJsonForProtocol(),
      'recipients': recipients.toJson(),
      'commandId': commandId.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarSchedulingSaveRequestImpl extends CalendarSchedulingSaveRequest {
  const _CalendarSchedulingSaveRequestImpl({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    required _id4cvk34.CalendarEventContent content,
    required List<String> recipients,
    required _isc.UuidValue commandId,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         content: content,
         recipients: recipients,
         commandId: commandId,
       );

  /// Returns a shallow copy of this [CalendarSchedulingSaveRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarSchedulingSaveRequest copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _id4cvk34.CalendarEventContent? content,
    List<String>? recipients,
    _isc.UuidValue? commandId,
  }) {
    return CalendarSchedulingSaveRequest(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      content: content ?? this.content.copyWith(),
      recipients: recipients ?? this.recipients.map((e0) => e0).toList(),
      commandId: commandId ?? this.commandId,
    );
  }
}
