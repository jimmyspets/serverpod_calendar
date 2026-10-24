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
import 'calendar_alarm_anchor.dart' as _iv448ru6;
import 'calendar_alarm_duration.dart' as _i1qnv8jf;

@_isc.immutable
abstract class CalendarAlarmDefinition
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAlarmDefinition._({
    this.absoluteUtc,
    this.relativeDuration,
    this.anchor,
    this.dateZoneId,
    this.repeat,
    this.repeatInterval,
  });

  const factory CalendarAlarmDefinition({
    DateTime? absoluteUtc,
    _i1qnv8jf.CalendarAlarmDuration? relativeDuration,
    _iv448ru6.CalendarAlarmAnchor? anchor,
    String? dateZoneId,
    int? repeat,
    _i1qnv8jf.CalendarAlarmDuration? repeatInterval,
  }) = _CalendarAlarmDefinitionImpl;

  factory CalendarAlarmDefinition.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmDefinition(
      absoluteUtc: jsonSerialization['absoluteUtc'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['absoluteUtc'],
            ),
      relativeDuration: jsonSerialization['relativeDuration'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i1qnv8jf.CalendarAlarmDuration>(
              jsonSerialization['relativeDuration'],
            ),
      anchor: jsonSerialization['anchor'] == null
          ? null
          : _iv448ru6.CalendarAlarmAnchor.fromJson(
              (jsonSerialization['anchor'] as String),
            ),
      dateZoneId: jsonSerialization['dateZoneId'] as String?,
      repeat: jsonSerialization['repeat'] as int?,
      repeatInterval: jsonSerialization['repeatInterval'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i1qnv8jf.CalendarAlarmDuration>(
              jsonSerialization['repeatInterval'],
            ),
    );
  }

  final DateTime? absoluteUtc;

  final _i1qnv8jf.CalendarAlarmDuration? relativeDuration;

  final _iv448ru6.CalendarAlarmAnchor? anchor;

  final String? dateZoneId;

  final int? repeat;

  final _i1qnv8jf.CalendarAlarmDuration? repeatInterval;

  /// Returns a shallow copy of this [CalendarAlarmDefinition]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAlarmDefinition copyWith({
    DateTime? absoluteUtc,
    _i1qnv8jf.CalendarAlarmDuration? relativeDuration,
    _iv448ru6.CalendarAlarmAnchor? anchor,
    String? dateZoneId,
    int? repeat,
    _i1qnv8jf.CalendarAlarmDuration? repeatInterval,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAlarmDefinition &&
            (identical(
                  other.absoluteUtc,
                  absoluteUtc,
                ) ||
                other.absoluteUtc == absoluteUtc) &&
            (identical(
                  other.relativeDuration,
                  relativeDuration,
                ) ||
                other.relativeDuration == relativeDuration) &&
            (identical(
                  other.anchor,
                  anchor,
                ) ||
                other.anchor == anchor) &&
            (identical(
                  other.dateZoneId,
                  dateZoneId,
                ) ||
                other.dateZoneId == dateZoneId) &&
            (identical(
                  other.repeat,
                  repeat,
                ) ||
                other.repeat == repeat) &&
            (identical(
                  other.repeatInterval,
                  repeatInterval,
                ) ||
                other.repeatInterval == repeatInterval);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      absoluteUtc,
      relativeDuration,
      anchor,
      dateZoneId,
      repeat,
      repeatInterval,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmDefinition',
      if (absoluteUtc != null) 'absoluteUtc': absoluteUtc?.toJson(),
      if (relativeDuration != null)
        'relativeDuration': relativeDuration?.toJson(),
      if (anchor != null) 'anchor': anchor?.toJson(),
      if (dateZoneId != null) 'dateZoneId': dateZoneId,
      if (repeat != null) 'repeat': repeat,
      if (repeatInterval != null) 'repeatInterval': repeatInterval?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmDefinition',
      if (absoluteUtc != null) 'absoluteUtc': absoluteUtc?.toJson(),
      if (relativeDuration != null)
        'relativeDuration': relativeDuration?.toJsonForProtocol(),
      if (anchor != null) 'anchor': anchor?.toJson(),
      if (dateZoneId != null) 'dateZoneId': dateZoneId,
      if (repeat != null) 'repeat': repeat,
      if (repeatInterval != null)
        'repeatInterval': repeatInterval?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAlarmDefinitionImpl extends CalendarAlarmDefinition {
  const _CalendarAlarmDefinitionImpl({
    DateTime? absoluteUtc,
    _i1qnv8jf.CalendarAlarmDuration? relativeDuration,
    _iv448ru6.CalendarAlarmAnchor? anchor,
    String? dateZoneId,
    int? repeat,
    _i1qnv8jf.CalendarAlarmDuration? repeatInterval,
  }) : super._(
         absoluteUtc: absoluteUtc,
         relativeDuration: relativeDuration,
         anchor: anchor,
         dateZoneId: dateZoneId,
         repeat: repeat,
         repeatInterval: repeatInterval,
       );

  /// Returns a shallow copy of this [CalendarAlarmDefinition]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAlarmDefinition copyWith({
    Object? absoluteUtc = _Undefined,
    Object? relativeDuration = _Undefined,
    Object? anchor = _Undefined,
    Object? dateZoneId = _Undefined,
    Object? repeat = _Undefined,
    Object? repeatInterval = _Undefined,
  }) {
    return CalendarAlarmDefinition(
      absoluteUtc: absoluteUtc is DateTime? ? absoluteUtc : this.absoluteUtc,
      relativeDuration: relativeDuration is _i1qnv8jf.CalendarAlarmDuration?
          ? relativeDuration
          : this.relativeDuration?.copyWith(),
      anchor: anchor is _iv448ru6.CalendarAlarmAnchor? ? anchor : this.anchor,
      dateZoneId: dateZoneId is String? ? dateZoneId : this.dateZoneId,
      repeat: repeat is int? ? repeat : this.repeat,
      repeatInterval: repeatInterval is _i1qnv8jf.CalendarAlarmDuration?
          ? repeatInterval
          : this.repeatInterval?.copyWith(),
    );
  }
}
