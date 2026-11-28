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
import 'calendar_task_view.dart' as _ii3yrr21;

@_is.immutable
abstract class CalendarTaskPage
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskPage._({
    required this.tasks,
    this.nextCursor,
  });

  const factory CalendarTaskPage({
    required List<_ii3yrr21.CalendarTaskView> tasks,
    String? nextCursor,
  }) = _CalendarTaskPageImpl;

  factory CalendarTaskPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarTaskPage(
      tasks: _ix00hwbf.Protocol().deserialize<List<_ii3yrr21.CalendarTaskView>>(
        jsonSerialization['tasks'],
      ),
      nextCursor: jsonSerialization['nextCursor'] as String?,
    );
  }

  final List<_ii3yrr21.CalendarTaskView> tasks;

  final String? nextCursor;

  /// Returns a shallow copy of this [CalendarTaskPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskPage copyWith({
    List<_ii3yrr21.CalendarTaskView>? tasks,
    String? nextCursor,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskPage &&
            const _iss.DeepCollectionEquality().equals(
              other.tasks,
              tasks,
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
      const _iss.DeepCollectionEquality().hash(tasks),
      nextCursor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskPage',
      'tasks': tasks.toJson(valueToJson: (v) => v.toJson()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskPage',
      'tasks': tasks.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskPageImpl extends CalendarTaskPage {
  const _CalendarTaskPageImpl({
    required List<_ii3yrr21.CalendarTaskView> tasks,
    String? nextCursor,
  }) : super._(
         tasks: tasks,
         nextCursor: nextCursor,
       );

  /// Returns a shallow copy of this [CalendarTaskPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskPage copyWith({
    List<_ii3yrr21.CalendarTaskView>? tasks,
    Object? nextCursor = _Undefined,
  }) {
    return CalendarTaskPage(
      tasks: tasks ?? this.tasks.map((e0) => e0.copyWith()).toList(),
      nextCursor: nextCursor is String? ? nextCursor : this.nextCursor,
    );
  }
}
