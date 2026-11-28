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
abstract class CalendarInvitationAdoptionReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
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
    required _is.UuidValue id,
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    required int eventRevision,
    required int invitationRevision,
    required DateTime adoptedAt,
  }) = _CalendarInvitationAdoptionReceiptImpl;

  factory CalendarInvitationAdoptionReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationAdoptionReceipt(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      invitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      eventRevision: jsonSerialization['eventRevision'] as int,
      invitationRevision: jsonSerialization['invitationRevision'] as int,
      adoptedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['adoptedAt'],
      ),
    );
  }

  final _is.UuidValue id;

  final _is.UuidValue invitationId;

  final _is.UuidValue sourceId;

  final _is.UuidValue calendarId;

  final _is.UuidValue eventId;

  final int eventRevision;

  final int invitationRevision;

  final DateTime adoptedAt;

  /// Returns a shallow copy of this [CalendarInvitationAdoptionReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationAdoptionReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
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
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationAdoptionReceiptImpl
    extends CalendarInvitationAdoptionReceipt {
  const _CalendarInvitationAdoptionReceiptImpl({
    required _is.UuidValue id,
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
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
  @_is.useResult
  @override
  CalendarInvitationAdoptionReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
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
