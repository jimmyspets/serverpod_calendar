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
abstract class CalendarAvailabilityOrganizer
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityOrganizer._({
    required this.address,
    this.commonName,
    this.language,
    this.directoryUri,
  });

  const factory CalendarAvailabilityOrganizer({
    required String address,
    String? commonName,
    String? language,
    String? directoryUri,
  }) = _CalendarAvailabilityOrganizerImpl;

  factory CalendarAvailabilityOrganizer.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOrganizer(
      address: jsonSerialization['address'] as String,
      commonName: jsonSerialization['commonName'] as String?,
      language: jsonSerialization['language'] as String?,
      directoryUri: jsonSerialization['directoryUri'] as String?,
    );
  }

  final String address;

  final String? commonName;

  final String? language;

  final String? directoryUri;

  /// Returns a shallow copy of this [CalendarAvailabilityOrganizer]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityOrganizer copyWith({
    String? address,
    String? commonName,
    String? language,
    String? directoryUri,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityOrganizer &&
            (identical(
                  other.address,
                  address,
                ) ||
                other.address == address) &&
            (identical(
                  other.commonName,
                  commonName,
                ) ||
                other.commonName == commonName) &&
            (identical(
                  other.language,
                  language,
                ) ||
                other.language == language) &&
            (identical(
                  other.directoryUri,
                  directoryUri,
                ) ||
                other.directoryUri == directoryUri);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      address,
      commonName,
      language,
      directoryUri,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOrganizer',
      'address': address,
      if (commonName != null) 'commonName': commonName,
      if (language != null) 'language': language,
      if (directoryUri != null) 'directoryUri': directoryUri,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOrganizer',
      'address': address,
      if (commonName != null) 'commonName': commonName,
      if (language != null) 'language': language,
      if (directoryUri != null) 'directoryUri': directoryUri,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityOrganizerImpl extends CalendarAvailabilityOrganizer {
  const _CalendarAvailabilityOrganizerImpl({
    required String address,
    String? commonName,
    String? language,
    String? directoryUri,
  }) : super._(
         address: address,
         commonName: commonName,
         language: language,
         directoryUri: directoryUri,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOrganizer]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityOrganizer copyWith({
    String? address,
    Object? commonName = _Undefined,
    Object? language = _Undefined,
    Object? directoryUri = _Undefined,
  }) {
    return CalendarAvailabilityOrganizer(
      address: address ?? this.address,
      commonName: commonName is String? ? commonName : this.commonName,
      language: language is String? ? language : this.language,
      directoryUri: directoryUri is String? ? directoryUri : this.directoryUri,
    );
  }
}
