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

abstract class CalendarRefreshResendCommand
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarRefreshResendCommand._({
    required this.eventId,
    required this.requestId,
    required this.commandId,
    required this.publicationId,
    required this.generation,
  });

  factory CalendarRefreshResendCommand({
    required _isc.UuidValue eventId,
    required _isc.UuidValue requestId,
    required _isc.UuidValue commandId,
    required _isc.UuidValue publicationId,
    required int generation,
  }) = _CalendarRefreshResendCommandImpl;

  factory CalendarRefreshResendCommand.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarRefreshResendCommand(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      requestId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestId'],
      ),
      commandId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      publicationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['publicationId'],
      ),
      generation: jsonSerialization['generation'] as int,
    );
  }

  _isc.UuidValue eventId;

  _isc.UuidValue requestId;

  _isc.UuidValue commandId;

  _isc.UuidValue publicationId;

  int generation;

  /// Returns a shallow copy of this [CalendarRefreshResendCommand]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarRefreshResendCommand copyWith({
    _isc.UuidValue? eventId,
    _isc.UuidValue? requestId,
    _isc.UuidValue? commandId,
    _isc.UuidValue? publicationId,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarRefreshResendCommandImpl extends CalendarRefreshResendCommand {
  _CalendarRefreshResendCommandImpl({
    required _isc.UuidValue eventId,
    required _isc.UuidValue requestId,
    required _isc.UuidValue commandId,
    required _isc.UuidValue publicationId,
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
  @_isc.useResult
  @override
  CalendarRefreshResendCommand copyWith({
    _isc.UuidValue? eventId,
    _isc.UuidValue? requestId,
    _isc.UuidValue? commandId,
    _isc.UuidValue? publicationId,
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
