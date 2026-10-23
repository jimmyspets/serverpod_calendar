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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_task_history_entry.dart' as _idhalyap;

@_is.immutable
abstract class CalendarTaskHistoryPage
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskHistoryPage._({
    required this.taskId,
    required this.revision,
    required this.originalStart,
    required this.entries,
    this.nextCursor,
  });

  const factory CalendarTaskHistoryPage({
    required _is.UuidValue taskId,
    required int revision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required List<_idhalyap.CalendarTaskHistoryEntry> entries,
    String? nextCursor,
  }) = _CalendarTaskHistoryPageImpl;

  factory CalendarTaskHistoryPage.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskHistoryPage(
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      revision: jsonSerialization['revision'] as int,
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      entries: _ix00hwbf.Protocol()
          .deserialize<List<_idhalyap.CalendarTaskHistoryEntry>>(
            jsonSerialization['entries'],
          ),
      nextCursor: jsonSerialization['nextCursor'] as String?,
    );
  }

  final _is.UuidValue taskId;

  final int revision;

  final _ieswiaty.CalendarEventTiming originalStart;

  final List<_idhalyap.CalendarTaskHistoryEntry> entries;

  final String? nextCursor;

  /// Returns a shallow copy of this [CalendarTaskHistoryPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskHistoryPage copyWith({
    _is.UuidValue? taskId,
    int? revision,
    _ieswiaty.CalendarEventTiming? originalStart,
    List<_idhalyap.CalendarTaskHistoryEntry>? entries,
    String? nextCursor,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskHistoryPage &&
            (identical(
                  other.taskId,
                  taskId,
                ) ||
                other.taskId == taskId) &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            const _iss.DeepCollectionEquality().equals(
              other.entries,
              entries,
            ) &&
            (identical(
                  other.nextCursor,
                  nextCursor,
                ) ||
                other.nextCursor == nextCursor);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      taskId,
      revision,
      originalStart,
      const _iss.DeepCollectionEquality().hash(entries),
      nextCursor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskHistoryPage',
      'taskId': taskId.toJson(),
      'revision': revision,
      'originalStart': originalStart.toJson(),
      'entries': entries.toJson(valueToJson: (v) => v.toJson()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskHistoryPage',
      'taskId': taskId.toJson(),
      'revision': revision,
      'originalStart': originalStart.toJsonForProtocol(),
      'entries': entries.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskHistoryPageImpl extends CalendarTaskHistoryPage {
  const _CalendarTaskHistoryPageImpl({
    required _is.UuidValue taskId,
    required int revision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required List<_idhalyap.CalendarTaskHistoryEntry> entries,
    String? nextCursor,
  }) : super._(
         taskId: taskId,
         revision: revision,
         originalStart: originalStart,
         entries: entries,
         nextCursor: nextCursor,
       );

  /// Returns a shallow copy of this [CalendarTaskHistoryPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskHistoryPage copyWith({
    _is.UuidValue? taskId,
    int? revision,
    _ieswiaty.CalendarEventTiming? originalStart,
    List<_idhalyap.CalendarTaskHistoryEntry>? entries,
    Object? nextCursor = _Undefined,
  }) {
    return CalendarTaskHistoryPage(
      taskId: taskId ?? this.taskId,
      revision: revision ?? this.revision,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      entries: entries ?? this.entries.map((e0) => e0.copyWith()).toList(),
      nextCursor: nextCursor is String? ? nextCursor : this.nextCursor,
    );
  }
}
