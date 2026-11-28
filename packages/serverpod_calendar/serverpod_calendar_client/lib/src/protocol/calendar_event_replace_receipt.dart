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
import 'calendar_event_receipt.dart' as _i500bvo7;

@_isc.immutable
abstract class CalendarEventReplaceReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventReplaceReceipt._({
    required this.receipt,
    required this.changed,
  });

  const factory CalendarEventReplaceReceipt({
    required _i500bvo7.CalendarEventReceipt receipt,
    required bool changed,
  }) = _CalendarEventReplaceReceiptImpl;

  factory CalendarEventReplaceReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventReplaceReceipt(
      receipt: _ie4a1wrz.Protocol().deserialize<_i500bvo7.CalendarEventReceipt>(
        jsonSerialization['receipt'],
      ),
      changed: _isc.BoolJsonExtension.fromJson(jsonSerialization['changed']),
    );
  }

  final _i500bvo7.CalendarEventReceipt receipt;

  final bool changed;

  /// Returns a shallow copy of this [CalendarEventReplaceReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventReplaceReceipt copyWith({
    _i500bvo7.CalendarEventReceipt? receipt,
    bool? changed,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventReplaceReceipt &&
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
      '__className__': 'serverpod_calendar.CalendarEventReplaceReceipt',
      'receipt': receipt.toJson(),
      'changed': changed,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventReplaceReceipt',
      'receipt': receipt.toJsonForProtocol(),
      'changed': changed,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarEventReplaceReceiptImpl extends CalendarEventReplaceReceipt {
  const _CalendarEventReplaceReceiptImpl({
    required _i500bvo7.CalendarEventReceipt receipt,
    required bool changed,
  }) : super._(
         receipt: receipt,
         changed: changed,
       );

  /// Returns a shallow copy of this [CalendarEventReplaceReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventReplaceReceipt copyWith({
    _i500bvo7.CalendarEventReceipt? receipt,
    bool? changed,
  }) {
    return CalendarEventReplaceReceipt(
      receipt: receipt ?? this.receipt.copyWith(),
      changed: changed ?? this.changed,
    );
  }
}
