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
import 'calendar_event_field_group.dart' as _iftiwkuj;
import 'calendar_event_recurrence.dart' as _iqxs44bf;
import 'calendar_event_status.dart' as _ivzxk9bc;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_event_timing_overrides.dart' as _ijijze99;
import 'calendar_event_transparency.dart' as _iwjkdwy7;

abstract class CalendarEventView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarEventView._({
    required this.id,
    required this.calendarId,
    required this.revision,
    required this.disclosedGroups,
    this.summary,
    this.description,
    this.location,
    this.timing,
    this.status,
    this.transparency,
    this.protocolUid,
    this.lastModified,
    this.recurrence,
    this.timingOverrides,
  });

  factory CalendarEventView({
    required _isc.UuidValue id,
    required _isc.UuidValue calendarId,
    required int revision,
    required List<_iftiwkuj.CalendarEventFieldGroup> disclosedGroups,
    String? summary,
    String? description,
    String? location,
    _ieswiaty.CalendarEventTiming? timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    String? protocolUid,
    DateTime? lastModified,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    _ijijze99.CalendarEventTimingOverrides? timingOverrides,
  }) = _CalendarEventViewImpl;

  factory CalendarEventView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarEventView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      disclosedGroups: _ie4a1wrz.Protocol()
          .deserialize<List<_iftiwkuj.CalendarEventFieldGroup>>(
            jsonSerialization['disclosedGroups'],
          ),
      summary: jsonSerialization['summary'] as String?,
      description: jsonSerialization['description'] as String?,
      location: jsonSerialization['location'] as String?,
      timing: jsonSerialization['timing'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
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
      protocolUid: jsonSerialization['protocolUid'] as String?,
      lastModified: jsonSerialization['lastModified'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastModified'],
            ),
      recurrence: jsonSerialization['recurrence'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_iqxs44bf.CalendarEventRecurrence>(
              jsonSerialization['recurrence'],
            ),
      timingOverrides: jsonSerialization['timingOverrides'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_ijijze99.CalendarEventTimingOverrides>(
                  jsonSerialization['timingOverrides'],
                ),
    );
  }

  _isc.UuidValue id;

  _isc.UuidValue calendarId;

  int revision;

  List<_iftiwkuj.CalendarEventFieldGroup> disclosedGroups;

  String? summary;

  String? description;

  String? location;

  _ieswiaty.CalendarEventTiming? timing;

  _ivzxk9bc.CalendarEventStatus? status;

  _iwjkdwy7.CalendarEventTransparency? transparency;

  String? protocolUid;

  DateTime? lastModified;

  _iqxs44bf.CalendarEventRecurrence? recurrence;

  _ijijze99.CalendarEventTimingOverrides? timingOverrides;

  /// Returns a shallow copy of this [CalendarEventView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? calendarId,
    int? revision,
    List<_iftiwkuj.CalendarEventFieldGroup>? disclosedGroups,
    String? summary,
    String? description,
    String? location,
    _ieswiaty.CalendarEventTiming? timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    String? protocolUid,
    DateTime? lastModified,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    _ijijze99.CalendarEventTimingOverrides? timingOverrides,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventView',
      'id': id.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (timing != null) 'timing': timing?.toJson(),
      if (status != null) 'status': status?.toJson(),
      if (transparency != null) 'transparency': transparency?.toJson(),
      if (protocolUid != null) 'protocolUid': protocolUid,
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
      if (recurrence != null) 'recurrence': recurrence?.toJson(),
      if (timingOverrides != null) 'timingOverrides': timingOverrides?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventView',
      'id': id.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (timing != null) 'timing': timing?.toJsonForProtocol(),
      if (status != null) 'status': status?.toJson(),
      if (transparency != null) 'transparency': transparency?.toJson(),
      if (protocolUid != null) 'protocolUid': protocolUid,
      if (lastModified != null) 'lastModified': lastModified?.toJson(),
      if (recurrence != null) 'recurrence': recurrence?.toJsonForProtocol(),
      if (timingOverrides != null)
        'timingOverrides': timingOverrides?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventViewImpl extends CalendarEventView {
  _CalendarEventViewImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue calendarId,
    required int revision,
    required List<_iftiwkuj.CalendarEventFieldGroup> disclosedGroups,
    String? summary,
    String? description,
    String? location,
    _ieswiaty.CalendarEventTiming? timing,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    String? protocolUid,
    DateTime? lastModified,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    _ijijze99.CalendarEventTimingOverrides? timingOverrides,
  }) : super._(
         id: id,
         calendarId: calendarId,
         revision: revision,
         disclosedGroups: disclosedGroups,
         summary: summary,
         description: description,
         location: location,
         timing: timing,
         status: status,
         transparency: transparency,
         protocolUid: protocolUid,
         lastModified: lastModified,
         recurrence: recurrence,
         timingOverrides: timingOverrides,
       );

  /// Returns a shallow copy of this [CalendarEventView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? calendarId,
    int? revision,
    List<_iftiwkuj.CalendarEventFieldGroup>? disclosedGroups,
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
    Object? timing = _Undefined,
    Object? status = _Undefined,
    Object? transparency = _Undefined,
    Object? protocolUid = _Undefined,
    Object? lastModified = _Undefined,
    Object? recurrence = _Undefined,
    Object? timingOverrides = _Undefined,
  }) {
    return CalendarEventView(
      id: id ?? this.id,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      disclosedGroups:
          disclosedGroups ?? this.disclosedGroups.map((e0) => e0).toList(),
      summary: summary is String? ? summary : this.summary,
      description: description is String? ? description : this.description,
      location: location is String? ? location : this.location,
      timing: timing is _ieswiaty.CalendarEventTiming?
          ? timing
          : this.timing?.copyWith(),
      status: status is _ivzxk9bc.CalendarEventStatus? ? status : this.status,
      transparency: transparency is _iwjkdwy7.CalendarEventTransparency?
          ? transparency
          : this.transparency,
      protocolUid: protocolUid is String? ? protocolUid : this.protocolUid,
      lastModified: lastModified is DateTime?
          ? lastModified
          : this.lastModified,
      recurrence: recurrence is _iqxs44bf.CalendarEventRecurrence?
          ? recurrence
          : this.recurrence?.copyWith(),
      timingOverrides:
          timingOverrides is _ijijze99.CalendarEventTimingOverrides?
          ? timingOverrides
          : this.timingOverrides?.copyWith(),
    );
  }
}
