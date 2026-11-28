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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'calendar_alarm_parent_kind.dart' as _ig3zti62;

@_isc.immutable
abstract class CalendarAlarmParent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAlarmParent._({
    required this.id,
    required this.kind,
  });

  const factory CalendarAlarmParent({
    required _isc.UuidValue id,
    required _ig3zti62.CalendarAlarmParentKind kind,
  }) = _CalendarAlarmParentImpl;

  factory CalendarAlarmParent.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarAlarmParent(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      kind: _ig3zti62.CalendarAlarmParentKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
    );
  }

  final _ig3zti62.CalendarAlarmParentKind kind;

  final _isc.UuidValue id;

  /// Returns a shallow copy of this [CalendarAlarmParent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAlarmParent copyWith({
    _isc.UuidValue? id,
    _ig3zti62.CalendarAlarmParentKind? kind,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAlarmParent &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.kind,
                  kind,
                ) ||
                other.kind == kind);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      kind,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmParent',
      'id': id.toJson(),
      'kind': kind.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmParent',
      'id': id.toJson(),
      'kind': kind.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAlarmParentImpl extends CalendarAlarmParent {
  const _CalendarAlarmParentImpl({
    required _isc.UuidValue id,
    required _ig3zti62.CalendarAlarmParentKind kind,
  }) : super._(
         id: id,
         kind: kind,
       );

  /// Returns a shallow copy of this [CalendarAlarmParent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAlarmParent copyWith({
    _isc.UuidValue? id,
    _ig3zti62.CalendarAlarmParentKind? kind,
  }) {
    return CalendarAlarmParent(
      id: id ?? this.id,
      kind: kind ?? this.kind,
    );
  }
}
