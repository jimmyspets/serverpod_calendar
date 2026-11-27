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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

@_isc.immutable
abstract class CalendarAvailabilityText
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityText._({
    required this.value,
    this.language,
    this.alternativeUri,
  });

  const factory CalendarAvailabilityText({
    required String value,
    String? language,
    String? alternativeUri,
  }) = _CalendarAvailabilityTextImpl;

  factory CalendarAvailabilityText.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityText(
      value: jsonSerialization['value'] as String,
      language: jsonSerialization['language'] as String?,
      alternativeUri: jsonSerialization['alternativeUri'] as String?,
    );
  }

  final String value;

  final String? language;

  final String? alternativeUri;

  /// Returns a shallow copy of this [CalendarAvailabilityText]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityText copyWith({
    String? value,
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
            other is CalendarAvailabilityText &&
            (identical(
                  other.value,
                  value,
                ) ||
                other.value == value) &&
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
      value,
      language,
      alternativeUri,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityText',
      'value': value,
      if (language != null) 'language': language,
      if (alternativeUri != null) 'alternativeUri': alternativeUri,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityText',
      'value': value,
      if (language != null) 'language': language,
      if (alternativeUri != null) 'alternativeUri': alternativeUri,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityTextImpl extends CalendarAvailabilityText {
  const _CalendarAvailabilityTextImpl({
    required String value,
    String? language,
    String? alternativeUri,
  }) : super._(
         value: value,
         language: language,
         alternativeUri: alternativeUri,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityText]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityText copyWith({
    String? value,
    Object? language = _Undefined,
    Object? alternativeUri = _Undefined,
  }) {
    return CalendarAvailabilityText(
      value: value ?? this.value,
      language: language is String? ? language : this.language,
      alternativeUri: alternativeUri is String?
          ? alternativeUri
          : this.alternativeUri,
    );
  }
}
