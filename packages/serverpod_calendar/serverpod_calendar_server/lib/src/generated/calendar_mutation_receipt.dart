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

abstract class CalendarMutationReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarMutationReceipt._({
    required this.calendarId,
    required this.revision,
    required this.deleted,
  });

  factory CalendarMutationReceipt({
    required _is.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) = _CalendarMutationReceiptImpl;

  factory CalendarMutationReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarMutationReceipt(
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      deleted: _is.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
    );
  }

  _is.UuidValue calendarId;

  int revision;

  bool deleted;

  /// Returns a shallow copy of this [CalendarMutationReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarMutationReceipt copyWith({
    _is.UuidValue? calendarId,
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
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarMutationReceiptImpl extends CalendarMutationReceipt {
  _CalendarMutationReceiptImpl({
    required _is.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) : super._(
         calendarId: calendarId,
         revision: revision,
         deleted: deleted,
       );

  /// Returns a shallow copy of this [CalendarMutationReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarMutationReceipt copyWith({
    _is.UuidValue? calendarId,
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
