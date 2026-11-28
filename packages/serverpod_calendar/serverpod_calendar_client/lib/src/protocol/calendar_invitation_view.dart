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
abstract class CalendarInvitationView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationView._({
    required this.id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required this.revision,
    required this.uid,
    required this.organizer,
    this.sequence,
    required this.stamp,
    this.sourceId,
    this.summary,
    this.timing,
    this.receivedAt,
    this.dismissedAt,
  }) : kind = kind ?? _ilccsff7.CalendarInvitationSourceKind.request;

  const factory CalendarInvitationView({
    required _isc.UuidValue id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required int revision,
    required String uid,
    required String organizer,
    int? sequence,
    required DateTime stamp,
    _isc.UuidValue? sourceId,
    String? summary,
    _ieswiaty.CalendarEventTiming? timing,
    DateTime? receivedAt,
    DateTime? dismissedAt,
  }) = _CalendarInvitationViewImpl;

  factory CalendarInvitationView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      kind: jsonSerialization['kind'] == null
          ? null
          : _ilccsff7.CalendarInvitationSourceKind.fromJson(
              (jsonSerialization['kind'] as String),
            ),
      revision: jsonSerialization['revision'] as int,
      uid: jsonSerialization['uid'] as String,
      organizer: jsonSerialization['organizer'] as String,
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      sourceId: jsonSerialization['sourceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['sourceId']),
      summary: jsonSerialization['summary'] as String?,
      timing: jsonSerialization['timing'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['timing'],
            ),
      receivedAt: jsonSerialization['receivedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['receivedAt'],
            ),
      dismissedAt: jsonSerialization['dismissedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['dismissedAt'],
            ),
    );
  }

  final _ilccsff7.CalendarInvitationSourceKind kind;

  final _isc.UuidValue id;

  final int revision;

  final String uid;

  final String organizer;

  final int? sequence;

  final DateTime stamp;

  final _isc.UuidValue? sourceId;

  final String? summary;

  final _ieswiaty.CalendarEventTiming? timing;

  final DateTime? receivedAt;

  final DateTime? dismissedAt;

  /// Returns a shallow copy of this [CalendarInvitationView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationView copyWith({
    _isc.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    int? revision,
    String? uid,
    String? organizer,
    int? sequence,
    DateTime? stamp,
    _isc.UuidValue? sourceId,
    String? summary,
    _ieswiaty.CalendarEventTiming? timing,
    DateTime? receivedAt,
    DateTime? dismissedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationView &&
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
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            (identical(
                  other.uid,
                  uid,
                ) ||
                other.uid == uid) &&
            (identical(
                  other.organizer,
                  organizer,
                ) ||
                other.organizer == organizer) &&
            (identical(
                  other.sequence,
                  sequence,
                ) ||
                other.sequence == sequence) &&
            (identical(
                  other.stamp,
                  stamp,
                ) ||
                other.stamp == stamp) &&
            (identical(
                  other.sourceId,
                  sourceId,
                ) ||
                other.sourceId == sourceId) &&
            (identical(
                  other.summary,
                  summary,
                ) ||
                other.summary == summary) &&
            (identical(
                  other.timing,
                  timing,
                ) ||
                other.timing == timing) &&
            (identical(
                  other.receivedAt,
                  receivedAt,
                ) ||
                other.receivedAt == receivedAt) &&
            (identical(
                  other.dismissedAt,
                  dismissedAt,
                ) ||
                other.dismissedAt == dismissedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      kind,
      revision,
      uid,
      organizer,
      sequence,
      stamp,
      sourceId,
      summary,
      timing,
      receivedAt,
      dismissedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationView',
      'id': id.toJson(),
      'kind': kind.toJson(),
      'revision': revision,
      'uid': uid,
      'organizer': organizer,
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      if (sourceId != null) 'sourceId': sourceId?.toJson(),
      if (summary != null) 'summary': summary,
      if (timing != null) 'timing': timing?.toJson(),
      if (receivedAt != null) 'receivedAt': receivedAt?.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationView',
      'id': id.toJson(),
      'kind': kind.toJson(),
      'revision': revision,
      'uid': uid,
      'organizer': organizer,
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      if (sourceId != null) 'sourceId': sourceId?.toJson(),
      if (summary != null) 'summary': summary,
      if (timing != null) 'timing': timing?.toJsonForProtocol(),
      if (receivedAt != null) 'receivedAt': receivedAt?.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationViewImpl extends CalendarInvitationView {
  const _CalendarInvitationViewImpl({
    required _isc.UuidValue id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required int revision,
    required String uid,
    required String organizer,
    int? sequence,
    required DateTime stamp,
    _isc.UuidValue? sourceId,
    String? summary,
    _ieswiaty.CalendarEventTiming? timing,
    DateTime? receivedAt,
    DateTime? dismissedAt,
  }) : super._(
         id: id,
         kind: kind,
         revision: revision,
         uid: uid,
         organizer: organizer,
         sequence: sequence,
         stamp: stamp,
         sourceId: sourceId,
         summary: summary,
         timing: timing,
         receivedAt: receivedAt,
         dismissedAt: dismissedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationView copyWith({
    _isc.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    int? revision,
    String? uid,
    String? organizer,
    Object? sequence = _Undefined,
    DateTime? stamp,
    Object? sourceId = _Undefined,
    Object? summary = _Undefined,
    Object? timing = _Undefined,
    Object? receivedAt = _Undefined,
    Object? dismissedAt = _Undefined,
  }) {
    return CalendarInvitationView(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      revision: revision ?? this.revision,
      uid: uid ?? this.uid,
      organizer: organizer ?? this.organizer,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      sourceId: sourceId is _isc.UuidValue? ? sourceId : this.sourceId,
      summary: summary is String? ? summary : this.summary,
      timing: timing is _ieswiaty.CalendarEventTiming?
          ? timing
          : this.timing?.copyWith(),
      receivedAt: receivedAt is DateTime? ? receivedAt : this.receivedAt,
      dismissedAt: dismissedAt is DateTime? ? dismissedAt : this.dismissedAt,
    );
  }
}
