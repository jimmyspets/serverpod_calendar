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
import 'package:serverpod_calendar_client/src/protocol/protocol.dart'
    as _ie4a1wrz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

@_isc.immutable
abstract class CalendarItemCategoryGroup
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarItemCategoryGroup._({
    required this.values,
    this.language,
  });

  const factory CalendarItemCategoryGroup({
    required List<String> values,
    String? language,
  }) = _CalendarItemCategoryGroupImpl;

  factory CalendarItemCategoryGroup.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarItemCategoryGroup(
      values: _ie4a1wrz.Protocol().deserialize<List<String>>(
        jsonSerialization['values'],
      ),
      language: jsonSerialization['language'] as String?,
    );
  }

  final List<String> values;

  final String? language;

  /// Returns a shallow copy of this [CalendarItemCategoryGroup]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarItemCategoryGroup copyWith({
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
            other is CalendarItemCategoryGroup &&
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
      '__className__': 'serverpod_calendar.CalendarItemCategoryGroup',
      'values': values.toJson(),
      if (language != null) 'language': language,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarItemCategoryGroup',
      'values': values.toJson(),
      if (language != null) 'language': language,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarItemCategoryGroupImpl extends CalendarItemCategoryGroup {
  const _CalendarItemCategoryGroupImpl({
    required List<String> values,
    String? language,
  }) : super._(
         values: values,
         language: language,
       );

  /// Returns a shallow copy of this [CalendarItemCategoryGroup]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarItemCategoryGroup copyWith({
    List<String>? values,
    Object? language = _Undefined,
  }) {
    return CalendarItemCategoryGroup(
      values: values ?? this.values.map((e0) => e0).toList(),
      language: language is String? ? language : this.language,
    );
  }
}
