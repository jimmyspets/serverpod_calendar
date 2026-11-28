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
abstract class CalendarFreeBusyPublishRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarFreeBusyPublishRequest._({
    required this.commandId,
    required this.calendarId,
    required this.fromUtc,
    required this.untilUtc,
    required this.recipients,
  });

  const factory CalendarFreeBusyPublishRequest({
    required _is.UuidValue commandId,
    required _is.UuidValue calendarId,
    required DateTime fromUtc,
    required DateTime untilUtc,
    required List<String> recipients,
  }) = _CalendarFreeBusyPublishRequestImpl;

  factory CalendarFreeBusyPublishRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyPublishRequest(
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      fromUtc: _is.DateTimeJsonExtension.fromJson(jsonSerialization['fromUtc']),
      untilUtc: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['untilUtc'],
      ),
      recipients: _ix00hwbf.Protocol().deserialize<List<String>>(
        jsonSerialization['recipients'],
      ),
    );
  }

  final _is.UuidValue commandId;

  final _is.UuidValue calendarId;

  final DateTime fromUtc;

  final DateTime untilUtc;

  final List<String> recipients;

  /// Returns a shallow copy of this [CalendarFreeBusyPublishRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyPublishRequest copyWith({
    _is.UuidValue? commandId,
    _is.UuidValue? calendarId,
    DateTime? fromUtc,
    DateTime? untilUtc,
    List<String>? recipients,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFreeBusyPublishRequest &&
            (identical(
                  other.commandId,
                  commandId,
                ) ||
                other.commandId == commandId) &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.fromUtc,
                  fromUtc,
                ) ||
                other.fromUtc == fromUtc) &&
            (identical(
                  other.untilUtc,
                  untilUtc,
                ) ||
                other.untilUtc == untilUtc) &&
            const _iss.DeepCollectionEquality().equals(
              other.recipients,
              recipients,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      commandId,
      calendarId,
      fromUtc,
      untilUtc,
      const _iss.DeepCollectionEquality().hash(recipients),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyPublishRequest',
      'commandId': commandId.toJson(),
      'calendarId': calendarId.toJson(),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'recipients': recipients.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyPublishRequest',
      'commandId': commandId.toJson(),
      'calendarId': calendarId.toJson(),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'recipients': recipients.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyPublishRequestImpl
    extends CalendarFreeBusyPublishRequest {
  const _CalendarFreeBusyPublishRequestImpl({
    required _is.UuidValue commandId,
    required _is.UuidValue calendarId,
    required DateTime fromUtc,
    required DateTime untilUtc,
    required List<String> recipients,
  }) : super._(
         commandId: commandId,
         calendarId: calendarId,
         fromUtc: fromUtc,
         untilUtc: untilUtc,
         recipients: recipients,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyPublishRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyPublishRequest copyWith({
    _is.UuidValue? commandId,
    _is.UuidValue? calendarId,
    DateTime? fromUtc,
    DateTime? untilUtc,
    List<String>? recipients,
  }) {
    return CalendarFreeBusyPublishRequest(
      commandId: commandId ?? this.commandId,
      calendarId: calendarId ?? this.calendarId,
      fromUtc: fromUtc ?? this.fromUtc,
      untilUtc: untilUtc ?? this.untilUtc,
      recipients: recipients ?? this.recipients.map((e0) => e0).toList(),
    );
  }
}
