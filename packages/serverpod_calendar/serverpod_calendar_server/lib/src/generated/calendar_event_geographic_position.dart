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
abstract class CalendarEventGeographicPosition
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventGeographicPosition._({
    required this.latitudeText,
    required this.longitudeText,
  });

  const factory CalendarEventGeographicPosition({
    required String latitudeText,
    required String longitudeText,
  }) = _CalendarEventGeographicPositionImpl;

  factory CalendarEventGeographicPosition.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventGeographicPosition(
      latitudeText: jsonSerialization['latitudeText'] as String,
      longitudeText: jsonSerialization['longitudeText'] as String,
    );
  }

  final String latitudeText;

  final String longitudeText;

  /// Returns a shallow copy of this [CalendarEventGeographicPosition]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventGeographicPosition copyWith({
    String? latitudeText,
    String? longitudeText,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventGeographicPosition &&
            (identical(
                  other.latitudeText,
                  latitudeText,
                ) ||
                other.latitudeText == latitudeText) &&
            (identical(
                  other.longitudeText,
                  longitudeText,
                ) ||
                other.longitudeText == longitudeText);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      latitudeText,
      longitudeText,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventGeographicPosition',
      'latitudeText': latitudeText,
      'longitudeText': longitudeText,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventGeographicPosition',
      'latitudeText': latitudeText,
      'longitudeText': longitudeText,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarEventGeographicPositionImpl
    extends CalendarEventGeographicPosition {
  const _CalendarEventGeographicPositionImpl({
    required String latitudeText,
    required String longitudeText,
  }) : super._(
         latitudeText: latitudeText,
         longitudeText: longitudeText,
       );

  /// Returns a shallow copy of this [CalendarEventGeographicPosition]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventGeographicPosition copyWith({
    String? latitudeText,
    String? longitudeText,
  }) {
    return CalendarEventGeographicPosition(
      latitudeText: latitudeText ?? this.latitudeText,
      longitudeText: longitudeText ?? this.longitudeText,
    );
  }
}
