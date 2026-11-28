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
abstract class CalendarAlarmActionView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAlarmActionView._({
    required this.id,
    required this.alarmId,
    required this.originalKey,
    required this.revision,
    this.acknowledgedAt,
    this.dismissedAt,
    this.pendingSnoozeAt,
    this.resetAt,
    required this.updatedAt,
  });

  const factory CalendarAlarmActionView({
    required _isc.UuidValue id,
    required _isc.UuidValue alarmId,
    required String originalKey,
    required int revision,
    DateTime? acknowledgedAt,
    DateTime? dismissedAt,
    DateTime? pendingSnoozeAt,
    DateTime? resetAt,
    required DateTime updatedAt,
  }) = _CalendarAlarmActionViewImpl;

  factory CalendarAlarmActionView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmActionView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      alarmId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['alarmId'],
      ),
      originalKey: jsonSerialization['originalKey'] as String,
      revision: jsonSerialization['revision'] as int,
      acknowledgedAt: jsonSerialization['acknowledgedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['acknowledgedAt'],
            ),
      dismissedAt: jsonSerialization['dismissedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['dismissedAt'],
            ),
      pendingSnoozeAt: jsonSerialization['pendingSnoozeAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['pendingSnoozeAt'],
            ),
      resetAt: jsonSerialization['resetAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['resetAt']),
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  final _isc.UuidValue id;

  final _isc.UuidValue alarmId;

  final String originalKey;

  final int revision;

  final DateTime? acknowledgedAt;

  final DateTime? dismissedAt;

  final DateTime? pendingSnoozeAt;

  final DateTime? resetAt;

  final DateTime updatedAt;

  /// Returns a shallow copy of this [CalendarAlarmActionView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAlarmActionView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? alarmId,
    String? originalKey,
    int? revision,
    DateTime? acknowledgedAt,
    DateTime? dismissedAt,
    DateTime? pendingSnoozeAt,
    DateTime? resetAt,
    DateTime? updatedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAlarmActionView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.alarmId,
                  alarmId,
                ) ||
                other.alarmId == alarmId) &&
            (identical(
                  other.originalKey,
                  originalKey,
                ) ||
                other.originalKey == originalKey) &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            (identical(
                  other.acknowledgedAt,
                  acknowledgedAt,
                ) ||
                other.acknowledgedAt == acknowledgedAt) &&
            (identical(
                  other.dismissedAt,
                  dismissedAt,
                ) ||
                other.dismissedAt == dismissedAt) &&
            (identical(
                  other.pendingSnoozeAt,
                  pendingSnoozeAt,
                ) ||
                other.pendingSnoozeAt == pendingSnoozeAt) &&
            (identical(
                  other.resetAt,
                  resetAt,
                ) ||
                other.resetAt == resetAt) &&
            (identical(
                  other.updatedAt,
                  updatedAt,
                ) ||
                other.updatedAt == updatedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      alarmId,
      originalKey,
      revision,
      acknowledgedAt,
      dismissedAt,
      pendingSnoozeAt,
      resetAt,
      updatedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmActionView',
      'id': id.toJson(),
      'alarmId': alarmId.toJson(),
      'originalKey': originalKey,
      'revision': revision,
      if (acknowledgedAt != null) 'acknowledgedAt': acknowledgedAt?.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
      if (pendingSnoozeAt != null) 'pendingSnoozeAt': pendingSnoozeAt?.toJson(),
      if (resetAt != null) 'resetAt': resetAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmActionView',
      'id': id.toJson(),
      'alarmId': alarmId.toJson(),
      'originalKey': originalKey,
      'revision': revision,
      if (acknowledgedAt != null) 'acknowledgedAt': acknowledgedAt?.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
      if (pendingSnoozeAt != null) 'pendingSnoozeAt': pendingSnoozeAt?.toJson(),
      if (resetAt != null) 'resetAt': resetAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAlarmActionViewImpl extends CalendarAlarmActionView {
  const _CalendarAlarmActionViewImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue alarmId,
    required String originalKey,
    required int revision,
    DateTime? acknowledgedAt,
    DateTime? dismissedAt,
    DateTime? pendingSnoozeAt,
    DateTime? resetAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         alarmId: alarmId,
         originalKey: originalKey,
         revision: revision,
         acknowledgedAt: acknowledgedAt,
         dismissedAt: dismissedAt,
         pendingSnoozeAt: pendingSnoozeAt,
         resetAt: resetAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarAlarmActionView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAlarmActionView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? alarmId,
    String? originalKey,
    int? revision,
    Object? acknowledgedAt = _Undefined,
    Object? dismissedAt = _Undefined,
    Object? pendingSnoozeAt = _Undefined,
    Object? resetAt = _Undefined,
    DateTime? updatedAt,
  }) {
    return CalendarAlarmActionView(
      id: id ?? this.id,
      alarmId: alarmId ?? this.alarmId,
      originalKey: originalKey ?? this.originalKey,
      revision: revision ?? this.revision,
      acknowledgedAt: acknowledgedAt is DateTime?
          ? acknowledgedAt
          : this.acknowledgedAt,
      dismissedAt: dismissedAt is DateTime? ? dismissedAt : this.dismissedAt,
      pendingSnoozeAt: pendingSnoozeAt is DateTime?
          ? pendingSnoozeAt
          : this.pendingSnoozeAt,
      resetAt: resetAt is DateTime? ? resetAt : this.resetAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
