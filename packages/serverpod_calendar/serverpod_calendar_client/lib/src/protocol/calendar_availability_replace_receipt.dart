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
import 'package:serverpod_calendar_client/src/protocol/protocol.dart'
    as _ie4a1wrz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'calendar_availability_receipt.dart' as _is1luycx;

@_isc.immutable
abstract class CalendarAvailabilityReplaceReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityReplaceReceipt._({
    required this.receipt,
    required this.changed,
  });

  const factory CalendarAvailabilityReplaceReceipt({
    required _is1luycx.CalendarAvailabilityReceipt receipt,
    required bool changed,
  }) = _CalendarAvailabilityReplaceReceiptImpl;

  factory CalendarAvailabilityReplaceReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityReplaceReceipt(
      receipt: _ie4a1wrz.Protocol()
          .deserialize<_is1luycx.CalendarAvailabilityReceipt>(
            jsonSerialization['receipt'],
          ),
      changed: _isc.BoolJsonExtension.fromJson(jsonSerialization['changed']),
    );
  }

  final _is1luycx.CalendarAvailabilityReceipt receipt;

  final bool changed;

  /// Returns a shallow copy of this [CalendarAvailabilityReplaceReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityReplaceReceipt copyWith({
    _is1luycx.CalendarAvailabilityReceipt? receipt,
    bool? changed,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityReplaceReceipt &&
            (identical(
                  other.receipt,
                  receipt,
                ) ||
                other.receipt == receipt) &&
            (identical(
                  other.changed,
                  changed,
                ) ||
                other.changed == changed);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      receipt,
      changed,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityReplaceReceipt',
      'receipt': receipt.toJson(),
      'changed': changed,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityReplaceReceipt',
      'receipt': receipt.toJsonForProtocol(),
      'changed': changed,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityReplaceReceiptImpl
    extends CalendarAvailabilityReplaceReceipt {
  const _CalendarAvailabilityReplaceReceiptImpl({
    required _is1luycx.CalendarAvailabilityReceipt receipt,
    required bool changed,
  }) : super._(
         receipt: receipt,
         changed: changed,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityReplaceReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityReplaceReceipt copyWith({
    _is1luycx.CalendarAvailabilityReceipt? receipt,
    bool? changed,
  }) {
    return CalendarAvailabilityReplaceReceipt(
      receipt: receipt ?? this.receipt.copyWith(),
      changed: changed ?? this.changed,
    );
  }
}
