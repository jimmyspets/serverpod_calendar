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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_task_receipt.dart' as _im9usybn;

@_isc.immutable
abstract class CalendarTaskImportResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskImportResult._({required this.receipts});

  const factory CalendarTaskImportResult({
    required List<_im9usybn.CalendarTaskReceipt> receipts,
  }) = _CalendarTaskImportResultImpl;

  factory CalendarTaskImportResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskImportResult(
      receipts: _ie4a1wrz.Protocol()
          .deserialize<List<_im9usybn.CalendarTaskReceipt>>(
            jsonSerialization['receipts'],
          ),
    );
  }

  final List<_im9usybn.CalendarTaskReceipt> receipts;

  /// Returns a shallow copy of this [CalendarTaskImportResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskImportResult copyWith({
    List<_im9usybn.CalendarTaskReceipt>? receipts,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskImportResult &&
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
      '__className__': 'serverpod_calendar.CalendarTaskImportResult',
      'receipts': receipts.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskImportResult',
      'receipts': receipts.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarTaskImportResultImpl extends CalendarTaskImportResult {
  const _CalendarTaskImportResultImpl({
    required List<_im9usybn.CalendarTaskReceipt> receipts,
  }) : super._(receipts: receipts);

  /// Returns a shallow copy of this [CalendarTaskImportResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskImportResult copyWith({
    List<_im9usybn.CalendarTaskReceipt>? receipts,
  }) {
    return CalendarTaskImportResult(
      receipts: receipts ?? this.receipts.map((e0) => e0.copyWith()).toList(),
    );
  }
}
