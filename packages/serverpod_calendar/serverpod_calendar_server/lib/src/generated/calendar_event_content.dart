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
import 'calendar_event_status.dart' as _ivzxk9bc;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_event_transparency.dart' as _iwjkdwy7;

@_is.immutable
abstract class CalendarEventContent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventContent._({
    this.summary,
    this.description,
    this.location,
    required this.timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    bool? recurring,
  }) : status = status ?? _ivzxk9bc.CalendarEventStatus.confirmed,
       transparency =
           transparency ?? _iwjkdwy7.CalendarEventTransparency.opaque,
       recurring = recurring ?? false;

  const factory CalendarEventContent({
    String? summary,
    String? description,
    String? location,
    required _ieswiaty.CalendarEventTiming timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    bool? recurring,
  }) = _CalendarEventContentImpl;

  factory CalendarEventContent.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventContent(
      summary: jsonSerialization['summary'] as String?,
      description: jsonSerialization['description'] as String?,
      location: jsonSerialization['location'] as String?,
      timing: _ix00hwbf.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
        jsonSerialization['timing'],
      ),
      status: jsonSerialization['status'] == null
          ? null
          : _ivzxk9bc.CalendarEventStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      transparency: jsonSerialization['transparency'] == null
          ? null
          : _iwjkdwy7.CalendarEventTransparency.fromJson(
              (jsonSerialization['transparency'] as String),
            ),
      recurring: jsonSerialization['recurring'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['recurring']),
    );
  }

  final String? summary;

  final String? description;

  final String? location;

  final _ieswiaty.CalendarEventTiming timing;

  final _ivzxk9bc.CalendarEventStatus status;

  final _iwjkdwy7.CalendarEventTransparency transparency;

  final bool recurring;

  /// Returns a shallow copy of this [CalendarEventContent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventContent copyWith({
    String? summary,
    String? description,
    String? location,
    _ieswiaty.CalendarEventTiming? timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    bool? recurring,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventContent &&
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
                  other.timing,
                  timing,
                ) ||
                other.timing == timing) &&
            (identical(
                  other.status,
                  status,
                ) ||
                other.status == status) &&
            (identical(
                  other.transparency,
                  transparency,
                ) ||
                other.transparency == transparency) &&
            (identical(
                  other.recurring,
                  recurring,
                ) ||
                other.recurring == recurring);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      summary,
      description,
      location,
      timing,
      status,
      transparency,
      recurring,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventContent',
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      'timing': timing.toJson(),
      'status': status.toJson(),
      'transparency': transparency.toJson(),
      'recurring': recurring,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventContent',
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      'timing': timing.toJsonForProtocol(),
      'status': status.toJson(),
      'transparency': transparency.toJson(),
      'recurring': recurring,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventContentImpl extends CalendarEventContent {
  const _CalendarEventContentImpl({
    String? summary,
    String? description,
    String? location,
    required _ieswiaty.CalendarEventTiming timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    bool? recurring,
  }) : super._(
         summary: summary,
         description: description,
         location: location,
         timing: timing,
         status: status,
         transparency: transparency,
         recurring: recurring,
       );

  /// Returns a shallow copy of this [CalendarEventContent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventContent copyWith({
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
    _ieswiaty.CalendarEventTiming? timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    bool? recurring,
  }) {
    return CalendarEventContent(
      summary: summary is String? ? summary : this.summary,
      description: description is String? ? description : this.description,
      location: location is String? ? location : this.location,
      timing: timing ?? this.timing.copyWith(),
      status: status ?? this.status,
      transparency: transparency ?? this.transparency,
      recurring: recurring ?? this.recurring,
    );
  }
}
