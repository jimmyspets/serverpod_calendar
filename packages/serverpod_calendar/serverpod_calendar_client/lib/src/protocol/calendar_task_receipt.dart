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
abstract class CalendarTaskReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskReceipt._({
    required this.taskId,
    required this.calendarId,
    required this.revision,
    required this.deleted,
  });

  const factory CalendarTaskReceipt({
    required _isc.UuidValue taskId,
    required _isc.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) = _CalendarTaskReceiptImpl;

  factory CalendarTaskReceipt.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarTaskReceipt(
      taskId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      deleted: _isc.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
    );
  }

  final _isc.UuidValue taskId;

  final _isc.UuidValue calendarId;

  final int revision;

  final bool deleted;

  /// Returns a shallow copy of this [CalendarTaskReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskReceipt copyWith({
    _isc.UuidValue? taskId,
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
            other is CalendarTaskReceipt &&
            (identical(
                  other.taskId,
                  taskId,
                ) ||
                other.taskId == taskId) &&
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
      taskId,
      calendarId,
      revision,
      deleted,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskReceipt',
      'taskId': taskId.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'deleted': deleted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskReceipt',
      'taskId': taskId.toJson(),
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

class _CalendarTaskReceiptImpl extends CalendarTaskReceipt {
  const _CalendarTaskReceiptImpl({
    required _isc.UuidValue taskId,
    required _isc.UuidValue calendarId,
    required int revision,
    required bool deleted,
  }) : super._(
         taskId: taskId,
         calendarId: calendarId,
         revision: revision,
         deleted: deleted,
       );

  /// Returns a shallow copy of this [CalendarTaskReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskReceipt copyWith({
    _isc.UuidValue? taskId,
    _isc.UuidValue? calendarId,
    int? revision,
    bool? deleted,
  }) {
    return CalendarTaskReceipt(
      taskId: taskId ?? this.taskId,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      deleted: deleted ?? this.deleted,
    );
  }
}
