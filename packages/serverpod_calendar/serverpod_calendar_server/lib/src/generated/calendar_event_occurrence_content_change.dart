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
import 'calendar_event_content_action.dart' as _ing6pwn6;
import 'calendar_event_content_field.dart' as _ipyf9yt3;

@_is.immutable
abstract class CalendarEventOccurrenceContentChange
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventOccurrenceContentChange._({
    required this.field,
    required this.action,
    this.text,
  });

  const factory CalendarEventOccurrenceContentChange({
    required _ipyf9yt3.CalendarEventContentField field,
    required _ing6pwn6.CalendarEventContentAction action,
    String? text,
  }) = _CalendarEventOccurrenceContentChangeImpl;

  factory CalendarEventOccurrenceContentChange.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrenceContentChange(
      field: _ipyf9yt3.CalendarEventContentField.fromJson(
        (jsonSerialization['field'] as String),
      ),
      action: _ing6pwn6.CalendarEventContentAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      text: jsonSerialization['text'] as String?,
    );
  }

  final _ipyf9yt3.CalendarEventContentField field;

  final _ing6pwn6.CalendarEventContentAction action;

  final String? text;

  /// Returns a shallow copy of this [CalendarEventOccurrenceContentChange]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventOccurrenceContentChange copyWith({
    _ipyf9yt3.CalendarEventContentField? field,
    _ing6pwn6.CalendarEventContentAction? action,
    String? text,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOccurrenceContentChange &&
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
                other.text == text);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      field,
      action,
      text,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarEventOccurrenceContentChange',
      'field': field.toJson(),
      'action': action.toJson(),
      if (text != null) 'text': text,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarEventOccurrenceContentChange',
      'field': field.toJson(),
      'action': action.toJson(),
      if (text != null) 'text': text,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventOccurrenceContentChangeImpl
    extends CalendarEventOccurrenceContentChange {
  const _CalendarEventOccurrenceContentChangeImpl({
    required _ipyf9yt3.CalendarEventContentField field,
    required _ing6pwn6.CalendarEventContentAction action,
    String? text,
  }) : super._(
         field: field,
         action: action,
         text: text,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrenceContentChange]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventOccurrenceContentChange copyWith({
    _ipyf9yt3.CalendarEventContentField? field,
    _ing6pwn6.CalendarEventContentAction? action,
    Object? text = _Undefined,
  }) {
    return CalendarEventOccurrenceContentChange(
      field: field ?? this.field,
      action: action ?? this.action,
      text: text is String? ? text : this.text,
    );
  }
}
