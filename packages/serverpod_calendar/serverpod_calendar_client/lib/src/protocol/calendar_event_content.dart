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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_event_recurrence.dart' as _iqxs44bf;
import 'calendar_event_status.dart' as _ivzxk9bc;
import 'calendar_event_text_parameters.dart' as _isfojy12;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_event_transparency.dart' as _iwjkdwy7;

@_isc.immutable
abstract class CalendarEventContent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventContent._({
    this.summary,
    this.description,
    this.location,
    required this.timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    this.recurrence,
    this.periods,
    this.textParameters,
  }) : status = status ?? _ivzxk9bc.CalendarEventStatus.confirmed,
       transparency =
           transparency ?? _iwjkdwy7.CalendarEventTransparency.opaque;

  const factory CalendarEventContent({
    String? summary,
    String? description,
    String? location,
    required _ieswiaty.CalendarEventTiming timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    List<_ieswiaty.CalendarEventTiming>? periods,
    _isfojy12.CalendarEventTextParameters? textParameters,
  }) = _CalendarEventContentImpl;

  factory CalendarEventContent.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventContent(
      summary: jsonSerialization['summary'] as String?,
      description: jsonSerialization['description'] as String?,
      location: jsonSerialization['location'] as String?,
      timing: _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
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
      recurrence: jsonSerialization['recurrence'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_iqxs44bf.CalendarEventRecurrence>(
              jsonSerialization['recurrence'],
            ),
      periods: jsonSerialization['periods'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<List<_ieswiaty.CalendarEventTiming>>(
                  jsonSerialization['periods'],
                ),
      textParameters: jsonSerialization['textParameters'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_isfojy12.CalendarEventTextParameters>(
                  jsonSerialization['textParameters'],
                ),
    );
  }

  final String? summary;

  final String? description;

  final String? location;

  final _ieswiaty.CalendarEventTiming timing;

  final _ivzxk9bc.CalendarEventStatus status;

  final _iwjkdwy7.CalendarEventTransparency transparency;

  final _iqxs44bf.CalendarEventRecurrence? recurrence;

  final List<_ieswiaty.CalendarEventTiming>? periods;

  final _isfojy12.CalendarEventTextParameters? textParameters;

  /// Returns a shallow copy of this [CalendarEventContent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventContent copyWith({
    String? summary,
    String? description,
    String? location,
    _ieswiaty.CalendarEventTiming? timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    List<_ieswiaty.CalendarEventTiming>? periods,
    _isfojy12.CalendarEventTextParameters? textParameters,
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
                  other.recurrence,
                  recurrence,
                ) ||
                other.recurrence == recurrence) &&
            const _iss.DeepCollectionEquality().equals(
              other.periods,
              periods,
            ) &&
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
      timing,
      status,
      transparency,
      recurrence,
      const _iss.DeepCollectionEquality().hash(periods),
      textParameters,
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
      if (recurrence != null) 'recurrence': recurrence?.toJson(),
      if (periods != null)
        'periods': periods?.toJson(valueToJson: (v) => v.toJson()),
      if (textParameters != null) 'textParameters': textParameters?.toJson(),
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
      if (recurrence != null) 'recurrence': recurrence?.toJsonForProtocol(),
      if (periods != null)
        'periods': periods?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (textParameters != null)
        'textParameters': textParameters?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    List<_ieswiaty.CalendarEventTiming>? periods,
    _isfojy12.CalendarEventTextParameters? textParameters,
  }) : super._(
         summary: summary,
         description: description,
         location: location,
         timing: timing,
         status: status,
         transparency: transparency,
         recurrence: recurrence,
         periods: periods,
         textParameters: textParameters,
       );

  /// Returns a shallow copy of this [CalendarEventContent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventContent copyWith({
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
    _ieswiaty.CalendarEventTiming? timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    Object? recurrence = _Undefined,
    Object? periods = _Undefined,
    Object? textParameters = _Undefined,
  }) {
    return CalendarEventContent(
      summary: summary is String? ? summary : this.summary,
      description: description is String? ? description : this.description,
      location: location is String? ? location : this.location,
      timing: timing ?? this.timing.copyWith(),
      status: status ?? this.status,
      transparency: transparency ?? this.transparency,
      recurrence: recurrence is _iqxs44bf.CalendarEventRecurrence?
          ? recurrence
          : this.recurrence?.copyWith(),
      periods: periods is List<_ieswiaty.CalendarEventTiming>?
          ? periods
          : this.periods?.map((e0) => e0.copyWith()).toList(),
      textParameters: textParameters is _isfojy12.CalendarEventTextParameters?
          ? textParameters
          : this.textParameters?.copyWith(),
    );
  }
}
