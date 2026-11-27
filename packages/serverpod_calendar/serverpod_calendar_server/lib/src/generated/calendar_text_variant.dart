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

abstract class CalendarTextVariant
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarTextVariant._({
    required this.value,
    this.language,
  });

  factory CalendarTextVariant({
    required String value,
    String? language,
  }) = _CalendarTextVariantImpl;

  factory CalendarTextVariant.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarTextVariant(
      value: jsonSerialization['value'] as String,
      language: jsonSerialization['language'] as String?,
    );
  }

  String value;

  String? language;

  /// Returns a shallow copy of this [CalendarTextVariant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTextVariant copyWith({
    String? value,
    String? language,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTextVariant',
      'value': value,
      if (language != null) 'language': language,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTextVariant',
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

class _CalendarTextVariantImpl extends CalendarTextVariant {
  _CalendarTextVariantImpl({
    required String value,
    String? language,
  }) : super._(
         value: value,
         language: language,
       );

  /// Returns a shallow copy of this [CalendarTextVariant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTextVariant copyWith({
    String? value,
    Object? language = _Undefined,
  }) {
    return CalendarTextVariant(
      value: value ?? this.value,
      language: language is String? ? language : this.language,
    );
  }
}
