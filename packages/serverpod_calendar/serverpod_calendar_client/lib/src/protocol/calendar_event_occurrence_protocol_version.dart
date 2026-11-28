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
import 'calendar_event_protocol_version.dart' as _iblfo3t0;
import 'calendar_event_timing.dart' as _ieswiaty;

@_isc.immutable
abstract class CalendarEventOccurrenceProtocolVersion
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventOccurrenceProtocolVersion._({
    required this.originalStart,
    bool? isThisAndFuture,
    required this.version,
  }) : isThisAndFuture = isThisAndFuture ?? false;

  const factory CalendarEventOccurrenceProtocolVersion({
    required _ieswiaty.CalendarEventTiming originalStart,
    bool? isThisAndFuture,
    required _iblfo3t0.CalendarEventProtocolVersion version,
  }) = _CalendarEventOccurrenceProtocolVersionImpl;

  factory CalendarEventOccurrenceProtocolVersion.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrenceProtocolVersion(
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      isThisAndFuture: jsonSerialization['isThisAndFuture'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['isThisAndFuture'],
            ),
      version: _ie4a1wrz.Protocol()
          .deserialize<_iblfo3t0.CalendarEventProtocolVersion>(
            jsonSerialization['version'],
          ),
    );
  }

  final _ieswiaty.CalendarEventTiming originalStart;

  final bool isThisAndFuture;

  final _iblfo3t0.CalendarEventProtocolVersion version;

  /// Returns a shallow copy of this [CalendarEventOccurrenceProtocolVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventOccurrenceProtocolVersion copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    bool? isThisAndFuture,
    _iblfo3t0.CalendarEventProtocolVersion? version,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOccurrenceProtocolVersion &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.isThisAndFuture,
                  isThisAndFuture,
                ) ||
                other.isThisAndFuture == isThisAndFuture) &&
            (identical(
                  other.version,
                  version,
                ) ||
                other.version == version);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      originalStart,
      isThisAndFuture,
      version,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarEventOccurrenceProtocolVersion',
      'originalStart': originalStart.toJson(),
      'isThisAndFuture': isThisAndFuture,
      'version': version.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarEventOccurrenceProtocolVersion',
      'originalStart': originalStart.toJsonForProtocol(),
      'isThisAndFuture': isThisAndFuture,
      'version': version.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarEventOccurrenceProtocolVersionImpl
    extends CalendarEventOccurrenceProtocolVersion {
  const _CalendarEventOccurrenceProtocolVersionImpl({
    required _ieswiaty.CalendarEventTiming originalStart,
    bool? isThisAndFuture,
    required _iblfo3t0.CalendarEventProtocolVersion version,
  }) : super._(
         originalStart: originalStart,
         isThisAndFuture: isThisAndFuture,
         version: version,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrenceProtocolVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventOccurrenceProtocolVersion copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    bool? isThisAndFuture,
    _iblfo3t0.CalendarEventProtocolVersion? version,
  }) {
    return CalendarEventOccurrenceProtocolVersion(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      isThisAndFuture: isThisAndFuture ?? this.isThisAndFuture,
      version: version ?? this.version.copyWith(),
    );
  }
}
