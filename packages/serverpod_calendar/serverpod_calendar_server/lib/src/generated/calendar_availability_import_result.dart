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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_availability_receipt.dart' as _is1luycx;

@_is.immutable
abstract class CalendarAvailabilityImportResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityImportResult._({required this.receipts});

  const factory CalendarAvailabilityImportResult({
    required List<_is1luycx.CalendarAvailabilityReceipt> receipts,
  }) = _CalendarAvailabilityImportResultImpl;

  factory CalendarAvailabilityImportResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityImportResult(
      receipts: _ix00hwbf.Protocol()
          .deserialize<List<_is1luycx.CalendarAvailabilityReceipt>>(
            jsonSerialization['receipts'],
          ),
    );
  }

  final List<_is1luycx.CalendarAvailabilityReceipt> receipts;

  /// Returns a shallow copy of this [CalendarAvailabilityImportResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityImportResult copyWith({
    List<_is1luycx.CalendarAvailabilityReceipt>? receipts,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityImportResult &&
            const _iss.DeepCollectionEquality().equals(
              other.receipts,
              receipts,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(receipts),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityImportResult',
      'receipts': receipts.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityImportResult',
      'receipts': receipts.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityImportResultImpl
    extends CalendarAvailabilityImportResult {
  const _CalendarAvailabilityImportResultImpl({
    required List<_is1luycx.CalendarAvailabilityReceipt> receipts,
  }) : super._(receipts: receipts);

  /// Returns a shallow copy of this [CalendarAvailabilityImportResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityImportResult copyWith({
    List<_is1luycx.CalendarAvailabilityReceipt>? receipts,
  }) {
    return CalendarAvailabilityImportResult(
      receipts: receipts ?? this.receipts.map((e0) => e0.copyWith()).toList(),
    );
  }
}
