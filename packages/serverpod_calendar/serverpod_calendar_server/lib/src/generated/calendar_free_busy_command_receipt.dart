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

@_is.immutable
abstract class CalendarFreeBusyCommandReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarFreeBusyCommandReceipt._({
    required this.id,
    required this.commandId,
    required this.deliveryIds,
    required this.stamp,
  });

  const factory CalendarFreeBusyCommandReceipt({
    required _is.UuidValue id,
    required _is.UuidValue commandId,
    required List<_is.UuidValue> deliveryIds,
    required DateTime stamp,
  }) = _CalendarFreeBusyCommandReceiptImpl;

  factory CalendarFreeBusyCommandReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyCommandReceipt(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      deliveryIds: _ix00hwbf.Protocol().deserialize<List<_is.UuidValue>>(
        jsonSerialization['deliveryIds'],
      ),
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
    );
  }

  final _is.UuidValue id;

  final _is.UuidValue commandId;

  final List<_is.UuidValue> deliveryIds;

  final DateTime stamp;

  /// Returns a shallow copy of this [CalendarFreeBusyCommandReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyCommandReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? commandId,
    List<_is.UuidValue>? deliveryIds,
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
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyCommandReceiptImpl
    extends CalendarFreeBusyCommandReceipt {
  const _CalendarFreeBusyCommandReceiptImpl({
    required _is.UuidValue id,
    required _is.UuidValue commandId,
    required List<_is.UuidValue> deliveryIds,
    required DateTime stamp,
  }) : super._(
         id: id,
         commandId: commandId,
         deliveryIds: deliveryIds,
         stamp: stamp,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyCommandReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyCommandReceipt copyWith({
    _is.UuidValue? id,
    _is.UuidValue? commandId,
    List<_is.UuidValue>? deliveryIds,
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
