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

@_isc.immutable
abstract class CalendarFreeBusyCommandReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarFreeBusyCommandReceipt._({
    required this.id,
    required this.commandId,
    required this.deliveryIds,
    required this.stamp,
  });

  const factory CalendarFreeBusyCommandReceipt({
    required _isc.UuidValue id,
    required _isc.UuidValue commandId,
    required List<_isc.UuidValue> deliveryIds,
    required DateTime stamp,
  }) = _CalendarFreeBusyCommandReceiptImpl;

  factory CalendarFreeBusyCommandReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyCommandReceipt(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      commandId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      deliveryIds: _ie4a1wrz.Protocol().deserialize<List<_isc.UuidValue>>(
        jsonSerialization['deliveryIds'],
      ),
      stamp: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
    );
  }

  final _isc.UuidValue id;

  final _isc.UuidValue commandId;

  final List<_isc.UuidValue> deliveryIds;

  final DateTime stamp;

  /// Returns a shallow copy of this [CalendarFreeBusyCommandReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarFreeBusyCommandReceipt copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? commandId,
    List<_isc.UuidValue>? deliveryIds,
    DateTime? stamp,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFreeBusyCommandReceipt &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.commandId,
                  commandId,
                ) ||
                other.commandId == commandId) &&
            const _iss.DeepCollectionEquality().equals(
              other.deliveryIds,
              deliveryIds,
            ) &&
            (identical(
                  other.stamp,
                  stamp,
                ) ||
                other.stamp == stamp);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      commandId,
      const _iss.DeepCollectionEquality().hash(deliveryIds),
      stamp,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyCommandReceipt',
      'id': id.toJson(),
      'commandId': commandId.toJson(),
      'deliveryIds': deliveryIds.toJson(valueToJson: (v) => v.toJson()),
      'stamp': stamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyCommandReceipt',
      'id': id.toJson(),
      'commandId': commandId.toJson(),
      'deliveryIds': deliveryIds.toJson(valueToJson: (v) => v.toJson()),
      'stamp': stamp.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyCommandReceiptImpl
    extends CalendarFreeBusyCommandReceipt {
  const _CalendarFreeBusyCommandReceiptImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue commandId,
    required List<_isc.UuidValue> deliveryIds,
    required DateTime stamp,
  }) : super._(
         id: id,
         commandId: commandId,
         deliveryIds: deliveryIds,
         stamp: stamp,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyCommandReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarFreeBusyCommandReceipt copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? commandId,
    List<_isc.UuidValue>? deliveryIds,
    DateTime? stamp,
  }) {
    return CalendarFreeBusyCommandReceipt(
      id: id ?? this.id,
      commandId: commandId ?? this.commandId,
      deliveryIds: deliveryIds ?? this.deliveryIds.map((e0) => e0).toList(),
      stamp: stamp ?? this.stamp,
    );
  }
}
