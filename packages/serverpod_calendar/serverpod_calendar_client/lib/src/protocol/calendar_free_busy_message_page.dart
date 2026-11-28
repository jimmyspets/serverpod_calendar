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

import 'calendar_free_busy_message_view.dart' as _iu6vjwqv;

@_isc.immutable
abstract class CalendarFreeBusyMessagePage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarFreeBusyMessagePage._({
    required this.items,
    this.cursor,
  });

  const factory CalendarFreeBusyMessagePage({
    required List<_iu6vjwqv.CalendarFreeBusyMessageView> items,
    String? cursor,
  }) = _CalendarFreeBusyMessagePageImpl;

  factory CalendarFreeBusyMessagePage.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyMessagePage(
      items: _ie4a1wrz.Protocol()
          .deserialize<List<_iu6vjwqv.CalendarFreeBusyMessageView>>(
            jsonSerialization['items'],
          ),
      cursor: jsonSerialization['cursor'] as String?,
    );
  }

  final List<_iu6vjwqv.CalendarFreeBusyMessageView> items;

  final String? cursor;

  /// Returns a shallow copy of this [CalendarFreeBusyMessagePage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarFreeBusyMessagePage copyWith({
    List<_iu6vjwqv.CalendarFreeBusyMessageView>? items,
    String? cursor,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFreeBusyMessagePage &&
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
      '__className__': 'serverpod_calendar.CalendarFreeBusyMessagePage',
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyMessagePage',
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFreeBusyMessagePageImpl extends CalendarFreeBusyMessagePage {
  const _CalendarFreeBusyMessagePageImpl({
    required List<_iu6vjwqv.CalendarFreeBusyMessageView> items,
    String? cursor,
  }) : super._(
         items: items,
         cursor: cursor,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyMessagePage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarFreeBusyMessagePage copyWith({
    List<_iu6vjwqv.CalendarFreeBusyMessageView>? items,
    Object? cursor = _Undefined,
  }) {
    return CalendarFreeBusyMessagePage(
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      cursor: cursor is String? ? cursor : this.cursor,
    );
  }
}
