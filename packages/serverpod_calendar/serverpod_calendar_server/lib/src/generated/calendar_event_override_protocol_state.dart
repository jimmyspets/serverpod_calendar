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
import 'calendar_event_protocol_version.dart' as _iblfo3t0;
import 'calendar_event_timing.dart' as _ieswiaty;

@_is.immutable
abstract class CalendarEventOverrideProtocolState
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventOverrideProtocolState._({
    required this.originalStart,
    bool? isThisAndFuture,
    required this.version,
    bool? summaryPresent,
    bool? descriptionPresent,
    bool? locationPresent,
    bool? statusPresent,
    bool? transparencyPresent,
  }) : isThisAndFuture = isThisAndFuture ?? false,
       summaryPresent = summaryPresent ?? false,
       descriptionPresent = descriptionPresent ?? false,
       locationPresent = locationPresent ?? false,
       statusPresent = statusPresent ?? false,
       transparencyPresent = transparencyPresent ?? false;

  const factory CalendarEventOverrideProtocolState({
    required _ieswiaty.CalendarEventTiming originalStart,
    bool? isThisAndFuture,
    required _iblfo3t0.CalendarEventProtocolVersion version,
    bool? summaryPresent,
    bool? descriptionPresent,
    bool? locationPresent,
    bool? statusPresent,
    bool? transparencyPresent,
  }) = _CalendarEventOverrideProtocolStateImpl;

  factory CalendarEventOverrideProtocolState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOverrideProtocolState(
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      isThisAndFuture: jsonSerialization['isThisAndFuture'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['isThisAndFuture'],
            ),
      version: _ix00hwbf.Protocol()
          .deserialize<_iblfo3t0.CalendarEventProtocolVersion>(
            jsonSerialization['version'],
          ),
      summaryPresent: jsonSerialization['summaryPresent'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['summaryPresent']),
      descriptionPresent: jsonSerialization['descriptionPresent'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['descriptionPresent'],
            ),
      locationPresent: jsonSerialization['locationPresent'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['locationPresent'],
            ),
      statusPresent: jsonSerialization['statusPresent'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['statusPresent']),
      transparencyPresent: jsonSerialization['transparencyPresent'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['transparencyPresent'],
            ),
    );
  }

  final _ieswiaty.CalendarEventTiming originalStart;

  final bool isThisAndFuture;

  final _iblfo3t0.CalendarEventProtocolVersion version;

  final bool summaryPresent;

  final bool descriptionPresent;

  final bool locationPresent;

  final bool statusPresent;

  final bool transparencyPresent;

  /// Returns a shallow copy of this [CalendarEventOverrideProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventOverrideProtocolState copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    bool? isThisAndFuture,
    _iblfo3t0.CalendarEventProtocolVersion? version,
    bool? summaryPresent,
    bool? descriptionPresent,
    bool? locationPresent,
    bool? statusPresent,
    bool? transparencyPresent,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOverrideProtocolState &&
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
                other.version == version) &&
            (identical(
                  other.summaryPresent,
                  summaryPresent,
                ) ||
                other.summaryPresent == summaryPresent) &&
            (identical(
                  other.descriptionPresent,
                  descriptionPresent,
                ) ||
                other.descriptionPresent == descriptionPresent) &&
            (identical(
                  other.locationPresent,
                  locationPresent,
                ) ||
                other.locationPresent == locationPresent) &&
            (identical(
                  other.statusPresent,
                  statusPresent,
                ) ||
                other.statusPresent == statusPresent) &&
            (identical(
                  other.transparencyPresent,
                  transparencyPresent,
                ) ||
                other.transparencyPresent == transparencyPresent);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      originalStart,
      isThisAndFuture,
      version,
      summaryPresent,
      descriptionPresent,
      locationPresent,
      statusPresent,
      transparencyPresent,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOverrideProtocolState',
      'originalStart': originalStart.toJson(),
      'isThisAndFuture': isThisAndFuture,
      'version': version.toJson(),
      'summaryPresent': summaryPresent,
      'descriptionPresent': descriptionPresent,
      'locationPresent': locationPresent,
      'statusPresent': statusPresent,
      'transparencyPresent': transparencyPresent,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarEventOverrideProtocolStateImpl
    extends CalendarEventOverrideProtocolState {
  const _CalendarEventOverrideProtocolStateImpl({
    required _ieswiaty.CalendarEventTiming originalStart,
    bool? isThisAndFuture,
    required _iblfo3t0.CalendarEventProtocolVersion version,
    bool? summaryPresent,
    bool? descriptionPresent,
    bool? locationPresent,
    bool? statusPresent,
    bool? transparencyPresent,
  }) : super._(
         originalStart: originalStart,
         isThisAndFuture: isThisAndFuture,
         version: version,
         summaryPresent: summaryPresent,
         descriptionPresent: descriptionPresent,
         locationPresent: locationPresent,
         statusPresent: statusPresent,
         transparencyPresent: transparencyPresent,
       );

  /// Returns a shallow copy of this [CalendarEventOverrideProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventOverrideProtocolState copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    bool? isThisAndFuture,
    _iblfo3t0.CalendarEventProtocolVersion? version,
    bool? summaryPresent,
    bool? descriptionPresent,
    bool? locationPresent,
    bool? statusPresent,
    bool? transparencyPresent,
  }) {
    return CalendarEventOverrideProtocolState(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      isThisAndFuture: isThisAndFuture ?? this.isThisAndFuture,
      version: version ?? this.version.copyWith(),
      summaryPresent: summaryPresent ?? this.summaryPresent,
      descriptionPresent: descriptionPresent ?? this.descriptionPresent,
      locationPresent: locationPresent ?? this.locationPresent,
      statusPresent: statusPresent ?? this.statusPresent,
      transparencyPresent: transparencyPresent ?? this.transparencyPresent,
    );
  }
}
