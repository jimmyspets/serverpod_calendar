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

import 'calendar_scheduling_delivery_state.dart' as _it5jr5tm;

abstract class CalendarRefreshResendReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarRefreshResendReceipt._({
    required this.resendId,
    required this.state,
    required this.unchanged,
  });

  factory CalendarRefreshResendReceipt({
    required _isc.UuidValue resendId,
    required _it5jr5tm.CalendarSchedulingDeliveryState state,
    required bool unchanged,
  }) = _CalendarRefreshResendReceiptImpl;

  factory CalendarRefreshResendReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarRefreshResendReceipt(
      resendId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['resendId'],
      ),
      state: _it5jr5tm.CalendarSchedulingDeliveryState.fromJson(
        (jsonSerialization['state'] as String),
      ),
      unchanged: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['unchanged'],
      ),
    );
  }

  _isc.UuidValue resendId;

  _it5jr5tm.CalendarSchedulingDeliveryState state;

  bool unchanged;

  /// Returns a shallow copy of this [CalendarRefreshResendReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarRefreshResendReceipt copyWith({
    _isc.UuidValue? resendId,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    bool? unchanged,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshResendReceipt',
      'resendId': resendId.toJson(),
      'state': state.toJson(),
      'unchanged': unchanged,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshResendReceipt',
      'resendId': resendId.toJson(),
      'state': state.toJson(),
      'unchanged': unchanged,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarRefreshResendReceiptImpl extends CalendarRefreshResendReceipt {
  _CalendarRefreshResendReceiptImpl({
    required _isc.UuidValue resendId,
    required _it5jr5tm.CalendarSchedulingDeliveryState state,
    required bool unchanged,
  }) : super._(
         resendId: resendId,
         state: state,
         unchanged: unchanged,
       );

  /// Returns a shallow copy of this [CalendarRefreshResendReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarRefreshResendReceipt copyWith({
    _isc.UuidValue? resendId,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    bool? unchanged,
  }) {
    return CalendarRefreshResendReceipt(
      resendId: resendId ?? this.resendId,
      state: state ?? this.state,
      unchanged: unchanged ?? this.unchanged,
    );
  }
}
