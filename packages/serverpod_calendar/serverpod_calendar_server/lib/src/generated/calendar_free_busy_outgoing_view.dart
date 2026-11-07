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

@_is.immutable
abstract class CalendarFreeBusyOutgoingView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarFreeBusyOutgoingView._({
    required this.id,
    required this.commandId,
    required this.method,
    required this.stamp,
    required this.expiresAt,
    this.terminalAt,
  });

  const factory CalendarFreeBusyOutgoingView({
    required _is.UuidValue id,
    required _is.UuidValue commandId,
    required String method,
    required DateTime stamp,
    required DateTime expiresAt,
    DateTime? terminalAt,
  }) = _CalendarFreeBusyOutgoingViewImpl;

  factory CalendarFreeBusyOutgoingView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyOutgoingView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      method: jsonSerialization['method'] as String,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      terminalAt: jsonSerialization['terminalAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['terminalAt']),
    );
  }

  final _is.UuidValue id;

  final _is.UuidValue commandId;

  final String method;

  final DateTime stamp;

  final DateTime expiresAt;

  final DateTime? terminalAt;

  /// Returns a shallow copy of this [CalendarFreeBusyOutgoingView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyOutgoingView copyWith({
    _is.UuidValue? id,
    _is.UuidValue? commandId,
    String? method,
    DateTime? stamp,
    DateTime? expiresAt,
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFreeBusyOutgoingView &&
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
            (identical(
                  other.method,
                  method,
                ) ||
                other.method == method) &&
            (identical(
                  other.stamp,
                  stamp,
                ) ||
                other.stamp == stamp) &&
            (identical(
                  other.expiresAt,
                  expiresAt,
                ) ||
                other.expiresAt == expiresAt) &&
            (identical(
                  other.terminalAt,
                  terminalAt,
                ) ||
                other.terminalAt == terminalAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      commandId,
      method,
      stamp,
      expiresAt,
      terminalAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyOutgoingView',
      'id': id.toJson(),
      'commandId': commandId.toJson(),
      'method': method,
      'stamp': stamp.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyOutgoingView',
      'id': id.toJson(),
      'commandId': commandId.toJson(),
      'method': method,
      'stamp': stamp.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyOutgoingViewImpl extends CalendarFreeBusyOutgoingView {
  const _CalendarFreeBusyOutgoingViewImpl({
    required _is.UuidValue id,
    required _is.UuidValue commandId,
    required String method,
    required DateTime stamp,
    required DateTime expiresAt,
    DateTime? terminalAt,
  }) : super._(
         id: id,
         commandId: commandId,
         method: method,
         stamp: stamp,
         expiresAt: expiresAt,
         terminalAt: terminalAt,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyOutgoingView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyOutgoingView copyWith({
    _is.UuidValue? id,
    _is.UuidValue? commandId,
    String? method,
    DateTime? stamp,
    DateTime? expiresAt,
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarFreeBusyOutgoingView(
      id: id ?? this.id,
      commandId: commandId ?? this.commandId,
      method: method ?? this.method,
      stamp: stamp ?? this.stamp,
      expiresAt: expiresAt ?? this.expiresAt,
      terminalAt: terminalAt is _is.UndefinedSentinel
          ? this.terminalAt
          : terminalAt,
    );
  }
}
