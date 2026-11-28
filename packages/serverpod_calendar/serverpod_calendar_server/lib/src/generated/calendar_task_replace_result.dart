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
import 'calendar_task_replace_receipt.dart' as _ib5z6spp;

@_is.immutable
abstract class CalendarTaskReplaceResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskReplaceResult._({required this.receipts});

  const factory CalendarTaskReplaceResult({
    required List<_ib5z6spp.CalendarTaskReplaceReceipt> receipts,
  }) = _CalendarTaskReplaceResultImpl;

  factory CalendarTaskReplaceResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskReplaceResult(
      receipts: _ix00hwbf.Protocol()
          .deserialize<List<_ib5z6spp.CalendarTaskReplaceReceipt>>(
            jsonSerialization['receipts'],
          ),
    );
  }

  final List<_ib5z6spp.CalendarTaskReplaceReceipt> receipts;

  /// Returns a shallow copy of this [CalendarTaskReplaceResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskReplaceResult copyWith({
    List<_ib5z6spp.CalendarTaskReplaceReceipt>? receipts,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskReplaceResult &&
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
      '__className__': 'serverpod_calendar.CalendarTaskReplaceResult',
      'receipts': receipts.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskReplaceResult',
      'receipts': receipts.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarTaskReplaceResultImpl extends CalendarTaskReplaceResult {
  const _CalendarTaskReplaceResultImpl({
    required List<_ib5z6spp.CalendarTaskReplaceReceipt> receipts,
  }) : super._(receipts: receipts);

  /// Returns a shallow copy of this [CalendarTaskReplaceResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskReplaceResult copyWith({
    List<_ib5z6spp.CalendarTaskReplaceReceipt>? receipts,
  }) {
    return CalendarTaskReplaceResult(
      receipts: receipts ?? this.receipts.map((e0) => e0.copyWith()).toList(),
    );
  }
}
