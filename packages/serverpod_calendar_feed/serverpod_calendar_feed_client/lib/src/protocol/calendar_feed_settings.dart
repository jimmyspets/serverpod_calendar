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
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as _imrxcdin;
import 'package:serverpod_calendar_feed_client/src/protocol/protocol.dart'
    as _ip8jx9v6;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

@_isc.immutable
abstract class CalendarFeedSettings
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarFeedSettings._({
    required this.displayName,
    required this.calendarIds,
    this.protocolMetadata,
    this.supplementalMetadata,
  });

  const factory CalendarFeedSettings({
    required String displayName,
    required List<_isc.UuidValue> calendarIds,
    _imrxcdin.CalendarProtocolMetadata? protocolMetadata,
    _imrxcdin.CalendarSupplementalMetadata? supplementalMetadata,
  }) = _CalendarFeedSettingsImpl;

  factory CalendarFeedSettings.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFeedSettings(
      displayName: jsonSerialization['displayName'] as String,
      calendarIds: _ip8jx9v6.Protocol().deserialize<List<_isc.UuidValue>>(
        jsonSerialization['calendarIds'],
      ),
      protocolMetadata: jsonSerialization['protocolMetadata'] == null
          ? null
          : _ip8jx9v6.Protocol()
                .deserialize<_imrxcdin.CalendarProtocolMetadata>(
                  jsonSerialization['protocolMetadata'],
                ),
      supplementalMetadata: jsonSerialization['supplementalMetadata'] == null
          ? null
          : _ip8jx9v6.Protocol()
                .deserialize<_imrxcdin.CalendarSupplementalMetadata>(
                  jsonSerialization['supplementalMetadata'],
                ),
    );
  }

  final String displayName;

  final List<_isc.UuidValue> calendarIds;

  final _imrxcdin.CalendarProtocolMetadata? protocolMetadata;

  final _imrxcdin.CalendarSupplementalMetadata? supplementalMetadata;

  /// Returns a shallow copy of this [CalendarFeedSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarFeedSettings copyWith({
    String? displayName,
    List<_isc.UuidValue>? calendarIds,
    _imrxcdin.CalendarProtocolMetadata? protocolMetadata,
    _imrxcdin.CalendarSupplementalMetadata? supplementalMetadata,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFeedSettings &&
            (identical(
                  other.displayName,
                  displayName,
                ) ||
                other.displayName == displayName) &&
            const _iss.DeepCollectionEquality().equals(
              other.calendarIds,
              calendarIds,
            ) &&
            (identical(
                  other.protocolMetadata,
                  protocolMetadata,
                ) ||
                other.protocolMetadata == protocolMetadata) &&
            (identical(
                  other.supplementalMetadata,
                  supplementalMetadata,
                ) ||
                other.supplementalMetadata == supplementalMetadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      displayName,
      const _iss.DeepCollectionEquality().hash(calendarIds),
      protocolMetadata,
      supplementalMetadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedSettings',
      'displayName': displayName,
      'calendarIds': calendarIds.toJson(valueToJson: (v) => v.toJson()),
      if (protocolMetadata != null)
        'protocolMetadata': protocolMetadata?.toJson(),
      if (supplementalMetadata != null)
        'supplementalMetadata': supplementalMetadata?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedSettings',
      'displayName': displayName,
      'calendarIds': calendarIds.toJson(valueToJson: (v) => v.toJson()),
      if (protocolMetadata != null)
        'protocolMetadata': protocolMetadata?.toJson(),
      if (supplementalMetadata != null)
        'supplementalMetadata': supplementalMetadata?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFeedSettingsImpl extends CalendarFeedSettings {
  const _CalendarFeedSettingsImpl({
    required String displayName,
    required List<_isc.UuidValue> calendarIds,
    _imrxcdin.CalendarProtocolMetadata? protocolMetadata,
    _imrxcdin.CalendarSupplementalMetadata? supplementalMetadata,
  }) : super._(
         displayName: displayName,
         calendarIds: calendarIds,
         protocolMetadata: protocolMetadata,
         supplementalMetadata: supplementalMetadata,
       );

  /// Returns a shallow copy of this [CalendarFeedSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarFeedSettings copyWith({
    String? displayName,
    List<_isc.UuidValue>? calendarIds,
    Object? protocolMetadata = _Undefined,
    Object? supplementalMetadata = _Undefined,
  }) {
    return CalendarFeedSettings(
      displayName: displayName ?? this.displayName,
      calendarIds: calendarIds ?? this.calendarIds.map((e0) => e0).toList(),
      protocolMetadata: protocolMetadata is _imrxcdin.CalendarProtocolMetadata?
          ? protocolMetadata
          : this.protocolMetadata?.copyWith(),
      supplementalMetadata:
          supplementalMetadata is _imrxcdin.CalendarSupplementalMetadata?
          ? supplementalMetadata
          : this.supplementalMetadata?.copyWith(),
    );
  }
}
