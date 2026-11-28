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
abstract class CalendarTaskOccurrenceContent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskOccurrenceContent._({
    this.summary,
    this.description,
    this.location,
    this.priority,
  });

  const factory CalendarTaskOccurrenceContent({
    String? summary,
    String? description,
    String? location,
    int? priority,
  }) = _CalendarTaskOccurrenceContentImpl;

  factory CalendarTaskOccurrenceContent.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskOccurrenceContent(
      summary: jsonSerialization['summary'] as String?,
      description: jsonSerialization['description'] as String?,
      location: jsonSerialization['location'] as String?,
      priority: jsonSerialization['priority'] as int?,
    );
  }

  final String? summary;

  final String? description;

  final String? location;

  final int? priority;

  /// Returns a shallow copy of this [CalendarTaskOccurrenceContent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskOccurrenceContent copyWith({
    String? summary,
    String? description,
    String? location,
    int? priority,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskOccurrenceContent &&
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
                  other.priority,
                  priority,
                ) ||
                other.priority == priority);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      summary,
      description,
      location,
      priority,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrenceContent',
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (priority != null) 'priority': priority,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrenceContent',
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (priority != null) 'priority': priority,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskOccurrenceContentImpl extends CalendarTaskOccurrenceContent {
  const _CalendarTaskOccurrenceContentImpl({
    String? summary,
    String? description,
    String? location,
    int? priority,
  }) : super._(
         summary: summary,
         description: description,
         location: location,
         priority: priority,
       );

  /// Returns a shallow copy of this [CalendarTaskOccurrenceContent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskOccurrenceContent copyWith({
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
    Object? priority = _Undefined,
  }) {
    return CalendarTaskOccurrenceContent(
      summary: summary is String? ? summary : this.summary,
      description: description is String? ? description : this.description,
      location: location is String? ? location : this.location,
      priority: priority is int? ? priority : this.priority,
    );
  }
}
