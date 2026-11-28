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

@_isc.immutable
abstract class CalendarSchedulingDeliveryView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarSchedulingDeliveryView._({
    required this.recipientAddress,
    required this.state,
    required this.attemptCount,
    this.resultCode,
  });

  const factory CalendarSchedulingDeliveryView({
    required String recipientAddress,
    required _it5jr5tm.CalendarSchedulingDeliveryState state,
    required int attemptCount,
    String? resultCode,
  }) = _CalendarSchedulingDeliveryViewImpl;

  factory CalendarSchedulingDeliveryView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingDeliveryView(
      recipientAddress: jsonSerialization['recipientAddress'] as String,
      state: _it5jr5tm.CalendarSchedulingDeliveryState.fromJson(
        (jsonSerialization['state'] as String),
      ),
      attemptCount: jsonSerialization['attemptCount'] as int,
      resultCode: jsonSerialization['resultCode'] as String?,
    );
  }

  final String recipientAddress;

  final _it5jr5tm.CalendarSchedulingDeliveryState state;

  final int attemptCount;

  final String? resultCode;

  /// Returns a shallow copy of this [CalendarSchedulingDeliveryView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarSchedulingDeliveryView copyWith({
    String? recipientAddress,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    String? resultCode,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingDeliveryView &&
            (identical(
                  other.recipientAddress,
                  recipientAddress,
                ) ||
                other.recipientAddress == recipientAddress) &&
            (identical(
                  other.state,
                  state,
                ) ||
                other.state == state) &&
            (identical(
                  other.attemptCount,
                  attemptCount,
                ) ||
                other.attemptCount == attemptCount) &&
            (identical(
                  other.resultCode,
                  resultCode,
                ) ||
                other.resultCode == resultCode);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      recipientAddress,
      state,
      attemptCount,
      resultCode,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingDeliveryView',
      'recipientAddress': recipientAddress,
      'state': state.toJson(),
      'attemptCount': attemptCount,
      if (resultCode != null) 'resultCode': resultCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingDeliveryView',
      'recipientAddress': recipientAddress,
      'state': state.toJson(),
      'attemptCount': attemptCount,
      if (resultCode != null) 'resultCode': resultCode,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingDeliveryViewImpl
    extends CalendarSchedulingDeliveryView {
  const _CalendarSchedulingDeliveryViewImpl({
    required String recipientAddress,
    required _it5jr5tm.CalendarSchedulingDeliveryState state,
    required int attemptCount,
    String? resultCode,
  }) : super._(
         recipientAddress: recipientAddress,
         state: state,
         attemptCount: attemptCount,
         resultCode: resultCode,
       );

  /// Returns a shallow copy of this [CalendarSchedulingDeliveryView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarSchedulingDeliveryView copyWith({
    String? recipientAddress,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    Object? resultCode = _Undefined,
  }) {
    return CalendarSchedulingDeliveryView(
      recipientAddress: recipientAddress ?? this.recipientAddress,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      resultCode: resultCode is String? ? resultCode : this.resultCode,
    );
  }
}
