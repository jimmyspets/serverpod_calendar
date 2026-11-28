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

@_isc.immutable
abstract class CalendarEventOccurrenceListQuery
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventOccurrenceListQuery._({
    required this.calendarId,
    required this.fromUtc,
    required this.untilUtc,
    int? pageSize,
    bool? includeCancelled,
    required this.fieldGroups,
    this.cursor,
  }) : pageSize = pageSize ?? 50,
       includeCancelled = includeCancelled ?? true;

  const factory CalendarEventOccurrenceListQuery({
    required _isc.UuidValue calendarId,
    required DateTime fromUtc,
    required DateTime untilUtc,
    int? pageSize,
    bool? includeCancelled,
    required List<_iftiwkuj.CalendarEventFieldGroup> fieldGroups,
    String? cursor,
  }) = _CalendarEventOccurrenceListQueryImpl;

  factory CalendarEventOccurrenceListQuery.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrenceListQuery(
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      fromUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['fromUtc'],
      ),
      untilUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['untilUtc'],
      ),
      pageSize: jsonSerialization['pageSize'] as int?,
      includeCancelled: jsonSerialization['includeCancelled'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['includeCancelled'],
            ),
      fieldGroups: _ie4a1wrz.Protocol()
          .deserialize<List<_iftiwkuj.CalendarEventFieldGroup>>(
            jsonSerialization['fieldGroups'],
          ),
      cursor: jsonSerialization['cursor'] as String?,
    );
  }

  final _isc.UuidValue calendarId;

  final DateTime fromUtc;

  final DateTime untilUtc;

  final int pageSize;

  final bool includeCancelled;

  final List<_iftiwkuj.CalendarEventFieldGroup> fieldGroups;

  final String? cursor;

  /// Returns a shallow copy of this [CalendarEventOccurrenceListQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventOccurrenceListQuery copyWith({
    _isc.UuidValue? calendarId,
    DateTime? fromUtc,
    DateTime? untilUtc,
    int? pageSize,
    bool? includeCancelled,
    List<_iftiwkuj.CalendarEventFieldGroup>? fieldGroups,
    String? cursor,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOccurrenceListQuery &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.fromUtc,
                  fromUtc,
                ) ||
                other.fromUtc == fromUtc) &&
            (identical(
                  other.untilUtc,
                  untilUtc,
                ) ||
                other.untilUtc == untilUtc) &&
            (identical(
                  other.pageSize,
                  pageSize,
                ) ||
                other.pageSize == pageSize) &&
            (identical(
                  other.includeCancelled,
                  includeCancelled,
                ) ||
                other.includeCancelled == includeCancelled) &&
            const _iss.DeepCollectionEquality().equals(
              other.fieldGroups,
              fieldGroups,
            ) &&
            (identical(
                  other.cursor,
                  cursor,
                ) ||
                other.cursor == cursor);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      calendarId,
      fromUtc,
      untilUtc,
      pageSize,
      includeCancelled,
      const _iss.DeepCollectionEquality().hash(fieldGroups),
      cursor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceListQuery',
      'calendarId': calendarId.toJson(),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'pageSize': pageSize,
      'includeCancelled': includeCancelled,
      'fieldGroups': fieldGroups.toJson(valueToJson: (v) => v.toJson()),
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceListQuery',
      'calendarId': calendarId.toJson(),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'pageSize': pageSize,
      'includeCancelled': includeCancelled,
      'fieldGroups': fieldGroups.toJson(valueToJson: (v) => v.toJson()),
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventOccurrenceListQueryImpl
    extends CalendarEventOccurrenceListQuery {
  const _CalendarEventOccurrenceListQueryImpl({
    required _isc.UuidValue calendarId,
    required DateTime fromUtc,
    required DateTime untilUtc,
    int? pageSize,
    bool? includeCancelled,
    required List<_iftiwkuj.CalendarEventFieldGroup> fieldGroups,
    String? cursor,
  }) : super._(
         calendarId: calendarId,
         fromUtc: fromUtc,
         untilUtc: untilUtc,
         pageSize: pageSize,
         includeCancelled: includeCancelled,
         fieldGroups: fieldGroups,
         cursor: cursor,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrenceListQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventOccurrenceListQuery copyWith({
    _isc.UuidValue? calendarId,
    DateTime? fromUtc,
    DateTime? untilUtc,
    int? pageSize,
    bool? includeCancelled,
    List<_iftiwkuj.CalendarEventFieldGroup>? fieldGroups,
    Object? cursor = _Undefined,
  }) {
    return CalendarEventOccurrenceListQuery(
      calendarId: calendarId ?? this.calendarId,
      fromUtc: fromUtc ?? this.fromUtc,
      untilUtc: untilUtc ?? this.untilUtc,
      pageSize: pageSize ?? this.pageSize,
      includeCancelled: includeCancelled ?? this.includeCancelled,
      fieldGroups: fieldGroups ?? this.fieldGroups.map((e0) => e0).toList(),
      cursor: cursor is String? ? cursor : this.cursor,
    );
  }
}
