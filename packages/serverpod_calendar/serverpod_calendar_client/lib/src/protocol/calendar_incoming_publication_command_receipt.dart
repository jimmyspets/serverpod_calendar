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

import 'calendar_incoming_publication_kind.dart' as _ing1vpo7;

@_isc.immutable
abstract class CalendarIncomingPublicationCommandReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarIncomingPublicationCommandReceipt._({
    required this.linkId,
    required this.entryId,
    required this.sourceId,
    required this.calendarId,
    required this.eventId,
    required this.eventRevision,
    required this.entryRevision,
    required this.kind,
    required this.recordedAt,
    bool? unchanged,
  }) : unchanged = unchanged ?? false;

  const factory CalendarIncomingPublicationCommandReceipt({
    required _isc.UuidValue linkId,
    required _isc.UuidValue entryId,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int eventRevision,
    required int entryRevision,
    required _ing1vpo7.CalendarIncomingPublicationKind kind,
    required DateTime recordedAt,
    bool? unchanged,
  }) = _CalendarIncomingPublicationCommandReceiptImpl;

  factory CalendarIncomingPublicationCommandReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationCommandReceipt(
      linkId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['linkId']),
      entryId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
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
      entryRevision: jsonSerialization['entryRevision'] as int,
      kind: _ing1vpo7.CalendarIncomingPublicationKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      recordedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['recordedAt'],
      ),
      unchanged: jsonSerialization['unchanged'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['unchanged']),
    );
  }

  final _isc.UuidValue linkId;

  final _isc.UuidValue entryId;

  final _isc.UuidValue sourceId;

  final _isc.UuidValue calendarId;

  final _isc.UuidValue eventId;

  final int eventRevision;

  final int entryRevision;

  final _ing1vpo7.CalendarIncomingPublicationKind kind;

  final DateTime recordedAt;

  final bool unchanged;

  /// Returns a shallow copy of this [CalendarIncomingPublicationCommandReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarIncomingPublicationCommandReceipt copyWith({
    _isc.UuidValue? linkId,
    _isc.UuidValue? entryId,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? eventRevision,
    int? entryRevision,
    _ing1vpo7.CalendarIncomingPublicationKind? kind,
    DateTime? recordedAt,
    bool? unchanged,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationCommandReceipt &&
            (identical(
                  other.linkId,
                  linkId,
                ) ||
                other.linkId == linkId) &&
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
                  other.entryRevision,
                  entryRevision,
                ) ||
                other.entryRevision == entryRevision) &&
            (identical(
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
            (identical(
                  other.recordedAt,
                  recordedAt,
                ) ||
                other.recordedAt == recordedAt) &&
            (identical(
                  other.unchanged,
                  unchanged,
                ) ||
                other.unchanged == unchanged);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      linkId,
      entryId,
      sourceId,
      calendarId,
      eventId,
      eventRevision,
      entryRevision,
      kind,
      recordedAt,
      unchanged,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationCommandReceipt',
      'linkId': linkId.toJson(),
      'entryId': entryId.toJson(),
      'sourceId': sourceId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'eventRevision': eventRevision,
      'entryRevision': entryRevision,
      'kind': kind.toJson(),
      'recordedAt': recordedAt.toJson(),
      'unchanged': unchanged,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationCommandReceipt',
      'linkId': linkId.toJson(),
      'entryId': entryId.toJson(),
      'sourceId': sourceId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'eventRevision': eventRevision,
      'entryRevision': entryRevision,
      'kind': kind.toJson(),
      'recordedAt': recordedAt.toJson(),
      'unchanged': unchanged,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarIncomingPublicationCommandReceiptImpl
    extends CalendarIncomingPublicationCommandReceipt {
  const _CalendarIncomingPublicationCommandReceiptImpl({
    required _isc.UuidValue linkId,
    required _isc.UuidValue entryId,
    required _isc.UuidValue sourceId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int eventRevision,
    required int entryRevision,
    required _ing1vpo7.CalendarIncomingPublicationKind kind,
    required DateTime recordedAt,
    bool? unchanged,
  }) : super._(
         linkId: linkId,
         entryId: entryId,
         sourceId: sourceId,
         calendarId: calendarId,
         eventId: eventId,
         eventRevision: eventRevision,
         entryRevision: entryRevision,
         kind: kind,
         recordedAt: recordedAt,
         unchanged: unchanged,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationCommandReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarIncomingPublicationCommandReceipt copyWith({
    _isc.UuidValue? linkId,
    _isc.UuidValue? entryId,
    _isc.UuidValue? sourceId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? eventRevision,
    int? entryRevision,
    _ing1vpo7.CalendarIncomingPublicationKind? kind,
    DateTime? recordedAt,
    bool? unchanged,
  }) {
    return CalendarIncomingPublicationCommandReceipt(
      linkId: linkId ?? this.linkId,
      entryId: entryId ?? this.entryId,
      sourceId: sourceId ?? this.sourceId,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      eventRevision: eventRevision ?? this.eventRevision,
      entryRevision: entryRevision ?? this.entryRevision,
      kind: kind ?? this.kind,
      recordedAt: recordedAt ?? this.recordedAt,
      unchanged: unchanged ?? this.unchanged,
    );
  }
}
