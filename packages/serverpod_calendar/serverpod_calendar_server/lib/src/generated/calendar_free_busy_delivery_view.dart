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
abstract class CalendarFreeBusyDeliveryView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarFreeBusyDeliveryView._({
    required this.id,
    required this.commandId,
    required this.state,
    required this.attemptCount,
    required this.expiresAt,
    this.terminalAt,
  });

  const factory CalendarFreeBusyDeliveryView({
    required _is.UuidValue id,
    required _is.UuidValue commandId,
    required String state,
    required int attemptCount,
    required DateTime expiresAt,
    DateTime? terminalAt,
  }) = _CalendarFreeBusyDeliveryViewImpl;

  factory CalendarFreeBusyDeliveryView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyDeliveryView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      state: jsonSerialization['state'] as String,
      attemptCount: jsonSerialization['attemptCount'] as int,
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

  final String state;

  final int attemptCount;

  final DateTime expiresAt;

  final DateTime? terminalAt;

  /// Returns a shallow copy of this [CalendarFreeBusyDeliveryView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyDeliveryView copyWith({
    _is.UuidValue? id,
    _is.UuidValue? commandId,
    String? state,
    int? attemptCount,
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
            other is CalendarFreeBusyDeliveryView &&
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
                  other.state,
                  state,
                ) ||
                other.state == state) &&
            (identical(
                  other.attemptCount,
                  attemptCount,
                ) ||
                other.attemptCount == attemptCount) &&
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
      state,
      attemptCount,
      expiresAt,
      terminalAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyDeliveryView',
      'id': id.toJson(),
      'commandId': commandId.toJson(),
      'state': state,
      'attemptCount': attemptCount,
      'expiresAt': expiresAt.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyDeliveryView',
      'id': id.toJson(),
      'commandId': commandId.toJson(),
      'state': state,
      'attemptCount': attemptCount,
      'expiresAt': expiresAt.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyDeliveryViewImpl extends CalendarFreeBusyDeliveryView {
  const _CalendarFreeBusyDeliveryViewImpl({
    required _is.UuidValue id,
    required _is.UuidValue commandId,
    required String state,
    required int attemptCount,
    required DateTime expiresAt,
    DateTime? terminalAt,
  }) : super._(
         id: id,
         commandId: commandId,
         state: state,
         attemptCount: attemptCount,
         expiresAt: expiresAt,
         terminalAt: terminalAt,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyDeliveryView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyDeliveryView copyWith({
    _is.UuidValue? id,
    _is.UuidValue? commandId,
    String? state,
    int? attemptCount,
    DateTime? expiresAt,
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarFreeBusyDeliveryView(
      id: id ?? this.id,
      commandId: commandId ?? this.commandId,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      expiresAt: expiresAt ?? this.expiresAt,
      terminalAt: terminalAt is _is.UndefinedSentinel
          ? this.terminalAt
          : terminalAt,
    );
  }
}
