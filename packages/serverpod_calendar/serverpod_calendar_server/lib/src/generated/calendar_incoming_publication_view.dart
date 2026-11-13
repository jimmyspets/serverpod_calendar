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
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;

import 'calendar_event_status.dart' as _ivzxk9bc;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_incoming_publication_kind.dart' as _ing1vpo7;

@_is.immutable
abstract class CalendarIncomingPublicationView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarIncomingPublicationView._({
    required this.id,
    required this.revision,
    required this.uid,
    required this.organizer,
    required this.recurring,
    required this.kind,
    required this.sourceId,
    this.sequence,
    required this.stamp,
    this.summary,
    this.timing,
    this.status,
    required this.receivedAt,
    this.dismissedAt,
  });

  const factory CalendarIncomingPublicationView({
    required _is.UuidValue id,
    required int revision,
    required String uid,
    required String organizer,
    required bool recurring,
    required _ing1vpo7.CalendarIncomingPublicationKind kind,
    required _is.UuidValue sourceId,
    int? sequence,
    required DateTime stamp,
    String? summary,
    _ieswiaty.CalendarEventTiming? timing,
    _ivzxk9bc.CalendarEventStatus? status,
    required DateTime receivedAt,
    DateTime? dismissedAt,
  }) = _CalendarIncomingPublicationViewImpl;

  factory CalendarIncomingPublicationView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      revision: jsonSerialization['revision'] as int,
      uid: jsonSerialization['uid'] as String,
      organizer: jsonSerialization['organizer'] as String,
      recurring: _is.BoolJsonExtension.fromJson(jsonSerialization['recurring']),
      kind: _ing1vpo7.CalendarIncomingPublicationKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      summary: jsonSerialization['summary'] as String?,
      timing: jsonSerialization['timing'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['timing'],
            ),
      status: jsonSerialization['status'] == null
          ? null
          : _ivzxk9bc.CalendarEventStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      dismissedAt: jsonSerialization['dismissedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['dismissedAt'],
            ),
    );
  }

  final _is.UuidValue id;

  final int revision;

  final String uid;

  final String organizer;

  final bool recurring;

  final _ing1vpo7.CalendarIncomingPublicationKind kind;

  final _is.UuidValue sourceId;

  final int? sequence;

  final DateTime stamp;

  final String? summary;

  final _ieswiaty.CalendarEventTiming? timing;

  final _ivzxk9bc.CalendarEventStatus? status;

  final DateTime receivedAt;

  final DateTime? dismissedAt;

  /// Returns a shallow copy of this [CalendarIncomingPublicationView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIncomingPublicationView copyWith({
    _is.UuidValue? id,
    int? revision,
    String? uid,
    String? organizer,
    bool? recurring,
    _ing1vpo7.CalendarIncomingPublicationKind? kind,
    _is.UuidValue? sourceId,
    int? sequence,
    DateTime? stamp,
    String? summary,
    _ieswiaty.CalendarEventTiming? timing =
        const _UndefinedCalendarIncomingPublicationView$timing(),
    _ivzxk9bc.CalendarEventStatus? status,
    DateTime? receivedAt,
    DateTime? dismissedAt = const _is.$UndefinedDateTime(),
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
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
                  other.recurring,
                  recurring,
                ) ||
                other.recurring == recurring) &&
            (identical(
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
            (identical(
                  other.sourceId,
                  sourceId,
                ) ||
                other.sourceId == sourceId) &&
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
                  other.status,
                  status,
                ) ||
                other.status == status) &&
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
      revision,
      uid,
      organizer,
      recurring,
      kind,
      sourceId,
      sequence,
      stamp,
      summary,
      timing,
      status,
      receivedAt,
      dismissedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarIncomingPublicationView',
      'id': id.toJson(),
      'revision': revision,
      'uid': uid,
      'organizer': organizer,
      'recurring': recurring,
      'kind': kind.toJson(),
      'sourceId': sourceId.toJson(),
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      if (summary != null) 'summary': summary,
      if (timing != null) 'timing': timing?.toJson(),
      if (status != null) 'status': status?.toJson(),
      'receivedAt': receivedAt.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarIncomingPublicationView',
      'id': id.toJson(),
      'revision': revision,
      'uid': uid,
      'organizer': organizer,
      'recurring': recurring,
      'kind': kind.toJson(),
      'sourceId': sourceId.toJson(),
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      if (summary != null) 'summary': summary,
      if (timing != null) 'timing': timing?.toJsonForProtocol(),
      if (status != null) 'status': status?.toJson(),
      'receivedAt': receivedAt.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedCalendarIncomingPublicationView$timing
    extends _is.UndefinedSentinel
    implements _ieswiaty.CalendarEventTiming {
  const _UndefinedCalendarIncomingPublicationView$timing();
}

class _CalendarIncomingPublicationViewImpl
    extends CalendarIncomingPublicationView {
  const _CalendarIncomingPublicationViewImpl({
    required _is.UuidValue id,
    required int revision,
    required String uid,
    required String organizer,
    required bool recurring,
    required _ing1vpo7.CalendarIncomingPublicationKind kind,
    required _is.UuidValue sourceId,
    int? sequence,
    required DateTime stamp,
    String? summary,
    _ieswiaty.CalendarEventTiming? timing,
    _ivzxk9bc.CalendarEventStatus? status,
    required DateTime receivedAt,
    DateTime? dismissedAt,
  }) : super._(
         id: id,
         revision: revision,
         uid: uid,
         organizer: organizer,
         recurring: recurring,
         kind: kind,
         sourceId: sourceId,
         sequence: sequence,
         stamp: stamp,
         summary: summary,
         timing: timing,
         status: status,
         receivedAt: receivedAt,
         dismissedAt: dismissedAt,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarIncomingPublicationView copyWith({
    _is.UuidValue? id,
    int? revision,
    String? uid,
    String? organizer,
    bool? recurring,
    _ing1vpo7.CalendarIncomingPublicationKind? kind,
    _is.UuidValue? sourceId,
    Object? sequence = _Undefined,
    DateTime? stamp,
    Object? summary = _Undefined,
    _ieswiaty.CalendarEventTiming? timing =
        const _UndefinedCalendarIncomingPublicationView$timing(),
    Object? status = _Undefined,
    DateTime? receivedAt,
    DateTime? dismissedAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarIncomingPublicationView(
      id: id ?? this.id,
      revision: revision ?? this.revision,
      uid: uid ?? this.uid,
      organizer: organizer ?? this.organizer,
      recurring: recurring ?? this.recurring,
      kind: kind ?? this.kind,
      sourceId: sourceId ?? this.sourceId,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      summary: summary is String? ? summary : this.summary,
      timing: timing is _is.UndefinedSentinel
          ? this.timing?.copyWith()
          : timing,
      status: status is _ivzxk9bc.CalendarEventStatus? ? status : this.status,
      receivedAt: receivedAt ?? this.receivedAt,
      dismissedAt: dismissedAt is _is.UndefinedSentinel
          ? this.dismissedAt
          : dismissedAt,
    );
  }
}
