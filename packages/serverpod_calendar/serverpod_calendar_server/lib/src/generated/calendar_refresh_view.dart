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
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;

import 'calendar_scheduling_delivery_state.dart' as _it5jr5tm;

abstract class CalendarRefreshView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarRefreshView._({
    required this.requestId,
    required this.attendeeAddress,
    required this.sourceStamp,
    required this.comments,
    required this.receivedAt,
    required this.expiresAt,
    this.dismissedAt,
    this.resendState,
  });

  factory CalendarRefreshView({
    required _is.UuidValue requestId,
    required String attendeeAddress,
    required DateTime sourceStamp,
    required List<String> comments,
    required DateTime receivedAt,
    required DateTime expiresAt,
    DateTime? dismissedAt,
    _it5jr5tm.CalendarSchedulingDeliveryState? resendState,
  }) = _CalendarRefreshViewImpl;

  factory CalendarRefreshView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarRefreshView(
      requestId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestId'],
      ),
      attendeeAddress: jsonSerialization['attendeeAddress'] as String,
      sourceStamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['sourceStamp'],
      ),
      comments: _ix00hwbf.Protocol().deserialize<List<String>>(
        jsonSerialization['comments'],
      ),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      dismissedAt: jsonSerialization['dismissedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['dismissedAt'],
            ),
      resendState: jsonSerialization['resendState'] == null
          ? null
          : _it5jr5tm.CalendarSchedulingDeliveryState.fromJson(
              (jsonSerialization['resendState'] as String),
            ),
    );
  }

  _is.UuidValue requestId;

  String attendeeAddress;

  DateTime sourceStamp;

  List<String> comments;

  DateTime receivedAt;

  DateTime expiresAt;

  DateTime? dismissedAt;

  _it5jr5tm.CalendarSchedulingDeliveryState? resendState;

  /// Returns a shallow copy of this [CalendarRefreshView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarRefreshView copyWith({
    _is.UuidValue? requestId,
    String? attendeeAddress,
    DateTime? sourceStamp,
    List<String>? comments,
    DateTime? receivedAt,
    DateTime? expiresAt,
    DateTime? dismissedAt = const _is.$UndefinedDateTime(),
    _it5jr5tm.CalendarSchedulingDeliveryState? resendState,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshView',
      'requestId': requestId.toJson(),
      'attendeeAddress': attendeeAddress,
      'sourceStamp': sourceStamp.toJson(),
      'comments': comments.toJson(),
      'receivedAt': receivedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
      if (resendState != null) 'resendState': resendState?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshView',
      'requestId': requestId.toJson(),
      'attendeeAddress': attendeeAddress,
      'sourceStamp': sourceStamp.toJson(),
      'comments': comments.toJson(),
      'receivedAt': receivedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
      if (resendState != null) 'resendState': resendState?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarRefreshViewImpl extends CalendarRefreshView {
  _CalendarRefreshViewImpl({
    required _is.UuidValue requestId,
    required String attendeeAddress,
    required DateTime sourceStamp,
    required List<String> comments,
    required DateTime receivedAt,
    required DateTime expiresAt,
    DateTime? dismissedAt,
    _it5jr5tm.CalendarSchedulingDeliveryState? resendState,
  }) : super._(
         requestId: requestId,
         attendeeAddress: attendeeAddress,
         sourceStamp: sourceStamp,
         comments: comments,
         receivedAt: receivedAt,
         expiresAt: expiresAt,
         dismissedAt: dismissedAt,
         resendState: resendState,
       );

  /// Returns a shallow copy of this [CalendarRefreshView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarRefreshView copyWith({
    _is.UuidValue? requestId,
    String? attendeeAddress,
    DateTime? sourceStamp,
    List<String>? comments,
    DateTime? receivedAt,
    DateTime? expiresAt,
    DateTime? dismissedAt = const _is.$UndefinedDateTime(),
    Object? resendState = _Undefined,
  }) {
    return CalendarRefreshView(
      requestId: requestId ?? this.requestId,
      attendeeAddress: attendeeAddress ?? this.attendeeAddress,
      sourceStamp: sourceStamp ?? this.sourceStamp,
      comments: comments ?? this.comments.map((e0) => e0).toList(),
      receivedAt: receivedAt ?? this.receivedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      dismissedAt: dismissedAt is _is.UndefinedSentinel
          ? this.dismissedAt
          : dismissedAt,
      resendState: resendState is _it5jr5tm.CalendarSchedulingDeliveryState?
          ? resendState
          : this.resendState,
    );
  }
}
