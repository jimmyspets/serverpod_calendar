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
abstract class CalendarInvitationApplyReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarInvitationApplyReceipt._({
    required this.id,
    required this.linkId,
    required this.invitationId,
    required this.sourceId,
    required this.calendarId,
    required this.eventId,
    required this.applicationRevision,
    required this.eventRevision,
    required this.invitationRevision,
    required this.appliedAt,
  });

  const factory CalendarInvitationApplyReceipt({
    required _is.UuidValue id,
    required _is.UuidValue linkId,
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    required int applicationRevision,
    required int eventRevision,
    required int invitationRevision,
    required DateTime appliedAt,
  }) = _CalendarInvitationApplyReceiptImpl;

  factory CalendarInvitationApplyReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationApplyReceipt(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      linkId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['linkId']),
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
      applicationRevision: jsonSerialization['applicationRevision'] as int,
      eventRevision: jsonSerialization['eventRevision'] as int,
      invitationRevision: jsonSerialization['invitationRevision'] as int,
      appliedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['appliedAt'],
      ),
    );
  }

  final _is.UuidValue id;

  final _is.UuidValue linkId;

  final _is.UuidValue invitationId;

  final _is.UuidValue sourceId;

  final _is.UuidValue calendarId;

  final _is.UuidValue eventId;

  final int applicationRevision;

  final int eventRevision;

  final int invitationRevision;

  final DateTime appliedAt;

  /// Returns a shallow copy of this [CalendarInvitationApplyReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationApplyReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? linkId,
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
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
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationApplyReceiptImpl
    extends CalendarInvitationApplyReceipt {
  const _CalendarInvitationApplyReceiptImpl({
    required _is.UuidValue id,
    required _is.UuidValue linkId,
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    required int applicationRevision,
    required int eventRevision,
    required int invitationRevision,
    required DateTime appliedAt,
  }) : super._(
         id: id,
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
  @_is.useResult
  @override
  CalendarInvitationApplyReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? linkId,
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
    int? applicationRevision,
    int? eventRevision,
    int? invitationRevision,
    DateTime? appliedAt,
  }) {
    return CalendarInvitationApplyReceipt(
      id: id ?? this.id,
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
