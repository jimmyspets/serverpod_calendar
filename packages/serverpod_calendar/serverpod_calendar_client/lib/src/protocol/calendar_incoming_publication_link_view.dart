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

import 'calendar_incoming_publication_command_receipt.dart' as _i81webjm;
import 'calendar_incoming_publication_kind.dart' as _ing1vpo7;

@_isc.immutable
abstract class CalendarIncomingPublicationLinkView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarIncomingPublicationLinkView._({
    required this.id,
    required this.entryId,
    required this.calendarId,
    required this.eventId,
    required this.eventRevision,
    required this.entryRevision,
    required this.deleted,
    required this.hasLocalChanges,
    this.acceptedSourceId,
    this.acceptedKind,
    this.acceptedSequence,
    this.acceptedStamp,
    required this.creationReceipt,
    this.latestApplyReceipt,
  });

  const factory CalendarIncomingPublicationLinkView({
    required _isc.UuidValue id,
    required _isc.UuidValue entryId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int eventRevision,
    required int entryRevision,
    required bool deleted,
    required bool hasLocalChanges,
    _isc.UuidValue? acceptedSourceId,
    _ing1vpo7.CalendarIncomingPublicationKind? acceptedKind,
    int? acceptedSequence,
    DateTime? acceptedStamp,
    required _i81webjm.CalendarIncomingPublicationCommandReceipt
    creationReceipt,
    _i81webjm.CalendarIncomingPublicationCommandReceipt? latestApplyReceipt,
  }) = _CalendarIncomingPublicationLinkViewImpl;

  factory CalendarIncomingPublicationLinkView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationLinkView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entryId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      eventRevision: jsonSerialization['eventRevision'] as int,
      entryRevision: jsonSerialization['entryRevision'] as int,
      deleted: _isc.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
      hasLocalChanges: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['hasLocalChanges'],
      ),
      acceptedSourceId: jsonSerialization['acceptedSourceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['acceptedSourceId'],
            ),
      acceptedKind: jsonSerialization['acceptedKind'] == null
          ? null
          : _ing1vpo7.CalendarIncomingPublicationKind.fromJson(
              (jsonSerialization['acceptedKind'] as String),
            ),
      acceptedSequence: jsonSerialization['acceptedSequence'] as int?,
      acceptedStamp: jsonSerialization['acceptedStamp'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['acceptedStamp'],
            ),
      creationReceipt: _ie4a1wrz.Protocol()
          .deserialize<_i81webjm.CalendarIncomingPublicationCommandReceipt>(
            jsonSerialization['creationReceipt'],
          ),
      latestApplyReceipt: jsonSerialization['latestApplyReceipt'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<
              _i81webjm.CalendarIncomingPublicationCommandReceipt
            >(jsonSerialization['latestApplyReceipt']),
    );
  }

  final _isc.UuidValue id;

  final _isc.UuidValue entryId;

  final _isc.UuidValue calendarId;

  final _isc.UuidValue eventId;

  final int eventRevision;

  final int entryRevision;

  final bool deleted;

  final bool hasLocalChanges;

  final _isc.UuidValue? acceptedSourceId;

  final _ing1vpo7.CalendarIncomingPublicationKind? acceptedKind;

  final int? acceptedSequence;

  final DateTime? acceptedStamp;

  final _i81webjm.CalendarIncomingPublicationCommandReceipt creationReceipt;

  final _i81webjm.CalendarIncomingPublicationCommandReceipt? latestApplyReceipt;

  /// Returns a shallow copy of this [CalendarIncomingPublicationLinkView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarIncomingPublicationLinkView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? entryId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? eventRevision,
    int? entryRevision,
    bool? deleted,
    bool? hasLocalChanges,
    _isc.UuidValue? acceptedSourceId = const _isc.$UndefinedUuidValue(),
    _ing1vpo7.CalendarIncomingPublicationKind? acceptedKind,
    int? acceptedSequence,
    DateTime? acceptedStamp = const _isc.$UndefinedDateTime(),
    _i81webjm.CalendarIncomingPublicationCommandReceipt? creationReceipt,
    _i81webjm.CalendarIncomingPublicationCommandReceipt? latestApplyReceipt =
        const _UndefinedCalendarIncomingPublicationLinkView$latestApplyReceipt(),
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationLinkView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.entryId,
                  entryId,
                ) ||
                other.entryId == entryId) &&
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
                  other.deleted,
                  deleted,
                ) ||
                other.deleted == deleted) &&
            (identical(
                  other.hasLocalChanges,
                  hasLocalChanges,
                ) ||
                other.hasLocalChanges == hasLocalChanges) &&
            (identical(
                  other.acceptedSourceId,
                  acceptedSourceId,
                ) ||
                other.acceptedSourceId == acceptedSourceId) &&
            (identical(
                  other.acceptedKind,
                  acceptedKind,
                ) ||
                other.acceptedKind == acceptedKind) &&
            (identical(
                  other.acceptedSequence,
                  acceptedSequence,
                ) ||
                other.acceptedSequence == acceptedSequence) &&
            (identical(
                  other.acceptedStamp,
                  acceptedStamp,
                ) ||
                other.acceptedStamp == acceptedStamp) &&
            (identical(
                  other.creationReceipt,
                  creationReceipt,
                ) ||
                other.creationReceipt == creationReceipt) &&
            (identical(
                  other.latestApplyReceipt,
                  latestApplyReceipt,
                ) ||
                other.latestApplyReceipt == latestApplyReceipt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      entryId,
      calendarId,
      eventId,
      eventRevision,
      entryRevision,
      deleted,
      hasLocalChanges,
      acceptedSourceId,
      acceptedKind,
      acceptedSequence,
      acceptedStamp,
      creationReceipt,
      latestApplyReceipt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarIncomingPublicationLinkView',
      'id': id.toJson(),
      'entryId': entryId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'eventRevision': eventRevision,
      'entryRevision': entryRevision,
      'deleted': deleted,
      'hasLocalChanges': hasLocalChanges,
      if (acceptedSourceId != null)
        'acceptedSourceId': acceptedSourceId?.toJson(),
      if (acceptedKind != null) 'acceptedKind': acceptedKind?.toJson(),
      if (acceptedSequence != null) 'acceptedSequence': acceptedSequence,
      if (acceptedStamp != null) 'acceptedStamp': acceptedStamp?.toJson(),
      'creationReceipt': creationReceipt.toJson(),
      if (latestApplyReceipt != null)
        'latestApplyReceipt': latestApplyReceipt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarIncomingPublicationLinkView',
      'id': id.toJson(),
      'entryId': entryId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'eventRevision': eventRevision,
      'entryRevision': entryRevision,
      'deleted': deleted,
      'hasLocalChanges': hasLocalChanges,
      if (acceptedSourceId != null)
        'acceptedSourceId': acceptedSourceId?.toJson(),
      if (acceptedKind != null) 'acceptedKind': acceptedKind?.toJson(),
      if (acceptedSequence != null) 'acceptedSequence': acceptedSequence,
      if (acceptedStamp != null) 'acceptedStamp': acceptedStamp?.toJson(),
      'creationReceipt': creationReceipt.toJsonForProtocol(),
      if (latestApplyReceipt != null)
        'latestApplyReceipt': latestApplyReceipt?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedCalendarIncomingPublicationLinkView$latestApplyReceipt
    extends _isc.UndefinedSentinel
    implements _i81webjm.CalendarIncomingPublicationCommandReceipt {
  const _UndefinedCalendarIncomingPublicationLinkView$latestApplyReceipt();
}

class _CalendarIncomingPublicationLinkViewImpl
    extends CalendarIncomingPublicationLinkView {
  const _CalendarIncomingPublicationLinkViewImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue entryId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int eventRevision,
    required int entryRevision,
    required bool deleted,
    required bool hasLocalChanges,
    _isc.UuidValue? acceptedSourceId,
    _ing1vpo7.CalendarIncomingPublicationKind? acceptedKind,
    int? acceptedSequence,
    DateTime? acceptedStamp,
    required _i81webjm.CalendarIncomingPublicationCommandReceipt
    creationReceipt,
    _i81webjm.CalendarIncomingPublicationCommandReceipt? latestApplyReceipt,
  }) : super._(
         id: id,
         entryId: entryId,
         calendarId: calendarId,
         eventId: eventId,
         eventRevision: eventRevision,
         entryRevision: entryRevision,
         deleted: deleted,
         hasLocalChanges: hasLocalChanges,
         acceptedSourceId: acceptedSourceId,
         acceptedKind: acceptedKind,
         acceptedSequence: acceptedSequence,
         acceptedStamp: acceptedStamp,
         creationReceipt: creationReceipt,
         latestApplyReceipt: latestApplyReceipt,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationLinkView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarIncomingPublicationLinkView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? entryId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? eventRevision,
    int? entryRevision,
    bool? deleted,
    bool? hasLocalChanges,
    _isc.UuidValue? acceptedSourceId = const _isc.$UndefinedUuidValue(),
    Object? acceptedKind = _Undefined,
    Object? acceptedSequence = _Undefined,
    DateTime? acceptedStamp = const _isc.$UndefinedDateTime(),
    _i81webjm.CalendarIncomingPublicationCommandReceipt? creationReceipt,
    _i81webjm.CalendarIncomingPublicationCommandReceipt? latestApplyReceipt =
        const _UndefinedCalendarIncomingPublicationLinkView$latestApplyReceipt(),
  }) {
    return CalendarIncomingPublicationLinkView(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      eventRevision: eventRevision ?? this.eventRevision,
      entryRevision: entryRevision ?? this.entryRevision,
      deleted: deleted ?? this.deleted,
      hasLocalChanges: hasLocalChanges ?? this.hasLocalChanges,
      acceptedSourceId: acceptedSourceId is _isc.UndefinedSentinel
          ? this.acceptedSourceId
          : acceptedSourceId,
      acceptedKind: acceptedKind is _ing1vpo7.CalendarIncomingPublicationKind?
          ? acceptedKind
          : this.acceptedKind,
      acceptedSequence: acceptedSequence is int?
          ? acceptedSequence
          : this.acceptedSequence,
      acceptedStamp: acceptedStamp is _isc.UndefinedSentinel
          ? this.acceptedStamp
          : acceptedStamp,
      creationReceipt: creationReceipt ?? this.creationReceipt.copyWith(),
      latestApplyReceipt: latestApplyReceipt is _isc.UndefinedSentinel
          ? this.latestApplyReceipt?.copyWith()
          : latestApplyReceipt,
    );
  }
}
