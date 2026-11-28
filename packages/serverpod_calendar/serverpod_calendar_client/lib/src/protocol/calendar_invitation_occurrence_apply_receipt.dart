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
import 'calendar_invitation_source_kind.dart' as _ilccsff7;

@_isc.immutable
abstract class CalendarInvitationOccurrenceApplyReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationOccurrenceApplyReceipt._({
    required this.id,
    required this.kind,
    required this.originalStart,
    required this.linkId,
    required this.invitationId,
    required this.sourceId,
    required this.calendarId,
    required this.eventId,
    required this.occurrenceRevision,
    required this.eventRevision,
    required this.invitationRevision,
    required this.appliedAt,
  });

  const factory CalendarInvitationOccurrenceApplyReceipt({
    required _isc.UuidValue id,
    required _ilccsff7.CalendarInvitationSourceKind kind,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _isc.UuidValue linkId,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int occurrenceRevision,
    required int eventRevision,
    required int invitationRevision,
    required DateTime appliedAt,
  }) = _CalendarInvitationOccurrenceApplyReceiptImpl;

  factory CalendarInvitationOccurrenceApplyReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationOccurrenceApplyReceipt(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      kind: _ilccsff7.CalendarInvitationSourceKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      linkId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['linkId']),
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
      occurrenceRevision: jsonSerialization['occurrenceRevision'] as int,
      eventRevision: jsonSerialization['eventRevision'] as int,
      invitationRevision: jsonSerialization['invitationRevision'] as int,
      appliedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['appliedAt'],
      ),
    );
  }

  final _isc.UuidValue id;

  final _ilccsff7.CalendarInvitationSourceKind kind;

  final _ieswiaty.CalendarEventTiming originalStart;

  final _isc.UuidValue linkId;

  final _isc.UuidValue invitationId;

  final _isc.UuidValue sourceId;

  final _isc.UuidValue calendarId;

  final _isc.UuidValue eventId;

  final int occurrenceRevision;

  final int eventRevision;

  final int invitationRevision;

  final DateTime appliedAt;

  /// Returns a shallow copy of this [CalendarInvitationOccurrenceApplyReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationOccurrenceApplyReceipt copyWith({
    _isc.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    _ieswiaty.CalendarEventTiming? originalStart,
    _isc.UuidValue? linkId,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? occurrenceRevision,
    int? eventRevision,
    int? invitationRevision,
    DateTime? appliedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationOccurrenceApplyReceipt &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.linkId,
                  linkId,
                ) ||
                other.linkId == linkId) &&
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
                  other.occurrenceRevision,
                  occurrenceRevision,
                ) ||
                other.occurrenceRevision == occurrenceRevision) &&
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
                  other.appliedAt,
                  appliedAt,
                ) ||
                other.appliedAt == appliedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      kind,
      originalStart,
      linkId,
      invitationId,
      sourceId,
      calendarId,
      eventId,
      occurrenceRevision,
      eventRevision,
      invitationRevision,
      appliedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationOccurrenceApplyReceipt',
      'id': id.toJson(),
      'kind': kind.toJson(),
      'originalStart': originalStart.toJson(),
      'linkId': linkId.toJson(),
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'occurrenceRevision': occurrenceRevision,
      'eventRevision': eventRevision,
      'invitationRevision': invitationRevision,
      'appliedAt': appliedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationOccurrenceApplyReceipt',
      'id': id.toJson(),
      'kind': kind.toJson(),
      'originalStart': originalStart.toJsonForProtocol(),
      'linkId': linkId.toJson(),
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'occurrenceRevision': occurrenceRevision,
      'eventRevision': eventRevision,
      'invitationRevision': invitationRevision,
      'appliedAt': appliedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarInvitationOccurrenceApplyReceiptImpl
    extends CalendarInvitationOccurrenceApplyReceipt {
  const _CalendarInvitationOccurrenceApplyReceiptImpl({
    required _isc.UuidValue id,
    required _ilccsff7.CalendarInvitationSourceKind kind,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _isc.UuidValue linkId,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int occurrenceRevision,
    required int eventRevision,
    required int invitationRevision,
    required DateTime appliedAt,
  }) : super._(
         id: id,
         kind: kind,
         originalStart: originalStart,
         linkId: linkId,
         invitationId: invitationId,
         sourceId: sourceId,
         calendarId: calendarId,
         eventId: eventId,
         occurrenceRevision: occurrenceRevision,
         eventRevision: eventRevision,
         invitationRevision: invitationRevision,
         appliedAt: appliedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationOccurrenceApplyReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationOccurrenceApplyReceipt copyWith({
    _isc.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    _ieswiaty.CalendarEventTiming? originalStart,
    _isc.UuidValue? linkId,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? occurrenceRevision,
    int? eventRevision,
    int? invitationRevision,
    DateTime? appliedAt,
  }) {
    return CalendarInvitationOccurrenceApplyReceipt(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      linkId: linkId ?? this.linkId,
      invitationId: invitationId ?? this.invitationId,
      sourceId: sourceId ?? this.sourceId,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      occurrenceRevision: occurrenceRevision ?? this.occurrenceRevision,
      eventRevision: eventRevision ?? this.eventRevision,
      invitationRevision: invitationRevision ?? this.invitationRevision,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }
}
