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

@_is.immutable
abstract class CalendarTaskSourceCategoryGroup
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskSourceCategoryGroup._({
    required this.values,
    this.language,
  });

  const factory CalendarTaskSourceCategoryGroup({
    required List<String> values,
    String? language,
  }) = _CalendarTaskSourceCategoryGroupImpl;

  factory CalendarTaskSourceCategoryGroup.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskSourceCategoryGroup(
      values: _ix00hwbf.Protocol().deserialize<List<String>>(
        jsonSerialization['values'],
      ),
      language: jsonSerialization['language'] as String?,
    );
  }

  final List<String> values;

  final String? language;

  /// Returns a shallow copy of this [CalendarTaskSourceCategoryGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskSourceCategoryGroup copyWith({
    List<String>? values,
    String? language,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskSourceCategoryGroup &&
            const _iss.DeepCollectionEquality().equals(
              other.values,
              values,
            ) &&
            (identical(
                  other.language,
                  language,
                ) ||
                other.language == language);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(values),
      language,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskSourceCategoryGroup',
      'values': values.toJson(),
      if (language != null) 'language': language,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskSourceCategoryGroupImpl
    extends CalendarTaskSourceCategoryGroup {
  const _CalendarTaskSourceCategoryGroupImpl({
    required List<String> values,
    String? language,
  }) : super._(
         values: values,
         language: language,
       );

  /// Returns a shallow copy of this [CalendarTaskSourceCategoryGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskSourceCategoryGroup copyWith({
    List<String>? values,
    Object? language = _Undefined,
  }) {
    return CalendarTaskSourceCategoryGroup(
      values: values ?? this.values.map((e0) => e0).toList(),
      language: language is String? ? language : this.language,
    );
  }
}
