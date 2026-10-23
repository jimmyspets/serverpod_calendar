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
import 'calendar_task_assignee.dart' as _ih5e3u6u;
import 'calendar_task_content.dart' as _if7nbvl8;

@_is.immutable
abstract class CalendarTaskCreateRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskCreateRequest._({
    required this.calendarId,
    required this.content,
    required this.assignees,
  });

  const factory CalendarTaskCreateRequest({
    required _is.UuidValue calendarId,
    required _if7nbvl8.CalendarTaskContent content,
    required List<_ih5e3u6u.CalendarTaskAssignee> assignees,
  }) = _CalendarTaskCreateRequestImpl;

  factory CalendarTaskCreateRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskCreateRequest(
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      content: _ix00hwbf.Protocol().deserialize<_if7nbvl8.CalendarTaskContent>(
        jsonSerialization['content'],
      ),
      assignees: _ix00hwbf.Protocol()
          .deserialize<List<_ih5e3u6u.CalendarTaskAssignee>>(
            jsonSerialization['assignees'],
          ),
    );
  }

  final _is.UuidValue calendarId;

  final _if7nbvl8.CalendarTaskContent content;

  final List<_ih5e3u6u.CalendarTaskAssignee> assignees;

  /// Returns a shallow copy of this [CalendarTaskCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskCreateRequest copyWith({
    _is.UuidValue? calendarId,
    _if7nbvl8.CalendarTaskContent? content,
    List<_ih5e3u6u.CalendarTaskAssignee>? assignees,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskCreateRequest &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.content,
                  content,
                ) ||
                other.content == content) &&
            const _iss.DeepCollectionEquality().equals(
              other.assignees,
              assignees,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      calendarId,
      content,
      const _iss.DeepCollectionEquality().hash(assignees),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskCreateRequest',
      'calendarId': calendarId.toJson(),
      'content': content.toJson(),
      'assignees': assignees.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskCreateRequest',
      'calendarId': calendarId.toJson(),
      'content': content.toJsonForProtocol(),
      'assignees': assignees.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarTaskCreateRequestImpl extends CalendarTaskCreateRequest {
  const _CalendarTaskCreateRequestImpl({
    required _is.UuidValue calendarId,
    required _if7nbvl8.CalendarTaskContent content,
    required List<_ih5e3u6u.CalendarTaskAssignee> assignees,
  }) : super._(
         calendarId: calendarId,
         content: content,
         assignees: assignees,
       );

  /// Returns a shallow copy of this [CalendarTaskCreateRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskCreateRequest copyWith({
    _is.UuidValue? calendarId,
    _if7nbvl8.CalendarTaskContent? content,
    List<_ih5e3u6u.CalendarTaskAssignee>? assignees,
  }) {
    return CalendarTaskCreateRequest(
      calendarId: calendarId ?? this.calendarId,
      content: content ?? this.content.copyWith(),
      assignees:
          assignees ?? this.assignees.map((e0) => e0.copyWith()).toList(),
    );
  }
}
