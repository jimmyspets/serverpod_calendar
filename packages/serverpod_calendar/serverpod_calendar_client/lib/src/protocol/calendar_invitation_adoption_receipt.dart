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
abstract class CalendarInvitationAdoptionReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationAdoptionReceipt._({
    required this.id,
    required this.invitationId,
    required this.sourceId,
    required this.calendarId,
    required this.eventId,
    required this.eventRevision,
    required this.invitationRevision,
    required this.adoptedAt,
  });

  const factory CalendarInvitationAdoptionReceipt({
    required _isc.UuidValue id,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int eventRevision,
    required int invitationRevision,
    required DateTime adoptedAt,
  }) = _CalendarInvitationAdoptionReceiptImpl;

  factory CalendarInvitationAdoptionReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationAdoptionReceipt(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      invitationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      sourceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      eventRevision: jsonSerialization['eventRevision'] as int,
      invitationRevision: jsonSerialization['invitationRevision'] as int,
      adoptedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['adoptedAt'],
      ),
    );
  }

  final _isc.UuidValue id;

  final _isc.UuidValue invitationId;

  final _isc.UuidValue sourceId;

  final _isc.UuidValue calendarId;

  final _isc.UuidValue eventId;

  final int eventRevision;

  final int invitationRevision;

  final DateTime adoptedAt;

  /// Returns a shallow copy of this [CalendarInvitationAdoptionReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationAdoptionReceipt copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? eventRevision,
    int? invitationRevision,
    DateTime? adoptedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationAdoptionReceipt &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
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
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.eventId,
                  eventId,
                ) ||
                other.eventId == eventId) &&
            (identical(
                  other.eventRevision,
                  eventRevision,
                ) ||
                other.eventRevision == eventRevision) &&
            (identical(
                  other.invitationRevision,
                  invitationRevision,
                ) ||
                other.invitationRevision == invitationRevision) &&
            (identical(
                  other.adoptedAt,
                  adoptedAt,
                ) ||
                other.adoptedAt == adoptedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      invitationId,
      sourceId,
      calendarId,
      eventId,
      eventRevision,
      invitationRevision,
      adoptedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationAdoptionReceipt',
      'id': id.toJson(),
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'eventRevision': eventRevision,
      'invitationRevision': invitationRevision,
      'adoptedAt': adoptedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationAdoptionReceipt',
      'id': id.toJson(),
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'eventRevision': eventRevision,
      'invitationRevision': invitationRevision,
      'adoptedAt': adoptedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarInvitationAdoptionReceiptImpl
    extends CalendarInvitationAdoptionReceipt {
  const _CalendarInvitationAdoptionReceiptImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int eventRevision,
    required int invitationRevision,
    required DateTime adoptedAt,
  }) : super._(
         id: id,
         invitationId: invitationId,
         sourceId: sourceId,
         calendarId: calendarId,
         eventId: eventId,
         eventRevision: eventRevision,
         invitationRevision: invitationRevision,
         adoptedAt: adoptedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationAdoptionReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationAdoptionReceipt copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? eventRevision,
    int? invitationRevision,
    DateTime? adoptedAt,
  }) {
    return CalendarInvitationAdoptionReceipt(
      id: id ?? this.id,
      invitationId: invitationId ?? this.invitationId,
      sourceId: sourceId ?? this.sourceId,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      eventRevision: eventRevision ?? this.eventRevision,
      invitationRevision: invitationRevision ?? this.invitationRevision,
      adoptedAt: adoptedAt ?? this.adoptedAt,
    );
  }
}
