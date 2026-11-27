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
abstract class CalendarAvailabilityExtension
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityExtension._({
    required this.name,
    required this.value,
  });

  const factory CalendarAvailabilityExtension({
    required String name,
    required String value,
  }) = _CalendarAvailabilityExtensionImpl;

  factory CalendarAvailabilityExtension.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityExtension(
      name: jsonSerialization['name'] as String,
      value: jsonSerialization['value'] as String,
    );
  }

  final String name;

  final String value;

  /// Returns a shallow copy of this [CalendarAvailabilityExtension]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityExtension copyWith({
    String? name,
    String? value,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityExtension &&
            (identical(
                  other.name,
                  name,
                ) ||
                other.name == name) &&
            (identical(
                  other.value,
                  value,
                ) ||
                other.value == value);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      name,
      value,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityExtension',
      'name': name,
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityExtension',
      'name': name,
      'value': value,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityExtensionImpl extends CalendarAvailabilityExtension {
  const _CalendarAvailabilityExtensionImpl({
    required String name,
    required String value,
  }) : super._(
         name: name,
         value: value,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityExtension]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityExtension copyWith({
    String? name,
    String? value,
  }) {
    return CalendarAvailabilityExtension(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }
}
