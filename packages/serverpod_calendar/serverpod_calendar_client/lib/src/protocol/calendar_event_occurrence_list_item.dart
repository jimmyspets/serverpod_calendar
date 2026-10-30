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
import 'calendar_event_field_group.dart' as _iftiwkuj;
import 'calendar_event_occurrence.dart' as _isyqnyev;
import 'calendar_event_status.dart' as _ivzxk9bc;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_event_transparency.dart' as _iwjkdwy7;

@_isc.immutable
abstract class CalendarEventOccurrenceListItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventOccurrenceListItem._({
    required this.eventId,
    required this.calendarId,
    required this.revision,
    required this.originalStart,
    required this.occurrence,
    required this.status,
    required this.transparency,
    required this.cancelled,
    required this.disclosedGroups,
  });

  const factory CalendarEventOccurrenceListItem({
    required _isc.UuidValue eventId,
    required _isc.UuidValue calendarId,
    required int revision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _isyqnyev.CalendarEventOccurrence occurrence,
    required _ivzxk9bc.CalendarEventStatus status,
    required _iwjkdwy7.CalendarEventTransparency transparency,
    required bool cancelled,
    required List<_iftiwkuj.CalendarEventFieldGroup> disclosedGroups,
  }) = _CalendarEventOccurrenceListItemImpl;

  factory CalendarEventOccurrenceListItem.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrenceListItem(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      occurrence: _ie4a1wrz.Protocol()
          .deserialize<_isyqnyev.CalendarEventOccurrence>(
            jsonSerialization['occurrence'],
          ),
      status: _ivzxk9bc.CalendarEventStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      transparency: _iwjkdwy7.CalendarEventTransparency.fromJson(
        (jsonSerialization['transparency'] as String),
      ),
      cancelled: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['cancelled'],
      ),
      disclosedGroups: _ie4a1wrz.Protocol()
          .deserialize<List<_iftiwkuj.CalendarEventFieldGroup>>(
            jsonSerialization['disclosedGroups'],
          ),
    );
  }

  final _isc.UuidValue eventId;

  final _isc.UuidValue calendarId;

  final int revision;

  final _ieswiaty.CalendarEventTiming originalStart;

  final _isyqnyev.CalendarEventOccurrence occurrence;

  final _ivzxk9bc.CalendarEventStatus status;

  final _iwjkdwy7.CalendarEventTransparency transparency;

  final bool cancelled;

  final List<_iftiwkuj.CalendarEventFieldGroup> disclosedGroups;

  /// Returns a shallow copy of this [CalendarEventOccurrenceListItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventOccurrenceListItem copyWith({
    _isc.UuidValue? eventId,
    _isc.UuidValue? calendarId,
    int? revision,
    _ieswiaty.CalendarEventTiming? originalStart,
    _isyqnyev.CalendarEventOccurrence? occurrence,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    bool? cancelled,
    List<_iftiwkuj.CalendarEventFieldGroup>? disclosedGroups,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOccurrenceListItem &&
            (identical(
                  other.eventId,
                  eventId,
                ) ||
                other.eventId == eventId) &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.occurrence,
                  occurrence,
                ) ||
                other.occurrence == occurrence) &&
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
                  other.cancelled,
                  cancelled,
                ) ||
                other.cancelled == cancelled) &&
            const _iss.DeepCollectionEquality().equals(
              other.disclosedGroups,
              disclosedGroups,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      calendarId,
      revision,
      originalStart,
      occurrence,
      status,
      transparency,
      cancelled,
      const _iss.DeepCollectionEquality().hash(disclosedGroups),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceListItem',
      'eventId': eventId.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'originalStart': originalStart.toJson(),
      'occurrence': occurrence.toJson(),
      'status': status.toJson(),
      'transparency': transparency.toJson(),
      'cancelled': cancelled,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceListItem',
      'eventId': eventId.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'originalStart': originalStart.toJsonForProtocol(),
      'occurrence': occurrence.toJsonForProtocol(),
      'status': status.toJson(),
      'transparency': transparency.toJson(),
      'cancelled': cancelled,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarEventOccurrenceListItemImpl
    extends CalendarEventOccurrenceListItem {
  const _CalendarEventOccurrenceListItemImpl({
    required _isc.UuidValue eventId,
    required _isc.UuidValue calendarId,
    required int revision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _isyqnyev.CalendarEventOccurrence occurrence,
    required _ivzxk9bc.CalendarEventStatus status,
    required _iwjkdwy7.CalendarEventTransparency transparency,
    required bool cancelled,
    required List<_iftiwkuj.CalendarEventFieldGroup> disclosedGroups,
  }) : super._(
         eventId: eventId,
         calendarId: calendarId,
         revision: revision,
         originalStart: originalStart,
         occurrence: occurrence,
         status: status,
         transparency: transparency,
         cancelled: cancelled,
         disclosedGroups: disclosedGroups,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrenceListItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventOccurrenceListItem copyWith({
    _isc.UuidValue? eventId,
    _isc.UuidValue? calendarId,
    int? revision,
    _ieswiaty.CalendarEventTiming? originalStart,
    _isyqnyev.CalendarEventOccurrence? occurrence,
    _ivzxk9bc.CalendarEventStatus? status,
    _iwjkdwy7.CalendarEventTransparency? transparency,
    bool? cancelled,
    List<_iftiwkuj.CalendarEventFieldGroup>? disclosedGroups,
  }) {
    return CalendarEventOccurrenceListItem(
      eventId: eventId ?? this.eventId,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      occurrence: occurrence ?? this.occurrence.copyWith(),
      status: status ?? this.status,
      transparency: transparency ?? this.transparency,
      cancelled: cancelled ?? this.cancelled,
      disclosedGroups:
          disclosedGroups ?? this.disclosedGroups.map((e0) => e0).toList(),
    );
  }
}
