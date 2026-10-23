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
import 'calendar_task_progress.dart' as _ikcsq95s;
import 'calendar_task_progress_action.dart' as _i6s7yrua;

@_isc.immutable
abstract class CalendarTaskHistoryEntry
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskHistoryEntry._({
    required this.revision,
    required this.action,
    required this.before,
    required this.after,
    required this.recordedAt,
  });

  const factory CalendarTaskHistoryEntry({
    required int revision,
    required _i6s7yrua.CalendarTaskProgressAction action,
    required _ikcsq95s.CalendarTaskProgress before,
    required _ikcsq95s.CalendarTaskProgress after,
    required DateTime recordedAt,
  }) = _CalendarTaskHistoryEntryImpl;

  factory CalendarTaskHistoryEntry.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskHistoryEntry(
      revision: jsonSerialization['revision'] as int,
      action: _i6s7yrua.CalendarTaskProgressAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      before: _ie4a1wrz.Protocol().deserialize<_ikcsq95s.CalendarTaskProgress>(
        jsonSerialization['before'],
      ),
      after: _ie4a1wrz.Protocol().deserialize<_ikcsq95s.CalendarTaskProgress>(
        jsonSerialization['after'],
      ),
      recordedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['recordedAt'],
      ),
    );
  }

  final int revision;

  final _i6s7yrua.CalendarTaskProgressAction action;

  final _ikcsq95s.CalendarTaskProgress before;

  final _ikcsq95s.CalendarTaskProgress after;

  final DateTime recordedAt;

  /// Returns a shallow copy of this [CalendarTaskHistoryEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskHistoryEntry copyWith({
    int? revision,
    _i6s7yrua.CalendarTaskProgressAction? action,
    _ikcsq95s.CalendarTaskProgress? before,
    _ikcsq95s.CalendarTaskProgress? after,
    DateTime? recordedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskHistoryEntry &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            (identical(
                  other.action,
                  action,
                ) ||
                other.action == action) &&
            (identical(
                  other.before,
                  before,
                ) ||
                other.before == before) &&
            (identical(
                  other.after,
                  after,
                ) ||
                other.after == after) &&
            (identical(
                  other.recordedAt,
                  recordedAt,
                ) ||
                other.recordedAt == recordedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      revision,
      action,
      before,
      after,
      recordedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskHistoryEntry',
      'revision': revision,
      'action': action.toJson(),
      'before': before.toJson(),
      'after': after.toJson(),
      'recordedAt': recordedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskHistoryEntry',
      'revision': revision,
      'action': action.toJson(),
      'before': before.toJsonForProtocol(),
      'after': after.toJsonForProtocol(),
      'recordedAt': recordedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarTaskHistoryEntryImpl extends CalendarTaskHistoryEntry {
  const _CalendarTaskHistoryEntryImpl({
    required int revision,
    required _i6s7yrua.CalendarTaskProgressAction action,
    required _ikcsq95s.CalendarTaskProgress before,
    required _ikcsq95s.CalendarTaskProgress after,
    required DateTime recordedAt,
  }) : super._(
         revision: revision,
         action: action,
         before: before,
         after: after,
         recordedAt: recordedAt,
       );

  /// Returns a shallow copy of this [CalendarTaskHistoryEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskHistoryEntry copyWith({
    int? revision,
    _i6s7yrua.CalendarTaskProgressAction? action,
    _ikcsq95s.CalendarTaskProgress? before,
    _ikcsq95s.CalendarTaskProgress? after,
    DateTime? recordedAt,
  }) {
    return CalendarTaskHistoryEntry(
      revision: revision ?? this.revision,
      action: action ?? this.action,
      before: before ?? this.before.copyWith(),
      after: after ?? this.after.copyWith(),
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
