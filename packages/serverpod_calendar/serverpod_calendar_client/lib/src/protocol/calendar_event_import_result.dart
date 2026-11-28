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
import 'calendar_event_receipt.dart' as _i500bvo7;

@_isc.immutable
abstract class CalendarEventImportResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventImportResult._({required this.receipts});

  const factory CalendarEventImportResult({
    required List<_i500bvo7.CalendarEventReceipt> receipts,
  }) = _CalendarEventImportResultImpl;

  factory CalendarEventImportResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventImportResult(
      receipts: _ie4a1wrz.Protocol()
          .deserialize<List<_i500bvo7.CalendarEventReceipt>>(
            jsonSerialization['receipts'],
          ),
    );
  }

  final List<_i500bvo7.CalendarEventReceipt> receipts;

  /// Returns a shallow copy of this [CalendarEventImportResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventImportResult copyWith({
    List<_i500bvo7.CalendarEventReceipt>? receipts,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventImportResult &&
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
      '__className__': 'serverpod_calendar.CalendarEventImportResult',
      'receipts': receipts.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventImportResult',
      'receipts': receipts.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarEventImportResultImpl extends CalendarEventImportResult {
  const _CalendarEventImportResultImpl({
    required List<_i500bvo7.CalendarEventReceipt> receipts,
  }) : super._(receipts: receipts);

  /// Returns a shallow copy of this [CalendarEventImportResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventImportResult copyWith({
    List<_i500bvo7.CalendarEventReceipt>? receipts,
  }) {
    return CalendarEventImportResult(
      receipts: receipts ?? this.receipts.map((e0) => e0.copyWith()).toList(),
    );
  }
}
