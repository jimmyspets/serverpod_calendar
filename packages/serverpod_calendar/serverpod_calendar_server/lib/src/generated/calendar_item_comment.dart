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
import 'calendar_text_parameters.dart' as _iffxqqc7;

@_is.immutable
abstract class CalendarItemComment
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarItemComment._({
    required this.value,
    this.parameters,
  });

  const factory CalendarItemComment({
    required String value,
    _iffxqqc7.CalendarTextParameters? parameters,
  }) = _CalendarItemCommentImpl;

  factory CalendarItemComment.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarItemComment(
      value: jsonSerialization['value'] as String,
      parameters: jsonSerialization['parameters'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_iffxqqc7.CalendarTextParameters>(
              jsonSerialization['parameters'],
            ),
    );
  }

  final String value;

  final _iffxqqc7.CalendarTextParameters? parameters;

  /// Returns a shallow copy of this [CalendarItemComment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarItemComment copyWith({
    String? value,
    _iffxqqc7.CalendarTextParameters? parameters,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarItemComment &&
            (identical(
                  other.value,
                  value,
                ) ||
                other.value == value) &&
            (identical(
                  other.parameters,
                  parameters,
                ) ||
                other.parameters == parameters);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      value,
      parameters,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarItemComment',
      'value': value,
      if (parameters != null) 'parameters': parameters?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarItemComment',
      'value': value,
      if (parameters != null) 'parameters': parameters?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarItemCommentImpl extends CalendarItemComment {
  const _CalendarItemCommentImpl({
    required String value,
    _iffxqqc7.CalendarTextParameters? parameters,
  }) : super._(
         value: value,
         parameters: parameters,
       );

  /// Returns a shallow copy of this [CalendarItemComment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarItemComment copyWith({
    String? value,
    Object? parameters = _Undefined,
  }) {
    return CalendarItemComment(
      value: value ?? this.value,
      parameters: parameters is _iffxqqc7.CalendarTextParameters?
          ? parameters
          : this.parameters?.copyWith(),
    );
  }
}
