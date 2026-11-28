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

import 'calendar_invitation_response_delivery_state.dart' as _iw51ozry;

abstract class CalendarAttendeeRefreshView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarAttendeeRefreshView._({
    this.deliveryId,
    this.state,
    required this.unchanged,
    required this.canRequest,
  });

  factory CalendarAttendeeRefreshView({
    _isc.UuidValue? deliveryId,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    required bool unchanged,
    required bool canRequest,
  }) = _CalendarAttendeeRefreshViewImpl;

  factory CalendarAttendeeRefreshView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAttendeeRefreshView(
      deliveryId: jsonSerialization['deliveryId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['deliveryId'],
            ),
      state: jsonSerialization['state'] == null
          ? null
          : _iw51ozry.CalendarInvitationResponseDeliveryState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      unchanged: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['unchanged'],
      ),
      canRequest: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['canRequest'],
      ),
    );
  }

  _isc.UuidValue? deliveryId;

  _iw51ozry.CalendarInvitationResponseDeliveryState? state;

  bool unchanged;

  bool canRequest;

  /// Returns a shallow copy of this [CalendarAttendeeRefreshView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAttendeeRefreshView copyWith({
    _isc.UuidValue? deliveryId = const _isc.$UndefinedUuidValue(),
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    bool? unchanged,
    bool? canRequest,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAttendeeRefreshView',
      if (deliveryId != null) 'deliveryId': deliveryId?.toJson(),
      if (state != null) 'state': state?.toJson(),
      'unchanged': unchanged,
      'canRequest': canRequest,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAttendeeRefreshView',
      if (deliveryId != null) 'deliveryId': deliveryId?.toJson(),
      if (state != null) 'state': state?.toJson(),
      'unchanged': unchanged,
      'canRequest': canRequest,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAttendeeRefreshViewImpl extends CalendarAttendeeRefreshView {
  _CalendarAttendeeRefreshViewImpl({
    _isc.UuidValue? deliveryId,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    required bool unchanged,
    required bool canRequest,
  }) : super._(
         deliveryId: deliveryId,
         state: state,
         unchanged: unchanged,
         canRequest: canRequest,
       );

  /// Returns a shallow copy of this [CalendarAttendeeRefreshView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAttendeeRefreshView copyWith({
    _isc.UuidValue? deliveryId = const _isc.$UndefinedUuidValue(),
    Object? state = _Undefined,
    bool? unchanged,
    bool? canRequest,
  }) {
    return CalendarAttendeeRefreshView(
      deliveryId: deliveryId is _isc.UndefinedSentinel
          ? this.deliveryId
          : deliveryId,
      state: state is _iw51ozry.CalendarInvitationResponseDeliveryState?
          ? state
          : this.state,
      unchanged: unchanged ?? this.unchanged,
      canRequest: canRequest ?? this.canRequest,
    );
  }
}
