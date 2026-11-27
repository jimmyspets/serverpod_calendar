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

abstract class CalendarCategory
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarCategory._({
    required this.value,
    this.language,
  });

  factory CalendarCategory({
    required String value,
    String? language,
  }) = _CalendarCategoryImpl;

  factory CalendarCategory.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarCategory(
      value: jsonSerialization['value'] as String,
      language: jsonSerialization['language'] as String?,
    );
  }

  String value;

  String? language;

  /// Returns a shallow copy of this [CalendarCategory]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarCategory copyWith({
    String? value,
    String? language,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarCategory',
      'value': value,
      if (language != null) 'language': language,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarCategory',
      'value': value,
      if (language != null) 'language': language,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarCategoryImpl extends CalendarCategory {
  _CalendarCategoryImpl({
    required String value,
    String? language,
  }) : super._(
         value: value,
         language: language,
       );

  /// Returns a shallow copy of this [CalendarCategory]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarCategory copyWith({
    String? value,
    Object? language = _Undefined,
  }) {
    return CalendarCategory(
      value: value ?? this.value,
      language: language is String? ? language : this.language,
    );
  }
}
