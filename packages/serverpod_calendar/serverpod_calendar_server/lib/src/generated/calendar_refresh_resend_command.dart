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

abstract class CalendarRefreshResendCommand
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarRefreshResendCommand._({
    required this.eventId,
    required this.requestId,
    required this.commandId,
    required this.publicationId,
    required this.generation,
  });

  factory CalendarRefreshResendCommand({
    required _is.UuidValue eventId,
    required _is.UuidValue requestId,
    required _is.UuidValue commandId,
    required _is.UuidValue publicationId,
    required int generation,
  }) = _CalendarRefreshResendCommandImpl;

  factory CalendarRefreshResendCommand.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarRefreshResendCommand(
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      requestId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestId'],
      ),
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      publicationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['publicationId'],
      ),
      generation: jsonSerialization['generation'] as int,
    );
  }

  _is.UuidValue eventId;

  _is.UuidValue requestId;

  _is.UuidValue commandId;

  _is.UuidValue publicationId;

  int generation;

  /// Returns a shallow copy of this [CalendarRefreshResendCommand]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarRefreshResendCommand copyWith({
    _is.UuidValue? eventId,
    _is.UuidValue? requestId,
    _is.UuidValue? commandId,
    _is.UuidValue? publicationId,
    int? generation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshResendCommand',
      'eventId': eventId.toJson(),
      'requestId': requestId.toJson(),
      'commandId': commandId.toJson(),
      'publicationId': publicationId.toJson(),
      'generation': generation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshResendCommand',
      'eventId': eventId.toJson(),
      'requestId': requestId.toJson(),
      'commandId': commandId.toJson(),
      'publicationId': publicationId.toJson(),
      'generation': generation,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarRefreshResendCommandImpl extends CalendarRefreshResendCommand {
  _CalendarRefreshResendCommandImpl({
    required _is.UuidValue eventId,
    required _is.UuidValue requestId,
    required _is.UuidValue commandId,
    required _is.UuidValue publicationId,
    required int generation,
  }) : super._(
         eventId: eventId,
         requestId: requestId,
         commandId: commandId,
         publicationId: publicationId,
         generation: generation,
       );

  /// Returns a shallow copy of this [CalendarRefreshResendCommand]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarRefreshResendCommand copyWith({
    _is.UuidValue? eventId,
    _is.UuidValue? requestId,
    _is.UuidValue? commandId,
    _is.UuidValue? publicationId,
    int? generation,
  }) {
    return CalendarRefreshResendCommand(
      eventId: eventId ?? this.eventId,
      requestId: requestId ?? this.requestId,
      commandId: commandId ?? this.commandId,
      publicationId: publicationId ?? this.publicationId,
      generation: generation ?? this.generation,
    );
  }
}
