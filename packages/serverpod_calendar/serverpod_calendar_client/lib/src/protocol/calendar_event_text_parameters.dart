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
import 'calendar_text_parameters.dart' as _iffxqqc7;

@_isc.immutable
abstract class CalendarEventTextParameters
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventTextParameters._({
    this.summary,
    this.description,
    this.location,
  });

  const factory CalendarEventTextParameters({
    _iffxqqc7.CalendarTextParameters? summary,
    _iffxqqc7.CalendarTextParameters? description,
    _iffxqqc7.CalendarTextParameters? location,
  }) = _CalendarEventTextParametersImpl;

  factory CalendarEventTextParameters.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventTextParameters(
      summary: jsonSerialization['summary'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_iffxqqc7.CalendarTextParameters>(
              jsonSerialization['summary'],
            ),
      description: jsonSerialization['description'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_iffxqqc7.CalendarTextParameters>(
              jsonSerialization['description'],
            ),
      location: jsonSerialization['location'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_iffxqqc7.CalendarTextParameters>(
              jsonSerialization['location'],
            ),
    );
  }

  final _iffxqqc7.CalendarTextParameters? summary;

  final _iffxqqc7.CalendarTextParameters? description;

  final _iffxqqc7.CalendarTextParameters? location;

  /// Returns a shallow copy of this [CalendarEventTextParameters]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventTextParameters copyWith({
    _iffxqqc7.CalendarTextParameters? summary,
    _iffxqqc7.CalendarTextParameters? description,
    _iffxqqc7.CalendarTextParameters? location,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventTextParameters &&
            (identical(
                  other.summary,
                  summary,
                ) ||
                other.summary == summary) &&
            (identical(
                  other.description,
                  description,
                ) ||
                other.description == description) &&
            (identical(
                  other.location,
                  location,
                ) ||
                other.location == location);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      summary,
      description,
      location,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventTextParameters',
      if (summary != null) 'summary': summary?.toJson(),
      if (description != null) 'description': description?.toJson(),
      if (location != null) 'location': location?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventTextParameters',
      if (summary != null) 'summary': summary?.toJsonForProtocol(),
      if (description != null) 'description': description?.toJsonForProtocol(),
      if (location != null) 'location': location?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventTextParametersImpl extends CalendarEventTextParameters {
  const _CalendarEventTextParametersImpl({
    _iffxqqc7.CalendarTextParameters? summary,
    _iffxqqc7.CalendarTextParameters? description,
    _iffxqqc7.CalendarTextParameters? location,
  }) : super._(
         summary: summary,
         description: description,
         location: location,
       );

  /// Returns a shallow copy of this [CalendarEventTextParameters]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventTextParameters copyWith({
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
  }) {
    return CalendarEventTextParameters(
      summary: summary is _iffxqqc7.CalendarTextParameters?
          ? summary
          : this.summary?.copyWith(),
      description: description is _iffxqqc7.CalendarTextParameters?
          ? description
          : this.description?.copyWith(),
      location: location is _iffxqqc7.CalendarTextParameters?
          ? location
          : this.location?.copyWith(),
    );
  }
}
