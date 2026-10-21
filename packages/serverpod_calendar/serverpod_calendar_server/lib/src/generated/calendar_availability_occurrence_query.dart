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

@_is.immutable
abstract class CalendarAvailabilityOccurrenceQuery
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityOccurrenceQuery._({
    required this.availabilityId,
    required this.openingUid,
    required this.expectedRevision,
    required this.fromUtc,
    required this.untilUtc,
  });

  const factory CalendarAvailabilityOccurrenceQuery({
    required _is.UuidValue availabilityId,
    required _is.UuidValue openingUid,
    required int expectedRevision,
    required DateTime fromUtc,
    required DateTime untilUtc,
  }) = _CalendarAvailabilityOccurrenceQueryImpl;

  factory CalendarAvailabilityOccurrenceQuery.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOccurrenceQuery(
      availabilityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['availabilityId'],
      ),
      openingUid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['openingUid'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      fromUtc: _is.DateTimeJsonExtension.fromJson(jsonSerialization['fromUtc']),
      untilUtc: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['untilUtc'],
      ),
    );
  }

  final _is.UuidValue availabilityId;

  final _is.UuidValue openingUid;

  final int expectedRevision;

  final DateTime fromUtc;

  final DateTime untilUtc;

  /// Returns a shallow copy of this [CalendarAvailabilityOccurrenceQuery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityOccurrenceQuery copyWith({
    _is.UuidValue? availabilityId,
    _is.UuidValue? openingUid,
    int? expectedRevision,
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
            other is CalendarAvailabilityOccurrenceQuery &&
            (identical(
                  other.availabilityId,
                  availabilityId,
                ) ||
                other.availabilityId == availabilityId) &&
            (identical(
                  other.openingUid,
                  openingUid,
                ) ||
                other.openingUid == openingUid) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision) &&
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
      availabilityId,
      openingUid,
      expectedRevision,
      fromUtc,
      untilUtc,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOccurrenceQuery',
      'availabilityId': availabilityId.toJson(),
      'openingUid': openingUid.toJson(),
      'expectedRevision': expectedRevision,
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOccurrenceQuery',
      'availabilityId': availabilityId.toJson(),
      'openingUid': openingUid.toJson(),
      'expectedRevision': expectedRevision,
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityOccurrenceQueryImpl
    extends CalendarAvailabilityOccurrenceQuery {
  const _CalendarAvailabilityOccurrenceQueryImpl({
    required _is.UuidValue availabilityId,
    required _is.UuidValue openingUid,
    required int expectedRevision,
    required DateTime fromUtc,
    required DateTime untilUtc,
  }) : super._(
         availabilityId: availabilityId,
         openingUid: openingUid,
         expectedRevision: expectedRevision,
         fromUtc: fromUtc,
         untilUtc: untilUtc,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOccurrenceQuery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityOccurrenceQuery copyWith({
    _is.UuidValue? availabilityId,
    _is.UuidValue? openingUid,
    int? expectedRevision,
    DateTime? fromUtc,
    DateTime? untilUtc,
  }) {
    return CalendarAvailabilityOccurrenceQuery(
      availabilityId: availabilityId ?? this.availabilityId,
      openingUid: openingUid ?? this.openingUid,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      fromUtc: fromUtc ?? this.fromUtc,
      untilUtc: untilUtc ?? this.untilUtc,
    );
  }
}
