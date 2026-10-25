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
import 'calendar_alarm_action_view.dart' as _ixqjnkie;
import 'calendar_alarm_firing_view.dart' as _i7xuciin;

@_isc.immutable
abstract class CalendarAlarmActivityPage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAlarmActivityPage._({
    required this.firings,
    required this.actions,
    this.nextCursor,
  });

  const factory CalendarAlarmActivityPage({
    required List<_i7xuciin.CalendarAlarmFiringView> firings,
    required List<_ixqjnkie.CalendarAlarmActionView> actions,
    String? nextCursor,
  }) = _CalendarAlarmActivityPageImpl;

  factory CalendarAlarmActivityPage.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmActivityPage(
      firings: _ie4a1wrz.Protocol()
          .deserialize<List<_i7xuciin.CalendarAlarmFiringView>>(
            jsonSerialization['firings'],
          ),
      actions: _ie4a1wrz.Protocol()
          .deserialize<List<_ixqjnkie.CalendarAlarmActionView>>(
            jsonSerialization['actions'],
          ),
      nextCursor: jsonSerialization['nextCursor'] as String?,
    );
  }

  final List<_i7xuciin.CalendarAlarmFiringView> firings;

  final List<_ixqjnkie.CalendarAlarmActionView> actions;

  final String? nextCursor;

  /// Returns a shallow copy of this [CalendarAlarmActivityPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAlarmActivityPage copyWith({
    List<_i7xuciin.CalendarAlarmFiringView>? firings,
    List<_ixqjnkie.CalendarAlarmActionView>? actions,
    String? nextCursor,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAlarmActivityPage &&
            const _iss.DeepCollectionEquality().equals(
              other.firings,
              firings,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.actions,
              actions,
            ) &&
            (identical(
                  other.nextCursor,
                  nextCursor,
                ) ||
                other.nextCursor == nextCursor);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(firings),
      const _iss.DeepCollectionEquality().hash(actions),
      nextCursor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmActivityPage',
      'firings': firings.toJson(valueToJson: (v) => v.toJson()),
      'actions': actions.toJson(valueToJson: (v) => v.toJson()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmActivityPage',
      'firings': firings.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'actions': actions.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAlarmActivityPageImpl extends CalendarAlarmActivityPage {
  const _CalendarAlarmActivityPageImpl({
    required List<_i7xuciin.CalendarAlarmFiringView> firings,
    required List<_ixqjnkie.CalendarAlarmActionView> actions,
    String? nextCursor,
  }) : super._(
         firings: firings,
         actions: actions,
         nextCursor: nextCursor,
       );

  /// Returns a shallow copy of this [CalendarAlarmActivityPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAlarmActivityPage copyWith({
    List<_i7xuciin.CalendarAlarmFiringView>? firings,
    List<_ixqjnkie.CalendarAlarmActionView>? actions,
    Object? nextCursor = _Undefined,
  }) {
    return CalendarAlarmActivityPage(
      firings: firings ?? this.firings.map((e0) => e0.copyWith()).toList(),
      actions: actions ?? this.actions.map((e0) => e0.copyWith()).toList(),
      nextCursor: nextCursor is String? ? nextCursor : this.nextCursor,
    );
  }
}
