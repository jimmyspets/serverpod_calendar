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

abstract class CalendarCategoryFilter
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarCategoryFilter._({
    required this.value,
    this.language,
  });

  factory CalendarCategoryFilter({
    required String value,
    String? language,
  }) = _CalendarCategoryFilterImpl;

  factory CalendarCategoryFilter.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarCategoryFilter(
      value: jsonSerialization['value'] as String,
      language: jsonSerialization['language'] as String?,
    );
  }

  String value;

  String? language;

  /// Returns a shallow copy of this [CalendarCategoryFilter]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarCategoryFilter copyWith({
    String? value,
    String? language,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarCategoryFilter',
      'value': value,
      if (language != null) 'language': language,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarCategoryFilter',
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

class _CalendarCategoryFilterImpl extends CalendarCategoryFilter {
  _CalendarCategoryFilterImpl({
    required String value,
    String? language,
  }) : super._(
         value: value,
         language: language,
       );

  /// Returns a shallow copy of this [CalendarCategoryFilter]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarCategoryFilter copyWith({
    String? value,
    Object? language = _Undefined,
  }) {
    return CalendarCategoryFilter(
      value: value ?? this.value,
      language: language is String? ? language : this.language,
    );
  }
}
