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
import 'calendar_event_recurrence.dart' as _iqxs44bf;
import 'calendar_task_timing.dart' as _i9h8y8lg;

@_isc.immutable
abstract class CalendarTaskContent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskContent._({
    this.summary,
    this.description,
    this.location,
    this.priority,
    required this.timing,
    this.recurrence,
  });

  const factory CalendarTaskContent({
    String? summary,
    String? description,
    String? location,
    int? priority,
    required _i9h8y8lg.CalendarTaskTiming timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
  }) = _CalendarTaskContentImpl;

  factory CalendarTaskContent.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarTaskContent(
      summary: jsonSerialization['summary'] as String?,
      description: jsonSerialization['description'] as String?,
      location: jsonSerialization['location'] as String?,
      priority: jsonSerialization['priority'] as int?,
      timing: _ie4a1wrz.Protocol().deserialize<_i9h8y8lg.CalendarTaskTiming>(
        jsonSerialization['timing'],
      ),
      recurrence: jsonSerialization['recurrence'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_iqxs44bf.CalendarEventRecurrence>(
              jsonSerialization['recurrence'],
            ),
    );
  }

  final String? summary;

  final String? description;

  final String? location;

  final int? priority;

  final _i9h8y8lg.CalendarTaskTiming timing;

  final _iqxs44bf.CalendarEventRecurrence? recurrence;

  /// Returns a shallow copy of this [CalendarTaskContent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskContent copyWith({
    String? summary,
    String? description,
    String? location,
    int? priority,
    _i9h8y8lg.CalendarTaskTiming? timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskContent &&
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
                other.priority == priority) &&
            (identical(
                  other.timing,
                  timing,
                ) ||
                other.timing == timing) &&
            (identical(
                  other.recurrence,
                  recurrence,
                ) ||
                other.recurrence == recurrence);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      summary,
      description,
      location,
      priority,
      timing,
      recurrence,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskContent',
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (priority != null) 'priority': priority,
      'timing': timing.toJson(),
      if (recurrence != null) 'recurrence': recurrence?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskContent',
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (priority != null) 'priority': priority,
      'timing': timing.toJsonForProtocol(),
      if (recurrence != null) 'recurrence': recurrence?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskContentImpl extends CalendarTaskContent {
  const _CalendarTaskContentImpl({
    String? summary,
    String? description,
    String? location,
    int? priority,
    required _i9h8y8lg.CalendarTaskTiming timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
  }) : super._(
         summary: summary,
         description: description,
         location: location,
         priority: priority,
         timing: timing,
         recurrence: recurrence,
       );

  /// Returns a shallow copy of this [CalendarTaskContent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskContent copyWith({
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
    Object? priority = _Undefined,
    _i9h8y8lg.CalendarTaskTiming? timing,
    Object? recurrence = _Undefined,
  }) {
    return CalendarTaskContent(
      summary: summary is String? ? summary : this.summary,
      description: description is String? ? description : this.description,
      location: location is String? ? location : this.location,
      priority: priority is int? ? priority : this.priority,
      timing: timing ?? this.timing.copyWith(),
      recurrence: recurrence is _iqxs44bf.CalendarEventRecurrence?
          ? recurrence
          : this.recurrence?.copyWith(),
    );
  }
}
