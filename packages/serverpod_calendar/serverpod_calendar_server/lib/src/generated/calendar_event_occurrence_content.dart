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
import 'calendar_event_text_parameters.dart' as _isfojy12;

@_is.immutable
abstract class CalendarEventOccurrenceContent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventOccurrenceContent._({
    this.summary,
    this.description,
    this.location,
    this.textParameters,
  });

  const factory CalendarEventOccurrenceContent({
    String? summary,
    String? description,
    String? location,
    _isfojy12.CalendarEventTextParameters? textParameters,
  }) = _CalendarEventOccurrenceContentImpl;

  factory CalendarEventOccurrenceContent.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrenceContent(
      summary: jsonSerialization['summary'] as String?,
      description: jsonSerialization['description'] as String?,
      location: jsonSerialization['location'] as String?,
      textParameters: jsonSerialization['textParameters'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_isfojy12.CalendarEventTextParameters>(
                  jsonSerialization['textParameters'],
                ),
    );
  }

  final String? summary;

  final String? description;

  final String? location;

  final _isfojy12.CalendarEventTextParameters? textParameters;

  /// Returns a shallow copy of this [CalendarEventOccurrenceContent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventOccurrenceContent copyWith({
    String? summary,
    String? description,
    String? location,
    _isfojy12.CalendarEventTextParameters? textParameters,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOccurrenceContent &&
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
                other.location == location) &&
            (identical(
                  other.textParameters,
                  textParameters,
                ) ||
                other.textParameters == textParameters);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      summary,
      description,
      location,
      textParameters,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceContent',
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (textParameters != null) 'textParameters': textParameters?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceContent',
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (textParameters != null)
        'textParameters': textParameters?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventOccurrenceContentImpl
    extends CalendarEventOccurrenceContent {
  const _CalendarEventOccurrenceContentImpl({
    String? summary,
    String? description,
    String? location,
    _isfojy12.CalendarEventTextParameters? textParameters,
  }) : super._(
         summary: summary,
         description: description,
         location: location,
         textParameters: textParameters,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrenceContent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventOccurrenceContent copyWith({
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
    Object? textParameters = _Undefined,
  }) {
    return CalendarEventOccurrenceContent(
      summary: summary is String? ? summary : this.summary,
      description: description is String? ? description : this.description,
      location: location is String? ? location : this.location,
      textParameters: textParameters is _isfojy12.CalendarEventTextParameters?
          ? textParameters
          : this.textParameters?.copyWith(),
    );
  }
}
