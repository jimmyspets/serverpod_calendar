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

import 'calendar_free_busy_delivery_view.dart' as _i4xvuj0s;

@_is.immutable
abstract class CalendarFreeBusyDeliveryPage
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarFreeBusyDeliveryPage._({
    required this.items,
    this.cursor,
  });

  const factory CalendarFreeBusyDeliveryPage({
    required List<_i4xvuj0s.CalendarFreeBusyDeliveryView> items,
    String? cursor,
  }) = _CalendarFreeBusyDeliveryPageImpl;

  factory CalendarFreeBusyDeliveryPage.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyDeliveryPage(
      items: _ix00hwbf.Protocol()
          .deserialize<List<_i4xvuj0s.CalendarFreeBusyDeliveryView>>(
            jsonSerialization['items'],
          ),
      cursor: jsonSerialization['cursor'] as String?,
    );
  }

  final List<_i4xvuj0s.CalendarFreeBusyDeliveryView> items;

  final String? cursor;

  /// Returns a shallow copy of this [CalendarFreeBusyDeliveryPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyDeliveryPage copyWith({
    List<_i4xvuj0s.CalendarFreeBusyDeliveryView>? items,
    String? cursor,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFreeBusyDeliveryPage &&
            const _iss.DeepCollectionEquality().equals(
              other.items,
              items,
            ) &&
            (identical(
                  other.cursor,
                  cursor,
                ) ||
                other.cursor == cursor);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(items),
      cursor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyDeliveryPage',
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyDeliveryPage',
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFreeBusyDeliveryPageImpl extends CalendarFreeBusyDeliveryPage {
  const _CalendarFreeBusyDeliveryPageImpl({
    required List<_i4xvuj0s.CalendarFreeBusyDeliveryView> items,
    String? cursor,
  }) : super._(
         items: items,
         cursor: cursor,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyDeliveryPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyDeliveryPage copyWith({
    List<_i4xvuj0s.CalendarFreeBusyDeliveryView>? items,
    Object? cursor = _Undefined,
  }) {
    return CalendarFreeBusyDeliveryPage(
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      cursor: cursor is String? ? cursor : this.cursor,
    );
  }
}
