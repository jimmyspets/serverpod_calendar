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
abstract class CalendarEventReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventReceipt._({
    required this.eventId,
    required this.calendarId,
    required this.revision,
    required this.deleted,
  });

  const factory CalendarEventReceipt({
    required _isc.UuidValue eventId,
    required _isc.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) = _CalendarEventReceiptImpl;

  factory CalendarEventReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventReceipt(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      deleted: _isc.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
    );
  }

  final _isc.UuidValue eventId;

  final _isc.UuidValue calendarId;

  final int revision;

  final bool deleted;

  /// Returns a shallow copy of this [CalendarEventReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventReceipt copyWith({
    _isc.UuidValue? eventId,
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
            other is CalendarEventReceipt &&
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
                  other.deleted,
                  deleted,
                ) ||
                other.deleted == deleted);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      calendarId,
      revision,
      deleted,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventReceipt',
      'eventId': eventId.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'deleted': deleted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventReceipt',
      'eventId': eventId.toJson(),
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

class _CalendarEventReceiptImpl extends CalendarEventReceipt {
  const _CalendarEventReceiptImpl({
    required _isc.UuidValue eventId,
    required _isc.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) : super._(
         eventId: eventId,
         calendarId: calendarId,
         revision: revision,
         deleted: deleted,
       );

  /// Returns a shallow copy of this [CalendarEventReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventReceipt copyWith({
    _isc.UuidValue? eventId,
    _isc.UuidValue? calendarId,
    int? revision,
    bool? deleted,
  }) {
    return CalendarEventReceipt(
      eventId: eventId ?? this.eventId,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      deleted: deleted ?? this.deleted,
    );
  }
}
