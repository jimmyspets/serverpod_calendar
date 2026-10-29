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
import 'calendar_invitation_source_kind.dart' as _ilccsff7;

@_isc.immutable
abstract class CalendarInvitationApplyReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationApplyReceipt._({
    required this.id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required this.linkId,
    required this.invitationId,
    required this.sourceId,
    required this.calendarId,
    required this.eventId,
    required this.applicationRevision,
    required this.eventRevision,
    required this.invitationRevision,
    required this.appliedAt,
  }) : kind = kind ?? _ilccsff7.CalendarInvitationSourceKind.request;

  const factory CalendarInvitationApplyReceipt({
    required _isc.UuidValue id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required _isc.UuidValue linkId,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int applicationRevision,
    required int eventRevision,
    required int invitationRevision,
    required DateTime appliedAt,
  }) = _CalendarInvitationApplyReceiptImpl;

  factory CalendarInvitationApplyReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationApplyReceipt(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      kind: jsonSerialization['kind'] == null
          ? null
          : _ilccsff7.CalendarInvitationSourceKind.fromJson(
              (jsonSerialization['kind'] as String),
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
      applicationRevision: jsonSerialization['applicationRevision'] as int,
      eventRevision: jsonSerialization['eventRevision'] as int,
      invitationRevision: jsonSerialization['invitationRevision'] as int,
      appliedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['appliedAt'],
      ),
    );
  }

  final _ilccsff7.CalendarInvitationSourceKind kind;

  final _isc.UuidValue id;

  final _isc.UuidValue linkId;

  final _isc.UuidValue invitationId;

  final _isc.UuidValue sourceId;

  final _isc.UuidValue calendarId;

  final _isc.UuidValue eventId;

  final int applicationRevision;

  final int eventRevision;

  final int invitationRevision;

  final DateTime appliedAt;

  /// Returns a shallow copy of this [CalendarInvitationApplyReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationApplyReceipt copyWith({
    _isc.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    _isc.UuidValue? linkId,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? applicationRevision,
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
            other is CalendarInvitationApplyReceipt &&
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
                  other.applicationRevision,
                  applicationRevision,
                ) ||
                other.applicationRevision == applicationRevision) &&
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
      linkId,
      invitationId,
      sourceId,
      calendarId,
      eventId,
      applicationRevision,
      eventRevision,
      invitationRevision,
      appliedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationApplyReceipt',
      'id': id.toJson(),
      'kind': kind.toJson(),
      'linkId': linkId.toJson(),
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'applicationRevision': applicationRevision,
      'eventRevision': eventRevision,
      'invitationRevision': invitationRevision,
      'appliedAt': appliedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationApplyReceipt',
      'id': id.toJson(),
      'kind': kind.toJson(),
      'linkId': linkId.toJson(),
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'applicationRevision': applicationRevision,
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

class _CalendarInvitationApplyReceiptImpl
    extends CalendarInvitationApplyReceipt {
  const _CalendarInvitationApplyReceiptImpl({
    required _isc.UuidValue id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required _isc.UuidValue linkId,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int applicationRevision,
    required int eventRevision,
    required int invitationRevision,
    required DateTime appliedAt,
  }) : super._(
         id: id,
         kind: kind,
         linkId: linkId,
         invitationId: invitationId,
         sourceId: sourceId,
         calendarId: calendarId,
         eventId: eventId,
         applicationRevision: applicationRevision,
         eventRevision: eventRevision,
         invitationRevision: invitationRevision,
         appliedAt: appliedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationApplyReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationApplyReceipt copyWith({
    _isc.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    _isc.UuidValue? linkId,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? applicationRevision,
    int? eventRevision,
    int? invitationRevision,
    DateTime? appliedAt,
  }) {
    return CalendarInvitationApplyReceipt(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      linkId: linkId ?? this.linkId,
      invitationId: invitationId ?? this.invitationId,
      sourceId: sourceId ?? this.sourceId,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      applicationRevision: applicationRevision ?? this.applicationRevision,
      eventRevision: eventRevision ?? this.eventRevision,
      invitationRevision: invitationRevision ?? this.invitationRevision,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }
}
