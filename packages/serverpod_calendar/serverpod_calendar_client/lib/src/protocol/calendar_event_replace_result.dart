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
import 'calendar_event_replace_receipt.dart' as _ii1x02jx;

@_isc.immutable
abstract class CalendarEventReplaceResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventReplaceResult._({required this.receipts});

  const factory CalendarEventReplaceResult({
    required List<_ii1x02jx.CalendarEventReplaceReceipt> receipts,
  }) = _CalendarEventReplaceResultImpl;

  factory CalendarEventReplaceResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventReplaceResult(
      receipts: _ie4a1wrz.Protocol()
          .deserialize<List<_ii1x02jx.CalendarEventReplaceReceipt>>(
            jsonSerialization['receipts'],
          ),
    );
  }

  final List<_ii1x02jx.CalendarEventReplaceReceipt> receipts;

  /// Returns a shallow copy of this [CalendarEventReplaceResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventReplaceResult copyWith({
    List<_ii1x02jx.CalendarEventReplaceReceipt>? receipts,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventReplaceResult &&
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
      '__className__': 'serverpod_calendar.CalendarEventReplaceResult',
      'receipts': receipts.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventReplaceResult',
      'receipts': receipts.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarEventReplaceResultImpl extends CalendarEventReplaceResult {
  const _CalendarEventReplaceResultImpl({
    required List<_ii1x02jx.CalendarEventReplaceReceipt> receipts,
  }) : super._(receipts: receipts);

  /// Returns a shallow copy of this [CalendarEventReplaceResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventReplaceResult copyWith({
    List<_ii1x02jx.CalendarEventReplaceReceipt>? receipts,
  }) {
    return CalendarEventReplaceResult(
      receipts: receipts ?? this.receipts.map((e0) => e0.copyWith()).toList(),
    );
  }
}
