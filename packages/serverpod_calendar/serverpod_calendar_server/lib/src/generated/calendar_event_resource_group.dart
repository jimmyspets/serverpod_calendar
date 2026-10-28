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
abstract class CalendarEventResourceGroup
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventResourceGroup._({
    required this.values,
    this.language,
    this.alternativeUri,
  });

  const factory CalendarEventResourceGroup({
    required List<String> values,
    String? language,
    String? alternativeUri,
  }) = _CalendarEventResourceGroupImpl;

  factory CalendarEventResourceGroup.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventResourceGroup(
      values: _ix00hwbf.Protocol().deserialize<List<String>>(
        jsonSerialization['values'],
      ),
      language: jsonSerialization['language'] as String?,
      alternativeUri: jsonSerialization['alternativeUri'] as String?,
    );
  }

  final List<String> values;

  final String? language;

  final String? alternativeUri;

  /// Returns a shallow copy of this [CalendarEventResourceGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventResourceGroup copyWith({
    List<String>? values,
    String? language,
    String? alternativeUri,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventResourceGroup &&
            const _iss.DeepCollectionEquality().equals(
              other.values,
              values,
            ) &&
            (identical(
                  other.language,
                  language,
                ) ||
                other.language == language) &&
            (identical(
                  other.alternativeUri,
                  alternativeUri,
                ) ||
                other.alternativeUri == alternativeUri);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(values),
      language,
      alternativeUri,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventResourceGroup',
      'values': values.toJson(),
      if (language != null) 'language': language,
      if (alternativeUri != null) 'alternativeUri': alternativeUri,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventResourceGroup',
      'values': values.toJson(),
      if (language != null) 'language': language,
      if (alternativeUri != null) 'alternativeUri': alternativeUri,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventResourceGroupImpl extends CalendarEventResourceGroup {
  const _CalendarEventResourceGroupImpl({
    required List<String> values,
    String? language,
    String? alternativeUri,
  }) : super._(
         values: values,
         language: language,
         alternativeUri: alternativeUri,
       );

  /// Returns a shallow copy of this [CalendarEventResourceGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventResourceGroup copyWith({
    List<String>? values,
    Object? language = _Undefined,
    Object? alternativeUri = _Undefined,
  }) {
    return CalendarEventResourceGroup(
      values: values ?? this.values.map((e0) => e0).toList(),
      language: language is String? ? language : this.language,
      alternativeUri: alternativeUri is String?
          ? alternativeUri
          : this.alternativeUri,
    );
  }
}
