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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

@_isc.immutable
abstract class CalendarAvailabilityReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityReceipt._({
    required this.availabilityId,
    required this.calendarId,
    required this.revision,
    required this.deleted,
  });

  const factory CalendarAvailabilityReceipt({
    required _isc.UuidValue availabilityId,
    required _isc.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) = _CalendarAvailabilityReceiptImpl;

  factory CalendarAvailabilityReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityReceipt(
      availabilityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['availabilityId'],
      ),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      deleted: _isc.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
    );
  }

  final _isc.UuidValue availabilityId;

  final _isc.UuidValue calendarId;

  final int revision;

  final bool deleted;

  /// Returns a shallow copy of this [CalendarAvailabilityReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityReceipt copyWith({
    _isc.UuidValue? availabilityId,
    _isc.UuidValue? calendarId,
    int? revision,
    bool? deleted,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityReceipt &&
            (identical(
                  other.availabilityId,
                  availabilityId,
                ) ||
                other.availabilityId == availabilityId) &&
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
                  other.deleted,
                  deleted,
                ) ||
                other.deleted == deleted);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      availabilityId,
      calendarId,
      revision,
      deleted,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityReceipt',
      'availabilityId': availabilityId.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'deleted': deleted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityReceipt',
      'availabilityId': availabilityId.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'deleted': deleted,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityReceiptImpl extends CalendarAvailabilityReceipt {
  const _CalendarAvailabilityReceiptImpl({
    required _isc.UuidValue availabilityId,
    required _isc.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) : super._(
         availabilityId: availabilityId,
         calendarId: calendarId,
         revision: revision,
         deleted: deleted,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityReceipt copyWith({
    _isc.UuidValue? availabilityId,
    _isc.UuidValue? calendarId,
    int? revision,
    bool? deleted,
  }) {
    return CalendarAvailabilityReceipt(
      availabilityId: availabilityId ?? this.availabilityId,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      deleted: deleted ?? this.deleted,
    );
  }
}
