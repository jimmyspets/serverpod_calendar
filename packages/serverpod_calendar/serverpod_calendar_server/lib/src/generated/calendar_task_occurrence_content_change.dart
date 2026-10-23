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
import 'calendar_task_content_action.dart' as _ihwe765g;
import 'calendar_task_content_field.dart' as _i496rta0;

@_is.immutable
abstract class CalendarTaskOccurrenceContentChange
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskOccurrenceContentChange._({
    required this.field,
    required this.action,
    this.text,
    this.priority,
  });

  const factory CalendarTaskOccurrenceContentChange({
    required _i496rta0.CalendarTaskContentField field,
    required _ihwe765g.CalendarTaskContentAction action,
    String? text,
    int? priority,
  }) = _CalendarTaskOccurrenceContentChangeImpl;

  factory CalendarTaskOccurrenceContentChange.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskOccurrenceContentChange(
      field: _i496rta0.CalendarTaskContentField.fromJson(
        (jsonSerialization['field'] as String),
      ),
      action: _ihwe765g.CalendarTaskContentAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      text: jsonSerialization['text'] as String?,
      priority: jsonSerialization['priority'] as int?,
    );
  }

  final _i496rta0.CalendarTaskContentField field;

  final _ihwe765g.CalendarTaskContentAction action;

  final String? text;

  final int? priority;

  /// Returns a shallow copy of this [CalendarTaskOccurrenceContentChange]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskOccurrenceContentChange copyWith({
    _i496rta0.CalendarTaskContentField? field,
    _ihwe765g.CalendarTaskContentAction? action,
    String? text,
    int? priority,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskOccurrenceContentChange &&
            (identical(
                  other.field,
                  field,
                ) ||
                other.field == field) &&
            (identical(
                  other.action,
                  action,
                ) ||
                other.action == action) &&
            (identical(
                  other.text,
                  text,
                ) ||
                other.text == text) &&
            (identical(
                  other.priority,
                  priority,
                ) ||
                other.priority == priority);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      field,
      action,
      text,
      priority,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrenceContentChange',
      'field': field.toJson(),
      'action': action.toJson(),
      if (text != null) 'text': text,
      if (priority != null) 'priority': priority,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrenceContentChange',
      'field': field.toJson(),
      'action': action.toJson(),
      if (text != null) 'text': text,
      if (priority != null) 'priority': priority,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskOccurrenceContentChangeImpl
    extends CalendarTaskOccurrenceContentChange {
  const _CalendarTaskOccurrenceContentChangeImpl({
    required _i496rta0.CalendarTaskContentField field,
    required _ihwe765g.CalendarTaskContentAction action,
    String? text,
    int? priority,
  }) : super._(
         field: field,
         action: action,
         text: text,
         priority: priority,
       );

  /// Returns a shallow copy of this [CalendarTaskOccurrenceContentChange]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskOccurrenceContentChange copyWith({
    _i496rta0.CalendarTaskContentField? field,
    _ihwe765g.CalendarTaskContentAction? action,
    Object? text = _Undefined,
    Object? priority = _Undefined,
  }) {
    return CalendarTaskOccurrenceContentChange(
      field: field ?? this.field,
      action: action ?? this.action,
      text: text is String? ? text : this.text,
      priority: priority is int? ? priority : this.priority,
    );
  }
}
