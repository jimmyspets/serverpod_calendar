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
import 'calendar_event_field_group.dart' as _iftiwkuj;
import 'calendar_event_occurrence.dart' as _isyqnyev;
import 'calendar_event_time_kind.dart' as _idbnuf6y;

abstract class CalendarEventOccurrencePreview
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarEventOccurrencePreview._({
    required this.eventId,
    required this.revision,
    required this.kind,
    this.zoneId,
    required this.disclosedGroups,
    required this.occurrences,
  });

  factory CalendarEventOccurrencePreview({
    required _is.UuidValue eventId,
    required int revision,
    required _idbnuf6y.CalendarEventTimeKind kind,
    String? zoneId,
    required List<_iftiwkuj.CalendarEventFieldGroup> disclosedGroups,
    required List<_isyqnyev.CalendarEventOccurrence> occurrences,
  }) = _CalendarEventOccurrencePreviewImpl;

  factory CalendarEventOccurrencePreview.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrencePreview(
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      revision: jsonSerialization['revision'] as int,
      kind: _idbnuf6y.CalendarEventTimeKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      zoneId: jsonSerialization['zoneId'] as String?,
      disclosedGroups: _ix00hwbf.Protocol()
          .deserialize<List<_iftiwkuj.CalendarEventFieldGroup>>(
            jsonSerialization['disclosedGroups'],
          ),
      occurrences: _ix00hwbf.Protocol()
          .deserialize<List<_isyqnyev.CalendarEventOccurrence>>(
            jsonSerialization['occurrences'],
          ),
    );
  }

  _is.UuidValue eventId;

  int revision;

  _idbnuf6y.CalendarEventTimeKind kind;

  String? zoneId;

  List<_iftiwkuj.CalendarEventFieldGroup> disclosedGroups;

  List<_isyqnyev.CalendarEventOccurrence> occurrences;

  /// Returns a shallow copy of this [CalendarEventOccurrencePreview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventOccurrencePreview copyWith({
    _is.UuidValue? eventId,
    int? revision,
    _idbnuf6y.CalendarEventTimeKind? kind,
    String? zoneId,
    List<_iftiwkuj.CalendarEventFieldGroup>? disclosedGroups,
    List<_isyqnyev.CalendarEventOccurrence>? occurrences,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrencePreview',
      'eventId': eventId.toJson(),
      'revision': revision,
      'kind': kind.toJson(),
      if (zoneId != null) 'zoneId': zoneId,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
      'occurrences': occurrences.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrencePreview',
      'eventId': eventId.toJson(),
      'revision': revision,
      'kind': kind.toJson(),
      if (zoneId != null) 'zoneId': zoneId,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
      'occurrences': occurrences.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventOccurrencePreviewImpl
    extends CalendarEventOccurrencePreview {
  _CalendarEventOccurrencePreviewImpl({
    required _is.UuidValue eventId,
    required int revision,
    required _idbnuf6y.CalendarEventTimeKind kind,
    String? zoneId,
    required List<_iftiwkuj.CalendarEventFieldGroup> disclosedGroups,
    required List<_isyqnyev.CalendarEventOccurrence> occurrences,
  }) : super._(
         eventId: eventId,
         revision: revision,
         kind: kind,
         zoneId: zoneId,
         disclosedGroups: disclosedGroups,
         occurrences: occurrences,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrencePreview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventOccurrencePreview copyWith({
    _is.UuidValue? eventId,
    int? revision,
    _idbnuf6y.CalendarEventTimeKind? kind,
    Object? zoneId = _Undefined,
    List<_iftiwkuj.CalendarEventFieldGroup>? disclosedGroups,
    List<_isyqnyev.CalendarEventOccurrence>? occurrences,
  }) {
    return CalendarEventOccurrencePreview(
      eventId: eventId ?? this.eventId,
      revision: revision ?? this.revision,
      kind: kind ?? this.kind,
      zoneId: zoneId is String? ? zoneId : this.zoneId,
      disclosedGroups:
          disclosedGroups ?? this.disclosedGroups.map((e0) => e0).toList(),
      occurrences:
          occurrences ?? this.occurrences.map((e0) => e0.copyWith()).toList(),
    );
  }
}
