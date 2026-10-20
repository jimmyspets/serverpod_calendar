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

abstract class CalendarMutationReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarMutationReceipt._({
    required this.calendarId,
    required this.revision,
    required this.deleted,
  });

  factory CalendarMutationReceipt({
    required _isc.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) = _CalendarMutationReceiptImpl;

  factory CalendarMutationReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarMutationReceipt(
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      deleted: _isc.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
    );
  }

  _isc.UuidValue calendarId;

  int revision;

  bool deleted;

  /// Returns a shallow copy of this [CalendarMutationReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarMutationReceipt copyWith({
    _isc.UuidValue? calendarId,
    int? revision,
    bool? deleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarMutationReceipt',
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'deleted': deleted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarMutationReceipt',
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

class _CalendarMutationReceiptImpl extends CalendarMutationReceipt {
  _CalendarMutationReceiptImpl({
    required _isc.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) : super._(
         calendarId: calendarId,
         revision: revision,
         deleted: deleted,
       );

  /// Returns a shallow copy of this [CalendarMutationReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarMutationReceipt copyWith({
    _isc.UuidValue? calendarId,
    int? revision,
    bool? deleted,
  }) {
    return CalendarMutationReceipt(
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      deleted: deleted ?? this.deleted,
    );
  }
}
