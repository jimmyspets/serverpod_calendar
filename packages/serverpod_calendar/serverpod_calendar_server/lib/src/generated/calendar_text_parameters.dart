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

@_is.immutable
abstract class CalendarTextParameters
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTextParameters._({
    this.language,
    this.alternativeUri,
  });

  const factory CalendarTextParameters({
    String? language,
    String? alternativeUri,
  }) = _CalendarTextParametersImpl;

  factory CalendarTextParameters.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTextParameters(
      language: jsonSerialization['language'] as String?,
      alternativeUri: jsonSerialization['alternativeUri'] as String?,
    );
  }

  final String? language;

  final String? alternativeUri;

  /// Returns a shallow copy of this [CalendarTextParameters]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTextParameters copyWith({
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
            other is CalendarTextParameters &&
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
      language,
      alternativeUri,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTextParameters',
      if (language != null) 'language': language,
      if (alternativeUri != null) 'alternativeUri': alternativeUri,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTextParameters',
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

class _CalendarTextParametersImpl extends CalendarTextParameters {
  const _CalendarTextParametersImpl({
    String? language,
    String? alternativeUri,
  }) : super._(
         language: language,
         alternativeUri: alternativeUri,
       );

  /// Returns a shallow copy of this [CalendarTextParameters]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTextParameters copyWith({
    Object? language = _Undefined,
    Object? alternativeUri = _Undefined,
  }) {
    return CalendarTextParameters(
      language: language is String? ? language : this.language,
      alternativeUri: alternativeUri is String?
          ? alternativeUri
          : this.alternativeUri,
    );
  }
}
