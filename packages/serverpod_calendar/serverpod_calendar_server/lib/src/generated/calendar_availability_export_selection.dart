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
abstract class CalendarAvailabilityExportSelection
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityExportSelection._({
    required this.availabilityId,
    required this.expectedRevision,
  });

  const factory CalendarAvailabilityExportSelection({
    required _is.UuidValue availabilityId,
    required int expectedRevision,
  }) = _CalendarAvailabilityExportSelectionImpl;

  factory CalendarAvailabilityExportSelection.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityExportSelection(
      availabilityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['availabilityId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
    );
  }

  final _is.UuidValue availabilityId;

  final int expectedRevision;

  /// Returns a shallow copy of this [CalendarAvailabilityExportSelection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityExportSelection copyWith({
    _is.UuidValue? availabilityId,
    int? expectedRevision,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityExportSelection &&
            (identical(
                  other.availabilityId,
                  availabilityId,
                ) ||
                other.availabilityId == availabilityId) &&
            (identical(
                  other.expectedRevision,
                  expectedRevision,
                ) ||
                other.expectedRevision == expectedRevision);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      availabilityId,
      expectedRevision,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityExportSelection',
      'availabilityId': availabilityId.toJson(),
      'expectedRevision': expectedRevision,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityExportSelection',
      'availabilityId': availabilityId.toJson(),
      'expectedRevision': expectedRevision,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityExportSelectionImpl
    extends CalendarAvailabilityExportSelection {
  const _CalendarAvailabilityExportSelectionImpl({
    required _is.UuidValue availabilityId,
    required int expectedRevision,
  }) : super._(
         availabilityId: availabilityId,
         expectedRevision: expectedRevision,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityExportSelection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityExportSelection copyWith({
    _is.UuidValue? availabilityId,
    int? expectedRevision,
  }) {
    return CalendarAvailabilityExportSelection(
      availabilityId: availabilityId ?? this.availabilityId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
    );
  }
}
