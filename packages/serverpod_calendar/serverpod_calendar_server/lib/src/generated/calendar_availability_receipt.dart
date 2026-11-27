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
abstract class CalendarAvailabilityReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityReceipt._({
    required this.availabilityId,
    required this.calendarId,
    required this.revision,
    required this.deleted,
  });

  const factory CalendarAvailabilityReceipt({
    required _is.UuidValue availabilityId,
    required _is.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) = _CalendarAvailabilityReceiptImpl;

  factory CalendarAvailabilityReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityReceipt(
      availabilityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['availabilityId'],
      ),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      deleted: _is.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
    );
  }

  final _is.UuidValue availabilityId;

  final _is.UuidValue calendarId;

  final int revision;

  final bool deleted;

  /// Returns a shallow copy of this [CalendarAvailabilityReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityReceipt copyWith({
    _is.UuidValue? availabilityId,
    _is.UuidValue? calendarId,
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
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityReceiptImpl extends CalendarAvailabilityReceipt {
  const _CalendarAvailabilityReceiptImpl({
    required _is.UuidValue availabilityId,
    required _is.UuidValue calendarId,
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
  @_is.useResult
  @override
  CalendarAvailabilityReceipt copyWith({
    _is.UuidValue? availabilityId,
    _is.UuidValue? calendarId,
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
