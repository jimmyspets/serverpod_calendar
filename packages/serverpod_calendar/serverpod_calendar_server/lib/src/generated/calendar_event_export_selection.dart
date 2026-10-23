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
abstract class CalendarEventExportSelection
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventExportSelection._({
    required this.eventId,
    required this.expectedRevision,
  });

  const factory CalendarEventExportSelection({
    required _is.UuidValue eventId,
    required int expectedRevision,
  }) = _CalendarEventExportSelectionImpl;

  factory CalendarEventExportSelection.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventExportSelection(
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      expectedRevision: jsonSerialization['expectedRevision'] as int,
    );
  }

  final _is.UuidValue eventId;

  final int expectedRevision;

  /// Returns a shallow copy of this [CalendarEventExportSelection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventExportSelection copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventExportSelection &&
            (identical(
                  other.eventId,
                  eventId,
                ) ||
                other.eventId == eventId) &&
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
      eventId,
      expectedRevision,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventExportSelection',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventExportSelection',
      'eventId': eventId.toJson(),
      'expectedRevision': expectedRevision,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarEventExportSelectionImpl extends CalendarEventExportSelection {
  const _CalendarEventExportSelectionImpl({
    required _is.UuidValue eventId,
    required int expectedRevision,
  }) : super._(
         eventId: eventId,
         expectedRevision: expectedRevision,
       );

  /// Returns a shallow copy of this [CalendarEventExportSelection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventExportSelection copyWith({
    _is.UuidValue? eventId,
    int? expectedRevision,
  }) {
    return CalendarEventExportSelection(
      eventId: eventId ?? this.eventId,
      expectedRevision: expectedRevision ?? this.expectedRevision,
    );
  }
}
