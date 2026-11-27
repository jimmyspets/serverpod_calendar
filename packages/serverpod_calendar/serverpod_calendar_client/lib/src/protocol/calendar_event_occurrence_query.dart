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
import 'calendar_event_civil.dart' as _i1bb5k1r;

@_isc.immutable
abstract class CalendarEventOccurrenceQuery
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventOccurrenceQuery._({
    required this.eventId,
    required this.expectedRevision,
    this.fromDate,
    this.untilDate,
    this.fromUtc,
    this.untilUtc,
  });

  const factory CalendarEventOccurrenceQuery({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    _i1bb5k1r.CalendarEventCivil? fromDate,
    _i1bb5k1r.CalendarEventCivil? untilDate,
    DateTime? fromUtc,
    DateTime? untilUtc,
  }) = _CalendarEventOccurrenceQueryImpl;

  factory CalendarEventOccurrenceQuery.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrenceQuery(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      fromDate: jsonSerialization['fromDate'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['fromDate'],
            ),
      untilDate: jsonSerialization['untilDate'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['untilDate'],
            ),
      fromUtc: jsonSerialization['fromUtc'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['fromUtc']),
      untilUtc: jsonSerialization['untilUtc'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['untilUtc']),
    );
  }

  final _isc.UuidValue eventId;

  final int expectedRevision;

  final _i1bb5k1r.CalendarEventCivil? fromDate;

  final _i1bb5k1r.CalendarEventCivil? untilDate;

  final DateTime? fromUtc;

  final DateTime? untilUtc;

  /// Returns a shallow copy of this [CalendarEventOccurrenceQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventOccurrenceQuery copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    _i1bb5k1r.CalendarEventCivil? fromDate,
    _i1bb5k1r.CalendarEventCivil? untilDate,
    DateTime? fromUtc,
    DateTime? untilUtc,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOccurrenceQuery &&
            (identical(
                  other.eventId,
                  eventId,
                ) ||
                other.eventId == eventId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
            (identical(
                  other.fromDate,
                  fromDate,
                ) ||
                other.fromDate == fromDate) &&
            (identical(
                  other.untilDate,
                  untilDate,
                ) ||
                other.untilDate == untilDate) &&
            (identical(
                  other.fromUtc,
                  fromUtc,
                ) ||
                other.fromUtc == fromUtc) &&
            (identical(
                  other.untilUtc,
                  untilUtc,
                ) ||
                other.untilUtc == untilUtc);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      expectedRevision,
      fromDate,
      untilDate,
      fromUtc,
      untilUtc,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceQuery',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      if (fromDate != null) 'fromDate': fromDate?.toJson(),
      if (untilDate != null) 'untilDate': untilDate?.toJson(),
      if (fromUtc != null) 'fromUtc': fromUtc?.toJson(),
      if (untilUtc != null) 'untilUtc': untilUtc?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceQuery',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
      if (fromDate != null) 'fromDate': fromDate?.toJsonForProtocol(),
      if (untilDate != null) 'untilDate': untilDate?.toJsonForProtocol(),
      if (fromUtc != null) 'fromUtc': fromUtc?.toJson(),
      if (untilUtc != null) 'untilUtc': untilUtc?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventOccurrenceQueryImpl extends CalendarEventOccurrenceQuery {
  const _CalendarEventOccurrenceQueryImpl({
    required _isc.UuidValue eventId,
    required int expectedRevision,
    _i1bb5k1r.CalendarEventCivil? fromDate,
    _i1bb5k1r.CalendarEventCivil? untilDate,
    DateTime? fromUtc,
    DateTime? untilUtc,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
         fromDate: fromDate,
         untilDate: untilDate,
         fromUtc: fromUtc,
         untilUtc: untilUtc,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrenceQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventOccurrenceQuery copyWith({
    _isc.UuidValue? eventId,
    int? expectedRevision,
    Object? fromDate = _Undefined,
    Object? untilDate = _Undefined,
    Object? fromUtc = _Undefined,
    Object? untilUtc = _Undefined,
  }) {
    return CalendarEventOccurrenceQuery(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      fromDate: fromDate is _i1bb5k1r.CalendarEventCivil?
          ? fromDate
          : this.fromDate?.copyWith(),
      untilDate: untilDate is _i1bb5k1r.CalendarEventCivil?
          ? untilDate
          : this.untilDate?.copyWith(),
      fromUtc: fromUtc is DateTime? ? fromUtc : this.fromUtc,
      untilUtc: untilUtc is DateTime? ? untilUtc : this.untilUtc,
    );
  }
}
